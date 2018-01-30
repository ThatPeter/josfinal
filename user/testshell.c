#include <inc/x86.h>
#include <inc/lib.h>

struct Mutex* mtx;
int global;
void func()
{	
	int i;
	for(i = 0; i < 10; i++)
	{
	mutex_lock(mtx);
		cprintf("global++: %d\n", global++);

	mutex_unlock(mtx);
	}
}


void test()
{
	int i;
	for(i = 0; i < 10; i++)
	{
		cprintf("BYE\n");
	}
}

void
umain(int argc, char **argv)
{	
global = 0;
	mutex_init(mtx);
 	envid_t id = thread_create(func);
	envid_t id2 = thread_create(func);
	thread_join(id);
	thread_join(id2);
	/*envid_t id2 = thread_create(test);
	thread_create(func);
	thread_create(test);
	
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id2);*/
}
