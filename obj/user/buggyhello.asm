
obj/user/buggyhello.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 88 00 00 00       	call   8000ca <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 f1 00 00 00       	call   800148 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x30>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 2a 00 00 00       	call   8000b0 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800096:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80009b:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80009d:	e8 a6 00 00 00       	call   800148 <sys_getenvid>
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	50                   	push   %eax
  8000a6:	e8 ec 02 00 00       	call   800397 <sys_thread_free>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b6:	e8 e8 09 00 00       	call   800aa3 <close_all>
	sys_env_destroy(0);
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	6a 00                	push   $0x0
  8000c0:	e8 42 00 00 00       	call   800107 <sys_env_destroy>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	89 c3                	mov    %eax,%ebx
  8000dd:	89 c7                	mov    %eax,%edi
  8000df:	89 c6                	mov    %eax,%esi
  8000e1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f8:	89 d1                	mov    %edx,%ecx
  8000fa:	89 d3                	mov    %edx,%ebx
  8000fc:	89 d7                	mov    %edx,%edi
  8000fe:	89 d6                	mov    %edx,%esi
  800100:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5f                   	pop    %edi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	57                   	push   %edi
  80010b:	56                   	push   %esi
  80010c:	53                   	push   %ebx
  80010d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800110:	b9 00 00 00 00       	mov    $0x0,%ecx
  800115:	b8 03 00 00 00       	mov    $0x3,%eax
  80011a:	8b 55 08             	mov    0x8(%ebp),%edx
  80011d:	89 cb                	mov    %ecx,%ebx
  80011f:	89 cf                	mov    %ecx,%edi
  800121:	89 ce                	mov    %ecx,%esi
  800123:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800125:	85 c0                	test   %eax,%eax
  800127:	7e 17                	jle    800140 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	50                   	push   %eax
  80012d:	6a 03                	push   $0x3
  80012f:	68 0a 24 80 00       	push   $0x80240a
  800134:	6a 23                	push   $0x23
  800136:	68 27 24 80 00       	push   $0x802427
  80013b:	e8 94 14 00 00       	call   8015d4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800140:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5f                   	pop    %edi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	57                   	push   %edi
  80014c:	56                   	push   %esi
  80014d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014e:	ba 00 00 00 00       	mov    $0x0,%edx
  800153:	b8 02 00 00 00       	mov    $0x2,%eax
  800158:	89 d1                	mov    %edx,%ecx
  80015a:	89 d3                	mov    %edx,%ebx
  80015c:	89 d7                	mov    %edx,%edi
  80015e:	89 d6                	mov    %edx,%esi
  800160:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800162:	5b                   	pop    %ebx
  800163:	5e                   	pop    %esi
  800164:	5f                   	pop    %edi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <sys_yield>:

void
sys_yield(void)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016d:	ba 00 00 00 00       	mov    $0x0,%edx
  800172:	b8 0b 00 00 00       	mov    $0xb,%eax
  800177:	89 d1                	mov    %edx,%ecx
  800179:	89 d3                	mov    %edx,%ebx
  80017b:	89 d7                	mov    %edx,%edi
  80017d:	89 d6                	mov    %edx,%esi
  80017f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5f                   	pop    %edi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    

00800186 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	57                   	push   %edi
  80018a:	56                   	push   %esi
  80018b:	53                   	push   %ebx
  80018c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018f:	be 00 00 00 00       	mov    $0x0,%esi
  800194:	b8 04 00 00 00       	mov    $0x4,%eax
  800199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019c:	8b 55 08             	mov    0x8(%ebp),%edx
  80019f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a2:	89 f7                	mov    %esi,%edi
  8001a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a6:	85 c0                	test   %eax,%eax
  8001a8:	7e 17                	jle    8001c1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001aa:	83 ec 0c             	sub    $0xc,%esp
  8001ad:	50                   	push   %eax
  8001ae:	6a 04                	push   $0x4
  8001b0:	68 0a 24 80 00       	push   $0x80240a
  8001b5:	6a 23                	push   $0x23
  8001b7:	68 27 24 80 00       	push   $0x802427
  8001bc:	e8 13 14 00 00       	call   8015d4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001da:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	7e 17                	jle    800203 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	50                   	push   %eax
  8001f0:	6a 05                	push   $0x5
  8001f2:	68 0a 24 80 00       	push   $0x80240a
  8001f7:	6a 23                	push   $0x23
  8001f9:	68 27 24 80 00       	push   $0x802427
  8001fe:	e8 d1 13 00 00       	call   8015d4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5f                   	pop    %edi
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    

0080020b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800214:	bb 00 00 00 00       	mov    $0x0,%ebx
  800219:	b8 06 00 00 00       	mov    $0x6,%eax
  80021e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800221:	8b 55 08             	mov    0x8(%ebp),%edx
  800224:	89 df                	mov    %ebx,%edi
  800226:	89 de                	mov    %ebx,%esi
  800228:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80022a:	85 c0                	test   %eax,%eax
  80022c:	7e 17                	jle    800245 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022e:	83 ec 0c             	sub    $0xc,%esp
  800231:	50                   	push   %eax
  800232:	6a 06                	push   $0x6
  800234:	68 0a 24 80 00       	push   $0x80240a
  800239:	6a 23                	push   $0x23
  80023b:	68 27 24 80 00       	push   $0x802427
  800240:	e8 8f 13 00 00       	call   8015d4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800245:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800248:	5b                   	pop    %ebx
  800249:	5e                   	pop    %esi
  80024a:	5f                   	pop    %edi
  80024b:	5d                   	pop    %ebp
  80024c:	c3                   	ret    

0080024d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	57                   	push   %edi
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	b8 08 00 00 00       	mov    $0x8,%eax
  800260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800263:	8b 55 08             	mov    0x8(%ebp),%edx
  800266:	89 df                	mov    %ebx,%edi
  800268:	89 de                	mov    %ebx,%esi
  80026a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80026c:	85 c0                	test   %eax,%eax
  80026e:	7e 17                	jle    800287 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	50                   	push   %eax
  800274:	6a 08                	push   $0x8
  800276:	68 0a 24 80 00       	push   $0x80240a
  80027b:	6a 23                	push   $0x23
  80027d:	68 27 24 80 00       	push   $0x802427
  800282:	e8 4d 13 00 00       	call   8015d4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	57                   	push   %edi
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
  800295:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	7e 17                	jle    8002c9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	83 ec 0c             	sub    $0xc,%esp
  8002b5:	50                   	push   %eax
  8002b6:	6a 09                	push   $0x9
  8002b8:	68 0a 24 80 00       	push   $0x80240a
  8002bd:	6a 23                	push   $0x23
  8002bf:	68 27 24 80 00       	push   $0x802427
  8002c4:	e8 0b 13 00 00       	call   8015d4 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cc:	5b                   	pop    %ebx
  8002cd:	5e                   	pop    %esi
  8002ce:	5f                   	pop    %edi
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ea:	89 df                	mov    %ebx,%edi
  8002ec:	89 de                	mov    %ebx,%esi
  8002ee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f0:	85 c0                	test   %eax,%eax
  8002f2:	7e 17                	jle    80030b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	50                   	push   %eax
  8002f8:	6a 0a                	push   $0xa
  8002fa:	68 0a 24 80 00       	push   $0x80240a
  8002ff:	6a 23                	push   $0x23
  800301:	68 27 24 80 00       	push   $0x802427
  800306:	e8 c9 12 00 00       	call   8015d4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800319:	be 00 00 00 00       	mov    $0x0,%esi
  80031e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	57                   	push   %edi
  80033a:	56                   	push   %esi
  80033b:	53                   	push   %ebx
  80033c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800344:	b8 0d 00 00 00       	mov    $0xd,%eax
  800349:	8b 55 08             	mov    0x8(%ebp),%edx
  80034c:	89 cb                	mov    %ecx,%ebx
  80034e:	89 cf                	mov    %ecx,%edi
  800350:	89 ce                	mov    %ecx,%esi
  800352:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800354:	85 c0                	test   %eax,%eax
  800356:	7e 17                	jle    80036f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	50                   	push   %eax
  80035c:	6a 0d                	push   $0xd
  80035e:	68 0a 24 80 00       	push   $0x80240a
  800363:	6a 23                	push   $0x23
  800365:	68 27 24 80 00       	push   $0x802427
  80036a:	e8 65 12 00 00       	call   8015d4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800372:	5b                   	pop    %ebx
  800373:	5e                   	pop    %esi
  800374:	5f                   	pop    %edi
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	57                   	push   %edi
  80037b:	56                   	push   %esi
  80037c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800382:	b8 0e 00 00 00       	mov    $0xe,%eax
  800387:	8b 55 08             	mov    0x8(%ebp),%edx
  80038a:	89 cb                	mov    %ecx,%ebx
  80038c:	89 cf                	mov    %ecx,%edi
  80038e:	89 ce                	mov    %ecx,%esi
  800390:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	89 cb                	mov    %ecx,%ebx
  8003ac:	89 cf                	mov    %ecx,%edi
  8003ae:	89 ce                	mov    %ecx,%esi
  8003b0:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003b2:	5b                   	pop    %ebx
  8003b3:	5e                   	pop    %esi
  8003b4:	5f                   	pop    %edi
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	57                   	push   %edi
  8003bb:	56                   	push   %esi
  8003bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c2:	b8 10 00 00 00       	mov    $0x10,%eax
  8003c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ca:	89 cb                	mov    %ecx,%ebx
  8003cc:	89 cf                	mov    %ecx,%edi
  8003ce:	89 ce                	mov    %ecx,%esi
  8003d0:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	53                   	push   %ebx
  8003db:	83 ec 04             	sub    $0x4,%esp
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003e1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003e3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003e7:	74 11                	je     8003fa <pgfault+0x23>
  8003e9:	89 d8                	mov    %ebx,%eax
  8003eb:	c1 e8 0c             	shr    $0xc,%eax
  8003ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003f5:	f6 c4 08             	test   $0x8,%ah
  8003f8:	75 14                	jne    80040e <pgfault+0x37>
		panic("faulting access");
  8003fa:	83 ec 04             	sub    $0x4,%esp
  8003fd:	68 35 24 80 00       	push   $0x802435
  800402:	6a 1f                	push   $0x1f
  800404:	68 45 24 80 00       	push   $0x802445
  800409:	e8 c6 11 00 00       	call   8015d4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  80040e:	83 ec 04             	sub    $0x4,%esp
  800411:	6a 07                	push   $0x7
  800413:	68 00 f0 7f 00       	push   $0x7ff000
  800418:	6a 00                	push   $0x0
  80041a:	e8 67 fd ff ff       	call   800186 <sys_page_alloc>
	if (r < 0) {
  80041f:	83 c4 10             	add    $0x10,%esp
  800422:	85 c0                	test   %eax,%eax
  800424:	79 12                	jns    800438 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800426:	50                   	push   %eax
  800427:	68 50 24 80 00       	push   $0x802450
  80042c:	6a 2d                	push   $0x2d
  80042e:	68 45 24 80 00       	push   $0x802445
  800433:	e8 9c 11 00 00       	call   8015d4 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800438:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80043e:	83 ec 04             	sub    $0x4,%esp
  800441:	68 00 10 00 00       	push   $0x1000
  800446:	53                   	push   %ebx
  800447:	68 00 f0 7f 00       	push   $0x7ff000
  80044c:	e8 db 19 00 00       	call   801e2c <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800451:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800458:	53                   	push   %ebx
  800459:	6a 00                	push   $0x0
  80045b:	68 00 f0 7f 00       	push   $0x7ff000
  800460:	6a 00                	push   $0x0
  800462:	e8 62 fd ff ff       	call   8001c9 <sys_page_map>
	if (r < 0) {
  800467:	83 c4 20             	add    $0x20,%esp
  80046a:	85 c0                	test   %eax,%eax
  80046c:	79 12                	jns    800480 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80046e:	50                   	push   %eax
  80046f:	68 50 24 80 00       	push   $0x802450
  800474:	6a 34                	push   $0x34
  800476:	68 45 24 80 00       	push   $0x802445
  80047b:	e8 54 11 00 00       	call   8015d4 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	68 00 f0 7f 00       	push   $0x7ff000
  800488:	6a 00                	push   $0x0
  80048a:	e8 7c fd ff ff       	call   80020b <sys_page_unmap>
	if (r < 0) {
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 c0                	test   %eax,%eax
  800494:	79 12                	jns    8004a8 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800496:	50                   	push   %eax
  800497:	68 50 24 80 00       	push   $0x802450
  80049c:	6a 38                	push   $0x38
  80049e:	68 45 24 80 00       	push   $0x802445
  8004a3:	e8 2c 11 00 00       	call   8015d4 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ab:	c9                   	leave  
  8004ac:	c3                   	ret    

008004ad <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	57                   	push   %edi
  8004b1:	56                   	push   %esi
  8004b2:	53                   	push   %ebx
  8004b3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004b6:	68 d7 03 80 00       	push   $0x8003d7
  8004bb:	e8 b9 1a 00 00       	call   801f79 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004c0:	b8 07 00 00 00       	mov    $0x7,%eax
  8004c5:	cd 30                	int    $0x30
  8004c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	79 17                	jns    8004e8 <fork+0x3b>
		panic("fork fault %e");
  8004d1:	83 ec 04             	sub    $0x4,%esp
  8004d4:	68 69 24 80 00       	push   $0x802469
  8004d9:	68 85 00 00 00       	push   $0x85
  8004de:	68 45 24 80 00       	push   $0x802445
  8004e3:	e8 ec 10 00 00       	call   8015d4 <_panic>
  8004e8:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ee:	75 24                	jne    800514 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004f0:	e8 53 fc ff ff       	call   800148 <sys_getenvid>
  8004f5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004fa:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800500:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800505:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	e9 64 01 00 00       	jmp    800678 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800514:	83 ec 04             	sub    $0x4,%esp
  800517:	6a 07                	push   $0x7
  800519:	68 00 f0 bf ee       	push   $0xeebff000
  80051e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800521:	e8 60 fc ff ff       	call   800186 <sys_page_alloc>
  800526:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80052e:	89 d8                	mov    %ebx,%eax
  800530:	c1 e8 16             	shr    $0x16,%eax
  800533:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80053a:	a8 01                	test   $0x1,%al
  80053c:	0f 84 fc 00 00 00    	je     80063e <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800542:	89 d8                	mov    %ebx,%eax
  800544:	c1 e8 0c             	shr    $0xc,%eax
  800547:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80054e:	f6 c2 01             	test   $0x1,%dl
  800551:	0f 84 e7 00 00 00    	je     80063e <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800557:	89 c6                	mov    %eax,%esi
  800559:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80055c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800563:	f6 c6 04             	test   $0x4,%dh
  800566:	74 39                	je     8005a1 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800568:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80056f:	83 ec 0c             	sub    $0xc,%esp
  800572:	25 07 0e 00 00       	and    $0xe07,%eax
  800577:	50                   	push   %eax
  800578:	56                   	push   %esi
  800579:	57                   	push   %edi
  80057a:	56                   	push   %esi
  80057b:	6a 00                	push   $0x0
  80057d:	e8 47 fc ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  800582:	83 c4 20             	add    $0x20,%esp
  800585:	85 c0                	test   %eax,%eax
  800587:	0f 89 b1 00 00 00    	jns    80063e <fork+0x191>
		    	panic("sys page map fault %e");
  80058d:	83 ec 04             	sub    $0x4,%esp
  800590:	68 77 24 80 00       	push   $0x802477
  800595:	6a 55                	push   $0x55
  800597:	68 45 24 80 00       	push   $0x802445
  80059c:	e8 33 10 00 00       	call   8015d4 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8005a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a8:	f6 c2 02             	test   $0x2,%dl
  8005ab:	75 0c                	jne    8005b9 <fork+0x10c>
  8005ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b4:	f6 c4 08             	test   $0x8,%ah
  8005b7:	74 5b                	je     800614 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	68 05 08 00 00       	push   $0x805
  8005c1:	56                   	push   %esi
  8005c2:	57                   	push   %edi
  8005c3:	56                   	push   %esi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 fe fb ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  8005cb:	83 c4 20             	add    $0x20,%esp
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	79 14                	jns    8005e6 <fork+0x139>
		    	panic("sys page map fault %e");
  8005d2:	83 ec 04             	sub    $0x4,%esp
  8005d5:	68 77 24 80 00       	push   $0x802477
  8005da:	6a 5c                	push   $0x5c
  8005dc:	68 45 24 80 00       	push   $0x802445
  8005e1:	e8 ee 0f 00 00       	call   8015d4 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005e6:	83 ec 0c             	sub    $0xc,%esp
  8005e9:	68 05 08 00 00       	push   $0x805
  8005ee:	56                   	push   %esi
  8005ef:	6a 00                	push   $0x0
  8005f1:	56                   	push   %esi
  8005f2:	6a 00                	push   $0x0
  8005f4:	e8 d0 fb ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  8005f9:	83 c4 20             	add    $0x20,%esp
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	79 3e                	jns    80063e <fork+0x191>
		    	panic("sys page map fault %e");
  800600:	83 ec 04             	sub    $0x4,%esp
  800603:	68 77 24 80 00       	push   $0x802477
  800608:	6a 60                	push   $0x60
  80060a:	68 45 24 80 00       	push   $0x802445
  80060f:	e8 c0 0f 00 00       	call   8015d4 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800614:	83 ec 0c             	sub    $0xc,%esp
  800617:	6a 05                	push   $0x5
  800619:	56                   	push   %esi
  80061a:	57                   	push   %edi
  80061b:	56                   	push   %esi
  80061c:	6a 00                	push   $0x0
  80061e:	e8 a6 fb ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  800623:	83 c4 20             	add    $0x20,%esp
  800626:	85 c0                	test   %eax,%eax
  800628:	79 14                	jns    80063e <fork+0x191>
		    	panic("sys page map fault %e");
  80062a:	83 ec 04             	sub    $0x4,%esp
  80062d:	68 77 24 80 00       	push   $0x802477
  800632:	6a 65                	push   $0x65
  800634:	68 45 24 80 00       	push   $0x802445
  800639:	e8 96 0f 00 00       	call   8015d4 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80063e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800644:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80064a:	0f 85 de fe ff ff    	jne    80052e <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800650:	a1 04 40 80 00       	mov    0x804004,%eax
  800655:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	50                   	push   %eax
  80065f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800662:	57                   	push   %edi
  800663:	e8 69 fc ff ff       	call   8002d1 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800668:	83 c4 08             	add    $0x8,%esp
  80066b:	6a 02                	push   $0x2
  80066d:	57                   	push   %edi
  80066e:	e8 da fb ff ff       	call   80024d <sys_env_set_status>
	
	return envid;
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <sfork>:

envid_t
sfork(void)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800683:	b8 00 00 00 00       	mov    $0x0,%eax
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800698:	68 90 00 80 00       	push   $0x800090
  80069d:	e8 d5 fc ff ff       	call   800377 <sys_thread_create>

	return id;
}
  8006a2:	c9                   	leave  
  8006a3:	c3                   	ret    

008006a4 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8006aa:	ff 75 08             	pushl  0x8(%ebp)
  8006ad:	e8 e5 fc ff ff       	call   800397 <sys_thread_free>
}
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8006bd:	ff 75 08             	pushl  0x8(%ebp)
  8006c0:	e8 f2 fc ff ff       	call   8003b7 <sys_thread_join>
}
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	56                   	push   %esi
  8006ce:	53                   	push   %ebx
  8006cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006d5:	83 ec 04             	sub    $0x4,%esp
  8006d8:	6a 07                	push   $0x7
  8006da:	6a 00                	push   $0x0
  8006dc:	56                   	push   %esi
  8006dd:	e8 a4 fa ff ff       	call   800186 <sys_page_alloc>
	if (r < 0) {
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	79 15                	jns    8006fe <queue_append+0x34>
		panic("%e\n", r);
  8006e9:	50                   	push   %eax
  8006ea:	68 bd 24 80 00       	push   $0x8024bd
  8006ef:	68 d5 00 00 00       	push   $0xd5
  8006f4:	68 45 24 80 00       	push   $0x802445
  8006f9:	e8 d6 0e 00 00       	call   8015d4 <_panic>
	}	

	wt->envid = envid;
  8006fe:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  800704:	83 3b 00             	cmpl   $0x0,(%ebx)
  800707:	75 13                	jne    80071c <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  800709:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800710:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800717:	00 00 00 
  80071a:	eb 1b                	jmp    800737 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  80071c:	8b 43 04             	mov    0x4(%ebx),%eax
  80071f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800726:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80072d:	00 00 00 
		queue->last = wt;
  800730:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  800737:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80073a:	5b                   	pop    %ebx
  80073b:	5e                   	pop    %esi
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  800747:	8b 02                	mov    (%edx),%eax
  800749:	85 c0                	test   %eax,%eax
  80074b:	75 17                	jne    800764 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  80074d:	83 ec 04             	sub    $0x4,%esp
  800750:	68 8d 24 80 00       	push   $0x80248d
  800755:	68 ec 00 00 00       	push   $0xec
  80075a:	68 45 24 80 00       	push   $0x802445
  80075f:	e8 70 0e 00 00       	call   8015d4 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  800764:	8b 48 04             	mov    0x4(%eax),%ecx
  800767:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  800769:	8b 00                	mov    (%eax),%eax
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    

0080076d <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	56                   	push   %esi
  800771:	53                   	push   %ebx
  800772:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800775:	b8 01 00 00 00       	mov    $0x1,%eax
  80077a:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80077d:	85 c0                	test   %eax,%eax
  80077f:	74 4a                	je     8007cb <mutex_lock+0x5e>
  800781:	8b 73 04             	mov    0x4(%ebx),%esi
  800784:	83 3e 00             	cmpl   $0x0,(%esi)
  800787:	75 42                	jne    8007cb <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  800789:	e8 ba f9 ff ff       	call   800148 <sys_getenvid>
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	56                   	push   %esi
  800792:	50                   	push   %eax
  800793:	e8 32 ff ff ff       	call   8006ca <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800798:	e8 ab f9 ff ff       	call   800148 <sys_getenvid>
  80079d:	83 c4 08             	add    $0x8,%esp
  8007a0:	6a 04                	push   $0x4
  8007a2:	50                   	push   %eax
  8007a3:	e8 a5 fa ff ff       	call   80024d <sys_env_set_status>

		if (r < 0) {
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	79 15                	jns    8007c4 <mutex_lock+0x57>
			panic("%e\n", r);
  8007af:	50                   	push   %eax
  8007b0:	68 bd 24 80 00       	push   $0x8024bd
  8007b5:	68 02 01 00 00       	push   $0x102
  8007ba:	68 45 24 80 00       	push   $0x802445
  8007bf:	e8 10 0e 00 00       	call   8015d4 <_panic>
		}
		sys_yield();
  8007c4:	e8 9e f9 ff ff       	call   800167 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007c9:	eb 08                	jmp    8007d3 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8007cb:	e8 78 f9 ff ff       	call   800148 <sys_getenvid>
  8007d0:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8007d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	83 ec 04             	sub    $0x4,%esp
  8007e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e9:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8007ec:	8b 43 04             	mov    0x4(%ebx),%eax
  8007ef:	83 38 00             	cmpl   $0x0,(%eax)
  8007f2:	74 33                	je     800827 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8007f4:	83 ec 0c             	sub    $0xc,%esp
  8007f7:	50                   	push   %eax
  8007f8:	e8 41 ff ff ff       	call   80073e <queue_pop>
  8007fd:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800800:	83 c4 08             	add    $0x8,%esp
  800803:	6a 02                	push   $0x2
  800805:	50                   	push   %eax
  800806:	e8 42 fa ff ff       	call   80024d <sys_env_set_status>
		if (r < 0) {
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	79 15                	jns    800827 <mutex_unlock+0x4d>
			panic("%e\n", r);
  800812:	50                   	push   %eax
  800813:	68 bd 24 80 00       	push   $0x8024bd
  800818:	68 16 01 00 00       	push   $0x116
  80081d:	68 45 24 80 00       	push   $0x802445
  800822:	e8 ad 0d 00 00       	call   8015d4 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  800827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	83 ec 04             	sub    $0x4,%esp
  800833:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800836:	e8 0d f9 ff ff       	call   800148 <sys_getenvid>
  80083b:	83 ec 04             	sub    $0x4,%esp
  80083e:	6a 07                	push   $0x7
  800840:	53                   	push   %ebx
  800841:	50                   	push   %eax
  800842:	e8 3f f9 ff ff       	call   800186 <sys_page_alloc>
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	85 c0                	test   %eax,%eax
  80084c:	79 15                	jns    800863 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80084e:	50                   	push   %eax
  80084f:	68 a8 24 80 00       	push   $0x8024a8
  800854:	68 22 01 00 00       	push   $0x122
  800859:	68 45 24 80 00       	push   $0x802445
  80085e:	e8 71 0d 00 00       	call   8015d4 <_panic>
	}	
	mtx->locked = 0;
  800863:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  800869:	8b 43 04             	mov    0x4(%ebx),%eax
  80086c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800872:	8b 43 04             	mov    0x4(%ebx),%eax
  800875:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80087c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  800883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800886:	c9                   	leave  
  800887:	c3                   	ret    

00800888 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	83 ec 04             	sub    $0x4,%esp
  80088f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  800892:	eb 21                	jmp    8008b5 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  800894:	83 ec 0c             	sub    $0xc,%esp
  800897:	50                   	push   %eax
  800898:	e8 a1 fe ff ff       	call   80073e <queue_pop>
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	6a 02                	push   $0x2
  8008a2:	50                   	push   %eax
  8008a3:	e8 a5 f9 ff ff       	call   80024d <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  8008a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8008ab:	8b 10                	mov    (%eax),%edx
  8008ad:	8b 52 04             	mov    0x4(%edx),%edx
  8008b0:	89 10                	mov    %edx,(%eax)
  8008b2:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8008b5:	8b 43 04             	mov    0x4(%ebx),%eax
  8008b8:	83 38 00             	cmpl   $0x0,(%eax)
  8008bb:	75 d7                	jne    800894 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008bd:	83 ec 04             	sub    $0x4,%esp
  8008c0:	68 00 10 00 00       	push   $0x1000
  8008c5:	6a 00                	push   $0x0
  8008c7:	53                   	push   %ebx
  8008c8:	e8 aa 14 00 00       	call   801d77 <memset>
	mtx = NULL;
}
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d3:	c9                   	leave  
  8008d4:	c3                   	ret    

008008d5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	05 00 00 00 30       	add    $0x30000000,%eax
  8008e0:	c1 e8 0c             	shr    $0xc,%eax
}
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	05 00 00 00 30       	add    $0x30000000,%eax
  8008f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008f5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800902:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800907:	89 c2                	mov    %eax,%edx
  800909:	c1 ea 16             	shr    $0x16,%edx
  80090c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800913:	f6 c2 01             	test   $0x1,%dl
  800916:	74 11                	je     800929 <fd_alloc+0x2d>
  800918:	89 c2                	mov    %eax,%edx
  80091a:	c1 ea 0c             	shr    $0xc,%edx
  80091d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800924:	f6 c2 01             	test   $0x1,%dl
  800927:	75 09                	jne    800932 <fd_alloc+0x36>
			*fd_store = fd;
  800929:	89 01                	mov    %eax,(%ecx)
			return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
  800930:	eb 17                	jmp    800949 <fd_alloc+0x4d>
  800932:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800937:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80093c:	75 c9                	jne    800907 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80093e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800944:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800951:	83 f8 1f             	cmp    $0x1f,%eax
  800954:	77 36                	ja     80098c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800956:	c1 e0 0c             	shl    $0xc,%eax
  800959:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80095e:	89 c2                	mov    %eax,%edx
  800960:	c1 ea 16             	shr    $0x16,%edx
  800963:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80096a:	f6 c2 01             	test   $0x1,%dl
  80096d:	74 24                	je     800993 <fd_lookup+0x48>
  80096f:	89 c2                	mov    %eax,%edx
  800971:	c1 ea 0c             	shr    $0xc,%edx
  800974:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80097b:	f6 c2 01             	test   $0x1,%dl
  80097e:	74 1a                	je     80099a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
  800983:	89 02                	mov    %eax,(%edx)
	return 0;
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
  80098a:	eb 13                	jmp    80099f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80098c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800991:	eb 0c                	jmp    80099f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800993:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800998:	eb 05                	jmp    80099f <fd_lookup+0x54>
  80099a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	83 ec 08             	sub    $0x8,%esp
  8009a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009aa:	ba 40 25 80 00       	mov    $0x802540,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009af:	eb 13                	jmp    8009c4 <dev_lookup+0x23>
  8009b1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009b4:	39 08                	cmp    %ecx,(%eax)
  8009b6:	75 0c                	jne    8009c4 <dev_lookup+0x23>
			*dev = devtab[i];
  8009b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c2:	eb 31                	jmp    8009f5 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009c4:	8b 02                	mov    (%edx),%eax
  8009c6:	85 c0                	test   %eax,%eax
  8009c8:	75 e7                	jne    8009b1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8009cf:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009d5:	83 ec 04             	sub    $0x4,%esp
  8009d8:	51                   	push   %ecx
  8009d9:	50                   	push   %eax
  8009da:	68 c4 24 80 00       	push   $0x8024c4
  8009df:	e8 c9 0c 00 00       	call   8016ad <cprintf>
	*dev = 0;
  8009e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	83 ec 10             	sub    $0x10,%esp
  8009ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a08:	50                   	push   %eax
  800a09:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a0f:	c1 e8 0c             	shr    $0xc,%eax
  800a12:	50                   	push   %eax
  800a13:	e8 33 ff ff ff       	call   80094b <fd_lookup>
  800a18:	83 c4 08             	add    $0x8,%esp
  800a1b:	85 c0                	test   %eax,%eax
  800a1d:	78 05                	js     800a24 <fd_close+0x2d>
	    || fd != fd2)
  800a1f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a22:	74 0c                	je     800a30 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a24:	84 db                	test   %bl,%bl
  800a26:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2b:	0f 44 c2             	cmove  %edx,%eax
  800a2e:	eb 41                	jmp    800a71 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a30:	83 ec 08             	sub    $0x8,%esp
  800a33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a36:	50                   	push   %eax
  800a37:	ff 36                	pushl  (%esi)
  800a39:	e8 63 ff ff ff       	call   8009a1 <dev_lookup>
  800a3e:	89 c3                	mov    %eax,%ebx
  800a40:	83 c4 10             	add    $0x10,%esp
  800a43:	85 c0                	test   %eax,%eax
  800a45:	78 1a                	js     800a61 <fd_close+0x6a>
		if (dev->dev_close)
  800a47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a4a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a4d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a52:	85 c0                	test   %eax,%eax
  800a54:	74 0b                	je     800a61 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a56:	83 ec 0c             	sub    $0xc,%esp
  800a59:	56                   	push   %esi
  800a5a:	ff d0                	call   *%eax
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a61:	83 ec 08             	sub    $0x8,%esp
  800a64:	56                   	push   %esi
  800a65:	6a 00                	push   $0x0
  800a67:	e8 9f f7 ff ff       	call   80020b <sys_page_unmap>
	return r;
  800a6c:	83 c4 10             	add    $0x10,%esp
  800a6f:	89 d8                	mov    %ebx,%eax
}
  800a71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a81:	50                   	push   %eax
  800a82:	ff 75 08             	pushl  0x8(%ebp)
  800a85:	e8 c1 fe ff ff       	call   80094b <fd_lookup>
  800a8a:	83 c4 08             	add    $0x8,%esp
  800a8d:	85 c0                	test   %eax,%eax
  800a8f:	78 10                	js     800aa1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a91:	83 ec 08             	sub    $0x8,%esp
  800a94:	6a 01                	push   $0x1
  800a96:	ff 75 f4             	pushl  -0xc(%ebp)
  800a99:	e8 59 ff ff ff       	call   8009f7 <fd_close>
  800a9e:	83 c4 10             	add    $0x10,%esp
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <close_all>:

void
close_all(void)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800aaa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800aaf:	83 ec 0c             	sub    $0xc,%esp
  800ab2:	53                   	push   %ebx
  800ab3:	e8 c0 ff ff ff       	call   800a78 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ab8:	83 c3 01             	add    $0x1,%ebx
  800abb:	83 c4 10             	add    $0x10,%esp
  800abe:	83 fb 20             	cmp    $0x20,%ebx
  800ac1:	75 ec                	jne    800aaf <close_all+0xc>
		close(i);
}
  800ac3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	57                   	push   %edi
  800acc:	56                   	push   %esi
  800acd:	53                   	push   %ebx
  800ace:	83 ec 2c             	sub    $0x2c,%esp
  800ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ad4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ad7:	50                   	push   %eax
  800ad8:	ff 75 08             	pushl  0x8(%ebp)
  800adb:	e8 6b fe ff ff       	call   80094b <fd_lookup>
  800ae0:	83 c4 08             	add    $0x8,%esp
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	0f 88 c1 00 00 00    	js     800bac <dup+0xe4>
		return r;
	close(newfdnum);
  800aeb:	83 ec 0c             	sub    $0xc,%esp
  800aee:	56                   	push   %esi
  800aef:	e8 84 ff ff ff       	call   800a78 <close>

	newfd = INDEX2FD(newfdnum);
  800af4:	89 f3                	mov    %esi,%ebx
  800af6:	c1 e3 0c             	shl    $0xc,%ebx
  800af9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800aff:	83 c4 04             	add    $0x4,%esp
  800b02:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b05:	e8 db fd ff ff       	call   8008e5 <fd2data>
  800b0a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b0c:	89 1c 24             	mov    %ebx,(%esp)
  800b0f:	e8 d1 fd ff ff       	call   8008e5 <fd2data>
  800b14:	83 c4 10             	add    $0x10,%esp
  800b17:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b1a:	89 f8                	mov    %edi,%eax
  800b1c:	c1 e8 16             	shr    $0x16,%eax
  800b1f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b26:	a8 01                	test   $0x1,%al
  800b28:	74 37                	je     800b61 <dup+0x99>
  800b2a:	89 f8                	mov    %edi,%eax
  800b2c:	c1 e8 0c             	shr    $0xc,%eax
  800b2f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b36:	f6 c2 01             	test   $0x1,%dl
  800b39:	74 26                	je     800b61 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b3b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	25 07 0e 00 00       	and    $0xe07,%eax
  800b4a:	50                   	push   %eax
  800b4b:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b4e:	6a 00                	push   $0x0
  800b50:	57                   	push   %edi
  800b51:	6a 00                	push   $0x0
  800b53:	e8 71 f6 ff ff       	call   8001c9 <sys_page_map>
  800b58:	89 c7                	mov    %eax,%edi
  800b5a:	83 c4 20             	add    $0x20,%esp
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	78 2e                	js     800b8f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b61:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b64:	89 d0                	mov    %edx,%eax
  800b66:	c1 e8 0c             	shr    $0xc,%eax
  800b69:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	25 07 0e 00 00       	and    $0xe07,%eax
  800b78:	50                   	push   %eax
  800b79:	53                   	push   %ebx
  800b7a:	6a 00                	push   $0x0
  800b7c:	52                   	push   %edx
  800b7d:	6a 00                	push   $0x0
  800b7f:	e8 45 f6 ff ff       	call   8001c9 <sys_page_map>
  800b84:	89 c7                	mov    %eax,%edi
  800b86:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b89:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b8b:	85 ff                	test   %edi,%edi
  800b8d:	79 1d                	jns    800bac <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b8f:	83 ec 08             	sub    $0x8,%esp
  800b92:	53                   	push   %ebx
  800b93:	6a 00                	push   $0x0
  800b95:	e8 71 f6 ff ff       	call   80020b <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b9a:	83 c4 08             	add    $0x8,%esp
  800b9d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ba0:	6a 00                	push   $0x0
  800ba2:	e8 64 f6 ff ff       	call   80020b <sys_page_unmap>
	return r;
  800ba7:	83 c4 10             	add    $0x10,%esp
  800baa:	89 f8                	mov    %edi,%eax
}
  800bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 14             	sub    $0x14,%esp
  800bbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bc1:	50                   	push   %eax
  800bc2:	53                   	push   %ebx
  800bc3:	e8 83 fd ff ff       	call   80094b <fd_lookup>
  800bc8:	83 c4 08             	add    $0x8,%esp
  800bcb:	89 c2                	mov    %eax,%edx
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	78 70                	js     800c41 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bd1:	83 ec 08             	sub    $0x8,%esp
  800bd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bd7:	50                   	push   %eax
  800bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bdb:	ff 30                	pushl  (%eax)
  800bdd:	e8 bf fd ff ff       	call   8009a1 <dev_lookup>
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	85 c0                	test   %eax,%eax
  800be7:	78 4f                	js     800c38 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800be9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bec:	8b 42 08             	mov    0x8(%edx),%eax
  800bef:	83 e0 03             	and    $0x3,%eax
  800bf2:	83 f8 01             	cmp    $0x1,%eax
  800bf5:	75 24                	jne    800c1b <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bf7:	a1 04 40 80 00       	mov    0x804004,%eax
  800bfc:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800c02:	83 ec 04             	sub    $0x4,%esp
  800c05:	53                   	push   %ebx
  800c06:	50                   	push   %eax
  800c07:	68 05 25 80 00       	push   $0x802505
  800c0c:	e8 9c 0a 00 00       	call   8016ad <cprintf>
		return -E_INVAL;
  800c11:	83 c4 10             	add    $0x10,%esp
  800c14:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c19:	eb 26                	jmp    800c41 <read+0x8d>
	}
	if (!dev->dev_read)
  800c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1e:	8b 40 08             	mov    0x8(%eax),%eax
  800c21:	85 c0                	test   %eax,%eax
  800c23:	74 17                	je     800c3c <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c25:	83 ec 04             	sub    $0x4,%esp
  800c28:	ff 75 10             	pushl  0x10(%ebp)
  800c2b:	ff 75 0c             	pushl  0xc(%ebp)
  800c2e:	52                   	push   %edx
  800c2f:	ff d0                	call   *%eax
  800c31:	89 c2                	mov    %eax,%edx
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	eb 09                	jmp    800c41 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c38:	89 c2                	mov    %eax,%edx
  800c3a:	eb 05                	jmp    800c41 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c3c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c41:	89 d0                	mov    %edx,%eax
  800c43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c54:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5c:	eb 21                	jmp    800c7f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c5e:	83 ec 04             	sub    $0x4,%esp
  800c61:	89 f0                	mov    %esi,%eax
  800c63:	29 d8                	sub    %ebx,%eax
  800c65:	50                   	push   %eax
  800c66:	89 d8                	mov    %ebx,%eax
  800c68:	03 45 0c             	add    0xc(%ebp),%eax
  800c6b:	50                   	push   %eax
  800c6c:	57                   	push   %edi
  800c6d:	e8 42 ff ff ff       	call   800bb4 <read>
		if (m < 0)
  800c72:	83 c4 10             	add    $0x10,%esp
  800c75:	85 c0                	test   %eax,%eax
  800c77:	78 10                	js     800c89 <readn+0x41>
			return m;
		if (m == 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	74 0a                	je     800c87 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c7d:	01 c3                	add    %eax,%ebx
  800c7f:	39 f3                	cmp    %esi,%ebx
  800c81:	72 db                	jb     800c5e <readn+0x16>
  800c83:	89 d8                	mov    %ebx,%eax
  800c85:	eb 02                	jmp    800c89 <readn+0x41>
  800c87:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	53                   	push   %ebx
  800c95:	83 ec 14             	sub    $0x14,%esp
  800c98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c9e:	50                   	push   %eax
  800c9f:	53                   	push   %ebx
  800ca0:	e8 a6 fc ff ff       	call   80094b <fd_lookup>
  800ca5:	83 c4 08             	add    $0x8,%esp
  800ca8:	89 c2                	mov    %eax,%edx
  800caa:	85 c0                	test   %eax,%eax
  800cac:	78 6b                	js     800d19 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cae:	83 ec 08             	sub    $0x8,%esp
  800cb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cb4:	50                   	push   %eax
  800cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cb8:	ff 30                	pushl  (%eax)
  800cba:	e8 e2 fc ff ff       	call   8009a1 <dev_lookup>
  800cbf:	83 c4 10             	add    $0x10,%esp
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	78 4a                	js     800d10 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ccd:	75 24                	jne    800cf3 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800ccf:	a1 04 40 80 00       	mov    0x804004,%eax
  800cd4:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800cda:	83 ec 04             	sub    $0x4,%esp
  800cdd:	53                   	push   %ebx
  800cde:	50                   	push   %eax
  800cdf:	68 21 25 80 00       	push   $0x802521
  800ce4:	e8 c4 09 00 00       	call   8016ad <cprintf>
		return -E_INVAL;
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800cf1:	eb 26                	jmp    800d19 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800cf3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cf6:	8b 52 0c             	mov    0xc(%edx),%edx
  800cf9:	85 d2                	test   %edx,%edx
  800cfb:	74 17                	je     800d14 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800cfd:	83 ec 04             	sub    $0x4,%esp
  800d00:	ff 75 10             	pushl  0x10(%ebp)
  800d03:	ff 75 0c             	pushl  0xc(%ebp)
  800d06:	50                   	push   %eax
  800d07:	ff d2                	call   *%edx
  800d09:	89 c2                	mov    %eax,%edx
  800d0b:	83 c4 10             	add    $0x10,%esp
  800d0e:	eb 09                	jmp    800d19 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d10:	89 c2                	mov    %eax,%edx
  800d12:	eb 05                	jmp    800d19 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d14:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d19:	89 d0                	mov    %edx,%eax
  800d1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d1e:	c9                   	leave  
  800d1f:	c3                   	ret    

00800d20 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d26:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d29:	50                   	push   %eax
  800d2a:	ff 75 08             	pushl  0x8(%ebp)
  800d2d:	e8 19 fc ff ff       	call   80094b <fd_lookup>
  800d32:	83 c4 08             	add    $0x8,%esp
  800d35:	85 c0                	test   %eax,%eax
  800d37:	78 0e                	js     800d47 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d39:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    

00800d49 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 14             	sub    $0x14,%esp
  800d50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d53:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d56:	50                   	push   %eax
  800d57:	53                   	push   %ebx
  800d58:	e8 ee fb ff ff       	call   80094b <fd_lookup>
  800d5d:	83 c4 08             	add    $0x8,%esp
  800d60:	89 c2                	mov    %eax,%edx
  800d62:	85 c0                	test   %eax,%eax
  800d64:	78 68                	js     800dce <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d66:	83 ec 08             	sub    $0x8,%esp
  800d69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6c:	50                   	push   %eax
  800d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d70:	ff 30                	pushl  (%eax)
  800d72:	e8 2a fc ff ff       	call   8009a1 <dev_lookup>
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	78 47                	js     800dc5 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d81:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d85:	75 24                	jne    800dab <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d87:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d8c:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	53                   	push   %ebx
  800d96:	50                   	push   %eax
  800d97:	68 e4 24 80 00       	push   $0x8024e4
  800d9c:	e8 0c 09 00 00       	call   8016ad <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800da9:	eb 23                	jmp    800dce <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800dab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dae:	8b 52 18             	mov    0x18(%edx),%edx
  800db1:	85 d2                	test   %edx,%edx
  800db3:	74 14                	je     800dc9 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800db5:	83 ec 08             	sub    $0x8,%esp
  800db8:	ff 75 0c             	pushl  0xc(%ebp)
  800dbb:	50                   	push   %eax
  800dbc:	ff d2                	call   *%edx
  800dbe:	89 c2                	mov    %eax,%edx
  800dc0:	83 c4 10             	add    $0x10,%esp
  800dc3:	eb 09                	jmp    800dce <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dc5:	89 c2                	mov    %eax,%edx
  800dc7:	eb 05                	jmp    800dce <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dc9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dce:	89 d0                	mov    %edx,%eax
  800dd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	53                   	push   %ebx
  800dd9:	83 ec 14             	sub    $0x14,%esp
  800ddc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ddf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800de2:	50                   	push   %eax
  800de3:	ff 75 08             	pushl  0x8(%ebp)
  800de6:	e8 60 fb ff ff       	call   80094b <fd_lookup>
  800deb:	83 c4 08             	add    $0x8,%esp
  800dee:	89 c2                	mov    %eax,%edx
  800df0:	85 c0                	test   %eax,%eax
  800df2:	78 58                	js     800e4c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800df4:	83 ec 08             	sub    $0x8,%esp
  800df7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dfa:	50                   	push   %eax
  800dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfe:	ff 30                	pushl  (%eax)
  800e00:	e8 9c fb ff ff       	call   8009a1 <dev_lookup>
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	78 37                	js     800e43 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e13:	74 32                	je     800e47 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e15:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e18:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e1f:	00 00 00 
	stat->st_isdir = 0;
  800e22:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e29:	00 00 00 
	stat->st_dev = dev;
  800e2c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e32:	83 ec 08             	sub    $0x8,%esp
  800e35:	53                   	push   %ebx
  800e36:	ff 75 f0             	pushl  -0x10(%ebp)
  800e39:	ff 50 14             	call   *0x14(%eax)
  800e3c:	89 c2                	mov    %eax,%edx
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	eb 09                	jmp    800e4c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e43:	89 c2                	mov    %eax,%edx
  800e45:	eb 05                	jmp    800e4c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e47:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e4c:	89 d0                	mov    %edx,%eax
  800e4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e51:	c9                   	leave  
  800e52:	c3                   	ret    

00800e53 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	6a 00                	push   $0x0
  800e5d:	ff 75 08             	pushl  0x8(%ebp)
  800e60:	e8 e3 01 00 00       	call   801048 <open>
  800e65:	89 c3                	mov    %eax,%ebx
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	78 1b                	js     800e89 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e6e:	83 ec 08             	sub    $0x8,%esp
  800e71:	ff 75 0c             	pushl  0xc(%ebp)
  800e74:	50                   	push   %eax
  800e75:	e8 5b ff ff ff       	call   800dd5 <fstat>
  800e7a:	89 c6                	mov    %eax,%esi
	close(fd);
  800e7c:	89 1c 24             	mov    %ebx,(%esp)
  800e7f:	e8 f4 fb ff ff       	call   800a78 <close>
	return r;
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	89 f0                	mov    %esi,%eax
}
  800e89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	56                   	push   %esi
  800e94:	53                   	push   %ebx
  800e95:	89 c6                	mov    %eax,%esi
  800e97:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e99:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ea0:	75 12                	jne    800eb4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ea2:	83 ec 0c             	sub    $0xc,%esp
  800ea5:	6a 01                	push   $0x1
  800ea7:	e8 39 12 00 00       	call   8020e5 <ipc_find_env>
  800eac:	a3 00 40 80 00       	mov    %eax,0x804000
  800eb1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800eb4:	6a 07                	push   $0x7
  800eb6:	68 00 50 80 00       	push   $0x805000
  800ebb:	56                   	push   %esi
  800ebc:	ff 35 00 40 80 00    	pushl  0x804000
  800ec2:	e8 bc 11 00 00       	call   802083 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ec7:	83 c4 0c             	add    $0xc,%esp
  800eca:	6a 00                	push   $0x0
  800ecc:	53                   	push   %ebx
  800ecd:	6a 00                	push   $0x0
  800ecf:	e8 34 11 00 00       	call   802008 <ipc_recv>
}
  800ed4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5d                   	pop    %ebp
  800eda:	c3                   	ret    

00800edb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee4:	8b 40 0c             	mov    0xc(%eax),%eax
  800ee7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800eec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eef:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ef4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef9:	b8 02 00 00 00       	mov    $0x2,%eax
  800efe:	e8 8d ff ff ff       	call   800e90 <fsipc>
}
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    

00800f05 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0e:	8b 40 0c             	mov    0xc(%eax),%eax
  800f11:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f16:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1b:	b8 06 00 00 00       	mov    $0x6,%eax
  800f20:	e8 6b ff ff ff       	call   800e90 <fsipc>
}
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	53                   	push   %ebx
  800f2b:	83 ec 04             	sub    $0x4,%esp
  800f2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
  800f34:	8b 40 0c             	mov    0xc(%eax),%eax
  800f37:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f41:	b8 05 00 00 00       	mov    $0x5,%eax
  800f46:	e8 45 ff ff ff       	call   800e90 <fsipc>
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 2c                	js     800f7b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f4f:	83 ec 08             	sub    $0x8,%esp
  800f52:	68 00 50 80 00       	push   $0x805000
  800f57:	53                   	push   %ebx
  800f58:	e8 d5 0c 00 00       	call   801c32 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f5d:	a1 80 50 80 00       	mov    0x805080,%eax
  800f62:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f68:	a1 84 50 80 00       	mov    0x805084,%eax
  800f6d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f73:	83 c4 10             	add    $0x10,%esp
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    

00800f80 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f89:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8c:	8b 52 0c             	mov    0xc(%edx),%edx
  800f8f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f95:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f9a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800f9f:	0f 47 c2             	cmova  %edx,%eax
  800fa2:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800fa7:	50                   	push   %eax
  800fa8:	ff 75 0c             	pushl  0xc(%ebp)
  800fab:	68 08 50 80 00       	push   $0x805008
  800fb0:	e8 0f 0e 00 00       	call   801dc4 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fba:	b8 04 00 00 00       	mov    $0x4,%eax
  800fbf:	e8 cc fe ff ff       	call   800e90 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	56                   	push   %esi
  800fca:	53                   	push   %ebx
  800fcb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd1:	8b 40 0c             	mov    0xc(%eax),%eax
  800fd4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fd9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe4:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe9:	e8 a2 fe ff ff       	call   800e90 <fsipc>
  800fee:	89 c3                	mov    %eax,%ebx
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	78 4b                	js     80103f <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ff4:	39 c6                	cmp    %eax,%esi
  800ff6:	73 16                	jae    80100e <devfile_read+0x48>
  800ff8:	68 50 25 80 00       	push   $0x802550
  800ffd:	68 57 25 80 00       	push   $0x802557
  801002:	6a 7c                	push   $0x7c
  801004:	68 6c 25 80 00       	push   $0x80256c
  801009:	e8 c6 05 00 00       	call   8015d4 <_panic>
	assert(r <= PGSIZE);
  80100e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801013:	7e 16                	jle    80102b <devfile_read+0x65>
  801015:	68 77 25 80 00       	push   $0x802577
  80101a:	68 57 25 80 00       	push   $0x802557
  80101f:	6a 7d                	push   $0x7d
  801021:	68 6c 25 80 00       	push   $0x80256c
  801026:	e8 a9 05 00 00       	call   8015d4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	50                   	push   %eax
  80102f:	68 00 50 80 00       	push   $0x805000
  801034:	ff 75 0c             	pushl  0xc(%ebp)
  801037:	e8 88 0d 00 00       	call   801dc4 <memmove>
	return r;
  80103c:	83 c4 10             	add    $0x10,%esp
}
  80103f:	89 d8                	mov    %ebx,%eax
  801041:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	53                   	push   %ebx
  80104c:	83 ec 20             	sub    $0x20,%esp
  80104f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801052:	53                   	push   %ebx
  801053:	e8 a1 0b 00 00       	call   801bf9 <strlen>
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801060:	7f 67                	jg     8010c9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801068:	50                   	push   %eax
  801069:	e8 8e f8 ff ff       	call   8008fc <fd_alloc>
  80106e:	83 c4 10             	add    $0x10,%esp
		return r;
  801071:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801073:	85 c0                	test   %eax,%eax
  801075:	78 57                	js     8010ce <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801077:	83 ec 08             	sub    $0x8,%esp
  80107a:	53                   	push   %ebx
  80107b:	68 00 50 80 00       	push   $0x805000
  801080:	e8 ad 0b 00 00       	call   801c32 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801085:	8b 45 0c             	mov    0xc(%ebp),%eax
  801088:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80108d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801090:	b8 01 00 00 00       	mov    $0x1,%eax
  801095:	e8 f6 fd ff ff       	call   800e90 <fsipc>
  80109a:	89 c3                	mov    %eax,%ebx
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	79 14                	jns    8010b7 <open+0x6f>
		fd_close(fd, 0);
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	6a 00                	push   $0x0
  8010a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ab:	e8 47 f9 ff ff       	call   8009f7 <fd_close>
		return r;
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	89 da                	mov    %ebx,%edx
  8010b5:	eb 17                	jmp    8010ce <open+0x86>
	}

	return fd2num(fd);
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8010bd:	e8 13 f8 ff ff       	call   8008d5 <fd2num>
  8010c2:	89 c2                	mov    %eax,%edx
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	eb 05                	jmp    8010ce <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010c9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010ce:	89 d0                	mov    %edx,%eax
  8010d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d3:	c9                   	leave  
  8010d4:	c3                   	ret    

008010d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010db:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8010e5:	e8 a6 fd ff ff       	call   800e90 <fsipc>
}
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    

008010ec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	56                   	push   %esi
  8010f0:	53                   	push   %ebx
  8010f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010f4:	83 ec 0c             	sub    $0xc,%esp
  8010f7:	ff 75 08             	pushl  0x8(%ebp)
  8010fa:	e8 e6 f7 ff ff       	call   8008e5 <fd2data>
  8010ff:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	68 83 25 80 00       	push   $0x802583
  801109:	53                   	push   %ebx
  80110a:	e8 23 0b 00 00       	call   801c32 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80110f:	8b 46 04             	mov    0x4(%esi),%eax
  801112:	2b 06                	sub    (%esi),%eax
  801114:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80111a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801121:	00 00 00 
	stat->st_dev = &devpipe;
  801124:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80112b:	30 80 00 
	return 0;
}
  80112e:	b8 00 00 00 00       	mov    $0x0,%eax
  801133:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801136:	5b                   	pop    %ebx
  801137:	5e                   	pop    %esi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	53                   	push   %ebx
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801144:	53                   	push   %ebx
  801145:	6a 00                	push   $0x0
  801147:	e8 bf f0 ff ff       	call   80020b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80114c:	89 1c 24             	mov    %ebx,(%esp)
  80114f:	e8 91 f7 ff ff       	call   8008e5 <fd2data>
  801154:	83 c4 08             	add    $0x8,%esp
  801157:	50                   	push   %eax
  801158:	6a 00                	push   $0x0
  80115a:	e8 ac f0 ff ff       	call   80020b <sys_page_unmap>
}
  80115f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 1c             	sub    $0x1c,%esp
  80116d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801170:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801172:	a1 04 40 80 00       	mov    0x804004,%eax
  801177:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	ff 75 e0             	pushl  -0x20(%ebp)
  801183:	e8 a2 0f 00 00       	call   80212a <pageref>
  801188:	89 c3                	mov    %eax,%ebx
  80118a:	89 3c 24             	mov    %edi,(%esp)
  80118d:	e8 98 0f 00 00       	call   80212a <pageref>
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	39 c3                	cmp    %eax,%ebx
  801197:	0f 94 c1             	sete   %cl
  80119a:	0f b6 c9             	movzbl %cl,%ecx
  80119d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8011a0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011a6:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011ac:	39 ce                	cmp    %ecx,%esi
  8011ae:	74 1e                	je     8011ce <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011b0:	39 c3                	cmp    %eax,%ebx
  8011b2:	75 be                	jne    801172 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011b4:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bd:	50                   	push   %eax
  8011be:	56                   	push   %esi
  8011bf:	68 8a 25 80 00       	push   $0x80258a
  8011c4:	e8 e4 04 00 00       	call   8016ad <cprintf>
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	eb a4                	jmp    801172 <_pipeisclosed+0xe>
	}
}
  8011ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 28             	sub    $0x28,%esp
  8011e2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011e5:	56                   	push   %esi
  8011e6:	e8 fa f6 ff ff       	call   8008e5 <fd2data>
  8011eb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	bf 00 00 00 00       	mov    $0x0,%edi
  8011f5:	eb 4b                	jmp    801242 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011f7:	89 da                	mov    %ebx,%edx
  8011f9:	89 f0                	mov    %esi,%eax
  8011fb:	e8 64 ff ff ff       	call   801164 <_pipeisclosed>
  801200:	85 c0                	test   %eax,%eax
  801202:	75 48                	jne    80124c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801204:	e8 5e ef ff ff       	call   800167 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801209:	8b 43 04             	mov    0x4(%ebx),%eax
  80120c:	8b 0b                	mov    (%ebx),%ecx
  80120e:	8d 51 20             	lea    0x20(%ecx),%edx
  801211:	39 d0                	cmp    %edx,%eax
  801213:	73 e2                	jae    8011f7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801215:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801218:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80121c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80121f:	89 c2                	mov    %eax,%edx
  801221:	c1 fa 1f             	sar    $0x1f,%edx
  801224:	89 d1                	mov    %edx,%ecx
  801226:	c1 e9 1b             	shr    $0x1b,%ecx
  801229:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80122c:	83 e2 1f             	and    $0x1f,%edx
  80122f:	29 ca                	sub    %ecx,%edx
  801231:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801235:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801239:	83 c0 01             	add    $0x1,%eax
  80123c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80123f:	83 c7 01             	add    $0x1,%edi
  801242:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801245:	75 c2                	jne    801209 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801247:	8b 45 10             	mov    0x10(%ebp),%eax
  80124a:	eb 05                	jmp    801251 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80124c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801251:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5f                   	pop    %edi
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    

00801259 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	57                   	push   %edi
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
  80125f:	83 ec 18             	sub    $0x18,%esp
  801262:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801265:	57                   	push   %edi
  801266:	e8 7a f6 ff ff       	call   8008e5 <fd2data>
  80126b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	bb 00 00 00 00       	mov    $0x0,%ebx
  801275:	eb 3d                	jmp    8012b4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801277:	85 db                	test   %ebx,%ebx
  801279:	74 04                	je     80127f <devpipe_read+0x26>
				return i;
  80127b:	89 d8                	mov    %ebx,%eax
  80127d:	eb 44                	jmp    8012c3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80127f:	89 f2                	mov    %esi,%edx
  801281:	89 f8                	mov    %edi,%eax
  801283:	e8 dc fe ff ff       	call   801164 <_pipeisclosed>
  801288:	85 c0                	test   %eax,%eax
  80128a:	75 32                	jne    8012be <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80128c:	e8 d6 ee ff ff       	call   800167 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801291:	8b 06                	mov    (%esi),%eax
  801293:	3b 46 04             	cmp    0x4(%esi),%eax
  801296:	74 df                	je     801277 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801298:	99                   	cltd   
  801299:	c1 ea 1b             	shr    $0x1b,%edx
  80129c:	01 d0                	add    %edx,%eax
  80129e:	83 e0 1f             	and    $0x1f,%eax
  8012a1:	29 d0                	sub    %edx,%eax
  8012a3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8012a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ab:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012ae:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012b1:	83 c3 01             	add    $0x1,%ebx
  8012b4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012b7:	75 d8                	jne    801291 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8012bc:	eb 05                	jmp    8012c3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012be:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c6:	5b                   	pop    %ebx
  8012c7:	5e                   	pop    %esi
  8012c8:	5f                   	pop    %edi
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	56                   	push   %esi
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d6:	50                   	push   %eax
  8012d7:	e8 20 f6 ff ff       	call   8008fc <fd_alloc>
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	89 c2                	mov    %eax,%edx
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	0f 88 2c 01 00 00    	js     801415 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e9:	83 ec 04             	sub    $0x4,%esp
  8012ec:	68 07 04 00 00       	push   $0x407
  8012f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f4:	6a 00                	push   $0x0
  8012f6:	e8 8b ee ff ff       	call   800186 <sys_page_alloc>
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	85 c0                	test   %eax,%eax
  801302:	0f 88 0d 01 00 00    	js     801415 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801308:	83 ec 0c             	sub    $0xc,%esp
  80130b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130e:	50                   	push   %eax
  80130f:	e8 e8 f5 ff ff       	call   8008fc <fd_alloc>
  801314:	89 c3                	mov    %eax,%ebx
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	85 c0                	test   %eax,%eax
  80131b:	0f 88 e2 00 00 00    	js     801403 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801321:	83 ec 04             	sub    $0x4,%esp
  801324:	68 07 04 00 00       	push   $0x407
  801329:	ff 75 f0             	pushl  -0x10(%ebp)
  80132c:	6a 00                	push   $0x0
  80132e:	e8 53 ee ff ff       	call   800186 <sys_page_alloc>
  801333:	89 c3                	mov    %eax,%ebx
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	0f 88 c3 00 00 00    	js     801403 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801340:	83 ec 0c             	sub    $0xc,%esp
  801343:	ff 75 f4             	pushl  -0xc(%ebp)
  801346:	e8 9a f5 ff ff       	call   8008e5 <fd2data>
  80134b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80134d:	83 c4 0c             	add    $0xc,%esp
  801350:	68 07 04 00 00       	push   $0x407
  801355:	50                   	push   %eax
  801356:	6a 00                	push   $0x0
  801358:	e8 29 ee ff ff       	call   800186 <sys_page_alloc>
  80135d:	89 c3                	mov    %eax,%ebx
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	0f 88 89 00 00 00    	js     8013f3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	ff 75 f0             	pushl  -0x10(%ebp)
  801370:	e8 70 f5 ff ff       	call   8008e5 <fd2data>
  801375:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80137c:	50                   	push   %eax
  80137d:	6a 00                	push   $0x0
  80137f:	56                   	push   %esi
  801380:	6a 00                	push   $0x0
  801382:	e8 42 ee ff ff       	call   8001c9 <sys_page_map>
  801387:	89 c3                	mov    %eax,%ebx
  801389:	83 c4 20             	add    $0x20,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 55                	js     8013e5 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801390:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801399:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013a5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ae:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013ba:	83 ec 0c             	sub    $0xc,%esp
  8013bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c0:	e8 10 f5 ff ff       	call   8008d5 <fd2num>
  8013c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013ca:	83 c4 04             	add    $0x4,%esp
  8013cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8013d0:	e8 00 f5 ff ff       	call   8008d5 <fd2num>
  8013d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d8:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e3:	eb 30                	jmp    801415 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	56                   	push   %esi
  8013e9:	6a 00                	push   $0x0
  8013eb:	e8 1b ee ff ff       	call   80020b <sys_page_unmap>
  8013f0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f9:	6a 00                	push   $0x0
  8013fb:	e8 0b ee ff ff       	call   80020b <sys_page_unmap>
  801400:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	ff 75 f4             	pushl  -0xc(%ebp)
  801409:	6a 00                	push   $0x0
  80140b:	e8 fb ed ff ff       	call   80020b <sys_page_unmap>
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801415:	89 d0                	mov    %edx,%eax
  801417:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141a:	5b                   	pop    %ebx
  80141b:	5e                   	pop    %esi
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801424:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801427:	50                   	push   %eax
  801428:	ff 75 08             	pushl  0x8(%ebp)
  80142b:	e8 1b f5 ff ff       	call   80094b <fd_lookup>
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 18                	js     80144f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	ff 75 f4             	pushl  -0xc(%ebp)
  80143d:	e8 a3 f4 ff ff       	call   8008e5 <fd2data>
	return _pipeisclosed(fd, p);
  801442:	89 c2                	mov    %eax,%edx
  801444:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801447:	e8 18 fd ff ff       	call   801164 <_pipeisclosed>
  80144c:	83 c4 10             	add    $0x10,%esp
}
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801454:	b8 00 00 00 00       	mov    $0x0,%eax
  801459:	5d                   	pop    %ebp
  80145a:	c3                   	ret    

0080145b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801461:	68 a2 25 80 00       	push   $0x8025a2
  801466:	ff 75 0c             	pushl  0xc(%ebp)
  801469:	e8 c4 07 00 00       	call   801c32 <strcpy>
	return 0;
}
  80146e:	b8 00 00 00 00       	mov    $0x0,%eax
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	57                   	push   %edi
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
  80147b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801481:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801486:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80148c:	eb 2d                	jmp    8014bb <devcons_write+0x46>
		m = n - tot;
  80148e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801491:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801493:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801496:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80149b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	03 45 0c             	add    0xc(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	57                   	push   %edi
  8014a7:	e8 18 09 00 00       	call   801dc4 <memmove>
		sys_cputs(buf, m);
  8014ac:	83 c4 08             	add    $0x8,%esp
  8014af:	53                   	push   %ebx
  8014b0:	57                   	push   %edi
  8014b1:	e8 14 ec ff ff       	call   8000ca <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014b6:	01 de                	add    %ebx,%esi
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	89 f0                	mov    %esi,%eax
  8014bd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014c0:	72 cc                	jb     80148e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c5:	5b                   	pop    %ebx
  8014c6:	5e                   	pop    %esi
  8014c7:	5f                   	pop    %edi
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014d9:	74 2a                	je     801505 <devcons_read+0x3b>
  8014db:	eb 05                	jmp    8014e2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014dd:	e8 85 ec ff ff       	call   800167 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014e2:	e8 01 ec ff ff       	call   8000e8 <sys_cgetc>
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	74 f2                	je     8014dd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	78 16                	js     801505 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014ef:	83 f8 04             	cmp    $0x4,%eax
  8014f2:	74 0c                	je     801500 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f7:	88 02                	mov    %al,(%edx)
	return 1;
  8014f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fe:	eb 05                	jmp    801505 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801500:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80150d:	8b 45 08             	mov    0x8(%ebp),%eax
  801510:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801513:	6a 01                	push   $0x1
  801515:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801518:	50                   	push   %eax
  801519:	e8 ac eb ff ff       	call   8000ca <sys_cputs>
}
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <getchar>:

int
getchar(void)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801529:	6a 01                	push   $0x1
  80152b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80152e:	50                   	push   %eax
  80152f:	6a 00                	push   $0x0
  801531:	e8 7e f6 ff ff       	call   800bb4 <read>
	if (r < 0)
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 0f                	js     80154c <getchar+0x29>
		return r;
	if (r < 1)
  80153d:	85 c0                	test   %eax,%eax
  80153f:	7e 06                	jle    801547 <getchar+0x24>
		return -E_EOF;
	return c;
  801541:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801545:	eb 05                	jmp    80154c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801547:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80154c:	c9                   	leave  
  80154d:	c3                   	ret    

0080154e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801554:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	ff 75 08             	pushl  0x8(%ebp)
  80155b:	e8 eb f3 ff ff       	call   80094b <fd_lookup>
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 11                	js     801578 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801567:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801570:	39 10                	cmp    %edx,(%eax)
  801572:	0f 94 c0             	sete   %al
  801575:	0f b6 c0             	movzbl %al,%eax
}
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <opencons>:

int
opencons(void)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801580:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	e8 73 f3 ff ff       	call   8008fc <fd_alloc>
  801589:	83 c4 10             	add    $0x10,%esp
		return r;
  80158c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 3e                	js     8015d0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801592:	83 ec 04             	sub    $0x4,%esp
  801595:	68 07 04 00 00       	push   $0x407
  80159a:	ff 75 f4             	pushl  -0xc(%ebp)
  80159d:	6a 00                	push   $0x0
  80159f:	e8 e2 eb ff ff       	call   800186 <sys_page_alloc>
  8015a4:	83 c4 10             	add    $0x10,%esp
		return r;
  8015a7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 23                	js     8015d0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015ad:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	50                   	push   %eax
  8015c6:	e8 0a f3 ff ff       	call   8008d5 <fd2num>
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	83 c4 10             	add    $0x10,%esp
}
  8015d0:	89 d0                	mov    %edx,%eax
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	56                   	push   %esi
  8015d8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015d9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015dc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015e2:	e8 61 eb ff ff       	call   800148 <sys_getenvid>
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	ff 75 0c             	pushl  0xc(%ebp)
  8015ed:	ff 75 08             	pushl  0x8(%ebp)
  8015f0:	56                   	push   %esi
  8015f1:	50                   	push   %eax
  8015f2:	68 b0 25 80 00       	push   $0x8025b0
  8015f7:	e8 b1 00 00 00       	call   8016ad <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015fc:	83 c4 18             	add    $0x18,%esp
  8015ff:	53                   	push   %ebx
  801600:	ff 75 10             	pushl  0x10(%ebp)
  801603:	e8 54 00 00 00       	call   80165c <vcprintf>
	cprintf("\n");
  801608:	c7 04 24 a6 24 80 00 	movl   $0x8024a6,(%esp)
  80160f:	e8 99 00 00 00       	call   8016ad <cprintf>
  801614:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801617:	cc                   	int3   
  801618:	eb fd                	jmp    801617 <_panic+0x43>

0080161a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	53                   	push   %ebx
  80161e:	83 ec 04             	sub    $0x4,%esp
  801621:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801624:	8b 13                	mov    (%ebx),%edx
  801626:	8d 42 01             	lea    0x1(%edx),%eax
  801629:	89 03                	mov    %eax,(%ebx)
  80162b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80162e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801632:	3d ff 00 00 00       	cmp    $0xff,%eax
  801637:	75 1a                	jne    801653 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	68 ff 00 00 00       	push   $0xff
  801641:	8d 43 08             	lea    0x8(%ebx),%eax
  801644:	50                   	push   %eax
  801645:	e8 80 ea ff ff       	call   8000ca <sys_cputs>
		b->idx = 0;
  80164a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801650:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801653:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801665:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80166c:	00 00 00 
	b.cnt = 0;
  80166f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801676:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801679:	ff 75 0c             	pushl  0xc(%ebp)
  80167c:	ff 75 08             	pushl  0x8(%ebp)
  80167f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	68 1a 16 80 00       	push   $0x80161a
  80168b:	e8 54 01 00 00       	call   8017e4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801690:	83 c4 08             	add    $0x8,%esp
  801693:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801699:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	e8 25 ea ff ff       	call   8000ca <sys_cputs>

	return b.cnt;
}
  8016a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016b3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016b6:	50                   	push   %eax
  8016b7:	ff 75 08             	pushl  0x8(%ebp)
  8016ba:	e8 9d ff ff ff       	call   80165c <vcprintf>
	va_end(ap);

	return cnt;
}
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	57                   	push   %edi
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 1c             	sub    $0x1c,%esp
  8016ca:	89 c7                	mov    %eax,%edi
  8016cc:	89 d6                	mov    %edx,%esi
  8016ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016da:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016e5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016e8:	39 d3                	cmp    %edx,%ebx
  8016ea:	72 05                	jb     8016f1 <printnum+0x30>
  8016ec:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016ef:	77 45                	ja     801736 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016f1:	83 ec 0c             	sub    $0xc,%esp
  8016f4:	ff 75 18             	pushl  0x18(%ebp)
  8016f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8016fa:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016fd:	53                   	push   %ebx
  8016fe:	ff 75 10             	pushl  0x10(%ebp)
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	ff 75 e4             	pushl  -0x1c(%ebp)
  801707:	ff 75 e0             	pushl  -0x20(%ebp)
  80170a:	ff 75 dc             	pushl  -0x24(%ebp)
  80170d:	ff 75 d8             	pushl  -0x28(%ebp)
  801710:	e8 5b 0a 00 00       	call   802170 <__udivdi3>
  801715:	83 c4 18             	add    $0x18,%esp
  801718:	52                   	push   %edx
  801719:	50                   	push   %eax
  80171a:	89 f2                	mov    %esi,%edx
  80171c:	89 f8                	mov    %edi,%eax
  80171e:	e8 9e ff ff ff       	call   8016c1 <printnum>
  801723:	83 c4 20             	add    $0x20,%esp
  801726:	eb 18                	jmp    801740 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	56                   	push   %esi
  80172c:	ff 75 18             	pushl  0x18(%ebp)
  80172f:	ff d7                	call   *%edi
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	eb 03                	jmp    801739 <printnum+0x78>
  801736:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801739:	83 eb 01             	sub    $0x1,%ebx
  80173c:	85 db                	test   %ebx,%ebx
  80173e:	7f e8                	jg     801728 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	56                   	push   %esi
  801744:	83 ec 04             	sub    $0x4,%esp
  801747:	ff 75 e4             	pushl  -0x1c(%ebp)
  80174a:	ff 75 e0             	pushl  -0x20(%ebp)
  80174d:	ff 75 dc             	pushl  -0x24(%ebp)
  801750:	ff 75 d8             	pushl  -0x28(%ebp)
  801753:	e8 48 0b 00 00       	call   8022a0 <__umoddi3>
  801758:	83 c4 14             	add    $0x14,%esp
  80175b:	0f be 80 d3 25 80 00 	movsbl 0x8025d3(%eax),%eax
  801762:	50                   	push   %eax
  801763:	ff d7                	call   *%edi
}
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176b:	5b                   	pop    %ebx
  80176c:	5e                   	pop    %esi
  80176d:	5f                   	pop    %edi
  80176e:	5d                   	pop    %ebp
  80176f:	c3                   	ret    

00801770 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801773:	83 fa 01             	cmp    $0x1,%edx
  801776:	7e 0e                	jle    801786 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801778:	8b 10                	mov    (%eax),%edx
  80177a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80177d:	89 08                	mov    %ecx,(%eax)
  80177f:	8b 02                	mov    (%edx),%eax
  801781:	8b 52 04             	mov    0x4(%edx),%edx
  801784:	eb 22                	jmp    8017a8 <getuint+0x38>
	else if (lflag)
  801786:	85 d2                	test   %edx,%edx
  801788:	74 10                	je     80179a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80178a:	8b 10                	mov    (%eax),%edx
  80178c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80178f:	89 08                	mov    %ecx,(%eax)
  801791:	8b 02                	mov    (%edx),%eax
  801793:	ba 00 00 00 00       	mov    $0x0,%edx
  801798:	eb 0e                	jmp    8017a8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80179a:	8b 10                	mov    (%eax),%edx
  80179c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80179f:	89 08                	mov    %ecx,(%eax)
  8017a1:	8b 02                	mov    (%edx),%eax
  8017a3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017b0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017b4:	8b 10                	mov    (%eax),%edx
  8017b6:	3b 50 04             	cmp    0x4(%eax),%edx
  8017b9:	73 0a                	jae    8017c5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017bb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017be:	89 08                	mov    %ecx,(%eax)
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	88 02                	mov    %al,(%edx)
}
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017cd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017d0:	50                   	push   %eax
  8017d1:	ff 75 10             	pushl  0x10(%ebp)
  8017d4:	ff 75 0c             	pushl  0xc(%ebp)
  8017d7:	ff 75 08             	pushl  0x8(%ebp)
  8017da:	e8 05 00 00 00       	call   8017e4 <vprintfmt>
	va_end(ap);
}
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	57                   	push   %edi
  8017e8:	56                   	push   %esi
  8017e9:	53                   	push   %ebx
  8017ea:	83 ec 2c             	sub    $0x2c,%esp
  8017ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017f3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017f6:	eb 12                	jmp    80180a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	0f 84 89 03 00 00    	je     801b89 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	53                   	push   %ebx
  801804:	50                   	push   %eax
  801805:	ff d6                	call   *%esi
  801807:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80180a:	83 c7 01             	add    $0x1,%edi
  80180d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801811:	83 f8 25             	cmp    $0x25,%eax
  801814:	75 e2                	jne    8017f8 <vprintfmt+0x14>
  801816:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80181a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801821:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801828:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	eb 07                	jmp    80183d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801836:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801839:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183d:	8d 47 01             	lea    0x1(%edi),%eax
  801840:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801843:	0f b6 07             	movzbl (%edi),%eax
  801846:	0f b6 c8             	movzbl %al,%ecx
  801849:	83 e8 23             	sub    $0x23,%eax
  80184c:	3c 55                	cmp    $0x55,%al
  80184e:	0f 87 1a 03 00 00    	ja     801b6e <vprintfmt+0x38a>
  801854:	0f b6 c0             	movzbl %al,%eax
  801857:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  80185e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801861:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801865:	eb d6                	jmp    80183d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801867:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80186a:	b8 00 00 00 00       	mov    $0x0,%eax
  80186f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801872:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801875:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801879:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80187c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80187f:	83 fa 09             	cmp    $0x9,%edx
  801882:	77 39                	ja     8018bd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801884:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801887:	eb e9                	jmp    801872 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801889:	8b 45 14             	mov    0x14(%ebp),%eax
  80188c:	8d 48 04             	lea    0x4(%eax),%ecx
  80188f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801892:	8b 00                	mov    (%eax),%eax
  801894:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801897:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80189a:	eb 27                	jmp    8018c3 <vprintfmt+0xdf>
  80189c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018a6:	0f 49 c8             	cmovns %eax,%ecx
  8018a9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018af:	eb 8c                	jmp    80183d <vprintfmt+0x59>
  8018b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018b4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018bb:	eb 80                	jmp    80183d <vprintfmt+0x59>
  8018bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018c0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018c7:	0f 89 70 ff ff ff    	jns    80183d <vprintfmt+0x59>
				width = precision, precision = -1;
  8018cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018d3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018da:	e9 5e ff ff ff       	jmp    80183d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018df:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018e5:	e9 53 ff ff ff       	jmp    80183d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ed:	8d 50 04             	lea    0x4(%eax),%edx
  8018f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	53                   	push   %ebx
  8018f7:	ff 30                	pushl  (%eax)
  8018f9:	ff d6                	call   *%esi
			break;
  8018fb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801901:	e9 04 ff ff ff       	jmp    80180a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801906:	8b 45 14             	mov    0x14(%ebp),%eax
  801909:	8d 50 04             	lea    0x4(%eax),%edx
  80190c:	89 55 14             	mov    %edx,0x14(%ebp)
  80190f:	8b 00                	mov    (%eax),%eax
  801911:	99                   	cltd   
  801912:	31 d0                	xor    %edx,%eax
  801914:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801916:	83 f8 0f             	cmp    $0xf,%eax
  801919:	7f 0b                	jg     801926 <vprintfmt+0x142>
  80191b:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  801922:	85 d2                	test   %edx,%edx
  801924:	75 18                	jne    80193e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801926:	50                   	push   %eax
  801927:	68 eb 25 80 00       	push   $0x8025eb
  80192c:	53                   	push   %ebx
  80192d:	56                   	push   %esi
  80192e:	e8 94 fe ff ff       	call   8017c7 <printfmt>
  801933:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801936:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801939:	e9 cc fe ff ff       	jmp    80180a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80193e:	52                   	push   %edx
  80193f:	68 69 25 80 00       	push   $0x802569
  801944:	53                   	push   %ebx
  801945:	56                   	push   %esi
  801946:	e8 7c fe ff ff       	call   8017c7 <printfmt>
  80194b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80194e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801951:	e9 b4 fe ff ff       	jmp    80180a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801956:	8b 45 14             	mov    0x14(%ebp),%eax
  801959:	8d 50 04             	lea    0x4(%eax),%edx
  80195c:	89 55 14             	mov    %edx,0x14(%ebp)
  80195f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801961:	85 ff                	test   %edi,%edi
  801963:	b8 e4 25 80 00       	mov    $0x8025e4,%eax
  801968:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80196b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80196f:	0f 8e 94 00 00 00    	jle    801a09 <vprintfmt+0x225>
  801975:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801979:	0f 84 98 00 00 00    	je     801a17 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	ff 75 d0             	pushl  -0x30(%ebp)
  801985:	57                   	push   %edi
  801986:	e8 86 02 00 00       	call   801c11 <strnlen>
  80198b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80198e:	29 c1                	sub    %eax,%ecx
  801990:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801993:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801996:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80199a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80199d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8019a0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a2:	eb 0f                	jmp    8019b3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	53                   	push   %ebx
  8019a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8019ab:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019ad:	83 ef 01             	sub    $0x1,%edi
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	85 ff                	test   %edi,%edi
  8019b5:	7f ed                	jg     8019a4 <vprintfmt+0x1c0>
  8019b7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019ba:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019bd:	85 c9                	test   %ecx,%ecx
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c4:	0f 49 c1             	cmovns %ecx,%eax
  8019c7:	29 c1                	sub    %eax,%ecx
  8019c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8019cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019d2:	89 cb                	mov    %ecx,%ebx
  8019d4:	eb 4d                	jmp    801a23 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019da:	74 1b                	je     8019f7 <vprintfmt+0x213>
  8019dc:	0f be c0             	movsbl %al,%eax
  8019df:	83 e8 20             	sub    $0x20,%eax
  8019e2:	83 f8 5e             	cmp    $0x5e,%eax
  8019e5:	76 10                	jbe    8019f7 <vprintfmt+0x213>
					putch('?', putdat);
  8019e7:	83 ec 08             	sub    $0x8,%esp
  8019ea:	ff 75 0c             	pushl  0xc(%ebp)
  8019ed:	6a 3f                	push   $0x3f
  8019ef:	ff 55 08             	call   *0x8(%ebp)
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	eb 0d                	jmp    801a04 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019f7:	83 ec 08             	sub    $0x8,%esp
  8019fa:	ff 75 0c             	pushl  0xc(%ebp)
  8019fd:	52                   	push   %edx
  8019fe:	ff 55 08             	call   *0x8(%ebp)
  801a01:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a04:	83 eb 01             	sub    $0x1,%ebx
  801a07:	eb 1a                	jmp    801a23 <vprintfmt+0x23f>
  801a09:	89 75 08             	mov    %esi,0x8(%ebp)
  801a0c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a0f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a12:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a15:	eb 0c                	jmp    801a23 <vprintfmt+0x23f>
  801a17:	89 75 08             	mov    %esi,0x8(%ebp)
  801a1a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a1d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a20:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a23:	83 c7 01             	add    $0x1,%edi
  801a26:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a2a:	0f be d0             	movsbl %al,%edx
  801a2d:	85 d2                	test   %edx,%edx
  801a2f:	74 23                	je     801a54 <vprintfmt+0x270>
  801a31:	85 f6                	test   %esi,%esi
  801a33:	78 a1                	js     8019d6 <vprintfmt+0x1f2>
  801a35:	83 ee 01             	sub    $0x1,%esi
  801a38:	79 9c                	jns    8019d6 <vprintfmt+0x1f2>
  801a3a:	89 df                	mov    %ebx,%edi
  801a3c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a42:	eb 18                	jmp    801a5c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	53                   	push   %ebx
  801a48:	6a 20                	push   $0x20
  801a4a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a4c:	83 ef 01             	sub    $0x1,%edi
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	eb 08                	jmp    801a5c <vprintfmt+0x278>
  801a54:	89 df                	mov    %ebx,%edi
  801a56:	8b 75 08             	mov    0x8(%ebp),%esi
  801a59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a5c:	85 ff                	test   %edi,%edi
  801a5e:	7f e4                	jg     801a44 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a63:	e9 a2 fd ff ff       	jmp    80180a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a68:	83 fa 01             	cmp    $0x1,%edx
  801a6b:	7e 16                	jle    801a83 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a6d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a70:	8d 50 08             	lea    0x8(%eax),%edx
  801a73:	89 55 14             	mov    %edx,0x14(%ebp)
  801a76:	8b 50 04             	mov    0x4(%eax),%edx
  801a79:	8b 00                	mov    (%eax),%eax
  801a7b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a7e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a81:	eb 32                	jmp    801ab5 <vprintfmt+0x2d1>
	else if (lflag)
  801a83:	85 d2                	test   %edx,%edx
  801a85:	74 18                	je     801a9f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a87:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8a:	8d 50 04             	lea    0x4(%eax),%edx
  801a8d:	89 55 14             	mov    %edx,0x14(%ebp)
  801a90:	8b 00                	mov    (%eax),%eax
  801a92:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a95:	89 c1                	mov    %eax,%ecx
  801a97:	c1 f9 1f             	sar    $0x1f,%ecx
  801a9a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a9d:	eb 16                	jmp    801ab5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a9f:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa2:	8d 50 04             	lea    0x4(%eax),%edx
  801aa5:	89 55 14             	mov    %edx,0x14(%ebp)
  801aa8:	8b 00                	mov    (%eax),%eax
  801aaa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aad:	89 c1                	mov    %eax,%ecx
  801aaf:	c1 f9 1f             	sar    $0x1f,%ecx
  801ab2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ab5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ab8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801abb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ac0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ac4:	79 74                	jns    801b3a <vprintfmt+0x356>
				putch('-', putdat);
  801ac6:	83 ec 08             	sub    $0x8,%esp
  801ac9:	53                   	push   %ebx
  801aca:	6a 2d                	push   $0x2d
  801acc:	ff d6                	call   *%esi
				num = -(long long) num;
  801ace:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ad1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ad4:	f7 d8                	neg    %eax
  801ad6:	83 d2 00             	adc    $0x0,%edx
  801ad9:	f7 da                	neg    %edx
  801adb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ade:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ae3:	eb 55                	jmp    801b3a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ae5:	8d 45 14             	lea    0x14(%ebp),%eax
  801ae8:	e8 83 fc ff ff       	call   801770 <getuint>
			base = 10;
  801aed:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801af2:	eb 46                	jmp    801b3a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801af4:	8d 45 14             	lea    0x14(%ebp),%eax
  801af7:	e8 74 fc ff ff       	call   801770 <getuint>
			base = 8;
  801afc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b01:	eb 37                	jmp    801b3a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b03:	83 ec 08             	sub    $0x8,%esp
  801b06:	53                   	push   %ebx
  801b07:	6a 30                	push   $0x30
  801b09:	ff d6                	call   *%esi
			putch('x', putdat);
  801b0b:	83 c4 08             	add    $0x8,%esp
  801b0e:	53                   	push   %ebx
  801b0f:	6a 78                	push   $0x78
  801b11:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b13:	8b 45 14             	mov    0x14(%ebp),%eax
  801b16:	8d 50 04             	lea    0x4(%eax),%edx
  801b19:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b1c:	8b 00                	mov    (%eax),%eax
  801b1e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b23:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b26:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b2b:	eb 0d                	jmp    801b3a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b2d:	8d 45 14             	lea    0x14(%ebp),%eax
  801b30:	e8 3b fc ff ff       	call   801770 <getuint>
			base = 16;
  801b35:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b41:	57                   	push   %edi
  801b42:	ff 75 e0             	pushl  -0x20(%ebp)
  801b45:	51                   	push   %ecx
  801b46:	52                   	push   %edx
  801b47:	50                   	push   %eax
  801b48:	89 da                	mov    %ebx,%edx
  801b4a:	89 f0                	mov    %esi,%eax
  801b4c:	e8 70 fb ff ff       	call   8016c1 <printnum>
			break;
  801b51:	83 c4 20             	add    $0x20,%esp
  801b54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b57:	e9 ae fc ff ff       	jmp    80180a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b5c:	83 ec 08             	sub    $0x8,%esp
  801b5f:	53                   	push   %ebx
  801b60:	51                   	push   %ecx
  801b61:	ff d6                	call   *%esi
			break;
  801b63:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b69:	e9 9c fc ff ff       	jmp    80180a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b6e:	83 ec 08             	sub    $0x8,%esp
  801b71:	53                   	push   %ebx
  801b72:	6a 25                	push   $0x25
  801b74:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	eb 03                	jmp    801b7e <vprintfmt+0x39a>
  801b7b:	83 ef 01             	sub    $0x1,%edi
  801b7e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b82:	75 f7                	jne    801b7b <vprintfmt+0x397>
  801b84:	e9 81 fc ff ff       	jmp    80180a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	83 ec 18             	sub    $0x18,%esp
  801b97:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ba0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ba4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ba7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	74 26                	je     801bd8 <vsnprintf+0x47>
  801bb2:	85 d2                	test   %edx,%edx
  801bb4:	7e 22                	jle    801bd8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801bb6:	ff 75 14             	pushl  0x14(%ebp)
  801bb9:	ff 75 10             	pushl  0x10(%ebp)
  801bbc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bbf:	50                   	push   %eax
  801bc0:	68 aa 17 80 00       	push   $0x8017aa
  801bc5:	e8 1a fc ff ff       	call   8017e4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bcd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	eb 05                	jmp    801bdd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bd8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801be5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801be8:	50                   	push   %eax
  801be9:	ff 75 10             	pushl  0x10(%ebp)
  801bec:	ff 75 0c             	pushl  0xc(%ebp)
  801bef:	ff 75 08             	pushl  0x8(%ebp)
  801bf2:	e8 9a ff ff ff       	call   801b91 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bff:	b8 00 00 00 00       	mov    $0x0,%eax
  801c04:	eb 03                	jmp    801c09 <strlen+0x10>
		n++;
  801c06:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c09:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c0d:	75 f7                	jne    801c06 <strlen+0xd>
		n++;
	return n;
}
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c17:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1f:	eb 03                	jmp    801c24 <strnlen+0x13>
		n++;
  801c21:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c24:	39 c2                	cmp    %eax,%edx
  801c26:	74 08                	je     801c30 <strnlen+0x1f>
  801c28:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c2c:	75 f3                	jne    801c21 <strnlen+0x10>
  801c2e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	53                   	push   %ebx
  801c36:	8b 45 08             	mov    0x8(%ebp),%eax
  801c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c3c:	89 c2                	mov    %eax,%edx
  801c3e:	83 c2 01             	add    $0x1,%edx
  801c41:	83 c1 01             	add    $0x1,%ecx
  801c44:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c48:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c4b:	84 db                	test   %bl,%bl
  801c4d:	75 ef                	jne    801c3e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c4f:	5b                   	pop    %ebx
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	53                   	push   %ebx
  801c56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c59:	53                   	push   %ebx
  801c5a:	e8 9a ff ff ff       	call   801bf9 <strlen>
  801c5f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c62:	ff 75 0c             	pushl  0xc(%ebp)
  801c65:	01 d8                	add    %ebx,%eax
  801c67:	50                   	push   %eax
  801c68:	e8 c5 ff ff ff       	call   801c32 <strcpy>
	return dst;
}
  801c6d:	89 d8                	mov    %ebx,%eax
  801c6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	56                   	push   %esi
  801c78:	53                   	push   %ebx
  801c79:	8b 75 08             	mov    0x8(%ebp),%esi
  801c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c7f:	89 f3                	mov    %esi,%ebx
  801c81:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c84:	89 f2                	mov    %esi,%edx
  801c86:	eb 0f                	jmp    801c97 <strncpy+0x23>
		*dst++ = *src;
  801c88:	83 c2 01             	add    $0x1,%edx
  801c8b:	0f b6 01             	movzbl (%ecx),%eax
  801c8e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c91:	80 39 01             	cmpb   $0x1,(%ecx)
  801c94:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c97:	39 da                	cmp    %ebx,%edx
  801c99:	75 ed                	jne    801c88 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c9b:	89 f0                	mov    %esi,%eax
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5d                   	pop    %ebp
  801ca0:	c3                   	ret    

00801ca1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	56                   	push   %esi
  801ca5:	53                   	push   %ebx
  801ca6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cac:	8b 55 10             	mov    0x10(%ebp),%edx
  801caf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801cb1:	85 d2                	test   %edx,%edx
  801cb3:	74 21                	je     801cd6 <strlcpy+0x35>
  801cb5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cb9:	89 f2                	mov    %esi,%edx
  801cbb:	eb 09                	jmp    801cc6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cbd:	83 c2 01             	add    $0x1,%edx
  801cc0:	83 c1 01             	add    $0x1,%ecx
  801cc3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cc6:	39 c2                	cmp    %eax,%edx
  801cc8:	74 09                	je     801cd3 <strlcpy+0x32>
  801cca:	0f b6 19             	movzbl (%ecx),%ebx
  801ccd:	84 db                	test   %bl,%bl
  801ccf:	75 ec                	jne    801cbd <strlcpy+0x1c>
  801cd1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cd3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cd6:	29 f0                	sub    %esi,%eax
}
  801cd8:	5b                   	pop    %ebx
  801cd9:	5e                   	pop    %esi
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    

00801cdc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ce5:	eb 06                	jmp    801ced <strcmp+0x11>
		p++, q++;
  801ce7:	83 c1 01             	add    $0x1,%ecx
  801cea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ced:	0f b6 01             	movzbl (%ecx),%eax
  801cf0:	84 c0                	test   %al,%al
  801cf2:	74 04                	je     801cf8 <strcmp+0x1c>
  801cf4:	3a 02                	cmp    (%edx),%al
  801cf6:	74 ef                	je     801ce7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cf8:	0f b6 c0             	movzbl %al,%eax
  801cfb:	0f b6 12             	movzbl (%edx),%edx
  801cfe:	29 d0                	sub    %edx,%eax
}
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    

00801d02 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	53                   	push   %ebx
  801d06:	8b 45 08             	mov    0x8(%ebp),%eax
  801d09:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0c:	89 c3                	mov    %eax,%ebx
  801d0e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d11:	eb 06                	jmp    801d19 <strncmp+0x17>
		n--, p++, q++;
  801d13:	83 c0 01             	add    $0x1,%eax
  801d16:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d19:	39 d8                	cmp    %ebx,%eax
  801d1b:	74 15                	je     801d32 <strncmp+0x30>
  801d1d:	0f b6 08             	movzbl (%eax),%ecx
  801d20:	84 c9                	test   %cl,%cl
  801d22:	74 04                	je     801d28 <strncmp+0x26>
  801d24:	3a 0a                	cmp    (%edx),%cl
  801d26:	74 eb                	je     801d13 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d28:	0f b6 00             	movzbl (%eax),%eax
  801d2b:	0f b6 12             	movzbl (%edx),%edx
  801d2e:	29 d0                	sub    %edx,%eax
  801d30:	eb 05                	jmp    801d37 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d32:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d37:	5b                   	pop    %ebx
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d44:	eb 07                	jmp    801d4d <strchr+0x13>
		if (*s == c)
  801d46:	38 ca                	cmp    %cl,%dl
  801d48:	74 0f                	je     801d59 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d4a:	83 c0 01             	add    $0x1,%eax
  801d4d:	0f b6 10             	movzbl (%eax),%edx
  801d50:	84 d2                	test   %dl,%dl
  801d52:	75 f2                	jne    801d46 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d59:	5d                   	pop    %ebp
  801d5a:	c3                   	ret    

00801d5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d65:	eb 03                	jmp    801d6a <strfind+0xf>
  801d67:	83 c0 01             	add    $0x1,%eax
  801d6a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d6d:	38 ca                	cmp    %cl,%dl
  801d6f:	74 04                	je     801d75 <strfind+0x1a>
  801d71:	84 d2                	test   %dl,%dl
  801d73:	75 f2                	jne    801d67 <strfind+0xc>
			break;
	return (char *) s;
}
  801d75:	5d                   	pop    %ebp
  801d76:	c3                   	ret    

00801d77 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	57                   	push   %edi
  801d7b:	56                   	push   %esi
  801d7c:	53                   	push   %ebx
  801d7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d83:	85 c9                	test   %ecx,%ecx
  801d85:	74 36                	je     801dbd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d87:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d8d:	75 28                	jne    801db7 <memset+0x40>
  801d8f:	f6 c1 03             	test   $0x3,%cl
  801d92:	75 23                	jne    801db7 <memset+0x40>
		c &= 0xFF;
  801d94:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d98:	89 d3                	mov    %edx,%ebx
  801d9a:	c1 e3 08             	shl    $0x8,%ebx
  801d9d:	89 d6                	mov    %edx,%esi
  801d9f:	c1 e6 18             	shl    $0x18,%esi
  801da2:	89 d0                	mov    %edx,%eax
  801da4:	c1 e0 10             	shl    $0x10,%eax
  801da7:	09 f0                	or     %esi,%eax
  801da9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801dab:	89 d8                	mov    %ebx,%eax
  801dad:	09 d0                	or     %edx,%eax
  801daf:	c1 e9 02             	shr    $0x2,%ecx
  801db2:	fc                   	cld    
  801db3:	f3 ab                	rep stos %eax,%es:(%edi)
  801db5:	eb 06                	jmp    801dbd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801db7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dba:	fc                   	cld    
  801dbb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dbd:	89 f8                	mov    %edi,%eax
  801dbf:	5b                   	pop    %ebx
  801dc0:	5e                   	pop    %esi
  801dc1:	5f                   	pop    %edi
  801dc2:	5d                   	pop    %ebp
  801dc3:	c3                   	ret    

00801dc4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	57                   	push   %edi
  801dc8:	56                   	push   %esi
  801dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dd2:	39 c6                	cmp    %eax,%esi
  801dd4:	73 35                	jae    801e0b <memmove+0x47>
  801dd6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dd9:	39 d0                	cmp    %edx,%eax
  801ddb:	73 2e                	jae    801e0b <memmove+0x47>
		s += n;
		d += n;
  801ddd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801de0:	89 d6                	mov    %edx,%esi
  801de2:	09 fe                	or     %edi,%esi
  801de4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801dea:	75 13                	jne    801dff <memmove+0x3b>
  801dec:	f6 c1 03             	test   $0x3,%cl
  801def:	75 0e                	jne    801dff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801df1:	83 ef 04             	sub    $0x4,%edi
  801df4:	8d 72 fc             	lea    -0x4(%edx),%esi
  801df7:	c1 e9 02             	shr    $0x2,%ecx
  801dfa:	fd                   	std    
  801dfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dfd:	eb 09                	jmp    801e08 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dff:	83 ef 01             	sub    $0x1,%edi
  801e02:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e05:	fd                   	std    
  801e06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e08:	fc                   	cld    
  801e09:	eb 1d                	jmp    801e28 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e0b:	89 f2                	mov    %esi,%edx
  801e0d:	09 c2                	or     %eax,%edx
  801e0f:	f6 c2 03             	test   $0x3,%dl
  801e12:	75 0f                	jne    801e23 <memmove+0x5f>
  801e14:	f6 c1 03             	test   $0x3,%cl
  801e17:	75 0a                	jne    801e23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e19:	c1 e9 02             	shr    $0x2,%ecx
  801e1c:	89 c7                	mov    %eax,%edi
  801e1e:	fc                   	cld    
  801e1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e21:	eb 05                	jmp    801e28 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e23:	89 c7                	mov    %eax,%edi
  801e25:	fc                   	cld    
  801e26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e28:	5e                   	pop    %esi
  801e29:	5f                   	pop    %edi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    

00801e2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e2f:	ff 75 10             	pushl  0x10(%ebp)
  801e32:	ff 75 0c             	pushl  0xc(%ebp)
  801e35:	ff 75 08             	pushl  0x8(%ebp)
  801e38:	e8 87 ff ff ff       	call   801dc4 <memmove>
}
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    

00801e3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	8b 45 08             	mov    0x8(%ebp),%eax
  801e47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4a:	89 c6                	mov    %eax,%esi
  801e4c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e4f:	eb 1a                	jmp    801e6b <memcmp+0x2c>
		if (*s1 != *s2)
  801e51:	0f b6 08             	movzbl (%eax),%ecx
  801e54:	0f b6 1a             	movzbl (%edx),%ebx
  801e57:	38 d9                	cmp    %bl,%cl
  801e59:	74 0a                	je     801e65 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e5b:	0f b6 c1             	movzbl %cl,%eax
  801e5e:	0f b6 db             	movzbl %bl,%ebx
  801e61:	29 d8                	sub    %ebx,%eax
  801e63:	eb 0f                	jmp    801e74 <memcmp+0x35>
		s1++, s2++;
  801e65:	83 c0 01             	add    $0x1,%eax
  801e68:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e6b:	39 f0                	cmp    %esi,%eax
  801e6d:	75 e2                	jne    801e51 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e74:	5b                   	pop    %ebx
  801e75:	5e                   	pop    %esi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    

00801e78 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	53                   	push   %ebx
  801e7c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e7f:	89 c1                	mov    %eax,%ecx
  801e81:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e84:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e88:	eb 0a                	jmp    801e94 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e8a:	0f b6 10             	movzbl (%eax),%edx
  801e8d:	39 da                	cmp    %ebx,%edx
  801e8f:	74 07                	je     801e98 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e91:	83 c0 01             	add    $0x1,%eax
  801e94:	39 c8                	cmp    %ecx,%eax
  801e96:	72 f2                	jb     801e8a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e98:	5b                   	pop    %ebx
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	57                   	push   %edi
  801e9f:	56                   	push   %esi
  801ea0:	53                   	push   %ebx
  801ea1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ea7:	eb 03                	jmp    801eac <strtol+0x11>
		s++;
  801ea9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801eac:	0f b6 01             	movzbl (%ecx),%eax
  801eaf:	3c 20                	cmp    $0x20,%al
  801eb1:	74 f6                	je     801ea9 <strtol+0xe>
  801eb3:	3c 09                	cmp    $0x9,%al
  801eb5:	74 f2                	je     801ea9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801eb7:	3c 2b                	cmp    $0x2b,%al
  801eb9:	75 0a                	jne    801ec5 <strtol+0x2a>
		s++;
  801ebb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ebe:	bf 00 00 00 00       	mov    $0x0,%edi
  801ec3:	eb 11                	jmp    801ed6 <strtol+0x3b>
  801ec5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801eca:	3c 2d                	cmp    $0x2d,%al
  801ecc:	75 08                	jne    801ed6 <strtol+0x3b>
		s++, neg = 1;
  801ece:	83 c1 01             	add    $0x1,%ecx
  801ed1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ed6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801edc:	75 15                	jne    801ef3 <strtol+0x58>
  801ede:	80 39 30             	cmpb   $0x30,(%ecx)
  801ee1:	75 10                	jne    801ef3 <strtol+0x58>
  801ee3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ee7:	75 7c                	jne    801f65 <strtol+0xca>
		s += 2, base = 16;
  801ee9:	83 c1 02             	add    $0x2,%ecx
  801eec:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ef1:	eb 16                	jmp    801f09 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ef3:	85 db                	test   %ebx,%ebx
  801ef5:	75 12                	jne    801f09 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ef7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801efc:	80 39 30             	cmpb   $0x30,(%ecx)
  801eff:	75 08                	jne    801f09 <strtol+0x6e>
		s++, base = 8;
  801f01:	83 c1 01             	add    $0x1,%ecx
  801f04:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f09:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f11:	0f b6 11             	movzbl (%ecx),%edx
  801f14:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f17:	89 f3                	mov    %esi,%ebx
  801f19:	80 fb 09             	cmp    $0x9,%bl
  801f1c:	77 08                	ja     801f26 <strtol+0x8b>
			dig = *s - '0';
  801f1e:	0f be d2             	movsbl %dl,%edx
  801f21:	83 ea 30             	sub    $0x30,%edx
  801f24:	eb 22                	jmp    801f48 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f26:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f29:	89 f3                	mov    %esi,%ebx
  801f2b:	80 fb 19             	cmp    $0x19,%bl
  801f2e:	77 08                	ja     801f38 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f30:	0f be d2             	movsbl %dl,%edx
  801f33:	83 ea 57             	sub    $0x57,%edx
  801f36:	eb 10                	jmp    801f48 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f38:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f3b:	89 f3                	mov    %esi,%ebx
  801f3d:	80 fb 19             	cmp    $0x19,%bl
  801f40:	77 16                	ja     801f58 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f42:	0f be d2             	movsbl %dl,%edx
  801f45:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f48:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f4b:	7d 0b                	jge    801f58 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f4d:	83 c1 01             	add    $0x1,%ecx
  801f50:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f54:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f56:	eb b9                	jmp    801f11 <strtol+0x76>

	if (endptr)
  801f58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f5c:	74 0d                	je     801f6b <strtol+0xd0>
		*endptr = (char *) s;
  801f5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f61:	89 0e                	mov    %ecx,(%esi)
  801f63:	eb 06                	jmp    801f6b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f65:	85 db                	test   %ebx,%ebx
  801f67:	74 98                	je     801f01 <strtol+0x66>
  801f69:	eb 9e                	jmp    801f09 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f6b:	89 c2                	mov    %eax,%edx
  801f6d:	f7 da                	neg    %edx
  801f6f:	85 ff                	test   %edi,%edi
  801f71:	0f 45 c2             	cmovne %edx,%eax
}
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5f                   	pop    %edi
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    

00801f79 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f7f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f86:	75 2a                	jne    801fb2 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f88:	83 ec 04             	sub    $0x4,%esp
  801f8b:	6a 07                	push   $0x7
  801f8d:	68 00 f0 bf ee       	push   $0xeebff000
  801f92:	6a 00                	push   $0x0
  801f94:	e8 ed e1 ff ff       	call   800186 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f99:	83 c4 10             	add    $0x10,%esp
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	79 12                	jns    801fb2 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fa0:	50                   	push   %eax
  801fa1:	68 bd 24 80 00       	push   $0x8024bd
  801fa6:	6a 23                	push   $0x23
  801fa8:	68 e0 28 80 00       	push   $0x8028e0
  801fad:	e8 22 f6 ff ff       	call   8015d4 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb5:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fba:	83 ec 08             	sub    $0x8,%esp
  801fbd:	68 e4 1f 80 00       	push   $0x801fe4
  801fc2:	6a 00                	push   $0x0
  801fc4:	e8 08 e3 ff ff       	call   8002d1 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	79 12                	jns    801fe2 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fd0:	50                   	push   %eax
  801fd1:	68 bd 24 80 00       	push   $0x8024bd
  801fd6:	6a 2c                	push   $0x2c
  801fd8:	68 e0 28 80 00       	push   $0x8028e0
  801fdd:	e8 f2 f5 ff ff       	call   8015d4 <_panic>
	}
}
  801fe2:	c9                   	leave  
  801fe3:	c3                   	ret    

00801fe4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fe4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fe5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fec:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fef:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801ff3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801ff8:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801ffc:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ffe:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802001:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802002:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802005:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802006:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802007:	c3                   	ret    

00802008 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	56                   	push   %esi
  80200c:	53                   	push   %ebx
  80200d:	8b 75 08             	mov    0x8(%ebp),%esi
  802010:	8b 45 0c             	mov    0xc(%ebp),%eax
  802013:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802016:	85 c0                	test   %eax,%eax
  802018:	75 12                	jne    80202c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80201a:	83 ec 0c             	sub    $0xc,%esp
  80201d:	68 00 00 c0 ee       	push   $0xeec00000
  802022:	e8 0f e3 ff ff       	call   800336 <sys_ipc_recv>
  802027:	83 c4 10             	add    $0x10,%esp
  80202a:	eb 0c                	jmp    802038 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80202c:	83 ec 0c             	sub    $0xc,%esp
  80202f:	50                   	push   %eax
  802030:	e8 01 e3 ff ff       	call   800336 <sys_ipc_recv>
  802035:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802038:	85 f6                	test   %esi,%esi
  80203a:	0f 95 c1             	setne  %cl
  80203d:	85 db                	test   %ebx,%ebx
  80203f:	0f 95 c2             	setne  %dl
  802042:	84 d1                	test   %dl,%cl
  802044:	74 09                	je     80204f <ipc_recv+0x47>
  802046:	89 c2                	mov    %eax,%edx
  802048:	c1 ea 1f             	shr    $0x1f,%edx
  80204b:	84 d2                	test   %dl,%dl
  80204d:	75 2d                	jne    80207c <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80204f:	85 f6                	test   %esi,%esi
  802051:	74 0d                	je     802060 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802053:	a1 04 40 80 00       	mov    0x804004,%eax
  802058:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80205e:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802060:	85 db                	test   %ebx,%ebx
  802062:	74 0d                	je     802071 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802064:	a1 04 40 80 00       	mov    0x804004,%eax
  802069:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80206f:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802071:	a1 04 40 80 00       	mov    0x804004,%eax
  802076:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80207c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5d                   	pop    %ebp
  802082:	c3                   	ret    

00802083 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	57                   	push   %edi
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	83 ec 0c             	sub    $0xc,%esp
  80208c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80208f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802092:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802095:	85 db                	test   %ebx,%ebx
  802097:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80209c:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80209f:	ff 75 14             	pushl  0x14(%ebp)
  8020a2:	53                   	push   %ebx
  8020a3:	56                   	push   %esi
  8020a4:	57                   	push   %edi
  8020a5:	e8 69 e2 ff ff       	call   800313 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020aa:	89 c2                	mov    %eax,%edx
  8020ac:	c1 ea 1f             	shr    $0x1f,%edx
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	84 d2                	test   %dl,%dl
  8020b4:	74 17                	je     8020cd <ipc_send+0x4a>
  8020b6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020b9:	74 12                	je     8020cd <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020bb:	50                   	push   %eax
  8020bc:	68 ee 28 80 00       	push   $0x8028ee
  8020c1:	6a 47                	push   $0x47
  8020c3:	68 fc 28 80 00       	push   $0x8028fc
  8020c8:	e8 07 f5 ff ff       	call   8015d4 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020cd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d0:	75 07                	jne    8020d9 <ipc_send+0x56>
			sys_yield();
  8020d2:	e8 90 e0 ff ff       	call   800167 <sys_yield>
  8020d7:	eb c6                	jmp    80209f <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	75 c2                	jne    80209f <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e0:	5b                   	pop    %ebx
  8020e1:	5e                   	pop    %esi
  8020e2:	5f                   	pop    %edi
  8020e3:	5d                   	pop    %ebp
  8020e4:	c3                   	ret    

008020e5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020eb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020f0:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020f6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020fc:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802102:	39 ca                	cmp    %ecx,%edx
  802104:	75 13                	jne    802119 <ipc_find_env+0x34>
			return envs[i].env_id;
  802106:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80210c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802111:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802117:	eb 0f                	jmp    802128 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802119:	83 c0 01             	add    $0x1,%eax
  80211c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802121:	75 cd                	jne    8020f0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802123:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802128:	5d                   	pop    %ebp
  802129:	c3                   	ret    

0080212a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80212a:	55                   	push   %ebp
  80212b:	89 e5                	mov    %esp,%ebp
  80212d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802130:	89 d0                	mov    %edx,%eax
  802132:	c1 e8 16             	shr    $0x16,%eax
  802135:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80213c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802141:	f6 c1 01             	test   $0x1,%cl
  802144:	74 1d                	je     802163 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802146:	c1 ea 0c             	shr    $0xc,%edx
  802149:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802150:	f6 c2 01             	test   $0x1,%dl
  802153:	74 0e                	je     802163 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802155:	c1 ea 0c             	shr    $0xc,%edx
  802158:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80215f:	ef 
  802160:	0f b7 c0             	movzwl %ax,%eax
}
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	66 90                	xchg   %ax,%ax
  802167:	66 90                	xchg   %ax,%ax
  802169:	66 90                	xchg   %ax,%ax
  80216b:	66 90                	xchg   %ax,%ax
  80216d:	66 90                	xchg   %ax,%ax
  80216f:	90                   	nop

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80217b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80217f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 f6                	test   %esi,%esi
  802189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80218d:	89 ca                	mov    %ecx,%edx
  80218f:	89 f8                	mov    %edi,%eax
  802191:	75 3d                	jne    8021d0 <__udivdi3+0x60>
  802193:	39 cf                	cmp    %ecx,%edi
  802195:	0f 87 c5 00 00 00    	ja     802260 <__udivdi3+0xf0>
  80219b:	85 ff                	test   %edi,%edi
  80219d:	89 fd                	mov    %edi,%ebp
  80219f:	75 0b                	jne    8021ac <__udivdi3+0x3c>
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	f7 f7                	div    %edi
  8021aa:	89 c5                	mov    %eax,%ebp
  8021ac:	89 c8                	mov    %ecx,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f5                	div    %ebp
  8021b2:	89 c1                	mov    %eax,%ecx
  8021b4:	89 d8                	mov    %ebx,%eax
  8021b6:	89 cf                	mov    %ecx,%edi
  8021b8:	f7 f5                	div    %ebp
  8021ba:	89 c3                	mov    %eax,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	39 ce                	cmp    %ecx,%esi
  8021d2:	77 74                	ja     802248 <__udivdi3+0xd8>
  8021d4:	0f bd fe             	bsr    %esi,%edi
  8021d7:	83 f7 1f             	xor    $0x1f,%edi
  8021da:	0f 84 98 00 00 00    	je     802278 <__udivdi3+0x108>
  8021e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	89 c5                	mov    %eax,%ebp
  8021e9:	29 fb                	sub    %edi,%ebx
  8021eb:	d3 e6                	shl    %cl,%esi
  8021ed:	89 d9                	mov    %ebx,%ecx
  8021ef:	d3 ed                	shr    %cl,%ebp
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	d3 e0                	shl    %cl,%eax
  8021f5:	09 ee                	or     %ebp,%esi
  8021f7:	89 d9                	mov    %ebx,%ecx
  8021f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fd:	89 d5                	mov    %edx,%ebp
  8021ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802203:	d3 ed                	shr    %cl,%ebp
  802205:	89 f9                	mov    %edi,%ecx
  802207:	d3 e2                	shl    %cl,%edx
  802209:	89 d9                	mov    %ebx,%ecx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	09 c2                	or     %eax,%edx
  80220f:	89 d0                	mov    %edx,%eax
  802211:	89 ea                	mov    %ebp,%edx
  802213:	f7 f6                	div    %esi
  802215:	89 d5                	mov    %edx,%ebp
  802217:	89 c3                	mov    %eax,%ebx
  802219:	f7 64 24 0c          	mull   0xc(%esp)
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	72 10                	jb     802231 <__udivdi3+0xc1>
  802221:	8b 74 24 08          	mov    0x8(%esp),%esi
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e6                	shl    %cl,%esi
  802229:	39 c6                	cmp    %eax,%esi
  80222b:	73 07                	jae    802234 <__udivdi3+0xc4>
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	75 03                	jne    802234 <__udivdi3+0xc4>
  802231:	83 eb 01             	sub    $0x1,%ebx
  802234:	31 ff                	xor    %edi,%edi
  802236:	89 d8                	mov    %ebx,%eax
  802238:	89 fa                	mov    %edi,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	31 ff                	xor    %edi,%edi
  80224a:	31 db                	xor    %ebx,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 d8                	mov    %ebx,%eax
  802262:	f7 f7                	div    %edi
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 c3                	mov    %eax,%ebx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 fa                	mov    %edi,%edx
  80226c:	83 c4 1c             	add    $0x1c,%esp
  80226f:	5b                   	pop    %ebx
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	39 ce                	cmp    %ecx,%esi
  80227a:	72 0c                	jb     802288 <__udivdi3+0x118>
  80227c:	31 db                	xor    %ebx,%ebx
  80227e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802282:	0f 87 34 ff ff ff    	ja     8021bc <__udivdi3+0x4c>
  802288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80228d:	e9 2a ff ff ff       	jmp    8021bc <__udivdi3+0x4c>
  802292:	66 90                	xchg   %ax,%ax
  802294:	66 90                	xchg   %ax,%ax
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 d2                	test   %edx,%edx
  8022b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 f3                	mov    %esi,%ebx
  8022c3:	89 3c 24             	mov    %edi,(%esp)
  8022c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ca:	75 1c                	jne    8022e8 <__umoddi3+0x48>
  8022cc:	39 f7                	cmp    %esi,%edi
  8022ce:	76 50                	jbe    802320 <__umoddi3+0x80>
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	f7 f7                	div    %edi
  8022d6:	89 d0                	mov    %edx,%eax
  8022d8:	31 d2                	xor    %edx,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	89 d0                	mov    %edx,%eax
  8022ec:	77 52                	ja     802340 <__umoddi3+0xa0>
  8022ee:	0f bd ea             	bsr    %edx,%ebp
  8022f1:	83 f5 1f             	xor    $0x1f,%ebp
  8022f4:	75 5a                	jne    802350 <__umoddi3+0xb0>
  8022f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	39 0c 24             	cmp    %ecx,(%esp)
  802303:	0f 86 d7 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  802309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80230d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802311:	83 c4 1c             	add    $0x1c,%esp
  802314:	5b                   	pop    %ebx
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	85 ff                	test   %edi,%edi
  802322:	89 fd                	mov    %edi,%ebp
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 f0                	mov    %esi,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 c8                	mov    %ecx,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	eb 99                	jmp    8022d8 <__umoddi3+0x38>
  80233f:	90                   	nop
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	83 c4 1c             	add    $0x1c,%esp
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    
  80234c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802350:	8b 34 24             	mov    (%esp),%esi
  802353:	bf 20 00 00 00       	mov    $0x20,%edi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	29 ef                	sub    %ebp,%edi
  80235c:	d3 e0                	shl    %cl,%eax
  80235e:	89 f9                	mov    %edi,%ecx
  802360:	89 f2                	mov    %esi,%edx
  802362:	d3 ea                	shr    %cl,%edx
  802364:	89 e9                	mov    %ebp,%ecx
  802366:	09 c2                	or     %eax,%edx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 14 24             	mov    %edx,(%esp)
  80236d:	89 f2                	mov    %esi,%edx
  80236f:	d3 e2                	shl    %cl,%edx
  802371:	89 f9                	mov    %edi,%ecx
  802373:	89 54 24 04          	mov    %edx,0x4(%esp)
  802377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	89 c6                	mov    %eax,%esi
  802381:	d3 e3                	shl    %cl,%ebx
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 d0                	mov    %edx,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	09 d8                	or     %ebx,%eax
  80238d:	89 d3                	mov    %edx,%ebx
  80238f:	89 f2                	mov    %esi,%edx
  802391:	f7 34 24             	divl   (%esp)
  802394:	89 d6                	mov    %edx,%esi
  802396:	d3 e3                	shl    %cl,%ebx
  802398:	f7 64 24 04          	mull   0x4(%esp)
  80239c:	39 d6                	cmp    %edx,%esi
  80239e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a2:	89 d1                	mov    %edx,%ecx
  8023a4:	89 c3                	mov    %eax,%ebx
  8023a6:	72 08                	jb     8023b0 <__umoddi3+0x110>
  8023a8:	75 11                	jne    8023bb <__umoddi3+0x11b>
  8023aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ae:	73 0b                	jae    8023bb <__umoddi3+0x11b>
  8023b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023b4:	1b 14 24             	sbb    (%esp),%edx
  8023b7:	89 d1                	mov    %edx,%ecx
  8023b9:	89 c3                	mov    %eax,%ebx
  8023bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023bf:	29 da                	sub    %ebx,%edx
  8023c1:	19 ce                	sbb    %ecx,%esi
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	89 f0                	mov    %esi,%eax
  8023c7:	d3 e0                	shl    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	d3 ea                	shr    %cl,%edx
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	d3 ee                	shr    %cl,%esi
  8023d1:	09 d0                	or     %edx,%eax
  8023d3:	89 f2                	mov    %esi,%edx
  8023d5:	83 c4 1c             	add    $0x1c,%esp
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 f9                	sub    %edi,%ecx
  8023e2:	19 d6                	sbb    %edx,%esi
  8023e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ec:	e9 18 ff ff ff       	jmp    802309 <__umoddi3+0x69>
