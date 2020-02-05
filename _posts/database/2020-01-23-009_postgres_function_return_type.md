---
layout: default
title: 009_postgres_function_return_type
categories:
- C++
tags:
- C++
---
//Description: pg和oracle对比，function参数

//Create Date: 2020-01-23 12:52:13

//Author: channy

# 009_postgres_function_return_type

# function 中的return类型问题

## 问题描述

1. **当函数参数带一个out时，return后面带的类型必须和第一个out类型一致**
```sql
--Postgresql中的用法
create or replace function out_test1(a int, out b int) returns text
as $$
begin
b = 1;
return 'hellocr';
end $$;
ERROR:  function result type must be integer because of OUT parameters
```
> 来自于backend/commands/functioncmds.c中的CreateFunction函数


```sql
--oracle支持返回与out不同的类型
SQL> create function out_test1(a int, b out int, c out int) return varchar as
  2  begin
  3  b := a + 1;   
  4  c := a * 2;
  5  return 'x';
  6  end;
  7  /

Function created.
```

pg只能值传参，不能引用值参 (PostgreSQL doesn't support passing parameters by reference. All parameters are passed by value only.)

CreateFunction的interpret_function_parameter_list中要求如果参数中有out类型，procedure要求返回值类型requiredResultType为record，否则和第一个out的类型一致。

尝试：

step 1. 把该约束去掉

结果：能够正常create函数没有报错,具体赋值在后续问题6中一同修改

2. **当函数参数带有out时，函数实现内的return不能带值**
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
> 来自于pl/plpgsql/src/pl_gram.y中对return子句的解析

尝试：

step 1. 把pl_gram.y中对应的判断增加读取return的值

结果：能够正常create函数没有报错,具体赋值在后续问题6中一同修改

3. **函数查重时只检查输入参数不检查输出参数（oracle也不支持）**
```sql
--pg
create or replace function out_test3(a int, out b int) returns int
as $$
begin
b = 1;
return 2;
end $$;
CREATE FUNCTION

create function out_test3(a int) returns int
as $$
begin
return 1;
end $$;
ERROR:  function "out_test3" already exists with same argument types
```

```sql
--oracle
SQL> create function out_test1(a int) return int as
  2  begin
  3  return a + 2;
  4  end;
  5  /
 
SQL> create function out_test1(a int, b out int) return int as
  2  begin
  3  b := 5;
  4  return a + b;
  5  end;
  6  /
create function out_test1(a int, b out int) return int as
                *
ERROR at line 1:
ORA-00955: name is already used by an existing object
```
oracle不支持重载？
```sql
SQL> create function out_test1(a int, b int, c int) return int as
  2  begin
  3  return a + b + c;
  4  end;
  5  /
create function out_test1(a int, b int, c int) return int as
                *
ERROR at line 1:
ORA-00955: name is already used by an existing object
```

> backend/parser/parser.c文件中的extractArgTypes函数中有对out类型参数的过滤处理，该过程在查找已存在的函数时只对in参数进行处理，过滤掉out参数。(PS：其实extractArgTypes是在gram.c文件中)

错误信息在pg_proc.c的ProcedureCreate里面,SearchSysCache3查找已有的in类型相同的函数

pg创建的函数存储在系统表pg_proc中，其中字段proargtypes（oidvector）存储了in/variadic类型的参数；字段proallargtypes（oid[]）存储了out/inout类型的参数，下标从1开始；字段proargmodes（char[]）存储了参数模式，下标对应proargtypes。

查找使用cache,在syscache.c中，cacheinfo记录了ProcedureRelationId的3个key

系统表syscache，用户创建的表relcache

尝试:

step 1: 把proallargtypes加入到cache的key值里面

结果：失败。CatalogCacheInitializeCache(catcache.c)里面有限制cache的key值不能为空

step 2: 在SearchSysCache3查找后进行对比out类型，相同则继续原来的流程；不同则新增加函数

结果：修改中。。。
```
/* cache key columns should always be NOT NULL */
			Assert(attr->attnotnull);
```

4. **本质上同问题3(函数查重时只检查输入参数不检查输出参数)，procedure中调用函数也只检查输入参数**
```sql
--pg
--test1
create or replace procedure test1()
as $$
declare
a int=0;
b int=0;
begin
select out_test3(0,b) into a; //
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

//test2
create or replace procedure test2()
as $$
declare
a int=0;
b int=0;
begin
select out_test3(0) into a;
b = out_test3(0);
insert into out_table1 values(a);
insert into out_table1 values(b);
end $$;
CREATE PROCEDURE

call test2();
CALL
select * from out_table1;
 id 
----
  1
  1
```

```sql
--oracle
SQL> create procedure test3 is
a varchar(2);
b int;
c int;
begin
a := out_test1(4, b, c);
dbms_output.put_line('a = '||a);
dbms_output.put_line('b = '||b);
dbms_output.put_line('c = '||c);
end;
/  2    3    4    5    6    7    8    9   10   11  

Procedure created.

SQL> call test3();
a = x
b = 5
c = 8

Call completed.
```

错误信息来自于parse_func.c中的ParseFuncOrColumn,

parse_analyze过程中
```
transformOptionalSelectInto (analyze.c)
	transformStmt 
		transformCallStmt
			ParseFuncOrColumn (parse_func.c)
				func_get_detail (返回FUNCDETAIL_NOTFOUND)
					FuncnameGetCandidates (返回NULL)
```



5. **函数参数有多个out时，函数返回类型必须是record（同问题1）**
```sql
--pg
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

```sql
--oracle
SQL> create function out_test1(a int, b out int, c out int) return varchar as
  2  begin
  3  b := a + 1;   
  4  c := a * 2;
  5  return 'x';
  6  end;
  7  /

Function created.
```

6. **inout类型赋值只在函数里面，函数外面依旧是原值，赋给inout的值给了return**
```sql
create or replace function out_test6(a int, inout b int) returns int
as $$
begin
b = 6;
return;
end $$;
CREATE FUNCTION

create or replace procedure test3()
as $$
declare
a int=0;
b int=0;
begin
a = out_test6(0,b);
insert into out_table1 values(a);
insert into out_table1 values(b);
end $$;
CREATE PROCEDURE

call test3();
CALL
select * from out_table1;
 id 
----
  6
  0

create or replace procedure test4()
as $$
declare
a int=0;
b int=0;
begin
a = out_test6(0,b);
insert into out_table1 values(b);
end $$;
CREATE PROCEDURE

call test4();
CALL

select * from out_table1;
id 
----
  0
  
create type out_re as (b int, c int);
CREATE TYPE
create or replace procedure test5()
as $$
declare
ret out_re;
begin
ret = out_test5(0);
insert into out_table1 values(ret.b);
insert into out_table1 values(ret.c);
end $$;
CREATE PROCEDURE

call test5();
CALL

select * from out_table1;
 id 
----
  1
  2
```

7. **oracle用法参考**
```sql
--oracle的用法
CREATE OR REPLACE FUNCTION szy_fun (
 v_id int,
 v_msg out varchar2
)
RETURN int
AS

begin
  dbms_output.put_line(v_id);
  v_msg := 'hello'; 
  return 99;
end;

--如下调用，是可以获取到值
declare
  v_msg varchar(30);
  v_out int;
begin
  v_out := szy_fun(1,v_msg);
  dbms_output.put_line('v_msg is '||v_msg);
  dbms_output.put_line('v_out is '||v_out);
end;
```



8. **差异性对比总结**
	8.1 return 的类型，oracle支持各种类型，pg要求带一个out时return类型和out一致，带多个out时return类型为record
	
	8.2 return返回值赋值，oracle引用传递，pg值传递

## 函数调用的流程（pg源码）


[back](/)

