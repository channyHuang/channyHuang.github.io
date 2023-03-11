---
layout: default
title: 学习SDL2.0
categories:
- Lib
tags:
- Lib
---
//Description: 学习SDL2.0

//Create Date: 2014-10-27 14:11:09

//Author: channy

​# SDL2.0  
SDL接口都比较简单，看名称就知道意思。

这里是参考资料：SDL2.0教程翻译·目录 - SDL中文教程

# SDL2.0_01_hello world!
​```c++  
#include <iostream>
#include <windows.h>
#include <string>
using namespace std;

#include <SDL.h>
#include <SDL_image.h>

int main(int argc, char** argv)
{
	SDL_Window *win = SDL_CreateWindow("hello world!", 100, 100, 640, 480, SDL_WINDOW_RESIZABLE);
	SDL_Surface *picture = SDL_LoadBMP("F:/material/m_bottle.bmp");
	SDL_Renderer *ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	SDL_Texture *tex = SDL_CreateTextureFromSurface(ren, picture);

	SDL_FreeSurface(picture);
	SDL_RenderClear(ren);
	SDL_RenderCopy(ren, tex, NULL, NULL);
	SDL_RenderPresent(ren);
	SDL_Delay(2000);
	SDL_DestroyTexture(tex);
	SDL_DestroyRenderer(ren);
	SDL_DestroyWindow(win);
	SDL_Quit();

	cout << "Success!" << endl;
	return 0;
}
```

# SDL2.0_02_functions  

```c++
#include <iostream>
#include <windows.h>
#include <string>
using namespace std;

#include <SDL.h>
#include <SDL_image.h>

const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

SDL_Window *win = nullptr;
SDL_Renderer *ren = nullptr;

SDL_Texture * LoadImage(string file) {
	SDL_Texture *tex = nullptr;
	SDL_Surface *loadImage = SDL_LoadBMP(file.c_str());
	if (loadImage != nullptr) {
		tex = SDL_CreateTextureFromSurface(ren, loadImage);
		SDL_FreeSurface(loadImage);
	}
	else {
		cout << SDL_GetError() << endl;
	}

	return tex;
}

void ApplySurface(int x, int y, SDL_Texture *tex, SDL_Renderer *ren){
	SDL_Rect pos;
	pos.x = x;
	pos.y = y;
	SDL_QueryTexture(tex, NULL, NULL, &pos.w, &pos.h);
	SDL_RenderCopy(ren, tex, NULL, &pos);
}

int main(int argc, char** argv)
{
	if (SDL_Init(SDL_INIT_EVERYTHING) == -1) {
		cout << SDL_GetError() << endl;
		return 0;
	}

	win = SDL_CreateWindow("02:", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_RESIZABLE);

	if (win == nullptr) {
		cout << SDL_GetError() << endl;
		return 0;
	}
	
	ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if (ren == nullptr) {
		cout << SDL_GetError() << endl;
		return 0;
	}
	SDL_Texture *bg = LoadImage("f:/material/giantShadowFlash.bmp");
	SDL_Texture *fg = LoadImage("F:/material/m_bottle.bmp");

	if (bg == nullptr || fg == nullptr) {
		cout << "Could not load one of the images!" << endl;
		return 0;
	}

	SDL_RenderClear(ren);

	int bw, bh;
	SDL_QueryTexture(bg, NULL, NULL, &bw, &bh);
	ApplySurface(0, 0, bg, ren);
	ApplySurface(bw, 0, bg, ren);
	ApplySurface(0, bh, bg, ren);
	ApplySurface(bw, bh, bg, ren);

	SDL_QueryTexture(fg, NULL, NULL, &bw, &bh);
	ApplySurface(SCREEN_WIDTH / 2 - bw / 2, SCREEN_HEIGHT / 2 - bh / 2, fg, ren);

	SDL_RenderPresent(ren);
	SDL_Delay(2000);
	SDL_DestroyTexture(bg);
	SDL_DestroyTexture(fg);
	SDL_DestroyRenderer(ren);
	SDL_DestroyWindow(win);
	SDL_Quit();

	cout << "Success!" << endl;
	return 0;
}
```

# SDL2.0_03_SDL_image Library
扩展库SDL_Image，运行的时候需要把zlib1.dll，libjpeg-9.dll，libpng16-16.dll一同拷到目录里，不然不会报错，但就是运行没显示结果。

代码是在上一课的基础上略加修改的。
```c++
#include <iostream>
#include <windows.h>
#include <string>
using namespace std;

#include <SDL.h>
#include <SDL_image.h>

const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

SDL_Window *win = nullptr;
SDL_Renderer *ren = nullptr;

SDL_Texture * LoadImage(string file) {
	SDL_Texture *tex = nullptr;
	tex = IMG_LoadTexture(ren, file.c_str());
	if (tex == nullptr) {
		cout << "Fail to load image in function LoadImage()!" << endl;
	}

	return tex;
}

void ApplySurface(int x, int y, SDL_Texture *tex, SDL_Renderer *ren){
	SDL_Rect pos;
	pos.x = x;
	pos.y = y;
	SDL_QueryTexture(tex, NULL, NULL, &pos.w, &pos.h);
	SDL_RenderCopy(ren, tex, NULL, &pos);
}

int main(int argc, char** argv)
{
	if (SDL_Init(SDL_INIT_EVERYTHING) == -1) {
		cout << SDL_GetError() << endl;
		return 0;
	}

	win = SDL_CreateWindow("02:", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_RESIZABLE);

	if (win == nullptr) {
		cout << SDL_GetError() << endl;
		return 0;
	}
	
	ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if (ren == nullptr) {
		cout << SDL_GetError() << endl;
		return 0;
	}
	SDL_Texture *bg = LoadImage("f:/material/giantShadowFlash.jpg");
	SDL_Texture *fg = LoadImage("F:/material/bubble.png");

	if (bg == nullptr || fg == nullptr) {
		cout << "Could not load one of the images!" << endl;
		return 0;
	}

	SDL_RenderClear(ren);

	int bw, bh;
	SDL_QueryTexture(bg, NULL, NULL, &bw, &bh);
	ApplySurface(0, 0, bg, ren);
	ApplySurface(bw, 0, bg, ren);
	ApplySurface(0, bh, bg, ren);
	ApplySurface(bw, bh, bg, ren);

	SDL_QueryTexture(fg, NULL, NULL, &bw, &bh);
	ApplySurface(SCREEN_WIDTH / 2 - bw / 2, SCREEN_HEIGHT / 2 - bh / 2, fg, ren);

	SDL_RenderPresent(ren);
	SDL_Delay(2000);
	SDL_DestroyTexture(bg);
	SDL_DestroyTexture(fg);
	SDL_DestroyRenderer(ren);
	SDL_DestroyWindow(win);
	SDL_Quit();

	cout << "Success!" << endl;
	return 0;
}
```

# SDL2.0_04_event
也是在前一课的基础上稍作修改的。
```c++
#include <iostream>
#include <windows.h>
#include <string>
using namespace std;

#include <SDL.h>
#include <SDL_image.h>

const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

SDL_Window *win = nullptr;
SDL_Renderer *ren = nullptr;

SDL_Texture * LoadImage(string file) {
	SDL_Texture *tex = nullptr;
	tex = IMG_LoadTexture(ren, file.c_str());
	if (tex == nullptr) {
		cout << "Fail to load image in function LoadImage()!" << endl;
	}

	return tex;
}

void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, int x, int y, int w, int h) {
	SDL_Rect dst;
	dst.x = x;
	dst.y = y;
	dst.w = w;
	dst.h = h;
	SDL_RenderCopy(ren, tex, NULL, &dst);
}

void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, int x, int y) {
	int w, h;
	SDL_QueryTexture(tex, NULL, NULL, &w, &h);
	renderTexture(tex, ren, x, y, w, h);
}

int main(int argc, char** argv)
{
	if (SDL_Init(SDL_INIT_EVERYTHING) == -1) {
		cout << SDL_GetError() << endl;
		return 0;
	}

	win = SDL_CreateWindow("04:", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_RESIZABLE);

	if (win == nullptr) {
		cout << SDL_GetError() << endl;
		return 0;
	}
	
	ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if (ren == nullptr) {
		cout << SDL_GetError() << endl;
		return 0;
	}
	SDL_Texture *bg = LoadImage("f:/material/giantShadowFlash.jpg");

	if (bg == nullptr) {
		cout << "Could not load one of the images!" << endl;
		return 0;
	}

	SDL_RenderClear(ren);

	int bw, bh;
	SDL_QueryTexture(bg, NULL, NULL, &bw, &bh);

	SDL_Event e;
	bool quit = false;
	while (!quit) {
		while (SDL_PollEvent(&e))
		{
			if (e.type == SDL_QUIT) {
				cout << "quit type..." << endl;
				quit = true;
			}
			if (e.type == SDL_KEYDOWN) {
				cout << "keydown type..." << endl;
				quit = true;
			}
			if (e.type == SDL_MOUSEBUTTONDOWN) {
				cout << "mousebuttondown type..." << endl;
				quit = true;
			}
		}
		SDL_RenderClear(ren);
		renderTexture(bg, ren, SCREEN_WIDTH/2 - bw/2, SCREEN_HEIGHT/2 - bh/2);
		SDL_RenderPresent(ren);
	}

	SDL_DestroyTexture(bg);
	SDL_DestroyRenderer(ren);
	SDL_DestroyWindow(win);
	SDL_Quit();
	IMG_Quit();

	cout << "Success!" << endl;
	return 0;
}
```

# SDL2.0_05_sprite sheet
裁剪。单击键盘1~4键观察图像的不同区域。

全局变量可以改成局部变量，这里懒得改了，有需要的直接看原文。
```c++
#include <iostream>
#include <windows.h>
#include <string>
using namespace std;

#include <SDL.h>
#include <SDL_image.h>

const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

SDL_Window *win = nullptr;
SDL_Renderer *ren = nullptr;

SDL_Texture * LoadImage(string file) {
	SDL_Texture *tex = nullptr;
	tex = IMG_LoadTexture(ren, file.c_str());
	if (tex == nullptr) {
		cout << "Fail to load image in function LoadImage()!" << endl;
	}

	return tex;
}

void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, SDL_Rect dst, SDL_Rect *clip = nullptr) {
	SDL_RenderCopy(ren, tex, clip, &dst);
}

void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, int x, int y, SDL_Rect *clip = nullptr) {
	SDL_Rect dst;
	dst.x = x;
	dst.y = y;
	if (clip != nullptr) {
		dst.w = clip->w;
		dst.h = clip->h;
	}
	else 
		SDL_QueryTexture(tex, NULL, NULL, &dst.w, &dst.h);
	renderTexture(tex, ren, dst, clip);
}

int main(int argc, char** argv)
{
	if (SDL_Init(SDL_INIT_EVERYTHING) == -1) {
		cout << SDL_GetError() << endl;
		return 0;
	}

	win = SDL_CreateWindow("05:", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_RESIZABLE);

	if (win == nullptr) {
		cout << SDL_GetError() << endl;
		return 0;
	}
	
	ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if (ren == nullptr) {
		cout << SDL_GetError() << endl;
		return 0;
	}


	SDL_Texture *bg = LoadImage("f:/material/giantShadowFlash.jpg");

	if (bg == nullptr) {
		cout << "Could not load one of the images!" << endl;
		return 0;
	}

	SDL_RenderClear(ren);

	int bw = 100, bh = 100;

	SDL_Rect clips[4];
	for (int i = 0; i < 4; i++) {
		clips[i].x = i / 2 * bw;
		clips[i].y = i % 2 * bh;
		clips[i].w = bw;
		clips[i].h = bh;
	}
	int useClip = 0;

	SDL_Event e;
	bool quit = false;
	while (!quit) {
		while (SDL_PollEvent(&e))
		{
			if (e.type == SDL_QUIT) {
				cout << "quit..." << endl;
				quit = true;
			}
			if (e.type == SDL_KEYDOWN) {
				switch (e.key.keysym.sym) {
				case SDLK_1:
					useClip = 0;
					break;
				case SDLK_2:
					useClip = 1;
					break;
				case SDLK_3:
					useClip = 2;
					break;
				case SDLK_4:
					useClip = 3;
					break;
				default:
					break;
				}
			}
		}
		SDL_RenderClear(ren);
		renderTexture(bg, ren, SCREEN_WIDTH/2 - bw/2, SCREEN_HEIGHT/2 - bh/2, &clips[useClip]);
		SDL_RenderPresent(ren);
	}

	SDL_DestroyTexture(bg);
	SDL_DestroyRenderer(ren);
	SDL_DestroyWindow(win);
	SDL_Quit();
	IMG_Quit();

	cout << "Success!" << endl;
	return 0;
}
```

# SDL2.0_06_text
使用了SDL_ttf扩展库，字体文件*.ttf可以在Sourceforge上下载。
```c++
#include <iostream>
#include <windows.h>
#include <string>
using namespace std;

#include <SDL.h>
#include <SDL_image.h>
#include <SDL_ttf.h>

const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 480;

void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, SDL_Rect dst, SDL_Rect *clip = nullptr) {
	SDL_RenderCopy(ren, tex, clip, &dst);
}

void renderTexture(SDL_Texture *tex, SDL_Renderer *ren, int x, int y, SDL_Rect *clip = nullptr) {
	SDL_Rect dst;
	dst.x = x;
	dst.y = y;
	if (clip != nullptr) {
		dst.w = clip->w;
		dst.h = clip->h;
	}
	else 
		SDL_QueryTexture(tex, NULL, NULL, &dst.w, &dst.h);
	renderTexture(tex, ren, dst, clip);
}

SDL_Texture *renderText(const string &message, const string &fontFile, SDL_Color color, int fontSize, SDL_Renderer *ren) {
	TTF_Font *font = TTF_OpenFont(fontFile.c_str(), fontSize);
	if (font == nullptr) {
		cout << "Failed to open font..." << endl;
		exit(0);
	}
	SDL_Surface *surf = TTF_RenderText_Blended(font, message.c_str(), color);
	SDL_Texture *tex = SDL_CreateTextureFromSurface(ren, surf);

	SDL_FreeSurface(surf);
	TTF_CloseFont(font);

	return tex;
}

int main(int argc, char** argv)
{
	if (SDL_Init(SDL_INIT_EVERYTHING) == -1) {
		cout << SDL_GetError() << endl;
		return 0;
	}

	if (TTF_Init() == -1) {
		cout << TTF_GetError() << endl;
		return 0;
	}

	SDL_Window *win = nullptr;
	win = SDL_CreateWindow("05:", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_RESIZABLE);

	if (win == nullptr) {
		cout << SDL_GetError() << endl;
		return 0;
	}
	
	SDL_Renderer *ren = nullptr;
	ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
	if (ren == nullptr) {
		cout << SDL_GetError() << endl;
		return 0;
	}

	SDL_Color color = { 128, 128, 128 };
	SDL_Texture *bg = renderText("Why I have to learn SDL?", "chivo-black-webfont.ttf", color, 64, ren);

	if (bg == nullptr) {
		cout << "Could not load font correctly!" << endl;
		return 0;
	}

	SDL_RenderClear(ren);

	int bw, bh;
	SDL_QueryTexture(bg, NULL, NULL, &bw, &bh);

	SDL_Event e;
	bool quit = false;
	while (!quit) {
		while (SDL_PollEvent(&e))
		{
			if (e.type == SDL_QUIT) {
				cout << "quit..." << endl;
				quit = true;
			}
			if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_ESCAPE) {
				quit = true;
			}
		}
		SDL_RenderClear(ren);
		renderTexture(bg, ren, SCREEN_WIDTH/2 - bw/2, SCREEN_HEIGHT/2 - bh/2);
		SDL_RenderPresent(ren);
	}

	SDL_DestroyTexture(bg);
	SDL_DestroyRenderer(ren);
	SDL_DestroyWindow(win);
	SDL_Quit();
	IMG_Quit();

	cout << "Success!" << endl;
	return 0;
}
```

# SDL2.0_07_classes
把前边所学的内容综合了一下。

单击键a和d实现旋转。

sdltest.h
```c++
#ifndef SDLTEST_H
#define SDLTEST_H

#include <iostream>
#include <windows.h>
#include <string>
#include <memory>
using namespace std;

#include <SDL.h>
#include <SDL_image.h>
#include <SDL_ttf.h>

class sdlTest
{
public:
	void Init(string title = "window title");
	void Quit();
	void Clear();
	void Present();

	SDL_Texture *LoadImage(string file);

	SDL_Texture *renderText(const string &message, const string &fontFile, SDL_Color color, int fontSize);

	SDL_Rect Box();

	void Draw(SDL_Texture *tex, SDL_Rect& dst, SDL_Rect *clip = NULL, float angle = 0.0, int xrot = 0, int yrot = 0, SDL_RendererFlip flip = SDL_FLIP_NONE);

private:
	static unique_ptr<SDL_Window, void(*)(SDL_Window*)> mWindow;
	static unique_ptr<SDL_Renderer, void(*)(SDL_Renderer*)> mRenderer;
	SDL_Rect mBox;
};

#endif
```

sdltest.cpp
```c++
#include "sdltest.h"

unique_ptr<SDL_Window, void(*)(SDL_Window*)> sdlTest::mWindow = unique_ptr<SDL_Window, void(*)(SDL_Window*)>(nullptr, SDL_DestroyWindow);
unique_ptr<SDL_Renderer, void(*)(SDL_Renderer*)> sdlTest::mRenderer = unique_ptr<SDL_Renderer, void(*)(SDL_Renderer*)>(nullptr, SDL_DestroyRenderer);

void sdlTest::Init(string title)
{
	if (SDL_Init(SDL_INIT_EVERYTHING) == -1) {
		cout << SDL_GetError() << endl;
		exit(0);
	}

	if (TTF_Init() == -1) {
		cout << TTF_GetError() << endl;
		exit(0);
	}

	mBox.x = 0;
	mBox.y = 0;
	mBox.w = 640;
	mBox.h = 480;

	mWindow.reset(SDL_CreateWindow(title.c_str(), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, mBox.w, mBox.h, SDL_WINDOW_SHOWN));
	mRenderer.reset(SDL_CreateRenderer(mWindow.get(), -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC));

	if (mWindow == nullptr || mRenderer == nullptr) {
		cout << "Failed to create window or renderer in SDL..." << endl;
		exit(0);
	}
}

void sdlTest::Quit()
{
	SDL_Quit();
	TTF_Quit();
}

void sdlTest::Clear()
{
	SDL_RenderClear(mRenderer.get());
}

void sdlTest::Present()
{
	SDL_RenderPresent(mRenderer.get());
}

SDL_Texture *sdlTest::LoadImage(string file) {
	SDL_Texture *tex = IMG_LoadTexture(mRenderer.get(), file.c_str());
	if (tex == nullptr) {
		cout << "Failed to load image..." << endl;
		exit(0);
	}

	return tex;
}

SDL_Texture *sdlTest::renderText(const string &message, const string &fontFile, SDL_Color color, int fontSize) {
	TTF_Font *font = TTF_OpenFont(fontFile.c_str(), fontSize);
	if (font == nullptr) {
		cout << "Failed to open font..." << endl;
		exit(0);
	}
	SDL_Surface *surf = TTF_RenderText_Blended(font, message.c_str(), color);
	SDL_Texture *tex = SDL_CreateTextureFromSurface(mRenderer.get(), surf);

	SDL_FreeSurface(surf);
	TTF_CloseFont(font);

	return tex;
}

SDL_Rect sdlTest::Box()
{
	SDL_GetWindowSize(mWindow.get(), &mBox.w, &mBox.h);
	return mBox;
}

void sdlTest::Draw(SDL_Texture *tex, SDL_Rect& dst, SDL_Rect *clip, float angle, int xrot, int yrot, SDL_RendererFlip flip) {
	xrot += dst.w / 2;
	yrot += dst.h / 2;
	SDL_Point rot = { xrot, yrot };
	SDL_RenderCopyEx(mRenderer.get(), tex, clip, &dst, angle, &rot, flip);
}
```

main.cpp
```c++
#include "sdltest.h"

int main(int argc, char** argv)
{
	sdlTest mytest;
	mytest.Init("07:");

	SDL_Texture *bg = mytest.LoadImage("F:/material/bubble.png");
	SDL_Color color = { 128, 128, 128 };
	SDL_Texture *fg = mytest.renderText("I hate SDL...", "chivo-black-webfont.ttf", color, 25);

	if (bg == nullptr) {
		cout << "Could not load font correctly!" << endl;
		return 0;
	}

	SDL_Rect pos = { mytest.Box().w / 2 - 150 / 2, mytest.Box().h / 2 - 150 / 2, 150, 150 };
	int angle = 0;

	SDL_Event e;
	bool quit = false;
	while (!quit) {
		while (SDL_PollEvent(&e))
		{
			if (e.type == SDL_QUIT) {
				cout << "quit..." << endl;
				quit = true;
			}
			if (e.type == SDL_KEYDOWN) {
				switch (e.key.keysym.sym)
				{
				case SDLK_d:
					angle += 2;
					break;
				case SDLK_a:
					angle -= 2;
					break;
				case SDLK_ESCAPE:
					quit = true;
					break;
				default:
					break;
				}
			}
		}
		
		mytest.Clear();
		mytest.Draw(bg, pos, NULL, angle);
//		mytest.Draw(fg, pos, NULL, angle, 0, 0, SDL_FLIP_VERTICAL);
		mytest.Draw(fg, pos, NULL, angle, 0, 0, SDL_FLIP_HORIZONTAL);
		mytest.Present();
	}

	SDL_DestroyTexture(bg);
	mytest.Quit();

	cout << "Success!" << endl;
	return 0;
}
```

# SDL2.0_08_timer
在上一课的基础上修改，sdltest.*文件不动。

单击s和p键实现计时器计时。

timer.h
```c++
#ifndef TIMER_H
#define TIMER_H

class Timer
{
public:
	Timer();
	void start();
	void pause();
	void stop();
	void unpause();

	int reset();

	int Ticks() const;
	bool Started() const;
	bool Paused() const;
private:
	int mStartTicks, mPausedTicks;
	bool mStarted, mPaused;
};

#endif
```

timer.cpp
```c++
#include "timer.h"

#include <SDL.h>

Timer::Timer() :mStartTicks(0), mPausedTicks(0), mStarted(false), mPaused(false)
{

}

void Timer::start()
{
	mStarted = true;
	mPaused = false;
	mStartTicks = SDL_GetTicks();
}

void Timer::pause()
{
	if (mStarted && !mPaused) {
		mPaused = true;
		mPausedTicks = SDL_GetTicks() - mStartTicks;
	}
}

void Timer::stop()
{
	mStarted = false;
	mPaused = false;
}

void Timer::unpause()
{
	if (mPaused) {
		mPaused = false;
		mStartTicks = SDL_GetTicks() - mPausedTicks;
		mPausedTicks = 0;
	}
}

int Timer::reset() {
	int elapsedTicks = Ticks();
	start();
	return elapsedTicks;
}

int Timer::Ticks() const {
	if (mStarted) {
		if (mPaused)
			return mPausedTicks;
		else
			return SDL_GetTicks() - mStartTicks;
	}
	return 0;
}

bool Timer::Started() const {
	return mStarted;
}

bool Timer::Paused() const {
	return mPaused;
}
```

main.cpp
```c++
#include "sdltest.h"
#include "timer.h"

#include <sstream>

int main(int argc, char** argv)
{
	sdlTest mytest;
	mytest.Init("07:");

	Timer timer;
	SDL_Rect msgbox, tickbox;

	SDL_Color color = { 128, 128, 128 };
	SDL_Texture *msg = mytest.renderText("I hate SDL...", "chivo-black-webfont.ttf", color, 25);
	msgbox.x = 0;
	msgbox.y = mytest.Box().h / 2;
	SDL_QueryTexture(msg, NULL, NULL, &msgbox.w, &msgbox.h);

	stringstream ssticks;
	ssticks << timer.Ticks();
	SDL_Texture *tick = mytest.renderText(ssticks.str(), "chivo-black-webfont.ttf", color, 30);
	ssticks.str("");
	tickbox.x = msgbox.w + 20;
	tickbox.y = mytest.Box().h / 2;
	SDL_QueryTexture(tick, NULL, NULL, &tickbox.w, &tickbox.h);

	SDL_Event e;
	bool quit = false;
	while (!quit) {
		while (SDL_PollEvent(&e))
		{
			if (e.type == SDL_QUIT) {
				cout << "quit..." << endl;
				quit = true;
			}
			if (e.type == SDL_KEYDOWN) {
				switch (e.key.keysym.sym)
				{
				case SDLK_s:
					if (timer.Started()) {
						timer.stop();
					}
					else {
						timer.start();
					}
					break;
				case SDLK_p:
					if (timer.Paused()) {
						timer.unpause();
					}
					else {
						timer.pause();
					}
					break;
				case SDLK_ESCAPE:
					quit = true;
					break;
				default:
					break;
				}
			}
		}
		
		if (timer.Started() && !timer.Paused()) {
			ssticks << timer.Ticks();
			SDL_DestroyTexture(tick);
			tick = mytest.renderText(ssticks.str(), "chivo-black-webfont.ttf", color, 30);
			ssticks.str("");
			SDL_QueryTexture(tick, NULL, NULL, &tickbox.w, &tickbox.h);
		}
		
		mytest.Clear();
		mytest.Draw(msg, msgbox);
		mytest.Draw(tick, tickbox);
		mytest.Present();
	}

	SDL_DestroyTexture(msg);
	SDL_DestroyTexture(tick);
	mytest.Quit();

	cout << "Success!" << endl;
	return 0;
}
```

[back](/)
