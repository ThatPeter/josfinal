#include <inc/x86.h>
#include <inc/lib.h>

//TESTING THREADS CUZ I CANT DO MAKEFILES


void func()
{	
	int i;
	for(i = 0; i < 10; i++)
	{
		cprintf("HI \n");	
	}
}


void
umain(int argc, char **argv)
{
	envid_t id = thread_create(func);
	cprintf("\nTHREAD CREATE RETURNED: %d\n\n", id);
	//exit();
}
