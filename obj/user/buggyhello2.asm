
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
  800063:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8000bd:	e8 bb 07 00 00       	call   80087d <close_all>
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
  800136:	68 f8 21 80 00       	push   $0x8021f8
  80013b:	6a 23                	push   $0x23
  80013d:	68 15 22 80 00       	push   $0x802215
  800142:	e8 5e 12 00 00       	call   8013a5 <_panic>

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
  8001b7:	68 f8 21 80 00       	push   $0x8021f8
  8001bc:	6a 23                	push   $0x23
  8001be:	68 15 22 80 00       	push   $0x802215
  8001c3:	e8 dd 11 00 00       	call   8013a5 <_panic>

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
  8001f9:	68 f8 21 80 00       	push   $0x8021f8
  8001fe:	6a 23                	push   $0x23
  800200:	68 15 22 80 00       	push   $0x802215
  800205:	e8 9b 11 00 00       	call   8013a5 <_panic>

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
  80023b:	68 f8 21 80 00       	push   $0x8021f8
  800240:	6a 23                	push   $0x23
  800242:	68 15 22 80 00       	push   $0x802215
  800247:	e8 59 11 00 00       	call   8013a5 <_panic>

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
  80027d:	68 f8 21 80 00       	push   $0x8021f8
  800282:	6a 23                	push   $0x23
  800284:	68 15 22 80 00       	push   $0x802215
  800289:	e8 17 11 00 00       	call   8013a5 <_panic>

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
  8002bf:	68 f8 21 80 00       	push   $0x8021f8
  8002c4:	6a 23                	push   $0x23
  8002c6:	68 15 22 80 00       	push   $0x802215
  8002cb:	e8 d5 10 00 00       	call   8013a5 <_panic>
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
  800301:	68 f8 21 80 00       	push   $0x8021f8
  800306:	6a 23                	push   $0x23
  800308:	68 15 22 80 00       	push   $0x802215
  80030d:	e8 93 10 00 00       	call   8013a5 <_panic>

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
  800365:	68 f8 21 80 00       	push   $0x8021f8
  80036a:	6a 23                	push   $0x23
  80036c:	68 15 22 80 00       	push   $0x802215
  800371:	e8 2f 10 00 00       	call   8013a5 <_panic>

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

008003be <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	53                   	push   %ebx
  8003c2:	83 ec 04             	sub    $0x4,%esp
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003c8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003ca:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003ce:	74 11                	je     8003e1 <pgfault+0x23>
  8003d0:	89 d8                	mov    %ebx,%eax
  8003d2:	c1 e8 0c             	shr    $0xc,%eax
  8003d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003dc:	f6 c4 08             	test   $0x8,%ah
  8003df:	75 14                	jne    8003f5 <pgfault+0x37>
		panic("faulting access");
  8003e1:	83 ec 04             	sub    $0x4,%esp
  8003e4:	68 23 22 80 00       	push   $0x802223
  8003e9:	6a 1e                	push   $0x1e
  8003eb:	68 33 22 80 00       	push   $0x802233
  8003f0:	e8 b0 0f 00 00       	call   8013a5 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	6a 07                	push   $0x7
  8003fa:	68 00 f0 7f 00       	push   $0x7ff000
  8003ff:	6a 00                	push   $0x0
  800401:	e8 87 fd ff ff       	call   80018d <sys_page_alloc>
	if (r < 0) {
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	85 c0                	test   %eax,%eax
  80040b:	79 12                	jns    80041f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80040d:	50                   	push   %eax
  80040e:	68 3e 22 80 00       	push   $0x80223e
  800413:	6a 2c                	push   $0x2c
  800415:	68 33 22 80 00       	push   $0x802233
  80041a:	e8 86 0f 00 00       	call   8013a5 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80041f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800425:	83 ec 04             	sub    $0x4,%esp
  800428:	68 00 10 00 00       	push   $0x1000
  80042d:	53                   	push   %ebx
  80042e:	68 00 f0 7f 00       	push   $0x7ff000
  800433:	e8 c5 17 00 00       	call   801bfd <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800438:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80043f:	53                   	push   %ebx
  800440:	6a 00                	push   $0x0
  800442:	68 00 f0 7f 00       	push   $0x7ff000
  800447:	6a 00                	push   $0x0
  800449:	e8 82 fd ff ff       	call   8001d0 <sys_page_map>
	if (r < 0) {
  80044e:	83 c4 20             	add    $0x20,%esp
  800451:	85 c0                	test   %eax,%eax
  800453:	79 12                	jns    800467 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800455:	50                   	push   %eax
  800456:	68 3e 22 80 00       	push   $0x80223e
  80045b:	6a 33                	push   $0x33
  80045d:	68 33 22 80 00       	push   $0x802233
  800462:	e8 3e 0f 00 00       	call   8013a5 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	68 00 f0 7f 00       	push   $0x7ff000
  80046f:	6a 00                	push   $0x0
  800471:	e8 9c fd ff ff       	call   800212 <sys_page_unmap>
	if (r < 0) {
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	85 c0                	test   %eax,%eax
  80047b:	79 12                	jns    80048f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80047d:	50                   	push   %eax
  80047e:	68 3e 22 80 00       	push   $0x80223e
  800483:	6a 37                	push   $0x37
  800485:	68 33 22 80 00       	push   $0x802233
  80048a:	e8 16 0f 00 00       	call   8013a5 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80048f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800492:	c9                   	leave  
  800493:	c3                   	ret    

00800494 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	57                   	push   %edi
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80049d:	68 be 03 80 00       	push   $0x8003be
  8004a2:	e8 a3 18 00 00       	call   801d4a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004a7:	b8 07 00 00 00       	mov    $0x7,%eax
  8004ac:	cd 30                	int    $0x30
  8004ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	85 c0                	test   %eax,%eax
  8004b6:	79 17                	jns    8004cf <fork+0x3b>
		panic("fork fault %e");
  8004b8:	83 ec 04             	sub    $0x4,%esp
  8004bb:	68 57 22 80 00       	push   $0x802257
  8004c0:	68 84 00 00 00       	push   $0x84
  8004c5:	68 33 22 80 00       	push   $0x802233
  8004ca:	e8 d6 0e 00 00       	call   8013a5 <_panic>
  8004cf:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004d1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d5:	75 24                	jne    8004fb <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004d7:	e8 73 fc ff ff       	call   80014f <sys_getenvid>
  8004dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004e1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8004e7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004ec:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f6:	e9 64 01 00 00       	jmp    80065f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004fb:	83 ec 04             	sub    $0x4,%esp
  8004fe:	6a 07                	push   $0x7
  800500:	68 00 f0 bf ee       	push   $0xeebff000
  800505:	ff 75 e4             	pushl  -0x1c(%ebp)
  800508:	e8 80 fc ff ff       	call   80018d <sys_page_alloc>
  80050d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800510:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800515:	89 d8                	mov    %ebx,%eax
  800517:	c1 e8 16             	shr    $0x16,%eax
  80051a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800521:	a8 01                	test   $0x1,%al
  800523:	0f 84 fc 00 00 00    	je     800625 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800529:	89 d8                	mov    %ebx,%eax
  80052b:	c1 e8 0c             	shr    $0xc,%eax
  80052e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800535:	f6 c2 01             	test   $0x1,%dl
  800538:	0f 84 e7 00 00 00    	je     800625 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80053e:	89 c6                	mov    %eax,%esi
  800540:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800543:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80054a:	f6 c6 04             	test   $0x4,%dh
  80054d:	74 39                	je     800588 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80054f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800556:	83 ec 0c             	sub    $0xc,%esp
  800559:	25 07 0e 00 00       	and    $0xe07,%eax
  80055e:	50                   	push   %eax
  80055f:	56                   	push   %esi
  800560:	57                   	push   %edi
  800561:	56                   	push   %esi
  800562:	6a 00                	push   $0x0
  800564:	e8 67 fc ff ff       	call   8001d0 <sys_page_map>
		if (r < 0) {
  800569:	83 c4 20             	add    $0x20,%esp
  80056c:	85 c0                	test   %eax,%eax
  80056e:	0f 89 b1 00 00 00    	jns    800625 <fork+0x191>
		    	panic("sys page map fault %e");
  800574:	83 ec 04             	sub    $0x4,%esp
  800577:	68 65 22 80 00       	push   $0x802265
  80057c:	6a 54                	push   $0x54
  80057e:	68 33 22 80 00       	push   $0x802233
  800583:	e8 1d 0e 00 00       	call   8013a5 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800588:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058f:	f6 c2 02             	test   $0x2,%dl
  800592:	75 0c                	jne    8005a0 <fork+0x10c>
  800594:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80059b:	f6 c4 08             	test   $0x8,%ah
  80059e:	74 5b                	je     8005fb <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005a0:	83 ec 0c             	sub    $0xc,%esp
  8005a3:	68 05 08 00 00       	push   $0x805
  8005a8:	56                   	push   %esi
  8005a9:	57                   	push   %edi
  8005aa:	56                   	push   %esi
  8005ab:	6a 00                	push   $0x0
  8005ad:	e8 1e fc ff ff       	call   8001d0 <sys_page_map>
		if (r < 0) {
  8005b2:	83 c4 20             	add    $0x20,%esp
  8005b5:	85 c0                	test   %eax,%eax
  8005b7:	79 14                	jns    8005cd <fork+0x139>
		    	panic("sys page map fault %e");
  8005b9:	83 ec 04             	sub    $0x4,%esp
  8005bc:	68 65 22 80 00       	push   $0x802265
  8005c1:	6a 5b                	push   $0x5b
  8005c3:	68 33 22 80 00       	push   $0x802233
  8005c8:	e8 d8 0d 00 00       	call   8013a5 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005cd:	83 ec 0c             	sub    $0xc,%esp
  8005d0:	68 05 08 00 00       	push   $0x805
  8005d5:	56                   	push   %esi
  8005d6:	6a 00                	push   $0x0
  8005d8:	56                   	push   %esi
  8005d9:	6a 00                	push   $0x0
  8005db:	e8 f0 fb ff ff       	call   8001d0 <sys_page_map>
		if (r < 0) {
  8005e0:	83 c4 20             	add    $0x20,%esp
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	79 3e                	jns    800625 <fork+0x191>
		    	panic("sys page map fault %e");
  8005e7:	83 ec 04             	sub    $0x4,%esp
  8005ea:	68 65 22 80 00       	push   $0x802265
  8005ef:	6a 5f                	push   $0x5f
  8005f1:	68 33 22 80 00       	push   $0x802233
  8005f6:	e8 aa 0d 00 00       	call   8013a5 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005fb:	83 ec 0c             	sub    $0xc,%esp
  8005fe:	6a 05                	push   $0x5
  800600:	56                   	push   %esi
  800601:	57                   	push   %edi
  800602:	56                   	push   %esi
  800603:	6a 00                	push   $0x0
  800605:	e8 c6 fb ff ff       	call   8001d0 <sys_page_map>
		if (r < 0) {
  80060a:	83 c4 20             	add    $0x20,%esp
  80060d:	85 c0                	test   %eax,%eax
  80060f:	79 14                	jns    800625 <fork+0x191>
		    	panic("sys page map fault %e");
  800611:	83 ec 04             	sub    $0x4,%esp
  800614:	68 65 22 80 00       	push   $0x802265
  800619:	6a 64                	push   $0x64
  80061b:	68 33 22 80 00       	push   $0x802233
  800620:	e8 80 0d 00 00       	call   8013a5 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800625:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80062b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800631:	0f 85 de fe ff ff    	jne    800515 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800637:	a1 04 40 80 00       	mov    0x804004,%eax
  80063c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	50                   	push   %eax
  800646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800649:	57                   	push   %edi
  80064a:	e8 89 fc ff ff       	call   8002d8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	6a 02                	push   $0x2
  800654:	57                   	push   %edi
  800655:	e8 fa fb ff ff       	call   800254 <sys_env_set_status>
	
	return envid;
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80065f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800662:	5b                   	pop    %ebx
  800663:	5e                   	pop    %esi
  800664:	5f                   	pop    %edi
  800665:	5d                   	pop    %ebp
  800666:	c3                   	ret    

00800667 <sfork>:

envid_t
sfork(void)
{
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80066a:	b8 00 00 00 00       	mov    $0x0,%eax
  80066f:	5d                   	pop    %ebp
  800670:	c3                   	ret    

00800671 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800671:	55                   	push   %ebp
  800672:	89 e5                	mov    %esp,%ebp
  800674:	56                   	push   %esi
  800675:	53                   	push   %ebx
  800676:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800679:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	68 7c 22 80 00       	push   $0x80227c
  800688:	e8 f1 0d 00 00       	call   80147e <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80068d:	c7 04 24 97 00 80 00 	movl   $0x800097,(%esp)
  800694:	e8 e5 fc ff ff       	call   80037e <sys_thread_create>
  800699:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80069b:	83 c4 08             	add    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	68 7c 22 80 00       	push   $0x80227c
  8006a4:	e8 d5 0d 00 00       	call   80147e <cprintf>
	return id;
}
  8006a9:	89 f0                	mov    %esi,%eax
  8006ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006ae:	5b                   	pop    %ebx
  8006af:	5e                   	pop    %esi
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	05 00 00 00 30       	add    $0x30000000,%eax
  8006bd:	c1 e8 0c             	shr    $0xc,%eax
}
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	05 00 00 00 30       	add    $0x30000000,%eax
  8006cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006d2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006df:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	c1 ea 16             	shr    $0x16,%edx
  8006e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006f0:	f6 c2 01             	test   $0x1,%dl
  8006f3:	74 11                	je     800706 <fd_alloc+0x2d>
  8006f5:	89 c2                	mov    %eax,%edx
  8006f7:	c1 ea 0c             	shr    $0xc,%edx
  8006fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800701:	f6 c2 01             	test   $0x1,%dl
  800704:	75 09                	jne    80070f <fd_alloc+0x36>
			*fd_store = fd;
  800706:	89 01                	mov    %eax,(%ecx)
			return 0;
  800708:	b8 00 00 00 00       	mov    $0x0,%eax
  80070d:	eb 17                	jmp    800726 <fd_alloc+0x4d>
  80070f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800714:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800719:	75 c9                	jne    8006e4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80071b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800721:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80072e:	83 f8 1f             	cmp    $0x1f,%eax
  800731:	77 36                	ja     800769 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800733:	c1 e0 0c             	shl    $0xc,%eax
  800736:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80073b:	89 c2                	mov    %eax,%edx
  80073d:	c1 ea 16             	shr    $0x16,%edx
  800740:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800747:	f6 c2 01             	test   $0x1,%dl
  80074a:	74 24                	je     800770 <fd_lookup+0x48>
  80074c:	89 c2                	mov    %eax,%edx
  80074e:	c1 ea 0c             	shr    $0xc,%edx
  800751:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800758:	f6 c2 01             	test   $0x1,%dl
  80075b:	74 1a                	je     800777 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80075d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800760:	89 02                	mov    %eax,(%edx)
	return 0;
  800762:	b8 00 00 00 00       	mov    $0x0,%eax
  800767:	eb 13                	jmp    80077c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076e:	eb 0c                	jmp    80077c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800770:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800775:	eb 05                	jmp    80077c <fd_lookup+0x54>
  800777:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800787:	ba 1c 23 80 00       	mov    $0x80231c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80078c:	eb 13                	jmp    8007a1 <dev_lookup+0x23>
  80078e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800791:	39 08                	cmp    %ecx,(%eax)
  800793:	75 0c                	jne    8007a1 <dev_lookup+0x23>
			*dev = devtab[i];
  800795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800798:	89 01                	mov    %eax,(%ecx)
			return 0;
  80079a:	b8 00 00 00 00       	mov    $0x0,%eax
  80079f:	eb 2e                	jmp    8007cf <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007a1:	8b 02                	mov    (%edx),%eax
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	75 e7                	jne    80078e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007a7:	a1 04 40 80 00       	mov    0x804004,%eax
  8007ac:	8b 40 7c             	mov    0x7c(%eax),%eax
  8007af:	83 ec 04             	sub    $0x4,%esp
  8007b2:	51                   	push   %ecx
  8007b3:	50                   	push   %eax
  8007b4:	68 a0 22 80 00       	push   $0x8022a0
  8007b9:	e8 c0 0c 00 00       	call   80147e <cprintf>
	*dev = 0;
  8007be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	56                   	push   %esi
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 10             	sub    $0x10,%esp
  8007d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007e9:	c1 e8 0c             	shr    $0xc,%eax
  8007ec:	50                   	push   %eax
  8007ed:	e8 36 ff ff ff       	call   800728 <fd_lookup>
  8007f2:	83 c4 08             	add    $0x8,%esp
  8007f5:	85 c0                	test   %eax,%eax
  8007f7:	78 05                	js     8007fe <fd_close+0x2d>
	    || fd != fd2)
  8007f9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007fc:	74 0c                	je     80080a <fd_close+0x39>
		return (must_exist ? r : 0);
  8007fe:	84 db                	test   %bl,%bl
  800800:	ba 00 00 00 00       	mov    $0x0,%edx
  800805:	0f 44 c2             	cmove  %edx,%eax
  800808:	eb 41                	jmp    80084b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800810:	50                   	push   %eax
  800811:	ff 36                	pushl  (%esi)
  800813:	e8 66 ff ff ff       	call   80077e <dev_lookup>
  800818:	89 c3                	mov    %eax,%ebx
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	85 c0                	test   %eax,%eax
  80081f:	78 1a                	js     80083b <fd_close+0x6a>
		if (dev->dev_close)
  800821:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800824:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800827:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80082c:	85 c0                	test   %eax,%eax
  80082e:	74 0b                	je     80083b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800830:	83 ec 0c             	sub    $0xc,%esp
  800833:	56                   	push   %esi
  800834:	ff d0                	call   *%eax
  800836:	89 c3                	mov    %eax,%ebx
  800838:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	56                   	push   %esi
  80083f:	6a 00                	push   $0x0
  800841:	e8 cc f9 ff ff       	call   800212 <sys_page_unmap>
	return r;
  800846:	83 c4 10             	add    $0x10,%esp
  800849:	89 d8                	mov    %ebx,%eax
}
  80084b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800858:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085b:	50                   	push   %eax
  80085c:	ff 75 08             	pushl  0x8(%ebp)
  80085f:	e8 c4 fe ff ff       	call   800728 <fd_lookup>
  800864:	83 c4 08             	add    $0x8,%esp
  800867:	85 c0                	test   %eax,%eax
  800869:	78 10                	js     80087b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	6a 01                	push   $0x1
  800870:	ff 75 f4             	pushl  -0xc(%ebp)
  800873:	e8 59 ff ff ff       	call   8007d1 <fd_close>
  800878:	83 c4 10             	add    $0x10,%esp
}
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    

0080087d <close_all>:

void
close_all(void)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	53                   	push   %ebx
  800881:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800884:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800889:	83 ec 0c             	sub    $0xc,%esp
  80088c:	53                   	push   %ebx
  80088d:	e8 c0 ff ff ff       	call   800852 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800892:	83 c3 01             	add    $0x1,%ebx
  800895:	83 c4 10             	add    $0x10,%esp
  800898:	83 fb 20             	cmp    $0x20,%ebx
  80089b:	75 ec                	jne    800889 <close_all+0xc>
		close(i);
}
  80089d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	57                   	push   %edi
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	83 ec 2c             	sub    $0x2c,%esp
  8008ab:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008b1:	50                   	push   %eax
  8008b2:	ff 75 08             	pushl  0x8(%ebp)
  8008b5:	e8 6e fe ff ff       	call   800728 <fd_lookup>
  8008ba:	83 c4 08             	add    $0x8,%esp
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	0f 88 c1 00 00 00    	js     800986 <dup+0xe4>
		return r;
	close(newfdnum);
  8008c5:	83 ec 0c             	sub    $0xc,%esp
  8008c8:	56                   	push   %esi
  8008c9:	e8 84 ff ff ff       	call   800852 <close>

	newfd = INDEX2FD(newfdnum);
  8008ce:	89 f3                	mov    %esi,%ebx
  8008d0:	c1 e3 0c             	shl    $0xc,%ebx
  8008d3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008d9:	83 c4 04             	add    $0x4,%esp
  8008dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008df:	e8 de fd ff ff       	call   8006c2 <fd2data>
  8008e4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 d4 fd ff ff       	call   8006c2 <fd2data>
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008f4:	89 f8                	mov    %edi,%eax
  8008f6:	c1 e8 16             	shr    $0x16,%eax
  8008f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800900:	a8 01                	test   $0x1,%al
  800902:	74 37                	je     80093b <dup+0x99>
  800904:	89 f8                	mov    %edi,%eax
  800906:	c1 e8 0c             	shr    $0xc,%eax
  800909:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800910:	f6 c2 01             	test   $0x1,%dl
  800913:	74 26                	je     80093b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800915:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	25 07 0e 00 00       	and    $0xe07,%eax
  800924:	50                   	push   %eax
  800925:	ff 75 d4             	pushl  -0x2c(%ebp)
  800928:	6a 00                	push   $0x0
  80092a:	57                   	push   %edi
  80092b:	6a 00                	push   $0x0
  80092d:	e8 9e f8 ff ff       	call   8001d0 <sys_page_map>
  800932:	89 c7                	mov    %eax,%edi
  800934:	83 c4 20             	add    $0x20,%esp
  800937:	85 c0                	test   %eax,%eax
  800939:	78 2e                	js     800969 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80093b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80093e:	89 d0                	mov    %edx,%eax
  800940:	c1 e8 0c             	shr    $0xc,%eax
  800943:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80094a:	83 ec 0c             	sub    $0xc,%esp
  80094d:	25 07 0e 00 00       	and    $0xe07,%eax
  800952:	50                   	push   %eax
  800953:	53                   	push   %ebx
  800954:	6a 00                	push   $0x0
  800956:	52                   	push   %edx
  800957:	6a 00                	push   $0x0
  800959:	e8 72 f8 ff ff       	call   8001d0 <sys_page_map>
  80095e:	89 c7                	mov    %eax,%edi
  800960:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800963:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800965:	85 ff                	test   %edi,%edi
  800967:	79 1d                	jns    800986 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800969:	83 ec 08             	sub    $0x8,%esp
  80096c:	53                   	push   %ebx
  80096d:	6a 00                	push   $0x0
  80096f:	e8 9e f8 ff ff       	call   800212 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800974:	83 c4 08             	add    $0x8,%esp
  800977:	ff 75 d4             	pushl  -0x2c(%ebp)
  80097a:	6a 00                	push   $0x0
  80097c:	e8 91 f8 ff ff       	call   800212 <sys_page_unmap>
	return r;
  800981:	83 c4 10             	add    $0x10,%esp
  800984:	89 f8                	mov    %edi,%eax
}
  800986:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	53                   	push   %ebx
  800992:	83 ec 14             	sub    $0x14,%esp
  800995:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800998:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80099b:	50                   	push   %eax
  80099c:	53                   	push   %ebx
  80099d:	e8 86 fd ff ff       	call   800728 <fd_lookup>
  8009a2:	83 c4 08             	add    $0x8,%esp
  8009a5:	89 c2                	mov    %eax,%edx
  8009a7:	85 c0                	test   %eax,%eax
  8009a9:	78 6d                	js     800a18 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009ab:	83 ec 08             	sub    $0x8,%esp
  8009ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009b1:	50                   	push   %eax
  8009b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b5:	ff 30                	pushl  (%eax)
  8009b7:	e8 c2 fd ff ff       	call   80077e <dev_lookup>
  8009bc:	83 c4 10             	add    $0x10,%esp
  8009bf:	85 c0                	test   %eax,%eax
  8009c1:	78 4c                	js     800a0f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009c6:	8b 42 08             	mov    0x8(%edx),%eax
  8009c9:	83 e0 03             	and    $0x3,%eax
  8009cc:	83 f8 01             	cmp    $0x1,%eax
  8009cf:	75 21                	jne    8009f2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8009d6:	8b 40 7c             	mov    0x7c(%eax),%eax
  8009d9:	83 ec 04             	sub    $0x4,%esp
  8009dc:	53                   	push   %ebx
  8009dd:	50                   	push   %eax
  8009de:	68 e1 22 80 00       	push   $0x8022e1
  8009e3:	e8 96 0a 00 00       	call   80147e <cprintf>
		return -E_INVAL;
  8009e8:	83 c4 10             	add    $0x10,%esp
  8009eb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009f0:	eb 26                	jmp    800a18 <read+0x8a>
	}
	if (!dev->dev_read)
  8009f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f5:	8b 40 08             	mov    0x8(%eax),%eax
  8009f8:	85 c0                	test   %eax,%eax
  8009fa:	74 17                	je     800a13 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009fc:	83 ec 04             	sub    $0x4,%esp
  8009ff:	ff 75 10             	pushl  0x10(%ebp)
  800a02:	ff 75 0c             	pushl  0xc(%ebp)
  800a05:	52                   	push   %edx
  800a06:	ff d0                	call   *%eax
  800a08:	89 c2                	mov    %eax,%edx
  800a0a:	83 c4 10             	add    $0x10,%esp
  800a0d:	eb 09                	jmp    800a18 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a0f:	89 c2                	mov    %eax,%edx
  800a11:	eb 05                	jmp    800a18 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a13:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a18:	89 d0                	mov    %edx,%eax
  800a1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	57                   	push   %edi
  800a23:	56                   	push   %esi
  800a24:	53                   	push   %ebx
  800a25:	83 ec 0c             	sub    $0xc,%esp
  800a28:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a33:	eb 21                	jmp    800a56 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a35:	83 ec 04             	sub    $0x4,%esp
  800a38:	89 f0                	mov    %esi,%eax
  800a3a:	29 d8                	sub    %ebx,%eax
  800a3c:	50                   	push   %eax
  800a3d:	89 d8                	mov    %ebx,%eax
  800a3f:	03 45 0c             	add    0xc(%ebp),%eax
  800a42:	50                   	push   %eax
  800a43:	57                   	push   %edi
  800a44:	e8 45 ff ff ff       	call   80098e <read>
		if (m < 0)
  800a49:	83 c4 10             	add    $0x10,%esp
  800a4c:	85 c0                	test   %eax,%eax
  800a4e:	78 10                	js     800a60 <readn+0x41>
			return m;
		if (m == 0)
  800a50:	85 c0                	test   %eax,%eax
  800a52:	74 0a                	je     800a5e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a54:	01 c3                	add    %eax,%ebx
  800a56:	39 f3                	cmp    %esi,%ebx
  800a58:	72 db                	jb     800a35 <readn+0x16>
  800a5a:	89 d8                	mov    %ebx,%eax
  800a5c:	eb 02                	jmp    800a60 <readn+0x41>
  800a5e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	53                   	push   %ebx
  800a6c:	83 ec 14             	sub    $0x14,%esp
  800a6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a72:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a75:	50                   	push   %eax
  800a76:	53                   	push   %ebx
  800a77:	e8 ac fc ff ff       	call   800728 <fd_lookup>
  800a7c:	83 c4 08             	add    $0x8,%esp
  800a7f:	89 c2                	mov    %eax,%edx
  800a81:	85 c0                	test   %eax,%eax
  800a83:	78 68                	js     800aed <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a85:	83 ec 08             	sub    $0x8,%esp
  800a88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a8b:	50                   	push   %eax
  800a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8f:	ff 30                	pushl  (%eax)
  800a91:	e8 e8 fc ff ff       	call   80077e <dev_lookup>
  800a96:	83 c4 10             	add    $0x10,%esp
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	78 47                	js     800ae4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aa0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800aa4:	75 21                	jne    800ac7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800aa6:	a1 04 40 80 00       	mov    0x804004,%eax
  800aab:	8b 40 7c             	mov    0x7c(%eax),%eax
  800aae:	83 ec 04             	sub    $0x4,%esp
  800ab1:	53                   	push   %ebx
  800ab2:	50                   	push   %eax
  800ab3:	68 fd 22 80 00       	push   $0x8022fd
  800ab8:	e8 c1 09 00 00       	call   80147e <cprintf>
		return -E_INVAL;
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ac5:	eb 26                	jmp    800aed <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ac7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aca:	8b 52 0c             	mov    0xc(%edx),%edx
  800acd:	85 d2                	test   %edx,%edx
  800acf:	74 17                	je     800ae8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ad1:	83 ec 04             	sub    $0x4,%esp
  800ad4:	ff 75 10             	pushl  0x10(%ebp)
  800ad7:	ff 75 0c             	pushl  0xc(%ebp)
  800ada:	50                   	push   %eax
  800adb:	ff d2                	call   *%edx
  800add:	89 c2                	mov    %eax,%edx
  800adf:	83 c4 10             	add    $0x10,%esp
  800ae2:	eb 09                	jmp    800aed <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ae4:	89 c2                	mov    %eax,%edx
  800ae6:	eb 05                	jmp    800aed <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ae8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800aed:	89 d0                	mov    %edx,%eax
  800aef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af2:	c9                   	leave  
  800af3:	c3                   	ret    

00800af4 <seek>:

int
seek(int fdnum, off_t offset)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800afa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800afd:	50                   	push   %eax
  800afe:	ff 75 08             	pushl  0x8(%ebp)
  800b01:	e8 22 fc ff ff       	call   800728 <fd_lookup>
  800b06:	83 c4 08             	add    $0x8,%esp
  800b09:	85 c0                	test   %eax,%eax
  800b0b:	78 0e                	js     800b1b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b13:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	53                   	push   %ebx
  800b21:	83 ec 14             	sub    $0x14,%esp
  800b24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b27:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b2a:	50                   	push   %eax
  800b2b:	53                   	push   %ebx
  800b2c:	e8 f7 fb ff ff       	call   800728 <fd_lookup>
  800b31:	83 c4 08             	add    $0x8,%esp
  800b34:	89 c2                	mov    %eax,%edx
  800b36:	85 c0                	test   %eax,%eax
  800b38:	78 65                	js     800b9f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b3a:	83 ec 08             	sub    $0x8,%esp
  800b3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b40:	50                   	push   %eax
  800b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b44:	ff 30                	pushl  (%eax)
  800b46:	e8 33 fc ff ff       	call   80077e <dev_lookup>
  800b4b:	83 c4 10             	add    $0x10,%esp
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	78 44                	js     800b96 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b52:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b55:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b59:	75 21                	jne    800b7c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b5b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b60:	8b 40 7c             	mov    0x7c(%eax),%eax
  800b63:	83 ec 04             	sub    $0x4,%esp
  800b66:	53                   	push   %ebx
  800b67:	50                   	push   %eax
  800b68:	68 c0 22 80 00       	push   $0x8022c0
  800b6d:	e8 0c 09 00 00       	call   80147e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b7a:	eb 23                	jmp    800b9f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7f:	8b 52 18             	mov    0x18(%edx),%edx
  800b82:	85 d2                	test   %edx,%edx
  800b84:	74 14                	je     800b9a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b86:	83 ec 08             	sub    $0x8,%esp
  800b89:	ff 75 0c             	pushl  0xc(%ebp)
  800b8c:	50                   	push   %eax
  800b8d:	ff d2                	call   *%edx
  800b8f:	89 c2                	mov    %eax,%edx
  800b91:	83 c4 10             	add    $0x10,%esp
  800b94:	eb 09                	jmp    800b9f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b96:	89 c2                	mov    %eax,%edx
  800b98:	eb 05                	jmp    800b9f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b9a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b9f:	89 d0                	mov    %edx,%eax
  800ba1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    

00800ba6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 14             	sub    $0x14,%esp
  800bad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bb3:	50                   	push   %eax
  800bb4:	ff 75 08             	pushl  0x8(%ebp)
  800bb7:	e8 6c fb ff ff       	call   800728 <fd_lookup>
  800bbc:	83 c4 08             	add    $0x8,%esp
  800bbf:	89 c2                	mov    %eax,%edx
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	78 58                	js     800c1d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bc5:	83 ec 08             	sub    $0x8,%esp
  800bc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bcb:	50                   	push   %eax
  800bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bcf:	ff 30                	pushl  (%eax)
  800bd1:	e8 a8 fb ff ff       	call   80077e <dev_lookup>
  800bd6:	83 c4 10             	add    $0x10,%esp
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	78 37                	js     800c14 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800be0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800be4:	74 32                	je     800c18 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800be6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800be9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800bf0:	00 00 00 
	stat->st_isdir = 0;
  800bf3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bfa:	00 00 00 
	stat->st_dev = dev;
  800bfd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c03:	83 ec 08             	sub    $0x8,%esp
  800c06:	53                   	push   %ebx
  800c07:	ff 75 f0             	pushl  -0x10(%ebp)
  800c0a:	ff 50 14             	call   *0x14(%eax)
  800c0d:	89 c2                	mov    %eax,%edx
  800c0f:	83 c4 10             	add    $0x10,%esp
  800c12:	eb 09                	jmp    800c1d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c14:	89 c2                	mov    %eax,%edx
  800c16:	eb 05                	jmp    800c1d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c18:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c1d:	89 d0                	mov    %edx,%eax
  800c1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c29:	83 ec 08             	sub    $0x8,%esp
  800c2c:	6a 00                	push   $0x0
  800c2e:	ff 75 08             	pushl  0x8(%ebp)
  800c31:	e8 e3 01 00 00       	call   800e19 <open>
  800c36:	89 c3                	mov    %eax,%ebx
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	78 1b                	js     800c5a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c3f:	83 ec 08             	sub    $0x8,%esp
  800c42:	ff 75 0c             	pushl  0xc(%ebp)
  800c45:	50                   	push   %eax
  800c46:	e8 5b ff ff ff       	call   800ba6 <fstat>
  800c4b:	89 c6                	mov    %eax,%esi
	close(fd);
  800c4d:	89 1c 24             	mov    %ebx,(%esp)
  800c50:	e8 fd fb ff ff       	call   800852 <close>
	return r;
  800c55:	83 c4 10             	add    $0x10,%esp
  800c58:	89 f0                	mov    %esi,%eax
}
  800c5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	89 c6                	mov    %eax,%esi
  800c68:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c6a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c71:	75 12                	jne    800c85 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c73:	83 ec 0c             	sub    $0xc,%esp
  800c76:	6a 01                	push   $0x1
  800c78:	e8 39 12 00 00       	call   801eb6 <ipc_find_env>
  800c7d:	a3 00 40 80 00       	mov    %eax,0x804000
  800c82:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c85:	6a 07                	push   $0x7
  800c87:	68 00 50 80 00       	push   $0x805000
  800c8c:	56                   	push   %esi
  800c8d:	ff 35 00 40 80 00    	pushl  0x804000
  800c93:	e8 bc 11 00 00       	call   801e54 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c98:	83 c4 0c             	add    $0xc,%esp
  800c9b:	6a 00                	push   $0x0
  800c9d:	53                   	push   %ebx
  800c9e:	6a 00                	push   $0x0
  800ca0:	e8 34 11 00 00       	call   801dd9 <ipc_recv>
}
  800ca5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	8b 40 0c             	mov    0xc(%eax),%eax
  800cb8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cca:	b8 02 00 00 00       	mov    $0x2,%eax
  800ccf:	e8 8d ff ff ff       	call   800c61 <fsipc>
}
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	8b 40 0c             	mov    0xc(%eax),%eax
  800ce2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cec:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf1:	e8 6b ff ff ff       	call   800c61 <fsipc>
}
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 04             	sub    $0x4,%esp
  800cff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d02:	8b 45 08             	mov    0x8(%ebp),%eax
  800d05:	8b 40 0c             	mov    0xc(%eax),%eax
  800d08:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d12:	b8 05 00 00 00       	mov    $0x5,%eax
  800d17:	e8 45 ff ff ff       	call   800c61 <fsipc>
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	78 2c                	js     800d4c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d20:	83 ec 08             	sub    $0x8,%esp
  800d23:	68 00 50 80 00       	push   $0x805000
  800d28:	53                   	push   %ebx
  800d29:	e8 d5 0c 00 00       	call   801a03 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d2e:	a1 80 50 80 00       	mov    0x805080,%eax
  800d33:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d39:	a1 84 50 80 00       	mov    0x805084,%eax
  800d3e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d44:	83 c4 10             	add    $0x10,%esp
  800d47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    

00800d51 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 0c             	sub    $0xc,%esp
  800d57:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	8b 52 0c             	mov    0xc(%edx),%edx
  800d60:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d66:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d6b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d70:	0f 47 c2             	cmova  %edx,%eax
  800d73:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d78:	50                   	push   %eax
  800d79:	ff 75 0c             	pushl  0xc(%ebp)
  800d7c:	68 08 50 80 00       	push   $0x805008
  800d81:	e8 0f 0e 00 00       	call   801b95 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d86:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d90:	e8 cc fe ff ff       	call   800c61 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	56                   	push   %esi
  800d9b:	53                   	push   %ebx
  800d9c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	8b 40 0c             	mov    0xc(%eax),%eax
  800da5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800daa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800db0:	ba 00 00 00 00       	mov    $0x0,%edx
  800db5:	b8 03 00 00 00       	mov    $0x3,%eax
  800dba:	e8 a2 fe ff ff       	call   800c61 <fsipc>
  800dbf:	89 c3                	mov    %eax,%ebx
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	78 4b                	js     800e10 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800dc5:	39 c6                	cmp    %eax,%esi
  800dc7:	73 16                	jae    800ddf <devfile_read+0x48>
  800dc9:	68 2c 23 80 00       	push   $0x80232c
  800dce:	68 33 23 80 00       	push   $0x802333
  800dd3:	6a 7c                	push   $0x7c
  800dd5:	68 48 23 80 00       	push   $0x802348
  800dda:	e8 c6 05 00 00       	call   8013a5 <_panic>
	assert(r <= PGSIZE);
  800ddf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800de4:	7e 16                	jle    800dfc <devfile_read+0x65>
  800de6:	68 53 23 80 00       	push   $0x802353
  800deb:	68 33 23 80 00       	push   $0x802333
  800df0:	6a 7d                	push   $0x7d
  800df2:	68 48 23 80 00       	push   $0x802348
  800df7:	e8 a9 05 00 00       	call   8013a5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800dfc:	83 ec 04             	sub    $0x4,%esp
  800dff:	50                   	push   %eax
  800e00:	68 00 50 80 00       	push   $0x805000
  800e05:	ff 75 0c             	pushl  0xc(%ebp)
  800e08:	e8 88 0d 00 00       	call   801b95 <memmove>
	return r;
  800e0d:	83 c4 10             	add    $0x10,%esp
}
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 20             	sub    $0x20,%esp
  800e20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e23:	53                   	push   %ebx
  800e24:	e8 a1 0b 00 00       	call   8019ca <strlen>
  800e29:	83 c4 10             	add    $0x10,%esp
  800e2c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e31:	7f 67                	jg     800e9a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e39:	50                   	push   %eax
  800e3a:	e8 9a f8 ff ff       	call   8006d9 <fd_alloc>
  800e3f:	83 c4 10             	add    $0x10,%esp
		return r;
  800e42:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e44:	85 c0                	test   %eax,%eax
  800e46:	78 57                	js     800e9f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	53                   	push   %ebx
  800e4c:	68 00 50 80 00       	push   $0x805000
  800e51:	e8 ad 0b 00 00       	call   801a03 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e59:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e61:	b8 01 00 00 00       	mov    $0x1,%eax
  800e66:	e8 f6 fd ff ff       	call   800c61 <fsipc>
  800e6b:	89 c3                	mov    %eax,%ebx
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	85 c0                	test   %eax,%eax
  800e72:	79 14                	jns    800e88 <open+0x6f>
		fd_close(fd, 0);
  800e74:	83 ec 08             	sub    $0x8,%esp
  800e77:	6a 00                	push   $0x0
  800e79:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7c:	e8 50 f9 ff ff       	call   8007d1 <fd_close>
		return r;
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	89 da                	mov    %ebx,%edx
  800e86:	eb 17                	jmp    800e9f <open+0x86>
	}

	return fd2num(fd);
  800e88:	83 ec 0c             	sub    $0xc,%esp
  800e8b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8e:	e8 1f f8 ff ff       	call   8006b2 <fd2num>
  800e93:	89 c2                	mov    %eax,%edx
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	eb 05                	jmp    800e9f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e9a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e9f:	89 d0                	mov    %edx,%eax
  800ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800eac:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb1:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb6:	e8 a6 fd ff ff       	call   800c61 <fsipc>
}
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	56                   	push   %esi
  800ec1:	53                   	push   %ebx
  800ec2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ec5:	83 ec 0c             	sub    $0xc,%esp
  800ec8:	ff 75 08             	pushl  0x8(%ebp)
  800ecb:	e8 f2 f7 ff ff       	call   8006c2 <fd2data>
  800ed0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ed2:	83 c4 08             	add    $0x8,%esp
  800ed5:	68 5f 23 80 00       	push   $0x80235f
  800eda:	53                   	push   %ebx
  800edb:	e8 23 0b 00 00       	call   801a03 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ee0:	8b 46 04             	mov    0x4(%esi),%eax
  800ee3:	2b 06                	sub    (%esi),%eax
  800ee5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800eeb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ef2:	00 00 00 
	stat->st_dev = &devpipe;
  800ef5:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800efc:	30 80 00 
	return 0;
}
  800eff:	b8 00 00 00 00       	mov    $0x0,%eax
  800f04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f15:	53                   	push   %ebx
  800f16:	6a 00                	push   $0x0
  800f18:	e8 f5 f2 ff ff       	call   800212 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f1d:	89 1c 24             	mov    %ebx,(%esp)
  800f20:	e8 9d f7 ff ff       	call   8006c2 <fd2data>
  800f25:	83 c4 08             	add    $0x8,%esp
  800f28:	50                   	push   %eax
  800f29:	6a 00                	push   $0x0
  800f2b:	e8 e2 f2 ff ff       	call   800212 <sys_page_unmap>
}
  800f30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f33:	c9                   	leave  
  800f34:	c3                   	ret    

00800f35 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 1c             	sub    $0x1c,%esp
  800f3e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f41:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f43:	a1 04 40 80 00       	mov    0x804004,%eax
  800f48:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	ff 75 e0             	pushl  -0x20(%ebp)
  800f54:	e8 9f 0f 00 00       	call   801ef8 <pageref>
  800f59:	89 c3                	mov    %eax,%ebx
  800f5b:	89 3c 24             	mov    %edi,(%esp)
  800f5e:	e8 95 0f 00 00       	call   801ef8 <pageref>
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	39 c3                	cmp    %eax,%ebx
  800f68:	0f 94 c1             	sete   %cl
  800f6b:	0f b6 c9             	movzbl %cl,%ecx
  800f6e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f71:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f77:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  800f7d:	39 ce                	cmp    %ecx,%esi
  800f7f:	74 1e                	je     800f9f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800f81:	39 c3                	cmp    %eax,%ebx
  800f83:	75 be                	jne    800f43 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f85:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  800f8b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f8e:	50                   	push   %eax
  800f8f:	56                   	push   %esi
  800f90:	68 66 23 80 00       	push   $0x802366
  800f95:	e8 e4 04 00 00       	call   80147e <cprintf>
  800f9a:	83 c4 10             	add    $0x10,%esp
  800f9d:	eb a4                	jmp    800f43 <_pipeisclosed+0xe>
	}
}
  800f9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    

00800faa <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	57                   	push   %edi
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 28             	sub    $0x28,%esp
  800fb3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fb6:	56                   	push   %esi
  800fb7:	e8 06 f7 ff ff       	call   8006c2 <fd2data>
  800fbc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	bf 00 00 00 00       	mov    $0x0,%edi
  800fc6:	eb 4b                	jmp    801013 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fc8:	89 da                	mov    %ebx,%edx
  800fca:	89 f0                	mov    %esi,%eax
  800fcc:	e8 64 ff ff ff       	call   800f35 <_pipeisclosed>
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	75 48                	jne    80101d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fd5:	e8 94 f1 ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fda:	8b 43 04             	mov    0x4(%ebx),%eax
  800fdd:	8b 0b                	mov    (%ebx),%ecx
  800fdf:	8d 51 20             	lea    0x20(%ecx),%edx
  800fe2:	39 d0                	cmp    %edx,%eax
  800fe4:	73 e2                	jae    800fc8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fe6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fed:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ff0:	89 c2                	mov    %eax,%edx
  800ff2:	c1 fa 1f             	sar    $0x1f,%edx
  800ff5:	89 d1                	mov    %edx,%ecx
  800ff7:	c1 e9 1b             	shr    $0x1b,%ecx
  800ffa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ffd:	83 e2 1f             	and    $0x1f,%edx
  801000:	29 ca                	sub    %ecx,%edx
  801002:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801006:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80100a:	83 c0 01             	add    $0x1,%eax
  80100d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801010:	83 c7 01             	add    $0x1,%edi
  801013:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801016:	75 c2                	jne    800fda <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801018:	8b 45 10             	mov    0x10(%ebp),%eax
  80101b:	eb 05                	jmp    801022 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80101d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801022:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801025:	5b                   	pop    %ebx
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    

0080102a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	57                   	push   %edi
  80102e:	56                   	push   %esi
  80102f:	53                   	push   %ebx
  801030:	83 ec 18             	sub    $0x18,%esp
  801033:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801036:	57                   	push   %edi
  801037:	e8 86 f6 ff ff       	call   8006c2 <fd2data>
  80103c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80103e:	83 c4 10             	add    $0x10,%esp
  801041:	bb 00 00 00 00       	mov    $0x0,%ebx
  801046:	eb 3d                	jmp    801085 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801048:	85 db                	test   %ebx,%ebx
  80104a:	74 04                	je     801050 <devpipe_read+0x26>
				return i;
  80104c:	89 d8                	mov    %ebx,%eax
  80104e:	eb 44                	jmp    801094 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801050:	89 f2                	mov    %esi,%edx
  801052:	89 f8                	mov    %edi,%eax
  801054:	e8 dc fe ff ff       	call   800f35 <_pipeisclosed>
  801059:	85 c0                	test   %eax,%eax
  80105b:	75 32                	jne    80108f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80105d:	e8 0c f1 ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801062:	8b 06                	mov    (%esi),%eax
  801064:	3b 46 04             	cmp    0x4(%esi),%eax
  801067:	74 df                	je     801048 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801069:	99                   	cltd   
  80106a:	c1 ea 1b             	shr    $0x1b,%edx
  80106d:	01 d0                	add    %edx,%eax
  80106f:	83 e0 1f             	and    $0x1f,%eax
  801072:	29 d0                	sub    %edx,%eax
  801074:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801079:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80107f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801082:	83 c3 01             	add    $0x1,%ebx
  801085:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801088:	75 d8                	jne    801062 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80108a:	8b 45 10             	mov    0x10(%ebp),%eax
  80108d:	eb 05                	jmp    801094 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80108f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801097:	5b                   	pop    %ebx
  801098:	5e                   	pop    %esi
  801099:	5f                   	pop    %edi
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a7:	50                   	push   %eax
  8010a8:	e8 2c f6 ff ff       	call   8006d9 <fd_alloc>
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	89 c2                	mov    %eax,%edx
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	0f 88 2c 01 00 00    	js     8011e6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010ba:	83 ec 04             	sub    $0x4,%esp
  8010bd:	68 07 04 00 00       	push   $0x407
  8010c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010c5:	6a 00                	push   $0x0
  8010c7:	e8 c1 f0 ff ff       	call   80018d <sys_page_alloc>
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	89 c2                	mov    %eax,%edx
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	0f 88 0d 01 00 00    	js     8011e6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010d9:	83 ec 0c             	sub    $0xc,%esp
  8010dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010df:	50                   	push   %eax
  8010e0:	e8 f4 f5 ff ff       	call   8006d9 <fd_alloc>
  8010e5:	89 c3                	mov    %eax,%ebx
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	0f 88 e2 00 00 00    	js     8011d4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010f2:	83 ec 04             	sub    $0x4,%esp
  8010f5:	68 07 04 00 00       	push   $0x407
  8010fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8010fd:	6a 00                	push   $0x0
  8010ff:	e8 89 f0 ff ff       	call   80018d <sys_page_alloc>
  801104:	89 c3                	mov    %eax,%ebx
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	0f 88 c3 00 00 00    	js     8011d4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801111:	83 ec 0c             	sub    $0xc,%esp
  801114:	ff 75 f4             	pushl  -0xc(%ebp)
  801117:	e8 a6 f5 ff ff       	call   8006c2 <fd2data>
  80111c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80111e:	83 c4 0c             	add    $0xc,%esp
  801121:	68 07 04 00 00       	push   $0x407
  801126:	50                   	push   %eax
  801127:	6a 00                	push   $0x0
  801129:	e8 5f f0 ff ff       	call   80018d <sys_page_alloc>
  80112e:	89 c3                	mov    %eax,%ebx
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	0f 88 89 00 00 00    	js     8011c4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	ff 75 f0             	pushl  -0x10(%ebp)
  801141:	e8 7c f5 ff ff       	call   8006c2 <fd2data>
  801146:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80114d:	50                   	push   %eax
  80114e:	6a 00                	push   $0x0
  801150:	56                   	push   %esi
  801151:	6a 00                	push   $0x0
  801153:	e8 78 f0 ff ff       	call   8001d0 <sys_page_map>
  801158:	89 c3                	mov    %eax,%ebx
  80115a:	83 c4 20             	add    $0x20,%esp
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 55                	js     8011b6 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801161:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801167:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80116c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801176:	8b 15 24 30 80 00    	mov    0x803024,%edx
  80117c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801181:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801184:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	ff 75 f4             	pushl  -0xc(%ebp)
  801191:	e8 1c f5 ff ff       	call   8006b2 <fd2num>
  801196:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801199:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80119b:	83 c4 04             	add    $0x4,%esp
  80119e:	ff 75 f0             	pushl  -0x10(%ebp)
  8011a1:	e8 0c f5 ff ff       	call   8006b2 <fd2num>
  8011a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a9:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b4:	eb 30                	jmp    8011e6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	56                   	push   %esi
  8011ba:	6a 00                	push   $0x0
  8011bc:	e8 51 f0 ff ff       	call   800212 <sys_page_unmap>
  8011c1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8011ca:	6a 00                	push   $0x0
  8011cc:	e8 41 f0 ff ff       	call   800212 <sys_page_unmap>
  8011d1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8011da:	6a 00                	push   $0x0
  8011dc:	e8 31 f0 ff ff       	call   800212 <sys_page_unmap>
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011e6:	89 d0                	mov    %edx,%eax
  8011e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	ff 75 08             	pushl  0x8(%ebp)
  8011fc:	e8 27 f5 ff ff       	call   800728 <fd_lookup>
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	78 18                	js     801220 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801208:	83 ec 0c             	sub    $0xc,%esp
  80120b:	ff 75 f4             	pushl  -0xc(%ebp)
  80120e:	e8 af f4 ff ff       	call   8006c2 <fd2data>
	return _pipeisclosed(fd, p);
  801213:	89 c2                	mov    %eax,%edx
  801215:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801218:	e8 18 fd ff ff       	call   800f35 <_pipeisclosed>
  80121d:	83 c4 10             	add    $0x10,%esp
}
  801220:	c9                   	leave  
  801221:	c3                   	ret    

00801222 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801232:	68 7e 23 80 00       	push   $0x80237e
  801237:	ff 75 0c             	pushl  0xc(%ebp)
  80123a:	e8 c4 07 00 00       	call   801a03 <strcpy>
	return 0;
}
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
  801244:	c9                   	leave  
  801245:	c3                   	ret    

00801246 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	57                   	push   %edi
  80124a:	56                   	push   %esi
  80124b:	53                   	push   %ebx
  80124c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801252:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801257:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80125d:	eb 2d                	jmp    80128c <devcons_write+0x46>
		m = n - tot;
  80125f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801262:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801264:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801267:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80126c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80126f:	83 ec 04             	sub    $0x4,%esp
  801272:	53                   	push   %ebx
  801273:	03 45 0c             	add    0xc(%ebp),%eax
  801276:	50                   	push   %eax
  801277:	57                   	push   %edi
  801278:	e8 18 09 00 00       	call   801b95 <memmove>
		sys_cputs(buf, m);
  80127d:	83 c4 08             	add    $0x8,%esp
  801280:	53                   	push   %ebx
  801281:	57                   	push   %edi
  801282:	e8 4a ee ff ff       	call   8000d1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801287:	01 de                	add    %ebx,%esi
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	89 f0                	mov    %esi,%eax
  80128e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801291:	72 cc                	jb     80125f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801293:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801296:	5b                   	pop    %ebx
  801297:	5e                   	pop    %esi
  801298:	5f                   	pop    %edi
  801299:	5d                   	pop    %ebp
  80129a:	c3                   	ret    

0080129b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	83 ec 08             	sub    $0x8,%esp
  8012a1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012aa:	74 2a                	je     8012d6 <devcons_read+0x3b>
  8012ac:	eb 05                	jmp    8012b3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012ae:	e8 bb ee ff ff       	call   80016e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012b3:	e8 37 ee ff ff       	call   8000ef <sys_cgetc>
  8012b8:	85 c0                	test   %eax,%eax
  8012ba:	74 f2                	je     8012ae <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 16                	js     8012d6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012c0:	83 f8 04             	cmp    $0x4,%eax
  8012c3:	74 0c                	je     8012d1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c8:	88 02                	mov    %al,(%edx)
	return 1;
  8012ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8012cf:	eb 05                	jmp    8012d6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012de:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012e4:	6a 01                	push   $0x1
  8012e6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012e9:	50                   	push   %eax
  8012ea:	e8 e2 ed ff ff       	call   8000d1 <sys_cputs>
}
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	c9                   	leave  
  8012f3:	c3                   	ret    

008012f4 <getchar>:

int
getchar(void)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012fa:	6a 01                	push   $0x1
  8012fc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012ff:	50                   	push   %eax
  801300:	6a 00                	push   $0x0
  801302:	e8 87 f6 ff ff       	call   80098e <read>
	if (r < 0)
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 0f                	js     80131d <getchar+0x29>
		return r;
	if (r < 1)
  80130e:	85 c0                	test   %eax,%eax
  801310:	7e 06                	jle    801318 <getchar+0x24>
		return -E_EOF;
	return c;
  801312:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801316:	eb 05                	jmp    80131d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801318:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80131d:	c9                   	leave  
  80131e:	c3                   	ret    

0080131f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801325:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	ff 75 08             	pushl  0x8(%ebp)
  80132c:	e8 f7 f3 ff ff       	call   800728 <fd_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 11                	js     801349 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801338:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801341:	39 10                	cmp    %edx,(%eax)
  801343:	0f 94 c0             	sete   %al
  801346:	0f b6 c0             	movzbl %al,%eax
}
  801349:	c9                   	leave  
  80134a:	c3                   	ret    

0080134b <opencons>:

int
opencons(void)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801351:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	e8 7f f3 ff ff       	call   8006d9 <fd_alloc>
  80135a:	83 c4 10             	add    $0x10,%esp
		return r;
  80135d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 3e                	js     8013a1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801363:	83 ec 04             	sub    $0x4,%esp
  801366:	68 07 04 00 00       	push   $0x407
  80136b:	ff 75 f4             	pushl  -0xc(%ebp)
  80136e:	6a 00                	push   $0x0
  801370:	e8 18 ee ff ff       	call   80018d <sys_page_alloc>
  801375:	83 c4 10             	add    $0x10,%esp
		return r;
  801378:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 23                	js     8013a1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80137e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801384:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801387:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	50                   	push   %eax
  801397:	e8 16 f3 ff ff       	call   8006b2 <fd2num>
  80139c:	89 c2                	mov    %eax,%edx
  80139e:	83 c4 10             	add    $0x10,%esp
}
  8013a1:	89 d0                	mov    %edx,%eax
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	56                   	push   %esi
  8013a9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013aa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013ad:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8013b3:	e8 97 ed ff ff       	call   80014f <sys_getenvid>
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	ff 75 0c             	pushl  0xc(%ebp)
  8013be:	ff 75 08             	pushl  0x8(%ebp)
  8013c1:	56                   	push   %esi
  8013c2:	50                   	push   %eax
  8013c3:	68 8c 23 80 00       	push   $0x80238c
  8013c8:	e8 b1 00 00 00       	call   80147e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013cd:	83 c4 18             	add    $0x18,%esp
  8013d0:	53                   	push   %ebx
  8013d1:	ff 75 10             	pushl  0x10(%ebp)
  8013d4:	e8 54 00 00 00       	call   80142d <vcprintf>
	cprintf("\n");
  8013d9:	c7 04 24 77 23 80 00 	movl   $0x802377,(%esp)
  8013e0:	e8 99 00 00 00       	call   80147e <cprintf>
  8013e5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013e8:	cc                   	int3   
  8013e9:	eb fd                	jmp    8013e8 <_panic+0x43>

008013eb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	53                   	push   %ebx
  8013ef:	83 ec 04             	sub    $0x4,%esp
  8013f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013f5:	8b 13                	mov    (%ebx),%edx
  8013f7:	8d 42 01             	lea    0x1(%edx),%eax
  8013fa:	89 03                	mov    %eax,(%ebx)
  8013fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801403:	3d ff 00 00 00       	cmp    $0xff,%eax
  801408:	75 1a                	jne    801424 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80140a:	83 ec 08             	sub    $0x8,%esp
  80140d:	68 ff 00 00 00       	push   $0xff
  801412:	8d 43 08             	lea    0x8(%ebx),%eax
  801415:	50                   	push   %eax
  801416:	e8 b6 ec ff ff       	call   8000d1 <sys_cputs>
		b->idx = 0;
  80141b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801421:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801424:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801428:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    

0080142d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801436:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80143d:	00 00 00 
	b.cnt = 0;
  801440:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801447:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80144a:	ff 75 0c             	pushl  0xc(%ebp)
  80144d:	ff 75 08             	pushl  0x8(%ebp)
  801450:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	68 eb 13 80 00       	push   $0x8013eb
  80145c:	e8 54 01 00 00       	call   8015b5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801461:	83 c4 08             	add    $0x8,%esp
  801464:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80146a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801470:	50                   	push   %eax
  801471:	e8 5b ec ff ff       	call   8000d1 <sys_cputs>

	return b.cnt;
}
  801476:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801484:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801487:	50                   	push   %eax
  801488:	ff 75 08             	pushl  0x8(%ebp)
  80148b:	e8 9d ff ff ff       	call   80142d <vcprintf>
	va_end(ap);

	return cnt;
}
  801490:	c9                   	leave  
  801491:	c3                   	ret    

00801492 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	57                   	push   %edi
  801496:	56                   	push   %esi
  801497:	53                   	push   %ebx
  801498:	83 ec 1c             	sub    $0x1c,%esp
  80149b:	89 c7                	mov    %eax,%edi
  80149d:	89 d6                	mov    %edx,%esi
  80149f:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014b6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014b9:	39 d3                	cmp    %edx,%ebx
  8014bb:	72 05                	jb     8014c2 <printnum+0x30>
  8014bd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014c0:	77 45                	ja     801507 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014c2:	83 ec 0c             	sub    $0xc,%esp
  8014c5:	ff 75 18             	pushl  0x18(%ebp)
  8014c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014ce:	53                   	push   %ebx
  8014cf:	ff 75 10             	pushl  0x10(%ebp)
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8014db:	ff 75 dc             	pushl  -0x24(%ebp)
  8014de:	ff 75 d8             	pushl  -0x28(%ebp)
  8014e1:	e8 5a 0a 00 00       	call   801f40 <__udivdi3>
  8014e6:	83 c4 18             	add    $0x18,%esp
  8014e9:	52                   	push   %edx
  8014ea:	50                   	push   %eax
  8014eb:	89 f2                	mov    %esi,%edx
  8014ed:	89 f8                	mov    %edi,%eax
  8014ef:	e8 9e ff ff ff       	call   801492 <printnum>
  8014f4:	83 c4 20             	add    $0x20,%esp
  8014f7:	eb 18                	jmp    801511 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014f9:	83 ec 08             	sub    $0x8,%esp
  8014fc:	56                   	push   %esi
  8014fd:	ff 75 18             	pushl  0x18(%ebp)
  801500:	ff d7                	call   *%edi
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	eb 03                	jmp    80150a <printnum+0x78>
  801507:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80150a:	83 eb 01             	sub    $0x1,%ebx
  80150d:	85 db                	test   %ebx,%ebx
  80150f:	7f e8                	jg     8014f9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	56                   	push   %esi
  801515:	83 ec 04             	sub    $0x4,%esp
  801518:	ff 75 e4             	pushl  -0x1c(%ebp)
  80151b:	ff 75 e0             	pushl  -0x20(%ebp)
  80151e:	ff 75 dc             	pushl  -0x24(%ebp)
  801521:	ff 75 d8             	pushl  -0x28(%ebp)
  801524:	e8 47 0b 00 00       	call   802070 <__umoddi3>
  801529:	83 c4 14             	add    $0x14,%esp
  80152c:	0f be 80 af 23 80 00 	movsbl 0x8023af(%eax),%eax
  801533:	50                   	push   %eax
  801534:	ff d7                	call   *%edi
}
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153c:	5b                   	pop    %ebx
  80153d:	5e                   	pop    %esi
  80153e:	5f                   	pop    %edi
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    

00801541 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801544:	83 fa 01             	cmp    $0x1,%edx
  801547:	7e 0e                	jle    801557 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801549:	8b 10                	mov    (%eax),%edx
  80154b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80154e:	89 08                	mov    %ecx,(%eax)
  801550:	8b 02                	mov    (%edx),%eax
  801552:	8b 52 04             	mov    0x4(%edx),%edx
  801555:	eb 22                	jmp    801579 <getuint+0x38>
	else if (lflag)
  801557:	85 d2                	test   %edx,%edx
  801559:	74 10                	je     80156b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80155b:	8b 10                	mov    (%eax),%edx
  80155d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801560:	89 08                	mov    %ecx,(%eax)
  801562:	8b 02                	mov    (%edx),%eax
  801564:	ba 00 00 00 00       	mov    $0x0,%edx
  801569:	eb 0e                	jmp    801579 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80156b:	8b 10                	mov    (%eax),%edx
  80156d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801570:	89 08                	mov    %ecx,(%eax)
  801572:	8b 02                	mov    (%edx),%eax
  801574:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    

0080157b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801581:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801585:	8b 10                	mov    (%eax),%edx
  801587:	3b 50 04             	cmp    0x4(%eax),%edx
  80158a:	73 0a                	jae    801596 <sprintputch+0x1b>
		*b->buf++ = ch;
  80158c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80158f:	89 08                	mov    %ecx,(%eax)
  801591:	8b 45 08             	mov    0x8(%ebp),%eax
  801594:	88 02                	mov    %al,(%edx)
}
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80159e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015a1:	50                   	push   %eax
  8015a2:	ff 75 10             	pushl  0x10(%ebp)
  8015a5:	ff 75 0c             	pushl  0xc(%ebp)
  8015a8:	ff 75 08             	pushl  0x8(%ebp)
  8015ab:	e8 05 00 00 00       	call   8015b5 <vprintfmt>
	va_end(ap);
}
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	57                   	push   %edi
  8015b9:	56                   	push   %esi
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 2c             	sub    $0x2c,%esp
  8015be:	8b 75 08             	mov    0x8(%ebp),%esi
  8015c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015c4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015c7:	eb 12                	jmp    8015db <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	0f 84 89 03 00 00    	je     80195a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	50                   	push   %eax
  8015d6:	ff d6                	call   *%esi
  8015d8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015db:	83 c7 01             	add    $0x1,%edi
  8015de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015e2:	83 f8 25             	cmp    $0x25,%eax
  8015e5:	75 e2                	jne    8015c9 <vprintfmt+0x14>
  8015e7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015eb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015f9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801600:	ba 00 00 00 00       	mov    $0x0,%edx
  801605:	eb 07                	jmp    80160e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801607:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80160a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160e:	8d 47 01             	lea    0x1(%edi),%eax
  801611:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801614:	0f b6 07             	movzbl (%edi),%eax
  801617:	0f b6 c8             	movzbl %al,%ecx
  80161a:	83 e8 23             	sub    $0x23,%eax
  80161d:	3c 55                	cmp    $0x55,%al
  80161f:	0f 87 1a 03 00 00    	ja     80193f <vprintfmt+0x38a>
  801625:	0f b6 c0             	movzbl %al,%eax
  801628:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  80162f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801632:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801636:	eb d6                	jmp    80160e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80163b:	b8 00 00 00 00       	mov    $0x0,%eax
  801640:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801643:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801646:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80164a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80164d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801650:	83 fa 09             	cmp    $0x9,%edx
  801653:	77 39                	ja     80168e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801655:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801658:	eb e9                	jmp    801643 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80165a:	8b 45 14             	mov    0x14(%ebp),%eax
  80165d:	8d 48 04             	lea    0x4(%eax),%ecx
  801660:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801663:	8b 00                	mov    (%eax),%eax
  801665:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80166b:	eb 27                	jmp    801694 <vprintfmt+0xdf>
  80166d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801670:	85 c0                	test   %eax,%eax
  801672:	b9 00 00 00 00       	mov    $0x0,%ecx
  801677:	0f 49 c8             	cmovns %eax,%ecx
  80167a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80167d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801680:	eb 8c                	jmp    80160e <vprintfmt+0x59>
  801682:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801685:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80168c:	eb 80                	jmp    80160e <vprintfmt+0x59>
  80168e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801691:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801694:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801698:	0f 89 70 ff ff ff    	jns    80160e <vprintfmt+0x59>
				width = precision, precision = -1;
  80169e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016a4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016ab:	e9 5e ff ff ff       	jmp    80160e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016b0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016b6:	e9 53 ff ff ff       	jmp    80160e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8016be:	8d 50 04             	lea    0x4(%eax),%edx
  8016c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	53                   	push   %ebx
  8016c8:	ff 30                	pushl  (%eax)
  8016ca:	ff d6                	call   *%esi
			break;
  8016cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016d2:	e9 04 ff ff ff       	jmp    8015db <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8016da:	8d 50 04             	lea    0x4(%eax),%edx
  8016dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8016e0:	8b 00                	mov    (%eax),%eax
  8016e2:	99                   	cltd   
  8016e3:	31 d0                	xor    %edx,%eax
  8016e5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016e7:	83 f8 0f             	cmp    $0xf,%eax
  8016ea:	7f 0b                	jg     8016f7 <vprintfmt+0x142>
  8016ec:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8016f3:	85 d2                	test   %edx,%edx
  8016f5:	75 18                	jne    80170f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016f7:	50                   	push   %eax
  8016f8:	68 c7 23 80 00       	push   $0x8023c7
  8016fd:	53                   	push   %ebx
  8016fe:	56                   	push   %esi
  8016ff:	e8 94 fe ff ff       	call   801598 <printfmt>
  801704:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801707:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80170a:	e9 cc fe ff ff       	jmp    8015db <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80170f:	52                   	push   %edx
  801710:	68 45 23 80 00       	push   $0x802345
  801715:	53                   	push   %ebx
  801716:	56                   	push   %esi
  801717:	e8 7c fe ff ff       	call   801598 <printfmt>
  80171c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801722:	e9 b4 fe ff ff       	jmp    8015db <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801727:	8b 45 14             	mov    0x14(%ebp),%eax
  80172a:	8d 50 04             	lea    0x4(%eax),%edx
  80172d:	89 55 14             	mov    %edx,0x14(%ebp)
  801730:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801732:	85 ff                	test   %edi,%edi
  801734:	b8 c0 23 80 00       	mov    $0x8023c0,%eax
  801739:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80173c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801740:	0f 8e 94 00 00 00    	jle    8017da <vprintfmt+0x225>
  801746:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80174a:	0f 84 98 00 00 00    	je     8017e8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	ff 75 d0             	pushl  -0x30(%ebp)
  801756:	57                   	push   %edi
  801757:	e8 86 02 00 00       	call   8019e2 <strnlen>
  80175c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80175f:	29 c1                	sub    %eax,%ecx
  801761:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801764:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801767:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80176b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80176e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801771:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801773:	eb 0f                	jmp    801784 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801775:	83 ec 08             	sub    $0x8,%esp
  801778:	53                   	push   %ebx
  801779:	ff 75 e0             	pushl  -0x20(%ebp)
  80177c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80177e:	83 ef 01             	sub    $0x1,%edi
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	85 ff                	test   %edi,%edi
  801786:	7f ed                	jg     801775 <vprintfmt+0x1c0>
  801788:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80178b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80178e:	85 c9                	test   %ecx,%ecx
  801790:	b8 00 00 00 00       	mov    $0x0,%eax
  801795:	0f 49 c1             	cmovns %ecx,%eax
  801798:	29 c1                	sub    %eax,%ecx
  80179a:	89 75 08             	mov    %esi,0x8(%ebp)
  80179d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017a0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017a3:	89 cb                	mov    %ecx,%ebx
  8017a5:	eb 4d                	jmp    8017f4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017a7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017ab:	74 1b                	je     8017c8 <vprintfmt+0x213>
  8017ad:	0f be c0             	movsbl %al,%eax
  8017b0:	83 e8 20             	sub    $0x20,%eax
  8017b3:	83 f8 5e             	cmp    $0x5e,%eax
  8017b6:	76 10                	jbe    8017c8 <vprintfmt+0x213>
					putch('?', putdat);
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	ff 75 0c             	pushl  0xc(%ebp)
  8017be:	6a 3f                	push   $0x3f
  8017c0:	ff 55 08             	call   *0x8(%ebp)
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	eb 0d                	jmp    8017d5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ce:	52                   	push   %edx
  8017cf:	ff 55 08             	call   *0x8(%ebp)
  8017d2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017d5:	83 eb 01             	sub    $0x1,%ebx
  8017d8:	eb 1a                	jmp    8017f4 <vprintfmt+0x23f>
  8017da:	89 75 08             	mov    %esi,0x8(%ebp)
  8017dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017e3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017e6:	eb 0c                	jmp    8017f4 <vprintfmt+0x23f>
  8017e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8017eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017f4:	83 c7 01             	add    $0x1,%edi
  8017f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017fb:	0f be d0             	movsbl %al,%edx
  8017fe:	85 d2                	test   %edx,%edx
  801800:	74 23                	je     801825 <vprintfmt+0x270>
  801802:	85 f6                	test   %esi,%esi
  801804:	78 a1                	js     8017a7 <vprintfmt+0x1f2>
  801806:	83 ee 01             	sub    $0x1,%esi
  801809:	79 9c                	jns    8017a7 <vprintfmt+0x1f2>
  80180b:	89 df                	mov    %ebx,%edi
  80180d:	8b 75 08             	mov    0x8(%ebp),%esi
  801810:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801813:	eb 18                	jmp    80182d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801815:	83 ec 08             	sub    $0x8,%esp
  801818:	53                   	push   %ebx
  801819:	6a 20                	push   $0x20
  80181b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80181d:	83 ef 01             	sub    $0x1,%edi
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	eb 08                	jmp    80182d <vprintfmt+0x278>
  801825:	89 df                	mov    %ebx,%edi
  801827:	8b 75 08             	mov    0x8(%ebp),%esi
  80182a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80182d:	85 ff                	test   %edi,%edi
  80182f:	7f e4                	jg     801815 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801831:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801834:	e9 a2 fd ff ff       	jmp    8015db <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801839:	83 fa 01             	cmp    $0x1,%edx
  80183c:	7e 16                	jle    801854 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80183e:	8b 45 14             	mov    0x14(%ebp),%eax
  801841:	8d 50 08             	lea    0x8(%eax),%edx
  801844:	89 55 14             	mov    %edx,0x14(%ebp)
  801847:	8b 50 04             	mov    0x4(%eax),%edx
  80184a:	8b 00                	mov    (%eax),%eax
  80184c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80184f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801852:	eb 32                	jmp    801886 <vprintfmt+0x2d1>
	else if (lflag)
  801854:	85 d2                	test   %edx,%edx
  801856:	74 18                	je     801870 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801858:	8b 45 14             	mov    0x14(%ebp),%eax
  80185b:	8d 50 04             	lea    0x4(%eax),%edx
  80185e:	89 55 14             	mov    %edx,0x14(%ebp)
  801861:	8b 00                	mov    (%eax),%eax
  801863:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801866:	89 c1                	mov    %eax,%ecx
  801868:	c1 f9 1f             	sar    $0x1f,%ecx
  80186b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80186e:	eb 16                	jmp    801886 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801870:	8b 45 14             	mov    0x14(%ebp),%eax
  801873:	8d 50 04             	lea    0x4(%eax),%edx
  801876:	89 55 14             	mov    %edx,0x14(%ebp)
  801879:	8b 00                	mov    (%eax),%eax
  80187b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80187e:	89 c1                	mov    %eax,%ecx
  801880:	c1 f9 1f             	sar    $0x1f,%ecx
  801883:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801886:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801889:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80188c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801891:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801895:	79 74                	jns    80190b <vprintfmt+0x356>
				putch('-', putdat);
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	53                   	push   %ebx
  80189b:	6a 2d                	push   $0x2d
  80189d:	ff d6                	call   *%esi
				num = -(long long) num;
  80189f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018a5:	f7 d8                	neg    %eax
  8018a7:	83 d2 00             	adc    $0x0,%edx
  8018aa:	f7 da                	neg    %edx
  8018ac:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018af:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018b4:	eb 55                	jmp    80190b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b9:	e8 83 fc ff ff       	call   801541 <getuint>
			base = 10;
  8018be:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018c3:	eb 46                	jmp    80190b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8018c8:	e8 74 fc ff ff       	call   801541 <getuint>
			base = 8;
  8018cd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018d2:	eb 37                	jmp    80190b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	53                   	push   %ebx
  8018d8:	6a 30                	push   $0x30
  8018da:	ff d6                	call   *%esi
			putch('x', putdat);
  8018dc:	83 c4 08             	add    $0x8,%esp
  8018df:	53                   	push   %ebx
  8018e0:	6a 78                	push   $0x78
  8018e2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e7:	8d 50 04             	lea    0x4(%eax),%edx
  8018ea:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018ed:	8b 00                	mov    (%eax),%eax
  8018ef:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018f7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018fc:	eb 0d                	jmp    80190b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018fe:	8d 45 14             	lea    0x14(%ebp),%eax
  801901:	e8 3b fc ff ff       	call   801541 <getuint>
			base = 16;
  801906:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80190b:	83 ec 0c             	sub    $0xc,%esp
  80190e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801912:	57                   	push   %edi
  801913:	ff 75 e0             	pushl  -0x20(%ebp)
  801916:	51                   	push   %ecx
  801917:	52                   	push   %edx
  801918:	50                   	push   %eax
  801919:	89 da                	mov    %ebx,%edx
  80191b:	89 f0                	mov    %esi,%eax
  80191d:	e8 70 fb ff ff       	call   801492 <printnum>
			break;
  801922:	83 c4 20             	add    $0x20,%esp
  801925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801928:	e9 ae fc ff ff       	jmp    8015db <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	53                   	push   %ebx
  801931:	51                   	push   %ecx
  801932:	ff d6                	call   *%esi
			break;
  801934:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801937:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80193a:	e9 9c fc ff ff       	jmp    8015db <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80193f:	83 ec 08             	sub    $0x8,%esp
  801942:	53                   	push   %ebx
  801943:	6a 25                	push   $0x25
  801945:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	eb 03                	jmp    80194f <vprintfmt+0x39a>
  80194c:	83 ef 01             	sub    $0x1,%edi
  80194f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801953:	75 f7                	jne    80194c <vprintfmt+0x397>
  801955:	e9 81 fc ff ff       	jmp    8015db <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80195a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5f                   	pop    %edi
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 18             	sub    $0x18,%esp
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
  80196b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80196e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801971:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801975:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801978:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80197f:	85 c0                	test   %eax,%eax
  801981:	74 26                	je     8019a9 <vsnprintf+0x47>
  801983:	85 d2                	test   %edx,%edx
  801985:	7e 22                	jle    8019a9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801987:	ff 75 14             	pushl  0x14(%ebp)
  80198a:	ff 75 10             	pushl  0x10(%ebp)
  80198d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801990:	50                   	push   %eax
  801991:	68 7b 15 80 00       	push   $0x80157b
  801996:	e8 1a fc ff ff       	call   8015b5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80199b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80199e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	eb 05                	jmp    8019ae <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019b9:	50                   	push   %eax
  8019ba:	ff 75 10             	pushl  0x10(%ebp)
  8019bd:	ff 75 0c             	pushl  0xc(%ebp)
  8019c0:	ff 75 08             	pushl  0x8(%ebp)
  8019c3:	e8 9a ff ff ff       	call   801962 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d5:	eb 03                	jmp    8019da <strlen+0x10>
		n++;
  8019d7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019da:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019de:	75 f7                	jne    8019d7 <strlen+0xd>
		n++;
	return n;
}
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f0:	eb 03                	jmp    8019f5 <strnlen+0x13>
		n++;
  8019f2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019f5:	39 c2                	cmp    %eax,%edx
  8019f7:	74 08                	je     801a01 <strnlen+0x1f>
  8019f9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019fd:	75 f3                	jne    8019f2 <strnlen+0x10>
  8019ff:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	53                   	push   %ebx
  801a07:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a0d:	89 c2                	mov    %eax,%edx
  801a0f:	83 c2 01             	add    $0x1,%edx
  801a12:	83 c1 01             	add    $0x1,%ecx
  801a15:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a19:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a1c:	84 db                	test   %bl,%bl
  801a1e:	75 ef                	jne    801a0f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a20:	5b                   	pop    %ebx
  801a21:	5d                   	pop    %ebp
  801a22:	c3                   	ret    

00801a23 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a23:	55                   	push   %ebp
  801a24:	89 e5                	mov    %esp,%ebp
  801a26:	53                   	push   %ebx
  801a27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a2a:	53                   	push   %ebx
  801a2b:	e8 9a ff ff ff       	call   8019ca <strlen>
  801a30:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a33:	ff 75 0c             	pushl  0xc(%ebp)
  801a36:	01 d8                	add    %ebx,%eax
  801a38:	50                   	push   %eax
  801a39:	e8 c5 ff ff ff       	call   801a03 <strcpy>
	return dst;
}
  801a3e:	89 d8                	mov    %ebx,%eax
  801a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	56                   	push   %esi
  801a49:	53                   	push   %ebx
  801a4a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a50:	89 f3                	mov    %esi,%ebx
  801a52:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a55:	89 f2                	mov    %esi,%edx
  801a57:	eb 0f                	jmp    801a68 <strncpy+0x23>
		*dst++ = *src;
  801a59:	83 c2 01             	add    $0x1,%edx
  801a5c:	0f b6 01             	movzbl (%ecx),%eax
  801a5f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a62:	80 39 01             	cmpb   $0x1,(%ecx)
  801a65:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a68:	39 da                	cmp    %ebx,%edx
  801a6a:	75 ed                	jne    801a59 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a6c:	89 f0                	mov    %esi,%eax
  801a6e:	5b                   	pop    %ebx
  801a6f:	5e                   	pop    %esi
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    

00801a72 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	56                   	push   %esi
  801a76:	53                   	push   %ebx
  801a77:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7d:	8b 55 10             	mov    0x10(%ebp),%edx
  801a80:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a82:	85 d2                	test   %edx,%edx
  801a84:	74 21                	je     801aa7 <strlcpy+0x35>
  801a86:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a8a:	89 f2                	mov    %esi,%edx
  801a8c:	eb 09                	jmp    801a97 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a8e:	83 c2 01             	add    $0x1,%edx
  801a91:	83 c1 01             	add    $0x1,%ecx
  801a94:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a97:	39 c2                	cmp    %eax,%edx
  801a99:	74 09                	je     801aa4 <strlcpy+0x32>
  801a9b:	0f b6 19             	movzbl (%ecx),%ebx
  801a9e:	84 db                	test   %bl,%bl
  801aa0:	75 ec                	jne    801a8e <strlcpy+0x1c>
  801aa2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801aa4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801aa7:	29 f0                	sub    %esi,%eax
}
  801aa9:	5b                   	pop    %ebx
  801aaa:	5e                   	pop    %esi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ab6:	eb 06                	jmp    801abe <strcmp+0x11>
		p++, q++;
  801ab8:	83 c1 01             	add    $0x1,%ecx
  801abb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801abe:	0f b6 01             	movzbl (%ecx),%eax
  801ac1:	84 c0                	test   %al,%al
  801ac3:	74 04                	je     801ac9 <strcmp+0x1c>
  801ac5:	3a 02                	cmp    (%edx),%al
  801ac7:	74 ef                	je     801ab8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ac9:	0f b6 c0             	movzbl %al,%eax
  801acc:	0f b6 12             	movzbl (%edx),%edx
  801acf:	29 d0                	sub    %edx,%eax
}
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	53                   	push   %ebx
  801ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ada:	8b 55 0c             	mov    0xc(%ebp),%edx
  801add:	89 c3                	mov    %eax,%ebx
  801adf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ae2:	eb 06                	jmp    801aea <strncmp+0x17>
		n--, p++, q++;
  801ae4:	83 c0 01             	add    $0x1,%eax
  801ae7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801aea:	39 d8                	cmp    %ebx,%eax
  801aec:	74 15                	je     801b03 <strncmp+0x30>
  801aee:	0f b6 08             	movzbl (%eax),%ecx
  801af1:	84 c9                	test   %cl,%cl
  801af3:	74 04                	je     801af9 <strncmp+0x26>
  801af5:	3a 0a                	cmp    (%edx),%cl
  801af7:	74 eb                	je     801ae4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801af9:	0f b6 00             	movzbl (%eax),%eax
  801afc:	0f b6 12             	movzbl (%edx),%edx
  801aff:	29 d0                	sub    %edx,%eax
  801b01:	eb 05                	jmp    801b08 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b03:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b08:	5b                   	pop    %ebx
  801b09:	5d                   	pop    %ebp
  801b0a:	c3                   	ret    

00801b0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b15:	eb 07                	jmp    801b1e <strchr+0x13>
		if (*s == c)
  801b17:	38 ca                	cmp    %cl,%dl
  801b19:	74 0f                	je     801b2a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b1b:	83 c0 01             	add    $0x1,%eax
  801b1e:	0f b6 10             	movzbl (%eax),%edx
  801b21:	84 d2                	test   %dl,%dl
  801b23:	75 f2                	jne    801b17 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    

00801b2c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b36:	eb 03                	jmp    801b3b <strfind+0xf>
  801b38:	83 c0 01             	add    $0x1,%eax
  801b3b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b3e:	38 ca                	cmp    %cl,%dl
  801b40:	74 04                	je     801b46 <strfind+0x1a>
  801b42:	84 d2                	test   %dl,%dl
  801b44:	75 f2                	jne    801b38 <strfind+0xc>
			break;
	return (char *) s;
}
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	57                   	push   %edi
  801b4c:	56                   	push   %esi
  801b4d:	53                   	push   %ebx
  801b4e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b54:	85 c9                	test   %ecx,%ecx
  801b56:	74 36                	je     801b8e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b58:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b5e:	75 28                	jne    801b88 <memset+0x40>
  801b60:	f6 c1 03             	test   $0x3,%cl
  801b63:	75 23                	jne    801b88 <memset+0x40>
		c &= 0xFF;
  801b65:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b69:	89 d3                	mov    %edx,%ebx
  801b6b:	c1 e3 08             	shl    $0x8,%ebx
  801b6e:	89 d6                	mov    %edx,%esi
  801b70:	c1 e6 18             	shl    $0x18,%esi
  801b73:	89 d0                	mov    %edx,%eax
  801b75:	c1 e0 10             	shl    $0x10,%eax
  801b78:	09 f0                	or     %esi,%eax
  801b7a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b7c:	89 d8                	mov    %ebx,%eax
  801b7e:	09 d0                	or     %edx,%eax
  801b80:	c1 e9 02             	shr    $0x2,%ecx
  801b83:	fc                   	cld    
  801b84:	f3 ab                	rep stos %eax,%es:(%edi)
  801b86:	eb 06                	jmp    801b8e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8b:	fc                   	cld    
  801b8c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b8e:	89 f8                	mov    %edi,%eax
  801b90:	5b                   	pop    %ebx
  801b91:	5e                   	pop    %esi
  801b92:	5f                   	pop    %edi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	57                   	push   %edi
  801b99:	56                   	push   %esi
  801b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ba0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ba3:	39 c6                	cmp    %eax,%esi
  801ba5:	73 35                	jae    801bdc <memmove+0x47>
  801ba7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801baa:	39 d0                	cmp    %edx,%eax
  801bac:	73 2e                	jae    801bdc <memmove+0x47>
		s += n;
		d += n;
  801bae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bb1:	89 d6                	mov    %edx,%esi
  801bb3:	09 fe                	or     %edi,%esi
  801bb5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bbb:	75 13                	jne    801bd0 <memmove+0x3b>
  801bbd:	f6 c1 03             	test   $0x3,%cl
  801bc0:	75 0e                	jne    801bd0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bc2:	83 ef 04             	sub    $0x4,%edi
  801bc5:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bc8:	c1 e9 02             	shr    $0x2,%ecx
  801bcb:	fd                   	std    
  801bcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bce:	eb 09                	jmp    801bd9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bd0:	83 ef 01             	sub    $0x1,%edi
  801bd3:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bd6:	fd                   	std    
  801bd7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bd9:	fc                   	cld    
  801bda:	eb 1d                	jmp    801bf9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bdc:	89 f2                	mov    %esi,%edx
  801bde:	09 c2                	or     %eax,%edx
  801be0:	f6 c2 03             	test   $0x3,%dl
  801be3:	75 0f                	jne    801bf4 <memmove+0x5f>
  801be5:	f6 c1 03             	test   $0x3,%cl
  801be8:	75 0a                	jne    801bf4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bea:	c1 e9 02             	shr    $0x2,%ecx
  801bed:	89 c7                	mov    %eax,%edi
  801bef:	fc                   	cld    
  801bf0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bf2:	eb 05                	jmp    801bf9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bf4:	89 c7                	mov    %eax,%edi
  801bf6:	fc                   	cld    
  801bf7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801bf9:	5e                   	pop    %esi
  801bfa:	5f                   	pop    %edi
  801bfb:	5d                   	pop    %ebp
  801bfc:	c3                   	ret    

00801bfd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c00:	ff 75 10             	pushl  0x10(%ebp)
  801c03:	ff 75 0c             	pushl  0xc(%ebp)
  801c06:	ff 75 08             	pushl  0x8(%ebp)
  801c09:	e8 87 ff ff ff       	call   801b95 <memmove>
}
  801c0e:	c9                   	leave  
  801c0f:	c3                   	ret    

00801c10 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	56                   	push   %esi
  801c14:	53                   	push   %ebx
  801c15:	8b 45 08             	mov    0x8(%ebp),%eax
  801c18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1b:	89 c6                	mov    %eax,%esi
  801c1d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c20:	eb 1a                	jmp    801c3c <memcmp+0x2c>
		if (*s1 != *s2)
  801c22:	0f b6 08             	movzbl (%eax),%ecx
  801c25:	0f b6 1a             	movzbl (%edx),%ebx
  801c28:	38 d9                	cmp    %bl,%cl
  801c2a:	74 0a                	je     801c36 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c2c:	0f b6 c1             	movzbl %cl,%eax
  801c2f:	0f b6 db             	movzbl %bl,%ebx
  801c32:	29 d8                	sub    %ebx,%eax
  801c34:	eb 0f                	jmp    801c45 <memcmp+0x35>
		s1++, s2++;
  801c36:	83 c0 01             	add    $0x1,%eax
  801c39:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c3c:	39 f0                	cmp    %esi,%eax
  801c3e:	75 e2                	jne    801c22 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c45:	5b                   	pop    %ebx
  801c46:	5e                   	pop    %esi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    

00801c49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c49:	55                   	push   %ebp
  801c4a:	89 e5                	mov    %esp,%ebp
  801c4c:	53                   	push   %ebx
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c50:	89 c1                	mov    %eax,%ecx
  801c52:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c55:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c59:	eb 0a                	jmp    801c65 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c5b:	0f b6 10             	movzbl (%eax),%edx
  801c5e:	39 da                	cmp    %ebx,%edx
  801c60:	74 07                	je     801c69 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c62:	83 c0 01             	add    $0x1,%eax
  801c65:	39 c8                	cmp    %ecx,%eax
  801c67:	72 f2                	jb     801c5b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c69:	5b                   	pop    %ebx
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    

00801c6c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	57                   	push   %edi
  801c70:	56                   	push   %esi
  801c71:	53                   	push   %ebx
  801c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c78:	eb 03                	jmp    801c7d <strtol+0x11>
		s++;
  801c7a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c7d:	0f b6 01             	movzbl (%ecx),%eax
  801c80:	3c 20                	cmp    $0x20,%al
  801c82:	74 f6                	je     801c7a <strtol+0xe>
  801c84:	3c 09                	cmp    $0x9,%al
  801c86:	74 f2                	je     801c7a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c88:	3c 2b                	cmp    $0x2b,%al
  801c8a:	75 0a                	jne    801c96 <strtol+0x2a>
		s++;
  801c8c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c8f:	bf 00 00 00 00       	mov    $0x0,%edi
  801c94:	eb 11                	jmp    801ca7 <strtol+0x3b>
  801c96:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c9b:	3c 2d                	cmp    $0x2d,%al
  801c9d:	75 08                	jne    801ca7 <strtol+0x3b>
		s++, neg = 1;
  801c9f:	83 c1 01             	add    $0x1,%ecx
  801ca2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ca7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cad:	75 15                	jne    801cc4 <strtol+0x58>
  801caf:	80 39 30             	cmpb   $0x30,(%ecx)
  801cb2:	75 10                	jne    801cc4 <strtol+0x58>
  801cb4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cb8:	75 7c                	jne    801d36 <strtol+0xca>
		s += 2, base = 16;
  801cba:	83 c1 02             	add    $0x2,%ecx
  801cbd:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cc2:	eb 16                	jmp    801cda <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cc4:	85 db                	test   %ebx,%ebx
  801cc6:	75 12                	jne    801cda <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cc8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ccd:	80 39 30             	cmpb   $0x30,(%ecx)
  801cd0:	75 08                	jne    801cda <strtol+0x6e>
		s++, base = 8;
  801cd2:	83 c1 01             	add    $0x1,%ecx
  801cd5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cda:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ce2:	0f b6 11             	movzbl (%ecx),%edx
  801ce5:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ce8:	89 f3                	mov    %esi,%ebx
  801cea:	80 fb 09             	cmp    $0x9,%bl
  801ced:	77 08                	ja     801cf7 <strtol+0x8b>
			dig = *s - '0';
  801cef:	0f be d2             	movsbl %dl,%edx
  801cf2:	83 ea 30             	sub    $0x30,%edx
  801cf5:	eb 22                	jmp    801d19 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801cf7:	8d 72 9f             	lea    -0x61(%edx),%esi
  801cfa:	89 f3                	mov    %esi,%ebx
  801cfc:	80 fb 19             	cmp    $0x19,%bl
  801cff:	77 08                	ja     801d09 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d01:	0f be d2             	movsbl %dl,%edx
  801d04:	83 ea 57             	sub    $0x57,%edx
  801d07:	eb 10                	jmp    801d19 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d09:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d0c:	89 f3                	mov    %esi,%ebx
  801d0e:	80 fb 19             	cmp    $0x19,%bl
  801d11:	77 16                	ja     801d29 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d13:	0f be d2             	movsbl %dl,%edx
  801d16:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d19:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d1c:	7d 0b                	jge    801d29 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d1e:	83 c1 01             	add    $0x1,%ecx
  801d21:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d25:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d27:	eb b9                	jmp    801ce2 <strtol+0x76>

	if (endptr)
  801d29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d2d:	74 0d                	je     801d3c <strtol+0xd0>
		*endptr = (char *) s;
  801d2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d32:	89 0e                	mov    %ecx,(%esi)
  801d34:	eb 06                	jmp    801d3c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d36:	85 db                	test   %ebx,%ebx
  801d38:	74 98                	je     801cd2 <strtol+0x66>
  801d3a:	eb 9e                	jmp    801cda <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d3c:	89 c2                	mov    %eax,%edx
  801d3e:	f7 da                	neg    %edx
  801d40:	85 ff                	test   %edi,%edi
  801d42:	0f 45 c2             	cmovne %edx,%eax
}
  801d45:	5b                   	pop    %ebx
  801d46:	5e                   	pop    %esi
  801d47:	5f                   	pop    %edi
  801d48:	5d                   	pop    %ebp
  801d49:	c3                   	ret    

00801d4a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d50:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d57:	75 2a                	jne    801d83 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d59:	83 ec 04             	sub    $0x4,%esp
  801d5c:	6a 07                	push   $0x7
  801d5e:	68 00 f0 bf ee       	push   $0xeebff000
  801d63:	6a 00                	push   $0x0
  801d65:	e8 23 e4 ff ff       	call   80018d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	79 12                	jns    801d83 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d71:	50                   	push   %eax
  801d72:	68 c0 26 80 00       	push   $0x8026c0
  801d77:	6a 23                	push   $0x23
  801d79:	68 c4 26 80 00       	push   $0x8026c4
  801d7e:	e8 22 f6 ff ff       	call   8013a5 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d83:	8b 45 08             	mov    0x8(%ebp),%eax
  801d86:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d8b:	83 ec 08             	sub    $0x8,%esp
  801d8e:	68 b5 1d 80 00       	push   $0x801db5
  801d93:	6a 00                	push   $0x0
  801d95:	e8 3e e5 ff ff       	call   8002d8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	79 12                	jns    801db3 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801da1:	50                   	push   %eax
  801da2:	68 c0 26 80 00       	push   $0x8026c0
  801da7:	6a 2c                	push   $0x2c
  801da9:	68 c4 26 80 00       	push   $0x8026c4
  801dae:	e8 f2 f5 ff ff       	call   8013a5 <_panic>
	}
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801db5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801db6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dbb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dbd:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dc0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dc4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dc9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dcd:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dcf:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dd2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dd3:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dd6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dd7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dd8:	c3                   	ret    

00801dd9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	56                   	push   %esi
  801ddd:	53                   	push   %ebx
  801dde:	8b 75 08             	mov    0x8(%ebp),%esi
  801de1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801de7:	85 c0                	test   %eax,%eax
  801de9:	75 12                	jne    801dfd <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801deb:	83 ec 0c             	sub    $0xc,%esp
  801dee:	68 00 00 c0 ee       	push   $0xeec00000
  801df3:	e8 45 e5 ff ff       	call   80033d <sys_ipc_recv>
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	eb 0c                	jmp    801e09 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801dfd:	83 ec 0c             	sub    $0xc,%esp
  801e00:	50                   	push   %eax
  801e01:	e8 37 e5 ff ff       	call   80033d <sys_ipc_recv>
  801e06:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e09:	85 f6                	test   %esi,%esi
  801e0b:	0f 95 c1             	setne  %cl
  801e0e:	85 db                	test   %ebx,%ebx
  801e10:	0f 95 c2             	setne  %dl
  801e13:	84 d1                	test   %dl,%cl
  801e15:	74 09                	je     801e20 <ipc_recv+0x47>
  801e17:	89 c2                	mov    %eax,%edx
  801e19:	c1 ea 1f             	shr    $0x1f,%edx
  801e1c:	84 d2                	test   %dl,%dl
  801e1e:	75 2d                	jne    801e4d <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e20:	85 f6                	test   %esi,%esi
  801e22:	74 0d                	je     801e31 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e24:	a1 04 40 80 00       	mov    0x804004,%eax
  801e29:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e2f:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e31:	85 db                	test   %ebx,%ebx
  801e33:	74 0d                	je     801e42 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e35:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e40:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e42:	a1 04 40 80 00       	mov    0x804004,%eax
  801e47:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	57                   	push   %edi
  801e58:	56                   	push   %esi
  801e59:	53                   	push   %ebx
  801e5a:	83 ec 0c             	sub    $0xc,%esp
  801e5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e60:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e66:	85 db                	test   %ebx,%ebx
  801e68:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e6d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e70:	ff 75 14             	pushl  0x14(%ebp)
  801e73:	53                   	push   %ebx
  801e74:	56                   	push   %esi
  801e75:	57                   	push   %edi
  801e76:	e8 9f e4 ff ff       	call   80031a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e7b:	89 c2                	mov    %eax,%edx
  801e7d:	c1 ea 1f             	shr    $0x1f,%edx
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	84 d2                	test   %dl,%dl
  801e85:	74 17                	je     801e9e <ipc_send+0x4a>
  801e87:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e8a:	74 12                	je     801e9e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e8c:	50                   	push   %eax
  801e8d:	68 d2 26 80 00       	push   $0x8026d2
  801e92:	6a 47                	push   $0x47
  801e94:	68 e0 26 80 00       	push   $0x8026e0
  801e99:	e8 07 f5 ff ff       	call   8013a5 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e9e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ea1:	75 07                	jne    801eaa <ipc_send+0x56>
			sys_yield();
  801ea3:	e8 c6 e2 ff ff       	call   80016e <sys_yield>
  801ea8:	eb c6                	jmp    801e70 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	75 c2                	jne    801e70 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5f                   	pop    %edi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    

00801eb6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ebc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ec1:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ec7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ecd:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ed3:	39 ca                	cmp    %ecx,%edx
  801ed5:	75 10                	jne    801ee7 <ipc_find_env+0x31>
			return envs[i].env_id;
  801ed7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801edd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ee2:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ee5:	eb 0f                	jmp    801ef6 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee7:	83 c0 01             	add    $0x1,%eax
  801eea:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eef:	75 d0                	jne    801ec1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ef1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801efe:	89 d0                	mov    %edx,%eax
  801f00:	c1 e8 16             	shr    $0x16,%eax
  801f03:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f0a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f0f:	f6 c1 01             	test   $0x1,%cl
  801f12:	74 1d                	je     801f31 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f14:	c1 ea 0c             	shr    $0xc,%edx
  801f17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f1e:	f6 c2 01             	test   $0x1,%dl
  801f21:	74 0e                	je     801f31 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f23:	c1 ea 0c             	shr    $0xc,%edx
  801f26:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f2d:	ef 
  801f2e:	0f b7 c0             	movzwl %ax,%eax
}
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    
  801f33:	66 90                	xchg   %ax,%ax
  801f35:	66 90                	xchg   %ax,%ax
  801f37:	66 90                	xchg   %ax,%ax
  801f39:	66 90                	xchg   %ax,%ax
  801f3b:	66 90                	xchg   %ax,%ax
  801f3d:	66 90                	xchg   %ax,%ax
  801f3f:	90                   	nop

00801f40 <__udivdi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 1c             	sub    $0x1c,%esp
  801f47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f57:	85 f6                	test   %esi,%esi
  801f59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5d:	89 ca                	mov    %ecx,%edx
  801f5f:	89 f8                	mov    %edi,%eax
  801f61:	75 3d                	jne    801fa0 <__udivdi3+0x60>
  801f63:	39 cf                	cmp    %ecx,%edi
  801f65:	0f 87 c5 00 00 00    	ja     802030 <__udivdi3+0xf0>
  801f6b:	85 ff                	test   %edi,%edi
  801f6d:	89 fd                	mov    %edi,%ebp
  801f6f:	75 0b                	jne    801f7c <__udivdi3+0x3c>
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
  801f76:	31 d2                	xor    %edx,%edx
  801f78:	f7 f7                	div    %edi
  801f7a:	89 c5                	mov    %eax,%ebp
  801f7c:	89 c8                	mov    %ecx,%eax
  801f7e:	31 d2                	xor    %edx,%edx
  801f80:	f7 f5                	div    %ebp
  801f82:	89 c1                	mov    %eax,%ecx
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	89 cf                	mov    %ecx,%edi
  801f88:	f7 f5                	div    %ebp
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	39 ce                	cmp    %ecx,%esi
  801fa2:	77 74                	ja     802018 <__udivdi3+0xd8>
  801fa4:	0f bd fe             	bsr    %esi,%edi
  801fa7:	83 f7 1f             	xor    $0x1f,%edi
  801faa:	0f 84 98 00 00 00    	je     802048 <__udivdi3+0x108>
  801fb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	89 c5                	mov    %eax,%ebp
  801fb9:	29 fb                	sub    %edi,%ebx
  801fbb:	d3 e6                	shl    %cl,%esi
  801fbd:	89 d9                	mov    %ebx,%ecx
  801fbf:	d3 ed                	shr    %cl,%ebp
  801fc1:	89 f9                	mov    %edi,%ecx
  801fc3:	d3 e0                	shl    %cl,%eax
  801fc5:	09 ee                	or     %ebp,%esi
  801fc7:	89 d9                	mov    %ebx,%ecx
  801fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcd:	89 d5                	mov    %edx,%ebp
  801fcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fd3:	d3 ed                	shr    %cl,%ebp
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e2                	shl    %cl,%edx
  801fd9:	89 d9                	mov    %ebx,%ecx
  801fdb:	d3 e8                	shr    %cl,%eax
  801fdd:	09 c2                	or     %eax,%edx
  801fdf:	89 d0                	mov    %edx,%eax
  801fe1:	89 ea                	mov    %ebp,%edx
  801fe3:	f7 f6                	div    %esi
  801fe5:	89 d5                	mov    %edx,%ebp
  801fe7:	89 c3                	mov    %eax,%ebx
  801fe9:	f7 64 24 0c          	mull   0xc(%esp)
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	72 10                	jb     802001 <__udivdi3+0xc1>
  801ff1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e6                	shl    %cl,%esi
  801ff9:	39 c6                	cmp    %eax,%esi
  801ffb:	73 07                	jae    802004 <__udivdi3+0xc4>
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	75 03                	jne    802004 <__udivdi3+0xc4>
  802001:	83 eb 01             	sub    $0x1,%ebx
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 d8                	mov    %ebx,%eax
  802008:	89 fa                	mov    %edi,%edx
  80200a:	83 c4 1c             	add    $0x1c,%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802018:	31 ff                	xor    %edi,%edi
  80201a:	31 db                	xor    %ebx,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 d8                	mov    %ebx,%eax
  802032:	f7 f7                	div    %edi
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 c3                	mov    %eax,%ebx
  802038:	89 d8                	mov    %ebx,%eax
  80203a:	89 fa                	mov    %edi,%edx
  80203c:	83 c4 1c             	add    $0x1c,%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	39 ce                	cmp    %ecx,%esi
  80204a:	72 0c                	jb     802058 <__udivdi3+0x118>
  80204c:	31 db                	xor    %ebx,%ebx
  80204e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802052:	0f 87 34 ff ff ff    	ja     801f8c <__udivdi3+0x4c>
  802058:	bb 01 00 00 00       	mov    $0x1,%ebx
  80205d:	e9 2a ff ff ff       	jmp    801f8c <__udivdi3+0x4c>
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80207b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80207f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 d2                	test   %edx,%edx
  802089:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80208d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802091:	89 f3                	mov    %esi,%ebx
  802093:	89 3c 24             	mov    %edi,(%esp)
  802096:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209a:	75 1c                	jne    8020b8 <__umoddi3+0x48>
  80209c:	39 f7                	cmp    %esi,%edi
  80209e:	76 50                	jbe    8020f0 <__umoddi3+0x80>
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	f7 f7                	div    %edi
  8020a6:	89 d0                	mov    %edx,%eax
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	39 f2                	cmp    %esi,%edx
  8020ba:	89 d0                	mov    %edx,%eax
  8020bc:	77 52                	ja     802110 <__umoddi3+0xa0>
  8020be:	0f bd ea             	bsr    %edx,%ebp
  8020c1:	83 f5 1f             	xor    $0x1f,%ebp
  8020c4:	75 5a                	jne    802120 <__umoddi3+0xb0>
  8020c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ca:	0f 82 e0 00 00 00    	jb     8021b0 <__umoddi3+0x140>
  8020d0:	39 0c 24             	cmp    %ecx,(%esp)
  8020d3:	0f 86 d7 00 00 00    	jbe    8021b0 <__umoddi3+0x140>
  8020d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020e1:	83 c4 1c             	add    $0x1c,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	85 ff                	test   %edi,%edi
  8020f2:	89 fd                	mov    %edi,%ebp
  8020f4:	75 0b                	jne    802101 <__umoddi3+0x91>
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f7                	div    %edi
  8020ff:	89 c5                	mov    %eax,%ebp
  802101:	89 f0                	mov    %esi,%eax
  802103:	31 d2                	xor    %edx,%edx
  802105:	f7 f5                	div    %ebp
  802107:	89 c8                	mov    %ecx,%eax
  802109:	f7 f5                	div    %ebp
  80210b:	89 d0                	mov    %edx,%eax
  80210d:	eb 99                	jmp    8020a8 <__umoddi3+0x38>
  80210f:	90                   	nop
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	8b 34 24             	mov    (%esp),%esi
  802123:	bf 20 00 00 00       	mov    $0x20,%edi
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	29 ef                	sub    %ebp,%edi
  80212c:	d3 e0                	shl    %cl,%eax
  80212e:	89 f9                	mov    %edi,%ecx
  802130:	89 f2                	mov    %esi,%edx
  802132:	d3 ea                	shr    %cl,%edx
  802134:	89 e9                	mov    %ebp,%ecx
  802136:	09 c2                	or     %eax,%edx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 14 24             	mov    %edx,(%esp)
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	d3 e2                	shl    %cl,%edx
  802141:	89 f9                	mov    %edi,%ecx
  802143:	89 54 24 04          	mov    %edx,0x4(%esp)
  802147:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	89 e9                	mov    %ebp,%ecx
  80214f:	89 c6                	mov    %eax,%esi
  802151:	d3 e3                	shl    %cl,%ebx
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 d0                	mov    %edx,%eax
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	09 d8                	or     %ebx,%eax
  80215d:	89 d3                	mov    %edx,%ebx
  80215f:	89 f2                	mov    %esi,%edx
  802161:	f7 34 24             	divl   (%esp)
  802164:	89 d6                	mov    %edx,%esi
  802166:	d3 e3                	shl    %cl,%ebx
  802168:	f7 64 24 04          	mull   0x4(%esp)
  80216c:	39 d6                	cmp    %edx,%esi
  80216e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802172:	89 d1                	mov    %edx,%ecx
  802174:	89 c3                	mov    %eax,%ebx
  802176:	72 08                	jb     802180 <__umoddi3+0x110>
  802178:	75 11                	jne    80218b <__umoddi3+0x11b>
  80217a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80217e:	73 0b                	jae    80218b <__umoddi3+0x11b>
  802180:	2b 44 24 04          	sub    0x4(%esp),%eax
  802184:	1b 14 24             	sbb    (%esp),%edx
  802187:	89 d1                	mov    %edx,%ecx
  802189:	89 c3                	mov    %eax,%ebx
  80218b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80218f:	29 da                	sub    %ebx,%edx
  802191:	19 ce                	sbb    %ecx,%esi
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 f0                	mov    %esi,%eax
  802197:	d3 e0                	shl    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	d3 ea                	shr    %cl,%edx
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	d3 ee                	shr    %cl,%esi
  8021a1:	09 d0                	or     %edx,%eax
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	83 c4 1c             	add    $0x1c,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	29 f9                	sub    %edi,%ecx
  8021b2:	19 d6                	sbb    %edx,%esi
  8021b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bc:	e9 18 ff ff ff       	jmp    8020d9 <__umoddi3+0x69>
