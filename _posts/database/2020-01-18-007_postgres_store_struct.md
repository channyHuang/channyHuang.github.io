---
layout: default
title: 2020-01-18-007_postgres_store_struct.md
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-01-18 23:22:01

//Author: channy

# 007_postgres_store_struct

# postgres store struct

## 系统表

pg_database 记录了当前数据库集所有的数据库

* 其中每个数据库有一个oid，对应base下同名文件夹，存放对应数据库的信息

```
postgres=# select * from pg_database
postgres-# ;
  oid  |  datname  | datdba | encoding | datcollate  |  datctype   | datistemplate | datallowconn | datconnlimit | datlastsysoid | datfrozenxid | datminmxid | dattables
pace |                          datacl                          
-------+-----------+--------+----------+-------------+-------------+---------------+--------------+--------------+---------------+--------------+------------+----------
-----+----------------------------------------------------------
 12711 | postgres  |     10 |        6 | en_US.UTF-8 | en_US.UTF-8 | f             | t            |           -1 |         12710 |          479 |          1 |          
1663 | {=Tc/postgres,postgres=CTc/postgres,channy=CTc/postgres}
     1 | template1 |     10 |        6 | en_US.UTF-8 | en_US.UTF-8 | t             | t            |           -1 |         12710 |          479 |          1 |          
1663 | {=c/postgres,postgres=CTc/postgres}
 12710 | template0 |     10 |        6 | en_US.UTF-8 | en_US.UTF-8 | t             | f            |           -1 |         12710 |          479 |          1 |          
1663 | {=c/postgres,postgres=CTc/postgres}
(3 rows)
```

```
postgres@channy-VirtualBox:/usr/local/pgsql/data/base$ ls
1  12710  12711
```

* pg_class 记录了数据表对应的文件夹名称relfilenode

```
postgres=# select * from pg_class limit 3;
  oid  |  relname   | relnamespace | reltype | reloftype | relowner | relam | relfilenode | reltablespace | relpages | reltuples | relallvisible | reltoastrelid | relha
sindex | relisshared | relpersistence | relkind | relnatts | relchecks | relhasrules | relhastriggers | relhassubclass | relrowsecurity | relforcerowsecurity | relispop
ulated | relreplident | relispartition | relrewrite | relfrozenxid | relminmxid | relacl | reloptions | relpartbound 
-------+------------+--------------+---------+-----------+----------+-------+-------------+---------------+----------+-----------+---------------+---------------+------
-------+-------------+----------------+---------+----------+-----------+-------------+----------------+----------------+----------------+---------------------+---------
-------+--------------+----------------+------------+--------------+------------+--------+------------+--------------
 16392 | debugtable |         2200 |   16394 |         0 |       10 |     2 |       16392 |             0 |        0 |         0 |             0 |             0 | f    
       | f           | p              | r       |        3 |         0 | f           | f              | f              | f              | f                   | t       
       | d            | f              |          0 |          488 |          1 |        |            | 
 16396 | seqtable   |         2200 |   16397 |         0 |       10 |     0 |       16396 |             0 |        1 |         1 |             0 |             0 | f    
       | f           | p              | S       |        3 |         0 | f           | f              | f              | f              | f                   | t       
       | n            | f              |          0 |            0 |          0 |        |            | 
 16401 | jointable  |         2200 |   16403 |         0 |       10 |     2 |       16401 |             0 |        0 |         0 |             0 |             0 | f    
       | f           | p              | r       |        4 |         0 | f           | f              | f              | f              | f                   | t       
       | d            | f              |          0 |          515 |          1 |        |            | 
(3 rows)
```

```
postgres@channy-VirtualBox:/usr/local/pgsql/data/base/12711$ ls -lrht 16*
-rw-r-x--- 1 postgres postgres 8.0K 1月   6 17:01 16392
-rw-r----- 1 postgres postgres 8.0K 1月   7 19:00 16396
-rw-r----- 1 postgres postgres 8.0K 1月   9 12:13 16401
```

## page、tuple

![page](E:/images/page.png)

![tuple](E:/images/tuple.png)

[back](/)

