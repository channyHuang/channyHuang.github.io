---
layout: default
title: function_return_modify_details
categories:
- Database
tags:
- Database
---
//Description: postgres 函数和程序的返回值研究

//Create Date: 2020-02-12 17:46:30

//Author: channy

[toc]

# function_return_modify_details

## 测试样例

> procedure没有returnType

```
create function f_test_12(a int, out b int, out c int) returns record as $$
begin
raise notice 'begin f'; 
a = 9;
b = a + 3;
c = a * 3;
raise notice 'c = %', c;
return;
end $$
language plpgsql;

create procedure p_test_12() as $$
declare
ret res_test_12;
x int = 14;
begin
raise notice 'begin p';
ret = f_test_12(x);
raise notice '%', ret;
end $$
language plpgsql;
```

## 返回类型判断

> backend/commands/functioncmds.c

```
 305         if (fp->mode != FUNC_PARAM_IN && fp->mode != FUNC_PARAM_VARIADIC)
 306         {
 307             //if (objtype == OBJECT_PROCEDURE)
 308             //  *requiredResultType = RECORDOID;
 309             //else if (outCount == 0) /* save first output param's type */
 310             //  *requiredResultType = toid;
 311             outCount++;
 312         }
 
 432     if (outCount > 0 || varCount > 0)
 433     {
 434         *allParameterTypes = construct_array(allTypes, parameterCount, OIDOID,
 435                                              sizeof(Oid), true, 'i');
 436         *parameterModes = construct_array(paramModes, parameterCount, CHAROID,
 437                                           1, true, 'c');
 438         //if (outCount > 1)
 439         //  *requiredResultType = RECORDOID;
 440         /* otherwise we set requiredResultType correctly above */
 441     }
```

> pl/plpgsql/src/pl_gram.y

```
3256     else if (plpgsql_curr_compile->out_param_varno >= 0)
3257     {
3258         int tok = yylex();
3259         
3260         if (tok == T_DATUM && plpgsql_peek() == ';' &&
3261             (yylval.wdatum.datum->dtype == PLPGSQL_DTYPE_VAR ||
3262              yylval.wdatum.datum->dtype == PLPGSQL_DTYPE_PROMISE ||
3263              yylval.wdatum.datum->dtype == PLPGSQL_DTYPE_ROW ||
3264              yylval.wdatum.datum->dtype == PLPGSQL_DTYPE_REC))
3265         {
3266             new->retvarno = yylval.wdatum.datum->dno;
3267         
3268             tok = yylex();
3269             Assert(tok == ';');
3270         }
3271         else
3272         {
3273             plpgsql_push_back_token(tok);
3274             new->expr = read_sql_expression(';', ";");
3275         }
3276    
3277         //if (yylex() != ';')
3278         //  ereport(ERROR,
3279         //          (errcode(ERRCODE_DATATYPE_MISMATCH),
3280         //           errmsg("RETURN cannot have a parameter in function with OUT parameters     "),
3281         //           parser_errposition(yylloc)));
3282         //new->retvarno = plpgsql_curr_compile->out_param_varno;
3283     }
```

# 正常pg的function和procedure

> function一定要有返回值（return或out）

## 只有in

```
create function f_test_12(a int, b varchar) returns void as $$
begin
raise notice 'begin f'; 
a = 9;
b = 'x';
raise notice 'a = %', b;
end $$
language plpgsql;
```

```error!!!
create function f_test_12(a int, b varchar) as $$
begin
raise notice 'begin f'; 
a = 9;
b = 'x';
raise notice 'a = %', b;
--return;
end $$
language plpgsql;
ERROR:  function result type must be specified
```

```
create function f_test_12(a int, b varchar) returns int as $$
begin
raise notice 'begin f'; 
a = 9;
b = 'x';
raise notice 'a = %', b;
return 8;
end $$
language plpgsql;
```

## 有in/out

### 无返回

```
create function f_test_12(a int, out b int) as $$
begin
raise notice 'begin f'; 
a = 9;
b = a + 3;
raise notice 'a = %', a;
return;
end $$
language plpgsql;
CREATE FUNCTION

postgres=# select f_test_12(2);
NOTICE:  begin f
NOTICE:  a = 9
 f_test_12 
-----------
        12
(1 row)
```

### 返回类型同out(只一个out)

```
postgres=# create function f_test_12(a int, out b int) returns int as $$
begin
raise notice 'begin f'; 
a = 9;
b = a + 3;
raise notice 'a = %', a;
return;
end $$
language plpgsql;
CREATE FUNCTION

postgres=# select f_test_12(5);
NOTICE:  begin f
NOTICE:  a = 9
 f_test_12 
-----------
        12
(1 row)
```

### 返回record(多个out)

```
postgres=# create function f_test_12(a int, out b int, out c int) returns record as $$
begin
raise notice 'begin f'; 
a = 9;
b = a + 3;
c = a * 3;
raise notice 'c = %', c;
return;
end $$
language plpgsql;
CREATE FUNCTION

postgres=# select f_test_12(3);
NOTICE:  begin f
NOTICE:  c = 27
 f_test_12         
-----------
 (12,27)
(1 row)
```

# 修改后pg的function

# 只有一个out

```
create function f_test_12(a int, out b int) returns varchar as $$
begin
raise notice 'begin f'; 
a = 9;
b = a + 3;
raise notice 'a = %', a;
return;
end $$
language plpgsql;
```

[back](/)

