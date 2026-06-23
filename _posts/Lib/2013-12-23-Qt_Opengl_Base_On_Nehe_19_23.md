---
layout: default
title: Qt下使用OpenGL-根据NeHe的教程改写的(19-23)
categories:
- Lib
tags:
- Lib
---
//Description: Qt下使用OpenGL-根据NeHe的教程改写的(19-23)

//Create Date: 2013-12-23 16:02:39

//Author: channy

[toc]

# 第十九课：粒子系统

在第六课纹理映射的基础上添加代码.

nehewidget.h

```c++
#ifndef NEHEWIDGET_H
#define NEHEWIDGET_H

#include <QtOpenGL>
//#include "ui_nehewidget.h"

#include <qgl.h>

#define    MAX_PARTICLES    1000        // 定义最大的粒子数

struct particles  
{
	bool    active;                    // 是否激活
	float    life;                    // 粒子生命
	float    fade;                    // 衰减速度
	float r,g,b;
	float x,y,z;
	float xi,yi,zi;
	float xg,yg,zg;
};

class nehewidget : public QGLWidget
{
	Q_OBJECT

public:
	nehewidget(QWidget *parent = 0,bool fs=false);
	~nehewidget();

protected:

	void initializeGL();
	void paintGL();
	void resizeGL(int w,int h);
	void loadGLTextures();

	void keyPressEvent(QKeyEvent *e);

	bool fullscreen;
	GLfloat xrot,yrot,zrot;
	GLuint texture[1];

	bool    rainbow;            // 是否为彩虹模式
	float    slowdown;            // 减速粒子
	float    xspeed;                // X方向的速度
	float    yspeed;                // Y方向的速度
	float    zoom;            // 沿Z轴缩放
	GLuint    loop;                // 循环变量
	GLuint    col;                // 当前的颜色
	GLuint    delay;                // 彩虹效果延迟

	particles particle[MAX_PARTICLES];
};

#endif // NEHEWIDGET_H
```

nehewidget.cpp

```c++
#include "nehewidget.h"

#include <gl/GL.h>
#include <gl/GLU.h>
#include <gl/glaux.h>

#include <QKeyEvent>
#include <QImage>
#include <QColor>

static GLfloat colors[12][3]=                // 彩虹颜色
{
	{1.0f,0.5f,0.5f},{1.0f,0.75f,0.5f},{1.0f,1.0f,0.5f},{0.75f,1.0f,0.5f},
	{0.5f,1.0f,0.5f},{0.5f,1.0f,0.75f},{0.5f,1.0f,1.0f},{0.5f,0.75f,1.0f},
	{0.5f,0.5f,1.0f},{0.75f,0.5f,1.0f},{1.0f,0.5f,1.0f},{1.0f,0.5f,0.75f}
};


nehewidget::nehewidget(QWidget *parent,bool fs)
	: QGLWidget(parent)
{
	slowdown=2.0f;
	zoom=-1.0f;

	fullscreen=fs;
	setGeometry(100,100,640,480);
	//	setCaption("OpenGL window"); //这个函数，不支持了吧？
	setWindowTitle("OpenGL Window");
	if(fullscreen) showFullScreen();
}

nehewidget::~nehewidget()
{

}

void nehewidget::initializeGL()
{
	loadGLTextures();
	glEnable(GL_TEXTURE_2D);

	glShadeModel(GL_SMOOTH);
	glClearColor(0,0,0,0);
	glClearDepth(1.0);
	glEnable(GL_DEPTH_TEST);

	glDisable(GL_DEPTH_TEST);
	 for (loop=0;loop<MAX_PARTICLES;loop++)  {
/*
		 particle[loop].x=0.0f;
		 particle[loop].y=0.0f;
		 particle[loop].z=0.0f;*/

		 particle[loop].active=true;                    // 使所有的粒子为激活状态
		 particle[loop].life=1.0f;                    // 所有的粒子生命值为最大
		 particle[loop].fade=float(rand()%100)/1000.0f
+0.003f;        // 随机生成衰减速率
		 particle[loop].r=colors[loop*(12/MAX_PARTICLES)][0];        // 粒子的红色颜色
		 particle[loop].g=colors[loop*(12/MAX_PARTICLES)][1];        // 粒子的绿色颜色
		 particle[loop].b=colors[loop*(12/MAX_PARTICLES)][2];        // 粒子的蓝色颜色
		 particle[loop].xi=float((rand()%50)-26.0f)*10.0f;        // 随机生成X轴方向速度
		 particle[loop].yi=float((rand()%50)-25.0f)*10.0f;        // 随机生成Y轴方向速度
		 particle[loop].zi=float((rand()%50)-25.0f)*10.0f;        // 随机生成Z轴方向速度
		 particle[loop].xg=0.0f;                        // 设置X轴方向加速度为0
		 particle[loop].yg=-0.8f;                        //  设置Y轴方向加速度为-0.8
		 particle[loop].zg=0.0f;                        //  设置Z轴方向加速度为0
	 }
	glDepthFunc(GL_LEQUAL);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);
}

void nehewidget::paintGL()
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	for (loop=0;loop<MAX_PARTICLES;loop++)  {
		if (particle[loop].active) {
			float x=particle[loop].x;
			float y=particle[loop].y;                // 返回Y轴的位置
			float z=particle[loop].z+zoom;            // 返回Z轴的位置
			glColor4f(particle[loop].r,particle[loop].g,particle[loop].b,particle[loop].life);
			glBegin(GL_TRIANGLE_STRIP);                // 绘制三角形带
			glTexCoord2d(1,1); glVertex3f(x+0.05f,y+0.05f,z); 
			glTexCoord2d(0,1); glVertex3f(x-0.05f,y+0.05f,z); 
			glTexCoord2d(1,0); glVertex3f(x+0.05f,y-0.05f,z); 
			glTexCoord2d(0,0); glVertex3f(x-0.05f,y-0.05f,z); 
			glEnd();

			particle[loop].x+=particle[loop].xi/(slowdown*1000);    // 更新X坐标的位置
			particle[loop].y+=particle[loop].yi/(slowdown*1000);    // 更新Y坐标的位置
			particle[loop].z+=particle[loop].zi/(slowdown*1000);    // 更新Z坐标的位置
			particle[loop].xi+=particle[loop].xg;            // 更新X轴方向速度大小
			particle[loop].yi+=particle[loop].yg;            // 更新Y轴方向速度大小
			particle[loop].zi+=particle[loop].zg;            // 更新Z轴方向速度大小
			particle[loop].life-=particle[loop].fade;        // 减少粒子的生命值
			if (particle[loop].life<0.0f)    {                // 如果粒子生命值小于0
				particle[loop].life=1.0f;                // 产生一个新的粒子
				particle[loop].fade=float(rand()%100)/1000.0f+0.003f;    // 随机生成衰减速率
				particle[loop].x=0.0f;                    // 新粒子出现在屏幕的中央
				particle[loop].y=0.0f;                    
				particle[loop].z=0.0f;
				particle[loop].xi=xspeed+float((rand()%60)-32.0f);    // 随机生成粒子速度
				particle[loop].yi=yspeed+float((rand()%60)-30.0f);    
				particle[loop].zi=float((rand()%60)-30.0f);     
				particle[loop].r=colors[col][0];            // 设置粒子颜色
				particle[loop].g=colors[col][1];            
				particle[loop].b=colors[col][2];        
			} 
		}
	}
}

void nehewidget::resizeGL(int w,int h)
{
	if(h==0) h=1;
	glViewport(0,0,(GLint)w,(GLint)h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	//下面这个函数在Qt和OpenGL新版本中都不支持了！先注释掉吧，以后不得不用时再想办法
	//	gluPerspective(45.0,(GLfloat)w/(GLfloat)h,0.1,100.0);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

void nehewidget::keyPressEvent(QKeyEvent *e)
{
	switch(e->key()) {
	case Qt::Key_F2:
		fullscreen=!fullscreen;
		if(fullscreen) showFullScreen();
		else {
			showNormal();
			setGeometry(0,0,640,480);
		}
		updateGL();
		break;
	case Qt::Key_Escape:
		close();
	}
}

void nehewidget::loadGLTextures()
{
	QImage tex,buf;
	if(!buf.load("./texture.bmp")) {
		qWarning("Please use single-color instead");
		QImage dummy(128,128,QImage::Format_RGB32);
		dummy.fill(Qt::red);
		buf=dummy;
	}
	tex=QGLWidget::convertToGLFormat(buf);
	glGenTextures(1,&texture[0]);
	glBindTexture(GL_TEXTURE_2D,texture[0]);
	glTexImage2D(GL_TEXTURE_2D,0,3,tex.width(),tex.height(),0,GL_RGB,GL_UNSIGNED_BYTE,tex.bits());
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
}
```

# 第二十课：蒙板

在第七课的代码基础上修改。

nehewidget.h

```c++
#ifndef NEHEWIDGET_H
#define NEHEWIDGET_H

#include <QtOpenGL/QGLWidget>
#include "ui_nehewidget.h"

class nehewidget : public QGLWidget
{
	Q_OBJECT

public:
	nehewidget(QWidget *parent = 0);
	~nehewidget();

protected:
	void initializeGL();
	void paintGL();
	void resizeGL(int w,int h);
	void loadGLTextures();

	bool masking;     // 是否使用“掩模”
	bool scene;      // 绘制那一个场景
	GLuint texture[3];     // 保存5个纹理标志
	GLuint loop;      // 循环变量

	GLfloat roll;      // 滚动纹理

};

#endif // NEHEWIDGET_H
```

nehewidget.cpp

```c++
#include "nehewidget.h"

nehewidget::nehewidget(QWidget *parent)
	: QGLWidget(parent)
{
	masking=TRUE;
	roll = 0;
	scene=true;
}

nehewidget::~nehewidget()
{

}

void nehewidget::initializeGL()
{
	loadGLTextures();
	glEnable(GL_TEXTURE_2D);

	glShadeModel(GL_SMOOTH);
	glClearColor(0,0,0,0);
	glClearDepth(1.0);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);
}

void nehewidget::paintGL()
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	glTranslatef(0.0f,0.0f,-1.0f); 
	glBindTexture(GL_TEXTURE_2D, texture[0]);    // 选择Logo纹理
	glBegin(GL_QUADS);       // 绘制纹理四边形
	glTexCoord2f(0.0f, -roll+0.0f); glVertex3f(-0.6f, -0.6f,  0.0f); 
	glTexCoord2f(3.0f, -roll+0.0f); glVertex3f( 0.6f, -0.6f,  0.0f); 
	glTexCoord2f(3.0f, -roll+3.0f); glVertex3f( 0.6f,  0.6f,  0.0f); 
	glTexCoord2f(0.0f, -roll+3.0f); glVertex3f(-0.6f,  0.6f,  0.0f); 
	glEnd();

	glEnable(GL_BLEND);       // 启用混合
	glDisable(GL_DEPTH_TEST);       // 禁用深度测试
	if(masking) {
		glBlendFunc(GL_DST_COLOR,GL_ZERO);
	}
	if(scene) {
		glTranslatef(0.0f,0.0f,-1.0f);     // 移入屏幕一个单位
		glRotatef(roll*360,0.0f,0.0f,1.0f);     // 沿Z轴旋转
		if(masking) {
			glBindTexture(GL_TEXTURE_2D, texture[1]);  // 选择第二个“掩模”纹理
			glBegin(GL_QUADS);     // 开始绘制四边形
			glTexCoord2f(0.0f, 0.0f); glVertex3f(-0.6f, -0.6f,  0.0f); 
			glTexCoord2f(1.0f, 0.0f); glVertex3f( 0.6f, -0.6f,  0.0f); 
			glTexCoord2f(1.0f, 1.0f); glVertex3f( 0.6f,  0.6f,  0.0f); 
			glTexCoord2f(0.0f, 1.0f); glVertex3f(-0.6f,  0.6f,  0.0f); 
			glEnd();     
		}
		glBlendFunc(GL_ONE, GL_ONE);    // 把纹理2复制到屏幕
		glBindTexture(GL_TEXTURE_2D, texture[0]);   // 选择第二个纹理
		glBegin(GL_QUADS);      // 绘制四边形
		glTexCoord2f(0.0f, 0.0f); glVertex3f(-0.6f, -0.6f,  0.0f); 
		glTexCoord2f(1.0f, 0.0f); glVertex3f( 0.6f, -0.6f,  0.0f); 
		glTexCoord2f(1.0f, 1.0f); glVertex3f( 0.6f,  0.6f,  0.0f); 
		glTexCoord2f(0.0f, 1.0f); glVertex3f(-0.6f,  0.6f,  0.0f); 
		glEnd();
	}
	else {
		if(masking) {
			glBindTexture(GL_TEXTURE_2D, texture[1]);  // 选择第一个“掩模”纹理
			glBegin(GL_QUADS);     // 开始绘制四边形
			glTexCoord2f(roll+0.0f, 0.0f); glVertex3f(-0.6f, -0.6f,  0.0f); 
			glTexCoord2f(roll+4.0f, 0.0f); glVertex3f( 0.6f, -0.6f,  0.0f); 
			glTexCoord2f(roll+4.0f, 4.0f); glVertex3f( 0.6f,  0.6f,  0.0f); 
			glTexCoord2f(roll+0.0f, 4.0f); glVertex3f(-0.6f,  0.6f,  0.0f); 
			glEnd();     
		}
		glBlendFunc(GL_ONE, GL_ONE);     // 把纹理1复制到屏幕
		glBindTexture(GL_TEXTURE_2D, texture[2]);    // 选择第一个纹理
		glBegin(GL_QUADS);       // 开始绘制四边形
		glTexCoord2f(roll+0.0f, 0.0f); glVertex3f(-0.6f, -0.6f,  0.0f); 
		glTexCoord2f(roll+4.0f, 0.0f); glVertex3f( 0.6f, -0.6f,  0.0f); 
		glTexCoord2f(roll+4.0f, 4.0f); glVertex3f( 0.6f,  0.6f,  0.0f); 
		glTexCoord2f(roll+0.0f, 4.0f); glVertex3f(-0.6f,  0.6f,  0.0f); 
		glEnd();   

	}
	glEnable(GL_DEPTH_TEST);       // 启用深度测试
	glDisable(GL_BLEND);       // 禁用混合
	roll+=0.002f;        // 增加纹理滚动变量
	if(roll>1.0f) roll-=1.0f;
}

void nehewidget::resizeGL(int w,int h)
{
	if(h==0) h=1;
	glViewport(0,0,(GLint)w,(GLint)h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	//下面这个函数在Qt和OpenGL新版本中都不支持了！先注释掉吧，以后不得不用时再想办法
	//	gluPerspective(45.0,(GLfloat)w/(GLfloat)h,0.1,100.0);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

void nehewidget::loadGLTextures()
{
	QImage tex,buf;
	if(!buf.load("texture.bmp")) {
		qWarning("Please use single-color instead");
		QImage dummy(128,128,QImage::Format_RGB32);
		dummy.fill(Qt::red);
		buf=dummy;
	}
	tex=QGLWidget::convertToGLFormat(buf);
	glGenTextures(3,&texture[0]);
	glBindTexture(GL_TEXTURE_2D,texture[0]);
	glTexImage2D(GL_TEXTURE_2D,0,3,tex.width(),tex.height(),0,GL_RGB,GL_UNSIGNED_BYTE,tex.bits());
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

	glBindTexture(GL_TEXTURE_2D,texture[1]);
	glTexImage2D(GL_TEXTURE_2D,0,3,tex.width(),tex.height(),0,GL_RGB,GL_UNSIGNED_BYTE,tex.bits());
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

	glBindTexture(GL_TEXTURE_2D,texture[2]);
	glTexImage2D(GL_TEXTURE_2D,0,3,tex.width(),tex.height(),0,GL_RGB,GL_UNSIGNED_BYTE,tex.bits());
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

//	gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGB,tex.width(),tex.height(),GL_RGBA,GL_UNSIGNED_BYTE,tex.bits());
}
```

# 第二十一课：线，反走样，计时，正投影和简单的声音

这一课用Qt的话有些大改动，先占个坑，改完了再贴代码。

nehewidget.h

nehewidget.cpp

# 第二十二课：

同上一课，改动较大，先占坑……

nehewidget.h

nehewidget.cpp

# 第二十三课：球面映射

在第十八课二次几何体代码的基础上修改。

nehewidget.h

```c++
#ifndef NEHEWIDGET_H
#define NEHEWIDGET_H

#include <QtOpenGL/QGLWidget>
//#include "ui_nehewidget.h"
#include <gl/GLU.h>
#include <gl/GL.h>
#include <gl/glaux.h>

class nehewidget : public QGLWidget
{
	Q_OBJECT

public:
	nehewidget(QWidget *parent = 0,bool fs=false);
	~nehewidget();

protected:
	void initializeGL();
	void paintGL();
	void resizeGL(int w,int h);

	void glDrawCube();
		
	void keyPressEvent(QKeyEvent *e);
	void loadGLTextures();
	bool fullscreen;
	GLfloat xrot,yrot,zrot;
	GLfloat zoom,xspeed,yspeed;
	GLuint texture[3],filter;

	bool light;

	int    part1;                        // 圆盘的起始角度
	int    part2;                        // 圆盘的结束角度
	int    p1;                        // 增量1
	int    p2;                        // 增量1
	GLUquadricObj *quadratic;                    // 二次几何体
	GLuint  object;                        // 二次几何体标示符

};

#endif // NEHEWIDGET_H
```

nehewidget.cpp

```c++
#include "nehewidget.h"

#include <QKeyEvent>

GLfloat lightAmbient[4]={0.5,0.5,0.5,1.0};
GLfloat lightDiffuse[4]={1.0,1.0,1.0,1.0};
GLfloat lightPosition[4]={0.0,0.0,0.0,1.0};

nehewidget::nehewidget(QWidget *parent,bool fs)
	: QGLWidget(parent)
{
	xrot=0.0;
	yrot=0.0;
	zrot=0.0;
	zoom=0.0;
	xspeed=yspeed=2.0;
	filter=0;
	light=false;

	p1 = 0;
	p2 = 1;
	object = 0;

	fullscreen=fs;
	setGeometry(100,100,640,480);
//	setCaption("OpenGL window"); //这个函数，不支持了吧？
	setWindowTitle("OpenGL Window");
	if(fullscreen) showFullScreen();
}

nehewidget::~nehewidget()
{
	gluDeleteQuadric(quadratic);
}

void nehewidget::initializeGL()
{
	loadGLTextures();
	glEnable(GL_TEXTURE_2D);

	glShadeModel(GL_SMOOTH);
	glClearColor(0,0,0,0);
	glClearDepth(1.0);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);

	glLightfv(GL_LIGHT1,GL_AMBIENT,lightAmbient);
	glLightfv(GL_LIGHT1,GL_DIFFUSE,lightDiffuse);
	glLightfv(GL_LIGHT1,GL_POSITION,lightPosition);
	glEnable(GL_LIGHT1);

	quadratic = gluNewQuadric();
	gluQuadricNormals(quadratic,GLU_SMOOTH);
	gluQuadricTexture(quadratic,GL_TRUE);

	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);   // 设置s方向的纹理自动生成
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);   // 设置t方向的纹理自动生成

}

void nehewidget::paintGL()
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	glTranslatef(0.0,0.0,zoom);
	glEnable(GL_TEXTURE_GEN_S);      // 自动生成s方向纹理坐标
	glEnable(GL_TEXTURE_GEN_T);      // 自动生成t方向纹理坐标
	glBindTexture(GL_TEXTURE_2D,texture[filter]);
	glPushMatrix();
	glRotatef(xrot,1.0,0.0,0.0);
	glRotatef(yrot,0.0,1.0,0.0);

	switch(object) {
	case 0:
		glDrawCube();
		break;
	case 1:
		glTranslatef(0.0f,0.0f,-1.5f);
		gluCylinder(quadratic,1.0f,1.0f,3.0f,32,32);
		break;
	case 2:
		gluSphere(quadratic,1.3f,32,32);
		break;
	case 3:
		glTranslatef(0.0f,0.0f,-1.5f);
		gluCylinder(quadratic,1.0f,0.0f,3.0f,32,32);
		break;
	default:
		break;
	}
	glPopMatrix();
	glDisable(GL_TEXTURE_GEN_S);      // 禁止自动生成纹理坐标
	glDisable(GL_TEXTURE_GEN_T);     

	xrot+=xspeed;
	yrot+=yspeed;
}

void nehewidget::resizeGL(int w,int h)
{
	if(h==0) h=1;
	glViewport(0,0,(GLint)w,(GLint)h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	//下面这个函数在Qt和OpenGL新版本中都不支持了！先注释掉吧，以后不得不用时再想办法
	//	gluPerspective(45.0,(GLfloat)w/(GLfloat)h,0.1,100.0);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

void nehewidget::keyPressEvent(QKeyEvent *e)
{
	switch(e->key()) {
	case Qt::Key_F2:
		fullscreen=!fullscreen;
		if(fullscreen) showFullScreen();
		else {
			showNormal();
			setGeometry(0,0,640,480);
		}
		updateGL();
		break;
	case Qt::Key_Space:
		object++;
		if (object > 3) object = 0;
		updateGL();
		break;
	case Qt::Key_Escape:
		close();
	}
}

void nehewidget::loadGLTextures()
{
	QImage tex,buf;
	if(!buf.load("./kaola.jpg")) {
		qWarning("Please use single-color instead");
		QImage dummy(128,128,QImage::Format_RGB32);
		dummy.fill(Qt::red);
		buf=dummy;
	}
	tex=QGLWidget::convertToGLFormat(buf);
	glGenTextures(3,&texture[0]);
	glBindTexture(GL_TEXTURE_2D,texture[0]);
	glTexImage2D(GL_TEXTURE_2D,0,3,tex.width(),tex.height(),0,GL_RGB,GL_UNSIGNED_BYTE,tex.bits());
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

	glBindTexture(GL_TEXTURE_2D,texture[1]);
	glTexImage2D(GL_TEXTURE_2D,0,3,tex.width(),tex.height(),0,GL_RGB,GL_UNSIGNED_BYTE,tex.bits());
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

	glBindTexture(GL_TEXTURE_2D,texture[2]);
	//	glTexImage2D(GL_TEXTURE_2D,0,3,tex.width(),tex.height(),0,GL_RGB,GL_UNSIGNED_BYTE,tex.bits());
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

	gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGB,tex.width(),tex.height(),GL_RGBA,GL_UNSIGNED_BYTE,tex.bits());
}

void nehewidget::glDrawCube()
{
	glBegin(GL_QUADS);
	glNormal3f(0.0,0.0,1.0);
	glTexCoord2f(0.0,0.0);glVertex3f(-0.2,-0.2,0.2);
	glTexCoord2f(1.0,0.0);glVertex3f(0.2,-0.2,0.2);
	glTexCoord2f(1.0,1.0);glVertex3f(0.2,0.2,0.2);
	glTexCoord2f(0.0,1.0);glVertex3f(-0.2,0.2,0.2);

	glNormal3f(0.0,0.0,-1.0);
	glTexCoord2f(1.0,0.0);glVertex3f(-0.2,-0.2,-0.2);
	glTexCoord2f(1.0,1.0);glVertex3f(-0.2,0.2,-0.2);
	glTexCoord2f(0.0,1.0);glVertex3f(0.2,0.2,-0.2);
	glTexCoord2f(0.0,0.0);glVertex3f(0.2,-0.2,-0.2);

	glNormal3f(0.0,1.0,0.0);
	glTexCoord2f(0.0,1.0);glVertex3f(-0.2,0.2,-0.2);
	glTexCoord2f(0.0,0.0);glVertex3f(-0.2,0.2,0.2);
	glTexCoord2f(1.0,0.0);glVertex3f(0.2,0.2,0.2);
	glTexCoord2f(1.0,1.0);glVertex3f(0.2,0.2,-0.2);

	glNormal3f(0.0,-1.0,0.0);
	glTexCoord2f(1.0,1.0);glVertex3f(-0.2,-0.2,-0.2);
	glTexCoord2f(0.0,1.0);glVertex3f(0.2,-0.2,-0.2);
	glTexCoord2f(0.0,0.0);glVertex3f(0.2,-0.2,-0.2);
	glTexCoord2f(1.0,0.0);glVertex3f(-0.2,-0.2,0.2);

	glNormal3f(1.0,0.0,0.0);
	glTexCoord2f(1.0,0.0);glVertex3f(0.2,-0.2,-0.2);
	glTexCoord2f(1.0,1.0);glVertex3f(0.2,0.2,-0.2);
	glTexCoord2f(0.0,1.0);glVertex3f(0.2,0.2,0.2);
	glTexCoord2f(0.0,0.0);glVertex3f(0.2,-0.2,0.2);

	glNormal3f(-1.0,0.0,0.0);
	glTexCoord2f(0.0,0.0);glVertex3f(-0.2,-0.2,-0.2);
	glTexCoord2f(1.0,0.0);glVertex3f(-0.2,-0.2,0.2);
	glTexCoord2f(1.0,1.0);glVertex3f(-0.2,0.2,0.2);
	glTexCoord2f(0.0,1.0);glVertex3f(-0.2,0.2,-0.2);

	glEnd();
}
```