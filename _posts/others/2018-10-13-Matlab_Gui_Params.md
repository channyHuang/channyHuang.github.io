---
layout: default
---

//Author: channy

//Create Date: 2018-10-13 13:44:29

//Description: Matlab gui 传递参数

# Matlab_Gui_Params

> 运用gui本身的varain{}、varaout{}传递参数（注：这种方式仅适用与gui间传递数据，且只适合与主子结构，及从主gui调用子gui，然后关掉子gui，而不适合递进结构，即一步一步实现的方式）

A.        输入参数传递：

比如子GUI的名称为subGUI, 设想的参数输入输出为：[out1, out2] = subGUI(in1, in2)

在subGUI的m文件中（由GUIDE自动产生）：

	第一行的形式为：function varargout = subGUI(varargin)，该行不用做任何修改；varargin 和 varargout 分别是一个可变长度的cell数组。输入参数in1和in2保存在varargin中，输出参数out1，out2包含在varargout中；

	在subGUI的OpeningFcn中，读入参数，并用guidata保存，即：
```
handles.in1 = varargin{1};
handles.in2 = varargin{2};
guidata(hObject, handles);
```

B.        返回参数的设置：

1)         在GUI子程序的OpeningFcn函数的结尾加上uiwait(handles.figure1); %figure1是subGUI的Tag；

2)         subGUI中控制程序结束（如"OK”和"Cancel"按钮）的callback末尾加上uiresume(handles.figure1)，不要将delete命令放在这些callback中；

3)         在子GUI的OutputFcn中设置要传递出去的参数，如 varargout{1} = handles.out1；varargout{2} = handles.out2;末尾添加 delete(handles.figure1); 结束程序。
 
在GUI的OpenFcn中，如果不加uiwait， 程序会直接运行到下面，执行OutputFcn。也就是说程序一运行，返回值就确定了，再在其它部分对handles.output作更改也没有效果了。加上uiwait后，只有执行了uiresume后，才会继续执行到OutputFcn，在此之前用户有充分的时间设置返回值。

通过以上设置以后，就可以通过 [out1, out2] = subGUI(in1, in2) 的形式调用该子程序。在一个GUI中调用另一个GUI时，主GUI不需要特别的设置，同调用普通的函数一样。在打开子GUI界面的同时，主程序还可以响应其它的控件。不需要担心子GUI的返回值被传错了地方。

> 应用setappdata\getappdata与rmappdata函数(gui间和gui内，推荐使用）

使用上面三个函数最有弹性处理数据的传送问题，与UserData的方式相类似，但是克服UserData的缺点，使一个对象能存取多个变量值。

(1)getappdata函数

VALUE＝getappdata(H,NAME)

(2)setappdata函数

setappdata(H,NAME,VALUE)

(3)rmappdata

rmappdata(H,NAME)

首先在matlab命令窗口输入magic(3)数据，因此当前的工作空间就存储了magic(3)这组数据了，然后建立一个按钮来获取并显示magic(3)数据

```matlab
>>A=magic(3);
>>setappdata(gcf,'A','A');%save
>>uicontrol(‘String’,'显示矩阵A'，'callback','A=getappdata(gcf,'A')');
```

当在主子gui内调用时，可以如下设置：fig1调用fig2时，使用fig2指令来打开fig2,
在fig2的m文件中，在回调函数中用setappdata(fig1,'A',A)实现返回fig1，并将参数A传递给fig1；然后在fig1的使用A的地方添加A=getappdata（fig1，‘A’）。

但这种方式的一个问题就是每调用一次，fig1的数据就得初始化一次，这是因为setappdata(fig1,'A',A)中出现了fig1，调用一次setappdata就得运行一次fig1的缘故，解决方案就是把setappdata(fig1,'A',A)改为setappdata(0,'A',A)，这样把A读入matlab workspace，相当于一个全局变量了，但当然比直接用global定义全局变量好！
 
 

[back](./)

