---
layout: default
---

//Author: channy

//Create Date: 2018-10-06 10:25:19

//Description: 

# Linux_Basic_Comment

## Basic comment

```shell
shutdown -t 0 //shutdown
touch filename //new a file 
rm filename //delete a file
mkdir dir //new a folder
rmdir dir //delete a folder
cp originFile targetFolder //copy a file or folder
mv originFile targetFolder //move a file or folder
```

```c++
int test_perror(const char *s) {
	perror(s);
	exit(1);
	return 0;
}
```

## fork & exec

```c++
#include <stdio.h>
#include <unistd.h>
#include <cstdlib>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/wait.h>

#include "common.cpp"

int test_fork() {
	pid_t pid;
	printf("hello world\n");
	pid = fork();
	if (!pid) {
		printf("child\n");
	} else if (pid > 0) {
		printf("parent\n");
	} else {
		printf("error\n");
	}
	return 0;
}

int test_exec() {
	execl("/bin/ls", "ls", "-l", NULL);
	perror("execl failed\n");
	return 0;
}

int test_failure() {
	char buf[10];
	int fd, pid;
	if ((fd = open("main.cpp", O_RDONLY)) < 0) {
		test_perror("open file failed");
	}
	read(fd, buf, 10);
	long pos;
	if ((pos = lseek(fd, 0L, 1)) < 0L) {
		test_perror("lseek failed");
	}
	printf("Before fork, %ld\n", pos);
	if ((pid = fork()) < 0) {
		test_perror("fork failed");
	} else if (!pid) {
		read(fd, buf, 10);
		if ((pos = lseek(fd, 0L, 1)) < 0L) {
			test_perror("lseek failed");
		}
		printf("After fork, %ld\n", pos);
	} else {
			wait(NULL);
			if ((pos = lseek(fd, 0L, 1)) < 0L) {
				test_perror("lseek failed");
			}
			printf("Parent, %ld\n", pos);
	}
	
	return 0;
}

int main() {
	test_failure();
	
	return 0;
}
```

## environ & gid & uid & nice

```c++
#include <cstdio>
#include <unistd.h>
#include <sys/types.h>
#include <sys/resource.h>

extern char ** environ;

int test_env() {
	char **env = environ;
	while (*env) {
		printf("%s\n", *env++);
	}
	return 0;
}

int test_id() {
	uid_t uid, euid;
	gid_t gid, egid;
	
	uid = getuid();
	euid = geteuid();
	gid = getgid();
	egid = getegid();
	
	printf("%d %d %d %d\n", uid, euid, gid, egid);
	return 0;
}

int main() {
	//test_env();
	test_id();
	nice(5);
	return 0;
}
```

## pipe 

```c++
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <sys/types.h>

#include "common.hpp"

int main() {
	int result = -1;
	int fd[2], nbytes;
	pid_t pid;
	char string[] = "hello world";
	char readBuffer[80];
	
	//can't swap fd[1] & fd[0]
	int *writeFd = &fd[1];
	int *readFd = &fd[0];
	
	result = pipe(fd);
	if (result == -1) {
		test_perror("pipe failed\n");
	}
	pid = fork();
	if (pid == -1) {
		test_perror("fork failed\n");
	}
	if (0 == pid) {
		close(*readFd);
		result = write(*writeFd, string, strlen(string));

	} else {
		close(*writeFd);
		nbytes = read(*readFd, readBuffer, sizeof(readBuffer));
		//output "hello world**"?
		printf("receive %d %s\n", nbytes, readBuffer);
	}
	
	return 0;
}
```

## thread

```c++
#include <cstdio>
#include <pthread.h>
#include <unistd.h>

#include "common.hpp"

#include <iostream>

int run = 1;
int retvalue;

void *start_routine(void *arg) {
	int *running = (int *)arg;
	std::cout << *running << std::endl;
	while (*running) {
		std::cout << "running" << std::endl;
		usleep(1);
	}
	std::cout << "exit" << std::endl;
	
	retvalue = 8;
	pthread_exit((void*)&retvalue);
}

int main() {
	pthread_t pt;
	int ret = -1, times = 3, i = 0;
	void *ret_join = NULL;
	ret = pthread_create(&pt, NULL, start_routine, &run);
	if (ret != 0) {
		test_perror("thread failed\n");
	}
	usleep(1);
	for (; i < times; i++) {
		std::cout << "main thread" << std::endl;
		usleep(1);
	}
	
	run = 0;
	pthread_join(pt, &ret_join);
	std::cout << "return " << ret_join << std::endl;
	return 0;
}
```

## mutex
```c++
#include <cstdio>
#include <pthread.h>
#include <unistd.h>
#include <sched.h>
#include <iostream>

pthread_mutex_t mutex;
int buffer_has_item = 0;
int running = 1;

void *producterFun(void *arg) {
	while (running) {
		pthread_mutex_lock(&mutex);
		buffer_has_item++;
		std::cout << "product: " << buffer_has_item << std::endl;
		pthread_mutex_unlock(&mutex);
	}
}

void *consumerFun(void *arg) {
	while (running) {
		pthread_mutex_lock(&mutex);
		buffer_has_item--;
		std::cout << "consumer: " << buffer_has_item << std::endl;
		pthread_mutex_unlock(&mutex);
	}
}



int main() {
	pthread_t consumer, producter;
	pthread_mutex_init(&mutex, NULL);
	pthread_create(&producter, NULL, producterFun, NULL);
	pthread_create(&consumer, NULL, consumerFun, NULL);
	usleep(1);
	running = 0;
	pthread_join(consumer, NULL);
	pthread_join(producter, NULL);
	pthread_mutex_destroy(&mutex);
	
	return 0;
}
```

## signal

```c++
#include <cstdio>
#include <cstdlib>
#include <csignal>
#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>
#include <iostream>

sem_t sem;
int running = 1;

void *producterFun(void *arg) {
	int semval = 0;
	while (running) {
		usleep(1);
		sem_post(&sem);
		sem_getvalue(&sem, &semval);
		std::cout << "product: " << semval << std::endl;
	}
}

void *consumerFun(void *arg) {
	int semval = 0;
	while (running) {
		usleep(1);
		sem_wait(&sem);
		sem_getvalue(&sem, &semval);
		std::cout << "consumer: " << semval << std::endl;
	}
}



int main() {
	pthread_t consumer, producter;
	sem_init(&sem, 0, 16);
	pthread_create(&producter, NULL, producterFun, NULL);
	pthread_create(&consumer, NULL, consumerFun, NULL);
	usleep(1);
	running = 0;
	pthread_join(consumer, NULL);
	pthread_join(producter, NULL);
	sem_destroy(&sem);
	
	return 0;
}
```

[back](./)