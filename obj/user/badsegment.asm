
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 f1 00 00 00       	call   80013f <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x30>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 2a 00 00 00       	call   8000a7 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80008d:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800092:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800094:	e8 a6 00 00 00       	call   80013f <sys_getenvid>
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	50                   	push   %eax
  80009d:	e8 ec 02 00 00       	call   80038e <sys_thread_free>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ad:	e8 66 0a 00 00       	call   800b18 <close_all>
	sys_env_destroy(0);
  8000b2:	83 ec 0c             	sub    $0xc,%esp
  8000b5:	6a 00                	push   $0x0
  8000b7:	e8 42 00 00 00       	call   8000fe <sys_env_destroy>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d2:	89 c3                	mov    %eax,%ebx
  8000d4:	89 c7                	mov    %eax,%edi
  8000d6:	89 c6                	mov    %eax,%esi
  8000d8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_cgetc>:

int
sys_cgetc(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ef:	89 d1                	mov    %edx,%ecx
  8000f1:	89 d3                	mov    %edx,%ebx
  8000f3:	89 d7                	mov    %edx,%edi
  8000f5:	89 d6                	mov    %edx,%esi
  8000f7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
  800104:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800107:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010c:	b8 03 00 00 00       	mov    $0x3,%eax
  800111:	8b 55 08             	mov    0x8(%ebp),%edx
  800114:	89 cb                	mov    %ecx,%ebx
  800116:	89 cf                	mov    %ecx,%edi
  800118:	89 ce                	mov    %ecx,%esi
  80011a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011c:	85 c0                	test   %eax,%eax
  80011e:	7e 17                	jle    800137 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800120:	83 ec 0c             	sub    $0xc,%esp
  800123:	50                   	push   %eax
  800124:	6a 03                	push   $0x3
  800126:	68 8a 24 80 00       	push   $0x80248a
  80012b:	6a 23                	push   $0x23
  80012d:	68 a7 24 80 00       	push   $0x8024a7
  800132:	e8 12 15 00 00       	call   801649 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800137:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 02 00 00 00       	mov    $0x2,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_yield>:

void
sys_yield(void)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	ba 00 00 00 00       	mov    $0x0,%edx
  800169:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016e:	89 d1                	mov    %edx,%ecx
  800170:	89 d3                	mov    %edx,%ebx
  800172:	89 d7                	mov    %edx,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5f                   	pop    %edi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	57                   	push   %edi
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
  800183:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800186:	be 00 00 00 00       	mov    $0x0,%esi
  80018b:	b8 04 00 00 00       	mov    $0x4,%eax
  800190:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800193:	8b 55 08             	mov    0x8(%ebp),%edx
  800196:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800199:	89 f7                	mov    %esi,%edi
  80019b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80019d:	85 c0                	test   %eax,%eax
  80019f:	7e 17                	jle    8001b8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a1:	83 ec 0c             	sub    $0xc,%esp
  8001a4:	50                   	push   %eax
  8001a5:	6a 04                	push   $0x4
  8001a7:	68 8a 24 80 00       	push   $0x80248a
  8001ac:	6a 23                	push   $0x23
  8001ae:	68 a7 24 80 00       	push   $0x8024a7
  8001b3:	e8 91 14 00 00       	call   801649 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bb:	5b                   	pop    %ebx
  8001bc:	5e                   	pop    %esi
  8001bd:	5f                   	pop    %edi
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    

008001c0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001da:	8b 75 18             	mov    0x18(%ebp),%esi
  8001dd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001df:	85 c0                	test   %eax,%eax
  8001e1:	7e 17                	jle    8001fa <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e3:	83 ec 0c             	sub    $0xc,%esp
  8001e6:	50                   	push   %eax
  8001e7:	6a 05                	push   $0x5
  8001e9:	68 8a 24 80 00       	push   $0x80248a
  8001ee:	6a 23                	push   $0x23
  8001f0:	68 a7 24 80 00       	push   $0x8024a7
  8001f5:	e8 4f 14 00 00       	call   801649 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fd:	5b                   	pop    %ebx
  8001fe:	5e                   	pop    %esi
  8001ff:	5f                   	pop    %edi
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    

00800202 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800210:	b8 06 00 00 00       	mov    $0x6,%eax
  800215:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800218:	8b 55 08             	mov    0x8(%ebp),%edx
  80021b:	89 df                	mov    %ebx,%edi
  80021d:	89 de                	mov    %ebx,%esi
  80021f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800221:	85 c0                	test   %eax,%eax
  800223:	7e 17                	jle    80023c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800225:	83 ec 0c             	sub    $0xc,%esp
  800228:	50                   	push   %eax
  800229:	6a 06                	push   $0x6
  80022b:	68 8a 24 80 00       	push   $0x80248a
  800230:	6a 23                	push   $0x23
  800232:	68 a7 24 80 00       	push   $0x8024a7
  800237:	e8 0d 14 00 00       	call   801649 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80023c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    

00800244 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	57                   	push   %edi
  800248:	56                   	push   %esi
  800249:	53                   	push   %ebx
  80024a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800252:	b8 08 00 00 00       	mov    $0x8,%eax
  800257:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025a:	8b 55 08             	mov    0x8(%ebp),%edx
  80025d:	89 df                	mov    %ebx,%edi
  80025f:	89 de                	mov    %ebx,%esi
  800261:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800263:	85 c0                	test   %eax,%eax
  800265:	7e 17                	jle    80027e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800267:	83 ec 0c             	sub    $0xc,%esp
  80026a:	50                   	push   %eax
  80026b:	6a 08                	push   $0x8
  80026d:	68 8a 24 80 00       	push   $0x80248a
  800272:	6a 23                	push   $0x23
  800274:	68 a7 24 80 00       	push   $0x8024a7
  800279:	e8 cb 13 00 00       	call   801649 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	57                   	push   %edi
  80028a:	56                   	push   %esi
  80028b:	53                   	push   %ebx
  80028c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800294:	b8 09 00 00 00       	mov    $0x9,%eax
  800299:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029c:	8b 55 08             	mov    0x8(%ebp),%edx
  80029f:	89 df                	mov    %ebx,%edi
  8002a1:	89 de                	mov    %ebx,%esi
  8002a3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a5:	85 c0                	test   %eax,%eax
  8002a7:	7e 17                	jle    8002c0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a9:	83 ec 0c             	sub    $0xc,%esp
  8002ac:	50                   	push   %eax
  8002ad:	6a 09                	push   $0x9
  8002af:	68 8a 24 80 00       	push   $0x80248a
  8002b4:	6a 23                	push   $0x23
  8002b6:	68 a7 24 80 00       	push   $0x8024a7
  8002bb:	e8 89 13 00 00       	call   801649 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c3:	5b                   	pop    %ebx
  8002c4:	5e                   	pop    %esi
  8002c5:	5f                   	pop    %edi
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	57                   	push   %edi
  8002cc:	56                   	push   %esi
  8002cd:	53                   	push   %ebx
  8002ce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002de:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e1:	89 df                	mov    %ebx,%edi
  8002e3:	89 de                	mov    %ebx,%esi
  8002e5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	7e 17                	jle    800302 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002eb:	83 ec 0c             	sub    $0xc,%esp
  8002ee:	50                   	push   %eax
  8002ef:	6a 0a                	push   $0xa
  8002f1:	68 8a 24 80 00       	push   $0x80248a
  8002f6:	6a 23                	push   $0x23
  8002f8:	68 a7 24 80 00       	push   $0x8024a7
  8002fd:	e8 47 13 00 00       	call   801649 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800310:	be 00 00 00 00       	mov    $0x0,%esi
  800315:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800323:	8b 7d 14             	mov    0x14(%ebp),%edi
  800326:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800328:	5b                   	pop    %ebx
  800329:	5e                   	pop    %esi
  80032a:	5f                   	pop    %edi
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
  800333:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800336:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800340:	8b 55 08             	mov    0x8(%ebp),%edx
  800343:	89 cb                	mov    %ecx,%ebx
  800345:	89 cf                	mov    %ecx,%edi
  800347:	89 ce                	mov    %ecx,%esi
  800349:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034b:	85 c0                	test   %eax,%eax
  80034d:	7e 17                	jle    800366 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034f:	83 ec 0c             	sub    $0xc,%esp
  800352:	50                   	push   %eax
  800353:	6a 0d                	push   $0xd
  800355:	68 8a 24 80 00       	push   $0x80248a
  80035a:	6a 23                	push   $0x23
  80035c:	68 a7 24 80 00       	push   $0x8024a7
  800361:	e8 e3 12 00 00       	call   801649 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800366:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	57                   	push   %edi
  800372:	56                   	push   %esi
  800373:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800374:	b9 00 00 00 00       	mov    $0x0,%ecx
  800379:	b8 0e 00 00 00       	mov    $0xe,%eax
  80037e:	8b 55 08             	mov    0x8(%ebp),%edx
  800381:	89 cb                	mov    %ecx,%ebx
  800383:	89 cf                	mov    %ecx,%edi
  800385:	89 ce                	mov    %ecx,%esi
  800387:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	57                   	push   %edi
  800392:	56                   	push   %esi
  800393:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800394:	b9 00 00 00 00       	mov    $0x0,%ecx
  800399:	b8 0f 00 00 00       	mov    $0xf,%eax
  80039e:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a1:	89 cb                	mov    %ecx,%ebx
  8003a3:	89 cf                	mov    %ecx,%edi
  8003a5:	89 ce                	mov    %ecx,%esi
  8003a7:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003a9:	5b                   	pop    %ebx
  8003aa:	5e                   	pop    %esi
  8003ab:	5f                   	pop    %edi
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b9:	b8 10 00 00 00       	mov    $0x10,%eax
  8003be:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c1:	89 cb                	mov    %ecx,%ebx
  8003c3:	89 cf                	mov    %ecx,%edi
  8003c5:	89 ce                	mov    %ecx,%esi
  8003c7:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8003c9:	5b                   	pop    %ebx
  8003ca:	5e                   	pop    %esi
  8003cb:	5f                   	pop    %edi
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	53                   	push   %ebx
  8003d2:	83 ec 04             	sub    $0x4,%esp
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003d8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003da:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003de:	74 11                	je     8003f1 <pgfault+0x23>
  8003e0:	89 d8                	mov    %ebx,%eax
  8003e2:	c1 e8 0c             	shr    $0xc,%eax
  8003e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003ec:	f6 c4 08             	test   $0x8,%ah
  8003ef:	75 14                	jne    800405 <pgfault+0x37>
		panic("faulting access");
  8003f1:	83 ec 04             	sub    $0x4,%esp
  8003f4:	68 b5 24 80 00       	push   $0x8024b5
  8003f9:	6a 1f                	push   $0x1f
  8003fb:	68 c5 24 80 00       	push   $0x8024c5
  800400:	e8 44 12 00 00       	call   801649 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800405:	83 ec 04             	sub    $0x4,%esp
  800408:	6a 07                	push   $0x7
  80040a:	68 00 f0 7f 00       	push   $0x7ff000
  80040f:	6a 00                	push   $0x0
  800411:	e8 67 fd ff ff       	call   80017d <sys_page_alloc>
	if (r < 0) {
  800416:	83 c4 10             	add    $0x10,%esp
  800419:	85 c0                	test   %eax,%eax
  80041b:	79 12                	jns    80042f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80041d:	50                   	push   %eax
  80041e:	68 d0 24 80 00       	push   $0x8024d0
  800423:	6a 2d                	push   $0x2d
  800425:	68 c5 24 80 00       	push   $0x8024c5
  80042a:	e8 1a 12 00 00       	call   801649 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80042f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800435:	83 ec 04             	sub    $0x4,%esp
  800438:	68 00 10 00 00       	push   $0x1000
  80043d:	53                   	push   %ebx
  80043e:	68 00 f0 7f 00       	push   $0x7ff000
  800443:	e8 59 1a 00 00       	call   801ea1 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800448:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80044f:	53                   	push   %ebx
  800450:	6a 00                	push   $0x0
  800452:	68 00 f0 7f 00       	push   $0x7ff000
  800457:	6a 00                	push   $0x0
  800459:	e8 62 fd ff ff       	call   8001c0 <sys_page_map>
	if (r < 0) {
  80045e:	83 c4 20             	add    $0x20,%esp
  800461:	85 c0                	test   %eax,%eax
  800463:	79 12                	jns    800477 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800465:	50                   	push   %eax
  800466:	68 d0 24 80 00       	push   $0x8024d0
  80046b:	6a 34                	push   $0x34
  80046d:	68 c5 24 80 00       	push   $0x8024c5
  800472:	e8 d2 11 00 00       	call   801649 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	68 00 f0 7f 00       	push   $0x7ff000
  80047f:	6a 00                	push   $0x0
  800481:	e8 7c fd ff ff       	call   800202 <sys_page_unmap>
	if (r < 0) {
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 c0                	test   %eax,%eax
  80048b:	79 12                	jns    80049f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80048d:	50                   	push   %eax
  80048e:	68 d0 24 80 00       	push   $0x8024d0
  800493:	6a 38                	push   $0x38
  800495:	68 c5 24 80 00       	push   $0x8024c5
  80049a:	e8 aa 11 00 00       	call   801649 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80049f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004a2:	c9                   	leave  
  8004a3:	c3                   	ret    

008004a4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	57                   	push   %edi
  8004a8:	56                   	push   %esi
  8004a9:	53                   	push   %ebx
  8004aa:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004ad:	68 ce 03 80 00       	push   $0x8003ce
  8004b2:	e8 37 1b 00 00       	call   801fee <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004b7:	b8 07 00 00 00       	mov    $0x7,%eax
  8004bc:	cd 30                	int    $0x30
  8004be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	85 c0                	test   %eax,%eax
  8004c6:	79 17                	jns    8004df <fork+0x3b>
		panic("fork fault %e");
  8004c8:	83 ec 04             	sub    $0x4,%esp
  8004cb:	68 e9 24 80 00       	push   $0x8024e9
  8004d0:	68 85 00 00 00       	push   $0x85
  8004d5:	68 c5 24 80 00       	push   $0x8024c5
  8004da:	e8 6a 11 00 00       	call   801649 <_panic>
  8004df:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e5:	75 24                	jne    80050b <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004e7:	e8 53 fc ff ff       	call   80013f <sys_getenvid>
  8004ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004f1:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8004f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004fc:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800501:	b8 00 00 00 00       	mov    $0x0,%eax
  800506:	e9 64 01 00 00       	jmp    80066f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80050b:	83 ec 04             	sub    $0x4,%esp
  80050e:	6a 07                	push   $0x7
  800510:	68 00 f0 bf ee       	push   $0xeebff000
  800515:	ff 75 e4             	pushl  -0x1c(%ebp)
  800518:	e8 60 fc ff ff       	call   80017d <sys_page_alloc>
  80051d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800520:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800525:	89 d8                	mov    %ebx,%eax
  800527:	c1 e8 16             	shr    $0x16,%eax
  80052a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800531:	a8 01                	test   $0x1,%al
  800533:	0f 84 fc 00 00 00    	je     800635 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800539:	89 d8                	mov    %ebx,%eax
  80053b:	c1 e8 0c             	shr    $0xc,%eax
  80053e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800545:	f6 c2 01             	test   $0x1,%dl
  800548:	0f 84 e7 00 00 00    	je     800635 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80054e:	89 c6                	mov    %eax,%esi
  800550:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800553:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80055a:	f6 c6 04             	test   $0x4,%dh
  80055d:	74 39                	je     800598 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80055f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800566:	83 ec 0c             	sub    $0xc,%esp
  800569:	25 07 0e 00 00       	and    $0xe07,%eax
  80056e:	50                   	push   %eax
  80056f:	56                   	push   %esi
  800570:	57                   	push   %edi
  800571:	56                   	push   %esi
  800572:	6a 00                	push   $0x0
  800574:	e8 47 fc ff ff       	call   8001c0 <sys_page_map>
		if (r < 0) {
  800579:	83 c4 20             	add    $0x20,%esp
  80057c:	85 c0                	test   %eax,%eax
  80057e:	0f 89 b1 00 00 00    	jns    800635 <fork+0x191>
		    	panic("sys page map fault %e");
  800584:	83 ec 04             	sub    $0x4,%esp
  800587:	68 f7 24 80 00       	push   $0x8024f7
  80058c:	6a 55                	push   $0x55
  80058e:	68 c5 24 80 00       	push   $0x8024c5
  800593:	e8 b1 10 00 00       	call   801649 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800598:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80059f:	f6 c2 02             	test   $0x2,%dl
  8005a2:	75 0c                	jne    8005b0 <fork+0x10c>
  8005a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ab:	f6 c4 08             	test   $0x8,%ah
  8005ae:	74 5b                	je     80060b <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	68 05 08 00 00       	push   $0x805
  8005b8:	56                   	push   %esi
  8005b9:	57                   	push   %edi
  8005ba:	56                   	push   %esi
  8005bb:	6a 00                	push   $0x0
  8005bd:	e8 fe fb ff ff       	call   8001c0 <sys_page_map>
		if (r < 0) {
  8005c2:	83 c4 20             	add    $0x20,%esp
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	79 14                	jns    8005dd <fork+0x139>
		    	panic("sys page map fault %e");
  8005c9:	83 ec 04             	sub    $0x4,%esp
  8005cc:	68 f7 24 80 00       	push   $0x8024f7
  8005d1:	6a 5c                	push   $0x5c
  8005d3:	68 c5 24 80 00       	push   $0x8024c5
  8005d8:	e8 6c 10 00 00       	call   801649 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005dd:	83 ec 0c             	sub    $0xc,%esp
  8005e0:	68 05 08 00 00       	push   $0x805
  8005e5:	56                   	push   %esi
  8005e6:	6a 00                	push   $0x0
  8005e8:	56                   	push   %esi
  8005e9:	6a 00                	push   $0x0
  8005eb:	e8 d0 fb ff ff       	call   8001c0 <sys_page_map>
		if (r < 0) {
  8005f0:	83 c4 20             	add    $0x20,%esp
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	79 3e                	jns    800635 <fork+0x191>
		    	panic("sys page map fault %e");
  8005f7:	83 ec 04             	sub    $0x4,%esp
  8005fa:	68 f7 24 80 00       	push   $0x8024f7
  8005ff:	6a 60                	push   $0x60
  800601:	68 c5 24 80 00       	push   $0x8024c5
  800606:	e8 3e 10 00 00       	call   801649 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	6a 05                	push   $0x5
  800610:	56                   	push   %esi
  800611:	57                   	push   %edi
  800612:	56                   	push   %esi
  800613:	6a 00                	push   $0x0
  800615:	e8 a6 fb ff ff       	call   8001c0 <sys_page_map>
		if (r < 0) {
  80061a:	83 c4 20             	add    $0x20,%esp
  80061d:	85 c0                	test   %eax,%eax
  80061f:	79 14                	jns    800635 <fork+0x191>
		    	panic("sys page map fault %e");
  800621:	83 ec 04             	sub    $0x4,%esp
  800624:	68 f7 24 80 00       	push   $0x8024f7
  800629:	6a 65                	push   $0x65
  80062b:	68 c5 24 80 00       	push   $0x8024c5
  800630:	e8 14 10 00 00       	call   801649 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800635:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80063b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800641:	0f 85 de fe ff ff    	jne    800525 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800647:	a1 04 40 80 00       	mov    0x804004,%eax
  80064c:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	50                   	push   %eax
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800659:	57                   	push   %edi
  80065a:	e8 69 fc ff ff       	call   8002c8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80065f:	83 c4 08             	add    $0x8,%esp
  800662:	6a 02                	push   $0x2
  800664:	57                   	push   %edi
  800665:	e8 da fb ff ff       	call   800244 <sys_env_set_status>
	
	return envid;
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80066f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800672:	5b                   	pop    %ebx
  800673:	5e                   	pop    %esi
  800674:	5f                   	pop    %edi
  800675:	5d                   	pop    %ebp
  800676:	c3                   	ret    

00800677 <sfork>:

envid_t
sfork(void)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80067a:	b8 00 00 00 00       	mov    $0x0,%eax
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    

00800681 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	56                   	push   %esi
  800685:	53                   	push   %ebx
  800686:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800689:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	68 88 25 80 00       	push   $0x802588
  800698:	e8 85 10 00 00       	call   801722 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80069d:	c7 04 24 87 00 80 00 	movl   $0x800087,(%esp)
  8006a4:	e8 c5 fc ff ff       	call   80036e <sys_thread_create>
  8006a9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	68 88 25 80 00       	push   $0x802588
  8006b4:	e8 69 10 00 00       	call   801722 <cprintf>
	return id;
}
  8006b9:	89 f0                	mov    %esi,%eax
  8006bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006be:	5b                   	pop    %ebx
  8006bf:	5e                   	pop    %esi
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8006c8:	ff 75 08             	pushl  0x8(%ebp)
  8006cb:	e8 be fc ff ff       	call   80038e <sys_thread_free>
}
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    

008006d5 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8006db:	ff 75 08             	pushl  0x8(%ebp)
  8006de:	e8 cb fc ff ff       	call   8003ae <sys_thread_join>
}
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
  8006ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006f3:	83 ec 04             	sub    $0x4,%esp
  8006f6:	6a 07                	push   $0x7
  8006f8:	6a 00                	push   $0x0
  8006fa:	56                   	push   %esi
  8006fb:	e8 7d fa ff ff       	call   80017d <sys_page_alloc>
	if (r < 0) {
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 c0                	test   %eax,%eax
  800705:	79 15                	jns    80071c <queue_append+0x34>
		panic("%e\n", r);
  800707:	50                   	push   %eax
  800708:	68 83 25 80 00       	push   $0x802583
  80070d:	68 c4 00 00 00       	push   $0xc4
  800712:	68 c5 24 80 00       	push   $0x8024c5
  800717:	e8 2d 0f 00 00       	call   801649 <_panic>
	}	
	wt->envid = envid;
  80071c:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  800722:	83 ec 04             	sub    $0x4,%esp
  800725:	ff 33                	pushl  (%ebx)
  800727:	56                   	push   %esi
  800728:	68 ac 25 80 00       	push   $0x8025ac
  80072d:	e8 f0 0f 00 00       	call   801722 <cprintf>
	if (queue->first == NULL) {
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	83 3b 00             	cmpl   $0x0,(%ebx)
  800738:	75 29                	jne    800763 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80073a:	83 ec 0c             	sub    $0xc,%esp
  80073d:	68 0d 25 80 00       	push   $0x80250d
  800742:	e8 db 0f 00 00       	call   801722 <cprintf>
		queue->first = wt;
  800747:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  80074d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800754:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80075b:	00 00 00 
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	eb 2b                	jmp    80078e <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  800763:	83 ec 0c             	sub    $0xc,%esp
  800766:	68 27 25 80 00       	push   $0x802527
  80076b:	e8 b2 0f 00 00       	call   801722 <cprintf>
		queue->last->next = wt;
  800770:	8b 43 04             	mov    0x4(%ebx),%eax
  800773:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80077a:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800781:	00 00 00 
		queue->last = wt;
  800784:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80078b:	83 c4 10             	add    $0x10,%esp
	}
}
  80078e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	53                   	push   %ebx
  800799:	83 ec 04             	sub    $0x4,%esp
  80079c:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80079f:	8b 02                	mov    (%edx),%eax
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	75 17                	jne    8007bc <queue_pop+0x27>
		panic("queue empty!\n");
  8007a5:	83 ec 04             	sub    $0x4,%esp
  8007a8:	68 45 25 80 00       	push   $0x802545
  8007ad:	68 d8 00 00 00       	push   $0xd8
  8007b2:	68 c5 24 80 00       	push   $0x8024c5
  8007b7:	e8 8d 0e 00 00       	call   801649 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8007bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8007bf:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8007c1:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	68 53 25 80 00       	push   $0x802553
  8007cc:	e8 51 0f 00 00       	call   801722 <cprintf>
	return envid;
}
  8007d1:	89 d8                	mov    %ebx,%eax
  8007d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	83 ec 04             	sub    $0x4,%esp
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8007e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8007e7:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	74 5a                	je     800848 <mutex_lock+0x70>
  8007ee:	8b 43 04             	mov    0x4(%ebx),%eax
  8007f1:	83 38 00             	cmpl   $0x0,(%eax)
  8007f4:	75 52                	jne    800848 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8007f6:	83 ec 0c             	sub    $0xc,%esp
  8007f9:	68 d4 25 80 00       	push   $0x8025d4
  8007fe:	e8 1f 0f 00 00       	call   801722 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  800803:	8b 5b 04             	mov    0x4(%ebx),%ebx
  800806:	e8 34 f9 ff ff       	call   80013f <sys_getenvid>
  80080b:	83 c4 08             	add    $0x8,%esp
  80080e:	53                   	push   %ebx
  80080f:	50                   	push   %eax
  800810:	e8 d3 fe ff ff       	call   8006e8 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800815:	e8 25 f9 ff ff       	call   80013f <sys_getenvid>
  80081a:	83 c4 08             	add    $0x8,%esp
  80081d:	6a 04                	push   $0x4
  80081f:	50                   	push   %eax
  800820:	e8 1f fa ff ff       	call   800244 <sys_env_set_status>
		if (r < 0) {
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	85 c0                	test   %eax,%eax
  80082a:	79 15                	jns    800841 <mutex_lock+0x69>
			panic("%e\n", r);
  80082c:	50                   	push   %eax
  80082d:	68 83 25 80 00       	push   $0x802583
  800832:	68 eb 00 00 00       	push   $0xeb
  800837:	68 c5 24 80 00       	push   $0x8024c5
  80083c:	e8 08 0e 00 00       	call   801649 <_panic>
		}
		sys_yield();
  800841:	e8 18 f9 ff ff       	call   80015e <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800846:	eb 18                	jmp    800860 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  800848:	83 ec 0c             	sub    $0xc,%esp
  80084b:	68 f4 25 80 00       	push   $0x8025f4
  800850:	e8 cd 0e 00 00       	call   801722 <cprintf>
	mtx->owner = sys_getenvid();}
  800855:	e8 e5 f8 ff ff       	call   80013f <sys_getenvid>
  80085a:	89 43 08             	mov    %eax,0x8(%ebx)
  80085d:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  800860:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	53                   	push   %ebx
  800869:	83 ec 04             	sub    $0x4,%esp
  80086c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
  800874:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  800877:	8b 43 04             	mov    0x4(%ebx),%eax
  80087a:	83 38 00             	cmpl   $0x0,(%eax)
  80087d:	74 33                	je     8008b2 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80087f:	83 ec 0c             	sub    $0xc,%esp
  800882:	50                   	push   %eax
  800883:	e8 0d ff ff ff       	call   800795 <queue_pop>
  800888:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80088b:	83 c4 08             	add    $0x8,%esp
  80088e:	6a 02                	push   $0x2
  800890:	50                   	push   %eax
  800891:	e8 ae f9 ff ff       	call   800244 <sys_env_set_status>
		if (r < 0) {
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	79 15                	jns    8008b2 <mutex_unlock+0x4d>
			panic("%e\n", r);
  80089d:	50                   	push   %eax
  80089e:	68 83 25 80 00       	push   $0x802583
  8008a3:	68 00 01 00 00       	push   $0x100
  8008a8:	68 c5 24 80 00       	push   $0x8024c5
  8008ad:	e8 97 0d 00 00       	call   801649 <_panic>
		}
	}

	asm volatile("pause");
  8008b2:	f3 90                	pause  
	//sys_yield();
}
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	83 ec 04             	sub    $0x4,%esp
  8008c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8008c3:	e8 77 f8 ff ff       	call   80013f <sys_getenvid>
  8008c8:	83 ec 04             	sub    $0x4,%esp
  8008cb:	6a 07                	push   $0x7
  8008cd:	53                   	push   %ebx
  8008ce:	50                   	push   %eax
  8008cf:	e8 a9 f8 ff ff       	call   80017d <sys_page_alloc>
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	85 c0                	test   %eax,%eax
  8008d9:	79 15                	jns    8008f0 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8008db:	50                   	push   %eax
  8008dc:	68 6e 25 80 00       	push   $0x80256e
  8008e1:	68 0d 01 00 00       	push   $0x10d
  8008e6:	68 c5 24 80 00       	push   $0x8024c5
  8008eb:	e8 59 0d 00 00       	call   801649 <_panic>
	}	
	mtx->locked = 0;
  8008f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8008f6:	8b 43 04             	mov    0x4(%ebx),%eax
  8008f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8008ff:	8b 43 04             	mov    0x4(%ebx),%eax
  800902:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800909:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  800910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80091b:	e8 1f f8 ff ff       	call   80013f <sys_getenvid>
  800920:	83 ec 08             	sub    $0x8,%esp
  800923:	ff 75 08             	pushl  0x8(%ebp)
  800926:	50                   	push   %eax
  800927:	e8 d6 f8 ff ff       	call   800202 <sys_page_unmap>
	if (r < 0) {
  80092c:	83 c4 10             	add    $0x10,%esp
  80092f:	85 c0                	test   %eax,%eax
  800931:	79 15                	jns    800948 <mutex_destroy+0x33>
		panic("%e\n", r);
  800933:	50                   	push   %eax
  800934:	68 83 25 80 00       	push   $0x802583
  800939:	68 1a 01 00 00       	push   $0x11a
  80093e:	68 c5 24 80 00       	push   $0x8024c5
  800943:	e8 01 0d 00 00       	call   801649 <_panic>
	}
}
  800948:	c9                   	leave  
  800949:	c3                   	ret    

0080094a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	05 00 00 00 30       	add    $0x30000000,%eax
  800955:	c1 e8 0c             	shr    $0xc,%eax
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	05 00 00 00 30       	add    $0x30000000,%eax
  800965:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80096a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800977:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80097c:	89 c2                	mov    %eax,%edx
  80097e:	c1 ea 16             	shr    $0x16,%edx
  800981:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800988:	f6 c2 01             	test   $0x1,%dl
  80098b:	74 11                	je     80099e <fd_alloc+0x2d>
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	c1 ea 0c             	shr    $0xc,%edx
  800992:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800999:	f6 c2 01             	test   $0x1,%dl
  80099c:	75 09                	jne    8009a7 <fd_alloc+0x36>
			*fd_store = fd;
  80099e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a5:	eb 17                	jmp    8009be <fd_alloc+0x4d>
  8009a7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8009ac:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8009b1:	75 c9                	jne    80097c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8009b3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8009b9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8009c6:	83 f8 1f             	cmp    $0x1f,%eax
  8009c9:	77 36                	ja     800a01 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8009cb:	c1 e0 0c             	shl    $0xc,%eax
  8009ce:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8009d3:	89 c2                	mov    %eax,%edx
  8009d5:	c1 ea 16             	shr    $0x16,%edx
  8009d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8009df:	f6 c2 01             	test   $0x1,%dl
  8009e2:	74 24                	je     800a08 <fd_lookup+0x48>
  8009e4:	89 c2                	mov    %eax,%edx
  8009e6:	c1 ea 0c             	shr    $0xc,%edx
  8009e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009f0:	f6 c2 01             	test   $0x1,%dl
  8009f3:	74 1a                	je     800a0f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8009f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f8:	89 02                	mov    %eax,(%edx)
	return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	eb 13                	jmp    800a14 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a06:	eb 0c                	jmp    800a14 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a0d:	eb 05                	jmp    800a14 <fd_lookup+0x54>
  800a0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	83 ec 08             	sub    $0x8,%esp
  800a1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1f:	ba 90 26 80 00       	mov    $0x802690,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800a24:	eb 13                	jmp    800a39 <dev_lookup+0x23>
  800a26:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800a29:	39 08                	cmp    %ecx,(%eax)
  800a2b:	75 0c                	jne    800a39 <dev_lookup+0x23>
			*dev = devtab[i];
  800a2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a30:	89 01                	mov    %eax,(%ecx)
			return 0;
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
  800a37:	eb 31                	jmp    800a6a <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800a39:	8b 02                	mov    (%edx),%eax
  800a3b:	85 c0                	test   %eax,%eax
  800a3d:	75 e7                	jne    800a26 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800a3f:	a1 04 40 80 00       	mov    0x804004,%eax
  800a44:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a4a:	83 ec 04             	sub    $0x4,%esp
  800a4d:	51                   	push   %ecx
  800a4e:	50                   	push   %eax
  800a4f:	68 14 26 80 00       	push   $0x802614
  800a54:	e8 c9 0c 00 00       	call   801722 <cprintf>
	*dev = 0;
  800a59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a62:	83 c4 10             	add    $0x10,%esp
  800a65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	83 ec 10             	sub    $0x10,%esp
  800a74:	8b 75 08             	mov    0x8(%ebp),%esi
  800a77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a7d:	50                   	push   %eax
  800a7e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a84:	c1 e8 0c             	shr    $0xc,%eax
  800a87:	50                   	push   %eax
  800a88:	e8 33 ff ff ff       	call   8009c0 <fd_lookup>
  800a8d:	83 c4 08             	add    $0x8,%esp
  800a90:	85 c0                	test   %eax,%eax
  800a92:	78 05                	js     800a99 <fd_close+0x2d>
	    || fd != fd2)
  800a94:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a97:	74 0c                	je     800aa5 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a99:	84 db                	test   %bl,%bl
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	0f 44 c2             	cmove  %edx,%eax
  800aa3:	eb 41                	jmp    800ae6 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800aa5:	83 ec 08             	sub    $0x8,%esp
  800aa8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aab:	50                   	push   %eax
  800aac:	ff 36                	pushl  (%esi)
  800aae:	e8 63 ff ff ff       	call   800a16 <dev_lookup>
  800ab3:	89 c3                	mov    %eax,%ebx
  800ab5:	83 c4 10             	add    $0x10,%esp
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	78 1a                	js     800ad6 <fd_close+0x6a>
		if (dev->dev_close)
  800abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800abf:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ac2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ac7:	85 c0                	test   %eax,%eax
  800ac9:	74 0b                	je     800ad6 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800acb:	83 ec 0c             	sub    $0xc,%esp
  800ace:	56                   	push   %esi
  800acf:	ff d0                	call   *%eax
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ad6:	83 ec 08             	sub    $0x8,%esp
  800ad9:	56                   	push   %esi
  800ada:	6a 00                	push   $0x0
  800adc:	e8 21 f7 ff ff       	call   800202 <sys_page_unmap>
	return r;
  800ae1:	83 c4 10             	add    $0x10,%esp
  800ae4:	89 d8                	mov    %ebx,%eax
}
  800ae6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800af3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af6:	50                   	push   %eax
  800af7:	ff 75 08             	pushl  0x8(%ebp)
  800afa:	e8 c1 fe ff ff       	call   8009c0 <fd_lookup>
  800aff:	83 c4 08             	add    $0x8,%esp
  800b02:	85 c0                	test   %eax,%eax
  800b04:	78 10                	js     800b16 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800b06:	83 ec 08             	sub    $0x8,%esp
  800b09:	6a 01                	push   $0x1
  800b0b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0e:	e8 59 ff ff ff       	call   800a6c <fd_close>
  800b13:	83 c4 10             	add    $0x10,%esp
}
  800b16:	c9                   	leave  
  800b17:	c3                   	ret    

00800b18 <close_all>:

void
close_all(void)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	53                   	push   %ebx
  800b1c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800b1f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800b24:	83 ec 0c             	sub    $0xc,%esp
  800b27:	53                   	push   %ebx
  800b28:	e8 c0 ff ff ff       	call   800aed <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b2d:	83 c3 01             	add    $0x1,%ebx
  800b30:	83 c4 10             	add    $0x10,%esp
  800b33:	83 fb 20             	cmp    $0x20,%ebx
  800b36:	75 ec                	jne    800b24 <close_all+0xc>
		close(i);
}
  800b38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3b:	c9                   	leave  
  800b3c:	c3                   	ret    

00800b3d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	83 ec 2c             	sub    $0x2c,%esp
  800b46:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b49:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b4c:	50                   	push   %eax
  800b4d:	ff 75 08             	pushl  0x8(%ebp)
  800b50:	e8 6b fe ff ff       	call   8009c0 <fd_lookup>
  800b55:	83 c4 08             	add    $0x8,%esp
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	0f 88 c1 00 00 00    	js     800c21 <dup+0xe4>
		return r;
	close(newfdnum);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	56                   	push   %esi
  800b64:	e8 84 ff ff ff       	call   800aed <close>

	newfd = INDEX2FD(newfdnum);
  800b69:	89 f3                	mov    %esi,%ebx
  800b6b:	c1 e3 0c             	shl    $0xc,%ebx
  800b6e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b74:	83 c4 04             	add    $0x4,%esp
  800b77:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b7a:	e8 db fd ff ff       	call   80095a <fd2data>
  800b7f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b81:	89 1c 24             	mov    %ebx,(%esp)
  800b84:	e8 d1 fd ff ff       	call   80095a <fd2data>
  800b89:	83 c4 10             	add    $0x10,%esp
  800b8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b8f:	89 f8                	mov    %edi,%eax
  800b91:	c1 e8 16             	shr    $0x16,%eax
  800b94:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b9b:	a8 01                	test   $0x1,%al
  800b9d:	74 37                	je     800bd6 <dup+0x99>
  800b9f:	89 f8                	mov    %edi,%eax
  800ba1:	c1 e8 0c             	shr    $0xc,%eax
  800ba4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800bab:	f6 c2 01             	test   $0x1,%dl
  800bae:	74 26                	je     800bd6 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800bb0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	25 07 0e 00 00       	and    $0xe07,%eax
  800bbf:	50                   	push   %eax
  800bc0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bc3:	6a 00                	push   $0x0
  800bc5:	57                   	push   %edi
  800bc6:	6a 00                	push   $0x0
  800bc8:	e8 f3 f5 ff ff       	call   8001c0 <sys_page_map>
  800bcd:	89 c7                	mov    %eax,%edi
  800bcf:	83 c4 20             	add    $0x20,%esp
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	78 2e                	js     800c04 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bd6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800bd9:	89 d0                	mov    %edx,%eax
  800bdb:	c1 e8 0c             	shr    $0xc,%eax
  800bde:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	25 07 0e 00 00       	and    $0xe07,%eax
  800bed:	50                   	push   %eax
  800bee:	53                   	push   %ebx
  800bef:	6a 00                	push   $0x0
  800bf1:	52                   	push   %edx
  800bf2:	6a 00                	push   $0x0
  800bf4:	e8 c7 f5 ff ff       	call   8001c0 <sys_page_map>
  800bf9:	89 c7                	mov    %eax,%edi
  800bfb:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800bfe:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c00:	85 ff                	test   %edi,%edi
  800c02:	79 1d                	jns    800c21 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c04:	83 ec 08             	sub    $0x8,%esp
  800c07:	53                   	push   %ebx
  800c08:	6a 00                	push   $0x0
  800c0a:	e8 f3 f5 ff ff       	call   800202 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c0f:	83 c4 08             	add    $0x8,%esp
  800c12:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c15:	6a 00                	push   $0x0
  800c17:	e8 e6 f5 ff ff       	call   800202 <sys_page_unmap>
	return r;
  800c1c:	83 c4 10             	add    $0x10,%esp
  800c1f:	89 f8                	mov    %edi,%eax
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 14             	sub    $0x14,%esp
  800c30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c36:	50                   	push   %eax
  800c37:	53                   	push   %ebx
  800c38:	e8 83 fd ff ff       	call   8009c0 <fd_lookup>
  800c3d:	83 c4 08             	add    $0x8,%esp
  800c40:	89 c2                	mov    %eax,%edx
  800c42:	85 c0                	test   %eax,%eax
  800c44:	78 70                	js     800cb6 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c46:	83 ec 08             	sub    $0x8,%esp
  800c49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c4c:	50                   	push   %eax
  800c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c50:	ff 30                	pushl  (%eax)
  800c52:	e8 bf fd ff ff       	call   800a16 <dev_lookup>
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	78 4f                	js     800cad <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c5e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c61:	8b 42 08             	mov    0x8(%edx),%eax
  800c64:	83 e0 03             	and    $0x3,%eax
  800c67:	83 f8 01             	cmp    $0x1,%eax
  800c6a:	75 24                	jne    800c90 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c6c:	a1 04 40 80 00       	mov    0x804004,%eax
  800c71:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800c77:	83 ec 04             	sub    $0x4,%esp
  800c7a:	53                   	push   %ebx
  800c7b:	50                   	push   %eax
  800c7c:	68 55 26 80 00       	push   $0x802655
  800c81:	e8 9c 0a 00 00       	call   801722 <cprintf>
		return -E_INVAL;
  800c86:	83 c4 10             	add    $0x10,%esp
  800c89:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c8e:	eb 26                	jmp    800cb6 <read+0x8d>
	}
	if (!dev->dev_read)
  800c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c93:	8b 40 08             	mov    0x8(%eax),%eax
  800c96:	85 c0                	test   %eax,%eax
  800c98:	74 17                	je     800cb1 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c9a:	83 ec 04             	sub    $0x4,%esp
  800c9d:	ff 75 10             	pushl  0x10(%ebp)
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	52                   	push   %edx
  800ca4:	ff d0                	call   *%eax
  800ca6:	89 c2                	mov    %eax,%edx
  800ca8:	83 c4 10             	add    $0x10,%esp
  800cab:	eb 09                	jmp    800cb6 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cad:	89 c2                	mov    %eax,%edx
  800caf:	eb 05                	jmp    800cb6 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800cb1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800cb6:	89 d0                	mov    %edx,%eax
  800cb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cbb:	c9                   	leave  
  800cbc:	c3                   	ret    

00800cbd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	eb 21                	jmp    800cf4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800cd3:	83 ec 04             	sub    $0x4,%esp
  800cd6:	89 f0                	mov    %esi,%eax
  800cd8:	29 d8                	sub    %ebx,%eax
  800cda:	50                   	push   %eax
  800cdb:	89 d8                	mov    %ebx,%eax
  800cdd:	03 45 0c             	add    0xc(%ebp),%eax
  800ce0:	50                   	push   %eax
  800ce1:	57                   	push   %edi
  800ce2:	e8 42 ff ff ff       	call   800c29 <read>
		if (m < 0)
  800ce7:	83 c4 10             	add    $0x10,%esp
  800cea:	85 c0                	test   %eax,%eax
  800cec:	78 10                	js     800cfe <readn+0x41>
			return m;
		if (m == 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	74 0a                	je     800cfc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cf2:	01 c3                	add    %eax,%ebx
  800cf4:	39 f3                	cmp    %esi,%ebx
  800cf6:	72 db                	jb     800cd3 <readn+0x16>
  800cf8:	89 d8                	mov    %ebx,%eax
  800cfa:	eb 02                	jmp    800cfe <readn+0x41>
  800cfc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 14             	sub    $0x14,%esp
  800d0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d13:	50                   	push   %eax
  800d14:	53                   	push   %ebx
  800d15:	e8 a6 fc ff ff       	call   8009c0 <fd_lookup>
  800d1a:	83 c4 08             	add    $0x8,%esp
  800d1d:	89 c2                	mov    %eax,%edx
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 6b                	js     800d8e <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d23:	83 ec 08             	sub    $0x8,%esp
  800d26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d29:	50                   	push   %eax
  800d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d2d:	ff 30                	pushl  (%eax)
  800d2f:	e8 e2 fc ff ff       	call   800a16 <dev_lookup>
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	85 c0                	test   %eax,%eax
  800d39:	78 4a                	js     800d85 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d3e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d42:	75 24                	jne    800d68 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d44:	a1 04 40 80 00       	mov    0x804004,%eax
  800d49:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800d4f:	83 ec 04             	sub    $0x4,%esp
  800d52:	53                   	push   %ebx
  800d53:	50                   	push   %eax
  800d54:	68 71 26 80 00       	push   $0x802671
  800d59:	e8 c4 09 00 00       	call   801722 <cprintf>
		return -E_INVAL;
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d66:	eb 26                	jmp    800d8e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d6b:	8b 52 0c             	mov    0xc(%edx),%edx
  800d6e:	85 d2                	test   %edx,%edx
  800d70:	74 17                	je     800d89 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d72:	83 ec 04             	sub    $0x4,%esp
  800d75:	ff 75 10             	pushl  0x10(%ebp)
  800d78:	ff 75 0c             	pushl  0xc(%ebp)
  800d7b:	50                   	push   %eax
  800d7c:	ff d2                	call   *%edx
  800d7e:	89 c2                	mov    %eax,%edx
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	eb 09                	jmp    800d8e <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	eb 05                	jmp    800d8e <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d89:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d8e:	89 d0                	mov    %edx,%eax
  800d90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d9b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d9e:	50                   	push   %eax
  800d9f:	ff 75 08             	pushl  0x8(%ebp)
  800da2:	e8 19 fc ff ff       	call   8009c0 <fd_lookup>
  800da7:	83 c4 08             	add    $0x8,%esp
  800daa:	85 c0                	test   %eax,%eax
  800dac:	78 0e                	js     800dbc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800dae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800db1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800db7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dbc:	c9                   	leave  
  800dbd:	c3                   	ret    

00800dbe <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 14             	sub    $0x14,%esp
  800dc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dc8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dcb:	50                   	push   %eax
  800dcc:	53                   	push   %ebx
  800dcd:	e8 ee fb ff ff       	call   8009c0 <fd_lookup>
  800dd2:	83 c4 08             	add    $0x8,%esp
  800dd5:	89 c2                	mov    %eax,%edx
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	78 68                	js     800e43 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ddb:	83 ec 08             	sub    $0x8,%esp
  800dde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800de1:	50                   	push   %eax
  800de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de5:	ff 30                	pushl  (%eax)
  800de7:	e8 2a fc ff ff       	call   800a16 <dev_lookup>
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	78 47                	js     800e3a <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800dfa:	75 24                	jne    800e20 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800dfc:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800e01:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e07:	83 ec 04             	sub    $0x4,%esp
  800e0a:	53                   	push   %ebx
  800e0b:	50                   	push   %eax
  800e0c:	68 34 26 80 00       	push   $0x802634
  800e11:	e8 0c 09 00 00       	call   801722 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e1e:	eb 23                	jmp    800e43 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800e20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e23:	8b 52 18             	mov    0x18(%edx),%edx
  800e26:	85 d2                	test   %edx,%edx
  800e28:	74 14                	je     800e3e <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800e2a:	83 ec 08             	sub    $0x8,%esp
  800e2d:	ff 75 0c             	pushl  0xc(%ebp)
  800e30:	50                   	push   %eax
  800e31:	ff d2                	call   *%edx
  800e33:	89 c2                	mov    %eax,%edx
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	eb 09                	jmp    800e43 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e3a:	89 c2                	mov    %eax,%edx
  800e3c:	eb 05                	jmp    800e43 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800e3e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800e43:	89 d0                	mov    %edx,%eax
  800e45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 14             	sub    $0x14,%esp
  800e51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e54:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e57:	50                   	push   %eax
  800e58:	ff 75 08             	pushl  0x8(%ebp)
  800e5b:	e8 60 fb ff ff       	call   8009c0 <fd_lookup>
  800e60:	83 c4 08             	add    $0x8,%esp
  800e63:	89 c2                	mov    %eax,%edx
  800e65:	85 c0                	test   %eax,%eax
  800e67:	78 58                	js     800ec1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e69:	83 ec 08             	sub    $0x8,%esp
  800e6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e6f:	50                   	push   %eax
  800e70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e73:	ff 30                	pushl  (%eax)
  800e75:	e8 9c fb ff ff       	call   800a16 <dev_lookup>
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	78 37                	js     800eb8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e84:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e88:	74 32                	je     800ebc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e8a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e8d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e94:	00 00 00 
	stat->st_isdir = 0;
  800e97:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e9e:	00 00 00 
	stat->st_dev = dev;
  800ea1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ea7:	83 ec 08             	sub    $0x8,%esp
  800eaa:	53                   	push   %ebx
  800eab:	ff 75 f0             	pushl  -0x10(%ebp)
  800eae:	ff 50 14             	call   *0x14(%eax)
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	eb 09                	jmp    800ec1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	eb 05                	jmp    800ec1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ebc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800ec1:	89 d0                	mov    %edx,%eax
  800ec3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ecd:	83 ec 08             	sub    $0x8,%esp
  800ed0:	6a 00                	push   $0x0
  800ed2:	ff 75 08             	pushl  0x8(%ebp)
  800ed5:	e8 e3 01 00 00       	call   8010bd <open>
  800eda:	89 c3                	mov    %eax,%ebx
  800edc:	83 c4 10             	add    $0x10,%esp
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	78 1b                	js     800efe <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800ee3:	83 ec 08             	sub    $0x8,%esp
  800ee6:	ff 75 0c             	pushl  0xc(%ebp)
  800ee9:	50                   	push   %eax
  800eea:	e8 5b ff ff ff       	call   800e4a <fstat>
  800eef:	89 c6                	mov    %eax,%esi
	close(fd);
  800ef1:	89 1c 24             	mov    %ebx,(%esp)
  800ef4:	e8 f4 fb ff ff       	call   800aed <close>
	return r;
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	89 f0                	mov    %esi,%eax
}
  800efe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	89 c6                	mov    %eax,%esi
  800f0c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800f0e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800f15:	75 12                	jne    800f29 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800f17:	83 ec 0c             	sub    $0xc,%esp
  800f1a:	6a 01                	push   $0x1
  800f1c:	e8 39 12 00 00       	call   80215a <ipc_find_env>
  800f21:	a3 00 40 80 00       	mov    %eax,0x804000
  800f26:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800f29:	6a 07                	push   $0x7
  800f2b:	68 00 50 80 00       	push   $0x805000
  800f30:	56                   	push   %esi
  800f31:	ff 35 00 40 80 00    	pushl  0x804000
  800f37:	e8 bc 11 00 00       	call   8020f8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800f3c:	83 c4 0c             	add    $0xc,%esp
  800f3f:	6a 00                	push   $0x0
  800f41:	53                   	push   %ebx
  800f42:	6a 00                	push   $0x0
  800f44:	e8 34 11 00 00       	call   80207d <ipc_recv>
}
  800f49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f56:	8b 45 08             	mov    0x8(%ebp),%eax
  800f59:	8b 40 0c             	mov    0xc(%eax),%eax
  800f5c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f64:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f69:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800f73:	e8 8d ff ff ff       	call   800f05 <fsipc>
}
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	8b 40 0c             	mov    0xc(%eax),%eax
  800f86:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f90:	b8 06 00 00 00       	mov    $0x6,%eax
  800f95:	e8 6b ff ff ff       	call   800f05 <fsipc>
}
  800f9a:	c9                   	leave  
  800f9b:	c3                   	ret    

00800f9c <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	53                   	push   %ebx
  800fa0:	83 ec 04             	sub    $0x4,%esp
  800fa3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa9:	8b 40 0c             	mov    0xc(%eax),%eax
  800fac:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800fb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb6:	b8 05 00 00 00       	mov    $0x5,%eax
  800fbb:	e8 45 ff ff ff       	call   800f05 <fsipc>
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	78 2c                	js     800ff0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800fc4:	83 ec 08             	sub    $0x8,%esp
  800fc7:	68 00 50 80 00       	push   $0x805000
  800fcc:	53                   	push   %ebx
  800fcd:	e8 d5 0c 00 00       	call   801ca7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800fd2:	a1 80 50 80 00       	mov    0x805080,%eax
  800fd7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800fdd:	a1 84 50 80 00       	mov    0x805084,%eax
  800fe2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 0c             	sub    $0xc,%esp
  800ffb:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	8b 52 0c             	mov    0xc(%edx),%edx
  801004:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80100a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80100f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801014:	0f 47 c2             	cmova  %edx,%eax
  801017:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80101c:	50                   	push   %eax
  80101d:	ff 75 0c             	pushl  0xc(%ebp)
  801020:	68 08 50 80 00       	push   $0x805008
  801025:	e8 0f 0e 00 00       	call   801e39 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80102a:	ba 00 00 00 00       	mov    $0x0,%edx
  80102f:	b8 04 00 00 00       	mov    $0x4,%eax
  801034:	e8 cc fe ff ff       	call   800f05 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	8b 40 0c             	mov    0xc(%eax),%eax
  801049:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80104e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801054:	ba 00 00 00 00       	mov    $0x0,%edx
  801059:	b8 03 00 00 00       	mov    $0x3,%eax
  80105e:	e8 a2 fe ff ff       	call   800f05 <fsipc>
  801063:	89 c3                	mov    %eax,%ebx
  801065:	85 c0                	test   %eax,%eax
  801067:	78 4b                	js     8010b4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801069:	39 c6                	cmp    %eax,%esi
  80106b:	73 16                	jae    801083 <devfile_read+0x48>
  80106d:	68 a0 26 80 00       	push   $0x8026a0
  801072:	68 a7 26 80 00       	push   $0x8026a7
  801077:	6a 7c                	push   $0x7c
  801079:	68 bc 26 80 00       	push   $0x8026bc
  80107e:	e8 c6 05 00 00       	call   801649 <_panic>
	assert(r <= PGSIZE);
  801083:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801088:	7e 16                	jle    8010a0 <devfile_read+0x65>
  80108a:	68 c7 26 80 00       	push   $0x8026c7
  80108f:	68 a7 26 80 00       	push   $0x8026a7
  801094:	6a 7d                	push   $0x7d
  801096:	68 bc 26 80 00       	push   $0x8026bc
  80109b:	e8 a9 05 00 00       	call   801649 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8010a0:	83 ec 04             	sub    $0x4,%esp
  8010a3:	50                   	push   %eax
  8010a4:	68 00 50 80 00       	push   $0x805000
  8010a9:	ff 75 0c             	pushl  0xc(%ebp)
  8010ac:	e8 88 0d 00 00       	call   801e39 <memmove>
	return r;
  8010b1:	83 c4 10             	add    $0x10,%esp
}
  8010b4:	89 d8                	mov    %ebx,%eax
  8010b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b9:	5b                   	pop    %ebx
  8010ba:	5e                   	pop    %esi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 20             	sub    $0x20,%esp
  8010c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8010c7:	53                   	push   %ebx
  8010c8:	e8 a1 0b 00 00       	call   801c6e <strlen>
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010d5:	7f 67                	jg     80113e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010d7:	83 ec 0c             	sub    $0xc,%esp
  8010da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	e8 8e f8 ff ff       	call   800971 <fd_alloc>
  8010e3:	83 c4 10             	add    $0x10,%esp
		return r;
  8010e6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	78 57                	js     801143 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	53                   	push   %ebx
  8010f0:	68 00 50 80 00       	push   $0x805000
  8010f5:	e8 ad 0b 00 00       	call   801ca7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8010fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010fd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801102:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801105:	b8 01 00 00 00       	mov    $0x1,%eax
  80110a:	e8 f6 fd ff ff       	call   800f05 <fsipc>
  80110f:	89 c3                	mov    %eax,%ebx
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	79 14                	jns    80112c <open+0x6f>
		fd_close(fd, 0);
  801118:	83 ec 08             	sub    $0x8,%esp
  80111b:	6a 00                	push   $0x0
  80111d:	ff 75 f4             	pushl  -0xc(%ebp)
  801120:	e8 47 f9 ff ff       	call   800a6c <fd_close>
		return r;
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	89 da                	mov    %ebx,%edx
  80112a:	eb 17                	jmp    801143 <open+0x86>
	}

	return fd2num(fd);
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	ff 75 f4             	pushl  -0xc(%ebp)
  801132:	e8 13 f8 ff ff       	call   80094a <fd2num>
  801137:	89 c2                	mov    %eax,%edx
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	eb 05                	jmp    801143 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80113e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801143:	89 d0                	mov    %edx,%eax
  801145:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801148:	c9                   	leave  
  801149:	c3                   	ret    

0080114a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801150:	ba 00 00 00 00       	mov    $0x0,%edx
  801155:	b8 08 00 00 00       	mov    $0x8,%eax
  80115a:	e8 a6 fd ff ff       	call   800f05 <fsipc>
}
  80115f:	c9                   	leave  
  801160:	c3                   	ret    

00801161 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801169:	83 ec 0c             	sub    $0xc,%esp
  80116c:	ff 75 08             	pushl  0x8(%ebp)
  80116f:	e8 e6 f7 ff ff       	call   80095a <fd2data>
  801174:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801176:	83 c4 08             	add    $0x8,%esp
  801179:	68 d3 26 80 00       	push   $0x8026d3
  80117e:	53                   	push   %ebx
  80117f:	e8 23 0b 00 00       	call   801ca7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801184:	8b 46 04             	mov    0x4(%esi),%eax
  801187:	2b 06                	sub    (%esi),%eax
  801189:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80118f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801196:	00 00 00 
	stat->st_dev = &devpipe;
  801199:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8011a0:	30 80 00 
	return 0;
}
  8011a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	53                   	push   %ebx
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8011b9:	53                   	push   %ebx
  8011ba:	6a 00                	push   $0x0
  8011bc:	e8 41 f0 ff ff       	call   800202 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8011c1:	89 1c 24             	mov    %ebx,(%esp)
  8011c4:	e8 91 f7 ff ff       	call   80095a <fd2data>
  8011c9:	83 c4 08             	add    $0x8,%esp
  8011cc:	50                   	push   %eax
  8011cd:	6a 00                	push   $0x0
  8011cf:	e8 2e f0 ff ff       	call   800202 <sys_page_unmap>
}
  8011d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d7:	c9                   	leave  
  8011d8:	c3                   	ret    

008011d9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 1c             	sub    $0x1c,%esp
  8011e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011e5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8011e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ec:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8011f2:	83 ec 0c             	sub    $0xc,%esp
  8011f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f8:	e8 a2 0f 00 00       	call   80219f <pageref>
  8011fd:	89 c3                	mov    %eax,%ebx
  8011ff:	89 3c 24             	mov    %edi,(%esp)
  801202:	e8 98 0f 00 00       	call   80219f <pageref>
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	39 c3                	cmp    %eax,%ebx
  80120c:	0f 94 c1             	sete   %cl
  80120f:	0f b6 c9             	movzbl %cl,%ecx
  801212:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801215:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80121b:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801221:	39 ce                	cmp    %ecx,%esi
  801223:	74 1e                	je     801243 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801225:	39 c3                	cmp    %eax,%ebx
  801227:	75 be                	jne    8011e7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801229:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80122f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801232:	50                   	push   %eax
  801233:	56                   	push   %esi
  801234:	68 da 26 80 00       	push   $0x8026da
  801239:	e8 e4 04 00 00       	call   801722 <cprintf>
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	eb a4                	jmp    8011e7 <_pipeisclosed+0xe>
	}
}
  801243:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801246:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801249:	5b                   	pop    %ebx
  80124a:	5e                   	pop    %esi
  80124b:	5f                   	pop    %edi
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	57                   	push   %edi
  801252:	56                   	push   %esi
  801253:	53                   	push   %ebx
  801254:	83 ec 28             	sub    $0x28,%esp
  801257:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80125a:	56                   	push   %esi
  80125b:	e8 fa f6 ff ff       	call   80095a <fd2data>
  801260:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	bf 00 00 00 00       	mov    $0x0,%edi
  80126a:	eb 4b                	jmp    8012b7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80126c:	89 da                	mov    %ebx,%edx
  80126e:	89 f0                	mov    %esi,%eax
  801270:	e8 64 ff ff ff       	call   8011d9 <_pipeisclosed>
  801275:	85 c0                	test   %eax,%eax
  801277:	75 48                	jne    8012c1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801279:	e8 e0 ee ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80127e:	8b 43 04             	mov    0x4(%ebx),%eax
  801281:	8b 0b                	mov    (%ebx),%ecx
  801283:	8d 51 20             	lea    0x20(%ecx),%edx
  801286:	39 d0                	cmp    %edx,%eax
  801288:	73 e2                	jae    80126c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80128a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801291:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801294:	89 c2                	mov    %eax,%edx
  801296:	c1 fa 1f             	sar    $0x1f,%edx
  801299:	89 d1                	mov    %edx,%ecx
  80129b:	c1 e9 1b             	shr    $0x1b,%ecx
  80129e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8012a1:	83 e2 1f             	and    $0x1f,%edx
  8012a4:	29 ca                	sub    %ecx,%edx
  8012a6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8012aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8012ae:	83 c0 01             	add    $0x1,%eax
  8012b1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012b4:	83 c7 01             	add    $0x1,%edi
  8012b7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8012ba:	75 c2                	jne    80127e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8012bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8012bf:	eb 05                	jmp    8012c6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012c1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8012c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c9:	5b                   	pop    %ebx
  8012ca:	5e                   	pop    %esi
  8012cb:	5f                   	pop    %edi
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 18             	sub    $0x18,%esp
  8012d7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8012da:	57                   	push   %edi
  8012db:	e8 7a f6 ff ff       	call   80095a <fd2data>
  8012e0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ea:	eb 3d                	jmp    801329 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8012ec:	85 db                	test   %ebx,%ebx
  8012ee:	74 04                	je     8012f4 <devpipe_read+0x26>
				return i;
  8012f0:	89 d8                	mov    %ebx,%eax
  8012f2:	eb 44                	jmp    801338 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8012f4:	89 f2                	mov    %esi,%edx
  8012f6:	89 f8                	mov    %edi,%eax
  8012f8:	e8 dc fe ff ff       	call   8011d9 <_pipeisclosed>
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	75 32                	jne    801333 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801301:	e8 58 ee ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801306:	8b 06                	mov    (%esi),%eax
  801308:	3b 46 04             	cmp    0x4(%esi),%eax
  80130b:	74 df                	je     8012ec <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80130d:	99                   	cltd   
  80130e:	c1 ea 1b             	shr    $0x1b,%edx
  801311:	01 d0                	add    %edx,%eax
  801313:	83 e0 1f             	and    $0x1f,%eax
  801316:	29 d0                	sub    %edx,%eax
  801318:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80131d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801320:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801323:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801326:	83 c3 01             	add    $0x1,%ebx
  801329:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80132c:	75 d8                	jne    801306 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80132e:	8b 45 10             	mov    0x10(%ebp),%eax
  801331:	eb 05                	jmp    801338 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801333:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133b:	5b                   	pop    %ebx
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	56                   	push   %esi
  801344:	53                   	push   %ebx
  801345:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801348:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	e8 20 f6 ff ff       	call   800971 <fd_alloc>
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	89 c2                	mov    %eax,%edx
  801356:	85 c0                	test   %eax,%eax
  801358:	0f 88 2c 01 00 00    	js     80148a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80135e:	83 ec 04             	sub    $0x4,%esp
  801361:	68 07 04 00 00       	push   $0x407
  801366:	ff 75 f4             	pushl  -0xc(%ebp)
  801369:	6a 00                	push   $0x0
  80136b:	e8 0d ee ff ff       	call   80017d <sys_page_alloc>
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	89 c2                	mov    %eax,%edx
  801375:	85 c0                	test   %eax,%eax
  801377:	0f 88 0d 01 00 00    	js     80148a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80137d:	83 ec 0c             	sub    $0xc,%esp
  801380:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	e8 e8 f5 ff ff       	call   800971 <fd_alloc>
  801389:	89 c3                	mov    %eax,%ebx
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	0f 88 e2 00 00 00    	js     801478 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801396:	83 ec 04             	sub    $0x4,%esp
  801399:	68 07 04 00 00       	push   $0x407
  80139e:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a1:	6a 00                	push   $0x0
  8013a3:	e8 d5 ed ff ff       	call   80017d <sys_page_alloc>
  8013a8:	89 c3                	mov    %eax,%ebx
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	0f 88 c3 00 00 00    	js     801478 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8013b5:	83 ec 0c             	sub    $0xc,%esp
  8013b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013bb:	e8 9a f5 ff ff       	call   80095a <fd2data>
  8013c0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013c2:	83 c4 0c             	add    $0xc,%esp
  8013c5:	68 07 04 00 00       	push   $0x407
  8013ca:	50                   	push   %eax
  8013cb:	6a 00                	push   $0x0
  8013cd:	e8 ab ed ff ff       	call   80017d <sys_page_alloc>
  8013d2:	89 c3                	mov    %eax,%ebx
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	0f 88 89 00 00 00    	js     801468 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013df:	83 ec 0c             	sub    $0xc,%esp
  8013e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e5:	e8 70 f5 ff ff       	call   80095a <fd2data>
  8013ea:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8013f1:	50                   	push   %eax
  8013f2:	6a 00                	push   $0x0
  8013f4:	56                   	push   %esi
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 c4 ed ff ff       	call   8001c0 <sys_page_map>
  8013fc:	89 c3                	mov    %eax,%ebx
  8013fe:	83 c4 20             	add    $0x20,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	78 55                	js     80145a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801405:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80140b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801410:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801413:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80141a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801420:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801423:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801425:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801428:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80142f:	83 ec 0c             	sub    $0xc,%esp
  801432:	ff 75 f4             	pushl  -0xc(%ebp)
  801435:	e8 10 f5 ff ff       	call   80094a <fd2num>
  80143a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80143f:	83 c4 04             	add    $0x4,%esp
  801442:	ff 75 f0             	pushl  -0x10(%ebp)
  801445:	e8 00 f5 ff ff       	call   80094a <fd2num>
  80144a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	ba 00 00 00 00       	mov    $0x0,%edx
  801458:	eb 30                	jmp    80148a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	56                   	push   %esi
  80145e:	6a 00                	push   $0x0
  801460:	e8 9d ed ff ff       	call   800202 <sys_page_unmap>
  801465:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	ff 75 f0             	pushl  -0x10(%ebp)
  80146e:	6a 00                	push   $0x0
  801470:	e8 8d ed ff ff       	call   800202 <sys_page_unmap>
  801475:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	ff 75 f4             	pushl  -0xc(%ebp)
  80147e:	6a 00                	push   $0x0
  801480:	e8 7d ed ff ff       	call   800202 <sys_page_unmap>
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80148a:	89 d0                	mov    %edx,%eax
  80148c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148f:	5b                   	pop    %ebx
  801490:	5e                   	pop    %esi
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801499:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	ff 75 08             	pushl  0x8(%ebp)
  8014a0:	e8 1b f5 ff ff       	call   8009c0 <fd_lookup>
  8014a5:	83 c4 10             	add    $0x10,%esp
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	78 18                	js     8014c4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b2:	e8 a3 f4 ff ff       	call   80095a <fd2data>
	return _pipeisclosed(fd, p);
  8014b7:	89 c2                	mov    %eax,%edx
  8014b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bc:	e8 18 fd ff ff       	call   8011d9 <_pipeisclosed>
  8014c1:	83 c4 10             	add    $0x10,%esp
}
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8014c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8014d6:	68 f2 26 80 00       	push   $0x8026f2
  8014db:	ff 75 0c             	pushl  0xc(%ebp)
  8014de:	e8 c4 07 00 00       	call   801ca7 <strcpy>
	return 0;
}
  8014e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	57                   	push   %edi
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014f6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014fb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801501:	eb 2d                	jmp    801530 <devcons_write+0x46>
		m = n - tot;
  801503:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801506:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801508:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80150b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801510:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801513:	83 ec 04             	sub    $0x4,%esp
  801516:	53                   	push   %ebx
  801517:	03 45 0c             	add    0xc(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	57                   	push   %edi
  80151c:	e8 18 09 00 00       	call   801e39 <memmove>
		sys_cputs(buf, m);
  801521:	83 c4 08             	add    $0x8,%esp
  801524:	53                   	push   %ebx
  801525:	57                   	push   %edi
  801526:	e8 96 eb ff ff       	call   8000c1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80152b:	01 de                	add    %ebx,%esi
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	89 f0                	mov    %esi,%eax
  801532:	3b 75 10             	cmp    0x10(%ebp),%esi
  801535:	72 cc                	jb     801503 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801537:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153a:	5b                   	pop    %ebx
  80153b:	5e                   	pop    %esi
  80153c:	5f                   	pop    %edi
  80153d:	5d                   	pop    %ebp
  80153e:	c3                   	ret    

0080153f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80154a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80154e:	74 2a                	je     80157a <devcons_read+0x3b>
  801550:	eb 05                	jmp    801557 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801552:	e8 07 ec ff ff       	call   80015e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801557:	e8 83 eb ff ff       	call   8000df <sys_cgetc>
  80155c:	85 c0                	test   %eax,%eax
  80155e:	74 f2                	je     801552 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801560:	85 c0                	test   %eax,%eax
  801562:	78 16                	js     80157a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801564:	83 f8 04             	cmp    $0x4,%eax
  801567:	74 0c                	je     801575 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801569:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156c:	88 02                	mov    %al,(%edx)
	return 1;
  80156e:	b8 01 00 00 00       	mov    $0x1,%eax
  801573:	eb 05                	jmp    80157a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801575:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801582:	8b 45 08             	mov    0x8(%ebp),%eax
  801585:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801588:	6a 01                	push   $0x1
  80158a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	e8 2e eb ff ff       	call   8000c1 <sys_cputs>
}
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <getchar>:

int
getchar(void)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80159e:	6a 01                	push   $0x1
  8015a0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	6a 00                	push   $0x0
  8015a6:	e8 7e f6 ff ff       	call   800c29 <read>
	if (r < 0)
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 0f                	js     8015c1 <getchar+0x29>
		return r;
	if (r < 1)
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	7e 06                	jle    8015bc <getchar+0x24>
		return -E_EOF;
	return c;
  8015b6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8015ba:	eb 05                	jmp    8015c1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8015bc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	ff 75 08             	pushl  0x8(%ebp)
  8015d0:	e8 eb f3 ff ff       	call   8009c0 <fd_lookup>
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	78 11                	js     8015ed <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8015dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015df:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015e5:	39 10                	cmp    %edx,(%eax)
  8015e7:	0f 94 c0             	sete   %al
  8015ea:	0f b6 c0             	movzbl %al,%eax
}
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <opencons>:

int
opencons(void)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	e8 73 f3 ff ff       	call   800971 <fd_alloc>
  8015fe:	83 c4 10             	add    $0x10,%esp
		return r;
  801601:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801603:	85 c0                	test   %eax,%eax
  801605:	78 3e                	js     801645 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	68 07 04 00 00       	push   $0x407
  80160f:	ff 75 f4             	pushl  -0xc(%ebp)
  801612:	6a 00                	push   $0x0
  801614:	e8 64 eb ff ff       	call   80017d <sys_page_alloc>
  801619:	83 c4 10             	add    $0x10,%esp
		return r;
  80161c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 23                	js     801645 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801622:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80162d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801630:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801637:	83 ec 0c             	sub    $0xc,%esp
  80163a:	50                   	push   %eax
  80163b:	e8 0a f3 ff ff       	call   80094a <fd2num>
  801640:	89 c2                	mov    %eax,%edx
  801642:	83 c4 10             	add    $0x10,%esp
}
  801645:	89 d0                	mov    %edx,%eax
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80164e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801651:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801657:	e8 e3 ea ff ff       	call   80013f <sys_getenvid>
  80165c:	83 ec 0c             	sub    $0xc,%esp
  80165f:	ff 75 0c             	pushl  0xc(%ebp)
  801662:	ff 75 08             	pushl  0x8(%ebp)
  801665:	56                   	push   %esi
  801666:	50                   	push   %eax
  801667:	68 00 27 80 00       	push   $0x802700
  80166c:	e8 b1 00 00 00       	call   801722 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801671:	83 c4 18             	add    $0x18,%esp
  801674:	53                   	push   %ebx
  801675:	ff 75 10             	pushl  0x10(%ebp)
  801678:	e8 54 00 00 00       	call   8016d1 <vcprintf>
	cprintf("\n");
  80167d:	c7 04 24 51 25 80 00 	movl   $0x802551,(%esp)
  801684:	e8 99 00 00 00       	call   801722 <cprintf>
  801689:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80168c:	cc                   	int3   
  80168d:	eb fd                	jmp    80168c <_panic+0x43>

0080168f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	53                   	push   %ebx
  801693:	83 ec 04             	sub    $0x4,%esp
  801696:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801699:	8b 13                	mov    (%ebx),%edx
  80169b:	8d 42 01             	lea    0x1(%edx),%eax
  80169e:	89 03                	mov    %eax,(%ebx)
  8016a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8016a7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8016ac:	75 1a                	jne    8016c8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	68 ff 00 00 00       	push   $0xff
  8016b6:	8d 43 08             	lea    0x8(%ebx),%eax
  8016b9:	50                   	push   %eax
  8016ba:	e8 02 ea ff ff       	call   8000c1 <sys_cputs>
		b->idx = 0;
  8016bf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016c5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8016c8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8016cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8016da:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016e1:	00 00 00 
	b.cnt = 0;
  8016e4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016eb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016ee:	ff 75 0c             	pushl  0xc(%ebp)
  8016f1:	ff 75 08             	pushl  0x8(%ebp)
  8016f4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8016fa:	50                   	push   %eax
  8016fb:	68 8f 16 80 00       	push   $0x80168f
  801700:	e8 54 01 00 00       	call   801859 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801705:	83 c4 08             	add    $0x8,%esp
  801708:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80170e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801714:	50                   	push   %eax
  801715:	e8 a7 e9 ff ff       	call   8000c1 <sys_cputs>

	return b.cnt;
}
  80171a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801728:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80172b:	50                   	push   %eax
  80172c:	ff 75 08             	pushl  0x8(%ebp)
  80172f:	e8 9d ff ff ff       	call   8016d1 <vcprintf>
	va_end(ap);

	return cnt;
}
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	57                   	push   %edi
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	83 ec 1c             	sub    $0x1c,%esp
  80173f:	89 c7                	mov    %eax,%edi
  801741:	89 d6                	mov    %edx,%esi
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	8b 55 0c             	mov    0xc(%ebp),%edx
  801749:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80174c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80174f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801752:	bb 00 00 00 00       	mov    $0x0,%ebx
  801757:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80175a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80175d:	39 d3                	cmp    %edx,%ebx
  80175f:	72 05                	jb     801766 <printnum+0x30>
  801761:	39 45 10             	cmp    %eax,0x10(%ebp)
  801764:	77 45                	ja     8017ab <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801766:	83 ec 0c             	sub    $0xc,%esp
  801769:	ff 75 18             	pushl  0x18(%ebp)
  80176c:	8b 45 14             	mov    0x14(%ebp),%eax
  80176f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801772:	53                   	push   %ebx
  801773:	ff 75 10             	pushl  0x10(%ebp)
  801776:	83 ec 08             	sub    $0x8,%esp
  801779:	ff 75 e4             	pushl  -0x1c(%ebp)
  80177c:	ff 75 e0             	pushl  -0x20(%ebp)
  80177f:	ff 75 dc             	pushl  -0x24(%ebp)
  801782:	ff 75 d8             	pushl  -0x28(%ebp)
  801785:	e8 56 0a 00 00       	call   8021e0 <__udivdi3>
  80178a:	83 c4 18             	add    $0x18,%esp
  80178d:	52                   	push   %edx
  80178e:	50                   	push   %eax
  80178f:	89 f2                	mov    %esi,%edx
  801791:	89 f8                	mov    %edi,%eax
  801793:	e8 9e ff ff ff       	call   801736 <printnum>
  801798:	83 c4 20             	add    $0x20,%esp
  80179b:	eb 18                	jmp    8017b5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	56                   	push   %esi
  8017a1:	ff 75 18             	pushl  0x18(%ebp)
  8017a4:	ff d7                	call   *%edi
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	eb 03                	jmp    8017ae <printnum+0x78>
  8017ab:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017ae:	83 eb 01             	sub    $0x1,%ebx
  8017b1:	85 db                	test   %ebx,%ebx
  8017b3:	7f e8                	jg     80179d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017b5:	83 ec 08             	sub    $0x8,%esp
  8017b8:	56                   	push   %esi
  8017b9:	83 ec 04             	sub    $0x4,%esp
  8017bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8017c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8017c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8017c8:	e8 43 0b 00 00       	call   802310 <__umoddi3>
  8017cd:	83 c4 14             	add    $0x14,%esp
  8017d0:	0f be 80 23 27 80 00 	movsbl 0x802723(%eax),%eax
  8017d7:	50                   	push   %eax
  8017d8:	ff d7                	call   *%edi
}
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e0:	5b                   	pop    %ebx
  8017e1:	5e                   	pop    %esi
  8017e2:	5f                   	pop    %edi
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017e8:	83 fa 01             	cmp    $0x1,%edx
  8017eb:	7e 0e                	jle    8017fb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017ed:	8b 10                	mov    (%eax),%edx
  8017ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017f2:	89 08                	mov    %ecx,(%eax)
  8017f4:	8b 02                	mov    (%edx),%eax
  8017f6:	8b 52 04             	mov    0x4(%edx),%edx
  8017f9:	eb 22                	jmp    80181d <getuint+0x38>
	else if (lflag)
  8017fb:	85 d2                	test   %edx,%edx
  8017fd:	74 10                	je     80180f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8017ff:	8b 10                	mov    (%eax),%edx
  801801:	8d 4a 04             	lea    0x4(%edx),%ecx
  801804:	89 08                	mov    %ecx,(%eax)
  801806:	8b 02                	mov    (%edx),%eax
  801808:	ba 00 00 00 00       	mov    $0x0,%edx
  80180d:	eb 0e                	jmp    80181d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80180f:	8b 10                	mov    (%eax),%edx
  801811:	8d 4a 04             	lea    0x4(%edx),%ecx
  801814:	89 08                	mov    %ecx,(%eax)
  801816:	8b 02                	mov    (%edx),%eax
  801818:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801825:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801829:	8b 10                	mov    (%eax),%edx
  80182b:	3b 50 04             	cmp    0x4(%eax),%edx
  80182e:	73 0a                	jae    80183a <sprintputch+0x1b>
		*b->buf++ = ch;
  801830:	8d 4a 01             	lea    0x1(%edx),%ecx
  801833:	89 08                	mov    %ecx,(%eax)
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	88 02                	mov    %al,(%edx)
}
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    

0080183c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801842:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801845:	50                   	push   %eax
  801846:	ff 75 10             	pushl  0x10(%ebp)
  801849:	ff 75 0c             	pushl  0xc(%ebp)
  80184c:	ff 75 08             	pushl  0x8(%ebp)
  80184f:	e8 05 00 00 00       	call   801859 <vprintfmt>
	va_end(ap);
}
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	57                   	push   %edi
  80185d:	56                   	push   %esi
  80185e:	53                   	push   %ebx
  80185f:	83 ec 2c             	sub    $0x2c,%esp
  801862:	8b 75 08             	mov    0x8(%ebp),%esi
  801865:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801868:	8b 7d 10             	mov    0x10(%ebp),%edi
  80186b:	eb 12                	jmp    80187f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80186d:	85 c0                	test   %eax,%eax
  80186f:	0f 84 89 03 00 00    	je     801bfe <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	53                   	push   %ebx
  801879:	50                   	push   %eax
  80187a:	ff d6                	call   *%esi
  80187c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80187f:	83 c7 01             	add    $0x1,%edi
  801882:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801886:	83 f8 25             	cmp    $0x25,%eax
  801889:	75 e2                	jne    80186d <vprintfmt+0x14>
  80188b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80188f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801896:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80189d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8018a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a9:	eb 07                	jmp    8018b2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018ae:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b2:	8d 47 01             	lea    0x1(%edi),%eax
  8018b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018b8:	0f b6 07             	movzbl (%edi),%eax
  8018bb:	0f b6 c8             	movzbl %al,%ecx
  8018be:	83 e8 23             	sub    $0x23,%eax
  8018c1:	3c 55                	cmp    $0x55,%al
  8018c3:	0f 87 1a 03 00 00    	ja     801be3 <vprintfmt+0x38a>
  8018c9:	0f b6 c0             	movzbl %al,%eax
  8018cc:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  8018d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8018d6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8018da:	eb d6                	jmp    8018b2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018df:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018e7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8018ea:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8018ee:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8018f1:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8018f4:	83 fa 09             	cmp    $0x9,%edx
  8018f7:	77 39                	ja     801932 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018f9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8018fc:	eb e9                	jmp    8018e7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801901:	8d 48 04             	lea    0x4(%eax),%ecx
  801904:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801907:	8b 00                	mov    (%eax),%eax
  801909:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80190c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80190f:	eb 27                	jmp    801938 <vprintfmt+0xdf>
  801911:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801914:	85 c0                	test   %eax,%eax
  801916:	b9 00 00 00 00       	mov    $0x0,%ecx
  80191b:	0f 49 c8             	cmovns %eax,%ecx
  80191e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801921:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801924:	eb 8c                	jmp    8018b2 <vprintfmt+0x59>
  801926:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801929:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801930:	eb 80                	jmp    8018b2 <vprintfmt+0x59>
  801932:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801935:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801938:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80193c:	0f 89 70 ff ff ff    	jns    8018b2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801942:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801945:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801948:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80194f:	e9 5e ff ff ff       	jmp    8018b2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801954:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801957:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80195a:	e9 53 ff ff ff       	jmp    8018b2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80195f:	8b 45 14             	mov    0x14(%ebp),%eax
  801962:	8d 50 04             	lea    0x4(%eax),%edx
  801965:	89 55 14             	mov    %edx,0x14(%ebp)
  801968:	83 ec 08             	sub    $0x8,%esp
  80196b:	53                   	push   %ebx
  80196c:	ff 30                	pushl  (%eax)
  80196e:	ff d6                	call   *%esi
			break;
  801970:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801973:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801976:	e9 04 ff ff ff       	jmp    80187f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80197b:	8b 45 14             	mov    0x14(%ebp),%eax
  80197e:	8d 50 04             	lea    0x4(%eax),%edx
  801981:	89 55 14             	mov    %edx,0x14(%ebp)
  801984:	8b 00                	mov    (%eax),%eax
  801986:	99                   	cltd   
  801987:	31 d0                	xor    %edx,%eax
  801989:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80198b:	83 f8 0f             	cmp    $0xf,%eax
  80198e:	7f 0b                	jg     80199b <vprintfmt+0x142>
  801990:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  801997:	85 d2                	test   %edx,%edx
  801999:	75 18                	jne    8019b3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80199b:	50                   	push   %eax
  80199c:	68 3b 27 80 00       	push   $0x80273b
  8019a1:	53                   	push   %ebx
  8019a2:	56                   	push   %esi
  8019a3:	e8 94 fe ff ff       	call   80183c <printfmt>
  8019a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019ae:	e9 cc fe ff ff       	jmp    80187f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8019b3:	52                   	push   %edx
  8019b4:	68 b9 26 80 00       	push   $0x8026b9
  8019b9:	53                   	push   %ebx
  8019ba:	56                   	push   %esi
  8019bb:	e8 7c fe ff ff       	call   80183c <printfmt>
  8019c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019c6:	e9 b4 fe ff ff       	jmp    80187f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8019cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ce:	8d 50 04             	lea    0x4(%eax),%edx
  8019d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8019d6:	85 ff                	test   %edi,%edi
  8019d8:	b8 34 27 80 00       	mov    $0x802734,%eax
  8019dd:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8019e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019e4:	0f 8e 94 00 00 00    	jle    801a7e <vprintfmt+0x225>
  8019ea:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8019ee:	0f 84 98 00 00 00    	je     801a8c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8019f4:	83 ec 08             	sub    $0x8,%esp
  8019f7:	ff 75 d0             	pushl  -0x30(%ebp)
  8019fa:	57                   	push   %edi
  8019fb:	e8 86 02 00 00       	call   801c86 <strnlen>
  801a00:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801a03:	29 c1                	sub    %eax,%ecx
  801a05:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801a08:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801a0b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801a0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a12:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801a15:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a17:	eb 0f                	jmp    801a28 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801a19:	83 ec 08             	sub    $0x8,%esp
  801a1c:	53                   	push   %ebx
  801a1d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a20:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a22:	83 ef 01             	sub    $0x1,%edi
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 ff                	test   %edi,%edi
  801a2a:	7f ed                	jg     801a19 <vprintfmt+0x1c0>
  801a2c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801a2f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801a32:	85 c9                	test   %ecx,%ecx
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
  801a39:	0f 49 c1             	cmovns %ecx,%eax
  801a3c:	29 c1                	sub    %eax,%ecx
  801a3e:	89 75 08             	mov    %esi,0x8(%ebp)
  801a41:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a44:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a47:	89 cb                	mov    %ecx,%ebx
  801a49:	eb 4d                	jmp    801a98 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a4b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a4f:	74 1b                	je     801a6c <vprintfmt+0x213>
  801a51:	0f be c0             	movsbl %al,%eax
  801a54:	83 e8 20             	sub    $0x20,%eax
  801a57:	83 f8 5e             	cmp    $0x5e,%eax
  801a5a:	76 10                	jbe    801a6c <vprintfmt+0x213>
					putch('?', putdat);
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	ff 75 0c             	pushl  0xc(%ebp)
  801a62:	6a 3f                	push   $0x3f
  801a64:	ff 55 08             	call   *0x8(%ebp)
  801a67:	83 c4 10             	add    $0x10,%esp
  801a6a:	eb 0d                	jmp    801a79 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	ff 75 0c             	pushl  0xc(%ebp)
  801a72:	52                   	push   %edx
  801a73:	ff 55 08             	call   *0x8(%ebp)
  801a76:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a79:	83 eb 01             	sub    $0x1,%ebx
  801a7c:	eb 1a                	jmp    801a98 <vprintfmt+0x23f>
  801a7e:	89 75 08             	mov    %esi,0x8(%ebp)
  801a81:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a84:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a87:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a8a:	eb 0c                	jmp    801a98 <vprintfmt+0x23f>
  801a8c:	89 75 08             	mov    %esi,0x8(%ebp)
  801a8f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a92:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a95:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a98:	83 c7 01             	add    $0x1,%edi
  801a9b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a9f:	0f be d0             	movsbl %al,%edx
  801aa2:	85 d2                	test   %edx,%edx
  801aa4:	74 23                	je     801ac9 <vprintfmt+0x270>
  801aa6:	85 f6                	test   %esi,%esi
  801aa8:	78 a1                	js     801a4b <vprintfmt+0x1f2>
  801aaa:	83 ee 01             	sub    $0x1,%esi
  801aad:	79 9c                	jns    801a4b <vprintfmt+0x1f2>
  801aaf:	89 df                	mov    %ebx,%edi
  801ab1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ab7:	eb 18                	jmp    801ad1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801ab9:	83 ec 08             	sub    $0x8,%esp
  801abc:	53                   	push   %ebx
  801abd:	6a 20                	push   $0x20
  801abf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801ac1:	83 ef 01             	sub    $0x1,%edi
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	eb 08                	jmp    801ad1 <vprintfmt+0x278>
  801ac9:	89 df                	mov    %ebx,%edi
  801acb:	8b 75 08             	mov    0x8(%ebp),%esi
  801ace:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ad1:	85 ff                	test   %edi,%edi
  801ad3:	7f e4                	jg     801ab9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ad5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ad8:	e9 a2 fd ff ff       	jmp    80187f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801add:	83 fa 01             	cmp    $0x1,%edx
  801ae0:	7e 16                	jle    801af8 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801ae2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae5:	8d 50 08             	lea    0x8(%eax),%edx
  801ae8:	89 55 14             	mov    %edx,0x14(%ebp)
  801aeb:	8b 50 04             	mov    0x4(%eax),%edx
  801aee:	8b 00                	mov    (%eax),%eax
  801af0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801af3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801af6:	eb 32                	jmp    801b2a <vprintfmt+0x2d1>
	else if (lflag)
  801af8:	85 d2                	test   %edx,%edx
  801afa:	74 18                	je     801b14 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801afc:	8b 45 14             	mov    0x14(%ebp),%eax
  801aff:	8d 50 04             	lea    0x4(%eax),%edx
  801b02:	89 55 14             	mov    %edx,0x14(%ebp)
  801b05:	8b 00                	mov    (%eax),%eax
  801b07:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b0a:	89 c1                	mov    %eax,%ecx
  801b0c:	c1 f9 1f             	sar    $0x1f,%ecx
  801b0f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801b12:	eb 16                	jmp    801b2a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801b14:	8b 45 14             	mov    0x14(%ebp),%eax
  801b17:	8d 50 04             	lea    0x4(%eax),%edx
  801b1a:	89 55 14             	mov    %edx,0x14(%ebp)
  801b1d:	8b 00                	mov    (%eax),%eax
  801b1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b22:	89 c1                	mov    %eax,%ecx
  801b24:	c1 f9 1f             	sar    $0x1f,%ecx
  801b27:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b2d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801b30:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b35:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b39:	79 74                	jns    801baf <vprintfmt+0x356>
				putch('-', putdat);
  801b3b:	83 ec 08             	sub    $0x8,%esp
  801b3e:	53                   	push   %ebx
  801b3f:	6a 2d                	push   $0x2d
  801b41:	ff d6                	call   *%esi
				num = -(long long) num;
  801b43:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b46:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b49:	f7 d8                	neg    %eax
  801b4b:	83 d2 00             	adc    $0x0,%edx
  801b4e:	f7 da                	neg    %edx
  801b50:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b53:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b58:	eb 55                	jmp    801baf <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b5a:	8d 45 14             	lea    0x14(%ebp),%eax
  801b5d:	e8 83 fc ff ff       	call   8017e5 <getuint>
			base = 10;
  801b62:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b67:	eb 46                	jmp    801baf <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b69:	8d 45 14             	lea    0x14(%ebp),%eax
  801b6c:	e8 74 fc ff ff       	call   8017e5 <getuint>
			base = 8;
  801b71:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b76:	eb 37                	jmp    801baf <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b78:	83 ec 08             	sub    $0x8,%esp
  801b7b:	53                   	push   %ebx
  801b7c:	6a 30                	push   $0x30
  801b7e:	ff d6                	call   *%esi
			putch('x', putdat);
  801b80:	83 c4 08             	add    $0x8,%esp
  801b83:	53                   	push   %ebx
  801b84:	6a 78                	push   $0x78
  801b86:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b88:	8b 45 14             	mov    0x14(%ebp),%eax
  801b8b:	8d 50 04             	lea    0x4(%eax),%edx
  801b8e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b91:	8b 00                	mov    (%eax),%eax
  801b93:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b98:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b9b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ba0:	eb 0d                	jmp    801baf <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ba2:	8d 45 14             	lea    0x14(%ebp),%eax
  801ba5:	e8 3b fc ff ff       	call   8017e5 <getuint>
			base = 16;
  801baa:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801baf:	83 ec 0c             	sub    $0xc,%esp
  801bb2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801bb6:	57                   	push   %edi
  801bb7:	ff 75 e0             	pushl  -0x20(%ebp)
  801bba:	51                   	push   %ecx
  801bbb:	52                   	push   %edx
  801bbc:	50                   	push   %eax
  801bbd:	89 da                	mov    %ebx,%edx
  801bbf:	89 f0                	mov    %esi,%eax
  801bc1:	e8 70 fb ff ff       	call   801736 <printnum>
			break;
  801bc6:	83 c4 20             	add    $0x20,%esp
  801bc9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bcc:	e9 ae fc ff ff       	jmp    80187f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801bd1:	83 ec 08             	sub    $0x8,%esp
  801bd4:	53                   	push   %ebx
  801bd5:	51                   	push   %ecx
  801bd6:	ff d6                	call   *%esi
			break;
  801bd8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bdb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801bde:	e9 9c fc ff ff       	jmp    80187f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801be3:	83 ec 08             	sub    $0x8,%esp
  801be6:	53                   	push   %ebx
  801be7:	6a 25                	push   $0x25
  801be9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801beb:	83 c4 10             	add    $0x10,%esp
  801bee:	eb 03                	jmp    801bf3 <vprintfmt+0x39a>
  801bf0:	83 ef 01             	sub    $0x1,%edi
  801bf3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801bf7:	75 f7                	jne    801bf0 <vprintfmt+0x397>
  801bf9:	e9 81 fc ff ff       	jmp    80187f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c01:	5b                   	pop    %ebx
  801c02:	5e                   	pop    %esi
  801c03:	5f                   	pop    %edi
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 18             	sub    $0x18,%esp
  801c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c12:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c15:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c19:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c23:	85 c0                	test   %eax,%eax
  801c25:	74 26                	je     801c4d <vsnprintf+0x47>
  801c27:	85 d2                	test   %edx,%edx
  801c29:	7e 22                	jle    801c4d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c2b:	ff 75 14             	pushl  0x14(%ebp)
  801c2e:	ff 75 10             	pushl  0x10(%ebp)
  801c31:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c34:	50                   	push   %eax
  801c35:	68 1f 18 80 00       	push   $0x80181f
  801c3a:	e8 1a fc ff ff       	call   801859 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c42:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c48:	83 c4 10             	add    $0x10,%esp
  801c4b:	eb 05                	jmp    801c52 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c52:	c9                   	leave  
  801c53:	c3                   	ret    

00801c54 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c5a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c5d:	50                   	push   %eax
  801c5e:	ff 75 10             	pushl  0x10(%ebp)
  801c61:	ff 75 0c             	pushl  0xc(%ebp)
  801c64:	ff 75 08             	pushl  0x8(%ebp)
  801c67:	e8 9a ff ff ff       	call   801c06 <vsnprintf>
	va_end(ap);

	return rc;
}
  801c6c:	c9                   	leave  
  801c6d:	c3                   	ret    

00801c6e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c74:	b8 00 00 00 00       	mov    $0x0,%eax
  801c79:	eb 03                	jmp    801c7e <strlen+0x10>
		n++;
  801c7b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c7e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c82:	75 f7                	jne    801c7b <strlen+0xd>
		n++;
	return n;
}
  801c84:	5d                   	pop    %ebp
  801c85:	c3                   	ret    

00801c86 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c94:	eb 03                	jmp    801c99 <strnlen+0x13>
		n++;
  801c96:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c99:	39 c2                	cmp    %eax,%edx
  801c9b:	74 08                	je     801ca5 <strnlen+0x1f>
  801c9d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801ca1:	75 f3                	jne    801c96 <strnlen+0x10>
  801ca3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	53                   	push   %ebx
  801cab:	8b 45 08             	mov    0x8(%ebp),%eax
  801cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801cb1:	89 c2                	mov    %eax,%edx
  801cb3:	83 c2 01             	add    $0x1,%edx
  801cb6:	83 c1 01             	add    $0x1,%ecx
  801cb9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801cbd:	88 5a ff             	mov    %bl,-0x1(%edx)
  801cc0:	84 db                	test   %bl,%bl
  801cc2:	75 ef                	jne    801cb3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801cc4:	5b                   	pop    %ebx
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	53                   	push   %ebx
  801ccb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801cce:	53                   	push   %ebx
  801ccf:	e8 9a ff ff ff       	call   801c6e <strlen>
  801cd4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801cd7:	ff 75 0c             	pushl  0xc(%ebp)
  801cda:	01 d8                	add    %ebx,%eax
  801cdc:	50                   	push   %eax
  801cdd:	e8 c5 ff ff ff       	call   801ca7 <strcpy>
	return dst;
}
  801ce2:	89 d8                	mov    %ebx,%eax
  801ce4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce7:	c9                   	leave  
  801ce8:	c3                   	ret    

00801ce9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	56                   	push   %esi
  801ced:	53                   	push   %ebx
  801cee:	8b 75 08             	mov    0x8(%ebp),%esi
  801cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf4:	89 f3                	mov    %esi,%ebx
  801cf6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cf9:	89 f2                	mov    %esi,%edx
  801cfb:	eb 0f                	jmp    801d0c <strncpy+0x23>
		*dst++ = *src;
  801cfd:	83 c2 01             	add    $0x1,%edx
  801d00:	0f b6 01             	movzbl (%ecx),%eax
  801d03:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d06:	80 39 01             	cmpb   $0x1,(%ecx)
  801d09:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d0c:	39 da                	cmp    %ebx,%edx
  801d0e:	75 ed                	jne    801cfd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d10:	89 f0                	mov    %esi,%eax
  801d12:	5b                   	pop    %ebx
  801d13:	5e                   	pop    %esi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    

00801d16 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	56                   	push   %esi
  801d1a:	53                   	push   %ebx
  801d1b:	8b 75 08             	mov    0x8(%ebp),%esi
  801d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d21:	8b 55 10             	mov    0x10(%ebp),%edx
  801d24:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d26:	85 d2                	test   %edx,%edx
  801d28:	74 21                	je     801d4b <strlcpy+0x35>
  801d2a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801d2e:	89 f2                	mov    %esi,%edx
  801d30:	eb 09                	jmp    801d3b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d32:	83 c2 01             	add    $0x1,%edx
  801d35:	83 c1 01             	add    $0x1,%ecx
  801d38:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801d3b:	39 c2                	cmp    %eax,%edx
  801d3d:	74 09                	je     801d48 <strlcpy+0x32>
  801d3f:	0f b6 19             	movzbl (%ecx),%ebx
  801d42:	84 db                	test   %bl,%bl
  801d44:	75 ec                	jne    801d32 <strlcpy+0x1c>
  801d46:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d48:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d4b:	29 f0                	sub    %esi,%eax
}
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    

00801d51 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d57:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d5a:	eb 06                	jmp    801d62 <strcmp+0x11>
		p++, q++;
  801d5c:	83 c1 01             	add    $0x1,%ecx
  801d5f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d62:	0f b6 01             	movzbl (%ecx),%eax
  801d65:	84 c0                	test   %al,%al
  801d67:	74 04                	je     801d6d <strcmp+0x1c>
  801d69:	3a 02                	cmp    (%edx),%al
  801d6b:	74 ef                	je     801d5c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d6d:	0f b6 c0             	movzbl %al,%eax
  801d70:	0f b6 12             	movzbl (%edx),%edx
  801d73:	29 d0                	sub    %edx,%eax
}
  801d75:	5d                   	pop    %ebp
  801d76:	c3                   	ret    

00801d77 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	53                   	push   %ebx
  801d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d86:	eb 06                	jmp    801d8e <strncmp+0x17>
		n--, p++, q++;
  801d88:	83 c0 01             	add    $0x1,%eax
  801d8b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d8e:	39 d8                	cmp    %ebx,%eax
  801d90:	74 15                	je     801da7 <strncmp+0x30>
  801d92:	0f b6 08             	movzbl (%eax),%ecx
  801d95:	84 c9                	test   %cl,%cl
  801d97:	74 04                	je     801d9d <strncmp+0x26>
  801d99:	3a 0a                	cmp    (%edx),%cl
  801d9b:	74 eb                	je     801d88 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d9d:	0f b6 00             	movzbl (%eax),%eax
  801da0:	0f b6 12             	movzbl (%edx),%edx
  801da3:	29 d0                	sub    %edx,%eax
  801da5:	eb 05                	jmp    801dac <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801dac:	5b                   	pop    %ebx
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    

00801daf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	8b 45 08             	mov    0x8(%ebp),%eax
  801db5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801db9:	eb 07                	jmp    801dc2 <strchr+0x13>
		if (*s == c)
  801dbb:	38 ca                	cmp    %cl,%dl
  801dbd:	74 0f                	je     801dce <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801dbf:	83 c0 01             	add    $0x1,%eax
  801dc2:	0f b6 10             	movzbl (%eax),%edx
  801dc5:	84 d2                	test   %dl,%dl
  801dc7:	75 f2                	jne    801dbb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801dc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dce:	5d                   	pop    %ebp
  801dcf:	c3                   	ret    

00801dd0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801dda:	eb 03                	jmp    801ddf <strfind+0xf>
  801ddc:	83 c0 01             	add    $0x1,%eax
  801ddf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801de2:	38 ca                	cmp    %cl,%dl
  801de4:	74 04                	je     801dea <strfind+0x1a>
  801de6:	84 d2                	test   %dl,%dl
  801de8:	75 f2                	jne    801ddc <strfind+0xc>
			break;
	return (char *) s;
}
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    

00801dec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	57                   	push   %edi
  801df0:	56                   	push   %esi
  801df1:	53                   	push   %ebx
  801df2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801df5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801df8:	85 c9                	test   %ecx,%ecx
  801dfa:	74 36                	je     801e32 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801dfc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801e02:	75 28                	jne    801e2c <memset+0x40>
  801e04:	f6 c1 03             	test   $0x3,%cl
  801e07:	75 23                	jne    801e2c <memset+0x40>
		c &= 0xFF;
  801e09:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e0d:	89 d3                	mov    %edx,%ebx
  801e0f:	c1 e3 08             	shl    $0x8,%ebx
  801e12:	89 d6                	mov    %edx,%esi
  801e14:	c1 e6 18             	shl    $0x18,%esi
  801e17:	89 d0                	mov    %edx,%eax
  801e19:	c1 e0 10             	shl    $0x10,%eax
  801e1c:	09 f0                	or     %esi,%eax
  801e1e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801e20:	89 d8                	mov    %ebx,%eax
  801e22:	09 d0                	or     %edx,%eax
  801e24:	c1 e9 02             	shr    $0x2,%ecx
  801e27:	fc                   	cld    
  801e28:	f3 ab                	rep stos %eax,%es:(%edi)
  801e2a:	eb 06                	jmp    801e32 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2f:	fc                   	cld    
  801e30:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e32:	89 f8                	mov    %edi,%eax
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    

00801e39 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	57                   	push   %edi
  801e3d:	56                   	push   %esi
  801e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e41:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e47:	39 c6                	cmp    %eax,%esi
  801e49:	73 35                	jae    801e80 <memmove+0x47>
  801e4b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e4e:	39 d0                	cmp    %edx,%eax
  801e50:	73 2e                	jae    801e80 <memmove+0x47>
		s += n;
		d += n;
  801e52:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e55:	89 d6                	mov    %edx,%esi
  801e57:	09 fe                	or     %edi,%esi
  801e59:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e5f:	75 13                	jne    801e74 <memmove+0x3b>
  801e61:	f6 c1 03             	test   $0x3,%cl
  801e64:	75 0e                	jne    801e74 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e66:	83 ef 04             	sub    $0x4,%edi
  801e69:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e6c:	c1 e9 02             	shr    $0x2,%ecx
  801e6f:	fd                   	std    
  801e70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e72:	eb 09                	jmp    801e7d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e74:	83 ef 01             	sub    $0x1,%edi
  801e77:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e7a:	fd                   	std    
  801e7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e7d:	fc                   	cld    
  801e7e:	eb 1d                	jmp    801e9d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	09 c2                	or     %eax,%edx
  801e84:	f6 c2 03             	test   $0x3,%dl
  801e87:	75 0f                	jne    801e98 <memmove+0x5f>
  801e89:	f6 c1 03             	test   $0x3,%cl
  801e8c:	75 0a                	jne    801e98 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e8e:	c1 e9 02             	shr    $0x2,%ecx
  801e91:	89 c7                	mov    %eax,%edi
  801e93:	fc                   	cld    
  801e94:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e96:	eb 05                	jmp    801e9d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e98:	89 c7                	mov    %eax,%edi
  801e9a:	fc                   	cld    
  801e9b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e9d:	5e                   	pop    %esi
  801e9e:	5f                   	pop    %edi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801ea4:	ff 75 10             	pushl  0x10(%ebp)
  801ea7:	ff 75 0c             	pushl  0xc(%ebp)
  801eaa:	ff 75 08             	pushl  0x8(%ebp)
  801ead:	e8 87 ff ff ff       	call   801e39 <memmove>
}
  801eb2:	c9                   	leave  
  801eb3:	c3                   	ret    

00801eb4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	56                   	push   %esi
  801eb8:	53                   	push   %ebx
  801eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebf:	89 c6                	mov    %eax,%esi
  801ec1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ec4:	eb 1a                	jmp    801ee0 <memcmp+0x2c>
		if (*s1 != *s2)
  801ec6:	0f b6 08             	movzbl (%eax),%ecx
  801ec9:	0f b6 1a             	movzbl (%edx),%ebx
  801ecc:	38 d9                	cmp    %bl,%cl
  801ece:	74 0a                	je     801eda <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ed0:	0f b6 c1             	movzbl %cl,%eax
  801ed3:	0f b6 db             	movzbl %bl,%ebx
  801ed6:	29 d8                	sub    %ebx,%eax
  801ed8:	eb 0f                	jmp    801ee9 <memcmp+0x35>
		s1++, s2++;
  801eda:	83 c0 01             	add    $0x1,%eax
  801edd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ee0:	39 f0                	cmp    %esi,%eax
  801ee2:	75 e2                	jne    801ec6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ee4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee9:	5b                   	pop    %ebx
  801eea:	5e                   	pop    %esi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    

00801eed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	53                   	push   %ebx
  801ef1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801ef4:	89 c1                	mov    %eax,%ecx
  801ef6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801ef9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801efd:	eb 0a                	jmp    801f09 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801eff:	0f b6 10             	movzbl (%eax),%edx
  801f02:	39 da                	cmp    %ebx,%edx
  801f04:	74 07                	je     801f0d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f06:	83 c0 01             	add    $0x1,%eax
  801f09:	39 c8                	cmp    %ecx,%eax
  801f0b:	72 f2                	jb     801eff <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801f0d:	5b                   	pop    %ebx
  801f0e:	5d                   	pop    %ebp
  801f0f:	c3                   	ret    

00801f10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	57                   	push   %edi
  801f14:	56                   	push   %esi
  801f15:	53                   	push   %ebx
  801f16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f1c:	eb 03                	jmp    801f21 <strtol+0x11>
		s++;
  801f1e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f21:	0f b6 01             	movzbl (%ecx),%eax
  801f24:	3c 20                	cmp    $0x20,%al
  801f26:	74 f6                	je     801f1e <strtol+0xe>
  801f28:	3c 09                	cmp    $0x9,%al
  801f2a:	74 f2                	je     801f1e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801f2c:	3c 2b                	cmp    $0x2b,%al
  801f2e:	75 0a                	jne    801f3a <strtol+0x2a>
		s++;
  801f30:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f33:	bf 00 00 00 00       	mov    $0x0,%edi
  801f38:	eb 11                	jmp    801f4b <strtol+0x3b>
  801f3a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801f3f:	3c 2d                	cmp    $0x2d,%al
  801f41:	75 08                	jne    801f4b <strtol+0x3b>
		s++, neg = 1;
  801f43:	83 c1 01             	add    $0x1,%ecx
  801f46:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f4b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f51:	75 15                	jne    801f68 <strtol+0x58>
  801f53:	80 39 30             	cmpb   $0x30,(%ecx)
  801f56:	75 10                	jne    801f68 <strtol+0x58>
  801f58:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f5c:	75 7c                	jne    801fda <strtol+0xca>
		s += 2, base = 16;
  801f5e:	83 c1 02             	add    $0x2,%ecx
  801f61:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f66:	eb 16                	jmp    801f7e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f68:	85 db                	test   %ebx,%ebx
  801f6a:	75 12                	jne    801f7e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f71:	80 39 30             	cmpb   $0x30,(%ecx)
  801f74:	75 08                	jne    801f7e <strtol+0x6e>
		s++, base = 8;
  801f76:	83 c1 01             	add    $0x1,%ecx
  801f79:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f7e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f83:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f86:	0f b6 11             	movzbl (%ecx),%edx
  801f89:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f8c:	89 f3                	mov    %esi,%ebx
  801f8e:	80 fb 09             	cmp    $0x9,%bl
  801f91:	77 08                	ja     801f9b <strtol+0x8b>
			dig = *s - '0';
  801f93:	0f be d2             	movsbl %dl,%edx
  801f96:	83 ea 30             	sub    $0x30,%edx
  801f99:	eb 22                	jmp    801fbd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f9b:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f9e:	89 f3                	mov    %esi,%ebx
  801fa0:	80 fb 19             	cmp    $0x19,%bl
  801fa3:	77 08                	ja     801fad <strtol+0x9d>
			dig = *s - 'a' + 10;
  801fa5:	0f be d2             	movsbl %dl,%edx
  801fa8:	83 ea 57             	sub    $0x57,%edx
  801fab:	eb 10                	jmp    801fbd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801fad:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fb0:	89 f3                	mov    %esi,%ebx
  801fb2:	80 fb 19             	cmp    $0x19,%bl
  801fb5:	77 16                	ja     801fcd <strtol+0xbd>
			dig = *s - 'A' + 10;
  801fb7:	0f be d2             	movsbl %dl,%edx
  801fba:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801fbd:	3b 55 10             	cmp    0x10(%ebp),%edx
  801fc0:	7d 0b                	jge    801fcd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801fc2:	83 c1 01             	add    $0x1,%ecx
  801fc5:	0f af 45 10          	imul   0x10(%ebp),%eax
  801fc9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801fcb:	eb b9                	jmp    801f86 <strtol+0x76>

	if (endptr)
  801fcd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801fd1:	74 0d                	je     801fe0 <strtol+0xd0>
		*endptr = (char *) s;
  801fd3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd6:	89 0e                	mov    %ecx,(%esi)
  801fd8:	eb 06                	jmp    801fe0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801fda:	85 db                	test   %ebx,%ebx
  801fdc:	74 98                	je     801f76 <strtol+0x66>
  801fde:	eb 9e                	jmp    801f7e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801fe0:	89 c2                	mov    %eax,%edx
  801fe2:	f7 da                	neg    %edx
  801fe4:	85 ff                	test   %edi,%edi
  801fe6:	0f 45 c2             	cmovne %edx,%eax
}
  801fe9:	5b                   	pop    %ebx
  801fea:	5e                   	pop    %esi
  801feb:	5f                   	pop    %edi
  801fec:	5d                   	pop    %ebp
  801fed:	c3                   	ret    

00801fee <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ff4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ffb:	75 2a                	jne    802027 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ffd:	83 ec 04             	sub    $0x4,%esp
  802000:	6a 07                	push   $0x7
  802002:	68 00 f0 bf ee       	push   $0xeebff000
  802007:	6a 00                	push   $0x0
  802009:	e8 6f e1 ff ff       	call   80017d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80200e:	83 c4 10             	add    $0x10,%esp
  802011:	85 c0                	test   %eax,%eax
  802013:	79 12                	jns    802027 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802015:	50                   	push   %eax
  802016:	68 83 25 80 00       	push   $0x802583
  80201b:	6a 23                	push   $0x23
  80201d:	68 20 2a 80 00       	push   $0x802a20
  802022:	e8 22 f6 ff ff       	call   801649 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802027:	8b 45 08             	mov    0x8(%ebp),%eax
  80202a:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80202f:	83 ec 08             	sub    $0x8,%esp
  802032:	68 59 20 80 00       	push   $0x802059
  802037:	6a 00                	push   $0x0
  802039:	e8 8a e2 ff ff       	call   8002c8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	85 c0                	test   %eax,%eax
  802043:	79 12                	jns    802057 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802045:	50                   	push   %eax
  802046:	68 83 25 80 00       	push   $0x802583
  80204b:	6a 2c                	push   $0x2c
  80204d:	68 20 2a 80 00       	push   $0x802a20
  802052:	e8 f2 f5 ff ff       	call   801649 <_panic>
	}
}
  802057:	c9                   	leave  
  802058:	c3                   	ret    

00802059 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802059:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80205a:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80205f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802061:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802064:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802068:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80206d:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802071:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802073:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802076:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802077:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80207a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80207b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80207c:	c3                   	ret    

0080207d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	56                   	push   %esi
  802081:	53                   	push   %ebx
  802082:	8b 75 08             	mov    0x8(%ebp),%esi
  802085:	8b 45 0c             	mov    0xc(%ebp),%eax
  802088:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80208b:	85 c0                	test   %eax,%eax
  80208d:	75 12                	jne    8020a1 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80208f:	83 ec 0c             	sub    $0xc,%esp
  802092:	68 00 00 c0 ee       	push   $0xeec00000
  802097:	e8 91 e2 ff ff       	call   80032d <sys_ipc_recv>
  80209c:	83 c4 10             	add    $0x10,%esp
  80209f:	eb 0c                	jmp    8020ad <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020a1:	83 ec 0c             	sub    $0xc,%esp
  8020a4:	50                   	push   %eax
  8020a5:	e8 83 e2 ff ff       	call   80032d <sys_ipc_recv>
  8020aa:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020ad:	85 f6                	test   %esi,%esi
  8020af:	0f 95 c1             	setne  %cl
  8020b2:	85 db                	test   %ebx,%ebx
  8020b4:	0f 95 c2             	setne  %dl
  8020b7:	84 d1                	test   %dl,%cl
  8020b9:	74 09                	je     8020c4 <ipc_recv+0x47>
  8020bb:	89 c2                	mov    %eax,%edx
  8020bd:	c1 ea 1f             	shr    $0x1f,%edx
  8020c0:	84 d2                	test   %dl,%dl
  8020c2:	75 2d                	jne    8020f1 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020c4:	85 f6                	test   %esi,%esi
  8020c6:	74 0d                	je     8020d5 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020c8:	a1 04 40 80 00       	mov    0x804004,%eax
  8020cd:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020d3:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020d5:	85 db                	test   %ebx,%ebx
  8020d7:	74 0d                	je     8020e6 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8020de:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8020e4:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8020eb:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8020f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f4:	5b                   	pop    %ebx
  8020f5:	5e                   	pop    %esi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    

008020f8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	57                   	push   %edi
  8020fc:	56                   	push   %esi
  8020fd:	53                   	push   %ebx
  8020fe:	83 ec 0c             	sub    $0xc,%esp
  802101:	8b 7d 08             	mov    0x8(%ebp),%edi
  802104:	8b 75 0c             	mov    0xc(%ebp),%esi
  802107:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80210a:	85 db                	test   %ebx,%ebx
  80210c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802111:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802114:	ff 75 14             	pushl  0x14(%ebp)
  802117:	53                   	push   %ebx
  802118:	56                   	push   %esi
  802119:	57                   	push   %edi
  80211a:	e8 eb e1 ff ff       	call   80030a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80211f:	89 c2                	mov    %eax,%edx
  802121:	c1 ea 1f             	shr    $0x1f,%edx
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	84 d2                	test   %dl,%dl
  802129:	74 17                	je     802142 <ipc_send+0x4a>
  80212b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80212e:	74 12                	je     802142 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802130:	50                   	push   %eax
  802131:	68 2e 2a 80 00       	push   $0x802a2e
  802136:	6a 47                	push   $0x47
  802138:	68 3c 2a 80 00       	push   $0x802a3c
  80213d:	e8 07 f5 ff ff       	call   801649 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802142:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802145:	75 07                	jne    80214e <ipc_send+0x56>
			sys_yield();
  802147:	e8 12 e0 ff ff       	call   80015e <sys_yield>
  80214c:	eb c6                	jmp    802114 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80214e:	85 c0                	test   %eax,%eax
  802150:	75 c2                	jne    802114 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802152:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5f                   	pop    %edi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    

0080215a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802160:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802165:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80216b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802171:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802177:	39 ca                	cmp    %ecx,%edx
  802179:	75 13                	jne    80218e <ipc_find_env+0x34>
			return envs[i].env_id;
  80217b:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802181:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802186:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80218c:	eb 0f                	jmp    80219d <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80218e:	83 c0 01             	add    $0x1,%eax
  802191:	3d 00 04 00 00       	cmp    $0x400,%eax
  802196:	75 cd                	jne    802165 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802198:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80219d:	5d                   	pop    %ebp
  80219e:	c3                   	ret    

0080219f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80219f:	55                   	push   %ebp
  8021a0:	89 e5                	mov    %esp,%ebp
  8021a2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	c1 e8 16             	shr    $0x16,%eax
  8021aa:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021b1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b6:	f6 c1 01             	test   $0x1,%cl
  8021b9:	74 1d                	je     8021d8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021bb:	c1 ea 0c             	shr    $0xc,%edx
  8021be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021c5:	f6 c2 01             	test   $0x1,%dl
  8021c8:	74 0e                	je     8021d8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ca:	c1 ea 0c             	shr    $0xc,%edx
  8021cd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021d4:	ef 
  8021d5:	0f b7 c0             	movzwl %ax,%eax
}
  8021d8:	5d                   	pop    %ebp
  8021d9:	c3                   	ret    
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 ca                	mov    %ecx,%edx
  8021ff:	89 f8                	mov    %edi,%eax
  802201:	75 3d                	jne    802240 <__udivdi3+0x60>
  802203:	39 cf                	cmp    %ecx,%edi
  802205:	0f 87 c5 00 00 00    	ja     8022d0 <__udivdi3+0xf0>
  80220b:	85 ff                	test   %edi,%edi
  80220d:	89 fd                	mov    %edi,%ebp
  80220f:	75 0b                	jne    80221c <__udivdi3+0x3c>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	31 d2                	xor    %edx,%edx
  802218:	f7 f7                	div    %edi
  80221a:	89 c5                	mov    %eax,%ebp
  80221c:	89 c8                	mov    %ecx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f5                	div    %ebp
  802222:	89 c1                	mov    %eax,%ecx
  802224:	89 d8                	mov    %ebx,%eax
  802226:	89 cf                	mov    %ecx,%edi
  802228:	f7 f5                	div    %ebp
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 ce                	cmp    %ecx,%esi
  802242:	77 74                	ja     8022b8 <__udivdi3+0xd8>
  802244:	0f bd fe             	bsr    %esi,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0x108>
  802250:	bb 20 00 00 00       	mov    $0x20,%ebx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	89 c5                	mov    %eax,%ebp
  802259:	29 fb                	sub    %edi,%ebx
  80225b:	d3 e6                	shl    %cl,%esi
  80225d:	89 d9                	mov    %ebx,%ecx
  80225f:	d3 ed                	shr    %cl,%ebp
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e0                	shl    %cl,%eax
  802265:	09 ee                	or     %ebp,%esi
  802267:	89 d9                	mov    %ebx,%ecx
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 d5                	mov    %edx,%ebp
  80226f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802273:	d3 ed                	shr    %cl,%ebp
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e2                	shl    %cl,%edx
  802279:	89 d9                	mov    %ebx,%ecx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	09 c2                	or     %eax,%edx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	89 ea                	mov    %ebp,%edx
  802283:	f7 f6                	div    %esi
  802285:	89 d5                	mov    %edx,%ebp
  802287:	89 c3                	mov    %eax,%ebx
  802289:	f7 64 24 0c          	mull   0xc(%esp)
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	72 10                	jb     8022a1 <__udivdi3+0xc1>
  802291:	8b 74 24 08          	mov    0x8(%esp),%esi
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e6                	shl    %cl,%esi
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 07                	jae    8022a4 <__udivdi3+0xc4>
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	75 03                	jne    8022a4 <__udivdi3+0xc4>
  8022a1:	83 eb 01             	sub    $0x1,%ebx
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 db                	xor    %ebx,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	f7 f7                	div    %edi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 fa                	mov    %edi,%edx
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 ce                	cmp    %ecx,%esi
  8022ea:	72 0c                	jb     8022f8 <__udivdi3+0x118>
  8022ec:	31 db                	xor    %ebx,%ebx
  8022ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022f2:	0f 87 34 ff ff ff    	ja     80222c <__udivdi3+0x4c>
  8022f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022fd:	e9 2a ff ff ff       	jmp    80222c <__udivdi3+0x4c>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80231b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80231f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 d2                	test   %edx,%edx
  802329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f3                	mov    %esi,%ebx
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	75 1c                	jne    802358 <__umoddi3+0x48>
  80233c:	39 f7                	cmp    %esi,%edi
  80233e:	76 50                	jbe    802390 <__umoddi3+0x80>
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	f7 f7                	div    %edi
  802346:	89 d0                	mov    %edx,%eax
  802348:	31 d2                	xor    %edx,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	77 52                	ja     8023b0 <__umoddi3+0xa0>
  80235e:	0f bd ea             	bsr    %edx,%ebp
  802361:	83 f5 1f             	xor    $0x1f,%ebp
  802364:	75 5a                	jne    8023c0 <__umoddi3+0xb0>
  802366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	39 0c 24             	cmp    %ecx,(%esp)
  802373:	0f 86 d7 00 00 00    	jbe    802450 <__umoddi3+0x140>
  802379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	85 ff                	test   %edi,%edi
  802392:	89 fd                	mov    %edi,%ebp
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 c8                	mov    %ecx,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	eb 99                	jmp    802348 <__umoddi3+0x38>
  8023af:	90                   	nop
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	83 c4 1c             	add    $0x1c,%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	8b 34 24             	mov    (%esp),%esi
  8023c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	29 ef                	sub    %ebp,%edi
  8023cc:	d3 e0                	shl    %cl,%eax
  8023ce:	89 f9                	mov    %edi,%ecx
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	d3 ea                	shr    %cl,%edx
  8023d4:	89 e9                	mov    %ebp,%ecx
  8023d6:	09 c2                	or     %eax,%edx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 14 24             	mov    %edx,(%esp)
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	d3 e2                	shl    %cl,%edx
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	d3 e3                	shl    %cl,%ebx
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	09 d8                	or     %ebx,%eax
  8023fd:	89 d3                	mov    %edx,%ebx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	f7 34 24             	divl   (%esp)
  802404:	89 d6                	mov    %edx,%esi
  802406:	d3 e3                	shl    %cl,%ebx
  802408:	f7 64 24 04          	mull   0x4(%esp)
  80240c:	39 d6                	cmp    %edx,%esi
  80240e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802412:	89 d1                	mov    %edx,%ecx
  802414:	89 c3                	mov    %eax,%ebx
  802416:	72 08                	jb     802420 <__umoddi3+0x110>
  802418:	75 11                	jne    80242b <__umoddi3+0x11b>
  80241a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80241e:	73 0b                	jae    80242b <__umoddi3+0x11b>
  802420:	2b 44 24 04          	sub    0x4(%esp),%eax
  802424:	1b 14 24             	sbb    (%esp),%edx
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80242f:	29 da                	sub    %ebx,%edx
  802431:	19 ce                	sbb    %ecx,%esi
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 f0                	mov    %esi,%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	d3 ea                	shr    %cl,%edx
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	09 d0                	or     %edx,%eax
  802443:	89 f2                	mov    %esi,%edx
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 f9                	sub    %edi,%ecx
  802452:	19 d6                	sbb    %edx,%esi
  802454:	89 74 24 04          	mov    %esi,0x4(%esp)
  802458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245c:	e9 18 ff ff ff       	jmp    802379 <__umoddi3+0x69>
