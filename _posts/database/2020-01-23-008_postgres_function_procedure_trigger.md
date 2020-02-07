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
- 样例1
```sql
--postgres
create function f_test_11(a int, out b int) returns int as $$
begin
b = 1;
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
```
- 样例2
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
						/exec_stmt_return (PLPGSQL_STMT_RETURN 返回语句,样例中stmt->retvarno=-1,但stmt->expr在只有in时不为空，有out时为空，return的值存储在estate->retval中)
				SPI_finish
```

```
//其它相关函数
exec_stmt_assign (pl_exec.c)
	exec_assign_expr
		exec_eval_expr
			exec_eval_simple_expr 
		exec_assign_value
ExecInterpExpr (execExprInterp.c,表达式求值,计算样例中的b=1)
ExecInterpExprStillValid
ExecEvalExpr (executor.h)
```

### 函数调用的流程（pg源码）


[back](/)

