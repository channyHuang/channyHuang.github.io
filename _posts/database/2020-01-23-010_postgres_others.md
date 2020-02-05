---
layout: default
title: 010_postgres_others
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-01-23 12:52:59

//Author: channy

# 010_postgres_others
# 其它目前看过的片段

## 逻辑订阅处理
```
ApplyWorkerMain (worker.c)
	LogicalRepApplyLoop (逻辑订阅处理流程)
		apply_dispatch 
			apply_handle_insert 
				slot_fill_defaults
				ExecSimpleRelationInsert (execReplication.c)
					simple_table_tuple_insert (tableam.c)
```

[back](/)

