---
layout: default
title: 2020-01-23-009_postgres_function_return_type.md
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-01-23 12:52:13

//Author: channy

# 009_postgres_function_return_type

# function 中的return类型问题

## 问题描述

1. 当函数参数带一个返回值时，return后面带的类型必须和返回值类型一致
> 来自于backend/commands/functioncmds.c中的CreateFunction函数
```sql
--Postgresql中的用法
create or replace function out_test1(a int, out b int) returns text
as $$
begin
b = 1;
return;
end $$;
ERROR:  function result type must be integer because of OUT parameters
```
CreateFunction的interpret_function_parameter_list中要求如果参数中有out类型，procedure要求返回值类型为record，否则和第一个out的类型一致。

尝试1：把该约束去掉后能够正常create函数没有报错,运行函数是否会报错放在后续进行测试

2. 当函数参数带有out时，函数实现内的return不能带值
> 来自于pl/plpgsql/src/pl_gram.y中对return子句的解析
```
create or replace function out_test2(a int, out b int) returns int
as $$
begin
b = 1;
return 2;
end $$;
ERROR:  RETURN cannot have a parameter in function with OUT parameters
LINE 5: return 2;
``` 
尝试1：把pl_gram.y中对应的判断增加读取return的值,能够正常create函数没有报错,运行函数是否会报错放在后续进行测试

3. 函数查重时只检查输入参数不检查输出参数
> backend/parser/parser.c文件中的extractArgTypes函数中有对out类型参数的过滤处理，该过程在查找已存在的函数时只对in参数进行处理，过滤掉out参数。(PS：其实是在gram.c文件中)
```sql
create or replace function out_test3(a int, out b int) returns int
as $$
begin
b = 1;
return;
end $$;
CREATE FUNCTION

create function out_test3(a int) returns int
as $$
begin
return 1;
end $$;
ERROR:  function "out_test3" already exists with same argument types
```
extractArgTypes函数返回所有非out和非table类型，不能单纯地去掉if判断，否则会出现把test1(a int, b int)和test1(a int, out b int)判断为重复函数。

错误信息在pg_proc.c的ProcedureCreate里面

尝试:

step 1. 返回类型list的同时返回mode（in,out,inout,variadic,table）

4. 带有out参数的函数不能被procedure使用？
```
create or replace procedure test1()
as $$
declare
a int=0;
b int=0;
begin
select out_test3(0,b) into a;
insert into out_table1 values(a);
insert into out_table1 values(b);
end $$;
CREATE PROCEDURE

call test1();
ERROR:  function out_test3(integer, integer) does not exist
LINE 1: select out_test3(0,b)
               ^
HINT:  No function matches the given name and argument types. You might need to add explicit type casts.
QUERY:  select out_test3(0,b)
CONTEXT:  PL/pgSQL function test1() line 6 at SQL statement
```

5. 函数参数有多个out时，函数返回类型必须是record
```
create or replace function out_test4(a int, out b int, out c int) returns int
as $$
begin
b = 1;
c = 2;
return;
end $$;
ERROR:  function result type must be record because of OUT parameters

create or replace function out_test5(a int, out b int, out c int) returns record
as $$
begin
b = 1;
c = 2;
return;
end $$;
CREATE FUNCTION
```

[back](/)

