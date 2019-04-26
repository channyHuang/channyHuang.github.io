---
layout: default
---

//Author: channy

//Create Date: 2019-04-25 16:43:33

//Description: unsolved questions in work

# About Memory Usage
Here I defined a calss to store strings.

```c++
calss MyString
{
	char **pAddr; 
	int *pCount; //be used how many times
	int *pAddrCount;
public:
	MyString(int count)
	{
		pAddr = new char*[count];
		pCount = new int;
		*pCount = 1;
		pAddrCount = new int;
		*pAddrCount = count;
	}
	~MyString()
	{
		if (--*pCount == 0)
		{
			delete [] pAddr;
			delete pCount;
			delete pAddrCount;
		}
	}
	//...
}
```

Each time I new a MyString, for example
**MyString mystring(6)**
then it will takes (6 + 2) * 4 = 32 bytes, right?

now I have about 1,500,000 strings to be stored, when I save them into a list, it costs me about 140M memory, why?

I use it like this

```c++
std::list<MyString> mystrings;

bool readLine(char *line)
{
	char *p;
	char *buf = line;
	
	MyString mystring(6);
	int i = 0;
	
	while (line)
	{
		mystring[i++] = line;
		char *nextStart = strchr(line, '\t');
		if (nextStart)
			line = nextStart + 1;
		else 
			line = nullptr;
	}
	
	mystrings.push_back(mystring);
}
```

My test file contains about 1,500,000 lines and each line contains 5 '\t' so 6 fields, normally it should use 32*1,500,000 ~ 40M, but actually it used about 140M, why???

Or because of class alignment? pAddr took 32bytes so are others? But it sounds ridiculous...

Here is total main.cpp (using Qt)
```c++
#include <QCoreApplication>

#include <QDebug>

#include <list>
using namespace std;

class RawStrsWrapper
{
    char **rawss;
    int *sscp;
    int *StrCountP;
public:
    RawStrsWrapper(int count)
    {
        rawss=new char*[count];
        sscp=new int;
        *sscp=1;
        StrCountP=new int;
        *StrCountP=count;
        for(int i=0;i<count;++i)
            rawss[i]=NULL;
    }
    ~RawStrsWrapper()
    {
        if (--*sscp==0)
        {
            delete[] rawss;
            delete sscp;
            delete StrCountP;
        }
    }
    RawStrsWrapper(const RawStrsWrapper &aSw)
    {
        ++(*aSw.sscp);
        StrCountP=aSw.StrCountP;
        rawss=aSw.rawss;
        sscp=aSw.sscp;
    }
    RawStrsWrapper operator=(const RawStrsWrapper & aSw)
    {
        ++(*aSw.sscp);
        if (--*sscp==0)
        {
            delete [] rawss;
            delete sscp;
            delete StrCountP;
        }
        StrCountP=aSw.StrCountP;
        rawss=aSw.rawss;
        sscp=aSw.sscp;
        return *this;
    }
    char* &operator[](int id)
    {
        if (id<0 || id>=(*StrCountP)) return rawss[0];
        return rawss[id];
    }
    int GetStrCount()
    {
        return (*StrCountP);
    }
};

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    list<RawStrsWrapper> m_Table;

    for (int i = 0; i < 100000; i++)
    {
        RawStrsWrapper strW(6);
        m_Table.push_back(strW);
    }

    return a.exec();
}

```


[back](./)