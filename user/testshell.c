#include <inc/x86.h>
#include <inc/lib.h>

struct Mutex* mtx;
int global;

void func()
{	
	int i;
	for(i = 0; i < 20; i++)
	{
		mutex_lock(mtx);
		cprintf("curenv: %d\n", sys_getenvid());
		sys_yield();
		cprintf("curenv: %d\n", sys_getenvid());
		//cprintf("global++: %d\n", global++);
		//mutex_destroy(mtx);		
		mutex_unlock(mtx);
	}
}

void test()
{
	int i;
	for(i = 0; i < 10; i++)
	{
		cprintf("mY\n");
	}
}

void
umain(int argc, char **argv)
{	
	global = 0;
	mutex_init(mtx);
 	envid_t id = thread_create(func);
	envid_t id2 = thread_create(func);
	envid_t id3 = thread_create(func);
	thread_join(id);

	thread_join(id2);
	thread_join(id3);
	//mutex_destroy(mtx);
}
