
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
  8000b6:	e8 e4 09 00 00       	call   800a9f <close_all>
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
  80013b:	e8 90 14 00 00       	call   8015d0 <_panic>

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
  8001bc:	e8 0f 14 00 00       	call   8015d0 <_panic>

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
  8001fe:	e8 cd 13 00 00       	call   8015d0 <_panic>

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
  800240:	e8 8b 13 00 00       	call   8015d0 <_panic>

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
  800282:	e8 49 13 00 00       	call   8015d0 <_panic>

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
  8002c4:	e8 07 13 00 00       	call   8015d0 <_panic>
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
  800306:	e8 c5 12 00 00       	call   8015d0 <_panic>

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
  80036a:	e8 61 12 00 00       	call   8015d0 <_panic>

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
  800409:	e8 c2 11 00 00       	call   8015d0 <_panic>
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
  800433:	e8 98 11 00 00       	call   8015d0 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800438:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80043e:	83 ec 04             	sub    $0x4,%esp
  800441:	68 00 10 00 00       	push   $0x1000
  800446:	53                   	push   %ebx
  800447:	68 00 f0 7f 00       	push   $0x7ff000
  80044c:	e8 d7 19 00 00       	call   801e28 <memcpy>

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
  80047b:	e8 50 11 00 00       	call   8015d0 <_panic>
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
  8004a3:	e8 28 11 00 00       	call   8015d0 <_panic>
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
  8004bb:	e8 b5 1a 00 00       	call   801f75 <set_pgfault_handler>
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
  8004e3:	e8 e8 10 00 00       	call   8015d0 <_panic>
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
  80059c:	e8 2f 10 00 00       	call   8015d0 <_panic>
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
  8005e1:	e8 ea 0f 00 00       	call   8015d0 <_panic>
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
  80060f:	e8 bc 0f 00 00       	call   8015d0 <_panic>
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
  800639:	e8 92 0f 00 00       	call   8015d0 <_panic>
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
  8006f9:	e8 d2 0e 00 00       	call   8015d0 <_panic>
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
  80075f:	e8 6c 0e 00 00       	call   8015d0 <_panic>
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
  800770:	53                   	push   %ebx
  800771:	83 ec 04             	sub    $0x4,%esp
  800774:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800777:	b8 01 00 00 00       	mov    $0x1,%eax
  80077c:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  80077f:	85 c0                	test   %eax,%eax
  800781:	74 45                	je     8007c8 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  800783:	e8 c0 f9 ff ff       	call   800148 <sys_getenvid>
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	83 c3 04             	add    $0x4,%ebx
  80078e:	53                   	push   %ebx
  80078f:	50                   	push   %eax
  800790:	e8 35 ff ff ff       	call   8006ca <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800795:	e8 ae f9 ff ff       	call   800148 <sys_getenvid>
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	6a 04                	push   $0x4
  80079f:	50                   	push   %eax
  8007a0:	e8 a8 fa ff ff       	call   80024d <sys_env_set_status>

		if (r < 0) {
  8007a5:	83 c4 10             	add    $0x10,%esp
  8007a8:	85 c0                	test   %eax,%eax
  8007aa:	79 15                	jns    8007c1 <mutex_lock+0x54>
			panic("%e\n", r);
  8007ac:	50                   	push   %eax
  8007ad:	68 bd 24 80 00       	push   $0x8024bd
  8007b2:	68 02 01 00 00       	push   $0x102
  8007b7:	68 45 24 80 00       	push   $0x802445
  8007bc:	e8 0f 0e 00 00       	call   8015d0 <_panic>
		}
		sys_yield();
  8007c1:	e8 a1 f9 ff ff       	call   800167 <sys_yield>
  8007c6:	eb 08                	jmp    8007d0 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8007c8:	e8 7b f9 ff ff       	call   800148 <sys_getenvid>
  8007cd:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8007d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	83 ec 04             	sub    $0x4,%esp
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8007df:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8007e3:	74 36                	je     80081b <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8007e5:	83 ec 0c             	sub    $0xc,%esp
  8007e8:	8d 43 04             	lea    0x4(%ebx),%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 4d ff ff ff       	call   80073e <queue_pop>
  8007f1:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8007f4:	83 c4 08             	add    $0x8,%esp
  8007f7:	6a 02                	push   $0x2
  8007f9:	50                   	push   %eax
  8007fa:	e8 4e fa ff ff       	call   80024d <sys_env_set_status>
		if (r < 0) {
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	85 c0                	test   %eax,%eax
  800804:	79 1d                	jns    800823 <mutex_unlock+0x4e>
			panic("%e\n", r);
  800806:	50                   	push   %eax
  800807:	68 bd 24 80 00       	push   $0x8024bd
  80080c:	68 16 01 00 00       	push   $0x116
  800811:	68 45 24 80 00       	push   $0x802445
  800816:	e8 b5 0d 00 00       	call   8015d0 <_panic>
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  800823:	e8 3f f9 ff ff       	call   800167 <sys_yield>
}
  800828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	53                   	push   %ebx
  800831:	83 ec 04             	sub    $0x4,%esp
  800834:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800837:	e8 0c f9 ff ff       	call   800148 <sys_getenvid>
  80083c:	83 ec 04             	sub    $0x4,%esp
  80083f:	6a 07                	push   $0x7
  800841:	53                   	push   %ebx
  800842:	50                   	push   %eax
  800843:	e8 3e f9 ff ff       	call   800186 <sys_page_alloc>
  800848:	83 c4 10             	add    $0x10,%esp
  80084b:	85 c0                	test   %eax,%eax
  80084d:	79 15                	jns    800864 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80084f:	50                   	push   %eax
  800850:	68 a8 24 80 00       	push   $0x8024a8
  800855:	68 23 01 00 00       	push   $0x123
  80085a:	68 45 24 80 00       	push   $0x802445
  80085f:	e8 6c 0d 00 00       	call   8015d0 <_panic>
	}	
	mtx->locked = 0;
  800864:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  80086a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  800871:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  800878:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  80087f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80088c:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  80088f:	eb 20                	jmp    8008b1 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  800891:	83 ec 0c             	sub    $0xc,%esp
  800894:	56                   	push   %esi
  800895:	e8 a4 fe ff ff       	call   80073e <queue_pop>
  80089a:	83 c4 08             	add    $0x8,%esp
  80089d:	6a 02                	push   $0x2
  80089f:	50                   	push   %eax
  8008a0:	e8 a8 f9 ff ff       	call   80024d <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8008a5:	8b 43 04             	mov    0x4(%ebx),%eax
  8008a8:	8b 40 04             	mov    0x4(%eax),%eax
  8008ab:	89 43 04             	mov    %eax,0x4(%ebx)
  8008ae:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8008b1:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8008b5:	75 da                	jne    800891 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008b7:	83 ec 04             	sub    $0x4,%esp
  8008ba:	68 00 10 00 00       	push   $0x1000
  8008bf:	6a 00                	push   $0x0
  8008c1:	53                   	push   %ebx
  8008c2:	e8 ac 14 00 00       	call   801d73 <memset>
	mtx = NULL;
}
  8008c7:	83 c4 10             	add    $0x10,%esp
  8008ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008cd:	5b                   	pop    %ebx
  8008ce:	5e                   	pop    %esi
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	05 00 00 00 30       	add    $0x30000000,%eax
  8008dc:	c1 e8 0c             	shr    $0xc,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8008ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008f1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800903:	89 c2                	mov    %eax,%edx
  800905:	c1 ea 16             	shr    $0x16,%edx
  800908:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80090f:	f6 c2 01             	test   $0x1,%dl
  800912:	74 11                	je     800925 <fd_alloc+0x2d>
  800914:	89 c2                	mov    %eax,%edx
  800916:	c1 ea 0c             	shr    $0xc,%edx
  800919:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800920:	f6 c2 01             	test   $0x1,%dl
  800923:	75 09                	jne    80092e <fd_alloc+0x36>
			*fd_store = fd;
  800925:	89 01                	mov    %eax,(%ecx)
			return 0;
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
  80092c:	eb 17                	jmp    800945 <fd_alloc+0x4d>
  80092e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800933:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800938:	75 c9                	jne    800903 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80093a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800940:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80094d:	83 f8 1f             	cmp    $0x1f,%eax
  800950:	77 36                	ja     800988 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800952:	c1 e0 0c             	shl    $0xc,%eax
  800955:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80095a:	89 c2                	mov    %eax,%edx
  80095c:	c1 ea 16             	shr    $0x16,%edx
  80095f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800966:	f6 c2 01             	test   $0x1,%dl
  800969:	74 24                	je     80098f <fd_lookup+0x48>
  80096b:	89 c2                	mov    %eax,%edx
  80096d:	c1 ea 0c             	shr    $0xc,%edx
  800970:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800977:	f6 c2 01             	test   $0x1,%dl
  80097a:	74 1a                	je     800996 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097f:	89 02                	mov    %eax,(%edx)
	return 0;
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
  800986:	eb 13                	jmp    80099b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800988:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80098d:	eb 0c                	jmp    80099b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80098f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800994:	eb 05                	jmp    80099b <fd_lookup+0x54>
  800996:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	83 ec 08             	sub    $0x8,%esp
  8009a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a6:	ba 40 25 80 00       	mov    $0x802540,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009ab:	eb 13                	jmp    8009c0 <dev_lookup+0x23>
  8009ad:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009b0:	39 08                	cmp    %ecx,(%eax)
  8009b2:	75 0c                	jne    8009c0 <dev_lookup+0x23>
			*dev = devtab[i];
  8009b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009be:	eb 31                	jmp    8009f1 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009c0:	8b 02                	mov    (%edx),%eax
  8009c2:	85 c0                	test   %eax,%eax
  8009c4:	75 e7                	jne    8009ad <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8009cb:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009d1:	83 ec 04             	sub    $0x4,%esp
  8009d4:	51                   	push   %ecx
  8009d5:	50                   	push   %eax
  8009d6:	68 c4 24 80 00       	push   $0x8024c4
  8009db:	e8 c9 0c 00 00       	call   8016a9 <cprintf>
	*dev = 0;
  8009e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	83 ec 10             	sub    $0x10,%esp
  8009fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a04:	50                   	push   %eax
  800a05:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a0b:	c1 e8 0c             	shr    $0xc,%eax
  800a0e:	50                   	push   %eax
  800a0f:	e8 33 ff ff ff       	call   800947 <fd_lookup>
  800a14:	83 c4 08             	add    $0x8,%esp
  800a17:	85 c0                	test   %eax,%eax
  800a19:	78 05                	js     800a20 <fd_close+0x2d>
	    || fd != fd2)
  800a1b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a1e:	74 0c                	je     800a2c <fd_close+0x39>
		return (must_exist ? r : 0);
  800a20:	84 db                	test   %bl,%bl
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	0f 44 c2             	cmove  %edx,%eax
  800a2a:	eb 41                	jmp    800a6d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a2c:	83 ec 08             	sub    $0x8,%esp
  800a2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a32:	50                   	push   %eax
  800a33:	ff 36                	pushl  (%esi)
  800a35:	e8 63 ff ff ff       	call   80099d <dev_lookup>
  800a3a:	89 c3                	mov    %eax,%ebx
  800a3c:	83 c4 10             	add    $0x10,%esp
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	78 1a                	js     800a5d <fd_close+0x6a>
		if (dev->dev_close)
  800a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a46:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a49:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a4e:	85 c0                	test   %eax,%eax
  800a50:	74 0b                	je     800a5d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a52:	83 ec 0c             	sub    $0xc,%esp
  800a55:	56                   	push   %esi
  800a56:	ff d0                	call   *%eax
  800a58:	89 c3                	mov    %eax,%ebx
  800a5a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a5d:	83 ec 08             	sub    $0x8,%esp
  800a60:	56                   	push   %esi
  800a61:	6a 00                	push   $0x0
  800a63:	e8 a3 f7 ff ff       	call   80020b <sys_page_unmap>
	return r;
  800a68:	83 c4 10             	add    $0x10,%esp
  800a6b:	89 d8                	mov    %ebx,%eax
}
  800a6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a7d:	50                   	push   %eax
  800a7e:	ff 75 08             	pushl  0x8(%ebp)
  800a81:	e8 c1 fe ff ff       	call   800947 <fd_lookup>
  800a86:	83 c4 08             	add    $0x8,%esp
  800a89:	85 c0                	test   %eax,%eax
  800a8b:	78 10                	js     800a9d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a8d:	83 ec 08             	sub    $0x8,%esp
  800a90:	6a 01                	push   $0x1
  800a92:	ff 75 f4             	pushl  -0xc(%ebp)
  800a95:	e8 59 ff ff ff       	call   8009f3 <fd_close>
  800a9a:	83 c4 10             	add    $0x10,%esp
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <close_all>:

void
close_all(void)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800aa6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800aab:	83 ec 0c             	sub    $0xc,%esp
  800aae:	53                   	push   %ebx
  800aaf:	e8 c0 ff ff ff       	call   800a74 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ab4:	83 c3 01             	add    $0x1,%ebx
  800ab7:	83 c4 10             	add    $0x10,%esp
  800aba:	83 fb 20             	cmp    $0x20,%ebx
  800abd:	75 ec                	jne    800aab <close_all+0xc>
		close(i);
}
  800abf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	83 ec 2c             	sub    $0x2c,%esp
  800acd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ad0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ad3:	50                   	push   %eax
  800ad4:	ff 75 08             	pushl  0x8(%ebp)
  800ad7:	e8 6b fe ff ff       	call   800947 <fd_lookup>
  800adc:	83 c4 08             	add    $0x8,%esp
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	0f 88 c1 00 00 00    	js     800ba8 <dup+0xe4>
		return r;
	close(newfdnum);
  800ae7:	83 ec 0c             	sub    $0xc,%esp
  800aea:	56                   	push   %esi
  800aeb:	e8 84 ff ff ff       	call   800a74 <close>

	newfd = INDEX2FD(newfdnum);
  800af0:	89 f3                	mov    %esi,%ebx
  800af2:	c1 e3 0c             	shl    $0xc,%ebx
  800af5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800afb:	83 c4 04             	add    $0x4,%esp
  800afe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b01:	e8 db fd ff ff       	call   8008e1 <fd2data>
  800b06:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b08:	89 1c 24             	mov    %ebx,(%esp)
  800b0b:	e8 d1 fd ff ff       	call   8008e1 <fd2data>
  800b10:	83 c4 10             	add    $0x10,%esp
  800b13:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b16:	89 f8                	mov    %edi,%eax
  800b18:	c1 e8 16             	shr    $0x16,%eax
  800b1b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b22:	a8 01                	test   $0x1,%al
  800b24:	74 37                	je     800b5d <dup+0x99>
  800b26:	89 f8                	mov    %edi,%eax
  800b28:	c1 e8 0c             	shr    $0xc,%eax
  800b2b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b32:	f6 c2 01             	test   $0x1,%dl
  800b35:	74 26                	je     800b5d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b37:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	25 07 0e 00 00       	and    $0xe07,%eax
  800b46:	50                   	push   %eax
  800b47:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b4a:	6a 00                	push   $0x0
  800b4c:	57                   	push   %edi
  800b4d:	6a 00                	push   $0x0
  800b4f:	e8 75 f6 ff ff       	call   8001c9 <sys_page_map>
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	83 c4 20             	add    $0x20,%esp
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	78 2e                	js     800b8b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b5d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b60:	89 d0                	mov    %edx,%eax
  800b62:	c1 e8 0c             	shr    $0xc,%eax
  800b65:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	25 07 0e 00 00       	and    $0xe07,%eax
  800b74:	50                   	push   %eax
  800b75:	53                   	push   %ebx
  800b76:	6a 00                	push   $0x0
  800b78:	52                   	push   %edx
  800b79:	6a 00                	push   $0x0
  800b7b:	e8 49 f6 ff ff       	call   8001c9 <sys_page_map>
  800b80:	89 c7                	mov    %eax,%edi
  800b82:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b85:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b87:	85 ff                	test   %edi,%edi
  800b89:	79 1d                	jns    800ba8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b8b:	83 ec 08             	sub    $0x8,%esp
  800b8e:	53                   	push   %ebx
  800b8f:	6a 00                	push   $0x0
  800b91:	e8 75 f6 ff ff       	call   80020b <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b96:	83 c4 08             	add    $0x8,%esp
  800b99:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b9c:	6a 00                	push   $0x0
  800b9e:	e8 68 f6 ff ff       	call   80020b <sys_page_unmap>
	return r;
  800ba3:	83 c4 10             	add    $0x10,%esp
  800ba6:	89 f8                	mov    %edi,%eax
}
  800ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 14             	sub    $0x14,%esp
  800bb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bbd:	50                   	push   %eax
  800bbe:	53                   	push   %ebx
  800bbf:	e8 83 fd ff ff       	call   800947 <fd_lookup>
  800bc4:	83 c4 08             	add    $0x8,%esp
  800bc7:	89 c2                	mov    %eax,%edx
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	78 70                	js     800c3d <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bcd:	83 ec 08             	sub    $0x8,%esp
  800bd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bd3:	50                   	push   %eax
  800bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd7:	ff 30                	pushl  (%eax)
  800bd9:	e8 bf fd ff ff       	call   80099d <dev_lookup>
  800bde:	83 c4 10             	add    $0x10,%esp
  800be1:	85 c0                	test   %eax,%eax
  800be3:	78 4f                	js     800c34 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800be5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800be8:	8b 42 08             	mov    0x8(%edx),%eax
  800beb:	83 e0 03             	and    $0x3,%eax
  800bee:	83 f8 01             	cmp    $0x1,%eax
  800bf1:	75 24                	jne    800c17 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bf3:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf8:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800bfe:	83 ec 04             	sub    $0x4,%esp
  800c01:	53                   	push   %ebx
  800c02:	50                   	push   %eax
  800c03:	68 05 25 80 00       	push   $0x802505
  800c08:	e8 9c 0a 00 00       	call   8016a9 <cprintf>
		return -E_INVAL;
  800c0d:	83 c4 10             	add    $0x10,%esp
  800c10:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c15:	eb 26                	jmp    800c3d <read+0x8d>
	}
	if (!dev->dev_read)
  800c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1a:	8b 40 08             	mov    0x8(%eax),%eax
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	74 17                	je     800c38 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c21:	83 ec 04             	sub    $0x4,%esp
  800c24:	ff 75 10             	pushl  0x10(%ebp)
  800c27:	ff 75 0c             	pushl  0xc(%ebp)
  800c2a:	52                   	push   %edx
  800c2b:	ff d0                	call   *%eax
  800c2d:	89 c2                	mov    %eax,%edx
  800c2f:	83 c4 10             	add    $0x10,%esp
  800c32:	eb 09                	jmp    800c3d <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c34:	89 c2                	mov    %eax,%edx
  800c36:	eb 05                	jmp    800c3d <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c38:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c3d:	89 d0                	mov    %edx,%eax
  800c3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c50:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	eb 21                	jmp    800c7b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c5a:	83 ec 04             	sub    $0x4,%esp
  800c5d:	89 f0                	mov    %esi,%eax
  800c5f:	29 d8                	sub    %ebx,%eax
  800c61:	50                   	push   %eax
  800c62:	89 d8                	mov    %ebx,%eax
  800c64:	03 45 0c             	add    0xc(%ebp),%eax
  800c67:	50                   	push   %eax
  800c68:	57                   	push   %edi
  800c69:	e8 42 ff ff ff       	call   800bb0 <read>
		if (m < 0)
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	85 c0                	test   %eax,%eax
  800c73:	78 10                	js     800c85 <readn+0x41>
			return m;
		if (m == 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	74 0a                	je     800c83 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c79:	01 c3                	add    %eax,%ebx
  800c7b:	39 f3                	cmp    %esi,%ebx
  800c7d:	72 db                	jb     800c5a <readn+0x16>
  800c7f:	89 d8                	mov    %ebx,%eax
  800c81:	eb 02                	jmp    800c85 <readn+0x41>
  800c83:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	53                   	push   %ebx
  800c91:	83 ec 14             	sub    $0x14,%esp
  800c94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c97:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c9a:	50                   	push   %eax
  800c9b:	53                   	push   %ebx
  800c9c:	e8 a6 fc ff ff       	call   800947 <fd_lookup>
  800ca1:	83 c4 08             	add    $0x8,%esp
  800ca4:	89 c2                	mov    %eax,%edx
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	78 6b                	js     800d15 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800caa:	83 ec 08             	sub    $0x8,%esp
  800cad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cb0:	50                   	push   %eax
  800cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cb4:	ff 30                	pushl  (%eax)
  800cb6:	e8 e2 fc ff ff       	call   80099d <dev_lookup>
  800cbb:	83 c4 10             	add    $0x10,%esp
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	78 4a                	js     800d0c <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cc9:	75 24                	jne    800cef <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800ccb:	a1 04 40 80 00       	mov    0x804004,%eax
  800cd0:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800cd6:	83 ec 04             	sub    $0x4,%esp
  800cd9:	53                   	push   %ebx
  800cda:	50                   	push   %eax
  800cdb:	68 21 25 80 00       	push   $0x802521
  800ce0:	e8 c4 09 00 00       	call   8016a9 <cprintf>
		return -E_INVAL;
  800ce5:	83 c4 10             	add    $0x10,%esp
  800ce8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ced:	eb 26                	jmp    800d15 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800cef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cf2:	8b 52 0c             	mov    0xc(%edx),%edx
  800cf5:	85 d2                	test   %edx,%edx
  800cf7:	74 17                	je     800d10 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800cf9:	83 ec 04             	sub    $0x4,%esp
  800cfc:	ff 75 10             	pushl  0x10(%ebp)
  800cff:	ff 75 0c             	pushl  0xc(%ebp)
  800d02:	50                   	push   %eax
  800d03:	ff d2                	call   *%edx
  800d05:	89 c2                	mov    %eax,%edx
  800d07:	83 c4 10             	add    $0x10,%esp
  800d0a:	eb 09                	jmp    800d15 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d0c:	89 c2                	mov    %eax,%edx
  800d0e:	eb 05                	jmp    800d15 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d10:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d15:	89 d0                	mov    %edx,%eax
  800d17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d1a:	c9                   	leave  
  800d1b:	c3                   	ret    

00800d1c <seek>:

int
seek(int fdnum, off_t offset)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d22:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d25:	50                   	push   %eax
  800d26:	ff 75 08             	pushl  0x8(%ebp)
  800d29:	e8 19 fc ff ff       	call   800947 <fd_lookup>
  800d2e:	83 c4 08             	add    $0x8,%esp
  800d31:	85 c0                	test   %eax,%eax
  800d33:	78 0e                	js     800d43 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	53                   	push   %ebx
  800d49:	83 ec 14             	sub    $0x14,%esp
  800d4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d52:	50                   	push   %eax
  800d53:	53                   	push   %ebx
  800d54:	e8 ee fb ff ff       	call   800947 <fd_lookup>
  800d59:	83 c4 08             	add    $0x8,%esp
  800d5c:	89 c2                	mov    %eax,%edx
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	78 68                	js     800dca <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d62:	83 ec 08             	sub    $0x8,%esp
  800d65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d68:	50                   	push   %eax
  800d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d6c:	ff 30                	pushl  (%eax)
  800d6e:	e8 2a fc ff ff       	call   80099d <dev_lookup>
  800d73:	83 c4 10             	add    $0x10,%esp
  800d76:	85 c0                	test   %eax,%eax
  800d78:	78 47                	js     800dc1 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d7d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d81:	75 24                	jne    800da7 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d83:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d88:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d8e:	83 ec 04             	sub    $0x4,%esp
  800d91:	53                   	push   %ebx
  800d92:	50                   	push   %eax
  800d93:	68 e4 24 80 00       	push   $0x8024e4
  800d98:	e8 0c 09 00 00       	call   8016a9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800da5:	eb 23                	jmp    800dca <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800da7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800daa:	8b 52 18             	mov    0x18(%edx),%edx
  800dad:	85 d2                	test   %edx,%edx
  800daf:	74 14                	je     800dc5 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800db1:	83 ec 08             	sub    $0x8,%esp
  800db4:	ff 75 0c             	pushl  0xc(%ebp)
  800db7:	50                   	push   %eax
  800db8:	ff d2                	call   *%edx
  800dba:	89 c2                	mov    %eax,%edx
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	eb 09                	jmp    800dca <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dc1:	89 c2                	mov    %eax,%edx
  800dc3:	eb 05                	jmp    800dca <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dc5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dca:	89 d0                	mov    %edx,%eax
  800dcc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dcf:	c9                   	leave  
  800dd0:	c3                   	ret    

00800dd1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 14             	sub    $0x14,%esp
  800dd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ddb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dde:	50                   	push   %eax
  800ddf:	ff 75 08             	pushl  0x8(%ebp)
  800de2:	e8 60 fb ff ff       	call   800947 <fd_lookup>
  800de7:	83 c4 08             	add    $0x8,%esp
  800dea:	89 c2                	mov    %eax,%edx
  800dec:	85 c0                	test   %eax,%eax
  800dee:	78 58                	js     800e48 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800df0:	83 ec 08             	sub    $0x8,%esp
  800df3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800df6:	50                   	push   %eax
  800df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfa:	ff 30                	pushl  (%eax)
  800dfc:	e8 9c fb ff ff       	call   80099d <dev_lookup>
  800e01:	83 c4 10             	add    $0x10,%esp
  800e04:	85 c0                	test   %eax,%eax
  800e06:	78 37                	js     800e3f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e0f:	74 32                	je     800e43 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e11:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e14:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e1b:	00 00 00 
	stat->st_isdir = 0;
  800e1e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e25:	00 00 00 
	stat->st_dev = dev;
  800e28:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	53                   	push   %ebx
  800e32:	ff 75 f0             	pushl  -0x10(%ebp)
  800e35:	ff 50 14             	call   *0x14(%eax)
  800e38:	89 c2                	mov    %eax,%edx
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	eb 09                	jmp    800e48 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e3f:	89 c2                	mov    %eax,%edx
  800e41:	eb 05                	jmp    800e48 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e43:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e48:	89 d0                	mov    %edx,%eax
  800e4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4d:	c9                   	leave  
  800e4e:	c3                   	ret    

00800e4f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e54:	83 ec 08             	sub    $0x8,%esp
  800e57:	6a 00                	push   $0x0
  800e59:	ff 75 08             	pushl  0x8(%ebp)
  800e5c:	e8 e3 01 00 00       	call   801044 <open>
  800e61:	89 c3                	mov    %eax,%ebx
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	85 c0                	test   %eax,%eax
  800e68:	78 1b                	js     800e85 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e6a:	83 ec 08             	sub    $0x8,%esp
  800e6d:	ff 75 0c             	pushl  0xc(%ebp)
  800e70:	50                   	push   %eax
  800e71:	e8 5b ff ff ff       	call   800dd1 <fstat>
  800e76:	89 c6                	mov    %eax,%esi
	close(fd);
  800e78:	89 1c 24             	mov    %ebx,(%esp)
  800e7b:	e8 f4 fb ff ff       	call   800a74 <close>
	return r;
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	89 f0                	mov    %esi,%eax
}
  800e85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
  800e91:	89 c6                	mov    %eax,%esi
  800e93:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e95:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e9c:	75 12                	jne    800eb0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e9e:	83 ec 0c             	sub    $0xc,%esp
  800ea1:	6a 01                	push   $0x1
  800ea3:	e8 39 12 00 00       	call   8020e1 <ipc_find_env>
  800ea8:	a3 00 40 80 00       	mov    %eax,0x804000
  800ead:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800eb0:	6a 07                	push   $0x7
  800eb2:	68 00 50 80 00       	push   $0x805000
  800eb7:	56                   	push   %esi
  800eb8:	ff 35 00 40 80 00    	pushl  0x804000
  800ebe:	e8 bc 11 00 00       	call   80207f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ec3:	83 c4 0c             	add    $0xc,%esp
  800ec6:	6a 00                	push   $0x0
  800ec8:	53                   	push   %ebx
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 34 11 00 00       	call   802004 <ipc_recv>
}
  800ed0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	8b 40 0c             	mov    0xc(%eax),%eax
  800ee3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eeb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ef0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef5:	b8 02 00 00 00       	mov    $0x2,%eax
  800efa:	e8 8d ff ff ff       	call   800e8c <fsipc>
}
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0a:	8b 40 0c             	mov    0xc(%eax),%eax
  800f0d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f12:	ba 00 00 00 00       	mov    $0x0,%edx
  800f17:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1c:	e8 6b ff ff ff       	call   800e8c <fsipc>
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	53                   	push   %ebx
  800f27:	83 ec 04             	sub    $0x4,%esp
  800f2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f30:	8b 40 0c             	mov    0xc(%eax),%eax
  800f33:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f38:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3d:	b8 05 00 00 00       	mov    $0x5,%eax
  800f42:	e8 45 ff ff ff       	call   800e8c <fsipc>
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 2c                	js     800f77 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f4b:	83 ec 08             	sub    $0x8,%esp
  800f4e:	68 00 50 80 00       	push   $0x805000
  800f53:	53                   	push   %ebx
  800f54:	e8 d5 0c 00 00       	call   801c2e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f59:	a1 80 50 80 00       	mov    0x805080,%eax
  800f5e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f64:	a1 84 50 80 00       	mov    0x805084,%eax
  800f69:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    

00800f7c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
  800f88:	8b 52 0c             	mov    0xc(%edx),%edx
  800f8b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f91:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f96:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800f9b:	0f 47 c2             	cmova  %edx,%eax
  800f9e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800fa3:	50                   	push   %eax
  800fa4:	ff 75 0c             	pushl  0xc(%ebp)
  800fa7:	68 08 50 80 00       	push   $0x805008
  800fac:	e8 0f 0e 00 00       	call   801dc0 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb6:	b8 04 00 00 00       	mov    $0x4,%eax
  800fbb:	e8 cc fe ff ff       	call   800e8c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fc0:	c9                   	leave  
  800fc1:	c3                   	ret    

00800fc2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	56                   	push   %esi
  800fc6:	53                   	push   %ebx
  800fc7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fca:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcd:	8b 40 0c             	mov    0xc(%eax),%eax
  800fd0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fd5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe0:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe5:	e8 a2 fe ff ff       	call   800e8c <fsipc>
  800fea:	89 c3                	mov    %eax,%ebx
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 4b                	js     80103b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ff0:	39 c6                	cmp    %eax,%esi
  800ff2:	73 16                	jae    80100a <devfile_read+0x48>
  800ff4:	68 50 25 80 00       	push   $0x802550
  800ff9:	68 57 25 80 00       	push   $0x802557
  800ffe:	6a 7c                	push   $0x7c
  801000:	68 6c 25 80 00       	push   $0x80256c
  801005:	e8 c6 05 00 00       	call   8015d0 <_panic>
	assert(r <= PGSIZE);
  80100a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80100f:	7e 16                	jle    801027 <devfile_read+0x65>
  801011:	68 77 25 80 00       	push   $0x802577
  801016:	68 57 25 80 00       	push   $0x802557
  80101b:	6a 7d                	push   $0x7d
  80101d:	68 6c 25 80 00       	push   $0x80256c
  801022:	e8 a9 05 00 00       	call   8015d0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801027:	83 ec 04             	sub    $0x4,%esp
  80102a:	50                   	push   %eax
  80102b:	68 00 50 80 00       	push   $0x805000
  801030:	ff 75 0c             	pushl  0xc(%ebp)
  801033:	e8 88 0d 00 00       	call   801dc0 <memmove>
	return r;
  801038:	83 c4 10             	add    $0x10,%esp
}
  80103b:	89 d8                	mov    %ebx,%eax
  80103d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	53                   	push   %ebx
  801048:	83 ec 20             	sub    $0x20,%esp
  80104b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80104e:	53                   	push   %ebx
  80104f:	e8 a1 0b 00 00       	call   801bf5 <strlen>
  801054:	83 c4 10             	add    $0x10,%esp
  801057:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80105c:	7f 67                	jg     8010c5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801064:	50                   	push   %eax
  801065:	e8 8e f8 ff ff       	call   8008f8 <fd_alloc>
  80106a:	83 c4 10             	add    $0x10,%esp
		return r;
  80106d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80106f:	85 c0                	test   %eax,%eax
  801071:	78 57                	js     8010ca <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801073:	83 ec 08             	sub    $0x8,%esp
  801076:	53                   	push   %ebx
  801077:	68 00 50 80 00       	push   $0x805000
  80107c:	e8 ad 0b 00 00       	call   801c2e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801081:	8b 45 0c             	mov    0xc(%ebp),%eax
  801084:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801089:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80108c:	b8 01 00 00 00       	mov    $0x1,%eax
  801091:	e8 f6 fd ff ff       	call   800e8c <fsipc>
  801096:	89 c3                	mov    %eax,%ebx
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	79 14                	jns    8010b3 <open+0x6f>
		fd_close(fd, 0);
  80109f:	83 ec 08             	sub    $0x8,%esp
  8010a2:	6a 00                	push   $0x0
  8010a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a7:	e8 47 f9 ff ff       	call   8009f3 <fd_close>
		return r;
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	89 da                	mov    %ebx,%edx
  8010b1:	eb 17                	jmp    8010ca <open+0x86>
	}

	return fd2num(fd);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b9:	e8 13 f8 ff ff       	call   8008d1 <fd2num>
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	eb 05                	jmp    8010ca <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010c5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010ca:	89 d0                	mov    %edx,%eax
  8010cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    

008010d1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8010e1:	e8 a6 fd ff ff       	call   800e8c <fsipc>
}
  8010e6:	c9                   	leave  
  8010e7:	c3                   	ret    

008010e8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
  8010ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	ff 75 08             	pushl  0x8(%ebp)
  8010f6:	e8 e6 f7 ff ff       	call   8008e1 <fd2data>
  8010fb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	68 83 25 80 00       	push   $0x802583
  801105:	53                   	push   %ebx
  801106:	e8 23 0b 00 00       	call   801c2e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80110b:	8b 46 04             	mov    0x4(%esi),%eax
  80110e:	2b 06                	sub    (%esi),%eax
  801110:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801116:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80111d:	00 00 00 
	stat->st_dev = &devpipe;
  801120:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801127:	30 80 00 
	return 0;
}
  80112a:	b8 00 00 00 00       	mov    $0x0,%eax
  80112f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801132:	5b                   	pop    %ebx
  801133:	5e                   	pop    %esi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	53                   	push   %ebx
  80113a:	83 ec 0c             	sub    $0xc,%esp
  80113d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801140:	53                   	push   %ebx
  801141:	6a 00                	push   $0x0
  801143:	e8 c3 f0 ff ff       	call   80020b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801148:	89 1c 24             	mov    %ebx,(%esp)
  80114b:	e8 91 f7 ff ff       	call   8008e1 <fd2data>
  801150:	83 c4 08             	add    $0x8,%esp
  801153:	50                   	push   %eax
  801154:	6a 00                	push   $0x0
  801156:	e8 b0 f0 ff ff       	call   80020b <sys_page_unmap>
}
  80115b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	83 ec 1c             	sub    $0x1c,%esp
  801169:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80116c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80116e:	a1 04 40 80 00       	mov    0x804004,%eax
  801173:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	ff 75 e0             	pushl  -0x20(%ebp)
  80117f:	e8 a2 0f 00 00       	call   802126 <pageref>
  801184:	89 c3                	mov    %eax,%ebx
  801186:	89 3c 24             	mov    %edi,(%esp)
  801189:	e8 98 0f 00 00       	call   802126 <pageref>
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	39 c3                	cmp    %eax,%ebx
  801193:	0f 94 c1             	sete   %cl
  801196:	0f b6 c9             	movzbl %cl,%ecx
  801199:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80119c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011a2:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011a8:	39 ce                	cmp    %ecx,%esi
  8011aa:	74 1e                	je     8011ca <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011ac:	39 c3                	cmp    %eax,%ebx
  8011ae:	75 be                	jne    80116e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011b0:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b9:	50                   	push   %eax
  8011ba:	56                   	push   %esi
  8011bb:	68 8a 25 80 00       	push   $0x80258a
  8011c0:	e8 e4 04 00 00       	call   8016a9 <cprintf>
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	eb a4                	jmp    80116e <_pipeisclosed+0xe>
	}
}
  8011ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d0:	5b                   	pop    %ebx
  8011d1:	5e                   	pop    %esi
  8011d2:	5f                   	pop    %edi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	57                   	push   %edi
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 28             	sub    $0x28,%esp
  8011de:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011e1:	56                   	push   %esi
  8011e2:	e8 fa f6 ff ff       	call   8008e1 <fd2data>
  8011e7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	bf 00 00 00 00       	mov    $0x0,%edi
  8011f1:	eb 4b                	jmp    80123e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011f3:	89 da                	mov    %ebx,%edx
  8011f5:	89 f0                	mov    %esi,%eax
  8011f7:	e8 64 ff ff ff       	call   801160 <_pipeisclosed>
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	75 48                	jne    801248 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801200:	e8 62 ef ff ff       	call   800167 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801205:	8b 43 04             	mov    0x4(%ebx),%eax
  801208:	8b 0b                	mov    (%ebx),%ecx
  80120a:	8d 51 20             	lea    0x20(%ecx),%edx
  80120d:	39 d0                	cmp    %edx,%eax
  80120f:	73 e2                	jae    8011f3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801214:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801218:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80121b:	89 c2                	mov    %eax,%edx
  80121d:	c1 fa 1f             	sar    $0x1f,%edx
  801220:	89 d1                	mov    %edx,%ecx
  801222:	c1 e9 1b             	shr    $0x1b,%ecx
  801225:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801228:	83 e2 1f             	and    $0x1f,%edx
  80122b:	29 ca                	sub    %ecx,%edx
  80122d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801231:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801235:	83 c0 01             	add    $0x1,%eax
  801238:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80123b:	83 c7 01             	add    $0x1,%edi
  80123e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801241:	75 c2                	jne    801205 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801243:	8b 45 10             	mov    0x10(%ebp),%eax
  801246:	eb 05                	jmp    80124d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80124d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801250:	5b                   	pop    %ebx
  801251:	5e                   	pop    %esi
  801252:	5f                   	pop    %edi
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	83 ec 18             	sub    $0x18,%esp
  80125e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801261:	57                   	push   %edi
  801262:	e8 7a f6 ff ff       	call   8008e1 <fd2data>
  801267:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801271:	eb 3d                	jmp    8012b0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801273:	85 db                	test   %ebx,%ebx
  801275:	74 04                	je     80127b <devpipe_read+0x26>
				return i;
  801277:	89 d8                	mov    %ebx,%eax
  801279:	eb 44                	jmp    8012bf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80127b:	89 f2                	mov    %esi,%edx
  80127d:	89 f8                	mov    %edi,%eax
  80127f:	e8 dc fe ff ff       	call   801160 <_pipeisclosed>
  801284:	85 c0                	test   %eax,%eax
  801286:	75 32                	jne    8012ba <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801288:	e8 da ee ff ff       	call   800167 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80128d:	8b 06                	mov    (%esi),%eax
  80128f:	3b 46 04             	cmp    0x4(%esi),%eax
  801292:	74 df                	je     801273 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801294:	99                   	cltd   
  801295:	c1 ea 1b             	shr    $0x1b,%edx
  801298:	01 d0                	add    %edx,%eax
  80129a:	83 e0 1f             	and    $0x1f,%eax
  80129d:	29 d0                	sub    %edx,%eax
  80129f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8012a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012aa:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012ad:	83 c3 01             	add    $0x1,%ebx
  8012b0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012b3:	75 d8                	jne    80128d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8012b8:	eb 05                	jmp    8012bf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5e                   	pop    %esi
  8012c4:	5f                   	pop    %edi
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    

008012c7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	56                   	push   %esi
  8012cb:	53                   	push   %ebx
  8012cc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d2:	50                   	push   %eax
  8012d3:	e8 20 f6 ff ff       	call   8008f8 <fd_alloc>
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	0f 88 2c 01 00 00    	js     801411 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e5:	83 ec 04             	sub    $0x4,%esp
  8012e8:	68 07 04 00 00       	push   $0x407
  8012ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f0:	6a 00                	push   $0x0
  8012f2:	e8 8f ee ff ff       	call   800186 <sys_page_alloc>
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	89 c2                	mov    %eax,%edx
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	0f 88 0d 01 00 00    	js     801411 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	e8 e8 f5 ff ff       	call   8008f8 <fd_alloc>
  801310:	89 c3                	mov    %eax,%ebx
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	0f 88 e2 00 00 00    	js     8013ff <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80131d:	83 ec 04             	sub    $0x4,%esp
  801320:	68 07 04 00 00       	push   $0x407
  801325:	ff 75 f0             	pushl  -0x10(%ebp)
  801328:	6a 00                	push   $0x0
  80132a:	e8 57 ee ff ff       	call   800186 <sys_page_alloc>
  80132f:	89 c3                	mov    %eax,%ebx
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	0f 88 c3 00 00 00    	js     8013ff <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	ff 75 f4             	pushl  -0xc(%ebp)
  801342:	e8 9a f5 ff ff       	call   8008e1 <fd2data>
  801347:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801349:	83 c4 0c             	add    $0xc,%esp
  80134c:	68 07 04 00 00       	push   $0x407
  801351:	50                   	push   %eax
  801352:	6a 00                	push   $0x0
  801354:	e8 2d ee ff ff       	call   800186 <sys_page_alloc>
  801359:	89 c3                	mov    %eax,%ebx
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	0f 88 89 00 00 00    	js     8013ef <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801366:	83 ec 0c             	sub    $0xc,%esp
  801369:	ff 75 f0             	pushl  -0x10(%ebp)
  80136c:	e8 70 f5 ff ff       	call   8008e1 <fd2data>
  801371:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801378:	50                   	push   %eax
  801379:	6a 00                	push   $0x0
  80137b:	56                   	push   %esi
  80137c:	6a 00                	push   $0x0
  80137e:	e8 46 ee ff ff       	call   8001c9 <sys_page_map>
  801383:	89 c3                	mov    %eax,%ebx
  801385:	83 c4 20             	add    $0x20,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 55                	js     8013e1 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80138c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801392:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801395:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801397:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013a1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013aa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013af:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013b6:	83 ec 0c             	sub    $0xc,%esp
  8013b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013bc:	e8 10 f5 ff ff       	call   8008d1 <fd2num>
  8013c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013c6:	83 c4 04             	add    $0x4,%esp
  8013c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8013cc:	e8 00 f5 ff ff       	call   8008d1 <fd2num>
  8013d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d4:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	ba 00 00 00 00       	mov    $0x0,%edx
  8013df:	eb 30                	jmp    801411 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	56                   	push   %esi
  8013e5:	6a 00                	push   $0x0
  8013e7:	e8 1f ee ff ff       	call   80020b <sys_page_unmap>
  8013ec:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 0f ee ff ff       	call   80020b <sys_page_unmap>
  8013fc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	ff 75 f4             	pushl  -0xc(%ebp)
  801405:	6a 00                	push   $0x0
  801407:	e8 ff ed ff ff       	call   80020b <sys_page_unmap>
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801411:	89 d0                	mov    %edx,%eax
  801413:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801416:	5b                   	pop    %ebx
  801417:	5e                   	pop    %esi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    

0080141a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	ff 75 08             	pushl  0x8(%ebp)
  801427:	e8 1b f5 ff ff       	call   800947 <fd_lookup>
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 18                	js     80144b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801433:	83 ec 0c             	sub    $0xc,%esp
  801436:	ff 75 f4             	pushl  -0xc(%ebp)
  801439:	e8 a3 f4 ff ff       	call   8008e1 <fd2data>
	return _pipeisclosed(fd, p);
  80143e:	89 c2                	mov    %eax,%edx
  801440:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801443:	e8 18 fd ff ff       	call   801160 <_pipeisclosed>
  801448:	83 c4 10             	add    $0x10,%esp
}
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801450:	b8 00 00 00 00       	mov    $0x0,%eax
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    

00801457 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80145d:	68 a2 25 80 00       	push   $0x8025a2
  801462:	ff 75 0c             	pushl  0xc(%ebp)
  801465:	e8 c4 07 00 00       	call   801c2e <strcpy>
	return 0;
}
  80146a:	b8 00 00 00 00       	mov    $0x0,%eax
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	57                   	push   %edi
  801475:	56                   	push   %esi
  801476:	53                   	push   %ebx
  801477:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80147d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801482:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801488:	eb 2d                	jmp    8014b7 <devcons_write+0x46>
		m = n - tot;
  80148a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80148d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80148f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801492:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801497:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80149a:	83 ec 04             	sub    $0x4,%esp
  80149d:	53                   	push   %ebx
  80149e:	03 45 0c             	add    0xc(%ebp),%eax
  8014a1:	50                   	push   %eax
  8014a2:	57                   	push   %edi
  8014a3:	e8 18 09 00 00       	call   801dc0 <memmove>
		sys_cputs(buf, m);
  8014a8:	83 c4 08             	add    $0x8,%esp
  8014ab:	53                   	push   %ebx
  8014ac:	57                   	push   %edi
  8014ad:	e8 18 ec ff ff       	call   8000ca <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014b2:	01 de                	add    %ebx,%esi
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	89 f0                	mov    %esi,%eax
  8014b9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014bc:	72 cc                	jb     80148a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5e                   	pop    %esi
  8014c3:	5f                   	pop    %edi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    

008014c6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	83 ec 08             	sub    $0x8,%esp
  8014cc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014d5:	74 2a                	je     801501 <devcons_read+0x3b>
  8014d7:	eb 05                	jmp    8014de <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014d9:	e8 89 ec ff ff       	call   800167 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014de:	e8 05 ec ff ff       	call   8000e8 <sys_cgetc>
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	74 f2                	je     8014d9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 16                	js     801501 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014eb:	83 f8 04             	cmp    $0x4,%eax
  8014ee:	74 0c                	je     8014fc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f3:	88 02                	mov    %al,(%edx)
	return 1;
  8014f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fa:	eb 05                	jmp    801501 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014fc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801509:	8b 45 08             	mov    0x8(%ebp),%eax
  80150c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80150f:	6a 01                	push   $0x1
  801511:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801514:	50                   	push   %eax
  801515:	e8 b0 eb ff ff       	call   8000ca <sys_cputs>
}
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    

0080151f <getchar>:

int
getchar(void)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801525:	6a 01                	push   $0x1
  801527:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	6a 00                	push   $0x0
  80152d:	e8 7e f6 ff ff       	call   800bb0 <read>
	if (r < 0)
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	85 c0                	test   %eax,%eax
  801537:	78 0f                	js     801548 <getchar+0x29>
		return r;
	if (r < 1)
  801539:	85 c0                	test   %eax,%eax
  80153b:	7e 06                	jle    801543 <getchar+0x24>
		return -E_EOF;
	return c;
  80153d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801541:	eb 05                	jmp    801548 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801543:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801553:	50                   	push   %eax
  801554:	ff 75 08             	pushl  0x8(%ebp)
  801557:	e8 eb f3 ff ff       	call   800947 <fd_lookup>
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 11                	js     801574 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801563:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801566:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80156c:	39 10                	cmp    %edx,(%eax)
  80156e:	0f 94 c0             	sete   %al
  801571:	0f b6 c0             	movzbl %al,%eax
}
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <opencons>:

int
opencons(void)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80157c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	e8 73 f3 ff ff       	call   8008f8 <fd_alloc>
  801585:	83 c4 10             	add    $0x10,%esp
		return r;
  801588:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 3e                	js     8015cc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80158e:	83 ec 04             	sub    $0x4,%esp
  801591:	68 07 04 00 00       	push   $0x407
  801596:	ff 75 f4             	pushl  -0xc(%ebp)
  801599:	6a 00                	push   $0x0
  80159b:	e8 e6 eb ff ff       	call   800186 <sys_page_alloc>
  8015a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8015a3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 23                	js     8015cc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015a9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015be:	83 ec 0c             	sub    $0xc,%esp
  8015c1:	50                   	push   %eax
  8015c2:	e8 0a f3 ff ff       	call   8008d1 <fd2num>
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	83 c4 10             	add    $0x10,%esp
}
  8015cc:	89 d0                	mov    %edx,%eax
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	56                   	push   %esi
  8015d4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015d5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015d8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015de:	e8 65 eb ff ff       	call   800148 <sys_getenvid>
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	ff 75 0c             	pushl  0xc(%ebp)
  8015e9:	ff 75 08             	pushl  0x8(%ebp)
  8015ec:	56                   	push   %esi
  8015ed:	50                   	push   %eax
  8015ee:	68 b0 25 80 00       	push   $0x8025b0
  8015f3:	e8 b1 00 00 00       	call   8016a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015f8:	83 c4 18             	add    $0x18,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	ff 75 10             	pushl  0x10(%ebp)
  8015ff:	e8 54 00 00 00       	call   801658 <vcprintf>
	cprintf("\n");
  801604:	c7 04 24 a6 24 80 00 	movl   $0x8024a6,(%esp)
  80160b:	e8 99 00 00 00       	call   8016a9 <cprintf>
  801610:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801613:	cc                   	int3   
  801614:	eb fd                	jmp    801613 <_panic+0x43>

00801616 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	53                   	push   %ebx
  80161a:	83 ec 04             	sub    $0x4,%esp
  80161d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801620:	8b 13                	mov    (%ebx),%edx
  801622:	8d 42 01             	lea    0x1(%edx),%eax
  801625:	89 03                	mov    %eax,(%ebx)
  801627:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80162a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80162e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801633:	75 1a                	jne    80164f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	68 ff 00 00 00       	push   $0xff
  80163d:	8d 43 08             	lea    0x8(%ebx),%eax
  801640:	50                   	push   %eax
  801641:	e8 84 ea ff ff       	call   8000ca <sys_cputs>
		b->idx = 0;
  801646:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80164c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80164f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801653:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801656:	c9                   	leave  
  801657:	c3                   	ret    

00801658 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801661:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801668:	00 00 00 
	b.cnt = 0;
  80166b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801672:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801675:	ff 75 0c             	pushl  0xc(%ebp)
  801678:	ff 75 08             	pushl  0x8(%ebp)
  80167b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	68 16 16 80 00       	push   $0x801616
  801687:	e8 54 01 00 00       	call   8017e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80168c:	83 c4 08             	add    $0x8,%esp
  80168f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801695:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	e8 29 ea ff ff       	call   8000ca <sys_cputs>

	return b.cnt;
}
  8016a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016b2:	50                   	push   %eax
  8016b3:	ff 75 08             	pushl  0x8(%ebp)
  8016b6:	e8 9d ff ff ff       	call   801658 <vcprintf>
	va_end(ap);

	return cnt;
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	57                   	push   %edi
  8016c1:	56                   	push   %esi
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 1c             	sub    $0x1c,%esp
  8016c6:	89 c7                	mov    %eax,%edi
  8016c8:	89 d6                	mov    %edx,%esi
  8016ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016e1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016e4:	39 d3                	cmp    %edx,%ebx
  8016e6:	72 05                	jb     8016ed <printnum+0x30>
  8016e8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016eb:	77 45                	ja     801732 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016ed:	83 ec 0c             	sub    $0xc,%esp
  8016f0:	ff 75 18             	pushl  0x18(%ebp)
  8016f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016f9:	53                   	push   %ebx
  8016fa:	ff 75 10             	pushl  0x10(%ebp)
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	ff 75 e4             	pushl  -0x1c(%ebp)
  801703:	ff 75 e0             	pushl  -0x20(%ebp)
  801706:	ff 75 dc             	pushl  -0x24(%ebp)
  801709:	ff 75 d8             	pushl  -0x28(%ebp)
  80170c:	e8 5f 0a 00 00       	call   802170 <__udivdi3>
  801711:	83 c4 18             	add    $0x18,%esp
  801714:	52                   	push   %edx
  801715:	50                   	push   %eax
  801716:	89 f2                	mov    %esi,%edx
  801718:	89 f8                	mov    %edi,%eax
  80171a:	e8 9e ff ff ff       	call   8016bd <printnum>
  80171f:	83 c4 20             	add    $0x20,%esp
  801722:	eb 18                	jmp    80173c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	56                   	push   %esi
  801728:	ff 75 18             	pushl  0x18(%ebp)
  80172b:	ff d7                	call   *%edi
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	eb 03                	jmp    801735 <printnum+0x78>
  801732:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801735:	83 eb 01             	sub    $0x1,%ebx
  801738:	85 db                	test   %ebx,%ebx
  80173a:	7f e8                	jg     801724 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80173c:	83 ec 08             	sub    $0x8,%esp
  80173f:	56                   	push   %esi
  801740:	83 ec 04             	sub    $0x4,%esp
  801743:	ff 75 e4             	pushl  -0x1c(%ebp)
  801746:	ff 75 e0             	pushl  -0x20(%ebp)
  801749:	ff 75 dc             	pushl  -0x24(%ebp)
  80174c:	ff 75 d8             	pushl  -0x28(%ebp)
  80174f:	e8 4c 0b 00 00       	call   8022a0 <__umoddi3>
  801754:	83 c4 14             	add    $0x14,%esp
  801757:	0f be 80 d3 25 80 00 	movsbl 0x8025d3(%eax),%eax
  80175e:	50                   	push   %eax
  80175f:	ff d7                	call   *%edi
}
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5f                   	pop    %edi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80176f:	83 fa 01             	cmp    $0x1,%edx
  801772:	7e 0e                	jle    801782 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801774:	8b 10                	mov    (%eax),%edx
  801776:	8d 4a 08             	lea    0x8(%edx),%ecx
  801779:	89 08                	mov    %ecx,(%eax)
  80177b:	8b 02                	mov    (%edx),%eax
  80177d:	8b 52 04             	mov    0x4(%edx),%edx
  801780:	eb 22                	jmp    8017a4 <getuint+0x38>
	else if (lflag)
  801782:	85 d2                	test   %edx,%edx
  801784:	74 10                	je     801796 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801786:	8b 10                	mov    (%eax),%edx
  801788:	8d 4a 04             	lea    0x4(%edx),%ecx
  80178b:	89 08                	mov    %ecx,(%eax)
  80178d:	8b 02                	mov    (%edx),%eax
  80178f:	ba 00 00 00 00       	mov    $0x0,%edx
  801794:	eb 0e                	jmp    8017a4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801796:	8b 10                	mov    (%eax),%edx
  801798:	8d 4a 04             	lea    0x4(%edx),%ecx
  80179b:	89 08                	mov    %ecx,(%eax)
  80179d:	8b 02                	mov    (%edx),%eax
  80179f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017ac:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017b0:	8b 10                	mov    (%eax),%edx
  8017b2:	3b 50 04             	cmp    0x4(%eax),%edx
  8017b5:	73 0a                	jae    8017c1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017ba:	89 08                	mov    %ecx,(%eax)
  8017bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bf:	88 02                	mov    %al,(%edx)
}
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017c9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017cc:	50                   	push   %eax
  8017cd:	ff 75 10             	pushl  0x10(%ebp)
  8017d0:	ff 75 0c             	pushl  0xc(%ebp)
  8017d3:	ff 75 08             	pushl  0x8(%ebp)
  8017d6:	e8 05 00 00 00       	call   8017e0 <vprintfmt>
	va_end(ap);
}
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	57                   	push   %edi
  8017e4:	56                   	push   %esi
  8017e5:	53                   	push   %ebx
  8017e6:	83 ec 2c             	sub    $0x2c,%esp
  8017e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8017ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017ef:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017f2:	eb 12                	jmp    801806 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	0f 84 89 03 00 00    	je     801b85 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	53                   	push   %ebx
  801800:	50                   	push   %eax
  801801:	ff d6                	call   *%esi
  801803:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801806:	83 c7 01             	add    $0x1,%edi
  801809:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80180d:	83 f8 25             	cmp    $0x25,%eax
  801810:	75 e2                	jne    8017f4 <vprintfmt+0x14>
  801812:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801816:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80181d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801824:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80182b:	ba 00 00 00 00       	mov    $0x0,%edx
  801830:	eb 07                	jmp    801839 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801832:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801835:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801839:	8d 47 01             	lea    0x1(%edi),%eax
  80183c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80183f:	0f b6 07             	movzbl (%edi),%eax
  801842:	0f b6 c8             	movzbl %al,%ecx
  801845:	83 e8 23             	sub    $0x23,%eax
  801848:	3c 55                	cmp    $0x55,%al
  80184a:	0f 87 1a 03 00 00    	ja     801b6a <vprintfmt+0x38a>
  801850:	0f b6 c0             	movzbl %al,%eax
  801853:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  80185a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80185d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801861:	eb d6                	jmp    801839 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801863:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801866:	b8 00 00 00 00       	mov    $0x0,%eax
  80186b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80186e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801871:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801875:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801878:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80187b:	83 fa 09             	cmp    $0x9,%edx
  80187e:	77 39                	ja     8018b9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801880:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801883:	eb e9                	jmp    80186e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801885:	8b 45 14             	mov    0x14(%ebp),%eax
  801888:	8d 48 04             	lea    0x4(%eax),%ecx
  80188b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80188e:	8b 00                	mov    (%eax),%eax
  801890:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801893:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801896:	eb 27                	jmp    8018bf <vprintfmt+0xdf>
  801898:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80189b:	85 c0                	test   %eax,%eax
  80189d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018a2:	0f 49 c8             	cmovns %eax,%ecx
  8018a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018ab:	eb 8c                	jmp    801839 <vprintfmt+0x59>
  8018ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018b0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018b7:	eb 80                	jmp    801839 <vprintfmt+0x59>
  8018b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018bc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018c3:	0f 89 70 ff ff ff    	jns    801839 <vprintfmt+0x59>
				width = precision, precision = -1;
  8018c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018d6:	e9 5e ff ff ff       	jmp    801839 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018db:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018e1:	e9 53 ff ff ff       	jmp    801839 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e9:	8d 50 04             	lea    0x4(%eax),%edx
  8018ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	53                   	push   %ebx
  8018f3:	ff 30                	pushl  (%eax)
  8018f5:	ff d6                	call   *%esi
			break;
  8018f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018fd:	e9 04 ff ff ff       	jmp    801806 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801902:	8b 45 14             	mov    0x14(%ebp),%eax
  801905:	8d 50 04             	lea    0x4(%eax),%edx
  801908:	89 55 14             	mov    %edx,0x14(%ebp)
  80190b:	8b 00                	mov    (%eax),%eax
  80190d:	99                   	cltd   
  80190e:	31 d0                	xor    %edx,%eax
  801910:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801912:	83 f8 0f             	cmp    $0xf,%eax
  801915:	7f 0b                	jg     801922 <vprintfmt+0x142>
  801917:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  80191e:	85 d2                	test   %edx,%edx
  801920:	75 18                	jne    80193a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801922:	50                   	push   %eax
  801923:	68 eb 25 80 00       	push   $0x8025eb
  801928:	53                   	push   %ebx
  801929:	56                   	push   %esi
  80192a:	e8 94 fe ff ff       	call   8017c3 <printfmt>
  80192f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801932:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801935:	e9 cc fe ff ff       	jmp    801806 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80193a:	52                   	push   %edx
  80193b:	68 69 25 80 00       	push   $0x802569
  801940:	53                   	push   %ebx
  801941:	56                   	push   %esi
  801942:	e8 7c fe ff ff       	call   8017c3 <printfmt>
  801947:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80194a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80194d:	e9 b4 fe ff ff       	jmp    801806 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801952:	8b 45 14             	mov    0x14(%ebp),%eax
  801955:	8d 50 04             	lea    0x4(%eax),%edx
  801958:	89 55 14             	mov    %edx,0x14(%ebp)
  80195b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80195d:	85 ff                	test   %edi,%edi
  80195f:	b8 e4 25 80 00       	mov    $0x8025e4,%eax
  801964:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801967:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80196b:	0f 8e 94 00 00 00    	jle    801a05 <vprintfmt+0x225>
  801971:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801975:	0f 84 98 00 00 00    	je     801a13 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	ff 75 d0             	pushl  -0x30(%ebp)
  801981:	57                   	push   %edi
  801982:	e8 86 02 00 00       	call   801c0d <strnlen>
  801987:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80198a:	29 c1                	sub    %eax,%ecx
  80198c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80198f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801992:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801996:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801999:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80199c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80199e:	eb 0f                	jmp    8019af <vprintfmt+0x1cf>
					putch(padc, putdat);
  8019a0:	83 ec 08             	sub    $0x8,%esp
  8019a3:	53                   	push   %ebx
  8019a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8019a7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a9:	83 ef 01             	sub    $0x1,%edi
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	85 ff                	test   %edi,%edi
  8019b1:	7f ed                	jg     8019a0 <vprintfmt+0x1c0>
  8019b3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019b6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019b9:	85 c9                	test   %ecx,%ecx
  8019bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c0:	0f 49 c1             	cmovns %ecx,%eax
  8019c3:	29 c1                	sub    %eax,%ecx
  8019c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8019c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019ce:	89 cb                	mov    %ecx,%ebx
  8019d0:	eb 4d                	jmp    801a1f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019d6:	74 1b                	je     8019f3 <vprintfmt+0x213>
  8019d8:	0f be c0             	movsbl %al,%eax
  8019db:	83 e8 20             	sub    $0x20,%eax
  8019de:	83 f8 5e             	cmp    $0x5e,%eax
  8019e1:	76 10                	jbe    8019f3 <vprintfmt+0x213>
					putch('?', putdat);
  8019e3:	83 ec 08             	sub    $0x8,%esp
  8019e6:	ff 75 0c             	pushl  0xc(%ebp)
  8019e9:	6a 3f                	push   $0x3f
  8019eb:	ff 55 08             	call   *0x8(%ebp)
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	eb 0d                	jmp    801a00 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019f3:	83 ec 08             	sub    $0x8,%esp
  8019f6:	ff 75 0c             	pushl  0xc(%ebp)
  8019f9:	52                   	push   %edx
  8019fa:	ff 55 08             	call   *0x8(%ebp)
  8019fd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a00:	83 eb 01             	sub    $0x1,%ebx
  801a03:	eb 1a                	jmp    801a1f <vprintfmt+0x23f>
  801a05:	89 75 08             	mov    %esi,0x8(%ebp)
  801a08:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a0b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a0e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a11:	eb 0c                	jmp    801a1f <vprintfmt+0x23f>
  801a13:	89 75 08             	mov    %esi,0x8(%ebp)
  801a16:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a19:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a1c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a1f:	83 c7 01             	add    $0x1,%edi
  801a22:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a26:	0f be d0             	movsbl %al,%edx
  801a29:	85 d2                	test   %edx,%edx
  801a2b:	74 23                	je     801a50 <vprintfmt+0x270>
  801a2d:	85 f6                	test   %esi,%esi
  801a2f:	78 a1                	js     8019d2 <vprintfmt+0x1f2>
  801a31:	83 ee 01             	sub    $0x1,%esi
  801a34:	79 9c                	jns    8019d2 <vprintfmt+0x1f2>
  801a36:	89 df                	mov    %ebx,%edi
  801a38:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a3e:	eb 18                	jmp    801a58 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	53                   	push   %ebx
  801a44:	6a 20                	push   $0x20
  801a46:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a48:	83 ef 01             	sub    $0x1,%edi
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	eb 08                	jmp    801a58 <vprintfmt+0x278>
  801a50:	89 df                	mov    %ebx,%edi
  801a52:	8b 75 08             	mov    0x8(%ebp),%esi
  801a55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a58:	85 ff                	test   %edi,%edi
  801a5a:	7f e4                	jg     801a40 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a5f:	e9 a2 fd ff ff       	jmp    801806 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a64:	83 fa 01             	cmp    $0x1,%edx
  801a67:	7e 16                	jle    801a7f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a69:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6c:	8d 50 08             	lea    0x8(%eax),%edx
  801a6f:	89 55 14             	mov    %edx,0x14(%ebp)
  801a72:	8b 50 04             	mov    0x4(%eax),%edx
  801a75:	8b 00                	mov    (%eax),%eax
  801a77:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a7a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a7d:	eb 32                	jmp    801ab1 <vprintfmt+0x2d1>
	else if (lflag)
  801a7f:	85 d2                	test   %edx,%edx
  801a81:	74 18                	je     801a9b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a83:	8b 45 14             	mov    0x14(%ebp),%eax
  801a86:	8d 50 04             	lea    0x4(%eax),%edx
  801a89:	89 55 14             	mov    %edx,0x14(%ebp)
  801a8c:	8b 00                	mov    (%eax),%eax
  801a8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a91:	89 c1                	mov    %eax,%ecx
  801a93:	c1 f9 1f             	sar    $0x1f,%ecx
  801a96:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a99:	eb 16                	jmp    801ab1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a9b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9e:	8d 50 04             	lea    0x4(%eax),%edx
  801aa1:	89 55 14             	mov    %edx,0x14(%ebp)
  801aa4:	8b 00                	mov    (%eax),%eax
  801aa6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aa9:	89 c1                	mov    %eax,%ecx
  801aab:	c1 f9 1f             	sar    $0x1f,%ecx
  801aae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ab1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ab4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801ab7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801abc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ac0:	79 74                	jns    801b36 <vprintfmt+0x356>
				putch('-', putdat);
  801ac2:	83 ec 08             	sub    $0x8,%esp
  801ac5:	53                   	push   %ebx
  801ac6:	6a 2d                	push   $0x2d
  801ac8:	ff d6                	call   *%esi
				num = -(long long) num;
  801aca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801acd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ad0:	f7 d8                	neg    %eax
  801ad2:	83 d2 00             	adc    $0x0,%edx
  801ad5:	f7 da                	neg    %edx
  801ad7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ada:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801adf:	eb 55                	jmp    801b36 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ae1:	8d 45 14             	lea    0x14(%ebp),%eax
  801ae4:	e8 83 fc ff ff       	call   80176c <getuint>
			base = 10;
  801ae9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801aee:	eb 46                	jmp    801b36 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801af0:	8d 45 14             	lea    0x14(%ebp),%eax
  801af3:	e8 74 fc ff ff       	call   80176c <getuint>
			base = 8;
  801af8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801afd:	eb 37                	jmp    801b36 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801aff:	83 ec 08             	sub    $0x8,%esp
  801b02:	53                   	push   %ebx
  801b03:	6a 30                	push   $0x30
  801b05:	ff d6                	call   *%esi
			putch('x', putdat);
  801b07:	83 c4 08             	add    $0x8,%esp
  801b0a:	53                   	push   %ebx
  801b0b:	6a 78                	push   $0x78
  801b0d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b0f:	8b 45 14             	mov    0x14(%ebp),%eax
  801b12:	8d 50 04             	lea    0x4(%eax),%edx
  801b15:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b18:	8b 00                	mov    (%eax),%eax
  801b1a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b1f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b22:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b27:	eb 0d                	jmp    801b36 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b29:	8d 45 14             	lea    0x14(%ebp),%eax
  801b2c:	e8 3b fc ff ff       	call   80176c <getuint>
			base = 16;
  801b31:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b36:	83 ec 0c             	sub    $0xc,%esp
  801b39:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b3d:	57                   	push   %edi
  801b3e:	ff 75 e0             	pushl  -0x20(%ebp)
  801b41:	51                   	push   %ecx
  801b42:	52                   	push   %edx
  801b43:	50                   	push   %eax
  801b44:	89 da                	mov    %ebx,%edx
  801b46:	89 f0                	mov    %esi,%eax
  801b48:	e8 70 fb ff ff       	call   8016bd <printnum>
			break;
  801b4d:	83 c4 20             	add    $0x20,%esp
  801b50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b53:	e9 ae fc ff ff       	jmp    801806 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b58:	83 ec 08             	sub    $0x8,%esp
  801b5b:	53                   	push   %ebx
  801b5c:	51                   	push   %ecx
  801b5d:	ff d6                	call   *%esi
			break;
  801b5f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b65:	e9 9c fc ff ff       	jmp    801806 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b6a:	83 ec 08             	sub    $0x8,%esp
  801b6d:	53                   	push   %ebx
  801b6e:	6a 25                	push   $0x25
  801b70:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	eb 03                	jmp    801b7a <vprintfmt+0x39a>
  801b77:	83 ef 01             	sub    $0x1,%edi
  801b7a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b7e:	75 f7                	jne    801b77 <vprintfmt+0x397>
  801b80:	e9 81 fc ff ff       	jmp    801806 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b88:	5b                   	pop    %ebx
  801b89:	5e                   	pop    %esi
  801b8a:	5f                   	pop    %edi
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    

00801b8d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	83 ec 18             	sub    $0x18,%esp
  801b93:	8b 45 08             	mov    0x8(%ebp),%eax
  801b96:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b99:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b9c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ba0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ba3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801baa:	85 c0                	test   %eax,%eax
  801bac:	74 26                	je     801bd4 <vsnprintf+0x47>
  801bae:	85 d2                	test   %edx,%edx
  801bb0:	7e 22                	jle    801bd4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801bb2:	ff 75 14             	pushl  0x14(%ebp)
  801bb5:	ff 75 10             	pushl  0x10(%ebp)
  801bb8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bbb:	50                   	push   %eax
  801bbc:	68 a6 17 80 00       	push   $0x8017a6
  801bc1:	e8 1a fc ff ff       	call   8017e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bc9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcf:	83 c4 10             	add    $0x10,%esp
  801bd2:	eb 05                	jmp    801bd9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bd4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801be1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801be4:	50                   	push   %eax
  801be5:	ff 75 10             	pushl  0x10(%ebp)
  801be8:	ff 75 0c             	pushl  0xc(%ebp)
  801beb:	ff 75 08             	pushl  0x8(%ebp)
  801bee:	e8 9a ff ff ff       	call   801b8d <vsnprintf>
	va_end(ap);

	return rc;
}
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    

00801bf5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801c00:	eb 03                	jmp    801c05 <strlen+0x10>
		n++;
  801c02:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c05:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c09:	75 f7                	jne    801c02 <strlen+0xd>
		n++;
	return n;
}
  801c0b:	5d                   	pop    %ebp
  801c0c:	c3                   	ret    

00801c0d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c13:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c16:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1b:	eb 03                	jmp    801c20 <strnlen+0x13>
		n++;
  801c1d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c20:	39 c2                	cmp    %eax,%edx
  801c22:	74 08                	je     801c2c <strnlen+0x1f>
  801c24:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c28:	75 f3                	jne    801c1d <strnlen+0x10>
  801c2a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	53                   	push   %ebx
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c38:	89 c2                	mov    %eax,%edx
  801c3a:	83 c2 01             	add    $0x1,%edx
  801c3d:	83 c1 01             	add    $0x1,%ecx
  801c40:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c44:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c47:	84 db                	test   %bl,%bl
  801c49:	75 ef                	jne    801c3a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c4b:	5b                   	pop    %ebx
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	53                   	push   %ebx
  801c52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c55:	53                   	push   %ebx
  801c56:	e8 9a ff ff ff       	call   801bf5 <strlen>
  801c5b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c5e:	ff 75 0c             	pushl  0xc(%ebp)
  801c61:	01 d8                	add    %ebx,%eax
  801c63:	50                   	push   %eax
  801c64:	e8 c5 ff ff ff       	call   801c2e <strcpy>
	return dst;
}
  801c69:	89 d8                	mov    %ebx,%eax
  801c6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6e:	c9                   	leave  
  801c6f:	c3                   	ret    

00801c70 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	56                   	push   %esi
  801c74:	53                   	push   %ebx
  801c75:	8b 75 08             	mov    0x8(%ebp),%esi
  801c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c7b:	89 f3                	mov    %esi,%ebx
  801c7d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c80:	89 f2                	mov    %esi,%edx
  801c82:	eb 0f                	jmp    801c93 <strncpy+0x23>
		*dst++ = *src;
  801c84:	83 c2 01             	add    $0x1,%edx
  801c87:	0f b6 01             	movzbl (%ecx),%eax
  801c8a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c8d:	80 39 01             	cmpb   $0x1,(%ecx)
  801c90:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c93:	39 da                	cmp    %ebx,%edx
  801c95:	75 ed                	jne    801c84 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c97:	89 f0                	mov    %esi,%eax
  801c99:	5b                   	pop    %ebx
  801c9a:	5e                   	pop    %esi
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	56                   	push   %esi
  801ca1:	53                   	push   %ebx
  801ca2:	8b 75 08             	mov    0x8(%ebp),%esi
  801ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca8:	8b 55 10             	mov    0x10(%ebp),%edx
  801cab:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801cad:	85 d2                	test   %edx,%edx
  801caf:	74 21                	je     801cd2 <strlcpy+0x35>
  801cb1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cb5:	89 f2                	mov    %esi,%edx
  801cb7:	eb 09                	jmp    801cc2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cb9:	83 c2 01             	add    $0x1,%edx
  801cbc:	83 c1 01             	add    $0x1,%ecx
  801cbf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cc2:	39 c2                	cmp    %eax,%edx
  801cc4:	74 09                	je     801ccf <strlcpy+0x32>
  801cc6:	0f b6 19             	movzbl (%ecx),%ebx
  801cc9:	84 db                	test   %bl,%bl
  801ccb:	75 ec                	jne    801cb9 <strlcpy+0x1c>
  801ccd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ccf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cd2:	29 f0                	sub    %esi,%eax
}
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    

00801cd8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cde:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ce1:	eb 06                	jmp    801ce9 <strcmp+0x11>
		p++, q++;
  801ce3:	83 c1 01             	add    $0x1,%ecx
  801ce6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ce9:	0f b6 01             	movzbl (%ecx),%eax
  801cec:	84 c0                	test   %al,%al
  801cee:	74 04                	je     801cf4 <strcmp+0x1c>
  801cf0:	3a 02                	cmp    (%edx),%al
  801cf2:	74 ef                	je     801ce3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cf4:	0f b6 c0             	movzbl %al,%eax
  801cf7:	0f b6 12             	movzbl (%edx),%edx
  801cfa:	29 d0                	sub    %edx,%eax
}
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	53                   	push   %ebx
  801d02:	8b 45 08             	mov    0x8(%ebp),%eax
  801d05:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d08:	89 c3                	mov    %eax,%ebx
  801d0a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d0d:	eb 06                	jmp    801d15 <strncmp+0x17>
		n--, p++, q++;
  801d0f:	83 c0 01             	add    $0x1,%eax
  801d12:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d15:	39 d8                	cmp    %ebx,%eax
  801d17:	74 15                	je     801d2e <strncmp+0x30>
  801d19:	0f b6 08             	movzbl (%eax),%ecx
  801d1c:	84 c9                	test   %cl,%cl
  801d1e:	74 04                	je     801d24 <strncmp+0x26>
  801d20:	3a 0a                	cmp    (%edx),%cl
  801d22:	74 eb                	je     801d0f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d24:	0f b6 00             	movzbl (%eax),%eax
  801d27:	0f b6 12             	movzbl (%edx),%edx
  801d2a:	29 d0                	sub    %edx,%eax
  801d2c:	eb 05                	jmp    801d33 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d2e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d33:	5b                   	pop    %ebx
  801d34:	5d                   	pop    %ebp
  801d35:	c3                   	ret    

00801d36 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d40:	eb 07                	jmp    801d49 <strchr+0x13>
		if (*s == c)
  801d42:	38 ca                	cmp    %cl,%dl
  801d44:	74 0f                	je     801d55 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d46:	83 c0 01             	add    $0x1,%eax
  801d49:	0f b6 10             	movzbl (%eax),%edx
  801d4c:	84 d2                	test   %dl,%dl
  801d4e:	75 f2                	jne    801d42 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d61:	eb 03                	jmp    801d66 <strfind+0xf>
  801d63:	83 c0 01             	add    $0x1,%eax
  801d66:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d69:	38 ca                	cmp    %cl,%dl
  801d6b:	74 04                	je     801d71 <strfind+0x1a>
  801d6d:	84 d2                	test   %dl,%dl
  801d6f:	75 f2                	jne    801d63 <strfind+0xc>
			break;
	return (char *) s;
}
  801d71:	5d                   	pop    %ebp
  801d72:	c3                   	ret    

00801d73 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	57                   	push   %edi
  801d77:	56                   	push   %esi
  801d78:	53                   	push   %ebx
  801d79:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d7f:	85 c9                	test   %ecx,%ecx
  801d81:	74 36                	je     801db9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d83:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d89:	75 28                	jne    801db3 <memset+0x40>
  801d8b:	f6 c1 03             	test   $0x3,%cl
  801d8e:	75 23                	jne    801db3 <memset+0x40>
		c &= 0xFF;
  801d90:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d94:	89 d3                	mov    %edx,%ebx
  801d96:	c1 e3 08             	shl    $0x8,%ebx
  801d99:	89 d6                	mov    %edx,%esi
  801d9b:	c1 e6 18             	shl    $0x18,%esi
  801d9e:	89 d0                	mov    %edx,%eax
  801da0:	c1 e0 10             	shl    $0x10,%eax
  801da3:	09 f0                	or     %esi,%eax
  801da5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801da7:	89 d8                	mov    %ebx,%eax
  801da9:	09 d0                	or     %edx,%eax
  801dab:	c1 e9 02             	shr    $0x2,%ecx
  801dae:	fc                   	cld    
  801daf:	f3 ab                	rep stos %eax,%es:(%edi)
  801db1:	eb 06                	jmp    801db9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801db3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db6:	fc                   	cld    
  801db7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801db9:	89 f8                	mov    %edi,%eax
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5f                   	pop    %edi
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	57                   	push   %edi
  801dc4:	56                   	push   %esi
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dce:	39 c6                	cmp    %eax,%esi
  801dd0:	73 35                	jae    801e07 <memmove+0x47>
  801dd2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dd5:	39 d0                	cmp    %edx,%eax
  801dd7:	73 2e                	jae    801e07 <memmove+0x47>
		s += n;
		d += n;
  801dd9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ddc:	89 d6                	mov    %edx,%esi
  801dde:	09 fe                	or     %edi,%esi
  801de0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801de6:	75 13                	jne    801dfb <memmove+0x3b>
  801de8:	f6 c1 03             	test   $0x3,%cl
  801deb:	75 0e                	jne    801dfb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801ded:	83 ef 04             	sub    $0x4,%edi
  801df0:	8d 72 fc             	lea    -0x4(%edx),%esi
  801df3:	c1 e9 02             	shr    $0x2,%ecx
  801df6:	fd                   	std    
  801df7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801df9:	eb 09                	jmp    801e04 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dfb:	83 ef 01             	sub    $0x1,%edi
  801dfe:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e01:	fd                   	std    
  801e02:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e04:	fc                   	cld    
  801e05:	eb 1d                	jmp    801e24 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e07:	89 f2                	mov    %esi,%edx
  801e09:	09 c2                	or     %eax,%edx
  801e0b:	f6 c2 03             	test   $0x3,%dl
  801e0e:	75 0f                	jne    801e1f <memmove+0x5f>
  801e10:	f6 c1 03             	test   $0x3,%cl
  801e13:	75 0a                	jne    801e1f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e15:	c1 e9 02             	shr    $0x2,%ecx
  801e18:	89 c7                	mov    %eax,%edi
  801e1a:	fc                   	cld    
  801e1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e1d:	eb 05                	jmp    801e24 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e1f:	89 c7                	mov    %eax,%edi
  801e21:	fc                   	cld    
  801e22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e24:	5e                   	pop    %esi
  801e25:	5f                   	pop    %edi
  801e26:	5d                   	pop    %ebp
  801e27:	c3                   	ret    

00801e28 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e2b:	ff 75 10             	pushl  0x10(%ebp)
  801e2e:	ff 75 0c             	pushl  0xc(%ebp)
  801e31:	ff 75 08             	pushl  0x8(%ebp)
  801e34:	e8 87 ff ff ff       	call   801dc0 <memmove>
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	56                   	push   %esi
  801e3f:	53                   	push   %ebx
  801e40:	8b 45 08             	mov    0x8(%ebp),%eax
  801e43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e46:	89 c6                	mov    %eax,%esi
  801e48:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e4b:	eb 1a                	jmp    801e67 <memcmp+0x2c>
		if (*s1 != *s2)
  801e4d:	0f b6 08             	movzbl (%eax),%ecx
  801e50:	0f b6 1a             	movzbl (%edx),%ebx
  801e53:	38 d9                	cmp    %bl,%cl
  801e55:	74 0a                	je     801e61 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e57:	0f b6 c1             	movzbl %cl,%eax
  801e5a:	0f b6 db             	movzbl %bl,%ebx
  801e5d:	29 d8                	sub    %ebx,%eax
  801e5f:	eb 0f                	jmp    801e70 <memcmp+0x35>
		s1++, s2++;
  801e61:	83 c0 01             	add    $0x1,%eax
  801e64:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e67:	39 f0                	cmp    %esi,%eax
  801e69:	75 e2                	jne    801e4d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e70:	5b                   	pop    %ebx
  801e71:	5e                   	pop    %esi
  801e72:	5d                   	pop    %ebp
  801e73:	c3                   	ret    

00801e74 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	53                   	push   %ebx
  801e78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e7b:	89 c1                	mov    %eax,%ecx
  801e7d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e80:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e84:	eb 0a                	jmp    801e90 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e86:	0f b6 10             	movzbl (%eax),%edx
  801e89:	39 da                	cmp    %ebx,%edx
  801e8b:	74 07                	je     801e94 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e8d:	83 c0 01             	add    $0x1,%eax
  801e90:	39 c8                	cmp    %ecx,%eax
  801e92:	72 f2                	jb     801e86 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e94:	5b                   	pop    %ebx
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    

00801e97 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	57                   	push   %edi
  801e9b:	56                   	push   %esi
  801e9c:	53                   	push   %ebx
  801e9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ea3:	eb 03                	jmp    801ea8 <strtol+0x11>
		s++;
  801ea5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ea8:	0f b6 01             	movzbl (%ecx),%eax
  801eab:	3c 20                	cmp    $0x20,%al
  801ead:	74 f6                	je     801ea5 <strtol+0xe>
  801eaf:	3c 09                	cmp    $0x9,%al
  801eb1:	74 f2                	je     801ea5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801eb3:	3c 2b                	cmp    $0x2b,%al
  801eb5:	75 0a                	jne    801ec1 <strtol+0x2a>
		s++;
  801eb7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801eba:	bf 00 00 00 00       	mov    $0x0,%edi
  801ebf:	eb 11                	jmp    801ed2 <strtol+0x3b>
  801ec1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ec6:	3c 2d                	cmp    $0x2d,%al
  801ec8:	75 08                	jne    801ed2 <strtol+0x3b>
		s++, neg = 1;
  801eca:	83 c1 01             	add    $0x1,%ecx
  801ecd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ed2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ed8:	75 15                	jne    801eef <strtol+0x58>
  801eda:	80 39 30             	cmpb   $0x30,(%ecx)
  801edd:	75 10                	jne    801eef <strtol+0x58>
  801edf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ee3:	75 7c                	jne    801f61 <strtol+0xca>
		s += 2, base = 16;
  801ee5:	83 c1 02             	add    $0x2,%ecx
  801ee8:	bb 10 00 00 00       	mov    $0x10,%ebx
  801eed:	eb 16                	jmp    801f05 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801eef:	85 db                	test   %ebx,%ebx
  801ef1:	75 12                	jne    801f05 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ef3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ef8:	80 39 30             	cmpb   $0x30,(%ecx)
  801efb:	75 08                	jne    801f05 <strtol+0x6e>
		s++, base = 8;
  801efd:	83 c1 01             	add    $0x1,%ecx
  801f00:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f05:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f0d:	0f b6 11             	movzbl (%ecx),%edx
  801f10:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f13:	89 f3                	mov    %esi,%ebx
  801f15:	80 fb 09             	cmp    $0x9,%bl
  801f18:	77 08                	ja     801f22 <strtol+0x8b>
			dig = *s - '0';
  801f1a:	0f be d2             	movsbl %dl,%edx
  801f1d:	83 ea 30             	sub    $0x30,%edx
  801f20:	eb 22                	jmp    801f44 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f22:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f25:	89 f3                	mov    %esi,%ebx
  801f27:	80 fb 19             	cmp    $0x19,%bl
  801f2a:	77 08                	ja     801f34 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f2c:	0f be d2             	movsbl %dl,%edx
  801f2f:	83 ea 57             	sub    $0x57,%edx
  801f32:	eb 10                	jmp    801f44 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f34:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f37:	89 f3                	mov    %esi,%ebx
  801f39:	80 fb 19             	cmp    $0x19,%bl
  801f3c:	77 16                	ja     801f54 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f3e:	0f be d2             	movsbl %dl,%edx
  801f41:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f44:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f47:	7d 0b                	jge    801f54 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f49:	83 c1 01             	add    $0x1,%ecx
  801f4c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f50:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f52:	eb b9                	jmp    801f0d <strtol+0x76>

	if (endptr)
  801f54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f58:	74 0d                	je     801f67 <strtol+0xd0>
		*endptr = (char *) s;
  801f5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f5d:	89 0e                	mov    %ecx,(%esi)
  801f5f:	eb 06                	jmp    801f67 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f61:	85 db                	test   %ebx,%ebx
  801f63:	74 98                	je     801efd <strtol+0x66>
  801f65:	eb 9e                	jmp    801f05 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f67:	89 c2                	mov    %eax,%edx
  801f69:	f7 da                	neg    %edx
  801f6b:	85 ff                	test   %edi,%edi
  801f6d:	0f 45 c2             	cmovne %edx,%eax
}
  801f70:	5b                   	pop    %ebx
  801f71:	5e                   	pop    %esi
  801f72:	5f                   	pop    %edi
  801f73:	5d                   	pop    %ebp
  801f74:	c3                   	ret    

00801f75 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f7b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f82:	75 2a                	jne    801fae <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f84:	83 ec 04             	sub    $0x4,%esp
  801f87:	6a 07                	push   $0x7
  801f89:	68 00 f0 bf ee       	push   $0xeebff000
  801f8e:	6a 00                	push   $0x0
  801f90:	e8 f1 e1 ff ff       	call   800186 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	85 c0                	test   %eax,%eax
  801f9a:	79 12                	jns    801fae <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f9c:	50                   	push   %eax
  801f9d:	68 bd 24 80 00       	push   $0x8024bd
  801fa2:	6a 23                	push   $0x23
  801fa4:	68 e0 28 80 00       	push   $0x8028e0
  801fa9:	e8 22 f6 ff ff       	call   8015d0 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fae:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb1:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fb6:	83 ec 08             	sub    $0x8,%esp
  801fb9:	68 e0 1f 80 00       	push   $0x801fe0
  801fbe:	6a 00                	push   $0x0
  801fc0:	e8 0c e3 ff ff       	call   8002d1 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fc5:	83 c4 10             	add    $0x10,%esp
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	79 12                	jns    801fde <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fcc:	50                   	push   %eax
  801fcd:	68 bd 24 80 00       	push   $0x8024bd
  801fd2:	6a 2c                	push   $0x2c
  801fd4:	68 e0 28 80 00       	push   $0x8028e0
  801fd9:	e8 f2 f5 ff ff       	call   8015d0 <_panic>
	}
}
  801fde:	c9                   	leave  
  801fdf:	c3                   	ret    

00801fe0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fe0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fe1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fe6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fe8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801feb:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fef:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801ff4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801ff8:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ffa:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ffd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ffe:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802001:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802002:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802003:	c3                   	ret    

00802004 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	56                   	push   %esi
  802008:	53                   	push   %ebx
  802009:	8b 75 08             	mov    0x8(%ebp),%esi
  80200c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802012:	85 c0                	test   %eax,%eax
  802014:	75 12                	jne    802028 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802016:	83 ec 0c             	sub    $0xc,%esp
  802019:	68 00 00 c0 ee       	push   $0xeec00000
  80201e:	e8 13 e3 ff ff       	call   800336 <sys_ipc_recv>
  802023:	83 c4 10             	add    $0x10,%esp
  802026:	eb 0c                	jmp    802034 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802028:	83 ec 0c             	sub    $0xc,%esp
  80202b:	50                   	push   %eax
  80202c:	e8 05 e3 ff ff       	call   800336 <sys_ipc_recv>
  802031:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802034:	85 f6                	test   %esi,%esi
  802036:	0f 95 c1             	setne  %cl
  802039:	85 db                	test   %ebx,%ebx
  80203b:	0f 95 c2             	setne  %dl
  80203e:	84 d1                	test   %dl,%cl
  802040:	74 09                	je     80204b <ipc_recv+0x47>
  802042:	89 c2                	mov    %eax,%edx
  802044:	c1 ea 1f             	shr    $0x1f,%edx
  802047:	84 d2                	test   %dl,%dl
  802049:	75 2d                	jne    802078 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80204b:	85 f6                	test   %esi,%esi
  80204d:	74 0d                	je     80205c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80204f:	a1 04 40 80 00       	mov    0x804004,%eax
  802054:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80205a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80205c:	85 db                	test   %ebx,%ebx
  80205e:	74 0d                	je     80206d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802060:	a1 04 40 80 00       	mov    0x804004,%eax
  802065:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80206b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80206d:	a1 04 40 80 00       	mov    0x804004,%eax
  802072:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80207b:	5b                   	pop    %ebx
  80207c:	5e                   	pop    %esi
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    

0080207f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80207f:	55                   	push   %ebp
  802080:	89 e5                	mov    %esp,%ebp
  802082:	57                   	push   %edi
  802083:	56                   	push   %esi
  802084:	53                   	push   %ebx
  802085:	83 ec 0c             	sub    $0xc,%esp
  802088:	8b 7d 08             	mov    0x8(%ebp),%edi
  80208b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80208e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802091:	85 db                	test   %ebx,%ebx
  802093:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802098:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80209b:	ff 75 14             	pushl  0x14(%ebp)
  80209e:	53                   	push   %ebx
  80209f:	56                   	push   %esi
  8020a0:	57                   	push   %edi
  8020a1:	e8 6d e2 ff ff       	call   800313 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020a6:	89 c2                	mov    %eax,%edx
  8020a8:	c1 ea 1f             	shr    $0x1f,%edx
  8020ab:	83 c4 10             	add    $0x10,%esp
  8020ae:	84 d2                	test   %dl,%dl
  8020b0:	74 17                	je     8020c9 <ipc_send+0x4a>
  8020b2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020b5:	74 12                	je     8020c9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020b7:	50                   	push   %eax
  8020b8:	68 ee 28 80 00       	push   $0x8028ee
  8020bd:	6a 47                	push   $0x47
  8020bf:	68 fc 28 80 00       	push   $0x8028fc
  8020c4:	e8 07 f5 ff ff       	call   8015d0 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020c9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020cc:	75 07                	jne    8020d5 <ipc_send+0x56>
			sys_yield();
  8020ce:	e8 94 e0 ff ff       	call   800167 <sys_yield>
  8020d3:	eb c6                	jmp    80209b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	75 c2                	jne    80209b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020dc:	5b                   	pop    %ebx
  8020dd:	5e                   	pop    %esi
  8020de:	5f                   	pop    %edi
  8020df:	5d                   	pop    %ebp
  8020e0:	c3                   	ret    

008020e1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020e1:	55                   	push   %ebp
  8020e2:	89 e5                	mov    %esp,%ebp
  8020e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020e7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020ec:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020f2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020f8:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8020fe:	39 ca                	cmp    %ecx,%edx
  802100:	75 13                	jne    802115 <ipc_find_env+0x34>
			return envs[i].env_id;
  802102:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802108:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80210d:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802113:	eb 0f                	jmp    802124 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802115:	83 c0 01             	add    $0x1,%eax
  802118:	3d 00 04 00 00       	cmp    $0x400,%eax
  80211d:	75 cd                	jne    8020ec <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802124:	5d                   	pop    %ebp
  802125:	c3                   	ret    

00802126 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212c:	89 d0                	mov    %edx,%eax
  80212e:	c1 e8 16             	shr    $0x16,%eax
  802131:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802138:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213d:	f6 c1 01             	test   $0x1,%cl
  802140:	74 1d                	je     80215f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802142:	c1 ea 0c             	shr    $0xc,%edx
  802145:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80214c:	f6 c2 01             	test   $0x1,%dl
  80214f:	74 0e                	je     80215f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802151:	c1 ea 0c             	shr    $0xc,%edx
  802154:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80215b:	ef 
  80215c:	0f b7 c0             	movzwl %ax,%eax
}
  80215f:	5d                   	pop    %ebp
  802160:	c3                   	ret    
  802161:	66 90                	xchg   %ax,%ax
  802163:	66 90                	xchg   %ax,%ax
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
