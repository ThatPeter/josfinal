
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
  800044:	e8 89 00 00 00       	call   8000d2 <sys_cputs>
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
  800059:	e8 f2 00 00 00       	call   800150 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	89 c2                	mov    %eax,%edx
  800065:	c1 e2 07             	shl    $0x7,%edx
  800068:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80006f:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 db                	test   %ebx,%ebx
  800076:	7e 07                	jle    80007f <libmain+0x31>
		binaryname = argv[0];
  800078:	8b 06                	mov    (%esi),%eax
  80007a:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	e8 aa ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800089:	e8 2a 00 00 00       	call   8000b8 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80009e:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000a3:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000a5:	e8 a6 00 00 00       	call   800150 <sys_getenvid>
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	50                   	push   %eax
  8000ae:	e8 ec 02 00 00       	call   80039f <sys_thread_free>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000be:	e8 b9 07 00 00       	call   80087c <close_all>
	sys_env_destroy(0);
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	6a 00                	push   $0x0
  8000c8:	e8 42 00 00 00       	call   80010f <sys_env_destroy>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	89 c3                	mov    %eax,%ebx
  8000e5:	89 c7                	mov    %eax,%edi
  8000e7:	89 c6                	mov    %eax,%esi
  8000e9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5f                   	pop    %edi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	57                   	push   %edi
  8000f4:	56                   	push   %esi
  8000f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fb:	b8 01 00 00 00       	mov    $0x1,%eax
  800100:	89 d1                	mov    %edx,%ecx
  800102:	89 d3                	mov    %edx,%ebx
  800104:	89 d7                	mov    %edx,%edi
  800106:	89 d6                	mov    %edx,%esi
  800108:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	57                   	push   %edi
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800118:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011d:	b8 03 00 00 00       	mov    $0x3,%eax
  800122:	8b 55 08             	mov    0x8(%ebp),%edx
  800125:	89 cb                	mov    %ecx,%ebx
  800127:	89 cf                	mov    %ecx,%edi
  800129:	89 ce                	mov    %ecx,%esi
  80012b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80012d:	85 c0                	test   %eax,%eax
  80012f:	7e 17                	jle    800148 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800131:	83 ec 0c             	sub    $0xc,%esp
  800134:	50                   	push   %eax
  800135:	6a 03                	push   $0x3
  800137:	68 d8 21 80 00       	push   $0x8021d8
  80013c:	6a 23                	push   $0x23
  80013e:	68 f5 21 80 00       	push   $0x8021f5
  800143:	e8 53 12 00 00       	call   80139b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	ba 00 00 00 00       	mov    $0x0,%edx
  80015b:	b8 02 00 00 00       	mov    $0x2,%eax
  800160:	89 d1                	mov    %edx,%ecx
  800162:	89 d3                	mov    %edx,%ebx
  800164:	89 d7                	mov    %edx,%edi
  800166:	89 d6                	mov    %edx,%esi
  800168:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <sys_yield>:

void
sys_yield(void)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800175:	ba 00 00 00 00       	mov    $0x0,%edx
  80017a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017f:	89 d1                	mov    %edx,%ecx
  800181:	89 d3                	mov    %edx,%ebx
  800183:	89 d7                	mov    %edx,%edi
  800185:	89 d6                	mov    %edx,%esi
  800187:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800189:	5b                   	pop    %ebx
  80018a:	5e                   	pop    %esi
  80018b:	5f                   	pop    %edi
  80018c:	5d                   	pop    %ebp
  80018d:	c3                   	ret    

0080018e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800197:	be 00 00 00 00       	mov    $0x0,%esi
  80019c:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001aa:	89 f7                	mov    %esi,%edi
  8001ac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ae:	85 c0                	test   %eax,%eax
  8001b0:	7e 17                	jle    8001c9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b2:	83 ec 0c             	sub    $0xc,%esp
  8001b5:	50                   	push   %eax
  8001b6:	6a 04                	push   $0x4
  8001b8:	68 d8 21 80 00       	push   $0x8021d8
  8001bd:	6a 23                	push   $0x23
  8001bf:	68 f5 21 80 00       	push   $0x8021f5
  8001c4:	e8 d2 11 00 00       	call   80139b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    

008001d1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	57                   	push   %edi
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001da:	b8 05 00 00 00       	mov    $0x5,%eax
  8001df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001eb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f0:	85 c0                	test   %eax,%eax
  8001f2:	7e 17                	jle    80020b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f4:	83 ec 0c             	sub    $0xc,%esp
  8001f7:	50                   	push   %eax
  8001f8:	6a 05                	push   $0x5
  8001fa:	68 d8 21 80 00       	push   $0x8021d8
  8001ff:	6a 23                	push   $0x23
  800201:	68 f5 21 80 00       	push   $0x8021f5
  800206:	e8 90 11 00 00       	call   80139b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    

00800213 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	57                   	push   %edi
  800217:	56                   	push   %esi
  800218:	53                   	push   %ebx
  800219:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800221:	b8 06 00 00 00       	mov    $0x6,%eax
  800226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800229:	8b 55 08             	mov    0x8(%ebp),%edx
  80022c:	89 df                	mov    %ebx,%edi
  80022e:	89 de                	mov    %ebx,%esi
  800230:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800232:	85 c0                	test   %eax,%eax
  800234:	7e 17                	jle    80024d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800236:	83 ec 0c             	sub    $0xc,%esp
  800239:	50                   	push   %eax
  80023a:	6a 06                	push   $0x6
  80023c:	68 d8 21 80 00       	push   $0x8021d8
  800241:	6a 23                	push   $0x23
  800243:	68 f5 21 80 00       	push   $0x8021f5
  800248:	e8 4e 11 00 00       	call   80139b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80024d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	57                   	push   %edi
  800259:	56                   	push   %esi
  80025a:	53                   	push   %ebx
  80025b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800263:	b8 08 00 00 00       	mov    $0x8,%eax
  800268:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026b:	8b 55 08             	mov    0x8(%ebp),%edx
  80026e:	89 df                	mov    %ebx,%edi
  800270:	89 de                	mov    %ebx,%esi
  800272:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800274:	85 c0                	test   %eax,%eax
  800276:	7e 17                	jle    80028f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800278:	83 ec 0c             	sub    $0xc,%esp
  80027b:	50                   	push   %eax
  80027c:	6a 08                	push   $0x8
  80027e:	68 d8 21 80 00       	push   $0x8021d8
  800283:	6a 23                	push   $0x23
  800285:	68 f5 21 80 00       	push   $0x8021f5
  80028a:	e8 0c 11 00 00       	call   80139b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	57                   	push   %edi
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a5:	b8 09 00 00 00       	mov    $0x9,%eax
  8002aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	89 df                	mov    %ebx,%edi
  8002b2:	89 de                	mov    %ebx,%esi
  8002b4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	7e 17                	jle    8002d1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ba:	83 ec 0c             	sub    $0xc,%esp
  8002bd:	50                   	push   %eax
  8002be:	6a 09                	push   $0x9
  8002c0:	68 d8 21 80 00       	push   $0x8021d8
  8002c5:	6a 23                	push   $0x23
  8002c7:	68 f5 21 80 00       	push   $0x8021f5
  8002cc:	e8 ca 10 00 00       	call   80139b <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d4:	5b                   	pop    %ebx
  8002d5:	5e                   	pop    %esi
  8002d6:	5f                   	pop    %edi
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	57                   	push   %edi
  8002dd:	56                   	push   %esi
  8002de:	53                   	push   %ebx
  8002df:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f2:	89 df                	mov    %ebx,%edi
  8002f4:	89 de                	mov    %ebx,%esi
  8002f6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	7e 17                	jle    800313 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fc:	83 ec 0c             	sub    $0xc,%esp
  8002ff:	50                   	push   %eax
  800300:	6a 0a                	push   $0xa
  800302:	68 d8 21 80 00       	push   $0x8021d8
  800307:	6a 23                	push   $0x23
  800309:	68 f5 21 80 00       	push   $0x8021f5
  80030e:	e8 88 10 00 00       	call   80139b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800313:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800316:	5b                   	pop    %ebx
  800317:	5e                   	pop    %esi
  800318:	5f                   	pop    %edi
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	57                   	push   %edi
  80031f:	56                   	push   %esi
  800320:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800321:	be 00 00 00 00       	mov    $0x0,%esi
  800326:	b8 0c 00 00 00       	mov    $0xc,%eax
  80032b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800334:	8b 7d 14             	mov    0x14(%ebp),%edi
  800337:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	57                   	push   %edi
  800342:	56                   	push   %esi
  800343:	53                   	push   %ebx
  800344:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800347:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800351:	8b 55 08             	mov    0x8(%ebp),%edx
  800354:	89 cb                	mov    %ecx,%ebx
  800356:	89 cf                	mov    %ecx,%edi
  800358:	89 ce                	mov    %ecx,%esi
  80035a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80035c:	85 c0                	test   %eax,%eax
  80035e:	7e 17                	jle    800377 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800360:	83 ec 0c             	sub    $0xc,%esp
  800363:	50                   	push   %eax
  800364:	6a 0d                	push   $0xd
  800366:	68 d8 21 80 00       	push   $0x8021d8
  80036b:	6a 23                	push   $0x23
  80036d:	68 f5 21 80 00       	push   $0x8021f5
  800372:	e8 24 10 00 00       	call   80139b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800377:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037a:	5b                   	pop    %ebx
  80037b:	5e                   	pop    %esi
  80037c:	5f                   	pop    %edi
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	57                   	push   %edi
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800385:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80038f:	8b 55 08             	mov    0x8(%ebp),%edx
  800392:	89 cb                	mov    %ecx,%ebx
  800394:	89 cf                	mov    %ecx,%edi
  800396:	89 ce                	mov    %ecx,%esi
  800398:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  80039a:	5b                   	pop    %ebx
  80039b:	5e                   	pop    %esi
  80039c:	5f                   	pop    %edi
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003af:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b2:	89 cb                	mov    %ecx,%ebx
  8003b4:	89 cf                	mov    %ecx,%edi
  8003b6:	89 ce                	mov    %ecx,%esi
  8003b8:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	53                   	push   %ebx
  8003c3:	83 ec 04             	sub    $0x4,%esp
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003c9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003cb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003cf:	74 11                	je     8003e2 <pgfault+0x23>
  8003d1:	89 d8                	mov    %ebx,%eax
  8003d3:	c1 e8 0c             	shr    $0xc,%eax
  8003d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003dd:	f6 c4 08             	test   $0x8,%ah
  8003e0:	75 14                	jne    8003f6 <pgfault+0x37>
		panic("faulting access");
  8003e2:	83 ec 04             	sub    $0x4,%esp
  8003e5:	68 03 22 80 00       	push   $0x802203
  8003ea:	6a 1e                	push   $0x1e
  8003ec:	68 13 22 80 00       	push   $0x802213
  8003f1:	e8 a5 0f 00 00       	call   80139b <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003f6:	83 ec 04             	sub    $0x4,%esp
  8003f9:	6a 07                	push   $0x7
  8003fb:	68 00 f0 7f 00       	push   $0x7ff000
  800400:	6a 00                	push   $0x0
  800402:	e8 87 fd ff ff       	call   80018e <sys_page_alloc>
	if (r < 0) {
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	85 c0                	test   %eax,%eax
  80040c:	79 12                	jns    800420 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80040e:	50                   	push   %eax
  80040f:	68 1e 22 80 00       	push   $0x80221e
  800414:	6a 2c                	push   $0x2c
  800416:	68 13 22 80 00       	push   $0x802213
  80041b:	e8 7b 0f 00 00       	call   80139b <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800420:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800426:	83 ec 04             	sub    $0x4,%esp
  800429:	68 00 10 00 00       	push   $0x1000
  80042e:	53                   	push   %ebx
  80042f:	68 00 f0 7f 00       	push   $0x7ff000
  800434:	e8 ba 17 00 00       	call   801bf3 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800439:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800440:	53                   	push   %ebx
  800441:	6a 00                	push   $0x0
  800443:	68 00 f0 7f 00       	push   $0x7ff000
  800448:	6a 00                	push   $0x0
  80044a:	e8 82 fd ff ff       	call   8001d1 <sys_page_map>
	if (r < 0) {
  80044f:	83 c4 20             	add    $0x20,%esp
  800452:	85 c0                	test   %eax,%eax
  800454:	79 12                	jns    800468 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800456:	50                   	push   %eax
  800457:	68 1e 22 80 00       	push   $0x80221e
  80045c:	6a 33                	push   $0x33
  80045e:	68 13 22 80 00       	push   $0x802213
  800463:	e8 33 0f 00 00       	call   80139b <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	68 00 f0 7f 00       	push   $0x7ff000
  800470:	6a 00                	push   $0x0
  800472:	e8 9c fd ff ff       	call   800213 <sys_page_unmap>
	if (r < 0) {
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	85 c0                	test   %eax,%eax
  80047c:	79 12                	jns    800490 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80047e:	50                   	push   %eax
  80047f:	68 1e 22 80 00       	push   $0x80221e
  800484:	6a 37                	push   $0x37
  800486:	68 13 22 80 00       	push   $0x802213
  80048b:	e8 0b 0f 00 00       	call   80139b <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800490:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800493:	c9                   	leave  
  800494:	c3                   	ret    

00800495 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	57                   	push   %edi
  800499:	56                   	push   %esi
  80049a:	53                   	push   %ebx
  80049b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80049e:	68 bf 03 80 00       	push   $0x8003bf
  8004a3:	e8 98 18 00 00       	call   801d40 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004a8:	b8 07 00 00 00       	mov    $0x7,%eax
  8004ad:	cd 30                	int    $0x30
  8004af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	79 17                	jns    8004d0 <fork+0x3b>
		panic("fork fault %e");
  8004b9:	83 ec 04             	sub    $0x4,%esp
  8004bc:	68 37 22 80 00       	push   $0x802237
  8004c1:	68 84 00 00 00       	push   $0x84
  8004c6:	68 13 22 80 00       	push   $0x802213
  8004cb:	e8 cb 0e 00 00       	call   80139b <_panic>
  8004d0:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004d6:	75 25                	jne    8004fd <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004d8:	e8 73 fc ff ff       	call   800150 <sys_getenvid>
  8004dd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004e2:	89 c2                	mov    %eax,%edx
  8004e4:	c1 e2 07             	shl    $0x7,%edx
  8004e7:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8004ee:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f8:	e9 61 01 00 00       	jmp    80065e <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004fd:	83 ec 04             	sub    $0x4,%esp
  800500:	6a 07                	push   $0x7
  800502:	68 00 f0 bf ee       	push   $0xeebff000
  800507:	ff 75 e4             	pushl  -0x1c(%ebp)
  80050a:	e8 7f fc ff ff       	call   80018e <sys_page_alloc>
  80050f:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800512:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800517:	89 d8                	mov    %ebx,%eax
  800519:	c1 e8 16             	shr    $0x16,%eax
  80051c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800523:	a8 01                	test   $0x1,%al
  800525:	0f 84 fc 00 00 00    	je     800627 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80052b:	89 d8                	mov    %ebx,%eax
  80052d:	c1 e8 0c             	shr    $0xc,%eax
  800530:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800537:	f6 c2 01             	test   $0x1,%dl
  80053a:	0f 84 e7 00 00 00    	je     800627 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800540:	89 c6                	mov    %eax,%esi
  800542:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800545:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80054c:	f6 c6 04             	test   $0x4,%dh
  80054f:	74 39                	je     80058a <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800551:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800558:	83 ec 0c             	sub    $0xc,%esp
  80055b:	25 07 0e 00 00       	and    $0xe07,%eax
  800560:	50                   	push   %eax
  800561:	56                   	push   %esi
  800562:	57                   	push   %edi
  800563:	56                   	push   %esi
  800564:	6a 00                	push   $0x0
  800566:	e8 66 fc ff ff       	call   8001d1 <sys_page_map>
		if (r < 0) {
  80056b:	83 c4 20             	add    $0x20,%esp
  80056e:	85 c0                	test   %eax,%eax
  800570:	0f 89 b1 00 00 00    	jns    800627 <fork+0x192>
		    	panic("sys page map fault %e");
  800576:	83 ec 04             	sub    $0x4,%esp
  800579:	68 45 22 80 00       	push   $0x802245
  80057e:	6a 54                	push   $0x54
  800580:	68 13 22 80 00       	push   $0x802213
  800585:	e8 11 0e 00 00       	call   80139b <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80058a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800591:	f6 c2 02             	test   $0x2,%dl
  800594:	75 0c                	jne    8005a2 <fork+0x10d>
  800596:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80059d:	f6 c4 08             	test   $0x8,%ah
  8005a0:	74 5b                	je     8005fd <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005a2:	83 ec 0c             	sub    $0xc,%esp
  8005a5:	68 05 08 00 00       	push   $0x805
  8005aa:	56                   	push   %esi
  8005ab:	57                   	push   %edi
  8005ac:	56                   	push   %esi
  8005ad:	6a 00                	push   $0x0
  8005af:	e8 1d fc ff ff       	call   8001d1 <sys_page_map>
		if (r < 0) {
  8005b4:	83 c4 20             	add    $0x20,%esp
  8005b7:	85 c0                	test   %eax,%eax
  8005b9:	79 14                	jns    8005cf <fork+0x13a>
		    	panic("sys page map fault %e");
  8005bb:	83 ec 04             	sub    $0x4,%esp
  8005be:	68 45 22 80 00       	push   $0x802245
  8005c3:	6a 5b                	push   $0x5b
  8005c5:	68 13 22 80 00       	push   $0x802213
  8005ca:	e8 cc 0d 00 00       	call   80139b <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	68 05 08 00 00       	push   $0x805
  8005d7:	56                   	push   %esi
  8005d8:	6a 00                	push   $0x0
  8005da:	56                   	push   %esi
  8005db:	6a 00                	push   $0x0
  8005dd:	e8 ef fb ff ff       	call   8001d1 <sys_page_map>
		if (r < 0) {
  8005e2:	83 c4 20             	add    $0x20,%esp
  8005e5:	85 c0                	test   %eax,%eax
  8005e7:	79 3e                	jns    800627 <fork+0x192>
		    	panic("sys page map fault %e");
  8005e9:	83 ec 04             	sub    $0x4,%esp
  8005ec:	68 45 22 80 00       	push   $0x802245
  8005f1:	6a 5f                	push   $0x5f
  8005f3:	68 13 22 80 00       	push   $0x802213
  8005f8:	e8 9e 0d 00 00       	call   80139b <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005fd:	83 ec 0c             	sub    $0xc,%esp
  800600:	6a 05                	push   $0x5
  800602:	56                   	push   %esi
  800603:	57                   	push   %edi
  800604:	56                   	push   %esi
  800605:	6a 00                	push   $0x0
  800607:	e8 c5 fb ff ff       	call   8001d1 <sys_page_map>
		if (r < 0) {
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	85 c0                	test   %eax,%eax
  800611:	79 14                	jns    800627 <fork+0x192>
		    	panic("sys page map fault %e");
  800613:	83 ec 04             	sub    $0x4,%esp
  800616:	68 45 22 80 00       	push   $0x802245
  80061b:	6a 64                	push   $0x64
  80061d:	68 13 22 80 00       	push   $0x802213
  800622:	e8 74 0d 00 00       	call   80139b <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800627:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80062d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800633:	0f 85 de fe ff ff    	jne    800517 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800639:	a1 04 40 80 00       	mov    0x804004,%eax
  80063e:	8b 40 70             	mov    0x70(%eax),%eax
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	50                   	push   %eax
  800645:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800648:	57                   	push   %edi
  800649:	e8 8b fc ff ff       	call   8002d9 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80064e:	83 c4 08             	add    $0x8,%esp
  800651:	6a 02                	push   $0x2
  800653:	57                   	push   %edi
  800654:	e8 fc fb ff ff       	call   800255 <sys_env_set_status>
	
	return envid;
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80065e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800661:	5b                   	pop    %ebx
  800662:	5e                   	pop    %esi
  800663:	5f                   	pop    %edi
  800664:	5d                   	pop    %ebp
  800665:	c3                   	ret    

00800666 <sfork>:

envid_t
sfork(void)
{
  800666:	55                   	push   %ebp
  800667:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800669:	b8 00 00 00 00       	mov    $0x0,%eax
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    

00800670 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	56                   	push   %esi
  800674:	53                   	push   %ebx
  800675:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800678:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	68 5c 22 80 00       	push   $0x80225c
  800687:	e8 e8 0d 00 00       	call   801474 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80068c:	c7 04 24 98 00 80 00 	movl   $0x800098,(%esp)
  800693:	e8 e7 fc ff ff       	call   80037f <sys_thread_create>
  800698:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80069a:	83 c4 08             	add    $0x8,%esp
  80069d:	53                   	push   %ebx
  80069e:	68 5c 22 80 00       	push   $0x80225c
  8006a3:	e8 cc 0d 00 00       	call   801474 <cprintf>
	return id;
	//return 0;
}
  8006a8:	89 f0                	mov    %esi,%eax
  8006aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006ad:	5b                   	pop    %ebx
  8006ae:	5e                   	pop    %esi
  8006af:	5d                   	pop    %ebp
  8006b0:	c3                   	ret    

008006b1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8006bc:	c1 e8 0c             	shr    $0xc,%eax
}
  8006bf:	5d                   	pop    %ebp
  8006c0:	c3                   	ret    

008006c1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	05 00 00 00 30       	add    $0x30000000,%eax
  8006cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006d1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006de:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006e3:	89 c2                	mov    %eax,%edx
  8006e5:	c1 ea 16             	shr    $0x16,%edx
  8006e8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006ef:	f6 c2 01             	test   $0x1,%dl
  8006f2:	74 11                	je     800705 <fd_alloc+0x2d>
  8006f4:	89 c2                	mov    %eax,%edx
  8006f6:	c1 ea 0c             	shr    $0xc,%edx
  8006f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800700:	f6 c2 01             	test   $0x1,%dl
  800703:	75 09                	jne    80070e <fd_alloc+0x36>
			*fd_store = fd;
  800705:	89 01                	mov    %eax,(%ecx)
			return 0;
  800707:	b8 00 00 00 00       	mov    $0x0,%eax
  80070c:	eb 17                	jmp    800725 <fd_alloc+0x4d>
  80070e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800713:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800718:	75 c9                	jne    8006e3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80071a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800720:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80072d:	83 f8 1f             	cmp    $0x1f,%eax
  800730:	77 36                	ja     800768 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800732:	c1 e0 0c             	shl    $0xc,%eax
  800735:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80073a:	89 c2                	mov    %eax,%edx
  80073c:	c1 ea 16             	shr    $0x16,%edx
  80073f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800746:	f6 c2 01             	test   $0x1,%dl
  800749:	74 24                	je     80076f <fd_lookup+0x48>
  80074b:	89 c2                	mov    %eax,%edx
  80074d:	c1 ea 0c             	shr    $0xc,%edx
  800750:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800757:	f6 c2 01             	test   $0x1,%dl
  80075a:	74 1a                	je     800776 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80075c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075f:	89 02                	mov    %eax,(%edx)
	return 0;
  800761:	b8 00 00 00 00       	mov    $0x0,%eax
  800766:	eb 13                	jmp    80077b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800768:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076d:	eb 0c                	jmp    80077b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80076f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800774:	eb 05                	jmp    80077b <fd_lookup+0x54>
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800786:	ba fc 22 80 00       	mov    $0x8022fc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80078b:	eb 13                	jmp    8007a0 <dev_lookup+0x23>
  80078d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800790:	39 08                	cmp    %ecx,(%eax)
  800792:	75 0c                	jne    8007a0 <dev_lookup+0x23>
			*dev = devtab[i];
  800794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800797:	89 01                	mov    %eax,(%ecx)
			return 0;
  800799:	b8 00 00 00 00       	mov    $0x0,%eax
  80079e:	eb 2e                	jmp    8007ce <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007a0:	8b 02                	mov    (%edx),%eax
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	75 e7                	jne    80078d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8007ab:	8b 40 54             	mov    0x54(%eax),%eax
  8007ae:	83 ec 04             	sub    $0x4,%esp
  8007b1:	51                   	push   %ecx
  8007b2:	50                   	push   %eax
  8007b3:	68 80 22 80 00       	push   $0x802280
  8007b8:	e8 b7 0c 00 00       	call   801474 <cprintf>
	*dev = 0;
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	56                   	push   %esi
  8007d4:	53                   	push   %ebx
  8007d5:	83 ec 10             	sub    $0x10,%esp
  8007d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e1:	50                   	push   %eax
  8007e2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007e8:	c1 e8 0c             	shr    $0xc,%eax
  8007eb:	50                   	push   %eax
  8007ec:	e8 36 ff ff ff       	call   800727 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	78 05                	js     8007fd <fd_close+0x2d>
	    || fd != fd2)
  8007f8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007fb:	74 0c                	je     800809 <fd_close+0x39>
		return (must_exist ? r : 0);
  8007fd:	84 db                	test   %bl,%bl
  8007ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800804:	0f 44 c2             	cmove  %edx,%eax
  800807:	eb 41                	jmp    80084a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800809:	83 ec 08             	sub    $0x8,%esp
  80080c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080f:	50                   	push   %eax
  800810:	ff 36                	pushl  (%esi)
  800812:	e8 66 ff ff ff       	call   80077d <dev_lookup>
  800817:	89 c3                	mov    %eax,%ebx
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	85 c0                	test   %eax,%eax
  80081e:	78 1a                	js     80083a <fd_close+0x6a>
		if (dev->dev_close)
  800820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800823:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800826:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80082b:	85 c0                	test   %eax,%eax
  80082d:	74 0b                	je     80083a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80082f:	83 ec 0c             	sub    $0xc,%esp
  800832:	56                   	push   %esi
  800833:	ff d0                	call   *%eax
  800835:	89 c3                	mov    %eax,%ebx
  800837:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	56                   	push   %esi
  80083e:	6a 00                	push   $0x0
  800840:	e8 ce f9 ff ff       	call   800213 <sys_page_unmap>
	return r;
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	89 d8                	mov    %ebx,%eax
}
  80084a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800857:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085a:	50                   	push   %eax
  80085b:	ff 75 08             	pushl  0x8(%ebp)
  80085e:	e8 c4 fe ff ff       	call   800727 <fd_lookup>
  800863:	83 c4 08             	add    $0x8,%esp
  800866:	85 c0                	test   %eax,%eax
  800868:	78 10                	js     80087a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	6a 01                	push   $0x1
  80086f:	ff 75 f4             	pushl  -0xc(%ebp)
  800872:	e8 59 ff ff ff       	call   8007d0 <fd_close>
  800877:	83 c4 10             	add    $0x10,%esp
}
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <close_all>:

void
close_all(void)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	53                   	push   %ebx
  800880:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800883:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800888:	83 ec 0c             	sub    $0xc,%esp
  80088b:	53                   	push   %ebx
  80088c:	e8 c0 ff ff ff       	call   800851 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800891:	83 c3 01             	add    $0x1,%ebx
  800894:	83 c4 10             	add    $0x10,%esp
  800897:	83 fb 20             	cmp    $0x20,%ebx
  80089a:	75 ec                	jne    800888 <close_all+0xc>
		close(i);
}
  80089c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    

008008a1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	57                   	push   %edi
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	83 ec 2c             	sub    $0x2c,%esp
  8008aa:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008b0:	50                   	push   %eax
  8008b1:	ff 75 08             	pushl  0x8(%ebp)
  8008b4:	e8 6e fe ff ff       	call   800727 <fd_lookup>
  8008b9:	83 c4 08             	add    $0x8,%esp
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	0f 88 c1 00 00 00    	js     800985 <dup+0xe4>
		return r;
	close(newfdnum);
  8008c4:	83 ec 0c             	sub    $0xc,%esp
  8008c7:	56                   	push   %esi
  8008c8:	e8 84 ff ff ff       	call   800851 <close>

	newfd = INDEX2FD(newfdnum);
  8008cd:	89 f3                	mov    %esi,%ebx
  8008cf:	c1 e3 0c             	shl    $0xc,%ebx
  8008d2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008d8:	83 c4 04             	add    $0x4,%esp
  8008db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008de:	e8 de fd ff ff       	call   8006c1 <fd2data>
  8008e3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008e5:	89 1c 24             	mov    %ebx,(%esp)
  8008e8:	e8 d4 fd ff ff       	call   8006c1 <fd2data>
  8008ed:	83 c4 10             	add    $0x10,%esp
  8008f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008f3:	89 f8                	mov    %edi,%eax
  8008f5:	c1 e8 16             	shr    $0x16,%eax
  8008f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008ff:	a8 01                	test   $0x1,%al
  800901:	74 37                	je     80093a <dup+0x99>
  800903:	89 f8                	mov    %edi,%eax
  800905:	c1 e8 0c             	shr    $0xc,%eax
  800908:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80090f:	f6 c2 01             	test   $0x1,%dl
  800912:	74 26                	je     80093a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800914:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80091b:	83 ec 0c             	sub    $0xc,%esp
  80091e:	25 07 0e 00 00       	and    $0xe07,%eax
  800923:	50                   	push   %eax
  800924:	ff 75 d4             	pushl  -0x2c(%ebp)
  800927:	6a 00                	push   $0x0
  800929:	57                   	push   %edi
  80092a:	6a 00                	push   $0x0
  80092c:	e8 a0 f8 ff ff       	call   8001d1 <sys_page_map>
  800931:	89 c7                	mov    %eax,%edi
  800933:	83 c4 20             	add    $0x20,%esp
  800936:	85 c0                	test   %eax,%eax
  800938:	78 2e                	js     800968 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80093a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80093d:	89 d0                	mov    %edx,%eax
  80093f:	c1 e8 0c             	shr    $0xc,%eax
  800942:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800949:	83 ec 0c             	sub    $0xc,%esp
  80094c:	25 07 0e 00 00       	and    $0xe07,%eax
  800951:	50                   	push   %eax
  800952:	53                   	push   %ebx
  800953:	6a 00                	push   $0x0
  800955:	52                   	push   %edx
  800956:	6a 00                	push   $0x0
  800958:	e8 74 f8 ff ff       	call   8001d1 <sys_page_map>
  80095d:	89 c7                	mov    %eax,%edi
  80095f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800962:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800964:	85 ff                	test   %edi,%edi
  800966:	79 1d                	jns    800985 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800968:	83 ec 08             	sub    $0x8,%esp
  80096b:	53                   	push   %ebx
  80096c:	6a 00                	push   $0x0
  80096e:	e8 a0 f8 ff ff       	call   800213 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800973:	83 c4 08             	add    $0x8,%esp
  800976:	ff 75 d4             	pushl  -0x2c(%ebp)
  800979:	6a 00                	push   $0x0
  80097b:	e8 93 f8 ff ff       	call   800213 <sys_page_unmap>
	return r;
  800980:	83 c4 10             	add    $0x10,%esp
  800983:	89 f8                	mov    %edi,%eax
}
  800985:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5f                   	pop    %edi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 14             	sub    $0x14,%esp
  800994:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800997:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80099a:	50                   	push   %eax
  80099b:	53                   	push   %ebx
  80099c:	e8 86 fd ff ff       	call   800727 <fd_lookup>
  8009a1:	83 c4 08             	add    $0x8,%esp
  8009a4:	89 c2                	mov    %eax,%edx
  8009a6:	85 c0                	test   %eax,%eax
  8009a8:	78 6d                	js     800a17 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009aa:	83 ec 08             	sub    $0x8,%esp
  8009ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009b0:	50                   	push   %eax
  8009b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b4:	ff 30                	pushl  (%eax)
  8009b6:	e8 c2 fd ff ff       	call   80077d <dev_lookup>
  8009bb:	83 c4 10             	add    $0x10,%esp
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 4c                	js     800a0e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009c5:	8b 42 08             	mov    0x8(%edx),%eax
  8009c8:	83 e0 03             	and    $0x3,%eax
  8009cb:	83 f8 01             	cmp    $0x1,%eax
  8009ce:	75 21                	jne    8009f1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8009d5:	8b 40 54             	mov    0x54(%eax),%eax
  8009d8:	83 ec 04             	sub    $0x4,%esp
  8009db:	53                   	push   %ebx
  8009dc:	50                   	push   %eax
  8009dd:	68 c1 22 80 00       	push   $0x8022c1
  8009e2:	e8 8d 0a 00 00       	call   801474 <cprintf>
		return -E_INVAL;
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009ef:	eb 26                	jmp    800a17 <read+0x8a>
	}
	if (!dev->dev_read)
  8009f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f4:	8b 40 08             	mov    0x8(%eax),%eax
  8009f7:	85 c0                	test   %eax,%eax
  8009f9:	74 17                	je     800a12 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009fb:	83 ec 04             	sub    $0x4,%esp
  8009fe:	ff 75 10             	pushl  0x10(%ebp)
  800a01:	ff 75 0c             	pushl  0xc(%ebp)
  800a04:	52                   	push   %edx
  800a05:	ff d0                	call   *%eax
  800a07:	89 c2                	mov    %eax,%edx
  800a09:	83 c4 10             	add    $0x10,%esp
  800a0c:	eb 09                	jmp    800a17 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a0e:	89 c2                	mov    %eax,%edx
  800a10:	eb 05                	jmp    800a17 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a12:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a17:	89 d0                	mov    %edx,%eax
  800a19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	83 ec 0c             	sub    $0xc,%esp
  800a27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a32:	eb 21                	jmp    800a55 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a34:	83 ec 04             	sub    $0x4,%esp
  800a37:	89 f0                	mov    %esi,%eax
  800a39:	29 d8                	sub    %ebx,%eax
  800a3b:	50                   	push   %eax
  800a3c:	89 d8                	mov    %ebx,%eax
  800a3e:	03 45 0c             	add    0xc(%ebp),%eax
  800a41:	50                   	push   %eax
  800a42:	57                   	push   %edi
  800a43:	e8 45 ff ff ff       	call   80098d <read>
		if (m < 0)
  800a48:	83 c4 10             	add    $0x10,%esp
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	78 10                	js     800a5f <readn+0x41>
			return m;
		if (m == 0)
  800a4f:	85 c0                	test   %eax,%eax
  800a51:	74 0a                	je     800a5d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a53:	01 c3                	add    %eax,%ebx
  800a55:	39 f3                	cmp    %esi,%ebx
  800a57:	72 db                	jb     800a34 <readn+0x16>
  800a59:	89 d8                	mov    %ebx,%eax
  800a5b:	eb 02                	jmp    800a5f <readn+0x41>
  800a5d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	53                   	push   %ebx
  800a6b:	83 ec 14             	sub    $0x14,%esp
  800a6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a74:	50                   	push   %eax
  800a75:	53                   	push   %ebx
  800a76:	e8 ac fc ff ff       	call   800727 <fd_lookup>
  800a7b:	83 c4 08             	add    $0x8,%esp
  800a7e:	89 c2                	mov    %eax,%edx
  800a80:	85 c0                	test   %eax,%eax
  800a82:	78 68                	js     800aec <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a84:	83 ec 08             	sub    $0x8,%esp
  800a87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a8a:	50                   	push   %eax
  800a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8e:	ff 30                	pushl  (%eax)
  800a90:	e8 e8 fc ff ff       	call   80077d <dev_lookup>
  800a95:	83 c4 10             	add    $0x10,%esp
  800a98:	85 c0                	test   %eax,%eax
  800a9a:	78 47                	js     800ae3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a9f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800aa3:	75 21                	jne    800ac6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800aa5:	a1 04 40 80 00       	mov    0x804004,%eax
  800aaa:	8b 40 54             	mov    0x54(%eax),%eax
  800aad:	83 ec 04             	sub    $0x4,%esp
  800ab0:	53                   	push   %ebx
  800ab1:	50                   	push   %eax
  800ab2:	68 dd 22 80 00       	push   $0x8022dd
  800ab7:	e8 b8 09 00 00       	call   801474 <cprintf>
		return -E_INVAL;
  800abc:	83 c4 10             	add    $0x10,%esp
  800abf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ac4:	eb 26                	jmp    800aec <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac9:	8b 52 0c             	mov    0xc(%edx),%edx
  800acc:	85 d2                	test   %edx,%edx
  800ace:	74 17                	je     800ae7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ad0:	83 ec 04             	sub    $0x4,%esp
  800ad3:	ff 75 10             	pushl  0x10(%ebp)
  800ad6:	ff 75 0c             	pushl  0xc(%ebp)
  800ad9:	50                   	push   %eax
  800ada:	ff d2                	call   *%edx
  800adc:	89 c2                	mov    %eax,%edx
  800ade:	83 c4 10             	add    $0x10,%esp
  800ae1:	eb 09                	jmp    800aec <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ae3:	89 c2                	mov    %eax,%edx
  800ae5:	eb 05                	jmp    800aec <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ae7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800aec:	89 d0                	mov    %edx,%eax
  800aee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af1:	c9                   	leave  
  800af2:	c3                   	ret    

00800af3 <seek>:

int
seek(int fdnum, off_t offset)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800af9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800afc:	50                   	push   %eax
  800afd:	ff 75 08             	pushl  0x8(%ebp)
  800b00:	e8 22 fc ff ff       	call   800727 <fd_lookup>
  800b05:	83 c4 08             	add    $0x8,%esp
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	78 0e                	js     800b1a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b12:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	53                   	push   %ebx
  800b20:	83 ec 14             	sub    $0x14,%esp
  800b23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b26:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b29:	50                   	push   %eax
  800b2a:	53                   	push   %ebx
  800b2b:	e8 f7 fb ff ff       	call   800727 <fd_lookup>
  800b30:	83 c4 08             	add    $0x8,%esp
  800b33:	89 c2                	mov    %eax,%edx
  800b35:	85 c0                	test   %eax,%eax
  800b37:	78 65                	js     800b9e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b39:	83 ec 08             	sub    $0x8,%esp
  800b3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b3f:	50                   	push   %eax
  800b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b43:	ff 30                	pushl  (%eax)
  800b45:	e8 33 fc ff ff       	call   80077d <dev_lookup>
  800b4a:	83 c4 10             	add    $0x10,%esp
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	78 44                	js     800b95 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b54:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b58:	75 21                	jne    800b7b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b5a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b5f:	8b 40 54             	mov    0x54(%eax),%eax
  800b62:	83 ec 04             	sub    $0x4,%esp
  800b65:	53                   	push   %ebx
  800b66:	50                   	push   %eax
  800b67:	68 a0 22 80 00       	push   $0x8022a0
  800b6c:	e8 03 09 00 00       	call   801474 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b79:	eb 23                	jmp    800b9e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7e:	8b 52 18             	mov    0x18(%edx),%edx
  800b81:	85 d2                	test   %edx,%edx
  800b83:	74 14                	je     800b99 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b85:	83 ec 08             	sub    $0x8,%esp
  800b88:	ff 75 0c             	pushl  0xc(%ebp)
  800b8b:	50                   	push   %eax
  800b8c:	ff d2                	call   *%edx
  800b8e:	89 c2                	mov    %eax,%edx
  800b90:	83 c4 10             	add    $0x10,%esp
  800b93:	eb 09                	jmp    800b9e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b95:	89 c2                	mov    %eax,%edx
  800b97:	eb 05                	jmp    800b9e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b99:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b9e:	89 d0                	mov    %edx,%eax
  800ba0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 14             	sub    $0x14,%esp
  800bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800baf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bb2:	50                   	push   %eax
  800bb3:	ff 75 08             	pushl  0x8(%ebp)
  800bb6:	e8 6c fb ff ff       	call   800727 <fd_lookup>
  800bbb:	83 c4 08             	add    $0x8,%esp
  800bbe:	89 c2                	mov    %eax,%edx
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	78 58                	js     800c1c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bc4:	83 ec 08             	sub    $0x8,%esp
  800bc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bca:	50                   	push   %eax
  800bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bce:	ff 30                	pushl  (%eax)
  800bd0:	e8 a8 fb ff ff       	call   80077d <dev_lookup>
  800bd5:	83 c4 10             	add    $0x10,%esp
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	78 37                	js     800c13 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bdf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800be3:	74 32                	je     800c17 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800be5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800be8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800bef:	00 00 00 
	stat->st_isdir = 0;
  800bf2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bf9:	00 00 00 
	stat->st_dev = dev;
  800bfc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c02:	83 ec 08             	sub    $0x8,%esp
  800c05:	53                   	push   %ebx
  800c06:	ff 75 f0             	pushl  -0x10(%ebp)
  800c09:	ff 50 14             	call   *0x14(%eax)
  800c0c:	89 c2                	mov    %eax,%edx
  800c0e:	83 c4 10             	add    $0x10,%esp
  800c11:	eb 09                	jmp    800c1c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c13:	89 c2                	mov    %eax,%edx
  800c15:	eb 05                	jmp    800c1c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c17:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c1c:	89 d0                	mov    %edx,%eax
  800c1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c21:	c9                   	leave  
  800c22:	c3                   	ret    

00800c23 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c28:	83 ec 08             	sub    $0x8,%esp
  800c2b:	6a 00                	push   $0x0
  800c2d:	ff 75 08             	pushl  0x8(%ebp)
  800c30:	e8 e3 01 00 00       	call   800e18 <open>
  800c35:	89 c3                	mov    %eax,%ebx
  800c37:	83 c4 10             	add    $0x10,%esp
  800c3a:	85 c0                	test   %eax,%eax
  800c3c:	78 1b                	js     800c59 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c3e:	83 ec 08             	sub    $0x8,%esp
  800c41:	ff 75 0c             	pushl  0xc(%ebp)
  800c44:	50                   	push   %eax
  800c45:	e8 5b ff ff ff       	call   800ba5 <fstat>
  800c4a:	89 c6                	mov    %eax,%esi
	close(fd);
  800c4c:	89 1c 24             	mov    %ebx,(%esp)
  800c4f:	e8 fd fb ff ff       	call   800851 <close>
	return r;
  800c54:	83 c4 10             	add    $0x10,%esp
  800c57:	89 f0                	mov    %esi,%eax
}
  800c59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	89 c6                	mov    %eax,%esi
  800c67:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c69:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c70:	75 12                	jne    800c84 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c72:	83 ec 0c             	sub    $0xc,%esp
  800c75:	6a 01                	push   $0x1
  800c77:	e8 2d 12 00 00       	call   801ea9 <ipc_find_env>
  800c7c:	a3 00 40 80 00       	mov    %eax,0x804000
  800c81:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c84:	6a 07                	push   $0x7
  800c86:	68 00 50 80 00       	push   $0x805000
  800c8b:	56                   	push   %esi
  800c8c:	ff 35 00 40 80 00    	pushl  0x804000
  800c92:	e8 b0 11 00 00       	call   801e47 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c97:	83 c4 0c             	add    $0xc,%esp
  800c9a:	6a 00                	push   $0x0
  800c9c:	53                   	push   %ebx
  800c9d:	6a 00                	push   $0x0
  800c9f:	e8 2b 11 00 00       	call   801dcf <ipc_recv>
}
  800ca4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	8b 40 0c             	mov    0xc(%eax),%eax
  800cb7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc9:	b8 02 00 00 00       	mov    $0x2,%eax
  800cce:	e8 8d ff ff ff       	call   800c60 <fsipc>
}
  800cd3:	c9                   	leave  
  800cd4:	c3                   	ret    

00800cd5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cde:	8b 40 0c             	mov    0xc(%eax),%eax
  800ce1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ce6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ceb:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf0:	e8 6b ff ff ff       	call   800c60 <fsipc>
}
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 04             	sub    $0x4,%esp
  800cfe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	8b 40 0c             	mov    0xc(%eax),%eax
  800d07:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d11:	b8 05 00 00 00       	mov    $0x5,%eax
  800d16:	e8 45 ff ff ff       	call   800c60 <fsipc>
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	78 2c                	js     800d4b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d1f:	83 ec 08             	sub    $0x8,%esp
  800d22:	68 00 50 80 00       	push   $0x805000
  800d27:	53                   	push   %ebx
  800d28:	e8 cc 0c 00 00       	call   8019f9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d2d:	a1 80 50 80 00       	mov    0x805080,%eax
  800d32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d38:	a1 84 50 80 00       	mov    0x805084,%eax
  800d3d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d43:	83 c4 10             	add    $0x10,%esp
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 52 0c             	mov    0xc(%edx),%edx
  800d5f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d65:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d6a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d6f:	0f 47 c2             	cmova  %edx,%eax
  800d72:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d77:	50                   	push   %eax
  800d78:	ff 75 0c             	pushl  0xc(%ebp)
  800d7b:	68 08 50 80 00       	push   $0x805008
  800d80:	e8 06 0e 00 00       	call   801b8b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d85:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8f:	e8 cc fe ff ff       	call   800c60 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d94:	c9                   	leave  
  800d95:	c3                   	ret    

00800d96 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800da1:	8b 40 0c             	mov    0xc(%eax),%eax
  800da4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800da9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800daf:	ba 00 00 00 00       	mov    $0x0,%edx
  800db4:	b8 03 00 00 00       	mov    $0x3,%eax
  800db9:	e8 a2 fe ff ff       	call   800c60 <fsipc>
  800dbe:	89 c3                	mov    %eax,%ebx
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	78 4b                	js     800e0f <devfile_read+0x79>
		return r;
	assert(r <= n);
  800dc4:	39 c6                	cmp    %eax,%esi
  800dc6:	73 16                	jae    800dde <devfile_read+0x48>
  800dc8:	68 0c 23 80 00       	push   $0x80230c
  800dcd:	68 13 23 80 00       	push   $0x802313
  800dd2:	6a 7c                	push   $0x7c
  800dd4:	68 28 23 80 00       	push   $0x802328
  800dd9:	e8 bd 05 00 00       	call   80139b <_panic>
	assert(r <= PGSIZE);
  800dde:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800de3:	7e 16                	jle    800dfb <devfile_read+0x65>
  800de5:	68 33 23 80 00       	push   $0x802333
  800dea:	68 13 23 80 00       	push   $0x802313
  800def:	6a 7d                	push   $0x7d
  800df1:	68 28 23 80 00       	push   $0x802328
  800df6:	e8 a0 05 00 00       	call   80139b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800dfb:	83 ec 04             	sub    $0x4,%esp
  800dfe:	50                   	push   %eax
  800dff:	68 00 50 80 00       	push   $0x805000
  800e04:	ff 75 0c             	pushl  0xc(%ebp)
  800e07:	e8 7f 0d 00 00       	call   801b8b <memmove>
	return r;
  800e0c:	83 c4 10             	add    $0x10,%esp
}
  800e0f:	89 d8                	mov    %ebx,%eax
  800e11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 20             	sub    $0x20,%esp
  800e1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e22:	53                   	push   %ebx
  800e23:	e8 98 0b 00 00       	call   8019c0 <strlen>
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e30:	7f 67                	jg     800e99 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e38:	50                   	push   %eax
  800e39:	e8 9a f8 ff ff       	call   8006d8 <fd_alloc>
  800e3e:	83 c4 10             	add    $0x10,%esp
		return r;
  800e41:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	78 57                	js     800e9e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e47:	83 ec 08             	sub    $0x8,%esp
  800e4a:	53                   	push   %ebx
  800e4b:	68 00 50 80 00       	push   $0x805000
  800e50:	e8 a4 0b 00 00       	call   8019f9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e58:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e60:	b8 01 00 00 00       	mov    $0x1,%eax
  800e65:	e8 f6 fd ff ff       	call   800c60 <fsipc>
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	79 14                	jns    800e87 <open+0x6f>
		fd_close(fd, 0);
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	6a 00                	push   $0x0
  800e78:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7b:	e8 50 f9 ff ff       	call   8007d0 <fd_close>
		return r;
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	89 da                	mov    %ebx,%edx
  800e85:	eb 17                	jmp    800e9e <open+0x86>
	}

	return fd2num(fd);
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8d:	e8 1f f8 ff ff       	call   8006b1 <fd2num>
  800e92:	89 c2                	mov    %eax,%edx
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	eb 05                	jmp    800e9e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e99:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e9e:	89 d0                	mov    %edx,%eax
  800ea0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800eab:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb5:	e8 a6 fd ff ff       	call   800c60 <fsipc>
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	56                   	push   %esi
  800ec0:	53                   	push   %ebx
  800ec1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ec4:	83 ec 0c             	sub    $0xc,%esp
  800ec7:	ff 75 08             	pushl  0x8(%ebp)
  800eca:	e8 f2 f7 ff ff       	call   8006c1 <fd2data>
  800ecf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ed1:	83 c4 08             	add    $0x8,%esp
  800ed4:	68 3f 23 80 00       	push   $0x80233f
  800ed9:	53                   	push   %ebx
  800eda:	e8 1a 0b 00 00       	call   8019f9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800edf:	8b 46 04             	mov    0x4(%esi),%eax
  800ee2:	2b 06                	sub    (%esi),%eax
  800ee4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800eea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ef1:	00 00 00 
	stat->st_dev = &devpipe;
  800ef4:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800efb:	30 80 00 
	return 0;
}
  800efe:	b8 00 00 00 00       	mov    $0x0,%eax
  800f03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    

00800f0a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	53                   	push   %ebx
  800f0e:	83 ec 0c             	sub    $0xc,%esp
  800f11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f14:	53                   	push   %ebx
  800f15:	6a 00                	push   $0x0
  800f17:	e8 f7 f2 ff ff       	call   800213 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f1c:	89 1c 24             	mov    %ebx,(%esp)
  800f1f:	e8 9d f7 ff ff       	call   8006c1 <fd2data>
  800f24:	83 c4 08             	add    $0x8,%esp
  800f27:	50                   	push   %eax
  800f28:	6a 00                	push   $0x0
  800f2a:	e8 e4 f2 ff ff       	call   800213 <sys_page_unmap>
}
  800f2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	56                   	push   %esi
  800f39:	53                   	push   %ebx
  800f3a:	83 ec 1c             	sub    $0x1c,%esp
  800f3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f40:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f42:	a1 04 40 80 00       	mov    0x804004,%eax
  800f47:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	ff 75 e0             	pushl  -0x20(%ebp)
  800f50:	e8 94 0f 00 00       	call   801ee9 <pageref>
  800f55:	89 c3                	mov    %eax,%ebx
  800f57:	89 3c 24             	mov    %edi,(%esp)
  800f5a:	e8 8a 0f 00 00       	call   801ee9 <pageref>
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	39 c3                	cmp    %eax,%ebx
  800f64:	0f 94 c1             	sete   %cl
  800f67:	0f b6 c9             	movzbl %cl,%ecx
  800f6a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f6d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f73:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  800f76:	39 ce                	cmp    %ecx,%esi
  800f78:	74 1b                	je     800f95 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800f7a:	39 c3                	cmp    %eax,%ebx
  800f7c:	75 c4                	jne    800f42 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f7e:	8b 42 64             	mov    0x64(%edx),%eax
  800f81:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f84:	50                   	push   %eax
  800f85:	56                   	push   %esi
  800f86:	68 46 23 80 00       	push   $0x802346
  800f8b:	e8 e4 04 00 00       	call   801474 <cprintf>
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	eb ad                	jmp    800f42 <_pipeisclosed+0xe>
	}
}
  800f95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9b:	5b                   	pop    %ebx
  800f9c:	5e                   	pop    %esi
  800f9d:	5f                   	pop    %edi
  800f9e:	5d                   	pop    %ebp
  800f9f:	c3                   	ret    

00800fa0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	53                   	push   %ebx
  800fa6:	83 ec 28             	sub    $0x28,%esp
  800fa9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fac:	56                   	push   %esi
  800fad:	e8 0f f7 ff ff       	call   8006c1 <fd2data>
  800fb2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	bf 00 00 00 00       	mov    $0x0,%edi
  800fbc:	eb 4b                	jmp    801009 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fbe:	89 da                	mov    %ebx,%edx
  800fc0:	89 f0                	mov    %esi,%eax
  800fc2:	e8 6d ff ff ff       	call   800f34 <_pipeisclosed>
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	75 48                	jne    801013 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fcb:	e8 9f f1 ff ff       	call   80016f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fd0:	8b 43 04             	mov    0x4(%ebx),%eax
  800fd3:	8b 0b                	mov    (%ebx),%ecx
  800fd5:	8d 51 20             	lea    0x20(%ecx),%edx
  800fd8:	39 d0                	cmp    %edx,%eax
  800fda:	73 e2                	jae    800fbe <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fe3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fe6:	89 c2                	mov    %eax,%edx
  800fe8:	c1 fa 1f             	sar    $0x1f,%edx
  800feb:	89 d1                	mov    %edx,%ecx
  800fed:	c1 e9 1b             	shr    $0x1b,%ecx
  800ff0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ff3:	83 e2 1f             	and    $0x1f,%edx
  800ff6:	29 ca                	sub    %ecx,%edx
  800ff8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ffc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801000:	83 c0 01             	add    $0x1,%eax
  801003:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801006:	83 c7 01             	add    $0x1,%edi
  801009:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80100c:	75 c2                	jne    800fd0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80100e:	8b 45 10             	mov    0x10(%ebp),%eax
  801011:	eb 05                	jmp    801018 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801013:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801018:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101b:	5b                   	pop    %ebx
  80101c:	5e                   	pop    %esi
  80101d:	5f                   	pop    %edi
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	53                   	push   %ebx
  801026:	83 ec 18             	sub    $0x18,%esp
  801029:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80102c:	57                   	push   %edi
  80102d:	e8 8f f6 ff ff       	call   8006c1 <fd2data>
  801032:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103c:	eb 3d                	jmp    80107b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80103e:	85 db                	test   %ebx,%ebx
  801040:	74 04                	je     801046 <devpipe_read+0x26>
				return i;
  801042:	89 d8                	mov    %ebx,%eax
  801044:	eb 44                	jmp    80108a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801046:	89 f2                	mov    %esi,%edx
  801048:	89 f8                	mov    %edi,%eax
  80104a:	e8 e5 fe ff ff       	call   800f34 <_pipeisclosed>
  80104f:	85 c0                	test   %eax,%eax
  801051:	75 32                	jne    801085 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801053:	e8 17 f1 ff ff       	call   80016f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801058:	8b 06                	mov    (%esi),%eax
  80105a:	3b 46 04             	cmp    0x4(%esi),%eax
  80105d:	74 df                	je     80103e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80105f:	99                   	cltd   
  801060:	c1 ea 1b             	shr    $0x1b,%edx
  801063:	01 d0                	add    %edx,%eax
  801065:	83 e0 1f             	and    $0x1f,%eax
  801068:	29 d0                	sub    %edx,%eax
  80106a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80106f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801072:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801075:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801078:	83 c3 01             	add    $0x1,%ebx
  80107b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80107e:	75 d8                	jne    801058 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801080:	8b 45 10             	mov    0x10(%ebp),%eax
  801083:	eb 05                	jmp    80108a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801085:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80108a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108d:	5b                   	pop    %ebx
  80108e:	5e                   	pop    %esi
  80108f:	5f                   	pop    %edi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	56                   	push   %esi
  801096:	53                   	push   %ebx
  801097:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80109a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80109d:	50                   	push   %eax
  80109e:	e8 35 f6 ff ff       	call   8006d8 <fd_alloc>
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	89 c2                	mov    %eax,%edx
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	0f 88 2c 01 00 00    	js     8011dc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010b0:	83 ec 04             	sub    $0x4,%esp
  8010b3:	68 07 04 00 00       	push   $0x407
  8010b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8010bb:	6a 00                	push   $0x0
  8010bd:	e8 cc f0 ff ff       	call   80018e <sys_page_alloc>
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	89 c2                	mov    %eax,%edx
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	0f 88 0d 01 00 00    	js     8011dc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d5:	50                   	push   %eax
  8010d6:	e8 fd f5 ff ff       	call   8006d8 <fd_alloc>
  8010db:	89 c3                	mov    %eax,%ebx
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	0f 88 e2 00 00 00    	js     8011ca <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010e8:	83 ec 04             	sub    $0x4,%esp
  8010eb:	68 07 04 00 00       	push   $0x407
  8010f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8010f3:	6a 00                	push   $0x0
  8010f5:	e8 94 f0 ff ff       	call   80018e <sys_page_alloc>
  8010fa:	89 c3                	mov    %eax,%ebx
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	0f 88 c3 00 00 00    	js     8011ca <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801107:	83 ec 0c             	sub    $0xc,%esp
  80110a:	ff 75 f4             	pushl  -0xc(%ebp)
  80110d:	e8 af f5 ff ff       	call   8006c1 <fd2data>
  801112:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801114:	83 c4 0c             	add    $0xc,%esp
  801117:	68 07 04 00 00       	push   $0x407
  80111c:	50                   	push   %eax
  80111d:	6a 00                	push   $0x0
  80111f:	e8 6a f0 ff ff       	call   80018e <sys_page_alloc>
  801124:	89 c3                	mov    %eax,%ebx
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	85 c0                	test   %eax,%eax
  80112b:	0f 88 89 00 00 00    	js     8011ba <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	ff 75 f0             	pushl  -0x10(%ebp)
  801137:	e8 85 f5 ff ff       	call   8006c1 <fd2data>
  80113c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801143:	50                   	push   %eax
  801144:	6a 00                	push   $0x0
  801146:	56                   	push   %esi
  801147:	6a 00                	push   $0x0
  801149:	e8 83 f0 ff ff       	call   8001d1 <sys_page_map>
  80114e:	89 c3                	mov    %eax,%ebx
  801150:	83 c4 20             	add    $0x20,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	78 55                	js     8011ac <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801157:	8b 15 24 30 80 00    	mov    0x803024,%edx
  80115d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801160:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801165:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80116c:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801172:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801175:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801177:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	ff 75 f4             	pushl  -0xc(%ebp)
  801187:	e8 25 f5 ff ff       	call   8006b1 <fd2num>
  80118c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801191:	83 c4 04             	add    $0x4,%esp
  801194:	ff 75 f0             	pushl  -0x10(%ebp)
  801197:	e8 15 f5 ff ff       	call   8006b1 <fd2num>
  80119c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011aa:	eb 30                	jmp    8011dc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	56                   	push   %esi
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 5c f0 ff ff       	call   800213 <sys_page_unmap>
  8011b7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8011c0:	6a 00                	push   $0x0
  8011c2:	e8 4c f0 ff ff       	call   800213 <sys_page_unmap>
  8011c7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d0:	6a 00                	push   $0x0
  8011d2:	e8 3c f0 ff ff       	call   800213 <sys_page_unmap>
  8011d7:	83 c4 10             	add    $0x10,%esp
  8011da:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011dc:	89 d0                	mov    %edx,%eax
  8011de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e1:	5b                   	pop    %ebx
  8011e2:	5e                   	pop    %esi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ee:	50                   	push   %eax
  8011ef:	ff 75 08             	pushl  0x8(%ebp)
  8011f2:	e8 30 f5 ff ff       	call   800727 <fd_lookup>
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	78 18                	js     801216 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	ff 75 f4             	pushl  -0xc(%ebp)
  801204:	e8 b8 f4 ff ff       	call   8006c1 <fd2data>
	return _pipeisclosed(fd, p);
  801209:	89 c2                	mov    %eax,%edx
  80120b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120e:	e8 21 fd ff ff       	call   800f34 <_pipeisclosed>
  801213:	83 c4 10             	add    $0x10,%esp
}
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80121b:	b8 00 00 00 00       	mov    $0x0,%eax
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801228:	68 5e 23 80 00       	push   $0x80235e
  80122d:	ff 75 0c             	pushl  0xc(%ebp)
  801230:	e8 c4 07 00 00       	call   8019f9 <strcpy>
	return 0;
}
  801235:	b8 00 00 00 00       	mov    $0x0,%eax
  80123a:	c9                   	leave  
  80123b:	c3                   	ret    

0080123c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	57                   	push   %edi
  801240:	56                   	push   %esi
  801241:	53                   	push   %ebx
  801242:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801248:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80124d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801253:	eb 2d                	jmp    801282 <devcons_write+0x46>
		m = n - tot;
  801255:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801258:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80125a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80125d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801262:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801265:	83 ec 04             	sub    $0x4,%esp
  801268:	53                   	push   %ebx
  801269:	03 45 0c             	add    0xc(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	57                   	push   %edi
  80126e:	e8 18 09 00 00       	call   801b8b <memmove>
		sys_cputs(buf, m);
  801273:	83 c4 08             	add    $0x8,%esp
  801276:	53                   	push   %ebx
  801277:	57                   	push   %edi
  801278:	e8 55 ee ff ff       	call   8000d2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80127d:	01 de                	add    %ebx,%esi
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	89 f0                	mov    %esi,%eax
  801284:	3b 75 10             	cmp    0x10(%ebp),%esi
  801287:	72 cc                	jb     801255 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801289:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128c:	5b                   	pop    %ebx
  80128d:	5e                   	pop    %esi
  80128e:	5f                   	pop    %edi
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    

00801291 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80129c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012a0:	74 2a                	je     8012cc <devcons_read+0x3b>
  8012a2:	eb 05                	jmp    8012a9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012a4:	e8 c6 ee ff ff       	call   80016f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012a9:	e8 42 ee ff ff       	call   8000f0 <sys_cgetc>
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	74 f2                	je     8012a4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012b2:	85 c0                	test   %eax,%eax
  8012b4:	78 16                	js     8012cc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012b6:	83 f8 04             	cmp    $0x4,%eax
  8012b9:	74 0c                	je     8012c7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012be:	88 02                	mov    %al,(%edx)
	return 1;
  8012c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c5:	eb 05                	jmp    8012cc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012cc:	c9                   	leave  
  8012cd:	c3                   	ret    

008012ce <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012da:	6a 01                	push   $0x1
  8012dc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	e8 ed ed ff ff       	call   8000d2 <sys_cputs>
}
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <getchar>:

int
getchar(void)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012f0:	6a 01                	push   $0x1
  8012f2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012f5:	50                   	push   %eax
  8012f6:	6a 00                	push   $0x0
  8012f8:	e8 90 f6 ff ff       	call   80098d <read>
	if (r < 0)
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 0f                	js     801313 <getchar+0x29>
		return r;
	if (r < 1)
  801304:	85 c0                	test   %eax,%eax
  801306:	7e 06                	jle    80130e <getchar+0x24>
		return -E_EOF;
	return c;
  801308:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80130c:	eb 05                	jmp    801313 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80130e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801313:	c9                   	leave  
  801314:	c3                   	ret    

00801315 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131e:	50                   	push   %eax
  80131f:	ff 75 08             	pushl  0x8(%ebp)
  801322:	e8 00 f4 ff ff       	call   800727 <fd_lookup>
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	78 11                	js     80133f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80132e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801331:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801337:	39 10                	cmp    %edx,(%eax)
  801339:	0f 94 c0             	sete   %al
  80133c:	0f b6 c0             	movzbl %al,%eax
}
  80133f:	c9                   	leave  
  801340:	c3                   	ret    

00801341 <opencons>:

int
opencons(void)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801347:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134a:	50                   	push   %eax
  80134b:	e8 88 f3 ff ff       	call   8006d8 <fd_alloc>
  801350:	83 c4 10             	add    $0x10,%esp
		return r;
  801353:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801355:	85 c0                	test   %eax,%eax
  801357:	78 3e                	js     801397 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801359:	83 ec 04             	sub    $0x4,%esp
  80135c:	68 07 04 00 00       	push   $0x407
  801361:	ff 75 f4             	pushl  -0xc(%ebp)
  801364:	6a 00                	push   $0x0
  801366:	e8 23 ee ff ff       	call   80018e <sys_page_alloc>
  80136b:	83 c4 10             	add    $0x10,%esp
		return r;
  80136e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801370:	85 c0                	test   %eax,%eax
  801372:	78 23                	js     801397 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801374:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80137a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80137f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801382:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801389:	83 ec 0c             	sub    $0xc,%esp
  80138c:	50                   	push   %eax
  80138d:	e8 1f f3 ff ff       	call   8006b1 <fd2num>
  801392:	89 c2                	mov    %eax,%edx
  801394:	83 c4 10             	add    $0x10,%esp
}
  801397:	89 d0                	mov    %edx,%eax
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	56                   	push   %esi
  80139f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013a0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013a3:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8013a9:	e8 a2 ed ff ff       	call   800150 <sys_getenvid>
  8013ae:	83 ec 0c             	sub    $0xc,%esp
  8013b1:	ff 75 0c             	pushl  0xc(%ebp)
  8013b4:	ff 75 08             	pushl  0x8(%ebp)
  8013b7:	56                   	push   %esi
  8013b8:	50                   	push   %eax
  8013b9:	68 6c 23 80 00       	push   $0x80236c
  8013be:	e8 b1 00 00 00       	call   801474 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013c3:	83 c4 18             	add    $0x18,%esp
  8013c6:	53                   	push   %ebx
  8013c7:	ff 75 10             	pushl  0x10(%ebp)
  8013ca:	e8 54 00 00 00       	call   801423 <vcprintf>
	cprintf("\n");
  8013cf:	c7 04 24 57 23 80 00 	movl   $0x802357,(%esp)
  8013d6:	e8 99 00 00 00       	call   801474 <cprintf>
  8013db:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013de:	cc                   	int3   
  8013df:	eb fd                	jmp    8013de <_panic+0x43>

008013e1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	53                   	push   %ebx
  8013e5:	83 ec 04             	sub    $0x4,%esp
  8013e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013eb:	8b 13                	mov    (%ebx),%edx
  8013ed:	8d 42 01             	lea    0x1(%edx),%eax
  8013f0:	89 03                	mov    %eax,(%ebx)
  8013f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013f9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013fe:	75 1a                	jne    80141a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	68 ff 00 00 00       	push   $0xff
  801408:	8d 43 08             	lea    0x8(%ebx),%eax
  80140b:	50                   	push   %eax
  80140c:	e8 c1 ec ff ff       	call   8000d2 <sys_cputs>
		b->idx = 0;
  801411:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801417:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80141a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80141e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80142c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801433:	00 00 00 
	b.cnt = 0;
  801436:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80143d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801440:	ff 75 0c             	pushl  0xc(%ebp)
  801443:	ff 75 08             	pushl  0x8(%ebp)
  801446:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	68 e1 13 80 00       	push   $0x8013e1
  801452:	e8 54 01 00 00       	call   8015ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801457:	83 c4 08             	add    $0x8,%esp
  80145a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801460:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	e8 66 ec ff ff       	call   8000d2 <sys_cputs>

	return b.cnt;
}
  80146c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80147a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80147d:	50                   	push   %eax
  80147e:	ff 75 08             	pushl  0x8(%ebp)
  801481:	e8 9d ff ff ff       	call   801423 <vcprintf>
	va_end(ap);

	return cnt;
}
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	57                   	push   %edi
  80148c:	56                   	push   %esi
  80148d:	53                   	push   %ebx
  80148e:	83 ec 1c             	sub    $0x1c,%esp
  801491:	89 c7                	mov    %eax,%edi
  801493:	89 d6                	mov    %edx,%esi
  801495:	8b 45 08             	mov    0x8(%ebp),%eax
  801498:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014ac:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014af:	39 d3                	cmp    %edx,%ebx
  8014b1:	72 05                	jb     8014b8 <printnum+0x30>
  8014b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014b6:	77 45                	ja     8014fd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014b8:	83 ec 0c             	sub    $0xc,%esp
  8014bb:	ff 75 18             	pushl  0x18(%ebp)
  8014be:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014c4:	53                   	push   %ebx
  8014c5:	ff 75 10             	pushl  0x10(%ebp)
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8014d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8014d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8014d7:	e8 54 0a 00 00       	call   801f30 <__udivdi3>
  8014dc:	83 c4 18             	add    $0x18,%esp
  8014df:	52                   	push   %edx
  8014e0:	50                   	push   %eax
  8014e1:	89 f2                	mov    %esi,%edx
  8014e3:	89 f8                	mov    %edi,%eax
  8014e5:	e8 9e ff ff ff       	call   801488 <printnum>
  8014ea:	83 c4 20             	add    $0x20,%esp
  8014ed:	eb 18                	jmp    801507 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014ef:	83 ec 08             	sub    $0x8,%esp
  8014f2:	56                   	push   %esi
  8014f3:	ff 75 18             	pushl  0x18(%ebp)
  8014f6:	ff d7                	call   *%edi
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	eb 03                	jmp    801500 <printnum+0x78>
  8014fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801500:	83 eb 01             	sub    $0x1,%ebx
  801503:	85 db                	test   %ebx,%ebx
  801505:	7f e8                	jg     8014ef <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801507:	83 ec 08             	sub    $0x8,%esp
  80150a:	56                   	push   %esi
  80150b:	83 ec 04             	sub    $0x4,%esp
  80150e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801511:	ff 75 e0             	pushl  -0x20(%ebp)
  801514:	ff 75 dc             	pushl  -0x24(%ebp)
  801517:	ff 75 d8             	pushl  -0x28(%ebp)
  80151a:	e8 41 0b 00 00       	call   802060 <__umoddi3>
  80151f:	83 c4 14             	add    $0x14,%esp
  801522:	0f be 80 8f 23 80 00 	movsbl 0x80238f(%eax),%eax
  801529:	50                   	push   %eax
  80152a:	ff d7                	call   *%edi
}
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801532:	5b                   	pop    %ebx
  801533:	5e                   	pop    %esi
  801534:	5f                   	pop    %edi
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    

00801537 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80153a:	83 fa 01             	cmp    $0x1,%edx
  80153d:	7e 0e                	jle    80154d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80153f:	8b 10                	mov    (%eax),%edx
  801541:	8d 4a 08             	lea    0x8(%edx),%ecx
  801544:	89 08                	mov    %ecx,(%eax)
  801546:	8b 02                	mov    (%edx),%eax
  801548:	8b 52 04             	mov    0x4(%edx),%edx
  80154b:	eb 22                	jmp    80156f <getuint+0x38>
	else if (lflag)
  80154d:	85 d2                	test   %edx,%edx
  80154f:	74 10                	je     801561 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801551:	8b 10                	mov    (%eax),%edx
  801553:	8d 4a 04             	lea    0x4(%edx),%ecx
  801556:	89 08                	mov    %ecx,(%eax)
  801558:	8b 02                	mov    (%edx),%eax
  80155a:	ba 00 00 00 00       	mov    $0x0,%edx
  80155f:	eb 0e                	jmp    80156f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801561:	8b 10                	mov    (%eax),%edx
  801563:	8d 4a 04             	lea    0x4(%edx),%ecx
  801566:	89 08                	mov    %ecx,(%eax)
  801568:	8b 02                	mov    (%edx),%eax
  80156a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    

00801571 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801577:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80157b:	8b 10                	mov    (%eax),%edx
  80157d:	3b 50 04             	cmp    0x4(%eax),%edx
  801580:	73 0a                	jae    80158c <sprintputch+0x1b>
		*b->buf++ = ch;
  801582:	8d 4a 01             	lea    0x1(%edx),%ecx
  801585:	89 08                	mov    %ecx,(%eax)
  801587:	8b 45 08             	mov    0x8(%ebp),%eax
  80158a:	88 02                	mov    %al,(%edx)
}
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801594:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801597:	50                   	push   %eax
  801598:	ff 75 10             	pushl  0x10(%ebp)
  80159b:	ff 75 0c             	pushl  0xc(%ebp)
  80159e:	ff 75 08             	pushl  0x8(%ebp)
  8015a1:	e8 05 00 00 00       	call   8015ab <vprintfmt>
	va_end(ap);
}
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	57                   	push   %edi
  8015af:	56                   	push   %esi
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 2c             	sub    $0x2c,%esp
  8015b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015ba:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015bd:	eb 12                	jmp    8015d1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	0f 84 89 03 00 00    	je     801950 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	50                   	push   %eax
  8015cc:	ff d6                	call   *%esi
  8015ce:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015d1:	83 c7 01             	add    $0x1,%edi
  8015d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015d8:	83 f8 25             	cmp    $0x25,%eax
  8015db:	75 e2                	jne    8015bf <vprintfmt+0x14>
  8015dd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015e1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015e8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015ef:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fb:	eb 07                	jmp    801604 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801600:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801604:	8d 47 01             	lea    0x1(%edi),%eax
  801607:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80160a:	0f b6 07             	movzbl (%edi),%eax
  80160d:	0f b6 c8             	movzbl %al,%ecx
  801610:	83 e8 23             	sub    $0x23,%eax
  801613:	3c 55                	cmp    $0x55,%al
  801615:	0f 87 1a 03 00 00    	ja     801935 <vprintfmt+0x38a>
  80161b:	0f b6 c0             	movzbl %al,%eax
  80161e:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  801625:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801628:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80162c:	eb d6                	jmp    801604 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80162e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801631:	b8 00 00 00 00       	mov    $0x0,%eax
  801636:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801639:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80163c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801640:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801643:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801646:	83 fa 09             	cmp    $0x9,%edx
  801649:	77 39                	ja     801684 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80164b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80164e:	eb e9                	jmp    801639 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801650:	8b 45 14             	mov    0x14(%ebp),%eax
  801653:	8d 48 04             	lea    0x4(%eax),%ecx
  801656:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801659:	8b 00                	mov    (%eax),%eax
  80165b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80165e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801661:	eb 27                	jmp    80168a <vprintfmt+0xdf>
  801663:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801666:	85 c0                	test   %eax,%eax
  801668:	b9 00 00 00 00       	mov    $0x0,%ecx
  80166d:	0f 49 c8             	cmovns %eax,%ecx
  801670:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801676:	eb 8c                	jmp    801604 <vprintfmt+0x59>
  801678:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80167b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801682:	eb 80                	jmp    801604 <vprintfmt+0x59>
  801684:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801687:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80168a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80168e:	0f 89 70 ff ff ff    	jns    801604 <vprintfmt+0x59>
				width = precision, precision = -1;
  801694:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801697:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80169a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016a1:	e9 5e ff ff ff       	jmp    801604 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016a6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016ac:	e9 53 ff ff ff       	jmp    801604 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b4:	8d 50 04             	lea    0x4(%eax),%edx
  8016b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ba:	83 ec 08             	sub    $0x8,%esp
  8016bd:	53                   	push   %ebx
  8016be:	ff 30                	pushl  (%eax)
  8016c0:	ff d6                	call   *%esi
			break;
  8016c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016c8:	e9 04 ff ff ff       	jmp    8015d1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d0:	8d 50 04             	lea    0x4(%eax),%edx
  8016d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d6:	8b 00                	mov    (%eax),%eax
  8016d8:	99                   	cltd   
  8016d9:	31 d0                	xor    %edx,%eax
  8016db:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016dd:	83 f8 0f             	cmp    $0xf,%eax
  8016e0:	7f 0b                	jg     8016ed <vprintfmt+0x142>
  8016e2:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8016e9:	85 d2                	test   %edx,%edx
  8016eb:	75 18                	jne    801705 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016ed:	50                   	push   %eax
  8016ee:	68 a7 23 80 00       	push   $0x8023a7
  8016f3:	53                   	push   %ebx
  8016f4:	56                   	push   %esi
  8016f5:	e8 94 fe ff ff       	call   80158e <printfmt>
  8016fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801700:	e9 cc fe ff ff       	jmp    8015d1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801705:	52                   	push   %edx
  801706:	68 25 23 80 00       	push   $0x802325
  80170b:	53                   	push   %ebx
  80170c:	56                   	push   %esi
  80170d:	e8 7c fe ff ff       	call   80158e <printfmt>
  801712:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801715:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801718:	e9 b4 fe ff ff       	jmp    8015d1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80171d:	8b 45 14             	mov    0x14(%ebp),%eax
  801720:	8d 50 04             	lea    0x4(%eax),%edx
  801723:	89 55 14             	mov    %edx,0x14(%ebp)
  801726:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801728:	85 ff                	test   %edi,%edi
  80172a:	b8 a0 23 80 00       	mov    $0x8023a0,%eax
  80172f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801732:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801736:	0f 8e 94 00 00 00    	jle    8017d0 <vprintfmt+0x225>
  80173c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801740:	0f 84 98 00 00 00    	je     8017de <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801746:	83 ec 08             	sub    $0x8,%esp
  801749:	ff 75 d0             	pushl  -0x30(%ebp)
  80174c:	57                   	push   %edi
  80174d:	e8 86 02 00 00       	call   8019d8 <strnlen>
  801752:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801755:	29 c1                	sub    %eax,%ecx
  801757:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80175a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80175d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801761:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801764:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801767:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801769:	eb 0f                	jmp    80177a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	53                   	push   %ebx
  80176f:	ff 75 e0             	pushl  -0x20(%ebp)
  801772:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801774:	83 ef 01             	sub    $0x1,%edi
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	85 ff                	test   %edi,%edi
  80177c:	7f ed                	jg     80176b <vprintfmt+0x1c0>
  80177e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801781:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801784:	85 c9                	test   %ecx,%ecx
  801786:	b8 00 00 00 00       	mov    $0x0,%eax
  80178b:	0f 49 c1             	cmovns %ecx,%eax
  80178e:	29 c1                	sub    %eax,%ecx
  801790:	89 75 08             	mov    %esi,0x8(%ebp)
  801793:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801796:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801799:	89 cb                	mov    %ecx,%ebx
  80179b:	eb 4d                	jmp    8017ea <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80179d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017a1:	74 1b                	je     8017be <vprintfmt+0x213>
  8017a3:	0f be c0             	movsbl %al,%eax
  8017a6:	83 e8 20             	sub    $0x20,%eax
  8017a9:	83 f8 5e             	cmp    $0x5e,%eax
  8017ac:	76 10                	jbe    8017be <vprintfmt+0x213>
					putch('?', putdat);
  8017ae:	83 ec 08             	sub    $0x8,%esp
  8017b1:	ff 75 0c             	pushl  0xc(%ebp)
  8017b4:	6a 3f                	push   $0x3f
  8017b6:	ff 55 08             	call   *0x8(%ebp)
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	eb 0d                	jmp    8017cb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	ff 75 0c             	pushl  0xc(%ebp)
  8017c4:	52                   	push   %edx
  8017c5:	ff 55 08             	call   *0x8(%ebp)
  8017c8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017cb:	83 eb 01             	sub    $0x1,%ebx
  8017ce:	eb 1a                	jmp    8017ea <vprintfmt+0x23f>
  8017d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8017d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017d9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017dc:	eb 0c                	jmp    8017ea <vprintfmt+0x23f>
  8017de:	89 75 08             	mov    %esi,0x8(%ebp)
  8017e1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017e7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017ea:	83 c7 01             	add    $0x1,%edi
  8017ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017f1:	0f be d0             	movsbl %al,%edx
  8017f4:	85 d2                	test   %edx,%edx
  8017f6:	74 23                	je     80181b <vprintfmt+0x270>
  8017f8:	85 f6                	test   %esi,%esi
  8017fa:	78 a1                	js     80179d <vprintfmt+0x1f2>
  8017fc:	83 ee 01             	sub    $0x1,%esi
  8017ff:	79 9c                	jns    80179d <vprintfmt+0x1f2>
  801801:	89 df                	mov    %ebx,%edi
  801803:	8b 75 08             	mov    0x8(%ebp),%esi
  801806:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801809:	eb 18                	jmp    801823 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	53                   	push   %ebx
  80180f:	6a 20                	push   $0x20
  801811:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801813:	83 ef 01             	sub    $0x1,%edi
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	eb 08                	jmp    801823 <vprintfmt+0x278>
  80181b:	89 df                	mov    %ebx,%edi
  80181d:	8b 75 08             	mov    0x8(%ebp),%esi
  801820:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801823:	85 ff                	test   %edi,%edi
  801825:	7f e4                	jg     80180b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801827:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80182a:	e9 a2 fd ff ff       	jmp    8015d1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80182f:	83 fa 01             	cmp    $0x1,%edx
  801832:	7e 16                	jle    80184a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801834:	8b 45 14             	mov    0x14(%ebp),%eax
  801837:	8d 50 08             	lea    0x8(%eax),%edx
  80183a:	89 55 14             	mov    %edx,0x14(%ebp)
  80183d:	8b 50 04             	mov    0x4(%eax),%edx
  801840:	8b 00                	mov    (%eax),%eax
  801842:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801845:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801848:	eb 32                	jmp    80187c <vprintfmt+0x2d1>
	else if (lflag)
  80184a:	85 d2                	test   %edx,%edx
  80184c:	74 18                	je     801866 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80184e:	8b 45 14             	mov    0x14(%ebp),%eax
  801851:	8d 50 04             	lea    0x4(%eax),%edx
  801854:	89 55 14             	mov    %edx,0x14(%ebp)
  801857:	8b 00                	mov    (%eax),%eax
  801859:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80185c:	89 c1                	mov    %eax,%ecx
  80185e:	c1 f9 1f             	sar    $0x1f,%ecx
  801861:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801864:	eb 16                	jmp    80187c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801866:	8b 45 14             	mov    0x14(%ebp),%eax
  801869:	8d 50 04             	lea    0x4(%eax),%edx
  80186c:	89 55 14             	mov    %edx,0x14(%ebp)
  80186f:	8b 00                	mov    (%eax),%eax
  801871:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801874:	89 c1                	mov    %eax,%ecx
  801876:	c1 f9 1f             	sar    $0x1f,%ecx
  801879:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80187c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80187f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801882:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801887:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80188b:	79 74                	jns    801901 <vprintfmt+0x356>
				putch('-', putdat);
  80188d:	83 ec 08             	sub    $0x8,%esp
  801890:	53                   	push   %ebx
  801891:	6a 2d                	push   $0x2d
  801893:	ff d6                	call   *%esi
				num = -(long long) num;
  801895:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801898:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80189b:	f7 d8                	neg    %eax
  80189d:	83 d2 00             	adc    $0x0,%edx
  8018a0:	f7 da                	neg    %edx
  8018a2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018aa:	eb 55                	jmp    801901 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8018af:	e8 83 fc ff ff       	call   801537 <getuint>
			base = 10;
  8018b4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018b9:	eb 46                	jmp    801901 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8018be:	e8 74 fc ff ff       	call   801537 <getuint>
			base = 8;
  8018c3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018c8:	eb 37                	jmp    801901 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	53                   	push   %ebx
  8018ce:	6a 30                	push   $0x30
  8018d0:	ff d6                	call   *%esi
			putch('x', putdat);
  8018d2:	83 c4 08             	add    $0x8,%esp
  8018d5:	53                   	push   %ebx
  8018d6:	6a 78                	push   $0x78
  8018d8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018da:	8b 45 14             	mov    0x14(%ebp),%eax
  8018dd:	8d 50 04             	lea    0x4(%eax),%edx
  8018e0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018e3:	8b 00                	mov    (%eax),%eax
  8018e5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018ea:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018ed:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018f2:	eb 0d                	jmp    801901 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8018f7:	e8 3b fc ff ff       	call   801537 <getuint>
			base = 16;
  8018fc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801901:	83 ec 0c             	sub    $0xc,%esp
  801904:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801908:	57                   	push   %edi
  801909:	ff 75 e0             	pushl  -0x20(%ebp)
  80190c:	51                   	push   %ecx
  80190d:	52                   	push   %edx
  80190e:	50                   	push   %eax
  80190f:	89 da                	mov    %ebx,%edx
  801911:	89 f0                	mov    %esi,%eax
  801913:	e8 70 fb ff ff       	call   801488 <printnum>
			break;
  801918:	83 c4 20             	add    $0x20,%esp
  80191b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80191e:	e9 ae fc ff ff       	jmp    8015d1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801923:	83 ec 08             	sub    $0x8,%esp
  801926:	53                   	push   %ebx
  801927:	51                   	push   %ecx
  801928:	ff d6                	call   *%esi
			break;
  80192a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801930:	e9 9c fc ff ff       	jmp    8015d1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801935:	83 ec 08             	sub    $0x8,%esp
  801938:	53                   	push   %ebx
  801939:	6a 25                	push   $0x25
  80193b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	eb 03                	jmp    801945 <vprintfmt+0x39a>
  801942:	83 ef 01             	sub    $0x1,%edi
  801945:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801949:	75 f7                	jne    801942 <vprintfmt+0x397>
  80194b:	e9 81 fc ff ff       	jmp    8015d1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801950:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801953:	5b                   	pop    %ebx
  801954:	5e                   	pop    %esi
  801955:	5f                   	pop    %edi
  801956:	5d                   	pop    %ebp
  801957:	c3                   	ret    

00801958 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	83 ec 18             	sub    $0x18,%esp
  80195e:	8b 45 08             	mov    0x8(%ebp),%eax
  801961:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801964:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801967:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80196b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80196e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801975:	85 c0                	test   %eax,%eax
  801977:	74 26                	je     80199f <vsnprintf+0x47>
  801979:	85 d2                	test   %edx,%edx
  80197b:	7e 22                	jle    80199f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80197d:	ff 75 14             	pushl  0x14(%ebp)
  801980:	ff 75 10             	pushl  0x10(%ebp)
  801983:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801986:	50                   	push   %eax
  801987:	68 71 15 80 00       	push   $0x801571
  80198c:	e8 1a fc ff ff       	call   8015ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801991:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801994:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801997:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	eb 05                	jmp    8019a4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80199f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019a4:	c9                   	leave  
  8019a5:	c3                   	ret    

008019a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019ac:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019af:	50                   	push   %eax
  8019b0:	ff 75 10             	pushl  0x10(%ebp)
  8019b3:	ff 75 0c             	pushl  0xc(%ebp)
  8019b6:	ff 75 08             	pushl  0x8(%ebp)
  8019b9:	e8 9a ff ff ff       	call   801958 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019cb:	eb 03                	jmp    8019d0 <strlen+0x10>
		n++;
  8019cd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019d4:	75 f7                	jne    8019cd <strlen+0xd>
		n++;
	return n;
}
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019de:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e6:	eb 03                	jmp    8019eb <strnlen+0x13>
		n++;
  8019e8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019eb:	39 c2                	cmp    %eax,%edx
  8019ed:	74 08                	je     8019f7 <strnlen+0x1f>
  8019ef:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019f3:	75 f3                	jne    8019e8 <strnlen+0x10>
  8019f5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801a00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a03:	89 c2                	mov    %eax,%edx
  801a05:	83 c2 01             	add    $0x1,%edx
  801a08:	83 c1 01             	add    $0x1,%ecx
  801a0b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a0f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a12:	84 db                	test   %bl,%bl
  801a14:	75 ef                	jne    801a05 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a16:	5b                   	pop    %ebx
  801a17:	5d                   	pop    %ebp
  801a18:	c3                   	ret    

00801a19 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	53                   	push   %ebx
  801a1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a20:	53                   	push   %ebx
  801a21:	e8 9a ff ff ff       	call   8019c0 <strlen>
  801a26:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a29:	ff 75 0c             	pushl  0xc(%ebp)
  801a2c:	01 d8                	add    %ebx,%eax
  801a2e:	50                   	push   %eax
  801a2f:	e8 c5 ff ff ff       	call   8019f9 <strcpy>
	return dst;
}
  801a34:	89 d8                	mov    %ebx,%eax
  801a36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	56                   	push   %esi
  801a3f:	53                   	push   %ebx
  801a40:	8b 75 08             	mov    0x8(%ebp),%esi
  801a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a46:	89 f3                	mov    %esi,%ebx
  801a48:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a4b:	89 f2                	mov    %esi,%edx
  801a4d:	eb 0f                	jmp    801a5e <strncpy+0x23>
		*dst++ = *src;
  801a4f:	83 c2 01             	add    $0x1,%edx
  801a52:	0f b6 01             	movzbl (%ecx),%eax
  801a55:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a58:	80 39 01             	cmpb   $0x1,(%ecx)
  801a5b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a5e:	39 da                	cmp    %ebx,%edx
  801a60:	75 ed                	jne    801a4f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a62:	89 f0                	mov    %esi,%eax
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	56                   	push   %esi
  801a6c:	53                   	push   %ebx
  801a6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a73:	8b 55 10             	mov    0x10(%ebp),%edx
  801a76:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a78:	85 d2                	test   %edx,%edx
  801a7a:	74 21                	je     801a9d <strlcpy+0x35>
  801a7c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a80:	89 f2                	mov    %esi,%edx
  801a82:	eb 09                	jmp    801a8d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a84:	83 c2 01             	add    $0x1,%edx
  801a87:	83 c1 01             	add    $0x1,%ecx
  801a8a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a8d:	39 c2                	cmp    %eax,%edx
  801a8f:	74 09                	je     801a9a <strlcpy+0x32>
  801a91:	0f b6 19             	movzbl (%ecx),%ebx
  801a94:	84 db                	test   %bl,%bl
  801a96:	75 ec                	jne    801a84 <strlcpy+0x1c>
  801a98:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a9a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a9d:	29 f0                	sub    %esi,%eax
}
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801aac:	eb 06                	jmp    801ab4 <strcmp+0x11>
		p++, q++;
  801aae:	83 c1 01             	add    $0x1,%ecx
  801ab1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ab4:	0f b6 01             	movzbl (%ecx),%eax
  801ab7:	84 c0                	test   %al,%al
  801ab9:	74 04                	je     801abf <strcmp+0x1c>
  801abb:	3a 02                	cmp    (%edx),%al
  801abd:	74 ef                	je     801aae <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801abf:	0f b6 c0             	movzbl %al,%eax
  801ac2:	0f b6 12             	movzbl (%edx),%edx
  801ac5:	29 d0                	sub    %edx,%eax
}
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	53                   	push   %ebx
  801acd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ad3:	89 c3                	mov    %eax,%ebx
  801ad5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ad8:	eb 06                	jmp    801ae0 <strncmp+0x17>
		n--, p++, q++;
  801ada:	83 c0 01             	add    $0x1,%eax
  801add:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ae0:	39 d8                	cmp    %ebx,%eax
  801ae2:	74 15                	je     801af9 <strncmp+0x30>
  801ae4:	0f b6 08             	movzbl (%eax),%ecx
  801ae7:	84 c9                	test   %cl,%cl
  801ae9:	74 04                	je     801aef <strncmp+0x26>
  801aeb:	3a 0a                	cmp    (%edx),%cl
  801aed:	74 eb                	je     801ada <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801aef:	0f b6 00             	movzbl (%eax),%eax
  801af2:	0f b6 12             	movzbl (%edx),%edx
  801af5:	29 d0                	sub    %edx,%eax
  801af7:	eb 05                	jmp    801afe <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801afe:	5b                   	pop    %ebx
  801aff:	5d                   	pop    %ebp
  801b00:	c3                   	ret    

00801b01 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	8b 45 08             	mov    0x8(%ebp),%eax
  801b07:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b0b:	eb 07                	jmp    801b14 <strchr+0x13>
		if (*s == c)
  801b0d:	38 ca                	cmp    %cl,%dl
  801b0f:	74 0f                	je     801b20 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b11:	83 c0 01             	add    $0x1,%eax
  801b14:	0f b6 10             	movzbl (%eax),%edx
  801b17:	84 d2                	test   %dl,%dl
  801b19:	75 f2                	jne    801b0d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b2c:	eb 03                	jmp    801b31 <strfind+0xf>
  801b2e:	83 c0 01             	add    $0x1,%eax
  801b31:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b34:	38 ca                	cmp    %cl,%dl
  801b36:	74 04                	je     801b3c <strfind+0x1a>
  801b38:	84 d2                	test   %dl,%dl
  801b3a:	75 f2                	jne    801b2e <strfind+0xc>
			break;
	return (char *) s;
}
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	53                   	push   %ebx
  801b44:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b47:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b4a:	85 c9                	test   %ecx,%ecx
  801b4c:	74 36                	je     801b84 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b54:	75 28                	jne    801b7e <memset+0x40>
  801b56:	f6 c1 03             	test   $0x3,%cl
  801b59:	75 23                	jne    801b7e <memset+0x40>
		c &= 0xFF;
  801b5b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b5f:	89 d3                	mov    %edx,%ebx
  801b61:	c1 e3 08             	shl    $0x8,%ebx
  801b64:	89 d6                	mov    %edx,%esi
  801b66:	c1 e6 18             	shl    $0x18,%esi
  801b69:	89 d0                	mov    %edx,%eax
  801b6b:	c1 e0 10             	shl    $0x10,%eax
  801b6e:	09 f0                	or     %esi,%eax
  801b70:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b72:	89 d8                	mov    %ebx,%eax
  801b74:	09 d0                	or     %edx,%eax
  801b76:	c1 e9 02             	shr    $0x2,%ecx
  801b79:	fc                   	cld    
  801b7a:	f3 ab                	rep stos %eax,%es:(%edi)
  801b7c:	eb 06                	jmp    801b84 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b81:	fc                   	cld    
  801b82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b84:	89 f8                	mov    %edi,%eax
  801b86:	5b                   	pop    %ebx
  801b87:	5e                   	pop    %esi
  801b88:	5f                   	pop    %edi
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	57                   	push   %edi
  801b8f:	56                   	push   %esi
  801b90:	8b 45 08             	mov    0x8(%ebp),%eax
  801b93:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b99:	39 c6                	cmp    %eax,%esi
  801b9b:	73 35                	jae    801bd2 <memmove+0x47>
  801b9d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ba0:	39 d0                	cmp    %edx,%eax
  801ba2:	73 2e                	jae    801bd2 <memmove+0x47>
		s += n;
		d += n;
  801ba4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ba7:	89 d6                	mov    %edx,%esi
  801ba9:	09 fe                	or     %edi,%esi
  801bab:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bb1:	75 13                	jne    801bc6 <memmove+0x3b>
  801bb3:	f6 c1 03             	test   $0x3,%cl
  801bb6:	75 0e                	jne    801bc6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bb8:	83 ef 04             	sub    $0x4,%edi
  801bbb:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bbe:	c1 e9 02             	shr    $0x2,%ecx
  801bc1:	fd                   	std    
  801bc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bc4:	eb 09                	jmp    801bcf <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bc6:	83 ef 01             	sub    $0x1,%edi
  801bc9:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bcc:	fd                   	std    
  801bcd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bcf:	fc                   	cld    
  801bd0:	eb 1d                	jmp    801bef <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bd2:	89 f2                	mov    %esi,%edx
  801bd4:	09 c2                	or     %eax,%edx
  801bd6:	f6 c2 03             	test   $0x3,%dl
  801bd9:	75 0f                	jne    801bea <memmove+0x5f>
  801bdb:	f6 c1 03             	test   $0x3,%cl
  801bde:	75 0a                	jne    801bea <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801be0:	c1 e9 02             	shr    $0x2,%ecx
  801be3:	89 c7                	mov    %eax,%edi
  801be5:	fc                   	cld    
  801be6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801be8:	eb 05                	jmp    801bef <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bea:	89 c7                	mov    %eax,%edi
  801bec:	fc                   	cld    
  801bed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801bef:	5e                   	pop    %esi
  801bf0:	5f                   	pop    %edi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801bf6:	ff 75 10             	pushl  0x10(%ebp)
  801bf9:	ff 75 0c             	pushl  0xc(%ebp)
  801bfc:	ff 75 08             	pushl  0x8(%ebp)
  801bff:	e8 87 ff ff ff       	call   801b8b <memmove>
}
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	56                   	push   %esi
  801c0a:	53                   	push   %ebx
  801c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c11:	89 c6                	mov    %eax,%esi
  801c13:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c16:	eb 1a                	jmp    801c32 <memcmp+0x2c>
		if (*s1 != *s2)
  801c18:	0f b6 08             	movzbl (%eax),%ecx
  801c1b:	0f b6 1a             	movzbl (%edx),%ebx
  801c1e:	38 d9                	cmp    %bl,%cl
  801c20:	74 0a                	je     801c2c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c22:	0f b6 c1             	movzbl %cl,%eax
  801c25:	0f b6 db             	movzbl %bl,%ebx
  801c28:	29 d8                	sub    %ebx,%eax
  801c2a:	eb 0f                	jmp    801c3b <memcmp+0x35>
		s1++, s2++;
  801c2c:	83 c0 01             	add    $0x1,%eax
  801c2f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c32:	39 f0                	cmp    %esi,%eax
  801c34:	75 e2                	jne    801c18 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3b:	5b                   	pop    %ebx
  801c3c:	5e                   	pop    %esi
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	53                   	push   %ebx
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c46:	89 c1                	mov    %eax,%ecx
  801c48:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c4b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c4f:	eb 0a                	jmp    801c5b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c51:	0f b6 10             	movzbl (%eax),%edx
  801c54:	39 da                	cmp    %ebx,%edx
  801c56:	74 07                	je     801c5f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c58:	83 c0 01             	add    $0x1,%eax
  801c5b:	39 c8                	cmp    %ecx,%eax
  801c5d:	72 f2                	jb     801c51 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c5f:	5b                   	pop    %ebx
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c6e:	eb 03                	jmp    801c73 <strtol+0x11>
		s++;
  801c70:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c73:	0f b6 01             	movzbl (%ecx),%eax
  801c76:	3c 20                	cmp    $0x20,%al
  801c78:	74 f6                	je     801c70 <strtol+0xe>
  801c7a:	3c 09                	cmp    $0x9,%al
  801c7c:	74 f2                	je     801c70 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c7e:	3c 2b                	cmp    $0x2b,%al
  801c80:	75 0a                	jne    801c8c <strtol+0x2a>
		s++;
  801c82:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c85:	bf 00 00 00 00       	mov    $0x0,%edi
  801c8a:	eb 11                	jmp    801c9d <strtol+0x3b>
  801c8c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c91:	3c 2d                	cmp    $0x2d,%al
  801c93:	75 08                	jne    801c9d <strtol+0x3b>
		s++, neg = 1;
  801c95:	83 c1 01             	add    $0x1,%ecx
  801c98:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c9d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ca3:	75 15                	jne    801cba <strtol+0x58>
  801ca5:	80 39 30             	cmpb   $0x30,(%ecx)
  801ca8:	75 10                	jne    801cba <strtol+0x58>
  801caa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cae:	75 7c                	jne    801d2c <strtol+0xca>
		s += 2, base = 16;
  801cb0:	83 c1 02             	add    $0x2,%ecx
  801cb3:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cb8:	eb 16                	jmp    801cd0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cba:	85 db                	test   %ebx,%ebx
  801cbc:	75 12                	jne    801cd0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cbe:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cc3:	80 39 30             	cmpb   $0x30,(%ecx)
  801cc6:	75 08                	jne    801cd0 <strtol+0x6e>
		s++, base = 8;
  801cc8:	83 c1 01             	add    $0x1,%ecx
  801ccb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cd0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cd8:	0f b6 11             	movzbl (%ecx),%edx
  801cdb:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cde:	89 f3                	mov    %esi,%ebx
  801ce0:	80 fb 09             	cmp    $0x9,%bl
  801ce3:	77 08                	ja     801ced <strtol+0x8b>
			dig = *s - '0';
  801ce5:	0f be d2             	movsbl %dl,%edx
  801ce8:	83 ea 30             	sub    $0x30,%edx
  801ceb:	eb 22                	jmp    801d0f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ced:	8d 72 9f             	lea    -0x61(%edx),%esi
  801cf0:	89 f3                	mov    %esi,%ebx
  801cf2:	80 fb 19             	cmp    $0x19,%bl
  801cf5:	77 08                	ja     801cff <strtol+0x9d>
			dig = *s - 'a' + 10;
  801cf7:	0f be d2             	movsbl %dl,%edx
  801cfa:	83 ea 57             	sub    $0x57,%edx
  801cfd:	eb 10                	jmp    801d0f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801cff:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d02:	89 f3                	mov    %esi,%ebx
  801d04:	80 fb 19             	cmp    $0x19,%bl
  801d07:	77 16                	ja     801d1f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d09:	0f be d2             	movsbl %dl,%edx
  801d0c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d0f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d12:	7d 0b                	jge    801d1f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d14:	83 c1 01             	add    $0x1,%ecx
  801d17:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d1b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d1d:	eb b9                	jmp    801cd8 <strtol+0x76>

	if (endptr)
  801d1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d23:	74 0d                	je     801d32 <strtol+0xd0>
		*endptr = (char *) s;
  801d25:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d28:	89 0e                	mov    %ecx,(%esi)
  801d2a:	eb 06                	jmp    801d32 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d2c:	85 db                	test   %ebx,%ebx
  801d2e:	74 98                	je     801cc8 <strtol+0x66>
  801d30:	eb 9e                	jmp    801cd0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d32:	89 c2                	mov    %eax,%edx
  801d34:	f7 da                	neg    %edx
  801d36:	85 ff                	test   %edi,%edi
  801d38:	0f 45 c2             	cmovne %edx,%eax
}
  801d3b:	5b                   	pop    %ebx
  801d3c:	5e                   	pop    %esi
  801d3d:	5f                   	pop    %edi
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d46:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d4d:	75 2a                	jne    801d79 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d4f:	83 ec 04             	sub    $0x4,%esp
  801d52:	6a 07                	push   $0x7
  801d54:	68 00 f0 bf ee       	push   $0xeebff000
  801d59:	6a 00                	push   $0x0
  801d5b:	e8 2e e4 ff ff       	call   80018e <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d60:	83 c4 10             	add    $0x10,%esp
  801d63:	85 c0                	test   %eax,%eax
  801d65:	79 12                	jns    801d79 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d67:	50                   	push   %eax
  801d68:	68 a0 26 80 00       	push   $0x8026a0
  801d6d:	6a 23                	push   $0x23
  801d6f:	68 a4 26 80 00       	push   $0x8026a4
  801d74:	e8 22 f6 ff ff       	call   80139b <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d81:	83 ec 08             	sub    $0x8,%esp
  801d84:	68 ab 1d 80 00       	push   $0x801dab
  801d89:	6a 00                	push   $0x0
  801d8b:	e8 49 e5 ff ff       	call   8002d9 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	85 c0                	test   %eax,%eax
  801d95:	79 12                	jns    801da9 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d97:	50                   	push   %eax
  801d98:	68 a0 26 80 00       	push   $0x8026a0
  801d9d:	6a 2c                	push   $0x2c
  801d9f:	68 a4 26 80 00       	push   $0x8026a4
  801da4:	e8 f2 f5 ff ff       	call   80139b <_panic>
	}
}
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    

00801dab <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dab:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dac:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801db1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801db3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801db6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dba:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dbf:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dc3:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dc5:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dc8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dc9:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dcc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dcd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dce:	c3                   	ret    

00801dcf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	56                   	push   %esi
  801dd3:	53                   	push   %ebx
  801dd4:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	75 12                	jne    801df3 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801de1:	83 ec 0c             	sub    $0xc,%esp
  801de4:	68 00 00 c0 ee       	push   $0xeec00000
  801de9:	e8 50 e5 ff ff       	call   80033e <sys_ipc_recv>
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	eb 0c                	jmp    801dff <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801df3:	83 ec 0c             	sub    $0xc,%esp
  801df6:	50                   	push   %eax
  801df7:	e8 42 e5 ff ff       	call   80033e <sys_ipc_recv>
  801dfc:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801dff:	85 f6                	test   %esi,%esi
  801e01:	0f 95 c1             	setne  %cl
  801e04:	85 db                	test   %ebx,%ebx
  801e06:	0f 95 c2             	setne  %dl
  801e09:	84 d1                	test   %dl,%cl
  801e0b:	74 09                	je     801e16 <ipc_recv+0x47>
  801e0d:	89 c2                	mov    %eax,%edx
  801e0f:	c1 ea 1f             	shr    $0x1f,%edx
  801e12:	84 d2                	test   %dl,%dl
  801e14:	75 2a                	jne    801e40 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e16:	85 f6                	test   %esi,%esi
  801e18:	74 0d                	je     801e27 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e1a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e25:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e27:	85 db                	test   %ebx,%ebx
  801e29:	74 0d                	je     801e38 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e2b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e30:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e36:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e38:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3d:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e40:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e43:	5b                   	pop    %ebx
  801e44:	5e                   	pop    %esi
  801e45:	5d                   	pop    %ebp
  801e46:	c3                   	ret    

00801e47 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	57                   	push   %edi
  801e4b:	56                   	push   %esi
  801e4c:	53                   	push   %ebx
  801e4d:	83 ec 0c             	sub    $0xc,%esp
  801e50:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e53:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e59:	85 db                	test   %ebx,%ebx
  801e5b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e60:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e63:	ff 75 14             	pushl  0x14(%ebp)
  801e66:	53                   	push   %ebx
  801e67:	56                   	push   %esi
  801e68:	57                   	push   %edi
  801e69:	e8 ad e4 ff ff       	call   80031b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e6e:	89 c2                	mov    %eax,%edx
  801e70:	c1 ea 1f             	shr    $0x1f,%edx
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	84 d2                	test   %dl,%dl
  801e78:	74 17                	je     801e91 <ipc_send+0x4a>
  801e7a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e7d:	74 12                	je     801e91 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e7f:	50                   	push   %eax
  801e80:	68 b2 26 80 00       	push   $0x8026b2
  801e85:	6a 47                	push   $0x47
  801e87:	68 c0 26 80 00       	push   $0x8026c0
  801e8c:	e8 0a f5 ff ff       	call   80139b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e91:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e94:	75 07                	jne    801e9d <ipc_send+0x56>
			sys_yield();
  801e96:	e8 d4 e2 ff ff       	call   80016f <sys_yield>
  801e9b:	eb c6                	jmp    801e63 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	75 c2                	jne    801e63 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea4:	5b                   	pop    %ebx
  801ea5:	5e                   	pop    %esi
  801ea6:	5f                   	pop    %edi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eaf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eb4:	89 c2                	mov    %eax,%edx
  801eb6:	c1 e2 07             	shl    $0x7,%edx
  801eb9:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801ec0:	8b 52 5c             	mov    0x5c(%edx),%edx
  801ec3:	39 ca                	cmp    %ecx,%edx
  801ec5:	75 11                	jne    801ed8 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ec7:	89 c2                	mov    %eax,%edx
  801ec9:	c1 e2 07             	shl    $0x7,%edx
  801ecc:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ed3:	8b 40 54             	mov    0x54(%eax),%eax
  801ed6:	eb 0f                	jmp    801ee7 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed8:	83 c0 01             	add    $0x1,%eax
  801edb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee0:	75 d2                	jne    801eb4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ee2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eef:	89 d0                	mov    %edx,%eax
  801ef1:	c1 e8 16             	shr    $0x16,%eax
  801ef4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f00:	f6 c1 01             	test   $0x1,%cl
  801f03:	74 1d                	je     801f22 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f05:	c1 ea 0c             	shr    $0xc,%edx
  801f08:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f0f:	f6 c2 01             	test   $0x1,%dl
  801f12:	74 0e                	je     801f22 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f14:	c1 ea 0c             	shr    $0xc,%edx
  801f17:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f1e:	ef 
  801f1f:	0f b7 c0             	movzwl %ax,%eax
}
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    
  801f24:	66 90                	xchg   %ax,%ax
  801f26:	66 90                	xchg   %ax,%ax
  801f28:	66 90                	xchg   %ax,%ax
  801f2a:	66 90                	xchg   %ax,%ax
  801f2c:	66 90                	xchg   %ax,%ax
  801f2e:	66 90                	xchg   %ax,%ax

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
