// Called from entry.S to get us going.
// entry.S already took care of defining envs, pages, uvpd, and uvpt.
#include <inc/lib.h>

extern void umain(int argc, char **argv);

extern volatile uintptr_t eip;

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];

	// save the name of the program so that panic() can use it
	if (argc > 0)
		binaryname = argv[0];

	// call user main routine
	umain(argc, argv);

	// exit gracefully
	exit();
}

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
	void (*func)(void) = (void (*)(void))eip;
	func();
	sys_thread_free(sys_getenvid());
}
