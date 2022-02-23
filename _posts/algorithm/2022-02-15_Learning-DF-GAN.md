---
layout: default
title: Learning_DF_GAN.md
categories:
- Game
tags:
- Game
---
//Description: Learning_DF_GAN (学习DF_GAN)

//Create Date: 2022-02-15 11:48:39

//Author: channy

# 概述 
[DF-GAN](https://github.com/tobran/DF-GAN)

开发环境：python3 (3.9，在conda下) 
使用到的库：pytorch, numpy, pandas, PIL等。  

## 文件结构
--DF-GAN
 |--code
   |--cfg // 设置文件存放路径
     |--bird.yml
   |--miscc
     |--config.py
     |--utils.py 
   |--main.py
   |--datassets.py // 数据加载与处理
   |--DAMSM.py // 文字处理
 |--DAMSMencoders // 预处理模型存放路径
 |--data // 数据存放路径

### 主流程
--main (main.py)
 |--TextDataSet
 |--NetG & NetD
 |--RNN_ENCODER
 |--sampling/train

### 数据处理
|--TextDataSet (datasets.py)
  |--load_bbox
  |--load_text_data
    |--load_filenames // 遍历文件夹获取文件名称列表
    |--load_captions // 加载每张图像的文字描述(遍历text.zip里面的文件)
    |--build_dictionary // 创建字典
  |--load_class_id // 图像分类

|--RNN_ENCODER (DAMSM.py)
  |--define_module // 使用torch.nn，默认使用LSTM
  |--init_weights

### 建立G和D模型
|--NetG (model.py)
  |--G_Block
    |--affine
  
|--NetD
  |--resD
  |--D_GET_LOGITS

### 训练
|--train (main.py) //默认600个epoch
  |--prepare_data (datasets.py) 
  |--save_image

# 文件具体解析  
## datasets.py
py2和py3兼容
```python
from __future__ import absolute_import #在py2中导入py3，绝对导入和相对导入（本目录模块和系统模块同名时是引用本目录还是引用系统）
from __future__ import division #py2默认截断式除法，使用该语句声明精确除法；py3默认精确除法
from __future__ import print_function #在py2中使用py3的print函数
from __future__ import unicode_literals #把所有字符串转换成unicode，否则同一字符串在不同编码下的长度不同
```

TextDataSet类，处理文字数据
```python
class TextDataset(data.Dataset):
    # 数据初始化
	def __init__(self, data_dir, split='train',
                 base_size=64,
                 transform=None, target_transform=None):
        self.transform = transform
		# 把数据转换成Tensor类型
        self.norm = transforms.Compose([
            transforms.ToTensor(),
            transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))])
        self.target_transform = target_transform
		# 描述文字长度
        self.embeddings_num = cfg.TEXT.CAPTIONS_PER_IMAGE
		# BRANCH_NUM生成不同尺度的图像
        self.imsize = []
        for i in range(cfg.TREE.BRANCH_NUM):
            self.imsize.append(base_size)
            base_size = base_size * 2

        self.data = []
        self.data_dir = data_dir
        if data_dir.find('birds') != -1:
            self.bbox = self.load_bbox()
        else:
            self.bbox = None
        split_dir = os.path.join(data_dir, split)
		# 加载描述文字并建立词典
        self.filenames, self.captions, self.ixtoword, /
            self.wordtoix, self.n_words = self.load_text_data(data_dir, split)
		# 加载图像分类id
        self.class_id = self.load_class_id(split_dir, len(self.filenames))
        self.number_example = len(self.filenames)
```

```
def get_imgs(img_path, imsize, bbox=None,
             transform=None, normalize=None):
	# 获取指定路径的图像数据，并进行缩放裁剪等处理，最后转换成Tensor类型
    img = Image.open(img_path).convert('RGB')
    width, height = img.size
    if bbox is not None:
        r = int(np.maximum(bbox[2], bbox[3]) * 0.75)
        center_x = int((2 * bbox[0] + bbox[2]) / 2)
        center_y = int((2 * bbox[1] + bbox[3]) / 2)
        y1 = np.maximum(0, center_y - r)
        y2 = np.minimum(height, center_y + r)
        x1 = np.maximum(0, center_x - r)
        x2 = np.minimum(width, center_x + r)
        img = img.crop([x1, y1, x2, y2])

    if transform is not None:
        img = transform(img)
        
    ret = []
    ret.append(normalize(img))
    #if cfg.GAN.B_DCGAN:
    '''
    for i in range(cfg.TREE.BRANCH_NUM):
        # print(imsize[i])
        re_img = transforms.Resize(imsize[i])(img)
        ret.append(normalize(re_img))
    '''

    return ret
```

```
def prepare_data(data):
	# 处理一批训练数据
    imgs, captions, captions_lens, class_ids, keys = data

    # sort data by the length in a decreasing order
    sorted_cap_lens, sorted_cap_indices = \
        torch.sort(captions_lens, 0, True)

    real_imgs = []
    for i in range(len(imgs)):
        imgs[i] = imgs[i][sorted_cap_indices]
        if cfg.CUDA:
            real_imgs.append(Variable(imgs[i]).cuda())
        else:
            real_imgs.append(Variable(imgs[i]))

    captions = captions[sorted_cap_indices].squeeze()
    class_ids = class_ids[sorted_cap_indices].numpy()
    # sent_indices = sent_indices[sorted_cap_indices]
    keys = [keys[i] for i in sorted_cap_indices.numpy()]
    # print('keys', type(keys), keys[-1])  # list
    if cfg.CUDA:
        captions = Variable(captions).cuda()
        sorted_cap_lens = Variable(sorted_cap_lens).cuda()
    else:
        captions = Variable(captions)
        sorted_cap_lens = Variable(sorted_cap_lens)

    return [real_imgs, captions, sorted_cap_lens,
            class_ids, keys]
```

## config.py
配置文件
```
__C = edict()
cfg = __C

# Dataset name: flowers, birds
__C.DATASET_NAME = 'birds'
__C.CONFIG_NAME = ''
__C.DATA_DIR = ''
__C.GPU_ID = -1 #GPU的id，-1为不使用GPU
__C.CUDA = False #是否使用GPU，如果使用的话需要和GPU_ID配合使用
__C.WORKERS = 6

__C.RNN_TYPE = 'LSTM'   # 'GRU' #文字描述处理RNN算法，有LSTM和GRU两种
__C.B_VALIDATION = False # 训练还是生成
__C.loss = 'hinge'
__C.TREE = edict()
__C.TREE.BRANCH_NUM = 3
__C.TREE.BASE_SIZE = 64


# Training options
__C.TRAIN = edict()
__C.TRAIN.BATCH_SIZE = 64 # 每个epoch训练多少组数据（张图像）
__C.TRAIN.MAX_EPOCH = 600 # epoch数
__C.TRAIN.SNAPSHOT_INTERVAL = 2000
__C.TRAIN.DISCRIMINATOR_LR = 2e-4
__C.TRAIN.GENERATOR_LR = 2e-4 #学习率
__C.TRAIN.ENCODER_LR = 2e-4 #学习率
__C.TRAIN.RNN_GRAD_CLIP = 0.25
__C.TRAIN.FLAG = True
__C.TRAIN.NET_E = ''
__C.TRAIN.NET_G = ''
__C.TRAIN.B_NET_D = True
__C.TRAIN.NF = 32
__C.TRAIN.SMOOTH = edict()
__C.TRAIN.SMOOTH.GAMMA1 = 5.0
__C.TRAIN.SMOOTH.GAMMA3 = 10.0
__C.TRAIN.SMOOTH.GAMMA2 = 5.0
__C.TRAIN.SMOOTH.LAMBDA = 1.0


# Modal options
__C.GAN = edict()
__C.GAN.DF_DIM = 64
__C.GAN.GF_DIM = 128
__C.GAN.Z_DIM = 100
__C.GAN.CONDITION_DIM = 100
__C.GAN.R_NUM = 2
__C.GAN.B_ATTENTION = True
__C.GAN.B_DCGAN = True


__C.TEXT = edict()
__C.TEXT.CAPTIONS_PER_IMAGE = 10
__C.TEXT.EMBEDDING_DIM = 256
__C.TEXT.WORDS_NUM = 18
__C.TEXT.DAMSM_NAME = '../DAMSMencoders/coco/text_encoder200.pth'
```

## main.py
主流程
```
if __name__ == "__main__":
	# 解析参数（然而貌似有bug，配置文件中的gpu_id读取不进来）
    args = parse_args()
    if args.cfg_file is not None:
        cfg_from_file(args.cfg_file)
    '''
    if args.gpu_id == -1:
        cfg.CUDA = False
    else:
        cfg.GPU_ID = args.gpu_id
    '''
    if args.data_dir != '':
        cfg.DATA_DIR = args.data_dir
    print('Using config:')
    pprint.pprint(cfg)

    if not cfg.TRAIN.FLAG:
        args.manualSeed = 100
    elif args.manualSeed is None:
        args.manualSeed = 100
        #args.manualSeed = random.randint(1, 10000)
    print("seed now is : ",args.manualSeed)
    random.seed(args.manualSeed)
    np.random.seed(args.manualSeed)
    torch.manual_seed(args.manualSeed)
    if cfg.CUDA:
        torch.cuda.manual_seed_all(args.manualSeed)

    ##########################################################################
    now = datetime.datetime.now(dateutil.tz.tzlocal())
    timestamp = now.strftime('%Y_%m_%d_%H_%M_%S')
    output_dir = '../output/%s_%s_%s' % \
        (cfg.DATASET_NAME, cfg.CONFIG_NAME, timestamp)

    #torch.cuda.set_device(cfg.GPU_ID)
    cudnn.benchmark = True

    # Get data loader ##################################################
    imsize = cfg.TREE.BASE_SIZE
    batch_size = cfg.TRAIN.BATCH_SIZE
    image_transform = transforms.Compose([
        transforms.Resize(int(imsize * 76 / 64)),
        transforms.RandomCrop(imsize),
        transforms.RandomHorizontalFlip()])
	# 使用TextDataset加载和解析数据，根据参数B_VALIDATION决定是加载train还是test数据集
    if cfg.B_VALIDATION:
        dataset = TextDataset(cfg.DATA_DIR, 'test',
                                base_size=cfg.TREE.BASE_SIZE,
                                transform=image_transform)
        print(dataset.n_words, dataset.embeddings_num)
        assert dataset
        dataloader = torch.utils.data.DataLoader(
            dataset, batch_size=batch_size, drop_last=True,
            shuffle=True, num_workers=int(cfg.WORKERS))
    else:     
        dataset = TextDataset(cfg.DATA_DIR, 'train',
                            base_size=cfg.TREE.BASE_SIZE,
                            transform=image_transform)
        print(dataset.n_words, dataset.embeddings_num)
        assert dataset
        dataloader = torch.utils.data.DataLoader(
            dataset, batch_size=batch_size, drop_last=True,
            shuffle=True, num_workers=int(cfg.WORKERS))

    # # validation data #

    #device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    device = torch.device("cpu")
	# 使用NetG和NetD类创建G和D两个网络
    netG = NetG(cfg.TRAIN.NF, 100).to(device)
    netD = NetD(cfg.TRAIN.NF).to(device)
	# 使用RNN_ENCODER编码描述文字
    text_encoder = RNN_ENCODER(dataset.n_words, nhidden=cfg.TEXT.EMBEDDING_DIM)
	# cfg.TEXT.DAMSM_NAME指向预训练好的字典文件，使用StackGAN Inception Evaluation Model预训练好的
    state_dict = torch.load(cfg.TEXT.DAMSM_NAME, map_location=lambda storage, loc: storage)
    text_encoder.load_state_dict(state_dict)
    #text_encoder.cuda()

    for p in text_encoder.parameters():
        p.requires_grad = False
    text_encoder.eval()    

    state_epoch=0

    optimizerG = torch.optim.Adam(netG.parameters(), lr=0.0001, betas=(0.0, 0.9))
    optimizerD = torch.optim.Adam(netD.parameters(), lr=0.0004, betas=(0.0, 0.9))  

	# 开始生成或训练
    if cfg.B_VALIDATION:
        count = sampling(text_encoder, netG, dataloader,device)  # generate images for the whole valid dataset
        print('state_epoch:  %d'%(state_epoch))
    else:
        
        count = train(dataloader,netG,netD,text_encoder,optimizerG,optimizerD, state_epoch,batch_size,device)
```

训练函数
```
def train(dataloader,netG,netD,text_encoder,optimizerG,optimizerD,state_epoch,batch_size,device):
	# 对每一轮epoch
    for epoch in range(state_epoch+1, cfg.TRAIN.MAX_EPOCH+1):
        print("train epoch ", epoch)
		# 按batch_size遍历数据集
        for step, data in enumerate(dataloader, 0):
            # TextDataSet中的prepare_data准备数据
            imags, captions, cap_lens, class_ids, keys = prepare_data(data)
            hidden = text_encoder.init_hidden(batch_size)
            # words_embs: batch_size x nef x seq_len
            # sent_emb: batch_size x nef
            words_embs, sent_emb = text_encoder(captions, cap_lens, hidden)
            words_embs, sent_emb = words_embs.detach(), sent_emb.detach()
			# 更新判别器D
            imgs=imags[0].to(device)
            real_features = netD(imgs)
            output = netD.COND_DNET(real_features,sent_emb)
            errD_real = torch.nn.ReLU()(1.0 - output).mean()

            output = netD.COND_DNET(real_features[:(batch_size - 1)], sent_emb[1:batch_size])
            errD_mismatch = torch.nn.ReLU()(1.0 + output).mean()
			# 更新生成器G
            # synthesize fake images
            noise = torch.randn(batch_size, 100)
            noise=noise.to(device)
            fake = netG(noise,sent_emb)  
            
            # G does not need update with D
            fake_features = netD(fake.detach()) 
			# 误差计算
            errD_fake = netD.COND_DNET(fake_features,sent_emb)
            errD_fake = torch.nn.ReLU()(1.0 + errD_fake).mean()          

            errD = errD_real + (errD_fake + errD_mismatch)/2.0
            optimizerD.zero_grad()
            optimizerG.zero_grad()
            errD.backward()
            optimizerD.step()

            #MA-GP
            interpolated = (imgs.data).requires_grad_()
            sent_inter = (sent_emb.data).requires_grad_()
            features = netD(interpolated)
            out = netD.COND_DNET(features,sent_inter)
            grads = torch.autograd.grad(outputs=out,
                                    inputs=(interpolated,sent_inter),
                                    #grad_outputs=torch.ones(out.size()).cuda(),
                                    grad_outputs=torch.ones(out.size()),
                                    retain_graph=True,
                                    create_graph=True,
                                    only_inputs=True)
            grad0 = grads[0].view(grads[0].size(0), -1)
            grad1 = grads[1].view(grads[1].size(0), -1)
            grad = torch.cat((grad0,grad1),dim=1)                        
            grad_l2norm = torch.sqrt(torch.sum(grad ** 2, dim=1))
            d_loss_gp = torch.mean((grad_l2norm) ** 6)
            d_loss = 2.0 * d_loss_gp
            optimizerD.zero_grad()
            optimizerG.zero_grad()
            d_loss.backward()
            optimizerD.step()
            
            # update G
            features = netD(fake)
            output = netD.COND_DNET(features,sent_emb)
            errG = - output.mean()
            optimizerG.zero_grad()
            optimizerD.zero_grad()
            errG.backward()
            optimizerG.step()

            print('[%d/%d][%d/%d] Loss_D: %.3f Loss_G %.3f'
                % (epoch, cfg.TRAIN.MAX_EPOCH, step, len(dataloader), errD.item(), errG.item()))
		# 存储当前epoch生成的图像
        vutils.save_image(fake.data,
                        '%s/%s/fake_samples_epoch_%03d.png' % (cfg.DATA_DIR, 'imgs', epoch),
                        normalize=True)
		# 存储模型
        if epoch%10==0:
            torch.save(netG.state_dict(), 'models/%s/netG_%03d.pth' % (cfg.CONFIG_NAME, epoch))
            torch.save(netD.state_dict(), 'models/%s/netD_%03d.pth' % (cfg.CONFIG_NAME, epoch))       
	# 源码这里返回count，然而count在前面并没有定义
    return 0
```

生成函数
```
def sampling(text_encoder, netG, dataloader,device):
    # 加载训练模型
    model_dir = cfg.TRAIN.NET_G
    split_dir = 'valid'
    # Build and load the generator
    netG.load_state_dict(torch.load('models/%s/netG.pth'%(cfg.CONFIG_NAME), map_location='cpu'))
    netG.eval()
	# 设置保存路径，每次生成batch_size批数据（张图像）
    batch_size = cfg.TRAIN.BATCH_SIZE
    s_tmp = model_dir
    save_dir = '%s/%s' % (s_tmp, split_dir)
    mkdir_p(save_dir)
    cnt = 0
    for i in range(1):  # (cfg.TEXT.CAPTIONS_PER_IMAGE):
        for step, data in enumerate(dataloader, 0):
            imags, captions, cap_lens, class_ids, keys = prepare_data(data)
            cnt += batch_size
            if step % 100 == 0:
                print('step: ', step)
            # if step > 50:
            #     break
            hidden = text_encoder.init_hidden(batch_size)
            # words_embs: batch_size x nef x seq_len
            # sent_emb: batch_size x nef
            words_embs, sent_emb = text_encoder(captions, cap_lens, hidden)
            words_embs, sent_emb = words_embs.detach(), sent_emb.detach()
            #######################################################
            # (2) Generate fake images
            ######################################################
            with torch.no_grad():
                noise = torch.randn(batch_size, 100)
                noise=noise.to(device)
                fake_imgs = netG(noise,sent_emb)
			# 保存数据
            for j in range(batch_size):
                s_tmp = '%s/single/%s' % (save_dir, keys[j])
                folder = s_tmp[:s_tmp.rfind('/')]
                if not os.path.isdir(folder):
                    print('Make a new folder: ', folder)
                    mkdir_p(folder)
                im = fake_imgs[j].data.cpu().numpy()
                # [-1, 1] --> [0, 255]
                im = (im + 1.0) * 127.5
                im = im.astype(np.uint8)
                im = np.transpose(im, (1, 2, 0))
                im = Image.fromarray(im)
                fullpath = '%s_%3d.png' % (s_tmp,i)
                im.save(fullpath)
```

## model.py
模型

```
class NetG(nn.Module):
    def __init__(self, ngf=64, nz=100):
        super(NetG, self).__init__()
        self.ngf = ngf

        # layer1输入的是一个100x1x1的随机噪声, 输出尺寸(ngf*8)x4x4
        self.fc = nn.Linear(nz, ngf*8*4*4)
        self.block0 = G_Block(ngf * 8, ngf * 8)#4x4
        self.block1 = G_Block(ngf * 8, ngf * 8)#4x4
        self.block2 = G_Block(ngf * 8, ngf * 8)#8x8
        self.block3 = G_Block(ngf * 8, ngf * 8)#16x16
        self.block4 = G_Block(ngf * 8, ngf * 4)#32x32
        self.block5 = G_Block(ngf * 4, ngf * 2)#64x64
        self.block6 = G_Block(ngf * 2, ngf * 1)#128x128

        self.conv_img = nn.Sequential(
            nn.LeakyReLU(0.2,inplace=True),
            nn.Conv2d(ngf, 3, 3, 1, 1),
            nn.Tanh(),
        )

    def forward(self, x, c):

        out = self.fc(x)
        out = out.view(x.size(0), 8*self.ngf, 4, 4)
        out = self.block0(out,c)

        out = F.interpolate(out, scale_factor=2)
        out = self.block1(out,c)

        out = F.interpolate(out, scale_factor=2)
        out = self.block2(out,c)

        out = F.interpolate(out, scale_factor=2)
        out = self.block3(out,c)

        out = F.interpolate(out, scale_factor=2)
        out = self.block4(out,c)

        out = F.interpolate(out, scale_factor=2)
        out = self.block5(out,c)

        out = F.interpolate(out, scale_factor=2)
        out = self.block6(out,c)

        out = self.conv_img(out)

        return out
```

```
# 定义鉴别器网络D
class NetD(nn.Module):
    def __init__(self, ndf):
        super(NetD, self).__init__()

        self.conv_img = nn.Conv2d(3, ndf, 3, 1, 1)#128
        self.block0 = resD(ndf * 1, ndf * 2)#64
        self.block1 = resD(ndf * 2, ndf * 4)#32
        self.block2 = resD(ndf * 4, ndf * 8)#16
        self.block3 = resD(ndf * 8, ndf * 16)#8
        self.block4 = resD(ndf * 16, ndf * 16)#4
        self.block5 = resD(ndf * 16, ndf * 16)#4

        self.COND_DNET = D_GET_LOGITS(ndf)

    def forward(self,x):

        out = self.conv_img(x)
        out = self.block0(out)
        out = self.block1(out)
        out = self.block2(out)
        out = self.block3(out)
        out = self.block4(out)
        out = self.block5(out)

        return out
```