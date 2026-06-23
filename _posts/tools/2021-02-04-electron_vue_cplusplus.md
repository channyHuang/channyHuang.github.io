---
layout: default
title: Electron_Vue_CPlusPlus
categories:
- Tools
tags:
- js
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

electron自身的目录结构比较简单，一个配置文件package.json,一个主页面脚本main.js和主页面main.html即可。

一般package.json里面配置了启动命令"start": "electron ./js/main.js"指定了入口。而main.js里面有createWindow新建窗口win.loadFile('../main.html')。

也可以把vue放入原electron目录中，不过需要调整vue build后的目录和文件位置。

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

## 路径说明

vue create新建项目后的目录

> public

> src

>> assets 资源目录 

>> components 组件，类似于c++项目中自定义的控件

>> router 页面跳转

>> views vue页面

>> App.vue 主页面

>> main.js 主函数入口

> babel.config.js

> package.json vue的配置文件，包含各种依赖库。其中自定义编译命令可在scripts里面设置，如npm build对应"build": "vue-cli-service build"

## electron+vue

在vue的目录下手动添加vue.config.js。内容如下，指定了vue的output路径。vue-cli-service build会在该路径下生成electron需要的js文件及其它。

```
module.exports = {
  publicPath: './',
  outputDir: './dist'
};
```

生成的文件放到electron指定的目录，就可以用vue开发electron的页面了。

## 其它依赖安装

如安装nan、node-gyp等。如果需要node.js和c++相互调用，需要node-gyp

在工程目录下编译
```
node-gyp rebuild --target=11.2.1 --arch=ia32 --dist-url=https://electronjs.org/headers --abi=83 --build-from-sourc
```
其中11.2.1为本机electron的版本；83为本机node.js版本对应的abi版本（官网可查）

## 在node.js中调用c++的动态库

一种方案是使用ffi，听说性能有折损，改用第二种方案，用c++写node addon

c++写node addon，需要熟悉v8。加载dll，注册函数

```c++
//xxx.cpp，加载dll中的checkDeviceAvaiable函数并封装注册给外部调用
void CheckDeviceAndFunc(const FunctionCallbackInfo<Value>& args)
{
  std::string str = "xxx.dll";
  HINSTANCE hDLL = LoadLibrary(str.c_str());
  bool bRes = false;
  if (hDLL != nullptr)
  {
      typedef bool(*TYPE_CheckDeviceAvaiableDLL)();
      TYPE_CheckDeviceAvaiableDLL checkDeviceAvaiableDLL = (TYPE_CheckDeviceAvaiableDLL)GetProcAddress(hDLL, "checkDeviceAvaiable");
      if (checkDeviceAvaiableDLL == nullptr)
      {
          bRes = false;
      }
      else 
      {
          bRes = (checkDeviceAvaiableDLL());
      }
  }
  Isolate* isolate = args.GetIsolate();
  Local<Number> num = Number::New(isolate, bRes);
  args.GetReturnValue().Set(num);
}

void RegisterModule(Local<Object> exports, Local<Object> module, Local<Context> context) {
  NODE_SET_METHOD(exports, "CheckDeviceAndFunc", CheckDeviceAndFunc);
}

NODE_MODULE(NODE_GYP_MODULE_NAME, RegisterModule)
```

然后写binding.gyp文件并用node-gyp编译，生成.node文件供js调用。

```
//binding.gyp
{
  "targets": [
    {
      "target_name": "ForNodeAddOn",
      "include_dirs": [
        "forNodeAddOn/includeDirs",
        "<!(node -e \"require('nan')\")"
      ],
      "sources": [ "forNodeAddOn/nodeAddOnMain.cpp" ,
      "forNodeAddOn/managerAddOn.cpp"
      ],
      "win_delay_load_hook":"true"
    }
  ]
}
```

```js
//
const Interface = require('./build/Release/ForNodeAddOn.node');
Interface.CheckDeviceAndFunc()
```

## electron和vue相互通信

理论上，electron有两个进程：主进程（node.js）和渲染进程（vue.js），经测试暂未找到直接在vue上引用.node文件的方法。故考虑vue-js-c++路线

### vue-js

vue可以通过import的方式直接调用js

```
//xxx.vue
import FingerRecog from "@/../fingerRecog.js"
```

```
//fingerRecog.js
const FingerRecog = {
    CheckDeviceAndFunc:function(){
      console.log('CheckDeviceAndFunc be called in fingerRecog.js ');
    }
};

module.exports = FingerRecog;
```

### js-c++

使用node addon

### vue-js-c++

electron主进程和渲染进程通信用ipcMain和ipcRenderer

在electron的main.js中增加preload预加载ipc并编写ipcMain的监听函数ipcMain.on，同步sendSync异步send。

```js
//main.js
function createWindow () {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      preload: __dirname + '/ipc.js'
    }
  })
  win.loadFile('../main.html');
}

ipcMain.on('CheckDeviceAndFunc', (event, arg) => {
  event.returnValue = true;
  //event.sender.send('CheckDeviceAndFunc', Interface.CheckDeviceAndFunc());
})

//ipc.js
window.ipcRenderer = require('electron').ipcRenderer;
window.ipcMain = require('electron').ipcMain;
```

在vue调用的js中编写ipcRenderer

```
fingerRecog.js
const FingerRecog = {
    CheckDeviceAndFunc:function(){
      var res = window.ipcRenderer.sendSync('CheckDeviceAndFunc');
      console.log('CheckDeviceAndFunc be called in fingerRecog.js ' + res);
      return res;
      /*window.ipcRenderer.once('checkDeviceAndFunc', (event, args) => {
        console.log('checkDeviceAndFunc call in fingerRecog.js ' + args);
      });*/
    }
    
};

module.exports = FingerRecog;
```

即可以实现vue-electron-c++通信

## 打包发布 electron-packager

安装electron-packager
```
npm install electron-packager --save-dev
```

设置镜像
```
//.npmrc
ELECTRON_MIRROR=https://npm.taobao.org/mirrors/electron/
ELECTRON_BUILDER_BINARIES_MIRROR=http://npm.taobao.org/mirrors/electron-builder-binaries/
```

打包发布
```
"packager": "electron-packager ./ outAppName --platform=win32 --arch=ia32 --out ./OutApp --electron-version 11.2.1 --overwrite --icon=./dist/favicon.ico"
```

上述命令打包后的结果会把node_modules也打包进去导致打包后的整个文件夹十分庞大。。。


# reference 

[Quick Start Guide](https://electronjs.org/docs/tutorial/quick-start)
