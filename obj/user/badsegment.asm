
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
  800053:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8000ad:	e8 bb 07 00 00       	call   80086d <close_all>
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
  800126:	68 ca 21 80 00       	push   $0x8021ca
  80012b:	6a 23                	push   $0x23
  80012d:	68 e7 21 80 00       	push   $0x8021e7
  800132:	e8 5e 12 00 00       	call   801395 <_panic>

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
  8001a7:	68 ca 21 80 00       	push   $0x8021ca
  8001ac:	6a 23                	push   $0x23
  8001ae:	68 e7 21 80 00       	push   $0x8021e7
  8001b3:	e8 dd 11 00 00       	call   801395 <_panic>

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
  8001e9:	68 ca 21 80 00       	push   $0x8021ca
  8001ee:	6a 23                	push   $0x23
  8001f0:	68 e7 21 80 00       	push   $0x8021e7
  8001f5:	e8 9b 11 00 00       	call   801395 <_panic>

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
  80022b:	68 ca 21 80 00       	push   $0x8021ca
  800230:	6a 23                	push   $0x23
  800232:	68 e7 21 80 00       	push   $0x8021e7
  800237:	e8 59 11 00 00       	call   801395 <_panic>

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
  80026d:	68 ca 21 80 00       	push   $0x8021ca
  800272:	6a 23                	push   $0x23
  800274:	68 e7 21 80 00       	push   $0x8021e7
  800279:	e8 17 11 00 00       	call   801395 <_panic>

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
  8002af:	68 ca 21 80 00       	push   $0x8021ca
  8002b4:	6a 23                	push   $0x23
  8002b6:	68 e7 21 80 00       	push   $0x8021e7
  8002bb:	e8 d5 10 00 00       	call   801395 <_panic>
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
  8002f1:	68 ca 21 80 00       	push   $0x8021ca
  8002f6:	6a 23                	push   $0x23
  8002f8:	68 e7 21 80 00       	push   $0x8021e7
  8002fd:	e8 93 10 00 00       	call   801395 <_panic>

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
  800355:	68 ca 21 80 00       	push   $0x8021ca
  80035a:	6a 23                	push   $0x23
  80035c:	68 e7 21 80 00       	push   $0x8021e7
  800361:	e8 2f 10 00 00       	call   801395 <_panic>

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

008003ae <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	53                   	push   %ebx
  8003b2:	83 ec 04             	sub    $0x4,%esp
  8003b5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003b8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003ba:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003be:	74 11                	je     8003d1 <pgfault+0x23>
  8003c0:	89 d8                	mov    %ebx,%eax
  8003c2:	c1 e8 0c             	shr    $0xc,%eax
  8003c5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003cc:	f6 c4 08             	test   $0x8,%ah
  8003cf:	75 14                	jne    8003e5 <pgfault+0x37>
		panic("faulting access");
  8003d1:	83 ec 04             	sub    $0x4,%esp
  8003d4:	68 f5 21 80 00       	push   $0x8021f5
  8003d9:	6a 1e                	push   $0x1e
  8003db:	68 05 22 80 00       	push   $0x802205
  8003e0:	e8 b0 0f 00 00       	call   801395 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003e5:	83 ec 04             	sub    $0x4,%esp
  8003e8:	6a 07                	push   $0x7
  8003ea:	68 00 f0 7f 00       	push   $0x7ff000
  8003ef:	6a 00                	push   $0x0
  8003f1:	e8 87 fd ff ff       	call   80017d <sys_page_alloc>
	if (r < 0) {
  8003f6:	83 c4 10             	add    $0x10,%esp
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	79 12                	jns    80040f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8003fd:	50                   	push   %eax
  8003fe:	68 10 22 80 00       	push   $0x802210
  800403:	6a 2c                	push   $0x2c
  800405:	68 05 22 80 00       	push   $0x802205
  80040a:	e8 86 0f 00 00       	call   801395 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80040f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800415:	83 ec 04             	sub    $0x4,%esp
  800418:	68 00 10 00 00       	push   $0x1000
  80041d:	53                   	push   %ebx
  80041e:	68 00 f0 7f 00       	push   $0x7ff000
  800423:	e8 c5 17 00 00       	call   801bed <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800428:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80042f:	53                   	push   %ebx
  800430:	6a 00                	push   $0x0
  800432:	68 00 f0 7f 00       	push   $0x7ff000
  800437:	6a 00                	push   $0x0
  800439:	e8 82 fd ff ff       	call   8001c0 <sys_page_map>
	if (r < 0) {
  80043e:	83 c4 20             	add    $0x20,%esp
  800441:	85 c0                	test   %eax,%eax
  800443:	79 12                	jns    800457 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800445:	50                   	push   %eax
  800446:	68 10 22 80 00       	push   $0x802210
  80044b:	6a 33                	push   $0x33
  80044d:	68 05 22 80 00       	push   $0x802205
  800452:	e8 3e 0f 00 00       	call   801395 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	68 00 f0 7f 00       	push   $0x7ff000
  80045f:	6a 00                	push   $0x0
  800461:	e8 9c fd ff ff       	call   800202 <sys_page_unmap>
	if (r < 0) {
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	85 c0                	test   %eax,%eax
  80046b:	79 12                	jns    80047f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80046d:	50                   	push   %eax
  80046e:	68 10 22 80 00       	push   $0x802210
  800473:	6a 37                	push   $0x37
  800475:	68 05 22 80 00       	push   $0x802205
  80047a:	e8 16 0f 00 00       	call   801395 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80047f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	57                   	push   %edi
  800488:	56                   	push   %esi
  800489:	53                   	push   %ebx
  80048a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80048d:	68 ae 03 80 00       	push   $0x8003ae
  800492:	e8 a3 18 00 00       	call   801d3a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800497:	b8 07 00 00 00       	mov    $0x7,%eax
  80049c:	cd 30                	int    $0x30
  80049e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	79 17                	jns    8004bf <fork+0x3b>
		panic("fork fault %e");
  8004a8:	83 ec 04             	sub    $0x4,%esp
  8004ab:	68 29 22 80 00       	push   $0x802229
  8004b0:	68 84 00 00 00       	push   $0x84
  8004b5:	68 05 22 80 00       	push   $0x802205
  8004ba:	e8 d6 0e 00 00       	call   801395 <_panic>
  8004bf:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c5:	75 24                	jne    8004eb <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004c7:	e8 73 fc ff ff       	call   80013f <sys_getenvid>
  8004cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8004d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004dc:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	e9 64 01 00 00       	jmp    80064f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004eb:	83 ec 04             	sub    $0x4,%esp
  8004ee:	6a 07                	push   $0x7
  8004f0:	68 00 f0 bf ee       	push   $0xeebff000
  8004f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004f8:	e8 80 fc ff ff       	call   80017d <sys_page_alloc>
  8004fd:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800500:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800505:	89 d8                	mov    %ebx,%eax
  800507:	c1 e8 16             	shr    $0x16,%eax
  80050a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800511:	a8 01                	test   $0x1,%al
  800513:	0f 84 fc 00 00 00    	je     800615 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800519:	89 d8                	mov    %ebx,%eax
  80051b:	c1 e8 0c             	shr    $0xc,%eax
  80051e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800525:	f6 c2 01             	test   $0x1,%dl
  800528:	0f 84 e7 00 00 00    	je     800615 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80052e:	89 c6                	mov    %eax,%esi
  800530:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800533:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80053a:	f6 c6 04             	test   $0x4,%dh
  80053d:	74 39                	je     800578 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80053f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800546:	83 ec 0c             	sub    $0xc,%esp
  800549:	25 07 0e 00 00       	and    $0xe07,%eax
  80054e:	50                   	push   %eax
  80054f:	56                   	push   %esi
  800550:	57                   	push   %edi
  800551:	56                   	push   %esi
  800552:	6a 00                	push   $0x0
  800554:	e8 67 fc ff ff       	call   8001c0 <sys_page_map>
		if (r < 0) {
  800559:	83 c4 20             	add    $0x20,%esp
  80055c:	85 c0                	test   %eax,%eax
  80055e:	0f 89 b1 00 00 00    	jns    800615 <fork+0x191>
		    	panic("sys page map fault %e");
  800564:	83 ec 04             	sub    $0x4,%esp
  800567:	68 37 22 80 00       	push   $0x802237
  80056c:	6a 54                	push   $0x54
  80056e:	68 05 22 80 00       	push   $0x802205
  800573:	e8 1d 0e 00 00       	call   801395 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800578:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80057f:	f6 c2 02             	test   $0x2,%dl
  800582:	75 0c                	jne    800590 <fork+0x10c>
  800584:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80058b:	f6 c4 08             	test   $0x8,%ah
  80058e:	74 5b                	je     8005eb <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800590:	83 ec 0c             	sub    $0xc,%esp
  800593:	68 05 08 00 00       	push   $0x805
  800598:	56                   	push   %esi
  800599:	57                   	push   %edi
  80059a:	56                   	push   %esi
  80059b:	6a 00                	push   $0x0
  80059d:	e8 1e fc ff ff       	call   8001c0 <sys_page_map>
		if (r < 0) {
  8005a2:	83 c4 20             	add    $0x20,%esp
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	79 14                	jns    8005bd <fork+0x139>
		    	panic("sys page map fault %e");
  8005a9:	83 ec 04             	sub    $0x4,%esp
  8005ac:	68 37 22 80 00       	push   $0x802237
  8005b1:	6a 5b                	push   $0x5b
  8005b3:	68 05 22 80 00       	push   $0x802205
  8005b8:	e8 d8 0d 00 00       	call   801395 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005bd:	83 ec 0c             	sub    $0xc,%esp
  8005c0:	68 05 08 00 00       	push   $0x805
  8005c5:	56                   	push   %esi
  8005c6:	6a 00                	push   $0x0
  8005c8:	56                   	push   %esi
  8005c9:	6a 00                	push   $0x0
  8005cb:	e8 f0 fb ff ff       	call   8001c0 <sys_page_map>
		if (r < 0) {
  8005d0:	83 c4 20             	add    $0x20,%esp
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	79 3e                	jns    800615 <fork+0x191>
		    	panic("sys page map fault %e");
  8005d7:	83 ec 04             	sub    $0x4,%esp
  8005da:	68 37 22 80 00       	push   $0x802237
  8005df:	6a 5f                	push   $0x5f
  8005e1:	68 05 22 80 00       	push   $0x802205
  8005e6:	e8 aa 0d 00 00       	call   801395 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005eb:	83 ec 0c             	sub    $0xc,%esp
  8005ee:	6a 05                	push   $0x5
  8005f0:	56                   	push   %esi
  8005f1:	57                   	push   %edi
  8005f2:	56                   	push   %esi
  8005f3:	6a 00                	push   $0x0
  8005f5:	e8 c6 fb ff ff       	call   8001c0 <sys_page_map>
		if (r < 0) {
  8005fa:	83 c4 20             	add    $0x20,%esp
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	79 14                	jns    800615 <fork+0x191>
		    	panic("sys page map fault %e");
  800601:	83 ec 04             	sub    $0x4,%esp
  800604:	68 37 22 80 00       	push   $0x802237
  800609:	6a 64                	push   $0x64
  80060b:	68 05 22 80 00       	push   $0x802205
  800610:	e8 80 0d 00 00       	call   801395 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800615:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80061b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800621:	0f 85 de fe ff ff    	jne    800505 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800627:	a1 04 40 80 00       	mov    0x804004,%eax
  80062c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	50                   	push   %eax
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800639:	57                   	push   %edi
  80063a:	e8 89 fc ff ff       	call   8002c8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	6a 02                	push   $0x2
  800644:	57                   	push   %edi
  800645:	e8 fa fb ff ff       	call   800244 <sys_env_set_status>
	
	return envid;
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80064f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800652:	5b                   	pop    %ebx
  800653:	5e                   	pop    %esi
  800654:	5f                   	pop    %edi
  800655:	5d                   	pop    %ebp
  800656:	c3                   	ret    

00800657 <sfork>:

envid_t
sfork(void)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80065a:	b8 00 00 00 00       	mov    $0x0,%eax
  80065f:	5d                   	pop    %ebp
  800660:	c3                   	ret    

00800661 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	56                   	push   %esi
  800665:	53                   	push   %ebx
  800666:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800669:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	68 50 22 80 00       	push   $0x802250
  800678:	e8 f1 0d 00 00       	call   80146e <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80067d:	c7 04 24 87 00 80 00 	movl   $0x800087,(%esp)
  800684:	e8 e5 fc ff ff       	call   80036e <sys_thread_create>
  800689:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80068b:	83 c4 08             	add    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	68 50 22 80 00       	push   $0x802250
  800694:	e8 d5 0d 00 00       	call   80146e <cprintf>
	return id;
}
  800699:	89 f0                	mov    %esi,%eax
  80069b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80069e:	5b                   	pop    %ebx
  80069f:	5e                   	pop    %esi
  8006a0:	5d                   	pop    %ebp
  8006a1:	c3                   	ret    

008006a2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	05 00 00 00 30       	add    $0x30000000,%eax
  8006ad:	c1 e8 0c             	shr    $0xc,%eax
}
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    

008006b2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	05 00 00 00 30       	add    $0x30000000,%eax
  8006bd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006c2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006c7:	5d                   	pop    %ebp
  8006c8:	c3                   	ret    

008006c9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006cf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006d4:	89 c2                	mov    %eax,%edx
  8006d6:	c1 ea 16             	shr    $0x16,%edx
  8006d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006e0:	f6 c2 01             	test   $0x1,%dl
  8006e3:	74 11                	je     8006f6 <fd_alloc+0x2d>
  8006e5:	89 c2                	mov    %eax,%edx
  8006e7:	c1 ea 0c             	shr    $0xc,%edx
  8006ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006f1:	f6 c2 01             	test   $0x1,%dl
  8006f4:	75 09                	jne    8006ff <fd_alloc+0x36>
			*fd_store = fd;
  8006f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8006f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fd:	eb 17                	jmp    800716 <fd_alloc+0x4d>
  8006ff:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800704:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800709:	75 c9                	jne    8006d4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80070b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800711:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80071e:	83 f8 1f             	cmp    $0x1f,%eax
  800721:	77 36                	ja     800759 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800723:	c1 e0 0c             	shl    $0xc,%eax
  800726:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80072b:	89 c2                	mov    %eax,%edx
  80072d:	c1 ea 16             	shr    $0x16,%edx
  800730:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800737:	f6 c2 01             	test   $0x1,%dl
  80073a:	74 24                	je     800760 <fd_lookup+0x48>
  80073c:	89 c2                	mov    %eax,%edx
  80073e:	c1 ea 0c             	shr    $0xc,%edx
  800741:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800748:	f6 c2 01             	test   $0x1,%dl
  80074b:	74 1a                	je     800767 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80074d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800750:	89 02                	mov    %eax,(%edx)
	return 0;
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 13                	jmp    80076c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075e:	eb 0c                	jmp    80076c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800760:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800765:	eb 05                	jmp    80076c <fd_lookup+0x54>
  800767:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800777:	ba f0 22 80 00       	mov    $0x8022f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80077c:	eb 13                	jmp    800791 <dev_lookup+0x23>
  80077e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800781:	39 08                	cmp    %ecx,(%eax)
  800783:	75 0c                	jne    800791 <dev_lookup+0x23>
			*dev = devtab[i];
  800785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800788:	89 01                	mov    %eax,(%ecx)
			return 0;
  80078a:	b8 00 00 00 00       	mov    $0x0,%eax
  80078f:	eb 2e                	jmp    8007bf <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800791:	8b 02                	mov    (%edx),%eax
  800793:	85 c0                	test   %eax,%eax
  800795:	75 e7                	jne    80077e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800797:	a1 04 40 80 00       	mov    0x804004,%eax
  80079c:	8b 40 7c             	mov    0x7c(%eax),%eax
  80079f:	83 ec 04             	sub    $0x4,%esp
  8007a2:	51                   	push   %ecx
  8007a3:	50                   	push   %eax
  8007a4:	68 74 22 80 00       	push   $0x802274
  8007a9:	e8 c0 0c 00 00       	call   80146e <cprintf>
	*dev = 0;
  8007ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007b7:	83 c4 10             	add    $0x10,%esp
  8007ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	56                   	push   %esi
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 10             	sub    $0x10,%esp
  8007c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d2:	50                   	push   %eax
  8007d3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007d9:	c1 e8 0c             	shr    $0xc,%eax
  8007dc:	50                   	push   %eax
  8007dd:	e8 36 ff ff ff       	call   800718 <fd_lookup>
  8007e2:	83 c4 08             	add    $0x8,%esp
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	78 05                	js     8007ee <fd_close+0x2d>
	    || fd != fd2)
  8007e9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007ec:	74 0c                	je     8007fa <fd_close+0x39>
		return (must_exist ? r : 0);
  8007ee:	84 db                	test   %bl,%bl
  8007f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f5:	0f 44 c2             	cmove  %edx,%eax
  8007f8:	eb 41                	jmp    80083b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	ff 36                	pushl  (%esi)
  800803:	e8 66 ff ff ff       	call   80076e <dev_lookup>
  800808:	89 c3                	mov    %eax,%ebx
  80080a:	83 c4 10             	add    $0x10,%esp
  80080d:	85 c0                	test   %eax,%eax
  80080f:	78 1a                	js     80082b <fd_close+0x6a>
		if (dev->dev_close)
  800811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800814:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800817:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80081c:	85 c0                	test   %eax,%eax
  80081e:	74 0b                	je     80082b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800820:	83 ec 0c             	sub    $0xc,%esp
  800823:	56                   	push   %esi
  800824:	ff d0                	call   *%eax
  800826:	89 c3                	mov    %eax,%ebx
  800828:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	56                   	push   %esi
  80082f:	6a 00                	push   $0x0
  800831:	e8 cc f9 ff ff       	call   800202 <sys_page_unmap>
	return r;
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	89 d8                	mov    %ebx,%eax
}
  80083b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800848:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084b:	50                   	push   %eax
  80084c:	ff 75 08             	pushl  0x8(%ebp)
  80084f:	e8 c4 fe ff ff       	call   800718 <fd_lookup>
  800854:	83 c4 08             	add    $0x8,%esp
  800857:	85 c0                	test   %eax,%eax
  800859:	78 10                	js     80086b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	6a 01                	push   $0x1
  800860:	ff 75 f4             	pushl  -0xc(%ebp)
  800863:	e8 59 ff ff ff       	call   8007c1 <fd_close>
  800868:	83 c4 10             	add    $0x10,%esp
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <close_all>:

void
close_all(void)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	53                   	push   %ebx
  800871:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800874:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800879:	83 ec 0c             	sub    $0xc,%esp
  80087c:	53                   	push   %ebx
  80087d:	e8 c0 ff ff ff       	call   800842 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800882:	83 c3 01             	add    $0x1,%ebx
  800885:	83 c4 10             	add    $0x10,%esp
  800888:	83 fb 20             	cmp    $0x20,%ebx
  80088b:	75 ec                	jne    800879 <close_all+0xc>
		close(i);
}
  80088d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	83 ec 2c             	sub    $0x2c,%esp
  80089b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80089e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008a1:	50                   	push   %eax
  8008a2:	ff 75 08             	pushl  0x8(%ebp)
  8008a5:	e8 6e fe ff ff       	call   800718 <fd_lookup>
  8008aa:	83 c4 08             	add    $0x8,%esp
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	0f 88 c1 00 00 00    	js     800976 <dup+0xe4>
		return r;
	close(newfdnum);
  8008b5:	83 ec 0c             	sub    $0xc,%esp
  8008b8:	56                   	push   %esi
  8008b9:	e8 84 ff ff ff       	call   800842 <close>

	newfd = INDEX2FD(newfdnum);
  8008be:	89 f3                	mov    %esi,%ebx
  8008c0:	c1 e3 0c             	shl    $0xc,%ebx
  8008c3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008c9:	83 c4 04             	add    $0x4,%esp
  8008cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008cf:	e8 de fd ff ff       	call   8006b2 <fd2data>
  8008d4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008d6:	89 1c 24             	mov    %ebx,(%esp)
  8008d9:	e8 d4 fd ff ff       	call   8006b2 <fd2data>
  8008de:	83 c4 10             	add    $0x10,%esp
  8008e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008e4:	89 f8                	mov    %edi,%eax
  8008e6:	c1 e8 16             	shr    $0x16,%eax
  8008e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008f0:	a8 01                	test   $0x1,%al
  8008f2:	74 37                	je     80092b <dup+0x99>
  8008f4:	89 f8                	mov    %edi,%eax
  8008f6:	c1 e8 0c             	shr    $0xc,%eax
  8008f9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800900:	f6 c2 01             	test   $0x1,%dl
  800903:	74 26                	je     80092b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800905:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	25 07 0e 00 00       	and    $0xe07,%eax
  800914:	50                   	push   %eax
  800915:	ff 75 d4             	pushl  -0x2c(%ebp)
  800918:	6a 00                	push   $0x0
  80091a:	57                   	push   %edi
  80091b:	6a 00                	push   $0x0
  80091d:	e8 9e f8 ff ff       	call   8001c0 <sys_page_map>
  800922:	89 c7                	mov    %eax,%edi
  800924:	83 c4 20             	add    $0x20,%esp
  800927:	85 c0                	test   %eax,%eax
  800929:	78 2e                	js     800959 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80092b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80092e:	89 d0                	mov    %edx,%eax
  800930:	c1 e8 0c             	shr    $0xc,%eax
  800933:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80093a:	83 ec 0c             	sub    $0xc,%esp
  80093d:	25 07 0e 00 00       	and    $0xe07,%eax
  800942:	50                   	push   %eax
  800943:	53                   	push   %ebx
  800944:	6a 00                	push   $0x0
  800946:	52                   	push   %edx
  800947:	6a 00                	push   $0x0
  800949:	e8 72 f8 ff ff       	call   8001c0 <sys_page_map>
  80094e:	89 c7                	mov    %eax,%edi
  800950:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800953:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800955:	85 ff                	test   %edi,%edi
  800957:	79 1d                	jns    800976 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800959:	83 ec 08             	sub    $0x8,%esp
  80095c:	53                   	push   %ebx
  80095d:	6a 00                	push   $0x0
  80095f:	e8 9e f8 ff ff       	call   800202 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800964:	83 c4 08             	add    $0x8,%esp
  800967:	ff 75 d4             	pushl  -0x2c(%ebp)
  80096a:	6a 00                	push   $0x0
  80096c:	e8 91 f8 ff ff       	call   800202 <sys_page_unmap>
	return r;
  800971:	83 c4 10             	add    $0x10,%esp
  800974:	89 f8                	mov    %edi,%eax
}
  800976:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	53                   	push   %ebx
  800982:	83 ec 14             	sub    $0x14,%esp
  800985:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800988:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80098b:	50                   	push   %eax
  80098c:	53                   	push   %ebx
  80098d:	e8 86 fd ff ff       	call   800718 <fd_lookup>
  800992:	83 c4 08             	add    $0x8,%esp
  800995:	89 c2                	mov    %eax,%edx
  800997:	85 c0                	test   %eax,%eax
  800999:	78 6d                	js     800a08 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a1:	50                   	push   %eax
  8009a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a5:	ff 30                	pushl  (%eax)
  8009a7:	e8 c2 fd ff ff       	call   80076e <dev_lookup>
  8009ac:	83 c4 10             	add    $0x10,%esp
  8009af:	85 c0                	test   %eax,%eax
  8009b1:	78 4c                	js     8009ff <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009b3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009b6:	8b 42 08             	mov    0x8(%edx),%eax
  8009b9:	83 e0 03             	and    $0x3,%eax
  8009bc:	83 f8 01             	cmp    $0x1,%eax
  8009bf:	75 21                	jne    8009e2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c6:	8b 40 7c             	mov    0x7c(%eax),%eax
  8009c9:	83 ec 04             	sub    $0x4,%esp
  8009cc:	53                   	push   %ebx
  8009cd:	50                   	push   %eax
  8009ce:	68 b5 22 80 00       	push   $0x8022b5
  8009d3:	e8 96 0a 00 00       	call   80146e <cprintf>
		return -E_INVAL;
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009e0:	eb 26                	jmp    800a08 <read+0x8a>
	}
	if (!dev->dev_read)
  8009e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e5:	8b 40 08             	mov    0x8(%eax),%eax
  8009e8:	85 c0                	test   %eax,%eax
  8009ea:	74 17                	je     800a03 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009ec:	83 ec 04             	sub    $0x4,%esp
  8009ef:	ff 75 10             	pushl  0x10(%ebp)
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	52                   	push   %edx
  8009f6:	ff d0                	call   *%eax
  8009f8:	89 c2                	mov    %eax,%edx
  8009fa:	83 c4 10             	add    $0x10,%esp
  8009fd:	eb 09                	jmp    800a08 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009ff:	89 c2                	mov    %eax,%edx
  800a01:	eb 05                	jmp    800a08 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a03:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a08:	89 d0                	mov    %edx,%eax
  800a0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	83 ec 0c             	sub    $0xc,%esp
  800a18:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a23:	eb 21                	jmp    800a46 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a25:	83 ec 04             	sub    $0x4,%esp
  800a28:	89 f0                	mov    %esi,%eax
  800a2a:	29 d8                	sub    %ebx,%eax
  800a2c:	50                   	push   %eax
  800a2d:	89 d8                	mov    %ebx,%eax
  800a2f:	03 45 0c             	add    0xc(%ebp),%eax
  800a32:	50                   	push   %eax
  800a33:	57                   	push   %edi
  800a34:	e8 45 ff ff ff       	call   80097e <read>
		if (m < 0)
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	85 c0                	test   %eax,%eax
  800a3e:	78 10                	js     800a50 <readn+0x41>
			return m;
		if (m == 0)
  800a40:	85 c0                	test   %eax,%eax
  800a42:	74 0a                	je     800a4e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a44:	01 c3                	add    %eax,%ebx
  800a46:	39 f3                	cmp    %esi,%ebx
  800a48:	72 db                	jb     800a25 <readn+0x16>
  800a4a:	89 d8                	mov    %ebx,%eax
  800a4c:	eb 02                	jmp    800a50 <readn+0x41>
  800a4e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5f                   	pop    %edi
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	53                   	push   %ebx
  800a5c:	83 ec 14             	sub    $0x14,%esp
  800a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a65:	50                   	push   %eax
  800a66:	53                   	push   %ebx
  800a67:	e8 ac fc ff ff       	call   800718 <fd_lookup>
  800a6c:	83 c4 08             	add    $0x8,%esp
  800a6f:	89 c2                	mov    %eax,%edx
  800a71:	85 c0                	test   %eax,%eax
  800a73:	78 68                	js     800add <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a75:	83 ec 08             	sub    $0x8,%esp
  800a78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a7b:	50                   	push   %eax
  800a7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a7f:	ff 30                	pushl  (%eax)
  800a81:	e8 e8 fc ff ff       	call   80076e <dev_lookup>
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	85 c0                	test   %eax,%eax
  800a8b:	78 47                	js     800ad4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a90:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a94:	75 21                	jne    800ab7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a96:	a1 04 40 80 00       	mov    0x804004,%eax
  800a9b:	8b 40 7c             	mov    0x7c(%eax),%eax
  800a9e:	83 ec 04             	sub    $0x4,%esp
  800aa1:	53                   	push   %ebx
  800aa2:	50                   	push   %eax
  800aa3:	68 d1 22 80 00       	push   $0x8022d1
  800aa8:	e8 c1 09 00 00       	call   80146e <cprintf>
		return -E_INVAL;
  800aad:	83 c4 10             	add    $0x10,%esp
  800ab0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ab5:	eb 26                	jmp    800add <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ab7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aba:	8b 52 0c             	mov    0xc(%edx),%edx
  800abd:	85 d2                	test   %edx,%edx
  800abf:	74 17                	je     800ad8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ac1:	83 ec 04             	sub    $0x4,%esp
  800ac4:	ff 75 10             	pushl  0x10(%ebp)
  800ac7:	ff 75 0c             	pushl  0xc(%ebp)
  800aca:	50                   	push   %eax
  800acb:	ff d2                	call   *%edx
  800acd:	89 c2                	mov    %eax,%edx
  800acf:	83 c4 10             	add    $0x10,%esp
  800ad2:	eb 09                	jmp    800add <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ad4:	89 c2                	mov    %eax,%edx
  800ad6:	eb 05                	jmp    800add <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ad8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800add:	89 d0                	mov    %edx,%eax
  800adf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae2:	c9                   	leave  
  800ae3:	c3                   	ret    

00800ae4 <seek>:

int
seek(int fdnum, off_t offset)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800aea:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800aed:	50                   	push   %eax
  800aee:	ff 75 08             	pushl  0x8(%ebp)
  800af1:	e8 22 fc ff ff       	call   800718 <fd_lookup>
  800af6:	83 c4 08             	add    $0x8,%esp
  800af9:	85 c0                	test   %eax,%eax
  800afb:	78 0e                	js     800b0b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800afd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b03:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0b:	c9                   	leave  
  800b0c:	c3                   	ret    

00800b0d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	53                   	push   %ebx
  800b11:	83 ec 14             	sub    $0x14,%esp
  800b14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b17:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b1a:	50                   	push   %eax
  800b1b:	53                   	push   %ebx
  800b1c:	e8 f7 fb ff ff       	call   800718 <fd_lookup>
  800b21:	83 c4 08             	add    $0x8,%esp
  800b24:	89 c2                	mov    %eax,%edx
  800b26:	85 c0                	test   %eax,%eax
  800b28:	78 65                	js     800b8f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b2a:	83 ec 08             	sub    $0x8,%esp
  800b2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b30:	50                   	push   %eax
  800b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b34:	ff 30                	pushl  (%eax)
  800b36:	e8 33 fc ff ff       	call   80076e <dev_lookup>
  800b3b:	83 c4 10             	add    $0x10,%esp
  800b3e:	85 c0                	test   %eax,%eax
  800b40:	78 44                	js     800b86 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b45:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b49:	75 21                	jne    800b6c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b4b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b50:	8b 40 7c             	mov    0x7c(%eax),%eax
  800b53:	83 ec 04             	sub    $0x4,%esp
  800b56:	53                   	push   %ebx
  800b57:	50                   	push   %eax
  800b58:	68 94 22 80 00       	push   $0x802294
  800b5d:	e8 0c 09 00 00       	call   80146e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b62:	83 c4 10             	add    $0x10,%esp
  800b65:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b6a:	eb 23                	jmp    800b8f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b6f:	8b 52 18             	mov    0x18(%edx),%edx
  800b72:	85 d2                	test   %edx,%edx
  800b74:	74 14                	je     800b8a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b76:	83 ec 08             	sub    $0x8,%esp
  800b79:	ff 75 0c             	pushl  0xc(%ebp)
  800b7c:	50                   	push   %eax
  800b7d:	ff d2                	call   *%edx
  800b7f:	89 c2                	mov    %eax,%edx
  800b81:	83 c4 10             	add    $0x10,%esp
  800b84:	eb 09                	jmp    800b8f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b86:	89 c2                	mov    %eax,%edx
  800b88:	eb 05                	jmp    800b8f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b8a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b8f:	89 d0                	mov    %edx,%eax
  800b91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    

00800b96 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 14             	sub    $0x14,%esp
  800b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ba0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ba3:	50                   	push   %eax
  800ba4:	ff 75 08             	pushl  0x8(%ebp)
  800ba7:	e8 6c fb ff ff       	call   800718 <fd_lookup>
  800bac:	83 c4 08             	add    $0x8,%esp
  800baf:	89 c2                	mov    %eax,%edx
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	78 58                	js     800c0d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bb5:	83 ec 08             	sub    $0x8,%esp
  800bb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bbb:	50                   	push   %eax
  800bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bbf:	ff 30                	pushl  (%eax)
  800bc1:	e8 a8 fb ff ff       	call   80076e <dev_lookup>
  800bc6:	83 c4 10             	add    $0x10,%esp
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	78 37                	js     800c04 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bd4:	74 32                	je     800c08 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bd6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800bd9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800be0:	00 00 00 
	stat->st_isdir = 0;
  800be3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bea:	00 00 00 
	stat->st_dev = dev;
  800bed:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bf3:	83 ec 08             	sub    $0x8,%esp
  800bf6:	53                   	push   %ebx
  800bf7:	ff 75 f0             	pushl  -0x10(%ebp)
  800bfa:	ff 50 14             	call   *0x14(%eax)
  800bfd:	89 c2                	mov    %eax,%edx
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	eb 09                	jmp    800c0d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c04:	89 c2                	mov    %eax,%edx
  800c06:	eb 05                	jmp    800c0d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c08:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c0d:	89 d0                	mov    %edx,%eax
  800c0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c19:	83 ec 08             	sub    $0x8,%esp
  800c1c:	6a 00                	push   $0x0
  800c1e:	ff 75 08             	pushl  0x8(%ebp)
  800c21:	e8 e3 01 00 00       	call   800e09 <open>
  800c26:	89 c3                	mov    %eax,%ebx
  800c28:	83 c4 10             	add    $0x10,%esp
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	78 1b                	js     800c4a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c2f:	83 ec 08             	sub    $0x8,%esp
  800c32:	ff 75 0c             	pushl  0xc(%ebp)
  800c35:	50                   	push   %eax
  800c36:	e8 5b ff ff ff       	call   800b96 <fstat>
  800c3b:	89 c6                	mov    %eax,%esi
	close(fd);
  800c3d:	89 1c 24             	mov    %ebx,(%esp)
  800c40:	e8 fd fb ff ff       	call   800842 <close>
	return r;
  800c45:	83 c4 10             	add    $0x10,%esp
  800c48:	89 f0                	mov    %esi,%eax
}
  800c4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	89 c6                	mov    %eax,%esi
  800c58:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c5a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c61:	75 12                	jne    800c75 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	6a 01                	push   $0x1
  800c68:	e8 39 12 00 00       	call   801ea6 <ipc_find_env>
  800c6d:	a3 00 40 80 00       	mov    %eax,0x804000
  800c72:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c75:	6a 07                	push   $0x7
  800c77:	68 00 50 80 00       	push   $0x805000
  800c7c:	56                   	push   %esi
  800c7d:	ff 35 00 40 80 00    	pushl  0x804000
  800c83:	e8 bc 11 00 00       	call   801e44 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c88:	83 c4 0c             	add    $0xc,%esp
  800c8b:	6a 00                	push   $0x0
  800c8d:	53                   	push   %ebx
  800c8e:	6a 00                	push   $0x0
  800c90:	e8 34 11 00 00       	call   801dc9 <ipc_recv>
}
  800c95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca5:	8b 40 0c             	mov    0xc(%eax),%eax
  800ca8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cba:	b8 02 00 00 00       	mov    $0x2,%eax
  800cbf:	e8 8d ff ff ff       	call   800c51 <fsipc>
}
  800cc4:	c9                   	leave  
  800cc5:	c3                   	ret    

00800cc6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccf:	8b 40 0c             	mov    0xc(%eax),%eax
  800cd2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800cd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdc:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce1:	e8 6b ff ff ff       	call   800c51 <fsipc>
}
  800ce6:	c9                   	leave  
  800ce7:	c3                   	ret    

00800ce8 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 04             	sub    $0x4,%esp
  800cef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	8b 40 0c             	mov    0xc(%eax),%eax
  800cf8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	b8 05 00 00 00       	mov    $0x5,%eax
  800d07:	e8 45 ff ff ff       	call   800c51 <fsipc>
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	78 2c                	js     800d3c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d10:	83 ec 08             	sub    $0x8,%esp
  800d13:	68 00 50 80 00       	push   $0x805000
  800d18:	53                   	push   %ebx
  800d19:	e8 d5 0c 00 00       	call   8019f3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d1e:	a1 80 50 80 00       	mov    0x805080,%eax
  800d23:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d29:	a1 84 50 80 00       	mov    0x805084,%eax
  800d2e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d34:	83 c4 10             	add    $0x10,%esp
  800d37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    

00800d41 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	8b 52 0c             	mov    0xc(%edx),%edx
  800d50:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d56:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d5b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d60:	0f 47 c2             	cmova  %edx,%eax
  800d63:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d68:	50                   	push   %eax
  800d69:	ff 75 0c             	pushl  0xc(%ebp)
  800d6c:	68 08 50 80 00       	push   $0x805008
  800d71:	e8 0f 0e 00 00       	call   801b85 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d76:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d80:	e8 cc fe ff ff       	call   800c51 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d85:	c9                   	leave  
  800d86:	c3                   	ret    

00800d87 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	8b 40 0c             	mov    0xc(%eax),%eax
  800d95:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800d9a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800da0:	ba 00 00 00 00       	mov    $0x0,%edx
  800da5:	b8 03 00 00 00       	mov    $0x3,%eax
  800daa:	e8 a2 fe ff ff       	call   800c51 <fsipc>
  800daf:	89 c3                	mov    %eax,%ebx
  800db1:	85 c0                	test   %eax,%eax
  800db3:	78 4b                	js     800e00 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800db5:	39 c6                	cmp    %eax,%esi
  800db7:	73 16                	jae    800dcf <devfile_read+0x48>
  800db9:	68 00 23 80 00       	push   $0x802300
  800dbe:	68 07 23 80 00       	push   $0x802307
  800dc3:	6a 7c                	push   $0x7c
  800dc5:	68 1c 23 80 00       	push   $0x80231c
  800dca:	e8 c6 05 00 00       	call   801395 <_panic>
	assert(r <= PGSIZE);
  800dcf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800dd4:	7e 16                	jle    800dec <devfile_read+0x65>
  800dd6:	68 27 23 80 00       	push   $0x802327
  800ddb:	68 07 23 80 00       	push   $0x802307
  800de0:	6a 7d                	push   $0x7d
  800de2:	68 1c 23 80 00       	push   $0x80231c
  800de7:	e8 a9 05 00 00       	call   801395 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800dec:	83 ec 04             	sub    $0x4,%esp
  800def:	50                   	push   %eax
  800df0:	68 00 50 80 00       	push   $0x805000
  800df5:	ff 75 0c             	pushl  0xc(%ebp)
  800df8:	e8 88 0d 00 00       	call   801b85 <memmove>
	return r;
  800dfd:	83 c4 10             	add    $0x10,%esp
}
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 20             	sub    $0x20,%esp
  800e10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e13:	53                   	push   %ebx
  800e14:	e8 a1 0b 00 00       	call   8019ba <strlen>
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e21:	7f 67                	jg     800e8a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e29:	50                   	push   %eax
  800e2a:	e8 9a f8 ff ff       	call   8006c9 <fd_alloc>
  800e2f:	83 c4 10             	add    $0x10,%esp
		return r;
  800e32:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e34:	85 c0                	test   %eax,%eax
  800e36:	78 57                	js     800e8f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	53                   	push   %ebx
  800e3c:	68 00 50 80 00       	push   $0x805000
  800e41:	e8 ad 0b 00 00       	call   8019f3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e46:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e49:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e51:	b8 01 00 00 00       	mov    $0x1,%eax
  800e56:	e8 f6 fd ff ff       	call   800c51 <fsipc>
  800e5b:	89 c3                	mov    %eax,%ebx
  800e5d:	83 c4 10             	add    $0x10,%esp
  800e60:	85 c0                	test   %eax,%eax
  800e62:	79 14                	jns    800e78 <open+0x6f>
		fd_close(fd, 0);
  800e64:	83 ec 08             	sub    $0x8,%esp
  800e67:	6a 00                	push   $0x0
  800e69:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6c:	e8 50 f9 ff ff       	call   8007c1 <fd_close>
		return r;
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	89 da                	mov    %ebx,%edx
  800e76:	eb 17                	jmp    800e8f <open+0x86>
	}

	return fd2num(fd);
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7e:	e8 1f f8 ff ff       	call   8006a2 <fd2num>
  800e83:	89 c2                	mov    %eax,%edx
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	eb 05                	jmp    800e8f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e8a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e8f:	89 d0                	mov    %edx,%eax
  800e91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800e9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea6:	e8 a6 fd ff ff       	call   800c51 <fsipc>
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800eb5:	83 ec 0c             	sub    $0xc,%esp
  800eb8:	ff 75 08             	pushl  0x8(%ebp)
  800ebb:	e8 f2 f7 ff ff       	call   8006b2 <fd2data>
  800ec0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ec2:	83 c4 08             	add    $0x8,%esp
  800ec5:	68 33 23 80 00       	push   $0x802333
  800eca:	53                   	push   %ebx
  800ecb:	e8 23 0b 00 00       	call   8019f3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ed0:	8b 46 04             	mov    0x4(%esi),%eax
  800ed3:	2b 06                	sub    (%esi),%eax
  800ed5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800edb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ee2:	00 00 00 
	stat->st_dev = &devpipe;
  800ee5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800eec:	30 80 00 
	return 0;
}
  800eef:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	53                   	push   %ebx
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f05:	53                   	push   %ebx
  800f06:	6a 00                	push   $0x0
  800f08:	e8 f5 f2 ff ff       	call   800202 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f0d:	89 1c 24             	mov    %ebx,(%esp)
  800f10:	e8 9d f7 ff ff       	call   8006b2 <fd2data>
  800f15:	83 c4 08             	add    $0x8,%esp
  800f18:	50                   	push   %eax
  800f19:	6a 00                	push   $0x0
  800f1b:	e8 e2 f2 ff ff       	call   800202 <sys_page_unmap>
}
  800f20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f23:	c9                   	leave  
  800f24:	c3                   	ret    

00800f25 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	83 ec 1c             	sub    $0x1c,%esp
  800f2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f31:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f33:	a1 04 40 80 00       	mov    0x804004,%eax
  800f38:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	ff 75 e0             	pushl  -0x20(%ebp)
  800f44:	e8 9f 0f 00 00       	call   801ee8 <pageref>
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	89 3c 24             	mov    %edi,(%esp)
  800f4e:	e8 95 0f 00 00       	call   801ee8 <pageref>
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	39 c3                	cmp    %eax,%ebx
  800f58:	0f 94 c1             	sete   %cl
  800f5b:	0f b6 c9             	movzbl %cl,%ecx
  800f5e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f61:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f67:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  800f6d:	39 ce                	cmp    %ecx,%esi
  800f6f:	74 1e                	je     800f8f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800f71:	39 c3                	cmp    %eax,%ebx
  800f73:	75 be                	jne    800f33 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f75:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  800f7b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7e:	50                   	push   %eax
  800f7f:	56                   	push   %esi
  800f80:	68 3a 23 80 00       	push   $0x80233a
  800f85:	e8 e4 04 00 00       	call   80146e <cprintf>
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	eb a4                	jmp    800f33 <_pipeisclosed+0xe>
	}
}
  800f8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	57                   	push   %edi
  800f9e:	56                   	push   %esi
  800f9f:	53                   	push   %ebx
  800fa0:	83 ec 28             	sub    $0x28,%esp
  800fa3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fa6:	56                   	push   %esi
  800fa7:	e8 06 f7 ff ff       	call   8006b2 <fd2data>
  800fac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb6:	eb 4b                	jmp    801003 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fb8:	89 da                	mov    %ebx,%edx
  800fba:	89 f0                	mov    %esi,%eax
  800fbc:	e8 64 ff ff ff       	call   800f25 <_pipeisclosed>
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	75 48                	jne    80100d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fc5:	e8 94 f1 ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fca:	8b 43 04             	mov    0x4(%ebx),%eax
  800fcd:	8b 0b                	mov    (%ebx),%ecx
  800fcf:	8d 51 20             	lea    0x20(%ecx),%edx
  800fd2:	39 d0                	cmp    %edx,%eax
  800fd4:	73 e2                	jae    800fb8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fdd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fe0:	89 c2                	mov    %eax,%edx
  800fe2:	c1 fa 1f             	sar    $0x1f,%edx
  800fe5:	89 d1                	mov    %edx,%ecx
  800fe7:	c1 e9 1b             	shr    $0x1b,%ecx
  800fea:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800fed:	83 e2 1f             	and    $0x1f,%edx
  800ff0:	29 ca                	sub    %ecx,%edx
  800ff2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ff6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ffa:	83 c0 01             	add    $0x1,%eax
  800ffd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801000:	83 c7 01             	add    $0x1,%edi
  801003:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801006:	75 c2                	jne    800fca <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801008:	8b 45 10             	mov    0x10(%ebp),%eax
  80100b:	eb 05                	jmp    801012 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80100d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
  801020:	83 ec 18             	sub    $0x18,%esp
  801023:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801026:	57                   	push   %edi
  801027:	e8 86 f6 ff ff       	call   8006b2 <fd2data>
  80102c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	bb 00 00 00 00       	mov    $0x0,%ebx
  801036:	eb 3d                	jmp    801075 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801038:	85 db                	test   %ebx,%ebx
  80103a:	74 04                	je     801040 <devpipe_read+0x26>
				return i;
  80103c:	89 d8                	mov    %ebx,%eax
  80103e:	eb 44                	jmp    801084 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801040:	89 f2                	mov    %esi,%edx
  801042:	89 f8                	mov    %edi,%eax
  801044:	e8 dc fe ff ff       	call   800f25 <_pipeisclosed>
  801049:	85 c0                	test   %eax,%eax
  80104b:	75 32                	jne    80107f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80104d:	e8 0c f1 ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801052:	8b 06                	mov    (%esi),%eax
  801054:	3b 46 04             	cmp    0x4(%esi),%eax
  801057:	74 df                	je     801038 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801059:	99                   	cltd   
  80105a:	c1 ea 1b             	shr    $0x1b,%edx
  80105d:	01 d0                	add    %edx,%eax
  80105f:	83 e0 1f             	and    $0x1f,%eax
  801062:	29 d0                	sub    %edx,%eax
  801064:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801069:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80106f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801072:	83 c3 01             	add    $0x1,%ebx
  801075:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801078:	75 d8                	jne    801052 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80107a:	8b 45 10             	mov    0x10(%ebp),%eax
  80107d:	eb 05                	jmp    801084 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80107f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801084:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801087:	5b                   	pop    %ebx
  801088:	5e                   	pop    %esi
  801089:	5f                   	pop    %edi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	56                   	push   %esi
  801090:	53                   	push   %ebx
  801091:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801094:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801097:	50                   	push   %eax
  801098:	e8 2c f6 ff ff       	call   8006c9 <fd_alloc>
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	89 c2                	mov    %eax,%edx
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	0f 88 2c 01 00 00    	js     8011d6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010aa:	83 ec 04             	sub    $0x4,%esp
  8010ad:	68 07 04 00 00       	push   $0x407
  8010b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b5:	6a 00                	push   $0x0
  8010b7:	e8 c1 f0 ff ff       	call   80017d <sys_page_alloc>
  8010bc:	83 c4 10             	add    $0x10,%esp
  8010bf:	89 c2                	mov    %eax,%edx
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	0f 88 0d 01 00 00    	js     8011d6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010cf:	50                   	push   %eax
  8010d0:	e8 f4 f5 ff ff       	call   8006c9 <fd_alloc>
  8010d5:	89 c3                	mov    %eax,%ebx
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	0f 88 e2 00 00 00    	js     8011c4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010e2:	83 ec 04             	sub    $0x4,%esp
  8010e5:	68 07 04 00 00       	push   $0x407
  8010ea:	ff 75 f0             	pushl  -0x10(%ebp)
  8010ed:	6a 00                	push   $0x0
  8010ef:	e8 89 f0 ff ff       	call   80017d <sys_page_alloc>
  8010f4:	89 c3                	mov    %eax,%ebx
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	0f 88 c3 00 00 00    	js     8011c4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801101:	83 ec 0c             	sub    $0xc,%esp
  801104:	ff 75 f4             	pushl  -0xc(%ebp)
  801107:	e8 a6 f5 ff ff       	call   8006b2 <fd2data>
  80110c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80110e:	83 c4 0c             	add    $0xc,%esp
  801111:	68 07 04 00 00       	push   $0x407
  801116:	50                   	push   %eax
  801117:	6a 00                	push   $0x0
  801119:	e8 5f f0 ff ff       	call   80017d <sys_page_alloc>
  80111e:	89 c3                	mov    %eax,%ebx
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	0f 88 89 00 00 00    	js     8011b4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	ff 75 f0             	pushl  -0x10(%ebp)
  801131:	e8 7c f5 ff ff       	call   8006b2 <fd2data>
  801136:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80113d:	50                   	push   %eax
  80113e:	6a 00                	push   $0x0
  801140:	56                   	push   %esi
  801141:	6a 00                	push   $0x0
  801143:	e8 78 f0 ff ff       	call   8001c0 <sys_page_map>
  801148:	89 c3                	mov    %eax,%ebx
  80114a:	83 c4 20             	add    $0x20,%esp
  80114d:	85 c0                	test   %eax,%eax
  80114f:	78 55                	js     8011a6 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801151:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801157:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80115c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801166:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80116c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801174:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80117b:	83 ec 0c             	sub    $0xc,%esp
  80117e:	ff 75 f4             	pushl  -0xc(%ebp)
  801181:	e8 1c f5 ff ff       	call   8006a2 <fd2num>
  801186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801189:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80118b:	83 c4 04             	add    $0x4,%esp
  80118e:	ff 75 f0             	pushl  -0x10(%ebp)
  801191:	e8 0c f5 ff ff       	call   8006a2 <fd2num>
  801196:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801199:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a4:	eb 30                	jmp    8011d6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	56                   	push   %esi
  8011aa:	6a 00                	push   $0x0
  8011ac:	e8 51 f0 ff ff       	call   800202 <sys_page_unmap>
  8011b1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011b4:	83 ec 08             	sub    $0x8,%esp
  8011b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8011ba:	6a 00                	push   $0x0
  8011bc:	e8 41 f0 ff ff       	call   800202 <sys_page_unmap>
  8011c1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011c4:	83 ec 08             	sub    $0x8,%esp
  8011c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ca:	6a 00                	push   $0x0
  8011cc:	e8 31 f0 ff ff       	call   800202 <sys_page_unmap>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011d6:	89 d0                	mov    %edx,%eax
  8011d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	ff 75 08             	pushl  0x8(%ebp)
  8011ec:	e8 27 f5 ff ff       	call   800718 <fd_lookup>
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 18                	js     801210 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011f8:	83 ec 0c             	sub    $0xc,%esp
  8011fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8011fe:	e8 af f4 ff ff       	call   8006b2 <fd2data>
	return _pipeisclosed(fd, p);
  801203:	89 c2                	mov    %eax,%edx
  801205:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801208:	e8 18 fd ff ff       	call   800f25 <_pipeisclosed>
  80120d:	83 c4 10             	add    $0x10,%esp
}
  801210:	c9                   	leave  
  801211:	c3                   	ret    

00801212 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801215:	b8 00 00 00 00       	mov    $0x0,%eax
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801222:	68 52 23 80 00       	push   $0x802352
  801227:	ff 75 0c             	pushl  0xc(%ebp)
  80122a:	e8 c4 07 00 00       	call   8019f3 <strcpy>
	return 0;
}
  80122f:	b8 00 00 00 00       	mov    $0x0,%eax
  801234:	c9                   	leave  
  801235:	c3                   	ret    

00801236 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	57                   	push   %edi
  80123a:	56                   	push   %esi
  80123b:	53                   	push   %ebx
  80123c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801242:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801247:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80124d:	eb 2d                	jmp    80127c <devcons_write+0x46>
		m = n - tot;
  80124f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801252:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801254:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801257:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80125c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80125f:	83 ec 04             	sub    $0x4,%esp
  801262:	53                   	push   %ebx
  801263:	03 45 0c             	add    0xc(%ebp),%eax
  801266:	50                   	push   %eax
  801267:	57                   	push   %edi
  801268:	e8 18 09 00 00       	call   801b85 <memmove>
		sys_cputs(buf, m);
  80126d:	83 c4 08             	add    $0x8,%esp
  801270:	53                   	push   %ebx
  801271:	57                   	push   %edi
  801272:	e8 4a ee ff ff       	call   8000c1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801277:	01 de                	add    %ebx,%esi
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	89 f0                	mov    %esi,%eax
  80127e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801281:	72 cc                	jb     80124f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5f                   	pop    %edi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801296:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80129a:	74 2a                	je     8012c6 <devcons_read+0x3b>
  80129c:	eb 05                	jmp    8012a3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80129e:	e8 bb ee ff ff       	call   80015e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012a3:	e8 37 ee ff ff       	call   8000df <sys_cgetc>
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	74 f2                	je     80129e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 16                	js     8012c6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012b0:	83 f8 04             	cmp    $0x4,%eax
  8012b3:	74 0c                	je     8012c1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b8:	88 02                	mov    %al,(%edx)
	return 1;
  8012ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8012bf:	eb 05                	jmp    8012c6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012c1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012c6:	c9                   	leave  
  8012c7:	c3                   	ret    

008012c8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012d4:	6a 01                	push   $0x1
  8012d6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012d9:	50                   	push   %eax
  8012da:	e8 e2 ed ff ff       	call   8000c1 <sys_cputs>
}
  8012df:	83 c4 10             	add    $0x10,%esp
  8012e2:	c9                   	leave  
  8012e3:	c3                   	ret    

008012e4 <getchar>:

int
getchar(void)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012ea:	6a 01                	push   $0x1
  8012ec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	6a 00                	push   $0x0
  8012f2:	e8 87 f6 ff ff       	call   80097e <read>
	if (r < 0)
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 0f                	js     80130d <getchar+0x29>
		return r;
	if (r < 1)
  8012fe:	85 c0                	test   %eax,%eax
  801300:	7e 06                	jle    801308 <getchar+0x24>
		return -E_EOF;
	return c;
  801302:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801306:	eb 05                	jmp    80130d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801308:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80130d:	c9                   	leave  
  80130e:	c3                   	ret    

0080130f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 75 08             	pushl  0x8(%ebp)
  80131c:	e8 f7 f3 ff ff       	call   800718 <fd_lookup>
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 11                	js     801339 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801328:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801331:	39 10                	cmp    %edx,(%eax)
  801333:	0f 94 c0             	sete   %al
  801336:	0f b6 c0             	movzbl %al,%eax
}
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <opencons>:

int
opencons(void)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801341:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801344:	50                   	push   %eax
  801345:	e8 7f f3 ff ff       	call   8006c9 <fd_alloc>
  80134a:	83 c4 10             	add    $0x10,%esp
		return r;
  80134d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 3e                	js     801391 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801353:	83 ec 04             	sub    $0x4,%esp
  801356:	68 07 04 00 00       	push   $0x407
  80135b:	ff 75 f4             	pushl  -0xc(%ebp)
  80135e:	6a 00                	push   $0x0
  801360:	e8 18 ee ff ff       	call   80017d <sys_page_alloc>
  801365:	83 c4 10             	add    $0x10,%esp
		return r;
  801368:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 23                	js     801391 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80136e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801374:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801377:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801379:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	50                   	push   %eax
  801387:	e8 16 f3 ff ff       	call   8006a2 <fd2num>
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	83 c4 10             	add    $0x10,%esp
}
  801391:	89 d0                	mov    %edx,%eax
  801393:	c9                   	leave  
  801394:	c3                   	ret    

00801395 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	56                   	push   %esi
  801399:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80139a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80139d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013a3:	e8 97 ed ff ff       	call   80013f <sys_getenvid>
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	ff 75 0c             	pushl  0xc(%ebp)
  8013ae:	ff 75 08             	pushl  0x8(%ebp)
  8013b1:	56                   	push   %esi
  8013b2:	50                   	push   %eax
  8013b3:	68 60 23 80 00       	push   $0x802360
  8013b8:	e8 b1 00 00 00       	call   80146e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013bd:	83 c4 18             	add    $0x18,%esp
  8013c0:	53                   	push   %ebx
  8013c1:	ff 75 10             	pushl  0x10(%ebp)
  8013c4:	e8 54 00 00 00       	call   80141d <vcprintf>
	cprintf("\n");
  8013c9:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  8013d0:	e8 99 00 00 00       	call   80146e <cprintf>
  8013d5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013d8:	cc                   	int3   
  8013d9:	eb fd                	jmp    8013d8 <_panic+0x43>

008013db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	53                   	push   %ebx
  8013df:	83 ec 04             	sub    $0x4,%esp
  8013e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013e5:	8b 13                	mov    (%ebx),%edx
  8013e7:	8d 42 01             	lea    0x1(%edx),%eax
  8013ea:	89 03                	mov    %eax,(%ebx)
  8013ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013f8:	75 1a                	jne    801414 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	68 ff 00 00 00       	push   $0xff
  801402:	8d 43 08             	lea    0x8(%ebx),%eax
  801405:	50                   	push   %eax
  801406:	e8 b6 ec ff ff       	call   8000c1 <sys_cputs>
		b->idx = 0;
  80140b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801411:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801414:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801418:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801426:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80142d:	00 00 00 
	b.cnt = 0;
  801430:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801437:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80143a:	ff 75 0c             	pushl  0xc(%ebp)
  80143d:	ff 75 08             	pushl  0x8(%ebp)
  801440:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801446:	50                   	push   %eax
  801447:	68 db 13 80 00       	push   $0x8013db
  80144c:	e8 54 01 00 00       	call   8015a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801451:	83 c4 08             	add    $0x8,%esp
  801454:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80145a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	e8 5b ec ff ff       	call   8000c1 <sys_cputs>

	return b.cnt;
}
  801466:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801474:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801477:	50                   	push   %eax
  801478:	ff 75 08             	pushl  0x8(%ebp)
  80147b:	e8 9d ff ff ff       	call   80141d <vcprintf>
	va_end(ap);

	return cnt;
}
  801480:	c9                   	leave  
  801481:	c3                   	ret    

00801482 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	57                   	push   %edi
  801486:	56                   	push   %esi
  801487:	53                   	push   %ebx
  801488:	83 ec 1c             	sub    $0x1c,%esp
  80148b:	89 c7                	mov    %eax,%edi
  80148d:	89 d6                	mov    %edx,%esi
  80148f:	8b 45 08             	mov    0x8(%ebp),%eax
  801492:	8b 55 0c             	mov    0xc(%ebp),%edx
  801495:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801498:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80149b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80149e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014a6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014a9:	39 d3                	cmp    %edx,%ebx
  8014ab:	72 05                	jb     8014b2 <printnum+0x30>
  8014ad:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014b0:	77 45                	ja     8014f7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014b2:	83 ec 0c             	sub    $0xc,%esp
  8014b5:	ff 75 18             	pushl  0x18(%ebp)
  8014b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bb:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014be:	53                   	push   %ebx
  8014bf:	ff 75 10             	pushl  0x10(%ebp)
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8014cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8014ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8014d1:	e8 5a 0a 00 00       	call   801f30 <__udivdi3>
  8014d6:	83 c4 18             	add    $0x18,%esp
  8014d9:	52                   	push   %edx
  8014da:	50                   	push   %eax
  8014db:	89 f2                	mov    %esi,%edx
  8014dd:	89 f8                	mov    %edi,%eax
  8014df:	e8 9e ff ff ff       	call   801482 <printnum>
  8014e4:	83 c4 20             	add    $0x20,%esp
  8014e7:	eb 18                	jmp    801501 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	56                   	push   %esi
  8014ed:	ff 75 18             	pushl  0x18(%ebp)
  8014f0:	ff d7                	call   *%edi
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb 03                	jmp    8014fa <printnum+0x78>
  8014f7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014fa:	83 eb 01             	sub    $0x1,%ebx
  8014fd:	85 db                	test   %ebx,%ebx
  8014ff:	7f e8                	jg     8014e9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	56                   	push   %esi
  801505:	83 ec 04             	sub    $0x4,%esp
  801508:	ff 75 e4             	pushl  -0x1c(%ebp)
  80150b:	ff 75 e0             	pushl  -0x20(%ebp)
  80150e:	ff 75 dc             	pushl  -0x24(%ebp)
  801511:	ff 75 d8             	pushl  -0x28(%ebp)
  801514:	e8 47 0b 00 00       	call   802060 <__umoddi3>
  801519:	83 c4 14             	add    $0x14,%esp
  80151c:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  801523:	50                   	push   %eax
  801524:	ff d7                	call   *%edi
}
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152c:	5b                   	pop    %ebx
  80152d:	5e                   	pop    %esi
  80152e:	5f                   	pop    %edi
  80152f:	5d                   	pop    %ebp
  801530:	c3                   	ret    

00801531 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801534:	83 fa 01             	cmp    $0x1,%edx
  801537:	7e 0e                	jle    801547 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801539:	8b 10                	mov    (%eax),%edx
  80153b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80153e:	89 08                	mov    %ecx,(%eax)
  801540:	8b 02                	mov    (%edx),%eax
  801542:	8b 52 04             	mov    0x4(%edx),%edx
  801545:	eb 22                	jmp    801569 <getuint+0x38>
	else if (lflag)
  801547:	85 d2                	test   %edx,%edx
  801549:	74 10                	je     80155b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80154b:	8b 10                	mov    (%eax),%edx
  80154d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801550:	89 08                	mov    %ecx,(%eax)
  801552:	8b 02                	mov    (%edx),%eax
  801554:	ba 00 00 00 00       	mov    $0x0,%edx
  801559:	eb 0e                	jmp    801569 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80155b:	8b 10                	mov    (%eax),%edx
  80155d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801560:	89 08                	mov    %ecx,(%eax)
  801562:	8b 02                	mov    (%edx),%eax
  801564:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801571:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801575:	8b 10                	mov    (%eax),%edx
  801577:	3b 50 04             	cmp    0x4(%eax),%edx
  80157a:	73 0a                	jae    801586 <sprintputch+0x1b>
		*b->buf++ = ch;
  80157c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80157f:	89 08                	mov    %ecx,(%eax)
  801581:	8b 45 08             	mov    0x8(%ebp),%eax
  801584:	88 02                	mov    %al,(%edx)
}
  801586:	5d                   	pop    %ebp
  801587:	c3                   	ret    

00801588 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80158e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801591:	50                   	push   %eax
  801592:	ff 75 10             	pushl  0x10(%ebp)
  801595:	ff 75 0c             	pushl  0xc(%ebp)
  801598:	ff 75 08             	pushl  0x8(%ebp)
  80159b:	e8 05 00 00 00       	call   8015a5 <vprintfmt>
	va_end(ap);
}
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	57                   	push   %edi
  8015a9:	56                   	push   %esi
  8015aa:	53                   	push   %ebx
  8015ab:	83 ec 2c             	sub    $0x2c,%esp
  8015ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015b7:	eb 12                	jmp    8015cb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	0f 84 89 03 00 00    	je     80194a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	53                   	push   %ebx
  8015c5:	50                   	push   %eax
  8015c6:	ff d6                	call   *%esi
  8015c8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015cb:	83 c7 01             	add    $0x1,%edi
  8015ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015d2:	83 f8 25             	cmp    $0x25,%eax
  8015d5:	75 e2                	jne    8015b9 <vprintfmt+0x14>
  8015d7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f5:	eb 07                	jmp    8015fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015fe:	8d 47 01             	lea    0x1(%edi),%eax
  801601:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801604:	0f b6 07             	movzbl (%edi),%eax
  801607:	0f b6 c8             	movzbl %al,%ecx
  80160a:	83 e8 23             	sub    $0x23,%eax
  80160d:	3c 55                	cmp    $0x55,%al
  80160f:	0f 87 1a 03 00 00    	ja     80192f <vprintfmt+0x38a>
  801615:	0f b6 c0             	movzbl %al,%eax
  801618:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  80161f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801622:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801626:	eb d6                	jmp    8015fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801628:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80162b:	b8 00 00 00 00       	mov    $0x0,%eax
  801630:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801633:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801636:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80163a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80163d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801640:	83 fa 09             	cmp    $0x9,%edx
  801643:	77 39                	ja     80167e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801645:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801648:	eb e9                	jmp    801633 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80164a:	8b 45 14             	mov    0x14(%ebp),%eax
  80164d:	8d 48 04             	lea    0x4(%eax),%ecx
  801650:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801653:	8b 00                	mov    (%eax),%eax
  801655:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80165b:	eb 27                	jmp    801684 <vprintfmt+0xdf>
  80165d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801660:	85 c0                	test   %eax,%eax
  801662:	b9 00 00 00 00       	mov    $0x0,%ecx
  801667:	0f 49 c8             	cmovns %eax,%ecx
  80166a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80166d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801670:	eb 8c                	jmp    8015fe <vprintfmt+0x59>
  801672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801675:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80167c:	eb 80                	jmp    8015fe <vprintfmt+0x59>
  80167e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801681:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801684:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801688:	0f 89 70 ff ff ff    	jns    8015fe <vprintfmt+0x59>
				width = precision, precision = -1;
  80168e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801691:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801694:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80169b:	e9 5e ff ff ff       	jmp    8015fe <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016a0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016a6:	e9 53 ff ff ff       	jmp    8015fe <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ae:	8d 50 04             	lea    0x4(%eax),%edx
  8016b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	53                   	push   %ebx
  8016b8:	ff 30                	pushl  (%eax)
  8016ba:	ff d6                	call   *%esi
			break;
  8016bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016c2:	e9 04 ff ff ff       	jmp    8015cb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ca:	8d 50 04             	lea    0x4(%eax),%edx
  8016cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d0:	8b 00                	mov    (%eax),%eax
  8016d2:	99                   	cltd   
  8016d3:	31 d0                	xor    %edx,%eax
  8016d5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016d7:	83 f8 0f             	cmp    $0xf,%eax
  8016da:	7f 0b                	jg     8016e7 <vprintfmt+0x142>
  8016dc:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8016e3:	85 d2                	test   %edx,%edx
  8016e5:	75 18                	jne    8016ff <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016e7:	50                   	push   %eax
  8016e8:	68 9b 23 80 00       	push   $0x80239b
  8016ed:	53                   	push   %ebx
  8016ee:	56                   	push   %esi
  8016ef:	e8 94 fe ff ff       	call   801588 <printfmt>
  8016f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016fa:	e9 cc fe ff ff       	jmp    8015cb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8016ff:	52                   	push   %edx
  801700:	68 19 23 80 00       	push   $0x802319
  801705:	53                   	push   %ebx
  801706:	56                   	push   %esi
  801707:	e8 7c fe ff ff       	call   801588 <printfmt>
  80170c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801712:	e9 b4 fe ff ff       	jmp    8015cb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801717:	8b 45 14             	mov    0x14(%ebp),%eax
  80171a:	8d 50 04             	lea    0x4(%eax),%edx
  80171d:	89 55 14             	mov    %edx,0x14(%ebp)
  801720:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801722:	85 ff                	test   %edi,%edi
  801724:	b8 94 23 80 00       	mov    $0x802394,%eax
  801729:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80172c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801730:	0f 8e 94 00 00 00    	jle    8017ca <vprintfmt+0x225>
  801736:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80173a:	0f 84 98 00 00 00    	je     8017d8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	ff 75 d0             	pushl  -0x30(%ebp)
  801746:	57                   	push   %edi
  801747:	e8 86 02 00 00       	call   8019d2 <strnlen>
  80174c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80174f:	29 c1                	sub    %eax,%ecx
  801751:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801754:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801757:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80175b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80175e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801761:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801763:	eb 0f                	jmp    801774 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801765:	83 ec 08             	sub    $0x8,%esp
  801768:	53                   	push   %ebx
  801769:	ff 75 e0             	pushl  -0x20(%ebp)
  80176c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80176e:	83 ef 01             	sub    $0x1,%edi
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	85 ff                	test   %edi,%edi
  801776:	7f ed                	jg     801765 <vprintfmt+0x1c0>
  801778:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80177b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80177e:	85 c9                	test   %ecx,%ecx
  801780:	b8 00 00 00 00       	mov    $0x0,%eax
  801785:	0f 49 c1             	cmovns %ecx,%eax
  801788:	29 c1                	sub    %eax,%ecx
  80178a:	89 75 08             	mov    %esi,0x8(%ebp)
  80178d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801790:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801793:	89 cb                	mov    %ecx,%ebx
  801795:	eb 4d                	jmp    8017e4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801797:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80179b:	74 1b                	je     8017b8 <vprintfmt+0x213>
  80179d:	0f be c0             	movsbl %al,%eax
  8017a0:	83 e8 20             	sub    $0x20,%eax
  8017a3:	83 f8 5e             	cmp    $0x5e,%eax
  8017a6:	76 10                	jbe    8017b8 <vprintfmt+0x213>
					putch('?', putdat);
  8017a8:	83 ec 08             	sub    $0x8,%esp
  8017ab:	ff 75 0c             	pushl  0xc(%ebp)
  8017ae:	6a 3f                	push   $0x3f
  8017b0:	ff 55 08             	call   *0x8(%ebp)
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	eb 0d                	jmp    8017c5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	ff 75 0c             	pushl  0xc(%ebp)
  8017be:	52                   	push   %edx
  8017bf:	ff 55 08             	call   *0x8(%ebp)
  8017c2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017c5:	83 eb 01             	sub    $0x1,%ebx
  8017c8:	eb 1a                	jmp    8017e4 <vprintfmt+0x23f>
  8017ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8017cd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017d6:	eb 0c                	jmp    8017e4 <vprintfmt+0x23f>
  8017d8:	89 75 08             	mov    %esi,0x8(%ebp)
  8017db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017de:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017e4:	83 c7 01             	add    $0x1,%edi
  8017e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017eb:	0f be d0             	movsbl %al,%edx
  8017ee:	85 d2                	test   %edx,%edx
  8017f0:	74 23                	je     801815 <vprintfmt+0x270>
  8017f2:	85 f6                	test   %esi,%esi
  8017f4:	78 a1                	js     801797 <vprintfmt+0x1f2>
  8017f6:	83 ee 01             	sub    $0x1,%esi
  8017f9:	79 9c                	jns    801797 <vprintfmt+0x1f2>
  8017fb:	89 df                	mov    %ebx,%edi
  8017fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801800:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801803:	eb 18                	jmp    80181d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801805:	83 ec 08             	sub    $0x8,%esp
  801808:	53                   	push   %ebx
  801809:	6a 20                	push   $0x20
  80180b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80180d:	83 ef 01             	sub    $0x1,%edi
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	eb 08                	jmp    80181d <vprintfmt+0x278>
  801815:	89 df                	mov    %ebx,%edi
  801817:	8b 75 08             	mov    0x8(%ebp),%esi
  80181a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80181d:	85 ff                	test   %edi,%edi
  80181f:	7f e4                	jg     801805 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801821:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801824:	e9 a2 fd ff ff       	jmp    8015cb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801829:	83 fa 01             	cmp    $0x1,%edx
  80182c:	7e 16                	jle    801844 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80182e:	8b 45 14             	mov    0x14(%ebp),%eax
  801831:	8d 50 08             	lea    0x8(%eax),%edx
  801834:	89 55 14             	mov    %edx,0x14(%ebp)
  801837:	8b 50 04             	mov    0x4(%eax),%edx
  80183a:	8b 00                	mov    (%eax),%eax
  80183c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80183f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801842:	eb 32                	jmp    801876 <vprintfmt+0x2d1>
	else if (lflag)
  801844:	85 d2                	test   %edx,%edx
  801846:	74 18                	je     801860 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801848:	8b 45 14             	mov    0x14(%ebp),%eax
  80184b:	8d 50 04             	lea    0x4(%eax),%edx
  80184e:	89 55 14             	mov    %edx,0x14(%ebp)
  801851:	8b 00                	mov    (%eax),%eax
  801853:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801856:	89 c1                	mov    %eax,%ecx
  801858:	c1 f9 1f             	sar    $0x1f,%ecx
  80185b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80185e:	eb 16                	jmp    801876 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801860:	8b 45 14             	mov    0x14(%ebp),%eax
  801863:	8d 50 04             	lea    0x4(%eax),%edx
  801866:	89 55 14             	mov    %edx,0x14(%ebp)
  801869:	8b 00                	mov    (%eax),%eax
  80186b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80186e:	89 c1                	mov    %eax,%ecx
  801870:	c1 f9 1f             	sar    $0x1f,%ecx
  801873:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801876:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801879:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80187c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801881:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801885:	79 74                	jns    8018fb <vprintfmt+0x356>
				putch('-', putdat);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	53                   	push   %ebx
  80188b:	6a 2d                	push   $0x2d
  80188d:	ff d6                	call   *%esi
				num = -(long long) num;
  80188f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801892:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801895:	f7 d8                	neg    %eax
  801897:	83 d2 00             	adc    $0x0,%edx
  80189a:	f7 da                	neg    %edx
  80189c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80189f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018a4:	eb 55                	jmp    8018fb <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8018a9:	e8 83 fc ff ff       	call   801531 <getuint>
			base = 10;
  8018ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018b3:	eb 46                	jmp    8018fb <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b8:	e8 74 fc ff ff       	call   801531 <getuint>
			base = 8;
  8018bd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018c2:	eb 37                	jmp    8018fb <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	53                   	push   %ebx
  8018c8:	6a 30                	push   $0x30
  8018ca:	ff d6                	call   *%esi
			putch('x', putdat);
  8018cc:	83 c4 08             	add    $0x8,%esp
  8018cf:	53                   	push   %ebx
  8018d0:	6a 78                	push   $0x78
  8018d2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d7:	8d 50 04             	lea    0x4(%eax),%edx
  8018da:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018dd:	8b 00                	mov    (%eax),%eax
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018e4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018e7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018ec:	eb 0d                	jmp    8018fb <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8018f1:	e8 3b fc ff ff       	call   801531 <getuint>
			base = 16;
  8018f6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801902:	57                   	push   %edi
  801903:	ff 75 e0             	pushl  -0x20(%ebp)
  801906:	51                   	push   %ecx
  801907:	52                   	push   %edx
  801908:	50                   	push   %eax
  801909:	89 da                	mov    %ebx,%edx
  80190b:	89 f0                	mov    %esi,%eax
  80190d:	e8 70 fb ff ff       	call   801482 <printnum>
			break;
  801912:	83 c4 20             	add    $0x20,%esp
  801915:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801918:	e9 ae fc ff ff       	jmp    8015cb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	53                   	push   %ebx
  801921:	51                   	push   %ecx
  801922:	ff d6                	call   *%esi
			break;
  801924:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801927:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80192a:	e9 9c fc ff ff       	jmp    8015cb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80192f:	83 ec 08             	sub    $0x8,%esp
  801932:	53                   	push   %ebx
  801933:	6a 25                	push   $0x25
  801935:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801937:	83 c4 10             	add    $0x10,%esp
  80193a:	eb 03                	jmp    80193f <vprintfmt+0x39a>
  80193c:	83 ef 01             	sub    $0x1,%edi
  80193f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801943:	75 f7                	jne    80193c <vprintfmt+0x397>
  801945:	e9 81 fc ff ff       	jmp    8015cb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80194a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194d:	5b                   	pop    %ebx
  80194e:	5e                   	pop    %esi
  80194f:	5f                   	pop    %edi
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	83 ec 18             	sub    $0x18,%esp
  801958:	8b 45 08             	mov    0x8(%ebp),%eax
  80195b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80195e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801961:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801965:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801968:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80196f:	85 c0                	test   %eax,%eax
  801971:	74 26                	je     801999 <vsnprintf+0x47>
  801973:	85 d2                	test   %edx,%edx
  801975:	7e 22                	jle    801999 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801977:	ff 75 14             	pushl  0x14(%ebp)
  80197a:	ff 75 10             	pushl  0x10(%ebp)
  80197d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801980:	50                   	push   %eax
  801981:	68 6b 15 80 00       	push   $0x80156b
  801986:	e8 1a fc ff ff       	call   8015a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80198b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80198e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801991:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	eb 05                	jmp    80199e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801999:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019a9:	50                   	push   %eax
  8019aa:	ff 75 10             	pushl  0x10(%ebp)
  8019ad:	ff 75 0c             	pushl  0xc(%ebp)
  8019b0:	ff 75 08             	pushl  0x8(%ebp)
  8019b3:	e8 9a ff ff ff       	call   801952 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019b8:	c9                   	leave  
  8019b9:	c3                   	ret    

008019ba <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c5:	eb 03                	jmp    8019ca <strlen+0x10>
		n++;
  8019c7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019ce:	75 f7                	jne    8019c7 <strlen+0xd>
		n++;
	return n;
}
  8019d0:	5d                   	pop    %ebp
  8019d1:	c3                   	ret    

008019d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019db:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e0:	eb 03                	jmp    8019e5 <strnlen+0x13>
		n++;
  8019e2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019e5:	39 c2                	cmp    %eax,%edx
  8019e7:	74 08                	je     8019f1 <strnlen+0x1f>
  8019e9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019ed:	75 f3                	jne    8019e2 <strnlen+0x10>
  8019ef:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	53                   	push   %ebx
  8019f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019fd:	89 c2                	mov    %eax,%edx
  8019ff:	83 c2 01             	add    $0x1,%edx
  801a02:	83 c1 01             	add    $0x1,%ecx
  801a05:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a09:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a0c:	84 db                	test   %bl,%bl
  801a0e:	75 ef                	jne    8019ff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a10:	5b                   	pop    %ebx
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	53                   	push   %ebx
  801a17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a1a:	53                   	push   %ebx
  801a1b:	e8 9a ff ff ff       	call   8019ba <strlen>
  801a20:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a23:	ff 75 0c             	pushl  0xc(%ebp)
  801a26:	01 d8                	add    %ebx,%eax
  801a28:	50                   	push   %eax
  801a29:	e8 c5 ff ff ff       	call   8019f3 <strcpy>
	return dst;
}
  801a2e:	89 d8                	mov    %ebx,%eax
  801a30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	56                   	push   %esi
  801a39:	53                   	push   %ebx
  801a3a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a40:	89 f3                	mov    %esi,%ebx
  801a42:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a45:	89 f2                	mov    %esi,%edx
  801a47:	eb 0f                	jmp    801a58 <strncpy+0x23>
		*dst++ = *src;
  801a49:	83 c2 01             	add    $0x1,%edx
  801a4c:	0f b6 01             	movzbl (%ecx),%eax
  801a4f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a52:	80 39 01             	cmpb   $0x1,(%ecx)
  801a55:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a58:	39 da                	cmp    %ebx,%edx
  801a5a:	75 ed                	jne    801a49 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a5c:	89 f0                	mov    %esi,%eax
  801a5e:	5b                   	pop    %ebx
  801a5f:	5e                   	pop    %esi
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    

00801a62 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6d:	8b 55 10             	mov    0x10(%ebp),%edx
  801a70:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a72:	85 d2                	test   %edx,%edx
  801a74:	74 21                	je     801a97 <strlcpy+0x35>
  801a76:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a7a:	89 f2                	mov    %esi,%edx
  801a7c:	eb 09                	jmp    801a87 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a7e:	83 c2 01             	add    $0x1,%edx
  801a81:	83 c1 01             	add    $0x1,%ecx
  801a84:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a87:	39 c2                	cmp    %eax,%edx
  801a89:	74 09                	je     801a94 <strlcpy+0x32>
  801a8b:	0f b6 19             	movzbl (%ecx),%ebx
  801a8e:	84 db                	test   %bl,%bl
  801a90:	75 ec                	jne    801a7e <strlcpy+0x1c>
  801a92:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a94:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a97:	29 f0                	sub    %esi,%eax
}
  801a99:	5b                   	pop    %ebx
  801a9a:	5e                   	pop    %esi
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    

00801a9d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801aa6:	eb 06                	jmp    801aae <strcmp+0x11>
		p++, q++;
  801aa8:	83 c1 01             	add    $0x1,%ecx
  801aab:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801aae:	0f b6 01             	movzbl (%ecx),%eax
  801ab1:	84 c0                	test   %al,%al
  801ab3:	74 04                	je     801ab9 <strcmp+0x1c>
  801ab5:	3a 02                	cmp    (%edx),%al
  801ab7:	74 ef                	je     801aa8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ab9:	0f b6 c0             	movzbl %al,%eax
  801abc:	0f b6 12             	movzbl (%edx),%edx
  801abf:	29 d0                	sub    %edx,%eax
}
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	53                   	push   %ebx
  801ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  801acd:	89 c3                	mov    %eax,%ebx
  801acf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ad2:	eb 06                	jmp    801ada <strncmp+0x17>
		n--, p++, q++;
  801ad4:	83 c0 01             	add    $0x1,%eax
  801ad7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ada:	39 d8                	cmp    %ebx,%eax
  801adc:	74 15                	je     801af3 <strncmp+0x30>
  801ade:	0f b6 08             	movzbl (%eax),%ecx
  801ae1:	84 c9                	test   %cl,%cl
  801ae3:	74 04                	je     801ae9 <strncmp+0x26>
  801ae5:	3a 0a                	cmp    (%edx),%cl
  801ae7:	74 eb                	je     801ad4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ae9:	0f b6 00             	movzbl (%eax),%eax
  801aec:	0f b6 12             	movzbl (%edx),%edx
  801aef:	29 d0                	sub    %edx,%eax
  801af1:	eb 05                	jmp    801af8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801af3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801af8:	5b                   	pop    %ebx
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	8b 45 08             	mov    0x8(%ebp),%eax
  801b01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b05:	eb 07                	jmp    801b0e <strchr+0x13>
		if (*s == c)
  801b07:	38 ca                	cmp    %cl,%dl
  801b09:	74 0f                	je     801b1a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b0b:	83 c0 01             	add    $0x1,%eax
  801b0e:	0f b6 10             	movzbl (%eax),%edx
  801b11:	84 d2                	test   %dl,%dl
  801b13:	75 f2                	jne    801b07 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1a:	5d                   	pop    %ebp
  801b1b:	c3                   	ret    

00801b1c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b26:	eb 03                	jmp    801b2b <strfind+0xf>
  801b28:	83 c0 01             	add    $0x1,%eax
  801b2b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b2e:	38 ca                	cmp    %cl,%dl
  801b30:	74 04                	je     801b36 <strfind+0x1a>
  801b32:	84 d2                	test   %dl,%dl
  801b34:	75 f2                	jne    801b28 <strfind+0xc>
			break;
	return (char *) s;
}
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	57                   	push   %edi
  801b3c:	56                   	push   %esi
  801b3d:	53                   	push   %ebx
  801b3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b41:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b44:	85 c9                	test   %ecx,%ecx
  801b46:	74 36                	je     801b7e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b48:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b4e:	75 28                	jne    801b78 <memset+0x40>
  801b50:	f6 c1 03             	test   $0x3,%cl
  801b53:	75 23                	jne    801b78 <memset+0x40>
		c &= 0xFF;
  801b55:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b59:	89 d3                	mov    %edx,%ebx
  801b5b:	c1 e3 08             	shl    $0x8,%ebx
  801b5e:	89 d6                	mov    %edx,%esi
  801b60:	c1 e6 18             	shl    $0x18,%esi
  801b63:	89 d0                	mov    %edx,%eax
  801b65:	c1 e0 10             	shl    $0x10,%eax
  801b68:	09 f0                	or     %esi,%eax
  801b6a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b6c:	89 d8                	mov    %ebx,%eax
  801b6e:	09 d0                	or     %edx,%eax
  801b70:	c1 e9 02             	shr    $0x2,%ecx
  801b73:	fc                   	cld    
  801b74:	f3 ab                	rep stos %eax,%es:(%edi)
  801b76:	eb 06                	jmp    801b7e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7b:	fc                   	cld    
  801b7c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b7e:	89 f8                	mov    %edi,%eax
  801b80:	5b                   	pop    %ebx
  801b81:	5e                   	pop    %esi
  801b82:	5f                   	pop    %edi
  801b83:	5d                   	pop    %ebp
  801b84:	c3                   	ret    

00801b85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	57                   	push   %edi
  801b89:	56                   	push   %esi
  801b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b93:	39 c6                	cmp    %eax,%esi
  801b95:	73 35                	jae    801bcc <memmove+0x47>
  801b97:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b9a:	39 d0                	cmp    %edx,%eax
  801b9c:	73 2e                	jae    801bcc <memmove+0x47>
		s += n;
		d += n;
  801b9e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ba1:	89 d6                	mov    %edx,%esi
  801ba3:	09 fe                	or     %edi,%esi
  801ba5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bab:	75 13                	jne    801bc0 <memmove+0x3b>
  801bad:	f6 c1 03             	test   $0x3,%cl
  801bb0:	75 0e                	jne    801bc0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bb2:	83 ef 04             	sub    $0x4,%edi
  801bb5:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bb8:	c1 e9 02             	shr    $0x2,%ecx
  801bbb:	fd                   	std    
  801bbc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bbe:	eb 09                	jmp    801bc9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bc0:	83 ef 01             	sub    $0x1,%edi
  801bc3:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bc6:	fd                   	std    
  801bc7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bc9:	fc                   	cld    
  801bca:	eb 1d                	jmp    801be9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bcc:	89 f2                	mov    %esi,%edx
  801bce:	09 c2                	or     %eax,%edx
  801bd0:	f6 c2 03             	test   $0x3,%dl
  801bd3:	75 0f                	jne    801be4 <memmove+0x5f>
  801bd5:	f6 c1 03             	test   $0x3,%cl
  801bd8:	75 0a                	jne    801be4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bda:	c1 e9 02             	shr    $0x2,%ecx
  801bdd:	89 c7                	mov    %eax,%edi
  801bdf:	fc                   	cld    
  801be0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801be2:	eb 05                	jmp    801be9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801be4:	89 c7                	mov    %eax,%edi
  801be6:	fc                   	cld    
  801be7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801be9:	5e                   	pop    %esi
  801bea:	5f                   	pop    %edi
  801beb:	5d                   	pop    %ebp
  801bec:	c3                   	ret    

00801bed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801bf0:	ff 75 10             	pushl  0x10(%ebp)
  801bf3:	ff 75 0c             	pushl  0xc(%ebp)
  801bf6:	ff 75 08             	pushl  0x8(%ebp)
  801bf9:	e8 87 ff ff ff       	call   801b85 <memmove>
}
  801bfe:	c9                   	leave  
  801bff:	c3                   	ret    

00801c00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	8b 45 08             	mov    0x8(%ebp),%eax
  801c08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c0b:	89 c6                	mov    %eax,%esi
  801c0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c10:	eb 1a                	jmp    801c2c <memcmp+0x2c>
		if (*s1 != *s2)
  801c12:	0f b6 08             	movzbl (%eax),%ecx
  801c15:	0f b6 1a             	movzbl (%edx),%ebx
  801c18:	38 d9                	cmp    %bl,%cl
  801c1a:	74 0a                	je     801c26 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c1c:	0f b6 c1             	movzbl %cl,%eax
  801c1f:	0f b6 db             	movzbl %bl,%ebx
  801c22:	29 d8                	sub    %ebx,%eax
  801c24:	eb 0f                	jmp    801c35 <memcmp+0x35>
		s1++, s2++;
  801c26:	83 c0 01             	add    $0x1,%eax
  801c29:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c2c:	39 f0                	cmp    %esi,%eax
  801c2e:	75 e2                	jne    801c12 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c35:	5b                   	pop    %ebx
  801c36:	5e                   	pop    %esi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	53                   	push   %ebx
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c40:	89 c1                	mov    %eax,%ecx
  801c42:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c45:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c49:	eb 0a                	jmp    801c55 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c4b:	0f b6 10             	movzbl (%eax),%edx
  801c4e:	39 da                	cmp    %ebx,%edx
  801c50:	74 07                	je     801c59 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c52:	83 c0 01             	add    $0x1,%eax
  801c55:	39 c8                	cmp    %ecx,%eax
  801c57:	72 f2                	jb     801c4b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c59:	5b                   	pop    %ebx
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	57                   	push   %edi
  801c60:	56                   	push   %esi
  801c61:	53                   	push   %ebx
  801c62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c68:	eb 03                	jmp    801c6d <strtol+0x11>
		s++;
  801c6a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c6d:	0f b6 01             	movzbl (%ecx),%eax
  801c70:	3c 20                	cmp    $0x20,%al
  801c72:	74 f6                	je     801c6a <strtol+0xe>
  801c74:	3c 09                	cmp    $0x9,%al
  801c76:	74 f2                	je     801c6a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c78:	3c 2b                	cmp    $0x2b,%al
  801c7a:	75 0a                	jne    801c86 <strtol+0x2a>
		s++;
  801c7c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c7f:	bf 00 00 00 00       	mov    $0x0,%edi
  801c84:	eb 11                	jmp    801c97 <strtol+0x3b>
  801c86:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c8b:	3c 2d                	cmp    $0x2d,%al
  801c8d:	75 08                	jne    801c97 <strtol+0x3b>
		s++, neg = 1;
  801c8f:	83 c1 01             	add    $0x1,%ecx
  801c92:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c97:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c9d:	75 15                	jne    801cb4 <strtol+0x58>
  801c9f:	80 39 30             	cmpb   $0x30,(%ecx)
  801ca2:	75 10                	jne    801cb4 <strtol+0x58>
  801ca4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ca8:	75 7c                	jne    801d26 <strtol+0xca>
		s += 2, base = 16;
  801caa:	83 c1 02             	add    $0x2,%ecx
  801cad:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cb2:	eb 16                	jmp    801cca <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cb4:	85 db                	test   %ebx,%ebx
  801cb6:	75 12                	jne    801cca <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cb8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cbd:	80 39 30             	cmpb   $0x30,(%ecx)
  801cc0:	75 08                	jne    801cca <strtol+0x6e>
		s++, base = 8;
  801cc2:	83 c1 01             	add    $0x1,%ecx
  801cc5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cd2:	0f b6 11             	movzbl (%ecx),%edx
  801cd5:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cd8:	89 f3                	mov    %esi,%ebx
  801cda:	80 fb 09             	cmp    $0x9,%bl
  801cdd:	77 08                	ja     801ce7 <strtol+0x8b>
			dig = *s - '0';
  801cdf:	0f be d2             	movsbl %dl,%edx
  801ce2:	83 ea 30             	sub    $0x30,%edx
  801ce5:	eb 22                	jmp    801d09 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ce7:	8d 72 9f             	lea    -0x61(%edx),%esi
  801cea:	89 f3                	mov    %esi,%ebx
  801cec:	80 fb 19             	cmp    $0x19,%bl
  801cef:	77 08                	ja     801cf9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801cf1:	0f be d2             	movsbl %dl,%edx
  801cf4:	83 ea 57             	sub    $0x57,%edx
  801cf7:	eb 10                	jmp    801d09 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801cf9:	8d 72 bf             	lea    -0x41(%edx),%esi
  801cfc:	89 f3                	mov    %esi,%ebx
  801cfe:	80 fb 19             	cmp    $0x19,%bl
  801d01:	77 16                	ja     801d19 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d03:	0f be d2             	movsbl %dl,%edx
  801d06:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d09:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d0c:	7d 0b                	jge    801d19 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d0e:	83 c1 01             	add    $0x1,%ecx
  801d11:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d15:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d17:	eb b9                	jmp    801cd2 <strtol+0x76>

	if (endptr)
  801d19:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d1d:	74 0d                	je     801d2c <strtol+0xd0>
		*endptr = (char *) s;
  801d1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d22:	89 0e                	mov    %ecx,(%esi)
  801d24:	eb 06                	jmp    801d2c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d26:	85 db                	test   %ebx,%ebx
  801d28:	74 98                	je     801cc2 <strtol+0x66>
  801d2a:	eb 9e                	jmp    801cca <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d2c:	89 c2                	mov    %eax,%edx
  801d2e:	f7 da                	neg    %edx
  801d30:	85 ff                	test   %edi,%edi
  801d32:	0f 45 c2             	cmovne %edx,%eax
}
  801d35:	5b                   	pop    %ebx
  801d36:	5e                   	pop    %esi
  801d37:	5f                   	pop    %edi
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d40:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d47:	75 2a                	jne    801d73 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d49:	83 ec 04             	sub    $0x4,%esp
  801d4c:	6a 07                	push   $0x7
  801d4e:	68 00 f0 bf ee       	push   $0xeebff000
  801d53:	6a 00                	push   $0x0
  801d55:	e8 23 e4 ff ff       	call   80017d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d5a:	83 c4 10             	add    $0x10,%esp
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	79 12                	jns    801d73 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d61:	50                   	push   %eax
  801d62:	68 80 26 80 00       	push   $0x802680
  801d67:	6a 23                	push   $0x23
  801d69:	68 84 26 80 00       	push   $0x802684
  801d6e:	e8 22 f6 ff ff       	call   801395 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d73:	8b 45 08             	mov    0x8(%ebp),%eax
  801d76:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d7b:	83 ec 08             	sub    $0x8,%esp
  801d7e:	68 a5 1d 80 00       	push   $0x801da5
  801d83:	6a 00                	push   $0x0
  801d85:	e8 3e e5 ff ff       	call   8002c8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	85 c0                	test   %eax,%eax
  801d8f:	79 12                	jns    801da3 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d91:	50                   	push   %eax
  801d92:	68 80 26 80 00       	push   $0x802680
  801d97:	6a 2c                	push   $0x2c
  801d99:	68 84 26 80 00       	push   $0x802684
  801d9e:	e8 f2 f5 ff ff       	call   801395 <_panic>
	}
}
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801da5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801da6:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dab:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dad:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801db0:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801db4:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801db9:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dbd:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dbf:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dc2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dc3:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dc6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dc7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dc8:	c3                   	ret    

00801dc9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	56                   	push   %esi
  801dcd:	53                   	push   %ebx
  801dce:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	75 12                	jne    801ded <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ddb:	83 ec 0c             	sub    $0xc,%esp
  801dde:	68 00 00 c0 ee       	push   $0xeec00000
  801de3:	e8 45 e5 ff ff       	call   80032d <sys_ipc_recv>
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	eb 0c                	jmp    801df9 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801ded:	83 ec 0c             	sub    $0xc,%esp
  801df0:	50                   	push   %eax
  801df1:	e8 37 e5 ff ff       	call   80032d <sys_ipc_recv>
  801df6:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801df9:	85 f6                	test   %esi,%esi
  801dfb:	0f 95 c1             	setne  %cl
  801dfe:	85 db                	test   %ebx,%ebx
  801e00:	0f 95 c2             	setne  %dl
  801e03:	84 d1                	test   %dl,%cl
  801e05:	74 09                	je     801e10 <ipc_recv+0x47>
  801e07:	89 c2                	mov    %eax,%edx
  801e09:	c1 ea 1f             	shr    $0x1f,%edx
  801e0c:	84 d2                	test   %dl,%dl
  801e0e:	75 2d                	jne    801e3d <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e10:	85 f6                	test   %esi,%esi
  801e12:	74 0d                	je     801e21 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e14:	a1 04 40 80 00       	mov    0x804004,%eax
  801e19:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e1f:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e21:	85 db                	test   %ebx,%ebx
  801e23:	74 0d                	je     801e32 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e25:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e30:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e32:	a1 04 40 80 00       	mov    0x804004,%eax
  801e37:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	57                   	push   %edi
  801e48:	56                   	push   %esi
  801e49:	53                   	push   %ebx
  801e4a:	83 ec 0c             	sub    $0xc,%esp
  801e4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e50:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e56:	85 db                	test   %ebx,%ebx
  801e58:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e5d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e60:	ff 75 14             	pushl  0x14(%ebp)
  801e63:	53                   	push   %ebx
  801e64:	56                   	push   %esi
  801e65:	57                   	push   %edi
  801e66:	e8 9f e4 ff ff       	call   80030a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e6b:	89 c2                	mov    %eax,%edx
  801e6d:	c1 ea 1f             	shr    $0x1f,%edx
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	84 d2                	test   %dl,%dl
  801e75:	74 17                	je     801e8e <ipc_send+0x4a>
  801e77:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e7a:	74 12                	je     801e8e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e7c:	50                   	push   %eax
  801e7d:	68 92 26 80 00       	push   $0x802692
  801e82:	6a 47                	push   $0x47
  801e84:	68 a0 26 80 00       	push   $0x8026a0
  801e89:	e8 07 f5 ff ff       	call   801395 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e8e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e91:	75 07                	jne    801e9a <ipc_send+0x56>
			sys_yield();
  801e93:	e8 c6 e2 ff ff       	call   80015e <sys_yield>
  801e98:	eb c6                	jmp    801e60 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e9a:	85 c0                	test   %eax,%eax
  801e9c:	75 c2                	jne    801e60 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea1:	5b                   	pop    %ebx
  801ea2:	5e                   	pop    %esi
  801ea3:	5f                   	pop    %edi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    

00801ea6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eac:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eb1:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801eb7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ebd:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ec3:	39 ca                	cmp    %ecx,%edx
  801ec5:	75 10                	jne    801ed7 <ipc_find_env+0x31>
			return envs[i].env_id;
  801ec7:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801ecd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ed2:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ed5:	eb 0f                	jmp    801ee6 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed7:	83 c0 01             	add    $0x1,%eax
  801eda:	3d 00 04 00 00       	cmp    $0x400,%eax
  801edf:	75 d0                	jne    801eb1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ee1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    

00801ee8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eee:	89 d0                	mov    %edx,%eax
  801ef0:	c1 e8 16             	shr    $0x16,%eax
  801ef3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801efa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eff:	f6 c1 01             	test   $0x1,%cl
  801f02:	74 1d                	je     801f21 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f04:	c1 ea 0c             	shr    $0xc,%edx
  801f07:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f0e:	f6 c2 01             	test   $0x1,%dl
  801f11:	74 0e                	je     801f21 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f13:	c1 ea 0c             	shr    $0xc,%edx
  801f16:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f1d:	ef 
  801f1e:	0f b7 c0             	movzwl %ax,%eax
}
  801f21:	5d                   	pop    %ebp
  801f22:	c3                   	ret    
  801f23:	66 90                	xchg   %ax,%ax
  801f25:	66 90                	xchg   %ax,%ax
  801f27:	66 90                	xchg   %ax,%ax
  801f29:	66 90                	xchg   %ax,%ax
  801f2b:	66 90                	xchg   %ax,%ax
  801f2d:	66 90                	xchg   %ax,%ax
  801f2f:	90                   	nop

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 1c             	sub    $0x1c,%esp
  801f37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f47:	85 f6                	test   %esi,%esi
  801f49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4d:	89 ca                	mov    %ecx,%edx
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	75 3d                	jne    801f90 <__udivdi3+0x60>
  801f53:	39 cf                	cmp    %ecx,%edi
  801f55:	0f 87 c5 00 00 00    	ja     802020 <__udivdi3+0xf0>
  801f5b:	85 ff                	test   %edi,%edi
  801f5d:	89 fd                	mov    %edi,%ebp
  801f5f:	75 0b                	jne    801f6c <__udivdi3+0x3c>
  801f61:	b8 01 00 00 00       	mov    $0x1,%eax
  801f66:	31 d2                	xor    %edx,%edx
  801f68:	f7 f7                	div    %edi
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	89 c8                	mov    %ecx,%eax
  801f6e:	31 d2                	xor    %edx,%edx
  801f70:	f7 f5                	div    %ebp
  801f72:	89 c1                	mov    %eax,%ecx
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	89 cf                	mov    %ecx,%edi
  801f78:	f7 f5                	div    %ebp
  801f7a:	89 c3                	mov    %eax,%ebx
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	89 fa                	mov    %edi,%edx
  801f80:	83 c4 1c             	add    $0x1c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	90                   	nop
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	39 ce                	cmp    %ecx,%esi
  801f92:	77 74                	ja     802008 <__udivdi3+0xd8>
  801f94:	0f bd fe             	bsr    %esi,%edi
  801f97:	83 f7 1f             	xor    $0x1f,%edi
  801f9a:	0f 84 98 00 00 00    	je     802038 <__udivdi3+0x108>
  801fa0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	89 c5                	mov    %eax,%ebp
  801fa9:	29 fb                	sub    %edi,%ebx
  801fab:	d3 e6                	shl    %cl,%esi
  801fad:	89 d9                	mov    %ebx,%ecx
  801faf:	d3 ed                	shr    %cl,%ebp
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	d3 e0                	shl    %cl,%eax
  801fb5:	09 ee                	or     %ebp,%esi
  801fb7:	89 d9                	mov    %ebx,%ecx
  801fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbd:	89 d5                	mov    %edx,%ebp
  801fbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fc3:	d3 ed                	shr    %cl,%ebp
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e2                	shl    %cl,%edx
  801fc9:	89 d9                	mov    %ebx,%ecx
  801fcb:	d3 e8                	shr    %cl,%eax
  801fcd:	09 c2                	or     %eax,%edx
  801fcf:	89 d0                	mov    %edx,%eax
  801fd1:	89 ea                	mov    %ebp,%edx
  801fd3:	f7 f6                	div    %esi
  801fd5:	89 d5                	mov    %edx,%ebp
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	f7 64 24 0c          	mull   0xc(%esp)
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	72 10                	jb     801ff1 <__udivdi3+0xc1>
  801fe1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e6                	shl    %cl,%esi
  801fe9:	39 c6                	cmp    %eax,%esi
  801feb:	73 07                	jae    801ff4 <__udivdi3+0xc4>
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	75 03                	jne    801ff4 <__udivdi3+0xc4>
  801ff1:	83 eb 01             	sub    $0x1,%ebx
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 d8                	mov    %ebx,%eax
  801ff8:	89 fa                	mov    %edi,%edx
  801ffa:	83 c4 1c             	add    $0x1c,%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
  802002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802008:	31 ff                	xor    %edi,%edi
  80200a:	31 db                	xor    %ebx,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 d8                	mov    %ebx,%eax
  802022:	f7 f7                	div    %edi
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 c3                	mov    %eax,%ebx
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	89 fa                	mov    %edi,%edx
  80202c:	83 c4 1c             	add    $0x1c,%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    
  802034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802038:	39 ce                	cmp    %ecx,%esi
  80203a:	72 0c                	jb     802048 <__udivdi3+0x118>
  80203c:	31 db                	xor    %ebx,%ebx
  80203e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802042:	0f 87 34 ff ff ff    	ja     801f7c <__udivdi3+0x4c>
  802048:	bb 01 00 00 00       	mov    $0x1,%ebx
  80204d:	e9 2a ff ff ff       	jmp    801f7c <__udivdi3+0x4c>
  802052:	66 90                	xchg   %ax,%ax
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80206b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80206f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 d2                	test   %edx,%edx
  802079:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f3                	mov    %esi,%ebx
  802083:	89 3c 24             	mov    %edi,(%esp)
  802086:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208a:	75 1c                	jne    8020a8 <__umoddi3+0x48>
  80208c:	39 f7                	cmp    %esi,%edi
  80208e:	76 50                	jbe    8020e0 <__umoddi3+0x80>
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	f7 f7                	div    %edi
  802096:	89 d0                	mov    %edx,%eax
  802098:	31 d2                	xor    %edx,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	89 d0                	mov    %edx,%eax
  8020ac:	77 52                	ja     802100 <__umoddi3+0xa0>
  8020ae:	0f bd ea             	bsr    %edx,%ebp
  8020b1:	83 f5 1f             	xor    $0x1f,%ebp
  8020b4:	75 5a                	jne    802110 <__umoddi3+0xb0>
  8020b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ba:	0f 82 e0 00 00 00    	jb     8021a0 <__umoddi3+0x140>
  8020c0:	39 0c 24             	cmp    %ecx,(%esp)
  8020c3:	0f 86 d7 00 00 00    	jbe    8021a0 <__umoddi3+0x140>
  8020c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020d1:	83 c4 1c             	add    $0x1c,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	85 ff                	test   %edi,%edi
  8020e2:	89 fd                	mov    %edi,%ebp
  8020e4:	75 0b                	jne    8020f1 <__umoddi3+0x91>
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	f7 f7                	div    %edi
  8020ef:	89 c5                	mov    %eax,%ebp
  8020f1:	89 f0                	mov    %esi,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  8020f5:	f7 f5                	div    %ebp
  8020f7:	89 c8                	mov    %ecx,%eax
  8020f9:	f7 f5                	div    %ebp
  8020fb:	89 d0                	mov    %edx,%eax
  8020fd:	eb 99                	jmp    802098 <__umoddi3+0x38>
  8020ff:	90                   	nop
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	83 c4 1c             	add    $0x1c,%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	8b 34 24             	mov    (%esp),%esi
  802113:	bf 20 00 00 00       	mov    $0x20,%edi
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	29 ef                	sub    %ebp,%edi
  80211c:	d3 e0                	shl    %cl,%eax
  80211e:	89 f9                	mov    %edi,%ecx
  802120:	89 f2                	mov    %esi,%edx
  802122:	d3 ea                	shr    %cl,%edx
  802124:	89 e9                	mov    %ebp,%ecx
  802126:	09 c2                	or     %eax,%edx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 14 24             	mov    %edx,(%esp)
  80212d:	89 f2                	mov    %esi,%edx
  80212f:	d3 e2                	shl    %cl,%edx
  802131:	89 f9                	mov    %edi,%ecx
  802133:	89 54 24 04          	mov    %edx,0x4(%esp)
  802137:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	89 c6                	mov    %eax,%esi
  802141:	d3 e3                	shl    %cl,%ebx
  802143:	89 f9                	mov    %edi,%ecx
  802145:	89 d0                	mov    %edx,%eax
  802147:	d3 e8                	shr    %cl,%eax
  802149:	89 e9                	mov    %ebp,%ecx
  80214b:	09 d8                	or     %ebx,%eax
  80214d:	89 d3                	mov    %edx,%ebx
  80214f:	89 f2                	mov    %esi,%edx
  802151:	f7 34 24             	divl   (%esp)
  802154:	89 d6                	mov    %edx,%esi
  802156:	d3 e3                	shl    %cl,%ebx
  802158:	f7 64 24 04          	mull   0x4(%esp)
  80215c:	39 d6                	cmp    %edx,%esi
  80215e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802162:	89 d1                	mov    %edx,%ecx
  802164:	89 c3                	mov    %eax,%ebx
  802166:	72 08                	jb     802170 <__umoddi3+0x110>
  802168:	75 11                	jne    80217b <__umoddi3+0x11b>
  80216a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80216e:	73 0b                	jae    80217b <__umoddi3+0x11b>
  802170:	2b 44 24 04          	sub    0x4(%esp),%eax
  802174:	1b 14 24             	sbb    (%esp),%edx
  802177:	89 d1                	mov    %edx,%ecx
  802179:	89 c3                	mov    %eax,%ebx
  80217b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80217f:	29 da                	sub    %ebx,%edx
  802181:	19 ce                	sbb    %ecx,%esi
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 f0                	mov    %esi,%eax
  802187:	d3 e0                	shl    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	d3 ea                	shr    %cl,%edx
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	d3 ee                	shr    %cl,%esi
  802191:	09 d0                	or     %edx,%eax
  802193:	89 f2                	mov    %esi,%edx
  802195:	83 c4 1c             	add    $0x1c,%esp
  802198:	5b                   	pop    %ebx
  802199:	5e                   	pop    %esi
  80219a:	5f                   	pop    %edi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	29 f9                	sub    %edi,%ecx
  8021a2:	19 d6                	sbb    %edx,%esi
  8021a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ac:	e9 18 ff ff ff       	jmp    8020c9 <__umoddi3+0x69>
