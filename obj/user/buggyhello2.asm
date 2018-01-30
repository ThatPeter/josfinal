
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
  8000bd:	e8 e4 09 00 00       	call   800aa6 <close_all>
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
  800142:	e8 90 14 00 00       	call   8015d7 <_panic>

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
  8001c3:	e8 0f 14 00 00       	call   8015d7 <_panic>

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
  800205:	e8 cd 13 00 00       	call   8015d7 <_panic>

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
  800247:	e8 8b 13 00 00       	call   8015d7 <_panic>

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
  800289:	e8 49 13 00 00       	call   8015d7 <_panic>

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
  8002cb:	e8 07 13 00 00       	call   8015d7 <_panic>
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
  80030d:	e8 c5 12 00 00       	call   8015d7 <_panic>

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
  800371:	e8 61 12 00 00       	call   8015d7 <_panic>

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
  800410:	e8 c2 11 00 00       	call   8015d7 <_panic>
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
  80043a:	e8 98 11 00 00       	call   8015d7 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80043f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800445:	83 ec 04             	sub    $0x4,%esp
  800448:	68 00 10 00 00       	push   $0x1000
  80044d:	53                   	push   %ebx
  80044e:	68 00 f0 7f 00       	push   $0x7ff000
  800453:	e8 d7 19 00 00       	call   801e2f <memcpy>

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
  800482:	e8 50 11 00 00       	call   8015d7 <_panic>
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
  8004aa:	e8 28 11 00 00       	call   8015d7 <_panic>
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
  8004c2:	e8 b5 1a 00 00       	call   801f7c <set_pgfault_handler>
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
  8004ea:	e8 e8 10 00 00       	call   8015d7 <_panic>
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
  8005a3:	e8 2f 10 00 00       	call   8015d7 <_panic>
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
  8005e8:	e8 ea 0f 00 00       	call   8015d7 <_panic>
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
  800616:	e8 bc 0f 00 00       	call   8015d7 <_panic>
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
  800640:	e8 92 0f 00 00       	call   8015d7 <_panic>
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
  800700:	e8 d2 0e 00 00       	call   8015d7 <_panic>
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
  800766:	e8 6c 0e 00 00       	call   8015d7 <_panic>
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
  800777:	53                   	push   %ebx
  800778:	83 ec 04             	sub    $0x4,%esp
  80077b:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80077e:	b8 01 00 00 00       	mov    $0x1,%eax
  800783:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  800786:	85 c0                	test   %eax,%eax
  800788:	74 45                	je     8007cf <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  80078a:	e8 c0 f9 ff ff       	call   80014f <sys_getenvid>
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	83 c3 04             	add    $0x4,%ebx
  800795:	53                   	push   %ebx
  800796:	50                   	push   %eax
  800797:	e8 35 ff ff ff       	call   8006d1 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80079c:	e8 ae f9 ff ff       	call   80014f <sys_getenvid>
  8007a1:	83 c4 08             	add    $0x8,%esp
  8007a4:	6a 04                	push   $0x4
  8007a6:	50                   	push   %eax
  8007a7:	e8 a8 fa ff ff       	call   800254 <sys_env_set_status>

		if (r < 0) {
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	79 15                	jns    8007c8 <mutex_lock+0x54>
			panic("%e\n", r);
  8007b3:	50                   	push   %eax
  8007b4:	68 cb 24 80 00       	push   $0x8024cb
  8007b9:	68 02 01 00 00       	push   $0x102
  8007be:	68 53 24 80 00       	push   $0x802453
  8007c3:	e8 0f 0e 00 00       	call   8015d7 <_panic>
		}
		sys_yield();
  8007c8:	e8 a1 f9 ff ff       	call   80016e <sys_yield>
  8007cd:	eb 08                	jmp    8007d7 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8007cf:	e8 7b f9 ff ff       	call   80014f <sys_getenvid>
  8007d4:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8007d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	83 ec 04             	sub    $0x4,%esp
  8007e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8007e6:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8007ea:	74 36                	je     800822 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8007ec:	83 ec 0c             	sub    $0xc,%esp
  8007ef:	8d 43 04             	lea    0x4(%ebx),%eax
  8007f2:	50                   	push   %eax
  8007f3:	e8 4d ff ff ff       	call   800745 <queue_pop>
  8007f8:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8007fb:	83 c4 08             	add    $0x8,%esp
  8007fe:	6a 02                	push   $0x2
  800800:	50                   	push   %eax
  800801:	e8 4e fa ff ff       	call   800254 <sys_env_set_status>
		if (r < 0) {
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	85 c0                	test   %eax,%eax
  80080b:	79 1d                	jns    80082a <mutex_unlock+0x4e>
			panic("%e\n", r);
  80080d:	50                   	push   %eax
  80080e:	68 cb 24 80 00       	push   $0x8024cb
  800813:	68 16 01 00 00       	push   $0x116
  800818:	68 53 24 80 00       	push   $0x802453
  80081d:	e8 b5 0d 00 00       	call   8015d7 <_panic>
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
  800827:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  80082a:	e8 3f f9 ff ff       	call   80016e <sys_yield>
}
  80082f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	83 ec 04             	sub    $0x4,%esp
  80083b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80083e:	e8 0c f9 ff ff       	call   80014f <sys_getenvid>
  800843:	83 ec 04             	sub    $0x4,%esp
  800846:	6a 07                	push   $0x7
  800848:	53                   	push   %ebx
  800849:	50                   	push   %eax
  80084a:	e8 3e f9 ff ff       	call   80018d <sys_page_alloc>
  80084f:	83 c4 10             	add    $0x10,%esp
  800852:	85 c0                	test   %eax,%eax
  800854:	79 15                	jns    80086b <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800856:	50                   	push   %eax
  800857:	68 b6 24 80 00       	push   $0x8024b6
  80085c:	68 23 01 00 00       	push   $0x123
  800861:	68 53 24 80 00       	push   $0x802453
  800866:	e8 6c 0d 00 00       	call   8015d7 <_panic>
	}	
	mtx->locked = 0;
  80086b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  800871:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  800878:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80087f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  800886:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  800893:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  800896:	eb 20                	jmp    8008b8 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  800898:	83 ec 0c             	sub    $0xc,%esp
  80089b:	56                   	push   %esi
  80089c:	e8 a4 fe ff ff       	call   800745 <queue_pop>
  8008a1:	83 c4 08             	add    $0x8,%esp
  8008a4:	6a 02                	push   $0x2
  8008a6:	50                   	push   %eax
  8008a7:	e8 a8 f9 ff ff       	call   800254 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8008ac:	8b 43 04             	mov    0x4(%ebx),%eax
  8008af:	8b 40 04             	mov    0x4(%eax),%eax
  8008b2:	89 43 04             	mov    %eax,0x4(%ebx)
  8008b5:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8008b8:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8008bc:	75 da                	jne    800898 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008be:	83 ec 04             	sub    $0x4,%esp
  8008c1:	68 00 10 00 00       	push   $0x1000
  8008c6:	6a 00                	push   $0x0
  8008c8:	53                   	push   %ebx
  8008c9:	e8 ac 14 00 00       	call   801d7a <memset>
	mtx = NULL;
}
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	05 00 00 00 30       	add    $0x30000000,%eax
  8008e3:	c1 e8 0c             	shr    $0xc,%eax
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8008f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008f8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800905:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	c1 ea 16             	shr    $0x16,%edx
  80090f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800916:	f6 c2 01             	test   $0x1,%dl
  800919:	74 11                	je     80092c <fd_alloc+0x2d>
  80091b:	89 c2                	mov    %eax,%edx
  80091d:	c1 ea 0c             	shr    $0xc,%edx
  800920:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800927:	f6 c2 01             	test   $0x1,%dl
  80092a:	75 09                	jne    800935 <fd_alloc+0x36>
			*fd_store = fd;
  80092c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
  800933:	eb 17                	jmp    80094c <fd_alloc+0x4d>
  800935:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80093a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80093f:	75 c9                	jne    80090a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800941:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800947:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800954:	83 f8 1f             	cmp    $0x1f,%eax
  800957:	77 36                	ja     80098f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800959:	c1 e0 0c             	shl    $0xc,%eax
  80095c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800961:	89 c2                	mov    %eax,%edx
  800963:	c1 ea 16             	shr    $0x16,%edx
  800966:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80096d:	f6 c2 01             	test   $0x1,%dl
  800970:	74 24                	je     800996 <fd_lookup+0x48>
  800972:	89 c2                	mov    %eax,%edx
  800974:	c1 ea 0c             	shr    $0xc,%edx
  800977:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80097e:	f6 c2 01             	test   $0x1,%dl
  800981:	74 1a                	je     80099d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
  800986:	89 02                	mov    %eax,(%edx)
	return 0;
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
  80098d:	eb 13                	jmp    8009a2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80098f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800994:	eb 0c                	jmp    8009a2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800996:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099b:	eb 05                	jmp    8009a2 <fd_lookup+0x54>
  80099d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ad:	ba 4c 25 80 00       	mov    $0x80254c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009b2:	eb 13                	jmp    8009c7 <dev_lookup+0x23>
  8009b4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009b7:	39 08                	cmp    %ecx,(%eax)
  8009b9:	75 0c                	jne    8009c7 <dev_lookup+0x23>
			*dev = devtab[i];
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c5:	eb 31                	jmp    8009f8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009c7:	8b 02                	mov    (%edx),%eax
  8009c9:	85 c0                	test   %eax,%eax
  8009cb:	75 e7                	jne    8009b4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8009d2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009d8:	83 ec 04             	sub    $0x4,%esp
  8009db:	51                   	push   %ecx
  8009dc:	50                   	push   %eax
  8009dd:	68 d0 24 80 00       	push   $0x8024d0
  8009e2:	e8 c9 0c 00 00       	call   8016b0 <cprintf>
	*dev = 0;
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009f0:	83 c4 10             	add    $0x10,%esp
  8009f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	83 ec 10             	sub    $0x10,%esp
  800a02:	8b 75 08             	mov    0x8(%ebp),%esi
  800a05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a0b:	50                   	push   %eax
  800a0c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a12:	c1 e8 0c             	shr    $0xc,%eax
  800a15:	50                   	push   %eax
  800a16:	e8 33 ff ff ff       	call   80094e <fd_lookup>
  800a1b:	83 c4 08             	add    $0x8,%esp
  800a1e:	85 c0                	test   %eax,%eax
  800a20:	78 05                	js     800a27 <fd_close+0x2d>
	    || fd != fd2)
  800a22:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a25:	74 0c                	je     800a33 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a27:	84 db                	test   %bl,%bl
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	0f 44 c2             	cmove  %edx,%eax
  800a31:	eb 41                	jmp    800a74 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a39:	50                   	push   %eax
  800a3a:	ff 36                	pushl  (%esi)
  800a3c:	e8 63 ff ff ff       	call   8009a4 <dev_lookup>
  800a41:	89 c3                	mov    %eax,%ebx
  800a43:	83 c4 10             	add    $0x10,%esp
  800a46:	85 c0                	test   %eax,%eax
  800a48:	78 1a                	js     800a64 <fd_close+0x6a>
		if (dev->dev_close)
  800a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a4d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a50:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a55:	85 c0                	test   %eax,%eax
  800a57:	74 0b                	je     800a64 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a59:	83 ec 0c             	sub    $0xc,%esp
  800a5c:	56                   	push   %esi
  800a5d:	ff d0                	call   *%eax
  800a5f:	89 c3                	mov    %eax,%ebx
  800a61:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	56                   	push   %esi
  800a68:	6a 00                	push   $0x0
  800a6a:	e8 a3 f7 ff ff       	call   800212 <sys_page_unmap>
	return r;
  800a6f:	83 c4 10             	add    $0x10,%esp
  800a72:	89 d8                	mov    %ebx,%eax
}
  800a74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a84:	50                   	push   %eax
  800a85:	ff 75 08             	pushl  0x8(%ebp)
  800a88:	e8 c1 fe ff ff       	call   80094e <fd_lookup>
  800a8d:	83 c4 08             	add    $0x8,%esp
  800a90:	85 c0                	test   %eax,%eax
  800a92:	78 10                	js     800aa4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a94:	83 ec 08             	sub    $0x8,%esp
  800a97:	6a 01                	push   $0x1
  800a99:	ff 75 f4             	pushl  -0xc(%ebp)
  800a9c:	e8 59 ff ff ff       	call   8009fa <fd_close>
  800aa1:	83 c4 10             	add    $0x10,%esp
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <close_all>:

void
close_all(void)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	53                   	push   %ebx
  800aaa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800aad:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ab2:	83 ec 0c             	sub    $0xc,%esp
  800ab5:	53                   	push   %ebx
  800ab6:	e8 c0 ff ff ff       	call   800a7b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800abb:	83 c3 01             	add    $0x1,%ebx
  800abe:	83 c4 10             	add    $0x10,%esp
  800ac1:	83 fb 20             	cmp    $0x20,%ebx
  800ac4:	75 ec                	jne    800ab2 <close_all+0xc>
		close(i);
}
  800ac6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac9:	c9                   	leave  
  800aca:	c3                   	ret    

00800acb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	57                   	push   %edi
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	83 ec 2c             	sub    $0x2c,%esp
  800ad4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ad7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ada:	50                   	push   %eax
  800adb:	ff 75 08             	pushl  0x8(%ebp)
  800ade:	e8 6b fe ff ff       	call   80094e <fd_lookup>
  800ae3:	83 c4 08             	add    $0x8,%esp
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	0f 88 c1 00 00 00    	js     800baf <dup+0xe4>
		return r;
	close(newfdnum);
  800aee:	83 ec 0c             	sub    $0xc,%esp
  800af1:	56                   	push   %esi
  800af2:	e8 84 ff ff ff       	call   800a7b <close>

	newfd = INDEX2FD(newfdnum);
  800af7:	89 f3                	mov    %esi,%ebx
  800af9:	c1 e3 0c             	shl    $0xc,%ebx
  800afc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b02:	83 c4 04             	add    $0x4,%esp
  800b05:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b08:	e8 db fd ff ff       	call   8008e8 <fd2data>
  800b0d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b0f:	89 1c 24             	mov    %ebx,(%esp)
  800b12:	e8 d1 fd ff ff       	call   8008e8 <fd2data>
  800b17:	83 c4 10             	add    $0x10,%esp
  800b1a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b1d:	89 f8                	mov    %edi,%eax
  800b1f:	c1 e8 16             	shr    $0x16,%eax
  800b22:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b29:	a8 01                	test   $0x1,%al
  800b2b:	74 37                	je     800b64 <dup+0x99>
  800b2d:	89 f8                	mov    %edi,%eax
  800b2f:	c1 e8 0c             	shr    $0xc,%eax
  800b32:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b39:	f6 c2 01             	test   $0x1,%dl
  800b3c:	74 26                	je     800b64 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	25 07 0e 00 00       	and    $0xe07,%eax
  800b4d:	50                   	push   %eax
  800b4e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b51:	6a 00                	push   $0x0
  800b53:	57                   	push   %edi
  800b54:	6a 00                	push   $0x0
  800b56:	e8 75 f6 ff ff       	call   8001d0 <sys_page_map>
  800b5b:	89 c7                	mov    %eax,%edi
  800b5d:	83 c4 20             	add    $0x20,%esp
  800b60:	85 c0                	test   %eax,%eax
  800b62:	78 2e                	js     800b92 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b67:	89 d0                	mov    %edx,%eax
  800b69:	c1 e8 0c             	shr    $0xc,%eax
  800b6c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	25 07 0e 00 00       	and    $0xe07,%eax
  800b7b:	50                   	push   %eax
  800b7c:	53                   	push   %ebx
  800b7d:	6a 00                	push   $0x0
  800b7f:	52                   	push   %edx
  800b80:	6a 00                	push   $0x0
  800b82:	e8 49 f6 ff ff       	call   8001d0 <sys_page_map>
  800b87:	89 c7                	mov    %eax,%edi
  800b89:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b8c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b8e:	85 ff                	test   %edi,%edi
  800b90:	79 1d                	jns    800baf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b92:	83 ec 08             	sub    $0x8,%esp
  800b95:	53                   	push   %ebx
  800b96:	6a 00                	push   $0x0
  800b98:	e8 75 f6 ff ff       	call   800212 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b9d:	83 c4 08             	add    $0x8,%esp
  800ba0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ba3:	6a 00                	push   $0x0
  800ba5:	e8 68 f6 ff ff       	call   800212 <sys_page_unmap>
	return r;
  800baa:	83 c4 10             	add    $0x10,%esp
  800bad:	89 f8                	mov    %edi,%eax
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 14             	sub    $0x14,%esp
  800bbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bc4:	50                   	push   %eax
  800bc5:	53                   	push   %ebx
  800bc6:	e8 83 fd ff ff       	call   80094e <fd_lookup>
  800bcb:	83 c4 08             	add    $0x8,%esp
  800bce:	89 c2                	mov    %eax,%edx
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	78 70                	js     800c44 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bd4:	83 ec 08             	sub    $0x8,%esp
  800bd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bda:	50                   	push   %eax
  800bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bde:	ff 30                	pushl  (%eax)
  800be0:	e8 bf fd ff ff       	call   8009a4 <dev_lookup>
  800be5:	83 c4 10             	add    $0x10,%esp
  800be8:	85 c0                	test   %eax,%eax
  800bea:	78 4f                	js     800c3b <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800bec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bef:	8b 42 08             	mov    0x8(%edx),%eax
  800bf2:	83 e0 03             	and    $0x3,%eax
  800bf5:	83 f8 01             	cmp    $0x1,%eax
  800bf8:	75 24                	jne    800c1e <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bfa:	a1 04 40 80 00       	mov    0x804004,%eax
  800bff:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800c05:	83 ec 04             	sub    $0x4,%esp
  800c08:	53                   	push   %ebx
  800c09:	50                   	push   %eax
  800c0a:	68 11 25 80 00       	push   $0x802511
  800c0f:	e8 9c 0a 00 00       	call   8016b0 <cprintf>
		return -E_INVAL;
  800c14:	83 c4 10             	add    $0x10,%esp
  800c17:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c1c:	eb 26                	jmp    800c44 <read+0x8d>
	}
	if (!dev->dev_read)
  800c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c21:	8b 40 08             	mov    0x8(%eax),%eax
  800c24:	85 c0                	test   %eax,%eax
  800c26:	74 17                	je     800c3f <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c28:	83 ec 04             	sub    $0x4,%esp
  800c2b:	ff 75 10             	pushl  0x10(%ebp)
  800c2e:	ff 75 0c             	pushl  0xc(%ebp)
  800c31:	52                   	push   %edx
  800c32:	ff d0                	call   *%eax
  800c34:	89 c2                	mov    %eax,%edx
  800c36:	83 c4 10             	add    $0x10,%esp
  800c39:	eb 09                	jmp    800c44 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c3b:	89 c2                	mov    %eax,%edx
  800c3d:	eb 05                	jmp    800c44 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c3f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c44:	89 d0                	mov    %edx,%eax
  800c46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c49:	c9                   	leave  
  800c4a:	c3                   	ret    

00800c4b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c57:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5f:	eb 21                	jmp    800c82 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c61:	83 ec 04             	sub    $0x4,%esp
  800c64:	89 f0                	mov    %esi,%eax
  800c66:	29 d8                	sub    %ebx,%eax
  800c68:	50                   	push   %eax
  800c69:	89 d8                	mov    %ebx,%eax
  800c6b:	03 45 0c             	add    0xc(%ebp),%eax
  800c6e:	50                   	push   %eax
  800c6f:	57                   	push   %edi
  800c70:	e8 42 ff ff ff       	call   800bb7 <read>
		if (m < 0)
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	78 10                	js     800c8c <readn+0x41>
			return m;
		if (m == 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	74 0a                	je     800c8a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c80:	01 c3                	add    %eax,%ebx
  800c82:	39 f3                	cmp    %esi,%ebx
  800c84:	72 db                	jb     800c61 <readn+0x16>
  800c86:	89 d8                	mov    %ebx,%eax
  800c88:	eb 02                	jmp    800c8c <readn+0x41>
  800c8a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	53                   	push   %ebx
  800c98:	83 ec 14             	sub    $0x14,%esp
  800c9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ca1:	50                   	push   %eax
  800ca2:	53                   	push   %ebx
  800ca3:	e8 a6 fc ff ff       	call   80094e <fd_lookup>
  800ca8:	83 c4 08             	add    $0x8,%esp
  800cab:	89 c2                	mov    %eax,%edx
  800cad:	85 c0                	test   %eax,%eax
  800caf:	78 6b                	js     800d1c <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cb1:	83 ec 08             	sub    $0x8,%esp
  800cb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cb7:	50                   	push   %eax
  800cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cbb:	ff 30                	pushl  (%eax)
  800cbd:	e8 e2 fc ff ff       	call   8009a4 <dev_lookup>
  800cc2:	83 c4 10             	add    $0x10,%esp
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	78 4a                	js     800d13 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ccc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cd0:	75 24                	jne    800cf6 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800cd2:	a1 04 40 80 00       	mov    0x804004,%eax
  800cd7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800cdd:	83 ec 04             	sub    $0x4,%esp
  800ce0:	53                   	push   %ebx
  800ce1:	50                   	push   %eax
  800ce2:	68 2d 25 80 00       	push   $0x80252d
  800ce7:	e8 c4 09 00 00       	call   8016b0 <cprintf>
		return -E_INVAL;
  800cec:	83 c4 10             	add    $0x10,%esp
  800cef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800cf4:	eb 26                	jmp    800d1c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800cf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cf9:	8b 52 0c             	mov    0xc(%edx),%edx
  800cfc:	85 d2                	test   %edx,%edx
  800cfe:	74 17                	je     800d17 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d00:	83 ec 04             	sub    $0x4,%esp
  800d03:	ff 75 10             	pushl  0x10(%ebp)
  800d06:	ff 75 0c             	pushl  0xc(%ebp)
  800d09:	50                   	push   %eax
  800d0a:	ff d2                	call   *%edx
  800d0c:	89 c2                	mov    %eax,%edx
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	eb 09                	jmp    800d1c <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d13:	89 c2                	mov    %eax,%edx
  800d15:	eb 05                	jmp    800d1c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d17:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d1c:	89 d0                	mov    %edx,%eax
  800d1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d21:	c9                   	leave  
  800d22:	c3                   	ret    

00800d23 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d29:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d2c:	50                   	push   %eax
  800d2d:	ff 75 08             	pushl  0x8(%ebp)
  800d30:	e8 19 fc ff ff       	call   80094e <fd_lookup>
  800d35:	83 c4 08             	add    $0x8,%esp
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	78 0e                	js     800d4a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d42:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d4a:	c9                   	leave  
  800d4b:	c3                   	ret    

00800d4c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 14             	sub    $0x14,%esp
  800d53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d56:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d59:	50                   	push   %eax
  800d5a:	53                   	push   %ebx
  800d5b:	e8 ee fb ff ff       	call   80094e <fd_lookup>
  800d60:	83 c4 08             	add    $0x8,%esp
  800d63:	89 c2                	mov    %eax,%edx
  800d65:	85 c0                	test   %eax,%eax
  800d67:	78 68                	js     800dd1 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d69:	83 ec 08             	sub    $0x8,%esp
  800d6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6f:	50                   	push   %eax
  800d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d73:	ff 30                	pushl  (%eax)
  800d75:	e8 2a fc ff ff       	call   8009a4 <dev_lookup>
  800d7a:	83 c4 10             	add    $0x10,%esp
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	78 47                	js     800dc8 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d84:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d88:	75 24                	jne    800dae <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d8a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d8f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	53                   	push   %ebx
  800d99:	50                   	push   %eax
  800d9a:	68 f0 24 80 00       	push   $0x8024f0
  800d9f:	e8 0c 09 00 00       	call   8016b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800dac:	eb 23                	jmp    800dd1 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800dae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800db1:	8b 52 18             	mov    0x18(%edx),%edx
  800db4:	85 d2                	test   %edx,%edx
  800db6:	74 14                	je     800dcc <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800db8:	83 ec 08             	sub    $0x8,%esp
  800dbb:	ff 75 0c             	pushl  0xc(%ebp)
  800dbe:	50                   	push   %eax
  800dbf:	ff d2                	call   *%edx
  800dc1:	89 c2                	mov    %eax,%edx
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	eb 09                	jmp    800dd1 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dc8:	89 c2                	mov    %eax,%edx
  800dca:	eb 05                	jmp    800dd1 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dcc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dd1:	89 d0                	mov    %edx,%eax
  800dd3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd6:	c9                   	leave  
  800dd7:	c3                   	ret    

00800dd8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	53                   	push   %ebx
  800ddc:	83 ec 14             	sub    $0x14,%esp
  800ddf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800de2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800de5:	50                   	push   %eax
  800de6:	ff 75 08             	pushl  0x8(%ebp)
  800de9:	e8 60 fb ff ff       	call   80094e <fd_lookup>
  800dee:	83 c4 08             	add    $0x8,%esp
  800df1:	89 c2                	mov    %eax,%edx
  800df3:	85 c0                	test   %eax,%eax
  800df5:	78 58                	js     800e4f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800df7:	83 ec 08             	sub    $0x8,%esp
  800dfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dfd:	50                   	push   %eax
  800dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e01:	ff 30                	pushl  (%eax)
  800e03:	e8 9c fb ff ff       	call   8009a4 <dev_lookup>
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	78 37                	js     800e46 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e12:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e16:	74 32                	je     800e4a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e18:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e1b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e22:	00 00 00 
	stat->st_isdir = 0;
  800e25:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e2c:	00 00 00 
	stat->st_dev = dev;
  800e2f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e35:	83 ec 08             	sub    $0x8,%esp
  800e38:	53                   	push   %ebx
  800e39:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3c:	ff 50 14             	call   *0x14(%eax)
  800e3f:	89 c2                	mov    %eax,%edx
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	eb 09                	jmp    800e4f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e46:	89 c2                	mov    %eax,%edx
  800e48:	eb 05                	jmp    800e4f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e4a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e4f:	89 d0                	mov    %edx,%eax
  800e51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e54:	c9                   	leave  
  800e55:	c3                   	ret    

00800e56 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e5b:	83 ec 08             	sub    $0x8,%esp
  800e5e:	6a 00                	push   $0x0
  800e60:	ff 75 08             	pushl  0x8(%ebp)
  800e63:	e8 e3 01 00 00       	call   80104b <open>
  800e68:	89 c3                	mov    %eax,%ebx
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	78 1b                	js     800e8c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e71:	83 ec 08             	sub    $0x8,%esp
  800e74:	ff 75 0c             	pushl  0xc(%ebp)
  800e77:	50                   	push   %eax
  800e78:	e8 5b ff ff ff       	call   800dd8 <fstat>
  800e7d:	89 c6                	mov    %eax,%esi
	close(fd);
  800e7f:	89 1c 24             	mov    %ebx,(%esp)
  800e82:	e8 f4 fb ff ff       	call   800a7b <close>
	return r;
  800e87:	83 c4 10             	add    $0x10,%esp
  800e8a:	89 f0                	mov    %esi,%eax
}
  800e8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	89 c6                	mov    %eax,%esi
  800e9a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e9c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ea3:	75 12                	jne    800eb7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ea5:	83 ec 0c             	sub    $0xc,%esp
  800ea8:	6a 01                	push   $0x1
  800eaa:	e8 39 12 00 00       	call   8020e8 <ipc_find_env>
  800eaf:	a3 00 40 80 00       	mov    %eax,0x804000
  800eb4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800eb7:	6a 07                	push   $0x7
  800eb9:	68 00 50 80 00       	push   $0x805000
  800ebe:	56                   	push   %esi
  800ebf:	ff 35 00 40 80 00    	pushl  0x804000
  800ec5:	e8 bc 11 00 00       	call   802086 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800eca:	83 c4 0c             	add    $0xc,%esp
  800ecd:	6a 00                	push   $0x0
  800ecf:	53                   	push   %ebx
  800ed0:	6a 00                	push   $0x0
  800ed2:	e8 34 11 00 00       	call   80200b <ipc_recv>
}
  800ed7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eda:	5b                   	pop    %ebx
  800edb:	5e                   	pop    %esi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee7:	8b 40 0c             	mov    0xc(%eax),%eax
  800eea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ef7:	ba 00 00 00 00       	mov    $0x0,%edx
  800efc:	b8 02 00 00 00       	mov    $0x2,%eax
  800f01:	e8 8d ff ff ff       	call   800e93 <fsipc>
}
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    

00800f08 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	8b 40 0c             	mov    0xc(%eax),%eax
  800f14:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f19:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f23:	e8 6b ff ff ff       	call   800e93 <fsipc>
}
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
  800f37:	8b 40 0c             	mov    0xc(%eax),%eax
  800f3a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f44:	b8 05 00 00 00       	mov    $0x5,%eax
  800f49:	e8 45 ff ff ff       	call   800e93 <fsipc>
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 2c                	js     800f7e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f52:	83 ec 08             	sub    $0x8,%esp
  800f55:	68 00 50 80 00       	push   $0x805000
  800f5a:	53                   	push   %ebx
  800f5b:	e8 d5 0c 00 00       	call   801c35 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f60:	a1 80 50 80 00       	mov    0x805080,%eax
  800f65:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f6b:	a1 84 50 80 00       	mov    0x805084,%eax
  800f70:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f81:	c9                   	leave  
  800f82:	c3                   	ret    

00800f83 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 0c             	sub    $0xc,%esp
  800f89:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8f:	8b 52 0c             	mov    0xc(%edx),%edx
  800f92:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f98:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f9d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800fa2:	0f 47 c2             	cmova  %edx,%eax
  800fa5:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800faa:	50                   	push   %eax
  800fab:	ff 75 0c             	pushl  0xc(%ebp)
  800fae:	68 08 50 80 00       	push   $0x805008
  800fb3:	e8 0f 0e 00 00       	call   801dc7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbd:	b8 04 00 00 00       	mov    $0x4,%eax
  800fc2:	e8 cc fe ff ff       	call   800e93 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	56                   	push   %esi
  800fcd:	53                   	push   %ebx
  800fce:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd4:	8b 40 0c             	mov    0xc(%eax),%eax
  800fd7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fdc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fe2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe7:	b8 03 00 00 00       	mov    $0x3,%eax
  800fec:	e8 a2 fe ff ff       	call   800e93 <fsipc>
  800ff1:	89 c3                	mov    %eax,%ebx
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 4b                	js     801042 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ff7:	39 c6                	cmp    %eax,%esi
  800ff9:	73 16                	jae    801011 <devfile_read+0x48>
  800ffb:	68 5c 25 80 00       	push   $0x80255c
  801000:	68 63 25 80 00       	push   $0x802563
  801005:	6a 7c                	push   $0x7c
  801007:	68 78 25 80 00       	push   $0x802578
  80100c:	e8 c6 05 00 00       	call   8015d7 <_panic>
	assert(r <= PGSIZE);
  801011:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801016:	7e 16                	jle    80102e <devfile_read+0x65>
  801018:	68 83 25 80 00       	push   $0x802583
  80101d:	68 63 25 80 00       	push   $0x802563
  801022:	6a 7d                	push   $0x7d
  801024:	68 78 25 80 00       	push   $0x802578
  801029:	e8 a9 05 00 00       	call   8015d7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80102e:	83 ec 04             	sub    $0x4,%esp
  801031:	50                   	push   %eax
  801032:	68 00 50 80 00       	push   $0x805000
  801037:	ff 75 0c             	pushl  0xc(%ebp)
  80103a:	e8 88 0d 00 00       	call   801dc7 <memmove>
	return r;
  80103f:	83 c4 10             	add    $0x10,%esp
}
  801042:	89 d8                	mov    %ebx,%eax
  801044:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5d                   	pop    %ebp
  80104a:	c3                   	ret    

0080104b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	53                   	push   %ebx
  80104f:	83 ec 20             	sub    $0x20,%esp
  801052:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801055:	53                   	push   %ebx
  801056:	e8 a1 0b 00 00       	call   801bfc <strlen>
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801063:	7f 67                	jg     8010cc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106b:	50                   	push   %eax
  80106c:	e8 8e f8 ff ff       	call   8008ff <fd_alloc>
  801071:	83 c4 10             	add    $0x10,%esp
		return r;
  801074:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801076:	85 c0                	test   %eax,%eax
  801078:	78 57                	js     8010d1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	53                   	push   %ebx
  80107e:	68 00 50 80 00       	push   $0x805000
  801083:	e8 ad 0b 00 00       	call   801c35 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801090:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801093:	b8 01 00 00 00       	mov    $0x1,%eax
  801098:	e8 f6 fd ff ff       	call   800e93 <fsipc>
  80109d:	89 c3                	mov    %eax,%ebx
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	79 14                	jns    8010ba <open+0x6f>
		fd_close(fd, 0);
  8010a6:	83 ec 08             	sub    $0x8,%esp
  8010a9:	6a 00                	push   $0x0
  8010ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ae:	e8 47 f9 ff ff       	call   8009fa <fd_close>
		return r;
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	89 da                	mov    %ebx,%edx
  8010b8:	eb 17                	jmp    8010d1 <open+0x86>
	}

	return fd2num(fd);
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8010c0:	e8 13 f8 ff ff       	call   8008d8 <fd2num>
  8010c5:	89 c2                	mov    %eax,%edx
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	eb 05                	jmp    8010d1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010cc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010d1:	89 d0                	mov    %edx,%eax
  8010d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d6:	c9                   	leave  
  8010d7:	c3                   	ret    

008010d8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010de:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8010e8:	e8 a6 fd ff ff       	call   800e93 <fsipc>
}
  8010ed:	c9                   	leave  
  8010ee:	c3                   	ret    

008010ef <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	56                   	push   %esi
  8010f3:	53                   	push   %ebx
  8010f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	ff 75 08             	pushl  0x8(%ebp)
  8010fd:	e8 e6 f7 ff ff       	call   8008e8 <fd2data>
  801102:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801104:	83 c4 08             	add    $0x8,%esp
  801107:	68 8f 25 80 00       	push   $0x80258f
  80110c:	53                   	push   %ebx
  80110d:	e8 23 0b 00 00       	call   801c35 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801112:	8b 46 04             	mov    0x4(%esi),%eax
  801115:	2b 06                	sub    (%esi),%eax
  801117:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80111d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801124:	00 00 00 
	stat->st_dev = &devpipe;
  801127:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  80112e:	30 80 00 
	return 0;
}
  801131:	b8 00 00 00 00       	mov    $0x0,%eax
  801136:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	53                   	push   %ebx
  801141:	83 ec 0c             	sub    $0xc,%esp
  801144:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801147:	53                   	push   %ebx
  801148:	6a 00                	push   $0x0
  80114a:	e8 c3 f0 ff ff       	call   800212 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80114f:	89 1c 24             	mov    %ebx,(%esp)
  801152:	e8 91 f7 ff ff       	call   8008e8 <fd2data>
  801157:	83 c4 08             	add    $0x8,%esp
  80115a:	50                   	push   %eax
  80115b:	6a 00                	push   $0x0
  80115d:	e8 b0 f0 ff ff       	call   800212 <sys_page_unmap>
}
  801162:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801165:	c9                   	leave  
  801166:	c3                   	ret    

00801167 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 1c             	sub    $0x1c,%esp
  801170:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801173:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801175:	a1 04 40 80 00       	mov    0x804004,%eax
  80117a:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	ff 75 e0             	pushl  -0x20(%ebp)
  801186:	e8 a2 0f 00 00       	call   80212d <pageref>
  80118b:	89 c3                	mov    %eax,%ebx
  80118d:	89 3c 24             	mov    %edi,(%esp)
  801190:	e8 98 0f 00 00       	call   80212d <pageref>
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	39 c3                	cmp    %eax,%ebx
  80119a:	0f 94 c1             	sete   %cl
  80119d:	0f b6 c9             	movzbl %cl,%ecx
  8011a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8011a3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011a9:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011af:	39 ce                	cmp    %ecx,%esi
  8011b1:	74 1e                	je     8011d1 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011b3:	39 c3                	cmp    %eax,%ebx
  8011b5:	75 be                	jne    801175 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011b7:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c0:	50                   	push   %eax
  8011c1:	56                   	push   %esi
  8011c2:	68 96 25 80 00       	push   $0x802596
  8011c7:	e8 e4 04 00 00       	call   8016b0 <cprintf>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	eb a4                	jmp    801175 <_pipeisclosed+0xe>
	}
}
  8011d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	57                   	push   %edi
  8011e0:	56                   	push   %esi
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 28             	sub    $0x28,%esp
  8011e5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011e8:	56                   	push   %esi
  8011e9:	e8 fa f6 ff ff       	call   8008e8 <fd2data>
  8011ee:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8011f8:	eb 4b                	jmp    801245 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011fa:	89 da                	mov    %ebx,%edx
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	e8 64 ff ff ff       	call   801167 <_pipeisclosed>
  801203:	85 c0                	test   %eax,%eax
  801205:	75 48                	jne    80124f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801207:	e8 62 ef ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80120c:	8b 43 04             	mov    0x4(%ebx),%eax
  80120f:	8b 0b                	mov    (%ebx),%ecx
  801211:	8d 51 20             	lea    0x20(%ecx),%edx
  801214:	39 d0                	cmp    %edx,%eax
  801216:	73 e2                	jae    8011fa <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801218:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80121f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801222:	89 c2                	mov    %eax,%edx
  801224:	c1 fa 1f             	sar    $0x1f,%edx
  801227:	89 d1                	mov    %edx,%ecx
  801229:	c1 e9 1b             	shr    $0x1b,%ecx
  80122c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80122f:	83 e2 1f             	and    $0x1f,%edx
  801232:	29 ca                	sub    %ecx,%edx
  801234:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801238:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80123c:	83 c0 01             	add    $0x1,%eax
  80123f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801242:	83 c7 01             	add    $0x1,%edi
  801245:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801248:	75 c2                	jne    80120c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80124a:	8b 45 10             	mov    0x10(%ebp),%eax
  80124d:	eb 05                	jmp    801254 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80124f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	57                   	push   %edi
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	83 ec 18             	sub    $0x18,%esp
  801265:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801268:	57                   	push   %edi
  801269:	e8 7a f6 ff ff       	call   8008e8 <fd2data>
  80126e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801270:	83 c4 10             	add    $0x10,%esp
  801273:	bb 00 00 00 00       	mov    $0x0,%ebx
  801278:	eb 3d                	jmp    8012b7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80127a:	85 db                	test   %ebx,%ebx
  80127c:	74 04                	je     801282 <devpipe_read+0x26>
				return i;
  80127e:	89 d8                	mov    %ebx,%eax
  801280:	eb 44                	jmp    8012c6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801282:	89 f2                	mov    %esi,%edx
  801284:	89 f8                	mov    %edi,%eax
  801286:	e8 dc fe ff ff       	call   801167 <_pipeisclosed>
  80128b:	85 c0                	test   %eax,%eax
  80128d:	75 32                	jne    8012c1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80128f:	e8 da ee ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801294:	8b 06                	mov    (%esi),%eax
  801296:	3b 46 04             	cmp    0x4(%esi),%eax
  801299:	74 df                	je     80127a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80129b:	99                   	cltd   
  80129c:	c1 ea 1b             	shr    $0x1b,%edx
  80129f:	01 d0                	add    %edx,%eax
  8012a1:	83 e0 1f             	and    $0x1f,%eax
  8012a4:	29 d0                	sub    %edx,%eax
  8012a6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8012ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ae:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012b1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012b4:	83 c3 01             	add    $0x1,%ebx
  8012b7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012ba:	75 d8                	jne    801294 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8012bf:	eb 05                	jmp    8012c6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012c1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c9:	5b                   	pop    %ebx
  8012ca:	5e                   	pop    %esi
  8012cb:	5f                   	pop    %edi
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	56                   	push   %esi
  8012d2:	53                   	push   %ebx
  8012d3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d9:	50                   	push   %eax
  8012da:	e8 20 f6 ff ff       	call   8008ff <fd_alloc>
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	89 c2                	mov    %eax,%edx
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	0f 88 2c 01 00 00    	js     801418 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ec:	83 ec 04             	sub    $0x4,%esp
  8012ef:	68 07 04 00 00       	push   $0x407
  8012f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f7:	6a 00                	push   $0x0
  8012f9:	e8 8f ee ff ff       	call   80018d <sys_page_alloc>
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	89 c2                	mov    %eax,%edx
  801303:	85 c0                	test   %eax,%eax
  801305:	0f 88 0d 01 00 00    	js     801418 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80130b:	83 ec 0c             	sub    $0xc,%esp
  80130e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	e8 e8 f5 ff ff       	call   8008ff <fd_alloc>
  801317:	89 c3                	mov    %eax,%ebx
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	0f 88 e2 00 00 00    	js     801406 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801324:	83 ec 04             	sub    $0x4,%esp
  801327:	68 07 04 00 00       	push   $0x407
  80132c:	ff 75 f0             	pushl  -0x10(%ebp)
  80132f:	6a 00                	push   $0x0
  801331:	e8 57 ee ff ff       	call   80018d <sys_page_alloc>
  801336:	89 c3                	mov    %eax,%ebx
  801338:	83 c4 10             	add    $0x10,%esp
  80133b:	85 c0                	test   %eax,%eax
  80133d:	0f 88 c3 00 00 00    	js     801406 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801343:	83 ec 0c             	sub    $0xc,%esp
  801346:	ff 75 f4             	pushl  -0xc(%ebp)
  801349:	e8 9a f5 ff ff       	call   8008e8 <fd2data>
  80134e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801350:	83 c4 0c             	add    $0xc,%esp
  801353:	68 07 04 00 00       	push   $0x407
  801358:	50                   	push   %eax
  801359:	6a 00                	push   $0x0
  80135b:	e8 2d ee ff ff       	call   80018d <sys_page_alloc>
  801360:	89 c3                	mov    %eax,%ebx
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	85 c0                	test   %eax,%eax
  801367:	0f 88 89 00 00 00    	js     8013f6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80136d:	83 ec 0c             	sub    $0xc,%esp
  801370:	ff 75 f0             	pushl  -0x10(%ebp)
  801373:	e8 70 f5 ff ff       	call   8008e8 <fd2data>
  801378:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80137f:	50                   	push   %eax
  801380:	6a 00                	push   $0x0
  801382:	56                   	push   %esi
  801383:	6a 00                	push   $0x0
  801385:	e8 46 ee ff ff       	call   8001d0 <sys_page_map>
  80138a:	89 c3                	mov    %eax,%ebx
  80138c:	83 c4 20             	add    $0x20,%esp
  80138f:	85 c0                	test   %eax,%eax
  801391:	78 55                	js     8013e8 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801393:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801399:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80139e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013a8:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8013ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013bd:	83 ec 0c             	sub    $0xc,%esp
  8013c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c3:	e8 10 f5 ff ff       	call   8008d8 <fd2num>
  8013c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013cb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013cd:	83 c4 04             	add    $0x4,%esp
  8013d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8013d3:	e8 00 f5 ff ff       	call   8008d8 <fd2num>
  8013d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013db:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e6:	eb 30                	jmp    801418 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	56                   	push   %esi
  8013ec:	6a 00                	push   $0x0
  8013ee:	e8 1f ee ff ff       	call   800212 <sys_page_unmap>
  8013f3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8013fc:	6a 00                	push   $0x0
  8013fe:	e8 0f ee ff ff       	call   800212 <sys_page_unmap>
  801403:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801406:	83 ec 08             	sub    $0x8,%esp
  801409:	ff 75 f4             	pushl  -0xc(%ebp)
  80140c:	6a 00                	push   $0x0
  80140e:	e8 ff ed ff ff       	call   800212 <sys_page_unmap>
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801418:	89 d0                	mov    %edx,%eax
  80141a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141d:	5b                   	pop    %ebx
  80141e:	5e                   	pop    %esi
  80141f:	5d                   	pop    %ebp
  801420:	c3                   	ret    

00801421 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801427:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	ff 75 08             	pushl  0x8(%ebp)
  80142e:	e8 1b f5 ff ff       	call   80094e <fd_lookup>
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	85 c0                	test   %eax,%eax
  801438:	78 18                	js     801452 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80143a:	83 ec 0c             	sub    $0xc,%esp
  80143d:	ff 75 f4             	pushl  -0xc(%ebp)
  801440:	e8 a3 f4 ff ff       	call   8008e8 <fd2data>
	return _pipeisclosed(fd, p);
  801445:	89 c2                	mov    %eax,%edx
  801447:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144a:	e8 18 fd ff ff       	call   801167 <_pipeisclosed>
  80144f:	83 c4 10             	add    $0x10,%esp
}
  801452:	c9                   	leave  
  801453:	c3                   	ret    

00801454 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801464:	68 ae 25 80 00       	push   $0x8025ae
  801469:	ff 75 0c             	pushl  0xc(%ebp)
  80146c:	e8 c4 07 00 00       	call   801c35 <strcpy>
	return 0;
}
  801471:	b8 00 00 00 00       	mov    $0x0,%eax
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	57                   	push   %edi
  80147c:	56                   	push   %esi
  80147d:	53                   	push   %ebx
  80147e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801484:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801489:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80148f:	eb 2d                	jmp    8014be <devcons_write+0x46>
		m = n - tot;
  801491:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801494:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801496:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801499:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80149e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014a1:	83 ec 04             	sub    $0x4,%esp
  8014a4:	53                   	push   %ebx
  8014a5:	03 45 0c             	add    0xc(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	57                   	push   %edi
  8014aa:	e8 18 09 00 00       	call   801dc7 <memmove>
		sys_cputs(buf, m);
  8014af:	83 c4 08             	add    $0x8,%esp
  8014b2:	53                   	push   %ebx
  8014b3:	57                   	push   %edi
  8014b4:	e8 18 ec ff ff       	call   8000d1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014b9:	01 de                	add    %ebx,%esi
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	89 f0                	mov    %esi,%eax
  8014c0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014c3:	72 cc                	jb     801491 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5f                   	pop    %edi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014dc:	74 2a                	je     801508 <devcons_read+0x3b>
  8014de:	eb 05                	jmp    8014e5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014e0:	e8 89 ec ff ff       	call   80016e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014e5:	e8 05 ec ff ff       	call   8000ef <sys_cgetc>
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	74 f2                	je     8014e0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 16                	js     801508 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014f2:	83 f8 04             	cmp    $0x4,%eax
  8014f5:	74 0c                	je     801503 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014fa:	88 02                	mov    %al,(%edx)
	return 1;
  8014fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801501:	eb 05                	jmp    801508 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801503:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801508:	c9                   	leave  
  801509:	c3                   	ret    

0080150a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801510:	8b 45 08             	mov    0x8(%ebp),%eax
  801513:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801516:	6a 01                	push   $0x1
  801518:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80151b:	50                   	push   %eax
  80151c:	e8 b0 eb ff ff       	call   8000d1 <sys_cputs>
}
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	c9                   	leave  
  801525:	c3                   	ret    

00801526 <getchar>:

int
getchar(void)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80152c:	6a 01                	push   $0x1
  80152e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801531:	50                   	push   %eax
  801532:	6a 00                	push   $0x0
  801534:	e8 7e f6 ff ff       	call   800bb7 <read>
	if (r < 0)
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 0f                	js     80154f <getchar+0x29>
		return r;
	if (r < 1)
  801540:	85 c0                	test   %eax,%eax
  801542:	7e 06                	jle    80154a <getchar+0x24>
		return -E_EOF;
	return c;
  801544:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801548:	eb 05                	jmp    80154f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80154a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80154f:	c9                   	leave  
  801550:	c3                   	ret    

00801551 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801557:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	ff 75 08             	pushl  0x8(%ebp)
  80155e:	e8 eb f3 ff ff       	call   80094e <fd_lookup>
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	78 11                	js     80157b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80156a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801573:	39 10                	cmp    %edx,(%eax)
  801575:	0f 94 c0             	sete   %al
  801578:	0f b6 c0             	movzbl %al,%eax
}
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    

0080157d <opencons>:

int
opencons(void)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801583:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	e8 73 f3 ff ff       	call   8008ff <fd_alloc>
  80158c:	83 c4 10             	add    $0x10,%esp
		return r;
  80158f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801591:	85 c0                	test   %eax,%eax
  801593:	78 3e                	js     8015d3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801595:	83 ec 04             	sub    $0x4,%esp
  801598:	68 07 04 00 00       	push   $0x407
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	6a 00                	push   $0x0
  8015a2:	e8 e6 eb ff ff       	call   80018d <sys_page_alloc>
  8015a7:	83 c4 10             	add    $0x10,%esp
		return r;
  8015aa:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 23                	js     8015d3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015b0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8015b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015c5:	83 ec 0c             	sub    $0xc,%esp
  8015c8:	50                   	push   %eax
  8015c9:	e8 0a f3 ff ff       	call   8008d8 <fd2num>
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	83 c4 10             	add    $0x10,%esp
}
  8015d3:	89 d0                	mov    %edx,%eax
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	56                   	push   %esi
  8015db:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015dc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015df:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8015e5:	e8 65 eb ff ff       	call   80014f <sys_getenvid>
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	ff 75 0c             	pushl  0xc(%ebp)
  8015f0:	ff 75 08             	pushl  0x8(%ebp)
  8015f3:	56                   	push   %esi
  8015f4:	50                   	push   %eax
  8015f5:	68 bc 25 80 00       	push   $0x8025bc
  8015fa:	e8 b1 00 00 00       	call   8016b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015ff:	83 c4 18             	add    $0x18,%esp
  801602:	53                   	push   %ebx
  801603:	ff 75 10             	pushl  0x10(%ebp)
  801606:	e8 54 00 00 00       	call   80165f <vcprintf>
	cprintf("\n");
  80160b:	c7 04 24 b4 24 80 00 	movl   $0x8024b4,(%esp)
  801612:	e8 99 00 00 00       	call   8016b0 <cprintf>
  801617:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80161a:	cc                   	int3   
  80161b:	eb fd                	jmp    80161a <_panic+0x43>

0080161d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	53                   	push   %ebx
  801621:	83 ec 04             	sub    $0x4,%esp
  801624:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801627:	8b 13                	mov    (%ebx),%edx
  801629:	8d 42 01             	lea    0x1(%edx),%eax
  80162c:	89 03                	mov    %eax,(%ebx)
  80162e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801631:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801635:	3d ff 00 00 00       	cmp    $0xff,%eax
  80163a:	75 1a                	jne    801656 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	68 ff 00 00 00       	push   $0xff
  801644:	8d 43 08             	lea    0x8(%ebx),%eax
  801647:	50                   	push   %eax
  801648:	e8 84 ea ff ff       	call   8000d1 <sys_cputs>
		b->idx = 0;
  80164d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801653:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801656:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80165a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801668:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80166f:	00 00 00 
	b.cnt = 0;
  801672:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801679:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80167c:	ff 75 0c             	pushl  0xc(%ebp)
  80167f:	ff 75 08             	pushl  0x8(%ebp)
  801682:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801688:	50                   	push   %eax
  801689:	68 1d 16 80 00       	push   $0x80161d
  80168e:	e8 54 01 00 00       	call   8017e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801693:	83 c4 08             	add    $0x8,%esp
  801696:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80169c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8016a2:	50                   	push   %eax
  8016a3:	e8 29 ea ff ff       	call   8000d1 <sys_cputs>

	return b.cnt;
}
  8016a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016b9:	50                   	push   %eax
  8016ba:	ff 75 08             	pushl  0x8(%ebp)
  8016bd:	e8 9d ff ff ff       	call   80165f <vcprintf>
	va_end(ap);

	return cnt;
}
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	57                   	push   %edi
  8016c8:	56                   	push   %esi
  8016c9:	53                   	push   %ebx
  8016ca:	83 ec 1c             	sub    $0x1c,%esp
  8016cd:	89 c7                	mov    %eax,%edi
  8016cf:	89 d6                	mov    %edx,%esi
  8016d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016da:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016e8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016eb:	39 d3                	cmp    %edx,%ebx
  8016ed:	72 05                	jb     8016f4 <printnum+0x30>
  8016ef:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016f2:	77 45                	ja     801739 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016f4:	83 ec 0c             	sub    $0xc,%esp
  8016f7:	ff 75 18             	pushl  0x18(%ebp)
  8016fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8016fd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801700:	53                   	push   %ebx
  801701:	ff 75 10             	pushl  0x10(%ebp)
  801704:	83 ec 08             	sub    $0x8,%esp
  801707:	ff 75 e4             	pushl  -0x1c(%ebp)
  80170a:	ff 75 e0             	pushl  -0x20(%ebp)
  80170d:	ff 75 dc             	pushl  -0x24(%ebp)
  801710:	ff 75 d8             	pushl  -0x28(%ebp)
  801713:	e8 58 0a 00 00       	call   802170 <__udivdi3>
  801718:	83 c4 18             	add    $0x18,%esp
  80171b:	52                   	push   %edx
  80171c:	50                   	push   %eax
  80171d:	89 f2                	mov    %esi,%edx
  80171f:	89 f8                	mov    %edi,%eax
  801721:	e8 9e ff ff ff       	call   8016c4 <printnum>
  801726:	83 c4 20             	add    $0x20,%esp
  801729:	eb 18                	jmp    801743 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	56                   	push   %esi
  80172f:	ff 75 18             	pushl  0x18(%ebp)
  801732:	ff d7                	call   *%edi
  801734:	83 c4 10             	add    $0x10,%esp
  801737:	eb 03                	jmp    80173c <printnum+0x78>
  801739:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80173c:	83 eb 01             	sub    $0x1,%ebx
  80173f:	85 db                	test   %ebx,%ebx
  801741:	7f e8                	jg     80172b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	56                   	push   %esi
  801747:	83 ec 04             	sub    $0x4,%esp
  80174a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80174d:	ff 75 e0             	pushl  -0x20(%ebp)
  801750:	ff 75 dc             	pushl  -0x24(%ebp)
  801753:	ff 75 d8             	pushl  -0x28(%ebp)
  801756:	e8 45 0b 00 00       	call   8022a0 <__umoddi3>
  80175b:	83 c4 14             	add    $0x14,%esp
  80175e:	0f be 80 df 25 80 00 	movsbl 0x8025df(%eax),%eax
  801765:	50                   	push   %eax
  801766:	ff d7                	call   *%edi
}
  801768:	83 c4 10             	add    $0x10,%esp
  80176b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5f                   	pop    %edi
  801771:	5d                   	pop    %ebp
  801772:	c3                   	ret    

00801773 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801773:	55                   	push   %ebp
  801774:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801776:	83 fa 01             	cmp    $0x1,%edx
  801779:	7e 0e                	jle    801789 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80177b:	8b 10                	mov    (%eax),%edx
  80177d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801780:	89 08                	mov    %ecx,(%eax)
  801782:	8b 02                	mov    (%edx),%eax
  801784:	8b 52 04             	mov    0x4(%edx),%edx
  801787:	eb 22                	jmp    8017ab <getuint+0x38>
	else if (lflag)
  801789:	85 d2                	test   %edx,%edx
  80178b:	74 10                	je     80179d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80178d:	8b 10                	mov    (%eax),%edx
  80178f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801792:	89 08                	mov    %ecx,(%eax)
  801794:	8b 02                	mov    (%edx),%eax
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	eb 0e                	jmp    8017ab <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80179d:	8b 10                	mov    (%eax),%edx
  80179f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017a2:	89 08                	mov    %ecx,(%eax)
  8017a4:	8b 02                	mov    (%edx),%eax
  8017a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017ab:	5d                   	pop    %ebp
  8017ac:	c3                   	ret    

008017ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017b7:	8b 10                	mov    (%eax),%edx
  8017b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8017bc:	73 0a                	jae    8017c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017c1:	89 08                	mov    %ecx,(%eax)
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	88 02                	mov    %al,(%edx)
}
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017d3:	50                   	push   %eax
  8017d4:	ff 75 10             	pushl  0x10(%ebp)
  8017d7:	ff 75 0c             	pushl  0xc(%ebp)
  8017da:	ff 75 08             	pushl  0x8(%ebp)
  8017dd:	e8 05 00 00 00       	call   8017e7 <vprintfmt>
	va_end(ap);
}
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	57                   	push   %edi
  8017eb:	56                   	push   %esi
  8017ec:	53                   	push   %ebx
  8017ed:	83 ec 2c             	sub    $0x2c,%esp
  8017f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017f9:	eb 12                	jmp    80180d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	0f 84 89 03 00 00    	je     801b8c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	53                   	push   %ebx
  801807:	50                   	push   %eax
  801808:	ff d6                	call   *%esi
  80180a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80180d:	83 c7 01             	add    $0x1,%edi
  801810:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801814:	83 f8 25             	cmp    $0x25,%eax
  801817:	75 e2                	jne    8017fb <vprintfmt+0x14>
  801819:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80181d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801824:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80182b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801832:	ba 00 00 00 00       	mov    $0x0,%edx
  801837:	eb 07                	jmp    801840 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801839:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80183c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801840:	8d 47 01             	lea    0x1(%edi),%eax
  801843:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801846:	0f b6 07             	movzbl (%edi),%eax
  801849:	0f b6 c8             	movzbl %al,%ecx
  80184c:	83 e8 23             	sub    $0x23,%eax
  80184f:	3c 55                	cmp    $0x55,%al
  801851:	0f 87 1a 03 00 00    	ja     801b71 <vprintfmt+0x38a>
  801857:	0f b6 c0             	movzbl %al,%eax
  80185a:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  801861:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801864:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801868:	eb d6                	jmp    801840 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80186d:	b8 00 00 00 00       	mov    $0x0,%eax
  801872:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801875:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801878:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80187c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80187f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801882:	83 fa 09             	cmp    $0x9,%edx
  801885:	77 39                	ja     8018c0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801887:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80188a:	eb e9                	jmp    801875 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80188c:	8b 45 14             	mov    0x14(%ebp),%eax
  80188f:	8d 48 04             	lea    0x4(%eax),%ecx
  801892:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801895:	8b 00                	mov    (%eax),%eax
  801897:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80189d:	eb 27                	jmp    8018c6 <vprintfmt+0xdf>
  80189f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a2:	85 c0                	test   %eax,%eax
  8018a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018a9:	0f 49 c8             	cmovns %eax,%ecx
  8018ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018b2:	eb 8c                	jmp    801840 <vprintfmt+0x59>
  8018b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018b7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018be:	eb 80                	jmp    801840 <vprintfmt+0x59>
  8018c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018c3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018ca:	0f 89 70 ff ff ff    	jns    801840 <vprintfmt+0x59>
				width = precision, precision = -1;
  8018d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018d6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018dd:	e9 5e ff ff ff       	jmp    801840 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018e2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018e8:	e9 53 ff ff ff       	jmp    801840 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f0:	8d 50 04             	lea    0x4(%eax),%edx
  8018f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f6:	83 ec 08             	sub    $0x8,%esp
  8018f9:	53                   	push   %ebx
  8018fa:	ff 30                	pushl  (%eax)
  8018fc:	ff d6                	call   *%esi
			break;
  8018fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801901:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801904:	e9 04 ff ff ff       	jmp    80180d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801909:	8b 45 14             	mov    0x14(%ebp),%eax
  80190c:	8d 50 04             	lea    0x4(%eax),%edx
  80190f:	89 55 14             	mov    %edx,0x14(%ebp)
  801912:	8b 00                	mov    (%eax),%eax
  801914:	99                   	cltd   
  801915:	31 d0                	xor    %edx,%eax
  801917:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801919:	83 f8 0f             	cmp    $0xf,%eax
  80191c:	7f 0b                	jg     801929 <vprintfmt+0x142>
  80191e:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  801925:	85 d2                	test   %edx,%edx
  801927:	75 18                	jne    801941 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801929:	50                   	push   %eax
  80192a:	68 f7 25 80 00       	push   $0x8025f7
  80192f:	53                   	push   %ebx
  801930:	56                   	push   %esi
  801931:	e8 94 fe ff ff       	call   8017ca <printfmt>
  801936:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801939:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80193c:	e9 cc fe ff ff       	jmp    80180d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801941:	52                   	push   %edx
  801942:	68 75 25 80 00       	push   $0x802575
  801947:	53                   	push   %ebx
  801948:	56                   	push   %esi
  801949:	e8 7c fe ff ff       	call   8017ca <printfmt>
  80194e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801951:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801954:	e9 b4 fe ff ff       	jmp    80180d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801959:	8b 45 14             	mov    0x14(%ebp),%eax
  80195c:	8d 50 04             	lea    0x4(%eax),%edx
  80195f:	89 55 14             	mov    %edx,0x14(%ebp)
  801962:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801964:	85 ff                	test   %edi,%edi
  801966:	b8 f0 25 80 00       	mov    $0x8025f0,%eax
  80196b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80196e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801972:	0f 8e 94 00 00 00    	jle    801a0c <vprintfmt+0x225>
  801978:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80197c:	0f 84 98 00 00 00    	je     801a1a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801982:	83 ec 08             	sub    $0x8,%esp
  801985:	ff 75 d0             	pushl  -0x30(%ebp)
  801988:	57                   	push   %edi
  801989:	e8 86 02 00 00       	call   801c14 <strnlen>
  80198e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801991:	29 c1                	sub    %eax,%ecx
  801993:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801996:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801999:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80199d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8019a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a5:	eb 0f                	jmp    8019b6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8019a7:	83 ec 08             	sub    $0x8,%esp
  8019aa:	53                   	push   %ebx
  8019ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8019ae:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019b0:	83 ef 01             	sub    $0x1,%edi
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	85 ff                	test   %edi,%edi
  8019b8:	7f ed                	jg     8019a7 <vprintfmt+0x1c0>
  8019ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019c0:	85 c9                	test   %ecx,%ecx
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c7:	0f 49 c1             	cmovns %ecx,%eax
  8019ca:	29 c1                	sub    %eax,%ecx
  8019cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8019cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019d5:	89 cb                	mov    %ecx,%ebx
  8019d7:	eb 4d                	jmp    801a26 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019dd:	74 1b                	je     8019fa <vprintfmt+0x213>
  8019df:	0f be c0             	movsbl %al,%eax
  8019e2:	83 e8 20             	sub    $0x20,%eax
  8019e5:	83 f8 5e             	cmp    $0x5e,%eax
  8019e8:	76 10                	jbe    8019fa <vprintfmt+0x213>
					putch('?', putdat);
  8019ea:	83 ec 08             	sub    $0x8,%esp
  8019ed:	ff 75 0c             	pushl  0xc(%ebp)
  8019f0:	6a 3f                	push   $0x3f
  8019f2:	ff 55 08             	call   *0x8(%ebp)
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	eb 0d                	jmp    801a07 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019fa:	83 ec 08             	sub    $0x8,%esp
  8019fd:	ff 75 0c             	pushl  0xc(%ebp)
  801a00:	52                   	push   %edx
  801a01:	ff 55 08             	call   *0x8(%ebp)
  801a04:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a07:	83 eb 01             	sub    $0x1,%ebx
  801a0a:	eb 1a                	jmp    801a26 <vprintfmt+0x23f>
  801a0c:	89 75 08             	mov    %esi,0x8(%ebp)
  801a0f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a12:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a15:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a18:	eb 0c                	jmp    801a26 <vprintfmt+0x23f>
  801a1a:	89 75 08             	mov    %esi,0x8(%ebp)
  801a1d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a20:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a23:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a26:	83 c7 01             	add    $0x1,%edi
  801a29:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a2d:	0f be d0             	movsbl %al,%edx
  801a30:	85 d2                	test   %edx,%edx
  801a32:	74 23                	je     801a57 <vprintfmt+0x270>
  801a34:	85 f6                	test   %esi,%esi
  801a36:	78 a1                	js     8019d9 <vprintfmt+0x1f2>
  801a38:	83 ee 01             	sub    $0x1,%esi
  801a3b:	79 9c                	jns    8019d9 <vprintfmt+0x1f2>
  801a3d:	89 df                	mov    %ebx,%edi
  801a3f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a45:	eb 18                	jmp    801a5f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a47:	83 ec 08             	sub    $0x8,%esp
  801a4a:	53                   	push   %ebx
  801a4b:	6a 20                	push   $0x20
  801a4d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a4f:	83 ef 01             	sub    $0x1,%edi
  801a52:	83 c4 10             	add    $0x10,%esp
  801a55:	eb 08                	jmp    801a5f <vprintfmt+0x278>
  801a57:	89 df                	mov    %ebx,%edi
  801a59:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a5f:	85 ff                	test   %edi,%edi
  801a61:	7f e4                	jg     801a47 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a63:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a66:	e9 a2 fd ff ff       	jmp    80180d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a6b:	83 fa 01             	cmp    $0x1,%edx
  801a6e:	7e 16                	jle    801a86 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a70:	8b 45 14             	mov    0x14(%ebp),%eax
  801a73:	8d 50 08             	lea    0x8(%eax),%edx
  801a76:	89 55 14             	mov    %edx,0x14(%ebp)
  801a79:	8b 50 04             	mov    0x4(%eax),%edx
  801a7c:	8b 00                	mov    (%eax),%eax
  801a7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a81:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a84:	eb 32                	jmp    801ab8 <vprintfmt+0x2d1>
	else if (lflag)
  801a86:	85 d2                	test   %edx,%edx
  801a88:	74 18                	je     801aa2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8d:	8d 50 04             	lea    0x4(%eax),%edx
  801a90:	89 55 14             	mov    %edx,0x14(%ebp)
  801a93:	8b 00                	mov    (%eax),%eax
  801a95:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a98:	89 c1                	mov    %eax,%ecx
  801a9a:	c1 f9 1f             	sar    $0x1f,%ecx
  801a9d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801aa0:	eb 16                	jmp    801ab8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa5:	8d 50 04             	lea    0x4(%eax),%edx
  801aa8:	89 55 14             	mov    %edx,0x14(%ebp)
  801aab:	8b 00                	mov    (%eax),%eax
  801aad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ab0:	89 c1                	mov    %eax,%ecx
  801ab2:	c1 f9 1f             	sar    $0x1f,%ecx
  801ab5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ab8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801abb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801abe:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ac3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ac7:	79 74                	jns    801b3d <vprintfmt+0x356>
				putch('-', putdat);
  801ac9:	83 ec 08             	sub    $0x8,%esp
  801acc:	53                   	push   %ebx
  801acd:	6a 2d                	push   $0x2d
  801acf:	ff d6                	call   *%esi
				num = -(long long) num;
  801ad1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ad4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ad7:	f7 d8                	neg    %eax
  801ad9:	83 d2 00             	adc    $0x0,%edx
  801adc:	f7 da                	neg    %edx
  801ade:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ae1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ae6:	eb 55                	jmp    801b3d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ae8:	8d 45 14             	lea    0x14(%ebp),%eax
  801aeb:	e8 83 fc ff ff       	call   801773 <getuint>
			base = 10;
  801af0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801af5:	eb 46                	jmp    801b3d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801af7:	8d 45 14             	lea    0x14(%ebp),%eax
  801afa:	e8 74 fc ff ff       	call   801773 <getuint>
			base = 8;
  801aff:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b04:	eb 37                	jmp    801b3d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b06:	83 ec 08             	sub    $0x8,%esp
  801b09:	53                   	push   %ebx
  801b0a:	6a 30                	push   $0x30
  801b0c:	ff d6                	call   *%esi
			putch('x', putdat);
  801b0e:	83 c4 08             	add    $0x8,%esp
  801b11:	53                   	push   %ebx
  801b12:	6a 78                	push   $0x78
  801b14:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b16:	8b 45 14             	mov    0x14(%ebp),%eax
  801b19:	8d 50 04             	lea    0x4(%eax),%edx
  801b1c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b1f:	8b 00                	mov    (%eax),%eax
  801b21:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b26:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b29:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b2e:	eb 0d                	jmp    801b3d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b30:	8d 45 14             	lea    0x14(%ebp),%eax
  801b33:	e8 3b fc ff ff       	call   801773 <getuint>
			base = 16;
  801b38:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b3d:	83 ec 0c             	sub    $0xc,%esp
  801b40:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b44:	57                   	push   %edi
  801b45:	ff 75 e0             	pushl  -0x20(%ebp)
  801b48:	51                   	push   %ecx
  801b49:	52                   	push   %edx
  801b4a:	50                   	push   %eax
  801b4b:	89 da                	mov    %ebx,%edx
  801b4d:	89 f0                	mov    %esi,%eax
  801b4f:	e8 70 fb ff ff       	call   8016c4 <printnum>
			break;
  801b54:	83 c4 20             	add    $0x20,%esp
  801b57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b5a:	e9 ae fc ff ff       	jmp    80180d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b5f:	83 ec 08             	sub    $0x8,%esp
  801b62:	53                   	push   %ebx
  801b63:	51                   	push   %ecx
  801b64:	ff d6                	call   *%esi
			break;
  801b66:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b6c:	e9 9c fc ff ff       	jmp    80180d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b71:	83 ec 08             	sub    $0x8,%esp
  801b74:	53                   	push   %ebx
  801b75:	6a 25                	push   $0x25
  801b77:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b79:	83 c4 10             	add    $0x10,%esp
  801b7c:	eb 03                	jmp    801b81 <vprintfmt+0x39a>
  801b7e:	83 ef 01             	sub    $0x1,%edi
  801b81:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b85:	75 f7                	jne    801b7e <vprintfmt+0x397>
  801b87:	e9 81 fc ff ff       	jmp    80180d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8f:	5b                   	pop    %ebx
  801b90:	5e                   	pop    %esi
  801b91:	5f                   	pop    %edi
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	83 ec 18             	sub    $0x18,%esp
  801b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ba0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ba3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ba7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801baa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	74 26                	je     801bdb <vsnprintf+0x47>
  801bb5:	85 d2                	test   %edx,%edx
  801bb7:	7e 22                	jle    801bdb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801bb9:	ff 75 14             	pushl  0x14(%ebp)
  801bbc:	ff 75 10             	pushl  0x10(%ebp)
  801bbf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bc2:	50                   	push   %eax
  801bc3:	68 ad 17 80 00       	push   $0x8017ad
  801bc8:	e8 1a fc ff ff       	call   8017e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bd0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	eb 05                	jmp    801be0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bdb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801be8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801beb:	50                   	push   %eax
  801bec:	ff 75 10             	pushl  0x10(%ebp)
  801bef:	ff 75 0c             	pushl  0xc(%ebp)
  801bf2:	ff 75 08             	pushl  0x8(%ebp)
  801bf5:	e8 9a ff ff ff       	call   801b94 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c02:	b8 00 00 00 00       	mov    $0x0,%eax
  801c07:	eb 03                	jmp    801c0c <strlen+0x10>
		n++;
  801c09:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c0c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c10:	75 f7                	jne    801c09 <strlen+0xd>
		n++;
	return n;
}
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c22:	eb 03                	jmp    801c27 <strnlen+0x13>
		n++;
  801c24:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c27:	39 c2                	cmp    %eax,%edx
  801c29:	74 08                	je     801c33 <strnlen+0x1f>
  801c2b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c2f:	75 f3                	jne    801c24 <strnlen+0x10>
  801c31:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	53                   	push   %ebx
  801c39:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c3f:	89 c2                	mov    %eax,%edx
  801c41:	83 c2 01             	add    $0x1,%edx
  801c44:	83 c1 01             	add    $0x1,%ecx
  801c47:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c4b:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c4e:	84 db                	test   %bl,%bl
  801c50:	75 ef                	jne    801c41 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c52:	5b                   	pop    %ebx
  801c53:	5d                   	pop    %ebp
  801c54:	c3                   	ret    

00801c55 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	53                   	push   %ebx
  801c59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c5c:	53                   	push   %ebx
  801c5d:	e8 9a ff ff ff       	call   801bfc <strlen>
  801c62:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c65:	ff 75 0c             	pushl  0xc(%ebp)
  801c68:	01 d8                	add    %ebx,%eax
  801c6a:	50                   	push   %eax
  801c6b:	e8 c5 ff ff ff       	call   801c35 <strcpy>
	return dst;
}
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c75:	c9                   	leave  
  801c76:	c3                   	ret    

00801c77 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	56                   	push   %esi
  801c7b:	53                   	push   %ebx
  801c7c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c82:	89 f3                	mov    %esi,%ebx
  801c84:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c87:	89 f2                	mov    %esi,%edx
  801c89:	eb 0f                	jmp    801c9a <strncpy+0x23>
		*dst++ = *src;
  801c8b:	83 c2 01             	add    $0x1,%edx
  801c8e:	0f b6 01             	movzbl (%ecx),%eax
  801c91:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c94:	80 39 01             	cmpb   $0x1,(%ecx)
  801c97:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c9a:	39 da                	cmp    %ebx,%edx
  801c9c:	75 ed                	jne    801c8b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c9e:	89 f0                	mov    %esi,%eax
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    

00801ca4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	56                   	push   %esi
  801ca8:	53                   	push   %ebx
  801ca9:	8b 75 08             	mov    0x8(%ebp),%esi
  801cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801caf:	8b 55 10             	mov    0x10(%ebp),%edx
  801cb2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801cb4:	85 d2                	test   %edx,%edx
  801cb6:	74 21                	je     801cd9 <strlcpy+0x35>
  801cb8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cbc:	89 f2                	mov    %esi,%edx
  801cbe:	eb 09                	jmp    801cc9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cc0:	83 c2 01             	add    $0x1,%edx
  801cc3:	83 c1 01             	add    $0x1,%ecx
  801cc6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cc9:	39 c2                	cmp    %eax,%edx
  801ccb:	74 09                	je     801cd6 <strlcpy+0x32>
  801ccd:	0f b6 19             	movzbl (%ecx),%ebx
  801cd0:	84 db                	test   %bl,%bl
  801cd2:	75 ec                	jne    801cc0 <strlcpy+0x1c>
  801cd4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cd6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cd9:	29 f0                	sub    %esi,%eax
}
  801cdb:	5b                   	pop    %ebx
  801cdc:	5e                   	pop    %esi
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ce8:	eb 06                	jmp    801cf0 <strcmp+0x11>
		p++, q++;
  801cea:	83 c1 01             	add    $0x1,%ecx
  801ced:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cf0:	0f b6 01             	movzbl (%ecx),%eax
  801cf3:	84 c0                	test   %al,%al
  801cf5:	74 04                	je     801cfb <strcmp+0x1c>
  801cf7:	3a 02                	cmp    (%edx),%al
  801cf9:	74 ef                	je     801cea <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cfb:	0f b6 c0             	movzbl %al,%eax
  801cfe:	0f b6 12             	movzbl (%edx),%edx
  801d01:	29 d0                	sub    %edx,%eax
}
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    

00801d05 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	53                   	push   %ebx
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d14:	eb 06                	jmp    801d1c <strncmp+0x17>
		n--, p++, q++;
  801d16:	83 c0 01             	add    $0x1,%eax
  801d19:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d1c:	39 d8                	cmp    %ebx,%eax
  801d1e:	74 15                	je     801d35 <strncmp+0x30>
  801d20:	0f b6 08             	movzbl (%eax),%ecx
  801d23:	84 c9                	test   %cl,%cl
  801d25:	74 04                	je     801d2b <strncmp+0x26>
  801d27:	3a 0a                	cmp    (%edx),%cl
  801d29:	74 eb                	je     801d16 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d2b:	0f b6 00             	movzbl (%eax),%eax
  801d2e:	0f b6 12             	movzbl (%edx),%edx
  801d31:	29 d0                	sub    %edx,%eax
  801d33:	eb 05                	jmp    801d3a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d35:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d3a:	5b                   	pop    %ebx
  801d3b:	5d                   	pop    %ebp
  801d3c:	c3                   	ret    

00801d3d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	8b 45 08             	mov    0x8(%ebp),%eax
  801d43:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d47:	eb 07                	jmp    801d50 <strchr+0x13>
		if (*s == c)
  801d49:	38 ca                	cmp    %cl,%dl
  801d4b:	74 0f                	je     801d5c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d4d:	83 c0 01             	add    $0x1,%eax
  801d50:	0f b6 10             	movzbl (%eax),%edx
  801d53:	84 d2                	test   %dl,%dl
  801d55:	75 f2                	jne    801d49 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	8b 45 08             	mov    0x8(%ebp),%eax
  801d64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d68:	eb 03                	jmp    801d6d <strfind+0xf>
  801d6a:	83 c0 01             	add    $0x1,%eax
  801d6d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d70:	38 ca                	cmp    %cl,%dl
  801d72:	74 04                	je     801d78 <strfind+0x1a>
  801d74:	84 d2                	test   %dl,%dl
  801d76:	75 f2                	jne    801d6a <strfind+0xc>
			break;
	return (char *) s;
}
  801d78:	5d                   	pop    %ebp
  801d79:	c3                   	ret    

00801d7a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	57                   	push   %edi
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
  801d80:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d86:	85 c9                	test   %ecx,%ecx
  801d88:	74 36                	je     801dc0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d8a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d90:	75 28                	jne    801dba <memset+0x40>
  801d92:	f6 c1 03             	test   $0x3,%cl
  801d95:	75 23                	jne    801dba <memset+0x40>
		c &= 0xFF;
  801d97:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d9b:	89 d3                	mov    %edx,%ebx
  801d9d:	c1 e3 08             	shl    $0x8,%ebx
  801da0:	89 d6                	mov    %edx,%esi
  801da2:	c1 e6 18             	shl    $0x18,%esi
  801da5:	89 d0                	mov    %edx,%eax
  801da7:	c1 e0 10             	shl    $0x10,%eax
  801daa:	09 f0                	or     %esi,%eax
  801dac:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801dae:	89 d8                	mov    %ebx,%eax
  801db0:	09 d0                	or     %edx,%eax
  801db2:	c1 e9 02             	shr    $0x2,%ecx
  801db5:	fc                   	cld    
  801db6:	f3 ab                	rep stos %eax,%es:(%edi)
  801db8:	eb 06                	jmp    801dc0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbd:	fc                   	cld    
  801dbe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dc0:	89 f8                	mov    %edi,%eax
  801dc2:	5b                   	pop    %ebx
  801dc3:	5e                   	pop    %esi
  801dc4:	5f                   	pop    %edi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	57                   	push   %edi
  801dcb:	56                   	push   %esi
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dd2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dd5:	39 c6                	cmp    %eax,%esi
  801dd7:	73 35                	jae    801e0e <memmove+0x47>
  801dd9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ddc:	39 d0                	cmp    %edx,%eax
  801dde:	73 2e                	jae    801e0e <memmove+0x47>
		s += n;
		d += n;
  801de0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801de3:	89 d6                	mov    %edx,%esi
  801de5:	09 fe                	or     %edi,%esi
  801de7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801ded:	75 13                	jne    801e02 <memmove+0x3b>
  801def:	f6 c1 03             	test   $0x3,%cl
  801df2:	75 0e                	jne    801e02 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801df4:	83 ef 04             	sub    $0x4,%edi
  801df7:	8d 72 fc             	lea    -0x4(%edx),%esi
  801dfa:	c1 e9 02             	shr    $0x2,%ecx
  801dfd:	fd                   	std    
  801dfe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e00:	eb 09                	jmp    801e0b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e02:	83 ef 01             	sub    $0x1,%edi
  801e05:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e08:	fd                   	std    
  801e09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e0b:	fc                   	cld    
  801e0c:	eb 1d                	jmp    801e2b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e0e:	89 f2                	mov    %esi,%edx
  801e10:	09 c2                	or     %eax,%edx
  801e12:	f6 c2 03             	test   $0x3,%dl
  801e15:	75 0f                	jne    801e26 <memmove+0x5f>
  801e17:	f6 c1 03             	test   $0x3,%cl
  801e1a:	75 0a                	jne    801e26 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e1c:	c1 e9 02             	shr    $0x2,%ecx
  801e1f:	89 c7                	mov    %eax,%edi
  801e21:	fc                   	cld    
  801e22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e24:	eb 05                	jmp    801e2b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e26:	89 c7                	mov    %eax,%edi
  801e28:	fc                   	cld    
  801e29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e2b:	5e                   	pop    %esi
  801e2c:	5f                   	pop    %edi
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    

00801e2f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e32:	ff 75 10             	pushl  0x10(%ebp)
  801e35:	ff 75 0c             	pushl  0xc(%ebp)
  801e38:	ff 75 08             	pushl  0x8(%ebp)
  801e3b:	e8 87 ff ff ff       	call   801dc7 <memmove>
}
  801e40:	c9                   	leave  
  801e41:	c3                   	ret    

00801e42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	56                   	push   %esi
  801e46:	53                   	push   %ebx
  801e47:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4d:	89 c6                	mov    %eax,%esi
  801e4f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e52:	eb 1a                	jmp    801e6e <memcmp+0x2c>
		if (*s1 != *s2)
  801e54:	0f b6 08             	movzbl (%eax),%ecx
  801e57:	0f b6 1a             	movzbl (%edx),%ebx
  801e5a:	38 d9                	cmp    %bl,%cl
  801e5c:	74 0a                	je     801e68 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e5e:	0f b6 c1             	movzbl %cl,%eax
  801e61:	0f b6 db             	movzbl %bl,%ebx
  801e64:	29 d8                	sub    %ebx,%eax
  801e66:	eb 0f                	jmp    801e77 <memcmp+0x35>
		s1++, s2++;
  801e68:	83 c0 01             	add    $0x1,%eax
  801e6b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e6e:	39 f0                	cmp    %esi,%eax
  801e70:	75 e2                	jne    801e54 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e77:	5b                   	pop    %ebx
  801e78:	5e                   	pop    %esi
  801e79:	5d                   	pop    %ebp
  801e7a:	c3                   	ret    

00801e7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	53                   	push   %ebx
  801e7f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e82:	89 c1                	mov    %eax,%ecx
  801e84:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e87:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e8b:	eb 0a                	jmp    801e97 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e8d:	0f b6 10             	movzbl (%eax),%edx
  801e90:	39 da                	cmp    %ebx,%edx
  801e92:	74 07                	je     801e9b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e94:	83 c0 01             	add    $0x1,%eax
  801e97:	39 c8                	cmp    %ecx,%eax
  801e99:	72 f2                	jb     801e8d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e9b:	5b                   	pop    %ebx
  801e9c:	5d                   	pop    %ebp
  801e9d:	c3                   	ret    

00801e9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e9e:	55                   	push   %ebp
  801e9f:	89 e5                	mov    %esp,%ebp
  801ea1:	57                   	push   %edi
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
  801ea4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ea7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801eaa:	eb 03                	jmp    801eaf <strtol+0x11>
		s++;
  801eac:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801eaf:	0f b6 01             	movzbl (%ecx),%eax
  801eb2:	3c 20                	cmp    $0x20,%al
  801eb4:	74 f6                	je     801eac <strtol+0xe>
  801eb6:	3c 09                	cmp    $0x9,%al
  801eb8:	74 f2                	je     801eac <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801eba:	3c 2b                	cmp    $0x2b,%al
  801ebc:	75 0a                	jne    801ec8 <strtol+0x2a>
		s++;
  801ebe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ec1:	bf 00 00 00 00       	mov    $0x0,%edi
  801ec6:	eb 11                	jmp    801ed9 <strtol+0x3b>
  801ec8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ecd:	3c 2d                	cmp    $0x2d,%al
  801ecf:	75 08                	jne    801ed9 <strtol+0x3b>
		s++, neg = 1;
  801ed1:	83 c1 01             	add    $0x1,%ecx
  801ed4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ed9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801edf:	75 15                	jne    801ef6 <strtol+0x58>
  801ee1:	80 39 30             	cmpb   $0x30,(%ecx)
  801ee4:	75 10                	jne    801ef6 <strtol+0x58>
  801ee6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801eea:	75 7c                	jne    801f68 <strtol+0xca>
		s += 2, base = 16;
  801eec:	83 c1 02             	add    $0x2,%ecx
  801eef:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ef4:	eb 16                	jmp    801f0c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ef6:	85 db                	test   %ebx,%ebx
  801ef8:	75 12                	jne    801f0c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801efa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eff:	80 39 30             	cmpb   $0x30,(%ecx)
  801f02:	75 08                	jne    801f0c <strtol+0x6e>
		s++, base = 8;
  801f04:	83 c1 01             	add    $0x1,%ecx
  801f07:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801f11:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f14:	0f b6 11             	movzbl (%ecx),%edx
  801f17:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f1a:	89 f3                	mov    %esi,%ebx
  801f1c:	80 fb 09             	cmp    $0x9,%bl
  801f1f:	77 08                	ja     801f29 <strtol+0x8b>
			dig = *s - '0';
  801f21:	0f be d2             	movsbl %dl,%edx
  801f24:	83 ea 30             	sub    $0x30,%edx
  801f27:	eb 22                	jmp    801f4b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f29:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f2c:	89 f3                	mov    %esi,%ebx
  801f2e:	80 fb 19             	cmp    $0x19,%bl
  801f31:	77 08                	ja     801f3b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f33:	0f be d2             	movsbl %dl,%edx
  801f36:	83 ea 57             	sub    $0x57,%edx
  801f39:	eb 10                	jmp    801f4b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f3b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f3e:	89 f3                	mov    %esi,%ebx
  801f40:	80 fb 19             	cmp    $0x19,%bl
  801f43:	77 16                	ja     801f5b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f45:	0f be d2             	movsbl %dl,%edx
  801f48:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f4b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f4e:	7d 0b                	jge    801f5b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f50:	83 c1 01             	add    $0x1,%ecx
  801f53:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f57:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f59:	eb b9                	jmp    801f14 <strtol+0x76>

	if (endptr)
  801f5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f5f:	74 0d                	je     801f6e <strtol+0xd0>
		*endptr = (char *) s;
  801f61:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f64:	89 0e                	mov    %ecx,(%esi)
  801f66:	eb 06                	jmp    801f6e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f68:	85 db                	test   %ebx,%ebx
  801f6a:	74 98                	je     801f04 <strtol+0x66>
  801f6c:	eb 9e                	jmp    801f0c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f6e:	89 c2                	mov    %eax,%edx
  801f70:	f7 da                	neg    %edx
  801f72:	85 ff                	test   %edi,%edi
  801f74:	0f 45 c2             	cmovne %edx,%eax
}
  801f77:	5b                   	pop    %ebx
  801f78:	5e                   	pop    %esi
  801f79:	5f                   	pop    %edi
  801f7a:	5d                   	pop    %ebp
  801f7b:	c3                   	ret    

00801f7c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f82:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f89:	75 2a                	jne    801fb5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f8b:	83 ec 04             	sub    $0x4,%esp
  801f8e:	6a 07                	push   $0x7
  801f90:	68 00 f0 bf ee       	push   $0xeebff000
  801f95:	6a 00                	push   $0x0
  801f97:	e8 f1 e1 ff ff       	call   80018d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f9c:	83 c4 10             	add    $0x10,%esp
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	79 12                	jns    801fb5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fa3:	50                   	push   %eax
  801fa4:	68 cb 24 80 00       	push   $0x8024cb
  801fa9:	6a 23                	push   $0x23
  801fab:	68 e0 28 80 00       	push   $0x8028e0
  801fb0:	e8 22 f6 ff ff       	call   8015d7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb8:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fbd:	83 ec 08             	sub    $0x8,%esp
  801fc0:	68 e7 1f 80 00       	push   $0x801fe7
  801fc5:	6a 00                	push   $0x0
  801fc7:	e8 0c e3 ff ff       	call   8002d8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fcc:	83 c4 10             	add    $0x10,%esp
  801fcf:	85 c0                	test   %eax,%eax
  801fd1:	79 12                	jns    801fe5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fd3:	50                   	push   %eax
  801fd4:	68 cb 24 80 00       	push   $0x8024cb
  801fd9:	6a 2c                	push   $0x2c
  801fdb:	68 e0 28 80 00       	push   $0x8028e0
  801fe0:	e8 f2 f5 ff ff       	call   8015d7 <_panic>
	}
}
  801fe5:	c9                   	leave  
  801fe6:	c3                   	ret    

00801fe7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fe7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fe8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fed:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fef:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801ff2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801ff6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801ffb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801fff:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802001:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802004:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802005:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802008:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802009:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80200a:	c3                   	ret    

0080200b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	56                   	push   %esi
  80200f:	53                   	push   %ebx
  802010:	8b 75 08             	mov    0x8(%ebp),%esi
  802013:	8b 45 0c             	mov    0xc(%ebp),%eax
  802016:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802019:	85 c0                	test   %eax,%eax
  80201b:	75 12                	jne    80202f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80201d:	83 ec 0c             	sub    $0xc,%esp
  802020:	68 00 00 c0 ee       	push   $0xeec00000
  802025:	e8 13 e3 ff ff       	call   80033d <sys_ipc_recv>
  80202a:	83 c4 10             	add    $0x10,%esp
  80202d:	eb 0c                	jmp    80203b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80202f:	83 ec 0c             	sub    $0xc,%esp
  802032:	50                   	push   %eax
  802033:	e8 05 e3 ff ff       	call   80033d <sys_ipc_recv>
  802038:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80203b:	85 f6                	test   %esi,%esi
  80203d:	0f 95 c1             	setne  %cl
  802040:	85 db                	test   %ebx,%ebx
  802042:	0f 95 c2             	setne  %dl
  802045:	84 d1                	test   %dl,%cl
  802047:	74 09                	je     802052 <ipc_recv+0x47>
  802049:	89 c2                	mov    %eax,%edx
  80204b:	c1 ea 1f             	shr    $0x1f,%edx
  80204e:	84 d2                	test   %dl,%dl
  802050:	75 2d                	jne    80207f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802052:	85 f6                	test   %esi,%esi
  802054:	74 0d                	je     802063 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802056:	a1 04 40 80 00       	mov    0x804004,%eax
  80205b:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802061:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802063:	85 db                	test   %ebx,%ebx
  802065:	74 0d                	je     802074 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802067:	a1 04 40 80 00       	mov    0x804004,%eax
  80206c:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802072:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802074:	a1 04 40 80 00       	mov    0x804004,%eax
  802079:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80207f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802082:	5b                   	pop    %ebx
  802083:	5e                   	pop    %esi
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	57                   	push   %edi
  80208a:	56                   	push   %esi
  80208b:	53                   	push   %ebx
  80208c:	83 ec 0c             	sub    $0xc,%esp
  80208f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802092:	8b 75 0c             	mov    0xc(%ebp),%esi
  802095:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802098:	85 db                	test   %ebx,%ebx
  80209a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80209f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020a2:	ff 75 14             	pushl  0x14(%ebp)
  8020a5:	53                   	push   %ebx
  8020a6:	56                   	push   %esi
  8020a7:	57                   	push   %edi
  8020a8:	e8 6d e2 ff ff       	call   80031a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020ad:	89 c2                	mov    %eax,%edx
  8020af:	c1 ea 1f             	shr    $0x1f,%edx
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	84 d2                	test   %dl,%dl
  8020b7:	74 17                	je     8020d0 <ipc_send+0x4a>
  8020b9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020bc:	74 12                	je     8020d0 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020be:	50                   	push   %eax
  8020bf:	68 ee 28 80 00       	push   $0x8028ee
  8020c4:	6a 47                	push   $0x47
  8020c6:	68 fc 28 80 00       	push   $0x8028fc
  8020cb:	e8 07 f5 ff ff       	call   8015d7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020d0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d3:	75 07                	jne    8020dc <ipc_send+0x56>
			sys_yield();
  8020d5:	e8 94 e0 ff ff       	call   80016e <sys_yield>
  8020da:	eb c6                	jmp    8020a2 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	75 c2                	jne    8020a2 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    

008020e8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020ee:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020f3:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020f9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ff:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802105:	39 ca                	cmp    %ecx,%edx
  802107:	75 13                	jne    80211c <ipc_find_env+0x34>
			return envs[i].env_id;
  802109:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80210f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802114:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80211a:	eb 0f                	jmp    80212b <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80211c:	83 c0 01             	add    $0x1,%eax
  80211f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802124:	75 cd                	jne    8020f3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802126:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80212b:	5d                   	pop    %ebp
  80212c:	c3                   	ret    

0080212d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80212d:	55                   	push   %ebp
  80212e:	89 e5                	mov    %esp,%ebp
  802130:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802133:	89 d0                	mov    %edx,%eax
  802135:	c1 e8 16             	shr    $0x16,%eax
  802138:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80213f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802144:	f6 c1 01             	test   $0x1,%cl
  802147:	74 1d                	je     802166 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802149:	c1 ea 0c             	shr    $0xc,%edx
  80214c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802153:	f6 c2 01             	test   $0x1,%dl
  802156:	74 0e                	je     802166 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802158:	c1 ea 0c             	shr    $0xc,%edx
  80215b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802162:	ef 
  802163:	0f b7 c0             	movzwl %ax,%eax
}
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
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
