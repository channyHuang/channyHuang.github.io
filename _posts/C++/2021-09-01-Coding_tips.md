---
layout: default
title: Coding_Tips.md
categories:
- C++
tags:
- C++
---
//Description: 

//Create Date: 2021-09-01 20:09:19

//Author: channy

# Coding Tips

## output file with time as name
```c++
	auto end = std::chrono::system_clock::now();
	std::time_t end_time = std::chrono::system_clock::to_time_t(end);
	std::string sTime = std::string(std::ctime(&end_time));
	//outputVoronoiDiagram(nFaceSize, nVerticesSize, faceVertices, facecolors, "rough_" + sTime.substr(11, 2) + sTime.substr(14, 2) + sTime.substr(17, 2) + ".ply");
```

## output the speed of network
```bat
@wmic NIC where "NetEnabled='true'" get "Name","Speed"

@pause
```


```python
import matplotlib.pyplot as plt
import numpy as np

def drawPowFunction():
    x = np.arange(0, 10, 0.1)
    y = x**(0.15)
    plt.title('powFunction')
    plt.plot(x, y)
    plt.show()
    
drawPowFunction();
```

## normal average

should be vn = sum(vi) / n;

not vn = (v1 + v2) / 2, vn += v3, vn /= 2...

##
