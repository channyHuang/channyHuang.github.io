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

## output model to obj/ply
### output model to ply
```c++
void outputToPlyFile(std::shared_ptr<VertexMesh> pmesh, const Vector3i& position) {
	if (pmesh->vertices_.size() <= 0 || pmesh->faces_.size() <= 0) {
		return;
	}
	std::string sFileName = "./mesh_" + std::to_string(position.x) + "_" + std::to_string(position.y) + "_" + std::to_string(position.z) + ".ply";
	Vector3 offset = Vector3(static_cast<Real>(position.x), static_cast<Real>(position.y), static_cast<Real>(position.z)) * 16.f;
	std::ofstream ofs(sFileName);
	ofs << "ply\nformat ascii 1.0\n";
	ofs << "element vertex " << pmesh->vertices_.size() << std::endl;
	ofs << "property float x\nproperty float y\nproperty float z\nproperty uchar red\nproperty uchar green\nproperty uchar blue\nproperty float nx\nproperty float ny\nproperty float nz\n";
	ofs << "element face " << pmesh->faces_.size() << std::endl;
	ofs << "property list uchar int vertex_index\nend_header\n";

	for (size_t i = 0; i < pmesh->vertices_.size(); i++) {
		Vector3i vcolor = { static_cast<int>((pmesh->sdfs_[i]) * 255), static_cast<int>((pmesh->sdfs_[i]) * 255), static_cast<int>((pmesh->sdfs_[i]) * 255) };
		ofs << pmesh->vertices_[i][0] + offset.x << " " << pmesh->vertices_[i][1] + offset.y << " " << pmesh->vertices_[i][2] + offset.z << " " 
			<< vcolor.x << " " << vcolor.y << " " << vcolor.z << " "
			<< pmesh->normals_[i].x << " " << pmesh->normals_[i].y << " " << pmesh->normals_[i].z << std::endl;
	}
	for (size_t i = 0; i < pmesh->faces_.size(); ++i) {
		ofs << "3 " << pmesh->faces_[i][0] << " " << pmesh->faces_[i][2] << " " << pmesh->faces_[i][1] << std::endl;
	}

	ofs.close();
}
```
