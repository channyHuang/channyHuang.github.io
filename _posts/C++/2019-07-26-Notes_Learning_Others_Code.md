---
layout: default
title: Notes_Learning_Others_Code.md
categories:
- C++
tags:
- C++
---
//Description: In a new project, teammates offer a base version of the fundamental classes. Heres are just some notes after reading theirs code.

//Create Date: 2019-07-26 09:24:57

//Author: channy

# 2019-07-26-Notes_Learning_Others_Code

> Summaries generally use code blocks to macro definition #define

For example, most of my functions use try-catch block, then it can be written as 

```c++
#define TRY_CATCH_BLOCK(func, msg) \
	try { \
		func;
	} \
	catch(std::exception &e) { \
		writeLog(#msg" catch an exception %s.", e.what()); \
	} \
	catch(...) { \
		writeLog(#msg" catch an unknow exception.");
	}
```

Then I can use it freely and simply...

> 把常用的代码段总结成宏定义

中文翻译好烦。。。请求外援。。。

> If different inputs needs to run different processes, then can define them in config files (ini,xml,etc)

For example, if input is x, need to run A -> B -> C; 
 
while if input is y, need to run A -> C -> B;

then I can define like this in config files:

```
"input":{
	list[{
	"type":"x",
	"process":["A","B","C"]
	},
	{
	"type":"y",
	"process":["A","C","B"]
	}]
}
``` 

Once demand is changed, I can only change config files but don't need to change my code and release a new version. Of cause the config files can be encrypted to make our project more safe.

> Class definition and declaration can also use macro definication

没想好怎么总结，想好再补。。。

```c++
```

> Same as above, when loading others dynamic library, some common code blocks can also be written as macro definition

```c++
#define LOAD_DLLFUN(FNAME, FNAME_STR) FNAME=(TYPE_##FNAME) qLib.resolve(FNAME_STR); \
        if (!FNAME){writeLog(QString().sprintf("load %s failed", FNAME_STR));return UNKNOW_ERROR_CODE;}
```

[back](./)

