---
layout: default
title: 004_postgres_plan
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-01-18 23:18:52

//Author: channy

# 004_postgres_plan

# postgres plan

## 计划树

```
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
PortalRun (pquery.c)
	PortalRunSelect/PortalRunMulti (select/create)
		ExecutorRun/PortalRunUtility
			standard_ExecutorRun/ProcessUtility.standard_ProcessUtility
				ExecutePlan/ProcessUtilitySlow (execMain.c)
					ExecProcNode (executor.h)
						ExecProcNodeFirst (execProcnode.c)
							ExecModifyTable (nodeModifyTable.c)
```

![plantree](E:/images/plantree.png)


[back](/)

