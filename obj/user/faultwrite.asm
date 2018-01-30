
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 f1 00 00 00       	call   800143 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	56                   	push   %esi
  800076:	53                   	push   %ebx
  800077:	e8 b7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007c:	e8 2a 00 00 00       	call   8000ab <exit>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800087:	5b                   	pop    %ebx
  800088:	5e                   	pop    %esi
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    

0080008b <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  80008b:	55                   	push   %ebp
  80008c:	89 e5                	mov    %esp,%ebp
  80008e:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800091:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800096:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800098:	e8 a6 00 00 00       	call   800143 <sys_getenvid>
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	50                   	push   %eax
  8000a1:	e8 ec 02 00 00       	call   800392 <sys_thread_free>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	c9                   	leave  
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 e4 09 00 00       	call   800a9a <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 0a 24 80 00       	push   $0x80240a
  80012f:	6a 23                	push   $0x23
  800131:	68 27 24 80 00       	push   $0x802427
  800136:	e8 90 14 00 00       	call   8015cb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 0a 24 80 00       	push   $0x80240a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 27 24 80 00       	push   $0x802427
  8001b7:	e8 0f 14 00 00       	call   8015cb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 0a 24 80 00       	push   $0x80240a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 27 24 80 00       	push   $0x802427
  8001f9:	e8 cd 13 00 00       	call   8015cb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 0a 24 80 00       	push   $0x80240a
  800234:	6a 23                	push   $0x23
  800236:	68 27 24 80 00       	push   $0x802427
  80023b:	e8 8b 13 00 00       	call   8015cb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 0a 24 80 00       	push   $0x80240a
  800276:	6a 23                	push   $0x23
  800278:	68 27 24 80 00       	push   $0x802427
  80027d:	e8 49 13 00 00       	call   8015cb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 0a 24 80 00       	push   $0x80240a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 27 24 80 00       	push   $0x802427
  8002bf:	e8 07 13 00 00       	call   8015cb <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 0a 24 80 00       	push   $0x80240a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 27 24 80 00       	push   $0x802427
  800301:	e8 c5 12 00 00       	call   8015cb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 0a 24 80 00       	push   $0x80240a
  80035e:	6a 23                	push   $0x23
  800360:	68 27 24 80 00       	push   $0x802427
  800365:	e8 61 12 00 00       	call   8015cb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800378:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800382:	8b 55 08             	mov    0x8(%ebp),%edx
  800385:	89 cb                	mov    %ecx,%ebx
  800387:	89 cf                	mov    %ecx,%edi
  800389:	89 ce                	mov    %ecx,%esi
  80038b:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  80038d:	5b                   	pop    %ebx
  80038e:	5e                   	pop    %esi
  80038f:	5f                   	pop    %edi
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    

00800392 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	57                   	push   %edi
  800396:	56                   	push   %esi
  800397:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800398:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039d:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a5:	89 cb                	mov    %ecx,%ebx
  8003a7:	89 cf                	mov    %ecx,%edi
  8003a9:	89 ce                	mov    %ecx,%esi
  8003ab:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003ad:	5b                   	pop    %ebx
  8003ae:	5e                   	pop    %esi
  8003af:	5f                   	pop    %edi
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bd:	b8 10 00 00 00       	mov    $0x10,%eax
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	89 cb                	mov    %ecx,%ebx
  8003c7:	89 cf                	mov    %ecx,%edi
  8003c9:	89 ce                	mov    %ecx,%esi
  8003cb:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 04             	sub    $0x4,%esp
  8003d9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003dc:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003de:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003e2:	74 11                	je     8003f5 <pgfault+0x23>
  8003e4:	89 d8                	mov    %ebx,%eax
  8003e6:	c1 e8 0c             	shr    $0xc,%eax
  8003e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003f0:	f6 c4 08             	test   $0x8,%ah
  8003f3:	75 14                	jne    800409 <pgfault+0x37>
		panic("faulting access");
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	68 35 24 80 00       	push   $0x802435
  8003fd:	6a 1f                	push   $0x1f
  8003ff:	68 45 24 80 00       	push   $0x802445
  800404:	e8 c2 11 00 00       	call   8015cb <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800409:	83 ec 04             	sub    $0x4,%esp
  80040c:	6a 07                	push   $0x7
  80040e:	68 00 f0 7f 00       	push   $0x7ff000
  800413:	6a 00                	push   $0x0
  800415:	e8 67 fd ff ff       	call   800181 <sys_page_alloc>
	if (r < 0) {
  80041a:	83 c4 10             	add    $0x10,%esp
  80041d:	85 c0                	test   %eax,%eax
  80041f:	79 12                	jns    800433 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800421:	50                   	push   %eax
  800422:	68 50 24 80 00       	push   $0x802450
  800427:	6a 2d                	push   $0x2d
  800429:	68 45 24 80 00       	push   $0x802445
  80042e:	e8 98 11 00 00       	call   8015cb <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800433:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800439:	83 ec 04             	sub    $0x4,%esp
  80043c:	68 00 10 00 00       	push   $0x1000
  800441:	53                   	push   %ebx
  800442:	68 00 f0 7f 00       	push   $0x7ff000
  800447:	e8 d7 19 00 00       	call   801e23 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80044c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800453:	53                   	push   %ebx
  800454:	6a 00                	push   $0x0
  800456:	68 00 f0 7f 00       	push   $0x7ff000
  80045b:	6a 00                	push   $0x0
  80045d:	e8 62 fd ff ff       	call   8001c4 <sys_page_map>
	if (r < 0) {
  800462:	83 c4 20             	add    $0x20,%esp
  800465:	85 c0                	test   %eax,%eax
  800467:	79 12                	jns    80047b <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800469:	50                   	push   %eax
  80046a:	68 50 24 80 00       	push   $0x802450
  80046f:	6a 34                	push   $0x34
  800471:	68 45 24 80 00       	push   $0x802445
  800476:	e8 50 11 00 00       	call   8015cb <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	68 00 f0 7f 00       	push   $0x7ff000
  800483:	6a 00                	push   $0x0
  800485:	e8 7c fd ff ff       	call   800206 <sys_page_unmap>
	if (r < 0) {
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	85 c0                	test   %eax,%eax
  80048f:	79 12                	jns    8004a3 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800491:	50                   	push   %eax
  800492:	68 50 24 80 00       	push   $0x802450
  800497:	6a 38                	push   $0x38
  800499:	68 45 24 80 00       	push   $0x802445
  80049e:	e8 28 11 00 00       	call   8015cb <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	57                   	push   %edi
  8004ac:	56                   	push   %esi
  8004ad:	53                   	push   %ebx
  8004ae:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004b1:	68 d2 03 80 00       	push   $0x8003d2
  8004b6:	e8 b5 1a 00 00       	call   801f70 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004bb:	b8 07 00 00 00       	mov    $0x7,%eax
  8004c0:	cd 30                	int    $0x30
  8004c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 17                	jns    8004e3 <fork+0x3b>
		panic("fork fault %e");
  8004cc:	83 ec 04             	sub    $0x4,%esp
  8004cf:	68 69 24 80 00       	push   $0x802469
  8004d4:	68 85 00 00 00       	push   $0x85
  8004d9:	68 45 24 80 00       	push   $0x802445
  8004de:	e8 e8 10 00 00       	call   8015cb <_panic>
  8004e3:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e9:	75 24                	jne    80050f <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004eb:	e8 53 fc ff ff       	call   800143 <sys_getenvid>
  8004f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004f5:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8004fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800500:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800505:	b8 00 00 00 00       	mov    $0x0,%eax
  80050a:	e9 64 01 00 00       	jmp    800673 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80050f:	83 ec 04             	sub    $0x4,%esp
  800512:	6a 07                	push   $0x7
  800514:	68 00 f0 bf ee       	push   $0xeebff000
  800519:	ff 75 e4             	pushl  -0x1c(%ebp)
  80051c:	e8 60 fc ff ff       	call   800181 <sys_page_alloc>
  800521:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800524:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800529:	89 d8                	mov    %ebx,%eax
  80052b:	c1 e8 16             	shr    $0x16,%eax
  80052e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800535:	a8 01                	test   $0x1,%al
  800537:	0f 84 fc 00 00 00    	je     800639 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80053d:	89 d8                	mov    %ebx,%eax
  80053f:	c1 e8 0c             	shr    $0xc,%eax
  800542:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800549:	f6 c2 01             	test   $0x1,%dl
  80054c:	0f 84 e7 00 00 00    	je     800639 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800552:	89 c6                	mov    %eax,%esi
  800554:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800557:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80055e:	f6 c6 04             	test   $0x4,%dh
  800561:	74 39                	je     80059c <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800563:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	25 07 0e 00 00       	and    $0xe07,%eax
  800572:	50                   	push   %eax
  800573:	56                   	push   %esi
  800574:	57                   	push   %edi
  800575:	56                   	push   %esi
  800576:	6a 00                	push   $0x0
  800578:	e8 47 fc ff ff       	call   8001c4 <sys_page_map>
		if (r < 0) {
  80057d:	83 c4 20             	add    $0x20,%esp
  800580:	85 c0                	test   %eax,%eax
  800582:	0f 89 b1 00 00 00    	jns    800639 <fork+0x191>
		    	panic("sys page map fault %e");
  800588:	83 ec 04             	sub    $0x4,%esp
  80058b:	68 77 24 80 00       	push   $0x802477
  800590:	6a 55                	push   $0x55
  800592:	68 45 24 80 00       	push   $0x802445
  800597:	e8 2f 10 00 00       	call   8015cb <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80059c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a3:	f6 c2 02             	test   $0x2,%dl
  8005a6:	75 0c                	jne    8005b4 <fork+0x10c>
  8005a8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005af:	f6 c4 08             	test   $0x8,%ah
  8005b2:	74 5b                	je     80060f <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005b4:	83 ec 0c             	sub    $0xc,%esp
  8005b7:	68 05 08 00 00       	push   $0x805
  8005bc:	56                   	push   %esi
  8005bd:	57                   	push   %edi
  8005be:	56                   	push   %esi
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 fe fb ff ff       	call   8001c4 <sys_page_map>
		if (r < 0) {
  8005c6:	83 c4 20             	add    $0x20,%esp
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	79 14                	jns    8005e1 <fork+0x139>
		    	panic("sys page map fault %e");
  8005cd:	83 ec 04             	sub    $0x4,%esp
  8005d0:	68 77 24 80 00       	push   $0x802477
  8005d5:	6a 5c                	push   $0x5c
  8005d7:	68 45 24 80 00       	push   $0x802445
  8005dc:	e8 ea 0f 00 00       	call   8015cb <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005e1:	83 ec 0c             	sub    $0xc,%esp
  8005e4:	68 05 08 00 00       	push   $0x805
  8005e9:	56                   	push   %esi
  8005ea:	6a 00                	push   $0x0
  8005ec:	56                   	push   %esi
  8005ed:	6a 00                	push   $0x0
  8005ef:	e8 d0 fb ff ff       	call   8001c4 <sys_page_map>
		if (r < 0) {
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	79 3e                	jns    800639 <fork+0x191>
		    	panic("sys page map fault %e");
  8005fb:	83 ec 04             	sub    $0x4,%esp
  8005fe:	68 77 24 80 00       	push   $0x802477
  800603:	6a 60                	push   $0x60
  800605:	68 45 24 80 00       	push   $0x802445
  80060a:	e8 bc 0f 00 00       	call   8015cb <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80060f:	83 ec 0c             	sub    $0xc,%esp
  800612:	6a 05                	push   $0x5
  800614:	56                   	push   %esi
  800615:	57                   	push   %edi
  800616:	56                   	push   %esi
  800617:	6a 00                	push   $0x0
  800619:	e8 a6 fb ff ff       	call   8001c4 <sys_page_map>
		if (r < 0) {
  80061e:	83 c4 20             	add    $0x20,%esp
  800621:	85 c0                	test   %eax,%eax
  800623:	79 14                	jns    800639 <fork+0x191>
		    	panic("sys page map fault %e");
  800625:	83 ec 04             	sub    $0x4,%esp
  800628:	68 77 24 80 00       	push   $0x802477
  80062d:	6a 65                	push   $0x65
  80062f:	68 45 24 80 00       	push   $0x802445
  800634:	e8 92 0f 00 00       	call   8015cb <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800639:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80063f:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800645:	0f 85 de fe ff ff    	jne    800529 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80064b:	a1 04 40 80 00       	mov    0x804004,%eax
  800650:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	50                   	push   %eax
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065d:	57                   	push   %edi
  80065e:	e8 69 fc ff ff       	call   8002cc <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	6a 02                	push   $0x2
  800668:	57                   	push   %edi
  800669:	e8 da fb ff ff       	call   800248 <sys_env_set_status>
	
	return envid;
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800676:	5b                   	pop    %ebx
  800677:	5e                   	pop    %esi
  800678:	5f                   	pop    %edi
  800679:	5d                   	pop    %ebp
  80067a:	c3                   	ret    

0080067b <sfork>:

envid_t
sfork(void)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80067e:	b8 00 00 00 00       	mov    $0x0,%eax
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    

00800685 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  80068b:	8b 45 08             	mov    0x8(%ebp),%eax
  80068e:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800693:	68 8b 00 80 00       	push   $0x80008b
  800698:	e8 d5 fc ff ff       	call   800372 <sys_thread_create>

	return id;
}
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8006a5:	ff 75 08             	pushl  0x8(%ebp)
  8006a8:	e8 e5 fc ff ff       	call   800392 <sys_thread_free>
}
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    

008006b2 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8006b8:	ff 75 08             	pushl  0x8(%ebp)
  8006bb:	e8 f2 fc ff ff       	call   8003b2 <sys_thread_join>
}
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    

008006c5 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006d0:	83 ec 04             	sub    $0x4,%esp
  8006d3:	6a 07                	push   $0x7
  8006d5:	6a 00                	push   $0x0
  8006d7:	56                   	push   %esi
  8006d8:	e8 a4 fa ff ff       	call   800181 <sys_page_alloc>
	if (r < 0) {
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	79 15                	jns    8006f9 <queue_append+0x34>
		panic("%e\n", r);
  8006e4:	50                   	push   %eax
  8006e5:	68 bd 24 80 00       	push   $0x8024bd
  8006ea:	68 d5 00 00 00       	push   $0xd5
  8006ef:	68 45 24 80 00       	push   $0x802445
  8006f4:	e8 d2 0e 00 00       	call   8015cb <_panic>
	}	

	wt->envid = envid;
  8006f9:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8006ff:	83 3b 00             	cmpl   $0x0,(%ebx)
  800702:	75 13                	jne    800717 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  800704:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80070b:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800712:	00 00 00 
  800715:	eb 1b                	jmp    800732 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  800717:	8b 43 04             	mov    0x4(%ebx),%eax
  80071a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800721:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800728:	00 00 00 
		queue->last = wt;
  80072b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  800732:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800735:	5b                   	pop    %ebx
  800736:	5e                   	pop    %esi
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  800742:	8b 02                	mov    (%edx),%eax
  800744:	85 c0                	test   %eax,%eax
  800746:	75 17                	jne    80075f <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  800748:	83 ec 04             	sub    $0x4,%esp
  80074b:	68 8d 24 80 00       	push   $0x80248d
  800750:	68 ec 00 00 00       	push   $0xec
  800755:	68 45 24 80 00       	push   $0x802445
  80075a:	e8 6c 0e 00 00       	call   8015cb <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80075f:	8b 48 04             	mov    0x4(%eax),%ecx
  800762:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  800764:	8b 00                	mov    (%eax),%eax
}
  800766:	c9                   	leave  
  800767:	c3                   	ret    

00800768 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	53                   	push   %ebx
  80076c:	83 ec 04             	sub    $0x4,%esp
  80076f:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800772:	b8 01 00 00 00       	mov    $0x1,%eax
  800777:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  80077a:	85 c0                	test   %eax,%eax
  80077c:	74 45                	je     8007c3 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  80077e:	e8 c0 f9 ff ff       	call   800143 <sys_getenvid>
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	83 c3 04             	add    $0x4,%ebx
  800789:	53                   	push   %ebx
  80078a:	50                   	push   %eax
  80078b:	e8 35 ff ff ff       	call   8006c5 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800790:	e8 ae f9 ff ff       	call   800143 <sys_getenvid>
  800795:	83 c4 08             	add    $0x8,%esp
  800798:	6a 04                	push   $0x4
  80079a:	50                   	push   %eax
  80079b:	e8 a8 fa ff ff       	call   800248 <sys_env_set_status>

		if (r < 0) {
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	79 15                	jns    8007bc <mutex_lock+0x54>
			panic("%e\n", r);
  8007a7:	50                   	push   %eax
  8007a8:	68 bd 24 80 00       	push   $0x8024bd
  8007ad:	68 02 01 00 00       	push   $0x102
  8007b2:	68 45 24 80 00       	push   $0x802445
  8007b7:	e8 0f 0e 00 00       	call   8015cb <_panic>
		}
		sys_yield();
  8007bc:	e8 a1 f9 ff ff       	call   800162 <sys_yield>
  8007c1:	eb 08                	jmp    8007cb <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8007c3:	e8 7b f9 ff ff       	call   800143 <sys_getenvid>
  8007c8:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8007cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	83 ec 04             	sub    $0x4,%esp
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8007da:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8007de:	74 36                	je     800816 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8007e0:	83 ec 0c             	sub    $0xc,%esp
  8007e3:	8d 43 04             	lea    0x4(%ebx),%eax
  8007e6:	50                   	push   %eax
  8007e7:	e8 4d ff ff ff       	call   800739 <queue_pop>
  8007ec:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8007ef:	83 c4 08             	add    $0x8,%esp
  8007f2:	6a 02                	push   $0x2
  8007f4:	50                   	push   %eax
  8007f5:	e8 4e fa ff ff       	call   800248 <sys_env_set_status>
		if (r < 0) {
  8007fa:	83 c4 10             	add    $0x10,%esp
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	79 1d                	jns    80081e <mutex_unlock+0x4e>
			panic("%e\n", r);
  800801:	50                   	push   %eax
  800802:	68 bd 24 80 00       	push   $0x8024bd
  800807:	68 16 01 00 00       	push   $0x116
  80080c:	68 45 24 80 00       	push   $0x802445
  800811:	e8 b5 0d 00 00       	call   8015cb <_panic>
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
  80081b:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  80081e:	e8 3f f9 ff ff       	call   800162 <sys_yield>
}
  800823:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800826:	c9                   	leave  
  800827:	c3                   	ret    

00800828 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	53                   	push   %ebx
  80082c:	83 ec 04             	sub    $0x4,%esp
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800832:	e8 0c f9 ff ff       	call   800143 <sys_getenvid>
  800837:	83 ec 04             	sub    $0x4,%esp
  80083a:	6a 07                	push   $0x7
  80083c:	53                   	push   %ebx
  80083d:	50                   	push   %eax
  80083e:	e8 3e f9 ff ff       	call   800181 <sys_page_alloc>
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	85 c0                	test   %eax,%eax
  800848:	79 15                	jns    80085f <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80084a:	50                   	push   %eax
  80084b:	68 a8 24 80 00       	push   $0x8024a8
  800850:	68 23 01 00 00       	push   $0x123
  800855:	68 45 24 80 00       	push   $0x802445
  80085a:	e8 6c 0d 00 00       	call   8015cb <_panic>
	}	
	mtx->locked = 0;
  80085f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  800865:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  80086c:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  800873:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  80087a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    

0080087f <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  800887:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  80088a:	eb 20                	jmp    8008ac <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80088c:	83 ec 0c             	sub    $0xc,%esp
  80088f:	56                   	push   %esi
  800890:	e8 a4 fe ff ff       	call   800739 <queue_pop>
  800895:	83 c4 08             	add    $0x8,%esp
  800898:	6a 02                	push   $0x2
  80089a:	50                   	push   %eax
  80089b:	e8 a8 f9 ff ff       	call   800248 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8008a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8008a3:	8b 40 04             	mov    0x4(%eax),%eax
  8008a6:	89 43 04             	mov    %eax,0x4(%ebx)
  8008a9:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8008ac:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8008b0:	75 da                	jne    80088c <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008b2:	83 ec 04             	sub    $0x4,%esp
  8008b5:	68 00 10 00 00       	push   $0x1000
  8008ba:	6a 00                	push   $0x0
  8008bc:	53                   	push   %ebx
  8008bd:	e8 ac 14 00 00       	call   801d6e <memset>
	mtx = NULL;
}
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8008d7:	c1 e8 0c             	shr    $0xc,%eax
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	05 00 00 00 30       	add    $0x30000000,%eax
  8008e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008ec:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8008fe:	89 c2                	mov    %eax,%edx
  800900:	c1 ea 16             	shr    $0x16,%edx
  800903:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80090a:	f6 c2 01             	test   $0x1,%dl
  80090d:	74 11                	je     800920 <fd_alloc+0x2d>
  80090f:	89 c2                	mov    %eax,%edx
  800911:	c1 ea 0c             	shr    $0xc,%edx
  800914:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80091b:	f6 c2 01             	test   $0x1,%dl
  80091e:	75 09                	jne    800929 <fd_alloc+0x36>
			*fd_store = fd;
  800920:	89 01                	mov    %eax,(%ecx)
			return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	eb 17                	jmp    800940 <fd_alloc+0x4d>
  800929:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80092e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800933:	75 c9                	jne    8008fe <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800935:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80093b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800948:	83 f8 1f             	cmp    $0x1f,%eax
  80094b:	77 36                	ja     800983 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80094d:	c1 e0 0c             	shl    $0xc,%eax
  800950:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800955:	89 c2                	mov    %eax,%edx
  800957:	c1 ea 16             	shr    $0x16,%edx
  80095a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800961:	f6 c2 01             	test   $0x1,%dl
  800964:	74 24                	je     80098a <fd_lookup+0x48>
  800966:	89 c2                	mov    %eax,%edx
  800968:	c1 ea 0c             	shr    $0xc,%edx
  80096b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800972:	f6 c2 01             	test   $0x1,%dl
  800975:	74 1a                	je     800991 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800977:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097a:	89 02                	mov    %eax,(%edx)
	return 0;
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
  800981:	eb 13                	jmp    800996 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800983:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800988:	eb 0c                	jmp    800996 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80098a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80098f:	eb 05                	jmp    800996 <fd_lookup+0x54>
  800991:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a1:	ba 40 25 80 00       	mov    $0x802540,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009a6:	eb 13                	jmp    8009bb <dev_lookup+0x23>
  8009a8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009ab:	39 08                	cmp    %ecx,(%eax)
  8009ad:	75 0c                	jne    8009bb <dev_lookup+0x23>
			*dev = devtab[i];
  8009af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b9:	eb 31                	jmp    8009ec <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009bb:	8b 02                	mov    (%edx),%eax
  8009bd:	85 c0                	test   %eax,%eax
  8009bf:	75 e7                	jne    8009a8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009cc:	83 ec 04             	sub    $0x4,%esp
  8009cf:	51                   	push   %ecx
  8009d0:	50                   	push   %eax
  8009d1:	68 c4 24 80 00       	push   $0x8024c4
  8009d6:	e8 c9 0c 00 00       	call   8016a4 <cprintf>
	*dev = 0;
  8009db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009de:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009e4:	83 c4 10             	add    $0x10,%esp
  8009e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	83 ec 10             	sub    $0x10,%esp
  8009f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8009fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ff:	50                   	push   %eax
  800a00:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a06:	c1 e8 0c             	shr    $0xc,%eax
  800a09:	50                   	push   %eax
  800a0a:	e8 33 ff ff ff       	call   800942 <fd_lookup>
  800a0f:	83 c4 08             	add    $0x8,%esp
  800a12:	85 c0                	test   %eax,%eax
  800a14:	78 05                	js     800a1b <fd_close+0x2d>
	    || fd != fd2)
  800a16:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a19:	74 0c                	je     800a27 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a1b:	84 db                	test   %bl,%bl
  800a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a22:	0f 44 c2             	cmove  %edx,%eax
  800a25:	eb 41                	jmp    800a68 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a27:	83 ec 08             	sub    $0x8,%esp
  800a2a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a2d:	50                   	push   %eax
  800a2e:	ff 36                	pushl  (%esi)
  800a30:	e8 63 ff ff ff       	call   800998 <dev_lookup>
  800a35:	89 c3                	mov    %eax,%ebx
  800a37:	83 c4 10             	add    $0x10,%esp
  800a3a:	85 c0                	test   %eax,%eax
  800a3c:	78 1a                	js     800a58 <fd_close+0x6a>
		if (dev->dev_close)
  800a3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a41:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a44:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	74 0b                	je     800a58 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a4d:	83 ec 0c             	sub    $0xc,%esp
  800a50:	56                   	push   %esi
  800a51:	ff d0                	call   *%eax
  800a53:	89 c3                	mov    %eax,%ebx
  800a55:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	56                   	push   %esi
  800a5c:	6a 00                	push   $0x0
  800a5e:	e8 a3 f7 ff ff       	call   800206 <sys_page_unmap>
	return r;
  800a63:	83 c4 10             	add    $0x10,%esp
  800a66:	89 d8                	mov    %ebx,%eax
}
  800a68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a78:	50                   	push   %eax
  800a79:	ff 75 08             	pushl  0x8(%ebp)
  800a7c:	e8 c1 fe ff ff       	call   800942 <fd_lookup>
  800a81:	83 c4 08             	add    $0x8,%esp
  800a84:	85 c0                	test   %eax,%eax
  800a86:	78 10                	js     800a98 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a88:	83 ec 08             	sub    $0x8,%esp
  800a8b:	6a 01                	push   $0x1
  800a8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800a90:	e8 59 ff ff ff       	call   8009ee <fd_close>
  800a95:	83 c4 10             	add    $0x10,%esp
}
  800a98:	c9                   	leave  
  800a99:	c3                   	ret    

00800a9a <close_all>:

void
close_all(void)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800aa1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800aa6:	83 ec 0c             	sub    $0xc,%esp
  800aa9:	53                   	push   %ebx
  800aaa:	e8 c0 ff ff ff       	call   800a6f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800aaf:	83 c3 01             	add    $0x1,%ebx
  800ab2:	83 c4 10             	add    $0x10,%esp
  800ab5:	83 fb 20             	cmp    $0x20,%ebx
  800ab8:	75 ec                	jne    800aa6 <close_all+0xc>
		close(i);
}
  800aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	83 ec 2c             	sub    $0x2c,%esp
  800ac8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800acb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ace:	50                   	push   %eax
  800acf:	ff 75 08             	pushl  0x8(%ebp)
  800ad2:	e8 6b fe ff ff       	call   800942 <fd_lookup>
  800ad7:	83 c4 08             	add    $0x8,%esp
  800ada:	85 c0                	test   %eax,%eax
  800adc:	0f 88 c1 00 00 00    	js     800ba3 <dup+0xe4>
		return r;
	close(newfdnum);
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	56                   	push   %esi
  800ae6:	e8 84 ff ff ff       	call   800a6f <close>

	newfd = INDEX2FD(newfdnum);
  800aeb:	89 f3                	mov    %esi,%ebx
  800aed:	c1 e3 0c             	shl    $0xc,%ebx
  800af0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800af6:	83 c4 04             	add    $0x4,%esp
  800af9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800afc:	e8 db fd ff ff       	call   8008dc <fd2data>
  800b01:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b03:	89 1c 24             	mov    %ebx,(%esp)
  800b06:	e8 d1 fd ff ff       	call   8008dc <fd2data>
  800b0b:	83 c4 10             	add    $0x10,%esp
  800b0e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b11:	89 f8                	mov    %edi,%eax
  800b13:	c1 e8 16             	shr    $0x16,%eax
  800b16:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b1d:	a8 01                	test   $0x1,%al
  800b1f:	74 37                	je     800b58 <dup+0x99>
  800b21:	89 f8                	mov    %edi,%eax
  800b23:	c1 e8 0c             	shr    $0xc,%eax
  800b26:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b2d:	f6 c2 01             	test   $0x1,%dl
  800b30:	74 26                	je     800b58 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b32:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	25 07 0e 00 00       	and    $0xe07,%eax
  800b41:	50                   	push   %eax
  800b42:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b45:	6a 00                	push   $0x0
  800b47:	57                   	push   %edi
  800b48:	6a 00                	push   $0x0
  800b4a:	e8 75 f6 ff ff       	call   8001c4 <sys_page_map>
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	83 c4 20             	add    $0x20,%esp
  800b54:	85 c0                	test   %eax,%eax
  800b56:	78 2e                	js     800b86 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b58:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b5b:	89 d0                	mov    %edx,%eax
  800b5d:	c1 e8 0c             	shr    $0xc,%eax
  800b60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b67:	83 ec 0c             	sub    $0xc,%esp
  800b6a:	25 07 0e 00 00       	and    $0xe07,%eax
  800b6f:	50                   	push   %eax
  800b70:	53                   	push   %ebx
  800b71:	6a 00                	push   $0x0
  800b73:	52                   	push   %edx
  800b74:	6a 00                	push   $0x0
  800b76:	e8 49 f6 ff ff       	call   8001c4 <sys_page_map>
  800b7b:	89 c7                	mov    %eax,%edi
  800b7d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b80:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b82:	85 ff                	test   %edi,%edi
  800b84:	79 1d                	jns    800ba3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b86:	83 ec 08             	sub    $0x8,%esp
  800b89:	53                   	push   %ebx
  800b8a:	6a 00                	push   $0x0
  800b8c:	e8 75 f6 ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b91:	83 c4 08             	add    $0x8,%esp
  800b94:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b97:	6a 00                	push   $0x0
  800b99:	e8 68 f6 ff ff       	call   800206 <sys_page_unmap>
	return r;
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	89 f8                	mov    %edi,%eax
}
  800ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	83 ec 14             	sub    $0x14,%esp
  800bb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bb5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bb8:	50                   	push   %eax
  800bb9:	53                   	push   %ebx
  800bba:	e8 83 fd ff ff       	call   800942 <fd_lookup>
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	89 c2                	mov    %eax,%edx
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	78 70                	js     800c38 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bc8:	83 ec 08             	sub    $0x8,%esp
  800bcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bce:	50                   	push   %eax
  800bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd2:	ff 30                	pushl  (%eax)
  800bd4:	e8 bf fd ff ff       	call   800998 <dev_lookup>
  800bd9:	83 c4 10             	add    $0x10,%esp
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	78 4f                	js     800c2f <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800be0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800be3:	8b 42 08             	mov    0x8(%edx),%eax
  800be6:	83 e0 03             	and    $0x3,%eax
  800be9:	83 f8 01             	cmp    $0x1,%eax
  800bec:	75 24                	jne    800c12 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bee:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800bf9:	83 ec 04             	sub    $0x4,%esp
  800bfc:	53                   	push   %ebx
  800bfd:	50                   	push   %eax
  800bfe:	68 05 25 80 00       	push   $0x802505
  800c03:	e8 9c 0a 00 00       	call   8016a4 <cprintf>
		return -E_INVAL;
  800c08:	83 c4 10             	add    $0x10,%esp
  800c0b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c10:	eb 26                	jmp    800c38 <read+0x8d>
	}
	if (!dev->dev_read)
  800c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c15:	8b 40 08             	mov    0x8(%eax),%eax
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	74 17                	je     800c33 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c1c:	83 ec 04             	sub    $0x4,%esp
  800c1f:	ff 75 10             	pushl  0x10(%ebp)
  800c22:	ff 75 0c             	pushl  0xc(%ebp)
  800c25:	52                   	push   %edx
  800c26:	ff d0                	call   *%eax
  800c28:	89 c2                	mov    %eax,%edx
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	eb 09                	jmp    800c38 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	eb 05                	jmp    800c38 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c33:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c38:	89 d0                	mov    %edx,%eax
  800c3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c4b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	eb 21                	jmp    800c76 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c55:	83 ec 04             	sub    $0x4,%esp
  800c58:	89 f0                	mov    %esi,%eax
  800c5a:	29 d8                	sub    %ebx,%eax
  800c5c:	50                   	push   %eax
  800c5d:	89 d8                	mov    %ebx,%eax
  800c5f:	03 45 0c             	add    0xc(%ebp),%eax
  800c62:	50                   	push   %eax
  800c63:	57                   	push   %edi
  800c64:	e8 42 ff ff ff       	call   800bab <read>
		if (m < 0)
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	78 10                	js     800c80 <readn+0x41>
			return m;
		if (m == 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	74 0a                	je     800c7e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c74:	01 c3                	add    %eax,%ebx
  800c76:	39 f3                	cmp    %esi,%ebx
  800c78:	72 db                	jb     800c55 <readn+0x16>
  800c7a:	89 d8                	mov    %ebx,%eax
  800c7c:	eb 02                	jmp    800c80 <readn+0x41>
  800c7e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 14             	sub    $0x14,%esp
  800c8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c95:	50                   	push   %eax
  800c96:	53                   	push   %ebx
  800c97:	e8 a6 fc ff ff       	call   800942 <fd_lookup>
  800c9c:	83 c4 08             	add    $0x8,%esp
  800c9f:	89 c2                	mov    %eax,%edx
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	78 6b                	js     800d10 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ca5:	83 ec 08             	sub    $0x8,%esp
  800ca8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cab:	50                   	push   %eax
  800cac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800caf:	ff 30                	pushl  (%eax)
  800cb1:	e8 e2 fc ff ff       	call   800998 <dev_lookup>
  800cb6:	83 c4 10             	add    $0x10,%esp
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	78 4a                	js     800d07 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cc4:	75 24                	jne    800cea <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800cc6:	a1 04 40 80 00       	mov    0x804004,%eax
  800ccb:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800cd1:	83 ec 04             	sub    $0x4,%esp
  800cd4:	53                   	push   %ebx
  800cd5:	50                   	push   %eax
  800cd6:	68 21 25 80 00       	push   $0x802521
  800cdb:	e8 c4 09 00 00       	call   8016a4 <cprintf>
		return -E_INVAL;
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ce8:	eb 26                	jmp    800d10 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800cea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ced:	8b 52 0c             	mov    0xc(%edx),%edx
  800cf0:	85 d2                	test   %edx,%edx
  800cf2:	74 17                	je     800d0b <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800cf4:	83 ec 04             	sub    $0x4,%esp
  800cf7:	ff 75 10             	pushl  0x10(%ebp)
  800cfa:	ff 75 0c             	pushl  0xc(%ebp)
  800cfd:	50                   	push   %eax
  800cfe:	ff d2                	call   *%edx
  800d00:	89 c2                	mov    %eax,%edx
  800d02:	83 c4 10             	add    $0x10,%esp
  800d05:	eb 09                	jmp    800d10 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d07:	89 c2                	mov    %eax,%edx
  800d09:	eb 05                	jmp    800d10 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d0b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d10:	89 d0                	mov    %edx,%eax
  800d12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d15:	c9                   	leave  
  800d16:	c3                   	ret    

00800d17 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d1d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d20:	50                   	push   %eax
  800d21:	ff 75 08             	pushl  0x8(%ebp)
  800d24:	e8 19 fc ff ff       	call   800942 <fd_lookup>
  800d29:	83 c4 08             	add    $0x8,%esp
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	78 0e                	js     800d3e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d30:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d36:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	53                   	push   %ebx
  800d44:	83 ec 14             	sub    $0x14,%esp
  800d47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d4d:	50                   	push   %eax
  800d4e:	53                   	push   %ebx
  800d4f:	e8 ee fb ff ff       	call   800942 <fd_lookup>
  800d54:	83 c4 08             	add    $0x8,%esp
  800d57:	89 c2                	mov    %eax,%edx
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	78 68                	js     800dc5 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d5d:	83 ec 08             	sub    $0x8,%esp
  800d60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d63:	50                   	push   %eax
  800d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d67:	ff 30                	pushl  (%eax)
  800d69:	e8 2a fc ff ff       	call   800998 <dev_lookup>
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	85 c0                	test   %eax,%eax
  800d73:	78 47                	js     800dbc <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d78:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d7c:	75 24                	jne    800da2 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d7e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d83:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d89:	83 ec 04             	sub    $0x4,%esp
  800d8c:	53                   	push   %ebx
  800d8d:	50                   	push   %eax
  800d8e:	68 e4 24 80 00       	push   $0x8024e4
  800d93:	e8 0c 09 00 00       	call   8016a4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800da0:	eb 23                	jmp    800dc5 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800da5:	8b 52 18             	mov    0x18(%edx),%edx
  800da8:	85 d2                	test   %edx,%edx
  800daa:	74 14                	je     800dc0 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800dac:	83 ec 08             	sub    $0x8,%esp
  800daf:	ff 75 0c             	pushl  0xc(%ebp)
  800db2:	50                   	push   %eax
  800db3:	ff d2                	call   *%edx
  800db5:	89 c2                	mov    %eax,%edx
  800db7:	83 c4 10             	add    $0x10,%esp
  800dba:	eb 09                	jmp    800dc5 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dbc:	89 c2                	mov    %eax,%edx
  800dbe:	eb 05                	jmp    800dc5 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dc0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dc5:	89 d0                	mov    %edx,%eax
  800dc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dca:	c9                   	leave  
  800dcb:	c3                   	ret    

00800dcc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 14             	sub    $0x14,%esp
  800dd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dd6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd9:	50                   	push   %eax
  800dda:	ff 75 08             	pushl  0x8(%ebp)
  800ddd:	e8 60 fb ff ff       	call   800942 <fd_lookup>
  800de2:	83 c4 08             	add    $0x8,%esp
  800de5:	89 c2                	mov    %eax,%edx
  800de7:	85 c0                	test   %eax,%eax
  800de9:	78 58                	js     800e43 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800deb:	83 ec 08             	sub    $0x8,%esp
  800dee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800df1:	50                   	push   %eax
  800df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df5:	ff 30                	pushl  (%eax)
  800df7:	e8 9c fb ff ff       	call   800998 <dev_lookup>
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	78 37                	js     800e3a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e06:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e0a:	74 32                	je     800e3e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e0c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e0f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e16:	00 00 00 
	stat->st_isdir = 0;
  800e19:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e20:	00 00 00 
	stat->st_dev = dev;
  800e23:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e29:	83 ec 08             	sub    $0x8,%esp
  800e2c:	53                   	push   %ebx
  800e2d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e30:	ff 50 14             	call   *0x14(%eax)
  800e33:	89 c2                	mov    %eax,%edx
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	eb 09                	jmp    800e43 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e3a:	89 c2                	mov    %eax,%edx
  800e3c:	eb 05                	jmp    800e43 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e3e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e43:	89 d0                	mov    %edx,%eax
  800e45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	6a 00                	push   $0x0
  800e54:	ff 75 08             	pushl  0x8(%ebp)
  800e57:	e8 e3 01 00 00       	call   80103f <open>
  800e5c:	89 c3                	mov    %eax,%ebx
  800e5e:	83 c4 10             	add    $0x10,%esp
  800e61:	85 c0                	test   %eax,%eax
  800e63:	78 1b                	js     800e80 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	ff 75 0c             	pushl  0xc(%ebp)
  800e6b:	50                   	push   %eax
  800e6c:	e8 5b ff ff ff       	call   800dcc <fstat>
  800e71:	89 c6                	mov    %eax,%esi
	close(fd);
  800e73:	89 1c 24             	mov    %ebx,(%esp)
  800e76:	e8 f4 fb ff ff       	call   800a6f <close>
	return r;
  800e7b:	83 c4 10             	add    $0x10,%esp
  800e7e:	89 f0                	mov    %esi,%eax
}
  800e80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	89 c6                	mov    %eax,%esi
  800e8e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e90:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e97:	75 12                	jne    800eab <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e99:	83 ec 0c             	sub    $0xc,%esp
  800e9c:	6a 01                	push   $0x1
  800e9e:	e8 39 12 00 00       	call   8020dc <ipc_find_env>
  800ea3:	a3 00 40 80 00       	mov    %eax,0x804000
  800ea8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800eab:	6a 07                	push   $0x7
  800ead:	68 00 50 80 00       	push   $0x805000
  800eb2:	56                   	push   %esi
  800eb3:	ff 35 00 40 80 00    	pushl  0x804000
  800eb9:	e8 bc 11 00 00       	call   80207a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ebe:	83 c4 0c             	add    $0xc,%esp
  800ec1:	6a 00                	push   $0x0
  800ec3:	53                   	push   %ebx
  800ec4:	6a 00                	push   $0x0
  800ec6:	e8 34 11 00 00       	call   801fff <ipc_recv>
}
  800ecb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ece:	5b                   	pop    %ebx
  800ecf:	5e                   	pop    %esi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  800edb:	8b 40 0c             	mov    0xc(%eax),%eax
  800ede:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800eeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ef5:	e8 8d ff ff ff       	call   800e87 <fsipc>
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f02:	8b 45 08             	mov    0x8(%ebp),%eax
  800f05:	8b 40 0c             	mov    0xc(%eax),%eax
  800f08:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f12:	b8 06 00 00 00       	mov    $0x6,%eax
  800f17:	e8 6b ff ff ff       	call   800e87 <fsipc>
}
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	53                   	push   %ebx
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f28:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2b:	8b 40 0c             	mov    0xc(%eax),%eax
  800f2e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f33:	ba 00 00 00 00       	mov    $0x0,%edx
  800f38:	b8 05 00 00 00       	mov    $0x5,%eax
  800f3d:	e8 45 ff ff ff       	call   800e87 <fsipc>
  800f42:	85 c0                	test   %eax,%eax
  800f44:	78 2c                	js     800f72 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f46:	83 ec 08             	sub    $0x8,%esp
  800f49:	68 00 50 80 00       	push   $0x805000
  800f4e:	53                   	push   %ebx
  800f4f:	e8 d5 0c 00 00       	call   801c29 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f54:	a1 80 50 80 00       	mov    0x805080,%eax
  800f59:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f5f:	a1 84 50 80 00       	mov    0x805084,%eax
  800f64:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	8b 52 0c             	mov    0xc(%edx),%edx
  800f86:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f8c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f91:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800f96:	0f 47 c2             	cmova  %edx,%eax
  800f99:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800f9e:	50                   	push   %eax
  800f9f:	ff 75 0c             	pushl  0xc(%ebp)
  800fa2:	68 08 50 80 00       	push   $0x805008
  800fa7:	e8 0f 0e 00 00       	call   801dbb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fac:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb6:	e8 cc fe ff ff       	call   800e87 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	56                   	push   %esi
  800fc1:	53                   	push   %ebx
  800fc2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc8:	8b 40 0c             	mov    0xc(%eax),%eax
  800fcb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fd0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdb:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe0:	e8 a2 fe ff ff       	call   800e87 <fsipc>
  800fe5:	89 c3                	mov    %eax,%ebx
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 4b                	js     801036 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800feb:	39 c6                	cmp    %eax,%esi
  800fed:	73 16                	jae    801005 <devfile_read+0x48>
  800fef:	68 50 25 80 00       	push   $0x802550
  800ff4:	68 57 25 80 00       	push   $0x802557
  800ff9:	6a 7c                	push   $0x7c
  800ffb:	68 6c 25 80 00       	push   $0x80256c
  801000:	e8 c6 05 00 00       	call   8015cb <_panic>
	assert(r <= PGSIZE);
  801005:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80100a:	7e 16                	jle    801022 <devfile_read+0x65>
  80100c:	68 77 25 80 00       	push   $0x802577
  801011:	68 57 25 80 00       	push   $0x802557
  801016:	6a 7d                	push   $0x7d
  801018:	68 6c 25 80 00       	push   $0x80256c
  80101d:	e8 a9 05 00 00       	call   8015cb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	50                   	push   %eax
  801026:	68 00 50 80 00       	push   $0x805000
  80102b:	ff 75 0c             	pushl  0xc(%ebp)
  80102e:	e8 88 0d 00 00       	call   801dbb <memmove>
	return r;
  801033:	83 c4 10             	add    $0x10,%esp
}
  801036:	89 d8                	mov    %ebx,%eax
  801038:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103b:	5b                   	pop    %ebx
  80103c:	5e                   	pop    %esi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    

0080103f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	53                   	push   %ebx
  801043:	83 ec 20             	sub    $0x20,%esp
  801046:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801049:	53                   	push   %ebx
  80104a:	e8 a1 0b 00 00       	call   801bf0 <strlen>
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801057:	7f 67                	jg     8010c0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105f:	50                   	push   %eax
  801060:	e8 8e f8 ff ff       	call   8008f3 <fd_alloc>
  801065:	83 c4 10             	add    $0x10,%esp
		return r;
  801068:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 57                	js     8010c5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80106e:	83 ec 08             	sub    $0x8,%esp
  801071:	53                   	push   %ebx
  801072:	68 00 50 80 00       	push   $0x805000
  801077:	e8 ad 0b 00 00       	call   801c29 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80107c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801084:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801087:	b8 01 00 00 00       	mov    $0x1,%eax
  80108c:	e8 f6 fd ff ff       	call   800e87 <fsipc>
  801091:	89 c3                	mov    %eax,%ebx
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	79 14                	jns    8010ae <open+0x6f>
		fd_close(fd, 0);
  80109a:	83 ec 08             	sub    $0x8,%esp
  80109d:	6a 00                	push   $0x0
  80109f:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a2:	e8 47 f9 ff ff       	call   8009ee <fd_close>
		return r;
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	89 da                	mov    %ebx,%edx
  8010ac:	eb 17                	jmp    8010c5 <open+0x86>
	}

	return fd2num(fd);
  8010ae:	83 ec 0c             	sub    $0xc,%esp
  8010b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b4:	e8 13 f8 ff ff       	call   8008cc <fd2num>
  8010b9:	89 c2                	mov    %eax,%edx
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	eb 05                	jmp    8010c5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010c0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010c5:	89 d0                	mov    %edx,%eax
  8010c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d7:	b8 08 00 00 00       	mov    $0x8,%eax
  8010dc:	e8 a6 fd ff ff       	call   800e87 <fsipc>
}
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	ff 75 08             	pushl  0x8(%ebp)
  8010f1:	e8 e6 f7 ff ff       	call   8008dc <fd2data>
  8010f6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010f8:	83 c4 08             	add    $0x8,%esp
  8010fb:	68 83 25 80 00       	push   $0x802583
  801100:	53                   	push   %ebx
  801101:	e8 23 0b 00 00       	call   801c29 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801106:	8b 46 04             	mov    0x4(%esi),%eax
  801109:	2b 06                	sub    (%esi),%eax
  80110b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801111:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801118:	00 00 00 
	stat->st_dev = &devpipe;
  80111b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801122:	30 80 00 
	return 0;
}
  801125:	b8 00 00 00 00       	mov    $0x0,%eax
  80112a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	53                   	push   %ebx
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80113b:	53                   	push   %ebx
  80113c:	6a 00                	push   $0x0
  80113e:	e8 c3 f0 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801143:	89 1c 24             	mov    %ebx,(%esp)
  801146:	e8 91 f7 ff ff       	call   8008dc <fd2data>
  80114b:	83 c4 08             	add    $0x8,%esp
  80114e:	50                   	push   %eax
  80114f:	6a 00                	push   $0x0
  801151:	e8 b0 f0 ff ff       	call   800206 <sys_page_unmap>
}
  801156:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801159:	c9                   	leave  
  80115a:	c3                   	ret    

0080115b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	57                   	push   %edi
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	83 ec 1c             	sub    $0x1c,%esp
  801164:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801167:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801169:	a1 04 40 80 00       	mov    0x804004,%eax
  80116e:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801174:	83 ec 0c             	sub    $0xc,%esp
  801177:	ff 75 e0             	pushl  -0x20(%ebp)
  80117a:	e8 a2 0f 00 00       	call   802121 <pageref>
  80117f:	89 c3                	mov    %eax,%ebx
  801181:	89 3c 24             	mov    %edi,(%esp)
  801184:	e8 98 0f 00 00       	call   802121 <pageref>
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	39 c3                	cmp    %eax,%ebx
  80118e:	0f 94 c1             	sete   %cl
  801191:	0f b6 c9             	movzbl %cl,%ecx
  801194:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801197:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80119d:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011a3:	39 ce                	cmp    %ecx,%esi
  8011a5:	74 1e                	je     8011c5 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011a7:	39 c3                	cmp    %eax,%ebx
  8011a9:	75 be                	jne    801169 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011ab:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b4:	50                   	push   %eax
  8011b5:	56                   	push   %esi
  8011b6:	68 8a 25 80 00       	push   $0x80258a
  8011bb:	e8 e4 04 00 00       	call   8016a4 <cprintf>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	eb a4                	jmp    801169 <_pipeisclosed+0xe>
	}
}
  8011c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5f                   	pop    %edi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	57                   	push   %edi
  8011d4:	56                   	push   %esi
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 28             	sub    $0x28,%esp
  8011d9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011dc:	56                   	push   %esi
  8011dd:	e8 fa f6 ff ff       	call   8008dc <fd2data>
  8011e2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8011ec:	eb 4b                	jmp    801239 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011ee:	89 da                	mov    %ebx,%edx
  8011f0:	89 f0                	mov    %esi,%eax
  8011f2:	e8 64 ff ff ff       	call   80115b <_pipeisclosed>
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	75 48                	jne    801243 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011fb:	e8 62 ef ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801200:	8b 43 04             	mov    0x4(%ebx),%eax
  801203:	8b 0b                	mov    (%ebx),%ecx
  801205:	8d 51 20             	lea    0x20(%ecx),%edx
  801208:	39 d0                	cmp    %edx,%eax
  80120a:	73 e2                	jae    8011ee <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80120c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801213:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801216:	89 c2                	mov    %eax,%edx
  801218:	c1 fa 1f             	sar    $0x1f,%edx
  80121b:	89 d1                	mov    %edx,%ecx
  80121d:	c1 e9 1b             	shr    $0x1b,%ecx
  801220:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801223:	83 e2 1f             	and    $0x1f,%edx
  801226:	29 ca                	sub    %ecx,%edx
  801228:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80122c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801230:	83 c0 01             	add    $0x1,%eax
  801233:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801236:	83 c7 01             	add    $0x1,%edi
  801239:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80123c:	75 c2                	jne    801200 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80123e:	8b 45 10             	mov    0x10(%ebp),%eax
  801241:	eb 05                	jmp    801248 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801243:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	83 ec 18             	sub    $0x18,%esp
  801259:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80125c:	57                   	push   %edi
  80125d:	e8 7a f6 ff ff       	call   8008dc <fd2data>
  801262:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126c:	eb 3d                	jmp    8012ab <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80126e:	85 db                	test   %ebx,%ebx
  801270:	74 04                	je     801276 <devpipe_read+0x26>
				return i;
  801272:	89 d8                	mov    %ebx,%eax
  801274:	eb 44                	jmp    8012ba <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801276:	89 f2                	mov    %esi,%edx
  801278:	89 f8                	mov    %edi,%eax
  80127a:	e8 dc fe ff ff       	call   80115b <_pipeisclosed>
  80127f:	85 c0                	test   %eax,%eax
  801281:	75 32                	jne    8012b5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801283:	e8 da ee ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801288:	8b 06                	mov    (%esi),%eax
  80128a:	3b 46 04             	cmp    0x4(%esi),%eax
  80128d:	74 df                	je     80126e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80128f:	99                   	cltd   
  801290:	c1 ea 1b             	shr    $0x1b,%edx
  801293:	01 d0                	add    %edx,%eax
  801295:	83 e0 1f             	and    $0x1f,%eax
  801298:	29 d0                	sub    %edx,%eax
  80129a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80129f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012a5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012a8:	83 c3 01             	add    $0x1,%ebx
  8012ab:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012ae:	75 d8                	jne    801288 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012b3:	eb 05                	jmp    8012ba <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012b5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	56                   	push   %esi
  8012c6:	53                   	push   %ebx
  8012c7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	e8 20 f6 ff ff       	call   8008f3 <fd_alloc>
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	0f 88 2c 01 00 00    	js     80140c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	68 07 04 00 00       	push   $0x407
  8012e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 8f ee ff ff       	call   800181 <sys_page_alloc>
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	89 c2                	mov    %eax,%edx
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	0f 88 0d 01 00 00    	js     80140c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012ff:	83 ec 0c             	sub    $0xc,%esp
  801302:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	e8 e8 f5 ff ff       	call   8008f3 <fd_alloc>
  80130b:	89 c3                	mov    %eax,%ebx
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	85 c0                	test   %eax,%eax
  801312:	0f 88 e2 00 00 00    	js     8013fa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801318:	83 ec 04             	sub    $0x4,%esp
  80131b:	68 07 04 00 00       	push   $0x407
  801320:	ff 75 f0             	pushl  -0x10(%ebp)
  801323:	6a 00                	push   $0x0
  801325:	e8 57 ee ff ff       	call   800181 <sys_page_alloc>
  80132a:	89 c3                	mov    %eax,%ebx
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	0f 88 c3 00 00 00    	js     8013fa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	ff 75 f4             	pushl  -0xc(%ebp)
  80133d:	e8 9a f5 ff ff       	call   8008dc <fd2data>
  801342:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801344:	83 c4 0c             	add    $0xc,%esp
  801347:	68 07 04 00 00       	push   $0x407
  80134c:	50                   	push   %eax
  80134d:	6a 00                	push   $0x0
  80134f:	e8 2d ee ff ff       	call   800181 <sys_page_alloc>
  801354:	89 c3                	mov    %eax,%ebx
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	0f 88 89 00 00 00    	js     8013ea <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801361:	83 ec 0c             	sub    $0xc,%esp
  801364:	ff 75 f0             	pushl  -0x10(%ebp)
  801367:	e8 70 f5 ff ff       	call   8008dc <fd2data>
  80136c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801373:	50                   	push   %eax
  801374:	6a 00                	push   $0x0
  801376:	56                   	push   %esi
  801377:	6a 00                	push   $0x0
  801379:	e8 46 ee ff ff       	call   8001c4 <sys_page_map>
  80137e:	89 c3                	mov    %eax,%ebx
  801380:	83 c4 20             	add    $0x20,%esp
  801383:	85 c0                	test   %eax,%eax
  801385:	78 55                	js     8013dc <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801387:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80138d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801390:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801392:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801395:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80139c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013aa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013b1:	83 ec 0c             	sub    $0xc,%esp
  8013b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b7:	e8 10 f5 ff ff       	call   8008cc <fd2num>
  8013bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013bf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013c1:	83 c4 04             	add    $0x4,%esp
  8013c4:	ff 75 f0             	pushl  -0x10(%ebp)
  8013c7:	e8 00 f5 ff ff       	call   8008cc <fd2num>
  8013cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013cf:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013da:	eb 30                	jmp    80140c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	56                   	push   %esi
  8013e0:	6a 00                	push   $0x0
  8013e2:	e8 1f ee ff ff       	call   800206 <sys_page_unmap>
  8013e7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 0f ee ff ff       	call   800206 <sys_page_unmap>
  8013f7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801400:	6a 00                	push   $0x0
  801402:	e8 ff ed ff ff       	call   800206 <sys_page_unmap>
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80140c:	89 d0                	mov    %edx,%eax
  80140e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80141b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141e:	50                   	push   %eax
  80141f:	ff 75 08             	pushl  0x8(%ebp)
  801422:	e8 1b f5 ff ff       	call   800942 <fd_lookup>
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 18                	js     801446 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80142e:	83 ec 0c             	sub    $0xc,%esp
  801431:	ff 75 f4             	pushl  -0xc(%ebp)
  801434:	e8 a3 f4 ff ff       	call   8008dc <fd2data>
	return _pipeisclosed(fd, p);
  801439:	89 c2                	mov    %eax,%edx
  80143b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143e:	e8 18 fd ff ff       	call   80115b <_pipeisclosed>
  801443:	83 c4 10             	add    $0x10,%esp
}
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80144b:	b8 00 00 00 00       	mov    $0x0,%eax
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    

00801452 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801458:	68 a2 25 80 00       	push   $0x8025a2
  80145d:	ff 75 0c             	pushl  0xc(%ebp)
  801460:	e8 c4 07 00 00       	call   801c29 <strcpy>
	return 0;
}
  801465:	b8 00 00 00 00       	mov    $0x0,%eax
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	57                   	push   %edi
  801470:	56                   	push   %esi
  801471:	53                   	push   %ebx
  801472:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801478:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80147d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801483:	eb 2d                	jmp    8014b2 <devcons_write+0x46>
		m = n - tot;
  801485:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801488:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80148a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80148d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801492:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	53                   	push   %ebx
  801499:	03 45 0c             	add    0xc(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	57                   	push   %edi
  80149e:	e8 18 09 00 00       	call   801dbb <memmove>
		sys_cputs(buf, m);
  8014a3:	83 c4 08             	add    $0x8,%esp
  8014a6:	53                   	push   %ebx
  8014a7:	57                   	push   %edi
  8014a8:	e8 18 ec ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014ad:	01 de                	add    %ebx,%esi
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	89 f0                	mov    %esi,%eax
  8014b4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014b7:	72 cc                	jb     801485 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014bc:	5b                   	pop    %ebx
  8014bd:	5e                   	pop    %esi
  8014be:	5f                   	pop    %edi
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	83 ec 08             	sub    $0x8,%esp
  8014c7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014d0:	74 2a                	je     8014fc <devcons_read+0x3b>
  8014d2:	eb 05                	jmp    8014d9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014d4:	e8 89 ec ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014d9:	e8 05 ec ff ff       	call   8000e3 <sys_cgetc>
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	74 f2                	je     8014d4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 16                	js     8014fc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014e6:	83 f8 04             	cmp    $0x4,%eax
  8014e9:	74 0c                	je     8014f7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ee:	88 02                	mov    %al,(%edx)
	return 1;
  8014f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f5:	eb 05                	jmp    8014fc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014f7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801504:	8b 45 08             	mov    0x8(%ebp),%eax
  801507:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80150a:	6a 01                	push   $0x1
  80150c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	e8 b0 eb ff ff       	call   8000c5 <sys_cputs>
}
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	c9                   	leave  
  801519:	c3                   	ret    

0080151a <getchar>:

int
getchar(void)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801520:	6a 01                	push   $0x1
  801522:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801525:	50                   	push   %eax
  801526:	6a 00                	push   $0x0
  801528:	e8 7e f6 ff ff       	call   800bab <read>
	if (r < 0)
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 0f                	js     801543 <getchar+0x29>
		return r;
	if (r < 1)
  801534:	85 c0                	test   %eax,%eax
  801536:	7e 06                	jle    80153e <getchar+0x24>
		return -E_EOF;
	return c;
  801538:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80153c:	eb 05                	jmp    801543 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80153e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	ff 75 08             	pushl  0x8(%ebp)
  801552:	e8 eb f3 ff ff       	call   800942 <fd_lookup>
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	85 c0                	test   %eax,%eax
  80155c:	78 11                	js     80156f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80155e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801561:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801567:	39 10                	cmp    %edx,(%eax)
  801569:	0f 94 c0             	sete   %al
  80156c:	0f b6 c0             	movzbl %al,%eax
}
  80156f:	c9                   	leave  
  801570:	c3                   	ret    

00801571 <opencons>:

int
opencons(void)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801577:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	e8 73 f3 ff ff       	call   8008f3 <fd_alloc>
  801580:	83 c4 10             	add    $0x10,%esp
		return r;
  801583:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801585:	85 c0                	test   %eax,%eax
  801587:	78 3e                	js     8015c7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801589:	83 ec 04             	sub    $0x4,%esp
  80158c:	68 07 04 00 00       	push   $0x407
  801591:	ff 75 f4             	pushl  -0xc(%ebp)
  801594:	6a 00                	push   $0x0
  801596:	e8 e6 eb ff ff       	call   800181 <sys_page_alloc>
  80159b:	83 c4 10             	add    $0x10,%esp
		return r;
  80159e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	78 23                	js     8015c7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015a4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ad:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015b9:	83 ec 0c             	sub    $0xc,%esp
  8015bc:	50                   	push   %eax
  8015bd:	e8 0a f3 ff ff       	call   8008cc <fd2num>
  8015c2:	89 c2                	mov    %eax,%edx
  8015c4:	83 c4 10             	add    $0x10,%esp
}
  8015c7:	89 d0                	mov    %edx,%eax
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015d0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015d3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015d9:	e8 65 eb ff ff       	call   800143 <sys_getenvid>
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	ff 75 0c             	pushl  0xc(%ebp)
  8015e4:	ff 75 08             	pushl  0x8(%ebp)
  8015e7:	56                   	push   %esi
  8015e8:	50                   	push   %eax
  8015e9:	68 b0 25 80 00       	push   $0x8025b0
  8015ee:	e8 b1 00 00 00       	call   8016a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015f3:	83 c4 18             	add    $0x18,%esp
  8015f6:	53                   	push   %ebx
  8015f7:	ff 75 10             	pushl  0x10(%ebp)
  8015fa:	e8 54 00 00 00       	call   801653 <vcprintf>
	cprintf("\n");
  8015ff:	c7 04 24 a6 24 80 00 	movl   $0x8024a6,(%esp)
  801606:	e8 99 00 00 00       	call   8016a4 <cprintf>
  80160b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80160e:	cc                   	int3   
  80160f:	eb fd                	jmp    80160e <_panic+0x43>

00801611 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	53                   	push   %ebx
  801615:	83 ec 04             	sub    $0x4,%esp
  801618:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80161b:	8b 13                	mov    (%ebx),%edx
  80161d:	8d 42 01             	lea    0x1(%edx),%eax
  801620:	89 03                	mov    %eax,(%ebx)
  801622:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801625:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801629:	3d ff 00 00 00       	cmp    $0xff,%eax
  80162e:	75 1a                	jne    80164a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801630:	83 ec 08             	sub    $0x8,%esp
  801633:	68 ff 00 00 00       	push   $0xff
  801638:	8d 43 08             	lea    0x8(%ebx),%eax
  80163b:	50                   	push   %eax
  80163c:	e8 84 ea ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  801641:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801647:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80164a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80164e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801651:	c9                   	leave  
  801652:	c3                   	ret    

00801653 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80165c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801663:	00 00 00 
	b.cnt = 0;
  801666:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80166d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801670:	ff 75 0c             	pushl  0xc(%ebp)
  801673:	ff 75 08             	pushl  0x8(%ebp)
  801676:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	68 11 16 80 00       	push   $0x801611
  801682:	e8 54 01 00 00       	call   8017db <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801687:	83 c4 08             	add    $0x8,%esp
  80168a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801690:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	e8 29 ea ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  80169c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016ad:	50                   	push   %eax
  8016ae:	ff 75 08             	pushl  0x8(%ebp)
  8016b1:	e8 9d ff ff ff       	call   801653 <vcprintf>
	va_end(ap);

	return cnt;
}
  8016b6:	c9                   	leave  
  8016b7:	c3                   	ret    

008016b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	57                   	push   %edi
  8016bc:	56                   	push   %esi
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 1c             	sub    $0x1c,%esp
  8016c1:	89 c7                	mov    %eax,%edi
  8016c3:	89 d6                	mov    %edx,%esi
  8016c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016dc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016df:	39 d3                	cmp    %edx,%ebx
  8016e1:	72 05                	jb     8016e8 <printnum+0x30>
  8016e3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016e6:	77 45                	ja     80172d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016e8:	83 ec 0c             	sub    $0xc,%esp
  8016eb:	ff 75 18             	pushl  0x18(%ebp)
  8016ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016f4:	53                   	push   %ebx
  8016f5:	ff 75 10             	pushl  0x10(%ebp)
  8016f8:	83 ec 08             	sub    $0x8,%esp
  8016fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801701:	ff 75 dc             	pushl  -0x24(%ebp)
  801704:	ff 75 d8             	pushl  -0x28(%ebp)
  801707:	e8 54 0a 00 00       	call   802160 <__udivdi3>
  80170c:	83 c4 18             	add    $0x18,%esp
  80170f:	52                   	push   %edx
  801710:	50                   	push   %eax
  801711:	89 f2                	mov    %esi,%edx
  801713:	89 f8                	mov    %edi,%eax
  801715:	e8 9e ff ff ff       	call   8016b8 <printnum>
  80171a:	83 c4 20             	add    $0x20,%esp
  80171d:	eb 18                	jmp    801737 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	56                   	push   %esi
  801723:	ff 75 18             	pushl  0x18(%ebp)
  801726:	ff d7                	call   *%edi
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	eb 03                	jmp    801730 <printnum+0x78>
  80172d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801730:	83 eb 01             	sub    $0x1,%ebx
  801733:	85 db                	test   %ebx,%ebx
  801735:	7f e8                	jg     80171f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	56                   	push   %esi
  80173b:	83 ec 04             	sub    $0x4,%esp
  80173e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801741:	ff 75 e0             	pushl  -0x20(%ebp)
  801744:	ff 75 dc             	pushl  -0x24(%ebp)
  801747:	ff 75 d8             	pushl  -0x28(%ebp)
  80174a:	e8 41 0b 00 00       	call   802290 <__umoddi3>
  80174f:	83 c4 14             	add    $0x14,%esp
  801752:	0f be 80 d3 25 80 00 	movsbl 0x8025d3(%eax),%eax
  801759:	50                   	push   %eax
  80175a:	ff d7                	call   *%edi
}
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5f                   	pop    %edi
  801765:	5d                   	pop    %ebp
  801766:	c3                   	ret    

00801767 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80176a:	83 fa 01             	cmp    $0x1,%edx
  80176d:	7e 0e                	jle    80177d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80176f:	8b 10                	mov    (%eax),%edx
  801771:	8d 4a 08             	lea    0x8(%edx),%ecx
  801774:	89 08                	mov    %ecx,(%eax)
  801776:	8b 02                	mov    (%edx),%eax
  801778:	8b 52 04             	mov    0x4(%edx),%edx
  80177b:	eb 22                	jmp    80179f <getuint+0x38>
	else if (lflag)
  80177d:	85 d2                	test   %edx,%edx
  80177f:	74 10                	je     801791 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801781:	8b 10                	mov    (%eax),%edx
  801783:	8d 4a 04             	lea    0x4(%edx),%ecx
  801786:	89 08                	mov    %ecx,(%eax)
  801788:	8b 02                	mov    (%edx),%eax
  80178a:	ba 00 00 00 00       	mov    $0x0,%edx
  80178f:	eb 0e                	jmp    80179f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801791:	8b 10                	mov    (%eax),%edx
  801793:	8d 4a 04             	lea    0x4(%edx),%ecx
  801796:	89 08                	mov    %ecx,(%eax)
  801798:	8b 02                	mov    (%edx),%eax
  80179a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    

008017a1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017a7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017ab:	8b 10                	mov    (%eax),%edx
  8017ad:	3b 50 04             	cmp    0x4(%eax),%edx
  8017b0:	73 0a                	jae    8017bc <sprintputch+0x1b>
		*b->buf++ = ch;
  8017b2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017b5:	89 08                	mov    %ecx,(%eax)
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	88 02                	mov    %al,(%edx)
}
  8017bc:	5d                   	pop    %ebp
  8017bd:	c3                   	ret    

008017be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017c7:	50                   	push   %eax
  8017c8:	ff 75 10             	pushl  0x10(%ebp)
  8017cb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ce:	ff 75 08             	pushl  0x8(%ebp)
  8017d1:	e8 05 00 00 00       	call   8017db <vprintfmt>
	va_end(ap);
}
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	57                   	push   %edi
  8017df:	56                   	push   %esi
  8017e0:	53                   	push   %ebx
  8017e1:	83 ec 2c             	sub    $0x2c,%esp
  8017e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8017e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017ea:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017ed:	eb 12                	jmp    801801 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	0f 84 89 03 00 00    	je     801b80 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	53                   	push   %ebx
  8017fb:	50                   	push   %eax
  8017fc:	ff d6                	call   *%esi
  8017fe:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801801:	83 c7 01             	add    $0x1,%edi
  801804:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801808:	83 f8 25             	cmp    $0x25,%eax
  80180b:	75 e2                	jne    8017ef <vprintfmt+0x14>
  80180d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801811:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801818:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80181f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801826:	ba 00 00 00 00       	mov    $0x0,%edx
  80182b:	eb 07                	jmp    801834 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801830:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801834:	8d 47 01             	lea    0x1(%edi),%eax
  801837:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80183a:	0f b6 07             	movzbl (%edi),%eax
  80183d:	0f b6 c8             	movzbl %al,%ecx
  801840:	83 e8 23             	sub    $0x23,%eax
  801843:	3c 55                	cmp    $0x55,%al
  801845:	0f 87 1a 03 00 00    	ja     801b65 <vprintfmt+0x38a>
  80184b:	0f b6 c0             	movzbl %al,%eax
  80184e:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  801855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801858:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80185c:	eb d6                	jmp    801834 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801861:	b8 00 00 00 00       	mov    $0x0,%eax
  801866:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801869:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80186c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801870:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801873:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801876:	83 fa 09             	cmp    $0x9,%edx
  801879:	77 39                	ja     8018b4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80187b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80187e:	eb e9                	jmp    801869 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801880:	8b 45 14             	mov    0x14(%ebp),%eax
  801883:	8d 48 04             	lea    0x4(%eax),%ecx
  801886:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801889:	8b 00                	mov    (%eax),%eax
  80188b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80188e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801891:	eb 27                	jmp    8018ba <vprintfmt+0xdf>
  801893:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801896:	85 c0                	test   %eax,%eax
  801898:	b9 00 00 00 00       	mov    $0x0,%ecx
  80189d:	0f 49 c8             	cmovns %eax,%ecx
  8018a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018a6:	eb 8c                	jmp    801834 <vprintfmt+0x59>
  8018a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018ab:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018b2:	eb 80                	jmp    801834 <vprintfmt+0x59>
  8018b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018b7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018be:	0f 89 70 ff ff ff    	jns    801834 <vprintfmt+0x59>
				width = precision, precision = -1;
  8018c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018d1:	e9 5e ff ff ff       	jmp    801834 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018d6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018dc:	e9 53 ff ff ff       	jmp    801834 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e4:	8d 50 04             	lea    0x4(%eax),%edx
  8018e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8018ea:	83 ec 08             	sub    $0x8,%esp
  8018ed:	53                   	push   %ebx
  8018ee:	ff 30                	pushl  (%eax)
  8018f0:	ff d6                	call   *%esi
			break;
  8018f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018f8:	e9 04 ff ff ff       	jmp    801801 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801900:	8d 50 04             	lea    0x4(%eax),%edx
  801903:	89 55 14             	mov    %edx,0x14(%ebp)
  801906:	8b 00                	mov    (%eax),%eax
  801908:	99                   	cltd   
  801909:	31 d0                	xor    %edx,%eax
  80190b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80190d:	83 f8 0f             	cmp    $0xf,%eax
  801910:	7f 0b                	jg     80191d <vprintfmt+0x142>
  801912:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  801919:	85 d2                	test   %edx,%edx
  80191b:	75 18                	jne    801935 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80191d:	50                   	push   %eax
  80191e:	68 eb 25 80 00       	push   $0x8025eb
  801923:	53                   	push   %ebx
  801924:	56                   	push   %esi
  801925:	e8 94 fe ff ff       	call   8017be <printfmt>
  80192a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801930:	e9 cc fe ff ff       	jmp    801801 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801935:	52                   	push   %edx
  801936:	68 69 25 80 00       	push   $0x802569
  80193b:	53                   	push   %ebx
  80193c:	56                   	push   %esi
  80193d:	e8 7c fe ff ff       	call   8017be <printfmt>
  801942:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801945:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801948:	e9 b4 fe ff ff       	jmp    801801 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80194d:	8b 45 14             	mov    0x14(%ebp),%eax
  801950:	8d 50 04             	lea    0x4(%eax),%edx
  801953:	89 55 14             	mov    %edx,0x14(%ebp)
  801956:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801958:	85 ff                	test   %edi,%edi
  80195a:	b8 e4 25 80 00       	mov    $0x8025e4,%eax
  80195f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801962:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801966:	0f 8e 94 00 00 00    	jle    801a00 <vprintfmt+0x225>
  80196c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801970:	0f 84 98 00 00 00    	je     801a0e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	ff 75 d0             	pushl  -0x30(%ebp)
  80197c:	57                   	push   %edi
  80197d:	e8 86 02 00 00       	call   801c08 <strnlen>
  801982:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801985:	29 c1                	sub    %eax,%ecx
  801987:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80198a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80198d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801991:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801994:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801997:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801999:	eb 0f                	jmp    8019aa <vprintfmt+0x1cf>
					putch(padc, putdat);
  80199b:	83 ec 08             	sub    $0x8,%esp
  80199e:	53                   	push   %ebx
  80199f:	ff 75 e0             	pushl  -0x20(%ebp)
  8019a2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a4:	83 ef 01             	sub    $0x1,%edi
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	85 ff                	test   %edi,%edi
  8019ac:	7f ed                	jg     80199b <vprintfmt+0x1c0>
  8019ae:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019b1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019b4:	85 c9                	test   %ecx,%ecx
  8019b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bb:	0f 49 c1             	cmovns %ecx,%eax
  8019be:	29 c1                	sub    %eax,%ecx
  8019c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8019c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019c9:	89 cb                	mov    %ecx,%ebx
  8019cb:	eb 4d                	jmp    801a1a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019cd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019d1:	74 1b                	je     8019ee <vprintfmt+0x213>
  8019d3:	0f be c0             	movsbl %al,%eax
  8019d6:	83 e8 20             	sub    $0x20,%eax
  8019d9:	83 f8 5e             	cmp    $0x5e,%eax
  8019dc:	76 10                	jbe    8019ee <vprintfmt+0x213>
					putch('?', putdat);
  8019de:	83 ec 08             	sub    $0x8,%esp
  8019e1:	ff 75 0c             	pushl  0xc(%ebp)
  8019e4:	6a 3f                	push   $0x3f
  8019e6:	ff 55 08             	call   *0x8(%ebp)
  8019e9:	83 c4 10             	add    $0x10,%esp
  8019ec:	eb 0d                	jmp    8019fb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	ff 75 0c             	pushl  0xc(%ebp)
  8019f4:	52                   	push   %edx
  8019f5:	ff 55 08             	call   *0x8(%ebp)
  8019f8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019fb:	83 eb 01             	sub    $0x1,%ebx
  8019fe:	eb 1a                	jmp    801a1a <vprintfmt+0x23f>
  801a00:	89 75 08             	mov    %esi,0x8(%ebp)
  801a03:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a06:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a09:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a0c:	eb 0c                	jmp    801a1a <vprintfmt+0x23f>
  801a0e:	89 75 08             	mov    %esi,0x8(%ebp)
  801a11:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a14:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a17:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a1a:	83 c7 01             	add    $0x1,%edi
  801a1d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a21:	0f be d0             	movsbl %al,%edx
  801a24:	85 d2                	test   %edx,%edx
  801a26:	74 23                	je     801a4b <vprintfmt+0x270>
  801a28:	85 f6                	test   %esi,%esi
  801a2a:	78 a1                	js     8019cd <vprintfmt+0x1f2>
  801a2c:	83 ee 01             	sub    $0x1,%esi
  801a2f:	79 9c                	jns    8019cd <vprintfmt+0x1f2>
  801a31:	89 df                	mov    %ebx,%edi
  801a33:	8b 75 08             	mov    0x8(%ebp),%esi
  801a36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a39:	eb 18                	jmp    801a53 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a3b:	83 ec 08             	sub    $0x8,%esp
  801a3e:	53                   	push   %ebx
  801a3f:	6a 20                	push   $0x20
  801a41:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a43:	83 ef 01             	sub    $0x1,%edi
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	eb 08                	jmp    801a53 <vprintfmt+0x278>
  801a4b:	89 df                	mov    %ebx,%edi
  801a4d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a53:	85 ff                	test   %edi,%edi
  801a55:	7f e4                	jg     801a3b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a5a:	e9 a2 fd ff ff       	jmp    801801 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a5f:	83 fa 01             	cmp    $0x1,%edx
  801a62:	7e 16                	jle    801a7a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a64:	8b 45 14             	mov    0x14(%ebp),%eax
  801a67:	8d 50 08             	lea    0x8(%eax),%edx
  801a6a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a6d:	8b 50 04             	mov    0x4(%eax),%edx
  801a70:	8b 00                	mov    (%eax),%eax
  801a72:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a75:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a78:	eb 32                	jmp    801aac <vprintfmt+0x2d1>
	else if (lflag)
  801a7a:	85 d2                	test   %edx,%edx
  801a7c:	74 18                	je     801a96 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a81:	8d 50 04             	lea    0x4(%eax),%edx
  801a84:	89 55 14             	mov    %edx,0x14(%ebp)
  801a87:	8b 00                	mov    (%eax),%eax
  801a89:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a8c:	89 c1                	mov    %eax,%ecx
  801a8e:	c1 f9 1f             	sar    $0x1f,%ecx
  801a91:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a94:	eb 16                	jmp    801aac <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a96:	8b 45 14             	mov    0x14(%ebp),%eax
  801a99:	8d 50 04             	lea    0x4(%eax),%edx
  801a9c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a9f:	8b 00                	mov    (%eax),%eax
  801aa1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aa4:	89 c1                	mov    %eax,%ecx
  801aa6:	c1 f9 1f             	sar    $0x1f,%ecx
  801aa9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801aac:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aaf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801ab2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ab7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801abb:	79 74                	jns    801b31 <vprintfmt+0x356>
				putch('-', putdat);
  801abd:	83 ec 08             	sub    $0x8,%esp
  801ac0:	53                   	push   %ebx
  801ac1:	6a 2d                	push   $0x2d
  801ac3:	ff d6                	call   *%esi
				num = -(long long) num;
  801ac5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ac8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801acb:	f7 d8                	neg    %eax
  801acd:	83 d2 00             	adc    $0x0,%edx
  801ad0:	f7 da                	neg    %edx
  801ad2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ad5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ada:	eb 55                	jmp    801b31 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801adc:	8d 45 14             	lea    0x14(%ebp),%eax
  801adf:	e8 83 fc ff ff       	call   801767 <getuint>
			base = 10;
  801ae4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ae9:	eb 46                	jmp    801b31 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801aeb:	8d 45 14             	lea    0x14(%ebp),%eax
  801aee:	e8 74 fc ff ff       	call   801767 <getuint>
			base = 8;
  801af3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801af8:	eb 37                	jmp    801b31 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801afa:	83 ec 08             	sub    $0x8,%esp
  801afd:	53                   	push   %ebx
  801afe:	6a 30                	push   $0x30
  801b00:	ff d6                	call   *%esi
			putch('x', putdat);
  801b02:	83 c4 08             	add    $0x8,%esp
  801b05:	53                   	push   %ebx
  801b06:	6a 78                	push   $0x78
  801b08:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b0a:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0d:	8d 50 04             	lea    0x4(%eax),%edx
  801b10:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b13:	8b 00                	mov    (%eax),%eax
  801b15:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b1a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b1d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b22:	eb 0d                	jmp    801b31 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b24:	8d 45 14             	lea    0x14(%ebp),%eax
  801b27:	e8 3b fc ff ff       	call   801767 <getuint>
			base = 16;
  801b2c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b38:	57                   	push   %edi
  801b39:	ff 75 e0             	pushl  -0x20(%ebp)
  801b3c:	51                   	push   %ecx
  801b3d:	52                   	push   %edx
  801b3e:	50                   	push   %eax
  801b3f:	89 da                	mov    %ebx,%edx
  801b41:	89 f0                	mov    %esi,%eax
  801b43:	e8 70 fb ff ff       	call   8016b8 <printnum>
			break;
  801b48:	83 c4 20             	add    $0x20,%esp
  801b4b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b4e:	e9 ae fc ff ff       	jmp    801801 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b53:	83 ec 08             	sub    $0x8,%esp
  801b56:	53                   	push   %ebx
  801b57:	51                   	push   %ecx
  801b58:	ff d6                	call   *%esi
			break;
  801b5a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b60:	e9 9c fc ff ff       	jmp    801801 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b65:	83 ec 08             	sub    $0x8,%esp
  801b68:	53                   	push   %ebx
  801b69:	6a 25                	push   $0x25
  801b6b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	eb 03                	jmp    801b75 <vprintfmt+0x39a>
  801b72:	83 ef 01             	sub    $0x1,%edi
  801b75:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b79:	75 f7                	jne    801b72 <vprintfmt+0x397>
  801b7b:	e9 81 fc ff ff       	jmp    801801 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5f                   	pop    %edi
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    

00801b88 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	83 ec 18             	sub    $0x18,%esp
  801b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b91:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b94:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b97:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b9b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ba5:	85 c0                	test   %eax,%eax
  801ba7:	74 26                	je     801bcf <vsnprintf+0x47>
  801ba9:	85 d2                	test   %edx,%edx
  801bab:	7e 22                	jle    801bcf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801bad:	ff 75 14             	pushl  0x14(%ebp)
  801bb0:	ff 75 10             	pushl  0x10(%ebp)
  801bb3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bb6:	50                   	push   %eax
  801bb7:	68 a1 17 80 00       	push   $0x8017a1
  801bbc:	e8 1a fc ff ff       	call   8017db <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bc4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bca:	83 c4 10             	add    $0x10,%esp
  801bcd:	eb 05                	jmp    801bd4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bd4:	c9                   	leave  
  801bd5:	c3                   	ret    

00801bd6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bd6:	55                   	push   %ebp
  801bd7:	89 e5                	mov    %esp,%ebp
  801bd9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bdc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bdf:	50                   	push   %eax
  801be0:	ff 75 10             	pushl  0x10(%ebp)
  801be3:	ff 75 0c             	pushl  0xc(%ebp)
  801be6:	ff 75 08             	pushl  0x8(%ebp)
  801be9:	e8 9a ff ff ff       	call   801b88 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bfb:	eb 03                	jmp    801c00 <strlen+0x10>
		n++;
  801bfd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c00:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c04:	75 f7                	jne    801bfd <strlen+0xd>
		n++;
	return n;
}
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    

00801c08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c11:	ba 00 00 00 00       	mov    $0x0,%edx
  801c16:	eb 03                	jmp    801c1b <strnlen+0x13>
		n++;
  801c18:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c1b:	39 c2                	cmp    %eax,%edx
  801c1d:	74 08                	je     801c27 <strnlen+0x1f>
  801c1f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c23:	75 f3                	jne    801c18 <strnlen+0x10>
  801c25:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	53                   	push   %ebx
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c33:	89 c2                	mov    %eax,%edx
  801c35:	83 c2 01             	add    $0x1,%edx
  801c38:	83 c1 01             	add    $0x1,%ecx
  801c3b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c3f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c42:	84 db                	test   %bl,%bl
  801c44:	75 ef                	jne    801c35 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c46:	5b                   	pop    %ebx
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	53                   	push   %ebx
  801c4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c50:	53                   	push   %ebx
  801c51:	e8 9a ff ff ff       	call   801bf0 <strlen>
  801c56:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c59:	ff 75 0c             	pushl  0xc(%ebp)
  801c5c:	01 d8                	add    %ebx,%eax
  801c5e:	50                   	push   %eax
  801c5f:	e8 c5 ff ff ff       	call   801c29 <strcpy>
	return dst;
}
  801c64:	89 d8                	mov    %ebx,%eax
  801c66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    

00801c6b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	56                   	push   %esi
  801c6f:	53                   	push   %ebx
  801c70:	8b 75 08             	mov    0x8(%ebp),%esi
  801c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c76:	89 f3                	mov    %esi,%ebx
  801c78:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c7b:	89 f2                	mov    %esi,%edx
  801c7d:	eb 0f                	jmp    801c8e <strncpy+0x23>
		*dst++ = *src;
  801c7f:	83 c2 01             	add    $0x1,%edx
  801c82:	0f b6 01             	movzbl (%ecx),%eax
  801c85:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c88:	80 39 01             	cmpb   $0x1,(%ecx)
  801c8b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c8e:	39 da                	cmp    %ebx,%edx
  801c90:	75 ed                	jne    801c7f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c92:	89 f0                	mov    %esi,%eax
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	8b 75 08             	mov    0x8(%ebp),%esi
  801ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca3:	8b 55 10             	mov    0x10(%ebp),%edx
  801ca6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ca8:	85 d2                	test   %edx,%edx
  801caa:	74 21                	je     801ccd <strlcpy+0x35>
  801cac:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cb0:	89 f2                	mov    %esi,%edx
  801cb2:	eb 09                	jmp    801cbd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cb4:	83 c2 01             	add    $0x1,%edx
  801cb7:	83 c1 01             	add    $0x1,%ecx
  801cba:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cbd:	39 c2                	cmp    %eax,%edx
  801cbf:	74 09                	je     801cca <strlcpy+0x32>
  801cc1:	0f b6 19             	movzbl (%ecx),%ebx
  801cc4:	84 db                	test   %bl,%bl
  801cc6:	75 ec                	jne    801cb4 <strlcpy+0x1c>
  801cc8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cca:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801ccd:	29 f0                	sub    %esi,%eax
}
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cdc:	eb 06                	jmp    801ce4 <strcmp+0x11>
		p++, q++;
  801cde:	83 c1 01             	add    $0x1,%ecx
  801ce1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ce4:	0f b6 01             	movzbl (%ecx),%eax
  801ce7:	84 c0                	test   %al,%al
  801ce9:	74 04                	je     801cef <strcmp+0x1c>
  801ceb:	3a 02                	cmp    (%edx),%al
  801ced:	74 ef                	je     801cde <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cef:	0f b6 c0             	movzbl %al,%eax
  801cf2:	0f b6 12             	movzbl (%edx),%edx
  801cf5:	29 d0                	sub    %edx,%eax
}
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	53                   	push   %ebx
  801cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801d00:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d03:	89 c3                	mov    %eax,%ebx
  801d05:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d08:	eb 06                	jmp    801d10 <strncmp+0x17>
		n--, p++, q++;
  801d0a:	83 c0 01             	add    $0x1,%eax
  801d0d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d10:	39 d8                	cmp    %ebx,%eax
  801d12:	74 15                	je     801d29 <strncmp+0x30>
  801d14:	0f b6 08             	movzbl (%eax),%ecx
  801d17:	84 c9                	test   %cl,%cl
  801d19:	74 04                	je     801d1f <strncmp+0x26>
  801d1b:	3a 0a                	cmp    (%edx),%cl
  801d1d:	74 eb                	je     801d0a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d1f:	0f b6 00             	movzbl (%eax),%eax
  801d22:	0f b6 12             	movzbl (%edx),%edx
  801d25:	29 d0                	sub    %edx,%eax
  801d27:	eb 05                	jmp    801d2e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d29:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d2e:	5b                   	pop    %ebx
  801d2f:	5d                   	pop    %ebp
  801d30:	c3                   	ret    

00801d31 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d3b:	eb 07                	jmp    801d44 <strchr+0x13>
		if (*s == c)
  801d3d:	38 ca                	cmp    %cl,%dl
  801d3f:	74 0f                	je     801d50 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d41:	83 c0 01             	add    $0x1,%eax
  801d44:	0f b6 10             	movzbl (%eax),%edx
  801d47:	84 d2                	test   %dl,%dl
  801d49:	75 f2                	jne    801d3d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    

00801d52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	8b 45 08             	mov    0x8(%ebp),%eax
  801d58:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d5c:	eb 03                	jmp    801d61 <strfind+0xf>
  801d5e:	83 c0 01             	add    $0x1,%eax
  801d61:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d64:	38 ca                	cmp    %cl,%dl
  801d66:	74 04                	je     801d6c <strfind+0x1a>
  801d68:	84 d2                	test   %dl,%dl
  801d6a:	75 f2                	jne    801d5e <strfind+0xc>
			break;
	return (char *) s;
}
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    

00801d6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d7a:	85 c9                	test   %ecx,%ecx
  801d7c:	74 36                	je     801db4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d84:	75 28                	jne    801dae <memset+0x40>
  801d86:	f6 c1 03             	test   $0x3,%cl
  801d89:	75 23                	jne    801dae <memset+0x40>
		c &= 0xFF;
  801d8b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d8f:	89 d3                	mov    %edx,%ebx
  801d91:	c1 e3 08             	shl    $0x8,%ebx
  801d94:	89 d6                	mov    %edx,%esi
  801d96:	c1 e6 18             	shl    $0x18,%esi
  801d99:	89 d0                	mov    %edx,%eax
  801d9b:	c1 e0 10             	shl    $0x10,%eax
  801d9e:	09 f0                	or     %esi,%eax
  801da0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801da2:	89 d8                	mov    %ebx,%eax
  801da4:	09 d0                	or     %edx,%eax
  801da6:	c1 e9 02             	shr    $0x2,%ecx
  801da9:	fc                   	cld    
  801daa:	f3 ab                	rep stos %eax,%es:(%edi)
  801dac:	eb 06                	jmp    801db4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db1:	fc                   	cld    
  801db2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801db4:	89 f8                	mov    %edi,%eax
  801db6:	5b                   	pop    %ebx
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	57                   	push   %edi
  801dbf:	56                   	push   %esi
  801dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dc9:	39 c6                	cmp    %eax,%esi
  801dcb:	73 35                	jae    801e02 <memmove+0x47>
  801dcd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dd0:	39 d0                	cmp    %edx,%eax
  801dd2:	73 2e                	jae    801e02 <memmove+0x47>
		s += n;
		d += n;
  801dd4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dd7:	89 d6                	mov    %edx,%esi
  801dd9:	09 fe                	or     %edi,%esi
  801ddb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801de1:	75 13                	jne    801df6 <memmove+0x3b>
  801de3:	f6 c1 03             	test   $0x3,%cl
  801de6:	75 0e                	jne    801df6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801de8:	83 ef 04             	sub    $0x4,%edi
  801deb:	8d 72 fc             	lea    -0x4(%edx),%esi
  801dee:	c1 e9 02             	shr    $0x2,%ecx
  801df1:	fd                   	std    
  801df2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801df4:	eb 09                	jmp    801dff <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801df6:	83 ef 01             	sub    $0x1,%edi
  801df9:	8d 72 ff             	lea    -0x1(%edx),%esi
  801dfc:	fd                   	std    
  801dfd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801dff:	fc                   	cld    
  801e00:	eb 1d                	jmp    801e1f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e02:	89 f2                	mov    %esi,%edx
  801e04:	09 c2                	or     %eax,%edx
  801e06:	f6 c2 03             	test   $0x3,%dl
  801e09:	75 0f                	jne    801e1a <memmove+0x5f>
  801e0b:	f6 c1 03             	test   $0x3,%cl
  801e0e:	75 0a                	jne    801e1a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e10:	c1 e9 02             	shr    $0x2,%ecx
  801e13:	89 c7                	mov    %eax,%edi
  801e15:	fc                   	cld    
  801e16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e18:	eb 05                	jmp    801e1f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e1a:	89 c7                	mov    %eax,%edi
  801e1c:	fc                   	cld    
  801e1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e1f:	5e                   	pop    %esi
  801e20:	5f                   	pop    %edi
  801e21:	5d                   	pop    %ebp
  801e22:	c3                   	ret    

00801e23 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e26:	ff 75 10             	pushl  0x10(%ebp)
  801e29:	ff 75 0c             	pushl  0xc(%ebp)
  801e2c:	ff 75 08             	pushl  0x8(%ebp)
  801e2f:	e8 87 ff ff ff       	call   801dbb <memmove>
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	56                   	push   %esi
  801e3a:	53                   	push   %ebx
  801e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e41:	89 c6                	mov    %eax,%esi
  801e43:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e46:	eb 1a                	jmp    801e62 <memcmp+0x2c>
		if (*s1 != *s2)
  801e48:	0f b6 08             	movzbl (%eax),%ecx
  801e4b:	0f b6 1a             	movzbl (%edx),%ebx
  801e4e:	38 d9                	cmp    %bl,%cl
  801e50:	74 0a                	je     801e5c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e52:	0f b6 c1             	movzbl %cl,%eax
  801e55:	0f b6 db             	movzbl %bl,%ebx
  801e58:	29 d8                	sub    %ebx,%eax
  801e5a:	eb 0f                	jmp    801e6b <memcmp+0x35>
		s1++, s2++;
  801e5c:	83 c0 01             	add    $0x1,%eax
  801e5f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e62:	39 f0                	cmp    %esi,%eax
  801e64:	75 e2                	jne    801e48 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e6b:	5b                   	pop    %ebx
  801e6c:	5e                   	pop    %esi
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    

00801e6f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	53                   	push   %ebx
  801e73:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e76:	89 c1                	mov    %eax,%ecx
  801e78:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e7b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e7f:	eb 0a                	jmp    801e8b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e81:	0f b6 10             	movzbl (%eax),%edx
  801e84:	39 da                	cmp    %ebx,%edx
  801e86:	74 07                	je     801e8f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e88:	83 c0 01             	add    $0x1,%eax
  801e8b:	39 c8                	cmp    %ecx,%eax
  801e8d:	72 f2                	jb     801e81 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e8f:	5b                   	pop    %ebx
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    

00801e92 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	57                   	push   %edi
  801e96:	56                   	push   %esi
  801e97:	53                   	push   %ebx
  801e98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e9e:	eb 03                	jmp    801ea3 <strtol+0x11>
		s++;
  801ea0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ea3:	0f b6 01             	movzbl (%ecx),%eax
  801ea6:	3c 20                	cmp    $0x20,%al
  801ea8:	74 f6                	je     801ea0 <strtol+0xe>
  801eaa:	3c 09                	cmp    $0x9,%al
  801eac:	74 f2                	je     801ea0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801eae:	3c 2b                	cmp    $0x2b,%al
  801eb0:	75 0a                	jne    801ebc <strtol+0x2a>
		s++;
  801eb2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801eb5:	bf 00 00 00 00       	mov    $0x0,%edi
  801eba:	eb 11                	jmp    801ecd <strtol+0x3b>
  801ebc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ec1:	3c 2d                	cmp    $0x2d,%al
  801ec3:	75 08                	jne    801ecd <strtol+0x3b>
		s++, neg = 1;
  801ec5:	83 c1 01             	add    $0x1,%ecx
  801ec8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ecd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ed3:	75 15                	jne    801eea <strtol+0x58>
  801ed5:	80 39 30             	cmpb   $0x30,(%ecx)
  801ed8:	75 10                	jne    801eea <strtol+0x58>
  801eda:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ede:	75 7c                	jne    801f5c <strtol+0xca>
		s += 2, base = 16;
  801ee0:	83 c1 02             	add    $0x2,%ecx
  801ee3:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ee8:	eb 16                	jmp    801f00 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801eea:	85 db                	test   %ebx,%ebx
  801eec:	75 12                	jne    801f00 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801eee:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ef3:	80 39 30             	cmpb   $0x30,(%ecx)
  801ef6:	75 08                	jne    801f00 <strtol+0x6e>
		s++, base = 8;
  801ef8:	83 c1 01             	add    $0x1,%ecx
  801efb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f00:	b8 00 00 00 00       	mov    $0x0,%eax
  801f05:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f08:	0f b6 11             	movzbl (%ecx),%edx
  801f0b:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f0e:	89 f3                	mov    %esi,%ebx
  801f10:	80 fb 09             	cmp    $0x9,%bl
  801f13:	77 08                	ja     801f1d <strtol+0x8b>
			dig = *s - '0';
  801f15:	0f be d2             	movsbl %dl,%edx
  801f18:	83 ea 30             	sub    $0x30,%edx
  801f1b:	eb 22                	jmp    801f3f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f1d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f20:	89 f3                	mov    %esi,%ebx
  801f22:	80 fb 19             	cmp    $0x19,%bl
  801f25:	77 08                	ja     801f2f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f27:	0f be d2             	movsbl %dl,%edx
  801f2a:	83 ea 57             	sub    $0x57,%edx
  801f2d:	eb 10                	jmp    801f3f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f2f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f32:	89 f3                	mov    %esi,%ebx
  801f34:	80 fb 19             	cmp    $0x19,%bl
  801f37:	77 16                	ja     801f4f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f39:	0f be d2             	movsbl %dl,%edx
  801f3c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f3f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f42:	7d 0b                	jge    801f4f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f44:	83 c1 01             	add    $0x1,%ecx
  801f47:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f4b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f4d:	eb b9                	jmp    801f08 <strtol+0x76>

	if (endptr)
  801f4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f53:	74 0d                	je     801f62 <strtol+0xd0>
		*endptr = (char *) s;
  801f55:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f58:	89 0e                	mov    %ecx,(%esi)
  801f5a:	eb 06                	jmp    801f62 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f5c:	85 db                	test   %ebx,%ebx
  801f5e:	74 98                	je     801ef8 <strtol+0x66>
  801f60:	eb 9e                	jmp    801f00 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f62:	89 c2                	mov    %eax,%edx
  801f64:	f7 da                	neg    %edx
  801f66:	85 ff                	test   %edi,%edi
  801f68:	0f 45 c2             	cmovne %edx,%eax
}
  801f6b:	5b                   	pop    %ebx
  801f6c:	5e                   	pop    %esi
  801f6d:	5f                   	pop    %edi
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f76:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f7d:	75 2a                	jne    801fa9 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f7f:	83 ec 04             	sub    $0x4,%esp
  801f82:	6a 07                	push   $0x7
  801f84:	68 00 f0 bf ee       	push   $0xeebff000
  801f89:	6a 00                	push   $0x0
  801f8b:	e8 f1 e1 ff ff       	call   800181 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	85 c0                	test   %eax,%eax
  801f95:	79 12                	jns    801fa9 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f97:	50                   	push   %eax
  801f98:	68 bd 24 80 00       	push   $0x8024bd
  801f9d:	6a 23                	push   $0x23
  801f9f:	68 e0 28 80 00       	push   $0x8028e0
  801fa4:	e8 22 f6 ff ff       	call   8015cb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fac:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fb1:	83 ec 08             	sub    $0x8,%esp
  801fb4:	68 db 1f 80 00       	push   $0x801fdb
  801fb9:	6a 00                	push   $0x0
  801fbb:	e8 0c e3 ff ff       	call   8002cc <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	79 12                	jns    801fd9 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fc7:	50                   	push   %eax
  801fc8:	68 bd 24 80 00       	push   $0x8024bd
  801fcd:	6a 2c                	push   $0x2c
  801fcf:	68 e0 28 80 00       	push   $0x8028e0
  801fd4:	e8 f2 f5 ff ff       	call   8015cb <_panic>
	}
}
  801fd9:	c9                   	leave  
  801fda:	c3                   	ret    

00801fdb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fdb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fdc:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fe1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fe3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fe6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fea:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fef:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801ff3:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ff5:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ff8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ff9:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ffc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ffd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ffe:	c3                   	ret    

00801fff <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	8b 75 08             	mov    0x8(%ebp),%esi
  802007:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80200d:	85 c0                	test   %eax,%eax
  80200f:	75 12                	jne    802023 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802011:	83 ec 0c             	sub    $0xc,%esp
  802014:	68 00 00 c0 ee       	push   $0xeec00000
  802019:	e8 13 e3 ff ff       	call   800331 <sys_ipc_recv>
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	eb 0c                	jmp    80202f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802023:	83 ec 0c             	sub    $0xc,%esp
  802026:	50                   	push   %eax
  802027:	e8 05 e3 ff ff       	call   800331 <sys_ipc_recv>
  80202c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80202f:	85 f6                	test   %esi,%esi
  802031:	0f 95 c1             	setne  %cl
  802034:	85 db                	test   %ebx,%ebx
  802036:	0f 95 c2             	setne  %dl
  802039:	84 d1                	test   %dl,%cl
  80203b:	74 09                	je     802046 <ipc_recv+0x47>
  80203d:	89 c2                	mov    %eax,%edx
  80203f:	c1 ea 1f             	shr    $0x1f,%edx
  802042:	84 d2                	test   %dl,%dl
  802044:	75 2d                	jne    802073 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802046:	85 f6                	test   %esi,%esi
  802048:	74 0d                	je     802057 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80204a:	a1 04 40 80 00       	mov    0x804004,%eax
  80204f:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802055:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802057:	85 db                	test   %ebx,%ebx
  802059:	74 0d                	je     802068 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80205b:	a1 04 40 80 00       	mov    0x804004,%eax
  802060:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802066:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802068:	a1 04 40 80 00       	mov    0x804004,%eax
  80206d:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802073:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802076:	5b                   	pop    %ebx
  802077:	5e                   	pop    %esi
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    

0080207a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	57                   	push   %edi
  80207e:	56                   	push   %esi
  80207f:	53                   	push   %ebx
  802080:	83 ec 0c             	sub    $0xc,%esp
  802083:	8b 7d 08             	mov    0x8(%ebp),%edi
  802086:	8b 75 0c             	mov    0xc(%ebp),%esi
  802089:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80208c:	85 db                	test   %ebx,%ebx
  80208e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802093:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802096:	ff 75 14             	pushl  0x14(%ebp)
  802099:	53                   	push   %ebx
  80209a:	56                   	push   %esi
  80209b:	57                   	push   %edi
  80209c:	e8 6d e2 ff ff       	call   80030e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020a1:	89 c2                	mov    %eax,%edx
  8020a3:	c1 ea 1f             	shr    $0x1f,%edx
  8020a6:	83 c4 10             	add    $0x10,%esp
  8020a9:	84 d2                	test   %dl,%dl
  8020ab:	74 17                	je     8020c4 <ipc_send+0x4a>
  8020ad:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020b0:	74 12                	je     8020c4 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020b2:	50                   	push   %eax
  8020b3:	68 ee 28 80 00       	push   $0x8028ee
  8020b8:	6a 47                	push   $0x47
  8020ba:	68 fc 28 80 00       	push   $0x8028fc
  8020bf:	e8 07 f5 ff ff       	call   8015cb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020c4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c7:	75 07                	jne    8020d0 <ipc_send+0x56>
			sys_yield();
  8020c9:	e8 94 e0 ff ff       	call   800162 <sys_yield>
  8020ce:	eb c6                	jmp    802096 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	75 c2                	jne    802096 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5f                   	pop    %edi
  8020da:	5d                   	pop    %ebp
  8020db:	c3                   	ret    

008020dc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020dc:	55                   	push   %ebp
  8020dd:	89 e5                	mov    %esp,%ebp
  8020df:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020e2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020e7:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020ed:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020f3:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8020f9:	39 ca                	cmp    %ecx,%edx
  8020fb:	75 13                	jne    802110 <ipc_find_env+0x34>
			return envs[i].env_id;
  8020fd:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802108:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80210e:	eb 0f                	jmp    80211f <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802110:	83 c0 01             	add    $0x1,%eax
  802113:	3d 00 04 00 00       	cmp    $0x400,%eax
  802118:	75 cd                	jne    8020e7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80211a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80211f:	5d                   	pop    %ebp
  802120:	c3                   	ret    

00802121 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802121:	55                   	push   %ebp
  802122:	89 e5                	mov    %esp,%ebp
  802124:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802127:	89 d0                	mov    %edx,%eax
  802129:	c1 e8 16             	shr    $0x16,%eax
  80212c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802133:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802138:	f6 c1 01             	test   $0x1,%cl
  80213b:	74 1d                	je     80215a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80213d:	c1 ea 0c             	shr    $0xc,%edx
  802140:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802147:	f6 c2 01             	test   $0x1,%dl
  80214a:	74 0e                	je     80215a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80214c:	c1 ea 0c             	shr    $0xc,%edx
  80214f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802156:	ef 
  802157:	0f b7 c0             	movzwl %ax,%eax
}
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__udivdi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80216b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80216f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 f6                	test   %esi,%esi
  802179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80217d:	89 ca                	mov    %ecx,%edx
  80217f:	89 f8                	mov    %edi,%eax
  802181:	75 3d                	jne    8021c0 <__udivdi3+0x60>
  802183:	39 cf                	cmp    %ecx,%edi
  802185:	0f 87 c5 00 00 00    	ja     802250 <__udivdi3+0xf0>
  80218b:	85 ff                	test   %edi,%edi
  80218d:	89 fd                	mov    %edi,%ebp
  80218f:	75 0b                	jne    80219c <__udivdi3+0x3c>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	31 d2                	xor    %edx,%edx
  802198:	f7 f7                	div    %edi
  80219a:	89 c5                	mov    %eax,%ebp
  80219c:	89 c8                	mov    %ecx,%eax
  80219e:	31 d2                	xor    %edx,%edx
  8021a0:	f7 f5                	div    %ebp
  8021a2:	89 c1                	mov    %eax,%ecx
  8021a4:	89 d8                	mov    %ebx,%eax
  8021a6:	89 cf                	mov    %ecx,%edi
  8021a8:	f7 f5                	div    %ebp
  8021aa:	89 c3                	mov    %eax,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	39 ce                	cmp    %ecx,%esi
  8021c2:	77 74                	ja     802238 <__udivdi3+0xd8>
  8021c4:	0f bd fe             	bsr    %esi,%edi
  8021c7:	83 f7 1f             	xor    $0x1f,%edi
  8021ca:	0f 84 98 00 00 00    	je     802268 <__udivdi3+0x108>
  8021d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	89 c5                	mov    %eax,%ebp
  8021d9:	29 fb                	sub    %edi,%ebx
  8021db:	d3 e6                	shl    %cl,%esi
  8021dd:	89 d9                	mov    %ebx,%ecx
  8021df:	d3 ed                	shr    %cl,%ebp
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	d3 e0                	shl    %cl,%eax
  8021e5:	09 ee                	or     %ebp,%esi
  8021e7:	89 d9                	mov    %ebx,%ecx
  8021e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ed:	89 d5                	mov    %edx,%ebp
  8021ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021f3:	d3 ed                	shr    %cl,%ebp
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	d3 e2                	shl    %cl,%edx
  8021f9:	89 d9                	mov    %ebx,%ecx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	09 c2                	or     %eax,%edx
  8021ff:	89 d0                	mov    %edx,%eax
  802201:	89 ea                	mov    %ebp,%edx
  802203:	f7 f6                	div    %esi
  802205:	89 d5                	mov    %edx,%ebp
  802207:	89 c3                	mov    %eax,%ebx
  802209:	f7 64 24 0c          	mull   0xc(%esp)
  80220d:	39 d5                	cmp    %edx,%ebp
  80220f:	72 10                	jb     802221 <__udivdi3+0xc1>
  802211:	8b 74 24 08          	mov    0x8(%esp),%esi
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e6                	shl    %cl,%esi
  802219:	39 c6                	cmp    %eax,%esi
  80221b:	73 07                	jae    802224 <__udivdi3+0xc4>
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	75 03                	jne    802224 <__udivdi3+0xc4>
  802221:	83 eb 01             	sub    $0x1,%ebx
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 d8                	mov    %ebx,%eax
  802228:	89 fa                	mov    %edi,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	31 ff                	xor    %edi,%edi
  80223a:	31 db                	xor    %ebx,%ebx
  80223c:	89 d8                	mov    %ebx,%eax
  80223e:	89 fa                	mov    %edi,%edx
  802240:	83 c4 1c             	add    $0x1c,%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	90                   	nop
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 d8                	mov    %ebx,%eax
  802252:	f7 f7                	div    %edi
  802254:	31 ff                	xor    %edi,%edi
  802256:	89 c3                	mov    %eax,%ebx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 fa                	mov    %edi,%edx
  80225c:	83 c4 1c             	add    $0x1c,%esp
  80225f:	5b                   	pop    %ebx
  802260:	5e                   	pop    %esi
  802261:	5f                   	pop    %edi
  802262:	5d                   	pop    %ebp
  802263:	c3                   	ret    
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	39 ce                	cmp    %ecx,%esi
  80226a:	72 0c                	jb     802278 <__udivdi3+0x118>
  80226c:	31 db                	xor    %ebx,%ebx
  80226e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802272:	0f 87 34 ff ff ff    	ja     8021ac <__udivdi3+0x4c>
  802278:	bb 01 00 00 00       	mov    $0x1,%ebx
  80227d:	e9 2a ff ff ff       	jmp    8021ac <__udivdi3+0x4c>
  802282:	66 90                	xchg   %ax,%ax
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	53                   	push   %ebx
  802294:	83 ec 1c             	sub    $0x1c,%esp
  802297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80229b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80229f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022a7:	85 d2                	test   %edx,%edx
  8022a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b1:	89 f3                	mov    %esi,%ebx
  8022b3:	89 3c 24             	mov    %edi,(%esp)
  8022b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ba:	75 1c                	jne    8022d8 <__umoddi3+0x48>
  8022bc:	39 f7                	cmp    %esi,%edi
  8022be:	76 50                	jbe    802310 <__umoddi3+0x80>
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	f7 f7                	div    %edi
  8022c6:	89 d0                	mov    %edx,%eax
  8022c8:	31 d2                	xor    %edx,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	89 d0                	mov    %edx,%eax
  8022dc:	77 52                	ja     802330 <__umoddi3+0xa0>
  8022de:	0f bd ea             	bsr    %edx,%ebp
  8022e1:	83 f5 1f             	xor    $0x1f,%ebp
  8022e4:	75 5a                	jne    802340 <__umoddi3+0xb0>
  8022e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ea:	0f 82 e0 00 00 00    	jb     8023d0 <__umoddi3+0x140>
  8022f0:	39 0c 24             	cmp    %ecx,(%esp)
  8022f3:	0f 86 d7 00 00 00    	jbe    8023d0 <__umoddi3+0x140>
  8022f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	85 ff                	test   %edi,%edi
  802312:	89 fd                	mov    %edi,%ebp
  802314:	75 0b                	jne    802321 <__umoddi3+0x91>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f7                	div    %edi
  80231f:	89 c5                	mov    %eax,%ebp
  802321:	89 f0                	mov    %esi,%eax
  802323:	31 d2                	xor    %edx,%edx
  802325:	f7 f5                	div    %ebp
  802327:	89 c8                	mov    %ecx,%eax
  802329:	f7 f5                	div    %ebp
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	eb 99                	jmp    8022c8 <__umoddi3+0x38>
  80232f:	90                   	nop
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	83 c4 1c             	add    $0x1c,%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5f                   	pop    %edi
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	8b 34 24             	mov    (%esp),%esi
  802343:	bf 20 00 00 00       	mov    $0x20,%edi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	29 ef                	sub    %ebp,%edi
  80234c:	d3 e0                	shl    %cl,%eax
  80234e:	89 f9                	mov    %edi,%ecx
  802350:	89 f2                	mov    %esi,%edx
  802352:	d3 ea                	shr    %cl,%edx
  802354:	89 e9                	mov    %ebp,%ecx
  802356:	09 c2                	or     %eax,%edx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 14 24             	mov    %edx,(%esp)
  80235d:	89 f2                	mov    %esi,%edx
  80235f:	d3 e2                	shl    %cl,%edx
  802361:	89 f9                	mov    %edi,%ecx
  802363:	89 54 24 04          	mov    %edx,0x4(%esp)
  802367:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	89 c6                	mov    %eax,%esi
  802371:	d3 e3                	shl    %cl,%ebx
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 d0                	mov    %edx,%eax
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	09 d8                	or     %ebx,%eax
  80237d:	89 d3                	mov    %edx,%ebx
  80237f:	89 f2                	mov    %esi,%edx
  802381:	f7 34 24             	divl   (%esp)
  802384:	89 d6                	mov    %edx,%esi
  802386:	d3 e3                	shl    %cl,%ebx
  802388:	f7 64 24 04          	mull   0x4(%esp)
  80238c:	39 d6                	cmp    %edx,%esi
  80238e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802392:	89 d1                	mov    %edx,%ecx
  802394:	89 c3                	mov    %eax,%ebx
  802396:	72 08                	jb     8023a0 <__umoddi3+0x110>
  802398:	75 11                	jne    8023ab <__umoddi3+0x11b>
  80239a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80239e:	73 0b                	jae    8023ab <__umoddi3+0x11b>
  8023a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023a4:	1b 14 24             	sbb    (%esp),%edx
  8023a7:	89 d1                	mov    %edx,%ecx
  8023a9:	89 c3                	mov    %eax,%ebx
  8023ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023af:	29 da                	sub    %ebx,%edx
  8023b1:	19 ce                	sbb    %ecx,%esi
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 f0                	mov    %esi,%eax
  8023b7:	d3 e0                	shl    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	d3 ea                	shr    %cl,%edx
  8023bd:	89 e9                	mov    %ebp,%ecx
  8023bf:	d3 ee                	shr    %cl,%esi
  8023c1:	09 d0                	or     %edx,%eax
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	83 c4 1c             	add    $0x1c,%esp
  8023c8:	5b                   	pop    %ebx
  8023c9:	5e                   	pop    %esi
  8023ca:	5f                   	pop    %edi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    
  8023cd:	8d 76 00             	lea    0x0(%esi),%esi
  8023d0:	29 f9                	sub    %edi,%ecx
  8023d2:	19 d6                	sbb    %edx,%esi
  8023d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023dc:	e9 18 ff ff ff       	jmp    8022f9 <__umoddi3+0x69>
