
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
  8000ad:	e8 04 08 00 00       	call   8008b6 <close_all>
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
  800126:	68 2a 22 80 00       	push   $0x80222a
  80012b:	6a 23                	push   $0x23
  80012d:	68 47 22 80 00       	push   $0x802247
  800132:	e8 b0 12 00 00       	call   8013e7 <_panic>

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
  8001a7:	68 2a 22 80 00       	push   $0x80222a
  8001ac:	6a 23                	push   $0x23
  8001ae:	68 47 22 80 00       	push   $0x802247
  8001b3:	e8 2f 12 00 00       	call   8013e7 <_panic>

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
  8001e9:	68 2a 22 80 00       	push   $0x80222a
  8001ee:	6a 23                	push   $0x23
  8001f0:	68 47 22 80 00       	push   $0x802247
  8001f5:	e8 ed 11 00 00       	call   8013e7 <_panic>

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
  80022b:	68 2a 22 80 00       	push   $0x80222a
  800230:	6a 23                	push   $0x23
  800232:	68 47 22 80 00       	push   $0x802247
  800237:	e8 ab 11 00 00       	call   8013e7 <_panic>

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
  80026d:	68 2a 22 80 00       	push   $0x80222a
  800272:	6a 23                	push   $0x23
  800274:	68 47 22 80 00       	push   $0x802247
  800279:	e8 69 11 00 00       	call   8013e7 <_panic>

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
  8002af:	68 2a 22 80 00       	push   $0x80222a
  8002b4:	6a 23                	push   $0x23
  8002b6:	68 47 22 80 00       	push   $0x802247
  8002bb:	e8 27 11 00 00       	call   8013e7 <_panic>
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
  8002f1:	68 2a 22 80 00       	push   $0x80222a
  8002f6:	6a 23                	push   $0x23
  8002f8:	68 47 22 80 00       	push   $0x802247
  8002fd:	e8 e5 10 00 00       	call   8013e7 <_panic>

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
  800355:	68 2a 22 80 00       	push   $0x80222a
  80035a:	6a 23                	push   $0x23
  80035c:	68 47 22 80 00       	push   $0x802247
  800361:	e8 81 10 00 00       	call   8013e7 <_panic>

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
  8003f4:	68 55 22 80 00       	push   $0x802255
  8003f9:	6a 1e                	push   $0x1e
  8003fb:	68 65 22 80 00       	push   $0x802265
  800400:	e8 e2 0f 00 00       	call   8013e7 <_panic>
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
  80041e:	68 70 22 80 00       	push   $0x802270
  800423:	6a 2c                	push   $0x2c
  800425:	68 65 22 80 00       	push   $0x802265
  80042a:	e8 b8 0f 00 00       	call   8013e7 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80042f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800435:	83 ec 04             	sub    $0x4,%esp
  800438:	68 00 10 00 00       	push   $0x1000
  80043d:	53                   	push   %ebx
  80043e:	68 00 f0 7f 00       	push   $0x7ff000
  800443:	e8 f7 17 00 00       	call   801c3f <memcpy>

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
  800466:	68 70 22 80 00       	push   $0x802270
  80046b:	6a 33                	push   $0x33
  80046d:	68 65 22 80 00       	push   $0x802265
  800472:	e8 70 0f 00 00       	call   8013e7 <_panic>
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
  80048e:	68 70 22 80 00       	push   $0x802270
  800493:	6a 37                	push   $0x37
  800495:	68 65 22 80 00       	push   $0x802265
  80049a:	e8 48 0f 00 00       	call   8013e7 <_panic>
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
  8004b2:	e8 d5 18 00 00       	call   801d8c <set_pgfault_handler>
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
  8004cb:	68 89 22 80 00       	push   $0x802289
  8004d0:	68 84 00 00 00       	push   $0x84
  8004d5:	68 65 22 80 00       	push   $0x802265
  8004da:	e8 08 0f 00 00       	call   8013e7 <_panic>
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
  800587:	68 97 22 80 00       	push   $0x802297
  80058c:	6a 54                	push   $0x54
  80058e:	68 65 22 80 00       	push   $0x802265
  800593:	e8 4f 0e 00 00       	call   8013e7 <_panic>
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
  8005cc:	68 97 22 80 00       	push   $0x802297
  8005d1:	6a 5b                	push   $0x5b
  8005d3:	68 65 22 80 00       	push   $0x802265
  8005d8:	e8 0a 0e 00 00       	call   8013e7 <_panic>
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
  8005fa:	68 97 22 80 00       	push   $0x802297
  8005ff:	6a 5f                	push   $0x5f
  800601:	68 65 22 80 00       	push   $0x802265
  800606:	e8 dc 0d 00 00       	call   8013e7 <_panic>
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
  800624:	68 97 22 80 00       	push   $0x802297
  800629:	6a 64                	push   $0x64
  80062b:	68 65 22 80 00       	push   $0x802265
  800630:	e8 b2 0d 00 00       	call   8013e7 <_panic>
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
  800693:	68 b0 22 80 00       	push   $0x8022b0
  800698:	e8 23 0e 00 00       	call   8014c0 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80069d:	c7 04 24 87 00 80 00 	movl   $0x800087,(%esp)
  8006a4:	e8 c5 fc ff ff       	call   80036e <sys_thread_create>
  8006a9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	68 b0 22 80 00       	push   $0x8022b0
  8006b4:	e8 07 0e 00 00       	call   8014c0 <cprintf>
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

008006e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8006f3:	c1 e8 0c             	shr    $0xc,%eax
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	05 00 00 00 30       	add    $0x30000000,%eax
  800703:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800708:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800715:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80071a:	89 c2                	mov    %eax,%edx
  80071c:	c1 ea 16             	shr    $0x16,%edx
  80071f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800726:	f6 c2 01             	test   $0x1,%dl
  800729:	74 11                	je     80073c <fd_alloc+0x2d>
  80072b:	89 c2                	mov    %eax,%edx
  80072d:	c1 ea 0c             	shr    $0xc,%edx
  800730:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800737:	f6 c2 01             	test   $0x1,%dl
  80073a:	75 09                	jne    800745 <fd_alloc+0x36>
			*fd_store = fd;
  80073c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80073e:	b8 00 00 00 00       	mov    $0x0,%eax
  800743:	eb 17                	jmp    80075c <fd_alloc+0x4d>
  800745:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80074a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80074f:	75 c9                	jne    80071a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800751:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800757:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800764:	83 f8 1f             	cmp    $0x1f,%eax
  800767:	77 36                	ja     80079f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800769:	c1 e0 0c             	shl    $0xc,%eax
  80076c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800771:	89 c2                	mov    %eax,%edx
  800773:	c1 ea 16             	shr    $0x16,%edx
  800776:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80077d:	f6 c2 01             	test   $0x1,%dl
  800780:	74 24                	je     8007a6 <fd_lookup+0x48>
  800782:	89 c2                	mov    %eax,%edx
  800784:	c1 ea 0c             	shr    $0xc,%edx
  800787:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80078e:	f6 c2 01             	test   $0x1,%dl
  800791:	74 1a                	je     8007ad <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800793:	8b 55 0c             	mov    0xc(%ebp),%edx
  800796:	89 02                	mov    %eax,(%edx)
	return 0;
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
  80079d:	eb 13                	jmp    8007b2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80079f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a4:	eb 0c                	jmp    8007b2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ab:	eb 05                	jmp    8007b2 <fd_lookup+0x54>
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 08             	sub    $0x8,%esp
  8007ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bd:	ba 50 23 80 00       	mov    $0x802350,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007c2:	eb 13                	jmp    8007d7 <dev_lookup+0x23>
  8007c4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007c7:	39 08                	cmp    %ecx,(%eax)
  8007c9:	75 0c                	jne    8007d7 <dev_lookup+0x23>
			*dev = devtab[i];
  8007cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d5:	eb 31                	jmp    800808 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007d7:	8b 02                	mov    (%edx),%eax
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	75 e7                	jne    8007c4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8007e2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8007e8:	83 ec 04             	sub    $0x4,%esp
  8007eb:	51                   	push   %ecx
  8007ec:	50                   	push   %eax
  8007ed:	68 d4 22 80 00       	push   $0x8022d4
  8007f2:	e8 c9 0c 00 00       	call   8014c0 <cprintf>
	*dev = 0;
  8007f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800800:	83 c4 10             	add    $0x10,%esp
  800803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	56                   	push   %esi
  80080e:	53                   	push   %ebx
  80080f:	83 ec 10             	sub    $0x10,%esp
  800812:	8b 75 08             	mov    0x8(%ebp),%esi
  800815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800818:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081b:	50                   	push   %eax
  80081c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800822:	c1 e8 0c             	shr    $0xc,%eax
  800825:	50                   	push   %eax
  800826:	e8 33 ff ff ff       	call   80075e <fd_lookup>
  80082b:	83 c4 08             	add    $0x8,%esp
  80082e:	85 c0                	test   %eax,%eax
  800830:	78 05                	js     800837 <fd_close+0x2d>
	    || fd != fd2)
  800832:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800835:	74 0c                	je     800843 <fd_close+0x39>
		return (must_exist ? r : 0);
  800837:	84 db                	test   %bl,%bl
  800839:	ba 00 00 00 00       	mov    $0x0,%edx
  80083e:	0f 44 c2             	cmove  %edx,%eax
  800841:	eb 41                	jmp    800884 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800849:	50                   	push   %eax
  80084a:	ff 36                	pushl  (%esi)
  80084c:	e8 63 ff ff ff       	call   8007b4 <dev_lookup>
  800851:	89 c3                	mov    %eax,%ebx
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	85 c0                	test   %eax,%eax
  800858:	78 1a                	js     800874 <fd_close+0x6a>
		if (dev->dev_close)
  80085a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800860:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800865:	85 c0                	test   %eax,%eax
  800867:	74 0b                	je     800874 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800869:	83 ec 0c             	sub    $0xc,%esp
  80086c:	56                   	push   %esi
  80086d:	ff d0                	call   *%eax
  80086f:	89 c3                	mov    %eax,%ebx
  800871:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800874:	83 ec 08             	sub    $0x8,%esp
  800877:	56                   	push   %esi
  800878:	6a 00                	push   $0x0
  80087a:	e8 83 f9 ff ff       	call   800202 <sys_page_unmap>
	return r;
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	89 d8                	mov    %ebx,%eax
}
  800884:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800891:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800894:	50                   	push   %eax
  800895:	ff 75 08             	pushl  0x8(%ebp)
  800898:	e8 c1 fe ff ff       	call   80075e <fd_lookup>
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	78 10                	js     8008b4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	6a 01                	push   $0x1
  8008a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8008ac:	e8 59 ff ff ff       	call   80080a <fd_close>
  8008b1:	83 c4 10             	add    $0x10,%esp
}
  8008b4:	c9                   	leave  
  8008b5:	c3                   	ret    

008008b6 <close_all>:

void
close_all(void)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008c2:	83 ec 0c             	sub    $0xc,%esp
  8008c5:	53                   	push   %ebx
  8008c6:	e8 c0 ff ff ff       	call   80088b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008cb:	83 c3 01             	add    $0x1,%ebx
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	83 fb 20             	cmp    $0x20,%ebx
  8008d4:	75 ec                	jne    8008c2 <close_all+0xc>
		close(i);
}
  8008d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	57                   	push   %edi
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
  8008e1:	83 ec 2c             	sub    $0x2c,%esp
  8008e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008ea:	50                   	push   %eax
  8008eb:	ff 75 08             	pushl  0x8(%ebp)
  8008ee:	e8 6b fe ff ff       	call   80075e <fd_lookup>
  8008f3:	83 c4 08             	add    $0x8,%esp
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	0f 88 c1 00 00 00    	js     8009bf <dup+0xe4>
		return r;
	close(newfdnum);
  8008fe:	83 ec 0c             	sub    $0xc,%esp
  800901:	56                   	push   %esi
  800902:	e8 84 ff ff ff       	call   80088b <close>

	newfd = INDEX2FD(newfdnum);
  800907:	89 f3                	mov    %esi,%ebx
  800909:	c1 e3 0c             	shl    $0xc,%ebx
  80090c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800912:	83 c4 04             	add    $0x4,%esp
  800915:	ff 75 e4             	pushl  -0x1c(%ebp)
  800918:	e8 db fd ff ff       	call   8006f8 <fd2data>
  80091d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80091f:	89 1c 24             	mov    %ebx,(%esp)
  800922:	e8 d1 fd ff ff       	call   8006f8 <fd2data>
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	c1 e8 16             	shr    $0x16,%eax
  800932:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800939:	a8 01                	test   $0x1,%al
  80093b:	74 37                	je     800974 <dup+0x99>
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	c1 e8 0c             	shr    $0xc,%eax
  800942:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800949:	f6 c2 01             	test   $0x1,%dl
  80094c:	74 26                	je     800974 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80094e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800955:	83 ec 0c             	sub    $0xc,%esp
  800958:	25 07 0e 00 00       	and    $0xe07,%eax
  80095d:	50                   	push   %eax
  80095e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800961:	6a 00                	push   $0x0
  800963:	57                   	push   %edi
  800964:	6a 00                	push   $0x0
  800966:	e8 55 f8 ff ff       	call   8001c0 <sys_page_map>
  80096b:	89 c7                	mov    %eax,%edi
  80096d:	83 c4 20             	add    $0x20,%esp
  800970:	85 c0                	test   %eax,%eax
  800972:	78 2e                	js     8009a2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800974:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e8 0c             	shr    $0xc,%eax
  80097c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800983:	83 ec 0c             	sub    $0xc,%esp
  800986:	25 07 0e 00 00       	and    $0xe07,%eax
  80098b:	50                   	push   %eax
  80098c:	53                   	push   %ebx
  80098d:	6a 00                	push   $0x0
  80098f:	52                   	push   %edx
  800990:	6a 00                	push   $0x0
  800992:	e8 29 f8 ff ff       	call   8001c0 <sys_page_map>
  800997:	89 c7                	mov    %eax,%edi
  800999:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80099c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80099e:	85 ff                	test   %edi,%edi
  8009a0:	79 1d                	jns    8009bf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	53                   	push   %ebx
  8009a6:	6a 00                	push   $0x0
  8009a8:	e8 55 f8 ff ff       	call   800202 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8009ad:	83 c4 08             	add    $0x8,%esp
  8009b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009b3:	6a 00                	push   $0x0
  8009b5:	e8 48 f8 ff ff       	call   800202 <sys_page_unmap>
	return r;
  8009ba:	83 c4 10             	add    $0x10,%esp
  8009bd:	89 f8                	mov    %edi,%eax
}
  8009bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	53                   	push   %ebx
  8009cb:	83 ec 14             	sub    $0x14,%esp
  8009ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009d4:	50                   	push   %eax
  8009d5:	53                   	push   %ebx
  8009d6:	e8 83 fd ff ff       	call   80075e <fd_lookup>
  8009db:	83 c4 08             	add    $0x8,%esp
  8009de:	89 c2                	mov    %eax,%edx
  8009e0:	85 c0                	test   %eax,%eax
  8009e2:	78 70                	js     800a54 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009e4:	83 ec 08             	sub    $0x8,%esp
  8009e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ea:	50                   	push   %eax
  8009eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ee:	ff 30                	pushl  (%eax)
  8009f0:	e8 bf fd ff ff       	call   8007b4 <dev_lookup>
  8009f5:	83 c4 10             	add    $0x10,%esp
  8009f8:	85 c0                	test   %eax,%eax
  8009fa:	78 4f                	js     800a4b <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009ff:	8b 42 08             	mov    0x8(%edx),%eax
  800a02:	83 e0 03             	and    $0x3,%eax
  800a05:	83 f8 01             	cmp    $0x1,%eax
  800a08:	75 24                	jne    800a2e <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a0a:	a1 04 40 80 00       	mov    0x804004,%eax
  800a0f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a15:	83 ec 04             	sub    $0x4,%esp
  800a18:	53                   	push   %ebx
  800a19:	50                   	push   %eax
  800a1a:	68 15 23 80 00       	push   $0x802315
  800a1f:	e8 9c 0a 00 00       	call   8014c0 <cprintf>
		return -E_INVAL;
  800a24:	83 c4 10             	add    $0x10,%esp
  800a27:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a2c:	eb 26                	jmp    800a54 <read+0x8d>
	}
	if (!dev->dev_read)
  800a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a31:	8b 40 08             	mov    0x8(%eax),%eax
  800a34:	85 c0                	test   %eax,%eax
  800a36:	74 17                	je     800a4f <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a38:	83 ec 04             	sub    $0x4,%esp
  800a3b:	ff 75 10             	pushl  0x10(%ebp)
  800a3e:	ff 75 0c             	pushl  0xc(%ebp)
  800a41:	52                   	push   %edx
  800a42:	ff d0                	call   *%eax
  800a44:	89 c2                	mov    %eax,%edx
  800a46:	83 c4 10             	add    $0x10,%esp
  800a49:	eb 09                	jmp    800a54 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a4b:	89 c2                	mov    %eax,%edx
  800a4d:	eb 05                	jmp    800a54 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a4f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a54:	89 d0                	mov    %edx,%eax
  800a56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	83 ec 0c             	sub    $0xc,%esp
  800a64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a67:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a6f:	eb 21                	jmp    800a92 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a71:	83 ec 04             	sub    $0x4,%esp
  800a74:	89 f0                	mov    %esi,%eax
  800a76:	29 d8                	sub    %ebx,%eax
  800a78:	50                   	push   %eax
  800a79:	89 d8                	mov    %ebx,%eax
  800a7b:	03 45 0c             	add    0xc(%ebp),%eax
  800a7e:	50                   	push   %eax
  800a7f:	57                   	push   %edi
  800a80:	e8 42 ff ff ff       	call   8009c7 <read>
		if (m < 0)
  800a85:	83 c4 10             	add    $0x10,%esp
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	78 10                	js     800a9c <readn+0x41>
			return m;
		if (m == 0)
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	74 0a                	je     800a9a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a90:	01 c3                	add    %eax,%ebx
  800a92:	39 f3                	cmp    %esi,%ebx
  800a94:	72 db                	jb     800a71 <readn+0x16>
  800a96:	89 d8                	mov    %ebx,%eax
  800a98:	eb 02                	jmp    800a9c <readn+0x41>
  800a9a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	53                   	push   %ebx
  800aa8:	83 ec 14             	sub    $0x14,%esp
  800aab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800aae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ab1:	50                   	push   %eax
  800ab2:	53                   	push   %ebx
  800ab3:	e8 a6 fc ff ff       	call   80075e <fd_lookup>
  800ab8:	83 c4 08             	add    $0x8,%esp
  800abb:	89 c2                	mov    %eax,%edx
  800abd:	85 c0                	test   %eax,%eax
  800abf:	78 6b                	js     800b2c <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ac1:	83 ec 08             	sub    $0x8,%esp
  800ac4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac7:	50                   	push   %eax
  800ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800acb:	ff 30                	pushl  (%eax)
  800acd:	e8 e2 fc ff ff       	call   8007b4 <dev_lookup>
  800ad2:	83 c4 10             	add    $0x10,%esp
  800ad5:	85 c0                	test   %eax,%eax
  800ad7:	78 4a                	js     800b23 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800adc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ae0:	75 24                	jne    800b06 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800ae2:	a1 04 40 80 00       	mov    0x804004,%eax
  800ae7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800aed:	83 ec 04             	sub    $0x4,%esp
  800af0:	53                   	push   %ebx
  800af1:	50                   	push   %eax
  800af2:	68 31 23 80 00       	push   $0x802331
  800af7:	e8 c4 09 00 00       	call   8014c0 <cprintf>
		return -E_INVAL;
  800afc:	83 c4 10             	add    $0x10,%esp
  800aff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b04:	eb 26                	jmp    800b2c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b09:	8b 52 0c             	mov    0xc(%edx),%edx
  800b0c:	85 d2                	test   %edx,%edx
  800b0e:	74 17                	je     800b27 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b10:	83 ec 04             	sub    $0x4,%esp
  800b13:	ff 75 10             	pushl  0x10(%ebp)
  800b16:	ff 75 0c             	pushl  0xc(%ebp)
  800b19:	50                   	push   %eax
  800b1a:	ff d2                	call   *%edx
  800b1c:	89 c2                	mov    %eax,%edx
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	eb 09                	jmp    800b2c <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	eb 05                	jmp    800b2c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b27:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b2c:	89 d0                	mov    %edx,%eax
  800b2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b31:	c9                   	leave  
  800b32:	c3                   	ret    

00800b33 <seek>:

int
seek(int fdnum, off_t offset)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b39:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b3c:	50                   	push   %eax
  800b3d:	ff 75 08             	pushl  0x8(%ebp)
  800b40:	e8 19 fc ff ff       	call   80075e <fd_lookup>
  800b45:	83 c4 08             	add    $0x8,%esp
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	78 0e                	js     800b5a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b4c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b52:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	53                   	push   %ebx
  800b60:	83 ec 14             	sub    $0x14,%esp
  800b63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b66:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b69:	50                   	push   %eax
  800b6a:	53                   	push   %ebx
  800b6b:	e8 ee fb ff ff       	call   80075e <fd_lookup>
  800b70:	83 c4 08             	add    $0x8,%esp
  800b73:	89 c2                	mov    %eax,%edx
  800b75:	85 c0                	test   %eax,%eax
  800b77:	78 68                	js     800be1 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b79:	83 ec 08             	sub    $0x8,%esp
  800b7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b7f:	50                   	push   %eax
  800b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b83:	ff 30                	pushl  (%eax)
  800b85:	e8 2a fc ff ff       	call   8007b4 <dev_lookup>
  800b8a:	83 c4 10             	add    $0x10,%esp
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	78 47                	js     800bd8 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b94:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b98:	75 24                	jne    800bbe <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b9a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b9f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800ba5:	83 ec 04             	sub    $0x4,%esp
  800ba8:	53                   	push   %ebx
  800ba9:	50                   	push   %eax
  800baa:	68 f4 22 80 00       	push   $0x8022f4
  800baf:	e8 0c 09 00 00       	call   8014c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800bb4:	83 c4 10             	add    $0x10,%esp
  800bb7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bbc:	eb 23                	jmp    800be1 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800bbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bc1:	8b 52 18             	mov    0x18(%edx),%edx
  800bc4:	85 d2                	test   %edx,%edx
  800bc6:	74 14                	je     800bdc <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800bc8:	83 ec 08             	sub    $0x8,%esp
  800bcb:	ff 75 0c             	pushl  0xc(%ebp)
  800bce:	50                   	push   %eax
  800bcf:	ff d2                	call   *%edx
  800bd1:	89 c2                	mov    %eax,%edx
  800bd3:	83 c4 10             	add    $0x10,%esp
  800bd6:	eb 09                	jmp    800be1 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bd8:	89 c2                	mov    %eax,%edx
  800bda:	eb 05                	jmp    800be1 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800bdc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800be1:	89 d0                	mov    %edx,%eax
  800be3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	53                   	push   %ebx
  800bec:	83 ec 14             	sub    $0x14,%esp
  800bef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bf2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bf5:	50                   	push   %eax
  800bf6:	ff 75 08             	pushl  0x8(%ebp)
  800bf9:	e8 60 fb ff ff       	call   80075e <fd_lookup>
  800bfe:	83 c4 08             	add    $0x8,%esp
  800c01:	89 c2                	mov    %eax,%edx
  800c03:	85 c0                	test   %eax,%eax
  800c05:	78 58                	js     800c5f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c07:	83 ec 08             	sub    $0x8,%esp
  800c0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c0d:	50                   	push   %eax
  800c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c11:	ff 30                	pushl  (%eax)
  800c13:	e8 9c fb ff ff       	call   8007b4 <dev_lookup>
  800c18:	83 c4 10             	add    $0x10,%esp
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	78 37                	js     800c56 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c22:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c26:	74 32                	je     800c5a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c28:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c2b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c32:	00 00 00 
	stat->st_isdir = 0;
  800c35:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c3c:	00 00 00 
	stat->st_dev = dev;
  800c3f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c45:	83 ec 08             	sub    $0x8,%esp
  800c48:	53                   	push   %ebx
  800c49:	ff 75 f0             	pushl  -0x10(%ebp)
  800c4c:	ff 50 14             	call   *0x14(%eax)
  800c4f:	89 c2                	mov    %eax,%edx
  800c51:	83 c4 10             	add    $0x10,%esp
  800c54:	eb 09                	jmp    800c5f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c56:	89 c2                	mov    %eax,%edx
  800c58:	eb 05                	jmp    800c5f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c5a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c5f:	89 d0                	mov    %edx,%eax
  800c61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c64:	c9                   	leave  
  800c65:	c3                   	ret    

00800c66 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c6b:	83 ec 08             	sub    $0x8,%esp
  800c6e:	6a 00                	push   $0x0
  800c70:	ff 75 08             	pushl  0x8(%ebp)
  800c73:	e8 e3 01 00 00       	call   800e5b <open>
  800c78:	89 c3                	mov    %eax,%ebx
  800c7a:	83 c4 10             	add    $0x10,%esp
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	78 1b                	js     800c9c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c81:	83 ec 08             	sub    $0x8,%esp
  800c84:	ff 75 0c             	pushl  0xc(%ebp)
  800c87:	50                   	push   %eax
  800c88:	e8 5b ff ff ff       	call   800be8 <fstat>
  800c8d:	89 c6                	mov    %eax,%esi
	close(fd);
  800c8f:	89 1c 24             	mov    %ebx,(%esp)
  800c92:	e8 f4 fb ff ff       	call   80088b <close>
	return r;
  800c97:	83 c4 10             	add    $0x10,%esp
  800c9a:	89 f0                	mov    %esi,%eax
}
  800c9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	89 c6                	mov    %eax,%esi
  800caa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800cac:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cb3:	75 12                	jne    800cc7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	6a 01                	push   $0x1
  800cba:	e8 39 12 00 00       	call   801ef8 <ipc_find_env>
  800cbf:	a3 00 40 80 00       	mov    %eax,0x804000
  800cc4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cc7:	6a 07                	push   $0x7
  800cc9:	68 00 50 80 00       	push   $0x805000
  800cce:	56                   	push   %esi
  800ccf:	ff 35 00 40 80 00    	pushl  0x804000
  800cd5:	e8 bc 11 00 00       	call   801e96 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800cda:	83 c4 0c             	add    $0xc,%esp
  800cdd:	6a 00                	push   $0x0
  800cdf:	53                   	push   %ebx
  800ce0:	6a 00                	push   $0x0
  800ce2:	e8 34 11 00 00       	call   801e1b <ipc_recv>
}
  800ce7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	8b 40 0c             	mov    0xc(%eax),%eax
  800cfa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d02:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d07:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0c:	b8 02 00 00 00       	mov    $0x2,%eax
  800d11:	e8 8d ff ff ff       	call   800ca3 <fsipc>
}
  800d16:	c9                   	leave  
  800d17:	c3                   	ret    

00800d18 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	8b 40 0c             	mov    0xc(%eax),%eax
  800d24:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d29:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d33:	e8 6b ff ff ff       	call   800ca3 <fsipc>
}
  800d38:	c9                   	leave  
  800d39:	c3                   	ret    

00800d3a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 04             	sub    $0x4,%esp
  800d41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d44:	8b 45 08             	mov    0x8(%ebp),%eax
  800d47:	8b 40 0c             	mov    0xc(%eax),%eax
  800d4a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d54:	b8 05 00 00 00       	mov    $0x5,%eax
  800d59:	e8 45 ff ff ff       	call   800ca3 <fsipc>
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	78 2c                	js     800d8e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d62:	83 ec 08             	sub    $0x8,%esp
  800d65:	68 00 50 80 00       	push   $0x805000
  800d6a:	53                   	push   %ebx
  800d6b:	e8 d5 0c 00 00       	call   801a45 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d70:	a1 80 50 80 00       	mov    0x805080,%eax
  800d75:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d7b:	a1 84 50 80 00       	mov    0x805084,%eax
  800d80:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d86:	83 c4 10             	add    $0x10,%esp
  800d89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d91:	c9                   	leave  
  800d92:	c3                   	ret    

00800d93 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	8b 52 0c             	mov    0xc(%edx),%edx
  800da2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800da8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800dad:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800db2:	0f 47 c2             	cmova  %edx,%eax
  800db5:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800dba:	50                   	push   %eax
  800dbb:	ff 75 0c             	pushl  0xc(%ebp)
  800dbe:	68 08 50 80 00       	push   $0x805008
  800dc3:	e8 0f 0e 00 00       	call   801bd7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcd:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd2:	e8 cc fe ff ff       	call   800ca3 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800dd7:	c9                   	leave  
  800dd8:	c3                   	ret    

00800dd9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
  800dde:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800de1:	8b 45 08             	mov    0x8(%ebp),%eax
  800de4:	8b 40 0c             	mov    0xc(%eax),%eax
  800de7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800dec:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800df2:	ba 00 00 00 00       	mov    $0x0,%edx
  800df7:	b8 03 00 00 00       	mov    $0x3,%eax
  800dfc:	e8 a2 fe ff ff       	call   800ca3 <fsipc>
  800e01:	89 c3                	mov    %eax,%ebx
  800e03:	85 c0                	test   %eax,%eax
  800e05:	78 4b                	js     800e52 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e07:	39 c6                	cmp    %eax,%esi
  800e09:	73 16                	jae    800e21 <devfile_read+0x48>
  800e0b:	68 60 23 80 00       	push   $0x802360
  800e10:	68 67 23 80 00       	push   $0x802367
  800e15:	6a 7c                	push   $0x7c
  800e17:	68 7c 23 80 00       	push   $0x80237c
  800e1c:	e8 c6 05 00 00       	call   8013e7 <_panic>
	assert(r <= PGSIZE);
  800e21:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e26:	7e 16                	jle    800e3e <devfile_read+0x65>
  800e28:	68 87 23 80 00       	push   $0x802387
  800e2d:	68 67 23 80 00       	push   $0x802367
  800e32:	6a 7d                	push   $0x7d
  800e34:	68 7c 23 80 00       	push   $0x80237c
  800e39:	e8 a9 05 00 00       	call   8013e7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e3e:	83 ec 04             	sub    $0x4,%esp
  800e41:	50                   	push   %eax
  800e42:	68 00 50 80 00       	push   $0x805000
  800e47:	ff 75 0c             	pushl  0xc(%ebp)
  800e4a:	e8 88 0d 00 00       	call   801bd7 <memmove>
	return r;
  800e4f:	83 c4 10             	add    $0x10,%esp
}
  800e52:	89 d8                	mov    %ebx,%eax
  800e54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	53                   	push   %ebx
  800e5f:	83 ec 20             	sub    $0x20,%esp
  800e62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e65:	53                   	push   %ebx
  800e66:	e8 a1 0b 00 00       	call   801a0c <strlen>
  800e6b:	83 c4 10             	add    $0x10,%esp
  800e6e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e73:	7f 67                	jg     800edc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e75:	83 ec 0c             	sub    $0xc,%esp
  800e78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7b:	50                   	push   %eax
  800e7c:	e8 8e f8 ff ff       	call   80070f <fd_alloc>
  800e81:	83 c4 10             	add    $0x10,%esp
		return r;
  800e84:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e86:	85 c0                	test   %eax,%eax
  800e88:	78 57                	js     800ee1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e8a:	83 ec 08             	sub    $0x8,%esp
  800e8d:	53                   	push   %ebx
  800e8e:	68 00 50 80 00       	push   $0x805000
  800e93:	e8 ad 0b 00 00       	call   801a45 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ea0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ea3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea8:	e8 f6 fd ff ff       	call   800ca3 <fsipc>
  800ead:	89 c3                	mov    %eax,%ebx
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	79 14                	jns    800eca <open+0x6f>
		fd_close(fd, 0);
  800eb6:	83 ec 08             	sub    $0x8,%esp
  800eb9:	6a 00                	push   $0x0
  800ebb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebe:	e8 47 f9 ff ff       	call   80080a <fd_close>
		return r;
  800ec3:	83 c4 10             	add    $0x10,%esp
  800ec6:	89 da                	mov    %ebx,%edx
  800ec8:	eb 17                	jmp    800ee1 <open+0x86>
	}

	return fd2num(fd);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed0:	e8 13 f8 ff ff       	call   8006e8 <fd2num>
  800ed5:	89 c2                	mov    %eax,%edx
  800ed7:	83 c4 10             	add    $0x10,%esp
  800eda:	eb 05                	jmp    800ee1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800edc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ee1:	89 d0                	mov    %edx,%eax
  800ee3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee6:	c9                   	leave  
  800ee7:	c3                   	ret    

00800ee8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800eee:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef8:	e8 a6 fd ff ff       	call   800ca3 <fsipc>
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	ff 75 08             	pushl  0x8(%ebp)
  800f0d:	e8 e6 f7 ff ff       	call   8006f8 <fd2data>
  800f12:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f14:	83 c4 08             	add    $0x8,%esp
  800f17:	68 93 23 80 00       	push   $0x802393
  800f1c:	53                   	push   %ebx
  800f1d:	e8 23 0b 00 00       	call   801a45 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f22:	8b 46 04             	mov    0x4(%esi),%eax
  800f25:	2b 06                	sub    (%esi),%eax
  800f27:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f2d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f34:	00 00 00 
	stat->st_dev = &devpipe;
  800f37:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f3e:	30 80 00 
	return 0;
}
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    

00800f4d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	53                   	push   %ebx
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f57:	53                   	push   %ebx
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 a3 f2 ff ff       	call   800202 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f5f:	89 1c 24             	mov    %ebx,(%esp)
  800f62:	e8 91 f7 ff ff       	call   8006f8 <fd2data>
  800f67:	83 c4 08             	add    $0x8,%esp
  800f6a:	50                   	push   %eax
  800f6b:	6a 00                	push   $0x0
  800f6d:	e8 90 f2 ff ff       	call   800202 <sys_page_unmap>
}
  800f72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	57                   	push   %edi
  800f7b:	56                   	push   %esi
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 1c             	sub    $0x1c,%esp
  800f80:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f83:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f85:	a1 04 40 80 00       	mov    0x804004,%eax
  800f8a:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f90:	83 ec 0c             	sub    $0xc,%esp
  800f93:	ff 75 e0             	pushl  -0x20(%ebp)
  800f96:	e8 a2 0f 00 00       	call   801f3d <pageref>
  800f9b:	89 c3                	mov    %eax,%ebx
  800f9d:	89 3c 24             	mov    %edi,(%esp)
  800fa0:	e8 98 0f 00 00       	call   801f3d <pageref>
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	39 c3                	cmp    %eax,%ebx
  800faa:	0f 94 c1             	sete   %cl
  800fad:	0f b6 c9             	movzbl %cl,%ecx
  800fb0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800fb3:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fb9:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  800fbf:	39 ce                	cmp    %ecx,%esi
  800fc1:	74 1e                	je     800fe1 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800fc3:	39 c3                	cmp    %eax,%ebx
  800fc5:	75 be                	jne    800f85 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fc7:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  800fcd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd0:	50                   	push   %eax
  800fd1:	56                   	push   %esi
  800fd2:	68 9a 23 80 00       	push   $0x80239a
  800fd7:	e8 e4 04 00 00       	call   8014c0 <cprintf>
  800fdc:	83 c4 10             	add    $0x10,%esp
  800fdf:	eb a4                	jmp    800f85 <_pipeisclosed+0xe>
	}
}
  800fe1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	57                   	push   %edi
  800ff0:	56                   	push   %esi
  800ff1:	53                   	push   %ebx
  800ff2:	83 ec 28             	sub    $0x28,%esp
  800ff5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800ff8:	56                   	push   %esi
  800ff9:	e8 fa f6 ff ff       	call   8006f8 <fd2data>
  800ffe:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	bf 00 00 00 00       	mov    $0x0,%edi
  801008:	eb 4b                	jmp    801055 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80100a:	89 da                	mov    %ebx,%edx
  80100c:	89 f0                	mov    %esi,%eax
  80100e:	e8 64 ff ff ff       	call   800f77 <_pipeisclosed>
  801013:	85 c0                	test   %eax,%eax
  801015:	75 48                	jne    80105f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801017:	e8 42 f1 ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80101c:	8b 43 04             	mov    0x4(%ebx),%eax
  80101f:	8b 0b                	mov    (%ebx),%ecx
  801021:	8d 51 20             	lea    0x20(%ecx),%edx
  801024:	39 d0                	cmp    %edx,%eax
  801026:	73 e2                	jae    80100a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801028:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80102f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801032:	89 c2                	mov    %eax,%edx
  801034:	c1 fa 1f             	sar    $0x1f,%edx
  801037:	89 d1                	mov    %edx,%ecx
  801039:	c1 e9 1b             	shr    $0x1b,%ecx
  80103c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80103f:	83 e2 1f             	and    $0x1f,%edx
  801042:	29 ca                	sub    %ecx,%edx
  801044:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801048:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80104c:	83 c0 01             	add    $0x1,%eax
  80104f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801052:	83 c7 01             	add    $0x1,%edi
  801055:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801058:	75 c2                	jne    80101c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80105a:	8b 45 10             	mov    0x10(%ebp),%eax
  80105d:	eb 05                	jmp    801064 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80105f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801064:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5f                   	pop    %edi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	57                   	push   %edi
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
  801072:	83 ec 18             	sub    $0x18,%esp
  801075:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801078:	57                   	push   %edi
  801079:	e8 7a f6 ff ff       	call   8006f8 <fd2data>
  80107e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	bb 00 00 00 00       	mov    $0x0,%ebx
  801088:	eb 3d                	jmp    8010c7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80108a:	85 db                	test   %ebx,%ebx
  80108c:	74 04                	je     801092 <devpipe_read+0x26>
				return i;
  80108e:	89 d8                	mov    %ebx,%eax
  801090:	eb 44                	jmp    8010d6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801092:	89 f2                	mov    %esi,%edx
  801094:	89 f8                	mov    %edi,%eax
  801096:	e8 dc fe ff ff       	call   800f77 <_pipeisclosed>
  80109b:	85 c0                	test   %eax,%eax
  80109d:	75 32                	jne    8010d1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80109f:	e8 ba f0 ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010a4:	8b 06                	mov    (%esi),%eax
  8010a6:	3b 46 04             	cmp    0x4(%esi),%eax
  8010a9:	74 df                	je     80108a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010ab:	99                   	cltd   
  8010ac:	c1 ea 1b             	shr    $0x1b,%edx
  8010af:	01 d0                	add    %edx,%eax
  8010b1:	83 e0 1f             	and    $0x1f,%eax
  8010b4:	29 d0                	sub    %edx,%eax
  8010b6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010be:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010c1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010c4:	83 c3 01             	add    $0x1,%ebx
  8010c7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010ca:	75 d8                	jne    8010a4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8010cf:	eb 05                	jmp    8010d6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010d1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d9:	5b                   	pop    %ebx
  8010da:	5e                   	pop    %esi
  8010db:	5f                   	pop    %edi
  8010dc:	5d                   	pop    %ebp
  8010dd:	c3                   	ret    

008010de <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e9:	50                   	push   %eax
  8010ea:	e8 20 f6 ff ff       	call   80070f <fd_alloc>
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	89 c2                	mov    %eax,%edx
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	0f 88 2c 01 00 00    	js     801228 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010fc:	83 ec 04             	sub    $0x4,%esp
  8010ff:	68 07 04 00 00       	push   $0x407
  801104:	ff 75 f4             	pushl  -0xc(%ebp)
  801107:	6a 00                	push   $0x0
  801109:	e8 6f f0 ff ff       	call   80017d <sys_page_alloc>
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	89 c2                	mov    %eax,%edx
  801113:	85 c0                	test   %eax,%eax
  801115:	0f 88 0d 01 00 00    	js     801228 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801121:	50                   	push   %eax
  801122:	e8 e8 f5 ff ff       	call   80070f <fd_alloc>
  801127:	89 c3                	mov    %eax,%ebx
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	0f 88 e2 00 00 00    	js     801216 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801134:	83 ec 04             	sub    $0x4,%esp
  801137:	68 07 04 00 00       	push   $0x407
  80113c:	ff 75 f0             	pushl  -0x10(%ebp)
  80113f:	6a 00                	push   $0x0
  801141:	e8 37 f0 ff ff       	call   80017d <sys_page_alloc>
  801146:	89 c3                	mov    %eax,%ebx
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	0f 88 c3 00 00 00    	js     801216 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	ff 75 f4             	pushl  -0xc(%ebp)
  801159:	e8 9a f5 ff ff       	call   8006f8 <fd2data>
  80115e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801160:	83 c4 0c             	add    $0xc,%esp
  801163:	68 07 04 00 00       	push   $0x407
  801168:	50                   	push   %eax
  801169:	6a 00                	push   $0x0
  80116b:	e8 0d f0 ff ff       	call   80017d <sys_page_alloc>
  801170:	89 c3                	mov    %eax,%ebx
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	85 c0                	test   %eax,%eax
  801177:	0f 88 89 00 00 00    	js     801206 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	ff 75 f0             	pushl  -0x10(%ebp)
  801183:	e8 70 f5 ff ff       	call   8006f8 <fd2data>
  801188:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80118f:	50                   	push   %eax
  801190:	6a 00                	push   $0x0
  801192:	56                   	push   %esi
  801193:	6a 00                	push   $0x0
  801195:	e8 26 f0 ff ff       	call   8001c0 <sys_page_map>
  80119a:	89 c3                	mov    %eax,%ebx
  80119c:	83 c4 20             	add    $0x20,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 55                	js     8011f8 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8011a3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ac:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011b8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011cd:	83 ec 0c             	sub    $0xc,%esp
  8011d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d3:	e8 10 f5 ff ff       	call   8006e8 <fd2num>
  8011d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011db:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011dd:	83 c4 04             	add    $0x4,%esp
  8011e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8011e3:	e8 00 f5 ff ff       	call   8006e8 <fd2num>
  8011e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011eb:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f6:	eb 30                	jmp    801228 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	56                   	push   %esi
  8011fc:	6a 00                	push   $0x0
  8011fe:	e8 ff ef ff ff       	call   800202 <sys_page_unmap>
  801203:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801206:	83 ec 08             	sub    $0x8,%esp
  801209:	ff 75 f0             	pushl  -0x10(%ebp)
  80120c:	6a 00                	push   $0x0
  80120e:	e8 ef ef ff ff       	call   800202 <sys_page_unmap>
  801213:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801216:	83 ec 08             	sub    $0x8,%esp
  801219:	ff 75 f4             	pushl  -0xc(%ebp)
  80121c:	6a 00                	push   $0x0
  80121e:	e8 df ef ff ff       	call   800202 <sys_page_unmap>
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801228:	89 d0                	mov    %edx,%eax
  80122a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801237:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	ff 75 08             	pushl  0x8(%ebp)
  80123e:	e8 1b f5 ff ff       	call   80075e <fd_lookup>
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	78 18                	js     801262 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80124a:	83 ec 0c             	sub    $0xc,%esp
  80124d:	ff 75 f4             	pushl  -0xc(%ebp)
  801250:	e8 a3 f4 ff ff       	call   8006f8 <fd2data>
	return _pipeisclosed(fd, p);
  801255:	89 c2                	mov    %eax,%edx
  801257:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125a:	e8 18 fd ff ff       	call   800f77 <_pipeisclosed>
  80125f:	83 c4 10             	add    $0x10,%esp
}
  801262:	c9                   	leave  
  801263:	c3                   	ret    

00801264 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801267:	b8 00 00 00 00       	mov    $0x0,%eax
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801274:	68 b2 23 80 00       	push   $0x8023b2
  801279:	ff 75 0c             	pushl  0xc(%ebp)
  80127c:	e8 c4 07 00 00       	call   801a45 <strcpy>
	return 0;
}
  801281:	b8 00 00 00 00       	mov    $0x0,%eax
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	57                   	push   %edi
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801294:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801299:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80129f:	eb 2d                	jmp    8012ce <devcons_write+0x46>
		m = n - tot;
  8012a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012a4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8012a6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012a9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8012ae:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012b1:	83 ec 04             	sub    $0x4,%esp
  8012b4:	53                   	push   %ebx
  8012b5:	03 45 0c             	add    0xc(%ebp),%eax
  8012b8:	50                   	push   %eax
  8012b9:	57                   	push   %edi
  8012ba:	e8 18 09 00 00       	call   801bd7 <memmove>
		sys_cputs(buf, m);
  8012bf:	83 c4 08             	add    $0x8,%esp
  8012c2:	53                   	push   %ebx
  8012c3:	57                   	push   %edi
  8012c4:	e8 f8 ed ff ff       	call   8000c1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012c9:	01 de                	add    %ebx,%esi
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	89 f0                	mov    %esi,%eax
  8012d0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012d3:	72 cc                	jb     8012a1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d8:	5b                   	pop    %ebx
  8012d9:	5e                   	pop    %esi
  8012da:	5f                   	pop    %edi
  8012db:	5d                   	pop    %ebp
  8012dc:	c3                   	ret    

008012dd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	83 ec 08             	sub    $0x8,%esp
  8012e3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012ec:	74 2a                	je     801318 <devcons_read+0x3b>
  8012ee:	eb 05                	jmp    8012f5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012f0:	e8 69 ee ff ff       	call   80015e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012f5:	e8 e5 ed ff ff       	call   8000df <sys_cgetc>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	74 f2                	je     8012f0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 16                	js     801318 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801302:	83 f8 04             	cmp    $0x4,%eax
  801305:	74 0c                	je     801313 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801307:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130a:	88 02                	mov    %al,(%edx)
	return 1;
  80130c:	b8 01 00 00 00       	mov    $0x1,%eax
  801311:	eb 05                	jmp    801318 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801313:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801320:	8b 45 08             	mov    0x8(%ebp),%eax
  801323:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801326:	6a 01                	push   $0x1
  801328:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80132b:	50                   	push   %eax
  80132c:	e8 90 ed ff ff       	call   8000c1 <sys_cputs>
}
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <getchar>:

int
getchar(void)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80133c:	6a 01                	push   $0x1
  80133e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801341:	50                   	push   %eax
  801342:	6a 00                	push   $0x0
  801344:	e8 7e f6 ff ff       	call   8009c7 <read>
	if (r < 0)
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 0f                	js     80135f <getchar+0x29>
		return r;
	if (r < 1)
  801350:	85 c0                	test   %eax,%eax
  801352:	7e 06                	jle    80135a <getchar+0x24>
		return -E_EOF;
	return c;
  801354:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801358:	eb 05                	jmp    80135f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80135a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136a:	50                   	push   %eax
  80136b:	ff 75 08             	pushl  0x8(%ebp)
  80136e:	e8 eb f3 ff ff       	call   80075e <fd_lookup>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	78 11                	js     80138b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80137a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801383:	39 10                	cmp    %edx,(%eax)
  801385:	0f 94 c0             	sete   %al
  801388:	0f b6 c0             	movzbl %al,%eax
}
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <opencons>:

int
opencons(void)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801393:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801396:	50                   	push   %eax
  801397:	e8 73 f3 ff ff       	call   80070f <fd_alloc>
  80139c:	83 c4 10             	add    $0x10,%esp
		return r;
  80139f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 3e                	js     8013e3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	68 07 04 00 00       	push   $0x407
  8013ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b0:	6a 00                	push   $0x0
  8013b2:	e8 c6 ed ff ff       	call   80017d <sys_page_alloc>
  8013b7:	83 c4 10             	add    $0x10,%esp
		return r;
  8013ba:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 23                	js     8013e3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013c0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013d5:	83 ec 0c             	sub    $0xc,%esp
  8013d8:	50                   	push   %eax
  8013d9:	e8 0a f3 ff ff       	call   8006e8 <fd2num>
  8013de:	89 c2                	mov    %eax,%edx
  8013e0:	83 c4 10             	add    $0x10,%esp
}
  8013e3:	89 d0                	mov    %edx,%eax
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	56                   	push   %esi
  8013eb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013ec:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013ef:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013f5:	e8 45 ed ff ff       	call   80013f <sys_getenvid>
  8013fa:	83 ec 0c             	sub    $0xc,%esp
  8013fd:	ff 75 0c             	pushl  0xc(%ebp)
  801400:	ff 75 08             	pushl  0x8(%ebp)
  801403:	56                   	push   %esi
  801404:	50                   	push   %eax
  801405:	68 c0 23 80 00       	push   $0x8023c0
  80140a:	e8 b1 00 00 00       	call   8014c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80140f:	83 c4 18             	add    $0x18,%esp
  801412:	53                   	push   %ebx
  801413:	ff 75 10             	pushl  0x10(%ebp)
  801416:	e8 54 00 00 00       	call   80146f <vcprintf>
	cprintf("\n");
  80141b:	c7 04 24 ab 23 80 00 	movl   $0x8023ab,(%esp)
  801422:	e8 99 00 00 00       	call   8014c0 <cprintf>
  801427:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80142a:	cc                   	int3   
  80142b:	eb fd                	jmp    80142a <_panic+0x43>

0080142d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	53                   	push   %ebx
  801431:	83 ec 04             	sub    $0x4,%esp
  801434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801437:	8b 13                	mov    (%ebx),%edx
  801439:	8d 42 01             	lea    0x1(%edx),%eax
  80143c:	89 03                	mov    %eax,(%ebx)
  80143e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801441:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801445:	3d ff 00 00 00       	cmp    $0xff,%eax
  80144a:	75 1a                	jne    801466 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	68 ff 00 00 00       	push   $0xff
  801454:	8d 43 08             	lea    0x8(%ebx),%eax
  801457:	50                   	push   %eax
  801458:	e8 64 ec ff ff       	call   8000c1 <sys_cputs>
		b->idx = 0;
  80145d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801463:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801466:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80146a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801478:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80147f:	00 00 00 
	b.cnt = 0;
  801482:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801489:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80148c:	ff 75 0c             	pushl  0xc(%ebp)
  80148f:	ff 75 08             	pushl  0x8(%ebp)
  801492:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	68 2d 14 80 00       	push   $0x80142d
  80149e:	e8 54 01 00 00       	call   8015f7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014a3:	83 c4 08             	add    $0x8,%esp
  8014a6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014b2:	50                   	push   %eax
  8014b3:	e8 09 ec ff ff       	call   8000c1 <sys_cputs>

	return b.cnt;
}
  8014b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014be:	c9                   	leave  
  8014bf:	c3                   	ret    

008014c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014c9:	50                   	push   %eax
  8014ca:	ff 75 08             	pushl  0x8(%ebp)
  8014cd:	e8 9d ff ff ff       	call   80146f <vcprintf>
	va_end(ap);

	return cnt;
}
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	57                   	push   %edi
  8014d8:	56                   	push   %esi
  8014d9:	53                   	push   %ebx
  8014da:	83 ec 1c             	sub    $0x1c,%esp
  8014dd:	89 c7                	mov    %eax,%edi
  8014df:	89 d6                	mov    %edx,%esi
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014f8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014fb:	39 d3                	cmp    %edx,%ebx
  8014fd:	72 05                	jb     801504 <printnum+0x30>
  8014ff:	39 45 10             	cmp    %eax,0x10(%ebp)
  801502:	77 45                	ja     801549 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801504:	83 ec 0c             	sub    $0xc,%esp
  801507:	ff 75 18             	pushl  0x18(%ebp)
  80150a:	8b 45 14             	mov    0x14(%ebp),%eax
  80150d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801510:	53                   	push   %ebx
  801511:	ff 75 10             	pushl  0x10(%ebp)
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	ff 75 e4             	pushl  -0x1c(%ebp)
  80151a:	ff 75 e0             	pushl  -0x20(%ebp)
  80151d:	ff 75 dc             	pushl  -0x24(%ebp)
  801520:	ff 75 d8             	pushl  -0x28(%ebp)
  801523:	e8 58 0a 00 00       	call   801f80 <__udivdi3>
  801528:	83 c4 18             	add    $0x18,%esp
  80152b:	52                   	push   %edx
  80152c:	50                   	push   %eax
  80152d:	89 f2                	mov    %esi,%edx
  80152f:	89 f8                	mov    %edi,%eax
  801531:	e8 9e ff ff ff       	call   8014d4 <printnum>
  801536:	83 c4 20             	add    $0x20,%esp
  801539:	eb 18                	jmp    801553 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	56                   	push   %esi
  80153f:	ff 75 18             	pushl  0x18(%ebp)
  801542:	ff d7                	call   *%edi
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	eb 03                	jmp    80154c <printnum+0x78>
  801549:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80154c:	83 eb 01             	sub    $0x1,%ebx
  80154f:	85 db                	test   %ebx,%ebx
  801551:	7f e8                	jg     80153b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801553:	83 ec 08             	sub    $0x8,%esp
  801556:	56                   	push   %esi
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80155d:	ff 75 e0             	pushl  -0x20(%ebp)
  801560:	ff 75 dc             	pushl  -0x24(%ebp)
  801563:	ff 75 d8             	pushl  -0x28(%ebp)
  801566:	e8 45 0b 00 00       	call   8020b0 <__umoddi3>
  80156b:	83 c4 14             	add    $0x14,%esp
  80156e:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801575:	50                   	push   %eax
  801576:	ff d7                	call   *%edi
}
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5e                   	pop    %esi
  801580:	5f                   	pop    %edi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    

00801583 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801586:	83 fa 01             	cmp    $0x1,%edx
  801589:	7e 0e                	jle    801599 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80158b:	8b 10                	mov    (%eax),%edx
  80158d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801590:	89 08                	mov    %ecx,(%eax)
  801592:	8b 02                	mov    (%edx),%eax
  801594:	8b 52 04             	mov    0x4(%edx),%edx
  801597:	eb 22                	jmp    8015bb <getuint+0x38>
	else if (lflag)
  801599:	85 d2                	test   %edx,%edx
  80159b:	74 10                	je     8015ad <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80159d:	8b 10                	mov    (%eax),%edx
  80159f:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015a2:	89 08                	mov    %ecx,(%eax)
  8015a4:	8b 02                	mov    (%edx),%eax
  8015a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ab:	eb 0e                	jmp    8015bb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015ad:	8b 10                	mov    (%eax),%edx
  8015af:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015b2:	89 08                	mov    %ecx,(%eax)
  8015b4:	8b 02                	mov    (%edx),%eax
  8015b6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015bb:	5d                   	pop    %ebp
  8015bc:	c3                   	ret    

008015bd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015c3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015c7:	8b 10                	mov    (%eax),%edx
  8015c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8015cc:	73 0a                	jae    8015d8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8015ce:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015d1:	89 08                	mov    %ecx,(%eax)
  8015d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d6:	88 02                	mov    %al,(%edx)
}
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    

008015da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015e3:	50                   	push   %eax
  8015e4:	ff 75 10             	pushl  0x10(%ebp)
  8015e7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ea:	ff 75 08             	pushl  0x8(%ebp)
  8015ed:	e8 05 00 00 00       	call   8015f7 <vprintfmt>
	va_end(ap);
}
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	c9                   	leave  
  8015f6:	c3                   	ret    

008015f7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	57                   	push   %edi
  8015fb:	56                   	push   %esi
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 2c             	sub    $0x2c,%esp
  801600:	8b 75 08             	mov    0x8(%ebp),%esi
  801603:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801606:	8b 7d 10             	mov    0x10(%ebp),%edi
  801609:	eb 12                	jmp    80161d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80160b:	85 c0                	test   %eax,%eax
  80160d:	0f 84 89 03 00 00    	je     80199c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	53                   	push   %ebx
  801617:	50                   	push   %eax
  801618:	ff d6                	call   *%esi
  80161a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80161d:	83 c7 01             	add    $0x1,%edi
  801620:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801624:	83 f8 25             	cmp    $0x25,%eax
  801627:	75 e2                	jne    80160b <vprintfmt+0x14>
  801629:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80162d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801634:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80163b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801642:	ba 00 00 00 00       	mov    $0x0,%edx
  801647:	eb 07                	jmp    801650 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801649:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80164c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801650:	8d 47 01             	lea    0x1(%edi),%eax
  801653:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801656:	0f b6 07             	movzbl (%edi),%eax
  801659:	0f b6 c8             	movzbl %al,%ecx
  80165c:	83 e8 23             	sub    $0x23,%eax
  80165f:	3c 55                	cmp    $0x55,%al
  801661:	0f 87 1a 03 00 00    	ja     801981 <vprintfmt+0x38a>
  801667:	0f b6 c0             	movzbl %al,%eax
  80166a:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801674:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801678:	eb d6                	jmp    801650 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80167a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80167d:	b8 00 00 00 00       	mov    $0x0,%eax
  801682:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801685:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801688:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80168c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80168f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801692:	83 fa 09             	cmp    $0x9,%edx
  801695:	77 39                	ja     8016d0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801697:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80169a:	eb e9                	jmp    801685 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80169c:	8b 45 14             	mov    0x14(%ebp),%eax
  80169f:	8d 48 04             	lea    0x4(%eax),%ecx
  8016a2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8016a5:	8b 00                	mov    (%eax),%eax
  8016a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016ad:	eb 27                	jmp    8016d6 <vprintfmt+0xdf>
  8016af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016b9:	0f 49 c8             	cmovns %eax,%ecx
  8016bc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016c2:	eb 8c                	jmp    801650 <vprintfmt+0x59>
  8016c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8016c7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016ce:	eb 80                	jmp    801650 <vprintfmt+0x59>
  8016d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016da:	0f 89 70 ff ff ff    	jns    801650 <vprintfmt+0x59>
				width = precision, precision = -1;
  8016e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016e6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016ed:	e9 5e ff ff ff       	jmp    801650 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016f2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016f8:	e9 53 ff ff ff       	jmp    801650 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801700:	8d 50 04             	lea    0x4(%eax),%edx
  801703:	89 55 14             	mov    %edx,0x14(%ebp)
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	53                   	push   %ebx
  80170a:	ff 30                	pushl  (%eax)
  80170c:	ff d6                	call   *%esi
			break;
  80170e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801711:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801714:	e9 04 ff ff ff       	jmp    80161d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801719:	8b 45 14             	mov    0x14(%ebp),%eax
  80171c:	8d 50 04             	lea    0x4(%eax),%edx
  80171f:	89 55 14             	mov    %edx,0x14(%ebp)
  801722:	8b 00                	mov    (%eax),%eax
  801724:	99                   	cltd   
  801725:	31 d0                	xor    %edx,%eax
  801727:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801729:	83 f8 0f             	cmp    $0xf,%eax
  80172c:	7f 0b                	jg     801739 <vprintfmt+0x142>
  80172e:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801735:	85 d2                	test   %edx,%edx
  801737:	75 18                	jne    801751 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801739:	50                   	push   %eax
  80173a:	68 fb 23 80 00       	push   $0x8023fb
  80173f:	53                   	push   %ebx
  801740:	56                   	push   %esi
  801741:	e8 94 fe ff ff       	call   8015da <printfmt>
  801746:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801749:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80174c:	e9 cc fe ff ff       	jmp    80161d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801751:	52                   	push   %edx
  801752:	68 79 23 80 00       	push   $0x802379
  801757:	53                   	push   %ebx
  801758:	56                   	push   %esi
  801759:	e8 7c fe ff ff       	call   8015da <printfmt>
  80175e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801761:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801764:	e9 b4 fe ff ff       	jmp    80161d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801769:	8b 45 14             	mov    0x14(%ebp),%eax
  80176c:	8d 50 04             	lea    0x4(%eax),%edx
  80176f:	89 55 14             	mov    %edx,0x14(%ebp)
  801772:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801774:	85 ff                	test   %edi,%edi
  801776:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80177b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80177e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801782:	0f 8e 94 00 00 00    	jle    80181c <vprintfmt+0x225>
  801788:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80178c:	0f 84 98 00 00 00    	je     80182a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801792:	83 ec 08             	sub    $0x8,%esp
  801795:	ff 75 d0             	pushl  -0x30(%ebp)
  801798:	57                   	push   %edi
  801799:	e8 86 02 00 00       	call   801a24 <strnlen>
  80179e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017a1:	29 c1                	sub    %eax,%ecx
  8017a3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8017a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017b5:	eb 0f                	jmp    8017c6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8017b7:	83 ec 08             	sub    $0x8,%esp
  8017ba:	53                   	push   %ebx
  8017bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8017be:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017c0:	83 ef 01             	sub    $0x1,%edi
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	85 ff                	test   %edi,%edi
  8017c8:	7f ed                	jg     8017b7 <vprintfmt+0x1c0>
  8017ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017cd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017d0:	85 c9                	test   %ecx,%ecx
  8017d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d7:	0f 49 c1             	cmovns %ecx,%eax
  8017da:	29 c1                	sub    %eax,%ecx
  8017dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8017df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017e5:	89 cb                	mov    %ecx,%ebx
  8017e7:	eb 4d                	jmp    801836 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017ed:	74 1b                	je     80180a <vprintfmt+0x213>
  8017ef:	0f be c0             	movsbl %al,%eax
  8017f2:	83 e8 20             	sub    $0x20,%eax
  8017f5:	83 f8 5e             	cmp    $0x5e,%eax
  8017f8:	76 10                	jbe    80180a <vprintfmt+0x213>
					putch('?', putdat);
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	ff 75 0c             	pushl  0xc(%ebp)
  801800:	6a 3f                	push   $0x3f
  801802:	ff 55 08             	call   *0x8(%ebp)
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	eb 0d                	jmp    801817 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80180a:	83 ec 08             	sub    $0x8,%esp
  80180d:	ff 75 0c             	pushl  0xc(%ebp)
  801810:	52                   	push   %edx
  801811:	ff 55 08             	call   *0x8(%ebp)
  801814:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801817:	83 eb 01             	sub    $0x1,%ebx
  80181a:	eb 1a                	jmp    801836 <vprintfmt+0x23f>
  80181c:	89 75 08             	mov    %esi,0x8(%ebp)
  80181f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801822:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801825:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801828:	eb 0c                	jmp    801836 <vprintfmt+0x23f>
  80182a:	89 75 08             	mov    %esi,0x8(%ebp)
  80182d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801830:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801833:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801836:	83 c7 01             	add    $0x1,%edi
  801839:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80183d:	0f be d0             	movsbl %al,%edx
  801840:	85 d2                	test   %edx,%edx
  801842:	74 23                	je     801867 <vprintfmt+0x270>
  801844:	85 f6                	test   %esi,%esi
  801846:	78 a1                	js     8017e9 <vprintfmt+0x1f2>
  801848:	83 ee 01             	sub    $0x1,%esi
  80184b:	79 9c                	jns    8017e9 <vprintfmt+0x1f2>
  80184d:	89 df                	mov    %ebx,%edi
  80184f:	8b 75 08             	mov    0x8(%ebp),%esi
  801852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801855:	eb 18                	jmp    80186f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801857:	83 ec 08             	sub    $0x8,%esp
  80185a:	53                   	push   %ebx
  80185b:	6a 20                	push   $0x20
  80185d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80185f:	83 ef 01             	sub    $0x1,%edi
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	eb 08                	jmp    80186f <vprintfmt+0x278>
  801867:	89 df                	mov    %ebx,%edi
  801869:	8b 75 08             	mov    0x8(%ebp),%esi
  80186c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80186f:	85 ff                	test   %edi,%edi
  801871:	7f e4                	jg     801857 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801873:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801876:	e9 a2 fd ff ff       	jmp    80161d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80187b:	83 fa 01             	cmp    $0x1,%edx
  80187e:	7e 16                	jle    801896 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801880:	8b 45 14             	mov    0x14(%ebp),%eax
  801883:	8d 50 08             	lea    0x8(%eax),%edx
  801886:	89 55 14             	mov    %edx,0x14(%ebp)
  801889:	8b 50 04             	mov    0x4(%eax),%edx
  80188c:	8b 00                	mov    (%eax),%eax
  80188e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801891:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801894:	eb 32                	jmp    8018c8 <vprintfmt+0x2d1>
	else if (lflag)
  801896:	85 d2                	test   %edx,%edx
  801898:	74 18                	je     8018b2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80189a:	8b 45 14             	mov    0x14(%ebp),%eax
  80189d:	8d 50 04             	lea    0x4(%eax),%edx
  8018a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a3:	8b 00                	mov    (%eax),%eax
  8018a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018a8:	89 c1                	mov    %eax,%ecx
  8018aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8018ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018b0:	eb 16                	jmp    8018c8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8018b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b5:	8d 50 04             	lea    0x4(%eax),%edx
  8018b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8018bb:	8b 00                	mov    (%eax),%eax
  8018bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018c0:	89 c1                	mov    %eax,%ecx
  8018c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8018c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018ce:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018d3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018d7:	79 74                	jns    80194d <vprintfmt+0x356>
				putch('-', putdat);
  8018d9:	83 ec 08             	sub    $0x8,%esp
  8018dc:	53                   	push   %ebx
  8018dd:	6a 2d                	push   $0x2d
  8018df:	ff d6                	call   *%esi
				num = -(long long) num;
  8018e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018e7:	f7 d8                	neg    %eax
  8018e9:	83 d2 00             	adc    $0x0,%edx
  8018ec:	f7 da                	neg    %edx
  8018ee:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018f6:	eb 55                	jmp    80194d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8018fb:	e8 83 fc ff ff       	call   801583 <getuint>
			base = 10;
  801900:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801905:	eb 46                	jmp    80194d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801907:	8d 45 14             	lea    0x14(%ebp),%eax
  80190a:	e8 74 fc ff ff       	call   801583 <getuint>
			base = 8;
  80190f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801914:	eb 37                	jmp    80194d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	53                   	push   %ebx
  80191a:	6a 30                	push   $0x30
  80191c:	ff d6                	call   *%esi
			putch('x', putdat);
  80191e:	83 c4 08             	add    $0x8,%esp
  801921:	53                   	push   %ebx
  801922:	6a 78                	push   $0x78
  801924:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801926:	8b 45 14             	mov    0x14(%ebp),%eax
  801929:	8d 50 04             	lea    0x4(%eax),%edx
  80192c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80192f:	8b 00                	mov    (%eax),%eax
  801931:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801936:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801939:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80193e:	eb 0d                	jmp    80194d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801940:	8d 45 14             	lea    0x14(%ebp),%eax
  801943:	e8 3b fc ff ff       	call   801583 <getuint>
			base = 16;
  801948:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801954:	57                   	push   %edi
  801955:	ff 75 e0             	pushl  -0x20(%ebp)
  801958:	51                   	push   %ecx
  801959:	52                   	push   %edx
  80195a:	50                   	push   %eax
  80195b:	89 da                	mov    %ebx,%edx
  80195d:	89 f0                	mov    %esi,%eax
  80195f:	e8 70 fb ff ff       	call   8014d4 <printnum>
			break;
  801964:	83 c4 20             	add    $0x20,%esp
  801967:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80196a:	e9 ae fc ff ff       	jmp    80161d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	53                   	push   %ebx
  801973:	51                   	push   %ecx
  801974:	ff d6                	call   *%esi
			break;
  801976:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801979:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80197c:	e9 9c fc ff ff       	jmp    80161d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801981:	83 ec 08             	sub    $0x8,%esp
  801984:	53                   	push   %ebx
  801985:	6a 25                	push   $0x25
  801987:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	eb 03                	jmp    801991 <vprintfmt+0x39a>
  80198e:	83 ef 01             	sub    $0x1,%edi
  801991:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801995:	75 f7                	jne    80198e <vprintfmt+0x397>
  801997:	e9 81 fc ff ff       	jmp    80161d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80199c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5f                   	pop    %edi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	83 ec 18             	sub    $0x18,%esp
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019b7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	74 26                	je     8019eb <vsnprintf+0x47>
  8019c5:	85 d2                	test   %edx,%edx
  8019c7:	7e 22                	jle    8019eb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019c9:	ff 75 14             	pushl  0x14(%ebp)
  8019cc:	ff 75 10             	pushl  0x10(%ebp)
  8019cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019d2:	50                   	push   %eax
  8019d3:	68 bd 15 80 00       	push   $0x8015bd
  8019d8:	e8 1a fc ff ff       	call   8015f7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e6:	83 c4 10             	add    $0x10,%esp
  8019e9:	eb 05                	jmp    8019f0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019f8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019fb:	50                   	push   %eax
  8019fc:	ff 75 10             	pushl  0x10(%ebp)
  8019ff:	ff 75 0c             	pushl  0xc(%ebp)
  801a02:	ff 75 08             	pushl  0x8(%ebp)
  801a05:	e8 9a ff ff ff       	call   8019a4 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a12:	b8 00 00 00 00       	mov    $0x0,%eax
  801a17:	eb 03                	jmp    801a1c <strlen+0x10>
		n++;
  801a19:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a1c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a20:	75 f7                	jne    801a19 <strlen+0xd>
		n++;
	return n;
}
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a32:	eb 03                	jmp    801a37 <strnlen+0x13>
		n++;
  801a34:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a37:	39 c2                	cmp    %eax,%edx
  801a39:	74 08                	je     801a43 <strnlen+0x1f>
  801a3b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a3f:	75 f3                	jne    801a34 <strnlen+0x10>
  801a41:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	53                   	push   %ebx
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a4f:	89 c2                	mov    %eax,%edx
  801a51:	83 c2 01             	add    $0x1,%edx
  801a54:	83 c1 01             	add    $0x1,%ecx
  801a57:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a5b:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a5e:	84 db                	test   %bl,%bl
  801a60:	75 ef                	jne    801a51 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a62:	5b                   	pop    %ebx
  801a63:	5d                   	pop    %ebp
  801a64:	c3                   	ret    

00801a65 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	53                   	push   %ebx
  801a69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a6c:	53                   	push   %ebx
  801a6d:	e8 9a ff ff ff       	call   801a0c <strlen>
  801a72:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a75:	ff 75 0c             	pushl  0xc(%ebp)
  801a78:	01 d8                	add    %ebx,%eax
  801a7a:	50                   	push   %eax
  801a7b:	e8 c5 ff ff ff       	call   801a45 <strcpy>
	return dst;
}
  801a80:	89 d8                	mov    %ebx,%eax
  801a82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a92:	89 f3                	mov    %esi,%ebx
  801a94:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a97:	89 f2                	mov    %esi,%edx
  801a99:	eb 0f                	jmp    801aaa <strncpy+0x23>
		*dst++ = *src;
  801a9b:	83 c2 01             	add    $0x1,%edx
  801a9e:	0f b6 01             	movzbl (%ecx),%eax
  801aa1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801aa4:	80 39 01             	cmpb   $0x1,(%ecx)
  801aa7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801aaa:	39 da                	cmp    %ebx,%edx
  801aac:	75 ed                	jne    801a9b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801aae:	89 f0                	mov    %esi,%eax
  801ab0:	5b                   	pop    %ebx
  801ab1:	5e                   	pop    %esi
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	56                   	push   %esi
  801ab8:	53                   	push   %ebx
  801ab9:	8b 75 08             	mov    0x8(%ebp),%esi
  801abc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801abf:	8b 55 10             	mov    0x10(%ebp),%edx
  801ac2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ac4:	85 d2                	test   %edx,%edx
  801ac6:	74 21                	je     801ae9 <strlcpy+0x35>
  801ac8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801acc:	89 f2                	mov    %esi,%edx
  801ace:	eb 09                	jmp    801ad9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801ad0:	83 c2 01             	add    $0x1,%edx
  801ad3:	83 c1 01             	add    $0x1,%ecx
  801ad6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ad9:	39 c2                	cmp    %eax,%edx
  801adb:	74 09                	je     801ae6 <strlcpy+0x32>
  801add:	0f b6 19             	movzbl (%ecx),%ebx
  801ae0:	84 db                	test   %bl,%bl
  801ae2:	75 ec                	jne    801ad0 <strlcpy+0x1c>
  801ae4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ae6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801ae9:	29 f0                	sub    %esi,%eax
}
  801aeb:	5b                   	pop    %ebx
  801aec:	5e                   	pop    %esi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801af8:	eb 06                	jmp    801b00 <strcmp+0x11>
		p++, q++;
  801afa:	83 c1 01             	add    $0x1,%ecx
  801afd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b00:	0f b6 01             	movzbl (%ecx),%eax
  801b03:	84 c0                	test   %al,%al
  801b05:	74 04                	je     801b0b <strcmp+0x1c>
  801b07:	3a 02                	cmp    (%edx),%al
  801b09:	74 ef                	je     801afa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b0b:	0f b6 c0             	movzbl %al,%eax
  801b0e:	0f b6 12             	movzbl (%edx),%edx
  801b11:	29 d0                	sub    %edx,%eax
}
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	53                   	push   %ebx
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1f:	89 c3                	mov    %eax,%ebx
  801b21:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b24:	eb 06                	jmp    801b2c <strncmp+0x17>
		n--, p++, q++;
  801b26:	83 c0 01             	add    $0x1,%eax
  801b29:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b2c:	39 d8                	cmp    %ebx,%eax
  801b2e:	74 15                	je     801b45 <strncmp+0x30>
  801b30:	0f b6 08             	movzbl (%eax),%ecx
  801b33:	84 c9                	test   %cl,%cl
  801b35:	74 04                	je     801b3b <strncmp+0x26>
  801b37:	3a 0a                	cmp    (%edx),%cl
  801b39:	74 eb                	je     801b26 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b3b:	0f b6 00             	movzbl (%eax),%eax
  801b3e:	0f b6 12             	movzbl (%edx),%edx
  801b41:	29 d0                	sub    %edx,%eax
  801b43:	eb 05                	jmp    801b4a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b45:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b4a:	5b                   	pop    %ebx
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b57:	eb 07                	jmp    801b60 <strchr+0x13>
		if (*s == c)
  801b59:	38 ca                	cmp    %cl,%dl
  801b5b:	74 0f                	je     801b6c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b5d:	83 c0 01             	add    $0x1,%eax
  801b60:	0f b6 10             	movzbl (%eax),%edx
  801b63:	84 d2                	test   %dl,%dl
  801b65:	75 f2                	jne    801b59 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	8b 45 08             	mov    0x8(%ebp),%eax
  801b74:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b78:	eb 03                	jmp    801b7d <strfind+0xf>
  801b7a:	83 c0 01             	add    $0x1,%eax
  801b7d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b80:	38 ca                	cmp    %cl,%dl
  801b82:	74 04                	je     801b88 <strfind+0x1a>
  801b84:	84 d2                	test   %dl,%dl
  801b86:	75 f2                	jne    801b7a <strfind+0xc>
			break;
	return (char *) s;
}
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    

00801b8a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	57                   	push   %edi
  801b8e:	56                   	push   %esi
  801b8f:	53                   	push   %ebx
  801b90:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b96:	85 c9                	test   %ecx,%ecx
  801b98:	74 36                	je     801bd0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b9a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ba0:	75 28                	jne    801bca <memset+0x40>
  801ba2:	f6 c1 03             	test   $0x3,%cl
  801ba5:	75 23                	jne    801bca <memset+0x40>
		c &= 0xFF;
  801ba7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801bab:	89 d3                	mov    %edx,%ebx
  801bad:	c1 e3 08             	shl    $0x8,%ebx
  801bb0:	89 d6                	mov    %edx,%esi
  801bb2:	c1 e6 18             	shl    $0x18,%esi
  801bb5:	89 d0                	mov    %edx,%eax
  801bb7:	c1 e0 10             	shl    $0x10,%eax
  801bba:	09 f0                	or     %esi,%eax
  801bbc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801bbe:	89 d8                	mov    %ebx,%eax
  801bc0:	09 d0                	or     %edx,%eax
  801bc2:	c1 e9 02             	shr    $0x2,%ecx
  801bc5:	fc                   	cld    
  801bc6:	f3 ab                	rep stos %eax,%es:(%edi)
  801bc8:	eb 06                	jmp    801bd0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcd:	fc                   	cld    
  801bce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bd0:	89 f8                	mov    %edi,%eax
  801bd2:	5b                   	pop    %ebx
  801bd3:	5e                   	pop    %esi
  801bd4:	5f                   	pop    %edi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    

00801bd7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	57                   	push   %edi
  801bdb:	56                   	push   %esi
  801bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801be5:	39 c6                	cmp    %eax,%esi
  801be7:	73 35                	jae    801c1e <memmove+0x47>
  801be9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bec:	39 d0                	cmp    %edx,%eax
  801bee:	73 2e                	jae    801c1e <memmove+0x47>
		s += n;
		d += n;
  801bf0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bf3:	89 d6                	mov    %edx,%esi
  801bf5:	09 fe                	or     %edi,%esi
  801bf7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bfd:	75 13                	jne    801c12 <memmove+0x3b>
  801bff:	f6 c1 03             	test   $0x3,%cl
  801c02:	75 0e                	jne    801c12 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801c04:	83 ef 04             	sub    $0x4,%edi
  801c07:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c0a:	c1 e9 02             	shr    $0x2,%ecx
  801c0d:	fd                   	std    
  801c0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c10:	eb 09                	jmp    801c1b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c12:	83 ef 01             	sub    $0x1,%edi
  801c15:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c18:	fd                   	std    
  801c19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c1b:	fc                   	cld    
  801c1c:	eb 1d                	jmp    801c3b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c1e:	89 f2                	mov    %esi,%edx
  801c20:	09 c2                	or     %eax,%edx
  801c22:	f6 c2 03             	test   $0x3,%dl
  801c25:	75 0f                	jne    801c36 <memmove+0x5f>
  801c27:	f6 c1 03             	test   $0x3,%cl
  801c2a:	75 0a                	jne    801c36 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c2c:	c1 e9 02             	shr    $0x2,%ecx
  801c2f:	89 c7                	mov    %eax,%edi
  801c31:	fc                   	cld    
  801c32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c34:	eb 05                	jmp    801c3b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c36:	89 c7                	mov    %eax,%edi
  801c38:	fc                   	cld    
  801c39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c3b:	5e                   	pop    %esi
  801c3c:	5f                   	pop    %edi
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c42:	ff 75 10             	pushl  0x10(%ebp)
  801c45:	ff 75 0c             	pushl  0xc(%ebp)
  801c48:	ff 75 08             	pushl  0x8(%ebp)
  801c4b:	e8 87 ff ff ff       	call   801bd7 <memmove>
}
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	56                   	push   %esi
  801c56:	53                   	push   %ebx
  801c57:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5d:	89 c6                	mov    %eax,%esi
  801c5f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c62:	eb 1a                	jmp    801c7e <memcmp+0x2c>
		if (*s1 != *s2)
  801c64:	0f b6 08             	movzbl (%eax),%ecx
  801c67:	0f b6 1a             	movzbl (%edx),%ebx
  801c6a:	38 d9                	cmp    %bl,%cl
  801c6c:	74 0a                	je     801c78 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c6e:	0f b6 c1             	movzbl %cl,%eax
  801c71:	0f b6 db             	movzbl %bl,%ebx
  801c74:	29 d8                	sub    %ebx,%eax
  801c76:	eb 0f                	jmp    801c87 <memcmp+0x35>
		s1++, s2++;
  801c78:	83 c0 01             	add    $0x1,%eax
  801c7b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c7e:	39 f0                	cmp    %esi,%eax
  801c80:	75 e2                	jne    801c64 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c87:	5b                   	pop    %ebx
  801c88:	5e                   	pop    %esi
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	53                   	push   %ebx
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c92:	89 c1                	mov    %eax,%ecx
  801c94:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c97:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c9b:	eb 0a                	jmp    801ca7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c9d:	0f b6 10             	movzbl (%eax),%edx
  801ca0:	39 da                	cmp    %ebx,%edx
  801ca2:	74 07                	je     801cab <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ca4:	83 c0 01             	add    $0x1,%eax
  801ca7:	39 c8                	cmp    %ecx,%eax
  801ca9:	72 f2                	jb     801c9d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801cab:	5b                   	pop    %ebx
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cba:	eb 03                	jmp    801cbf <strtol+0x11>
		s++;
  801cbc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cbf:	0f b6 01             	movzbl (%ecx),%eax
  801cc2:	3c 20                	cmp    $0x20,%al
  801cc4:	74 f6                	je     801cbc <strtol+0xe>
  801cc6:	3c 09                	cmp    $0x9,%al
  801cc8:	74 f2                	je     801cbc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801cca:	3c 2b                	cmp    $0x2b,%al
  801ccc:	75 0a                	jne    801cd8 <strtol+0x2a>
		s++;
  801cce:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801cd1:	bf 00 00 00 00       	mov    $0x0,%edi
  801cd6:	eb 11                	jmp    801ce9 <strtol+0x3b>
  801cd8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801cdd:	3c 2d                	cmp    $0x2d,%al
  801cdf:	75 08                	jne    801ce9 <strtol+0x3b>
		s++, neg = 1;
  801ce1:	83 c1 01             	add    $0x1,%ecx
  801ce4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ce9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cef:	75 15                	jne    801d06 <strtol+0x58>
  801cf1:	80 39 30             	cmpb   $0x30,(%ecx)
  801cf4:	75 10                	jne    801d06 <strtol+0x58>
  801cf6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cfa:	75 7c                	jne    801d78 <strtol+0xca>
		s += 2, base = 16;
  801cfc:	83 c1 02             	add    $0x2,%ecx
  801cff:	bb 10 00 00 00       	mov    $0x10,%ebx
  801d04:	eb 16                	jmp    801d1c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801d06:	85 db                	test   %ebx,%ebx
  801d08:	75 12                	jne    801d1c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d0a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d0f:	80 39 30             	cmpb   $0x30,(%ecx)
  801d12:	75 08                	jne    801d1c <strtol+0x6e>
		s++, base = 8;
  801d14:	83 c1 01             	add    $0x1,%ecx
  801d17:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d21:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d24:	0f b6 11             	movzbl (%ecx),%edx
  801d27:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d2a:	89 f3                	mov    %esi,%ebx
  801d2c:	80 fb 09             	cmp    $0x9,%bl
  801d2f:	77 08                	ja     801d39 <strtol+0x8b>
			dig = *s - '0';
  801d31:	0f be d2             	movsbl %dl,%edx
  801d34:	83 ea 30             	sub    $0x30,%edx
  801d37:	eb 22                	jmp    801d5b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d39:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d3c:	89 f3                	mov    %esi,%ebx
  801d3e:	80 fb 19             	cmp    $0x19,%bl
  801d41:	77 08                	ja     801d4b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d43:	0f be d2             	movsbl %dl,%edx
  801d46:	83 ea 57             	sub    $0x57,%edx
  801d49:	eb 10                	jmp    801d5b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d4b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d4e:	89 f3                	mov    %esi,%ebx
  801d50:	80 fb 19             	cmp    $0x19,%bl
  801d53:	77 16                	ja     801d6b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d55:	0f be d2             	movsbl %dl,%edx
  801d58:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d5e:	7d 0b                	jge    801d6b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d60:	83 c1 01             	add    $0x1,%ecx
  801d63:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d67:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d69:	eb b9                	jmp    801d24 <strtol+0x76>

	if (endptr)
  801d6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d6f:	74 0d                	je     801d7e <strtol+0xd0>
		*endptr = (char *) s;
  801d71:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d74:	89 0e                	mov    %ecx,(%esi)
  801d76:	eb 06                	jmp    801d7e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d78:	85 db                	test   %ebx,%ebx
  801d7a:	74 98                	je     801d14 <strtol+0x66>
  801d7c:	eb 9e                	jmp    801d1c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d7e:	89 c2                	mov    %eax,%edx
  801d80:	f7 da                	neg    %edx
  801d82:	85 ff                	test   %edi,%edi
  801d84:	0f 45 c2             	cmovne %edx,%eax
}
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d92:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d99:	75 2a                	jne    801dc5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d9b:	83 ec 04             	sub    $0x4,%esp
  801d9e:	6a 07                	push   $0x7
  801da0:	68 00 f0 bf ee       	push   $0xeebff000
  801da5:	6a 00                	push   $0x0
  801da7:	e8 d1 e3 ff ff       	call   80017d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	85 c0                	test   %eax,%eax
  801db1:	79 12                	jns    801dc5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801db3:	50                   	push   %eax
  801db4:	68 e0 26 80 00       	push   $0x8026e0
  801db9:	6a 23                	push   $0x23
  801dbb:	68 e4 26 80 00       	push   $0x8026e4
  801dc0:	e8 22 f6 ff ff       	call   8013e7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dcd:	83 ec 08             	sub    $0x8,%esp
  801dd0:	68 f7 1d 80 00       	push   $0x801df7
  801dd5:	6a 00                	push   $0x0
  801dd7:	e8 ec e4 ff ff       	call   8002c8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	79 12                	jns    801df5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801de3:	50                   	push   %eax
  801de4:	68 e0 26 80 00       	push   $0x8026e0
  801de9:	6a 2c                	push   $0x2c
  801deb:	68 e4 26 80 00       	push   $0x8026e4
  801df0:	e8 f2 f5 ff ff       	call   8013e7 <_panic>
	}
}
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801df7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801df8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dfd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dff:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e02:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e06:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e0b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e0f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e11:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e14:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e15:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e18:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e19:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e1a:	c3                   	ret    

00801e1b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	56                   	push   %esi
  801e1f:	53                   	push   %ebx
  801e20:	8b 75 08             	mov    0x8(%ebp),%esi
  801e23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	75 12                	jne    801e3f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e2d:	83 ec 0c             	sub    $0xc,%esp
  801e30:	68 00 00 c0 ee       	push   $0xeec00000
  801e35:	e8 f3 e4 ff ff       	call   80032d <sys_ipc_recv>
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	eb 0c                	jmp    801e4b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e3f:	83 ec 0c             	sub    $0xc,%esp
  801e42:	50                   	push   %eax
  801e43:	e8 e5 e4 ff ff       	call   80032d <sys_ipc_recv>
  801e48:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e4b:	85 f6                	test   %esi,%esi
  801e4d:	0f 95 c1             	setne  %cl
  801e50:	85 db                	test   %ebx,%ebx
  801e52:	0f 95 c2             	setne  %dl
  801e55:	84 d1                	test   %dl,%cl
  801e57:	74 09                	je     801e62 <ipc_recv+0x47>
  801e59:	89 c2                	mov    %eax,%edx
  801e5b:	c1 ea 1f             	shr    $0x1f,%edx
  801e5e:	84 d2                	test   %dl,%dl
  801e60:	75 2d                	jne    801e8f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e62:	85 f6                	test   %esi,%esi
  801e64:	74 0d                	je     801e73 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e66:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6b:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801e71:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e73:	85 db                	test   %ebx,%ebx
  801e75:	74 0d                	je     801e84 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e77:	a1 04 40 80 00       	mov    0x804004,%eax
  801e7c:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801e82:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e84:	a1 04 40 80 00       	mov    0x804004,%eax
  801e89:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801e8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e92:	5b                   	pop    %ebx
  801e93:	5e                   	pop    %esi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    

00801e96 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	57                   	push   %edi
  801e9a:	56                   	push   %esi
  801e9b:	53                   	push   %ebx
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ea2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ea5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ea8:	85 db                	test   %ebx,%ebx
  801eaa:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eaf:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801eb2:	ff 75 14             	pushl  0x14(%ebp)
  801eb5:	53                   	push   %ebx
  801eb6:	56                   	push   %esi
  801eb7:	57                   	push   %edi
  801eb8:	e8 4d e4 ff ff       	call   80030a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ebd:	89 c2                	mov    %eax,%edx
  801ebf:	c1 ea 1f             	shr    $0x1f,%edx
  801ec2:	83 c4 10             	add    $0x10,%esp
  801ec5:	84 d2                	test   %dl,%dl
  801ec7:	74 17                	je     801ee0 <ipc_send+0x4a>
  801ec9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ecc:	74 12                	je     801ee0 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ece:	50                   	push   %eax
  801ecf:	68 f2 26 80 00       	push   $0x8026f2
  801ed4:	6a 47                	push   $0x47
  801ed6:	68 00 27 80 00       	push   $0x802700
  801edb:	e8 07 f5 ff ff       	call   8013e7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ee0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee3:	75 07                	jne    801eec <ipc_send+0x56>
			sys_yield();
  801ee5:	e8 74 e2 ff ff       	call   80015e <sys_yield>
  801eea:	eb c6                	jmp    801eb2 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801eec:	85 c0                	test   %eax,%eax
  801eee:	75 c2                	jne    801eb2 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ef0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef3:	5b                   	pop    %ebx
  801ef4:	5e                   	pop    %esi
  801ef5:	5f                   	pop    %edi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    

00801ef8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f03:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f09:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f0f:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f15:	39 ca                	cmp    %ecx,%edx
  801f17:	75 13                	jne    801f2c <ipc_find_env+0x34>
			return envs[i].env_id;
  801f19:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f1f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f24:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f2a:	eb 0f                	jmp    801f3b <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f2c:	83 c0 01             	add    $0x1,%eax
  801f2f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f34:	75 cd                	jne    801f03 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    

00801f3d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f43:	89 d0                	mov    %edx,%eax
  801f45:	c1 e8 16             	shr    $0x16,%eax
  801f48:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f4f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f54:	f6 c1 01             	test   $0x1,%cl
  801f57:	74 1d                	je     801f76 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f59:	c1 ea 0c             	shr    $0xc,%edx
  801f5c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f63:	f6 c2 01             	test   $0x1,%dl
  801f66:	74 0e                	je     801f76 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f68:	c1 ea 0c             	shr    $0xc,%edx
  801f6b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f72:	ef 
  801f73:	0f b7 c0             	movzwl %ax,%eax
}
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
  801f78:	66 90                	xchg   %ax,%ax
  801f7a:	66 90                	xchg   %ax,%ax
  801f7c:	66 90                	xchg   %ax,%ax
  801f7e:	66 90                	xchg   %ax,%ax

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 f6                	test   %esi,%esi
  801f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9d:	89 ca                	mov    %ecx,%edx
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	75 3d                	jne    801fe0 <__udivdi3+0x60>
  801fa3:	39 cf                	cmp    %ecx,%edi
  801fa5:	0f 87 c5 00 00 00    	ja     802070 <__udivdi3+0xf0>
  801fab:	85 ff                	test   %edi,%edi
  801fad:	89 fd                	mov    %edi,%ebp
  801faf:	75 0b                	jne    801fbc <__udivdi3+0x3c>
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	31 d2                	xor    %edx,%edx
  801fb8:	f7 f7                	div    %edi
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	89 c8                	mov    %ecx,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f5                	div    %ebp
  801fc2:	89 c1                	mov    %eax,%ecx
  801fc4:	89 d8                	mov    %ebx,%eax
  801fc6:	89 cf                	mov    %ecx,%edi
  801fc8:	f7 f5                	div    %ebp
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	89 fa                	mov    %edi,%edx
  801fd0:	83 c4 1c             	add    $0x1c,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
  801fd8:	90                   	nop
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	39 ce                	cmp    %ecx,%esi
  801fe2:	77 74                	ja     802058 <__udivdi3+0xd8>
  801fe4:	0f bd fe             	bsr    %esi,%edi
  801fe7:	83 f7 1f             	xor    $0x1f,%edi
  801fea:	0f 84 98 00 00 00    	je     802088 <__udivdi3+0x108>
  801ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	89 c5                	mov    %eax,%ebp
  801ff9:	29 fb                	sub    %edi,%ebx
  801ffb:	d3 e6                	shl    %cl,%esi
  801ffd:	89 d9                	mov    %ebx,%ecx
  801fff:	d3 ed                	shr    %cl,%ebp
  802001:	89 f9                	mov    %edi,%ecx
  802003:	d3 e0                	shl    %cl,%eax
  802005:	09 ee                	or     %ebp,%esi
  802007:	89 d9                	mov    %ebx,%ecx
  802009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200d:	89 d5                	mov    %edx,%ebp
  80200f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802013:	d3 ed                	shr    %cl,%ebp
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 d9                	mov    %ebx,%ecx
  80201b:	d3 e8                	shr    %cl,%eax
  80201d:	09 c2                	or     %eax,%edx
  80201f:	89 d0                	mov    %edx,%eax
  802021:	89 ea                	mov    %ebp,%edx
  802023:	f7 f6                	div    %esi
  802025:	89 d5                	mov    %edx,%ebp
  802027:	89 c3                	mov    %eax,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	72 10                	jb     802041 <__udivdi3+0xc1>
  802031:	8b 74 24 08          	mov    0x8(%esp),%esi
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e6                	shl    %cl,%esi
  802039:	39 c6                	cmp    %eax,%esi
  80203b:	73 07                	jae    802044 <__udivdi3+0xc4>
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	75 03                	jne    802044 <__udivdi3+0xc4>
  802041:	83 eb 01             	sub    $0x1,%ebx
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 d8                	mov    %ebx,%eax
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	31 ff                	xor    %edi,%edi
  80205a:	31 db                	xor    %ebx,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d8                	mov    %ebx,%eax
  802072:	f7 f7                	div    %edi
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 c3                	mov    %eax,%ebx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 fa                	mov    %edi,%edx
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	39 ce                	cmp    %ecx,%esi
  80208a:	72 0c                	jb     802098 <__udivdi3+0x118>
  80208c:	31 db                	xor    %ebx,%ebx
  80208e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802092:	0f 87 34 ff ff ff    	ja     801fcc <__udivdi3+0x4c>
  802098:	bb 01 00 00 00       	mov    $0x1,%ebx
  80209d:	e9 2a ff ff ff       	jmp    801fcc <__udivdi3+0x4c>
  8020a2:	66 90                	xchg   %ax,%ax
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 d2                	test   %edx,%edx
  8020c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f3                	mov    %esi,%ebx
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	75 1c                	jne    8020f8 <__umoddi3+0x48>
  8020dc:	39 f7                	cmp    %esi,%edi
  8020de:	76 50                	jbe    802130 <__umoddi3+0x80>
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	f7 f7                	div    %edi
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	31 d2                	xor    %edx,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	89 d0                	mov    %edx,%eax
  8020fc:	77 52                	ja     802150 <__umoddi3+0xa0>
  8020fe:	0f bd ea             	bsr    %edx,%ebp
  802101:	83 f5 1f             	xor    $0x1f,%ebp
  802104:	75 5a                	jne    802160 <__umoddi3+0xb0>
  802106:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80210a:	0f 82 e0 00 00 00    	jb     8021f0 <__umoddi3+0x140>
  802110:	39 0c 24             	cmp    %ecx,(%esp)
  802113:	0f 86 d7 00 00 00    	jbe    8021f0 <__umoddi3+0x140>
  802119:	8b 44 24 08          	mov    0x8(%esp),%eax
  80211d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	85 ff                	test   %edi,%edi
  802132:	89 fd                	mov    %edi,%ebp
  802134:	75 0b                	jne    802141 <__umoddi3+0x91>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f7                	div    %edi
  80213f:	89 c5                	mov    %eax,%ebp
  802141:	89 f0                	mov    %esi,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	f7 f5                	div    %ebp
  802147:	89 c8                	mov    %ecx,%eax
  802149:	f7 f5                	div    %ebp
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	eb 99                	jmp    8020e8 <__umoddi3+0x38>
  80214f:	90                   	nop
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	83 c4 1c             	add    $0x1c,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	8b 34 24             	mov    (%esp),%esi
  802163:	bf 20 00 00 00       	mov    $0x20,%edi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	29 ef                	sub    %ebp,%edi
  80216c:	d3 e0                	shl    %cl,%eax
  80216e:	89 f9                	mov    %edi,%ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	d3 ea                	shr    %cl,%edx
  802174:	89 e9                	mov    %ebp,%ecx
  802176:	09 c2                	or     %eax,%edx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 14 24             	mov    %edx,(%esp)
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	d3 e2                	shl    %cl,%edx
  802181:	89 f9                	mov    %edi,%ecx
  802183:	89 54 24 04          	mov    %edx,0x4(%esp)
  802187:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	89 c6                	mov    %eax,%esi
  802191:	d3 e3                	shl    %cl,%ebx
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 d0                	mov    %edx,%eax
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	09 d8                	or     %ebx,%eax
  80219d:	89 d3                	mov    %edx,%ebx
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	f7 34 24             	divl   (%esp)
  8021a4:	89 d6                	mov    %edx,%esi
  8021a6:	d3 e3                	shl    %cl,%ebx
  8021a8:	f7 64 24 04          	mull   0x4(%esp)
  8021ac:	39 d6                	cmp    %edx,%esi
  8021ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b2:	89 d1                	mov    %edx,%ecx
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	72 08                	jb     8021c0 <__umoddi3+0x110>
  8021b8:	75 11                	jne    8021cb <__umoddi3+0x11b>
  8021ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021be:	73 0b                	jae    8021cb <__umoddi3+0x11b>
  8021c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021c4:	1b 14 24             	sbb    (%esp),%edx
  8021c7:	89 d1                	mov    %edx,%ecx
  8021c9:	89 c3                	mov    %eax,%ebx
  8021cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021cf:	29 da                	sub    %ebx,%edx
  8021d1:	19 ce                	sbb    %ecx,%esi
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e0                	shl    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	d3 ea                	shr    %cl,%edx
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	09 d0                	or     %edx,%eax
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	83 c4 1c             	add    $0x1c,%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	29 f9                	sub    %edi,%ecx
  8021f2:	19 d6                	sbb    %edx,%esi
  8021f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021fc:	e9 18 ff ff ff       	jmp    802119 <__umoddi3+0x69>
