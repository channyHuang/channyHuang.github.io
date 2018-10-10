---
layout: default
---

//Author: channy

//Create Date: 2018-10-10 10:45:11

//Description: 之前做项目时保存的小小模板笔记

# Model_Code_Of_InputOutput

## 并行

### for循环并行化的几种声明形式

（尽管OpenMP可以方便地对for循环进行并行化，但并不是所有的for循环都可以进行并行化。以下几种情况不能进行并行化：

1. for循环中的循环变量必须是有符号整形。例如，for (unsigned int i = 0; i < 10; ++i){}会编译不通过；

2. for循环中比较操作符必须是<, <=, >, >=。例如for (int i = 0; i ！= 10; ++i){}会编译不通过；

3. for循环中的第三个表达式，必须是整数的加减，并且加减的值必须是一个循环不变量。例如for (int i = 0; i != 10; i = i + 1){}会编译不通过；感觉只能++i; i++; --i; 或i--；

4. 如果for循环中的比较操作为<或<=，那么循环变量只能增加；反之亦然。例如for (int i = 0; i != 10; --i)会编译不通过；

5. 循环必须是单入口、单出口，也就是说循环内部不允许能够达到循环以外的跳转语句，exit除外。异常的处理也必须在循环体内处理。例如：若循环体内的break或goto会跳转到循环体外，那么会编译不通过。
 ）
 
```c++
#include <iostream>  
#include <omp.h> // OpenMP编程需要包含的头文件  
  
int main()  
{  
//for循环并行化声明形式1  
#pragma omp parallel   
    {  
        std::cout << "OK" << std::endl;  
#pragma omp for   
        for (int i = 0; i < 10; ++i)  
        {  
            std::cout << i << std::endl;  
        }  
    }  
  
//for循环并行化声明形式2  
#pragma omp parallel for  
    for (int j = 0; j < 10; ++j)  
    {  
        std::cout << j << std::endl;  
    }  
    return 0;  
}  
```
 
## c/c++
### c++ 输入若干行
```c++
while (std::cin >> n) {
}
```

### c++重定向输入输出
```c++
std::ofstream ofs("factorResult.txt");
streambuf *oldbuf = cout.rdbuf();
cout.rdbuf(ofs.rdbuf());

cout.rdbuf(oldbuf);
```

### c++ cout 格式化输出
```c++
#include <iostream>
#include <iomanip>
using namespace std;
 
cout << std::fixed << std::setprecision(n) << result << endl;
```

### c/c++ 读写txt
```c++
%d int; %s string; %f float; %lf double
/* sscanf example */
#include <stdio.h>
 
int main ()
{
  char sentence []="Rudolph is 12 years old";
  char str [20];
  int i;
 
  sscanf (sentence,"%s %*s %d",str,&i);
  printf ("%s -> %d\n",str,i);
  
  return 0;
}
std::ofstream ofs("points.ply");
 ofs << "ply \n format ascii 1.0 \n element vertex " << currentDepth.rows * currentDepth.cols << " \n property float x \n property float y \n property float z \n property uchar diffuse_red \n property uchar diffuse_green \n property uchar diffuse_blue \n end_header" << std::endl;
 
 for (int x = 0; x < currentDepth.rows; x++) {
 for (int y = 0; y < currentDepth.cols; y++) {
 Eigen::Vector3d ptX = params.get3Dpoint(index, x, y, currentDepth.at<double>(x, y));
 
 ofs << ptX(0) << " " << ptX(1) << " " << ptX(2) << " ";
 ofs << (int)currentImg.at<cv::Vec3b>(x, y)[2] << " " << (int)currentImg.at<cv::Vec3b>(x, y)[1] << " " << (int)currentImg.at<cv::Vec3b>(x, y)[0] << std::endl;
 }
 }
 
 ofs.close();
int totalVertex = 0;
 char str[100];
 std::ifstream ifs(modelName);
 ifs >> str;
 while (strcmp(str, "vertex") != 0){
 ifs >> str;
 }
 ifs >> totalVertex;
 while (strcmp(str, "end_header") != 0) {
 ifs >> str;
 }
 
 std::string strs;
 int minn = 99999, maxn = 0;
 while (totalVertex--) {
 Eigen::Vector4d pX = Eigen::Vector4d::Ones(4, 1);
 for (int i = 0; i < 3; i++) {
 ifs >> pX(i, 0);
 }
 std::getline(ifs, strs);
 Eigen::Vector3d px = currentParam.getP() * pX;
 
 int y = px(0, 0) / px(2, 0);
 int x = px(1, 0) / px(2, 0);
 if (x >= 0 && x < currentImg.rows && y >= 0 && y < currentImg.cols) {
 depth.at<double>(x, y) = px(2, 0);
 
 minn = std::min(minn, (int)px(2, 0));
 maxn = std::max(maxn, (int)px(2, 0));
 }
 }
 ifs.close();
 ```
### split分割
```
#include <vector>
#include <string>
#include <iostream>
using namespace std;
 
vector<string> split(const string &s, const string &seperator){
  vector<string> result;
  typedef string::size_type string_size;
  string_size i = 0;
  
  while(i != s.size()){
    //找到字符串中首个不等于分隔符的字母；
    int flag = 0;
    while(i != s.size() && flag == 0){
      flag = 1;
      for(string_size x = 0; x < seperator.size(); ++x)
     if(s[i] == seperator[x]){
       ++i;
      　　flag = 0;
     　　 break;
     }
    }
    
    //找到又一个分隔符，将两个分隔符之间的字符串取出；
    flag = 0;
    string_size j = i;
    while(j != s.size() && flag == 0){
      for(string_size x = 0; x < seperator.size(); ++x)
     if(s[j] == seperator[x]){
      　　flag = 1;
     　　 break;
     }
      if(flag == 0) 
     ++j;
    }
    if(i != j){
      result.push_back(s.substr(i, j-i));
      i = j;
    }
  }
  return result;
}
 
int main(){
  string s = "a,b*c*d,e";
  vector<string> v = split(s, ",*"); //可按多个字符来分隔;
  for(vector<string>::size_type i = 0; i != v.size(); ++i)
    cout << v[i] << " ";
  cout << endl;
  //输出: a b c d
}

///
void SplitString(const std::string& s, std::vector<std::string>& v, const std::string& c)
{
  std::string::size_type pos1, pos2;
  pos2 = s.find(c);
  pos1 = 0;
  while(std::string::npos != pos2)
  {
    v.push_back(s.substr(pos1, pos2-pos1));
 
    pos1 = pos2 + c.size();
    pos2 = s.find(c, pos1);
  }
  if(pos1 != s.length())
    v.push_back(s.substr(pos1));
}
 
///
#include <string.h>
#include <stdio.h>
 
int main(){
  char s[] = "a,b*c,d";
  const char *sep = ",*"; //可按多个字符来分割
  char *p;
  p = strtok(s, sep);
  while(p){
    printf("%s ", p);
    p = strtok(NULL, sep);
  }
  printf("\n");
  return 0;
}
//输出: a b c d
 
///
#include <boost/algorithm/string.hpp>
#include <iostream>
#include <string>
#include <vector>
 
using namespace std;
using namespace boost;
 
void print( vector <string> & v )
{
  for (size_t n = 0; n < v.size(); n++)
    cout << "\"" << v[ n ] << "\"\n";
  cout << endl;
}
 
int main()
{
  string s = "a,b, c ,,e,f,";
  vector <string> fields;
 
  cout << "Original = \"" << s << "\"\n\n";
 
  cout << "Split on \',\' only\n";
  split( fields, s, is_any_of( "," ) );
  print( fields );
 
  cout << "Split on \" ,\"\n";
  split( fields, s, is_any_of( " ," ) );
  print( fields );
 
  cout << "Split on \" ,\" and elide delimiters\n"; 
  split( fields, s, is_any_of( " ," ), token_compress_on );
  print( fields );
 
  return 0;
}
``` 
 
 
## Matlab的输入输出
### 编译c

```matlab
mex ***.c
```

### 读取网格模型或大型数据
```matlab
%%
function [mesh] = readMesh(filename) 
    if ~exist(filename)
        error(['File ' filename 'does not exist']);
    end
    
    cachepath = [filename '.cache'];
    
    if exist(cachepath)
        S = load(cachepath, '-mat');
        mesh = S.mesh;
        if 1 %version
            fprintf('[readMesh] loaded cached mesh %s successfully\n', filename);
            return;
        else 
            delete(cachepath);
            clear mesh;
        end
    end
    
    
    %read mesh normally
end
```

### 添加工具箱
```matlab
addpath(getpath('path of toolbox'))
%Example:
addpath(genpath('D:\MATLAB\R2014b\toolbox\vision'));
```

### matlab 写入txt
```matlab
    path = 'E:/points.txt';
    fin = fopen(path, 'wt');
    fprintf(fin, ['ply \n format ascii 1.0 \n element face 0 \n property list uchar int vertex_indices \n element vertex' int2str(size(pts, 2)) '\n property float x \n property float y \n property float z \n property uchar diffuse_red \n property uchar diffuse_green \n property uchar diffuse_blue \n end_header']);
    for i = 1:size(pts, 2)
        fprintf(fin, '%f %f %f %d %d %d\n', pts(1, i), pts(2, i), pts(3, i), rgbs(1,i), rgbs(2,i), rgbs(3,i));
    end
    fclose(fin);
num2str(k1,'%03d')
```

### matlab 写矩阵入txt
```matlab
points = rand(3, 100);
fin = fopen('test.txt', 'w');
fprintf(fin, '%f %f %f\n', points(1,:), points(2,:), points(3,:));
```

### matlab 读取txt
txt格式样例：
```matlab
cam_pos      = [91, 465, -292]';
cam_dir      = [0.0496855, -0.285692, 0.957033]';
cam_up       = [0.00725319, 0.958294, 0.285692]';
cam_lookat   = [0, 0, 1]';
cam_sky      = [0, 1, 0]';
cam_right    = [1.32832, 0.00964677, -0.0660817]';
cam_fpoint   = [0, 0, 10]';
cam_angle    = 90;
```
读取和显示坐标系：
```matlab
%show dtam data
function showcamera()
   path = 'E:\thirdLib\opendtam_cross_platform-master\build\Trajectory_30_seconds';
   txtfiles = dir([path '\*.txt']); 
   filenum = length(txtfiles);
   if (filenum > 10) 
       filenum = 10;
   end
   for i = 1:filenum
       txtfile = [path '\' txtfiles(i).name];
       fin = fopen(txtfile);
       while(fin)
           line = fgetl(fin);
           switch(line(5))
               case 'p'
                   r = sscanf(line, '%*s = [%f, %f, %f]');
                   R(:,:,i) = rodrigues(r);
               case 'd'
                   t(:,:,i) = sscanf(line, '%*s = [%f, %f, %f]');
                   break;
               otherwise
           end
       end
       fclose(fin);
   end
   
   draw(R, t);
   
end
 
function draw(R, t)
    axis = [0, 0, 0; 1, 0, 0; 0, 1, 0; 0, 0, 1];
    drawsingle(axis);
    for i = 1:size(R, 3)
        naxis = (axis + [t(:, :, i)';t(:, :, i)';t(:, :, i)';t(:, :, i)'])*R(:, :, i);
        drawsingle(naxis);
    end
end
 
function drawsingle(axis)
    hold on;
    line([axis(1, 1), axis(2, 1)], [axis(1, 2), axis(2, 2)],[axis(1, 3), axis(2, 3)], 'Color', 'r');
    view(3);
    line([axis(1, 1), axis(3, 1)], [axis(1, 2), axis(3, 2)],[axis(1, 3), axis(3, 3)], 'Color', 'g');
    line([axis(1, 1), axis(4, 1)], [axis(1, 2), axis(4, 2)],[axis(1, 3), axis(4, 3)], 'Color', 'b');
end
```

## Document 文档模板
### cmake 
#### add dependency
main project:
```cmake
cmake_minimum_required (VERSION 2.8.11)
project (Project)
include_directories (Project)
add_subdirectory (Dependency)
add_executable (Project main.cpp)
target_link_libraries (Project Dependency)
```
dependency project:
```cmake
project (Dependency)
add_library (Dependency SomethingToCompile.cpp)
target_include_directories (Dependency PUBLIC .)
or change to:
include_directories (Project ${includedir})
target_include_directories (Dependency PUBLIC includedir)
```
#### set as startup project (cmake 3.6 or later)
```cmake
#set as startup project
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${target})
```
#### errors
could not find boost
************************
```cmake
set(CMAKE_PREFIX_PATH
 "E:/thirdLib/boost_1_56_0"
)
set(BOOST_DIR "E:/thirdLib/boost_1_56_0")
set(BOOST_ROOT "E:/thirdLib/boost_1_56_0")
set(BOOST_INCLUDEDIR "E:/thirdLib/boost_1_56_0")
set(BOOST_LIBRARYDIR "E:/thirdLib/boost_1_56_0/lib64-msvc-12.0")
set(Boost_USE_STATIC_LIBS ON)
set(Boost_DEBUG ON)
 
find_package(Boost 1.56 COMPONENTS serialization system filesystem thread program_options date_time regex timer chrono)
if(NOT Boost_SERIALIZATION_LIBRARY)
  message(FATAL_ERROR "Missing required Boost components >= v1.56, please install/upgrade Boost or configure your search paths.")
endif()
...
```
CMake Error at CMakeLists.txt:18 (find_package):

  Found package configuration file:

    D:/useAsE/thirdLib/opencv/build/OpenCVConfig.cmake

  but it set OpenCV_FOUND to FALSE so package "OpenCV" is considered to be
  NOT FOUND.

opencv的库文件和当前cmake选择的vs不一致
#### template
```
cmake_minimum_required(VERSION 3.0.0)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ")#-O0 -g -ggdb -fpermissive
 
set(target projectName)
 
set(CMAKE_PREFIX_PATH 
 "E:/thirdLib/OpenCV/opencv/build"
 "D:/Qt/Qt5.4.1/5.4/msvc2013_64_opengl"
 )
set(Eigen_DIR "E:/thirdLib/eigen-3.3.2") 
set(BOOST_INCLUDE_DIR "E:/thirdLib/boost_1_56_0")
set(BOOST_LIBRARY_DIR "E:/thirdLib/boost_1_56_0/lib64-msvc-12.0") 
set(PCL_INCLUDE_DIR "E:/thirdLib/PCL_1.7.2/include/pcl-1.7")
set(PCL_LIB_DIR "E:/thirdLib/PCL_1.7.2/lib")
set(VTK_DIR "E:/thirdLib/VTK-7.0.0.rc1")
set(VTK_INCLUDE_DIR "E:/thirdLib/PCL_1.7.2/3rdParty/VTK/include/vtk-6.2")
 
project(${target})
find_package(CUDA REQUIRED)
find_package(OpenCV REQUIRED)
find_package(Qt5Core REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5Widgets REQUIRED)
 
file (GLOB HEADERS "*.h" "*.hpp")
file (GLOB SOURCES "*.cu" "*.c" "*.cpp")
 
include_directories(${target}
 ${CUDA_INCLUDE_DIRS}
 ${OpenCV_INCLUDE_DIRS}
 ${PROJECT_SOURCE_DIR}/inc
 ${PROJECT_SOURCE_DIR}/common/inc
 ${PCL_INCLUDE_DIR}
 ${BOOST_INCLUDE_DIR}
 ${Eigen_DIR}
 )
link_directories(
 ${BOOST_LIBRARY_DIR}
 ${PCL_LIB_DIR}
 ) 
 
 
# Dont propogate host flags into CUDA environment.
set(CUDA_PROPAGATE_HOST_FLAGS off)
 
# Generate code for 2.0 and 3.0 CUDA compute architectures (TODO: Verify this works)
#set(CUDA_NVCC_FLAGS "-use_fast_math -gencode arch=compute_30,code=sm_30 -gencode arch=compute_20,code=sm_20" ) 
 
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS}; -gencode arch=compute_30,code=sm_30; -gencode arch=compute_35,code=sm_35; -gencode arch=compute_50,code=sm_50; --use_fast_math ;--restrict; ) 
 
cuda_add_executable(${target}
 ${HEADERS}
 ${SOURCES}
 )
 
target_link_libraries(${target}
 ${OpenCV_LIBS}
 Qt5::Core
 Qt5::Widgets
 Qt5::Gui
 ) 
```

### latex
写论文时用的latex模板

```latex
\documentclass[12pt, UTF8]{ctexart}
%\documentclass[12pt, UTF8]{ctexrep}
\usepackage{amsmath}
\usepackage{bibentry}
\usepackage{CJK}
\usepackage{fancyhdr} %页眉
\usepackage{float}
\usepackage{geometry}
\usepackage{graphicx}
\usepackage{longtable}
\usepackage{multirow}
\usepackage{pdfpages}
\usepackage{subfigure}
\usepackage{supertabular}
\usepackage{setspace} %行距
\usepackage[super,square]{natbib}
\usepackage{titlesec}
\usepackage{titletoc}
\usepackage[colorlinks, linkcolor=blue, citecolor=green]{hyperref}
\geometry{left=3.17 cm,right=3.17 cm,top=2.54 cm,bottom=2.54 cm}
\title{基于xxx数据xxxx}
\date{}
%>60page

\titleformat{\section}{\centering\Large\bfseries}{第 \arabic{section} 章}{1 em}{}
\titlecontents{section}[0pt]{ \addvspace{2pt}\filright}{\contentspush{\thecontentslabel\ }}{}{\titlerule*[8pt]{.}\contentspage}

\CTEXsetup[name={第,章},number={\arabic{section}}]{section}
\iffalse
\makeatletter
\@addtoreset{equation}{section}
\@addtoreset{figure}{section}
\@addtoreset{table}{section}
\makeatother
\fi

\renewcommand\listfigurename{\textbf{图目录}}
\renewcommand\listtablename{\textbf{表目录}}
\renewcommand\thefigure{ \thesection.\arabic{figure}}
\renewcommand\thetable{ \thesection.\arabic{table} }
\renewcommand\theequation{\thesection.\arabic{equation} }
%\renewcommand{\figurename}{}
%\renewcommand{\tablename}{}


\LARGE
\setlength{\baselineskip}{20pt}

\begin{document}
\pagestyle{plain}

\iffalse
\begin{titlepage}
\maketitle
\section*{版本控制}
\begin{longtable}{c|c|c}
\hline
版本号 & 内容 & 最后修改时间 \\
\hline
v2.0 & 初稿，并增加实验结果 & 2016/12/18 \\
\hline
v3.0 & 修改模型形变过程，同时修改实验结果，主要改动5-7章的描述 & 2017/01/04 \\
\hline
v4.0 & 修改了部分插图，增加多组数据的实验结果及对比，及IMU部分说明 & 2017/01/05 \\
\hline
v5.0 & 根据反馈意见进行修改 & 2017/01/15 \\
\hline
\end{longtable}
\end{titlepage}
\fi

\newpage
\includepdf[pages=-]{faceWithName.pdf}

\newpage
\pagestyle{fancy}{
\lhead{浙江大学硕士学位论文}
\rhead{\rightmark }
%\rhead{\sectionmark}
}
\renewcommand{\sectionmark}[1]{\markright {第 \arabic{section} 章 \quad #1}{}}
%\renewcommand{\sectionmark}[1]{\markright {第 \arabic{section} 章}{}}

\pagenumbering{roman}
\section*{摘要}
\rhead{摘要}
\addcontentsline{toc}{section}{摘要}


\textbf{Key words:} 3D reconstruction, IMU and vision combination, model repair

\newpage
\rhead{\rightmark }
\pagenumbering{Roman}
\tableofcontents

\newpage
\rhead{图目录}
\listoffigures

\newpage
\rhead{表目录}
\listoftables

\newpage
\rhead{\rightmark }
\pagenumbering{arabic}
\section{绪论}



\section{概述}
\subsection{环境要求}
标配：
操作系统：windows 7, x64 bit
开发环境：visual studio 2013, 用x86编译运行（CGAL）
第三方库：
gtsam 3.2.1 (不支持boost 1.58及以上版本)
Boost 1.56
Qt 5.7.0
OpenCV 3
PCL 1.8.0
OpenGL
CGAL
\section{路径设置}


\newpage
\begin{thebibliography}{MM}
\addtolength{\itemsep}{-0.5em}
%relative work (section 1)
\bibitem{1} Shan Q, Curless B, Furukawa Y, et al. Occluding contours for multi-view stereo[C]//Computer Vision and Pattern Recognition (CVPR), 2014 IEEE Conference on. IEEE, 2014: 4002-4009.
\end{thebibliography}

\addcontentsline{toc}{section}{参考文献}

\end{document}
```


