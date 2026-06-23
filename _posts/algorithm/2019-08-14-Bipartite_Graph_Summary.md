---
layout: default
title: Bipartite_Graph_Summary.md
categories:
- Algorithm
tags:
- OJ
---
//Description: 闲时做OJ的一些笔记和总结，二分图。最近在做hiho，以上面的题为例

//Create Date: 2019-08-14 17:19:39

//Author: channy

# Bipartite_Graph_Summary

二分图的最小点覆盖点数，即二分图最大匹配（hiho1127），不能用贪心。。。

本来想用贪心的，写都写完了，发现样例就不通过（样例良心），贪心慎用～

```c++
#include <iostream>
#include <algorithm>

#define MAXN 5005


class Index {
public:
    int index;
    Index *pre, *next;
    Index(int _idx = 0) {
        index = _idx;
        pre = nullptr;
        next = nullptr;
    }
};

class Node {
public:
    int index;
    bool flag;
    int numOfChildren;
    Index *children;
    Node (int _idx = 0) {
        index = _idx;
        numOfChildren = 0;
        children = nullptr;
        flag = false;
    }
};

Node nodes[MAXN];

int findMaxChildren(int numOfNode) {
    int index = -1;
    for (int i = 1; i <= numOfNode; i++) {
        if (nodes[i].flag) continue;
        if (index == -1) index = i;
        else if (nodes[index].numOfChildren < nodes[i].numOfChildren)  index = i;
    }

    return index;
}


void addEdge(int a, int b) {
    nodes[a].numOfChildren++;
    if (nodes[a].children == nullptr) nodes[a].children = new Index(b);
    else {
        Index *curIdx = nodes[a].children;
        while (curIdx->next != nullptr) curIdx = curIdx->next;
        curIdx->next = new Index(b);
        curIdx->next->pre = curIdx;
    }
}

int main() {
    int numOfNode, numOfEdge;
    int a, b;
    std::cin >> numOfNode >> numOfEdge;
    for (int i = 1; i <= numOfEdge; i++) {
        //nodes[i] = Node(i);
        std::cin >> a >> b;
        addEdge(a, b);
        addEdge(b, a);
    }
    int maxMatch = 0;

    //for (int i = 1; i <= numOfNode; i++ ) std::cout << nodes[i].numOfChildren << " ";
    //std::cout << "---" << std::endl;

    while (1) {
        int i = findMaxChildren(numOfNode);
        if (i == -1) break;

        //std::cout << "select " << i << std::endl;

        maxMatch++;
        nodes[i].flag = true;

        Index *curIdx = nodes[i].children;
        while (curIdx != nullptr) {
            if (nodes[curIdx->index].flag == false) {
                nodes[curIdx->index].flag = true;
                nodes[curIdx->index].numOfChildren = 0;
            }
            curIdx = curIdx->next;
        }

    }

    std::cout << maxMatch << std::endl;
    std::cout << numOfNode - maxMatch << std::endl;
    return 0;
}

//input
5 4
3 2
1 3
5 4
1 5
```

[back](./)

