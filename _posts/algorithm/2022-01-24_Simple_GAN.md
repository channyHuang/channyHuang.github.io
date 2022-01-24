---
layout: default
title: Simple_GAN.md
categories:
- Game
tags:
- Game
---
//Description: Simple_GAN (一个简单的GAN例子)

//Create Date: 2022-01-24 15:28:39

//Author: channy

# 概述 
[一个简单的GAN例子](https://zhuanlan.zhihu.com/p/85908702)

一个形象的比喻：
> 简单的来说，就是让无数的猴子随机敲键盘，那把些不听话，敲不出有规律字符的猴子全部干掉，接着在这群猴子里面找能敲出正确单词的猴子，把剩下的干掉，把敲不出有意义句子的猴子再干掉，敲不出莎士比亚的全干掉。。。剩下的就是莎士比亚猴了

开发环境：python3 (3.8.10)  
使用到的库：numpy, matplotlib, keras(tensorflow), tqdm。  
其中，原文用到的Adam在tensorflow 2.7.0版本中需要改成adam_v2，使用时改成adam_v2.Adam

```shell
>>> print(tf.version.VERSION)
2.7.0
```

```python
from keras.datasets import mnist
from keras.layers import Dense, Dropout, Input
from keras.models import Model,Sequential
from keras.layers.advanced_activations import LeakyReLU
from keras.optimizers import adam_v2
from tqdm import tqdm
import numpy as np
import matplotlib.pyplot as plt
```

加载训练数据，这里使用的是keras自带的mnist数据集，即上一步导入的库*from keras.datasets import mnist*的作用

```python
# Load the dataset
def load_data():
  (x_train, y_train), (_, _) = mnist.load_data()
  x_train = (x_train.astype(np.float32) - 127.5)/127.5

  # Convert shape from (60000, 28, 28) to (60000, 784)
  x_train = x_train.reshape(60000, 784)
  return (x_train, y_train)

X_train, y_train = load_data()
print(X_train.shape, y_train.shape)
```

建立线性模型Sequential，类似于MLP/CNN。生成器G和判别器D都是MLP/CNN，即GAN由两个神经网络连接而成。

```python
def build_generator():
    model = Sequential()

    model.add(Dense(units=256, input_dim=100))
    model.add(LeakyReLU(alpha=0.2))

    model.add(Dense(units=512))
    model.add(LeakyReLU(alpha=0.2))

    model.add(Dense(units=1024))
    model.add(LeakyReLU(alpha=0.2))

    model.add(Dense(units=784, activation='tanh'))

    model.compile(loss='binary_crossentropy', optimizer=adam_v2.Adam(0.0002, 0.5))
    return model

generator = build_generator()
generator.summary()

def build_discriminator():
    model = Sequential()

    model.add(Dense(units=1024 ,input_dim=784))
    model.add(LeakyReLU(alpha=0.2))
    model.add(Dropout(0.3))

    model.add(Dense(units=512))
    model.add(LeakyReLU(alpha=0.2))
    model.add(Dropout(0.3))

    model.add(Dense(units=256))
    model.add(LeakyReLU(alpha=0.2))
    model.add(Dropout(0.3))

    model.add(Dense(units=1, activation='sigmoid'))

    model.compile(loss='binary_crossentropy', optimizer=adam_v2.Adam(0.0002, 0.5))
    return model

discriminator = build_discriminator()
discriminator.summary()
```

建立GAN，连接G和D

```
def build_GAN(discriminator, generator):
    discriminator.trainable=False
    GAN_input = Input(shape=(100,))
    x = generator(GAN_input)
    GAN_output= discriminator(x)
    GAN = Model(inputs=GAN_input, outputs=GAN_output)
    GAN.compile(loss='binary_crossentropy', optimizer=adam_v2.Adam(0.0002, 0.5))
    return GAN

GAN = build_GAN(discriminator, generator)
GAN.summary()
```

画图函数，为了直观地感受结果，也是导入库matplotlib的作用

```
def draw_images(generator, epoch, examples=25, dim=(5,5), figsize=(10,10)):
    noise= np.random.normal(loc=0, scale=1, size=[examples, 100])
    generated_images = generator.predict(noise)
    generated_images = generated_images.reshape(25,28,28)
    plt.figure(figsize=figsize)
    for i in range(generated_images.shape[0]):
        plt.subplot(dim[0], dim[1], i+1)
        plt.imshow(generated_images[i], interpolation='nearest', cmap='Greys')
        plt.axis('off')
    plt.tight_layout()
    plt.savefig('Generated_images %d.png' %epoch)
```

训练函数，训练GAN。epochs为迭代次数，tqdm为动态显示进度条，batch_size为最终需要生成的128张图片，也是初始使用噪声生成的假图片。

每次迭代利用高斯分布的噪声noise作为训练的初始输入，从Mnist中随机选取128张图片，标注并和噪声图片混合。训练D，训练完成后，D的权重weight得到了更新。然后固定weight，训练G。

```
def train_GAN(epochs=1, batch_size=128):

  #Loading the data
  X_train, y_train = load_data()

  # Creating GAN
  generator= build_generator()
  discriminator= build_discriminator()
  GAN = build_GAN(discriminator, generator)

  for i in range(1, epochs+1):
    print("Epoch %d" %i)

    for _ in tqdm(range(batch_size)):
      # Generate fake images from random noiset
      noise= np.random.normal(0,1, (batch_size, 100))
      fake_images = generator.predict(noise)

      # Select a random batch of real images from MNIST
      real_images = X_train[np.random.randint(0, X_train.shape[0], batch_size)]

      # Labels for fake and real images
      label_fake = np.zeros(batch_size)
      label_real = np.ones(batch_size)

      # Concatenate fake and real images
      X = np.concatenate([fake_images, real_images])
      y = np.concatenate([label_fake, label_real])

      # Train the discriminator
      discriminator.trainable=True
      discriminator.train_on_batch(X, y)

      # Train the generator/chained GAN model (with frozen weights in discriminator)
      discriminator.trainable=False
      GAN.train_on_batch(noise, label_real)

    # Draw generated images every 15 epoches
    if i == 1 or i % 10 == 0:
      draw_images(generator, i)
train_GAN(epochs=400, batch_size=128)
```

总的来说，具体操作步骤如下：  
1. Generator利用自己最新的权重，生成了一堆假图片。
1. Discrminator根据真假图片的真实label，不断训练更新自己的权重，直到可以顺利鉴别真假图片。
1. 此时discriminator权重被固定，不再发生变化。generator利用最新的discrimintor，苦苦思索，不断训练自己的权重，最终使discriminator将假图片鉴定为真图片。