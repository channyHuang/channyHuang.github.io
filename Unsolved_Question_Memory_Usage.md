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


[back](./)