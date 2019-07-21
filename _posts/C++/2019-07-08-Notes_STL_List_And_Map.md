---
layout: default
---

//Author: channy

//Create Date: 2019-07-08 09:19:15

//Description: 

# Notes_STL_List_And_Map

已知：erase后迭代器会失效，已经重置了迭代器

问题：程序依旧会崩溃

原因：此代码中原因还未知。工作代码中出现过erase的是局部变量，实际上map还是没有erase

跟进：过了几天再试又好了。。。

（没有经历过把bug解释为神学的程序员不是好程序员）

代码：
```c++
#include <QCoreApplication>
#include <QDebug>
int main(int argc, char *argv[])
{
    //QCoreApplication a(argc, argv);

    QList<int> ql;
    qDebug() << ql.size();

    QMap<int, QList<int>> qm;
    qm[0] = ql;

    for (QMap<int, QList<int>>::iterator iter = qm.begin(); iter != qm.end(); iter++) {

        qDebug() << qm.size();

        for (QList<int>::iterator itr = iter->begin(); itr != iter->end(); itr++) {
            itr = iter->erase(itr);
        }

        if (iter->size() == 0) {
            iter = qm.erase(iter);
            //如果不加下面的判断，会崩溃。。。iter != qm.end() == true. But why???
			if (qm.size() == 0) break;
        }
    }

    //return a.exec();
    return 0;
}
```

[back](./)

