---
layout: default
title: Path Planning 路径规划
categories:
- Algorithm
tags:
- Game
---
//Description: 现有的路径规划算法，一般分为两大类：基于搜索的和基于采样的。基于搜索的比较入门的有DFS/BFS/Dijkstra/A*等，基于采样的比较入门的有RTT等。

//Create Date: 2023-02-28 20:40:39

//Author: channy

[toc]

# 概述  
路径规划算法，一般分为两大类：基于搜索的和基于采样的。  
```
// 以二维地图为例，设起点st，终点end，障碍物函数block()。
struct Point {
    int x, y;
};
```

# 基于搜索的路径规划算法
## DFS/BFS 深度优先算法/广度优先算法
DFS/BFS是OJ中常用的搜索算法。DFS可以看成是从可能的第1_1步走到可能的第n_1步，当第n+1_1步没有选择时，退回到第n步的另一种可能n_2，继续往前走直到达到目的。而BFS则是利用队列，把所有可能的第1步放入队列，再对队列里的每一个第1步（1_1, 1_2, ...) 把所有可能的第2步放入队列，以此类推，直到达到目的。  
```
bool DFS(Point &st) {
    if (st == end) return true;
    vector<Point> dir = {Point(-1, 0), Point(1, 0), Point(0, -1), Point(0, 1)};
    for (int i = 0; i < 4; ++i) {
        Point next = st + dir[i];
        if (block(next)) continue;
        bool res = DFS(next);
        if (res) return true;
    }
    return false;
}

bool BFS(Point &st) {
    if (st == end) return true;
    queue<Point> qu;
    qu.push(st);
    while (!qu.empty()) {
        Point cur = qu.front();
        qu.pop();
        if (cur == end) return true;
        for (int i = 0; i < 4; ++i) {
            Point next = cur + dir[i];
            if (block(next)) continue;
            qu.push(next);
        }
    }
    return false;
}
```
## Dijkstra算法
在BFS的基础上，在下一步的选择时优先选择当前走过的路径中代价最短的。当每一步的代价都相同时，退化成BFS。
```
// Cost(st, end)从st到end的代价函数
struct Point {
    int x, y;
    int cost;
}

bool Dijkstra(Point &st) {
    priority_queue<Point> qu;
    while (!qu.empty()) {
        Point cur = qu.front();
        qu.pop();
        if (cur == end) return true;
        for (int i = 0; i < 4; ++i) {
            Point next = cur + dir[i];
            if (block(next)) continue;
            next.cost = cur.cost + Cost(cur, cur + dir[i]);           
            qu.push(next);
        }
    }
    return false;
}
```
## 最佳优先算法
在BFS的基础上，在下一步的选择时优先选择当前位置到目的位置最近的路径。
```
```
## A*算法
结合了Dijstra和最佳优先算法。f = g + h。其中g(st, cur)为起始位置到当前位置的代价，h(cur, end)为当前位置到目的位置的代价。
## 双向A*算法
## Aaytime Repairing A*算法 (ARA*)
## Learning Real-time A*算法 (LRTA*)
## Real-time Adaptive A*算法 (RTAA*)
## Lifelong Planning A* (LPA*)
## Dynamic A*算法 (D*)
## Anytime D*

# 基于采样的路径规划算法
## RRT
## RRT-Connect
## RRT*
## Anytime RRT*
## Batch Informed Trees (BIT*)

# 参考资料
1. [路径规划的Python基本实现](https://github.com/zhm-real/PathPlanning)
