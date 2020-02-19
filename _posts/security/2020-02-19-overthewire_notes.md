---
layout: default
title: overthewire_notes
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-02-19 21:32:26

//Author: channy

# overthewire_notes

[address](https://overthewire.org/wargames/)

## Bandit

0. ssh -p2220 bandit0@bandit.labs.overthewire.org

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

```
[back](./)

