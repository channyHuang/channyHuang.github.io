---
layout: default
title: Qt下使用OpenGL-根据NeHe的教程改写的(6-8)
categories:
- Lib
tags:
- Lib
---
//Description: Qt下使用OpenGL-根据NeHe的教程改写的(6-8)

//Create Date: 2013-12-23 16:02:39

//Author: channy

[toc]

# 第六课：纹理映射

从这一课开始是在第一课的代码基础上增加代码的……

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

	void keyPressEvent(QKeyEvent *e);

	bool fullscreen;
	GLfloat xrot,yrot,zrot;
	GLuint texture[1];
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
}

void nehewidget::paintGL()
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	glTranslatef(0.0,0.0,0.0);
	glRotatef(xrot,1.0,0.0,0.0);
	glRotatef(yrot,0.0,1.0,0.0);
	glRotatef(zrot,0.0,0.0,1.0);
	glBindTexture(GL_TEXTURE_2D,texture[0]);
	glBegin(GL_QUADS);
	glTexCoord2f(0.0,0.0);glVertex3f(-0.2,-0.2,0.2);
	glTexCoord2f(1.0,0.0);glVertex3f(0.2,-0.2,0.2);
	glTexCoord2f(1.0,1.0);glVertex3f(0.2,0.2,0.2);
	glTexCoord2f(0.0,1.0);glVertex3f(-0.2,0.2,0.2);

	glTexCoord2f(1.0,0.0);glVertex3f(-0.2,-0.2,-0.2);
	glTexCoord2f(1.0,1.0);glVertex3f(-0.2,0.2,-0.2);
	glTexCoord2f(0.0,1.0);glVertex3f(0.2,0.2,-0.2);
	glTexCoord2f(0.0,0.0);glVertex3f(0.2,-0.2,-0.2);

	glTexCoord2f(0.0,1.0);glVertex3f(-0.2,0.2,-0.2);
	glTexCoord2f(0.0,0.0);glVertex3f(-0.2,0.2,0.2);
	glTexCoord2f(1.0,0.0);glVertex3f(0.2,0.2,0.2);
	glTexCoord2f(1.0,1.0);glVertex3f(0.2,0.2,-0.2);

	glTexCoord2f(1.0,1.0);glVertex3f(-0.2,-0.2,-0.2);
	glTexCoord2f(0.0,1.0);glVertex3f(0.2,-0.2,-0.2);
	glTexCoord2f(0.0,0.0);glVertex3f(0.2,-0.2,-0.2);
	glTexCoord2f(1.0,0.0);glVertex3f(-0.2,-0.2,0.2);

	glTexCoord2f(1.0,0.0);glVertex3f(0.2,-0.2,-0.2);
	glTexCoord2f(1.0,1.0);glVertex3f(0.2,0.2,-0.2);
	glTexCoord2f(0.0,1.0);glVertex3f(0.2,0.2,0.2);
	glTexCoord2f(0.0,0.0);glVertex3f(0.2,-0.2,0.2);

	glTexCoord2f(0.0,0.0);glVertex3f(-0.2,-0.2,-0.2);
	glTexCoord2f(1.0,0.0);glVertex3f(-0.2,-0.2,0.2);
	glTexCoord2f(1.0,1.0);glVertex3f(-0.2,0.2,0.2);
	glTexCoord2f(0.0,1.0);glVertex3f(-0.2,0.2,-0.2);
	glEnd();
	xrot+=3;
	yrot+=4;
	zrot+=2;
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

# 第七课：光照和键盘控制

头晕了……还是从第一课代码的基础上更改好……

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

	bool fullscreen;
	GLfloat xrot,yrot,zrot;
	GLfloat zoom,xspeed,yspeed;
	GLuint texture[3],filter;

	bool light;
};

#endif // NEHEWIDGET_H
```

nehewidget.cpp 文件：

```c++
#include "nehewidget.h"

#include <gl/GLU.h>
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
}

void nehewidget::paintGL()
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	glTranslatef(0.0,0.0,zoom);
	glRotatef(xrot,1.0,0.0,0.0);
	glRotatef(yrot,0.0,1.0,0.0);
	glBindTexture(GL_TEXTURE_2D,texture[filter]);
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
	case Qt::Key_F:
		filter+=1;
		if(filter>2) {
			filter=0;
		}
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
		xspeed-=0.2;
		updateGL();
		break;
	case Qt::Key_Down:
		xspeed+=0.2;
		updateGL();
		break;
	case Qt::Key_Right:
		yspeed+=0.2;
		updateGL();
		break;
	case Qt::Key_Left:
		yspeed-=0.2;
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
//	glTexImage2D(GL_TEXTURE_2D,0,3,tex.width(),tex.height(),0,GL_RGB,GL_UNSIGNED_BYTE,tex.bits());
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

	gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGB,tex.width(),tex.height(),GL_RGBA,GL_UNSIGNED_BYTE,tex.bits());
}
```

# 第八课：融合

在上一课代码的基础上加几行就好了

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

	bool fullscreen;
	GLfloat xrot,yrot,zrot;
	GLfloat zoom,xspeed,yspeed;
	GLuint texture[3],filter;

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
	blend=false;

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
}

void nehewidget::paintGL()
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	glTranslatef(0.0,0.0,zoom);
	glRotatef(xrot,1.0,0.0,0.0);
	glRotatef(yrot,0.0,1.0,0.0);
	glBindTexture(GL_TEXTURE_2D,texture[filter]);
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
		updateGL();
		break;
	case Qt::Key_PageDown:
		zoom+=0.2;
		updateGL();
		break;
	case Qt::Key_Up:
		xspeed-=0.2;
		updateGL();
		break;
	case Qt::Key_Down:
		xspeed+=0.2;
		updateGL();
		break;
	case Qt::Key_Right:
		yspeed+=0.2;
		updateGL();
		break;
	case Qt::Key_Left:
		yspeed-=0.2;
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
//	glTexImage2D(GL_TEXTURE_2D,0,3,tex.width(),tex.height(),0,GL_RGB,GL_UNSIGNED_BYTE,tex.bits());
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

	gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGB,tex.width(),tex.height(),GL_RGBA,GL_UNSIGNED_BYTE,tex.bits());
}
```