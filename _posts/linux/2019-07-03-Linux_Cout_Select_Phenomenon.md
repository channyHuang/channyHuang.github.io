---
layout: default
title: Linux_Cout_Select_Phenomenon
categories:
- Linux
tags:
- Linux
---
//Author: channy

//Create Date: 2019-07-03 14:53:52

//Description: 

# Linux_Cout_Select_Phenomenon

When using std::cout and select in linux, a strange thing happened.

Reason: cout didn't flush. Need to add std::cout.flush(). Perfect~

For example, 
```c++
//using Qt

#include <QCoreApplication>
#include <iostream>

bool hasInput(int nWaitSec, char *cCmd)
{
    fd_set rfds;
    tv.tv_sec = nWaitSec;
    tv.tv_usec = 0;

    //here cout didn't output
	std::cout << ">>>";
	retval = select(1, &rfds, nullptr, nullptr, &tv);

	if (retval == -1)
	    perror("select()");
    else if (retval){
        std::cin.getline(cCmd, 256);
        return true;
    }
    else {
        std::cout << "listen input time out, exit" << std::endl;
    }
																			    return false;
																			}

																			int main(){
	QString sHelpMsg;
    sHelpMsg.append("hello\n");
    //this centence didn't output
	sHelpMsg.append("how are you?");

    std::cout << sHelpMsg.toStdString().c_str();
	char cCmd[256] = {0};
    if (hasInput(60, cCmd)) {
	    std::cout << "get input" << std::endl;
	}
	else {
		std::cout << "timeout" << std::endl;
	}
	return 0;
}

```

The output of the above is:
```
hello
//here is input
how are you?>>>get input
```

Why "how are you" output after input? Can't it be output before?

[back](./)

