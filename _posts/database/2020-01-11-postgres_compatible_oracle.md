---
layout: default
title: 2020-01-11-postgres_compatible_oracle.md
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



[back](/)

