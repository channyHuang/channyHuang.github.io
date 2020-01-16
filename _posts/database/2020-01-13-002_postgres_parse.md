---
layout: default
title: 2020-01-13-postgres_parse.md
categories:
- C++
tags:
- C++
---
//Description: 初识parsetree

//Create Date: 2020-01-13 23:04:46

//Author: channy

# postgres_parse

# 基本流程

```
main
	PostmasterMain
		InitializeGUCOptions
		CreateDataDirLockFile
		StartupDataBase(StartChildProcess)
		ServerLoop
		AuxiliaryProcessMain
	PostgresMain
		exec_simple_query
			pg_parse_query (postgres.c)
				raw_parser (parser.c)
			pg_analyze_and_rewrite
				parse_analyze (analyze.c, parse_analyze_for_gram (ADB))
					transformTopLevelStmt (parsetree -> query)
						transformOptionalSelectInto
							transformStmt
								transformInsertStmt
									make_parsestate
									transformStmt
									transformInsertRow
									transformOnConflictClause
								transformSelectStmt
									transformStmt
										transformFromClause
											transformFromClauseItem
					transformFromAndWhere (ADB)
				pg_rewrite_query (query -> querytree_list)
					QueryRewrite
						RewriteQuery
							fireRules
						fireRIRrules
							ApplyRetrieveRule
			pg_plan_queries (querytree_list -> plantree_list)
				pg_plan_query (rewrite->plan)
					planner
						standard_planner
							subquery_planner
								pull_up_sublinks
								pull_up_subqueries (merge subqueries to main query)
									pull_up_subqueries_recurse
								preprocess_expression
								grouping_planner
			CreatePortal
			PortalDefineQuery
			PortalStart
			PortalRun
				PortalRunSelect
					ExecutorRun
						standard_ExecutorRun
							ExecutePlan
```

# gdb调试parsetree_list

exec_simple_query

```
//select * from testtable left join debugtable on testtable.id = debugtable.id;
gdb after pg_parse_query
(gdb) p *((RawStmt *)(parsetree_list->head.data->ptr_value))->stmt
$6 = {type = T_SelectStmt}
(gdb) p *(SelectStmt *)((RawStmt *)(parsetree_list->head.data->ptr_value))->stmt
$7 = {type = T_SelectStmt, distinctClause = 0x0, intoClause = 0x0,
  targetList = 0x21a4fd8, fromClause = 0x21a5520, whereClause = 0x0,
  groupClause = 0x0, havingClause = 0x0, windowClause = 0x0,
  valuesLists = 0x0, sortClause = 0x0, limitOffset = 0x0,
  limitCount = 0x0, lockingClause = 0x0, withClause = 0x0,
  op = SETOP_NONE, all = false, larg = 0x0, rarg = 0x0}
(gdb) set $stmt = (SelectStmt *)((RawStmt *)(parsetree_list->head.data->ptr_value))->stmt
(gdb) p *(Value *)($stmt->targetList->head.data->ptr_value)
$15 = {type = T_ResTarget, val = {ival = 0, str = 0x0}}
(gdb) p *(Value *)($stmt->fromClause->head.data->ptr_value)
$16 = {type = T_JoinExpr, val = {ival = 0, str = 0x0}}
(gdb) set $from = (JoinExpr *)($stmt->fromClause->head.data->ptr_value)
(gdb) p *(RangeVar *)($from->larg)
$19 = {type = T_RangeVar, catalogname = 0x0, schemaname = 0x0,
  relname = 0x21a5010 "testtable", inh = true, relpersistence = 112 'p',
  alias = 0x0, location = 14}
```

```
//select * from debugtable, testtable where debugtable.id = testtable.id;
gdb after pg_plan_queries
(gdb) p *(Node *)(plantree_list->head.data->ptr_value)
$1 = {type = T_PlannedStmt}
(gdb) set $plan = (PlannedStmt *)((plantree_list->head.data->ptr_value))
(gdb) p *$plan
$2 = {type = T_PlannedStmt, commandType = CMD_SELECT, queryId = 0,
  hasReturning = false, hasModifyingCTE = false, canSetTag = true,
  transientPlan = false, dependsOnRole = false,
  parallelModeNeeded = false, jitFlags = 0, planTree = 0x21a56d8,
  rtable = 0x2271d18, resultRelations = 0x0, rootResultRelations = 0x0,
  subplans = 0x0, rewindPlanIDs = 0x0, rowMarks = 0x0,
  relationOids = 0x2271d78, invalItems = 0x0, paramExecTypes = 0x0,
  utilityStmt = 0x0, stmt_location = 0, stmt_len = 70}
(gdb) set $plantree = (Plan *)($plan->planTree)
(gdb) p *$plantree
$3 = {type = T_HashJoin, startup_cost = 13.15,
  total_cost = 40.994999999999997, plan_rows = 602, plan_width = 587,
  parallel_aware = false, parallel_safe = true, plan_node_id = 0,
  targetlist = 0x2272348, qual = 0x0, lefttree = 0x2270590,
  righttree = 0x2271b40, initPlan = 0x0, extParam = 0x0, allParam = 0x0}
(gdb) p *(Value *)($plan->rtable->head.data->ptr_value)
$5 = {type = T_RangeTblEntry, val = {ival = 16392,
    str = 0x7200004008 <error: Cannot access memory at address 0x7200004008>}}
(gdb) set $rtable = (RangeTblEntry *)($plan->rtable->head.data->ptr_value)(gdb) p *($rtable)
$6 = {type = T_RangeTblEntry, rtekind = RTE_RELATION, relid = 16392,
  relkind = 114 'r', rellockmode = 1, tablesample = 0x0, subquery = 0x0,
  security_barrier = false, jointype = JOIN_INNER, joinaliasvars = 0x0,
  functions = 0x0, funcordinality = false, tablefunc = 0x0,
  values_lists = 0x0, ctename = 0x0, ctelevelsup = 0,
  self_reference = false, coltypes = 0x0, coltypmods = 0x0,
  colcollations = 0x0, enrname = 0x0, enrtuples = 0, alias = 0x0,
  eref = 0x21a5a20, lateral = false, inh = false, inFromCl = true,
  requiredPerms = 2, checkAsUser = 0, selectedCols = 0x2294138,
  insertedCols = 0x0, updatedCols = 0x0, extraUpdatedCols = 0x0,
  securityQuals = 0x0}
(gdb) p *($plantree->lefttree)
$12 = {type = T_SeqScan, startup_cost = 0,
  total_cost = 18.600000000000001, plan_rows = 860, plan_width = 66,
  parallel_aware = false, parallel_safe = true, plan_node_id = 1,
  targetlist = 0x2271388, qual = 0x0, lefttree = 0x0, righttree = 0x0,
  initPlan = 0x0, extParam = 0x0, allParam = 0x0}
(gdb) p *($plantree->righttree)
$13 = {type = T_Hash, startup_cost = 11.4, total_cost = 11.4,
  plan_rows = 140, plan_width = 521, parallel_aware = false,
  parallel_safe = true, plan_node_id = 2, targetlist = 0x22728f0,
  qual = 0x0, lefttree = 0x2271728, righttree = 0x0, initPlan = 0x0,
  extParam = 0x0, allParam = 0x0}
```

这两个语句都比较简单，也没有设置规则什么的，所以rewrite其实并没有做什么，rewrite后和rewrite前的树一样。

[back](/)

