---
layout: default
title: Electron_Vue_CPlusPlus
categories:
- C++
tags:
- C++
---
//Description: Electron、Vue和C++相互调用

//Create Date: 2021-02-01 13:27:33

//Author: channy

# electron项目增加vue支持

背景：需求已有electron项目，要求使用element-ui，而element-ui是基于[vue](https://cn.vuejs.org) 的，所以只能使用electron+vue的结构。

## 环境安装

1. 安装node.js, https://nodejs.org/en/download/

ps: 安装好后可以输入npm -v查看版本

pps: 考虑到墙的问题，可使用淘宝镜像，后续用cnpm代替npm

```
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

2. npm安装electron 

```
npm install -g electron
```

3. 安装vue

```
cnpm install @vue/cli -g
cnpm install i -g @vue/cli-init
```

4. 安装element-ui

```
npm i element-ui -S -g
```

或者在工程目录下安装element-ui

```
npm i element-ui -S
```

5. 新建vue工程。尝试了一下 vue init，好像带不起electron，也可能是配置没写好

```
vue init webpack vueinit

? Project name vueinit
? Project description A Vue.js project
? Author
? Vue build standalone
? Install vue-router? Yes
? Use ESLint to lint your code? No
? Set up unit tests No
? Setup e2e tests with Nightwatch? No
? Should we run `npm install` for you after the project has been created? (recommended) no

   vue-cli · Generated "vueinit".

# Project initialization finished!
# ========================

To get started:

  cd vueinit
  npm install (or if using yarn: yarn)
  npm run dev

Documentation can be found at https://vuejs-templates.github.io/webpack
```

5. vue creat

```
vue create projectname
``` 

6. 把原electron放入vue的目录中，同时修改配置文件

7. 安装依赖
```
npm install
```

8. 编译
```
npm run builds
```

9. 进到electron工程目录下，运行
```
npm install
npm run start
```