---
layout: default
title: overthewire_wargames_notes_bandit
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-02-19 21:32:26

//Author: channy

# overthewire_wargames_notes

[address](https://overthewire.org/wargames/)

除了网络问题经常卡之外，其它都好

## Bandit

* ssh -p2220 bandit0@bandit.labs.overthewire.org

其实直接用xshell也可以的^_^

1. 0->1

```
bandit0@bandit:~$ cat readme
boJ9jbbUNNfktd78OOpsqOltutMc3MY1
```

2. 1->2

```
bandit1@bandit:~$ cat ./-
CV1DtqXWVFXTvM2F0k09SHz0YwRINYA9
```

3. 2->3

```
bandit2@bandit:~$ cat 'spaces in this filename'
UmHadQclWmgdLOKQ3YNgjWxGoRMb5luK
```

4. 3->4

```
bandit3@bandit:~/inhere$ ls -all
total 12
drwxr-xr-x 2 root    root    4096 Oct 16  2018 .
drwxr-xr-x 3 root    root    4096 Oct 16  2018 ..
-rw-r----- 1 bandit4 bandit3   33 Oct 16  2018 .hidden
bandit3@bandit:~/inhere$ cat .hidden 
pIwrPrtPN36QITSp3EQaw936yaFoFgAB
```

5. 4->5

一个个试吗？其它都是乱码

```
bandit4@bandit:~/inhere$ cat ./-file07
koReBOKuIDDepwhWk7jZC0RTdopnAYKh
```

6. find ./ -size 

```
bandit5@bandit:~$ cd inhere/
bandit5@bandit:~/inhere$ find ./ -size 1033c
./maybehere07/.file2
bandit5@bandit:~/inhere$ cat ./maybehere07/.file2
DXjZPULLxYr17uwoI01bNLQbtFemEgo7
```

7. /dev/null 空设备，1:标准输出; 2:标准错误

```
bandit6@bandit:~$ find / -size 33c -user bandit7 -group bandit6 2> /dev/null
/var/lib/dpkg/info/bandit7.password
bandit6@bandit:~$ cat /var/lib/dpkg/info/bandit7.password
HKBPTKQnIay4Fw76bEy8PVxKEDQRKTzs
```

8. 

```
bandit7@bandit:~$ grep millionth data.txt
millionth	cvX2JJa4CFALtqS87jk27qwqGhBM9plV
```

9. sort将文件的每一行作为一个单位，相互比较; uniq -u 仅显示出一次的行列。

```
bandit8@bandit:~$ sort data.txt | uniq -u
UsvVyFSfZZWbi6wgC7dAFyFuR6jQQUhR
```

10. strings [filename]

```
bandit9@bandit:~$ strings data.txt | grep '=='
2========== the
========== password
========== isa
========== truKLdjsbJ5g7yyJ2X2R0o3a5HQJFuLk
```

11. base64

```
bandit10@bandit:~$ cat data.txt | base64 -d
The password is IFukwKGsFW8MOq3IRFqrxE1hxTNEbUPR
```

12. tr 

```
bandit11@bandit:~$ cat data.txt | tr [a-zA-Z] [n-za-mN-ZA-M]
The password is 5Te8Y4drgCRfCx8ugdwuEX8KFC6k2EUu
```

13. xxd 16进制操作或反操作; tar -xvf xxx.tar, gzip -d xxx.gz, bzip2 -d xxx.bz

file查看文件类型，反复解压就是了


```
xxd -r data.txt > /tmp/channy/data
...
bandit12@bandit:/tmp/data$ file data8.bin
data8.bin: gzip compressed data, was "data9.bin", last modified: Tue Oct 16 12:00:23 2018, max compression, from Unix
bandit12@bandit:/tmp/data$ mv data8.bin data.gz
bandit12@bandit:/tmp/data$ gzip -d data.gz
bandit12@bandit:/tmp/data$ ls
data
bandit12@bandit:/tmp/data$ file data
data: ASCII text
bandit12@bandit:/tmp/data$ mv data data.txt
bandit12@bandit:/tmp/data$ cat data.txt
The password is 8ZjyCRiBWFYkneahHwxCv3wb2a1ORpYL
```

14. ssh

```
bandit13@bandit:~$ ls
sshkey.private
bandit13@bandit:~$ ssh -i sshkey.private bandit14@localhost

bandit14@bandit:~$ cat /etc/bandit_pass/bandit14
4wcYUJFw0k0XLShlDzztnTBHiqxU3b3e
```

15. nc

```
bandit14@bandit:~$ cat /etc/bandit_pass/bandit14 | nc localhost 30000
Correct!
BfMYroe26WYalil77FoDi9qh59eK5xNr

```

16. ncat

```
bandit15@bandit:~$ ncat --ssl localhost 30001
BfMYroe26WYalil77FoDi9qh59eK5xNr
Correct!
cluFn7wTiGryunymYOu4RcffSxQluehd

```

17. nmap

```
bandit16@bandit:~$ nmap -p 31000-32000 localhost

Starting Nmap 7.40 ( https://nmap.org ) at 2020-02-20 03:32 CET
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00025s latency).
Not shown: 999 closed ports
PORT      STATE SERVICE
31518/tcp open  unknown
31790/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 0.13 seconds

bandit16@bandit:~$ nmap -sV -p 31518,31790 localhost

Starting Nmap 7.40 ( https://nmap.org ) at 2020-02-20 03:33 CET
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00020s latency).
PORT      STATE SERVICE     VERSION
31518/tcp open  ssl/echo
31790/tcp open  ssl/unknown
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port31790-TCP:V=7.40%T=SSL%I=7%D=2/20%Time=5E4DEFFA%P=x86_64-pc-linux-g
SF:nu%r(GenericLines,31,"Wrong!\x20Please\x20enter\x20the\x20correct\x20cu
SF:rrent\x20password\n")%r(GetRequest,31,"Wrong!\x20Please\x20enter\x20the
SF:\x20correct\x20current\x20password\n")%r(HTTPOptions,31,"Wrong!\x20Plea
SF:se\x20enter\x20the\x20correct\x20current\x20password\n")%r(RTSPRequest,
SF:31,"Wrong!\x20Please\x20enter\x20the\x20correct\x20current\x20password\
SF:n")%r(Help,31,"Wrong!\x20Please\x20enter\x20the\x20correct\x20current\x
SF:20password\n")%r(SSLSessionReq,31,"Wrong!\x20Please\x20enter\x20the\x20
SF:correct\x20current\x20password\n")%r(TLSSessionReq,31,"Wrong!\x20Please
SF:\x20enter\x20the\x20correct\x20current\x20password\n")%r(Kerberos,31,"W
SF:rong!\x20Please\x20enter\x20the\x20correct\x20current\x20password\n")%r
SF:(FourOhFourRequest,31,"Wrong!\x20Please\x20enter\x20the\x20correct\x20c
SF:urrent\x20password\n")%r(LPDString,31,"Wrong!\x20Please\x20enter\x20the
SF:\x20correct\x20current\x20password\n")%r(LDAPSearchReq,31,"Wrong!\x20Pl
SF:ease\x20enter\x20the\x20correct\x20current\x20password\n")%r(SIPOptions
SF:,31,"Wrong!\x20Please\x20enter\x20the\x20correct\x20current\x20password
SF:\n");

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 88.67 seconds

bandit16@bandit:~$ ncat --ssl localhost 31518
cluFn7wTiGryunymYOu4RcffSxQluehd
cluFn7wTiGryunymYOu4RcffSxQluehd
^C
bandit16@bandit:~$ ncat --ssl localhost 31790
cluFn7wTiGryunymYOu4RcffSxQluehd
Correct!
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAvmOkuifmMg6HL2YPIOjon6iWfbp7c3jx34YkYWqUH57SUdyJ
imZzeyGC0gtZPGujUSxiJSWI/oTqexh+cAMTSMlOJf7+BrJObArnxd9Y7YT2bRPQ
Ja6Lzb558YW3FZl87ORiO+rW4LCDCNd2lUvLE/GL2GWyuKN0K5iCd5TbtJzEkQTu
DSt2mcNn4rhAL+JFr56o4T6z8WWAW18BR6yGrMq7Q/kALHYW3OekePQAzL0VUYbW
JGTi65CxbCnzc/w4+mqQyvmzpWtMAzJTzAzQxNbkR2MBGySxDLrjg0LWN6sK7wNX
x0YVztz/zbIkPjfkU1jHS+9EbVNj+D1XFOJuaQIDAQABAoIBABagpxpM1aoLWfvD
KHcj10nqcoBc4oE11aFYQwik7xfW+24pRNuDE6SFthOar69jp5RlLwD1NhPx3iBl
J9nOM8OJ0VToum43UOS8YxF8WwhXriYGnc1sskbwpXOUDc9uX4+UESzH22P29ovd
d8WErY0gPxun8pbJLmxkAtWNhpMvfe0050vk9TL5wqbu9AlbssgTcCXkMQnPw9nC
YNN6DDP2lbcBrvgT9YCNL6C+ZKufD52yOQ9qOkwFTEQpjtF4uNtJom+asvlpmS8A
vLY9r60wYSvmZhNqBUrj7lyCtXMIu1kkd4w7F77k+DjHoAXyxcUp1DGL51sOmama
+TOWWgECgYEA8JtPxP0GRJ+IQkX262jM3dEIkza8ky5moIwUqYdsx0NxHgRRhORT
8c8hAuRBb2G82so8vUHk/fur85OEfc9TncnCY2crpoqsghifKLxrLgtT+qDpfZnx
SatLdt8GfQ85yA7hnWWJ2MxF3NaeSDm75Lsm+tBbAiyc9P2jGRNtMSkCgYEAypHd
HCctNi/FwjulhttFx/rHYKhLidZDFYeiE/v45bN4yFm8x7R/b0iE7KaszX+Exdvt
SghaTdcG0Knyw1bpJVyusavPzpaJMjdJ6tcFhVAbAjm7enCIvGCSx+X3l5SiWg0A
R57hJglezIiVjv3aGwHwvlZvtszK6zV6oXFAu0ECgYAbjo46T4hyP5tJi93V5HDi
Ttiek7xRVxUl+iU7rWkGAXFpMLFteQEsRr7PJ/lemmEY5eTDAFMLy9FL2m9oQWCg
R8VdwSk8r9FGLS+9aKcV5PI/WEKlwgXinB3OhYimtiG2Cg5JCqIZFHxD6MjEGOiu
L8ktHMPvodBwNsSBULpG0QKBgBAplTfC1HOnWiMGOU3KPwYWt0O6CdTkmJOmL8Ni
blh9elyZ9FsGxsgtRBXRsqXuz7wtsQAgLHxbdLq/ZJQ7YfzOKU4ZxEnabvXnvWkU
YOdjHdSOoKvDQNWu6ucyLRAWFuISeXw9a/9p7ftpxm0TSgyvmfLF2MIAEwyzRqaM
77pBAoGAMmjmIJdjp+Ez8duyn3ieo36yrttF5NSsJLAbxFpdlc1gvtGCWW+9Cq0b
dxviW8+TFVEBl1O4f7HVm6EpTscdDxU+bCXWkfjuRb7Dy9GOtt9JPsX8MBTakzh3
vBgsyi/sN3RqRBcGU40fOoZyfAMT8s1m/uYv52O6IgeuZ/ujbjY=
-----END RSA PRIVATE KEY-----

//以下测试失败
mkdir /tmp/channy
echo "上面那段私钥"　> /tmp/channy/sshkey
chmod 600 /tmp/channy/sshkey
ssh bandit17@localhost -i /tmp/channy/sshkey

# 登陆后，cat /etc/bandit_pass/bandit17
# 获得密码xLYVMN9WE5zQ5vHacb0sZEVqbrp7nBTn
```

18. diff [file1] [file2]

```
bandit17@bandit:~$ diff passwords.new passwords.old
42c42
< kfBf3eYk5BPBRzwjqutbbfE887SVc5Yd
---
> hlbSBPAWJmL6WFDb06gpTx1pPButblOA
```

19. 这么神奇的么？

```
bandit17@bandit:/$ ssh bandit18@localhost cat readme
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ECDSA key fingerprint is SHA256:98UL0ZWr85496EtCRkKlo20X3OPnyPSB5tB5RPbhczc.
Are you sure you want to continue connecting (yes/no)? yes
Failed to add the host to the list of known hosts (/home/bandit17/.ssh/known_hosts).
This is a OverTheWire game server. More information on http://www.overthewire.org/wargames

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0640 for '/home/bandit17/.ssh/id_rsa' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "/home/bandit17/.ssh/id_rsa": bad permissions
bandit18@localhost's password:
IueksS7Ubh8G3DCwVzrTd8rAVOwq3M5x
```

20. setuid

```
bandit19@bandit:~$ ./bandit20-do cat /etc/bandit_pass/bandit20
GbKksEFF4yrVs6il55v6gwY5aVje5f0j
```

21. & run in background 

```
//试了下没成功
bandit20@bandit:~$ echo "GbKksEFF4yrVs6il55v6gwY5aVje5f0j" | nc -l -p 9877&
[1] 4074
bandit20@bandit:~$ ./suconnect 9877
Read: GbKksEFF4yrVs6il55v6gwY5aVje5f0j
Password matches, sending next password
gE269g2h3mw3pwgrj0Ha9Uoqen1c9DGr

two terminel:
1:terminal 1:nc -l 12345
2:terminal 2:./suconnect 12345
3.terminal 1:GbKksEFF4yrVs6il55v6gwY5aVje5f0j
```

22. cron linux下的定时执行工具; crontab 

查看/etc/cron.d下的cronjob_bandit22, 执行了/usr/bin下的cronjob_bandit22

```
bandit21@bandit:~$ cd /etc/cron.d
bandit21@bandit:/etc/cron.d$ ls
atop  cronjob_bandit22  cronjob_bandit23  cronjob_bandit24
bandit21@bandit:/etc/cron.d$ vim cronjob_bandit22
bandit21@bandit:/etc/cron.d$ cd /usr/bin
bandit21@bandit:/usr/bin$ cat cronjob_bandit22.sh 
#!/bin/bash
chmod 644 /tmp/t7O6lds9S0RqQh9aMcz6ShpAoZKF7fgv
cat /etc/bandit_pass/bandit22 > /tmp/t7O6lds9S0RqQh9aMcz6ShpAoZKF7fgv
bandit21@bandit:/usr/bin$ cat /tmp/t7O6lds9S0RqQh9aMcz6ShpAoZKF7fgv
Yk7owGAcWjwMVRwrTesJEwB7WVOiILLI
```

23. cut

```
bandit22@bandit:~$ cd /usr/bin
bandit22@bandit:/usr/bin$ cat cronjob_bandit23.sh
#!/bin/bash

myname=$(whoami)
mytarget=$(echo I am user $myname | md5sum | cut -d ' ' -f 1)

echo "Copying passwordfile /etc/bandit_pass/$myname to /tmp/$mytarget"

cat /etc/bandit_pass/$myname > /tmp/$mytarget

bandit22@bandit:/usr/bin$ echo I am user bandit23 | md5sum | cut -d ' ' -f 1
8ca319486bfbbc3663ea0fbe81326349
bandit22@bandit:/usr/bin$ cat /tmp/8ca319486bfbbc3663ea0fbe81326349
jc1udXuA1tiHqjIsL8yaapX5XIAI6i0n
```

24. 又双叒叕失败了

```
bandit23@bandit:/tmp/channy$ cd /usr/bin
bandit23@bandit:/usr/bin$ cat cronjob_bandit24.sh
#!/bin/bash

myname=$(whoami)

cd /var/spool/$myname
echo "Executing and deleting all scripts in /var/spool/$myname:"
for i in * .*;
do
    if [ "$i" != "." -a "$i" != ".." ];
    then
	echo "Handling $i"
	timeout -s 9 60 ./$i
	rm -f ./$i
    fi
done

bandit23@bandit:/usr/bin$ cd /tmp/channy
bandit23@bandit:/tmp/channy$ cat bandit24.sh
#!/bin/bash

cat /etc/bandit_pass/bandit24 >> /tmp/channy/bandit24_pass

bandit23@bandit:/tmp/channy$ ls
bandit24.sh

//按理说应该有此文件
bandit23@bandit:/tmp/channy$ cat bandit24_pass
UoMYTrfrBFHyQXmg6gzctqAwOmw1IohZ
```

25. 要用bash不能用sh, bash兼容sh，反之不行

```
bandit24@bandit:/tmp/channy$ cat bandit25.sh
#!/bin/bash

for i in {0..9999}
do
	printf "UoMYTrfrBFHyQXmg6gzctqAwOmw1IohZ %04d\n" $i
done

bandit24@bandit:/tmp/channy$ bash bandit25.sh | nc localhost 30002
# ...
Wrong! Please enter the correct pincode. Try again.
Correct!
The password of user bandit25 is uNG9O58gUE7snukf3bvZ0rxhtnjzSGzG

Exiting.
```

26. ???

```
# password: 5czgV9L3Xx8JPOyRbXh6lQbmIOWvPT6Z
```

27. connect failed

利用vim的:set shell=/bin/bash修改shell，再通过:shell获得bash

```
bandit26@bandit:~$ ls
bandit27-do  text.txt
bandit26@bandit:~$ ./bandit27-do
Run a command as another user.
  Example: ./bandit27-do id
bandit26@bandit:~$ ./bandit27-do cat /etc/bandit_pass/bandit27
3ba3118a22e93127a4ed485be72ef5ea
```

28. git

```
bandit27@bandit:/tmp/channy$ git clone  ssh://bandit27-git@localhost/home/bandit27-git/repo
Cloning into 'repo'...
Could not create directory '/home/bandit27/.ssh'.
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ECDSA key fingerprint is SHA256:98UL0ZWr85496EtCRkKlo20X3OPnyPSB5tB5RPbhczc.
Are you sure you want to continue connecting (yes/no)? yes
Failed to add the host to the list of known hosts (/home/bandit27/.ssh/known_hosts).
This is a OverTheWire game server. More information on http://www.overthewire.org/wargames

bandit27-git@localhost's password:
remote: Counting objects: 3, done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (3/3), done.
bandit27@bandit:/tmp/channy$ ls
repo
bandit27@bandit:/tmp/channy$ cd repo
bandit27@bandit:/tmp/channy/repo$ ls
README
bandit27@bandit:/tmp/channy/repo$ vim README
bandit27@bandit:/tmp/channy/repo$ cat README
The password to the next level is: 0ef186ac70e04ea33b4c1853d2526fa2
```

29. git log, git diff

```
bandit28@bandit:/tmp/channy$ git clone ssh://bandit28-git@localhost/home/bandit28-git/repo
Cloning into 'repo'...
Could not create directory '/home/bandit28/.ssh'.
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ECDSA key fingerprint is SHA256:98UL0ZWr85496EtCRkKlo20X3OPnyPSB5tB5RPbhczc.
Are you sure you want to continue connecting (yes/no)? yes
Failed to add the host to the list of known hosts (/home/bandit28/.ssh/known_hosts).
This is a OverTheWire game server. More information on http://www.overthewire.org/wargames

bandit28-git@localhost's password:
remote: Counting objects: 9, done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 9 (delta 2), reused 0 (delta 0)
Receiving objects: 100% (9/9), done.
Resolving deltas: 100% (2/2), done.

bandit28@bandit:/tmp/channy$ ls
repo
bandit28@bandit:/tmp/channy$ cd repo
bandit28@bandit:/tmp/channy/repo$ ls
README.md
bandit28@bandit:/tmp/channy/repo$ vim README.md

bandit28@bandit:/tmp/channy/repo$ git log
commit 073c27c130e6ee407e12faad1dd3848a110c4f95
Author: Morla Porla <morla@overthewire.org>
Date:   Tue Oct 16 14:00:39 2018 +0200

    fix info leak

commit 186a1038cc54d1358d42d468cdc8e3cc28a93fcb
Author: Morla Porla <morla@overthewire.org>
Date:   Tue Oct 16 14:00:39 2018 +0200

    add missing data

commit b67405defc6ef44210c53345fc953e6a21338cc7
Author: Ben Dover <noone@overthewire.org>
Date:   Tue Oct 16 14:00:39 2018 +0200

    initial commit of README.md
bandit28@bandit:/tmp/channy/repo$ git diff 186a10
diff --git a/README.md b/README.md
index 3f7cee8..5c6457b 100644
--- a/README.md
+++ b/README.md
@@ -4,5 +4,5 @@ Some notes for level29 of bandit.
 ## credentials

 - username: bandit29
-- password: bbc96594b4e001778eee9975372716b2
+- password: xxxxxxxxxx
```

30. git branch -a, git checkout 

```
bandit29@bandit:/tmp/channy$ git clone ssh://bandit29-git@localhost/home/bandit29-git/repo
Cloning into 'repo'...
Could not create directory '/home/bandit29/.ssh'.
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ECDSA key fingerprint is SHA256:98UL0ZWr85496EtCRkKlo20X3OPnyPSB5tB5RPbhczc.
Are you sure you want to continue connecting (yes/no)? yes
Failed to add the host to the list of known hosts (/home/bandit29/.ssh/known_hosts).
This is a OverTheWire game server. More information on http://www.overthewire.org/wargames

bandit29-git@localhost's password:
remote: Counting objects: 16, done.
remote: Compressing objects: 100% (11/11), done.
remote: Total 16 (delta 2), reused 0 (delta 0)
Receiving objects: 100% (16/16), done.
Resolving deltas: 100% (2/2), done.

bandit29@bandit:/tmp/channy/repo$ git branch -a
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/dev
  remotes/origin/master
  remotes/origin/sploits-dev

bandit29@bandit:/tmp/channy/repo$ git checkout dev
Branch dev set up to track remote branch dev from origin.
Switched to a new branch 'dev'
bandit29@bandit:/tmp/channy/repo$ ls
code  README.md

bandit29@bandit:/tmp/channy/repo$ cat README.md
# Bandit Notes
Some notes for bandit30 of bandit.

## credentials

- username: bandit30
- password: 5b90576bedb2cc04c86a9e924ce42faf

```

31. git .git, git show --name-only, git show-ref --tags -d

```
bandit30@bandit:/tmp/channy$ git clone  ssh://bandit30-git@localhost/home/bandit30-git/repo
Cloning into 'repo'...
Could not create directory '/home/bandit30/.ssh'.
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ECDSA key fingerprint is SHA256:98UL0ZWr85496EtCRkKlo20X3OPnyPSB5tB5RPbhczc.
Are you sure you want to continue connecting (yes/no)? yes
Failed to add the host to the list of known hosts (/home/bandit30/.ssh/known_hosts).
This is a OverTheWire game server. More information on http://www.overthewire.org/wargames

bandit30-git@localhost's password:
remote: Counting objects: 4, done.
remote: Total 4 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (4/4), done.

bandit30@bandit:/tmp/channy/repo$ cat README.md
just an epmty file... muahaha

bandit30@bandit:/tmp/channy/repo$ cd .git
bandit30@bandit:/tmp/channy/repo/.git$ ls
branches  description  hooks  info  objects      refs
config    HEAD         index  logs  packed-refs
bandit30@bandit:/tmp/channy/repo/.git$ cat packed-refs 
# pack-refs with: peeled fully-peeled 
3aa4c239f729b07deb99a52f125893e162daac9e refs/remotes/origin/master
f17132340e8ee6c159e0a4a6bc6f80e1da3b1aea refs/tags/secret
bandit30@bandit:/tmp/channy/repo/.git$ cd ..
bandit30@bandit:/tmp/channy/repo$ git show --name-only secret
47e603bb428404d265f59c42920d81e5
```

32. git 

```
bandit31@bandit:/tmp/channy/repo$ cat README.md 
This time your task is to push a file to the remote repository.

Details:
    File name: key.txt
    Content: 'May I come in?'
    Branch: master

bandit31@bandit:/tmp/channy/repo$ git add -f key.txt

bandit31@bandit:/tmp/channy/repo$ git push
Could not create directory '/home/bandit31/.ssh'.
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ECDSA key fingerprint is SHA256:98UL0ZWr85496EtCRkKlo20X3OPnyPSB5tB5RPbhczc.
Are you sure you want to continue connecting (yes/no)? yes
Failed to add the host to the list of known hosts (/home/bandit31/.ssh/known_hosts).
This is a OverTheWire game server. More information on http://www.overthewire.org/wargames

bandit31-git@localhost's password:
Counting objects: 3, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 324 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
remote: ### Attempting to validate files... ####
remote:
remote: .oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.
remote:
remote: Well done! Here is the password for the next level:
remote: 56a9bf19c63d650ce78e6ec0354ee45e
remote:
remote: .oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.oOo.
remote:
To ssh://localhost/home/bandit31-git/repo
 ! [remote rejected] master -> master (pre-receive hook declined)
error: failed to push some refs to 'ssh://bandit31-git@localhost/home/bandit31-git/repo'

```

33. $0, whoami

不管输入什么都变成了大写的，从而导致命令执行失败，则改用$0，获得shell，然后通过whoami可以知道自己是bandit33 

```
  Enjoy your stay!

WELCOME TO THE UPPERCASE SHELL

>> $0
$ whoami
bandit33
$ cat /etc/bandit_pass/bandit33
c9c3199ddf4121b10cf581a98d51caee
```

34. At this moment, level 34 does not exist yet.

[back](./)

