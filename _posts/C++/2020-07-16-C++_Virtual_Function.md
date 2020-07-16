---
layout: default
title: C++_Virtual_Function
categories:
- C++
tags:
- C++
---
//Description: C++, virtual function

//Create Date: 2020-07-16 17:38:59

//Author: channy

# C++_Virtual_Function

```
class A {
public:
     A(int _val = 0) {
        val = _val;
        cout << "create A " << val << endl;
    }

    virtual ~A() {
        cout << "destroy A " << val << endl;
    }

    void fun() {
        cout << "funcA " << val << endl;
    }

    virtual void vFun() {
        cout << "vFunA " << val << endl;
    }

    int val;
};

class B : public A {
public:
     B(int _val = 0) : A(_val) {
        cout << "create B " << val << endl;
    }

    virtual ~B() {
        cout << "destroy B " << val << endl;
    }

    void fun() {
        cout << "funcB " << val << endl;
    }

    virtual void vFun() {
        cout << "vFunB " << val << endl;
    }
};

    A a(1);
    a.fun();
    a.vFun();
    cout << "----" << endl;
    B b(2);
    b.fun();
    b.vFun();
    cout << "----" << endl;
    A c = B(3);
    c.fun();
    c.vFun();
    cout << "----" << endl;
```

```
create A 1
funcA 1
vFunA 1
----
create A 2
create B 2
funcB 2
vFunB 2
----
create A 3
create B 3
destroy B 3
destroy A 3
funcA 3
vFunA 3
----
destroy A 3
destroy B 2
destroy A 2
destroy A 1
```

## 子类B:

构造函数: 先父类后子类, 不能是virtual

析构函数:

1. 非virtual类，先子类后父类

2. virtual类, 先子类后父类

重写函数: 只子类

虚函数: 只子类

## 声明父类A, 构造子类B

构造函数: 先父类后子类，会调用析构函数析构掉子类和构造子类时产生的父类

析构函数: 父类

重写函数: 父类

虚函数: 父类

[back](/)

