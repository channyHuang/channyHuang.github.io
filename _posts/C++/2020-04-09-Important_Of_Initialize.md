---
layout: default
title: Important_Of_Initialize
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: 2020-04-09 09:55:36

//Author: channy

# Important_Of_Initialize
# 初始化的重要性

在刷leetcode第306题时发现一个奇怪现象：

注意类Solution里面的私有变量flag，注释掉一个不改变flag的语句会导致输出结果不一样！！！

编译用的是Qt4.5.1,win10下

why???

```c++
#include <QDebug>
#include <iostream>
using namespace std;

class Solution {
public:
    bool isAdditiveNumber(string num) {
        //flag = false; //一开始没有初始化
        int len = num.length();
        for (int i = 1; i <= len - 2; i++) {
	    //下一句中的num[i + 1]应该是num[i]
            if (num[0] == '0' && i != 1) break;
            for (int j = i + 1; j <= len - 1; j++) {
                if (num[i + 1] == '0' && j != i + 1) break;
                search(num, i, j, add(num.substr(0, i), num.substr(i, j - i)));
                if (flag) return flag;
            }
        }
        return flag;
    }

    void search(string num, int pos1, int pos2, string next) {
        if (next.length() > num.length() - pos2) return;
        if (num.substr(pos2, next.length()) != next) return;
        if (next.length() == num.length() - pos2) {
            qDebug() << pos1 << " " << pos2;
            flag = true;
            return;
        }
        if (pos1 == 2 && pos2 == 4) cout << next << ".";
        search(num, pos2, pos2 + next.length(), add(num.substr(pos1, pos2 - pos1), next));
    }

    string add(string a, string b) {
        int lena = a.length();
        int lenb = b.length();
        int add = 0;
        if (lena >= lenb) {
            int pos = lena - 1;
            for (int i = lenb - 1; i >= 0; i--) {
                a[pos] += (b[i] - '0') + add;
                add = 0;
                if (a[pos] > '9') {
                    a[pos] -= 10;
                    add = 1;
                }
                pos--;
            }
            while (add) {
                if (pos < 0) {
                    a = "1" + a;
                    add = 0;
                }
                else {
                    a[pos]++;
                    add = 0;
                    if (a[pos] > '9') {
                        a[pos] -= 10;
                        add = 1;
                    }
                    pos--;
                }
            }
            return a;
        }
        int pos = lenb - 1;
        for (int i = lena - 1; i >= 0; i--) {
            b[pos] += (a[i] - '0') + add;
            add = 0;
            if (b[pos] > '9') {
                b[pos] -= 10;
                add = 1;
            }
            pos--;
        }
        while (add) {
            if (pos < 0) {
                b = "1" + b;
                add = 0;
            }
            else {
                b[pos]++;
                add = 0;
                if (b[pos] > '9') {
                    b[pos] -= 10;
                    add = 1;
                }
                pos--;
            }
        }
        return b;
    }

private:
    bool flag;
};

int main() {
    Solution s;
    //奇怪的现象出现了，下面这句没有被注释掉的时候，isAdditiveNumber("101020305080130210")输出是true,注释掉后输出的是false!!!
    cout << (s.add("10", "20")) << endl; 
    qDebug() << s.isAdditiveNumber("101020305080130210");
}
```

[back](/)

