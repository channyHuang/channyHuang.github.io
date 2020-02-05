---
layout: default
title: 001_postgres_compatible_oracle
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-01-11 15:31:04

//Author: channy

# postgres_compatible_oracle

# 任务1: 兼容oracle的delete语句

pg: DELETE FROM tablename;

oracle: DELETE tablename;

关键词匹配问题，直接在gram.y中把FROM替换成opt_from: FROM {} | {};即可。注意如果configure之后才安装bison需要重新configure，否则make最后一行不会报错，但gram.c并不包含修改，会导致修改无效。

# 任务2: 兼容oracle外连接(+)语句

pg: SELECT * FROM table1, table2 WHERE table1.id = table2.id;

oracle: SELECT * FROM table1, table2 WHERE table1.id(+) = table2.id;

参考ADB，增加终结符，在yylex中判断返回cur_token，并在parsetree转变成querytree时转换回JoinExpr，后续同pg

# 任务3: 分析pg12中的虚拟列(generated column)加入到pg11中的方法

1. 关键词匹配，增加generated always as的匹配语法，增加stored等关键词

2. create table时在DefineGeneration中处理虚拟列的关系信息

3. update时在语义分析中把虚拟列也加入targetlist

4. 学习WAL日志相关结构体、基本流程等

[back](/)

