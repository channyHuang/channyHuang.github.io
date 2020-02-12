---
layout: default
title: 008_postgres_function_procedure_trigger
categories:
- C++
tags:
- C++
---
//Description: function/procedure/trigger

//Create Date: 2020-01-23 12:50:51

//Author: channy

# 008_postgres_trigger
# 触发器

## 测试样例
### trigger测试样例

```sql
--postgres
create function proc() returns trigger as
$$
declare
begin
    raise notice '%', TG_NAME;
    return null;
end;
$$
language plpgsql;

create trigger testtri after insert on testtable for each statement execute procedure proc();
```

//执行insert函数触发触发器
```
postgres=# insert into testtable values(1020, 1, 1);
NOTICE:  testtri
INSERT 0 1
```

### function测试样例

```sql
--postgres
create function f_test_11(a int, out b int) returns int as $$
begin
b = 1;
return;
end $$
language plpgsql;

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

create or replace procedure p_test_11() as $$
declare
a int=0;
b int=0;
begin 
a = f_test_11(b);
raise notice '%', a;
raise notice '%', b;
end $$
language plpgsql;

create type res_test_12 as (b int, c int);
--CREATE TYPE
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

postgres=# call p_test_11();
NOTICE:  1
NOTICE:  0
CALL

postgres=# call p_test_12();
NOTICE:  9
NOTICE:  (12,27)
NOTICE:  14
CALL
```

```sql
--postgresql，in参数值可以在函数内部被临时修改，而oracle的不可以修改
create function out_test2(a int, b int) returns int as $$
begin
b = 1;
return a + b;
end $$
language plpgsql;

create or replace procedure test2() as $$
declare
a int=0;
b int=5;
begin 
a = out_test2(3, b);
raise notice '%', a;
raise notice '%', b;
end $$
language plpgsql;

--pg result
postgres=# call test2();
NOTICE:  4
NOTICE:  5
CALL
```

## 基本流程
### create function 创建函数

![函数创建流程](./procedure_create.png)

function对应于CreateFunctionStmt，同样地，trigger对应CreateTrigStmt

```
(gdb) p *$stmt
$5 = {type = T_CreateFunctionStmt, is_procedure = false, 
  replace = false, funcname = 0x138f190, parameters = 0x0, 
  returnType = 0x138f270, options = 0x138f488}
```

* create属于utility事务，在重写计划过程中没有实质性的操作

```
...
ProcessUtilitySlow (utility.c)
	CreateFunction (functioncmds.c)
		compute_function_attributes (计算各种参数，如参数型号等) 
			buildoidvector (处理所有in参数，不考虑out)
			construct_array (处理所有参数)
		SearchSysCache1 (处理语言)
		(options里面的DefElem,as_item存函数体)
		interpret_function_parameter_list (验证参数的有效性，根据out参数确定返回值类型)
		interpret_AS_clause ()
		ProcedureCreate (pg_proc.c,存到pg_proc系统表)
			SearchSysCache3 (查找同名同in参数类型的函数，处理重载，插入或更新系统表)
			recordDependencyOn (pg_depend.c, 处理依赖，系统表pg_depend)
			OidFunctionCall1 (语言验证)
	/CreateTrigger (存到pg_trigger系统表)
```

[pg_proc](https://www.postgresql.org/docs/12/catalog-pg-proc.html)
[pg_trigger](http://postgres.cn/docs/11/catalog-pg-trigger.html)

#### 相关结构体

```c++
typedef struct FmgrInfo
{
	PGFunction	fn_addr;		/* pointer to function or handler to be called */
	Oid			fn_oid;			/* OID of function (NOT of handler, if any) */
	short		fn_nargs;		/* number of input args (0..FUNC_MAX_ARGS) */
	bool		fn_strict;		/* function is "strict" (NULL in => NULL out) */
	bool		fn_retset;		/* function returns a set */
	unsigned char fn_stats;		/* collect stats if track_functions > this */
	void	   *fn_extra;		/* extra space for use by handler */
	MemoryContext fn_mcxt;		/* memory context to store fn_extra in */
	fmNodePtr	fn_expr;		/* expression parse tree for call, or NULL */
} FmgrInfo;

typedef struct FunctionCallInfoBaseData
{
	FmgrInfo   *flinfo;			/* ptr to lookup info used for this call */
	fmNodePtr	context;		/* pass info about context of call */
	fmNodePtr	resultinfo;		/* pass or return extra info about result */
	Oid			fncollation;	/* collation for function to use */
#define FIELDNO_FUNCTIONCALLINFODATA_ISNULL 4
	bool		isnull;			/* function must set true if result is NULL */
	short		nargs;			/* # arguments actually passed */
#define FIELDNO_FUNCTIONCALLINFODATA_ARGS 6
	NullableDatum args[FLEXIBLE_ARRAY_MEMBER];
} FunctionCallInfoBaseData;
```

### call procedure 调用函数

```
...
ProcessUtility (utility.c)
	standard_ProcessUtility
		ExecuteCallStmt (functioncmds.c)
			SearchSysCache1 (查找procedure)
			expand_function_arguments (clauses.c,处理参数)
			InitFunctionCallInfoData　(初始化)
			ExecPrepareExpr (execExpr.c)
			FunctionCallInvoke (plpgsql_call_handler, pl_handler.c. 返回estate.retval)
				plpgsql_estate_setup
				SPI_connect_ext
				plpgsql_compile (返回PLpgSQL_function)
				plpgsql_exec_function (pl_exec.c. 返回estate.retval，SPI_datumTransfer解析SPI返回的record。trigger也类似，plpgsql_exec_event_trigger)
					copy_plpgsql_datums
					exec_stmt (Java spi. 类似于Android里面调用C++用NDK?)
						exec_stmt_block 
							exec_stmts
								exec_stmt (只有in时返回值存储在PLpgSQL_execstate结构体的retval中) 
						/exec_stmt_assign (PLPGSQL_STMT_ASSIGN 赋值语句，临时值存储在estate->datums[stmt->varno]中)
						/exec_stmt_return (PLPGSQL_STMT_RETURN 返回语句,样例中stmt->retvarno=-1/3,但stmt->expr在只有in时不为空，有out时为空，return的值存储在estate->retval中)
				SPI_finish
```

```
plpgsql_call_handler (pl_handler.c, call procedure p_test_12)
	plpgsql_exec_function
		plpgsql_estate_setup
		exec_stmt (pl_exec.c)
			exec_stmt_block
				exec_stmts
					exec_stmt	
						exec_stmt_assign (pl_exec.c)
							exec_assign_expr
								exec_eval_expr
									exec_eval_simple_expr (expr->expr_simple_state(op))
										ExecInitExprWithParams
											ExecInitExprRec
												ExecInitFunc
										ExecEvalExpr (executor.h)
											ExecInterpExprStillValid (execExprInterp.c)
												ExecInterpExpr (execExprInterp.c,表达式求值,计算样例中的b=1,传入参数econtext中存储了函数的in参数econtext->ecxt_param_list_info->paramFetchArg，EEOP_PARAM_CALLBACK->plpgsql_param_eval_var传入输入参数的值存储在estate->datums[], EEOP_FUNCEXPR进入函数f_test_12)
													plpgsql_call_handler (call function f_test_12)
							exec_assign_value
							
plpgsql_call_handler (call function f_test_12)
	plpgsql_exec_function
```

```
--postgres
create procedure p_test_12() as $$
declare
ret res_test_12;
a int = 14;
begin
raise notice 'begin';
ret = f_test_12(a); //assign
raise notice 'end';
raise notice '%', ret;
raise notice '%', a;
end $$
language plpgsql;

//exec_stmts 调试，对应p_test_12里面begin和end之间的五个语句
(gdb) p *(PLpgSQL_stmt *)(stmts->head->data.ptr_value)
$24 = {cmd_type = PLPGSQL_STMT_RAISE, lineno = 6, stmtid = 1}
(gdb) p *(PLpgSQL_stmt *)(stmts->head->next->data.ptr_value)
$25 = {cmd_type = PLPGSQL_STMT_ASSIGN, lineno = 7, stmtid = 2}
(gdb) p *(PLpgSQL_stmt *)(stmts->head->next->next->data.ptr_value)
$26 = {cmd_type = PLPGSQL_STMT_RAISE, lineno = 8, stmtid = 3}
(gdb) p *(PLpgSQL_stmt *)(stmts->head->next->next->next->data.ptr_value)
$27 = {cmd_type = PLPGSQL_STMT_RAISE, lineno = 9, stmtid = 4}
(gdb) p *(PLpgSQL_stmt *)(stmts->head->next->next->next->next->data.ptr_value)
$28 = {cmd_type = PLPGSQL_STMT_RAISE, lineno = 10, stmtid = 5}
(gdb) p *(PLpgSQL_stmt *)(stmts->head->next->next->next->next->next->data.ptr_value)
$29 = {cmd_type = PLPGSQL_STMT_RETURN, lineno = 0, stmtid = 7}

(gdb) set $stmt = (PLpgSQL_stmt_assign *)(stmts->head->next->data.ptr_value)
(gdb) p *$stmt
$31 = {cmd_type = PLPGSQL_STMT_ASSIGN, lineno = 7, stmtid = 2, varno = 1, 
  expr = 0x556203f582e8}
(gdb) set $expr = (PLpgSQL_expr *)($stmt->expr)
(gdb) p *$expr
$32 = {query = 0x556203f58380 "SELECT f_test_12(a)", plan = 0x556203f5e888, 
  paramnos = 0x556203f58a28, rwparam = -1, func = 0x556203e81f60, ns = 0x556203f58110, 
  expr_simple_expr = 0x556203f5e2e8, expr_simple_generation = 2, expr_simple_type = 2249, 
  expr_simple_typmod = -1, expr_simple_state = 0x556203f35178, expr_simple_in_use = false, 
  expr_simple_lxid = 21}
(gdb) set $func = (PLpgSQL_function *)$expr->func
(gdb) p *$func
$33 = {fn_signature = 0x556203f2d948 "p_test_12()", fn_oid = 24629, fn_xmin = 597, 
  fn_tid = {ip_blkid = {bi_hi = 0, bi_lo = 78}, ip_posid = 6}, 
  fn_is_trigger = PLPGSQL_NOT_TRIGGER, fn_input_collation = 0, 
  fn_hashkey = 0x556203f272e0, fn_cxt = 0x556203f2d830, fn_rettype = 2278, 
  fn_rettyplen = 4, fn_retbyval = true, fn_retistuple = false, fn_retisdomain = false, 
  fn_retset = false, fn_readonly = false, fn_prokind = 112 'p', fn_nargs = 0, 
  fn_argvarnos = {0 <repeats 100 times>}, out_param_varno = -1, found_varno = 0, 
  new_varno = 0, old_varno = 0, resolve_option = PLPGSQL_RESOLVE_ERROR, 
  print_strict_params = false, extra_warnings = 0, extra_errors = 0, nstatements = 7, 
  ndatums = 3, datums = 0x556203f589f0, copiable_size = 200, action = 0x556203f58938, 
  cur_estate = 0x7ffc5aa2f6d0, use_count = 1}
```

```
exec_eval_simple_expr (econtext->ecxt_param_list_info = setup_param_list(estate, expr);)

Breakpoint 11, plpgsql_estate_setup (estate=0x7ffc5aa2ee50, 
    func=0x556203e82378, rsi=0x0, simple_eval_estate=0x0) at pl_exec.c:3880
3880	{
(gdb) p *func
$52 = {fn_signature = 0x556203f159b8 "f_test_12(integer)", fn_oid = 24630, 
  fn_xmin = 599, fn_tid = {ip_blkid = {bi_hi = 0, bi_lo = 78}, ip_posid = 7}, 
  fn_is_trigger = PLPGSQL_NOT_TRIGGER, fn_input_collation = 0, 
  fn_hashkey = 0x556203f27128, fn_cxt = 0x556203f158a0, fn_rettype = 2249, 
  fn_rettyplen = -1, fn_retbyval = false, fn_retistuple = true, 
  fn_retisdomain = false, fn_retset = false, fn_readonly = false, 
  fn_prokind = 102 'f', fn_nargs = 1, fn_argvarnos = {0 <repeats 100 times>}, 
  out_param_varno = 3, found_varno = 4, new_varno = 0, old_varno = 0, 
  resolve_option = PLPGSQL_RESOLVE_ERROR, print_strict_params = false, 
  extra_warnings = 0, extra_errors = 0, nstatements = 8, ndatums = 5, 
  datums = 0x556203f7f6d8, copiable_size = 288, action = 0x556203f7f680, 
  cur_estate = 0x0, use_count = 1}	
```

```
plpgsql_exec_function //把fcinfo里的in值存储到estate->datums里面

(gdb) set $dat = (PLpgSQL_var *)(estate.datums[0])
(gdb) p *$dat
$11 = {dtype = PLPGSQL_DTYPE_VAR, dno = 0, refname = 0x55732b27f0c0 "a", lineno = 0, 
  isconst = false, notnull = false, default_val = 0x0, datatype = 0x55732b27efb0, 
  cursor_explicit_expr = 0x0, cursor_explicit_argrow = 0, cursor_options = 0, value = 0, 
  isnull = true, freeval = false, promise = PLPGSQL_PROMISE_NONE}
(gdb) p fcinfo->args[0].value
$12 = 14

ExecInterpExpr //op = state->steps; fcinfo = op->d.func.fcinfo_data;

(gdb) 
ExecInitFunc (scratch=0x7ffe9db56030, node=0x55732b276968, 
    args=0x55732b276a20, funcid=32825, inputcollid=0, state=0x55732b283798)
    at execExpr.c:2229
(gdb) p *fcinfo
$28 = {flinfo = 0x55732b283830, context = 0x0, resultinfo = 0x0, 
  fncollation = 0, isnull = false, nargs = 1, args = 0x55732b2838a8}
(gdb) p *fcinfo->args
$29 = {value = 0, isnull = false}


//a int = 14
Breakpoint 1, ExecInitExprWithParams (node=0x55732b276bf8, ext_params=0x0)
    at execExpr.c:158
158	{
(gdb) p *node
$1 = {type = T_Const}
(gdb) p *(Const *)node
$2 = {xpr = {type = T_Const}, consttype = 23, consttypmod = -1, 
  constcollid = 0, constlen = 4, constvalue = 14, constisnull = false, 
  constbyval = true, location = 7}
(gdb) c
Continuing.

//f_test_12(a)
Breakpoint 1, ExecInitExprWithParams (node=0x55732b27a888, 
    ext_params=0x55732b25ae30) at execExpr.c:158
158	{
(gdb) p *node
$3 = {type = T_FuncExpr}
(gdb) p *(FuncExpr *)node
$4 = {xpr = {type = T_FuncExpr}, funcid = 32825, funcresulttype = 2249, 
  funcretset = false, funcvariadic = false, funcformat = COERCE_EXPLICIT_CALL, 
  funccollid = 0, inputcollid = 0, args = 0x55732b27a940, location = 7}
```


### 函数调用的流程（pg源码）

![函数调用流程图](./procedure_call.png)

| 函数名 | 功能简介 | 输出 |
|:---|:---|:---|
| plpgsql_call_handler | call的入口 | 输入FunctionCallInfoBaseData，输出Datum即为return的返回值 |
| plpgsql_exec_function | 调用运行函数 | 输出Datum即为return的返回值 |
| exec_stmt | 计算return的表态式 | 输出return code，返回值在输入参数estate中存储，函数第一次走exec_stmt_block，后续根据函数体的具体内容选择assign赋值、call调用其它函数、return返回、if/case/loop等不同的分支 |
| exec_stmt_assign | 处理函数体内的赋值操作，在执行过程中，对函数的in/out参数的赋值结果都记录在输入参数estate->datums[]中 | void | 
| exec_stmt_return | 处理返回操作，有stmt->retvarno个参数，对于多个out，estate->datums[retvarno]存储返回结果record（PLPGSQL_DTYPE_ROW）| 输出return code |
| make_tuple_from_row | 把out参数转化成record |  void |

由于pg支持同名函数，而函数又只用in参数的类型进行区分，故returns的类型只能限定为和out参数类型一致（只有一个out参数）或是record类型（有多个out参数），否则的话会出现out参数值和returns的值无法同时传回来的问题

| out参数的个数 | 函数返回值类型限制 | 函数返回值结构 | 函数返回值存储情况 |
|:---|:---|:---|:---|
| 0 | 无 | Datum | 存储函数体中"return {expr};"中表达式expr的值 |
| 1 | 和out参数类型一致 | Datum |  执行函数后out参数的值 |
| 2 | record | Datum | 执行函数后所有out参数的值集 | 

[back](/)

