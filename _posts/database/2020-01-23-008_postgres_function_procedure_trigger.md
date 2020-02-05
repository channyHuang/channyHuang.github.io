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

```
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


### call procedure 调用函数

[back](/)

