
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
  8000bd:	e8 66 0a 00 00       	call   800b28 <close_all>
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
  800136:	68 98 24 80 00       	push   $0x802498
  80013b:	6a 23                	push   $0x23
  80013d:	68 b5 24 80 00       	push   $0x8024b5
  800142:	e8 12 15 00 00       	call   801659 <_panic>

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
  8001b7:	68 98 24 80 00       	push   $0x802498
  8001bc:	6a 23                	push   $0x23
  8001be:	68 b5 24 80 00       	push   $0x8024b5
  8001c3:	e8 91 14 00 00       	call   801659 <_panic>

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
  8001f9:	68 98 24 80 00       	push   $0x802498
  8001fe:	6a 23                	push   $0x23
  800200:	68 b5 24 80 00       	push   $0x8024b5
  800205:	e8 4f 14 00 00       	call   801659 <_panic>

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
  80023b:	68 98 24 80 00       	push   $0x802498
  800240:	6a 23                	push   $0x23
  800242:	68 b5 24 80 00       	push   $0x8024b5
  800247:	e8 0d 14 00 00       	call   801659 <_panic>

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
  80027d:	68 98 24 80 00       	push   $0x802498
  800282:	6a 23                	push   $0x23
  800284:	68 b5 24 80 00       	push   $0x8024b5
  800289:	e8 cb 13 00 00       	call   801659 <_panic>

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
  8002bf:	68 98 24 80 00       	push   $0x802498
  8002c4:	6a 23                	push   $0x23
  8002c6:	68 b5 24 80 00       	push   $0x8024b5
  8002cb:	e8 89 13 00 00       	call   801659 <_panic>
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
  800301:	68 98 24 80 00       	push   $0x802498
  800306:	6a 23                	push   $0x23
  800308:	68 b5 24 80 00       	push   $0x8024b5
  80030d:	e8 47 13 00 00       	call   801659 <_panic>

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
  800365:	68 98 24 80 00       	push   $0x802498
  80036a:	6a 23                	push   $0x23
  80036c:	68 b5 24 80 00       	push   $0x8024b5
  800371:	e8 e3 12 00 00       	call   801659 <_panic>

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
  800404:	68 c3 24 80 00       	push   $0x8024c3
  800409:	6a 1f                	push   $0x1f
  80040b:	68 d3 24 80 00       	push   $0x8024d3
  800410:	e8 44 12 00 00       	call   801659 <_panic>
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
  80042e:	68 de 24 80 00       	push   $0x8024de
  800433:	6a 2d                	push   $0x2d
  800435:	68 d3 24 80 00       	push   $0x8024d3
  80043a:	e8 1a 12 00 00       	call   801659 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80043f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800445:	83 ec 04             	sub    $0x4,%esp
  800448:	68 00 10 00 00       	push   $0x1000
  80044d:	53                   	push   %ebx
  80044e:	68 00 f0 7f 00       	push   $0x7ff000
  800453:	e8 59 1a 00 00       	call   801eb1 <memcpy>

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
  800476:	68 de 24 80 00       	push   $0x8024de
  80047b:	6a 34                	push   $0x34
  80047d:	68 d3 24 80 00       	push   $0x8024d3
  800482:	e8 d2 11 00 00       	call   801659 <_panic>
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
  80049e:	68 de 24 80 00       	push   $0x8024de
  8004a3:	6a 38                	push   $0x38
  8004a5:	68 d3 24 80 00       	push   $0x8024d3
  8004aa:	e8 aa 11 00 00       	call   801659 <_panic>
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
  8004c2:	e8 37 1b 00 00       	call   801ffe <set_pgfault_handler>
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
  8004db:	68 f7 24 80 00       	push   $0x8024f7
  8004e0:	68 85 00 00 00       	push   $0x85
  8004e5:	68 d3 24 80 00       	push   $0x8024d3
  8004ea:	e8 6a 11 00 00       	call   801659 <_panic>
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
  800597:	68 05 25 80 00       	push   $0x802505
  80059c:	6a 55                	push   $0x55
  80059e:	68 d3 24 80 00       	push   $0x8024d3
  8005a3:	e8 b1 10 00 00       	call   801659 <_panic>
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
  8005dc:	68 05 25 80 00       	push   $0x802505
  8005e1:	6a 5c                	push   $0x5c
  8005e3:	68 d3 24 80 00       	push   $0x8024d3
  8005e8:	e8 6c 10 00 00       	call   801659 <_panic>
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
  80060a:	68 05 25 80 00       	push   $0x802505
  80060f:	6a 60                	push   $0x60
  800611:	68 d3 24 80 00       	push   $0x8024d3
  800616:	e8 3e 10 00 00       	call   801659 <_panic>
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
  800634:	68 05 25 80 00       	push   $0x802505
  800639:	6a 65                	push   $0x65
  80063b:	68 d3 24 80 00       	push   $0x8024d3
  800640:	e8 14 10 00 00       	call   801659 <_panic>
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
  8006a3:	68 98 25 80 00       	push   $0x802598
  8006a8:	e8 85 10 00 00       	call   801732 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006ad:	c7 04 24 97 00 80 00 	movl   $0x800097,(%esp)
  8006b4:	e8 c5 fc ff ff       	call   80037e <sys_thread_create>
  8006b9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	68 98 25 80 00       	push   $0x802598
  8006c4:	e8 69 10 00 00       	call   801732 <cprintf>
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

008006f8 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	56                   	push   %esi
  8006fc:	53                   	push   %ebx
  8006fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  800703:	83 ec 04             	sub    $0x4,%esp
  800706:	6a 07                	push   $0x7
  800708:	6a 00                	push   $0x0
  80070a:	56                   	push   %esi
  80070b:	e8 7d fa ff ff       	call   80018d <sys_page_alloc>
	if (r < 0) {
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	85 c0                	test   %eax,%eax
  800715:	79 15                	jns    80072c <queue_append+0x34>
		panic("%e\n", r);
  800717:	50                   	push   %eax
  800718:	68 91 25 80 00       	push   $0x802591
  80071d:	68 c4 00 00 00       	push   $0xc4
  800722:	68 d3 24 80 00       	push   $0x8024d3
  800727:	e8 2d 0f 00 00       	call   801659 <_panic>
	}	
	wt->envid = envid;
  80072c:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  800732:	83 ec 04             	sub    $0x4,%esp
  800735:	ff 33                	pushl  (%ebx)
  800737:	56                   	push   %esi
  800738:	68 bc 25 80 00       	push   $0x8025bc
  80073d:	e8 f0 0f 00 00       	call   801732 <cprintf>
	if (queue->first == NULL) {
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	83 3b 00             	cmpl   $0x0,(%ebx)
  800748:	75 29                	jne    800773 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80074a:	83 ec 0c             	sub    $0xc,%esp
  80074d:	68 1b 25 80 00       	push   $0x80251b
  800752:	e8 db 0f 00 00       	call   801732 <cprintf>
		queue->first = wt;
  800757:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80075d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800764:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80076b:	00 00 00 
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	eb 2b                	jmp    80079e <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  800773:	83 ec 0c             	sub    $0xc,%esp
  800776:	68 35 25 80 00       	push   $0x802535
  80077b:	e8 b2 0f 00 00       	call   801732 <cprintf>
		queue->last->next = wt;
  800780:	8b 43 04             	mov    0x4(%ebx),%eax
  800783:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80078a:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800791:	00 00 00 
		queue->last = wt;
  800794:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80079b:	83 c4 10             	add    $0x10,%esp
	}
}
  80079e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007a1:	5b                   	pop    %ebx
  8007a2:	5e                   	pop    %esi
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	83 ec 04             	sub    $0x4,%esp
  8007ac:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8007af:	8b 02                	mov    (%edx),%eax
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	75 17                	jne    8007cc <queue_pop+0x27>
		panic("queue empty!\n");
  8007b5:	83 ec 04             	sub    $0x4,%esp
  8007b8:	68 53 25 80 00       	push   $0x802553
  8007bd:	68 d8 00 00 00       	push   $0xd8
  8007c2:	68 d3 24 80 00       	push   $0x8024d3
  8007c7:	e8 8d 0e 00 00       	call   801659 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8007cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8007cf:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8007d1:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	53                   	push   %ebx
  8007d7:	68 61 25 80 00       	push   $0x802561
  8007dc:	e8 51 0f 00 00       	call   801732 <cprintf>
	return envid;
}
  8007e1:	89 d8                	mov    %ebx,%eax
  8007e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	83 ec 04             	sub    $0x4,%esp
  8007ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8007f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8007f7:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	74 5a                	je     800858 <mutex_lock+0x70>
  8007fe:	8b 43 04             	mov    0x4(%ebx),%eax
  800801:	83 38 00             	cmpl   $0x0,(%eax)
  800804:	75 52                	jne    800858 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  800806:	83 ec 0c             	sub    $0xc,%esp
  800809:	68 e4 25 80 00       	push   $0x8025e4
  80080e:	e8 1f 0f 00 00       	call   801732 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  800813:	8b 5b 04             	mov    0x4(%ebx),%ebx
  800816:	e8 34 f9 ff ff       	call   80014f <sys_getenvid>
  80081b:	83 c4 08             	add    $0x8,%esp
  80081e:	53                   	push   %ebx
  80081f:	50                   	push   %eax
  800820:	e8 d3 fe ff ff       	call   8006f8 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800825:	e8 25 f9 ff ff       	call   80014f <sys_getenvid>
  80082a:	83 c4 08             	add    $0x8,%esp
  80082d:	6a 04                	push   $0x4
  80082f:	50                   	push   %eax
  800830:	e8 1f fa ff ff       	call   800254 <sys_env_set_status>
		if (r < 0) {
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	85 c0                	test   %eax,%eax
  80083a:	79 15                	jns    800851 <mutex_lock+0x69>
			panic("%e\n", r);
  80083c:	50                   	push   %eax
  80083d:	68 91 25 80 00       	push   $0x802591
  800842:	68 eb 00 00 00       	push   $0xeb
  800847:	68 d3 24 80 00       	push   $0x8024d3
  80084c:	e8 08 0e 00 00       	call   801659 <_panic>
		}
		sys_yield();
  800851:	e8 18 f9 ff ff       	call   80016e <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800856:	eb 18                	jmp    800870 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  800858:	83 ec 0c             	sub    $0xc,%esp
  80085b:	68 04 26 80 00       	push   $0x802604
  800860:	e8 cd 0e 00 00       	call   801732 <cprintf>
	mtx->owner = sys_getenvid();}
  800865:	e8 e5 f8 ff ff       	call   80014f <sys_getenvid>
  80086a:	89 43 08             	mov    %eax,0x8(%ebx)
  80086d:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  800870:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	53                   	push   %ebx
  800879:	83 ec 04             	sub    $0x4,%esp
  80087c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
  800884:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  800887:	8b 43 04             	mov    0x4(%ebx),%eax
  80088a:	83 38 00             	cmpl   $0x0,(%eax)
  80088d:	74 33                	je     8008c2 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80088f:	83 ec 0c             	sub    $0xc,%esp
  800892:	50                   	push   %eax
  800893:	e8 0d ff ff ff       	call   8007a5 <queue_pop>
  800898:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	6a 02                	push   $0x2
  8008a0:	50                   	push   %eax
  8008a1:	e8 ae f9 ff ff       	call   800254 <sys_env_set_status>
		if (r < 0) {
  8008a6:	83 c4 10             	add    $0x10,%esp
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	79 15                	jns    8008c2 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8008ad:	50                   	push   %eax
  8008ae:	68 91 25 80 00       	push   $0x802591
  8008b3:	68 00 01 00 00       	push   $0x100
  8008b8:	68 d3 24 80 00       	push   $0x8024d3
  8008bd:	e8 97 0d 00 00       	call   801659 <_panic>
		}
	}

	asm volatile("pause");
  8008c2:	f3 90                	pause  
	//sys_yield();
}
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	53                   	push   %ebx
  8008cd:	83 ec 04             	sub    $0x4,%esp
  8008d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8008d3:	e8 77 f8 ff ff       	call   80014f <sys_getenvid>
  8008d8:	83 ec 04             	sub    $0x4,%esp
  8008db:	6a 07                	push   $0x7
  8008dd:	53                   	push   %ebx
  8008de:	50                   	push   %eax
  8008df:	e8 a9 f8 ff ff       	call   80018d <sys_page_alloc>
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	85 c0                	test   %eax,%eax
  8008e9:	79 15                	jns    800900 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8008eb:	50                   	push   %eax
  8008ec:	68 7c 25 80 00       	push   $0x80257c
  8008f1:	68 0d 01 00 00       	push   $0x10d
  8008f6:	68 d3 24 80 00       	push   $0x8024d3
  8008fb:	e8 59 0d 00 00       	call   801659 <_panic>
	}	
	mtx->locked = 0;
  800900:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  800906:	8b 43 04             	mov    0x4(%ebx),%eax
  800909:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80090f:	8b 43 04             	mov    0x4(%ebx),%eax
  800912:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800919:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  800920:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80092b:	e8 1f f8 ff ff       	call   80014f <sys_getenvid>
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	ff 75 08             	pushl  0x8(%ebp)
  800936:	50                   	push   %eax
  800937:	e8 d6 f8 ff ff       	call   800212 <sys_page_unmap>
	if (r < 0) {
  80093c:	83 c4 10             	add    $0x10,%esp
  80093f:	85 c0                	test   %eax,%eax
  800941:	79 15                	jns    800958 <mutex_destroy+0x33>
		panic("%e\n", r);
  800943:	50                   	push   %eax
  800944:	68 91 25 80 00       	push   $0x802591
  800949:	68 1a 01 00 00       	push   $0x11a
  80094e:	68 d3 24 80 00       	push   $0x8024d3
  800953:	e8 01 0d 00 00       	call   801659 <_panic>
	}
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	05 00 00 00 30       	add    $0x30000000,%eax
  800965:	c1 e8 0c             	shr    $0xc,%eax
}
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	05 00 00 00 30       	add    $0x30000000,%eax
  800975:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80097a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800987:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	c1 ea 16             	shr    $0x16,%edx
  800991:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800998:	f6 c2 01             	test   $0x1,%dl
  80099b:	74 11                	je     8009ae <fd_alloc+0x2d>
  80099d:	89 c2                	mov    %eax,%edx
  80099f:	c1 ea 0c             	shr    $0xc,%edx
  8009a2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009a9:	f6 c2 01             	test   $0x1,%dl
  8009ac:	75 09                	jne    8009b7 <fd_alloc+0x36>
			*fd_store = fd;
  8009ae:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b5:	eb 17                	jmp    8009ce <fd_alloc+0x4d>
  8009b7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8009bc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8009c1:	75 c9                	jne    80098c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8009c3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8009c9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8009d6:	83 f8 1f             	cmp    $0x1f,%eax
  8009d9:	77 36                	ja     800a11 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8009db:	c1 e0 0c             	shl    $0xc,%eax
  8009de:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8009e3:	89 c2                	mov    %eax,%edx
  8009e5:	c1 ea 16             	shr    $0x16,%edx
  8009e8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8009ef:	f6 c2 01             	test   $0x1,%dl
  8009f2:	74 24                	je     800a18 <fd_lookup+0x48>
  8009f4:	89 c2                	mov    %eax,%edx
  8009f6:	c1 ea 0c             	shr    $0xc,%edx
  8009f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a00:	f6 c2 01             	test   $0x1,%dl
  800a03:	74 1a                	je     800a1f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800a05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a08:	89 02                	mov    %eax,(%edx)
	return 0;
  800a0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0f:	eb 13                	jmp    800a24 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a16:	eb 0c                	jmp    800a24 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a18:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a1d:	eb 05                	jmp    800a24 <fd_lookup+0x54>
  800a1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	83 ec 08             	sub    $0x8,%esp
  800a2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2f:	ba a0 26 80 00       	mov    $0x8026a0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800a34:	eb 13                	jmp    800a49 <dev_lookup+0x23>
  800a36:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800a39:	39 08                	cmp    %ecx,(%eax)
  800a3b:	75 0c                	jne    800a49 <dev_lookup+0x23>
			*dev = devtab[i];
  800a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a40:	89 01                	mov    %eax,(%ecx)
			return 0;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	eb 31                	jmp    800a7a <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800a49:	8b 02                	mov    (%edx),%eax
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	75 e7                	jne    800a36 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800a4f:	a1 04 40 80 00       	mov    0x804004,%eax
  800a54:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a5a:	83 ec 04             	sub    $0x4,%esp
  800a5d:	51                   	push   %ecx
  800a5e:	50                   	push   %eax
  800a5f:	68 24 26 80 00       	push   $0x802624
  800a64:	e8 c9 0c 00 00       	call   801732 <cprintf>
	*dev = 0;
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a72:	83 c4 10             	add    $0x10,%esp
  800a75:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	83 ec 10             	sub    $0x10,%esp
  800a84:	8b 75 08             	mov    0x8(%ebp),%esi
  800a87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a8d:	50                   	push   %eax
  800a8e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a94:	c1 e8 0c             	shr    $0xc,%eax
  800a97:	50                   	push   %eax
  800a98:	e8 33 ff ff ff       	call   8009d0 <fd_lookup>
  800a9d:	83 c4 08             	add    $0x8,%esp
  800aa0:	85 c0                	test   %eax,%eax
  800aa2:	78 05                	js     800aa9 <fd_close+0x2d>
	    || fd != fd2)
  800aa4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800aa7:	74 0c                	je     800ab5 <fd_close+0x39>
		return (must_exist ? r : 0);
  800aa9:	84 db                	test   %bl,%bl
  800aab:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab0:	0f 44 c2             	cmove  %edx,%eax
  800ab3:	eb 41                	jmp    800af6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ab5:	83 ec 08             	sub    $0x8,%esp
  800ab8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800abb:	50                   	push   %eax
  800abc:	ff 36                	pushl  (%esi)
  800abe:	e8 63 ff ff ff       	call   800a26 <dev_lookup>
  800ac3:	89 c3                	mov    %eax,%ebx
  800ac5:	83 c4 10             	add    $0x10,%esp
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	78 1a                	js     800ae6 <fd_close+0x6a>
		if (dev->dev_close)
  800acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800acf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ad2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ad7:	85 c0                	test   %eax,%eax
  800ad9:	74 0b                	je     800ae6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800adb:	83 ec 0c             	sub    $0xc,%esp
  800ade:	56                   	push   %esi
  800adf:	ff d0                	call   *%eax
  800ae1:	89 c3                	mov    %eax,%ebx
  800ae3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ae6:	83 ec 08             	sub    $0x8,%esp
  800ae9:	56                   	push   %esi
  800aea:	6a 00                	push   $0x0
  800aec:	e8 21 f7 ff ff       	call   800212 <sys_page_unmap>
	return r;
  800af1:	83 c4 10             	add    $0x10,%esp
  800af4:	89 d8                	mov    %ebx,%eax
}
  800af6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b06:	50                   	push   %eax
  800b07:	ff 75 08             	pushl  0x8(%ebp)
  800b0a:	e8 c1 fe ff ff       	call   8009d0 <fd_lookup>
  800b0f:	83 c4 08             	add    $0x8,%esp
  800b12:	85 c0                	test   %eax,%eax
  800b14:	78 10                	js     800b26 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	6a 01                	push   $0x1
  800b1b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1e:	e8 59 ff ff ff       	call   800a7c <fd_close>
  800b23:	83 c4 10             	add    $0x10,%esp
}
  800b26:	c9                   	leave  
  800b27:	c3                   	ret    

00800b28 <close_all>:

void
close_all(void)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	53                   	push   %ebx
  800b2c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800b2f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800b34:	83 ec 0c             	sub    $0xc,%esp
  800b37:	53                   	push   %ebx
  800b38:	e8 c0 ff ff ff       	call   800afd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b3d:	83 c3 01             	add    $0x1,%ebx
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	83 fb 20             	cmp    $0x20,%ebx
  800b46:	75 ec                	jne    800b34 <close_all+0xc>
		close(i);
}
  800b48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 2c             	sub    $0x2c,%esp
  800b56:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b59:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b5c:	50                   	push   %eax
  800b5d:	ff 75 08             	pushl  0x8(%ebp)
  800b60:	e8 6b fe ff ff       	call   8009d0 <fd_lookup>
  800b65:	83 c4 08             	add    $0x8,%esp
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	0f 88 c1 00 00 00    	js     800c31 <dup+0xe4>
		return r;
	close(newfdnum);
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	56                   	push   %esi
  800b74:	e8 84 ff ff ff       	call   800afd <close>

	newfd = INDEX2FD(newfdnum);
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	c1 e3 0c             	shl    $0xc,%ebx
  800b7e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b84:	83 c4 04             	add    $0x4,%esp
  800b87:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b8a:	e8 db fd ff ff       	call   80096a <fd2data>
  800b8f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b91:	89 1c 24             	mov    %ebx,(%esp)
  800b94:	e8 d1 fd ff ff       	call   80096a <fd2data>
  800b99:	83 c4 10             	add    $0x10,%esp
  800b9c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b9f:	89 f8                	mov    %edi,%eax
  800ba1:	c1 e8 16             	shr    $0x16,%eax
  800ba4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800bab:	a8 01                	test   $0x1,%al
  800bad:	74 37                	je     800be6 <dup+0x99>
  800baf:	89 f8                	mov    %edi,%eax
  800bb1:	c1 e8 0c             	shr    $0xc,%eax
  800bb4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800bbb:	f6 c2 01             	test   $0x1,%dl
  800bbe:	74 26                	je     800be6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800bc0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	25 07 0e 00 00       	and    $0xe07,%eax
  800bcf:	50                   	push   %eax
  800bd0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bd3:	6a 00                	push   $0x0
  800bd5:	57                   	push   %edi
  800bd6:	6a 00                	push   $0x0
  800bd8:	e8 f3 f5 ff ff       	call   8001d0 <sys_page_map>
  800bdd:	89 c7                	mov    %eax,%edi
  800bdf:	83 c4 20             	add    $0x20,%esp
  800be2:	85 c0                	test   %eax,%eax
  800be4:	78 2e                	js     800c14 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800be6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800be9:	89 d0                	mov    %edx,%eax
  800beb:	c1 e8 0c             	shr    $0xc,%eax
  800bee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bf5:	83 ec 0c             	sub    $0xc,%esp
  800bf8:	25 07 0e 00 00       	and    $0xe07,%eax
  800bfd:	50                   	push   %eax
  800bfe:	53                   	push   %ebx
  800bff:	6a 00                	push   $0x0
  800c01:	52                   	push   %edx
  800c02:	6a 00                	push   $0x0
  800c04:	e8 c7 f5 ff ff       	call   8001d0 <sys_page_map>
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800c0e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c10:	85 ff                	test   %edi,%edi
  800c12:	79 1d                	jns    800c31 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c14:	83 ec 08             	sub    $0x8,%esp
  800c17:	53                   	push   %ebx
  800c18:	6a 00                	push   $0x0
  800c1a:	e8 f3 f5 ff ff       	call   800212 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c1f:	83 c4 08             	add    $0x8,%esp
  800c22:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c25:	6a 00                	push   $0x0
  800c27:	e8 e6 f5 ff ff       	call   800212 <sys_page_unmap>
	return r;
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	89 f8                	mov    %edi,%eax
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 14             	sub    $0x14,%esp
  800c40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c46:	50                   	push   %eax
  800c47:	53                   	push   %ebx
  800c48:	e8 83 fd ff ff       	call   8009d0 <fd_lookup>
  800c4d:	83 c4 08             	add    $0x8,%esp
  800c50:	89 c2                	mov    %eax,%edx
  800c52:	85 c0                	test   %eax,%eax
  800c54:	78 70                	js     800cc6 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c56:	83 ec 08             	sub    $0x8,%esp
  800c59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c5c:	50                   	push   %eax
  800c5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c60:	ff 30                	pushl  (%eax)
  800c62:	e8 bf fd ff ff       	call   800a26 <dev_lookup>
  800c67:	83 c4 10             	add    $0x10,%esp
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	78 4f                	js     800cbd <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c6e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c71:	8b 42 08             	mov    0x8(%edx),%eax
  800c74:	83 e0 03             	and    $0x3,%eax
  800c77:	83 f8 01             	cmp    $0x1,%eax
  800c7a:	75 24                	jne    800ca0 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c7c:	a1 04 40 80 00       	mov    0x804004,%eax
  800c81:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800c87:	83 ec 04             	sub    $0x4,%esp
  800c8a:	53                   	push   %ebx
  800c8b:	50                   	push   %eax
  800c8c:	68 65 26 80 00       	push   $0x802665
  800c91:	e8 9c 0a 00 00       	call   801732 <cprintf>
		return -E_INVAL;
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c9e:	eb 26                	jmp    800cc6 <read+0x8d>
	}
	if (!dev->dev_read)
  800ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca3:	8b 40 08             	mov    0x8(%eax),%eax
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	74 17                	je     800cc1 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800caa:	83 ec 04             	sub    $0x4,%esp
  800cad:	ff 75 10             	pushl  0x10(%ebp)
  800cb0:	ff 75 0c             	pushl  0xc(%ebp)
  800cb3:	52                   	push   %edx
  800cb4:	ff d0                	call   *%eax
  800cb6:	89 c2                	mov    %eax,%edx
  800cb8:	83 c4 10             	add    $0x10,%esp
  800cbb:	eb 09                	jmp    800cc6 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cbd:	89 c2                	mov    %eax,%edx
  800cbf:	eb 05                	jmp    800cc6 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800cc1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800cc6:	89 d0                	mov    %edx,%eax
  800cc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    

00800ccd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cd9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce1:	eb 21                	jmp    800d04 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800ce3:	83 ec 04             	sub    $0x4,%esp
  800ce6:	89 f0                	mov    %esi,%eax
  800ce8:	29 d8                	sub    %ebx,%eax
  800cea:	50                   	push   %eax
  800ceb:	89 d8                	mov    %ebx,%eax
  800ced:	03 45 0c             	add    0xc(%ebp),%eax
  800cf0:	50                   	push   %eax
  800cf1:	57                   	push   %edi
  800cf2:	e8 42 ff ff ff       	call   800c39 <read>
		if (m < 0)
  800cf7:	83 c4 10             	add    $0x10,%esp
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	78 10                	js     800d0e <readn+0x41>
			return m;
		if (m == 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	74 0a                	je     800d0c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800d02:	01 c3                	add    %eax,%ebx
  800d04:	39 f3                	cmp    %esi,%ebx
  800d06:	72 db                	jb     800ce3 <readn+0x16>
  800d08:	89 d8                	mov    %ebx,%eax
  800d0a:	eb 02                	jmp    800d0e <readn+0x41>
  800d0c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800d0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 14             	sub    $0x14,%esp
  800d1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d23:	50                   	push   %eax
  800d24:	53                   	push   %ebx
  800d25:	e8 a6 fc ff ff       	call   8009d0 <fd_lookup>
  800d2a:	83 c4 08             	add    $0x8,%esp
  800d2d:	89 c2                	mov    %eax,%edx
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	78 6b                	js     800d9e <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d33:	83 ec 08             	sub    $0x8,%esp
  800d36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d39:	50                   	push   %eax
  800d3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d3d:	ff 30                	pushl  (%eax)
  800d3f:	e8 e2 fc ff ff       	call   800a26 <dev_lookup>
  800d44:	83 c4 10             	add    $0x10,%esp
  800d47:	85 c0                	test   %eax,%eax
  800d49:	78 4a                	js     800d95 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d4e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d52:	75 24                	jne    800d78 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d54:	a1 04 40 80 00       	mov    0x804004,%eax
  800d59:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800d5f:	83 ec 04             	sub    $0x4,%esp
  800d62:	53                   	push   %ebx
  800d63:	50                   	push   %eax
  800d64:	68 81 26 80 00       	push   $0x802681
  800d69:	e8 c4 09 00 00       	call   801732 <cprintf>
		return -E_INVAL;
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d76:	eb 26                	jmp    800d9e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d78:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d7b:	8b 52 0c             	mov    0xc(%edx),%edx
  800d7e:	85 d2                	test   %edx,%edx
  800d80:	74 17                	je     800d99 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	ff 75 10             	pushl  0x10(%ebp)
  800d88:	ff 75 0c             	pushl  0xc(%ebp)
  800d8b:	50                   	push   %eax
  800d8c:	ff d2                	call   *%edx
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	83 c4 10             	add    $0x10,%esp
  800d93:	eb 09                	jmp    800d9e <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	eb 05                	jmp    800d9e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d99:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d9e:	89 d0                	mov    %edx,%eax
  800da0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800da3:	c9                   	leave  
  800da4:	c3                   	ret    

00800da5 <seek>:

int
seek(int fdnum, off_t offset)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800dab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800dae:	50                   	push   %eax
  800daf:	ff 75 08             	pushl  0x8(%ebp)
  800db2:	e8 19 fc ff ff       	call   8009d0 <fd_lookup>
  800db7:	83 c4 08             	add    $0x8,%esp
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	78 0e                	js     800dcc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800dbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800dc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    

00800dce <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 14             	sub    $0x14,%esp
  800dd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ddb:	50                   	push   %eax
  800ddc:	53                   	push   %ebx
  800ddd:	e8 ee fb ff ff       	call   8009d0 <fd_lookup>
  800de2:	83 c4 08             	add    $0x8,%esp
  800de5:	89 c2                	mov    %eax,%edx
  800de7:	85 c0                	test   %eax,%eax
  800de9:	78 68                	js     800e53 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800deb:	83 ec 08             	sub    $0x8,%esp
  800dee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800df1:	50                   	push   %eax
  800df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df5:	ff 30                	pushl  (%eax)
  800df7:	e8 2a fc ff ff       	call   800a26 <dev_lookup>
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	78 47                	js     800e4a <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e06:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800e0a:	75 24                	jne    800e30 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800e0c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800e11:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e17:	83 ec 04             	sub    $0x4,%esp
  800e1a:	53                   	push   %ebx
  800e1b:	50                   	push   %eax
  800e1c:	68 44 26 80 00       	push   $0x802644
  800e21:	e8 0c 09 00 00       	call   801732 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e2e:	eb 23                	jmp    800e53 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800e30:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e33:	8b 52 18             	mov    0x18(%edx),%edx
  800e36:	85 d2                	test   %edx,%edx
  800e38:	74 14                	je     800e4e <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800e3a:	83 ec 08             	sub    $0x8,%esp
  800e3d:	ff 75 0c             	pushl  0xc(%ebp)
  800e40:	50                   	push   %eax
  800e41:	ff d2                	call   *%edx
  800e43:	89 c2                	mov    %eax,%edx
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	eb 09                	jmp    800e53 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e4a:	89 c2                	mov    %eax,%edx
  800e4c:	eb 05                	jmp    800e53 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800e4e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800e53:	89 d0                	mov    %edx,%eax
  800e55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    

00800e5a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	53                   	push   %ebx
  800e5e:	83 ec 14             	sub    $0x14,%esp
  800e61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e64:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e67:	50                   	push   %eax
  800e68:	ff 75 08             	pushl  0x8(%ebp)
  800e6b:	e8 60 fb ff ff       	call   8009d0 <fd_lookup>
  800e70:	83 c4 08             	add    $0x8,%esp
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	85 c0                	test   %eax,%eax
  800e77:	78 58                	js     800ed1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e79:	83 ec 08             	sub    $0x8,%esp
  800e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7f:	50                   	push   %eax
  800e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e83:	ff 30                	pushl  (%eax)
  800e85:	e8 9c fb ff ff       	call   800a26 <dev_lookup>
  800e8a:	83 c4 10             	add    $0x10,%esp
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	78 37                	js     800ec8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e94:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e98:	74 32                	je     800ecc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e9a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e9d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ea4:	00 00 00 
	stat->st_isdir = 0;
  800ea7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800eae:	00 00 00 
	stat->st_dev = dev;
  800eb1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800eb7:	83 ec 08             	sub    $0x8,%esp
  800eba:	53                   	push   %ebx
  800ebb:	ff 75 f0             	pushl  -0x10(%ebp)
  800ebe:	ff 50 14             	call   *0x14(%eax)
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	eb 09                	jmp    800ed1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ec8:	89 c2                	mov    %eax,%edx
  800eca:	eb 05                	jmp    800ed1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ecc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800ed1:	89 d0                	mov    %edx,%eax
  800ed3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800edd:	83 ec 08             	sub    $0x8,%esp
  800ee0:	6a 00                	push   $0x0
  800ee2:	ff 75 08             	pushl  0x8(%ebp)
  800ee5:	e8 e3 01 00 00       	call   8010cd <open>
  800eea:	89 c3                	mov    %eax,%ebx
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	78 1b                	js     800f0e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800ef3:	83 ec 08             	sub    $0x8,%esp
  800ef6:	ff 75 0c             	pushl  0xc(%ebp)
  800ef9:	50                   	push   %eax
  800efa:	e8 5b ff ff ff       	call   800e5a <fstat>
  800eff:	89 c6                	mov    %eax,%esi
	close(fd);
  800f01:	89 1c 24             	mov    %ebx,(%esp)
  800f04:	e8 f4 fb ff ff       	call   800afd <close>
	return r;
  800f09:	83 c4 10             	add    $0x10,%esp
  800f0c:	89 f0                	mov    %esi,%eax
}
  800f0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	89 c6                	mov    %eax,%esi
  800f1c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800f1e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800f25:	75 12                	jne    800f39 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	6a 01                	push   $0x1
  800f2c:	e8 39 12 00 00       	call   80216a <ipc_find_env>
  800f31:	a3 00 40 80 00       	mov    %eax,0x804000
  800f36:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800f39:	6a 07                	push   $0x7
  800f3b:	68 00 50 80 00       	push   $0x805000
  800f40:	56                   	push   %esi
  800f41:	ff 35 00 40 80 00    	pushl  0x804000
  800f47:	e8 bc 11 00 00       	call   802108 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800f4c:	83 c4 0c             	add    $0xc,%esp
  800f4f:	6a 00                	push   $0x0
  800f51:	53                   	push   %ebx
  800f52:	6a 00                	push   $0x0
  800f54:	e8 34 11 00 00       	call   80208d <ipc_recv>
}
  800f59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5e                   	pop    %esi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f66:	8b 45 08             	mov    0x8(%ebp),%eax
  800f69:	8b 40 0c             	mov    0xc(%eax),%eax
  800f6c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f74:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f79:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800f83:	e8 8d ff ff ff       	call   800f15 <fsipc>
}
  800f88:	c9                   	leave  
  800f89:	c3                   	ret    

00800f8a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
  800f93:	8b 40 0c             	mov    0xc(%eax),%eax
  800f96:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa0:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa5:	e8 6b ff ff ff       	call   800f15 <fsipc>
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 04             	sub    $0x4,%esp
  800fb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	8b 40 0c             	mov    0xc(%eax),%eax
  800fbc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800fc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800fcb:	e8 45 ff ff ff       	call   800f15 <fsipc>
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 2c                	js     801000 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800fd4:	83 ec 08             	sub    $0x8,%esp
  800fd7:	68 00 50 80 00       	push   $0x805000
  800fdc:	53                   	push   %ebx
  800fdd:	e8 d5 0c 00 00       	call   801cb7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800fe2:	a1 80 50 80 00       	mov    0x805080,%eax
  800fe7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800fed:	a1 84 50 80 00       	mov    0x805084,%eax
  800ff2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ff8:	83 c4 10             	add    $0x10,%esp
  800ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801000:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801003:	c9                   	leave  
  801004:	c3                   	ret    

00801005 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80100e:	8b 55 08             	mov    0x8(%ebp),%edx
  801011:	8b 52 0c             	mov    0xc(%edx),%edx
  801014:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80101a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80101f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801024:	0f 47 c2             	cmova  %edx,%eax
  801027:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80102c:	50                   	push   %eax
  80102d:	ff 75 0c             	pushl  0xc(%ebp)
  801030:	68 08 50 80 00       	push   $0x805008
  801035:	e8 0f 0e 00 00       	call   801e49 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80103a:	ba 00 00 00 00       	mov    $0x0,%edx
  80103f:	b8 04 00 00 00       	mov    $0x4,%eax
  801044:	e8 cc fe ff ff       	call   800f15 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
  801050:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	8b 40 0c             	mov    0xc(%eax),%eax
  801059:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80105e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801064:	ba 00 00 00 00       	mov    $0x0,%edx
  801069:	b8 03 00 00 00       	mov    $0x3,%eax
  80106e:	e8 a2 fe ff ff       	call   800f15 <fsipc>
  801073:	89 c3                	mov    %eax,%ebx
  801075:	85 c0                	test   %eax,%eax
  801077:	78 4b                	js     8010c4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801079:	39 c6                	cmp    %eax,%esi
  80107b:	73 16                	jae    801093 <devfile_read+0x48>
  80107d:	68 b0 26 80 00       	push   $0x8026b0
  801082:	68 b7 26 80 00       	push   $0x8026b7
  801087:	6a 7c                	push   $0x7c
  801089:	68 cc 26 80 00       	push   $0x8026cc
  80108e:	e8 c6 05 00 00       	call   801659 <_panic>
	assert(r <= PGSIZE);
  801093:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801098:	7e 16                	jle    8010b0 <devfile_read+0x65>
  80109a:	68 d7 26 80 00       	push   $0x8026d7
  80109f:	68 b7 26 80 00       	push   $0x8026b7
  8010a4:	6a 7d                	push   $0x7d
  8010a6:	68 cc 26 80 00       	push   $0x8026cc
  8010ab:	e8 a9 05 00 00       	call   801659 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8010b0:	83 ec 04             	sub    $0x4,%esp
  8010b3:	50                   	push   %eax
  8010b4:	68 00 50 80 00       	push   $0x805000
  8010b9:	ff 75 0c             	pushl  0xc(%ebp)
  8010bc:	e8 88 0d 00 00       	call   801e49 <memmove>
	return r;
  8010c1:	83 c4 10             	add    $0x10,%esp
}
  8010c4:	89 d8                	mov    %ebx,%eax
  8010c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010c9:	5b                   	pop    %ebx
  8010ca:	5e                   	pop    %esi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	53                   	push   %ebx
  8010d1:	83 ec 20             	sub    $0x20,%esp
  8010d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8010d7:	53                   	push   %ebx
  8010d8:	e8 a1 0b 00 00       	call   801c7e <strlen>
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010e5:	7f 67                	jg     80114e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	e8 8e f8 ff ff       	call   800981 <fd_alloc>
  8010f3:	83 c4 10             	add    $0x10,%esp
		return r;
  8010f6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	78 57                	js     801153 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8010fc:	83 ec 08             	sub    $0x8,%esp
  8010ff:	53                   	push   %ebx
  801100:	68 00 50 80 00       	push   $0x805000
  801105:	e8 ad 0b 00 00       	call   801cb7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80110a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801112:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801115:	b8 01 00 00 00       	mov    $0x1,%eax
  80111a:	e8 f6 fd ff ff       	call   800f15 <fsipc>
  80111f:	89 c3                	mov    %eax,%ebx
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	85 c0                	test   %eax,%eax
  801126:	79 14                	jns    80113c <open+0x6f>
		fd_close(fd, 0);
  801128:	83 ec 08             	sub    $0x8,%esp
  80112b:	6a 00                	push   $0x0
  80112d:	ff 75 f4             	pushl  -0xc(%ebp)
  801130:	e8 47 f9 ff ff       	call   800a7c <fd_close>
		return r;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	89 da                	mov    %ebx,%edx
  80113a:	eb 17                	jmp    801153 <open+0x86>
	}

	return fd2num(fd);
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	ff 75 f4             	pushl  -0xc(%ebp)
  801142:	e8 13 f8 ff ff       	call   80095a <fd2num>
  801147:	89 c2                	mov    %eax,%edx
  801149:	83 c4 10             	add    $0x10,%esp
  80114c:	eb 05                	jmp    801153 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80114e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801153:	89 d0                	mov    %edx,%eax
  801155:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801158:	c9                   	leave  
  801159:	c3                   	ret    

0080115a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801160:	ba 00 00 00 00       	mov    $0x0,%edx
  801165:	b8 08 00 00 00       	mov    $0x8,%eax
  80116a:	e8 a6 fd ff ff       	call   800f15 <fsipc>
}
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	ff 75 08             	pushl  0x8(%ebp)
  80117f:	e8 e6 f7 ff ff       	call   80096a <fd2data>
  801184:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801186:	83 c4 08             	add    $0x8,%esp
  801189:	68 e3 26 80 00       	push   $0x8026e3
  80118e:	53                   	push   %ebx
  80118f:	e8 23 0b 00 00       	call   801cb7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801194:	8b 46 04             	mov    0x4(%esi),%eax
  801197:	2b 06                	sub    (%esi),%eax
  801199:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80119f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011a6:	00 00 00 
	stat->st_dev = &devpipe;
  8011a9:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8011b0:	30 80 00 
	return 0;
}
  8011b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 0c             	sub    $0xc,%esp
  8011c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8011c9:	53                   	push   %ebx
  8011ca:	6a 00                	push   $0x0
  8011cc:	e8 41 f0 ff ff       	call   800212 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8011d1:	89 1c 24             	mov    %ebx,(%esp)
  8011d4:	e8 91 f7 ff ff       	call   80096a <fd2data>
  8011d9:	83 c4 08             	add    $0x8,%esp
  8011dc:	50                   	push   %eax
  8011dd:	6a 00                	push   $0x0
  8011df:	e8 2e f0 ff ff       	call   800212 <sys_page_unmap>
}
  8011e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    

008011e9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	57                   	push   %edi
  8011ed:	56                   	push   %esi
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 1c             	sub    $0x1c,%esp
  8011f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011f5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8011f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fc:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801202:	83 ec 0c             	sub    $0xc,%esp
  801205:	ff 75 e0             	pushl  -0x20(%ebp)
  801208:	e8 a2 0f 00 00       	call   8021af <pageref>
  80120d:	89 c3                	mov    %eax,%ebx
  80120f:	89 3c 24             	mov    %edi,(%esp)
  801212:	e8 98 0f 00 00       	call   8021af <pageref>
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	39 c3                	cmp    %eax,%ebx
  80121c:	0f 94 c1             	sete   %cl
  80121f:	0f b6 c9             	movzbl %cl,%ecx
  801222:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801225:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80122b:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801231:	39 ce                	cmp    %ecx,%esi
  801233:	74 1e                	je     801253 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801235:	39 c3                	cmp    %eax,%ebx
  801237:	75 be                	jne    8011f7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801239:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80123f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801242:	50                   	push   %eax
  801243:	56                   	push   %esi
  801244:	68 ea 26 80 00       	push   $0x8026ea
  801249:	e8 e4 04 00 00       	call   801732 <cprintf>
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	eb a4                	jmp    8011f7 <_pipeisclosed+0xe>
	}
}
  801253:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801259:	5b                   	pop    %ebx
  80125a:	5e                   	pop    %esi
  80125b:	5f                   	pop    %edi
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    

0080125e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	83 ec 28             	sub    $0x28,%esp
  801267:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80126a:	56                   	push   %esi
  80126b:	e8 fa f6 ff ff       	call   80096a <fd2data>
  801270:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	bf 00 00 00 00       	mov    $0x0,%edi
  80127a:	eb 4b                	jmp    8012c7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80127c:	89 da                	mov    %ebx,%edx
  80127e:	89 f0                	mov    %esi,%eax
  801280:	e8 64 ff ff ff       	call   8011e9 <_pipeisclosed>
  801285:	85 c0                	test   %eax,%eax
  801287:	75 48                	jne    8012d1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801289:	e8 e0 ee ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80128e:	8b 43 04             	mov    0x4(%ebx),%eax
  801291:	8b 0b                	mov    (%ebx),%ecx
  801293:	8d 51 20             	lea    0x20(%ecx),%edx
  801296:	39 d0                	cmp    %edx,%eax
  801298:	73 e2                	jae    80127c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80129a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8012a1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8012a4:	89 c2                	mov    %eax,%edx
  8012a6:	c1 fa 1f             	sar    $0x1f,%edx
  8012a9:	89 d1                	mov    %edx,%ecx
  8012ab:	c1 e9 1b             	shr    $0x1b,%ecx
  8012ae:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8012b1:	83 e2 1f             	and    $0x1f,%edx
  8012b4:	29 ca                	sub    %ecx,%edx
  8012b6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8012ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8012be:	83 c0 01             	add    $0x1,%eax
  8012c1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012c4:	83 c7 01             	add    $0x1,%edi
  8012c7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8012ca:	75 c2                	jne    80128e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8012cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8012cf:	eb 05                	jmp    8012d6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8012d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d9:	5b                   	pop    %ebx
  8012da:	5e                   	pop    %esi
  8012db:	5f                   	pop    %edi
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	57                   	push   %edi
  8012e2:	56                   	push   %esi
  8012e3:	53                   	push   %ebx
  8012e4:	83 ec 18             	sub    $0x18,%esp
  8012e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8012ea:	57                   	push   %edi
  8012eb:	e8 7a f6 ff ff       	call   80096a <fd2data>
  8012f0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012fa:	eb 3d                	jmp    801339 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8012fc:	85 db                	test   %ebx,%ebx
  8012fe:	74 04                	je     801304 <devpipe_read+0x26>
				return i;
  801300:	89 d8                	mov    %ebx,%eax
  801302:	eb 44                	jmp    801348 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801304:	89 f2                	mov    %esi,%edx
  801306:	89 f8                	mov    %edi,%eax
  801308:	e8 dc fe ff ff       	call   8011e9 <_pipeisclosed>
  80130d:	85 c0                	test   %eax,%eax
  80130f:	75 32                	jne    801343 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801311:	e8 58 ee ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801316:	8b 06                	mov    (%esi),%eax
  801318:	3b 46 04             	cmp    0x4(%esi),%eax
  80131b:	74 df                	je     8012fc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80131d:	99                   	cltd   
  80131e:	c1 ea 1b             	shr    $0x1b,%edx
  801321:	01 d0                	add    %edx,%eax
  801323:	83 e0 1f             	and    $0x1f,%eax
  801326:	29 d0                	sub    %edx,%eax
  801328:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80132d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801330:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801333:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801336:	83 c3 01             	add    $0x1,%ebx
  801339:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80133c:	75 d8                	jne    801316 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80133e:	8b 45 10             	mov    0x10(%ebp),%eax
  801341:	eb 05                	jmp    801348 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801343:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801348:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5e                   	pop    %esi
  80134d:	5f                   	pop    %edi
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    

00801350 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	56                   	push   %esi
  801354:	53                   	push   %ebx
  801355:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801358:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	e8 20 f6 ff ff       	call   800981 <fd_alloc>
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	89 c2                	mov    %eax,%edx
  801366:	85 c0                	test   %eax,%eax
  801368:	0f 88 2c 01 00 00    	js     80149a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80136e:	83 ec 04             	sub    $0x4,%esp
  801371:	68 07 04 00 00       	push   $0x407
  801376:	ff 75 f4             	pushl  -0xc(%ebp)
  801379:	6a 00                	push   $0x0
  80137b:	e8 0d ee ff ff       	call   80018d <sys_page_alloc>
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	89 c2                	mov    %eax,%edx
  801385:	85 c0                	test   %eax,%eax
  801387:	0f 88 0d 01 00 00    	js     80149a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80138d:	83 ec 0c             	sub    $0xc,%esp
  801390:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801393:	50                   	push   %eax
  801394:	e8 e8 f5 ff ff       	call   800981 <fd_alloc>
  801399:	89 c3                	mov    %eax,%ebx
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	0f 88 e2 00 00 00    	js     801488 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013a6:	83 ec 04             	sub    $0x4,%esp
  8013a9:	68 07 04 00 00       	push   $0x407
  8013ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8013b1:	6a 00                	push   $0x0
  8013b3:	e8 d5 ed ff ff       	call   80018d <sys_page_alloc>
  8013b8:	89 c3                	mov    %eax,%ebx
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	0f 88 c3 00 00 00    	js     801488 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013cb:	e8 9a f5 ff ff       	call   80096a <fd2data>
  8013d0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013d2:	83 c4 0c             	add    $0xc,%esp
  8013d5:	68 07 04 00 00       	push   $0x407
  8013da:	50                   	push   %eax
  8013db:	6a 00                	push   $0x0
  8013dd:	e8 ab ed ff ff       	call   80018d <sys_page_alloc>
  8013e2:	89 c3                	mov    %eax,%ebx
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	0f 88 89 00 00 00    	js     801478 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013ef:	83 ec 0c             	sub    $0xc,%esp
  8013f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013f5:	e8 70 f5 ff ff       	call   80096a <fd2data>
  8013fa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801401:	50                   	push   %eax
  801402:	6a 00                	push   $0x0
  801404:	56                   	push   %esi
  801405:	6a 00                	push   $0x0
  801407:	e8 c4 ed ff ff       	call   8001d0 <sys_page_map>
  80140c:	89 c3                	mov    %eax,%ebx
  80140e:	83 c4 20             	add    $0x20,%esp
  801411:	85 c0                	test   %eax,%eax
  801413:	78 55                	js     80146a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801415:	8b 15 24 30 80 00    	mov    0x803024,%edx
  80141b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801420:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801423:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80142a:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801430:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801433:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801435:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801438:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80143f:	83 ec 0c             	sub    $0xc,%esp
  801442:	ff 75 f4             	pushl  -0xc(%ebp)
  801445:	e8 10 f5 ff ff       	call   80095a <fd2num>
  80144a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80144f:	83 c4 04             	add    $0x4,%esp
  801452:	ff 75 f0             	pushl  -0x10(%ebp)
  801455:	e8 00 f5 ff ff       	call   80095a <fd2num>
  80145a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80145d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	ba 00 00 00 00       	mov    $0x0,%edx
  801468:	eb 30                	jmp    80149a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80146a:	83 ec 08             	sub    $0x8,%esp
  80146d:	56                   	push   %esi
  80146e:	6a 00                	push   $0x0
  801470:	e8 9d ed ff ff       	call   800212 <sys_page_unmap>
  801475:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	ff 75 f0             	pushl  -0x10(%ebp)
  80147e:	6a 00                	push   $0x0
  801480:	e8 8d ed ff ff       	call   800212 <sys_page_unmap>
  801485:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	ff 75 f4             	pushl  -0xc(%ebp)
  80148e:	6a 00                	push   $0x0
  801490:	e8 7d ed ff ff       	call   800212 <sys_page_unmap>
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80149a:	89 d0                	mov    %edx,%eax
  80149c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	ff 75 08             	pushl  0x8(%ebp)
  8014b0:	e8 1b f5 ff ff       	call   8009d0 <fd_lookup>
  8014b5:	83 c4 10             	add    $0x10,%esp
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 18                	js     8014d4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8014bc:	83 ec 0c             	sub    $0xc,%esp
  8014bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c2:	e8 a3 f4 ff ff       	call   80096a <fd2data>
	return _pipeisclosed(fd, p);
  8014c7:	89 c2                	mov    %eax,%edx
  8014c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cc:	e8 18 fd ff ff       	call   8011e9 <_pipeisclosed>
  8014d1:	83 c4 10             	add    $0x10,%esp
}
  8014d4:	c9                   	leave  
  8014d5:	c3                   	ret    

008014d6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8014d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014de:	5d                   	pop    %ebp
  8014df:	c3                   	ret    

008014e0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8014e6:	68 02 27 80 00       	push   $0x802702
  8014eb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ee:	e8 c4 07 00 00       	call   801cb7 <strcpy>
	return 0;
}
  8014f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	57                   	push   %edi
  8014fe:	56                   	push   %esi
  8014ff:	53                   	push   %ebx
  801500:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801506:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80150b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801511:	eb 2d                	jmp    801540 <devcons_write+0x46>
		m = n - tot;
  801513:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801516:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801518:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80151b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801520:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801523:	83 ec 04             	sub    $0x4,%esp
  801526:	53                   	push   %ebx
  801527:	03 45 0c             	add    0xc(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	57                   	push   %edi
  80152c:	e8 18 09 00 00       	call   801e49 <memmove>
		sys_cputs(buf, m);
  801531:	83 c4 08             	add    $0x8,%esp
  801534:	53                   	push   %ebx
  801535:	57                   	push   %edi
  801536:	e8 96 eb ff ff       	call   8000d1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80153b:	01 de                	add    %ebx,%esi
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	89 f0                	mov    %esi,%eax
  801542:	3b 75 10             	cmp    0x10(%ebp),%esi
  801545:	72 cc                	jb     801513 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801547:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154a:	5b                   	pop    %ebx
  80154b:	5e                   	pop    %esi
  80154c:	5f                   	pop    %edi
  80154d:	5d                   	pop    %ebp
  80154e:	c3                   	ret    

0080154f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80155a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80155e:	74 2a                	je     80158a <devcons_read+0x3b>
  801560:	eb 05                	jmp    801567 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801562:	e8 07 ec ff ff       	call   80016e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801567:	e8 83 eb ff ff       	call   8000ef <sys_cgetc>
  80156c:	85 c0                	test   %eax,%eax
  80156e:	74 f2                	je     801562 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801570:	85 c0                	test   %eax,%eax
  801572:	78 16                	js     80158a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801574:	83 f8 04             	cmp    $0x4,%eax
  801577:	74 0c                	je     801585 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801579:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157c:	88 02                	mov    %al,(%edx)
	return 1;
  80157e:	b8 01 00 00 00       	mov    $0x1,%eax
  801583:	eb 05                	jmp    80158a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801585:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801592:	8b 45 08             	mov    0x8(%ebp),%eax
  801595:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801598:	6a 01                	push   $0x1
  80159a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	e8 2e eb ff ff       	call   8000d1 <sys_cputs>
}
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <getchar>:

int
getchar(void)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8015ae:	6a 01                	push   $0x1
  8015b0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	6a 00                	push   $0x0
  8015b6:	e8 7e f6 ff ff       	call   800c39 <read>
	if (r < 0)
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 0f                	js     8015d1 <getchar+0x29>
		return r;
	if (r < 1)
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	7e 06                	jle    8015cc <getchar+0x24>
		return -E_EOF;
	return c;
  8015c6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8015ca:	eb 05                	jmp    8015d1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8015cc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	ff 75 08             	pushl  0x8(%ebp)
  8015e0:	e8 eb f3 ff ff       	call   8009d0 <fd_lookup>
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 11                	js     8015fd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8015ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ef:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8015f5:	39 10                	cmp    %edx,(%eax)
  8015f7:	0f 94 c0             	sete   %al
  8015fa:	0f b6 c0             	movzbl %al,%eax
}
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <opencons>:

int
opencons(void)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801605:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	e8 73 f3 ff ff       	call   800981 <fd_alloc>
  80160e:	83 c4 10             	add    $0x10,%esp
		return r;
  801611:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801613:	85 c0                	test   %eax,%eax
  801615:	78 3e                	js     801655 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801617:	83 ec 04             	sub    $0x4,%esp
  80161a:	68 07 04 00 00       	push   $0x407
  80161f:	ff 75 f4             	pushl  -0xc(%ebp)
  801622:	6a 00                	push   $0x0
  801624:	e8 64 eb ff ff       	call   80018d <sys_page_alloc>
  801629:	83 c4 10             	add    $0x10,%esp
		return r;
  80162c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 23                	js     801655 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801632:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801638:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801640:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801647:	83 ec 0c             	sub    $0xc,%esp
  80164a:	50                   	push   %eax
  80164b:	e8 0a f3 ff ff       	call   80095a <fd2num>
  801650:	89 c2                	mov    %eax,%edx
  801652:	83 c4 10             	add    $0x10,%esp
}
  801655:	89 d0                	mov    %edx,%eax
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	56                   	push   %esi
  80165d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80165e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801661:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801667:	e8 e3 ea ff ff       	call   80014f <sys_getenvid>
  80166c:	83 ec 0c             	sub    $0xc,%esp
  80166f:	ff 75 0c             	pushl  0xc(%ebp)
  801672:	ff 75 08             	pushl  0x8(%ebp)
  801675:	56                   	push   %esi
  801676:	50                   	push   %eax
  801677:	68 10 27 80 00       	push   $0x802710
  80167c:	e8 b1 00 00 00       	call   801732 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801681:	83 c4 18             	add    $0x18,%esp
  801684:	53                   	push   %ebx
  801685:	ff 75 10             	pushl  0x10(%ebp)
  801688:	e8 54 00 00 00       	call   8016e1 <vcprintf>
	cprintf("\n");
  80168d:	c7 04 24 5f 25 80 00 	movl   $0x80255f,(%esp)
  801694:	e8 99 00 00 00       	call   801732 <cprintf>
  801699:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80169c:	cc                   	int3   
  80169d:	eb fd                	jmp    80169c <_panic+0x43>

0080169f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8016a9:	8b 13                	mov    (%ebx),%edx
  8016ab:	8d 42 01             	lea    0x1(%edx),%eax
  8016ae:	89 03                	mov    %eax,(%ebx)
  8016b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8016b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8016bc:	75 1a                	jne    8016d8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8016be:	83 ec 08             	sub    $0x8,%esp
  8016c1:	68 ff 00 00 00       	push   $0xff
  8016c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8016c9:	50                   	push   %eax
  8016ca:	e8 02 ea ff ff       	call   8000d1 <sys_cputs>
		b->idx = 0;
  8016cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016d5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8016d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8016dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8016ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016f1:	00 00 00 
	b.cnt = 0;
  8016f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016fe:	ff 75 0c             	pushl  0xc(%ebp)
  801701:	ff 75 08             	pushl  0x8(%ebp)
  801704:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80170a:	50                   	push   %eax
  80170b:	68 9f 16 80 00       	push   $0x80169f
  801710:	e8 54 01 00 00       	call   801869 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801715:	83 c4 08             	add    $0x8,%esp
  801718:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80171e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801724:	50                   	push   %eax
  801725:	e8 a7 e9 ff ff       	call   8000d1 <sys_cputs>

	return b.cnt;
}
  80172a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801738:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80173b:	50                   	push   %eax
  80173c:	ff 75 08             	pushl  0x8(%ebp)
  80173f:	e8 9d ff ff ff       	call   8016e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  801744:	c9                   	leave  
  801745:	c3                   	ret    

00801746 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	57                   	push   %edi
  80174a:	56                   	push   %esi
  80174b:	53                   	push   %ebx
  80174c:	83 ec 1c             	sub    $0x1c,%esp
  80174f:	89 c7                	mov    %eax,%edi
  801751:	89 d6                	mov    %edx,%esi
  801753:	8b 45 08             	mov    0x8(%ebp),%eax
  801756:	8b 55 0c             	mov    0xc(%ebp),%edx
  801759:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80175c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80175f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801762:	bb 00 00 00 00       	mov    $0x0,%ebx
  801767:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80176a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80176d:	39 d3                	cmp    %edx,%ebx
  80176f:	72 05                	jb     801776 <printnum+0x30>
  801771:	39 45 10             	cmp    %eax,0x10(%ebp)
  801774:	77 45                	ja     8017bb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801776:	83 ec 0c             	sub    $0xc,%esp
  801779:	ff 75 18             	pushl  0x18(%ebp)
  80177c:	8b 45 14             	mov    0x14(%ebp),%eax
  80177f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801782:	53                   	push   %ebx
  801783:	ff 75 10             	pushl  0x10(%ebp)
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	ff 75 e4             	pushl  -0x1c(%ebp)
  80178c:	ff 75 e0             	pushl  -0x20(%ebp)
  80178f:	ff 75 dc             	pushl  -0x24(%ebp)
  801792:	ff 75 d8             	pushl  -0x28(%ebp)
  801795:	e8 56 0a 00 00       	call   8021f0 <__udivdi3>
  80179a:	83 c4 18             	add    $0x18,%esp
  80179d:	52                   	push   %edx
  80179e:	50                   	push   %eax
  80179f:	89 f2                	mov    %esi,%edx
  8017a1:	89 f8                	mov    %edi,%eax
  8017a3:	e8 9e ff ff ff       	call   801746 <printnum>
  8017a8:	83 c4 20             	add    $0x20,%esp
  8017ab:	eb 18                	jmp    8017c5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	56                   	push   %esi
  8017b1:	ff 75 18             	pushl  0x18(%ebp)
  8017b4:	ff d7                	call   *%edi
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	eb 03                	jmp    8017be <printnum+0x78>
  8017bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017be:	83 eb 01             	sub    $0x1,%ebx
  8017c1:	85 db                	test   %ebx,%ebx
  8017c3:	7f e8                	jg     8017ad <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	56                   	push   %esi
  8017c9:	83 ec 04             	sub    $0x4,%esp
  8017cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8017d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8017d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8017d8:	e8 43 0b 00 00       	call   802320 <__umoddi3>
  8017dd:	83 c4 14             	add    $0x14,%esp
  8017e0:	0f be 80 33 27 80 00 	movsbl 0x802733(%eax),%eax
  8017e7:	50                   	push   %eax
  8017e8:	ff d7                	call   *%edi
}
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f0:	5b                   	pop    %ebx
  8017f1:	5e                   	pop    %esi
  8017f2:	5f                   	pop    %edi
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017f8:	83 fa 01             	cmp    $0x1,%edx
  8017fb:	7e 0e                	jle    80180b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017fd:	8b 10                	mov    (%eax),%edx
  8017ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  801802:	89 08                	mov    %ecx,(%eax)
  801804:	8b 02                	mov    (%edx),%eax
  801806:	8b 52 04             	mov    0x4(%edx),%edx
  801809:	eb 22                	jmp    80182d <getuint+0x38>
	else if (lflag)
  80180b:	85 d2                	test   %edx,%edx
  80180d:	74 10                	je     80181f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80180f:	8b 10                	mov    (%eax),%edx
  801811:	8d 4a 04             	lea    0x4(%edx),%ecx
  801814:	89 08                	mov    %ecx,(%eax)
  801816:	8b 02                	mov    (%edx),%eax
  801818:	ba 00 00 00 00       	mov    $0x0,%edx
  80181d:	eb 0e                	jmp    80182d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80181f:	8b 10                	mov    (%eax),%edx
  801821:	8d 4a 04             	lea    0x4(%edx),%ecx
  801824:	89 08                	mov    %ecx,(%eax)
  801826:	8b 02                	mov    (%edx),%eax
  801828:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801835:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801839:	8b 10                	mov    (%eax),%edx
  80183b:	3b 50 04             	cmp    0x4(%eax),%edx
  80183e:	73 0a                	jae    80184a <sprintputch+0x1b>
		*b->buf++ = ch;
  801840:	8d 4a 01             	lea    0x1(%edx),%ecx
  801843:	89 08                	mov    %ecx,(%eax)
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	88 02                	mov    %al,(%edx)
}
  80184a:	5d                   	pop    %ebp
  80184b:	c3                   	ret    

0080184c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801852:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801855:	50                   	push   %eax
  801856:	ff 75 10             	pushl  0x10(%ebp)
  801859:	ff 75 0c             	pushl  0xc(%ebp)
  80185c:	ff 75 08             	pushl  0x8(%ebp)
  80185f:	e8 05 00 00 00       	call   801869 <vprintfmt>
	va_end(ap);
}
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	c9                   	leave  
  801868:	c3                   	ret    

00801869 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	57                   	push   %edi
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
  80186f:	83 ec 2c             	sub    $0x2c,%esp
  801872:	8b 75 08             	mov    0x8(%ebp),%esi
  801875:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801878:	8b 7d 10             	mov    0x10(%ebp),%edi
  80187b:	eb 12                	jmp    80188f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80187d:	85 c0                	test   %eax,%eax
  80187f:	0f 84 89 03 00 00    	je     801c0e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	53                   	push   %ebx
  801889:	50                   	push   %eax
  80188a:	ff d6                	call   *%esi
  80188c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80188f:	83 c7 01             	add    $0x1,%edi
  801892:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801896:	83 f8 25             	cmp    $0x25,%eax
  801899:	75 e2                	jne    80187d <vprintfmt+0x14>
  80189b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80189f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8018a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018ad:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8018b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b9:	eb 07                	jmp    8018c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018be:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c2:	8d 47 01             	lea    0x1(%edi),%eax
  8018c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018c8:	0f b6 07             	movzbl (%edi),%eax
  8018cb:	0f b6 c8             	movzbl %al,%ecx
  8018ce:	83 e8 23             	sub    $0x23,%eax
  8018d1:	3c 55                	cmp    $0x55,%al
  8018d3:	0f 87 1a 03 00 00    	ja     801bf3 <vprintfmt+0x38a>
  8018d9:	0f b6 c0             	movzbl %al,%eax
  8018dc:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
  8018e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8018e6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8018ea:	eb d6                	jmp    8018c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8018fa:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8018fe:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801901:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801904:	83 fa 09             	cmp    $0x9,%edx
  801907:	77 39                	ja     801942 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801909:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80190c:	eb e9                	jmp    8018f7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80190e:	8b 45 14             	mov    0x14(%ebp),%eax
  801911:	8d 48 04             	lea    0x4(%eax),%ecx
  801914:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801917:	8b 00                	mov    (%eax),%eax
  801919:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80191c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80191f:	eb 27                	jmp    801948 <vprintfmt+0xdf>
  801921:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801924:	85 c0                	test   %eax,%eax
  801926:	b9 00 00 00 00       	mov    $0x0,%ecx
  80192b:	0f 49 c8             	cmovns %eax,%ecx
  80192e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801931:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801934:	eb 8c                	jmp    8018c2 <vprintfmt+0x59>
  801936:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801939:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801940:	eb 80                	jmp    8018c2 <vprintfmt+0x59>
  801942:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801945:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801948:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80194c:	0f 89 70 ff ff ff    	jns    8018c2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801952:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801955:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801958:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80195f:	e9 5e ff ff ff       	jmp    8018c2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801964:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801967:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80196a:	e9 53 ff ff ff       	jmp    8018c2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80196f:	8b 45 14             	mov    0x14(%ebp),%eax
  801972:	8d 50 04             	lea    0x4(%eax),%edx
  801975:	89 55 14             	mov    %edx,0x14(%ebp)
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	53                   	push   %ebx
  80197c:	ff 30                	pushl  (%eax)
  80197e:	ff d6                	call   *%esi
			break;
  801980:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801983:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801986:	e9 04 ff ff ff       	jmp    80188f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80198b:	8b 45 14             	mov    0x14(%ebp),%eax
  80198e:	8d 50 04             	lea    0x4(%eax),%edx
  801991:	89 55 14             	mov    %edx,0x14(%ebp)
  801994:	8b 00                	mov    (%eax),%eax
  801996:	99                   	cltd   
  801997:	31 d0                	xor    %edx,%eax
  801999:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80199b:	83 f8 0f             	cmp    $0xf,%eax
  80199e:	7f 0b                	jg     8019ab <vprintfmt+0x142>
  8019a0:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  8019a7:	85 d2                	test   %edx,%edx
  8019a9:	75 18                	jne    8019c3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8019ab:	50                   	push   %eax
  8019ac:	68 4b 27 80 00       	push   $0x80274b
  8019b1:	53                   	push   %ebx
  8019b2:	56                   	push   %esi
  8019b3:	e8 94 fe ff ff       	call   80184c <printfmt>
  8019b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019be:	e9 cc fe ff ff       	jmp    80188f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8019c3:	52                   	push   %edx
  8019c4:	68 c9 26 80 00       	push   $0x8026c9
  8019c9:	53                   	push   %ebx
  8019ca:	56                   	push   %esi
  8019cb:	e8 7c fe ff ff       	call   80184c <printfmt>
  8019d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019d6:	e9 b4 fe ff ff       	jmp    80188f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8019db:	8b 45 14             	mov    0x14(%ebp),%eax
  8019de:	8d 50 04             	lea    0x4(%eax),%edx
  8019e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019e4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8019e6:	85 ff                	test   %edi,%edi
  8019e8:	b8 44 27 80 00       	mov    $0x802744,%eax
  8019ed:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8019f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019f4:	0f 8e 94 00 00 00    	jle    801a8e <vprintfmt+0x225>
  8019fa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8019fe:	0f 84 98 00 00 00    	je     801a9c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801a04:	83 ec 08             	sub    $0x8,%esp
  801a07:	ff 75 d0             	pushl  -0x30(%ebp)
  801a0a:	57                   	push   %edi
  801a0b:	e8 86 02 00 00       	call   801c96 <strnlen>
  801a10:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801a13:	29 c1                	sub    %eax,%ecx
  801a15:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801a18:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801a1b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801a1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a22:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801a25:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a27:	eb 0f                	jmp    801a38 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801a29:	83 ec 08             	sub    $0x8,%esp
  801a2c:	53                   	push   %ebx
  801a2d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a30:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a32:	83 ef 01             	sub    $0x1,%edi
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	85 ff                	test   %edi,%edi
  801a3a:	7f ed                	jg     801a29 <vprintfmt+0x1c0>
  801a3c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801a3f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801a42:	85 c9                	test   %ecx,%ecx
  801a44:	b8 00 00 00 00       	mov    $0x0,%eax
  801a49:	0f 49 c1             	cmovns %ecx,%eax
  801a4c:	29 c1                	sub    %eax,%ecx
  801a4e:	89 75 08             	mov    %esi,0x8(%ebp)
  801a51:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a54:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a57:	89 cb                	mov    %ecx,%ebx
  801a59:	eb 4d                	jmp    801aa8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a5b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a5f:	74 1b                	je     801a7c <vprintfmt+0x213>
  801a61:	0f be c0             	movsbl %al,%eax
  801a64:	83 e8 20             	sub    $0x20,%eax
  801a67:	83 f8 5e             	cmp    $0x5e,%eax
  801a6a:	76 10                	jbe    801a7c <vprintfmt+0x213>
					putch('?', putdat);
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	ff 75 0c             	pushl  0xc(%ebp)
  801a72:	6a 3f                	push   $0x3f
  801a74:	ff 55 08             	call   *0x8(%ebp)
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	eb 0d                	jmp    801a89 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a7c:	83 ec 08             	sub    $0x8,%esp
  801a7f:	ff 75 0c             	pushl  0xc(%ebp)
  801a82:	52                   	push   %edx
  801a83:	ff 55 08             	call   *0x8(%ebp)
  801a86:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a89:	83 eb 01             	sub    $0x1,%ebx
  801a8c:	eb 1a                	jmp    801aa8 <vprintfmt+0x23f>
  801a8e:	89 75 08             	mov    %esi,0x8(%ebp)
  801a91:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a94:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a97:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a9a:	eb 0c                	jmp    801aa8 <vprintfmt+0x23f>
  801a9c:	89 75 08             	mov    %esi,0x8(%ebp)
  801a9f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801aa2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801aa5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801aa8:	83 c7 01             	add    $0x1,%edi
  801aab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801aaf:	0f be d0             	movsbl %al,%edx
  801ab2:	85 d2                	test   %edx,%edx
  801ab4:	74 23                	je     801ad9 <vprintfmt+0x270>
  801ab6:	85 f6                	test   %esi,%esi
  801ab8:	78 a1                	js     801a5b <vprintfmt+0x1f2>
  801aba:	83 ee 01             	sub    $0x1,%esi
  801abd:	79 9c                	jns    801a5b <vprintfmt+0x1f2>
  801abf:	89 df                	mov    %ebx,%edi
  801ac1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ac7:	eb 18                	jmp    801ae1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801ac9:	83 ec 08             	sub    $0x8,%esp
  801acc:	53                   	push   %ebx
  801acd:	6a 20                	push   $0x20
  801acf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801ad1:	83 ef 01             	sub    $0x1,%edi
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	eb 08                	jmp    801ae1 <vprintfmt+0x278>
  801ad9:	89 df                	mov    %ebx,%edi
  801adb:	8b 75 08             	mov    0x8(%ebp),%esi
  801ade:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ae1:	85 ff                	test   %edi,%edi
  801ae3:	7f e4                	jg     801ac9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ae5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ae8:	e9 a2 fd ff ff       	jmp    80188f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801aed:	83 fa 01             	cmp    $0x1,%edx
  801af0:	7e 16                	jle    801b08 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801af2:	8b 45 14             	mov    0x14(%ebp),%eax
  801af5:	8d 50 08             	lea    0x8(%eax),%edx
  801af8:	89 55 14             	mov    %edx,0x14(%ebp)
  801afb:	8b 50 04             	mov    0x4(%eax),%edx
  801afe:	8b 00                	mov    (%eax),%eax
  801b00:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b03:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801b06:	eb 32                	jmp    801b3a <vprintfmt+0x2d1>
	else if (lflag)
  801b08:	85 d2                	test   %edx,%edx
  801b0a:	74 18                	je     801b24 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801b0c:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0f:	8d 50 04             	lea    0x4(%eax),%edx
  801b12:	89 55 14             	mov    %edx,0x14(%ebp)
  801b15:	8b 00                	mov    (%eax),%eax
  801b17:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b1a:	89 c1                	mov    %eax,%ecx
  801b1c:	c1 f9 1f             	sar    $0x1f,%ecx
  801b1f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801b22:	eb 16                	jmp    801b3a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801b24:	8b 45 14             	mov    0x14(%ebp),%eax
  801b27:	8d 50 04             	lea    0x4(%eax),%edx
  801b2a:	89 55 14             	mov    %edx,0x14(%ebp)
  801b2d:	8b 00                	mov    (%eax),%eax
  801b2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b32:	89 c1                	mov    %eax,%ecx
  801b34:	c1 f9 1f             	sar    $0x1f,%ecx
  801b37:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b3a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801b40:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b45:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b49:	79 74                	jns    801bbf <vprintfmt+0x356>
				putch('-', putdat);
  801b4b:	83 ec 08             	sub    $0x8,%esp
  801b4e:	53                   	push   %ebx
  801b4f:	6a 2d                	push   $0x2d
  801b51:	ff d6                	call   *%esi
				num = -(long long) num;
  801b53:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b56:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b59:	f7 d8                	neg    %eax
  801b5b:	83 d2 00             	adc    $0x0,%edx
  801b5e:	f7 da                	neg    %edx
  801b60:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b63:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b68:	eb 55                	jmp    801bbf <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b6a:	8d 45 14             	lea    0x14(%ebp),%eax
  801b6d:	e8 83 fc ff ff       	call   8017f5 <getuint>
			base = 10;
  801b72:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b77:	eb 46                	jmp    801bbf <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b79:	8d 45 14             	lea    0x14(%ebp),%eax
  801b7c:	e8 74 fc ff ff       	call   8017f5 <getuint>
			base = 8;
  801b81:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b86:	eb 37                	jmp    801bbf <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b88:	83 ec 08             	sub    $0x8,%esp
  801b8b:	53                   	push   %ebx
  801b8c:	6a 30                	push   $0x30
  801b8e:	ff d6                	call   *%esi
			putch('x', putdat);
  801b90:	83 c4 08             	add    $0x8,%esp
  801b93:	53                   	push   %ebx
  801b94:	6a 78                	push   $0x78
  801b96:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b98:	8b 45 14             	mov    0x14(%ebp),%eax
  801b9b:	8d 50 04             	lea    0x4(%eax),%edx
  801b9e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ba1:	8b 00                	mov    (%eax),%eax
  801ba3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ba8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801bab:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801bb0:	eb 0d                	jmp    801bbf <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801bb2:	8d 45 14             	lea    0x14(%ebp),%eax
  801bb5:	e8 3b fc ff ff       	call   8017f5 <getuint>
			base = 16;
  801bba:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801bbf:	83 ec 0c             	sub    $0xc,%esp
  801bc2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801bc6:	57                   	push   %edi
  801bc7:	ff 75 e0             	pushl  -0x20(%ebp)
  801bca:	51                   	push   %ecx
  801bcb:	52                   	push   %edx
  801bcc:	50                   	push   %eax
  801bcd:	89 da                	mov    %ebx,%edx
  801bcf:	89 f0                	mov    %esi,%eax
  801bd1:	e8 70 fb ff ff       	call   801746 <printnum>
			break;
  801bd6:	83 c4 20             	add    $0x20,%esp
  801bd9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bdc:	e9 ae fc ff ff       	jmp    80188f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801be1:	83 ec 08             	sub    $0x8,%esp
  801be4:	53                   	push   %ebx
  801be5:	51                   	push   %ecx
  801be6:	ff d6                	call   *%esi
			break;
  801be8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801beb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801bee:	e9 9c fc ff ff       	jmp    80188f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801bf3:	83 ec 08             	sub    $0x8,%esp
  801bf6:	53                   	push   %ebx
  801bf7:	6a 25                	push   $0x25
  801bf9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801bfb:	83 c4 10             	add    $0x10,%esp
  801bfe:	eb 03                	jmp    801c03 <vprintfmt+0x39a>
  801c00:	83 ef 01             	sub    $0x1,%edi
  801c03:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801c07:	75 f7                	jne    801c00 <vprintfmt+0x397>
  801c09:	e9 81 fc ff ff       	jmp    80188f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c11:	5b                   	pop    %ebx
  801c12:	5e                   	pop    %esi
  801c13:	5f                   	pop    %edi
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 18             	sub    $0x18,%esp
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c25:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c29:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c33:	85 c0                	test   %eax,%eax
  801c35:	74 26                	je     801c5d <vsnprintf+0x47>
  801c37:	85 d2                	test   %edx,%edx
  801c39:	7e 22                	jle    801c5d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c3b:	ff 75 14             	pushl  0x14(%ebp)
  801c3e:	ff 75 10             	pushl  0x10(%ebp)
  801c41:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c44:	50                   	push   %eax
  801c45:	68 2f 18 80 00       	push   $0x80182f
  801c4a:	e8 1a fc ff ff       	call   801869 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c52:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	eb 05                	jmp    801c62 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    

00801c64 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c6a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c6d:	50                   	push   %eax
  801c6e:	ff 75 10             	pushl  0x10(%ebp)
  801c71:	ff 75 0c             	pushl  0xc(%ebp)
  801c74:	ff 75 08             	pushl  0x8(%ebp)
  801c77:	e8 9a ff ff ff       	call   801c16 <vsnprintf>
	va_end(ap);

	return rc;
}
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c84:	b8 00 00 00 00       	mov    $0x0,%eax
  801c89:	eb 03                	jmp    801c8e <strlen+0x10>
		n++;
  801c8b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c8e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c92:	75 f7                	jne    801c8b <strlen+0xd>
		n++;
	return n;
}
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    

00801c96 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca4:	eb 03                	jmp    801ca9 <strnlen+0x13>
		n++;
  801ca6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ca9:	39 c2                	cmp    %eax,%edx
  801cab:	74 08                	je     801cb5 <strnlen+0x1f>
  801cad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801cb1:	75 f3                	jne    801ca6 <strnlen+0x10>
  801cb3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	53                   	push   %ebx
  801cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801cc1:	89 c2                	mov    %eax,%edx
  801cc3:	83 c2 01             	add    $0x1,%edx
  801cc6:	83 c1 01             	add    $0x1,%ecx
  801cc9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801ccd:	88 5a ff             	mov    %bl,-0x1(%edx)
  801cd0:	84 db                	test   %bl,%bl
  801cd2:	75 ef                	jne    801cc3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801cd4:	5b                   	pop    %ebx
  801cd5:	5d                   	pop    %ebp
  801cd6:	c3                   	ret    

00801cd7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	53                   	push   %ebx
  801cdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801cde:	53                   	push   %ebx
  801cdf:	e8 9a ff ff ff       	call   801c7e <strlen>
  801ce4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801ce7:	ff 75 0c             	pushl  0xc(%ebp)
  801cea:	01 d8                	add    %ebx,%eax
  801cec:	50                   	push   %eax
  801ced:	e8 c5 ff ff ff       	call   801cb7 <strcpy>
	return dst;
}
  801cf2:	89 d8                	mov    %ebx,%eax
  801cf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    

00801cf9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	8b 75 08             	mov    0x8(%ebp),%esi
  801d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d04:	89 f3                	mov    %esi,%ebx
  801d06:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d09:	89 f2                	mov    %esi,%edx
  801d0b:	eb 0f                	jmp    801d1c <strncpy+0x23>
		*dst++ = *src;
  801d0d:	83 c2 01             	add    $0x1,%edx
  801d10:	0f b6 01             	movzbl (%ecx),%eax
  801d13:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d16:	80 39 01             	cmpb   $0x1,(%ecx)
  801d19:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d1c:	39 da                	cmp    %ebx,%edx
  801d1e:	75 ed                	jne    801d0d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d20:	89 f0                	mov    %esi,%eax
  801d22:	5b                   	pop    %ebx
  801d23:	5e                   	pop    %esi
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    

00801d26 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	56                   	push   %esi
  801d2a:	53                   	push   %ebx
  801d2b:	8b 75 08             	mov    0x8(%ebp),%esi
  801d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d31:	8b 55 10             	mov    0x10(%ebp),%edx
  801d34:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d36:	85 d2                	test   %edx,%edx
  801d38:	74 21                	je     801d5b <strlcpy+0x35>
  801d3a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801d3e:	89 f2                	mov    %esi,%edx
  801d40:	eb 09                	jmp    801d4b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d42:	83 c2 01             	add    $0x1,%edx
  801d45:	83 c1 01             	add    $0x1,%ecx
  801d48:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801d4b:	39 c2                	cmp    %eax,%edx
  801d4d:	74 09                	je     801d58 <strlcpy+0x32>
  801d4f:	0f b6 19             	movzbl (%ecx),%ebx
  801d52:	84 db                	test   %bl,%bl
  801d54:	75 ec                	jne    801d42 <strlcpy+0x1c>
  801d56:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d58:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d5b:	29 f0                	sub    %esi,%eax
}
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d67:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d6a:	eb 06                	jmp    801d72 <strcmp+0x11>
		p++, q++;
  801d6c:	83 c1 01             	add    $0x1,%ecx
  801d6f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d72:	0f b6 01             	movzbl (%ecx),%eax
  801d75:	84 c0                	test   %al,%al
  801d77:	74 04                	je     801d7d <strcmp+0x1c>
  801d79:	3a 02                	cmp    (%edx),%al
  801d7b:	74 ef                	je     801d6c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d7d:	0f b6 c0             	movzbl %al,%eax
  801d80:	0f b6 12             	movzbl (%edx),%edx
  801d83:	29 d0                	sub    %edx,%eax
}
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    

00801d87 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	53                   	push   %ebx
  801d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d91:	89 c3                	mov    %eax,%ebx
  801d93:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d96:	eb 06                	jmp    801d9e <strncmp+0x17>
		n--, p++, q++;
  801d98:	83 c0 01             	add    $0x1,%eax
  801d9b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d9e:	39 d8                	cmp    %ebx,%eax
  801da0:	74 15                	je     801db7 <strncmp+0x30>
  801da2:	0f b6 08             	movzbl (%eax),%ecx
  801da5:	84 c9                	test   %cl,%cl
  801da7:	74 04                	je     801dad <strncmp+0x26>
  801da9:	3a 0a                	cmp    (%edx),%cl
  801dab:	74 eb                	je     801d98 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801dad:	0f b6 00             	movzbl (%eax),%eax
  801db0:	0f b6 12             	movzbl (%edx),%edx
  801db3:	29 d0                	sub    %edx,%eax
  801db5:	eb 05                	jmp    801dbc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801db7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801dbc:	5b                   	pop    %ebx
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801dc9:	eb 07                	jmp    801dd2 <strchr+0x13>
		if (*s == c)
  801dcb:	38 ca                	cmp    %cl,%dl
  801dcd:	74 0f                	je     801dde <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801dcf:	83 c0 01             	add    $0x1,%eax
  801dd2:	0f b6 10             	movzbl (%eax),%edx
  801dd5:	84 d2                	test   %dl,%dl
  801dd7:	75 f2                	jne    801dcb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	8b 45 08             	mov    0x8(%ebp),%eax
  801de6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801dea:	eb 03                	jmp    801def <strfind+0xf>
  801dec:	83 c0 01             	add    $0x1,%eax
  801def:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801df2:	38 ca                	cmp    %cl,%dl
  801df4:	74 04                	je     801dfa <strfind+0x1a>
  801df6:	84 d2                	test   %dl,%dl
  801df8:	75 f2                	jne    801dec <strfind+0xc>
			break;
	return (char *) s;
}
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    

00801dfc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	57                   	push   %edi
  801e00:	56                   	push   %esi
  801e01:	53                   	push   %ebx
  801e02:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801e08:	85 c9                	test   %ecx,%ecx
  801e0a:	74 36                	je     801e42 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801e0c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801e12:	75 28                	jne    801e3c <memset+0x40>
  801e14:	f6 c1 03             	test   $0x3,%cl
  801e17:	75 23                	jne    801e3c <memset+0x40>
		c &= 0xFF;
  801e19:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e1d:	89 d3                	mov    %edx,%ebx
  801e1f:	c1 e3 08             	shl    $0x8,%ebx
  801e22:	89 d6                	mov    %edx,%esi
  801e24:	c1 e6 18             	shl    $0x18,%esi
  801e27:	89 d0                	mov    %edx,%eax
  801e29:	c1 e0 10             	shl    $0x10,%eax
  801e2c:	09 f0                	or     %esi,%eax
  801e2e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801e30:	89 d8                	mov    %ebx,%eax
  801e32:	09 d0                	or     %edx,%eax
  801e34:	c1 e9 02             	shr    $0x2,%ecx
  801e37:	fc                   	cld    
  801e38:	f3 ab                	rep stos %eax,%es:(%edi)
  801e3a:	eb 06                	jmp    801e42 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3f:	fc                   	cld    
  801e40:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e42:	89 f8                	mov    %edi,%eax
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    

00801e49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e49:	55                   	push   %ebp
  801e4a:	89 e5                	mov    %esp,%ebp
  801e4c:	57                   	push   %edi
  801e4d:	56                   	push   %esi
  801e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e51:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e57:	39 c6                	cmp    %eax,%esi
  801e59:	73 35                	jae    801e90 <memmove+0x47>
  801e5b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e5e:	39 d0                	cmp    %edx,%eax
  801e60:	73 2e                	jae    801e90 <memmove+0x47>
		s += n;
		d += n;
  801e62:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e65:	89 d6                	mov    %edx,%esi
  801e67:	09 fe                	or     %edi,%esi
  801e69:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e6f:	75 13                	jne    801e84 <memmove+0x3b>
  801e71:	f6 c1 03             	test   $0x3,%cl
  801e74:	75 0e                	jne    801e84 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e76:	83 ef 04             	sub    $0x4,%edi
  801e79:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e7c:	c1 e9 02             	shr    $0x2,%ecx
  801e7f:	fd                   	std    
  801e80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e82:	eb 09                	jmp    801e8d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e84:	83 ef 01             	sub    $0x1,%edi
  801e87:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e8a:	fd                   	std    
  801e8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e8d:	fc                   	cld    
  801e8e:	eb 1d                	jmp    801ead <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e90:	89 f2                	mov    %esi,%edx
  801e92:	09 c2                	or     %eax,%edx
  801e94:	f6 c2 03             	test   $0x3,%dl
  801e97:	75 0f                	jne    801ea8 <memmove+0x5f>
  801e99:	f6 c1 03             	test   $0x3,%cl
  801e9c:	75 0a                	jne    801ea8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e9e:	c1 e9 02             	shr    $0x2,%ecx
  801ea1:	89 c7                	mov    %eax,%edi
  801ea3:	fc                   	cld    
  801ea4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801ea6:	eb 05                	jmp    801ead <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801ea8:	89 c7                	mov    %eax,%edi
  801eaa:	fc                   	cld    
  801eab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801ead:	5e                   	pop    %esi
  801eae:	5f                   	pop    %edi
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    

00801eb1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801eb4:	ff 75 10             	pushl  0x10(%ebp)
  801eb7:	ff 75 0c             	pushl  0xc(%ebp)
  801eba:	ff 75 08             	pushl  0x8(%ebp)
  801ebd:	e8 87 ff ff ff       	call   801e49 <memmove>
}
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	56                   	push   %esi
  801ec8:	53                   	push   %ebx
  801ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ecf:	89 c6                	mov    %eax,%esi
  801ed1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ed4:	eb 1a                	jmp    801ef0 <memcmp+0x2c>
		if (*s1 != *s2)
  801ed6:	0f b6 08             	movzbl (%eax),%ecx
  801ed9:	0f b6 1a             	movzbl (%edx),%ebx
  801edc:	38 d9                	cmp    %bl,%cl
  801ede:	74 0a                	je     801eea <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ee0:	0f b6 c1             	movzbl %cl,%eax
  801ee3:	0f b6 db             	movzbl %bl,%ebx
  801ee6:	29 d8                	sub    %ebx,%eax
  801ee8:	eb 0f                	jmp    801ef9 <memcmp+0x35>
		s1++, s2++;
  801eea:	83 c0 01             	add    $0x1,%eax
  801eed:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ef0:	39 f0                	cmp    %esi,%eax
  801ef2:	75 e2                	jne    801ed6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ef9:	5b                   	pop    %ebx
  801efa:	5e                   	pop    %esi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    

00801efd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	53                   	push   %ebx
  801f01:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801f04:	89 c1                	mov    %eax,%ecx
  801f06:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801f09:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f0d:	eb 0a                	jmp    801f19 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801f0f:	0f b6 10             	movzbl (%eax),%edx
  801f12:	39 da                	cmp    %ebx,%edx
  801f14:	74 07                	je     801f1d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f16:	83 c0 01             	add    $0x1,%eax
  801f19:	39 c8                	cmp    %ecx,%eax
  801f1b:	72 f2                	jb     801f0f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801f1d:	5b                   	pop    %ebx
  801f1e:	5d                   	pop    %ebp
  801f1f:	c3                   	ret    

00801f20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	57                   	push   %edi
  801f24:	56                   	push   %esi
  801f25:	53                   	push   %ebx
  801f26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f2c:	eb 03                	jmp    801f31 <strtol+0x11>
		s++;
  801f2e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f31:	0f b6 01             	movzbl (%ecx),%eax
  801f34:	3c 20                	cmp    $0x20,%al
  801f36:	74 f6                	je     801f2e <strtol+0xe>
  801f38:	3c 09                	cmp    $0x9,%al
  801f3a:	74 f2                	je     801f2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801f3c:	3c 2b                	cmp    $0x2b,%al
  801f3e:	75 0a                	jne    801f4a <strtol+0x2a>
		s++;
  801f40:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f43:	bf 00 00 00 00       	mov    $0x0,%edi
  801f48:	eb 11                	jmp    801f5b <strtol+0x3b>
  801f4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801f4f:	3c 2d                	cmp    $0x2d,%al
  801f51:	75 08                	jne    801f5b <strtol+0x3b>
		s++, neg = 1;
  801f53:	83 c1 01             	add    $0x1,%ecx
  801f56:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f5b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f61:	75 15                	jne    801f78 <strtol+0x58>
  801f63:	80 39 30             	cmpb   $0x30,(%ecx)
  801f66:	75 10                	jne    801f78 <strtol+0x58>
  801f68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f6c:	75 7c                	jne    801fea <strtol+0xca>
		s += 2, base = 16;
  801f6e:	83 c1 02             	add    $0x2,%ecx
  801f71:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f76:	eb 16                	jmp    801f8e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f78:	85 db                	test   %ebx,%ebx
  801f7a:	75 12                	jne    801f8e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f81:	80 39 30             	cmpb   $0x30,(%ecx)
  801f84:	75 08                	jne    801f8e <strtol+0x6e>
		s++, base = 8;
  801f86:	83 c1 01             	add    $0x1,%ecx
  801f89:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f93:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f96:	0f b6 11             	movzbl (%ecx),%edx
  801f99:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f9c:	89 f3                	mov    %esi,%ebx
  801f9e:	80 fb 09             	cmp    $0x9,%bl
  801fa1:	77 08                	ja     801fab <strtol+0x8b>
			dig = *s - '0';
  801fa3:	0f be d2             	movsbl %dl,%edx
  801fa6:	83 ea 30             	sub    $0x30,%edx
  801fa9:	eb 22                	jmp    801fcd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801fab:	8d 72 9f             	lea    -0x61(%edx),%esi
  801fae:	89 f3                	mov    %esi,%ebx
  801fb0:	80 fb 19             	cmp    $0x19,%bl
  801fb3:	77 08                	ja     801fbd <strtol+0x9d>
			dig = *s - 'a' + 10;
  801fb5:	0f be d2             	movsbl %dl,%edx
  801fb8:	83 ea 57             	sub    $0x57,%edx
  801fbb:	eb 10                	jmp    801fcd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801fbd:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fc0:	89 f3                	mov    %esi,%ebx
  801fc2:	80 fb 19             	cmp    $0x19,%bl
  801fc5:	77 16                	ja     801fdd <strtol+0xbd>
			dig = *s - 'A' + 10;
  801fc7:	0f be d2             	movsbl %dl,%edx
  801fca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801fcd:	3b 55 10             	cmp    0x10(%ebp),%edx
  801fd0:	7d 0b                	jge    801fdd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801fd2:	83 c1 01             	add    $0x1,%ecx
  801fd5:	0f af 45 10          	imul   0x10(%ebp),%eax
  801fd9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801fdb:	eb b9                	jmp    801f96 <strtol+0x76>

	if (endptr)
  801fdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801fe1:	74 0d                	je     801ff0 <strtol+0xd0>
		*endptr = (char *) s;
  801fe3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe6:	89 0e                	mov    %ecx,(%esi)
  801fe8:	eb 06                	jmp    801ff0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801fea:	85 db                	test   %ebx,%ebx
  801fec:	74 98                	je     801f86 <strtol+0x66>
  801fee:	eb 9e                	jmp    801f8e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ff0:	89 c2                	mov    %eax,%edx
  801ff2:	f7 da                	neg    %edx
  801ff4:	85 ff                	test   %edi,%edi
  801ff6:	0f 45 c2             	cmovne %edx,%eax
}
  801ff9:	5b                   	pop    %ebx
  801ffa:	5e                   	pop    %esi
  801ffb:	5f                   	pop    %edi
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    

00801ffe <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802004:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80200b:	75 2a                	jne    802037 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  80200d:	83 ec 04             	sub    $0x4,%esp
  802010:	6a 07                	push   $0x7
  802012:	68 00 f0 bf ee       	push   $0xeebff000
  802017:	6a 00                	push   $0x0
  802019:	e8 6f e1 ff ff       	call   80018d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80201e:	83 c4 10             	add    $0x10,%esp
  802021:	85 c0                	test   %eax,%eax
  802023:	79 12                	jns    802037 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802025:	50                   	push   %eax
  802026:	68 91 25 80 00       	push   $0x802591
  80202b:	6a 23                	push   $0x23
  80202d:	68 40 2a 80 00       	push   $0x802a40
  802032:	e8 22 f6 ff ff       	call   801659 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802037:	8b 45 08             	mov    0x8(%ebp),%eax
  80203a:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80203f:	83 ec 08             	sub    $0x8,%esp
  802042:	68 69 20 80 00       	push   $0x802069
  802047:	6a 00                	push   $0x0
  802049:	e8 8a e2 ff ff       	call   8002d8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	85 c0                	test   %eax,%eax
  802053:	79 12                	jns    802067 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802055:	50                   	push   %eax
  802056:	68 91 25 80 00       	push   $0x802591
  80205b:	6a 2c                	push   $0x2c
  80205d:	68 40 2a 80 00       	push   $0x802a40
  802062:	e8 f2 f5 ff ff       	call   801659 <_panic>
	}
}
  802067:	c9                   	leave  
  802068:	c3                   	ret    

00802069 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802069:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80206a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80206f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802071:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802074:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802078:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80207d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802081:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802083:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802086:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802087:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80208a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80208b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80208c:	c3                   	ret    

0080208d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80208d:	55                   	push   %ebp
  80208e:	89 e5                	mov    %esp,%ebp
  802090:	56                   	push   %esi
  802091:	53                   	push   %ebx
  802092:	8b 75 08             	mov    0x8(%ebp),%esi
  802095:	8b 45 0c             	mov    0xc(%ebp),%eax
  802098:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80209b:	85 c0                	test   %eax,%eax
  80209d:	75 12                	jne    8020b1 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80209f:	83 ec 0c             	sub    $0xc,%esp
  8020a2:	68 00 00 c0 ee       	push   $0xeec00000
  8020a7:	e8 91 e2 ff ff       	call   80033d <sys_ipc_recv>
  8020ac:	83 c4 10             	add    $0x10,%esp
  8020af:	eb 0c                	jmp    8020bd <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020b1:	83 ec 0c             	sub    $0xc,%esp
  8020b4:	50                   	push   %eax
  8020b5:	e8 83 e2 ff ff       	call   80033d <sys_ipc_recv>
  8020ba:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020bd:	85 f6                	test   %esi,%esi
  8020bf:	0f 95 c1             	setne  %cl
  8020c2:	85 db                	test   %ebx,%ebx
  8020c4:	0f 95 c2             	setne  %dl
  8020c7:	84 d1                	test   %dl,%cl
  8020c9:	74 09                	je     8020d4 <ipc_recv+0x47>
  8020cb:	89 c2                	mov    %eax,%edx
  8020cd:	c1 ea 1f             	shr    $0x1f,%edx
  8020d0:	84 d2                	test   %dl,%dl
  8020d2:	75 2d                	jne    802101 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020d4:	85 f6                	test   %esi,%esi
  8020d6:	74 0d                	je     8020e5 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8020dd:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020e3:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020e5:	85 db                	test   %ebx,%ebx
  8020e7:	74 0d                	je     8020f6 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ee:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8020f4:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8020fb:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802101:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802104:	5b                   	pop    %ebx
  802105:	5e                   	pop    %esi
  802106:	5d                   	pop    %ebp
  802107:	c3                   	ret    

00802108 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	57                   	push   %edi
  80210c:	56                   	push   %esi
  80210d:	53                   	push   %ebx
  80210e:	83 ec 0c             	sub    $0xc,%esp
  802111:	8b 7d 08             	mov    0x8(%ebp),%edi
  802114:	8b 75 0c             	mov    0xc(%ebp),%esi
  802117:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80211a:	85 db                	test   %ebx,%ebx
  80211c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802121:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802124:	ff 75 14             	pushl  0x14(%ebp)
  802127:	53                   	push   %ebx
  802128:	56                   	push   %esi
  802129:	57                   	push   %edi
  80212a:	e8 eb e1 ff ff       	call   80031a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80212f:	89 c2                	mov    %eax,%edx
  802131:	c1 ea 1f             	shr    $0x1f,%edx
  802134:	83 c4 10             	add    $0x10,%esp
  802137:	84 d2                	test   %dl,%dl
  802139:	74 17                	je     802152 <ipc_send+0x4a>
  80213b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80213e:	74 12                	je     802152 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802140:	50                   	push   %eax
  802141:	68 4e 2a 80 00       	push   $0x802a4e
  802146:	6a 47                	push   $0x47
  802148:	68 5c 2a 80 00       	push   $0x802a5c
  80214d:	e8 07 f5 ff ff       	call   801659 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802152:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802155:	75 07                	jne    80215e <ipc_send+0x56>
			sys_yield();
  802157:	e8 12 e0 ff ff       	call   80016e <sys_yield>
  80215c:	eb c6                	jmp    802124 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80215e:	85 c0                	test   %eax,%eax
  802160:	75 c2                	jne    802124 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802165:	5b                   	pop    %ebx
  802166:	5e                   	pop    %esi
  802167:	5f                   	pop    %edi
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    

0080216a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802170:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802175:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80217b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802181:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802187:	39 ca                	cmp    %ecx,%edx
  802189:	75 13                	jne    80219e <ipc_find_env+0x34>
			return envs[i].env_id;
  80218b:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802191:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802196:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80219c:	eb 0f                	jmp    8021ad <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80219e:	83 c0 01             	add    $0x1,%eax
  8021a1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021a6:	75 cd                	jne    802175 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021ad:	5d                   	pop    %ebp
  8021ae:	c3                   	ret    

008021af <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	c1 e8 16             	shr    $0x16,%eax
  8021ba:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021c1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021c6:	f6 c1 01             	test   $0x1,%cl
  8021c9:	74 1d                	je     8021e8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021cb:	c1 ea 0c             	shr    $0xc,%edx
  8021ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021d5:	f6 c2 01             	test   $0x1,%dl
  8021d8:	74 0e                	je     8021e8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021da:	c1 ea 0c             	shr    $0xc,%edx
  8021dd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021e4:	ef 
  8021e5:	0f b7 c0             	movzwl %ax,%eax
}
  8021e8:	5d                   	pop    %ebp
  8021e9:	c3                   	ret    
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 f6                	test   %esi,%esi
  802209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80220d:	89 ca                	mov    %ecx,%edx
  80220f:	89 f8                	mov    %edi,%eax
  802211:	75 3d                	jne    802250 <__udivdi3+0x60>
  802213:	39 cf                	cmp    %ecx,%edi
  802215:	0f 87 c5 00 00 00    	ja     8022e0 <__udivdi3+0xf0>
  80221b:	85 ff                	test   %edi,%edi
  80221d:	89 fd                	mov    %edi,%ebp
  80221f:	75 0b                	jne    80222c <__udivdi3+0x3c>
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	31 d2                	xor    %edx,%edx
  802228:	f7 f7                	div    %edi
  80222a:	89 c5                	mov    %eax,%ebp
  80222c:	89 c8                	mov    %ecx,%eax
  80222e:	31 d2                	xor    %edx,%edx
  802230:	f7 f5                	div    %ebp
  802232:	89 c1                	mov    %eax,%ecx
  802234:	89 d8                	mov    %ebx,%eax
  802236:	89 cf                	mov    %ecx,%edi
  802238:	f7 f5                	div    %ebp
  80223a:	89 c3                	mov    %eax,%ebx
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
  802250:	39 ce                	cmp    %ecx,%esi
  802252:	77 74                	ja     8022c8 <__udivdi3+0xd8>
  802254:	0f bd fe             	bsr    %esi,%edi
  802257:	83 f7 1f             	xor    $0x1f,%edi
  80225a:	0f 84 98 00 00 00    	je     8022f8 <__udivdi3+0x108>
  802260:	bb 20 00 00 00       	mov    $0x20,%ebx
  802265:	89 f9                	mov    %edi,%ecx
  802267:	89 c5                	mov    %eax,%ebp
  802269:	29 fb                	sub    %edi,%ebx
  80226b:	d3 e6                	shl    %cl,%esi
  80226d:	89 d9                	mov    %ebx,%ecx
  80226f:	d3 ed                	shr    %cl,%ebp
  802271:	89 f9                	mov    %edi,%ecx
  802273:	d3 e0                	shl    %cl,%eax
  802275:	09 ee                	or     %ebp,%esi
  802277:	89 d9                	mov    %ebx,%ecx
  802279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227d:	89 d5                	mov    %edx,%ebp
  80227f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802283:	d3 ed                	shr    %cl,%ebp
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e2                	shl    %cl,%edx
  802289:	89 d9                	mov    %ebx,%ecx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	09 c2                	or     %eax,%edx
  80228f:	89 d0                	mov    %edx,%eax
  802291:	89 ea                	mov    %ebp,%edx
  802293:	f7 f6                	div    %esi
  802295:	89 d5                	mov    %edx,%ebp
  802297:	89 c3                	mov    %eax,%ebx
  802299:	f7 64 24 0c          	mull   0xc(%esp)
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	72 10                	jb     8022b1 <__udivdi3+0xc1>
  8022a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	d3 e6                	shl    %cl,%esi
  8022a9:	39 c6                	cmp    %eax,%esi
  8022ab:	73 07                	jae    8022b4 <__udivdi3+0xc4>
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	75 03                	jne    8022b4 <__udivdi3+0xc4>
  8022b1:	83 eb 01             	sub    $0x1,%ebx
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 d8                	mov    %ebx,%eax
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	83 c4 1c             	add    $0x1c,%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    
  8022c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c8:	31 ff                	xor    %edi,%edi
  8022ca:	31 db                	xor    %ebx,%ebx
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	89 fa                	mov    %edi,%edx
  8022d0:	83 c4 1c             	add    $0x1c,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	89 d8                	mov    %ebx,%eax
  8022e2:	f7 f7                	div    %edi
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 c3                	mov    %eax,%ebx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 fa                	mov    %edi,%edx
  8022ec:	83 c4 1c             	add    $0x1c,%esp
  8022ef:	5b                   	pop    %ebx
  8022f0:	5e                   	pop    %esi
  8022f1:	5f                   	pop    %edi
  8022f2:	5d                   	pop    %ebp
  8022f3:	c3                   	ret    
  8022f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	39 ce                	cmp    %ecx,%esi
  8022fa:	72 0c                	jb     802308 <__udivdi3+0x118>
  8022fc:	31 db                	xor    %ebx,%ebx
  8022fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802302:	0f 87 34 ff ff ff    	ja     80223c <__udivdi3+0x4c>
  802308:	bb 01 00 00 00       	mov    $0x1,%ebx
  80230d:	e9 2a ff ff ff       	jmp    80223c <__udivdi3+0x4c>
  802312:	66 90                	xchg   %ax,%ax
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__umoddi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	53                   	push   %ebx
  802324:	83 ec 1c             	sub    $0x1c,%esp
  802327:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80232b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80232f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802333:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802337:	85 d2                	test   %edx,%edx
  802339:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80233d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802341:	89 f3                	mov    %esi,%ebx
  802343:	89 3c 24             	mov    %edi,(%esp)
  802346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80234a:	75 1c                	jne    802368 <__umoddi3+0x48>
  80234c:	39 f7                	cmp    %esi,%edi
  80234e:	76 50                	jbe    8023a0 <__umoddi3+0x80>
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	f7 f7                	div    %edi
  802356:	89 d0                	mov    %edx,%eax
  802358:	31 d2                	xor    %edx,%edx
  80235a:	83 c4 1c             	add    $0x1c,%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5f                   	pop    %edi
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    
  802362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802368:	39 f2                	cmp    %esi,%edx
  80236a:	89 d0                	mov    %edx,%eax
  80236c:	77 52                	ja     8023c0 <__umoddi3+0xa0>
  80236e:	0f bd ea             	bsr    %edx,%ebp
  802371:	83 f5 1f             	xor    $0x1f,%ebp
  802374:	75 5a                	jne    8023d0 <__umoddi3+0xb0>
  802376:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80237a:	0f 82 e0 00 00 00    	jb     802460 <__umoddi3+0x140>
  802380:	39 0c 24             	cmp    %ecx,(%esp)
  802383:	0f 86 d7 00 00 00    	jbe    802460 <__umoddi3+0x140>
  802389:	8b 44 24 08          	mov    0x8(%esp),%eax
  80238d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802391:	83 c4 1c             	add    $0x1c,%esp
  802394:	5b                   	pop    %ebx
  802395:	5e                   	pop    %esi
  802396:	5f                   	pop    %edi
  802397:	5d                   	pop    %ebp
  802398:	c3                   	ret    
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	85 ff                	test   %edi,%edi
  8023a2:	89 fd                	mov    %edi,%ebp
  8023a4:	75 0b                	jne    8023b1 <__umoddi3+0x91>
  8023a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	f7 f7                	div    %edi
  8023af:	89 c5                	mov    %eax,%ebp
  8023b1:	89 f0                	mov    %esi,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f5                	div    %ebp
  8023b7:	89 c8                	mov    %ecx,%eax
  8023b9:	f7 f5                	div    %ebp
  8023bb:	89 d0                	mov    %edx,%eax
  8023bd:	eb 99                	jmp    802358 <__umoddi3+0x38>
  8023bf:	90                   	nop
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 f2                	mov    %esi,%edx
  8023c4:	83 c4 1c             	add    $0x1c,%esp
  8023c7:	5b                   	pop    %ebx
  8023c8:	5e                   	pop    %esi
  8023c9:	5f                   	pop    %edi
  8023ca:	5d                   	pop    %ebp
  8023cb:	c3                   	ret    
  8023cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	8b 34 24             	mov    (%esp),%esi
  8023d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023d8:	89 e9                	mov    %ebp,%ecx
  8023da:	29 ef                	sub    %ebp,%edi
  8023dc:	d3 e0                	shl    %cl,%eax
  8023de:	89 f9                	mov    %edi,%ecx
  8023e0:	89 f2                	mov    %esi,%edx
  8023e2:	d3 ea                	shr    %cl,%edx
  8023e4:	89 e9                	mov    %ebp,%ecx
  8023e6:	09 c2                	or     %eax,%edx
  8023e8:	89 d8                	mov    %ebx,%eax
  8023ea:	89 14 24             	mov    %edx,(%esp)
  8023ed:	89 f2                	mov    %esi,%edx
  8023ef:	d3 e2                	shl    %cl,%edx
  8023f1:	89 f9                	mov    %edi,%ecx
  8023f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023fb:	d3 e8                	shr    %cl,%eax
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	89 c6                	mov    %eax,%esi
  802401:	d3 e3                	shl    %cl,%ebx
  802403:	89 f9                	mov    %edi,%ecx
  802405:	89 d0                	mov    %edx,%eax
  802407:	d3 e8                	shr    %cl,%eax
  802409:	89 e9                	mov    %ebp,%ecx
  80240b:	09 d8                	or     %ebx,%eax
  80240d:	89 d3                	mov    %edx,%ebx
  80240f:	89 f2                	mov    %esi,%edx
  802411:	f7 34 24             	divl   (%esp)
  802414:	89 d6                	mov    %edx,%esi
  802416:	d3 e3                	shl    %cl,%ebx
  802418:	f7 64 24 04          	mull   0x4(%esp)
  80241c:	39 d6                	cmp    %edx,%esi
  80241e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802422:	89 d1                	mov    %edx,%ecx
  802424:	89 c3                	mov    %eax,%ebx
  802426:	72 08                	jb     802430 <__umoddi3+0x110>
  802428:	75 11                	jne    80243b <__umoddi3+0x11b>
  80242a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80242e:	73 0b                	jae    80243b <__umoddi3+0x11b>
  802430:	2b 44 24 04          	sub    0x4(%esp),%eax
  802434:	1b 14 24             	sbb    (%esp),%edx
  802437:	89 d1                	mov    %edx,%ecx
  802439:	89 c3                	mov    %eax,%ebx
  80243b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80243f:	29 da                	sub    %ebx,%edx
  802441:	19 ce                	sbb    %ecx,%esi
  802443:	89 f9                	mov    %edi,%ecx
  802445:	89 f0                	mov    %esi,%eax
  802447:	d3 e0                	shl    %cl,%eax
  802449:	89 e9                	mov    %ebp,%ecx
  80244b:	d3 ea                	shr    %cl,%edx
  80244d:	89 e9                	mov    %ebp,%ecx
  80244f:	d3 ee                	shr    %cl,%esi
  802451:	09 d0                	or     %edx,%eax
  802453:	89 f2                	mov    %esi,%edx
  802455:	83 c4 1c             	add    $0x1c,%esp
  802458:	5b                   	pop    %ebx
  802459:	5e                   	pop    %esi
  80245a:	5f                   	pop    %edi
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    
  80245d:	8d 76 00             	lea    0x0(%esi),%esi
  802460:	29 f9                	sub    %edi,%ecx
  802462:	19 d6                	sbb    %edx,%esi
  802464:	89 74 24 04          	mov    %esi,0x4(%esp)
  802468:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80246c:	e9 18 ff ff ff       	jmp    802389 <__umoddi3+0x69>
