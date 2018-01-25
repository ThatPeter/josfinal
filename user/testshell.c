#include <inc/x86.h>
#include <inc/lib.h>

//TESTING THREADS CUZ I CANT DO MAKEFILES

void func()
{	
	int i;
	for(i = 0; i < 10; i++)
	{
		cprintf("HI\n");
	}
	//sys_thread_free(sys_getenvid());
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
	envid_t id = thread_create(func);
	envid_t id2 = thread_create(test);
	thread_create(func);
	thread_create(test);
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id);
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id2);
}
