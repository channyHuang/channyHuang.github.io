---
layout: default
title: 005_postgres_generated_column
categories:
- Database
tags:
- Database
---
//Description:

//Create Date: 2020-01-18 23:20:08

//Author: channy

# postgres generated column

## 带虚拟列的表的create

* create属于utility事务，在重写计划过程中没有实质性的操作

//create 
```
PortalRun (pquery.c)
	PortalRunMulti
		PortalRunUtility (utility.c)
			ProcessUtility
				standard_ProcessUtility
					ProcessUtilitySlow
						transformCreateStmt (parse_utilcmd.c)
							transformColumnDefinition (在ColumnDef中记录generated，值为default)
						DefineRelation
						transformRelOptions
						NewRelationCreateToastTable
```

* 主要操作在<span style="color:red;">**DefineRelation**</span>中
* 为了修改系统表pg_type,pg_class,pg_constraint,pg_attrdef等
* 每修改一张表（包括系统表）都会触发WAL日志写入

//create table testtable (height integer, width integer, area integer generated always as (height * width) stored);
```
DefineRelation (tablecmds.c)
//数据准备
	(权限检査oid valid? tablespaceid valid? heaptuple valid?)
	transformRelOptions (把options list改写成pg_class中reloptions字段的格式)
	heap_reloptions (校验)
	MergeAttributes (对继承表合并属性，该语句中没有继承表)
	BuildDescForRelation (创建tupleDesc结构用于pg_attribute系统表)
	(对属性定义链表中的每一个属性进行处理，査看是否有默认值、表达式或约束检査)
//写数据
	heap_create_with_catalog (heap.c, 创建表的物理文件并修改相应的系统表)
//初始化表数据
		heap_create (创建文件到relcache中)
			heapam_relation_set_new_filenode (在base/对应数据库oid/目录下创建新文件)
//写系统表数据
		AddNewRelationType (写pg_type)
			TypeCreate (pg_type.c)
				CatalogTupleInsert (indexing.c)
					simple_heap_insert (heapam.c)
						heap_insert
				GenerateTypeDependencies (写pg_depend)
		AddNewRelationTuple (写pg_class)
		AddNewAttributeTuples (写pg_attribute)
		StoreConstraints (pg_constraint, 此语句中该表不改变; pg_attrdef, 增加虚拟列的默认值记录)
//处理constraints，虚拟列的计算表达式存储在这里
	AddRleationNewConstraints (处理表中约束与默认值)
		cookConstraint (把表达式转换成可存储的结构，同时更新系统表pg_class中constraint的数量)
//其它
	(处理分区表)
	StoreCataloglnheritance (对继承表存储继承关系)
```

PS: 系统表结构

[pg_type](https://www.postgresql.org/docs/12/catalog-pg-type.html) ???

[pg_class](https://www.postgresql.org/docs/12/catalog-pg-class.html) 存储表、索引、视图等的属性

[pg_attribute](https://www.postgresql.org/docs/12/catalog-pg-attribute.html) 存储所有表每一列的属性

[pg_attrdef](https://www.postgresql.org/docs/12/catalog-pg-attrdef.html) 存储列的默认值

[pg_depend] (https://www.postgresql.org/docs/12/catalog-pg-depend.html) 存储依赖关系

```
Breakpoint 2, heap_create_with_catalog (
    relname=0x7ffff5e655f0 "testtable", relnamespace=2200, 
    reltablespace=0, relid=0, reltypeid=0, reloftypeid=0, ownerid=10, 
    accessmtd=2, tupdesc=0x1a20660, cooked_constraints=0x0, 
    relkind=114 'r', relpersistence=112 'p', shared_relation=false, 
    mapped_relation=false, oncommit=ONCOMMIT_NOOP, reloptions=0, 
    use_user_acl=true, allow_system_table_mods=false, is_internal=false, 
    relrewrite=0, typaddress=0x0) at heap.c:1095
```

```
Breakpoint 3, cookDefault (pstate=0x1a1df88, raw_default=0x1a08980, 
    atttypid=1043, atttypmod=9, attname=0x7f4522c5bb54 "area", 
    attgenerated=115 's') at heap.c:2983
```

## 系统表具体内容
### pg_type
```
postgres=# select * from pg_type limit 5 offset 411;
  oid  |  typname   | typnamespace | typowner | typlen | typbyval | typtype | typcategory | typispreferred | typisdefined | typdelim | typrelid | typelem | typarray | t
ypinput  | typoutput  | typreceive  |   typsend   | typmodin | typmodout |    typanalyze    | typalign | typstorage | typnotnull | typbasetype | typtypmod | typndims | 
typcollation | typdefaultbin | typdefault | typacl 
-------+------------+--------------+----------+--------+----------+---------+-------------+----------------+--------------+----------+----------+---------+----------+--
---------+------------+-------------+-------------+----------+-----------+------------------+----------+------------+------------+-------------+-----------+----------+-
-------------+---------------+------------+--------
 16461 | testtable  |         2200 |       10 |     -1 | f        | c       | C           | f              | t            | ,        |    16459 |       0 |    16460 | r
ecord_in | record_out | record_recv | record_send | -        | -         | -                | d        | x          | f          |           0 |        -1 |        0 | 
           0 |               |            | 
 16460 | _testtable |         2200 |       10 |     -1 | f        | b       | A           | f              | t            | ,        |        0 |   16461 |        0 | a
rray_in  | array_out  | array_recv  | array_send  | -        | -         | array_typanalyze | d        | x          | f          |           0 |        -1 |        0 | 
           0 |               |            | 
(2 rows)
```
### pg_attribute
width是普通列；area是虚拟列，在atthasdef中和普通列不同，attgenerated中有标记stored
```
postgres=# select * from pg_attribute where attname = 'area' or attname = 'width';
 attrelid | attname | atttypid | attstattarget | attlen | attnum | attndims | attcacheoff | atttypmod | attbyval | attstorage | attalign | attnotnull | atthasdef | atth
asmissing | attidentity | attgenerated | attisdropped | attislocal | attinhcount | attcollation | attacl | attoptions | attfdwoptions | attmissingval 
----------+---------+----------+---------------+--------+--------+----------+-------------+-----------+----------+------------+----------+------------+-----------+-----
----------+-------------+--------------+--------------+------------+-------------+--------------+--------+------------+---------------+---------------
    16459 | width   |       23 |            -1 |      4 |      2 |        0 |          -1 |        -1 | t        | p          | i        | f          | f         | f   
          |             |              | f            | t          |           0 |            0 |        |            |               | 
    16459 | area    |       23 |            -1 |      4 |      3 |        0 |          -1 |        -1 | t        | p          | i        | f          | t         | f   
          |             | s            | f            | t          |           0 |            0 |        |            |               | 
(2 rows)
```
### pg_attrdef
create的表中包含有虚拟列时，该表会增加
```
postgres=# select * from pg_attrdef;
  oid  | adrelid | adnum |                                                                                                                                              
                                adbin                                                                                                                                   
                                           
-------+---------+-------+----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------
 16462 |   16459 |     3 | {OPEXPR :opno 514 :opfuncid 141 :opresulttype 23 :opretset false :opcollid 0 :inputcollid 0 :args ({VAR :varno 1 :varattno 1 :vartype 23 :var
typmod -1 :varcollid 0 :varlevelsup 0 :varnoold 1 :varoattno 1 :location 89} {VAR :varno 1 :varattno 2 :vartype 23 :vartypmod -1 :varcollid 0 :varlevelsup 0 :varnoold 1
 :varoattno 2 :location 98}) :location 96}
(1 row)
```
### pg_depend
记录虚拟列的依赖信息
```
postgres=# select * from pg_depend where objid=16479;
 classid | objid | objsubid | refclassid | refobjid | refobjsubid | deptype 
---------+-------+----------+------------+----------+-------------+---------
    1259 | 16479 |        0 |       2615 |     2200 |           0 | n
    1259 | 16479 |        3 |       1259 |    16479 |           1 | a
    1259 | 16479 |        3 |       1259 |    16479 |           2 | a
(3 rows)
```

## 带虚拟列的表的insert和update

* 虚拟列的值在insert和update时会自动更新，不能指定值
* 写虚拟列的值在存储时进行计算，即ExecInsert和ExecUpdate中
* 如果create时虚拟列指定的类型和计算结果类型不一样，会进行转化，转化失败会报错

### 主要修改的文件
* tupdesc.c -> 增加attgenerated标记
* heap.c -> 修改系统表pg_attrdef存储虚拟列表达式，pg_depend用于当虚拟列依赖的列被drop的同时删除虚拟列
* trigger.c 
* analyze.c -> 获取更新列增加虚拟列
* execReplication.c
* nodeModifyTable.c -> 在执行中增加虚拟列的计算

### 具体流程和修改点
//update testtable set width = 8 where height = 3;
```
transformTopLevelStmt (analyze.c)
	transformOptionalSelectInto
		transformStmt
			transformUpdateStmt
				transformUpdateTargetList (pg12+虚拟列也放入要更新的list中)
```

//insert into testtable values(12,2);
```
ExecModifyTable (nodeModifyTable.c)
	ExecInsert (pg12+ExecComputeStoredGenerated) 
		table_tuple_insert (tableam.h)
			heapam_tuple_insert (heapam_handler.c)
				heap_insert	(heapam.c)
					XLogInsert
	//ExecUpdate (pg12+ExecComputeStoredGenerated)
```

pg有自己的Expr格式和处理流程

```
ExecComputeStoredGenerated (nodeModifyTable.c)
	ExecPrepareExpr
		ExecInitExpr
			ExprEvalPushStep 		
	slot_getallattrs (tuptable.h)
		slot_getsomeattrs
			slot_getsomeattrs_int (execTuples.c，获取值的地址到slot的tts_values中)
				tts_buffer_heap_getsomeattrs
	ExecEvalExpr 
		ExecInterpExprStillValid (execExprInterp.c)
			ExecInterpExpr
```

## gdb 调试信息

//create table testtable (height integer, width integer, area integer generated always as (height * width) stored);
```
(gdb) set $stmt = (CreateStmt *)((RawStmt *)(parsetree_list->head.data->ptr_value))->stmt
(gdb) p *$stmt
$6 = {type = T_CreateStmt, relation = 0x11bafc8, tableElts = 0x11bb230, inhRelations = 0x0, partbound = 0x0, partspec = 0x0, 
  ofTypename = 0x0, constraints = 0x0, options = 0x0, oncommit = ONCOMMIT_NOOP, tablespacename = 0x0, accessMethod = 0x0, 
  if_not_exists = false}
(gdb) p *(RangeVar *)($stmt->relation)
$7 = {type = T_RangeVar, catalogname = 0x0, schemaname = 0x0, relname = 0x11bafa0 "testtable", inh = true, relpersistence = 112 'p', 
  alias = 0x0, location = 13}
(gdb) p *(Node *)($stmt->tableElts->head.data->ptr_value)
$9 = {type = T_ColumnDef}
(gdb) p *(ColumnDef *)($stmt->tableElts->head.data->ptr_value)
$10 = {type = T_ColumnDef, colname = 0x11bb020 "height", typeName = 0x11bb118, inhcount = 0, is_local = true, is_not_null = false, 
  is_from_type = false, storage = 0 '\000', raw_default = 0x0, cooked_default = 0x0, identity = 0 '\000', identitySequence = 0x0, 
  generated = 0 '\000', collClause = 0x0, collOid = 0, constraints = 0x0, fdwoptions = 0x0, location = 24}
(gdb) p *(ColumnDef *)($stmt->tableElts->head->next.data->ptr_value)
$11 = {type = T_ColumnDef, colname = 0x11bb268 "width", typeName = 0x11bb360, inhcount = 0, is_local = true, is_not_null = false, 
  is_from_type = false, storage = 0 '\000', raw_default = 0x0, cooked_default = 0x0, identity = 0 '\000', identitySequence = 0x0, 
  generated = 0 '\000', collClause = 0x0, collOid = 0, constraints = 0x0, fdwoptions = 0x0, location = 40}
(gdb) p *(ColumnDef *)($stmt->tableElts->head->next->next.data->ptr_value)
$12 = {type = T_ColumnDef, colname = 0x11bb478 "area", typeName = 0x11bb570, inhcount = 0, is_local = true, is_not_null = false, 
  is_from_type = false, storage = 0 '\000', raw_default = 0x0, cooked_default = 0x0, identity = 0 '\000', identitySequence = 0x0, 
  generated = 0 '\000', collClause = 0x0, collOid = 0, constraints = 0x11bb9a8, fdwoptions = 0x0, location = 55}
(gdb) set $colwidth = (ColumnDef *)($stmt->tableElts->head->next.data->ptr_value)
(gdb) set $colarea = (ColumnDef *)($stmt->tableElts->head->next.data->ptr_value)
(gdb) p *$colwidth->typeName
$13 = {type = T_TypeName, names = 0x11bb2d8, typeOid = 0, setof = false, pct_type = false, typmods = 0x0, typemod = -1, 
  arrayBounds = 0x0, location = 46}
(gdb) p *$colarea->typeName
$14 = {type = T_TypeName, names = 0x11bb2d8, typeOid = 0, setof = false, pct_type = false, typmods = 0x0, typemod = -1, 
  arrayBounds = 0x0, location = 46}
```

//insert into testtable values(6, 9);
```
(gdb) p *(InsertStmt *)((RawStmt *)(parsetree_list->head.data->ptr_value))->stmt
$5 = {type = T_InsertStmt, relation = 0x2c4ee78, cols = 0x0, 
  selectStmt = 0x2c4efc8, onConflictClause = 0x0, returningList = 0x0, 
  withClause = 0x0, override = OVERRIDING_NOT_SET}
(gdb) set $stmt = (InsertStmt *)((RawStmt *)(parsetree_list->head.data->ptr_value))->stmt
(gdb) p *(RangeVar *)($stmt->relation)
$7 = {type = T_RangeVar, catalogname = 0x0, schemaname = 0x0, 
  relname = 0x2c4ee50 "testtable", inh = true, relpersistence = 112 'p', 
  alias = 0x0, location = 12}
(gdb) p *(SelectStmt *)($stmt->selectStmt)
$9 = {type = T_SelectStmt, distinctClause = 0x0, intoClause = 0x0, 
  targetList = 0x0, fromClause = 0x0, whereClause = 0x0, 
  groupClause = 0x0, havingClause = 0x0, windowClause = 0x0, 
  valuesLists = 0x2c4f108, sortClause = 0x0, limitOffset = 0x0, 
  limitCount = 0x0, lockingClause = 0x0, withClause = 0x0, 
  op = SETOP_NONE, all = false, larg = 0x0, rarg = 0x0}
(gdb) set $sstmt = (SelectStmt *)($stmt->selectStmt)
(gdb) p *(Node *)($sstmt->valuesLists->head.data->ptr_value)
$10 = {type = T_List}
(gdb) set $vl = (List *)($sstmt->valuesLists->head.data->ptr_value)
(gdb) p *(Node *)($vl->head.data->ptr_value)
$11 = {type = T_A_Const}
(gdb) p *(A_Const *)($vl->head.data->ptr_value)
$12 = {type = T_A_Const, val = {type = T_Integer, val = {ival = 6, 
      str = 0x6 <error: Cannot access memory at address 0x6>}}, 
  location = 29}
(gdb) p *(A_Const *)($vl->head->next.data->ptr_value)
$13 = {type = T_A_Const, val = {type = T_Integer, val = {ival = 9, 
      str = 0x9 <error: Cannot access memory at address 0x9>}}, 
  location = 31}
```

[back](/)

