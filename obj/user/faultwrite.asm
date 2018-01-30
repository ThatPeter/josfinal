
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
  8000b1:	e8 e8 09 00 00       	call   800a9e <close_all>
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
  800136:	e8 94 14 00 00       	call   8015cf <_panic>

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
  8001b7:	e8 13 14 00 00       	call   8015cf <_panic>

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
  8001f9:	e8 d1 13 00 00       	call   8015cf <_panic>

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
  80023b:	e8 8f 13 00 00       	call   8015cf <_panic>

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
  80027d:	e8 4d 13 00 00       	call   8015cf <_panic>

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
  8002bf:	e8 0b 13 00 00       	call   8015cf <_panic>
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
  800301:	e8 c9 12 00 00       	call   8015cf <_panic>

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
  800365:	e8 65 12 00 00       	call   8015cf <_panic>

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
  800404:	e8 c6 11 00 00       	call   8015cf <_panic>
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
  80042e:	e8 9c 11 00 00       	call   8015cf <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800433:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800439:	83 ec 04             	sub    $0x4,%esp
  80043c:	68 00 10 00 00       	push   $0x1000
  800441:	53                   	push   %ebx
  800442:	68 00 f0 7f 00       	push   $0x7ff000
  800447:	e8 db 19 00 00       	call   801e27 <memcpy>

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
  800476:	e8 54 11 00 00       	call   8015cf <_panic>
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
  80049e:	e8 2c 11 00 00       	call   8015cf <_panic>
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
  8004b6:	e8 b9 1a 00 00       	call   801f74 <set_pgfault_handler>
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
  8004de:	e8 ec 10 00 00       	call   8015cf <_panic>
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
  800597:	e8 33 10 00 00       	call   8015cf <_panic>
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
  8005dc:	e8 ee 0f 00 00       	call   8015cf <_panic>
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
  80060a:	e8 c0 0f 00 00       	call   8015cf <_panic>
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
  800634:	e8 96 0f 00 00       	call   8015cf <_panic>
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
  8006f4:	e8 d6 0e 00 00       	call   8015cf <_panic>
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
  80075a:	e8 70 0e 00 00       	call   8015cf <_panic>
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
  80076b:	56                   	push   %esi
  80076c:	53                   	push   %ebx
  80076d:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800770:	b8 01 00 00 00       	mov    $0x1,%eax
  800775:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800778:	85 c0                	test   %eax,%eax
  80077a:	74 4a                	je     8007c6 <mutex_lock+0x5e>
  80077c:	8b 73 04             	mov    0x4(%ebx),%esi
  80077f:	83 3e 00             	cmpl   $0x0,(%esi)
  800782:	75 42                	jne    8007c6 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  800784:	e8 ba f9 ff ff       	call   800143 <sys_getenvid>
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	56                   	push   %esi
  80078d:	50                   	push   %eax
  80078e:	e8 32 ff ff ff       	call   8006c5 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800793:	e8 ab f9 ff ff       	call   800143 <sys_getenvid>
  800798:	83 c4 08             	add    $0x8,%esp
  80079b:	6a 04                	push   $0x4
  80079d:	50                   	push   %eax
  80079e:	e8 a5 fa ff ff       	call   800248 <sys_env_set_status>

		if (r < 0) {
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	79 15                	jns    8007bf <mutex_lock+0x57>
			panic("%e\n", r);
  8007aa:	50                   	push   %eax
  8007ab:	68 bd 24 80 00       	push   $0x8024bd
  8007b0:	68 02 01 00 00       	push   $0x102
  8007b5:	68 45 24 80 00       	push   $0x802445
  8007ba:	e8 10 0e 00 00       	call   8015cf <_panic>
		}
		sys_yield();
  8007bf:	e8 9e f9 ff ff       	call   800162 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007c4:	eb 08                	jmp    8007ce <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8007c6:	e8 78 f9 ff ff       	call   800143 <sys_getenvid>
  8007cb:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8007ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007d1:	5b                   	pop    %ebx
  8007d2:	5e                   	pop    %esi
  8007d3:	5d                   	pop    %ebp
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
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e4:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8007e7:	8b 43 04             	mov    0x4(%ebx),%eax
  8007ea:	83 38 00             	cmpl   $0x0,(%eax)
  8007ed:	74 33                	je     800822 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8007ef:	83 ec 0c             	sub    $0xc,%esp
  8007f2:	50                   	push   %eax
  8007f3:	e8 41 ff ff ff       	call   800739 <queue_pop>
  8007f8:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8007fb:	83 c4 08             	add    $0x8,%esp
  8007fe:	6a 02                	push   $0x2
  800800:	50                   	push   %eax
  800801:	e8 42 fa ff ff       	call   800248 <sys_env_set_status>
		if (r < 0) {
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	85 c0                	test   %eax,%eax
  80080b:	79 15                	jns    800822 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80080d:	50                   	push   %eax
  80080e:	68 bd 24 80 00       	push   $0x8024bd
  800813:	68 16 01 00 00       	push   $0x116
  800818:	68 45 24 80 00       	push   $0x802445
  80081d:	e8 ad 0d 00 00       	call   8015cf <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  800822:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	83 ec 04             	sub    $0x4,%esp
  80082e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800831:	e8 0d f9 ff ff       	call   800143 <sys_getenvid>
  800836:	83 ec 04             	sub    $0x4,%esp
  800839:	6a 07                	push   $0x7
  80083b:	53                   	push   %ebx
  80083c:	50                   	push   %eax
  80083d:	e8 3f f9 ff ff       	call   800181 <sys_page_alloc>
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	85 c0                	test   %eax,%eax
  800847:	79 15                	jns    80085e <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800849:	50                   	push   %eax
  80084a:	68 a8 24 80 00       	push   $0x8024a8
  80084f:	68 22 01 00 00       	push   $0x122
  800854:	68 45 24 80 00       	push   $0x802445
  800859:	e8 71 0d 00 00       	call   8015cf <_panic>
	}	
	mtx->locked = 0;
  80085e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  800864:	8b 43 04             	mov    0x4(%ebx),%eax
  800867:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80086d:	8b 43 04             	mov    0x4(%ebx),%eax
  800870:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800877:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80087e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	83 ec 04             	sub    $0x4,%esp
  80088a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  80088d:	eb 21                	jmp    8008b0 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  80088f:	83 ec 0c             	sub    $0xc,%esp
  800892:	50                   	push   %eax
  800893:	e8 a1 fe ff ff       	call   800739 <queue_pop>
  800898:	83 c4 08             	add    $0x8,%esp
  80089b:	6a 02                	push   $0x2
  80089d:	50                   	push   %eax
  80089e:	e8 a5 f9 ff ff       	call   800248 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  8008a3:	8b 43 04             	mov    0x4(%ebx),%eax
  8008a6:	8b 10                	mov    (%eax),%edx
  8008a8:	8b 52 04             	mov    0x4(%edx),%edx
  8008ab:	89 10                	mov    %edx,(%eax)
  8008ad:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8008b0:	8b 43 04             	mov    0x4(%ebx),%eax
  8008b3:	83 38 00             	cmpl   $0x0,(%eax)
  8008b6:	75 d7                	jne    80088f <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008b8:	83 ec 04             	sub    $0x4,%esp
  8008bb:	68 00 10 00 00       	push   $0x1000
  8008c0:	6a 00                	push   $0x0
  8008c2:	53                   	push   %ebx
  8008c3:	e8 aa 14 00 00       	call   801d72 <memset>
	mtx = NULL;
}
  8008c8:	83 c4 10             	add    $0x10,%esp
  8008cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8008db:	c1 e8 0c             	shr    $0xc,%eax
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8008eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800902:	89 c2                	mov    %eax,%edx
  800904:	c1 ea 16             	shr    $0x16,%edx
  800907:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80090e:	f6 c2 01             	test   $0x1,%dl
  800911:	74 11                	je     800924 <fd_alloc+0x2d>
  800913:	89 c2                	mov    %eax,%edx
  800915:	c1 ea 0c             	shr    $0xc,%edx
  800918:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80091f:	f6 c2 01             	test   $0x1,%dl
  800922:	75 09                	jne    80092d <fd_alloc+0x36>
			*fd_store = fd;
  800924:	89 01                	mov    %eax,(%ecx)
			return 0;
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	eb 17                	jmp    800944 <fd_alloc+0x4d>
  80092d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800932:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800937:	75 c9                	jne    800902 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800939:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80093f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80094c:	83 f8 1f             	cmp    $0x1f,%eax
  80094f:	77 36                	ja     800987 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800951:	c1 e0 0c             	shl    $0xc,%eax
  800954:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800959:	89 c2                	mov    %eax,%edx
  80095b:	c1 ea 16             	shr    $0x16,%edx
  80095e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800965:	f6 c2 01             	test   $0x1,%dl
  800968:	74 24                	je     80098e <fd_lookup+0x48>
  80096a:	89 c2                	mov    %eax,%edx
  80096c:	c1 ea 0c             	shr    $0xc,%edx
  80096f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800976:	f6 c2 01             	test   $0x1,%dl
  800979:	74 1a                	je     800995 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80097b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097e:	89 02                	mov    %eax,(%edx)
	return 0;
  800980:	b8 00 00 00 00       	mov    $0x0,%eax
  800985:	eb 13                	jmp    80099a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800987:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80098c:	eb 0c                	jmp    80099a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80098e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800993:	eb 05                	jmp    80099a <fd_lookup+0x54>
  800995:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 08             	sub    $0x8,%esp
  8009a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a5:	ba 40 25 80 00       	mov    $0x802540,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009aa:	eb 13                	jmp    8009bf <dev_lookup+0x23>
  8009ac:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009af:	39 08                	cmp    %ecx,(%eax)
  8009b1:	75 0c                	jne    8009bf <dev_lookup+0x23>
			*dev = devtab[i];
  8009b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bd:	eb 31                	jmp    8009f0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009bf:	8b 02                	mov    (%edx),%eax
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	75 e7                	jne    8009ac <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009c5:	a1 04 40 80 00       	mov    0x804004,%eax
  8009ca:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009d0:	83 ec 04             	sub    $0x4,%esp
  8009d3:	51                   	push   %ecx
  8009d4:	50                   	push   %eax
  8009d5:	68 c4 24 80 00       	push   $0x8024c4
  8009da:	e8 c9 0c 00 00       	call   8016a8 <cprintf>
	*dev = 0;
  8009df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009e8:	83 c4 10             	add    $0x10,%esp
  8009eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009f0:	c9                   	leave  
  8009f1:	c3                   	ret    

008009f2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	83 ec 10             	sub    $0x10,%esp
  8009fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a03:	50                   	push   %eax
  800a04:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a0a:	c1 e8 0c             	shr    $0xc,%eax
  800a0d:	50                   	push   %eax
  800a0e:	e8 33 ff ff ff       	call   800946 <fd_lookup>
  800a13:	83 c4 08             	add    $0x8,%esp
  800a16:	85 c0                	test   %eax,%eax
  800a18:	78 05                	js     800a1f <fd_close+0x2d>
	    || fd != fd2)
  800a1a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a1d:	74 0c                	je     800a2b <fd_close+0x39>
		return (must_exist ? r : 0);
  800a1f:	84 db                	test   %bl,%bl
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	0f 44 c2             	cmove  %edx,%eax
  800a29:	eb 41                	jmp    800a6c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a2b:	83 ec 08             	sub    $0x8,%esp
  800a2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a31:	50                   	push   %eax
  800a32:	ff 36                	pushl  (%esi)
  800a34:	e8 63 ff ff ff       	call   80099c <dev_lookup>
  800a39:	89 c3                	mov    %eax,%ebx
  800a3b:	83 c4 10             	add    $0x10,%esp
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	78 1a                	js     800a5c <fd_close+0x6a>
		if (dev->dev_close)
  800a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a45:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a48:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	74 0b                	je     800a5c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a51:	83 ec 0c             	sub    $0xc,%esp
  800a54:	56                   	push   %esi
  800a55:	ff d0                	call   *%eax
  800a57:	89 c3                	mov    %eax,%ebx
  800a59:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a5c:	83 ec 08             	sub    $0x8,%esp
  800a5f:	56                   	push   %esi
  800a60:	6a 00                	push   $0x0
  800a62:	e8 9f f7 ff ff       	call   800206 <sys_page_unmap>
	return r;
  800a67:	83 c4 10             	add    $0x10,%esp
  800a6a:	89 d8                	mov    %ebx,%eax
}
  800a6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a7c:	50                   	push   %eax
  800a7d:	ff 75 08             	pushl  0x8(%ebp)
  800a80:	e8 c1 fe ff ff       	call   800946 <fd_lookup>
  800a85:	83 c4 08             	add    $0x8,%esp
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	78 10                	js     800a9c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a8c:	83 ec 08             	sub    $0x8,%esp
  800a8f:	6a 01                	push   $0x1
  800a91:	ff 75 f4             	pushl  -0xc(%ebp)
  800a94:	e8 59 ff ff ff       	call   8009f2 <fd_close>
  800a99:	83 c4 10             	add    $0x10,%esp
}
  800a9c:	c9                   	leave  
  800a9d:	c3                   	ret    

00800a9e <close_all>:

void
close_all(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	53                   	push   %ebx
  800aa2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800aa5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800aaa:	83 ec 0c             	sub    $0xc,%esp
  800aad:	53                   	push   %ebx
  800aae:	e8 c0 ff ff ff       	call   800a73 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ab3:	83 c3 01             	add    $0x1,%ebx
  800ab6:	83 c4 10             	add    $0x10,%esp
  800ab9:	83 fb 20             	cmp    $0x20,%ebx
  800abc:	75 ec                	jne    800aaa <close_all+0xc>
		close(i);
}
  800abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    

00800ac3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	57                   	push   %edi
  800ac7:	56                   	push   %esi
  800ac8:	53                   	push   %ebx
  800ac9:	83 ec 2c             	sub    $0x2c,%esp
  800acc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800acf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ad2:	50                   	push   %eax
  800ad3:	ff 75 08             	pushl  0x8(%ebp)
  800ad6:	e8 6b fe ff ff       	call   800946 <fd_lookup>
  800adb:	83 c4 08             	add    $0x8,%esp
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	0f 88 c1 00 00 00    	js     800ba7 <dup+0xe4>
		return r;
	close(newfdnum);
  800ae6:	83 ec 0c             	sub    $0xc,%esp
  800ae9:	56                   	push   %esi
  800aea:	e8 84 ff ff ff       	call   800a73 <close>

	newfd = INDEX2FD(newfdnum);
  800aef:	89 f3                	mov    %esi,%ebx
  800af1:	c1 e3 0c             	shl    $0xc,%ebx
  800af4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800afa:	83 c4 04             	add    $0x4,%esp
  800afd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b00:	e8 db fd ff ff       	call   8008e0 <fd2data>
  800b05:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b07:	89 1c 24             	mov    %ebx,(%esp)
  800b0a:	e8 d1 fd ff ff       	call   8008e0 <fd2data>
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b15:	89 f8                	mov    %edi,%eax
  800b17:	c1 e8 16             	shr    $0x16,%eax
  800b1a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b21:	a8 01                	test   $0x1,%al
  800b23:	74 37                	je     800b5c <dup+0x99>
  800b25:	89 f8                	mov    %edi,%eax
  800b27:	c1 e8 0c             	shr    $0xc,%eax
  800b2a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b31:	f6 c2 01             	test   $0x1,%dl
  800b34:	74 26                	je     800b5c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b36:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	25 07 0e 00 00       	and    $0xe07,%eax
  800b45:	50                   	push   %eax
  800b46:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b49:	6a 00                	push   $0x0
  800b4b:	57                   	push   %edi
  800b4c:	6a 00                	push   $0x0
  800b4e:	e8 71 f6 ff ff       	call   8001c4 <sys_page_map>
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	83 c4 20             	add    $0x20,%esp
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	78 2e                	js     800b8a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b5c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	c1 e8 0c             	shr    $0xc,%eax
  800b64:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b6b:	83 ec 0c             	sub    $0xc,%esp
  800b6e:	25 07 0e 00 00       	and    $0xe07,%eax
  800b73:	50                   	push   %eax
  800b74:	53                   	push   %ebx
  800b75:	6a 00                	push   $0x0
  800b77:	52                   	push   %edx
  800b78:	6a 00                	push   $0x0
  800b7a:	e8 45 f6 ff ff       	call   8001c4 <sys_page_map>
  800b7f:	89 c7                	mov    %eax,%edi
  800b81:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b84:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b86:	85 ff                	test   %edi,%edi
  800b88:	79 1d                	jns    800ba7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b8a:	83 ec 08             	sub    $0x8,%esp
  800b8d:	53                   	push   %ebx
  800b8e:	6a 00                	push   $0x0
  800b90:	e8 71 f6 ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b95:	83 c4 08             	add    $0x8,%esp
  800b98:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b9b:	6a 00                	push   $0x0
  800b9d:	e8 64 f6 ff ff       	call   800206 <sys_page_unmap>
	return r;
  800ba2:	83 c4 10             	add    $0x10,%esp
  800ba5:	89 f8                	mov    %edi,%eax
}
  800ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	53                   	push   %ebx
  800bb3:	83 ec 14             	sub    $0x14,%esp
  800bb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bbc:	50                   	push   %eax
  800bbd:	53                   	push   %ebx
  800bbe:	e8 83 fd ff ff       	call   800946 <fd_lookup>
  800bc3:	83 c4 08             	add    $0x8,%esp
  800bc6:	89 c2                	mov    %eax,%edx
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	78 70                	js     800c3c <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bcc:	83 ec 08             	sub    $0x8,%esp
  800bcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bd2:	50                   	push   %eax
  800bd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd6:	ff 30                	pushl  (%eax)
  800bd8:	e8 bf fd ff ff       	call   80099c <dev_lookup>
  800bdd:	83 c4 10             	add    $0x10,%esp
  800be0:	85 c0                	test   %eax,%eax
  800be2:	78 4f                	js     800c33 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800be4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800be7:	8b 42 08             	mov    0x8(%edx),%eax
  800bea:	83 e0 03             	and    $0x3,%eax
  800bed:	83 f8 01             	cmp    $0x1,%eax
  800bf0:	75 24                	jne    800c16 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bf2:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800bfd:	83 ec 04             	sub    $0x4,%esp
  800c00:	53                   	push   %ebx
  800c01:	50                   	push   %eax
  800c02:	68 05 25 80 00       	push   $0x802505
  800c07:	e8 9c 0a 00 00       	call   8016a8 <cprintf>
		return -E_INVAL;
  800c0c:	83 c4 10             	add    $0x10,%esp
  800c0f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c14:	eb 26                	jmp    800c3c <read+0x8d>
	}
	if (!dev->dev_read)
  800c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c19:	8b 40 08             	mov    0x8(%eax),%eax
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	74 17                	je     800c37 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c20:	83 ec 04             	sub    $0x4,%esp
  800c23:	ff 75 10             	pushl  0x10(%ebp)
  800c26:	ff 75 0c             	pushl  0xc(%ebp)
  800c29:	52                   	push   %edx
  800c2a:	ff d0                	call   *%eax
  800c2c:	89 c2                	mov    %eax,%edx
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	eb 09                	jmp    800c3c <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c33:	89 c2                	mov    %eax,%edx
  800c35:	eb 05                	jmp    800c3c <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c37:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c3c:	89 d0                	mov    %edx,%eax
  800c3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c4f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c52:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c57:	eb 21                	jmp    800c7a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c59:	83 ec 04             	sub    $0x4,%esp
  800c5c:	89 f0                	mov    %esi,%eax
  800c5e:	29 d8                	sub    %ebx,%eax
  800c60:	50                   	push   %eax
  800c61:	89 d8                	mov    %ebx,%eax
  800c63:	03 45 0c             	add    0xc(%ebp),%eax
  800c66:	50                   	push   %eax
  800c67:	57                   	push   %edi
  800c68:	e8 42 ff ff ff       	call   800baf <read>
		if (m < 0)
  800c6d:	83 c4 10             	add    $0x10,%esp
  800c70:	85 c0                	test   %eax,%eax
  800c72:	78 10                	js     800c84 <readn+0x41>
			return m;
		if (m == 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	74 0a                	je     800c82 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c78:	01 c3                	add    %eax,%ebx
  800c7a:	39 f3                	cmp    %esi,%ebx
  800c7c:	72 db                	jb     800c59 <readn+0x16>
  800c7e:	89 d8                	mov    %ebx,%eax
  800c80:	eb 02                	jmp    800c84 <readn+0x41>
  800c82:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 14             	sub    $0x14,%esp
  800c93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c96:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c99:	50                   	push   %eax
  800c9a:	53                   	push   %ebx
  800c9b:	e8 a6 fc ff ff       	call   800946 <fd_lookup>
  800ca0:	83 c4 08             	add    $0x8,%esp
  800ca3:	89 c2                	mov    %eax,%edx
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	78 6b                	js     800d14 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ca9:	83 ec 08             	sub    $0x8,%esp
  800cac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800caf:	50                   	push   %eax
  800cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cb3:	ff 30                	pushl  (%eax)
  800cb5:	e8 e2 fc ff ff       	call   80099c <dev_lookup>
  800cba:	83 c4 10             	add    $0x10,%esp
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	78 4a                	js     800d0b <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cc4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cc8:	75 24                	jne    800cee <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800cca:	a1 04 40 80 00       	mov    0x804004,%eax
  800ccf:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800cd5:	83 ec 04             	sub    $0x4,%esp
  800cd8:	53                   	push   %ebx
  800cd9:	50                   	push   %eax
  800cda:	68 21 25 80 00       	push   $0x802521
  800cdf:	e8 c4 09 00 00       	call   8016a8 <cprintf>
		return -E_INVAL;
  800ce4:	83 c4 10             	add    $0x10,%esp
  800ce7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800cec:	eb 26                	jmp    800d14 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800cee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cf1:	8b 52 0c             	mov    0xc(%edx),%edx
  800cf4:	85 d2                	test   %edx,%edx
  800cf6:	74 17                	je     800d0f <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800cf8:	83 ec 04             	sub    $0x4,%esp
  800cfb:	ff 75 10             	pushl  0x10(%ebp)
  800cfe:	ff 75 0c             	pushl  0xc(%ebp)
  800d01:	50                   	push   %eax
  800d02:	ff d2                	call   *%edx
  800d04:	89 c2                	mov    %eax,%edx
  800d06:	83 c4 10             	add    $0x10,%esp
  800d09:	eb 09                	jmp    800d14 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d0b:	89 c2                	mov    %eax,%edx
  800d0d:	eb 05                	jmp    800d14 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d0f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d14:	89 d0                	mov    %edx,%eax
  800d16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d19:	c9                   	leave  
  800d1a:	c3                   	ret    

00800d1b <seek>:

int
seek(int fdnum, off_t offset)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d21:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d24:	50                   	push   %eax
  800d25:	ff 75 08             	pushl  0x8(%ebp)
  800d28:	e8 19 fc ff ff       	call   800946 <fd_lookup>
  800d2d:	83 c4 08             	add    $0x8,%esp
  800d30:	85 c0                	test   %eax,%eax
  800d32:	78 0e                	js     800d42 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d34:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	53                   	push   %ebx
  800d48:	83 ec 14             	sub    $0x14,%esp
  800d4b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d51:	50                   	push   %eax
  800d52:	53                   	push   %ebx
  800d53:	e8 ee fb ff ff       	call   800946 <fd_lookup>
  800d58:	83 c4 08             	add    $0x8,%esp
  800d5b:	89 c2                	mov    %eax,%edx
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	78 68                	js     800dc9 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d61:	83 ec 08             	sub    $0x8,%esp
  800d64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d67:	50                   	push   %eax
  800d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d6b:	ff 30                	pushl  (%eax)
  800d6d:	e8 2a fc ff ff       	call   80099c <dev_lookup>
  800d72:	83 c4 10             	add    $0x10,%esp
  800d75:	85 c0                	test   %eax,%eax
  800d77:	78 47                	js     800dc0 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d7c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d80:	75 24                	jne    800da6 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d82:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d87:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d8d:	83 ec 04             	sub    $0x4,%esp
  800d90:	53                   	push   %ebx
  800d91:	50                   	push   %eax
  800d92:	68 e4 24 80 00       	push   $0x8024e4
  800d97:	e8 0c 09 00 00       	call   8016a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d9c:	83 c4 10             	add    $0x10,%esp
  800d9f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800da4:	eb 23                	jmp    800dc9 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800da6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800da9:	8b 52 18             	mov    0x18(%edx),%edx
  800dac:	85 d2                	test   %edx,%edx
  800dae:	74 14                	je     800dc4 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800db0:	83 ec 08             	sub    $0x8,%esp
  800db3:	ff 75 0c             	pushl  0xc(%ebp)
  800db6:	50                   	push   %eax
  800db7:	ff d2                	call   *%edx
  800db9:	89 c2                	mov    %eax,%edx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	eb 09                	jmp    800dc9 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dc0:	89 c2                	mov    %eax,%edx
  800dc2:	eb 05                	jmp    800dc9 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dc4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dc9:	89 d0                	mov    %edx,%eax
  800dcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 14             	sub    $0x14,%esp
  800dd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dda:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ddd:	50                   	push   %eax
  800dde:	ff 75 08             	pushl  0x8(%ebp)
  800de1:	e8 60 fb ff ff       	call   800946 <fd_lookup>
  800de6:	83 c4 08             	add    $0x8,%esp
  800de9:	89 c2                	mov    %eax,%edx
  800deb:	85 c0                	test   %eax,%eax
  800ded:	78 58                	js     800e47 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800def:	83 ec 08             	sub    $0x8,%esp
  800df2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800df5:	50                   	push   %eax
  800df6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df9:	ff 30                	pushl  (%eax)
  800dfb:	e8 9c fb ff ff       	call   80099c <dev_lookup>
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	78 37                	js     800e3e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e0e:	74 32                	je     800e42 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e10:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e13:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e1a:	00 00 00 
	stat->st_isdir = 0;
  800e1d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e24:	00 00 00 
	stat->st_dev = dev;
  800e27:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e2d:	83 ec 08             	sub    $0x8,%esp
  800e30:	53                   	push   %ebx
  800e31:	ff 75 f0             	pushl  -0x10(%ebp)
  800e34:	ff 50 14             	call   *0x14(%eax)
  800e37:	89 c2                	mov    %eax,%edx
  800e39:	83 c4 10             	add    $0x10,%esp
  800e3c:	eb 09                	jmp    800e47 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e3e:	89 c2                	mov    %eax,%edx
  800e40:	eb 05                	jmp    800e47 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e42:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e47:	89 d0                	mov    %edx,%eax
  800e49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4c:	c9                   	leave  
  800e4d:	c3                   	ret    

00800e4e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	6a 00                	push   $0x0
  800e58:	ff 75 08             	pushl  0x8(%ebp)
  800e5b:	e8 e3 01 00 00       	call   801043 <open>
  800e60:	89 c3                	mov    %eax,%ebx
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	78 1b                	js     800e84 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e69:	83 ec 08             	sub    $0x8,%esp
  800e6c:	ff 75 0c             	pushl  0xc(%ebp)
  800e6f:	50                   	push   %eax
  800e70:	e8 5b ff ff ff       	call   800dd0 <fstat>
  800e75:	89 c6                	mov    %eax,%esi
	close(fd);
  800e77:	89 1c 24             	mov    %ebx,(%esp)
  800e7a:	e8 f4 fb ff ff       	call   800a73 <close>
	return r;
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	89 f0                	mov    %esi,%eax
}
  800e84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	56                   	push   %esi
  800e8f:	53                   	push   %ebx
  800e90:	89 c6                	mov    %eax,%esi
  800e92:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e94:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e9b:	75 12                	jne    800eaf <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e9d:	83 ec 0c             	sub    $0xc,%esp
  800ea0:	6a 01                	push   $0x1
  800ea2:	e8 39 12 00 00       	call   8020e0 <ipc_find_env>
  800ea7:	a3 00 40 80 00       	mov    %eax,0x804000
  800eac:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800eaf:	6a 07                	push   $0x7
  800eb1:	68 00 50 80 00       	push   $0x805000
  800eb6:	56                   	push   %esi
  800eb7:	ff 35 00 40 80 00    	pushl  0x804000
  800ebd:	e8 bc 11 00 00       	call   80207e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ec2:	83 c4 0c             	add    $0xc,%esp
  800ec5:	6a 00                	push   $0x0
  800ec7:	53                   	push   %ebx
  800ec8:	6a 00                	push   $0x0
  800eca:	e8 34 11 00 00       	call   802003 <ipc_recv>
}
  800ecf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed2:	5b                   	pop    %ebx
  800ed3:	5e                   	pop    %esi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800edc:	8b 45 08             	mov    0x8(%ebp),%eax
  800edf:	8b 40 0c             	mov    0xc(%eax),%eax
  800ee2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eea:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800eef:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef4:	b8 02 00 00 00       	mov    $0x2,%eax
  800ef9:	e8 8d ff ff ff       	call   800e8b <fsipc>
}
  800efe:	c9                   	leave  
  800eff:	c3                   	ret    

00800f00 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f06:	8b 45 08             	mov    0x8(%ebp),%eax
  800f09:	8b 40 0c             	mov    0xc(%eax),%eax
  800f0c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f11:	ba 00 00 00 00       	mov    $0x0,%edx
  800f16:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1b:	e8 6b ff ff ff       	call   800e8b <fsipc>
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	53                   	push   %ebx
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2f:	8b 40 0c             	mov    0xc(%eax),%eax
  800f32:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f37:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3c:	b8 05 00 00 00       	mov    $0x5,%eax
  800f41:	e8 45 ff ff ff       	call   800e8b <fsipc>
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 2c                	js     800f76 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f4a:	83 ec 08             	sub    $0x8,%esp
  800f4d:	68 00 50 80 00       	push   $0x805000
  800f52:	53                   	push   %ebx
  800f53:	e8 d5 0c 00 00       	call   801c2d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f58:	a1 80 50 80 00       	mov    0x805080,%eax
  800f5d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f63:	a1 84 50 80 00       	mov    0x805084,%eax
  800f68:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f84:	8b 55 08             	mov    0x8(%ebp),%edx
  800f87:	8b 52 0c             	mov    0xc(%edx),%edx
  800f8a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f90:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f95:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800f9a:	0f 47 c2             	cmova  %edx,%eax
  800f9d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800fa2:	50                   	push   %eax
  800fa3:	ff 75 0c             	pushl  0xc(%ebp)
  800fa6:	68 08 50 80 00       	push   $0x805008
  800fab:	e8 0f 0e 00 00       	call   801dbf <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb5:	b8 04 00 00 00       	mov    $0x4,%eax
  800fba:	e8 cc fe ff ff       	call   800e8b <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
  800fc6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcc:	8b 40 0c             	mov    0xc(%eax),%eax
  800fcf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fd4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fda:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe4:	e8 a2 fe ff ff       	call   800e8b <fsipc>
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 4b                	js     80103a <devfile_read+0x79>
		return r;
	assert(r <= n);
  800fef:	39 c6                	cmp    %eax,%esi
  800ff1:	73 16                	jae    801009 <devfile_read+0x48>
  800ff3:	68 50 25 80 00       	push   $0x802550
  800ff8:	68 57 25 80 00       	push   $0x802557
  800ffd:	6a 7c                	push   $0x7c
  800fff:	68 6c 25 80 00       	push   $0x80256c
  801004:	e8 c6 05 00 00       	call   8015cf <_panic>
	assert(r <= PGSIZE);
  801009:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80100e:	7e 16                	jle    801026 <devfile_read+0x65>
  801010:	68 77 25 80 00       	push   $0x802577
  801015:	68 57 25 80 00       	push   $0x802557
  80101a:	6a 7d                	push   $0x7d
  80101c:	68 6c 25 80 00       	push   $0x80256c
  801021:	e8 a9 05 00 00       	call   8015cf <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801026:	83 ec 04             	sub    $0x4,%esp
  801029:	50                   	push   %eax
  80102a:	68 00 50 80 00       	push   $0x805000
  80102f:	ff 75 0c             	pushl  0xc(%ebp)
  801032:	e8 88 0d 00 00       	call   801dbf <memmove>
	return r;
  801037:	83 c4 10             	add    $0x10,%esp
}
  80103a:	89 d8                	mov    %ebx,%eax
  80103c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103f:	5b                   	pop    %ebx
  801040:	5e                   	pop    %esi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	53                   	push   %ebx
  801047:	83 ec 20             	sub    $0x20,%esp
  80104a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80104d:	53                   	push   %ebx
  80104e:	e8 a1 0b 00 00       	call   801bf4 <strlen>
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80105b:	7f 67                	jg     8010c4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801063:	50                   	push   %eax
  801064:	e8 8e f8 ff ff       	call   8008f7 <fd_alloc>
  801069:	83 c4 10             	add    $0x10,%esp
		return r;
  80106c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80106e:	85 c0                	test   %eax,%eax
  801070:	78 57                	js     8010c9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801072:	83 ec 08             	sub    $0x8,%esp
  801075:	53                   	push   %ebx
  801076:	68 00 50 80 00       	push   $0x805000
  80107b:	e8 ad 0b 00 00       	call   801c2d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801080:	8b 45 0c             	mov    0xc(%ebp),%eax
  801083:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801088:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80108b:	b8 01 00 00 00       	mov    $0x1,%eax
  801090:	e8 f6 fd ff ff       	call   800e8b <fsipc>
  801095:	89 c3                	mov    %eax,%ebx
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	85 c0                	test   %eax,%eax
  80109c:	79 14                	jns    8010b2 <open+0x6f>
		fd_close(fd, 0);
  80109e:	83 ec 08             	sub    $0x8,%esp
  8010a1:	6a 00                	push   $0x0
  8010a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a6:	e8 47 f9 ff ff       	call   8009f2 <fd_close>
		return r;
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	89 da                	mov    %ebx,%edx
  8010b0:	eb 17                	jmp    8010c9 <open+0x86>
	}

	return fd2num(fd);
  8010b2:	83 ec 0c             	sub    $0xc,%esp
  8010b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b8:	e8 13 f8 ff ff       	call   8008d0 <fd2num>
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	eb 05                	jmp    8010c9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010c4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010c9:	89 d0                	mov    %edx,%eax
  8010cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010db:	b8 08 00 00 00       	mov    $0x8,%eax
  8010e0:	e8 a6 fd ff ff       	call   800e8b <fsipc>
}
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    

008010e7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	56                   	push   %esi
  8010eb:	53                   	push   %ebx
  8010ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010ef:	83 ec 0c             	sub    $0xc,%esp
  8010f2:	ff 75 08             	pushl  0x8(%ebp)
  8010f5:	e8 e6 f7 ff ff       	call   8008e0 <fd2data>
  8010fa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010fc:	83 c4 08             	add    $0x8,%esp
  8010ff:	68 83 25 80 00       	push   $0x802583
  801104:	53                   	push   %ebx
  801105:	e8 23 0b 00 00       	call   801c2d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80110a:	8b 46 04             	mov    0x4(%esi),%eax
  80110d:	2b 06                	sub    (%esi),%eax
  80110f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801115:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80111c:	00 00 00 
	stat->st_dev = &devpipe;
  80111f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801126:	30 80 00 
	return 0;
}
  801129:	b8 00 00 00 00       	mov    $0x0,%eax
  80112e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	53                   	push   %ebx
  801139:	83 ec 0c             	sub    $0xc,%esp
  80113c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80113f:	53                   	push   %ebx
  801140:	6a 00                	push   $0x0
  801142:	e8 bf f0 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801147:	89 1c 24             	mov    %ebx,(%esp)
  80114a:	e8 91 f7 ff ff       	call   8008e0 <fd2data>
  80114f:	83 c4 08             	add    $0x8,%esp
  801152:	50                   	push   %eax
  801153:	6a 00                	push   $0x0
  801155:	e8 ac f0 ff ff       	call   800206 <sys_page_unmap>
}
  80115a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    

0080115f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	57                   	push   %edi
  801163:	56                   	push   %esi
  801164:	53                   	push   %ebx
  801165:	83 ec 1c             	sub    $0x1c,%esp
  801168:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80116b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80116d:	a1 04 40 80 00       	mov    0x804004,%eax
  801172:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801178:	83 ec 0c             	sub    $0xc,%esp
  80117b:	ff 75 e0             	pushl  -0x20(%ebp)
  80117e:	e8 a2 0f 00 00       	call   802125 <pageref>
  801183:	89 c3                	mov    %eax,%ebx
  801185:	89 3c 24             	mov    %edi,(%esp)
  801188:	e8 98 0f 00 00       	call   802125 <pageref>
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	39 c3                	cmp    %eax,%ebx
  801192:	0f 94 c1             	sete   %cl
  801195:	0f b6 c9             	movzbl %cl,%ecx
  801198:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80119b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011a1:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011a7:	39 ce                	cmp    %ecx,%esi
  8011a9:	74 1e                	je     8011c9 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011ab:	39 c3                	cmp    %eax,%ebx
  8011ad:	75 be                	jne    80116d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011af:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b8:	50                   	push   %eax
  8011b9:	56                   	push   %esi
  8011ba:	68 8a 25 80 00       	push   $0x80258a
  8011bf:	e8 e4 04 00 00       	call   8016a8 <cprintf>
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	eb a4                	jmp    80116d <_pipeisclosed+0xe>
	}
}
  8011c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5f                   	pop    %edi
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    

008011d4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	57                   	push   %edi
  8011d8:	56                   	push   %esi
  8011d9:	53                   	push   %ebx
  8011da:	83 ec 28             	sub    $0x28,%esp
  8011dd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011e0:	56                   	push   %esi
  8011e1:	e8 fa f6 ff ff       	call   8008e0 <fd2data>
  8011e6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	bf 00 00 00 00       	mov    $0x0,%edi
  8011f0:	eb 4b                	jmp    80123d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011f2:	89 da                	mov    %ebx,%edx
  8011f4:	89 f0                	mov    %esi,%eax
  8011f6:	e8 64 ff ff ff       	call   80115f <_pipeisclosed>
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	75 48                	jne    801247 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011ff:	e8 5e ef ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801204:	8b 43 04             	mov    0x4(%ebx),%eax
  801207:	8b 0b                	mov    (%ebx),%ecx
  801209:	8d 51 20             	lea    0x20(%ecx),%edx
  80120c:	39 d0                	cmp    %edx,%eax
  80120e:	73 e2                	jae    8011f2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801213:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801217:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	c1 fa 1f             	sar    $0x1f,%edx
  80121f:	89 d1                	mov    %edx,%ecx
  801221:	c1 e9 1b             	shr    $0x1b,%ecx
  801224:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801227:	83 e2 1f             	and    $0x1f,%edx
  80122a:	29 ca                	sub    %ecx,%edx
  80122c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801230:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801234:	83 c0 01             	add    $0x1,%eax
  801237:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80123a:	83 c7 01             	add    $0x1,%edi
  80123d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801240:	75 c2                	jne    801204 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801242:	8b 45 10             	mov    0x10(%ebp),%eax
  801245:	eb 05                	jmp    80124c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801247:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80124c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124f:	5b                   	pop    %ebx
  801250:	5e                   	pop    %esi
  801251:	5f                   	pop    %edi
  801252:	5d                   	pop    %ebp
  801253:	c3                   	ret    

00801254 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	57                   	push   %edi
  801258:	56                   	push   %esi
  801259:	53                   	push   %ebx
  80125a:	83 ec 18             	sub    $0x18,%esp
  80125d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801260:	57                   	push   %edi
  801261:	e8 7a f6 ff ff       	call   8008e0 <fd2data>
  801266:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801270:	eb 3d                	jmp    8012af <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801272:	85 db                	test   %ebx,%ebx
  801274:	74 04                	je     80127a <devpipe_read+0x26>
				return i;
  801276:	89 d8                	mov    %ebx,%eax
  801278:	eb 44                	jmp    8012be <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80127a:	89 f2                	mov    %esi,%edx
  80127c:	89 f8                	mov    %edi,%eax
  80127e:	e8 dc fe ff ff       	call   80115f <_pipeisclosed>
  801283:	85 c0                	test   %eax,%eax
  801285:	75 32                	jne    8012b9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801287:	e8 d6 ee ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80128c:	8b 06                	mov    (%esi),%eax
  80128e:	3b 46 04             	cmp    0x4(%esi),%eax
  801291:	74 df                	je     801272 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801293:	99                   	cltd   
  801294:	c1 ea 1b             	shr    $0x1b,%edx
  801297:	01 d0                	add    %edx,%eax
  801299:	83 e0 1f             	and    $0x1f,%eax
  80129c:	29 d0                	sub    %edx,%eax
  80129e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8012a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012a9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012ac:	83 c3 01             	add    $0x1,%ebx
  8012af:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012b2:	75 d8                	jne    80128c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8012b7:	eb 05                	jmp    8012be <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5f                   	pop    %edi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	56                   	push   %esi
  8012ca:	53                   	push   %ebx
  8012cb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	e8 20 f6 ff ff       	call   8008f7 <fd_alloc>
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	0f 88 2c 01 00 00    	js     801410 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e4:	83 ec 04             	sub    $0x4,%esp
  8012e7:	68 07 04 00 00       	push   $0x407
  8012ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ef:	6a 00                	push   $0x0
  8012f1:	e8 8b ee ff ff       	call   800181 <sys_page_alloc>
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	0f 88 0d 01 00 00    	js     801410 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801303:	83 ec 0c             	sub    $0xc,%esp
  801306:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	e8 e8 f5 ff ff       	call   8008f7 <fd_alloc>
  80130f:	89 c3                	mov    %eax,%ebx
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	85 c0                	test   %eax,%eax
  801316:	0f 88 e2 00 00 00    	js     8013fe <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80131c:	83 ec 04             	sub    $0x4,%esp
  80131f:	68 07 04 00 00       	push   $0x407
  801324:	ff 75 f0             	pushl  -0x10(%ebp)
  801327:	6a 00                	push   $0x0
  801329:	e8 53 ee ff ff       	call   800181 <sys_page_alloc>
  80132e:	89 c3                	mov    %eax,%ebx
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	0f 88 c3 00 00 00    	js     8013fe <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80133b:	83 ec 0c             	sub    $0xc,%esp
  80133e:	ff 75 f4             	pushl  -0xc(%ebp)
  801341:	e8 9a f5 ff ff       	call   8008e0 <fd2data>
  801346:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801348:	83 c4 0c             	add    $0xc,%esp
  80134b:	68 07 04 00 00       	push   $0x407
  801350:	50                   	push   %eax
  801351:	6a 00                	push   $0x0
  801353:	e8 29 ee ff ff       	call   800181 <sys_page_alloc>
  801358:	89 c3                	mov    %eax,%ebx
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	0f 88 89 00 00 00    	js     8013ee <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	ff 75 f0             	pushl  -0x10(%ebp)
  80136b:	e8 70 f5 ff ff       	call   8008e0 <fd2data>
  801370:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801377:	50                   	push   %eax
  801378:	6a 00                	push   $0x0
  80137a:	56                   	push   %esi
  80137b:	6a 00                	push   $0x0
  80137d:	e8 42 ee ff ff       	call   8001c4 <sys_page_map>
  801382:	89 c3                	mov    %eax,%ebx
  801384:	83 c4 20             	add    $0x20,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 55                	js     8013e0 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80138b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801394:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801399:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013a0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013b5:	83 ec 0c             	sub    $0xc,%esp
  8013b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013bb:	e8 10 f5 ff ff       	call   8008d0 <fd2num>
  8013c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013c5:	83 c4 04             	add    $0x4,%esp
  8013c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8013cb:	e8 00 f5 ff ff       	call   8008d0 <fd2num>
  8013d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d3:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013de:	eb 30                	jmp    801410 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	56                   	push   %esi
  8013e4:	6a 00                	push   $0x0
  8013e6:	e8 1b ee ff ff       	call   800206 <sys_page_unmap>
  8013eb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f4:	6a 00                	push   $0x0
  8013f6:	e8 0b ee ff ff       	call   800206 <sys_page_unmap>
  8013fb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	ff 75 f4             	pushl  -0xc(%ebp)
  801404:	6a 00                	push   $0x0
  801406:	e8 fb ed ff ff       	call   800206 <sys_page_unmap>
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801410:	89 d0                	mov    %edx,%eax
  801412:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801415:	5b                   	pop    %ebx
  801416:	5e                   	pop    %esi
  801417:	5d                   	pop    %ebp
  801418:	c3                   	ret    

00801419 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80141f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801422:	50                   	push   %eax
  801423:	ff 75 08             	pushl  0x8(%ebp)
  801426:	e8 1b f5 ff ff       	call   800946 <fd_lookup>
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	85 c0                	test   %eax,%eax
  801430:	78 18                	js     80144a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801432:	83 ec 0c             	sub    $0xc,%esp
  801435:	ff 75 f4             	pushl  -0xc(%ebp)
  801438:	e8 a3 f4 ff ff       	call   8008e0 <fd2data>
	return _pipeisclosed(fd, p);
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801442:	e8 18 fd ff ff       	call   80115f <_pipeisclosed>
  801447:	83 c4 10             	add    $0x10,%esp
}
  80144a:	c9                   	leave  
  80144b:	c3                   	ret    

0080144c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80144f:	b8 00 00 00 00       	mov    $0x0,%eax
  801454:	5d                   	pop    %ebp
  801455:	c3                   	ret    

00801456 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80145c:	68 a2 25 80 00       	push   $0x8025a2
  801461:	ff 75 0c             	pushl  0xc(%ebp)
  801464:	e8 c4 07 00 00       	call   801c2d <strcpy>
	return 0;
}
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
  80146e:	c9                   	leave  
  80146f:	c3                   	ret    

00801470 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	57                   	push   %edi
  801474:	56                   	push   %esi
  801475:	53                   	push   %ebx
  801476:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80147c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801481:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801487:	eb 2d                	jmp    8014b6 <devcons_write+0x46>
		m = n - tot;
  801489:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80148c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80148e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801491:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801496:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801499:	83 ec 04             	sub    $0x4,%esp
  80149c:	53                   	push   %ebx
  80149d:	03 45 0c             	add    0xc(%ebp),%eax
  8014a0:	50                   	push   %eax
  8014a1:	57                   	push   %edi
  8014a2:	e8 18 09 00 00       	call   801dbf <memmove>
		sys_cputs(buf, m);
  8014a7:	83 c4 08             	add    $0x8,%esp
  8014aa:	53                   	push   %ebx
  8014ab:	57                   	push   %edi
  8014ac:	e8 14 ec ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014b1:	01 de                	add    %ebx,%esi
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	89 f0                	mov    %esi,%eax
  8014b8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014bb:	72 cc                	jb     801489 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c0:	5b                   	pop    %ebx
  8014c1:	5e                   	pop    %esi
  8014c2:	5f                   	pop    %edi
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    

008014c5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014d4:	74 2a                	je     801500 <devcons_read+0x3b>
  8014d6:	eb 05                	jmp    8014dd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014d8:	e8 85 ec ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014dd:	e8 01 ec ff ff       	call   8000e3 <sys_cgetc>
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	74 f2                	je     8014d8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 16                	js     801500 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014ea:	83 f8 04             	cmp    $0x4,%eax
  8014ed:	74 0c                	je     8014fb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f2:	88 02                	mov    %al,(%edx)
	return 1;
  8014f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f9:	eb 05                	jmp    801500 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014fb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801500:	c9                   	leave  
  801501:	c3                   	ret    

00801502 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801508:	8b 45 08             	mov    0x8(%ebp),%eax
  80150b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80150e:	6a 01                	push   $0x1
  801510:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	e8 ac eb ff ff       	call   8000c5 <sys_cputs>
}
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	c9                   	leave  
  80151d:	c3                   	ret    

0080151e <getchar>:

int
getchar(void)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801524:	6a 01                	push   $0x1
  801526:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801529:	50                   	push   %eax
  80152a:	6a 00                	push   $0x0
  80152c:	e8 7e f6 ff ff       	call   800baf <read>
	if (r < 0)
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 0f                	js     801547 <getchar+0x29>
		return r;
	if (r < 1)
  801538:	85 c0                	test   %eax,%eax
  80153a:	7e 06                	jle    801542 <getchar+0x24>
		return -E_EOF;
	return c;
  80153c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801540:	eb 05                	jmp    801547 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801542:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801547:	c9                   	leave  
  801548:	c3                   	ret    

00801549 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	ff 75 08             	pushl  0x8(%ebp)
  801556:	e8 eb f3 ff ff       	call   800946 <fd_lookup>
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	85 c0                	test   %eax,%eax
  801560:	78 11                	js     801573 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801562:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801565:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80156b:	39 10                	cmp    %edx,(%eax)
  80156d:	0f 94 c0             	sete   %al
  801570:	0f b6 c0             	movzbl %al,%eax
}
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <opencons>:

int
opencons(void)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80157b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157e:	50                   	push   %eax
  80157f:	e8 73 f3 ff ff       	call   8008f7 <fd_alloc>
  801584:	83 c4 10             	add    $0x10,%esp
		return r;
  801587:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 3e                	js     8015cb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80158d:	83 ec 04             	sub    $0x4,%esp
  801590:	68 07 04 00 00       	push   $0x407
  801595:	ff 75 f4             	pushl  -0xc(%ebp)
  801598:	6a 00                	push   $0x0
  80159a:	e8 e2 eb ff ff       	call   800181 <sys_page_alloc>
  80159f:	83 c4 10             	add    $0x10,%esp
		return r;
  8015a2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 23                	js     8015cb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015a8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015bd:	83 ec 0c             	sub    $0xc,%esp
  8015c0:	50                   	push   %eax
  8015c1:	e8 0a f3 ff ff       	call   8008d0 <fd2num>
  8015c6:	89 c2                	mov    %eax,%edx
  8015c8:	83 c4 10             	add    $0x10,%esp
}
  8015cb:	89 d0                	mov    %edx,%eax
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015d4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015d7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015dd:	e8 61 eb ff ff       	call   800143 <sys_getenvid>
  8015e2:	83 ec 0c             	sub    $0xc,%esp
  8015e5:	ff 75 0c             	pushl  0xc(%ebp)
  8015e8:	ff 75 08             	pushl  0x8(%ebp)
  8015eb:	56                   	push   %esi
  8015ec:	50                   	push   %eax
  8015ed:	68 b0 25 80 00       	push   $0x8025b0
  8015f2:	e8 b1 00 00 00       	call   8016a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015f7:	83 c4 18             	add    $0x18,%esp
  8015fa:	53                   	push   %ebx
  8015fb:	ff 75 10             	pushl  0x10(%ebp)
  8015fe:	e8 54 00 00 00       	call   801657 <vcprintf>
	cprintf("\n");
  801603:	c7 04 24 a6 24 80 00 	movl   $0x8024a6,(%esp)
  80160a:	e8 99 00 00 00       	call   8016a8 <cprintf>
  80160f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801612:	cc                   	int3   
  801613:	eb fd                	jmp    801612 <_panic+0x43>

00801615 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	53                   	push   %ebx
  801619:	83 ec 04             	sub    $0x4,%esp
  80161c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80161f:	8b 13                	mov    (%ebx),%edx
  801621:	8d 42 01             	lea    0x1(%edx),%eax
  801624:	89 03                	mov    %eax,(%ebx)
  801626:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801629:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80162d:	3d ff 00 00 00       	cmp    $0xff,%eax
  801632:	75 1a                	jne    80164e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	68 ff 00 00 00       	push   $0xff
  80163c:	8d 43 08             	lea    0x8(%ebx),%eax
  80163f:	50                   	push   %eax
  801640:	e8 80 ea ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  801645:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80164b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80164e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801652:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801660:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801667:	00 00 00 
	b.cnt = 0;
  80166a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801671:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801674:	ff 75 0c             	pushl  0xc(%ebp)
  801677:	ff 75 08             	pushl  0x8(%ebp)
  80167a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	68 15 16 80 00       	push   $0x801615
  801686:	e8 54 01 00 00       	call   8017df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80168b:	83 c4 08             	add    $0x8,%esp
  80168e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801694:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80169a:	50                   	push   %eax
  80169b:	e8 25 ea ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  8016a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016b1:	50                   	push   %eax
  8016b2:	ff 75 08             	pushl  0x8(%ebp)
  8016b5:	e8 9d ff ff ff       	call   801657 <vcprintf>
	va_end(ap);

	return cnt;
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	57                   	push   %edi
  8016c0:	56                   	push   %esi
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 1c             	sub    $0x1c,%esp
  8016c5:	89 c7                	mov    %eax,%edi
  8016c7:	89 d6                	mov    %edx,%esi
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016e3:	39 d3                	cmp    %edx,%ebx
  8016e5:	72 05                	jb     8016ec <printnum+0x30>
  8016e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016ea:	77 45                	ja     801731 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016ec:	83 ec 0c             	sub    $0xc,%esp
  8016ef:	ff 75 18             	pushl  0x18(%ebp)
  8016f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016f8:	53                   	push   %ebx
  8016f9:	ff 75 10             	pushl  0x10(%ebp)
  8016fc:	83 ec 08             	sub    $0x8,%esp
  8016ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801702:	ff 75 e0             	pushl  -0x20(%ebp)
  801705:	ff 75 dc             	pushl  -0x24(%ebp)
  801708:	ff 75 d8             	pushl  -0x28(%ebp)
  80170b:	e8 50 0a 00 00       	call   802160 <__udivdi3>
  801710:	83 c4 18             	add    $0x18,%esp
  801713:	52                   	push   %edx
  801714:	50                   	push   %eax
  801715:	89 f2                	mov    %esi,%edx
  801717:	89 f8                	mov    %edi,%eax
  801719:	e8 9e ff ff ff       	call   8016bc <printnum>
  80171e:	83 c4 20             	add    $0x20,%esp
  801721:	eb 18                	jmp    80173b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	56                   	push   %esi
  801727:	ff 75 18             	pushl  0x18(%ebp)
  80172a:	ff d7                	call   *%edi
  80172c:	83 c4 10             	add    $0x10,%esp
  80172f:	eb 03                	jmp    801734 <printnum+0x78>
  801731:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801734:	83 eb 01             	sub    $0x1,%ebx
  801737:	85 db                	test   %ebx,%ebx
  801739:	7f e8                	jg     801723 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	56                   	push   %esi
  80173f:	83 ec 04             	sub    $0x4,%esp
  801742:	ff 75 e4             	pushl  -0x1c(%ebp)
  801745:	ff 75 e0             	pushl  -0x20(%ebp)
  801748:	ff 75 dc             	pushl  -0x24(%ebp)
  80174b:	ff 75 d8             	pushl  -0x28(%ebp)
  80174e:	e8 3d 0b 00 00       	call   802290 <__umoddi3>
  801753:	83 c4 14             	add    $0x14,%esp
  801756:	0f be 80 d3 25 80 00 	movsbl 0x8025d3(%eax),%eax
  80175d:	50                   	push   %eax
  80175e:	ff d7                	call   *%edi
}
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5f                   	pop    %edi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80176e:	83 fa 01             	cmp    $0x1,%edx
  801771:	7e 0e                	jle    801781 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801773:	8b 10                	mov    (%eax),%edx
  801775:	8d 4a 08             	lea    0x8(%edx),%ecx
  801778:	89 08                	mov    %ecx,(%eax)
  80177a:	8b 02                	mov    (%edx),%eax
  80177c:	8b 52 04             	mov    0x4(%edx),%edx
  80177f:	eb 22                	jmp    8017a3 <getuint+0x38>
	else if (lflag)
  801781:	85 d2                	test   %edx,%edx
  801783:	74 10                	je     801795 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801785:	8b 10                	mov    (%eax),%edx
  801787:	8d 4a 04             	lea    0x4(%edx),%ecx
  80178a:	89 08                	mov    %ecx,(%eax)
  80178c:	8b 02                	mov    (%edx),%eax
  80178e:	ba 00 00 00 00       	mov    $0x0,%edx
  801793:	eb 0e                	jmp    8017a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801795:	8b 10                	mov    (%eax),%edx
  801797:	8d 4a 04             	lea    0x4(%edx),%ecx
  80179a:	89 08                	mov    %ecx,(%eax)
  80179c:	8b 02                	mov    (%edx),%eax
  80179e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017af:	8b 10                	mov    (%eax),%edx
  8017b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8017b4:	73 0a                	jae    8017c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017b9:	89 08                	mov    %ecx,(%eax)
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	88 02                	mov    %al,(%edx)
}
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017cb:	50                   	push   %eax
  8017cc:	ff 75 10             	pushl  0x10(%ebp)
  8017cf:	ff 75 0c             	pushl  0xc(%ebp)
  8017d2:	ff 75 08             	pushl  0x8(%ebp)
  8017d5:	e8 05 00 00 00       	call   8017df <vprintfmt>
	va_end(ap);
}
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    

008017df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	57                   	push   %edi
  8017e3:	56                   	push   %esi
  8017e4:	53                   	push   %ebx
  8017e5:	83 ec 2c             	sub    $0x2c,%esp
  8017e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8017eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017f1:	eb 12                	jmp    801805 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	0f 84 89 03 00 00    	je     801b84 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	53                   	push   %ebx
  8017ff:	50                   	push   %eax
  801800:	ff d6                	call   *%esi
  801802:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801805:	83 c7 01             	add    $0x1,%edi
  801808:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80180c:	83 f8 25             	cmp    $0x25,%eax
  80180f:	75 e2                	jne    8017f3 <vprintfmt+0x14>
  801811:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801815:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80181c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801823:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80182a:	ba 00 00 00 00       	mov    $0x0,%edx
  80182f:	eb 07                	jmp    801838 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801831:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801834:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801838:	8d 47 01             	lea    0x1(%edi),%eax
  80183b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80183e:	0f b6 07             	movzbl (%edi),%eax
  801841:	0f b6 c8             	movzbl %al,%ecx
  801844:	83 e8 23             	sub    $0x23,%eax
  801847:	3c 55                	cmp    $0x55,%al
  801849:	0f 87 1a 03 00 00    	ja     801b69 <vprintfmt+0x38a>
  80184f:	0f b6 c0             	movzbl %al,%eax
  801852:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  801859:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80185c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801860:	eb d6                	jmp    801838 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801862:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801865:	b8 00 00 00 00       	mov    $0x0,%eax
  80186a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80186d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801870:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801874:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801877:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80187a:	83 fa 09             	cmp    $0x9,%edx
  80187d:	77 39                	ja     8018b8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80187f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801882:	eb e9                	jmp    80186d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801884:	8b 45 14             	mov    0x14(%ebp),%eax
  801887:	8d 48 04             	lea    0x4(%eax),%ecx
  80188a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80188d:	8b 00                	mov    (%eax),%eax
  80188f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801892:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801895:	eb 27                	jmp    8018be <vprintfmt+0xdf>
  801897:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80189a:	85 c0                	test   %eax,%eax
  80189c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018a1:	0f 49 c8             	cmovns %eax,%ecx
  8018a4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018aa:	eb 8c                	jmp    801838 <vprintfmt+0x59>
  8018ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018af:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018b6:	eb 80                	jmp    801838 <vprintfmt+0x59>
  8018b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018bb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018c2:	0f 89 70 ff ff ff    	jns    801838 <vprintfmt+0x59>
				width = precision, precision = -1;
  8018c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018d5:	e9 5e ff ff ff       	jmp    801838 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018da:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018e0:	e9 53 ff ff ff       	jmp    801838 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e8:	8d 50 04             	lea    0x4(%eax),%edx
  8018eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	53                   	push   %ebx
  8018f2:	ff 30                	pushl  (%eax)
  8018f4:	ff d6                	call   *%esi
			break;
  8018f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018fc:	e9 04 ff ff ff       	jmp    801805 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801901:	8b 45 14             	mov    0x14(%ebp),%eax
  801904:	8d 50 04             	lea    0x4(%eax),%edx
  801907:	89 55 14             	mov    %edx,0x14(%ebp)
  80190a:	8b 00                	mov    (%eax),%eax
  80190c:	99                   	cltd   
  80190d:	31 d0                	xor    %edx,%eax
  80190f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801911:	83 f8 0f             	cmp    $0xf,%eax
  801914:	7f 0b                	jg     801921 <vprintfmt+0x142>
  801916:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  80191d:	85 d2                	test   %edx,%edx
  80191f:	75 18                	jne    801939 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801921:	50                   	push   %eax
  801922:	68 eb 25 80 00       	push   $0x8025eb
  801927:	53                   	push   %ebx
  801928:	56                   	push   %esi
  801929:	e8 94 fe ff ff       	call   8017c2 <printfmt>
  80192e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801931:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801934:	e9 cc fe ff ff       	jmp    801805 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801939:	52                   	push   %edx
  80193a:	68 69 25 80 00       	push   $0x802569
  80193f:	53                   	push   %ebx
  801940:	56                   	push   %esi
  801941:	e8 7c fe ff ff       	call   8017c2 <printfmt>
  801946:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801949:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80194c:	e9 b4 fe ff ff       	jmp    801805 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801951:	8b 45 14             	mov    0x14(%ebp),%eax
  801954:	8d 50 04             	lea    0x4(%eax),%edx
  801957:	89 55 14             	mov    %edx,0x14(%ebp)
  80195a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80195c:	85 ff                	test   %edi,%edi
  80195e:	b8 e4 25 80 00       	mov    $0x8025e4,%eax
  801963:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801966:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80196a:	0f 8e 94 00 00 00    	jle    801a04 <vprintfmt+0x225>
  801970:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801974:	0f 84 98 00 00 00    	je     801a12 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80197a:	83 ec 08             	sub    $0x8,%esp
  80197d:	ff 75 d0             	pushl  -0x30(%ebp)
  801980:	57                   	push   %edi
  801981:	e8 86 02 00 00       	call   801c0c <strnlen>
  801986:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801989:	29 c1                	sub    %eax,%ecx
  80198b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80198e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801991:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801995:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801998:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80199b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80199d:	eb 0f                	jmp    8019ae <vprintfmt+0x1cf>
					putch(padc, putdat);
  80199f:	83 ec 08             	sub    $0x8,%esp
  8019a2:	53                   	push   %ebx
  8019a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8019a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a8:	83 ef 01             	sub    $0x1,%edi
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	85 ff                	test   %edi,%edi
  8019b0:	7f ed                	jg     80199f <vprintfmt+0x1c0>
  8019b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019b8:	85 c9                	test   %ecx,%ecx
  8019ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bf:	0f 49 c1             	cmovns %ecx,%eax
  8019c2:	29 c1                	sub    %eax,%ecx
  8019c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8019c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019cd:	89 cb                	mov    %ecx,%ebx
  8019cf:	eb 4d                	jmp    801a1e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019d5:	74 1b                	je     8019f2 <vprintfmt+0x213>
  8019d7:	0f be c0             	movsbl %al,%eax
  8019da:	83 e8 20             	sub    $0x20,%eax
  8019dd:	83 f8 5e             	cmp    $0x5e,%eax
  8019e0:	76 10                	jbe    8019f2 <vprintfmt+0x213>
					putch('?', putdat);
  8019e2:	83 ec 08             	sub    $0x8,%esp
  8019e5:	ff 75 0c             	pushl  0xc(%ebp)
  8019e8:	6a 3f                	push   $0x3f
  8019ea:	ff 55 08             	call   *0x8(%ebp)
  8019ed:	83 c4 10             	add    $0x10,%esp
  8019f0:	eb 0d                	jmp    8019ff <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019f2:	83 ec 08             	sub    $0x8,%esp
  8019f5:	ff 75 0c             	pushl  0xc(%ebp)
  8019f8:	52                   	push   %edx
  8019f9:	ff 55 08             	call   *0x8(%ebp)
  8019fc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019ff:	83 eb 01             	sub    $0x1,%ebx
  801a02:	eb 1a                	jmp    801a1e <vprintfmt+0x23f>
  801a04:	89 75 08             	mov    %esi,0x8(%ebp)
  801a07:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a0a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a0d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a10:	eb 0c                	jmp    801a1e <vprintfmt+0x23f>
  801a12:	89 75 08             	mov    %esi,0x8(%ebp)
  801a15:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a18:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a1b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a1e:	83 c7 01             	add    $0x1,%edi
  801a21:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a25:	0f be d0             	movsbl %al,%edx
  801a28:	85 d2                	test   %edx,%edx
  801a2a:	74 23                	je     801a4f <vprintfmt+0x270>
  801a2c:	85 f6                	test   %esi,%esi
  801a2e:	78 a1                	js     8019d1 <vprintfmt+0x1f2>
  801a30:	83 ee 01             	sub    $0x1,%esi
  801a33:	79 9c                	jns    8019d1 <vprintfmt+0x1f2>
  801a35:	89 df                	mov    %ebx,%edi
  801a37:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a3d:	eb 18                	jmp    801a57 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a3f:	83 ec 08             	sub    $0x8,%esp
  801a42:	53                   	push   %ebx
  801a43:	6a 20                	push   $0x20
  801a45:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a47:	83 ef 01             	sub    $0x1,%edi
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	eb 08                	jmp    801a57 <vprintfmt+0x278>
  801a4f:	89 df                	mov    %ebx,%edi
  801a51:	8b 75 08             	mov    0x8(%ebp),%esi
  801a54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a57:	85 ff                	test   %edi,%edi
  801a59:	7f e4                	jg     801a3f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a5e:	e9 a2 fd ff ff       	jmp    801805 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a63:	83 fa 01             	cmp    $0x1,%edx
  801a66:	7e 16                	jle    801a7e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a68:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6b:	8d 50 08             	lea    0x8(%eax),%edx
  801a6e:	89 55 14             	mov    %edx,0x14(%ebp)
  801a71:	8b 50 04             	mov    0x4(%eax),%edx
  801a74:	8b 00                	mov    (%eax),%eax
  801a76:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a79:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a7c:	eb 32                	jmp    801ab0 <vprintfmt+0x2d1>
	else if (lflag)
  801a7e:	85 d2                	test   %edx,%edx
  801a80:	74 18                	je     801a9a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a82:	8b 45 14             	mov    0x14(%ebp),%eax
  801a85:	8d 50 04             	lea    0x4(%eax),%edx
  801a88:	89 55 14             	mov    %edx,0x14(%ebp)
  801a8b:	8b 00                	mov    (%eax),%eax
  801a8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a90:	89 c1                	mov    %eax,%ecx
  801a92:	c1 f9 1f             	sar    $0x1f,%ecx
  801a95:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a98:	eb 16                	jmp    801ab0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a9a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9d:	8d 50 04             	lea    0x4(%eax),%edx
  801aa0:	89 55 14             	mov    %edx,0x14(%ebp)
  801aa3:	8b 00                	mov    (%eax),%eax
  801aa5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aa8:	89 c1                	mov    %eax,%ecx
  801aaa:	c1 f9 1f             	sar    $0x1f,%ecx
  801aad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ab0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ab3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801ab6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801abb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801abf:	79 74                	jns    801b35 <vprintfmt+0x356>
				putch('-', putdat);
  801ac1:	83 ec 08             	sub    $0x8,%esp
  801ac4:	53                   	push   %ebx
  801ac5:	6a 2d                	push   $0x2d
  801ac7:	ff d6                	call   *%esi
				num = -(long long) num;
  801ac9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801acc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801acf:	f7 d8                	neg    %eax
  801ad1:	83 d2 00             	adc    $0x0,%edx
  801ad4:	f7 da                	neg    %edx
  801ad6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ad9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ade:	eb 55                	jmp    801b35 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ae0:	8d 45 14             	lea    0x14(%ebp),%eax
  801ae3:	e8 83 fc ff ff       	call   80176b <getuint>
			base = 10;
  801ae8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801aed:	eb 46                	jmp    801b35 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801aef:	8d 45 14             	lea    0x14(%ebp),%eax
  801af2:	e8 74 fc ff ff       	call   80176b <getuint>
			base = 8;
  801af7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801afc:	eb 37                	jmp    801b35 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	53                   	push   %ebx
  801b02:	6a 30                	push   $0x30
  801b04:	ff d6                	call   *%esi
			putch('x', putdat);
  801b06:	83 c4 08             	add    $0x8,%esp
  801b09:	53                   	push   %ebx
  801b0a:	6a 78                	push   $0x78
  801b0c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b0e:	8b 45 14             	mov    0x14(%ebp),%eax
  801b11:	8d 50 04             	lea    0x4(%eax),%edx
  801b14:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b17:	8b 00                	mov    (%eax),%eax
  801b19:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b1e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b21:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b26:	eb 0d                	jmp    801b35 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b28:	8d 45 14             	lea    0x14(%ebp),%eax
  801b2b:	e8 3b fc ff ff       	call   80176b <getuint>
			base = 16;
  801b30:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b35:	83 ec 0c             	sub    $0xc,%esp
  801b38:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b3c:	57                   	push   %edi
  801b3d:	ff 75 e0             	pushl  -0x20(%ebp)
  801b40:	51                   	push   %ecx
  801b41:	52                   	push   %edx
  801b42:	50                   	push   %eax
  801b43:	89 da                	mov    %ebx,%edx
  801b45:	89 f0                	mov    %esi,%eax
  801b47:	e8 70 fb ff ff       	call   8016bc <printnum>
			break;
  801b4c:	83 c4 20             	add    $0x20,%esp
  801b4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b52:	e9 ae fc ff ff       	jmp    801805 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b57:	83 ec 08             	sub    $0x8,%esp
  801b5a:	53                   	push   %ebx
  801b5b:	51                   	push   %ecx
  801b5c:	ff d6                	call   *%esi
			break;
  801b5e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b64:	e9 9c fc ff ff       	jmp    801805 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b69:	83 ec 08             	sub    $0x8,%esp
  801b6c:	53                   	push   %ebx
  801b6d:	6a 25                	push   $0x25
  801b6f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	eb 03                	jmp    801b79 <vprintfmt+0x39a>
  801b76:	83 ef 01             	sub    $0x1,%edi
  801b79:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b7d:	75 f7                	jne    801b76 <vprintfmt+0x397>
  801b7f:	e9 81 fc ff ff       	jmp    801805 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b87:	5b                   	pop    %ebx
  801b88:	5e                   	pop    %esi
  801b89:	5f                   	pop    %edi
  801b8a:	5d                   	pop    %ebp
  801b8b:	c3                   	ret    

00801b8c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 18             	sub    $0x18,%esp
  801b92:	8b 45 08             	mov    0x8(%ebp),%eax
  801b95:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b98:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b9b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b9f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ba2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	74 26                	je     801bd3 <vsnprintf+0x47>
  801bad:	85 d2                	test   %edx,%edx
  801baf:	7e 22                	jle    801bd3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801bb1:	ff 75 14             	pushl  0x14(%ebp)
  801bb4:	ff 75 10             	pushl  0x10(%ebp)
  801bb7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bba:	50                   	push   %eax
  801bbb:	68 a5 17 80 00       	push   $0x8017a5
  801bc0:	e8 1a fc ff ff       	call   8017df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bc8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	eb 05                	jmp    801bd8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801be0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801be3:	50                   	push   %eax
  801be4:	ff 75 10             	pushl  0x10(%ebp)
  801be7:	ff 75 0c             	pushl  0xc(%ebp)
  801bea:	ff 75 08             	pushl  0x8(%ebp)
  801bed:	e8 9a ff ff ff       	call   801b8c <vsnprintf>
	va_end(ap);

	return rc;
}
  801bf2:	c9                   	leave  
  801bf3:	c3                   	ret    

00801bf4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bfa:	b8 00 00 00 00       	mov    $0x0,%eax
  801bff:	eb 03                	jmp    801c04 <strlen+0x10>
		n++;
  801c01:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c04:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c08:	75 f7                	jne    801c01 <strlen+0xd>
		n++;
	return n;
}
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    

00801c0c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c12:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c15:	ba 00 00 00 00       	mov    $0x0,%edx
  801c1a:	eb 03                	jmp    801c1f <strnlen+0x13>
		n++;
  801c1c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c1f:	39 c2                	cmp    %eax,%edx
  801c21:	74 08                	je     801c2b <strnlen+0x1f>
  801c23:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c27:	75 f3                	jne    801c1c <strnlen+0x10>
  801c29:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    

00801c2d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	53                   	push   %ebx
  801c31:	8b 45 08             	mov    0x8(%ebp),%eax
  801c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c37:	89 c2                	mov    %eax,%edx
  801c39:	83 c2 01             	add    $0x1,%edx
  801c3c:	83 c1 01             	add    $0x1,%ecx
  801c3f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c43:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c46:	84 db                	test   %bl,%bl
  801c48:	75 ef                	jne    801c39 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c4a:	5b                   	pop    %ebx
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    

00801c4d <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	53                   	push   %ebx
  801c51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c54:	53                   	push   %ebx
  801c55:	e8 9a ff ff ff       	call   801bf4 <strlen>
  801c5a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c5d:	ff 75 0c             	pushl  0xc(%ebp)
  801c60:	01 d8                	add    %ebx,%eax
  801c62:	50                   	push   %eax
  801c63:	e8 c5 ff ff ff       	call   801c2d <strcpy>
	return dst;
}
  801c68:	89 d8                	mov    %ebx,%eax
  801c6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6d:	c9                   	leave  
  801c6e:	c3                   	ret    

00801c6f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	56                   	push   %esi
  801c73:	53                   	push   %ebx
  801c74:	8b 75 08             	mov    0x8(%ebp),%esi
  801c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c7a:	89 f3                	mov    %esi,%ebx
  801c7c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c7f:	89 f2                	mov    %esi,%edx
  801c81:	eb 0f                	jmp    801c92 <strncpy+0x23>
		*dst++ = *src;
  801c83:	83 c2 01             	add    $0x1,%edx
  801c86:	0f b6 01             	movzbl (%ecx),%eax
  801c89:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c8c:	80 39 01             	cmpb   $0x1,(%ecx)
  801c8f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c92:	39 da                	cmp    %ebx,%edx
  801c94:	75 ed                	jne    801c83 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c96:	89 f0                	mov    %esi,%eax
  801c98:	5b                   	pop    %ebx
  801c99:	5e                   	pop    %esi
  801c9a:	5d                   	pop    %ebp
  801c9b:	c3                   	ret    

00801c9c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	56                   	push   %esi
  801ca0:	53                   	push   %ebx
  801ca1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ca7:	8b 55 10             	mov    0x10(%ebp),%edx
  801caa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801cac:	85 d2                	test   %edx,%edx
  801cae:	74 21                	je     801cd1 <strlcpy+0x35>
  801cb0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cb4:	89 f2                	mov    %esi,%edx
  801cb6:	eb 09                	jmp    801cc1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cb8:	83 c2 01             	add    $0x1,%edx
  801cbb:	83 c1 01             	add    $0x1,%ecx
  801cbe:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cc1:	39 c2                	cmp    %eax,%edx
  801cc3:	74 09                	je     801cce <strlcpy+0x32>
  801cc5:	0f b6 19             	movzbl (%ecx),%ebx
  801cc8:	84 db                	test   %bl,%bl
  801cca:	75 ec                	jne    801cb8 <strlcpy+0x1c>
  801ccc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cd1:	29 f0                	sub    %esi,%eax
}
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ce0:	eb 06                	jmp    801ce8 <strcmp+0x11>
		p++, q++;
  801ce2:	83 c1 01             	add    $0x1,%ecx
  801ce5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ce8:	0f b6 01             	movzbl (%ecx),%eax
  801ceb:	84 c0                	test   %al,%al
  801ced:	74 04                	je     801cf3 <strcmp+0x1c>
  801cef:	3a 02                	cmp    (%edx),%al
  801cf1:	74 ef                	je     801ce2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cf3:	0f b6 c0             	movzbl %al,%eax
  801cf6:	0f b6 12             	movzbl (%edx),%edx
  801cf9:	29 d0                	sub    %edx,%eax
}
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    

00801cfd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cfd:	55                   	push   %ebp
  801cfe:	89 e5                	mov    %esp,%ebp
  801d00:	53                   	push   %ebx
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d07:	89 c3                	mov    %eax,%ebx
  801d09:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d0c:	eb 06                	jmp    801d14 <strncmp+0x17>
		n--, p++, q++;
  801d0e:	83 c0 01             	add    $0x1,%eax
  801d11:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d14:	39 d8                	cmp    %ebx,%eax
  801d16:	74 15                	je     801d2d <strncmp+0x30>
  801d18:	0f b6 08             	movzbl (%eax),%ecx
  801d1b:	84 c9                	test   %cl,%cl
  801d1d:	74 04                	je     801d23 <strncmp+0x26>
  801d1f:	3a 0a                	cmp    (%edx),%cl
  801d21:	74 eb                	je     801d0e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d23:	0f b6 00             	movzbl (%eax),%eax
  801d26:	0f b6 12             	movzbl (%edx),%edx
  801d29:	29 d0                	sub    %edx,%eax
  801d2b:	eb 05                	jmp    801d32 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d2d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d32:	5b                   	pop    %ebx
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    

00801d35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d3f:	eb 07                	jmp    801d48 <strchr+0x13>
		if (*s == c)
  801d41:	38 ca                	cmp    %cl,%dl
  801d43:	74 0f                	je     801d54 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d45:	83 c0 01             	add    $0x1,%eax
  801d48:	0f b6 10             	movzbl (%eax),%edx
  801d4b:	84 d2                	test   %dl,%dl
  801d4d:	75 f2                	jne    801d41 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d54:	5d                   	pop    %ebp
  801d55:	c3                   	ret    

00801d56 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d60:	eb 03                	jmp    801d65 <strfind+0xf>
  801d62:	83 c0 01             	add    $0x1,%eax
  801d65:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d68:	38 ca                	cmp    %cl,%dl
  801d6a:	74 04                	je     801d70 <strfind+0x1a>
  801d6c:	84 d2                	test   %dl,%dl
  801d6e:	75 f2                	jne    801d62 <strfind+0xc>
			break;
	return (char *) s;
}
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    

00801d72 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d7e:	85 c9                	test   %ecx,%ecx
  801d80:	74 36                	je     801db8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d82:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d88:	75 28                	jne    801db2 <memset+0x40>
  801d8a:	f6 c1 03             	test   $0x3,%cl
  801d8d:	75 23                	jne    801db2 <memset+0x40>
		c &= 0xFF;
  801d8f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d93:	89 d3                	mov    %edx,%ebx
  801d95:	c1 e3 08             	shl    $0x8,%ebx
  801d98:	89 d6                	mov    %edx,%esi
  801d9a:	c1 e6 18             	shl    $0x18,%esi
  801d9d:	89 d0                	mov    %edx,%eax
  801d9f:	c1 e0 10             	shl    $0x10,%eax
  801da2:	09 f0                	or     %esi,%eax
  801da4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801da6:	89 d8                	mov    %ebx,%eax
  801da8:	09 d0                	or     %edx,%eax
  801daa:	c1 e9 02             	shr    $0x2,%ecx
  801dad:	fc                   	cld    
  801dae:	f3 ab                	rep stos %eax,%es:(%edi)
  801db0:	eb 06                	jmp    801db8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801db2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db5:	fc                   	cld    
  801db6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801db8:	89 f8                	mov    %edi,%eax
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	57                   	push   %edi
  801dc3:	56                   	push   %esi
  801dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dcd:	39 c6                	cmp    %eax,%esi
  801dcf:	73 35                	jae    801e06 <memmove+0x47>
  801dd1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dd4:	39 d0                	cmp    %edx,%eax
  801dd6:	73 2e                	jae    801e06 <memmove+0x47>
		s += n;
		d += n;
  801dd8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ddb:	89 d6                	mov    %edx,%esi
  801ddd:	09 fe                	or     %edi,%esi
  801ddf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801de5:	75 13                	jne    801dfa <memmove+0x3b>
  801de7:	f6 c1 03             	test   $0x3,%cl
  801dea:	75 0e                	jne    801dfa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801dec:	83 ef 04             	sub    $0x4,%edi
  801def:	8d 72 fc             	lea    -0x4(%edx),%esi
  801df2:	c1 e9 02             	shr    $0x2,%ecx
  801df5:	fd                   	std    
  801df6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801df8:	eb 09                	jmp    801e03 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dfa:	83 ef 01             	sub    $0x1,%edi
  801dfd:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e00:	fd                   	std    
  801e01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e03:	fc                   	cld    
  801e04:	eb 1d                	jmp    801e23 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e06:	89 f2                	mov    %esi,%edx
  801e08:	09 c2                	or     %eax,%edx
  801e0a:	f6 c2 03             	test   $0x3,%dl
  801e0d:	75 0f                	jne    801e1e <memmove+0x5f>
  801e0f:	f6 c1 03             	test   $0x3,%cl
  801e12:	75 0a                	jne    801e1e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e14:	c1 e9 02             	shr    $0x2,%ecx
  801e17:	89 c7                	mov    %eax,%edi
  801e19:	fc                   	cld    
  801e1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e1c:	eb 05                	jmp    801e23 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e1e:	89 c7                	mov    %eax,%edi
  801e20:	fc                   	cld    
  801e21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e23:	5e                   	pop    %esi
  801e24:	5f                   	pop    %edi
  801e25:	5d                   	pop    %ebp
  801e26:	c3                   	ret    

00801e27 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e2a:	ff 75 10             	pushl  0x10(%ebp)
  801e2d:	ff 75 0c             	pushl  0xc(%ebp)
  801e30:	ff 75 08             	pushl  0x8(%ebp)
  801e33:	e8 87 ff ff ff       	call   801dbf <memmove>
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	56                   	push   %esi
  801e3e:	53                   	push   %ebx
  801e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e45:	89 c6                	mov    %eax,%esi
  801e47:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e4a:	eb 1a                	jmp    801e66 <memcmp+0x2c>
		if (*s1 != *s2)
  801e4c:	0f b6 08             	movzbl (%eax),%ecx
  801e4f:	0f b6 1a             	movzbl (%edx),%ebx
  801e52:	38 d9                	cmp    %bl,%cl
  801e54:	74 0a                	je     801e60 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e56:	0f b6 c1             	movzbl %cl,%eax
  801e59:	0f b6 db             	movzbl %bl,%ebx
  801e5c:	29 d8                	sub    %ebx,%eax
  801e5e:	eb 0f                	jmp    801e6f <memcmp+0x35>
		s1++, s2++;
  801e60:	83 c0 01             	add    $0x1,%eax
  801e63:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e66:	39 f0                	cmp    %esi,%eax
  801e68:	75 e2                	jne    801e4c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e6f:	5b                   	pop    %ebx
  801e70:	5e                   	pop    %esi
  801e71:	5d                   	pop    %ebp
  801e72:	c3                   	ret    

00801e73 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	53                   	push   %ebx
  801e77:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e7a:	89 c1                	mov    %eax,%ecx
  801e7c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e7f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e83:	eb 0a                	jmp    801e8f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e85:	0f b6 10             	movzbl (%eax),%edx
  801e88:	39 da                	cmp    %ebx,%edx
  801e8a:	74 07                	je     801e93 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e8c:	83 c0 01             	add    $0x1,%eax
  801e8f:	39 c8                	cmp    %ecx,%eax
  801e91:	72 f2                	jb     801e85 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e93:	5b                   	pop    %ebx
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    

00801e96 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	57                   	push   %edi
  801e9a:	56                   	push   %esi
  801e9b:	53                   	push   %ebx
  801e9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ea2:	eb 03                	jmp    801ea7 <strtol+0x11>
		s++;
  801ea4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ea7:	0f b6 01             	movzbl (%ecx),%eax
  801eaa:	3c 20                	cmp    $0x20,%al
  801eac:	74 f6                	je     801ea4 <strtol+0xe>
  801eae:	3c 09                	cmp    $0x9,%al
  801eb0:	74 f2                	je     801ea4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801eb2:	3c 2b                	cmp    $0x2b,%al
  801eb4:	75 0a                	jne    801ec0 <strtol+0x2a>
		s++;
  801eb6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801eb9:	bf 00 00 00 00       	mov    $0x0,%edi
  801ebe:	eb 11                	jmp    801ed1 <strtol+0x3b>
  801ec0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ec5:	3c 2d                	cmp    $0x2d,%al
  801ec7:	75 08                	jne    801ed1 <strtol+0x3b>
		s++, neg = 1;
  801ec9:	83 c1 01             	add    $0x1,%ecx
  801ecc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ed1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ed7:	75 15                	jne    801eee <strtol+0x58>
  801ed9:	80 39 30             	cmpb   $0x30,(%ecx)
  801edc:	75 10                	jne    801eee <strtol+0x58>
  801ede:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ee2:	75 7c                	jne    801f60 <strtol+0xca>
		s += 2, base = 16;
  801ee4:	83 c1 02             	add    $0x2,%ecx
  801ee7:	bb 10 00 00 00       	mov    $0x10,%ebx
  801eec:	eb 16                	jmp    801f04 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801eee:	85 db                	test   %ebx,%ebx
  801ef0:	75 12                	jne    801f04 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ef2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ef7:	80 39 30             	cmpb   $0x30,(%ecx)
  801efa:	75 08                	jne    801f04 <strtol+0x6e>
		s++, base = 8;
  801efc:	83 c1 01             	add    $0x1,%ecx
  801eff:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f04:	b8 00 00 00 00       	mov    $0x0,%eax
  801f09:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f0c:	0f b6 11             	movzbl (%ecx),%edx
  801f0f:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f12:	89 f3                	mov    %esi,%ebx
  801f14:	80 fb 09             	cmp    $0x9,%bl
  801f17:	77 08                	ja     801f21 <strtol+0x8b>
			dig = *s - '0';
  801f19:	0f be d2             	movsbl %dl,%edx
  801f1c:	83 ea 30             	sub    $0x30,%edx
  801f1f:	eb 22                	jmp    801f43 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f21:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f24:	89 f3                	mov    %esi,%ebx
  801f26:	80 fb 19             	cmp    $0x19,%bl
  801f29:	77 08                	ja     801f33 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f2b:	0f be d2             	movsbl %dl,%edx
  801f2e:	83 ea 57             	sub    $0x57,%edx
  801f31:	eb 10                	jmp    801f43 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f33:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f36:	89 f3                	mov    %esi,%ebx
  801f38:	80 fb 19             	cmp    $0x19,%bl
  801f3b:	77 16                	ja     801f53 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f3d:	0f be d2             	movsbl %dl,%edx
  801f40:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f43:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f46:	7d 0b                	jge    801f53 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f48:	83 c1 01             	add    $0x1,%ecx
  801f4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f4f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f51:	eb b9                	jmp    801f0c <strtol+0x76>

	if (endptr)
  801f53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f57:	74 0d                	je     801f66 <strtol+0xd0>
		*endptr = (char *) s;
  801f59:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f5c:	89 0e                	mov    %ecx,(%esi)
  801f5e:	eb 06                	jmp    801f66 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f60:	85 db                	test   %ebx,%ebx
  801f62:	74 98                	je     801efc <strtol+0x66>
  801f64:	eb 9e                	jmp    801f04 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f66:	89 c2                	mov    %eax,%edx
  801f68:	f7 da                	neg    %edx
  801f6a:	85 ff                	test   %edi,%edi
  801f6c:	0f 45 c2             	cmovne %edx,%eax
}
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    

00801f74 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f7a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f81:	75 2a                	jne    801fad <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f83:	83 ec 04             	sub    $0x4,%esp
  801f86:	6a 07                	push   $0x7
  801f88:	68 00 f0 bf ee       	push   $0xeebff000
  801f8d:	6a 00                	push   $0x0
  801f8f:	e8 ed e1 ff ff       	call   800181 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	85 c0                	test   %eax,%eax
  801f99:	79 12                	jns    801fad <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f9b:	50                   	push   %eax
  801f9c:	68 bd 24 80 00       	push   $0x8024bd
  801fa1:	6a 23                	push   $0x23
  801fa3:	68 e0 28 80 00       	push   $0x8028e0
  801fa8:	e8 22 f6 ff ff       	call   8015cf <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fad:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb0:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fb5:	83 ec 08             	sub    $0x8,%esp
  801fb8:	68 df 1f 80 00       	push   $0x801fdf
  801fbd:	6a 00                	push   $0x0
  801fbf:	e8 08 e3 ff ff       	call   8002cc <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	79 12                	jns    801fdd <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fcb:	50                   	push   %eax
  801fcc:	68 bd 24 80 00       	push   $0x8024bd
  801fd1:	6a 2c                	push   $0x2c
  801fd3:	68 e0 28 80 00       	push   $0x8028e0
  801fd8:	e8 f2 f5 ff ff       	call   8015cf <_panic>
	}
}
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    

00801fdf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fdf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fe0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fe5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fe7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fea:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fee:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801ff3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801ff7:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ff9:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ffc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ffd:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802000:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802001:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802002:	c3                   	ret    

00802003 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	8b 75 08             	mov    0x8(%ebp),%esi
  80200b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802011:	85 c0                	test   %eax,%eax
  802013:	75 12                	jne    802027 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802015:	83 ec 0c             	sub    $0xc,%esp
  802018:	68 00 00 c0 ee       	push   $0xeec00000
  80201d:	e8 0f e3 ff ff       	call   800331 <sys_ipc_recv>
  802022:	83 c4 10             	add    $0x10,%esp
  802025:	eb 0c                	jmp    802033 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802027:	83 ec 0c             	sub    $0xc,%esp
  80202a:	50                   	push   %eax
  80202b:	e8 01 e3 ff ff       	call   800331 <sys_ipc_recv>
  802030:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802033:	85 f6                	test   %esi,%esi
  802035:	0f 95 c1             	setne  %cl
  802038:	85 db                	test   %ebx,%ebx
  80203a:	0f 95 c2             	setne  %dl
  80203d:	84 d1                	test   %dl,%cl
  80203f:	74 09                	je     80204a <ipc_recv+0x47>
  802041:	89 c2                	mov    %eax,%edx
  802043:	c1 ea 1f             	shr    $0x1f,%edx
  802046:	84 d2                	test   %dl,%dl
  802048:	75 2d                	jne    802077 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80204a:	85 f6                	test   %esi,%esi
  80204c:	74 0d                	je     80205b <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80204e:	a1 04 40 80 00       	mov    0x804004,%eax
  802053:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802059:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80205b:	85 db                	test   %ebx,%ebx
  80205d:	74 0d                	je     80206c <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80205f:	a1 04 40 80 00       	mov    0x804004,%eax
  802064:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80206a:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80206c:	a1 04 40 80 00       	mov    0x804004,%eax
  802071:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802077:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80207a:	5b                   	pop    %ebx
  80207b:	5e                   	pop    %esi
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    

0080207e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 0c             	sub    $0xc,%esp
  802087:	8b 7d 08             	mov    0x8(%ebp),%edi
  80208a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80208d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802090:	85 db                	test   %ebx,%ebx
  802092:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802097:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80209a:	ff 75 14             	pushl  0x14(%ebp)
  80209d:	53                   	push   %ebx
  80209e:	56                   	push   %esi
  80209f:	57                   	push   %edi
  8020a0:	e8 69 e2 ff ff       	call   80030e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020a5:	89 c2                	mov    %eax,%edx
  8020a7:	c1 ea 1f             	shr    $0x1f,%edx
  8020aa:	83 c4 10             	add    $0x10,%esp
  8020ad:	84 d2                	test   %dl,%dl
  8020af:	74 17                	je     8020c8 <ipc_send+0x4a>
  8020b1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020b4:	74 12                	je     8020c8 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020b6:	50                   	push   %eax
  8020b7:	68 ee 28 80 00       	push   $0x8028ee
  8020bc:	6a 47                	push   $0x47
  8020be:	68 fc 28 80 00       	push   $0x8028fc
  8020c3:	e8 07 f5 ff ff       	call   8015cf <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020c8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020cb:	75 07                	jne    8020d4 <ipc_send+0x56>
			sys_yield();
  8020cd:	e8 90 e0 ff ff       	call   800162 <sys_yield>
  8020d2:	eb c6                	jmp    80209a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020d4:	85 c0                	test   %eax,%eax
  8020d6:	75 c2                	jne    80209a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020db:	5b                   	pop    %ebx
  8020dc:	5e                   	pop    %esi
  8020dd:	5f                   	pop    %edi
  8020de:	5d                   	pop    %ebp
  8020df:	c3                   	ret    

008020e0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020e6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020eb:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020f1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020f7:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8020fd:	39 ca                	cmp    %ecx,%edx
  8020ff:	75 13                	jne    802114 <ipc_find_env+0x34>
			return envs[i].env_id;
  802101:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802107:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80210c:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802112:	eb 0f                	jmp    802123 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802114:	83 c0 01             	add    $0x1,%eax
  802117:	3d 00 04 00 00       	cmp    $0x400,%eax
  80211c:	75 cd                	jne    8020eb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80211e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    

00802125 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212b:	89 d0                	mov    %edx,%eax
  80212d:	c1 e8 16             	shr    $0x16,%eax
  802130:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802137:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213c:	f6 c1 01             	test   $0x1,%cl
  80213f:	74 1d                	je     80215e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802141:	c1 ea 0c             	shr    $0xc,%edx
  802144:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80214b:	f6 c2 01             	test   $0x1,%dl
  80214e:	74 0e                	je     80215e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802150:	c1 ea 0c             	shr    $0xc,%edx
  802153:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80215a:	ef 
  80215b:	0f b7 c0             	movzwl %ax,%eax
}
  80215e:	5d                   	pop    %ebp
  80215f:	c3                   	ret    

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
