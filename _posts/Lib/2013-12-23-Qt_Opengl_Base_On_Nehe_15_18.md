---
layout: default
title: Qt下使用OpenGL-根据NeHe的教程改写的(15-18)
categories:
- Lib
tags:
- Lib
---
//Description: Qt下使用OpenGL-根据NeHe的教程改写的(15-18)

//Create Date: 2013-12-23 16:02:39

//Author: channy

[toc]

# 第十五课：纹理文字

这课和上面一课，即第十四课轮廓文字合一块了，这里不再重复贴代码……

# 第十六课：雾

在第七课的代码基础上修改。

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
	GLuint fogfilter;
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

GLuint fogmode[3]={GL_EXP,GL_EXP2,GL_LINEAR};
GLfloat fogcolor[4]={0.5,0.5,0.5,1.0};

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
	fogfilter=0;

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

	glFogi(GL_FOG_MODE,fogmode[fogfilter]);
	glFogfv(GL_FOG_COLOR,fogcolor);
	glFogf(GL_FOG_DENSITY,0.35);
	glHint(GL_FOG_HINT,GL_DONT_CARE);
	glFogf(GL_FOG_START,0.0);
	glFogf(GL_FOG_END,0.0);
	glEnable(GL_FOG);
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

# 第十七课：2D图像文字

文字还真是麻烦，屏幕又是一片黑白。Who can tell me where I was wrong???

nehewidget.h

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

	void loadTextures();
	void keyPressEvent(QKeyEvent *e);
	bool fullscreen;
};

#endif // NEHEWIDGET_H
```

nehewidget.cpp

```
#include "nehewidget.h"

#include <gl/GLU.h>
#include <gl/GL.h>
#include <QVector2D>
#include <QKeyEvent>
#include <QOpenGLFunctions>

namespace {
	GLuint  texture[2];                             // Storage For Our Font Texture
	GLuint  loop;                                   // Generic Loop Variable

	GLfloat cnt1;                                   // 1st Counter Used To Move Text & For Coloring
	GLfloat cnt2;                                   // 2nd Counter Used To Move Text & For Coloring

	struct FyjBitmapChar
	{
		QVector<QVector2D> texCoords;
		int right; //字符宽度
		int height;//字符高度
		int ascillValue;
	};

	struct FyjBitmapFont
	{
		char *name;
		int quality;
		FyjBitmapChar *characters;
	};

	static FyjBitmapChar chars1[128];
	static FyjBitmapChar chars2[128];

	const FyjBitmapFont font1 = {"standard", 128, chars1};
	const FyjBitmapFont font2 = {"Itatic", 128, chars2};

	void buildFont()
	{
		float   cx;                      // Holds Our X Character Coord
		float   cy;                     // Holds Our Y Character Coord
		glBindTexture(GL_TEXTURE_2D, texture[0]);
		for (loop = 0; loop < 256; loop++) {
			cx = float(loop%16)/16.0f; //当前字符的x纹理坐标
			cy = float(loop/16)/16.0f; //当前字符的y纹理坐标
			if (loop < 128) {
				chars1[loop].texCoords<<QVector2D(cx, cy + 0.0625f)
					<<QVector2D(cx+0.0625f, cy+0.0625f)
					<<QVector2D(cx+0.0625f, cy)
					<<QVector2D(cx, cy);
				chars1[loop].height = 16;
				chars1[loop].right = 10;
				chars1[loop].ascillValue = loop+32;
			} else {
				chars2[loop-128].texCoords<<QVector2D(cx, cy + 0.0625f)
					<<QVector2D(cx+0.0625f, cy+0.0625f)
					<<QVector2D(cx+0.0625f, cy)
					<<QVector2D(cx, cy);
				chars2[loop-128].height = 12;
				chars2[loop-128].right = 10;
				chars2[loop-128].ascillValue = loop-128+32;
			}
		}
	}

	void renderBitmapCharacter(FyjBitmapChar c, int fontSize)
	{
		Q_ASSERT_X(c.ascillValue >= 32 && c.ascillValue <= 127,
			"renderBitmapCharacter", "unspported char");
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		QVector<QVector2D> vertices;
		vertices<<QVector2D(0, 0)
			<<QVector2D(fontSize, 0)
			<<QVector2D(fontSize, fontSize)
			<<QVector2D(0, fontSize);
		glVertexPointer(2, GL_FLOAT, 0, vertices.constData());
		glTexCoordPointer(2, GL_FLOAT, 0, c.texCoords.constData());
		glDrawArrays(GL_QUADS, 0, 4);
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}

	void renderBitmapString(GLint x, GLint y, QString string, int set, int fontSize)
	{
		int numOfReturnChar = 0;
		if (string.isNull() || string.isEmpty())
			return;
		if (set > 1)
			set = 1;
		FyjBitmapFont currentFont;
		if (set == 0)
			currentFont = font1;
		else
			currentFont = font2;

		glBindTexture(GL_TEXTURE_2D, texture[0]);
		glDisable(GL_DEPTH_TEST);
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();
//		glOrtho(0,640,0,480,-1,1);
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glLoadIdentity();
//		glTranslatef(x, y, 0);
		for(int i = 0; i < string.length(); i++) {
			char c = string.at(i).toLatin1();
			if (c == '\n') {
				numOfReturnChar++;
				glLoadIdentity();
//				glTranslatef(x, y - numOfReturnChar * currentFont.characters[0].height, 0);
				continue;
			}
			renderBitmapCharacter(currentFont.characters[c-32], fontSize);
//			glTranslatef(currentFont.characters[c-32].right * fontSize/16, 0, 0);
		}
		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
		glEnable(GL_DEPTH_TEST);
	}

	void glPrint(GLint x, GLint y, int set, int fontSize, const char *fmt, ...)
	{
		char   text[256];              // Holds Our String
		va_list     ap;                 // Pointer To List Of Arguments
		if (fmt == NULL)                    // If There's No Text
			return;                     // Do Nothing
		va_start(ap, fmt);                  // Parses The String For Variables
		vsprintf(text, fmt, ap);                // And Converts Symbols To Actual Numbers
		va_end(ap);                     // Results Are Stored In Text

		renderBitmapString(x, y, QString(text), set, fontSize);
	}

	void drawTextureMappedQuad()
	{
		QVector<QVector2D> vertices;
		QVector<QVector2D> texCoords;
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		vertices<<QVector2D(-1.0f, 1.0f)
			<<QVector2D(1.0f, 1.0f)
			<<QVector2D(1.0f,-1.0f)
			<<QVector2D(-1.0f,-1.0f);
		texCoords<<QVector2D(0.0f,0.0f)
			<<QVector2D(1.0f,0.0f)
			<<QVector2D(1.0f,1.0f)
			<<QVector2D(0.0f,1.0f);
		glTexCoordPointer(2, GL_FLOAT, 0, texCoords.constData());
		glVertexPointer(2, GL_FLOAT, 0, vertices.constData());
		glDrawArrays(GL_QUADS, 0, 4);
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}

}

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

void nehewidget::loadTextures()
{
	texture[0] = bindTexture(QString("./texture.bmp"),
		GL_TEXTURE_2D,
		GL_RGBA,
		QGLContext::LinearFilteringBindOption);
	// Create Nearest Filtered Texture
	glBindTexture(GL_TEXTURE_2D, texture[0]);

	texture[1] = bindTexture(QString("./0.bmp"),
		GL_TEXTURE_2D,
		GL_RGBA,
		QGLContext::LinearFilteringBindOption);
	// Create Linear Filtered Texture
	glBindTexture(GL_TEXTURE_2D, texture[1]);
}

void nehewidget::initializeGL()
{
	loadTextures();
	glEnable(GL_TEXTURE_2D);
	buildFont();
	glBlendFunc(GL_SRC_ALPHA,GL_ONE);
	glShadeModel(GL_SMOOTH);   // Enables Smooth Shading
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);  // Black Background
	glClearDepth(1.0f);             // Depth Buffer Setup
	glEnable(GL_DEPTH_TEST);        // Enables Depth Testing
	glDepthFunc(GL_LEQUAL);        // The Type Of Depth Test To Do
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST); // Really Nice Perspective Calculations
}

void nehewidget::paintGL()
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);  // Clear The Screen And The Depth Buffer
	glLoadIdentity();       // Reset The Current Modelview Matrix

	glBindTexture(GL_TEXTURE_2D, texture[1]);
	glTranslatef(0.0f,0.0f,-5.0f);
	glRotatef(45.0f,0.0f,0.0f,1.0f);
	glRotatef(cnt1*30.0f,1.0f,1.0f,0.0f);
	glDisable(GL_BLEND);
	glColor3f(1.0f,1.0f,1.0f);
	drawTextureMappedQuad();

	glRotatef(90.0f,1.0f,1.0f,0.0f);
	drawTextureMappedQuad();

	glEnable(GL_BLEND);
	glLoadIdentity();

	glColor3f(1.0f*float(cos(cnt1)),1.0f*float(sin(cnt2)),1.0f-0.5f*float(cos(cnt1+cnt2)));
	glPrint(int((280+250*cos(cnt1))),int(235+200*sin(cnt2)),0, 16, "NeHe");

	glColor3f(1.0f*float(sin(cnt2)),1.0f-0.5f*float(cos(cnt1+cnt2)),1.0f*float(cos(cnt1)));
	glPrint(int((280+230*cos(cnt2))),int(235+200*sin(cnt1)), 1, 24, "OpenGL");

	glColor3f(0.0f,0.0f,1.0f);
	glPrint(int(240+200*cos((cnt2+cnt1)/5)),2, 0, 16, "Giuseppe D'Agata");

	glColor3f(1.0f,1.0f,1.0f);
	glPrint(int(242+200*cos((cnt2+cnt1)/5)),2, 0, 16, "Giuseppe D'Agata");

	cnt1+=0.01f;
	cnt2+=0.0081f;
}

void nehewidget::resizeGL(int w,int h)
{
	if(h==0) h=1;
	glViewport(0,0,(GLint)w,(GLint)h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

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
```

# 第十八课：二次几何体

在第七课光照的基础上加代码。

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
}

void nehewidget::paintGL()
{
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();

	glTranslatef(0.0,0.0,zoom);
	glRotatef(xrot,1.0,0.0,0.0);
	glRotatef(yrot,0.0,1.0,0.0);
	glBindTexture(GL_TEXTURE_2D,texture[filter]);

	switch(object) {
	case 0:
		glDrawCube();
		break;
	case 1:
		glTranslatef(0.0f,0.0f,-1.5f);
		gluCylinder(quadratic,1.0f,1.0f,3.0f,32,32);
		break;
	case 2:
		gluDisk(quadratic,0.5f,1.5f,32,32);
		break;
	case 3:
		gluSphere(quadratic,1.3f,32,32);
		break;
	case 4:
		glTranslatef(0.0f,0.0f,-1.5f);
		gluCylinder(quadratic,1.0f,0.0f,3.0f,32,32);
		break;
	case 5:
		part1+=p1;
		part2+=p2;
		if(part1>359) {
			p1 = 0;
			p2 = 1;
			part1 = 0;
			part2 = 0;
		}
		if(part2>359) {
			p1 = 1;
			p2 = 0;
		}
		gluPartialDisk(quadratic,0.5f,1.5f,32,32,part1,part2-part1);
		break;
	default:
		break;
	}

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
		if (object > 5) object = 0;
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