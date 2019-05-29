---
layout: default
---

//Author: channy

//Create Date: 2018-10-13 13:49:04

//Description: 

# Head_File_Include_Each_Other

class A as usual
```c++
//--classA.h 
#include "classB.h"
class A {
public:
    A();
    void action();
private:
    B b;
};


//classA.cpp
A::A() {
    cout << "creat A" << endl;
}
void A::action() {
    cout  << "class A:" << endl;
}
```

Class B as follow
```c++
//classB.h
class A;
class B {
public:
    B();
    void action();
private:
    A *a;
};


//classB.cpp
#include "classA.h"
B::B() {
    cout << "creat B" << endl;
}
void B::action() {
    cout  << "class B:" << endl;
    a->action();
}

-----------------------
main() {
    ...
}
```


[back](./)

