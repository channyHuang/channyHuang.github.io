---
layout: default
title: overthewire_wargamees_notes_krypton
categories:
- Security
tags:
- Security
---
//Description:

//Create Date: 2020-02-25 14:43:54

//Author: channy

# overthewire_wargamees_notes_krypton

[address](https://overthewire.org/wargames/krypton/)

> ssh -p2222 krypton1@leviathan.labs.overthewire.org

## 1. 

```
//Qt + c++
#include <iostream>
#include <QByteArray>
#include <QDebug>

int main() {
    QByteArray str = "S1JZUFRPTklTR1JFQVQ=";
    qDebug() << QByteArray::fromBase64(str);
    return 0;
}
```

```
"KRYPTONISGREAT"
Press <RETURN> to close this window...
```

```
krypton1@krypton:~$ cd /krypton/
krypton1@krypton:/krypton$ ls -lrht  
total 24K
drwxr-xr-x 2 root root 4.0K Nov  4 05:21 krypton1
drwxr-xr-x 2 root root 4.0K Nov  4 05:21 krypton2
drwxr-xr-x 2 root root 4.0K Nov  4 05:21 krypton4
drwxr-xr-x 2 root root 4.0K Nov  4 05:21 krypton3
drwxr-xr-x 2 root root 4.0K Nov  4 05:21 krypton5
drwxr-xr-x 3 root root 4.0K Nov  4 05:21 krypton6
```

## 2.

```
krypton1@krypton:/krypton/krypton1$ ls -lrht -a
total 16K
-rw-r----- 1 krypton1 krypton1   26 Nov  4 05:21 krypton2
-rw-r----- 1 krypton1 krypton1  882 Nov  4 05:21 README
drwxr-xr-x 2 root     root     4.0K Nov  4 05:21 .
drwxr-xr-x 8 root     root     4.0K Nov  4 05:21 ..
krypton1@krypton:/krypton/krypton1$ file krypton2 
krypton2: ASCII text
krypton1@krypton:/krypton/krypton1$ cat krypton2 
YRIRY GJB CNFFJBEQ EBGGRA
```

```
#include <iostream>

int main() {
    std::string str=  "YRIRY GJB CNFFJBEQ EBGGRA";
    int len = str.length();
    for (int x = 1; x < 27; x++) {
        for (int i = 0; i < len; i++) {
            if (str[i] == ' ') continue;
            str[i] = (str[i] - 'A' + 1) % 26 + 'a';
        }
        std::cout << x << std::endl << str << std::endl;
    }
    return 0;
}
```

```
//换成小写的好看些方便查找，记得换回大写
...
24
exoxe mph itllphkw khmmxg
25
level two password rotten
26
slcls adv whzzdvyk yvaalu
Press <RETURN> to close this window...
```

## 3. encrypt是把原文加密，krypton3里面存的是加密后的文字 

```
krypton1@krypton:/krypton/krypton2$ ls -lrht
total 24K
-rw-r----- 1 krypton2 krypton2   13 Nov  4 05:21 krypton3
-rw-r----- 1 krypton3 krypton3   27 Nov  4 05:21 keyfile.dat
-rwsr-x--- 1 krypton3 krypton2 8.8K Nov  4 05:21 encrypt
-rw-r----- 1 krypton2 krypton2 1.8K Nov  4 05:21 README
krypton2@krypton:/krypton/krypton2$ cat krypton3 
OMQEMDUEQMEK
krypton2@krypton:/tmp/channy$ cat tmp.txt
abcdefghijklmnopqrstuvwxyz
krypton2@krypton:/tmp/channy$ /krypton/krypton2/encrypt ./tmp.txt
krypton2@krypton:/tmp/channy$ cat ciphertext 
MNOPQRSTUVWXYZABCDEFGHIJKLkrypton2@krypton:/tmp/channy$ 
```

```
//记得换成大写
caesariseasy
```

## 4. 

```
krypton3@krypton:/krypton/krypton3$ ls -lrht   
total 28K
-rw-r----- 1 krypton3 krypton3   42 Nov  4 05:21 krypton4
-rw-r----- 1 krypton3 krypton3  560 Nov  4 05:21 found3
-rw-r----- 1 krypton3 krypton3 2.1K Nov  4 05:21 found2
-rw-r----- 1 krypton3 krypton3 1.6K Nov  4 05:21 found1
-rw-r----- 1 krypton3 krypton3  785 Nov  4 05:21 README
-rw-r----- 1 krypton3 krypton3   37 Nov  4 05:21 HINT2
-rw-r----- 1 krypton3 krypton3   56 Nov  4 05:21 HINT1
krypton3@krypton:/krypton/krypton3$ cat krypton4 
KSVVW BGSJD SVSIS VXBMN YQUUK BNWCU ANMJS krypton3@krypton:/krypton/krypton3$ cat HINT1
Some letters are more prevalent in English than others.
krypton3@krypton:/krypton/krypton3$ cat HINT2
"Frequency Analysis" is your friend.
```

[统计词频](http://www.richkni.co.uk/php/crypta/freq.php)

经过网站分析，我们可以知道，三个found里面，单个字母频率最高的是S，三个字母是JDS。
如果我们将S对应E，JDS对应THE，那么DS可以对应为HE，JD为TH。
SN和NS对应为 ER,RE。
Q为A，则QG为AN。
CG和BG可以是IN或ON，但是 CBG到ION，我们可以将CG转换为IN，将BG转换为ON
对于find1中的前端，“CGZNL YJBEN QYDLQ ZQSUQ”可以翻译为“IN $ R $ $ TO $ RA $ H $ A $ AE $ A”，它就像“IN CRYPTOGRAPHY A $ AE $ A”，

由此推断，我们可以得到转换表：
```
密文： A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
明文： B O I H G K N Q V T W Y U R X Z A J E M S L D F P C 
```

[直接翻译出密文](https://quipqiup.com/)

```
得到密码：WELLD ONETH ELEVE LFOUR PASSW ORDIS BRUTE
整理后：WELL DONE THE LEVEL FOUR PASSWORD IS BRUTE
```

## 5. 

```
krypton4@krypton:/krypton/krypton4$ ls -lrht
total 20K
-rw-r----- 1 krypton4 krypton4   10 Nov  4 05:21 krypton5
-rw-r----- 1 krypton4 krypton4 2.9K Nov  4 05:21 found2
-rw-r----- 1 krypton4 krypton4 1.7K Nov  4 05:21 found1
-rw-r----- 1 krypton4 krypton4 1.4K Nov  4 05:21 README
-rw-r----- 1 krypton4 krypton4  287 Nov  4 05:21 HINT
krypton4@krypton:/krypton/krypton4$ cat HINT 
Frequency analysis will still work, but you need to analyse it
by "keylength".  Analysis of cipher text at position 1, 6, 12, etc
should reveal the 1st letter of the key, in this case.  Treat this as
6 different mono-alphabetic ciphers...

Persistence and some good guesses are the key!
```

先用http://www.richkni.co.uk/php/crypta/freq.php进行词频分析，然后发现三个字母词中XRI的出现频率最高，计算出现的XRI，每两个之间的间隔，这些间隔的公因子就为密钥长度，由于题目已经告知密钥长度为6，所以我们可以直接进行猜密钥，有个网站可以得到密钥。
http://www.simonsingh.net/The_Black_Chamber/vigenere_cracking_tool.html

得到的密钥为FREKEY，之后就可以进行解密了，最后结果为’CLEAR TEXT’

## 6. 本关和上一关差不多，但是没有告知密钥长度，可以根据krypton4中说的方式获得长度。

利用此网站的统计数据（http://www.simonsingh.net/The_Black_Chamber/vigenere_cracking_tool.html），猜出密钥长度，然后进行对比，得到密钥为：‘KEYLENGTH’，一开始猜测长度为3，但发现后面的密钥匹配很难匹配，所以改成9，然后就得到了密钥。

之后利用krypton4的脚本进行解码即可，解码得到‘RANDOM’

## 7. 看文件目录，感觉和krypton2相似。给了一个明文生成密文，如此我们可以输入重复的内容，比如A*200，查看得到的密文，由此判断密钥。得到密文，我们可以看到密文中是“EICTDGYIYZKTHNSIRFXYCPFUEOCKRN”的重复，所以猜测这个是密钥，然后按照前几题的思路，写个脚本进行解密，得到下一关的密码。

[back](/)

