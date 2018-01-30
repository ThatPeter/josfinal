
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 88 00 00 00       	call   8000d1 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 f1 00 00 00       	call   80014f <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 2a 00 00 00       	call   8000b7 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  80009d:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000a2:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000a4:	e8 a6 00 00 00       	call   80014f <sys_getenvid>
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	50                   	push   %eax
  8000ad:	e8 ec 02 00 00       	call   80039e <sys_thread_free>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000bd:	e8 e8 09 00 00       	call   800aaa <close_all>
	sys_env_destroy(0);
  8000c2:	83 ec 0c             	sub    $0xc,%esp
  8000c5:	6a 00                	push   $0x0
  8000c7:	e8 42 00 00 00       	call   80010e <sys_env_destroy>
}
  8000cc:	83 c4 10             	add    $0x10,%esp
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    

008000d1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000df:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e2:	89 c3                	mov    %eax,%ebx
  8000e4:	89 c7                	mov    %eax,%edi
  8000e6:	89 c6                	mov    %eax,%esi
  8000e8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5f                   	pop    %edi
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    

008000ef <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	57                   	push   %edi
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ff:	89 d1                	mov    %edx,%ecx
  800101:	89 d3                	mov    %edx,%ebx
  800103:	89 d7                	mov    %edx,%edi
  800105:	89 d6                	mov    %edx,%esi
  800107:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	57                   	push   %edi
  800112:	56                   	push   %esi
  800113:	53                   	push   %ebx
  800114:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800117:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011c:	b8 03 00 00 00       	mov    $0x3,%eax
  800121:	8b 55 08             	mov    0x8(%ebp),%edx
  800124:	89 cb                	mov    %ecx,%ebx
  800126:	89 cf                	mov    %ecx,%edi
  800128:	89 ce                	mov    %ecx,%esi
  80012a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80012c:	85 c0                	test   %eax,%eax
  80012e:	7e 17                	jle    800147 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800130:	83 ec 0c             	sub    $0xc,%esp
  800133:	50                   	push   %eax
  800134:	6a 03                	push   $0x3
  800136:	68 18 24 80 00       	push   $0x802418
  80013b:	6a 23                	push   $0x23
  80013d:	68 35 24 80 00       	push   $0x802435
  800142:	e8 94 14 00 00       	call   8015db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800147:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5f                   	pop    %edi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <sys_yield>:

void
sys_yield(void)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017e:	89 d1                	mov    %edx,%ecx
  800180:	89 d3                	mov    %edx,%ebx
  800182:	89 d7                	mov    %edx,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800188:	5b                   	pop    %ebx
  800189:	5e                   	pop    %esi
  80018a:	5f                   	pop    %edi
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	57                   	push   %edi
  800191:	56                   	push   %esi
  800192:	53                   	push   %ebx
  800193:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800196:	be 00 00 00 00       	mov    $0x0,%esi
  80019b:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a9:	89 f7                	mov    %esi,%edi
  8001ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ad:	85 c0                	test   %eax,%eax
  8001af:	7e 17                	jle    8001c8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b1:	83 ec 0c             	sub    $0xc,%esp
  8001b4:	50                   	push   %eax
  8001b5:	6a 04                	push   $0x4
  8001b7:	68 18 24 80 00       	push   $0x802418
  8001bc:	6a 23                	push   $0x23
  8001be:	68 35 24 80 00       	push   $0x802435
  8001c3:	e8 13 14 00 00       	call   8015db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cb:	5b                   	pop    %ebx
  8001cc:	5e                   	pop    %esi
  8001cd:	5f                   	pop    %edi
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    

008001d0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8001de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ea:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ef:	85 c0                	test   %eax,%eax
  8001f1:	7e 17                	jle    80020a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f3:	83 ec 0c             	sub    $0xc,%esp
  8001f6:	50                   	push   %eax
  8001f7:	6a 05                	push   $0x5
  8001f9:	68 18 24 80 00       	push   $0x802418
  8001fe:	6a 23                	push   $0x23
  800200:	68 35 24 80 00       	push   $0x802435
  800205:	e8 d1 13 00 00       	call   8015db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	57                   	push   %edi
  800216:	56                   	push   %esi
  800217:	53                   	push   %ebx
  800218:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800220:	b8 06 00 00 00       	mov    $0x6,%eax
  800225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800228:	8b 55 08             	mov    0x8(%ebp),%edx
  80022b:	89 df                	mov    %ebx,%edi
  80022d:	89 de                	mov    %ebx,%esi
  80022f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800231:	85 c0                	test   %eax,%eax
  800233:	7e 17                	jle    80024c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	50                   	push   %eax
  800239:	6a 06                	push   $0x6
  80023b:	68 18 24 80 00       	push   $0x802418
  800240:	6a 23                	push   $0x23
  800242:	68 35 24 80 00       	push   $0x802435
  800247:	e8 8f 13 00 00       	call   8015db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    

00800254 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	57                   	push   %edi
  800258:	56                   	push   %esi
  800259:	53                   	push   %ebx
  80025a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800262:	b8 08 00 00 00       	mov    $0x8,%eax
  800267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026a:	8b 55 08             	mov    0x8(%ebp),%edx
  80026d:	89 df                	mov    %ebx,%edi
  80026f:	89 de                	mov    %ebx,%esi
  800271:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800273:	85 c0                	test   %eax,%eax
  800275:	7e 17                	jle    80028e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	50                   	push   %eax
  80027b:	6a 08                	push   $0x8
  80027d:	68 18 24 80 00       	push   $0x802418
  800282:	6a 23                	push   $0x23
  800284:	68 35 24 80 00       	push   $0x802435
  800289:	e8 4d 13 00 00       	call   8015db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	57                   	push   %edi
  80029a:	56                   	push   %esi
  80029b:	53                   	push   %ebx
  80029c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	89 df                	mov    %ebx,%edi
  8002b1:	89 de                	mov    %ebx,%esi
  8002b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b5:	85 c0                	test   %eax,%eax
  8002b7:	7e 17                	jle    8002d0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b9:	83 ec 0c             	sub    $0xc,%esp
  8002bc:	50                   	push   %eax
  8002bd:	6a 09                	push   $0x9
  8002bf:	68 18 24 80 00       	push   $0x802418
  8002c4:	6a 23                	push   $0x23
  8002c6:	68 35 24 80 00       	push   $0x802435
  8002cb:	e8 0b 13 00 00       	call   8015db <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	57                   	push   %edi
  8002dc:	56                   	push   %esi
  8002dd:	53                   	push   %ebx
  8002de:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f1:	89 df                	mov    %ebx,%edi
  8002f3:	89 de                	mov    %ebx,%esi
  8002f5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f7:	85 c0                	test   %eax,%eax
  8002f9:	7e 17                	jle    800312 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fb:	83 ec 0c             	sub    $0xc,%esp
  8002fe:	50                   	push   %eax
  8002ff:	6a 0a                	push   $0xa
  800301:	68 18 24 80 00       	push   $0x802418
  800306:	6a 23                	push   $0x23
  800308:	68 35 24 80 00       	push   $0x802435
  80030d:	e8 c9 12 00 00       	call   8015db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800312:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800320:	be 00 00 00 00       	mov    $0x0,%esi
  800325:	b8 0c 00 00 00       	mov    $0xc,%eax
  80032a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800333:	8b 7d 14             	mov    0x14(%ebp),%edi
  800336:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800338:	5b                   	pop    %ebx
  800339:	5e                   	pop    %esi
  80033a:	5f                   	pop    %edi
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800346:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800350:	8b 55 08             	mov    0x8(%ebp),%edx
  800353:	89 cb                	mov    %ecx,%ebx
  800355:	89 cf                	mov    %ecx,%edi
  800357:	89 ce                	mov    %ecx,%esi
  800359:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80035b:	85 c0                	test   %eax,%eax
  80035d:	7e 17                	jle    800376 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035f:	83 ec 0c             	sub    $0xc,%esp
  800362:	50                   	push   %eax
  800363:	6a 0d                	push   $0xd
  800365:	68 18 24 80 00       	push   $0x802418
  80036a:	6a 23                	push   $0x23
  80036c:	68 35 24 80 00       	push   $0x802435
  800371:	e8 65 12 00 00       	call   8015db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800376:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800379:	5b                   	pop    %ebx
  80037a:	5e                   	pop    %esi
  80037b:	5f                   	pop    %edi
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	57                   	push   %edi
  800382:	56                   	push   %esi
  800383:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800384:	b9 00 00 00 00       	mov    $0x0,%ecx
  800389:	b8 0e 00 00 00       	mov    $0xe,%eax
  80038e:	8b 55 08             	mov    0x8(%ebp),%edx
  800391:	89 cb                	mov    %ecx,%ebx
  800393:	89 cf                	mov    %ecx,%edi
  800395:	89 ce                	mov    %ecx,%esi
  800397:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800399:	5b                   	pop    %ebx
  80039a:	5e                   	pop    %esi
  80039b:	5f                   	pop    %edi
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	57                   	push   %edi
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b1:	89 cb                	mov    %ecx,%ebx
  8003b3:	89 cf                	mov    %ecx,%edi
  8003b5:	89 ce                	mov    %ecx,%esi
  8003b7:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5f                   	pop    %edi
  8003bc:	5d                   	pop    %ebp
  8003bd:	c3                   	ret    

008003be <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c9:	b8 10 00 00 00       	mov    $0x10,%eax
  8003ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d1:	89 cb                	mov    %ecx,%ebx
  8003d3:	89 cf                	mov    %ecx,%edi
  8003d5:	89 ce                	mov    %ecx,%esi
  8003d7:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8003d9:	5b                   	pop    %ebx
  8003da:	5e                   	pop    %esi
  8003db:	5f                   	pop    %edi
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	53                   	push   %ebx
  8003e2:	83 ec 04             	sub    $0x4,%esp
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003e8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003ea:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003ee:	74 11                	je     800401 <pgfault+0x23>
  8003f0:	89 d8                	mov    %ebx,%eax
  8003f2:	c1 e8 0c             	shr    $0xc,%eax
  8003f5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003fc:	f6 c4 08             	test   $0x8,%ah
  8003ff:	75 14                	jne    800415 <pgfault+0x37>
		panic("faulting access");
  800401:	83 ec 04             	sub    $0x4,%esp
  800404:	68 43 24 80 00       	push   $0x802443
  800409:	6a 1f                	push   $0x1f
  80040b:	68 53 24 80 00       	push   $0x802453
  800410:	e8 c6 11 00 00       	call   8015db <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800415:	83 ec 04             	sub    $0x4,%esp
  800418:	6a 07                	push   $0x7
  80041a:	68 00 f0 7f 00       	push   $0x7ff000
  80041f:	6a 00                	push   $0x0
  800421:	e8 67 fd ff ff       	call   80018d <sys_page_alloc>
	if (r < 0) {
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	85 c0                	test   %eax,%eax
  80042b:	79 12                	jns    80043f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80042d:	50                   	push   %eax
  80042e:	68 5e 24 80 00       	push   $0x80245e
  800433:	6a 2d                	push   $0x2d
  800435:	68 53 24 80 00       	push   $0x802453
  80043a:	e8 9c 11 00 00       	call   8015db <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80043f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800445:	83 ec 04             	sub    $0x4,%esp
  800448:	68 00 10 00 00       	push   $0x1000
  80044d:	53                   	push   %ebx
  80044e:	68 00 f0 7f 00       	push   $0x7ff000
  800453:	e8 db 19 00 00       	call   801e33 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800458:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80045f:	53                   	push   %ebx
  800460:	6a 00                	push   $0x0
  800462:	68 00 f0 7f 00       	push   $0x7ff000
  800467:	6a 00                	push   $0x0
  800469:	e8 62 fd ff ff       	call   8001d0 <sys_page_map>
	if (r < 0) {
  80046e:	83 c4 20             	add    $0x20,%esp
  800471:	85 c0                	test   %eax,%eax
  800473:	79 12                	jns    800487 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800475:	50                   	push   %eax
  800476:	68 5e 24 80 00       	push   $0x80245e
  80047b:	6a 34                	push   $0x34
  80047d:	68 53 24 80 00       	push   $0x802453
  800482:	e8 54 11 00 00       	call   8015db <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	68 00 f0 7f 00       	push   $0x7ff000
  80048f:	6a 00                	push   $0x0
  800491:	e8 7c fd ff ff       	call   800212 <sys_page_unmap>
	if (r < 0) {
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	85 c0                	test   %eax,%eax
  80049b:	79 12                	jns    8004af <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80049d:	50                   	push   %eax
  80049e:	68 5e 24 80 00       	push   $0x80245e
  8004a3:	6a 38                	push   $0x38
  8004a5:	68 53 24 80 00       	push   $0x802453
  8004aa:	e8 2c 11 00 00       	call   8015db <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004b2:	c9                   	leave  
  8004b3:	c3                   	ret    

008004b4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	57                   	push   %edi
  8004b8:	56                   	push   %esi
  8004b9:	53                   	push   %ebx
  8004ba:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004bd:	68 de 03 80 00       	push   $0x8003de
  8004c2:	e8 b9 1a 00 00       	call   801f80 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004c7:	b8 07 00 00 00       	mov    $0x7,%eax
  8004cc:	cd 30                	int    $0x30
  8004ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	79 17                	jns    8004ef <fork+0x3b>
		panic("fork fault %e");
  8004d8:	83 ec 04             	sub    $0x4,%esp
  8004db:	68 77 24 80 00       	push   $0x802477
  8004e0:	68 85 00 00 00       	push   $0x85
  8004e5:	68 53 24 80 00       	push   $0x802453
  8004ea:	e8 ec 10 00 00       	call   8015db <_panic>
  8004ef:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f5:	75 24                	jne    80051b <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004f7:	e8 53 fc ff ff       	call   80014f <sys_getenvid>
  8004fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800501:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800507:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80050c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800511:	b8 00 00 00 00       	mov    $0x0,%eax
  800516:	e9 64 01 00 00       	jmp    80067f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80051b:	83 ec 04             	sub    $0x4,%esp
  80051e:	6a 07                	push   $0x7
  800520:	68 00 f0 bf ee       	push   $0xeebff000
  800525:	ff 75 e4             	pushl  -0x1c(%ebp)
  800528:	e8 60 fc ff ff       	call   80018d <sys_page_alloc>
  80052d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800530:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800535:	89 d8                	mov    %ebx,%eax
  800537:	c1 e8 16             	shr    $0x16,%eax
  80053a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800541:	a8 01                	test   $0x1,%al
  800543:	0f 84 fc 00 00 00    	je     800645 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800549:	89 d8                	mov    %ebx,%eax
  80054b:	c1 e8 0c             	shr    $0xc,%eax
  80054e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800555:	f6 c2 01             	test   $0x1,%dl
  800558:	0f 84 e7 00 00 00    	je     800645 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80055e:	89 c6                	mov    %eax,%esi
  800560:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800563:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80056a:	f6 c6 04             	test   $0x4,%dh
  80056d:	74 39                	je     8005a8 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80056f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800576:	83 ec 0c             	sub    $0xc,%esp
  800579:	25 07 0e 00 00       	and    $0xe07,%eax
  80057e:	50                   	push   %eax
  80057f:	56                   	push   %esi
  800580:	57                   	push   %edi
  800581:	56                   	push   %esi
  800582:	6a 00                	push   $0x0
  800584:	e8 47 fc ff ff       	call   8001d0 <sys_page_map>
		if (r < 0) {
  800589:	83 c4 20             	add    $0x20,%esp
  80058c:	85 c0                	test   %eax,%eax
  80058e:	0f 89 b1 00 00 00    	jns    800645 <fork+0x191>
		    	panic("sys page map fault %e");
  800594:	83 ec 04             	sub    $0x4,%esp
  800597:	68 85 24 80 00       	push   $0x802485
  80059c:	6a 55                	push   $0x55
  80059e:	68 53 24 80 00       	push   $0x802453
  8005a3:	e8 33 10 00 00       	call   8015db <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8005a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005af:	f6 c2 02             	test   $0x2,%dl
  8005b2:	75 0c                	jne    8005c0 <fork+0x10c>
  8005b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005bb:	f6 c4 08             	test   $0x8,%ah
  8005be:	74 5b                	je     80061b <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005c0:	83 ec 0c             	sub    $0xc,%esp
  8005c3:	68 05 08 00 00       	push   $0x805
  8005c8:	56                   	push   %esi
  8005c9:	57                   	push   %edi
  8005ca:	56                   	push   %esi
  8005cb:	6a 00                	push   $0x0
  8005cd:	e8 fe fb ff ff       	call   8001d0 <sys_page_map>
		if (r < 0) {
  8005d2:	83 c4 20             	add    $0x20,%esp
  8005d5:	85 c0                	test   %eax,%eax
  8005d7:	79 14                	jns    8005ed <fork+0x139>
		    	panic("sys page map fault %e");
  8005d9:	83 ec 04             	sub    $0x4,%esp
  8005dc:	68 85 24 80 00       	push   $0x802485
  8005e1:	6a 5c                	push   $0x5c
  8005e3:	68 53 24 80 00       	push   $0x802453
  8005e8:	e8 ee 0f 00 00       	call   8015db <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005ed:	83 ec 0c             	sub    $0xc,%esp
  8005f0:	68 05 08 00 00       	push   $0x805
  8005f5:	56                   	push   %esi
  8005f6:	6a 00                	push   $0x0
  8005f8:	56                   	push   %esi
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 d0 fb ff ff       	call   8001d0 <sys_page_map>
		if (r < 0) {
  800600:	83 c4 20             	add    $0x20,%esp
  800603:	85 c0                	test   %eax,%eax
  800605:	79 3e                	jns    800645 <fork+0x191>
		    	panic("sys page map fault %e");
  800607:	83 ec 04             	sub    $0x4,%esp
  80060a:	68 85 24 80 00       	push   $0x802485
  80060f:	6a 60                	push   $0x60
  800611:	68 53 24 80 00       	push   $0x802453
  800616:	e8 c0 0f 00 00       	call   8015db <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80061b:	83 ec 0c             	sub    $0xc,%esp
  80061e:	6a 05                	push   $0x5
  800620:	56                   	push   %esi
  800621:	57                   	push   %edi
  800622:	56                   	push   %esi
  800623:	6a 00                	push   $0x0
  800625:	e8 a6 fb ff ff       	call   8001d0 <sys_page_map>
		if (r < 0) {
  80062a:	83 c4 20             	add    $0x20,%esp
  80062d:	85 c0                	test   %eax,%eax
  80062f:	79 14                	jns    800645 <fork+0x191>
		    	panic("sys page map fault %e");
  800631:	83 ec 04             	sub    $0x4,%esp
  800634:	68 85 24 80 00       	push   $0x802485
  800639:	6a 65                	push   $0x65
  80063b:	68 53 24 80 00       	push   $0x802453
  800640:	e8 96 0f 00 00       	call   8015db <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800645:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80064b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800651:	0f 85 de fe ff ff    	jne    800535 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800657:	a1 04 40 80 00       	mov    0x804004,%eax
  80065c:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	50                   	push   %eax
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800669:	57                   	push   %edi
  80066a:	e8 69 fc ff ff       	call   8002d8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	6a 02                	push   $0x2
  800674:	57                   	push   %edi
  800675:	e8 da fb ff ff       	call   800254 <sys_env_set_status>
	
	return envid;
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80067f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800682:	5b                   	pop    %ebx
  800683:	5e                   	pop    %esi
  800684:	5f                   	pop    %edi
  800685:	5d                   	pop    %ebp
  800686:	c3                   	ret    

00800687 <sfork>:

envid_t
sfork(void)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80068a:	b8 00 00 00 00       	mov    $0x0,%eax
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  800697:	8b 45 08             	mov    0x8(%ebp),%eax
  80069a:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80069f:	68 97 00 80 00       	push   $0x800097
  8006a4:	e8 d5 fc ff ff       	call   80037e <sys_thread_create>

	return id;
}
  8006a9:	c9                   	leave  
  8006aa:	c3                   	ret    

008006ab <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8006b1:	ff 75 08             	pushl  0x8(%ebp)
  8006b4:	e8 e5 fc ff ff       	call   80039e <sys_thread_free>
}
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	c9                   	leave  
  8006bd:	c3                   	ret    

008006be <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8006c4:	ff 75 08             	pushl  0x8(%ebp)
  8006c7:	e8 f2 fc ff ff       	call   8003be <sys_thread_join>
}
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    

008006d1 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	56                   	push   %esi
  8006d5:	53                   	push   %ebx
  8006d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006dc:	83 ec 04             	sub    $0x4,%esp
  8006df:	6a 07                	push   $0x7
  8006e1:	6a 00                	push   $0x0
  8006e3:	56                   	push   %esi
  8006e4:	e8 a4 fa ff ff       	call   80018d <sys_page_alloc>
	if (r < 0) {
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	79 15                	jns    800705 <queue_append+0x34>
		panic("%e\n", r);
  8006f0:	50                   	push   %eax
  8006f1:	68 cb 24 80 00       	push   $0x8024cb
  8006f6:	68 d5 00 00 00       	push   $0xd5
  8006fb:	68 53 24 80 00       	push   $0x802453
  800700:	e8 d6 0e 00 00       	call   8015db <_panic>
	}	

	wt->envid = envid;
  800705:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  80070b:	83 3b 00             	cmpl   $0x0,(%ebx)
  80070e:	75 13                	jne    800723 <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  800710:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800717:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80071e:	00 00 00 
  800721:	eb 1b                	jmp    80073e <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  800723:	8b 43 04             	mov    0x4(%ebx),%eax
  800726:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80072d:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800734:	00 00 00 
		queue->last = wt;
  800737:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80073e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  80074e:	8b 02                	mov    (%edx),%eax
  800750:	85 c0                	test   %eax,%eax
  800752:	75 17                	jne    80076b <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  800754:	83 ec 04             	sub    $0x4,%esp
  800757:	68 9b 24 80 00       	push   $0x80249b
  80075c:	68 ec 00 00 00       	push   $0xec
  800761:	68 53 24 80 00       	push   $0x802453
  800766:	e8 70 0e 00 00       	call   8015db <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  80076b:	8b 48 04             	mov    0x4(%eax),%ecx
  80076e:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  800770:	8b 00                	mov    (%eax),%eax
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	56                   	push   %esi
  800778:	53                   	push   %ebx
  800779:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80077c:	b8 01 00 00 00       	mov    $0x1,%eax
  800781:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800784:	85 c0                	test   %eax,%eax
  800786:	74 4a                	je     8007d2 <mutex_lock+0x5e>
  800788:	8b 73 04             	mov    0x4(%ebx),%esi
  80078b:	83 3e 00             	cmpl   $0x0,(%esi)
  80078e:	75 42                	jne    8007d2 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  800790:	e8 ba f9 ff ff       	call   80014f <sys_getenvid>
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	56                   	push   %esi
  800799:	50                   	push   %eax
  80079a:	e8 32 ff ff ff       	call   8006d1 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80079f:	e8 ab f9 ff ff       	call   80014f <sys_getenvid>
  8007a4:	83 c4 08             	add    $0x8,%esp
  8007a7:	6a 04                	push   $0x4
  8007a9:	50                   	push   %eax
  8007aa:	e8 a5 fa ff ff       	call   800254 <sys_env_set_status>

		if (r < 0) {
  8007af:	83 c4 10             	add    $0x10,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	79 15                	jns    8007cb <mutex_lock+0x57>
			panic("%e\n", r);
  8007b6:	50                   	push   %eax
  8007b7:	68 cb 24 80 00       	push   $0x8024cb
  8007bc:	68 02 01 00 00       	push   $0x102
  8007c1:	68 53 24 80 00       	push   $0x802453
  8007c6:	e8 10 0e 00 00       	call   8015db <_panic>
		}
		sys_yield();
  8007cb:	e8 9e f9 ff ff       	call   80016e <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007d0:	eb 08                	jmp    8007da <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8007d2:	e8 78 f9 ff ff       	call   80014f <sys_getenvid>
  8007d7:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8007da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 04             	sub    $0x4,%esp
  8007e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f0:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8007f3:	8b 43 04             	mov    0x4(%ebx),%eax
  8007f6:	83 38 00             	cmpl   $0x0,(%eax)
  8007f9:	74 33                	je     80082e <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8007fb:	83 ec 0c             	sub    $0xc,%esp
  8007fe:	50                   	push   %eax
  8007ff:	e8 41 ff ff ff       	call   800745 <queue_pop>
  800804:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800807:	83 c4 08             	add    $0x8,%esp
  80080a:	6a 02                	push   $0x2
  80080c:	50                   	push   %eax
  80080d:	e8 42 fa ff ff       	call   800254 <sys_env_set_status>
		if (r < 0) {
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	85 c0                	test   %eax,%eax
  800817:	79 15                	jns    80082e <mutex_unlock+0x4d>
			panic("%e\n", r);
  800819:	50                   	push   %eax
  80081a:	68 cb 24 80 00       	push   $0x8024cb
  80081f:	68 16 01 00 00       	push   $0x116
  800824:	68 53 24 80 00       	push   $0x802453
  800829:	e8 ad 0d 00 00       	call   8015db <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  80082e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800831:	c9                   	leave  
  800832:	c3                   	ret    

00800833 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	83 ec 04             	sub    $0x4,%esp
  80083a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80083d:	e8 0d f9 ff ff       	call   80014f <sys_getenvid>
  800842:	83 ec 04             	sub    $0x4,%esp
  800845:	6a 07                	push   $0x7
  800847:	53                   	push   %ebx
  800848:	50                   	push   %eax
  800849:	e8 3f f9 ff ff       	call   80018d <sys_page_alloc>
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	85 c0                	test   %eax,%eax
  800853:	79 15                	jns    80086a <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800855:	50                   	push   %eax
  800856:	68 b6 24 80 00       	push   $0x8024b6
  80085b:	68 22 01 00 00       	push   $0x122
  800860:	68 53 24 80 00       	push   $0x802453
  800865:	e8 71 0d 00 00       	call   8015db <_panic>
	}	
	mtx->locked = 0;
  80086a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  800870:	8b 43 04             	mov    0x4(%ebx),%eax
  800873:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800879:	8b 43 04             	mov    0x4(%ebx),%eax
  80087c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800883:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80088a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	53                   	push   %ebx
  800893:	83 ec 04             	sub    $0x4,%esp
  800896:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  800899:	eb 21                	jmp    8008bc <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  80089b:	83 ec 0c             	sub    $0xc,%esp
  80089e:	50                   	push   %eax
  80089f:	e8 a1 fe ff ff       	call   800745 <queue_pop>
  8008a4:	83 c4 08             	add    $0x8,%esp
  8008a7:	6a 02                	push   $0x2
  8008a9:	50                   	push   %eax
  8008aa:	e8 a5 f9 ff ff       	call   800254 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  8008af:	8b 43 04             	mov    0x4(%ebx),%eax
  8008b2:	8b 10                	mov    (%eax),%edx
  8008b4:	8b 52 04             	mov    0x4(%edx),%edx
  8008b7:	89 10                	mov    %edx,(%eax)
  8008b9:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8008bc:	8b 43 04             	mov    0x4(%ebx),%eax
  8008bf:	83 38 00             	cmpl   $0x0,(%eax)
  8008c2:	75 d7                	jne    80089b <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008c4:	83 ec 04             	sub    $0x4,%esp
  8008c7:	68 00 10 00 00       	push   $0x1000
  8008cc:	6a 00                	push   $0x0
  8008ce:	53                   	push   %ebx
  8008cf:	e8 aa 14 00 00       	call   801d7e <memset>
	mtx = NULL;
}
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	05 00 00 00 30       	add    $0x30000000,%eax
  8008e7:	c1 e8 0c             	shr    $0xc,%eax
}
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8008f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008fc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800909:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80090e:	89 c2                	mov    %eax,%edx
  800910:	c1 ea 16             	shr    $0x16,%edx
  800913:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80091a:	f6 c2 01             	test   $0x1,%dl
  80091d:	74 11                	je     800930 <fd_alloc+0x2d>
  80091f:	89 c2                	mov    %eax,%edx
  800921:	c1 ea 0c             	shr    $0xc,%edx
  800924:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80092b:	f6 c2 01             	test   $0x1,%dl
  80092e:	75 09                	jne    800939 <fd_alloc+0x36>
			*fd_store = fd;
  800930:	89 01                	mov    %eax,(%ecx)
			return 0;
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
  800937:	eb 17                	jmp    800950 <fd_alloc+0x4d>
  800939:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80093e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800943:	75 c9                	jne    80090e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800945:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80094b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800958:	83 f8 1f             	cmp    $0x1f,%eax
  80095b:	77 36                	ja     800993 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80095d:	c1 e0 0c             	shl    $0xc,%eax
  800960:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800965:	89 c2                	mov    %eax,%edx
  800967:	c1 ea 16             	shr    $0x16,%edx
  80096a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800971:	f6 c2 01             	test   $0x1,%dl
  800974:	74 24                	je     80099a <fd_lookup+0x48>
  800976:	89 c2                	mov    %eax,%edx
  800978:	c1 ea 0c             	shr    $0xc,%edx
  80097b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800982:	f6 c2 01             	test   $0x1,%dl
  800985:	74 1a                	je     8009a1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098a:	89 02                	mov    %eax,(%edx)
	return 0;
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
  800991:	eb 13                	jmp    8009a6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800993:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800998:	eb 0c                	jmp    8009a6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80099a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099f:	eb 05                	jmp    8009a6 <fd_lookup+0x54>
  8009a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b1:	ba 4c 25 80 00       	mov    $0x80254c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009b6:	eb 13                	jmp    8009cb <dev_lookup+0x23>
  8009b8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009bb:	39 08                	cmp    %ecx,(%eax)
  8009bd:	75 0c                	jne    8009cb <dev_lookup+0x23>
			*dev = devtab[i];
  8009bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c9:	eb 31                	jmp    8009fc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009cb:	8b 02                	mov    (%edx),%eax
  8009cd:	85 c0                	test   %eax,%eax
  8009cf:	75 e7                	jne    8009b8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8009d6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009dc:	83 ec 04             	sub    $0x4,%esp
  8009df:	51                   	push   %ecx
  8009e0:	50                   	push   %eax
  8009e1:	68 d0 24 80 00       	push   $0x8024d0
  8009e6:	e8 c9 0c 00 00       	call   8016b4 <cprintf>
	*dev = 0;
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009f4:	83 c4 10             	add    $0x10,%esp
  8009f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	83 ec 10             	sub    $0x10,%esp
  800a06:	8b 75 08             	mov    0x8(%ebp),%esi
  800a09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a0f:	50                   	push   %eax
  800a10:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a16:	c1 e8 0c             	shr    $0xc,%eax
  800a19:	50                   	push   %eax
  800a1a:	e8 33 ff ff ff       	call   800952 <fd_lookup>
  800a1f:	83 c4 08             	add    $0x8,%esp
  800a22:	85 c0                	test   %eax,%eax
  800a24:	78 05                	js     800a2b <fd_close+0x2d>
	    || fd != fd2)
  800a26:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a29:	74 0c                	je     800a37 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a2b:	84 db                	test   %bl,%bl
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	0f 44 c2             	cmove  %edx,%eax
  800a35:	eb 41                	jmp    800a78 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a37:	83 ec 08             	sub    $0x8,%esp
  800a3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a3d:	50                   	push   %eax
  800a3e:	ff 36                	pushl  (%esi)
  800a40:	e8 63 ff ff ff       	call   8009a8 <dev_lookup>
  800a45:	89 c3                	mov    %eax,%ebx
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	85 c0                	test   %eax,%eax
  800a4c:	78 1a                	js     800a68 <fd_close+0x6a>
		if (dev->dev_close)
  800a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a51:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a54:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	74 0b                	je     800a68 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a5d:	83 ec 0c             	sub    $0xc,%esp
  800a60:	56                   	push   %esi
  800a61:	ff d0                	call   *%eax
  800a63:	89 c3                	mov    %eax,%ebx
  800a65:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a68:	83 ec 08             	sub    $0x8,%esp
  800a6b:	56                   	push   %esi
  800a6c:	6a 00                	push   $0x0
  800a6e:	e8 9f f7 ff ff       	call   800212 <sys_page_unmap>
	return r;
  800a73:	83 c4 10             	add    $0x10,%esp
  800a76:	89 d8                	mov    %ebx,%eax
}
  800a78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a88:	50                   	push   %eax
  800a89:	ff 75 08             	pushl  0x8(%ebp)
  800a8c:	e8 c1 fe ff ff       	call   800952 <fd_lookup>
  800a91:	83 c4 08             	add    $0x8,%esp
  800a94:	85 c0                	test   %eax,%eax
  800a96:	78 10                	js     800aa8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a98:	83 ec 08             	sub    $0x8,%esp
  800a9b:	6a 01                	push   $0x1
  800a9d:	ff 75 f4             	pushl  -0xc(%ebp)
  800aa0:	e8 59 ff ff ff       	call   8009fe <fd_close>
  800aa5:	83 c4 10             	add    $0x10,%esp
}
  800aa8:	c9                   	leave  
  800aa9:	c3                   	ret    

00800aaa <close_all>:

void
close_all(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	53                   	push   %ebx
  800aae:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ab1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ab6:	83 ec 0c             	sub    $0xc,%esp
  800ab9:	53                   	push   %ebx
  800aba:	e8 c0 ff ff ff       	call   800a7f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800abf:	83 c3 01             	add    $0x1,%ebx
  800ac2:	83 c4 10             	add    $0x10,%esp
  800ac5:	83 fb 20             	cmp    $0x20,%ebx
  800ac8:	75 ec                	jne    800ab6 <close_all+0xc>
		close(i);
}
  800aca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	83 ec 2c             	sub    $0x2c,%esp
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800adb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ade:	50                   	push   %eax
  800adf:	ff 75 08             	pushl  0x8(%ebp)
  800ae2:	e8 6b fe ff ff       	call   800952 <fd_lookup>
  800ae7:	83 c4 08             	add    $0x8,%esp
  800aea:	85 c0                	test   %eax,%eax
  800aec:	0f 88 c1 00 00 00    	js     800bb3 <dup+0xe4>
		return r;
	close(newfdnum);
  800af2:	83 ec 0c             	sub    $0xc,%esp
  800af5:	56                   	push   %esi
  800af6:	e8 84 ff ff ff       	call   800a7f <close>

	newfd = INDEX2FD(newfdnum);
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	c1 e3 0c             	shl    $0xc,%ebx
  800b00:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b06:	83 c4 04             	add    $0x4,%esp
  800b09:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b0c:	e8 db fd ff ff       	call   8008ec <fd2data>
  800b11:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b13:	89 1c 24             	mov    %ebx,(%esp)
  800b16:	e8 d1 fd ff ff       	call   8008ec <fd2data>
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b21:	89 f8                	mov    %edi,%eax
  800b23:	c1 e8 16             	shr    $0x16,%eax
  800b26:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b2d:	a8 01                	test   $0x1,%al
  800b2f:	74 37                	je     800b68 <dup+0x99>
  800b31:	89 f8                	mov    %edi,%eax
  800b33:	c1 e8 0c             	shr    $0xc,%eax
  800b36:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b3d:	f6 c2 01             	test   $0x1,%dl
  800b40:	74 26                	je     800b68 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b42:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	25 07 0e 00 00       	and    $0xe07,%eax
  800b51:	50                   	push   %eax
  800b52:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b55:	6a 00                	push   $0x0
  800b57:	57                   	push   %edi
  800b58:	6a 00                	push   $0x0
  800b5a:	e8 71 f6 ff ff       	call   8001d0 <sys_page_map>
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	83 c4 20             	add    $0x20,%esp
  800b64:	85 c0                	test   %eax,%eax
  800b66:	78 2e                	js     800b96 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b68:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b6b:	89 d0                	mov    %edx,%eax
  800b6d:	c1 e8 0c             	shr    $0xc,%eax
  800b70:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	25 07 0e 00 00       	and    $0xe07,%eax
  800b7f:	50                   	push   %eax
  800b80:	53                   	push   %ebx
  800b81:	6a 00                	push   $0x0
  800b83:	52                   	push   %edx
  800b84:	6a 00                	push   $0x0
  800b86:	e8 45 f6 ff ff       	call   8001d0 <sys_page_map>
  800b8b:	89 c7                	mov    %eax,%edi
  800b8d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b90:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b92:	85 ff                	test   %edi,%edi
  800b94:	79 1d                	jns    800bb3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b96:	83 ec 08             	sub    $0x8,%esp
  800b99:	53                   	push   %ebx
  800b9a:	6a 00                	push   $0x0
  800b9c:	e8 71 f6 ff ff       	call   800212 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ba1:	83 c4 08             	add    $0x8,%esp
  800ba4:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ba7:	6a 00                	push   $0x0
  800ba9:	e8 64 f6 ff ff       	call   800212 <sys_page_unmap>
	return r;
  800bae:	83 c4 10             	add    $0x10,%esp
  800bb1:	89 f8                	mov    %edi,%eax
}
  800bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 14             	sub    $0x14,%esp
  800bc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bc5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bc8:	50                   	push   %eax
  800bc9:	53                   	push   %ebx
  800bca:	e8 83 fd ff ff       	call   800952 <fd_lookup>
  800bcf:	83 c4 08             	add    $0x8,%esp
  800bd2:	89 c2                	mov    %eax,%edx
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	78 70                	js     800c48 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bd8:	83 ec 08             	sub    $0x8,%esp
  800bdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bde:	50                   	push   %eax
  800bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be2:	ff 30                	pushl  (%eax)
  800be4:	e8 bf fd ff ff       	call   8009a8 <dev_lookup>
  800be9:	83 c4 10             	add    $0x10,%esp
  800bec:	85 c0                	test   %eax,%eax
  800bee:	78 4f                	js     800c3f <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800bf0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bf3:	8b 42 08             	mov    0x8(%edx),%eax
  800bf6:	83 e0 03             	and    $0x3,%eax
  800bf9:	83 f8 01             	cmp    $0x1,%eax
  800bfc:	75 24                	jne    800c22 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bfe:	a1 04 40 80 00       	mov    0x804004,%eax
  800c03:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800c09:	83 ec 04             	sub    $0x4,%esp
  800c0c:	53                   	push   %ebx
  800c0d:	50                   	push   %eax
  800c0e:	68 11 25 80 00       	push   $0x802511
  800c13:	e8 9c 0a 00 00       	call   8016b4 <cprintf>
		return -E_INVAL;
  800c18:	83 c4 10             	add    $0x10,%esp
  800c1b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c20:	eb 26                	jmp    800c48 <read+0x8d>
	}
	if (!dev->dev_read)
  800c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c25:	8b 40 08             	mov    0x8(%eax),%eax
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	74 17                	je     800c43 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c2c:	83 ec 04             	sub    $0x4,%esp
  800c2f:	ff 75 10             	pushl  0x10(%ebp)
  800c32:	ff 75 0c             	pushl  0xc(%ebp)
  800c35:	52                   	push   %edx
  800c36:	ff d0                	call   *%eax
  800c38:	89 c2                	mov    %eax,%edx
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	eb 09                	jmp    800c48 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c3f:	89 c2                	mov    %eax,%edx
  800c41:	eb 05                	jmp    800c48 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c43:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c48:	89 d0                	mov    %edx,%eax
  800c4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	57                   	push   %edi
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c5b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c63:	eb 21                	jmp    800c86 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c65:	83 ec 04             	sub    $0x4,%esp
  800c68:	89 f0                	mov    %esi,%eax
  800c6a:	29 d8                	sub    %ebx,%eax
  800c6c:	50                   	push   %eax
  800c6d:	89 d8                	mov    %ebx,%eax
  800c6f:	03 45 0c             	add    0xc(%ebp),%eax
  800c72:	50                   	push   %eax
  800c73:	57                   	push   %edi
  800c74:	e8 42 ff ff ff       	call   800bbb <read>
		if (m < 0)
  800c79:	83 c4 10             	add    $0x10,%esp
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	78 10                	js     800c90 <readn+0x41>
			return m;
		if (m == 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	74 0a                	je     800c8e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c84:	01 c3                	add    %eax,%ebx
  800c86:	39 f3                	cmp    %esi,%ebx
  800c88:	72 db                	jb     800c65 <readn+0x16>
  800c8a:	89 d8                	mov    %ebx,%eax
  800c8c:	eb 02                	jmp    800c90 <readn+0x41>
  800c8e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 14             	sub    $0x14,%esp
  800c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ca2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ca5:	50                   	push   %eax
  800ca6:	53                   	push   %ebx
  800ca7:	e8 a6 fc ff ff       	call   800952 <fd_lookup>
  800cac:	83 c4 08             	add    $0x8,%esp
  800caf:	89 c2                	mov    %eax,%edx
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	78 6b                	js     800d20 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cb5:	83 ec 08             	sub    $0x8,%esp
  800cb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cbb:	50                   	push   %eax
  800cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cbf:	ff 30                	pushl  (%eax)
  800cc1:	e8 e2 fc ff ff       	call   8009a8 <dev_lookup>
  800cc6:	83 c4 10             	add    $0x10,%esp
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	78 4a                	js     800d17 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cd4:	75 24                	jne    800cfa <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800cd6:	a1 04 40 80 00       	mov    0x804004,%eax
  800cdb:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800ce1:	83 ec 04             	sub    $0x4,%esp
  800ce4:	53                   	push   %ebx
  800ce5:	50                   	push   %eax
  800ce6:	68 2d 25 80 00       	push   $0x80252d
  800ceb:	e8 c4 09 00 00       	call   8016b4 <cprintf>
		return -E_INVAL;
  800cf0:	83 c4 10             	add    $0x10,%esp
  800cf3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800cf8:	eb 26                	jmp    800d20 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800cfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cfd:	8b 52 0c             	mov    0xc(%edx),%edx
  800d00:	85 d2                	test   %edx,%edx
  800d02:	74 17                	je     800d1b <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d04:	83 ec 04             	sub    $0x4,%esp
  800d07:	ff 75 10             	pushl  0x10(%ebp)
  800d0a:	ff 75 0c             	pushl  0xc(%ebp)
  800d0d:	50                   	push   %eax
  800d0e:	ff d2                	call   *%edx
  800d10:	89 c2                	mov    %eax,%edx
  800d12:	83 c4 10             	add    $0x10,%esp
  800d15:	eb 09                	jmp    800d20 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d17:	89 c2                	mov    %eax,%edx
  800d19:	eb 05                	jmp    800d20 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d1b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d20:	89 d0                	mov    %edx,%eax
  800d22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d2d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d30:	50                   	push   %eax
  800d31:	ff 75 08             	pushl  0x8(%ebp)
  800d34:	e8 19 fc ff ff       	call   800952 <fd_lookup>
  800d39:	83 c4 08             	add    $0x8,%esp
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	78 0e                	js     800d4e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d40:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d46:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	53                   	push   %ebx
  800d54:	83 ec 14             	sub    $0x14,%esp
  800d57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d5d:	50                   	push   %eax
  800d5e:	53                   	push   %ebx
  800d5f:	e8 ee fb ff ff       	call   800952 <fd_lookup>
  800d64:	83 c4 08             	add    $0x8,%esp
  800d67:	89 c2                	mov    %eax,%edx
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	78 68                	js     800dd5 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d6d:	83 ec 08             	sub    $0x8,%esp
  800d70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d73:	50                   	push   %eax
  800d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d77:	ff 30                	pushl  (%eax)
  800d79:	e8 2a fc ff ff       	call   8009a8 <dev_lookup>
  800d7e:	83 c4 10             	add    $0x10,%esp
  800d81:	85 c0                	test   %eax,%eax
  800d83:	78 47                	js     800dcc <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d88:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d8c:	75 24                	jne    800db2 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d8e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d93:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d99:	83 ec 04             	sub    $0x4,%esp
  800d9c:	53                   	push   %ebx
  800d9d:	50                   	push   %eax
  800d9e:	68 f0 24 80 00       	push   $0x8024f0
  800da3:	e8 0c 09 00 00       	call   8016b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800db0:	eb 23                	jmp    800dd5 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800db2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800db5:	8b 52 18             	mov    0x18(%edx),%edx
  800db8:	85 d2                	test   %edx,%edx
  800dba:	74 14                	je     800dd0 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800dbc:	83 ec 08             	sub    $0x8,%esp
  800dbf:	ff 75 0c             	pushl  0xc(%ebp)
  800dc2:	50                   	push   %eax
  800dc3:	ff d2                	call   *%edx
  800dc5:	89 c2                	mov    %eax,%edx
  800dc7:	83 c4 10             	add    $0x10,%esp
  800dca:	eb 09                	jmp    800dd5 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dcc:	89 c2                	mov    %eax,%edx
  800dce:	eb 05                	jmp    800dd5 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dd0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dd5:	89 d0                	mov    %edx,%eax
  800dd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 14             	sub    $0x14,%esp
  800de3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800de6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800de9:	50                   	push   %eax
  800dea:	ff 75 08             	pushl  0x8(%ebp)
  800ded:	e8 60 fb ff ff       	call   800952 <fd_lookup>
  800df2:	83 c4 08             	add    $0x8,%esp
  800df5:	89 c2                	mov    %eax,%edx
  800df7:	85 c0                	test   %eax,%eax
  800df9:	78 58                	js     800e53 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dfb:	83 ec 08             	sub    $0x8,%esp
  800dfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e01:	50                   	push   %eax
  800e02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e05:	ff 30                	pushl  (%eax)
  800e07:	e8 9c fb ff ff       	call   8009a8 <dev_lookup>
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	78 37                	js     800e4a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e16:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e1a:	74 32                	je     800e4e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e1c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e1f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e26:	00 00 00 
	stat->st_isdir = 0;
  800e29:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e30:	00 00 00 
	stat->st_dev = dev;
  800e33:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	53                   	push   %ebx
  800e3d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e40:	ff 50 14             	call   *0x14(%eax)
  800e43:	89 c2                	mov    %eax,%edx
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	eb 09                	jmp    800e53 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e4a:	89 c2                	mov    %eax,%edx
  800e4c:	eb 05                	jmp    800e53 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e4e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e53:	89 d0                	mov    %edx,%eax
  800e55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    

00800e5a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	6a 00                	push   $0x0
  800e64:	ff 75 08             	pushl  0x8(%ebp)
  800e67:	e8 e3 01 00 00       	call   80104f <open>
  800e6c:	89 c3                	mov    %eax,%ebx
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	85 c0                	test   %eax,%eax
  800e73:	78 1b                	js     800e90 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e75:	83 ec 08             	sub    $0x8,%esp
  800e78:	ff 75 0c             	pushl  0xc(%ebp)
  800e7b:	50                   	push   %eax
  800e7c:	e8 5b ff ff ff       	call   800ddc <fstat>
  800e81:	89 c6                	mov    %eax,%esi
	close(fd);
  800e83:	89 1c 24             	mov    %ebx,(%esp)
  800e86:	e8 f4 fb ff ff       	call   800a7f <close>
	return r;
  800e8b:	83 c4 10             	add    $0x10,%esp
  800e8e:	89 f0                	mov    %esi,%eax
}
  800e90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	89 c6                	mov    %eax,%esi
  800e9e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800ea0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ea7:	75 12                	jne    800ebb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ea9:	83 ec 0c             	sub    $0xc,%esp
  800eac:	6a 01                	push   $0x1
  800eae:	e8 39 12 00 00       	call   8020ec <ipc_find_env>
  800eb3:	a3 00 40 80 00       	mov    %eax,0x804000
  800eb8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ebb:	6a 07                	push   $0x7
  800ebd:	68 00 50 80 00       	push   $0x805000
  800ec2:	56                   	push   %esi
  800ec3:	ff 35 00 40 80 00    	pushl  0x804000
  800ec9:	e8 bc 11 00 00       	call   80208a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ece:	83 c4 0c             	add    $0xc,%esp
  800ed1:	6a 00                	push   $0x0
  800ed3:	53                   	push   %ebx
  800ed4:	6a 00                	push   $0x0
  800ed6:	e8 34 11 00 00       	call   80200f <ipc_recv>
}
  800edb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ede:	5b                   	pop    %ebx
  800edf:	5e                   	pop    %esi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eeb:	8b 40 0c             	mov    0xc(%eax),%eax
  800eee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800efb:	ba 00 00 00 00       	mov    $0x0,%edx
  800f00:	b8 02 00 00 00       	mov    $0x2,%eax
  800f05:	e8 8d ff ff ff       	call   800e97 <fsipc>
}
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
  800f15:	8b 40 0c             	mov    0xc(%eax),%eax
  800f18:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f22:	b8 06 00 00 00       	mov    $0x6,%eax
  800f27:	e8 6b ff ff ff       	call   800e97 <fsipc>
}
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    

00800f2e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	53                   	push   %ebx
  800f32:	83 ec 04             	sub    $0x4,%esp
  800f35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3b:	8b 40 0c             	mov    0xc(%eax),%eax
  800f3e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f43:	ba 00 00 00 00       	mov    $0x0,%edx
  800f48:	b8 05 00 00 00       	mov    $0x5,%eax
  800f4d:	e8 45 ff ff ff       	call   800e97 <fsipc>
  800f52:	85 c0                	test   %eax,%eax
  800f54:	78 2c                	js     800f82 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f56:	83 ec 08             	sub    $0x8,%esp
  800f59:	68 00 50 80 00       	push   $0x805000
  800f5e:	53                   	push   %ebx
  800f5f:	e8 d5 0c 00 00       	call   801c39 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f64:	a1 80 50 80 00       	mov    0x805080,%eax
  800f69:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f6f:	a1 84 50 80 00       	mov    0x805084,%eax
  800f74:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f90:	8b 55 08             	mov    0x8(%ebp),%edx
  800f93:	8b 52 0c             	mov    0xc(%edx),%edx
  800f96:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f9c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800fa1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800fa6:	0f 47 c2             	cmova  %edx,%eax
  800fa9:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800fae:	50                   	push   %eax
  800faf:	ff 75 0c             	pushl  0xc(%ebp)
  800fb2:	68 08 50 80 00       	push   $0x805008
  800fb7:	e8 0f 0e 00 00       	call   801dcb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc1:	b8 04 00 00 00       	mov    $0x4,%eax
  800fc6:	e8 cc fe ff ff       	call   800e97 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    

00800fcd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	56                   	push   %esi
  800fd1:	53                   	push   %ebx
  800fd2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd8:	8b 40 0c             	mov    0xc(%eax),%eax
  800fdb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fe0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fe6:	ba 00 00 00 00       	mov    $0x0,%edx
  800feb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ff0:	e8 a2 fe ff ff       	call   800e97 <fsipc>
  800ff5:	89 c3                	mov    %eax,%ebx
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	78 4b                	js     801046 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ffb:	39 c6                	cmp    %eax,%esi
  800ffd:	73 16                	jae    801015 <devfile_read+0x48>
  800fff:	68 5c 25 80 00       	push   $0x80255c
  801004:	68 63 25 80 00       	push   $0x802563
  801009:	6a 7c                	push   $0x7c
  80100b:	68 78 25 80 00       	push   $0x802578
  801010:	e8 c6 05 00 00       	call   8015db <_panic>
	assert(r <= PGSIZE);
  801015:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80101a:	7e 16                	jle    801032 <devfile_read+0x65>
  80101c:	68 83 25 80 00       	push   $0x802583
  801021:	68 63 25 80 00       	push   $0x802563
  801026:	6a 7d                	push   $0x7d
  801028:	68 78 25 80 00       	push   $0x802578
  80102d:	e8 a9 05 00 00       	call   8015db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801032:	83 ec 04             	sub    $0x4,%esp
  801035:	50                   	push   %eax
  801036:	68 00 50 80 00       	push   $0x805000
  80103b:	ff 75 0c             	pushl  0xc(%ebp)
  80103e:	e8 88 0d 00 00       	call   801dcb <memmove>
	return r;
  801043:	83 c4 10             	add    $0x10,%esp
}
  801046:	89 d8                	mov    %ebx,%eax
  801048:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	53                   	push   %ebx
  801053:	83 ec 20             	sub    $0x20,%esp
  801056:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801059:	53                   	push   %ebx
  80105a:	e8 a1 0b 00 00       	call   801c00 <strlen>
  80105f:	83 c4 10             	add    $0x10,%esp
  801062:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801067:	7f 67                	jg     8010d0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801069:	83 ec 0c             	sub    $0xc,%esp
  80106c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106f:	50                   	push   %eax
  801070:	e8 8e f8 ff ff       	call   800903 <fd_alloc>
  801075:	83 c4 10             	add    $0x10,%esp
		return r;
  801078:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80107a:	85 c0                	test   %eax,%eax
  80107c:	78 57                	js     8010d5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80107e:	83 ec 08             	sub    $0x8,%esp
  801081:	53                   	push   %ebx
  801082:	68 00 50 80 00       	push   $0x805000
  801087:	e8 ad 0b 00 00       	call   801c39 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80108c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801094:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801097:	b8 01 00 00 00       	mov    $0x1,%eax
  80109c:	e8 f6 fd ff ff       	call   800e97 <fsipc>
  8010a1:	89 c3                	mov    %eax,%ebx
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 14                	jns    8010be <open+0x6f>
		fd_close(fd, 0);
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	6a 00                	push   $0x0
  8010af:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b2:	e8 47 f9 ff ff       	call   8009fe <fd_close>
		return r;
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	89 da                	mov    %ebx,%edx
  8010bc:	eb 17                	jmp    8010d5 <open+0x86>
	}

	return fd2num(fd);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8010c4:	e8 13 f8 ff ff       	call   8008dc <fd2num>
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	eb 05                	jmp    8010d5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010d0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010d5:	89 d0                	mov    %edx,%eax
  8010d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e7:	b8 08 00 00 00       	mov    $0x8,%eax
  8010ec:	e8 a6 fd ff ff       	call   800e97 <fsipc>
}
  8010f1:	c9                   	leave  
  8010f2:	c3                   	ret    

008010f3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	ff 75 08             	pushl  0x8(%ebp)
  801101:	e8 e6 f7 ff ff       	call   8008ec <fd2data>
  801106:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801108:	83 c4 08             	add    $0x8,%esp
  80110b:	68 8f 25 80 00       	push   $0x80258f
  801110:	53                   	push   %ebx
  801111:	e8 23 0b 00 00       	call   801c39 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801116:	8b 46 04             	mov    0x4(%esi),%eax
  801119:	2b 06                	sub    (%esi),%eax
  80111b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801121:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801128:	00 00 00 
	stat->st_dev = &devpipe;
  80112b:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801132:	30 80 00 
	return 0;
}
  801135:	b8 00 00 00 00       	mov    $0x0,%eax
  80113a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	53                   	push   %ebx
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80114b:	53                   	push   %ebx
  80114c:	6a 00                	push   $0x0
  80114e:	e8 bf f0 ff ff       	call   800212 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801153:	89 1c 24             	mov    %ebx,(%esp)
  801156:	e8 91 f7 ff ff       	call   8008ec <fd2data>
  80115b:	83 c4 08             	add    $0x8,%esp
  80115e:	50                   	push   %eax
  80115f:	6a 00                	push   $0x0
  801161:	e8 ac f0 ff ff       	call   800212 <sys_page_unmap>
}
  801166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801169:	c9                   	leave  
  80116a:	c3                   	ret    

0080116b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	57                   	push   %edi
  80116f:	56                   	push   %esi
  801170:	53                   	push   %ebx
  801171:	83 ec 1c             	sub    $0x1c,%esp
  801174:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801177:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801179:	a1 04 40 80 00       	mov    0x804004,%eax
  80117e:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	ff 75 e0             	pushl  -0x20(%ebp)
  80118a:	e8 a2 0f 00 00       	call   802131 <pageref>
  80118f:	89 c3                	mov    %eax,%ebx
  801191:	89 3c 24             	mov    %edi,(%esp)
  801194:	e8 98 0f 00 00       	call   802131 <pageref>
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	39 c3                	cmp    %eax,%ebx
  80119e:	0f 94 c1             	sete   %cl
  8011a1:	0f b6 c9             	movzbl %cl,%ecx
  8011a4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8011a7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011ad:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011b3:	39 ce                	cmp    %ecx,%esi
  8011b5:	74 1e                	je     8011d5 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011b7:	39 c3                	cmp    %eax,%ebx
  8011b9:	75 be                	jne    801179 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011bb:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c4:	50                   	push   %eax
  8011c5:	56                   	push   %esi
  8011c6:	68 96 25 80 00       	push   $0x802596
  8011cb:	e8 e4 04 00 00       	call   8016b4 <cprintf>
  8011d0:	83 c4 10             	add    $0x10,%esp
  8011d3:	eb a4                	jmp    801179 <_pipeisclosed+0xe>
	}
}
  8011d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5f                   	pop    %edi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 28             	sub    $0x28,%esp
  8011e9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011ec:	56                   	push   %esi
  8011ed:	e8 fa f6 ff ff       	call   8008ec <fd2data>
  8011f2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8011fc:	eb 4b                	jmp    801249 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011fe:	89 da                	mov    %ebx,%edx
  801200:	89 f0                	mov    %esi,%eax
  801202:	e8 64 ff ff ff       	call   80116b <_pipeisclosed>
  801207:	85 c0                	test   %eax,%eax
  801209:	75 48                	jne    801253 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80120b:	e8 5e ef ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801210:	8b 43 04             	mov    0x4(%ebx),%eax
  801213:	8b 0b                	mov    (%ebx),%ecx
  801215:	8d 51 20             	lea    0x20(%ecx),%edx
  801218:	39 d0                	cmp    %edx,%eax
  80121a:	73 e2                	jae    8011fe <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80121c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801223:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801226:	89 c2                	mov    %eax,%edx
  801228:	c1 fa 1f             	sar    $0x1f,%edx
  80122b:	89 d1                	mov    %edx,%ecx
  80122d:	c1 e9 1b             	shr    $0x1b,%ecx
  801230:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801233:	83 e2 1f             	and    $0x1f,%edx
  801236:	29 ca                	sub    %ecx,%edx
  801238:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80123c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801240:	83 c0 01             	add    $0x1,%eax
  801243:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801246:	83 c7 01             	add    $0x1,%edi
  801249:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80124c:	75 c2                	jne    801210 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80124e:	8b 45 10             	mov    0x10(%ebp),%eax
  801251:	eb 05                	jmp    801258 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801258:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125b:	5b                   	pop    %ebx
  80125c:	5e                   	pop    %esi
  80125d:	5f                   	pop    %edi
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	53                   	push   %ebx
  801266:	83 ec 18             	sub    $0x18,%esp
  801269:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80126c:	57                   	push   %edi
  80126d:	e8 7a f6 ff ff       	call   8008ec <fd2data>
  801272:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127c:	eb 3d                	jmp    8012bb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80127e:	85 db                	test   %ebx,%ebx
  801280:	74 04                	je     801286 <devpipe_read+0x26>
				return i;
  801282:	89 d8                	mov    %ebx,%eax
  801284:	eb 44                	jmp    8012ca <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801286:	89 f2                	mov    %esi,%edx
  801288:	89 f8                	mov    %edi,%eax
  80128a:	e8 dc fe ff ff       	call   80116b <_pipeisclosed>
  80128f:	85 c0                	test   %eax,%eax
  801291:	75 32                	jne    8012c5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801293:	e8 d6 ee ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801298:	8b 06                	mov    (%esi),%eax
  80129a:	3b 46 04             	cmp    0x4(%esi),%eax
  80129d:	74 df                	je     80127e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80129f:	99                   	cltd   
  8012a0:	c1 ea 1b             	shr    $0x1b,%edx
  8012a3:	01 d0                	add    %edx,%eax
  8012a5:	83 e0 1f             	and    $0x1f,%eax
  8012a8:	29 d0                	sub    %edx,%eax
  8012aa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8012af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012b5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012b8:	83 c3 01             	add    $0x1,%ebx
  8012bb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012be:	75 d8                	jne    801298 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c3:	eb 05                	jmp    8012ca <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	56                   	push   %esi
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012dd:	50                   	push   %eax
  8012de:	e8 20 f6 ff ff       	call   800903 <fd_alloc>
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	89 c2                	mov    %eax,%edx
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	0f 88 2c 01 00 00    	js     80141c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012f0:	83 ec 04             	sub    $0x4,%esp
  8012f3:	68 07 04 00 00       	push   $0x407
  8012f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012fb:	6a 00                	push   $0x0
  8012fd:	e8 8b ee ff ff       	call   80018d <sys_page_alloc>
  801302:	83 c4 10             	add    $0x10,%esp
  801305:	89 c2                	mov    %eax,%edx
  801307:	85 c0                	test   %eax,%eax
  801309:	0f 88 0d 01 00 00    	js     80141c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801315:	50                   	push   %eax
  801316:	e8 e8 f5 ff ff       	call   800903 <fd_alloc>
  80131b:	89 c3                	mov    %eax,%ebx
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	0f 88 e2 00 00 00    	js     80140a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801328:	83 ec 04             	sub    $0x4,%esp
  80132b:	68 07 04 00 00       	push   $0x407
  801330:	ff 75 f0             	pushl  -0x10(%ebp)
  801333:	6a 00                	push   $0x0
  801335:	e8 53 ee ff ff       	call   80018d <sys_page_alloc>
  80133a:	89 c3                	mov    %eax,%ebx
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	85 c0                	test   %eax,%eax
  801341:	0f 88 c3 00 00 00    	js     80140a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801347:	83 ec 0c             	sub    $0xc,%esp
  80134a:	ff 75 f4             	pushl  -0xc(%ebp)
  80134d:	e8 9a f5 ff ff       	call   8008ec <fd2data>
  801352:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801354:	83 c4 0c             	add    $0xc,%esp
  801357:	68 07 04 00 00       	push   $0x407
  80135c:	50                   	push   %eax
  80135d:	6a 00                	push   $0x0
  80135f:	e8 29 ee ff ff       	call   80018d <sys_page_alloc>
  801364:	89 c3                	mov    %eax,%ebx
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	85 c0                	test   %eax,%eax
  80136b:	0f 88 89 00 00 00    	js     8013fa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	ff 75 f0             	pushl  -0x10(%ebp)
  801377:	e8 70 f5 ff ff       	call   8008ec <fd2data>
  80137c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801383:	50                   	push   %eax
  801384:	6a 00                	push   $0x0
  801386:	56                   	push   %esi
  801387:	6a 00                	push   $0x0
  801389:	e8 42 ee ff ff       	call   8001d0 <sys_page_map>
  80138e:	89 c3                	mov    %eax,%ebx
  801390:	83 c4 20             	add    $0x20,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	78 55                	js     8013ec <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801397:	8b 15 24 30 80 00    	mov    0x803024,%edx
  80139d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8013a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013ac:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8013b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013c1:	83 ec 0c             	sub    $0xc,%esp
  8013c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c7:	e8 10 f5 ff ff       	call   8008dc <fd2num>
  8013cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013cf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013d1:	83 c4 04             	add    $0x4,%esp
  8013d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8013d7:	e8 00 f5 ff ff       	call   8008dc <fd2num>
  8013dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013df:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ea:	eb 30                	jmp    80141c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	56                   	push   %esi
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 1b ee ff ff       	call   800212 <sys_page_unmap>
  8013f7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	ff 75 f0             	pushl  -0x10(%ebp)
  801400:	6a 00                	push   $0x0
  801402:	e8 0b ee ff ff       	call   800212 <sys_page_unmap>
  801407:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	ff 75 f4             	pushl  -0xc(%ebp)
  801410:	6a 00                	push   $0x0
  801412:	e8 fb ed ff ff       	call   800212 <sys_page_unmap>
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80141c:	89 d0                	mov    %edx,%eax
  80141e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80142b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	ff 75 08             	pushl  0x8(%ebp)
  801432:	e8 1b f5 ff ff       	call   800952 <fd_lookup>
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 18                	js     801456 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80143e:	83 ec 0c             	sub    $0xc,%esp
  801441:	ff 75 f4             	pushl  -0xc(%ebp)
  801444:	e8 a3 f4 ff ff       	call   8008ec <fd2data>
	return _pipeisclosed(fd, p);
  801449:	89 c2                	mov    %eax,%edx
  80144b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144e:	e8 18 fd ff ff       	call   80116b <_pipeisclosed>
  801453:	83 c4 10             	add    $0x10,%esp
}
  801456:	c9                   	leave  
  801457:	c3                   	ret    

00801458 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    

00801462 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801468:	68 ae 25 80 00       	push   $0x8025ae
  80146d:	ff 75 0c             	pushl  0xc(%ebp)
  801470:	e8 c4 07 00 00       	call   801c39 <strcpy>
	return 0;
}
  801475:	b8 00 00 00 00       	mov    $0x0,%eax
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	57                   	push   %edi
  801480:	56                   	push   %esi
  801481:	53                   	push   %ebx
  801482:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801488:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80148d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801493:	eb 2d                	jmp    8014c2 <devcons_write+0x46>
		m = n - tot;
  801495:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801498:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80149a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80149d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8014a2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	53                   	push   %ebx
  8014a9:	03 45 0c             	add    0xc(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	57                   	push   %edi
  8014ae:	e8 18 09 00 00       	call   801dcb <memmove>
		sys_cputs(buf, m);
  8014b3:	83 c4 08             	add    $0x8,%esp
  8014b6:	53                   	push   %ebx
  8014b7:	57                   	push   %edi
  8014b8:	e8 14 ec ff ff       	call   8000d1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014bd:	01 de                	add    %ebx,%esi
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	89 f0                	mov    %esi,%eax
  8014c4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014c7:	72 cc                	jb     801495 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014cc:	5b                   	pop    %ebx
  8014cd:	5e                   	pop    %esi
  8014ce:	5f                   	pop    %edi
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    

008014d1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014e0:	74 2a                	je     80150c <devcons_read+0x3b>
  8014e2:	eb 05                	jmp    8014e9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014e4:	e8 85 ec ff ff       	call   80016e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014e9:	e8 01 ec ff ff       	call   8000ef <sys_cgetc>
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	74 f2                	je     8014e4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 16                	js     80150c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014f6:	83 f8 04             	cmp    $0x4,%eax
  8014f9:	74 0c                	je     801507 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014fe:	88 02                	mov    %al,(%edx)
	return 1;
  801500:	b8 01 00 00 00       	mov    $0x1,%eax
  801505:	eb 05                	jmp    80150c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801507:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801514:	8b 45 08             	mov    0x8(%ebp),%eax
  801517:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80151a:	6a 01                	push   $0x1
  80151c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	e8 ac eb ff ff       	call   8000d1 <sys_cputs>
}
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <getchar>:

int
getchar(void)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801530:	6a 01                	push   $0x1
  801532:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801535:	50                   	push   %eax
  801536:	6a 00                	push   $0x0
  801538:	e8 7e f6 ff ff       	call   800bbb <read>
	if (r < 0)
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 0f                	js     801553 <getchar+0x29>
		return r;
	if (r < 1)
  801544:	85 c0                	test   %eax,%eax
  801546:	7e 06                	jle    80154e <getchar+0x24>
		return -E_EOF;
	return c;
  801548:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80154c:	eb 05                	jmp    801553 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80154e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801553:	c9                   	leave  
  801554:	c3                   	ret    

00801555 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155e:	50                   	push   %eax
  80155f:	ff 75 08             	pushl  0x8(%ebp)
  801562:	e8 eb f3 ff ff       	call   800952 <fd_lookup>
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 11                	js     80157f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80156e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801571:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801577:	39 10                	cmp    %edx,(%eax)
  801579:	0f 94 c0             	sete   %al
  80157c:	0f b6 c0             	movzbl %al,%eax
}
  80157f:	c9                   	leave  
  801580:	c3                   	ret    

00801581 <opencons>:

int
opencons(void)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801587:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	e8 73 f3 ff ff       	call   800903 <fd_alloc>
  801590:	83 c4 10             	add    $0x10,%esp
		return r;
  801593:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801595:	85 c0                	test   %eax,%eax
  801597:	78 3e                	js     8015d7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	68 07 04 00 00       	push   $0x407
  8015a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a4:	6a 00                	push   $0x0
  8015a6:	e8 e2 eb ff ff       	call   80018d <sys_page_alloc>
  8015ab:	83 c4 10             	add    $0x10,%esp
		return r;
  8015ae:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 23                	js     8015d7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015b4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8015ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	50                   	push   %eax
  8015cd:	e8 0a f3 ff ff       	call   8008dc <fd2num>
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	83 c4 10             	add    $0x10,%esp
}
  8015d7:	89 d0                	mov    %edx,%eax
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	56                   	push   %esi
  8015df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015e3:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8015e9:	e8 61 eb ff ff       	call   80014f <sys_getenvid>
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	ff 75 0c             	pushl  0xc(%ebp)
  8015f4:	ff 75 08             	pushl  0x8(%ebp)
  8015f7:	56                   	push   %esi
  8015f8:	50                   	push   %eax
  8015f9:	68 bc 25 80 00       	push   $0x8025bc
  8015fe:	e8 b1 00 00 00       	call   8016b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801603:	83 c4 18             	add    $0x18,%esp
  801606:	53                   	push   %ebx
  801607:	ff 75 10             	pushl  0x10(%ebp)
  80160a:	e8 54 00 00 00       	call   801663 <vcprintf>
	cprintf("\n");
  80160f:	c7 04 24 b4 24 80 00 	movl   $0x8024b4,(%esp)
  801616:	e8 99 00 00 00       	call   8016b4 <cprintf>
  80161b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80161e:	cc                   	int3   
  80161f:	eb fd                	jmp    80161e <_panic+0x43>

00801621 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	53                   	push   %ebx
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80162b:	8b 13                	mov    (%ebx),%edx
  80162d:	8d 42 01             	lea    0x1(%edx),%eax
  801630:	89 03                	mov    %eax,(%ebx)
  801632:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801635:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801639:	3d ff 00 00 00       	cmp    $0xff,%eax
  80163e:	75 1a                	jne    80165a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801640:	83 ec 08             	sub    $0x8,%esp
  801643:	68 ff 00 00 00       	push   $0xff
  801648:	8d 43 08             	lea    0x8(%ebx),%eax
  80164b:	50                   	push   %eax
  80164c:	e8 80 ea ff ff       	call   8000d1 <sys_cputs>
		b->idx = 0;
  801651:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801657:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80165a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80165e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80166c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801673:	00 00 00 
	b.cnt = 0;
  801676:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80167d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801680:	ff 75 0c             	pushl  0xc(%ebp)
  801683:	ff 75 08             	pushl  0x8(%ebp)
  801686:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80168c:	50                   	push   %eax
  80168d:	68 21 16 80 00       	push   $0x801621
  801692:	e8 54 01 00 00       	call   8017eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801697:	83 c4 08             	add    $0x8,%esp
  80169a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8016a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	e8 25 ea ff ff       	call   8000d1 <sys_cputs>

	return b.cnt;
}
  8016ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016bd:	50                   	push   %eax
  8016be:	ff 75 08             	pushl  0x8(%ebp)
  8016c1:	e8 9d ff ff ff       	call   801663 <vcprintf>
	va_end(ap);

	return cnt;
}
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	57                   	push   %edi
  8016cc:	56                   	push   %esi
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 1c             	sub    $0x1c,%esp
  8016d1:	89 c7                	mov    %eax,%edi
  8016d3:	89 d6                	mov    %edx,%esi
  8016d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016ef:	39 d3                	cmp    %edx,%ebx
  8016f1:	72 05                	jb     8016f8 <printnum+0x30>
  8016f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016f6:	77 45                	ja     80173d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	ff 75 18             	pushl  0x18(%ebp)
  8016fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801701:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801704:	53                   	push   %ebx
  801705:	ff 75 10             	pushl  0x10(%ebp)
  801708:	83 ec 08             	sub    $0x8,%esp
  80170b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80170e:	ff 75 e0             	pushl  -0x20(%ebp)
  801711:	ff 75 dc             	pushl  -0x24(%ebp)
  801714:	ff 75 d8             	pushl  -0x28(%ebp)
  801717:	e8 54 0a 00 00       	call   802170 <__udivdi3>
  80171c:	83 c4 18             	add    $0x18,%esp
  80171f:	52                   	push   %edx
  801720:	50                   	push   %eax
  801721:	89 f2                	mov    %esi,%edx
  801723:	89 f8                	mov    %edi,%eax
  801725:	e8 9e ff ff ff       	call   8016c8 <printnum>
  80172a:	83 c4 20             	add    $0x20,%esp
  80172d:	eb 18                	jmp    801747 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80172f:	83 ec 08             	sub    $0x8,%esp
  801732:	56                   	push   %esi
  801733:	ff 75 18             	pushl  0x18(%ebp)
  801736:	ff d7                	call   *%edi
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	eb 03                	jmp    801740 <printnum+0x78>
  80173d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801740:	83 eb 01             	sub    $0x1,%ebx
  801743:	85 db                	test   %ebx,%ebx
  801745:	7f e8                	jg     80172f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801747:	83 ec 08             	sub    $0x8,%esp
  80174a:	56                   	push   %esi
  80174b:	83 ec 04             	sub    $0x4,%esp
  80174e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801751:	ff 75 e0             	pushl  -0x20(%ebp)
  801754:	ff 75 dc             	pushl  -0x24(%ebp)
  801757:	ff 75 d8             	pushl  -0x28(%ebp)
  80175a:	e8 41 0b 00 00       	call   8022a0 <__umoddi3>
  80175f:	83 c4 14             	add    $0x14,%esp
  801762:	0f be 80 df 25 80 00 	movsbl 0x8025df(%eax),%eax
  801769:	50                   	push   %eax
  80176a:	ff d7                	call   *%edi
}
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801772:	5b                   	pop    %ebx
  801773:	5e                   	pop    %esi
  801774:	5f                   	pop    %edi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80177a:	83 fa 01             	cmp    $0x1,%edx
  80177d:	7e 0e                	jle    80178d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80177f:	8b 10                	mov    (%eax),%edx
  801781:	8d 4a 08             	lea    0x8(%edx),%ecx
  801784:	89 08                	mov    %ecx,(%eax)
  801786:	8b 02                	mov    (%edx),%eax
  801788:	8b 52 04             	mov    0x4(%edx),%edx
  80178b:	eb 22                	jmp    8017af <getuint+0x38>
	else if (lflag)
  80178d:	85 d2                	test   %edx,%edx
  80178f:	74 10                	je     8017a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801791:	8b 10                	mov    (%eax),%edx
  801793:	8d 4a 04             	lea    0x4(%edx),%ecx
  801796:	89 08                	mov    %ecx,(%eax)
  801798:	8b 02                	mov    (%edx),%eax
  80179a:	ba 00 00 00 00       	mov    $0x0,%edx
  80179f:	eb 0e                	jmp    8017af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8017a1:	8b 10                	mov    (%eax),%edx
  8017a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017a6:	89 08                	mov    %ecx,(%eax)
  8017a8:	8b 02                	mov    (%edx),%eax
  8017aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    

008017b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017bb:	8b 10                	mov    (%eax),%edx
  8017bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8017c0:	73 0a                	jae    8017cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8017c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017c5:	89 08                	mov    %ecx,(%eax)
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	88 02                	mov    %al,(%edx)
}
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017d7:	50                   	push   %eax
  8017d8:	ff 75 10             	pushl  0x10(%ebp)
  8017db:	ff 75 0c             	pushl  0xc(%ebp)
  8017de:	ff 75 08             	pushl  0x8(%ebp)
  8017e1:	e8 05 00 00 00       	call   8017eb <vprintfmt>
	va_end(ap);
}
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	c9                   	leave  
  8017ea:	c3                   	ret    

008017eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	57                   	push   %edi
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
  8017f1:	83 ec 2c             	sub    $0x2c,%esp
  8017f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017fd:	eb 12                	jmp    801811 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017ff:	85 c0                	test   %eax,%eax
  801801:	0f 84 89 03 00 00    	je     801b90 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	53                   	push   %ebx
  80180b:	50                   	push   %eax
  80180c:	ff d6                	call   *%esi
  80180e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801811:	83 c7 01             	add    $0x1,%edi
  801814:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801818:	83 f8 25             	cmp    $0x25,%eax
  80181b:	75 e2                	jne    8017ff <vprintfmt+0x14>
  80181d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801821:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801828:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80182f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801836:	ba 00 00 00 00       	mov    $0x0,%edx
  80183b:	eb 07                	jmp    801844 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801840:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801844:	8d 47 01             	lea    0x1(%edi),%eax
  801847:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80184a:	0f b6 07             	movzbl (%edi),%eax
  80184d:	0f b6 c8             	movzbl %al,%ecx
  801850:	83 e8 23             	sub    $0x23,%eax
  801853:	3c 55                	cmp    $0x55,%al
  801855:	0f 87 1a 03 00 00    	ja     801b75 <vprintfmt+0x38a>
  80185b:	0f b6 c0             	movzbl %al,%eax
  80185e:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  801865:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801868:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80186c:	eb d6                	jmp    801844 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801871:	b8 00 00 00 00       	mov    $0x0,%eax
  801876:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801879:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80187c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801880:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801883:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801886:	83 fa 09             	cmp    $0x9,%edx
  801889:	77 39                	ja     8018c4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80188b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80188e:	eb e9                	jmp    801879 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801890:	8b 45 14             	mov    0x14(%ebp),%eax
  801893:	8d 48 04             	lea    0x4(%eax),%ecx
  801896:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801899:	8b 00                	mov    (%eax),%eax
  80189b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8018a1:	eb 27                	jmp    8018ca <vprintfmt+0xdf>
  8018a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018ad:	0f 49 c8             	cmovns %eax,%ecx
  8018b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018b6:	eb 8c                	jmp    801844 <vprintfmt+0x59>
  8018b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018c2:	eb 80                	jmp    801844 <vprintfmt+0x59>
  8018c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018c7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018ce:	0f 89 70 ff ff ff    	jns    801844 <vprintfmt+0x59>
				width = precision, precision = -1;
  8018d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018e1:	e9 5e ff ff ff       	jmp    801844 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018ec:	e9 53 ff ff ff       	jmp    801844 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f4:	8d 50 04             	lea    0x4(%eax),%edx
  8018f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	53                   	push   %ebx
  8018fe:	ff 30                	pushl  (%eax)
  801900:	ff d6                	call   *%esi
			break;
  801902:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801905:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801908:	e9 04 ff ff ff       	jmp    801811 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80190d:	8b 45 14             	mov    0x14(%ebp),%eax
  801910:	8d 50 04             	lea    0x4(%eax),%edx
  801913:	89 55 14             	mov    %edx,0x14(%ebp)
  801916:	8b 00                	mov    (%eax),%eax
  801918:	99                   	cltd   
  801919:	31 d0                	xor    %edx,%eax
  80191b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80191d:	83 f8 0f             	cmp    $0xf,%eax
  801920:	7f 0b                	jg     80192d <vprintfmt+0x142>
  801922:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  801929:	85 d2                	test   %edx,%edx
  80192b:	75 18                	jne    801945 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80192d:	50                   	push   %eax
  80192e:	68 f7 25 80 00       	push   $0x8025f7
  801933:	53                   	push   %ebx
  801934:	56                   	push   %esi
  801935:	e8 94 fe ff ff       	call   8017ce <printfmt>
  80193a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80193d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801940:	e9 cc fe ff ff       	jmp    801811 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801945:	52                   	push   %edx
  801946:	68 75 25 80 00       	push   $0x802575
  80194b:	53                   	push   %ebx
  80194c:	56                   	push   %esi
  80194d:	e8 7c fe ff ff       	call   8017ce <printfmt>
  801952:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801955:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801958:	e9 b4 fe ff ff       	jmp    801811 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80195d:	8b 45 14             	mov    0x14(%ebp),%eax
  801960:	8d 50 04             	lea    0x4(%eax),%edx
  801963:	89 55 14             	mov    %edx,0x14(%ebp)
  801966:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801968:	85 ff                	test   %edi,%edi
  80196a:	b8 f0 25 80 00       	mov    $0x8025f0,%eax
  80196f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801972:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801976:	0f 8e 94 00 00 00    	jle    801a10 <vprintfmt+0x225>
  80197c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801980:	0f 84 98 00 00 00    	je     801a1e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	ff 75 d0             	pushl  -0x30(%ebp)
  80198c:	57                   	push   %edi
  80198d:	e8 86 02 00 00       	call   801c18 <strnlen>
  801992:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801995:	29 c1                	sub    %eax,%ecx
  801997:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80199a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80199d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8019a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8019a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a9:	eb 0f                	jmp    8019ba <vprintfmt+0x1cf>
					putch(padc, putdat);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	53                   	push   %ebx
  8019af:	ff 75 e0             	pushl  -0x20(%ebp)
  8019b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019b4:	83 ef 01             	sub    $0x1,%edi
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	85 ff                	test   %edi,%edi
  8019bc:	7f ed                	jg     8019ab <vprintfmt+0x1c0>
  8019be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019c4:	85 c9                	test   %ecx,%ecx
  8019c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cb:	0f 49 c1             	cmovns %ecx,%eax
  8019ce:	29 c1                	sub    %eax,%ecx
  8019d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8019d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019d9:	89 cb                	mov    %ecx,%ebx
  8019db:	eb 4d                	jmp    801a2a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019e1:	74 1b                	je     8019fe <vprintfmt+0x213>
  8019e3:	0f be c0             	movsbl %al,%eax
  8019e6:	83 e8 20             	sub    $0x20,%eax
  8019e9:	83 f8 5e             	cmp    $0x5e,%eax
  8019ec:	76 10                	jbe    8019fe <vprintfmt+0x213>
					putch('?', putdat);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	ff 75 0c             	pushl  0xc(%ebp)
  8019f4:	6a 3f                	push   $0x3f
  8019f6:	ff 55 08             	call   *0x8(%ebp)
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	eb 0d                	jmp    801a0b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019fe:	83 ec 08             	sub    $0x8,%esp
  801a01:	ff 75 0c             	pushl  0xc(%ebp)
  801a04:	52                   	push   %edx
  801a05:	ff 55 08             	call   *0x8(%ebp)
  801a08:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a0b:	83 eb 01             	sub    $0x1,%ebx
  801a0e:	eb 1a                	jmp    801a2a <vprintfmt+0x23f>
  801a10:	89 75 08             	mov    %esi,0x8(%ebp)
  801a13:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a16:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a19:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a1c:	eb 0c                	jmp    801a2a <vprintfmt+0x23f>
  801a1e:	89 75 08             	mov    %esi,0x8(%ebp)
  801a21:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a24:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a27:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a2a:	83 c7 01             	add    $0x1,%edi
  801a2d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a31:	0f be d0             	movsbl %al,%edx
  801a34:	85 d2                	test   %edx,%edx
  801a36:	74 23                	je     801a5b <vprintfmt+0x270>
  801a38:	85 f6                	test   %esi,%esi
  801a3a:	78 a1                	js     8019dd <vprintfmt+0x1f2>
  801a3c:	83 ee 01             	sub    $0x1,%esi
  801a3f:	79 9c                	jns    8019dd <vprintfmt+0x1f2>
  801a41:	89 df                	mov    %ebx,%edi
  801a43:	8b 75 08             	mov    0x8(%ebp),%esi
  801a46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a49:	eb 18                	jmp    801a63 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a4b:	83 ec 08             	sub    $0x8,%esp
  801a4e:	53                   	push   %ebx
  801a4f:	6a 20                	push   $0x20
  801a51:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a53:	83 ef 01             	sub    $0x1,%edi
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	eb 08                	jmp    801a63 <vprintfmt+0x278>
  801a5b:	89 df                	mov    %ebx,%edi
  801a5d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a63:	85 ff                	test   %edi,%edi
  801a65:	7f e4                	jg     801a4b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a6a:	e9 a2 fd ff ff       	jmp    801811 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a6f:	83 fa 01             	cmp    $0x1,%edx
  801a72:	7e 16                	jle    801a8a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a74:	8b 45 14             	mov    0x14(%ebp),%eax
  801a77:	8d 50 08             	lea    0x8(%eax),%edx
  801a7a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a7d:	8b 50 04             	mov    0x4(%eax),%edx
  801a80:	8b 00                	mov    (%eax),%eax
  801a82:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a85:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a88:	eb 32                	jmp    801abc <vprintfmt+0x2d1>
	else if (lflag)
  801a8a:	85 d2                	test   %edx,%edx
  801a8c:	74 18                	je     801aa6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a8e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a91:	8d 50 04             	lea    0x4(%eax),%edx
  801a94:	89 55 14             	mov    %edx,0x14(%ebp)
  801a97:	8b 00                	mov    (%eax),%eax
  801a99:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a9c:	89 c1                	mov    %eax,%ecx
  801a9e:	c1 f9 1f             	sar    $0x1f,%ecx
  801aa1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801aa4:	eb 16                	jmp    801abc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801aa6:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa9:	8d 50 04             	lea    0x4(%eax),%edx
  801aac:	89 55 14             	mov    %edx,0x14(%ebp)
  801aaf:	8b 00                	mov    (%eax),%eax
  801ab1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ab4:	89 c1                	mov    %eax,%ecx
  801ab6:	c1 f9 1f             	sar    $0x1f,%ecx
  801ab9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801abc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801abf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801ac2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ac7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801acb:	79 74                	jns    801b41 <vprintfmt+0x356>
				putch('-', putdat);
  801acd:	83 ec 08             	sub    $0x8,%esp
  801ad0:	53                   	push   %ebx
  801ad1:	6a 2d                	push   $0x2d
  801ad3:	ff d6                	call   *%esi
				num = -(long long) num;
  801ad5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ad8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801adb:	f7 d8                	neg    %eax
  801add:	83 d2 00             	adc    $0x0,%edx
  801ae0:	f7 da                	neg    %edx
  801ae2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ae5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801aea:	eb 55                	jmp    801b41 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801aec:	8d 45 14             	lea    0x14(%ebp),%eax
  801aef:	e8 83 fc ff ff       	call   801777 <getuint>
			base = 10;
  801af4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801af9:	eb 46                	jmp    801b41 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801afb:	8d 45 14             	lea    0x14(%ebp),%eax
  801afe:	e8 74 fc ff ff       	call   801777 <getuint>
			base = 8;
  801b03:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b08:	eb 37                	jmp    801b41 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b0a:	83 ec 08             	sub    $0x8,%esp
  801b0d:	53                   	push   %ebx
  801b0e:	6a 30                	push   $0x30
  801b10:	ff d6                	call   *%esi
			putch('x', putdat);
  801b12:	83 c4 08             	add    $0x8,%esp
  801b15:	53                   	push   %ebx
  801b16:	6a 78                	push   $0x78
  801b18:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b1a:	8b 45 14             	mov    0x14(%ebp),%eax
  801b1d:	8d 50 04             	lea    0x4(%eax),%edx
  801b20:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b23:	8b 00                	mov    (%eax),%eax
  801b25:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b2a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b2d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b32:	eb 0d                	jmp    801b41 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b34:	8d 45 14             	lea    0x14(%ebp),%eax
  801b37:	e8 3b fc ff ff       	call   801777 <getuint>
			base = 16;
  801b3c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b48:	57                   	push   %edi
  801b49:	ff 75 e0             	pushl  -0x20(%ebp)
  801b4c:	51                   	push   %ecx
  801b4d:	52                   	push   %edx
  801b4e:	50                   	push   %eax
  801b4f:	89 da                	mov    %ebx,%edx
  801b51:	89 f0                	mov    %esi,%eax
  801b53:	e8 70 fb ff ff       	call   8016c8 <printnum>
			break;
  801b58:	83 c4 20             	add    $0x20,%esp
  801b5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b5e:	e9 ae fc ff ff       	jmp    801811 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b63:	83 ec 08             	sub    $0x8,%esp
  801b66:	53                   	push   %ebx
  801b67:	51                   	push   %ecx
  801b68:	ff d6                	call   *%esi
			break;
  801b6a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b70:	e9 9c fc ff ff       	jmp    801811 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b75:	83 ec 08             	sub    $0x8,%esp
  801b78:	53                   	push   %ebx
  801b79:	6a 25                	push   $0x25
  801b7b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	eb 03                	jmp    801b85 <vprintfmt+0x39a>
  801b82:	83 ef 01             	sub    $0x1,%edi
  801b85:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b89:	75 f7                	jne    801b82 <vprintfmt+0x397>
  801b8b:	e9 81 fc ff ff       	jmp    801811 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 18             	sub    $0x18,%esp
  801b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ba4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ba7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801bab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	74 26                	je     801bdf <vsnprintf+0x47>
  801bb9:	85 d2                	test   %edx,%edx
  801bbb:	7e 22                	jle    801bdf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801bbd:	ff 75 14             	pushl  0x14(%ebp)
  801bc0:	ff 75 10             	pushl  0x10(%ebp)
  801bc3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bc6:	50                   	push   %eax
  801bc7:	68 b1 17 80 00       	push   $0x8017b1
  801bcc:	e8 1a fc ff ff       	call   8017eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bd4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	eb 05                	jmp    801be4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bdf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bef:	50                   	push   %eax
  801bf0:	ff 75 10             	pushl  0x10(%ebp)
  801bf3:	ff 75 0c             	pushl  0xc(%ebp)
  801bf6:	ff 75 08             	pushl  0x8(%ebp)
  801bf9:	e8 9a ff ff ff       	call   801b98 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0b:	eb 03                	jmp    801c10 <strlen+0x10>
		n++;
  801c0d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c10:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c14:	75 f7                	jne    801c0d <strlen+0xd>
		n++;
	return n;
}
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    

00801c18 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c21:	ba 00 00 00 00       	mov    $0x0,%edx
  801c26:	eb 03                	jmp    801c2b <strnlen+0x13>
		n++;
  801c28:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c2b:	39 c2                	cmp    %eax,%edx
  801c2d:	74 08                	je     801c37 <strnlen+0x1f>
  801c2f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c33:	75 f3                	jne    801c28 <strnlen+0x10>
  801c35:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	53                   	push   %ebx
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c43:	89 c2                	mov    %eax,%edx
  801c45:	83 c2 01             	add    $0x1,%edx
  801c48:	83 c1 01             	add    $0x1,%ecx
  801c4b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c4f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c52:	84 db                	test   %bl,%bl
  801c54:	75 ef                	jne    801c45 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c56:	5b                   	pop    %ebx
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	53                   	push   %ebx
  801c5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c60:	53                   	push   %ebx
  801c61:	e8 9a ff ff ff       	call   801c00 <strlen>
  801c66:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c69:	ff 75 0c             	pushl  0xc(%ebp)
  801c6c:	01 d8                	add    %ebx,%eax
  801c6e:	50                   	push   %eax
  801c6f:	e8 c5 ff ff ff       	call   801c39 <strcpy>
	return dst;
}
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    

00801c7b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	56                   	push   %esi
  801c7f:	53                   	push   %ebx
  801c80:	8b 75 08             	mov    0x8(%ebp),%esi
  801c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c86:	89 f3                	mov    %esi,%ebx
  801c88:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c8b:	89 f2                	mov    %esi,%edx
  801c8d:	eb 0f                	jmp    801c9e <strncpy+0x23>
		*dst++ = *src;
  801c8f:	83 c2 01             	add    $0x1,%edx
  801c92:	0f b6 01             	movzbl (%ecx),%eax
  801c95:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c98:	80 39 01             	cmpb   $0x1,(%ecx)
  801c9b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c9e:	39 da                	cmp    %ebx,%edx
  801ca0:	75 ed                	jne    801c8f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ca2:	89 f0                	mov    %esi,%eax
  801ca4:	5b                   	pop    %ebx
  801ca5:	5e                   	pop    %esi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    

00801ca8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	56                   	push   %esi
  801cac:	53                   	push   %ebx
  801cad:	8b 75 08             	mov    0x8(%ebp),%esi
  801cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb3:	8b 55 10             	mov    0x10(%ebp),%edx
  801cb6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801cb8:	85 d2                	test   %edx,%edx
  801cba:	74 21                	je     801cdd <strlcpy+0x35>
  801cbc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cc0:	89 f2                	mov    %esi,%edx
  801cc2:	eb 09                	jmp    801ccd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cc4:	83 c2 01             	add    $0x1,%edx
  801cc7:	83 c1 01             	add    $0x1,%ecx
  801cca:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ccd:	39 c2                	cmp    %eax,%edx
  801ccf:	74 09                	je     801cda <strlcpy+0x32>
  801cd1:	0f b6 19             	movzbl (%ecx),%ebx
  801cd4:	84 db                	test   %bl,%bl
  801cd6:	75 ec                	jne    801cc4 <strlcpy+0x1c>
  801cd8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cda:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cdd:	29 f0                	sub    %esi,%eax
}
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    

00801ce3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cec:	eb 06                	jmp    801cf4 <strcmp+0x11>
		p++, q++;
  801cee:	83 c1 01             	add    $0x1,%ecx
  801cf1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cf4:	0f b6 01             	movzbl (%ecx),%eax
  801cf7:	84 c0                	test   %al,%al
  801cf9:	74 04                	je     801cff <strcmp+0x1c>
  801cfb:	3a 02                	cmp    (%edx),%al
  801cfd:	74 ef                	je     801cee <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cff:	0f b6 c0             	movzbl %al,%eax
  801d02:	0f b6 12             	movzbl (%edx),%edx
  801d05:	29 d0                	sub    %edx,%eax
}
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	53                   	push   %ebx
  801d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d10:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d13:	89 c3                	mov    %eax,%ebx
  801d15:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d18:	eb 06                	jmp    801d20 <strncmp+0x17>
		n--, p++, q++;
  801d1a:	83 c0 01             	add    $0x1,%eax
  801d1d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d20:	39 d8                	cmp    %ebx,%eax
  801d22:	74 15                	je     801d39 <strncmp+0x30>
  801d24:	0f b6 08             	movzbl (%eax),%ecx
  801d27:	84 c9                	test   %cl,%cl
  801d29:	74 04                	je     801d2f <strncmp+0x26>
  801d2b:	3a 0a                	cmp    (%edx),%cl
  801d2d:	74 eb                	je     801d1a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d2f:	0f b6 00             	movzbl (%eax),%eax
  801d32:	0f b6 12             	movzbl (%edx),%edx
  801d35:	29 d0                	sub    %edx,%eax
  801d37:	eb 05                	jmp    801d3e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d39:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d3e:	5b                   	pop    %ebx
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	8b 45 08             	mov    0x8(%ebp),%eax
  801d47:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d4b:	eb 07                	jmp    801d54 <strchr+0x13>
		if (*s == c)
  801d4d:	38 ca                	cmp    %cl,%dl
  801d4f:	74 0f                	je     801d60 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d51:	83 c0 01             	add    $0x1,%eax
  801d54:	0f b6 10             	movzbl (%eax),%edx
  801d57:	84 d2                	test   %dl,%dl
  801d59:	75 f2                	jne    801d4d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	8b 45 08             	mov    0x8(%ebp),%eax
  801d68:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d6c:	eb 03                	jmp    801d71 <strfind+0xf>
  801d6e:	83 c0 01             	add    $0x1,%eax
  801d71:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d74:	38 ca                	cmp    %cl,%dl
  801d76:	74 04                	je     801d7c <strfind+0x1a>
  801d78:	84 d2                	test   %dl,%dl
  801d7a:	75 f2                	jne    801d6e <strfind+0xc>
			break;
	return (char *) s;
}
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d8a:	85 c9                	test   %ecx,%ecx
  801d8c:	74 36                	je     801dc4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d94:	75 28                	jne    801dbe <memset+0x40>
  801d96:	f6 c1 03             	test   $0x3,%cl
  801d99:	75 23                	jne    801dbe <memset+0x40>
		c &= 0xFF;
  801d9b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d9f:	89 d3                	mov    %edx,%ebx
  801da1:	c1 e3 08             	shl    $0x8,%ebx
  801da4:	89 d6                	mov    %edx,%esi
  801da6:	c1 e6 18             	shl    $0x18,%esi
  801da9:	89 d0                	mov    %edx,%eax
  801dab:	c1 e0 10             	shl    $0x10,%eax
  801dae:	09 f0                	or     %esi,%eax
  801db0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801db2:	89 d8                	mov    %ebx,%eax
  801db4:	09 d0                	or     %edx,%eax
  801db6:	c1 e9 02             	shr    $0x2,%ecx
  801db9:	fc                   	cld    
  801dba:	f3 ab                	rep stos %eax,%es:(%edi)
  801dbc:	eb 06                	jmp    801dc4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc1:	fc                   	cld    
  801dc2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dc4:	89 f8                	mov    %edi,%eax
  801dc6:	5b                   	pop    %ebx
  801dc7:	5e                   	pop    %esi
  801dc8:	5f                   	pop    %edi
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    

00801dcb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	57                   	push   %edi
  801dcf:	56                   	push   %esi
  801dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dd9:	39 c6                	cmp    %eax,%esi
  801ddb:	73 35                	jae    801e12 <memmove+0x47>
  801ddd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801de0:	39 d0                	cmp    %edx,%eax
  801de2:	73 2e                	jae    801e12 <memmove+0x47>
		s += n;
		d += n;
  801de4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801de7:	89 d6                	mov    %edx,%esi
  801de9:	09 fe                	or     %edi,%esi
  801deb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801df1:	75 13                	jne    801e06 <memmove+0x3b>
  801df3:	f6 c1 03             	test   $0x3,%cl
  801df6:	75 0e                	jne    801e06 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801df8:	83 ef 04             	sub    $0x4,%edi
  801dfb:	8d 72 fc             	lea    -0x4(%edx),%esi
  801dfe:	c1 e9 02             	shr    $0x2,%ecx
  801e01:	fd                   	std    
  801e02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e04:	eb 09                	jmp    801e0f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e06:	83 ef 01             	sub    $0x1,%edi
  801e09:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e0c:	fd                   	std    
  801e0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e0f:	fc                   	cld    
  801e10:	eb 1d                	jmp    801e2f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e12:	89 f2                	mov    %esi,%edx
  801e14:	09 c2                	or     %eax,%edx
  801e16:	f6 c2 03             	test   $0x3,%dl
  801e19:	75 0f                	jne    801e2a <memmove+0x5f>
  801e1b:	f6 c1 03             	test   $0x3,%cl
  801e1e:	75 0a                	jne    801e2a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e20:	c1 e9 02             	shr    $0x2,%ecx
  801e23:	89 c7                	mov    %eax,%edi
  801e25:	fc                   	cld    
  801e26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e28:	eb 05                	jmp    801e2f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e2a:	89 c7                	mov    %eax,%edi
  801e2c:	fc                   	cld    
  801e2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e2f:	5e                   	pop    %esi
  801e30:	5f                   	pop    %edi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e36:	ff 75 10             	pushl  0x10(%ebp)
  801e39:	ff 75 0c             	pushl  0xc(%ebp)
  801e3c:	ff 75 08             	pushl  0x8(%ebp)
  801e3f:	e8 87 ff ff ff       	call   801dcb <memmove>
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	56                   	push   %esi
  801e4a:	53                   	push   %ebx
  801e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e51:	89 c6                	mov    %eax,%esi
  801e53:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e56:	eb 1a                	jmp    801e72 <memcmp+0x2c>
		if (*s1 != *s2)
  801e58:	0f b6 08             	movzbl (%eax),%ecx
  801e5b:	0f b6 1a             	movzbl (%edx),%ebx
  801e5e:	38 d9                	cmp    %bl,%cl
  801e60:	74 0a                	je     801e6c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e62:	0f b6 c1             	movzbl %cl,%eax
  801e65:	0f b6 db             	movzbl %bl,%ebx
  801e68:	29 d8                	sub    %ebx,%eax
  801e6a:	eb 0f                	jmp    801e7b <memcmp+0x35>
		s1++, s2++;
  801e6c:	83 c0 01             	add    $0x1,%eax
  801e6f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e72:	39 f0                	cmp    %esi,%eax
  801e74:	75 e2                	jne    801e58 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e7b:	5b                   	pop    %ebx
  801e7c:	5e                   	pop    %esi
  801e7d:	5d                   	pop    %ebp
  801e7e:	c3                   	ret    

00801e7f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	53                   	push   %ebx
  801e83:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e86:	89 c1                	mov    %eax,%ecx
  801e88:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e8b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e8f:	eb 0a                	jmp    801e9b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e91:	0f b6 10             	movzbl (%eax),%edx
  801e94:	39 da                	cmp    %ebx,%edx
  801e96:	74 07                	je     801e9f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e98:	83 c0 01             	add    $0x1,%eax
  801e9b:	39 c8                	cmp    %ecx,%eax
  801e9d:	72 f2                	jb     801e91 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e9f:	5b                   	pop    %ebx
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	57                   	push   %edi
  801ea6:	56                   	push   %esi
  801ea7:	53                   	push   %ebx
  801ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801eae:	eb 03                	jmp    801eb3 <strtol+0x11>
		s++;
  801eb0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801eb3:	0f b6 01             	movzbl (%ecx),%eax
  801eb6:	3c 20                	cmp    $0x20,%al
  801eb8:	74 f6                	je     801eb0 <strtol+0xe>
  801eba:	3c 09                	cmp    $0x9,%al
  801ebc:	74 f2                	je     801eb0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ebe:	3c 2b                	cmp    $0x2b,%al
  801ec0:	75 0a                	jne    801ecc <strtol+0x2a>
		s++;
  801ec2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ec5:	bf 00 00 00 00       	mov    $0x0,%edi
  801eca:	eb 11                	jmp    801edd <strtol+0x3b>
  801ecc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ed1:	3c 2d                	cmp    $0x2d,%al
  801ed3:	75 08                	jne    801edd <strtol+0x3b>
		s++, neg = 1;
  801ed5:	83 c1 01             	add    $0x1,%ecx
  801ed8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801edd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ee3:	75 15                	jne    801efa <strtol+0x58>
  801ee5:	80 39 30             	cmpb   $0x30,(%ecx)
  801ee8:	75 10                	jne    801efa <strtol+0x58>
  801eea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801eee:	75 7c                	jne    801f6c <strtol+0xca>
		s += 2, base = 16;
  801ef0:	83 c1 02             	add    $0x2,%ecx
  801ef3:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ef8:	eb 16                	jmp    801f10 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801efa:	85 db                	test   %ebx,%ebx
  801efc:	75 12                	jne    801f10 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801efe:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f03:	80 39 30             	cmpb   $0x30,(%ecx)
  801f06:	75 08                	jne    801f10 <strtol+0x6e>
		s++, base = 8;
  801f08:	83 c1 01             	add    $0x1,%ecx
  801f0b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
  801f15:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f18:	0f b6 11             	movzbl (%ecx),%edx
  801f1b:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f1e:	89 f3                	mov    %esi,%ebx
  801f20:	80 fb 09             	cmp    $0x9,%bl
  801f23:	77 08                	ja     801f2d <strtol+0x8b>
			dig = *s - '0';
  801f25:	0f be d2             	movsbl %dl,%edx
  801f28:	83 ea 30             	sub    $0x30,%edx
  801f2b:	eb 22                	jmp    801f4f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f30:	89 f3                	mov    %esi,%ebx
  801f32:	80 fb 19             	cmp    $0x19,%bl
  801f35:	77 08                	ja     801f3f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f37:	0f be d2             	movsbl %dl,%edx
  801f3a:	83 ea 57             	sub    $0x57,%edx
  801f3d:	eb 10                	jmp    801f4f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f42:	89 f3                	mov    %esi,%ebx
  801f44:	80 fb 19             	cmp    $0x19,%bl
  801f47:	77 16                	ja     801f5f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f49:	0f be d2             	movsbl %dl,%edx
  801f4c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f52:	7d 0b                	jge    801f5f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f54:	83 c1 01             	add    $0x1,%ecx
  801f57:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f5b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f5d:	eb b9                	jmp    801f18 <strtol+0x76>

	if (endptr)
  801f5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f63:	74 0d                	je     801f72 <strtol+0xd0>
		*endptr = (char *) s;
  801f65:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f68:	89 0e                	mov    %ecx,(%esi)
  801f6a:	eb 06                	jmp    801f72 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f6c:	85 db                	test   %ebx,%ebx
  801f6e:	74 98                	je     801f08 <strtol+0x66>
  801f70:	eb 9e                	jmp    801f10 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f72:	89 c2                	mov    %eax,%edx
  801f74:	f7 da                	neg    %edx
  801f76:	85 ff                	test   %edi,%edi
  801f78:	0f 45 c2             	cmovne %edx,%eax
}
  801f7b:	5b                   	pop    %ebx
  801f7c:	5e                   	pop    %esi
  801f7d:	5f                   	pop    %edi
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f86:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f8d:	75 2a                	jne    801fb9 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f8f:	83 ec 04             	sub    $0x4,%esp
  801f92:	6a 07                	push   $0x7
  801f94:	68 00 f0 bf ee       	push   $0xeebff000
  801f99:	6a 00                	push   $0x0
  801f9b:	e8 ed e1 ff ff       	call   80018d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fa0:	83 c4 10             	add    $0x10,%esp
  801fa3:	85 c0                	test   %eax,%eax
  801fa5:	79 12                	jns    801fb9 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fa7:	50                   	push   %eax
  801fa8:	68 cb 24 80 00       	push   $0x8024cb
  801fad:	6a 23                	push   $0x23
  801faf:	68 e0 28 80 00       	push   $0x8028e0
  801fb4:	e8 22 f6 ff ff       	call   8015db <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbc:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fc1:	83 ec 08             	sub    $0x8,%esp
  801fc4:	68 eb 1f 80 00       	push   $0x801feb
  801fc9:	6a 00                	push   $0x0
  801fcb:	e8 08 e3 ff ff       	call   8002d8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	79 12                	jns    801fe9 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fd7:	50                   	push   %eax
  801fd8:	68 cb 24 80 00       	push   $0x8024cb
  801fdd:	6a 2c                	push   $0x2c
  801fdf:	68 e0 28 80 00       	push   $0x8028e0
  801fe4:	e8 f2 f5 ff ff       	call   8015db <_panic>
	}
}
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    

00801feb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801feb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fec:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ff1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ff3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801ff6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801ffa:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fff:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802003:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802005:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802008:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802009:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80200c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80200d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80200e:	c3                   	ret    

0080200f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	8b 75 08             	mov    0x8(%ebp),%esi
  802017:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80201d:	85 c0                	test   %eax,%eax
  80201f:	75 12                	jne    802033 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802021:	83 ec 0c             	sub    $0xc,%esp
  802024:	68 00 00 c0 ee       	push   $0xeec00000
  802029:	e8 0f e3 ff ff       	call   80033d <sys_ipc_recv>
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	eb 0c                	jmp    80203f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802033:	83 ec 0c             	sub    $0xc,%esp
  802036:	50                   	push   %eax
  802037:	e8 01 e3 ff ff       	call   80033d <sys_ipc_recv>
  80203c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80203f:	85 f6                	test   %esi,%esi
  802041:	0f 95 c1             	setne  %cl
  802044:	85 db                	test   %ebx,%ebx
  802046:	0f 95 c2             	setne  %dl
  802049:	84 d1                	test   %dl,%cl
  80204b:	74 09                	je     802056 <ipc_recv+0x47>
  80204d:	89 c2                	mov    %eax,%edx
  80204f:	c1 ea 1f             	shr    $0x1f,%edx
  802052:	84 d2                	test   %dl,%dl
  802054:	75 2d                	jne    802083 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802056:	85 f6                	test   %esi,%esi
  802058:	74 0d                	je     802067 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80205a:	a1 04 40 80 00       	mov    0x804004,%eax
  80205f:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802065:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802067:	85 db                	test   %ebx,%ebx
  802069:	74 0d                	je     802078 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80206b:	a1 04 40 80 00       	mov    0x804004,%eax
  802070:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802076:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802078:	a1 04 40 80 00       	mov    0x804004,%eax
  80207d:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802083:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802086:	5b                   	pop    %ebx
  802087:	5e                   	pop    %esi
  802088:	5d                   	pop    %ebp
  802089:	c3                   	ret    

0080208a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80208a:	55                   	push   %ebp
  80208b:	89 e5                	mov    %esp,%ebp
  80208d:	57                   	push   %edi
  80208e:	56                   	push   %esi
  80208f:	53                   	push   %ebx
  802090:	83 ec 0c             	sub    $0xc,%esp
  802093:	8b 7d 08             	mov    0x8(%ebp),%edi
  802096:	8b 75 0c             	mov    0xc(%ebp),%esi
  802099:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80209c:	85 db                	test   %ebx,%ebx
  80209e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020a3:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020a6:	ff 75 14             	pushl  0x14(%ebp)
  8020a9:	53                   	push   %ebx
  8020aa:	56                   	push   %esi
  8020ab:	57                   	push   %edi
  8020ac:	e8 69 e2 ff ff       	call   80031a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020b1:	89 c2                	mov    %eax,%edx
  8020b3:	c1 ea 1f             	shr    $0x1f,%edx
  8020b6:	83 c4 10             	add    $0x10,%esp
  8020b9:	84 d2                	test   %dl,%dl
  8020bb:	74 17                	je     8020d4 <ipc_send+0x4a>
  8020bd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c0:	74 12                	je     8020d4 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020c2:	50                   	push   %eax
  8020c3:	68 ee 28 80 00       	push   $0x8028ee
  8020c8:	6a 47                	push   $0x47
  8020ca:	68 fc 28 80 00       	push   $0x8028fc
  8020cf:	e8 07 f5 ff ff       	call   8015db <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020d4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d7:	75 07                	jne    8020e0 <ipc_send+0x56>
			sys_yield();
  8020d9:	e8 90 e0 ff ff       	call   80016e <sys_yield>
  8020de:	eb c6                	jmp    8020a6 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	75 c2                	jne    8020a6 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e7:	5b                   	pop    %ebx
  8020e8:	5e                   	pop    %esi
  8020e9:	5f                   	pop    %edi
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    

008020ec <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020f2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020f7:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020fd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802103:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802109:	39 ca                	cmp    %ecx,%edx
  80210b:	75 13                	jne    802120 <ipc_find_env+0x34>
			return envs[i].env_id;
  80210d:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802113:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802118:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80211e:	eb 0f                	jmp    80212f <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802120:	83 c0 01             	add    $0x1,%eax
  802123:	3d 00 04 00 00       	cmp    $0x400,%eax
  802128:	75 cd                	jne    8020f7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80212a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80212f:	5d                   	pop    %ebp
  802130:	c3                   	ret    

00802131 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802131:	55                   	push   %ebp
  802132:	89 e5                	mov    %esp,%ebp
  802134:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802137:	89 d0                	mov    %edx,%eax
  802139:	c1 e8 16             	shr    $0x16,%eax
  80213c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802143:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802148:	f6 c1 01             	test   $0x1,%cl
  80214b:	74 1d                	je     80216a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80214d:	c1 ea 0c             	shr    $0xc,%edx
  802150:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802157:	f6 c2 01             	test   $0x1,%dl
  80215a:	74 0e                	je     80216a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80215c:	c1 ea 0c             	shr    $0xc,%edx
  80215f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802166:	ef 
  802167:	0f b7 c0             	movzwl %ax,%eax
}
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

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
