---
layout: default
title: 002_postgres_base_flow
categories:
- Database
tags:
- Database
---
//Description: 初识parsetree

//Create Date: 2020-01-13 23:04:46

//Author: channy

# postgres base flow

## 进程信息

* background writer: 后台写进程
* walwriter: wal日志写进程
* postgres [local] idle:  psql连接的进程
* 其它，暂且忽视

```
postgres@channy-VirtualBox:~$ ps x | grep postgres
 2307 ?        Ss     0:00 /usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data
 2308 ?        Ss     0:00 postgres: logger   
 2310 ?        Ss     0:00 postgres: checkpointer   
 2311 ?        Ss     0:00 postgres: background writer   
 2312 ?        Ss     0:00 postgres: walwriter   
 2313 ?        Ss     0:00 postgres: autovacuum launcher   
 2314 ?        Ss     0:00 postgres: stats collector   
 2315 ?        Ss     0:00 postgres: logical replication launcher   
 2317 ?        Ss     0:00 postgres: postgres postgres [local] idle
 2319 pts/1    S+     0:00 grep --color=auto postgres
```

## 主函数

```c++
main
	PostmasterMain
		InitializeGUCOptions (what is GUC?)
		CreateDataDirLockFile (锁定数据库集)
		reset_shared (share memory)
		StartupDataBase (StartChildProcess)
			AuxiliaryProcessMain (启动其它相关进程)
				CheckerModeMain
				StartupProcessMain
				BootstrapModeMain
				BackgroundWriterMain
				CheckpointerMain
				WalWriterMain
				WalReceiverMain
		ServerLoop (接收连接请求)
			PostgresMain
			MaybeStartWalReceiver
			maybe_start_bgworkers
```

* EXEC_BACKEND 仅当编译/运行平台为windows系列时，才有可能定义 EXEC_BACKEND。
```
6891 if test "$PORTNAME" = "win32"; then
6892   CPPFLAGS="$CPPFLAGS -I$srcdir/src/include/port/win32 -DEXEC_BACKEND"
6893 fi
```


## 基本流程

词法、语法分析 -> 语义分析 -> 重写 -> 计划 -> 执行

```
PostgresMain
	exec_simple_query (Q)
		pg_parse_query (postgres.c)
			raw_parser (parser.c，词法、语法分析，flex/bison，gram.y)
		start_xact_command
		pg_analyze_and_rewrite
		pg_plan_queries (querytree_list -> plantree_list)
		CreatePortal
		PortalDefineQuery
		PortalStart
		PortalRun (pquery.c)
		finish_xact_command
```

[back](/)

