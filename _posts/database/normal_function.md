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