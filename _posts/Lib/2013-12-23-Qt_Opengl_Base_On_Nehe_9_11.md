---
layout: default
title: Qt下使用OpenGL-根据NeHe的教程改写的(9-11)
categories:
- Lib
tags:
- Lib
---
//Description: Qt下使用OpenGL-根据NeHe的教程改写的(9-11)

//Create Date: 2013-12-23 16:02:39

//Author: channy

[toc]

# 第九课：闪烁的星星

还是从第一课的代码上改合适点……

nehewidget.h 文件：

```c++
#ifndef NEHEWIDGET_H
#define NEHEWIDGET_H

#include <QtOpenGL/QGLWidget>
//#include "ui_nehewidget.h"

#include <qgl.h>

const GLuint num=50;
typedef struct {
	int r,g,b;
	GLfloat dist,angle;
}stars;

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

	void keyPressEvent(QKeyEvent *e);
	void loadGLTextures();
	void timerEvent(QTimerEvent *);

	bool fullscreen;
	GLfloat zoom;
	GLuint texture[1];
	GLfloat spin,tilt;
	GLuint loop;

	bool twinkle;
	stars star[num];
};

#endif // NEHEWIDGET_H
```

nehewidget.cpp 文件：

```c++
#include "nehewidget.h"

#include <gl/GLU.h>
#include <QKeyEvent>

nehewidget::nehewidget(QWidget *parent,bool fs)
	: QGLWidget(parent)
{
	zoom=-0.0;
	tilt=90.0;
	spin=0.0;
	loop=0;
	twinkle=false;

	fullscreen=fs;
	setGeometry(100,100,640,480);
//	setCaption("OpenGL window"); //这个函数，不支持了吧？
	setWindowTitle("OpenGL Window");
	if(fullscreen) showFullScreen();

	startTimer(5);
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

//	glBlendFunc(GL_SRC_ALPHA,GL_ONE);
//	glEnable(GL_BLEND);
	for(loop=0;loop<num;loop++) {
		star[loop].angle=0.0;
		star[loop].dist=((float)loop)/num*1.5;
		star[loop].r=rand()%256;
		star[loop].g=rand()%256;
		star[loop].b=rand()%256;
	}
}

void nehewidget::paintGL()
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glBindTexture(GL_TEXTURE_2D,texture[0]);
	for(loop=0;loop<num;loop++) {
		glLoadIdentity();

		glTranslatef(0.0,0.0,zoom);
		glRotatef(tilt,1.0,0.0,0.0);
		glRotatef(star[loop].angle,0.0,1.0,0.0);
		glTranslatef(star[loop].dist,0.0,0.0);
		glRotatef(-star[loop].angle,0.0,1.0,0.0);
		glRotatef(-tilt,1.0,0.0,0.0);

		if(twinkle) {
			glColor4ub(star[(num-loop)-1].r,star[(num-loop)-1].g,star[(num-loop)-1].b,255);
			glBegin(GL_QUADS);
			glTexCoord2f(0.0,0.0);glVertex3f(-0.01,-0.01,0.01);
			glTexCoord2f(1.0,0.0);glVertex3f(0.01,-0.01,0.01);
			glTexCoord2f(1.0,1.0);glVertex3f(0.01,0.01,0.01);
			glTexCoord2f(0.0,1.0);glVertex3f(-0.01,0.01,0.01);
			glEnd();
		}
		glRotatef(spin,0.0,0.0,1.0);
		glColor4ub(star[loop].r,star[loop].g,star[loop].b,255);
		glBegin(GL_QUADS);
		glTexCoord2f(0.0,0.0);glVertex3f(-0.01,-0.01,0.01);
		glTexCoord2f(1.0,0.0);glVertex3f(0.01,-0.01,0.01);
		glTexCoord2f(1.0,1.0);glVertex3f(0.01,0.01,0.01);
		glTexCoord2f(0.0,1.0);glVertex3f(-0.01,0.01,0.01);
		glEnd();

		spin+=0.01;
		star[loop].angle+=((float)loop)/num;
		star[loop].dist-=0.01;
		if(star[loop].dist<0.0) {
			star[loop].dist+=1.5;
			star[loop].r=rand()%256;
			star[loop].g=rand()%256;
			star[loop].b=rand()%256;
		}
	}
}

void nehewidget::timerEvent(QTimerEvent *)
{
	updateGL();
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
	case Qt::Key_T:
		twinkle=!twinkle;
		updateGL();
		break;
	case Qt::Key_PageUp:
		zoom-=0.2;
		updateGL();
		break;
	case Qt::Key_PageDown:
		zoom+=0.2;
		updateGL();
		break;
	case Qt::Key_Up:
		tilt-=0.5;
		updateGL();
		break;
	case Qt::Key_Down:
		tilt+=0.5;
		updateGL();
		break;
	case Qt::Key_F2:
		fullscreen=!fullscreen;
		if(fullscreen) showFullScreen();
		else {
			showNormal();
			setGeometry(100,100,640,480);
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
	if(!buf.load("texture.bmp")) {
		qWarning("Please use single-color instead");
		QImage dummy(128,128,QImage::Format_RGB32);
		dummy.fill(Qt::red);
		buf=dummy;
	}
	tex=QGLWidget::convertToGLFormat(buf);
	glGenTextures(1,&texture[0]);
	glBindTexture(GL_TEXTURE_2D,texture[0]);
	glTexImage2D(GL_TEXTURE_2D,0,3,tex.width(),tex.height(),0,GL_RGB,GL_UNSIGNED_BYTE,tex.bits());
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
}
```

# 第十课：漫游三维世界

貌似出来的效果和预想的不一样……哪里写错了？

nehewidget.h 文件：

```c++
#ifndef NEHEWIDGET_H
#define NEHEWIDGET_H

#include <QtOpenGL/QGLWidget>
//#include "ui_nehewidget.h"

#include <qgl.h>

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

	void keyPressEvent(QKeyEvent *e);
	void loadGLTextures();
	void setupworld();

	bool fullscreen;
	GLfloat xrot,yrot,zrot;
	GLfloat zoom;
	GLuint texture[3],filter;

	GLfloat lookupdown,walkbias,walkbiasangle;

	bool light;
	bool blend;
};

#endif // NEHEWIDGET_H
```

nehewidget.cpp 文件：

```c++
#include "nehewidget.h"

#include <gl/GLU.h>
#include <QKeyEvent>
#include <iostream>
#include <fstream>
#include <math.h>

GLfloat lightAmbient[4]={0.5,0.5,0.5,1.0};
GLfloat lightDiffuse[4]={1.0,1.0,1.0,1.0};
GLfloat lightPosition[4]={0.0,0.0,0.0,1.0};

typedef struct tagvertex {
	float x,y,z,u,v;
}VERTEX;
typedef struct tagtrangle {
	VERTEX vertex[3];
}TRIANGLE;
typedef struct tagsector {
	int numtriangles;
	TRIANGLE *triangles;
}SECTOR;
SECTOR sector1;
float heading=0.0,prover=0.0174532925f;

void nehewidget::setupworld()
{
	float x,y,z,u,v;
	int numtriangles;
	char line[255];
	std::ifstream file;
	file.open("World.txt");
	file.getline(line,250);
	file.getline(line,250);
	sscanf(line,"NUMPOLLIES %d",&numtriangles);
	sector1.triangles=new TRIANGLE[numtriangles];
	sector1.numtriangles=numtriangles;
	for(int loop=0;loop<numtriangles;loop++)
		for(int vert=0;vert<3;vert++) {
			file.getline(line,250);
			while(line[0]=='/'||line[0]=='\n') file.getline(line,250);
			sscanf(line,"%f %f %f %f %f",§or1.triangles[loop].vertex[vert].x,§or1.triangles[loop].vertex[vert].y,§or1.triangles[loop].vertex[vert].z,§or1.triangles[loop].vertex[vert].u,§or1.triangles[loop].vertex[vert].v);
//			sector1.triangles[loop].vertex->x/=2;
//			sector1.triangles[loop].vertex->y/=2;
//			sector1.triangles[loop].vertex->z/=2;
		}
	file.close();
}

nehewidget::nehewidget(QWidget *parent,bool fs)
	: QGLWidget(parent)
{
	xrot=0.0;
	yrot=0.0;
	zrot=0.0;
	zoom=0.0;
	filter=0;
	light=false;
	blend=false;

	lookupdown=0.0f;
	walkbias=0.0f;
	walkbiasangle=0.0f;

	//setupworld();

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
	glDepthFunc(GL_LEQUAL);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);

	glLightfv(GL_LIGHT1,GL_AMBIENT,lightAmbient);
	glLightfv(GL_LIGHT1,GL_DIFFUSE,lightDiffuse);
	glLightfv(GL_LIGHT1,GL_POSITION,lightPosition);
	glEnable(GL_LIGHT1);

	glColor4f(1.0,1.0,1.0,0.5);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE);

	setupworld();
}

void nehewidget::paintGL()
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	GLfloat xx,yy,zz,uu,vv;
	GLfloat sceneroty=360.0f-yrot;

	glRotatef(lookupdown,1.0,0.0,0.0);
	glRotatef(sceneroty,0.0,1.0,0.0);
	glTranslatef(-xrot,-walkbias-0.25f,-zrot);
	
	glBindTexture(GL_TEXTURE_2D,texture[filter]);
	for(int loop=0;loop<sector1.numtriangles;loop++) {
		glBegin(GL_TRIANGLES);
		glNormal3f(0.0,0.0,1.0);
		xx=sector1.triangles[loop].vertex[0].x;
		yy=sector1.triangles[loop].vertex[0].y;
		zz=sector1.triangles[loop].vertex[0].z;
		uu=sector1.triangles[loop].vertex[0].u;
		vv=sector1.triangles[loop].vertex[0].v;
		glTexCoord2f(uu,vv);glVertex3f(xx,yy,zz);

		xx=sector1.triangles[loop].vertex[1].x;
		yy=sector1.triangles[loop].vertex[1].y;
		zz=sector1.triangles[loop].vertex[1].z;
		uu=sector1.triangles[loop].vertex[1].u;
		vv=sector1.triangles[loop].vertex[1].v;
		glTexCoord2f(uu,vv);glVertex3f(xx,yy,zz);

		xx=sector1.triangles[loop].vertex[2].x;
		yy=sector1.triangles[loop].vertex[2].y;
		zz=sector1.triangles[loop].vertex[2].z;
		uu=sector1.triangles[loop].vertex[2].u;
		vv=sector1.triangles[loop].vertex[2].v;
		glTexCoord2f(uu,vv);glVertex3f(xx,yy,zz);
		
		glEnd();
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
	case Qt::Key_L:
		light=!light;
		if(!light) {
			glDisable(GL_LIGHTING);
		}
		else {
			glEnable(GL_LIGHTING);
		}
		updateGL();
		break;
	case Qt::Key_B:
		blend=!blend;
		if(blend) {
			glEnable(GL_BLEND);
			glDisable(GL_DEPTH_TEST);
		}
		else {
			glDisable(GL_BLEND);
			glEnable(GL_DEPTH_TEST);
		}
		updateGL();
		break;
	case Qt::Key_F:
		filter+=1;
		if(filter>2) {
			filter=0;
		}
		updateGL();
		break;
	case Qt::Key_PageUp:
		zoom-=0.2;
		lookupdown-=1.0f;
		updateGL();
		break;
	case Qt::Key_PageDown:
		zoom+=0.2;
		lookupdown+=1.0f;
		updateGL();
		break;
	case Qt::Key_Up:
		xrot-=(float)sin(heading*prover)*0.05f;
		zrot-=(float)cos(heading*prover)*0.05f;
		if(walkbiasangle>=359.0f) walkbiasangle=0.0f;
		else walkbiasangle+=10;
		walkbias=(float)sin(walkbiasangle*prover)/20.0f;
		updateGL();
		break;
	case Qt::Key_Down:
		xrot+=(float)sin(heading*prover)*0.05f;
		zrot+=(float)cos(heading*prover)*0.05f;
		if(walkbiasangle<=1.0f) walkbiasangle=359.0f;
		else walkbiasangle-=10;
		walkbias=(float)sin(walkbiasangle*prover)/20.0f;
		updateGL();
		break;
	case Qt::Key_Right:
		yrot-=1.0f;
		updateGL();
		break;
	case Qt::Key_Left:
		yrot+=1.0f;
		updateGL();
		break;
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
	if(!buf.load("Mud.bmp")) {
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
```

# 第十一课：红旗飘飘

可以从纹理映射那里的代码开始修改，最好还是从第一课的代码改起吧

nehewidget.h 文件：

```c++
#ifndef NEHEWIDGET_H
#define NEHEWIDGET_H

#include <QtOpenGL>
//#include "ui_nehewidget.h"

#include <qgl.h>

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
	void timerEvent(QTimerEvent *);

	void keyPressEvent(QKeyEvent *e);

	bool fullscreen;
	GLfloat xrot,yrot,zrot;
	GLuint texture[1];
	GLfloat hold;
	float points[45][45][3];
	int wigglecount;
};

#endif // NEHEWIDGET_H
```

nehewidget.cpp 文件：

```c++
#include "nehewidget.h"

#include <gl/GL.h>
#include <gl/GLU.h>

#include <QKeyEvent>
#include <QImage>
#include <QColor>

nehewidget::nehewidget(QWidget *parent,bool fs)
	: QGLWidget(parent)
{
	xrot=yrot=zrot=0.0;
	hold=0.0;
	wigglecount=0;

	fullscreen=fs;
	setGeometry(100,100,640,480);
//	setCaption("OpenGL window"); //这个函数，不支持了吧？
	setWindowTitle("OpenGL Window");
	if(fullscreen) showFullScreen();

	startTimer(5);
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

	glPolygonMode(GL_BACK,GL_FILL);
	glPolygonMode(GL_FRONT,GL_LINE);
	for(int x=0;x<45;x++)
		for(int y=0;y<45;y++) {
			points[x][y][0]=float((x/9.0)-4.5);
			points[x][y][1]=float((y/9.0)-4.5);
			points[x][y][2]=float(sin((((x/9.0)*40.0)/360.0)*3.1415926*2.0));
		}
}

void nehewidget::paintGL()
{
	int x,y;
	float fx,fy,fxb,fyb;

	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	glTranslatef(0.0,0.0,0.0);
	glRotatef(xrot,1.0,0.0,0.0);
	glRotatef(yrot,0.0,1.0,0.0);
	glRotatef(zrot,0.0,0.0,1.0);
	glBindTexture(GL_TEXTURE_2D,texture[0]);
	glBegin(GL_QUADS);

	for(x=0;x<44;x++) 
		for(y=0;y<44;y++) {
			fx=float(x)/44.0;
			fy=float(y)/44.0;
			fxb=float(x+1)/44.0;
			fyb=float(y+1)/44.0;
			glTexCoord2f(fx,fy);
			glVertex3f(points[x][y][0],points[x][y][1],points[x][y][2]);
			glTexCoord2f(fx,fyb);
			glVertex3f(points[x][y+1][0],points[x][y+1][1],points[x][y+1][2]);
			glTexCoord2f(fxb,fyb);
			glVertex3f(points[x+1][y+1][0],points[x+1][y+1][1],points[x+1][y+1][2]);
			glTexCoord2f(fxb,fy);
			glVertex3f(points[x+1][y][0],points[x+1][y][1],points[x+1][y][2]);
		}
	
	glEnd();

	if(wigglecount==2) {
		for(y=0;y<45;y++) {
			hold=points[0][y][2];
			for(x=0;x<45;x++) {
				points[x][y][2]=points[x+1][y][2];
			}
			points[44][y][2]=hold;
		}
		wigglecount=0;
	}
	wigglecount++;
	xrot+=0.3;
	yrot+=0.2;
	zrot+=0.4;
}

void nehewidget::timerEvent(QTimerEvent *)
{
	updateGL();
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
			setGeometry(100,100,640,480);
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
	if(!buf.load("texture.bmp")) {
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

[back](./)

