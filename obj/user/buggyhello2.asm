
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
  800063:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8000bd:	e8 04 08 00 00       	call   8008c6 <close_all>
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
  800136:	68 38 22 80 00       	push   $0x802238
  80013b:	6a 23                	push   $0x23
  80013d:	68 55 22 80 00       	push   $0x802255
  800142:	e8 b0 12 00 00       	call   8013f7 <_panic>

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
  8001b7:	68 38 22 80 00       	push   $0x802238
  8001bc:	6a 23                	push   $0x23
  8001be:	68 55 22 80 00       	push   $0x802255
  8001c3:	e8 2f 12 00 00       	call   8013f7 <_panic>

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
  8001f9:	68 38 22 80 00       	push   $0x802238
  8001fe:	6a 23                	push   $0x23
  800200:	68 55 22 80 00       	push   $0x802255
  800205:	e8 ed 11 00 00       	call   8013f7 <_panic>

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
  80023b:	68 38 22 80 00       	push   $0x802238
  800240:	6a 23                	push   $0x23
  800242:	68 55 22 80 00       	push   $0x802255
  800247:	e8 ab 11 00 00       	call   8013f7 <_panic>

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
  80027d:	68 38 22 80 00       	push   $0x802238
  800282:	6a 23                	push   $0x23
  800284:	68 55 22 80 00       	push   $0x802255
  800289:	e8 69 11 00 00       	call   8013f7 <_panic>

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
  8002bf:	68 38 22 80 00       	push   $0x802238
  8002c4:	6a 23                	push   $0x23
  8002c6:	68 55 22 80 00       	push   $0x802255
  8002cb:	e8 27 11 00 00       	call   8013f7 <_panic>
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
  800301:	68 38 22 80 00       	push   $0x802238
  800306:	6a 23                	push   $0x23
  800308:	68 55 22 80 00       	push   $0x802255
  80030d:	e8 e5 10 00 00       	call   8013f7 <_panic>

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
  800365:	68 38 22 80 00       	push   $0x802238
  80036a:	6a 23                	push   $0x23
  80036c:	68 55 22 80 00       	push   $0x802255
  800371:	e8 81 10 00 00       	call   8013f7 <_panic>

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
  800404:	68 63 22 80 00       	push   $0x802263
  800409:	6a 1e                	push   $0x1e
  80040b:	68 73 22 80 00       	push   $0x802273
  800410:	e8 e2 0f 00 00       	call   8013f7 <_panic>
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
  80042e:	68 7e 22 80 00       	push   $0x80227e
  800433:	6a 2c                	push   $0x2c
  800435:	68 73 22 80 00       	push   $0x802273
  80043a:	e8 b8 0f 00 00       	call   8013f7 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80043f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800445:	83 ec 04             	sub    $0x4,%esp
  800448:	68 00 10 00 00       	push   $0x1000
  80044d:	53                   	push   %ebx
  80044e:	68 00 f0 7f 00       	push   $0x7ff000
  800453:	e8 f7 17 00 00       	call   801c4f <memcpy>

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
  800476:	68 7e 22 80 00       	push   $0x80227e
  80047b:	6a 33                	push   $0x33
  80047d:	68 73 22 80 00       	push   $0x802273
  800482:	e8 70 0f 00 00       	call   8013f7 <_panic>
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
  80049e:	68 7e 22 80 00       	push   $0x80227e
  8004a3:	6a 37                	push   $0x37
  8004a5:	68 73 22 80 00       	push   $0x802273
  8004aa:	e8 48 0f 00 00       	call   8013f7 <_panic>
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
  8004c2:	e8 d5 18 00 00       	call   801d9c <set_pgfault_handler>
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
  8004db:	68 97 22 80 00       	push   $0x802297
  8004e0:	68 84 00 00 00       	push   $0x84
  8004e5:	68 73 22 80 00       	push   $0x802273
  8004ea:	e8 08 0f 00 00       	call   8013f7 <_panic>
  8004ef:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004f5:	75 24                	jne    80051b <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004f7:	e8 53 fc ff ff       	call   80014f <sys_getenvid>
  8004fc:	25 ff 03 00 00       	and    $0x3ff,%eax
  800501:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800597:	68 a5 22 80 00       	push   $0x8022a5
  80059c:	6a 54                	push   $0x54
  80059e:	68 73 22 80 00       	push   $0x802273
  8005a3:	e8 4f 0e 00 00       	call   8013f7 <_panic>
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
  8005dc:	68 a5 22 80 00       	push   $0x8022a5
  8005e1:	6a 5b                	push   $0x5b
  8005e3:	68 73 22 80 00       	push   $0x802273
  8005e8:	e8 0a 0e 00 00       	call   8013f7 <_panic>
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
  80060a:	68 a5 22 80 00       	push   $0x8022a5
  80060f:	6a 5f                	push   $0x5f
  800611:	68 73 22 80 00       	push   $0x802273
  800616:	e8 dc 0d 00 00       	call   8013f7 <_panic>
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
  800634:	68 a5 22 80 00       	push   $0x8022a5
  800639:	6a 64                	push   $0x64
  80063b:	68 73 22 80 00       	push   $0x802273
  800640:	e8 b2 0d 00 00       	call   8013f7 <_panic>
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
  80065c:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	56                   	push   %esi
  800695:	53                   	push   %ebx
  800696:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800699:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	68 bc 22 80 00       	push   $0x8022bc
  8006a8:	e8 23 0e 00 00       	call   8014d0 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006ad:	c7 04 24 97 00 80 00 	movl   $0x800097,(%esp)
  8006b4:	e8 c5 fc ff ff       	call   80037e <sys_thread_create>
  8006b9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	68 bc 22 80 00       	push   $0x8022bc
  8006c4:	e8 07 0e 00 00       	call   8014d0 <cprintf>
	return id;
}
  8006c9:	89 f0                	mov    %esi,%eax
  8006cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006ce:	5b                   	pop    %ebx
  8006cf:	5e                   	pop    %esi
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8006d8:	ff 75 08             	pushl  0x8(%ebp)
  8006db:	e8 be fc ff ff       	call   80039e <sys_thread_free>
}
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    

008006e5 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8006eb:	ff 75 08             	pushl  0x8(%ebp)
  8006ee:	e8 cb fc ff ff       	call   8003be <sys_thread_join>
}
  8006f3:	83 c4 10             	add    $0x10,%esp
  8006f6:	c9                   	leave  
  8006f7:	c3                   	ret    

008006f8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	05 00 00 00 30       	add    $0x30000000,%eax
  800703:	c1 e8 0c             	shr    $0xc,%eax
}
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	05 00 00 00 30       	add    $0x30000000,%eax
  800713:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800718:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800725:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80072a:	89 c2                	mov    %eax,%edx
  80072c:	c1 ea 16             	shr    $0x16,%edx
  80072f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800736:	f6 c2 01             	test   $0x1,%dl
  800739:	74 11                	je     80074c <fd_alloc+0x2d>
  80073b:	89 c2                	mov    %eax,%edx
  80073d:	c1 ea 0c             	shr    $0xc,%edx
  800740:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800747:	f6 c2 01             	test   $0x1,%dl
  80074a:	75 09                	jne    800755 <fd_alloc+0x36>
			*fd_store = fd;
  80074c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
  800753:	eb 17                	jmp    80076c <fd_alloc+0x4d>
  800755:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80075a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80075f:	75 c9                	jne    80072a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800761:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800767:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800774:	83 f8 1f             	cmp    $0x1f,%eax
  800777:	77 36                	ja     8007af <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800779:	c1 e0 0c             	shl    $0xc,%eax
  80077c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800781:	89 c2                	mov    %eax,%edx
  800783:	c1 ea 16             	shr    $0x16,%edx
  800786:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80078d:	f6 c2 01             	test   $0x1,%dl
  800790:	74 24                	je     8007b6 <fd_lookup+0x48>
  800792:	89 c2                	mov    %eax,%edx
  800794:	c1 ea 0c             	shr    $0xc,%edx
  800797:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80079e:	f6 c2 01             	test   $0x1,%dl
  8007a1:	74 1a                	je     8007bd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a6:	89 02                	mov    %eax,(%edx)
	return 0;
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ad:	eb 13                	jmp    8007c2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b4:	eb 0c                	jmp    8007c2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007bb:	eb 05                	jmp    8007c2 <fd_lookup+0x54>
  8007bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cd:	ba 5c 23 80 00       	mov    $0x80235c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007d2:	eb 13                	jmp    8007e7 <dev_lookup+0x23>
  8007d4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007d7:	39 08                	cmp    %ecx,(%eax)
  8007d9:	75 0c                	jne    8007e7 <dev_lookup+0x23>
			*dev = devtab[i];
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007de:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e5:	eb 31                	jmp    800818 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007e7:	8b 02                	mov    (%edx),%eax
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	75 e7                	jne    8007d4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8007f2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	51                   	push   %ecx
  8007fc:	50                   	push   %eax
  8007fd:	68 e0 22 80 00       	push   $0x8022e0
  800802:	e8 c9 0c 00 00       	call   8014d0 <cprintf>
	*dev = 0;
  800807:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800810:	83 c4 10             	add    $0x10,%esp
  800813:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	83 ec 10             	sub    $0x10,%esp
  800822:	8b 75 08             	mov    0x8(%ebp),%esi
  800825:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800828:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082b:	50                   	push   %eax
  80082c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800832:	c1 e8 0c             	shr    $0xc,%eax
  800835:	50                   	push   %eax
  800836:	e8 33 ff ff ff       	call   80076e <fd_lookup>
  80083b:	83 c4 08             	add    $0x8,%esp
  80083e:	85 c0                	test   %eax,%eax
  800840:	78 05                	js     800847 <fd_close+0x2d>
	    || fd != fd2)
  800842:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800845:	74 0c                	je     800853 <fd_close+0x39>
		return (must_exist ? r : 0);
  800847:	84 db                	test   %bl,%bl
  800849:	ba 00 00 00 00       	mov    $0x0,%edx
  80084e:	0f 44 c2             	cmove  %edx,%eax
  800851:	eb 41                	jmp    800894 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800859:	50                   	push   %eax
  80085a:	ff 36                	pushl  (%esi)
  80085c:	e8 63 ff ff ff       	call   8007c4 <dev_lookup>
  800861:	89 c3                	mov    %eax,%ebx
  800863:	83 c4 10             	add    $0x10,%esp
  800866:	85 c0                	test   %eax,%eax
  800868:	78 1a                	js     800884 <fd_close+0x6a>
		if (dev->dev_close)
  80086a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800870:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800875:	85 c0                	test   %eax,%eax
  800877:	74 0b                	je     800884 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800879:	83 ec 0c             	sub    $0xc,%esp
  80087c:	56                   	push   %esi
  80087d:	ff d0                	call   *%eax
  80087f:	89 c3                	mov    %eax,%ebx
  800881:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	56                   	push   %esi
  800888:	6a 00                	push   $0x0
  80088a:	e8 83 f9 ff ff       	call   800212 <sys_page_unmap>
	return r;
  80088f:	83 c4 10             	add    $0x10,%esp
  800892:	89 d8                	mov    %ebx,%eax
}
  800894:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a4:	50                   	push   %eax
  8008a5:	ff 75 08             	pushl  0x8(%ebp)
  8008a8:	e8 c1 fe ff ff       	call   80076e <fd_lookup>
  8008ad:	83 c4 08             	add    $0x8,%esp
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	78 10                	js     8008c4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	6a 01                	push   $0x1
  8008b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8008bc:	e8 59 ff ff ff       	call   80081a <fd_close>
  8008c1:	83 c4 10             	add    $0x10,%esp
}
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <close_all>:

void
close_all(void)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	53                   	push   %ebx
  8008ca:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008cd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008d2:	83 ec 0c             	sub    $0xc,%esp
  8008d5:	53                   	push   %ebx
  8008d6:	e8 c0 ff ff ff       	call   80089b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008db:	83 c3 01             	add    $0x1,%ebx
  8008de:	83 c4 10             	add    $0x10,%esp
  8008e1:	83 fb 20             	cmp    $0x20,%ebx
  8008e4:	75 ec                	jne    8008d2 <close_all+0xc>
		close(i);
}
  8008e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	57                   	push   %edi
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
  8008f1:	83 ec 2c             	sub    $0x2c,%esp
  8008f4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008fa:	50                   	push   %eax
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 6b fe ff ff       	call   80076e <fd_lookup>
  800903:	83 c4 08             	add    $0x8,%esp
  800906:	85 c0                	test   %eax,%eax
  800908:	0f 88 c1 00 00 00    	js     8009cf <dup+0xe4>
		return r;
	close(newfdnum);
  80090e:	83 ec 0c             	sub    $0xc,%esp
  800911:	56                   	push   %esi
  800912:	e8 84 ff ff ff       	call   80089b <close>

	newfd = INDEX2FD(newfdnum);
  800917:	89 f3                	mov    %esi,%ebx
  800919:	c1 e3 0c             	shl    $0xc,%ebx
  80091c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800922:	83 c4 04             	add    $0x4,%esp
  800925:	ff 75 e4             	pushl  -0x1c(%ebp)
  800928:	e8 db fd ff ff       	call   800708 <fd2data>
  80092d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80092f:	89 1c 24             	mov    %ebx,(%esp)
  800932:	e8 d1 fd ff ff       	call   800708 <fd2data>
  800937:	83 c4 10             	add    $0x10,%esp
  80093a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	c1 e8 16             	shr    $0x16,%eax
  800942:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800949:	a8 01                	test   $0x1,%al
  80094b:	74 37                	je     800984 <dup+0x99>
  80094d:	89 f8                	mov    %edi,%eax
  80094f:	c1 e8 0c             	shr    $0xc,%eax
  800952:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800959:	f6 c2 01             	test   $0x1,%dl
  80095c:	74 26                	je     800984 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80095e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800965:	83 ec 0c             	sub    $0xc,%esp
  800968:	25 07 0e 00 00       	and    $0xe07,%eax
  80096d:	50                   	push   %eax
  80096e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800971:	6a 00                	push   $0x0
  800973:	57                   	push   %edi
  800974:	6a 00                	push   $0x0
  800976:	e8 55 f8 ff ff       	call   8001d0 <sys_page_map>
  80097b:	89 c7                	mov    %eax,%edi
  80097d:	83 c4 20             	add    $0x20,%esp
  800980:	85 c0                	test   %eax,%eax
  800982:	78 2e                	js     8009b2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800984:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800987:	89 d0                	mov    %edx,%eax
  800989:	c1 e8 0c             	shr    $0xc,%eax
  80098c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800993:	83 ec 0c             	sub    $0xc,%esp
  800996:	25 07 0e 00 00       	and    $0xe07,%eax
  80099b:	50                   	push   %eax
  80099c:	53                   	push   %ebx
  80099d:	6a 00                	push   $0x0
  80099f:	52                   	push   %edx
  8009a0:	6a 00                	push   $0x0
  8009a2:	e8 29 f8 ff ff       	call   8001d0 <sys_page_map>
  8009a7:	89 c7                	mov    %eax,%edi
  8009a9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8009ac:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009ae:	85 ff                	test   %edi,%edi
  8009b0:	79 1d                	jns    8009cf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8009b2:	83 ec 08             	sub    $0x8,%esp
  8009b5:	53                   	push   %ebx
  8009b6:	6a 00                	push   $0x0
  8009b8:	e8 55 f8 ff ff       	call   800212 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8009bd:	83 c4 08             	add    $0x8,%esp
  8009c0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009c3:	6a 00                	push   $0x0
  8009c5:	e8 48 f8 ff ff       	call   800212 <sys_page_unmap>
	return r;
  8009ca:	83 c4 10             	add    $0x10,%esp
  8009cd:	89 f8                	mov    %edi,%eax
}
  8009cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	83 ec 14             	sub    $0x14,%esp
  8009de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009e4:	50                   	push   %eax
  8009e5:	53                   	push   %ebx
  8009e6:	e8 83 fd ff ff       	call   80076e <fd_lookup>
  8009eb:	83 c4 08             	add    $0x8,%esp
  8009ee:	89 c2                	mov    %eax,%edx
  8009f0:	85 c0                	test   %eax,%eax
  8009f2:	78 70                	js     800a64 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009f4:	83 ec 08             	sub    $0x8,%esp
  8009f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009fa:	50                   	push   %eax
  8009fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009fe:	ff 30                	pushl  (%eax)
  800a00:	e8 bf fd ff ff       	call   8007c4 <dev_lookup>
  800a05:	83 c4 10             	add    $0x10,%esp
  800a08:	85 c0                	test   %eax,%eax
  800a0a:	78 4f                	js     800a5b <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a0f:	8b 42 08             	mov    0x8(%edx),%eax
  800a12:	83 e0 03             	and    $0x3,%eax
  800a15:	83 f8 01             	cmp    $0x1,%eax
  800a18:	75 24                	jne    800a3e <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a1a:	a1 04 40 80 00       	mov    0x804004,%eax
  800a1f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a25:	83 ec 04             	sub    $0x4,%esp
  800a28:	53                   	push   %ebx
  800a29:	50                   	push   %eax
  800a2a:	68 21 23 80 00       	push   $0x802321
  800a2f:	e8 9c 0a 00 00       	call   8014d0 <cprintf>
		return -E_INVAL;
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a3c:	eb 26                	jmp    800a64 <read+0x8d>
	}
	if (!dev->dev_read)
  800a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a41:	8b 40 08             	mov    0x8(%eax),%eax
  800a44:	85 c0                	test   %eax,%eax
  800a46:	74 17                	je     800a5f <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a48:	83 ec 04             	sub    $0x4,%esp
  800a4b:	ff 75 10             	pushl  0x10(%ebp)
  800a4e:	ff 75 0c             	pushl  0xc(%ebp)
  800a51:	52                   	push   %edx
  800a52:	ff d0                	call   *%eax
  800a54:	89 c2                	mov    %eax,%edx
  800a56:	83 c4 10             	add    $0x10,%esp
  800a59:	eb 09                	jmp    800a64 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a5b:	89 c2                	mov    %eax,%edx
  800a5d:	eb 05                	jmp    800a64 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a5f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a64:	89 d0                	mov    %edx,%eax
  800a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	57                   	push   %edi
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	83 ec 0c             	sub    $0xc,%esp
  800a74:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a77:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a7a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a7f:	eb 21                	jmp    800aa2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a81:	83 ec 04             	sub    $0x4,%esp
  800a84:	89 f0                	mov    %esi,%eax
  800a86:	29 d8                	sub    %ebx,%eax
  800a88:	50                   	push   %eax
  800a89:	89 d8                	mov    %ebx,%eax
  800a8b:	03 45 0c             	add    0xc(%ebp),%eax
  800a8e:	50                   	push   %eax
  800a8f:	57                   	push   %edi
  800a90:	e8 42 ff ff ff       	call   8009d7 <read>
		if (m < 0)
  800a95:	83 c4 10             	add    $0x10,%esp
  800a98:	85 c0                	test   %eax,%eax
  800a9a:	78 10                	js     800aac <readn+0x41>
			return m;
		if (m == 0)
  800a9c:	85 c0                	test   %eax,%eax
  800a9e:	74 0a                	je     800aaa <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800aa0:	01 c3                	add    %eax,%ebx
  800aa2:	39 f3                	cmp    %esi,%ebx
  800aa4:	72 db                	jb     800a81 <readn+0x16>
  800aa6:	89 d8                	mov    %ebx,%eax
  800aa8:	eb 02                	jmp    800aac <readn+0x41>
  800aaa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800aac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	53                   	push   %ebx
  800ab8:	83 ec 14             	sub    $0x14,%esp
  800abb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800abe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ac1:	50                   	push   %eax
  800ac2:	53                   	push   %ebx
  800ac3:	e8 a6 fc ff ff       	call   80076e <fd_lookup>
  800ac8:	83 c4 08             	add    $0x8,%esp
  800acb:	89 c2                	mov    %eax,%edx
  800acd:	85 c0                	test   %eax,%eax
  800acf:	78 6b                	js     800b3c <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ad1:	83 ec 08             	sub    $0x8,%esp
  800ad4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad7:	50                   	push   %eax
  800ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800adb:	ff 30                	pushl  (%eax)
  800add:	e8 e2 fc ff ff       	call   8007c4 <dev_lookup>
  800ae2:	83 c4 10             	add    $0x10,%esp
  800ae5:	85 c0                	test   %eax,%eax
  800ae7:	78 4a                	js     800b33 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800af0:	75 24                	jne    800b16 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800af2:	a1 04 40 80 00       	mov    0x804004,%eax
  800af7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800afd:	83 ec 04             	sub    $0x4,%esp
  800b00:	53                   	push   %ebx
  800b01:	50                   	push   %eax
  800b02:	68 3d 23 80 00       	push   $0x80233d
  800b07:	e8 c4 09 00 00       	call   8014d0 <cprintf>
		return -E_INVAL;
  800b0c:	83 c4 10             	add    $0x10,%esp
  800b0f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b14:	eb 26                	jmp    800b3c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b16:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b19:	8b 52 0c             	mov    0xc(%edx),%edx
  800b1c:	85 d2                	test   %edx,%edx
  800b1e:	74 17                	je     800b37 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b20:	83 ec 04             	sub    $0x4,%esp
  800b23:	ff 75 10             	pushl  0x10(%ebp)
  800b26:	ff 75 0c             	pushl  0xc(%ebp)
  800b29:	50                   	push   %eax
  800b2a:	ff d2                	call   *%edx
  800b2c:	89 c2                	mov    %eax,%edx
  800b2e:	83 c4 10             	add    $0x10,%esp
  800b31:	eb 09                	jmp    800b3c <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b33:	89 c2                	mov    %eax,%edx
  800b35:	eb 05                	jmp    800b3c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b37:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b3c:	89 d0                	mov    %edx,%eax
  800b3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b41:	c9                   	leave  
  800b42:	c3                   	ret    

00800b43 <seek>:

int
seek(int fdnum, off_t offset)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b49:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b4c:	50                   	push   %eax
  800b4d:	ff 75 08             	pushl  0x8(%ebp)
  800b50:	e8 19 fc ff ff       	call   80076e <fd_lookup>
  800b55:	83 c4 08             	add    $0x8,%esp
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	78 0e                	js     800b6a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b62:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	53                   	push   %ebx
  800b70:	83 ec 14             	sub    $0x14,%esp
  800b73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b76:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b79:	50                   	push   %eax
  800b7a:	53                   	push   %ebx
  800b7b:	e8 ee fb ff ff       	call   80076e <fd_lookup>
  800b80:	83 c4 08             	add    $0x8,%esp
  800b83:	89 c2                	mov    %eax,%edx
  800b85:	85 c0                	test   %eax,%eax
  800b87:	78 68                	js     800bf1 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b89:	83 ec 08             	sub    $0x8,%esp
  800b8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b8f:	50                   	push   %eax
  800b90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b93:	ff 30                	pushl  (%eax)
  800b95:	e8 2a fc ff ff       	call   8007c4 <dev_lookup>
  800b9a:	83 c4 10             	add    $0x10,%esp
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	78 47                	js     800be8 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ba8:	75 24                	jne    800bce <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800baa:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800baf:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800bb5:	83 ec 04             	sub    $0x4,%esp
  800bb8:	53                   	push   %ebx
  800bb9:	50                   	push   %eax
  800bba:	68 00 23 80 00       	push   $0x802300
  800bbf:	e8 0c 09 00 00       	call   8014d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800bc4:	83 c4 10             	add    $0x10,%esp
  800bc7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bcc:	eb 23                	jmp    800bf1 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800bce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bd1:	8b 52 18             	mov    0x18(%edx),%edx
  800bd4:	85 d2                	test   %edx,%edx
  800bd6:	74 14                	je     800bec <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800bd8:	83 ec 08             	sub    $0x8,%esp
  800bdb:	ff 75 0c             	pushl  0xc(%ebp)
  800bde:	50                   	push   %eax
  800bdf:	ff d2                	call   *%edx
  800be1:	89 c2                	mov    %eax,%edx
  800be3:	83 c4 10             	add    $0x10,%esp
  800be6:	eb 09                	jmp    800bf1 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800be8:	89 c2                	mov    %eax,%edx
  800bea:	eb 05                	jmp    800bf1 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800bec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800bf1:	89 d0                	mov    %edx,%eax
  800bf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 14             	sub    $0x14,%esp
  800bff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c05:	50                   	push   %eax
  800c06:	ff 75 08             	pushl  0x8(%ebp)
  800c09:	e8 60 fb ff ff       	call   80076e <fd_lookup>
  800c0e:	83 c4 08             	add    $0x8,%esp
  800c11:	89 c2                	mov    %eax,%edx
  800c13:	85 c0                	test   %eax,%eax
  800c15:	78 58                	js     800c6f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c17:	83 ec 08             	sub    $0x8,%esp
  800c1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c1d:	50                   	push   %eax
  800c1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c21:	ff 30                	pushl  (%eax)
  800c23:	e8 9c fb ff ff       	call   8007c4 <dev_lookup>
  800c28:	83 c4 10             	add    $0x10,%esp
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	78 37                	js     800c66 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c32:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c36:	74 32                	je     800c6a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c38:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c3b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c42:	00 00 00 
	stat->st_isdir = 0;
  800c45:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c4c:	00 00 00 
	stat->st_dev = dev;
  800c4f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c55:	83 ec 08             	sub    $0x8,%esp
  800c58:	53                   	push   %ebx
  800c59:	ff 75 f0             	pushl  -0x10(%ebp)
  800c5c:	ff 50 14             	call   *0x14(%eax)
  800c5f:	89 c2                	mov    %eax,%edx
  800c61:	83 c4 10             	add    $0x10,%esp
  800c64:	eb 09                	jmp    800c6f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c66:	89 c2                	mov    %eax,%edx
  800c68:	eb 05                	jmp    800c6f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c6a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c6f:	89 d0                	mov    %edx,%eax
  800c71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c74:	c9                   	leave  
  800c75:	c3                   	ret    

00800c76 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c7b:	83 ec 08             	sub    $0x8,%esp
  800c7e:	6a 00                	push   $0x0
  800c80:	ff 75 08             	pushl  0x8(%ebp)
  800c83:	e8 e3 01 00 00       	call   800e6b <open>
  800c88:	89 c3                	mov    %eax,%ebx
  800c8a:	83 c4 10             	add    $0x10,%esp
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	78 1b                	js     800cac <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c91:	83 ec 08             	sub    $0x8,%esp
  800c94:	ff 75 0c             	pushl  0xc(%ebp)
  800c97:	50                   	push   %eax
  800c98:	e8 5b ff ff ff       	call   800bf8 <fstat>
  800c9d:	89 c6                	mov    %eax,%esi
	close(fd);
  800c9f:	89 1c 24             	mov    %ebx,(%esp)
  800ca2:	e8 f4 fb ff ff       	call   80089b <close>
	return r;
  800ca7:	83 c4 10             	add    $0x10,%esp
  800caa:	89 f0                	mov    %esi,%eax
}
  800cac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	89 c6                	mov    %eax,%esi
  800cba:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800cbc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cc3:	75 12                	jne    800cd7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	6a 01                	push   $0x1
  800cca:	e8 39 12 00 00       	call   801f08 <ipc_find_env>
  800ccf:	a3 00 40 80 00       	mov    %eax,0x804000
  800cd4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cd7:	6a 07                	push   $0x7
  800cd9:	68 00 50 80 00       	push   $0x805000
  800cde:	56                   	push   %esi
  800cdf:	ff 35 00 40 80 00    	pushl  0x804000
  800ce5:	e8 bc 11 00 00       	call   801ea6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800cea:	83 c4 0c             	add    $0xc,%esp
  800ced:	6a 00                	push   $0x0
  800cef:	53                   	push   %ebx
  800cf0:	6a 00                	push   $0x0
  800cf2:	e8 34 11 00 00       	call   801e2b <ipc_recv>
}
  800cf7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	8b 40 0c             	mov    0xc(%eax),%eax
  800d0a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d12:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d17:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1c:	b8 02 00 00 00       	mov    $0x2,%eax
  800d21:	e8 8d ff ff ff       	call   800cb3 <fsipc>
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	8b 40 0c             	mov    0xc(%eax),%eax
  800d34:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d39:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d43:	e8 6b ff ff ff       	call   800cb3 <fsipc>
}
  800d48:	c9                   	leave  
  800d49:	c3                   	ret    

00800d4a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 04             	sub    $0x4,%esp
  800d51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d54:	8b 45 08             	mov    0x8(%ebp),%eax
  800d57:	8b 40 0c             	mov    0xc(%eax),%eax
  800d5a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d64:	b8 05 00 00 00       	mov    $0x5,%eax
  800d69:	e8 45 ff ff ff       	call   800cb3 <fsipc>
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	78 2c                	js     800d9e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d72:	83 ec 08             	sub    $0x8,%esp
  800d75:	68 00 50 80 00       	push   $0x805000
  800d7a:	53                   	push   %ebx
  800d7b:	e8 d5 0c 00 00       	call   801a55 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d80:	a1 80 50 80 00       	mov    0x805080,%eax
  800d85:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d8b:	a1 84 50 80 00       	mov    0x805084,%eax
  800d90:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d96:	83 c4 10             	add    $0x10,%esp
  800d99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800da1:	c9                   	leave  
  800da2:	c3                   	ret    

00800da3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800dac:	8b 55 08             	mov    0x8(%ebp),%edx
  800daf:	8b 52 0c             	mov    0xc(%edx),%edx
  800db2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800db8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800dbd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800dc2:	0f 47 c2             	cmova  %edx,%eax
  800dc5:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800dca:	50                   	push   %eax
  800dcb:	ff 75 0c             	pushl  0xc(%ebp)
  800dce:	68 08 50 80 00       	push   $0x805008
  800dd3:	e8 0f 0e 00 00       	call   801be7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800dd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddd:	b8 04 00 00 00       	mov    $0x4,%eax
  800de2:	e8 cc fe ff ff       	call   800cb3 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800de7:	c9                   	leave  
  800de8:	c3                   	ret    

00800de9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	8b 40 0c             	mov    0xc(%eax),%eax
  800df7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800dfc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e02:	ba 00 00 00 00       	mov    $0x0,%edx
  800e07:	b8 03 00 00 00       	mov    $0x3,%eax
  800e0c:	e8 a2 fe ff ff       	call   800cb3 <fsipc>
  800e11:	89 c3                	mov    %eax,%ebx
  800e13:	85 c0                	test   %eax,%eax
  800e15:	78 4b                	js     800e62 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e17:	39 c6                	cmp    %eax,%esi
  800e19:	73 16                	jae    800e31 <devfile_read+0x48>
  800e1b:	68 6c 23 80 00       	push   $0x80236c
  800e20:	68 73 23 80 00       	push   $0x802373
  800e25:	6a 7c                	push   $0x7c
  800e27:	68 88 23 80 00       	push   $0x802388
  800e2c:	e8 c6 05 00 00       	call   8013f7 <_panic>
	assert(r <= PGSIZE);
  800e31:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e36:	7e 16                	jle    800e4e <devfile_read+0x65>
  800e38:	68 93 23 80 00       	push   $0x802393
  800e3d:	68 73 23 80 00       	push   $0x802373
  800e42:	6a 7d                	push   $0x7d
  800e44:	68 88 23 80 00       	push   $0x802388
  800e49:	e8 a9 05 00 00       	call   8013f7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e4e:	83 ec 04             	sub    $0x4,%esp
  800e51:	50                   	push   %eax
  800e52:	68 00 50 80 00       	push   $0x805000
  800e57:	ff 75 0c             	pushl  0xc(%ebp)
  800e5a:	e8 88 0d 00 00       	call   801be7 <memmove>
	return r;
  800e5f:	83 c4 10             	add    $0x10,%esp
}
  800e62:	89 d8                	mov    %ebx,%eax
  800e64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    

00800e6b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	53                   	push   %ebx
  800e6f:	83 ec 20             	sub    $0x20,%esp
  800e72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e75:	53                   	push   %ebx
  800e76:	e8 a1 0b 00 00       	call   801a1c <strlen>
  800e7b:	83 c4 10             	add    $0x10,%esp
  800e7e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e83:	7f 67                	jg     800eec <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e85:	83 ec 0c             	sub    $0xc,%esp
  800e88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8b:	50                   	push   %eax
  800e8c:	e8 8e f8 ff ff       	call   80071f <fd_alloc>
  800e91:	83 c4 10             	add    $0x10,%esp
		return r;
  800e94:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	78 57                	js     800ef1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e9a:	83 ec 08             	sub    $0x8,%esp
  800e9d:	53                   	push   %ebx
  800e9e:	68 00 50 80 00       	push   $0x805000
  800ea3:	e8 ad 0b 00 00       	call   801a55 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eab:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800eb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eb3:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb8:	e8 f6 fd ff ff       	call   800cb3 <fsipc>
  800ebd:	89 c3                	mov    %eax,%ebx
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	79 14                	jns    800eda <open+0x6f>
		fd_close(fd, 0);
  800ec6:	83 ec 08             	sub    $0x8,%esp
  800ec9:	6a 00                	push   $0x0
  800ecb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ece:	e8 47 f9 ff ff       	call   80081a <fd_close>
		return r;
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	89 da                	mov    %ebx,%edx
  800ed8:	eb 17                	jmp    800ef1 <open+0x86>
	}

	return fd2num(fd);
  800eda:	83 ec 0c             	sub    $0xc,%esp
  800edd:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee0:	e8 13 f8 ff ff       	call   8006f8 <fd2num>
  800ee5:	89 c2                	mov    %eax,%edx
  800ee7:	83 c4 10             	add    $0x10,%esp
  800eea:	eb 05                	jmp    800ef1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800eec:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ef1:	89 d0                	mov    %edx,%eax
  800ef3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800efe:	ba 00 00 00 00       	mov    $0x0,%edx
  800f03:	b8 08 00 00 00       	mov    $0x8,%eax
  800f08:	e8 a6 fd ff ff       	call   800cb3 <fsipc>
}
  800f0d:	c9                   	leave  
  800f0e:	c3                   	ret    

00800f0f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f17:	83 ec 0c             	sub    $0xc,%esp
  800f1a:	ff 75 08             	pushl  0x8(%ebp)
  800f1d:	e8 e6 f7 ff ff       	call   800708 <fd2data>
  800f22:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f24:	83 c4 08             	add    $0x8,%esp
  800f27:	68 9f 23 80 00       	push   $0x80239f
  800f2c:	53                   	push   %ebx
  800f2d:	e8 23 0b 00 00       	call   801a55 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f32:	8b 46 04             	mov    0x4(%esi),%eax
  800f35:	2b 06                	sub    (%esi),%eax
  800f37:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f3d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f44:	00 00 00 
	stat->st_dev = &devpipe;
  800f47:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800f4e:	30 80 00 
	return 0;
}
  800f51:	b8 00 00 00 00       	mov    $0x0,%eax
  800f56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f59:	5b                   	pop    %ebx
  800f5a:	5e                   	pop    %esi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	53                   	push   %ebx
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f67:	53                   	push   %ebx
  800f68:	6a 00                	push   $0x0
  800f6a:	e8 a3 f2 ff ff       	call   800212 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f6f:	89 1c 24             	mov    %ebx,(%esp)
  800f72:	e8 91 f7 ff ff       	call   800708 <fd2data>
  800f77:	83 c4 08             	add    $0x8,%esp
  800f7a:	50                   	push   %eax
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 90 f2 ff ff       	call   800212 <sys_page_unmap>
}
  800f82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 1c             	sub    $0x1c,%esp
  800f90:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f93:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f95:	a1 04 40 80 00       	mov    0x804004,%eax
  800f9a:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	ff 75 e0             	pushl  -0x20(%ebp)
  800fa6:	e8 a2 0f 00 00       	call   801f4d <pageref>
  800fab:	89 c3                	mov    %eax,%ebx
  800fad:	89 3c 24             	mov    %edi,(%esp)
  800fb0:	e8 98 0f 00 00       	call   801f4d <pageref>
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	39 c3                	cmp    %eax,%ebx
  800fba:	0f 94 c1             	sete   %cl
  800fbd:	0f b6 c9             	movzbl %cl,%ecx
  800fc0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800fc3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fc9:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  800fcf:	39 ce                	cmp    %ecx,%esi
  800fd1:	74 1e                	je     800ff1 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800fd3:	39 c3                	cmp    %eax,%ebx
  800fd5:	75 be                	jne    800f95 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fd7:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  800fdd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe0:	50                   	push   %eax
  800fe1:	56                   	push   %esi
  800fe2:	68 a6 23 80 00       	push   $0x8023a6
  800fe7:	e8 e4 04 00 00       	call   8014d0 <cprintf>
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	eb a4                	jmp    800f95 <_pipeisclosed+0xe>
	}
}
  800ff1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ff4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	83 ec 28             	sub    $0x28,%esp
  801005:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801008:	56                   	push   %esi
  801009:	e8 fa f6 ff ff       	call   800708 <fd2data>
  80100e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	bf 00 00 00 00       	mov    $0x0,%edi
  801018:	eb 4b                	jmp    801065 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80101a:	89 da                	mov    %ebx,%edx
  80101c:	89 f0                	mov    %esi,%eax
  80101e:	e8 64 ff ff ff       	call   800f87 <_pipeisclosed>
  801023:	85 c0                	test   %eax,%eax
  801025:	75 48                	jne    80106f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801027:	e8 42 f1 ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80102c:	8b 43 04             	mov    0x4(%ebx),%eax
  80102f:	8b 0b                	mov    (%ebx),%ecx
  801031:	8d 51 20             	lea    0x20(%ecx),%edx
  801034:	39 d0                	cmp    %edx,%eax
  801036:	73 e2                	jae    80101a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801038:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80103f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801042:	89 c2                	mov    %eax,%edx
  801044:	c1 fa 1f             	sar    $0x1f,%edx
  801047:	89 d1                	mov    %edx,%ecx
  801049:	c1 e9 1b             	shr    $0x1b,%ecx
  80104c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80104f:	83 e2 1f             	and    $0x1f,%edx
  801052:	29 ca                	sub    %ecx,%edx
  801054:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801058:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80105c:	83 c0 01             	add    $0x1,%eax
  80105f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801062:	83 c7 01             	add    $0x1,%edi
  801065:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801068:	75 c2                	jne    80102c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80106a:	8b 45 10             	mov    0x10(%ebp),%eax
  80106d:	eb 05                	jmp    801074 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80106f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801074:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801077:	5b                   	pop    %ebx
  801078:	5e                   	pop    %esi
  801079:	5f                   	pop    %edi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	57                   	push   %edi
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
  801082:	83 ec 18             	sub    $0x18,%esp
  801085:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801088:	57                   	push   %edi
  801089:	e8 7a f6 ff ff       	call   800708 <fd2data>
  80108e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	bb 00 00 00 00       	mov    $0x0,%ebx
  801098:	eb 3d                	jmp    8010d7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80109a:	85 db                	test   %ebx,%ebx
  80109c:	74 04                	je     8010a2 <devpipe_read+0x26>
				return i;
  80109e:	89 d8                	mov    %ebx,%eax
  8010a0:	eb 44                	jmp    8010e6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8010a2:	89 f2                	mov    %esi,%edx
  8010a4:	89 f8                	mov    %edi,%eax
  8010a6:	e8 dc fe ff ff       	call   800f87 <_pipeisclosed>
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	75 32                	jne    8010e1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8010af:	e8 ba f0 ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010b4:	8b 06                	mov    (%esi),%eax
  8010b6:	3b 46 04             	cmp    0x4(%esi),%eax
  8010b9:	74 df                	je     80109a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010bb:	99                   	cltd   
  8010bc:	c1 ea 1b             	shr    $0x1b,%edx
  8010bf:	01 d0                	add    %edx,%eax
  8010c1:	83 e0 1f             	and    $0x1f,%eax
  8010c4:	29 d0                	sub    %edx,%eax
  8010c6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ce:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010d1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010d4:	83 c3 01             	add    $0x1,%ebx
  8010d7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010da:	75 d8                	jne    8010b4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8010df:	eb 05                	jmp    8010e6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010e1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	5f                   	pop    %edi
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f9:	50                   	push   %eax
  8010fa:	e8 20 f6 ff ff       	call   80071f <fd_alloc>
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	89 c2                	mov    %eax,%edx
  801104:	85 c0                	test   %eax,%eax
  801106:	0f 88 2c 01 00 00    	js     801238 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	68 07 04 00 00       	push   $0x407
  801114:	ff 75 f4             	pushl  -0xc(%ebp)
  801117:	6a 00                	push   $0x0
  801119:	e8 6f f0 ff ff       	call   80018d <sys_page_alloc>
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	89 c2                	mov    %eax,%edx
  801123:	85 c0                	test   %eax,%eax
  801125:	0f 88 0d 01 00 00    	js     801238 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801131:	50                   	push   %eax
  801132:	e8 e8 f5 ff ff       	call   80071f <fd_alloc>
  801137:	89 c3                	mov    %eax,%ebx
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	0f 88 e2 00 00 00    	js     801226 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	68 07 04 00 00       	push   $0x407
  80114c:	ff 75 f0             	pushl  -0x10(%ebp)
  80114f:	6a 00                	push   $0x0
  801151:	e8 37 f0 ff ff       	call   80018d <sys_page_alloc>
  801156:	89 c3                	mov    %eax,%ebx
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	0f 88 c3 00 00 00    	js     801226 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	ff 75 f4             	pushl  -0xc(%ebp)
  801169:	e8 9a f5 ff ff       	call   800708 <fd2data>
  80116e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801170:	83 c4 0c             	add    $0xc,%esp
  801173:	68 07 04 00 00       	push   $0x407
  801178:	50                   	push   %eax
  801179:	6a 00                	push   $0x0
  80117b:	e8 0d f0 ff ff       	call   80018d <sys_page_alloc>
  801180:	89 c3                	mov    %eax,%ebx
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	85 c0                	test   %eax,%eax
  801187:	0f 88 89 00 00 00    	js     801216 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80118d:	83 ec 0c             	sub    $0xc,%esp
  801190:	ff 75 f0             	pushl  -0x10(%ebp)
  801193:	e8 70 f5 ff ff       	call   800708 <fd2data>
  801198:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80119f:	50                   	push   %eax
  8011a0:	6a 00                	push   $0x0
  8011a2:	56                   	push   %esi
  8011a3:	6a 00                	push   $0x0
  8011a5:	e8 26 f0 ff ff       	call   8001d0 <sys_page_map>
  8011aa:	89 c3                	mov    %eax,%ebx
  8011ac:	83 c4 20             	add    $0x20,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 55                	js     801208 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8011b3:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8011b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011c8:	8b 15 24 30 80 00    	mov    0x803024,%edx
  8011ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011dd:	83 ec 0c             	sub    $0xc,%esp
  8011e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e3:	e8 10 f5 ff ff       	call   8006f8 <fd2num>
  8011e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011eb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011ed:	83 c4 04             	add    $0x4,%esp
  8011f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8011f3:	e8 00 f5 ff ff       	call   8006f8 <fd2num>
  8011f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fb:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	ba 00 00 00 00       	mov    $0x0,%edx
  801206:	eb 30                	jmp    801238 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801208:	83 ec 08             	sub    $0x8,%esp
  80120b:	56                   	push   %esi
  80120c:	6a 00                	push   $0x0
  80120e:	e8 ff ef ff ff       	call   800212 <sys_page_unmap>
  801213:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801216:	83 ec 08             	sub    $0x8,%esp
  801219:	ff 75 f0             	pushl  -0x10(%ebp)
  80121c:	6a 00                	push   $0x0
  80121e:	e8 ef ef ff ff       	call   800212 <sys_page_unmap>
  801223:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801226:	83 ec 08             	sub    $0x8,%esp
  801229:	ff 75 f4             	pushl  -0xc(%ebp)
  80122c:	6a 00                	push   $0x0
  80122e:	e8 df ef ff ff       	call   800212 <sys_page_unmap>
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801238:	89 d0                	mov    %edx,%eax
  80123a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801247:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124a:	50                   	push   %eax
  80124b:	ff 75 08             	pushl  0x8(%ebp)
  80124e:	e8 1b f5 ff ff       	call   80076e <fd_lookup>
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	78 18                	js     801272 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80125a:	83 ec 0c             	sub    $0xc,%esp
  80125d:	ff 75 f4             	pushl  -0xc(%ebp)
  801260:	e8 a3 f4 ff ff       	call   800708 <fd2data>
	return _pipeisclosed(fd, p);
  801265:	89 c2                	mov    %eax,%edx
  801267:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80126a:	e8 18 fd ff ff       	call   800f87 <_pipeisclosed>
  80126f:	83 c4 10             	add    $0x10,%esp
}
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801277:	b8 00 00 00 00       	mov    $0x0,%eax
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801284:	68 be 23 80 00       	push   $0x8023be
  801289:	ff 75 0c             	pushl  0xc(%ebp)
  80128c:	e8 c4 07 00 00       	call   801a55 <strcpy>
	return 0;
}
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012a4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012a9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012af:	eb 2d                	jmp    8012de <devcons_write+0x46>
		m = n - tot;
  8012b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012b4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8012b6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012b9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8012be:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012c1:	83 ec 04             	sub    $0x4,%esp
  8012c4:	53                   	push   %ebx
  8012c5:	03 45 0c             	add    0xc(%ebp),%eax
  8012c8:	50                   	push   %eax
  8012c9:	57                   	push   %edi
  8012ca:	e8 18 09 00 00       	call   801be7 <memmove>
		sys_cputs(buf, m);
  8012cf:	83 c4 08             	add    $0x8,%esp
  8012d2:	53                   	push   %ebx
  8012d3:	57                   	push   %edi
  8012d4:	e8 f8 ed ff ff       	call   8000d1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012d9:	01 de                	add    %ebx,%esi
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	89 f0                	mov    %esi,%eax
  8012e0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012e3:	72 cc                	jb     8012b1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5f                   	pop    %edi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012fc:	74 2a                	je     801328 <devcons_read+0x3b>
  8012fe:	eb 05                	jmp    801305 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801300:	e8 69 ee ff ff       	call   80016e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801305:	e8 e5 ed ff ff       	call   8000ef <sys_cgetc>
  80130a:	85 c0                	test   %eax,%eax
  80130c:	74 f2                	je     801300 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80130e:	85 c0                	test   %eax,%eax
  801310:	78 16                	js     801328 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801312:	83 f8 04             	cmp    $0x4,%eax
  801315:	74 0c                	je     801323 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801317:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131a:	88 02                	mov    %al,(%edx)
	return 1;
  80131c:	b8 01 00 00 00       	mov    $0x1,%eax
  801321:	eb 05                	jmp    801328 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801323:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801328:	c9                   	leave  
  801329:	c3                   	ret    

0080132a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801336:	6a 01                	push   $0x1
  801338:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	e8 90 ed ff ff       	call   8000d1 <sys_cputs>
}
  801341:	83 c4 10             	add    $0x10,%esp
  801344:	c9                   	leave  
  801345:	c3                   	ret    

00801346 <getchar>:

int
getchar(void)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80134c:	6a 01                	push   $0x1
  80134e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801351:	50                   	push   %eax
  801352:	6a 00                	push   $0x0
  801354:	e8 7e f6 ff ff       	call   8009d7 <read>
	if (r < 0)
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 0f                	js     80136f <getchar+0x29>
		return r;
	if (r < 1)
  801360:	85 c0                	test   %eax,%eax
  801362:	7e 06                	jle    80136a <getchar+0x24>
		return -E_EOF;
	return c;
  801364:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801368:	eb 05                	jmp    80136f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80136a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801377:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	ff 75 08             	pushl  0x8(%ebp)
  80137e:	e8 eb f3 ff ff       	call   80076e <fd_lookup>
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 11                	js     80139b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80138a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138d:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801393:	39 10                	cmp    %edx,(%eax)
  801395:	0f 94 c0             	sete   %al
  801398:	0f b6 c0             	movzbl %al,%eax
}
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <opencons>:

int
opencons(void)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a6:	50                   	push   %eax
  8013a7:	e8 73 f3 ff ff       	call   80071f <fd_alloc>
  8013ac:	83 c4 10             	add    $0x10,%esp
		return r;
  8013af:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 3e                	js     8013f3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	68 07 04 00 00       	push   $0x407
  8013bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c0:	6a 00                	push   $0x0
  8013c2:	e8 c6 ed ff ff       	call   80018d <sys_page_alloc>
  8013c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8013ca:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 23                	js     8013f3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013d0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8013d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013de:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	50                   	push   %eax
  8013e9:	e8 0a f3 ff ff       	call   8006f8 <fd2num>
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	83 c4 10             	add    $0x10,%esp
}
  8013f3:	89 d0                	mov    %edx,%eax
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	56                   	push   %esi
  8013fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013ff:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801405:	e8 45 ed ff ff       	call   80014f <sys_getenvid>
  80140a:	83 ec 0c             	sub    $0xc,%esp
  80140d:	ff 75 0c             	pushl  0xc(%ebp)
  801410:	ff 75 08             	pushl  0x8(%ebp)
  801413:	56                   	push   %esi
  801414:	50                   	push   %eax
  801415:	68 cc 23 80 00       	push   $0x8023cc
  80141a:	e8 b1 00 00 00       	call   8014d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80141f:	83 c4 18             	add    $0x18,%esp
  801422:	53                   	push   %ebx
  801423:	ff 75 10             	pushl  0x10(%ebp)
  801426:	e8 54 00 00 00       	call   80147f <vcprintf>
	cprintf("\n");
  80142b:	c7 04 24 b7 23 80 00 	movl   $0x8023b7,(%esp)
  801432:	e8 99 00 00 00       	call   8014d0 <cprintf>
  801437:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80143a:	cc                   	int3   
  80143b:	eb fd                	jmp    80143a <_panic+0x43>

0080143d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	53                   	push   %ebx
  801441:	83 ec 04             	sub    $0x4,%esp
  801444:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801447:	8b 13                	mov    (%ebx),%edx
  801449:	8d 42 01             	lea    0x1(%edx),%eax
  80144c:	89 03                	mov    %eax,(%ebx)
  80144e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801451:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801455:	3d ff 00 00 00       	cmp    $0xff,%eax
  80145a:	75 1a                	jne    801476 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	68 ff 00 00 00       	push   $0xff
  801464:	8d 43 08             	lea    0x8(%ebx),%eax
  801467:	50                   	push   %eax
  801468:	e8 64 ec ff ff       	call   8000d1 <sys_cputs>
		b->idx = 0;
  80146d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801473:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801476:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80147a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147d:	c9                   	leave  
  80147e:	c3                   	ret    

0080147f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80147f:	55                   	push   %ebp
  801480:	89 e5                	mov    %esp,%ebp
  801482:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801488:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80148f:	00 00 00 
	b.cnt = 0;
  801492:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801499:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80149c:	ff 75 0c             	pushl  0xc(%ebp)
  80149f:	ff 75 08             	pushl  0x8(%ebp)
  8014a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	68 3d 14 80 00       	push   $0x80143d
  8014ae:	e8 54 01 00 00       	call   801607 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014b3:	83 c4 08             	add    $0x8,%esp
  8014b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	e8 09 ec ff ff       	call   8000d1 <sys_cputs>

	return b.cnt;
}
  8014c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014d9:	50                   	push   %eax
  8014da:	ff 75 08             	pushl  0x8(%ebp)
  8014dd:	e8 9d ff ff ff       	call   80147f <vcprintf>
	va_end(ap);

	return cnt;
}
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	57                   	push   %edi
  8014e8:	56                   	push   %esi
  8014e9:	53                   	push   %ebx
  8014ea:	83 ec 1c             	sub    $0x1c,%esp
  8014ed:	89 c7                	mov    %eax,%edi
  8014ef:	89 d6                	mov    %edx,%esi
  8014f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801500:	bb 00 00 00 00       	mov    $0x0,%ebx
  801505:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801508:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80150b:	39 d3                	cmp    %edx,%ebx
  80150d:	72 05                	jb     801514 <printnum+0x30>
  80150f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801512:	77 45                	ja     801559 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801514:	83 ec 0c             	sub    $0xc,%esp
  801517:	ff 75 18             	pushl  0x18(%ebp)
  80151a:	8b 45 14             	mov    0x14(%ebp),%eax
  80151d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801520:	53                   	push   %ebx
  801521:	ff 75 10             	pushl  0x10(%ebp)
  801524:	83 ec 08             	sub    $0x8,%esp
  801527:	ff 75 e4             	pushl  -0x1c(%ebp)
  80152a:	ff 75 e0             	pushl  -0x20(%ebp)
  80152d:	ff 75 dc             	pushl  -0x24(%ebp)
  801530:	ff 75 d8             	pushl  -0x28(%ebp)
  801533:	e8 58 0a 00 00       	call   801f90 <__udivdi3>
  801538:	83 c4 18             	add    $0x18,%esp
  80153b:	52                   	push   %edx
  80153c:	50                   	push   %eax
  80153d:	89 f2                	mov    %esi,%edx
  80153f:	89 f8                	mov    %edi,%eax
  801541:	e8 9e ff ff ff       	call   8014e4 <printnum>
  801546:	83 c4 20             	add    $0x20,%esp
  801549:	eb 18                	jmp    801563 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	56                   	push   %esi
  80154f:	ff 75 18             	pushl  0x18(%ebp)
  801552:	ff d7                	call   *%edi
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	eb 03                	jmp    80155c <printnum+0x78>
  801559:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80155c:	83 eb 01             	sub    $0x1,%ebx
  80155f:	85 db                	test   %ebx,%ebx
  801561:	7f e8                	jg     80154b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	56                   	push   %esi
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80156d:	ff 75 e0             	pushl  -0x20(%ebp)
  801570:	ff 75 dc             	pushl  -0x24(%ebp)
  801573:	ff 75 d8             	pushl  -0x28(%ebp)
  801576:	e8 45 0b 00 00       	call   8020c0 <__umoddi3>
  80157b:	83 c4 14             	add    $0x14,%esp
  80157e:	0f be 80 ef 23 80 00 	movsbl 0x8023ef(%eax),%eax
  801585:	50                   	push   %eax
  801586:	ff d7                	call   *%edi
}
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158e:	5b                   	pop    %ebx
  80158f:	5e                   	pop    %esi
  801590:	5f                   	pop    %edi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    

00801593 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801596:	83 fa 01             	cmp    $0x1,%edx
  801599:	7e 0e                	jle    8015a9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80159b:	8b 10                	mov    (%eax),%edx
  80159d:	8d 4a 08             	lea    0x8(%edx),%ecx
  8015a0:	89 08                	mov    %ecx,(%eax)
  8015a2:	8b 02                	mov    (%edx),%eax
  8015a4:	8b 52 04             	mov    0x4(%edx),%edx
  8015a7:	eb 22                	jmp    8015cb <getuint+0x38>
	else if (lflag)
  8015a9:	85 d2                	test   %edx,%edx
  8015ab:	74 10                	je     8015bd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8015ad:	8b 10                	mov    (%eax),%edx
  8015af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015b2:	89 08                	mov    %ecx,(%eax)
  8015b4:	8b 02                	mov    (%edx),%eax
  8015b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bb:	eb 0e                	jmp    8015cb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015bd:	8b 10                	mov    (%eax),%edx
  8015bf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015c2:	89 08                	mov    %ecx,(%eax)
  8015c4:	8b 02                	mov    (%edx),%eax
  8015c6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015cb:	5d                   	pop    %ebp
  8015cc:	c3                   	ret    

008015cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015d7:	8b 10                	mov    (%eax),%edx
  8015d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8015dc:	73 0a                	jae    8015e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8015de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015e1:	89 08                	mov    %ecx,(%eax)
  8015e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e6:	88 02                	mov    %al,(%edx)
}
  8015e8:	5d                   	pop    %ebp
  8015e9:	c3                   	ret    

008015ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015f3:	50                   	push   %eax
  8015f4:	ff 75 10             	pushl  0x10(%ebp)
  8015f7:	ff 75 0c             	pushl  0xc(%ebp)
  8015fa:	ff 75 08             	pushl  0x8(%ebp)
  8015fd:	e8 05 00 00 00       	call   801607 <vprintfmt>
	va_end(ap);
}
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	57                   	push   %edi
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	83 ec 2c             	sub    $0x2c,%esp
  801610:	8b 75 08             	mov    0x8(%ebp),%esi
  801613:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801616:	8b 7d 10             	mov    0x10(%ebp),%edi
  801619:	eb 12                	jmp    80162d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80161b:	85 c0                	test   %eax,%eax
  80161d:	0f 84 89 03 00 00    	je     8019ac <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	53                   	push   %ebx
  801627:	50                   	push   %eax
  801628:	ff d6                	call   *%esi
  80162a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80162d:	83 c7 01             	add    $0x1,%edi
  801630:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801634:	83 f8 25             	cmp    $0x25,%eax
  801637:	75 e2                	jne    80161b <vprintfmt+0x14>
  801639:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80163d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801644:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80164b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801652:	ba 00 00 00 00       	mov    $0x0,%edx
  801657:	eb 07                	jmp    801660 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801659:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80165c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801660:	8d 47 01             	lea    0x1(%edi),%eax
  801663:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801666:	0f b6 07             	movzbl (%edi),%eax
  801669:	0f b6 c8             	movzbl %al,%ecx
  80166c:	83 e8 23             	sub    $0x23,%eax
  80166f:	3c 55                	cmp    $0x55,%al
  801671:	0f 87 1a 03 00 00    	ja     801991 <vprintfmt+0x38a>
  801677:	0f b6 c0             	movzbl %al,%eax
  80167a:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  801681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801684:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801688:	eb d6                	jmp    801660 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80168a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80168d:	b8 00 00 00 00       	mov    $0x0,%eax
  801692:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801695:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801698:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80169c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80169f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8016a2:	83 fa 09             	cmp    $0x9,%edx
  8016a5:	77 39                	ja     8016e0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8016a7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8016aa:	eb e9                	jmp    801695 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8016ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8016af:	8d 48 04             	lea    0x4(%eax),%ecx
  8016b2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8016b5:	8b 00                	mov    (%eax),%eax
  8016b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016bd:	eb 27                	jmp    8016e6 <vprintfmt+0xdf>
  8016bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016c9:	0f 49 c8             	cmovns %eax,%ecx
  8016cc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016d2:	eb 8c                	jmp    801660 <vprintfmt+0x59>
  8016d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8016d7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016de:	eb 80                	jmp    801660 <vprintfmt+0x59>
  8016e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016e3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016ea:	0f 89 70 ff ff ff    	jns    801660 <vprintfmt+0x59>
				width = precision, precision = -1;
  8016f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016fd:	e9 5e ff ff ff       	jmp    801660 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801702:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801705:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801708:	e9 53 ff ff ff       	jmp    801660 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80170d:	8b 45 14             	mov    0x14(%ebp),%eax
  801710:	8d 50 04             	lea    0x4(%eax),%edx
  801713:	89 55 14             	mov    %edx,0x14(%ebp)
  801716:	83 ec 08             	sub    $0x8,%esp
  801719:	53                   	push   %ebx
  80171a:	ff 30                	pushl  (%eax)
  80171c:	ff d6                	call   *%esi
			break;
  80171e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801721:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801724:	e9 04 ff ff ff       	jmp    80162d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801729:	8b 45 14             	mov    0x14(%ebp),%eax
  80172c:	8d 50 04             	lea    0x4(%eax),%edx
  80172f:	89 55 14             	mov    %edx,0x14(%ebp)
  801732:	8b 00                	mov    (%eax),%eax
  801734:	99                   	cltd   
  801735:	31 d0                	xor    %edx,%eax
  801737:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801739:	83 f8 0f             	cmp    $0xf,%eax
  80173c:	7f 0b                	jg     801749 <vprintfmt+0x142>
  80173e:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  801745:	85 d2                	test   %edx,%edx
  801747:	75 18                	jne    801761 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801749:	50                   	push   %eax
  80174a:	68 07 24 80 00       	push   $0x802407
  80174f:	53                   	push   %ebx
  801750:	56                   	push   %esi
  801751:	e8 94 fe ff ff       	call   8015ea <printfmt>
  801756:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801759:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80175c:	e9 cc fe ff ff       	jmp    80162d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801761:	52                   	push   %edx
  801762:	68 85 23 80 00       	push   $0x802385
  801767:	53                   	push   %ebx
  801768:	56                   	push   %esi
  801769:	e8 7c fe ff ff       	call   8015ea <printfmt>
  80176e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801771:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801774:	e9 b4 fe ff ff       	jmp    80162d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801779:	8b 45 14             	mov    0x14(%ebp),%eax
  80177c:	8d 50 04             	lea    0x4(%eax),%edx
  80177f:	89 55 14             	mov    %edx,0x14(%ebp)
  801782:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801784:	85 ff                	test   %edi,%edi
  801786:	b8 00 24 80 00       	mov    $0x802400,%eax
  80178b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80178e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801792:	0f 8e 94 00 00 00    	jle    80182c <vprintfmt+0x225>
  801798:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80179c:	0f 84 98 00 00 00    	je     80183a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	ff 75 d0             	pushl  -0x30(%ebp)
  8017a8:	57                   	push   %edi
  8017a9:	e8 86 02 00 00       	call   801a34 <strnlen>
  8017ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017b1:	29 c1                	sub    %eax,%ecx
  8017b3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8017b6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017b9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017c3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017c5:	eb 0f                	jmp    8017d6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	53                   	push   %ebx
  8017cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8017ce:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017d0:	83 ef 01             	sub    $0x1,%edi
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	85 ff                	test   %edi,%edi
  8017d8:	7f ed                	jg     8017c7 <vprintfmt+0x1c0>
  8017da:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017dd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017e0:	85 c9                	test   %ecx,%ecx
  8017e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e7:	0f 49 c1             	cmovns %ecx,%eax
  8017ea:	29 c1                	sub    %eax,%ecx
  8017ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8017ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017f5:	89 cb                	mov    %ecx,%ebx
  8017f7:	eb 4d                	jmp    801846 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017fd:	74 1b                	je     80181a <vprintfmt+0x213>
  8017ff:	0f be c0             	movsbl %al,%eax
  801802:	83 e8 20             	sub    $0x20,%eax
  801805:	83 f8 5e             	cmp    $0x5e,%eax
  801808:	76 10                	jbe    80181a <vprintfmt+0x213>
					putch('?', putdat);
  80180a:	83 ec 08             	sub    $0x8,%esp
  80180d:	ff 75 0c             	pushl  0xc(%ebp)
  801810:	6a 3f                	push   $0x3f
  801812:	ff 55 08             	call   *0x8(%ebp)
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	eb 0d                	jmp    801827 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	ff 75 0c             	pushl  0xc(%ebp)
  801820:	52                   	push   %edx
  801821:	ff 55 08             	call   *0x8(%ebp)
  801824:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801827:	83 eb 01             	sub    $0x1,%ebx
  80182a:	eb 1a                	jmp    801846 <vprintfmt+0x23f>
  80182c:	89 75 08             	mov    %esi,0x8(%ebp)
  80182f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801832:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801835:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801838:	eb 0c                	jmp    801846 <vprintfmt+0x23f>
  80183a:	89 75 08             	mov    %esi,0x8(%ebp)
  80183d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801840:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801843:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801846:	83 c7 01             	add    $0x1,%edi
  801849:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80184d:	0f be d0             	movsbl %al,%edx
  801850:	85 d2                	test   %edx,%edx
  801852:	74 23                	je     801877 <vprintfmt+0x270>
  801854:	85 f6                	test   %esi,%esi
  801856:	78 a1                	js     8017f9 <vprintfmt+0x1f2>
  801858:	83 ee 01             	sub    $0x1,%esi
  80185b:	79 9c                	jns    8017f9 <vprintfmt+0x1f2>
  80185d:	89 df                	mov    %ebx,%edi
  80185f:	8b 75 08             	mov    0x8(%ebp),%esi
  801862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801865:	eb 18                	jmp    80187f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801867:	83 ec 08             	sub    $0x8,%esp
  80186a:	53                   	push   %ebx
  80186b:	6a 20                	push   $0x20
  80186d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80186f:	83 ef 01             	sub    $0x1,%edi
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	eb 08                	jmp    80187f <vprintfmt+0x278>
  801877:	89 df                	mov    %ebx,%edi
  801879:	8b 75 08             	mov    0x8(%ebp),%esi
  80187c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80187f:	85 ff                	test   %edi,%edi
  801881:	7f e4                	jg     801867 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801883:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801886:	e9 a2 fd ff ff       	jmp    80162d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80188b:	83 fa 01             	cmp    $0x1,%edx
  80188e:	7e 16                	jle    8018a6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801890:	8b 45 14             	mov    0x14(%ebp),%eax
  801893:	8d 50 08             	lea    0x8(%eax),%edx
  801896:	89 55 14             	mov    %edx,0x14(%ebp)
  801899:	8b 50 04             	mov    0x4(%eax),%edx
  80189c:	8b 00                	mov    (%eax),%eax
  80189e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018a4:	eb 32                	jmp    8018d8 <vprintfmt+0x2d1>
	else if (lflag)
  8018a6:	85 d2                	test   %edx,%edx
  8018a8:	74 18                	je     8018c2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8018aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ad:	8d 50 04             	lea    0x4(%eax),%edx
  8018b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b3:	8b 00                	mov    (%eax),%eax
  8018b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018b8:	89 c1                	mov    %eax,%ecx
  8018ba:	c1 f9 1f             	sar    $0x1f,%ecx
  8018bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018c0:	eb 16                	jmp    8018d8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8018c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c5:	8d 50 04             	lea    0x4(%eax),%edx
  8018c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8018cb:	8b 00                	mov    (%eax),%eax
  8018cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018d0:	89 c1                	mov    %eax,%ecx
  8018d2:	c1 f9 1f             	sar    $0x1f,%ecx
  8018d5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018db:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018de:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018e3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018e7:	79 74                	jns    80195d <vprintfmt+0x356>
				putch('-', putdat);
  8018e9:	83 ec 08             	sub    $0x8,%esp
  8018ec:	53                   	push   %ebx
  8018ed:	6a 2d                	push   $0x2d
  8018ef:	ff d6                	call   *%esi
				num = -(long long) num;
  8018f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018f4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018f7:	f7 d8                	neg    %eax
  8018f9:	83 d2 00             	adc    $0x0,%edx
  8018fc:	f7 da                	neg    %edx
  8018fe:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801901:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801906:	eb 55                	jmp    80195d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801908:	8d 45 14             	lea    0x14(%ebp),%eax
  80190b:	e8 83 fc ff ff       	call   801593 <getuint>
			base = 10;
  801910:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801915:	eb 46                	jmp    80195d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801917:	8d 45 14             	lea    0x14(%ebp),%eax
  80191a:	e8 74 fc ff ff       	call   801593 <getuint>
			base = 8;
  80191f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801924:	eb 37                	jmp    80195d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	53                   	push   %ebx
  80192a:	6a 30                	push   $0x30
  80192c:	ff d6                	call   *%esi
			putch('x', putdat);
  80192e:	83 c4 08             	add    $0x8,%esp
  801931:	53                   	push   %ebx
  801932:	6a 78                	push   $0x78
  801934:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801936:	8b 45 14             	mov    0x14(%ebp),%eax
  801939:	8d 50 04             	lea    0x4(%eax),%edx
  80193c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80193f:	8b 00                	mov    (%eax),%eax
  801941:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801946:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801949:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80194e:	eb 0d                	jmp    80195d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801950:	8d 45 14             	lea    0x14(%ebp),%eax
  801953:	e8 3b fc ff ff       	call   801593 <getuint>
			base = 16;
  801958:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801964:	57                   	push   %edi
  801965:	ff 75 e0             	pushl  -0x20(%ebp)
  801968:	51                   	push   %ecx
  801969:	52                   	push   %edx
  80196a:	50                   	push   %eax
  80196b:	89 da                	mov    %ebx,%edx
  80196d:	89 f0                	mov    %esi,%eax
  80196f:	e8 70 fb ff ff       	call   8014e4 <printnum>
			break;
  801974:	83 c4 20             	add    $0x20,%esp
  801977:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80197a:	e9 ae fc ff ff       	jmp    80162d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	53                   	push   %ebx
  801983:	51                   	push   %ecx
  801984:	ff d6                	call   *%esi
			break;
  801986:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801989:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80198c:	e9 9c fc ff ff       	jmp    80162d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801991:	83 ec 08             	sub    $0x8,%esp
  801994:	53                   	push   %ebx
  801995:	6a 25                	push   $0x25
  801997:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	eb 03                	jmp    8019a1 <vprintfmt+0x39a>
  80199e:	83 ef 01             	sub    $0x1,%edi
  8019a1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8019a5:	75 f7                	jne    80199e <vprintfmt+0x397>
  8019a7:	e9 81 fc ff ff       	jmp    80162d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8019ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019af:	5b                   	pop    %ebx
  8019b0:	5e                   	pop    %esi
  8019b1:	5f                   	pop    %edi
  8019b2:	5d                   	pop    %ebp
  8019b3:	c3                   	ret    

008019b4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 18             	sub    $0x18,%esp
  8019ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019c3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019c7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	74 26                	je     8019fb <vsnprintf+0x47>
  8019d5:	85 d2                	test   %edx,%edx
  8019d7:	7e 22                	jle    8019fb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019d9:	ff 75 14             	pushl  0x14(%ebp)
  8019dc:	ff 75 10             	pushl  0x10(%ebp)
  8019df:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019e2:	50                   	push   %eax
  8019e3:	68 cd 15 80 00       	push   $0x8015cd
  8019e8:	e8 1a fc ff ff       	call   801607 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019f0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f6:	83 c4 10             	add    $0x10,%esp
  8019f9:	eb 05                	jmp    801a00 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a08:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a0b:	50                   	push   %eax
  801a0c:	ff 75 10             	pushl  0x10(%ebp)
  801a0f:	ff 75 0c             	pushl  0xc(%ebp)
  801a12:	ff 75 08             	pushl  0x8(%ebp)
  801a15:	e8 9a ff ff ff       	call   8019b4 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a22:	b8 00 00 00 00       	mov    $0x0,%eax
  801a27:	eb 03                	jmp    801a2c <strlen+0x10>
		n++;
  801a29:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a2c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a30:	75 f7                	jne    801a29 <strlen+0xd>
		n++;
	return n;
}
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a42:	eb 03                	jmp    801a47 <strnlen+0x13>
		n++;
  801a44:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a47:	39 c2                	cmp    %eax,%edx
  801a49:	74 08                	je     801a53 <strnlen+0x1f>
  801a4b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a4f:	75 f3                	jne    801a44 <strnlen+0x10>
  801a51:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a53:	5d                   	pop    %ebp
  801a54:	c3                   	ret    

00801a55 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	53                   	push   %ebx
  801a59:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a5f:	89 c2                	mov    %eax,%edx
  801a61:	83 c2 01             	add    $0x1,%edx
  801a64:	83 c1 01             	add    $0x1,%ecx
  801a67:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a6b:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a6e:	84 db                	test   %bl,%bl
  801a70:	75 ef                	jne    801a61 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a72:	5b                   	pop    %ebx
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	53                   	push   %ebx
  801a79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a7c:	53                   	push   %ebx
  801a7d:	e8 9a ff ff ff       	call   801a1c <strlen>
  801a82:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a85:	ff 75 0c             	pushl  0xc(%ebp)
  801a88:	01 d8                	add    %ebx,%eax
  801a8a:	50                   	push   %eax
  801a8b:	e8 c5 ff ff ff       	call   801a55 <strcpy>
	return dst;
}
  801a90:	89 d8                	mov    %ebx,%eax
  801a92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a95:	c9                   	leave  
  801a96:	c3                   	ret    

00801a97 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	56                   	push   %esi
  801a9b:	53                   	push   %ebx
  801a9c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa2:	89 f3                	mov    %esi,%ebx
  801aa4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801aa7:	89 f2                	mov    %esi,%edx
  801aa9:	eb 0f                	jmp    801aba <strncpy+0x23>
		*dst++ = *src;
  801aab:	83 c2 01             	add    $0x1,%edx
  801aae:	0f b6 01             	movzbl (%ecx),%eax
  801ab1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ab4:	80 39 01             	cmpb   $0x1,(%ecx)
  801ab7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801aba:	39 da                	cmp    %ebx,%edx
  801abc:	75 ed                	jne    801aab <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801abe:	89 f0                	mov    %esi,%eax
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    

00801ac4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	56                   	push   %esi
  801ac8:	53                   	push   %ebx
  801ac9:	8b 75 08             	mov    0x8(%ebp),%esi
  801acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acf:	8b 55 10             	mov    0x10(%ebp),%edx
  801ad2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ad4:	85 d2                	test   %edx,%edx
  801ad6:	74 21                	je     801af9 <strlcpy+0x35>
  801ad8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801adc:	89 f2                	mov    %esi,%edx
  801ade:	eb 09                	jmp    801ae9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801ae0:	83 c2 01             	add    $0x1,%edx
  801ae3:	83 c1 01             	add    $0x1,%ecx
  801ae6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ae9:	39 c2                	cmp    %eax,%edx
  801aeb:	74 09                	je     801af6 <strlcpy+0x32>
  801aed:	0f b6 19             	movzbl (%ecx),%ebx
  801af0:	84 db                	test   %bl,%bl
  801af2:	75 ec                	jne    801ae0 <strlcpy+0x1c>
  801af4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801af6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801af9:	29 f0                	sub    %esi,%eax
}
  801afb:	5b                   	pop    %ebx
  801afc:	5e                   	pop    %esi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    

00801aff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b05:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801b08:	eb 06                	jmp    801b10 <strcmp+0x11>
		p++, q++;
  801b0a:	83 c1 01             	add    $0x1,%ecx
  801b0d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b10:	0f b6 01             	movzbl (%ecx),%eax
  801b13:	84 c0                	test   %al,%al
  801b15:	74 04                	je     801b1b <strcmp+0x1c>
  801b17:	3a 02                	cmp    (%edx),%al
  801b19:	74 ef                	je     801b0a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b1b:	0f b6 c0             	movzbl %al,%eax
  801b1e:	0f b6 12             	movzbl (%edx),%edx
  801b21:	29 d0                	sub    %edx,%eax
}
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	53                   	push   %ebx
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b2f:	89 c3                	mov    %eax,%ebx
  801b31:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b34:	eb 06                	jmp    801b3c <strncmp+0x17>
		n--, p++, q++;
  801b36:	83 c0 01             	add    $0x1,%eax
  801b39:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b3c:	39 d8                	cmp    %ebx,%eax
  801b3e:	74 15                	je     801b55 <strncmp+0x30>
  801b40:	0f b6 08             	movzbl (%eax),%ecx
  801b43:	84 c9                	test   %cl,%cl
  801b45:	74 04                	je     801b4b <strncmp+0x26>
  801b47:	3a 0a                	cmp    (%edx),%cl
  801b49:	74 eb                	je     801b36 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b4b:	0f b6 00             	movzbl (%eax),%eax
  801b4e:	0f b6 12             	movzbl (%edx),%edx
  801b51:	29 d0                	sub    %edx,%eax
  801b53:	eb 05                	jmp    801b5a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b5a:	5b                   	pop    %ebx
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	8b 45 08             	mov    0x8(%ebp),%eax
  801b63:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b67:	eb 07                	jmp    801b70 <strchr+0x13>
		if (*s == c)
  801b69:	38 ca                	cmp    %cl,%dl
  801b6b:	74 0f                	je     801b7c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b6d:	83 c0 01             	add    $0x1,%eax
  801b70:	0f b6 10             	movzbl (%eax),%edx
  801b73:	84 d2                	test   %dl,%dl
  801b75:	75 f2                	jne    801b69 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	8b 45 08             	mov    0x8(%ebp),%eax
  801b84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b88:	eb 03                	jmp    801b8d <strfind+0xf>
  801b8a:	83 c0 01             	add    $0x1,%eax
  801b8d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b90:	38 ca                	cmp    %cl,%dl
  801b92:	74 04                	je     801b98 <strfind+0x1a>
  801b94:	84 d2                	test   %dl,%dl
  801b96:	75 f2                	jne    801b8a <strfind+0xc>
			break;
	return (char *) s;
}
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	57                   	push   %edi
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ba3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ba6:	85 c9                	test   %ecx,%ecx
  801ba8:	74 36                	je     801be0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801baa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801bb0:	75 28                	jne    801bda <memset+0x40>
  801bb2:	f6 c1 03             	test   $0x3,%cl
  801bb5:	75 23                	jne    801bda <memset+0x40>
		c &= 0xFF;
  801bb7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801bbb:	89 d3                	mov    %edx,%ebx
  801bbd:	c1 e3 08             	shl    $0x8,%ebx
  801bc0:	89 d6                	mov    %edx,%esi
  801bc2:	c1 e6 18             	shl    $0x18,%esi
  801bc5:	89 d0                	mov    %edx,%eax
  801bc7:	c1 e0 10             	shl    $0x10,%eax
  801bca:	09 f0                	or     %esi,%eax
  801bcc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801bce:	89 d8                	mov    %ebx,%eax
  801bd0:	09 d0                	or     %edx,%eax
  801bd2:	c1 e9 02             	shr    $0x2,%ecx
  801bd5:	fc                   	cld    
  801bd6:	f3 ab                	rep stos %eax,%es:(%edi)
  801bd8:	eb 06                	jmp    801be0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bdd:	fc                   	cld    
  801bde:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801be0:	89 f8                	mov    %edi,%eax
  801be2:	5b                   	pop    %ebx
  801be3:	5e                   	pop    %esi
  801be4:	5f                   	pop    %edi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	57                   	push   %edi
  801beb:	56                   	push   %esi
  801bec:	8b 45 08             	mov    0x8(%ebp),%eax
  801bef:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bf2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801bf5:	39 c6                	cmp    %eax,%esi
  801bf7:	73 35                	jae    801c2e <memmove+0x47>
  801bf9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bfc:	39 d0                	cmp    %edx,%eax
  801bfe:	73 2e                	jae    801c2e <memmove+0x47>
		s += n;
		d += n;
  801c00:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c03:	89 d6                	mov    %edx,%esi
  801c05:	09 fe                	or     %edi,%esi
  801c07:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c0d:	75 13                	jne    801c22 <memmove+0x3b>
  801c0f:	f6 c1 03             	test   $0x3,%cl
  801c12:	75 0e                	jne    801c22 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801c14:	83 ef 04             	sub    $0x4,%edi
  801c17:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c1a:	c1 e9 02             	shr    $0x2,%ecx
  801c1d:	fd                   	std    
  801c1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c20:	eb 09                	jmp    801c2b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c22:	83 ef 01             	sub    $0x1,%edi
  801c25:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c28:	fd                   	std    
  801c29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c2b:	fc                   	cld    
  801c2c:	eb 1d                	jmp    801c4b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c2e:	89 f2                	mov    %esi,%edx
  801c30:	09 c2                	or     %eax,%edx
  801c32:	f6 c2 03             	test   $0x3,%dl
  801c35:	75 0f                	jne    801c46 <memmove+0x5f>
  801c37:	f6 c1 03             	test   $0x3,%cl
  801c3a:	75 0a                	jne    801c46 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c3c:	c1 e9 02             	shr    $0x2,%ecx
  801c3f:	89 c7                	mov    %eax,%edi
  801c41:	fc                   	cld    
  801c42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c44:	eb 05                	jmp    801c4b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c46:	89 c7                	mov    %eax,%edi
  801c48:	fc                   	cld    
  801c49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c4b:	5e                   	pop    %esi
  801c4c:	5f                   	pop    %edi
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c52:	ff 75 10             	pushl  0x10(%ebp)
  801c55:	ff 75 0c             	pushl  0xc(%ebp)
  801c58:	ff 75 08             	pushl  0x8(%ebp)
  801c5b:	e8 87 ff ff ff       	call   801be7 <memmove>
}
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	56                   	push   %esi
  801c66:	53                   	push   %ebx
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6d:	89 c6                	mov    %eax,%esi
  801c6f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c72:	eb 1a                	jmp    801c8e <memcmp+0x2c>
		if (*s1 != *s2)
  801c74:	0f b6 08             	movzbl (%eax),%ecx
  801c77:	0f b6 1a             	movzbl (%edx),%ebx
  801c7a:	38 d9                	cmp    %bl,%cl
  801c7c:	74 0a                	je     801c88 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c7e:	0f b6 c1             	movzbl %cl,%eax
  801c81:	0f b6 db             	movzbl %bl,%ebx
  801c84:	29 d8                	sub    %ebx,%eax
  801c86:	eb 0f                	jmp    801c97 <memcmp+0x35>
		s1++, s2++;
  801c88:	83 c0 01             	add    $0x1,%eax
  801c8b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c8e:	39 f0                	cmp    %esi,%eax
  801c90:	75 e2                	jne    801c74 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c97:	5b                   	pop    %ebx
  801c98:	5e                   	pop    %esi
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	53                   	push   %ebx
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801ca2:	89 c1                	mov    %eax,%ecx
  801ca4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801ca7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801cab:	eb 0a                	jmp    801cb7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801cad:	0f b6 10             	movzbl (%eax),%edx
  801cb0:	39 da                	cmp    %ebx,%edx
  801cb2:	74 07                	je     801cbb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801cb4:	83 c0 01             	add    $0x1,%eax
  801cb7:	39 c8                	cmp    %ecx,%eax
  801cb9:	72 f2                	jb     801cad <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801cbb:	5b                   	pop    %ebx
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    

00801cbe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cca:	eb 03                	jmp    801ccf <strtol+0x11>
		s++;
  801ccc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ccf:	0f b6 01             	movzbl (%ecx),%eax
  801cd2:	3c 20                	cmp    $0x20,%al
  801cd4:	74 f6                	je     801ccc <strtol+0xe>
  801cd6:	3c 09                	cmp    $0x9,%al
  801cd8:	74 f2                	je     801ccc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801cda:	3c 2b                	cmp    $0x2b,%al
  801cdc:	75 0a                	jne    801ce8 <strtol+0x2a>
		s++;
  801cde:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ce1:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce6:	eb 11                	jmp    801cf9 <strtol+0x3b>
  801ce8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ced:	3c 2d                	cmp    $0x2d,%al
  801cef:	75 08                	jne    801cf9 <strtol+0x3b>
		s++, neg = 1;
  801cf1:	83 c1 01             	add    $0x1,%ecx
  801cf4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cf9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cff:	75 15                	jne    801d16 <strtol+0x58>
  801d01:	80 39 30             	cmpb   $0x30,(%ecx)
  801d04:	75 10                	jne    801d16 <strtol+0x58>
  801d06:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801d0a:	75 7c                	jne    801d88 <strtol+0xca>
		s += 2, base = 16;
  801d0c:	83 c1 02             	add    $0x2,%ecx
  801d0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801d14:	eb 16                	jmp    801d2c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801d16:	85 db                	test   %ebx,%ebx
  801d18:	75 12                	jne    801d2c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d1a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d1f:	80 39 30             	cmpb   $0x30,(%ecx)
  801d22:	75 08                	jne    801d2c <strtol+0x6e>
		s++, base = 8;
  801d24:	83 c1 01             	add    $0x1,%ecx
  801d27:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d31:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d34:	0f b6 11             	movzbl (%ecx),%edx
  801d37:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d3a:	89 f3                	mov    %esi,%ebx
  801d3c:	80 fb 09             	cmp    $0x9,%bl
  801d3f:	77 08                	ja     801d49 <strtol+0x8b>
			dig = *s - '0';
  801d41:	0f be d2             	movsbl %dl,%edx
  801d44:	83 ea 30             	sub    $0x30,%edx
  801d47:	eb 22                	jmp    801d6b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d49:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d4c:	89 f3                	mov    %esi,%ebx
  801d4e:	80 fb 19             	cmp    $0x19,%bl
  801d51:	77 08                	ja     801d5b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d53:	0f be d2             	movsbl %dl,%edx
  801d56:	83 ea 57             	sub    $0x57,%edx
  801d59:	eb 10                	jmp    801d6b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d5b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d5e:	89 f3                	mov    %esi,%ebx
  801d60:	80 fb 19             	cmp    $0x19,%bl
  801d63:	77 16                	ja     801d7b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d65:	0f be d2             	movsbl %dl,%edx
  801d68:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d6b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d6e:	7d 0b                	jge    801d7b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d70:	83 c1 01             	add    $0x1,%ecx
  801d73:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d77:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d79:	eb b9                	jmp    801d34 <strtol+0x76>

	if (endptr)
  801d7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d7f:	74 0d                	je     801d8e <strtol+0xd0>
		*endptr = (char *) s;
  801d81:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d84:	89 0e                	mov    %ecx,(%esi)
  801d86:	eb 06                	jmp    801d8e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d88:	85 db                	test   %ebx,%ebx
  801d8a:	74 98                	je     801d24 <strtol+0x66>
  801d8c:	eb 9e                	jmp    801d2c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d8e:	89 c2                	mov    %eax,%edx
  801d90:	f7 da                	neg    %edx
  801d92:	85 ff                	test   %edi,%edi
  801d94:	0f 45 c2             	cmovne %edx,%eax
}
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    

00801d9c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801da2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801da9:	75 2a                	jne    801dd5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801dab:	83 ec 04             	sub    $0x4,%esp
  801dae:	6a 07                	push   $0x7
  801db0:	68 00 f0 bf ee       	push   $0xeebff000
  801db5:	6a 00                	push   $0x0
  801db7:	e8 d1 e3 ff ff       	call   80018d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dbc:	83 c4 10             	add    $0x10,%esp
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	79 12                	jns    801dd5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801dc3:	50                   	push   %eax
  801dc4:	68 00 27 80 00       	push   $0x802700
  801dc9:	6a 23                	push   $0x23
  801dcb:	68 04 27 80 00       	push   $0x802704
  801dd0:	e8 22 f6 ff ff       	call   8013f7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd8:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801ddd:	83 ec 08             	sub    $0x8,%esp
  801de0:	68 07 1e 80 00       	push   $0x801e07
  801de5:	6a 00                	push   $0x0
  801de7:	e8 ec e4 ff ff       	call   8002d8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	85 c0                	test   %eax,%eax
  801df1:	79 12                	jns    801e05 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801df3:	50                   	push   %eax
  801df4:	68 00 27 80 00       	push   $0x802700
  801df9:	6a 2c                	push   $0x2c
  801dfb:	68 04 27 80 00       	push   $0x802704
  801e00:	e8 f2 f5 ff ff       	call   8013f7 <_panic>
	}
}
  801e05:	c9                   	leave  
  801e06:	c3                   	ret    

00801e07 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e07:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e08:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e0d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e0f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e12:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e16:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e1b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e1f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e21:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e24:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e25:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e28:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e29:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e2a:	c3                   	ret    

00801e2b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	56                   	push   %esi
  801e2f:	53                   	push   %ebx
  801e30:	8b 75 08             	mov    0x8(%ebp),%esi
  801e33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e39:	85 c0                	test   %eax,%eax
  801e3b:	75 12                	jne    801e4f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e3d:	83 ec 0c             	sub    $0xc,%esp
  801e40:	68 00 00 c0 ee       	push   $0xeec00000
  801e45:	e8 f3 e4 ff ff       	call   80033d <sys_ipc_recv>
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	eb 0c                	jmp    801e5b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e4f:	83 ec 0c             	sub    $0xc,%esp
  801e52:	50                   	push   %eax
  801e53:	e8 e5 e4 ff ff       	call   80033d <sys_ipc_recv>
  801e58:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e5b:	85 f6                	test   %esi,%esi
  801e5d:	0f 95 c1             	setne  %cl
  801e60:	85 db                	test   %ebx,%ebx
  801e62:	0f 95 c2             	setne  %dl
  801e65:	84 d1                	test   %dl,%cl
  801e67:	74 09                	je     801e72 <ipc_recv+0x47>
  801e69:	89 c2                	mov    %eax,%edx
  801e6b:	c1 ea 1f             	shr    $0x1f,%edx
  801e6e:	84 d2                	test   %dl,%dl
  801e70:	75 2d                	jne    801e9f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e72:	85 f6                	test   %esi,%esi
  801e74:	74 0d                	je     801e83 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e76:	a1 04 40 80 00       	mov    0x804004,%eax
  801e7b:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801e81:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e83:	85 db                	test   %ebx,%ebx
  801e85:	74 0d                	je     801e94 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e87:	a1 04 40 80 00       	mov    0x804004,%eax
  801e8c:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801e92:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e94:	a1 04 40 80 00       	mov    0x804004,%eax
  801e99:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801e9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea2:	5b                   	pop    %ebx
  801ea3:	5e                   	pop    %esi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    

00801ea6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	57                   	push   %edi
  801eaa:	56                   	push   %esi
  801eab:	53                   	push   %ebx
  801eac:	83 ec 0c             	sub    $0xc,%esp
  801eaf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eb2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801eb8:	85 db                	test   %ebx,%ebx
  801eba:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ebf:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ec2:	ff 75 14             	pushl  0x14(%ebp)
  801ec5:	53                   	push   %ebx
  801ec6:	56                   	push   %esi
  801ec7:	57                   	push   %edi
  801ec8:	e8 4d e4 ff ff       	call   80031a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ecd:	89 c2                	mov    %eax,%edx
  801ecf:	c1 ea 1f             	shr    $0x1f,%edx
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	84 d2                	test   %dl,%dl
  801ed7:	74 17                	je     801ef0 <ipc_send+0x4a>
  801ed9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801edc:	74 12                	je     801ef0 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ede:	50                   	push   %eax
  801edf:	68 12 27 80 00       	push   $0x802712
  801ee4:	6a 47                	push   $0x47
  801ee6:	68 20 27 80 00       	push   $0x802720
  801eeb:	e8 07 f5 ff ff       	call   8013f7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ef0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef3:	75 07                	jne    801efc <ipc_send+0x56>
			sys_yield();
  801ef5:	e8 74 e2 ff ff       	call   80016e <sys_yield>
  801efa:	eb c6                	jmp    801ec2 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801efc:	85 c0                	test   %eax,%eax
  801efe:	75 c2                	jne    801ec2 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f0e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f13:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f19:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f1f:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f25:	39 ca                	cmp    %ecx,%edx
  801f27:	75 13                	jne    801f3c <ipc_find_env+0x34>
			return envs[i].env_id;
  801f29:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f2f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f34:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f3a:	eb 0f                	jmp    801f4b <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f3c:	83 c0 01             	add    $0x1,%eax
  801f3f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f44:	75 cd                	jne    801f13 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f4b:	5d                   	pop    %ebp
  801f4c:	c3                   	ret    

00801f4d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f53:	89 d0                	mov    %edx,%eax
  801f55:	c1 e8 16             	shr    $0x16,%eax
  801f58:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f5f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f64:	f6 c1 01             	test   $0x1,%cl
  801f67:	74 1d                	je     801f86 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f69:	c1 ea 0c             	shr    $0xc,%edx
  801f6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f73:	f6 c2 01             	test   $0x1,%dl
  801f76:	74 0e                	je     801f86 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f78:	c1 ea 0c             	shr    $0xc,%edx
  801f7b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f82:	ef 
  801f83:	0f b7 c0             	movzwl %ax,%eax
}
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	66 90                	xchg   %ax,%ax
  801f8a:	66 90                	xchg   %ax,%ax
  801f8c:	66 90                	xchg   %ax,%ax
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 ca                	mov    %ecx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	75 3d                	jne    801ff0 <__udivdi3+0x60>
  801fb3:	39 cf                	cmp    %ecx,%edi
  801fb5:	0f 87 c5 00 00 00    	ja     802080 <__udivdi3+0xf0>
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	89 fd                	mov    %edi,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f7                	div    %edi
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 c8                	mov    %ecx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	89 cf                	mov    %ecx,%edi
  801fd8:	f7 f5                	div    %ebp
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 ce                	cmp    %ecx,%esi
  801ff2:	77 74                	ja     802068 <__udivdi3+0xd8>
  801ff4:	0f bd fe             	bsr    %esi,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0x108>
  802000:	bb 20 00 00 00       	mov    $0x20,%ebx
  802005:	89 f9                	mov    %edi,%ecx
  802007:	89 c5                	mov    %eax,%ebp
  802009:	29 fb                	sub    %edi,%ebx
  80200b:	d3 e6                	shl    %cl,%esi
  80200d:	89 d9                	mov    %ebx,%ecx
  80200f:	d3 ed                	shr    %cl,%ebp
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e0                	shl    %cl,%eax
  802015:	09 ee                	or     %ebp,%esi
  802017:	89 d9                	mov    %ebx,%ecx
  802019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201d:	89 d5                	mov    %edx,%ebp
  80201f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802023:	d3 ed                	shr    %cl,%ebp
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 d9                	mov    %ebx,%ecx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	09 c2                	or     %eax,%edx
  80202f:	89 d0                	mov    %edx,%eax
  802031:	89 ea                	mov    %ebp,%edx
  802033:	f7 f6                	div    %esi
  802035:	89 d5                	mov    %edx,%ebp
  802037:	89 c3                	mov    %eax,%ebx
  802039:	f7 64 24 0c          	mull   0xc(%esp)
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	72 10                	jb     802051 <__udivdi3+0xc1>
  802041:	8b 74 24 08          	mov    0x8(%esp),%esi
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e6                	shl    %cl,%esi
  802049:	39 c6                	cmp    %eax,%esi
  80204b:	73 07                	jae    802054 <__udivdi3+0xc4>
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	75 03                	jne    802054 <__udivdi3+0xc4>
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 d8                	mov    %ebx,%eax
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 db                	xor    %ebx,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d8                	mov    %ebx,%eax
  802082:	f7 f7                	div    %edi
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 c3                	mov    %eax,%ebx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	39 ce                	cmp    %ecx,%esi
  80209a:	72 0c                	jb     8020a8 <__udivdi3+0x118>
  80209c:	31 db                	xor    %ebx,%ebx
  80209e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020a2:	0f 87 34 ff ff ff    	ja     801fdc <__udivdi3+0x4c>
  8020a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ad:	e9 2a ff ff ff       	jmp    801fdc <__udivdi3+0x4c>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f3                	mov    %esi,%ebx
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	75 1c                	jne    802108 <__umoddi3+0x48>
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	76 50                	jbe    802140 <__umoddi3+0x80>
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	f7 f7                	div    %edi
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	31 d2                	xor    %edx,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	77 52                	ja     802160 <__umoddi3+0xa0>
  80210e:	0f bd ea             	bsr    %edx,%ebp
  802111:	83 f5 1f             	xor    $0x1f,%ebp
  802114:	75 5a                	jne    802170 <__umoddi3+0xb0>
  802116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	39 0c 24             	cmp    %ecx,(%esp)
  802123:	0f 86 d7 00 00 00    	jbe    802200 <__umoddi3+0x140>
  802129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80212d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	85 ff                	test   %edi,%edi
  802142:	89 fd                	mov    %edi,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 c8                	mov    %ecx,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	eb 99                	jmp    8020f8 <__umoddi3+0x38>
  80215f:	90                   	nop
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	8b 34 24             	mov    (%esp),%esi
  802173:	bf 20 00 00 00       	mov    $0x20,%edi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	29 ef                	sub    %ebp,%edi
  80217c:	d3 e0                	shl    %cl,%eax
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	89 f2                	mov    %esi,%edx
  802182:	d3 ea                	shr    %cl,%edx
  802184:	89 e9                	mov    %ebp,%ecx
  802186:	09 c2                	or     %eax,%edx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 14 24             	mov    %edx,(%esp)
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 f9                	mov    %edi,%ecx
  802193:	89 54 24 04          	mov    %edx,0x4(%esp)
  802197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	d3 e3                	shl    %cl,%ebx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	09 d8                	or     %ebx,%eax
  8021ad:	89 d3                	mov    %edx,%ebx
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	f7 34 24             	divl   (%esp)
  8021b4:	89 d6                	mov    %edx,%esi
  8021b6:	d3 e3                	shl    %cl,%ebx
  8021b8:	f7 64 24 04          	mull   0x4(%esp)
  8021bc:	39 d6                	cmp    %edx,%esi
  8021be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c2:	89 d1                	mov    %edx,%ecx
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	72 08                	jb     8021d0 <__umoddi3+0x110>
  8021c8:	75 11                	jne    8021db <__umoddi3+0x11b>
  8021ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ce:	73 0b                	jae    8021db <__umoddi3+0x11b>
  8021d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021d4:	1b 14 24             	sbb    (%esp),%edx
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021df:	29 da                	sub    %ebx,%edx
  8021e1:	19 ce                	sbb    %ecx,%esi
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e0                	shl    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d0                	or     %edx,%eax
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 f9                	sub    %edi,%ecx
  802202:	19 d6                	sbb    %edx,%esi
  802204:	89 74 24 04          	mov    %esi,0x4(%esp)
  802208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220c:	e9 18 ff ff ff       	jmp    802129 <__umoddi3+0x69>
