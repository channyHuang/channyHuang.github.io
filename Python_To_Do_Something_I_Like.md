---
layout: default
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


[back](./)

