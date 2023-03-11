---
layout: default
title: Simple_CGAN.md
categories:
- Algorithm
tags:
- Game
---
//Description: Simple_CGAN (一个简单的CGAN例子)

//Create Date: 2022-01-26 09:28:39

//Author: channy

# 概述 
[一个简单的CGAN例子](https://github.com/junhyeog/CGAN)

开发环境：python3 (3.8.10)  
使用到的库：numpy, matplotlib, keras(tensorflow), pandas等等。  
其中，原文用到gpu，个人电脑渣只能用cpu，故把gpu注释掉了

```
#import module
import cv2
from tensorflow import keras
import pickle
import numpy
import time
from matplotlib import pyplot
import random
import pandas
import os
import tensorflow as tf
from matplotlib.animation import FuncAnimation
from multiprocessing import Process
import datetime
from tensorflow.keras.datasets.mnist import load_data
# from tensorflow.keras.datasets.fashion_mnist import load_data
gpus= tf.config.experimental.list_physical_devices('GPU')
#tf.config.experimental.set_memory_growth(gpus[0], True)
```

大步骤同GAN一样，都是先建立G和D两个模型

```
def create_gen():
    condition=keras.Input((1))
    layer=keras.layers.Embedding(10,128)(condition)
    layer=keras.layers.Dense(128)(layer)
    condition_out=keras.layers.Reshape((8,8,2))(layer)

    noise=keras.Input((100))
    layer=keras.layers.Dense(1024)(noise)
    layer=keras.layers.BatchNormalization()(layer)
    activation=keras.layers.LeakyReLU()(layer)

    layer=keras.layers.Dense(4096)(activation)
    layer=keras.layers.BatchNormalization()(layer)
    activation=keras.layers.LeakyReLU()(layer)
    noise_out=keras.layers.Reshape((8,8,64))(activation)

    mix=keras.layers.Concatenate()([condition_out,noise_out])
    x=keras.layers.Conv2DTranspose(512,(4,4),strides=(2,2))(mix)
    x=keras.layers.BatchNormalization()(x)
    x=keras.layers.LeakyReLU()(x)

    x=keras.layers.Conv2DTranspose(256,(4,4),strides=(2,2))(x)
    x=keras.layers.BatchNormalization()(x)
    x=keras.layers.LeakyReLU()(x)
    x=keras.layers.Conv2D(1,(11,11))(x)
    x=keras.layers.Activation('tanh')(x)

    generator=keras.Model([condition,noise],x)
    return generator
generator=create_gen()
generator.summary()

def create_dis():
    condition=keras.Input((1))
    layer=keras.layers.Embedding(10,128)(condition)
    layer=keras.layers.Dense(784)(layer)
    condition_out=keras.layers.Reshape((28,28,1))(layer)
    img=keras.Input((28,28,1))
    x=keras.layers.Concatenate()([condition_out,img])
    x=keras.layers.Conv2D(128,(7,7))(x)
    x=keras.layers.BatchNormalization()(x)
    x=keras.layers.LeakyReLU()(x)
    x=keras.layers.Conv2D(128,(5,5))(x)
    x=keras.layers.BatchNormalization()(x)
    x=keras.layers.LeakyReLU()(x)
    x=keras.layers.Conv2D(64,(5,5))(x)
    x=keras.layers.BatchNormalization()(x)
    x=keras.layers.LeakyReLU()(x)

    x=keras.layers.Flatten()(x)
    x=keras.layers.Dense(1)(x)
    x=keras.layers.Activation('sigmoid')(x)

    discriminator=keras.Model([condition,img],x)
    opt=tf.keras.optimizers.Adam(learning_rate=0.0002,beta_1=0.5)
    discriminator.compile(loss='binary_crossentropy',metrics=['accuracy'],optimizer=opt)
    return discriminator
discriminator=create_dis()
discriminator.summary()
```

建立GAN，连接G和D

```
def define_model():
    global discriminator
    global generator
    discriminator.trainable=False
    label=keras.Input((1))
    noise=keras.Input((100))
    gan_input=[label,noise]
    gan_output=(discriminator([label,generator(gan_input)]))
    model=keras.Model(inputs=gan_input,outputs=gan_output)
    opt=tf.keras.optimizers.Adam(learning_rate=0.0002,beta_1=0.5)
    model.compile(loss='binary_crossentropy',optimizer=opt,metrics=['accuracy'])
    model.summary()
    return model
model=define_model()
#%% load data
def load_image():
    (x_train, y_train), (_, _) = load_data()
    x_train=numpy.expand_dims(x_train,axis= -1)
    x_train=x_train.astype('float32')
    x_train=(x_train-127.5)/127.5
    real=[]
    for index in range(x_train.shape[0]):
        real.append([[[y_train[index]],x_train[index]],1])
    return real
real=load_image()
```

输入为随机噪声混合真实的训练数据。CGAN和GAN的差异也在此处。

```
def create_noise(size,amount):
    amount=int(amount/10)
    noise=numpy.array([[random.uniform(-127.5,127.5)/127.5 for _ in range(size)] for _ in range(amount*10)])
    label=numpy.array([[n] for n in range(10)]*amount)
    random.shuffle(label)
    return noise,label
#%%
def mix(real,generator,size,amount):
    noise,label=create_noise(size,amount)
    data=[]
    data.extend(random.choices(real,k=amount))

    gen=generator.predict([label,noise])
    for index in range(len(noise)):
        data.append([[label[index],gen[index]],0])
    random.shuffle(data)
    x_label,x_img,y=[],[],[]
    for  index in range(len(data)):
        d=data[index][0]

        ans=data[index][1]
        x_label.append(d[0])
        x_img.append(d[1])
        y.append([ans])
    x_label=numpy.array(x_label)
    x_img=numpy.array(x_img)
    y=numpy.array(y)
    x_img=x_img+(numpy.random.rand(amount*2,28,28,1)/127.5)
    return x_label,x_img,y
```

可视化输出，同时保存训练模型

```
def plot_img(generator,noise,x):
        label=numpy.array([[n] for n in range(10)]*int(noise.shape[0]/10))

        gen=generator.predict([label,noise])
        pyplot.figure(dpi=600)
        pyplot.title(x)
        for loop in range(10):
            for img in range(10):
                pyplot.subplot(10,10,img+1+loop*10)
                pyplot.xticks([])
                pyplot.yticks([])
                pyplot.imshow(gen[img+loop*10].reshape(28,28),cmap='gray_r')
        pyplot.savefig(f"D:\\mnist_gan\\{x}")
        pyplot.close('all')
        discriminator.save('discriminator.h5')
        generator.save('generator.h5')
```

最后是迭代

```
now=datetime.datetime.now()
# while True:
amount=50
size=100
now =datetime.datetime.now()
for x in range(1,48001):
    x_label,x_img,y=mix(real,generator,size,amount)


    # train discriminator

    discriminator.train_on_batch([x_label,x_img],y)
    # dis_loss,acc=discriminator.evaluate([x_label,x_img],y)



    # train generator
    noise,label=create_noise(size,amount*2)
    model.train_on_batch([label,noise],numpy.array([1 for _ in range(label.shape[0])]))
    # gen_loss,acc=model.evaluate([label,noise],numpy.array([1 for n in range(label.shape[0])]))




    if x%600==0:
        print(datetime.datetime.now()-now)
        # print(f"discriminator:{dis_loss}    generator:{gen_loss}")
        plot_img(generator,noise,x)
```