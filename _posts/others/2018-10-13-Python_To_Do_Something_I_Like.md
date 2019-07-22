---
layout: default
title: Python_To_Do_Something_I_Like
categories:
- Python
tags:
- Python
---
//Author: channy

//Create Date: 2018-10-13 13:38:46

//Description: 

# Python_To_Do_Something_I_Like

## 分割mp3
```python
from pydub import AudioSegment
from pydub.silence import split_on_silence
 
file = '21.mp3'#file anme
 
song = AudioSegment.from_mp3(file)
words = split_on_silence(song, min_silence_len=2000, silence_thresh=-100)
 
print len(words)
 
j = 0;
for i in words:
 j = j+1;
 new = AudioSegment.empty()
 new = i;
 new.export('21/%03d.mp3'%j, format='mp3')
```

## 保存网页图像
```python
import urllib
 
def saveAsPng_1():
 numOfPage = 353;
 localPath = 'd:\\useAsE\\page';
 for i in range(1, numOfPage):
 url = "http://img.sslibrary.com/n/fc6e4282a753bf989f32334579021ea6MC153628655981/img0/B064342871F1CA073DF21FD0194E4907CB6072FF921E32FAAA2A54BCA45FCAA3A54919FBC95D1271759CFF0AA8576BC59FB586C1F9030783AE4CCCA9A83D630570CACA94FAED9BC950931E977753E07B6EBC718847B03305B73CF5954125F07858C17196546CB132D81516415F6A0530917A/bf1/qw/13050173/10CD5A124BBE4A08B1391395986EEDD2/"+'%06d'%i+"?zoom=0";
 filename = localPath + '\\%s.png'%i;
 urllib.urlretrieve(url, filename);
 
def saveAsPng_2():
 numOfPage = 1;
 localPath = 'd:\\useAsE\\page';
 for i in range(1, numOfPage):
 url = "http://img.sslibrary.com/n/92972996f3bd6d2576ae3a56d7934b9bMC152853932305/img0/D798B95EE0B5B84674ABEB52ABB18CFC66E7B58F432CC4BECAF2CBAB6CCE31BB7230CEF8C7B167EB6C7F302A0990713A11B2B95679A3FF43E9A53C9DDD327AA7B015E0815CB4D384FE4C865AD78D7D56C0BC459ABEA838E143599696E67345A1BA984F175EC470E1DA9D5B351995A0C02A62/bf1/qw/13095810/559BB81D33BA4EDE80CA6820FD17403B/"+str+"?zoom=0";
 filename = localPath + '\\%s.png'%i;
 data = urllib.urlopen(url).read()
 f = file(path, "wb")
 f.write(data)
 f.close()
 
saveAsPng_1();
```

## 背日语单词
经验：接口和版本对应

用的Tkinter做界面

Tkinter版本不一样接口不一样
```python
#coding: utf-8
import Tkinter
import MySQLdb
import sqlite3
import random
import re
#import pandas as pd

curIdx = 0
answer = []
isShowAnswer = 0
what = ["mean", "prononce", "word"]

def initWidget():
    global mainWin
    mainWin = Tkinter.Tk()
    mainWin.title("Come on, channy")
    mainWin.attributes('-alpha', 0)
 
    global isShowAnswer
    isShowAnswer = Tkinter.IntVar()
    isShowAnswer.set(0)
    global isTestWhat
    isTestWhat = Tkinter.StringVar()
    isTestWhat.set(what[0])
    global isGivenWhat
    isGivenWhat = Tkinter.StringVar()
    isGivenWhat.set(what[1])

    showAnsBtn = Tkinter.Checkbutton(mainWin, text="show answer", variable=isShowAnswer, command=showAnswer, onvalue=1, offvalue=0)
    showAnsBtn.pack()
    Tkinter.Label(mainWin, text="test what:").pack()
    testWhatBtn = Tkinter.OptionMenu(mainWin, isTestWhat, what[0], what[1], what[2])
    testWhatBtn.pack()

    Tkinter.Label(mainWin, text="given what:").pack()
    givenWhatBtn = Tkinter.OptionMenu(mainWin, isGivenWhat, what[2], what[1], what[0])
    givenWhatBtn.pack()

    Tkinter.Label(mainWin, text="Select the meaning of Word:").pack()
    deleteBtn = Tkinter.Button(mainWin, text="Delete this word", command=deleteWord)
    deleteBtn.pack()

    readBtn = Tkinter.Button(mainWin, text="Read File", command=readFile)
    readBtn.pack()

    aboutBtn = Tkinter.Button(mainWin, text="About", command=about) 
    aboutBtn.pack()  

    global wordLabel
    wordLabel = Tkinter.Label(mainWin, text="word")
    wordLabel.pack()
    global selectAns
    selectAns = Tkinter.IntVar()
    selectAns.set(0)
  
    for i in range(0, 4):
        answer.append(Tkinter.Radiobutton(mainWin, text="A", variable=selectAns, command=showAnswer, value=i+1))
        answer[i].pack()

    showWord()

def deleteDB():
    db = sqlite3.connect("test.db")
    cursor = db.cursor()
    cursor.execute("DROP TABLE IF EXISTS WORDS") 
    db.close() 

def readFile():
    wordFile = open('words.txt')
    try:
        words = wordFile.read().decode('utf-8').splitlines()
    finally:
        wordFile.close()
 
    db = sqlite3.connect("test.db")
    cursor = db.cursor()
    cursor.execute("DROP TABLE IF EXISTS WORDS")
    cursor.execute("CREATE TABLE WORDS(ORIGINWORD CHAR(20) NOT NULL, PRONONCE CHAR(20), MEANING CHAR(20), NONE CHAR(10), FRIQUENCY INT)")
  
    insertSql = ""
    for word in words: 
        words = word.split(' ')
        lenOfWords = len(words)
        if (lenOfWords < 3):
            continue
        wordSplit = re.split('[(,)]', words[0]) 
        if (len(wordSplit) == 1):
            insertSql = "INSERT INTO WORDS(ORIGINWORD, PRONONCE, MEANING, NONE, FRIQUENCY) values ('%s', '%s', '%s', '%s', 0)"%(words[0], words[0], words[2], words[1])
        else:
            insertSql = "INSERT INTO WORDS(ORIGINWORD, PRONONCE, MEANING, NONE, FRIQUENCY) values ('%s', '%s', '%s', '%s', 0)"%(wordSplit[1], wordSplit[0], words[2], words[1])
        cursor.execute(insertSql)
    db.commit()
    db.close() 

def readDb():
    db = sqlite3.connect("test.db")
    cursor = db.cursor()  
    cursor.execute("SELECT * FROM WORDS")
    words = cursor.fetchall()
    db.close() 
    return words

def deleteWord(): 
    db = sqlite3.connect("test.db")
    cursor = db.cursor()
    cursor.execute("DELETE FROM WORDS WHERE ORIGINWORD = %s"%(words[curIdx][0]))
    db.close()

def about():
    aboutWin = Tkinter.Tk()
    Tkinter.Label(aboutWin, text="Come on").pack()
    aboutWin.title("About") 

def showAnswer():
    answer[curIdx]['fg'] = 'green'
    wordLabel.after(5000, showWord)

def showWord():
    global curIdx
    selectAns.set(0) 
    answer[curIdx]['fg'] = 'black'
    words = readDb()
    lenOfWords = len(words)
    idxs = random.sample(range(0, lenOfWords), 4)
    curIdx = random.randint(0, 3)
    
    wordIdx = 0
    ansIdx = 0 #test mean
    if (isGivenWhat.get() == "mean"):
        wordIdx = 2
    elif (isGivenWhat.get() == "prononce"):
        wordIdx = 1
    if (isTestWhat.get() == "mean"):
        ansIdx = 2
    elif (isTestWhat.get() == "prononce"):
        ansIdx = 1

    wordLabel['text'] = words[idxs[0]][wordIdx]
    answer[curIdx]['text'] = words[idxs[0]][ansIdx]
    for i in range(0, 4):
        if (curIdx == i):
            continue
        answer[i]['text'] = words[idxs[i + 1 if(i < curIdx) else i]][ansIdx]
    if (isShowAnswer.get() == 1):
        showAnswer() 

if __name__ == "__main__":
    initWidget()
    mainWin.mainloop()     

```

[back](./)

