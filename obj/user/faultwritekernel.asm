
obj/user/faultwritekernel.debug:     file format elf32-i386


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
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
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
  800057:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  80008b:	55                   	push   %ebp
  80008c:	89 e5                	mov    %esp,%ebp
  80008e:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8000b1:	e8 04 08 00 00       	call   8008ba <close_all>
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
  80012a:	68 2a 22 80 00       	push   $0x80222a
  80012f:	6a 23                	push   $0x23
  800131:	68 47 22 80 00       	push   $0x802247
  800136:	e8 b0 12 00 00       	call   8013eb <_panic>

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
  8001ab:	68 2a 22 80 00       	push   $0x80222a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 47 22 80 00       	push   $0x802247
  8001b7:	e8 2f 12 00 00       	call   8013eb <_panic>

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
  8001ed:	68 2a 22 80 00       	push   $0x80222a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 47 22 80 00       	push   $0x802247
  8001f9:	e8 ed 11 00 00       	call   8013eb <_panic>

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
  80022f:	68 2a 22 80 00       	push   $0x80222a
  800234:	6a 23                	push   $0x23
  800236:	68 47 22 80 00       	push   $0x802247
  80023b:	e8 ab 11 00 00       	call   8013eb <_panic>

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
  800271:	68 2a 22 80 00       	push   $0x80222a
  800276:	6a 23                	push   $0x23
  800278:	68 47 22 80 00       	push   $0x802247
  80027d:	e8 69 11 00 00       	call   8013eb <_panic>

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
  8002b3:	68 2a 22 80 00       	push   $0x80222a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 47 22 80 00       	push   $0x802247
  8002bf:	e8 27 11 00 00       	call   8013eb <_panic>
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
  8002f5:	68 2a 22 80 00       	push   $0x80222a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 47 22 80 00       	push   $0x802247
  800301:	e8 e5 10 00 00       	call   8013eb <_panic>

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
  800359:	68 2a 22 80 00       	push   $0x80222a
  80035e:	6a 23                	push   $0x23
  800360:	68 47 22 80 00       	push   $0x802247
  800365:	e8 81 10 00 00       	call   8013eb <_panic>

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
  8003f8:	68 55 22 80 00       	push   $0x802255
  8003fd:	6a 1e                	push   $0x1e
  8003ff:	68 65 22 80 00       	push   $0x802265
  800404:	e8 e2 0f 00 00       	call   8013eb <_panic>
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
  800422:	68 70 22 80 00       	push   $0x802270
  800427:	6a 2c                	push   $0x2c
  800429:	68 65 22 80 00       	push   $0x802265
  80042e:	e8 b8 0f 00 00       	call   8013eb <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800433:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800439:	83 ec 04             	sub    $0x4,%esp
  80043c:	68 00 10 00 00       	push   $0x1000
  800441:	53                   	push   %ebx
  800442:	68 00 f0 7f 00       	push   $0x7ff000
  800447:	e8 f7 17 00 00       	call   801c43 <memcpy>

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
  80046a:	68 70 22 80 00       	push   $0x802270
  80046f:	6a 33                	push   $0x33
  800471:	68 65 22 80 00       	push   $0x802265
  800476:	e8 70 0f 00 00       	call   8013eb <_panic>
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
  800492:	68 70 22 80 00       	push   $0x802270
  800497:	6a 37                	push   $0x37
  800499:	68 65 22 80 00       	push   $0x802265
  80049e:	e8 48 0f 00 00       	call   8013eb <_panic>
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
  8004b6:	e8 d5 18 00 00       	call   801d90 <set_pgfault_handler>
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
  8004cf:	68 89 22 80 00       	push   $0x802289
  8004d4:	68 84 00 00 00       	push   $0x84
  8004d9:	68 65 22 80 00       	push   $0x802265
  8004de:	e8 08 0f 00 00       	call   8013eb <_panic>
  8004e3:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e9:	75 24                	jne    80050f <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004eb:	e8 53 fc ff ff       	call   800143 <sys_getenvid>
  8004f0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004f5:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  80058b:	68 97 22 80 00       	push   $0x802297
  800590:	6a 54                	push   $0x54
  800592:	68 65 22 80 00       	push   $0x802265
  800597:	e8 4f 0e 00 00       	call   8013eb <_panic>
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
  8005d0:	68 97 22 80 00       	push   $0x802297
  8005d5:	6a 5b                	push   $0x5b
  8005d7:	68 65 22 80 00       	push   $0x802265
  8005dc:	e8 0a 0e 00 00       	call   8013eb <_panic>
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
  8005fe:	68 97 22 80 00       	push   $0x802297
  800603:	6a 5f                	push   $0x5f
  800605:	68 65 22 80 00       	push   $0x802265
  80060a:	e8 dc 0d 00 00       	call   8013eb <_panic>
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
  800628:	68 97 22 80 00       	push   $0x802297
  80062d:	6a 64                	push   $0x64
  80062f:	68 65 22 80 00       	push   $0x802265
  800634:	e8 b2 0d 00 00       	call   8013eb <_panic>
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
  800650:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	56                   	push   %esi
  800689:	53                   	push   %ebx
  80068a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80068d:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	68 b0 22 80 00       	push   $0x8022b0
  80069c:	e8 23 0e 00 00       	call   8014c4 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006a1:	c7 04 24 8b 00 80 00 	movl   $0x80008b,(%esp)
  8006a8:	e8 c5 fc ff ff       	call   800372 <sys_thread_create>
  8006ad:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	68 b0 22 80 00       	push   $0x8022b0
  8006b8:	e8 07 0e 00 00       	call   8014c4 <cprintf>
	return id;
}
  8006bd:	89 f0                	mov    %esi,%eax
  8006bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006c2:	5b                   	pop    %ebx
  8006c3:	5e                   	pop    %esi
  8006c4:	5d                   	pop    %ebp
  8006c5:	c3                   	ret    

008006c6 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8006cc:	ff 75 08             	pushl  0x8(%ebp)
  8006cf:	e8 be fc ff ff       	call   800392 <sys_thread_free>
}
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	c9                   	leave  
  8006d8:	c3                   	ret    

008006d9 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8006df:	ff 75 08             	pushl  0x8(%ebp)
  8006e2:	e8 cb fc ff ff       	call   8003b2 <sys_thread_join>
}
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8006f7:	c1 e8 0c             	shr    $0xc,%eax
}
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	05 00 00 00 30       	add    $0x30000000,%eax
  800707:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80070c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800719:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80071e:	89 c2                	mov    %eax,%edx
  800720:	c1 ea 16             	shr    $0x16,%edx
  800723:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80072a:	f6 c2 01             	test   $0x1,%dl
  80072d:	74 11                	je     800740 <fd_alloc+0x2d>
  80072f:	89 c2                	mov    %eax,%edx
  800731:	c1 ea 0c             	shr    $0xc,%edx
  800734:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80073b:	f6 c2 01             	test   $0x1,%dl
  80073e:	75 09                	jne    800749 <fd_alloc+0x36>
			*fd_store = fd;
  800740:	89 01                	mov    %eax,(%ecx)
			return 0;
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
  800747:	eb 17                	jmp    800760 <fd_alloc+0x4d>
  800749:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80074e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800753:	75 c9                	jne    80071e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800755:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80075b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800768:	83 f8 1f             	cmp    $0x1f,%eax
  80076b:	77 36                	ja     8007a3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80076d:	c1 e0 0c             	shl    $0xc,%eax
  800770:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800775:	89 c2                	mov    %eax,%edx
  800777:	c1 ea 16             	shr    $0x16,%edx
  80077a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800781:	f6 c2 01             	test   $0x1,%dl
  800784:	74 24                	je     8007aa <fd_lookup+0x48>
  800786:	89 c2                	mov    %eax,%edx
  800788:	c1 ea 0c             	shr    $0xc,%edx
  80078b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800792:	f6 c2 01             	test   $0x1,%dl
  800795:	74 1a                	je     8007b1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	89 02                	mov    %eax,(%edx)
	return 0;
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	eb 13                	jmp    8007b6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a8:	eb 0c                	jmp    8007b6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007af:	eb 05                	jmp    8007b6 <fd_lookup+0x54>
  8007b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	ba 50 23 80 00       	mov    $0x802350,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007c6:	eb 13                	jmp    8007db <dev_lookup+0x23>
  8007c8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007cb:	39 08                	cmp    %ecx,(%eax)
  8007cd:	75 0c                	jne    8007db <dev_lookup+0x23>
			*dev = devtab[i];
  8007cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	eb 31                	jmp    80080c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007db:	8b 02                	mov    (%edx),%eax
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	75 e7                	jne    8007c8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8007e6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8007ec:	83 ec 04             	sub    $0x4,%esp
  8007ef:	51                   	push   %ecx
  8007f0:	50                   	push   %eax
  8007f1:	68 d4 22 80 00       	push   $0x8022d4
  8007f6:	e8 c9 0c 00 00       	call   8014c4 <cprintf>
	*dev = 0;
  8007fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	83 ec 10             	sub    $0x10,%esp
  800816:	8b 75 08             	mov    0x8(%ebp),%esi
  800819:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80081c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800826:	c1 e8 0c             	shr    $0xc,%eax
  800829:	50                   	push   %eax
  80082a:	e8 33 ff ff ff       	call   800762 <fd_lookup>
  80082f:	83 c4 08             	add    $0x8,%esp
  800832:	85 c0                	test   %eax,%eax
  800834:	78 05                	js     80083b <fd_close+0x2d>
	    || fd != fd2)
  800836:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800839:	74 0c                	je     800847 <fd_close+0x39>
		return (must_exist ? r : 0);
  80083b:	84 db                	test   %bl,%bl
  80083d:	ba 00 00 00 00       	mov    $0x0,%edx
  800842:	0f 44 c2             	cmove  %edx,%eax
  800845:	eb 41                	jmp    800888 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084d:	50                   	push   %eax
  80084e:	ff 36                	pushl  (%esi)
  800850:	e8 63 ff ff ff       	call   8007b8 <dev_lookup>
  800855:	89 c3                	mov    %eax,%ebx
  800857:	83 c4 10             	add    $0x10,%esp
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 1a                	js     800878 <fd_close+0x6a>
		if (dev->dev_close)
  80085e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800861:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800864:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800869:	85 c0                	test   %eax,%eax
  80086b:	74 0b                	je     800878 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80086d:	83 ec 0c             	sub    $0xc,%esp
  800870:	56                   	push   %esi
  800871:	ff d0                	call   *%eax
  800873:	89 c3                	mov    %eax,%ebx
  800875:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	56                   	push   %esi
  80087c:	6a 00                	push   $0x0
  80087e:	e8 83 f9 ff ff       	call   800206 <sys_page_unmap>
	return r;
  800883:	83 c4 10             	add    $0x10,%esp
  800886:	89 d8                	mov    %ebx,%eax
}
  800888:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800895:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800898:	50                   	push   %eax
  800899:	ff 75 08             	pushl  0x8(%ebp)
  80089c:	e8 c1 fe ff ff       	call   800762 <fd_lookup>
  8008a1:	83 c4 08             	add    $0x8,%esp
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	78 10                	js     8008b8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	6a 01                	push   $0x1
  8008ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8008b0:	e8 59 ff ff ff       	call   80080e <fd_close>
  8008b5:	83 c4 10             	add    $0x10,%esp
}
  8008b8:	c9                   	leave  
  8008b9:	c3                   	ret    

008008ba <close_all>:

void
close_all(void)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008c6:	83 ec 0c             	sub    $0xc,%esp
  8008c9:	53                   	push   %ebx
  8008ca:	e8 c0 ff ff ff       	call   80088f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008cf:	83 c3 01             	add    $0x1,%ebx
  8008d2:	83 c4 10             	add    $0x10,%esp
  8008d5:	83 fb 20             	cmp    $0x20,%ebx
  8008d8:	75 ec                	jne    8008c6 <close_all+0xc>
		close(i);
}
  8008da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    

008008df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
  8008e5:	83 ec 2c             	sub    $0x2c,%esp
  8008e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008ee:	50                   	push   %eax
  8008ef:	ff 75 08             	pushl  0x8(%ebp)
  8008f2:	e8 6b fe ff ff       	call   800762 <fd_lookup>
  8008f7:	83 c4 08             	add    $0x8,%esp
  8008fa:	85 c0                	test   %eax,%eax
  8008fc:	0f 88 c1 00 00 00    	js     8009c3 <dup+0xe4>
		return r;
	close(newfdnum);
  800902:	83 ec 0c             	sub    $0xc,%esp
  800905:	56                   	push   %esi
  800906:	e8 84 ff ff ff       	call   80088f <close>

	newfd = INDEX2FD(newfdnum);
  80090b:	89 f3                	mov    %esi,%ebx
  80090d:	c1 e3 0c             	shl    $0xc,%ebx
  800910:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800916:	83 c4 04             	add    $0x4,%esp
  800919:	ff 75 e4             	pushl  -0x1c(%ebp)
  80091c:	e8 db fd ff ff       	call   8006fc <fd2data>
  800921:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800923:	89 1c 24             	mov    %ebx,(%esp)
  800926:	e8 d1 fd ff ff       	call   8006fc <fd2data>
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800931:	89 f8                	mov    %edi,%eax
  800933:	c1 e8 16             	shr    $0x16,%eax
  800936:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80093d:	a8 01                	test   $0x1,%al
  80093f:	74 37                	je     800978 <dup+0x99>
  800941:	89 f8                	mov    %edi,%eax
  800943:	c1 e8 0c             	shr    $0xc,%eax
  800946:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80094d:	f6 c2 01             	test   $0x1,%dl
  800950:	74 26                	je     800978 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800952:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800959:	83 ec 0c             	sub    $0xc,%esp
  80095c:	25 07 0e 00 00       	and    $0xe07,%eax
  800961:	50                   	push   %eax
  800962:	ff 75 d4             	pushl  -0x2c(%ebp)
  800965:	6a 00                	push   $0x0
  800967:	57                   	push   %edi
  800968:	6a 00                	push   $0x0
  80096a:	e8 55 f8 ff ff       	call   8001c4 <sys_page_map>
  80096f:	89 c7                	mov    %eax,%edi
  800971:	83 c4 20             	add    $0x20,%esp
  800974:	85 c0                	test   %eax,%eax
  800976:	78 2e                	js     8009a6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800978:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80097b:	89 d0                	mov    %edx,%eax
  80097d:	c1 e8 0c             	shr    $0xc,%eax
  800980:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800987:	83 ec 0c             	sub    $0xc,%esp
  80098a:	25 07 0e 00 00       	and    $0xe07,%eax
  80098f:	50                   	push   %eax
  800990:	53                   	push   %ebx
  800991:	6a 00                	push   $0x0
  800993:	52                   	push   %edx
  800994:	6a 00                	push   $0x0
  800996:	e8 29 f8 ff ff       	call   8001c4 <sys_page_map>
  80099b:	89 c7                	mov    %eax,%edi
  80099d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8009a0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009a2:	85 ff                	test   %edi,%edi
  8009a4:	79 1d                	jns    8009c3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8009a6:	83 ec 08             	sub    $0x8,%esp
  8009a9:	53                   	push   %ebx
  8009aa:	6a 00                	push   $0x0
  8009ac:	e8 55 f8 ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8009b1:	83 c4 08             	add    $0x8,%esp
  8009b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009b7:	6a 00                	push   $0x0
  8009b9:	e8 48 f8 ff ff       	call   800206 <sys_page_unmap>
	return r;
  8009be:	83 c4 10             	add    $0x10,%esp
  8009c1:	89 f8                	mov    %edi,%eax
}
  8009c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009c6:	5b                   	pop    %ebx
  8009c7:	5e                   	pop    %esi
  8009c8:	5f                   	pop    %edi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 14             	sub    $0x14,%esp
  8009d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009d8:	50                   	push   %eax
  8009d9:	53                   	push   %ebx
  8009da:	e8 83 fd ff ff       	call   800762 <fd_lookup>
  8009df:	83 c4 08             	add    $0x8,%esp
  8009e2:	89 c2                	mov    %eax,%edx
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	78 70                	js     800a58 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ee:	50                   	push   %eax
  8009ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009f2:	ff 30                	pushl  (%eax)
  8009f4:	e8 bf fd ff ff       	call   8007b8 <dev_lookup>
  8009f9:	83 c4 10             	add    $0x10,%esp
  8009fc:	85 c0                	test   %eax,%eax
  8009fe:	78 4f                	js     800a4f <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a00:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a03:	8b 42 08             	mov    0x8(%edx),%eax
  800a06:	83 e0 03             	and    $0x3,%eax
  800a09:	83 f8 01             	cmp    $0x1,%eax
  800a0c:	75 24                	jne    800a32 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a0e:	a1 04 40 80 00       	mov    0x804004,%eax
  800a13:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a19:	83 ec 04             	sub    $0x4,%esp
  800a1c:	53                   	push   %ebx
  800a1d:	50                   	push   %eax
  800a1e:	68 15 23 80 00       	push   $0x802315
  800a23:	e8 9c 0a 00 00       	call   8014c4 <cprintf>
		return -E_INVAL;
  800a28:	83 c4 10             	add    $0x10,%esp
  800a2b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a30:	eb 26                	jmp    800a58 <read+0x8d>
	}
	if (!dev->dev_read)
  800a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a35:	8b 40 08             	mov    0x8(%eax),%eax
  800a38:	85 c0                	test   %eax,%eax
  800a3a:	74 17                	je     800a53 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a3c:	83 ec 04             	sub    $0x4,%esp
  800a3f:	ff 75 10             	pushl  0x10(%ebp)
  800a42:	ff 75 0c             	pushl  0xc(%ebp)
  800a45:	52                   	push   %edx
  800a46:	ff d0                	call   *%eax
  800a48:	89 c2                	mov    %eax,%edx
  800a4a:	83 c4 10             	add    $0x10,%esp
  800a4d:	eb 09                	jmp    800a58 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	eb 05                	jmp    800a58 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a53:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a58:	89 d0                	mov    %edx,%eax
  800a5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	83 ec 0c             	sub    $0xc,%esp
  800a68:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a73:	eb 21                	jmp    800a96 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a75:	83 ec 04             	sub    $0x4,%esp
  800a78:	89 f0                	mov    %esi,%eax
  800a7a:	29 d8                	sub    %ebx,%eax
  800a7c:	50                   	push   %eax
  800a7d:	89 d8                	mov    %ebx,%eax
  800a7f:	03 45 0c             	add    0xc(%ebp),%eax
  800a82:	50                   	push   %eax
  800a83:	57                   	push   %edi
  800a84:	e8 42 ff ff ff       	call   8009cb <read>
		if (m < 0)
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	78 10                	js     800aa0 <readn+0x41>
			return m;
		if (m == 0)
  800a90:	85 c0                	test   %eax,%eax
  800a92:	74 0a                	je     800a9e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a94:	01 c3                	add    %eax,%ebx
  800a96:	39 f3                	cmp    %esi,%ebx
  800a98:	72 db                	jb     800a75 <readn+0x16>
  800a9a:	89 d8                	mov    %ebx,%eax
  800a9c:	eb 02                	jmp    800aa0 <readn+0x41>
  800a9e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	53                   	push   %ebx
  800aac:	83 ec 14             	sub    $0x14,%esp
  800aaf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ab2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ab5:	50                   	push   %eax
  800ab6:	53                   	push   %ebx
  800ab7:	e8 a6 fc ff ff       	call   800762 <fd_lookup>
  800abc:	83 c4 08             	add    $0x8,%esp
  800abf:	89 c2                	mov    %eax,%edx
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	78 6b                	js     800b30 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ac5:	83 ec 08             	sub    $0x8,%esp
  800ac8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acb:	50                   	push   %eax
  800acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800acf:	ff 30                	pushl  (%eax)
  800ad1:	e8 e2 fc ff ff       	call   8007b8 <dev_lookup>
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	78 4a                	js     800b27 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800add:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ae4:	75 24                	jne    800b0a <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800ae6:	a1 04 40 80 00       	mov    0x804004,%eax
  800aeb:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800af1:	83 ec 04             	sub    $0x4,%esp
  800af4:	53                   	push   %ebx
  800af5:	50                   	push   %eax
  800af6:	68 31 23 80 00       	push   $0x802331
  800afb:	e8 c4 09 00 00       	call   8014c4 <cprintf>
		return -E_INVAL;
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b08:	eb 26                	jmp    800b30 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0d:	8b 52 0c             	mov    0xc(%edx),%edx
  800b10:	85 d2                	test   %edx,%edx
  800b12:	74 17                	je     800b2b <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b14:	83 ec 04             	sub    $0x4,%esp
  800b17:	ff 75 10             	pushl  0x10(%ebp)
  800b1a:	ff 75 0c             	pushl  0xc(%ebp)
  800b1d:	50                   	push   %eax
  800b1e:	ff d2                	call   *%edx
  800b20:	89 c2                	mov    %eax,%edx
  800b22:	83 c4 10             	add    $0x10,%esp
  800b25:	eb 09                	jmp    800b30 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	eb 05                	jmp    800b30 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b2b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b30:	89 d0                	mov    %edx,%eax
  800b32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <seek>:

int
seek(int fdnum, off_t offset)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b3d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b40:	50                   	push   %eax
  800b41:	ff 75 08             	pushl  0x8(%ebp)
  800b44:	e8 19 fc ff ff       	call   800762 <fd_lookup>
  800b49:	83 c4 08             	add    $0x8,%esp
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	78 0e                	js     800b5e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b50:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b56:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5e:	c9                   	leave  
  800b5f:	c3                   	ret    

00800b60 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	53                   	push   %ebx
  800b64:	83 ec 14             	sub    $0x14,%esp
  800b67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b6d:	50                   	push   %eax
  800b6e:	53                   	push   %ebx
  800b6f:	e8 ee fb ff ff       	call   800762 <fd_lookup>
  800b74:	83 c4 08             	add    $0x8,%esp
  800b77:	89 c2                	mov    %eax,%edx
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	78 68                	js     800be5 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b7d:	83 ec 08             	sub    $0x8,%esp
  800b80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b83:	50                   	push   %eax
  800b84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b87:	ff 30                	pushl  (%eax)
  800b89:	e8 2a fc ff ff       	call   8007b8 <dev_lookup>
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	85 c0                	test   %eax,%eax
  800b93:	78 47                	js     800bdc <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b98:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b9c:	75 24                	jne    800bc2 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b9e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800ba3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800ba9:	83 ec 04             	sub    $0x4,%esp
  800bac:	53                   	push   %ebx
  800bad:	50                   	push   %eax
  800bae:	68 f4 22 80 00       	push   $0x8022f4
  800bb3:	e8 0c 09 00 00       	call   8014c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800bb8:	83 c4 10             	add    $0x10,%esp
  800bbb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bc0:	eb 23                	jmp    800be5 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800bc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bc5:	8b 52 18             	mov    0x18(%edx),%edx
  800bc8:	85 d2                	test   %edx,%edx
  800bca:	74 14                	je     800be0 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800bcc:	83 ec 08             	sub    $0x8,%esp
  800bcf:	ff 75 0c             	pushl  0xc(%ebp)
  800bd2:	50                   	push   %eax
  800bd3:	ff d2                	call   *%edx
  800bd5:	89 c2                	mov    %eax,%edx
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	eb 09                	jmp    800be5 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bdc:	89 c2                	mov    %eax,%edx
  800bde:	eb 05                	jmp    800be5 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800be0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800be5:	89 d0                	mov    %edx,%eax
  800be7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 14             	sub    $0x14,%esp
  800bf3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bf6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bf9:	50                   	push   %eax
  800bfa:	ff 75 08             	pushl  0x8(%ebp)
  800bfd:	e8 60 fb ff ff       	call   800762 <fd_lookup>
  800c02:	83 c4 08             	add    $0x8,%esp
  800c05:	89 c2                	mov    %eax,%edx
  800c07:	85 c0                	test   %eax,%eax
  800c09:	78 58                	js     800c63 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c0b:	83 ec 08             	sub    $0x8,%esp
  800c0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c11:	50                   	push   %eax
  800c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c15:	ff 30                	pushl  (%eax)
  800c17:	e8 9c fb ff ff       	call   8007b8 <dev_lookup>
  800c1c:	83 c4 10             	add    $0x10,%esp
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	78 37                	js     800c5a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c26:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c2a:	74 32                	je     800c5e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c2c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c2f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c36:	00 00 00 
	stat->st_isdir = 0;
  800c39:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c40:	00 00 00 
	stat->st_dev = dev;
  800c43:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c49:	83 ec 08             	sub    $0x8,%esp
  800c4c:	53                   	push   %ebx
  800c4d:	ff 75 f0             	pushl  -0x10(%ebp)
  800c50:	ff 50 14             	call   *0x14(%eax)
  800c53:	89 c2                	mov    %eax,%edx
  800c55:	83 c4 10             	add    $0x10,%esp
  800c58:	eb 09                	jmp    800c63 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c5a:	89 c2                	mov    %eax,%edx
  800c5c:	eb 05                	jmp    800c63 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c5e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c63:	89 d0                	mov    %edx,%eax
  800c65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c6f:	83 ec 08             	sub    $0x8,%esp
  800c72:	6a 00                	push   $0x0
  800c74:	ff 75 08             	pushl  0x8(%ebp)
  800c77:	e8 e3 01 00 00       	call   800e5f <open>
  800c7c:	89 c3                	mov    %eax,%ebx
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	85 c0                	test   %eax,%eax
  800c83:	78 1b                	js     800ca0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c85:	83 ec 08             	sub    $0x8,%esp
  800c88:	ff 75 0c             	pushl  0xc(%ebp)
  800c8b:	50                   	push   %eax
  800c8c:	e8 5b ff ff ff       	call   800bec <fstat>
  800c91:	89 c6                	mov    %eax,%esi
	close(fd);
  800c93:	89 1c 24             	mov    %ebx,(%esp)
  800c96:	e8 f4 fb ff ff       	call   80088f <close>
	return r;
  800c9b:	83 c4 10             	add    $0x10,%esp
  800c9e:	89 f0                	mov    %esi,%eax
}
  800ca0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	89 c6                	mov    %eax,%esi
  800cae:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800cb0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cb7:	75 12                	jne    800ccb <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	6a 01                	push   $0x1
  800cbe:	e8 39 12 00 00       	call   801efc <ipc_find_env>
  800cc3:	a3 00 40 80 00       	mov    %eax,0x804000
  800cc8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ccb:	6a 07                	push   $0x7
  800ccd:	68 00 50 80 00       	push   $0x805000
  800cd2:	56                   	push   %esi
  800cd3:	ff 35 00 40 80 00    	pushl  0x804000
  800cd9:	e8 bc 11 00 00       	call   801e9a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800cde:	83 c4 0c             	add    $0xc,%esp
  800ce1:	6a 00                	push   $0x0
  800ce3:	53                   	push   %ebx
  800ce4:	6a 00                	push   $0x0
  800ce6:	e8 34 11 00 00       	call   801e1f <ipc_recv>
}
  800ceb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfb:	8b 40 0c             	mov    0xc(%eax),%eax
  800cfe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d06:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 02 00 00 00       	mov    $0x2,%eax
  800d15:	e8 8d ff ff ff       	call   800ca7 <fsipc>
}
  800d1a:	c9                   	leave  
  800d1b:	c3                   	ret    

00800d1c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d22:	8b 45 08             	mov    0x8(%ebp),%eax
  800d25:	8b 40 0c             	mov    0xc(%eax),%eax
  800d28:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d32:	b8 06 00 00 00       	mov    $0x6,%eax
  800d37:	e8 6b ff ff ff       	call   800ca7 <fsipc>
}
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    

00800d3e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	53                   	push   %ebx
  800d42:	83 ec 04             	sub    $0x4,%esp
  800d45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	8b 40 0c             	mov    0xc(%eax),%eax
  800d4e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d53:	ba 00 00 00 00       	mov    $0x0,%edx
  800d58:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5d:	e8 45 ff ff ff       	call   800ca7 <fsipc>
  800d62:	85 c0                	test   %eax,%eax
  800d64:	78 2c                	js     800d92 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d66:	83 ec 08             	sub    $0x8,%esp
  800d69:	68 00 50 80 00       	push   $0x805000
  800d6e:	53                   	push   %ebx
  800d6f:	e8 d5 0c 00 00       	call   801a49 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d74:	a1 80 50 80 00       	mov    0x805080,%eax
  800d79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d7f:	a1 84 50 80 00       	mov    0x805084,%eax
  800d84:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d8a:	83 c4 10             	add    $0x10,%esp
  800d8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	83 ec 0c             	sub    $0xc,%esp
  800d9d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	8b 52 0c             	mov    0xc(%edx),%edx
  800da6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800dac:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800db1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800db6:	0f 47 c2             	cmova  %edx,%eax
  800db9:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800dbe:	50                   	push   %eax
  800dbf:	ff 75 0c             	pushl  0xc(%ebp)
  800dc2:	68 08 50 80 00       	push   $0x805008
  800dc7:	e8 0f 0e 00 00       	call   801bdb <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800dcc:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800dd6:	e8 cc fe ff ff       	call   800ca7 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800ddb:	c9                   	leave  
  800ddc:	c3                   	ret    

00800ddd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	8b 40 0c             	mov    0xc(%eax),%eax
  800deb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800df0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800df6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfb:	b8 03 00 00 00       	mov    $0x3,%eax
  800e00:	e8 a2 fe ff ff       	call   800ca7 <fsipc>
  800e05:	89 c3                	mov    %eax,%ebx
  800e07:	85 c0                	test   %eax,%eax
  800e09:	78 4b                	js     800e56 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e0b:	39 c6                	cmp    %eax,%esi
  800e0d:	73 16                	jae    800e25 <devfile_read+0x48>
  800e0f:	68 60 23 80 00       	push   $0x802360
  800e14:	68 67 23 80 00       	push   $0x802367
  800e19:	6a 7c                	push   $0x7c
  800e1b:	68 7c 23 80 00       	push   $0x80237c
  800e20:	e8 c6 05 00 00       	call   8013eb <_panic>
	assert(r <= PGSIZE);
  800e25:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e2a:	7e 16                	jle    800e42 <devfile_read+0x65>
  800e2c:	68 87 23 80 00       	push   $0x802387
  800e31:	68 67 23 80 00       	push   $0x802367
  800e36:	6a 7d                	push   $0x7d
  800e38:	68 7c 23 80 00       	push   $0x80237c
  800e3d:	e8 a9 05 00 00       	call   8013eb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e42:	83 ec 04             	sub    $0x4,%esp
  800e45:	50                   	push   %eax
  800e46:	68 00 50 80 00       	push   $0x805000
  800e4b:	ff 75 0c             	pushl  0xc(%ebp)
  800e4e:	e8 88 0d 00 00       	call   801bdb <memmove>
	return r;
  800e53:	83 c4 10             	add    $0x10,%esp
}
  800e56:	89 d8                	mov    %ebx,%eax
  800e58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    

00800e5f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	53                   	push   %ebx
  800e63:	83 ec 20             	sub    $0x20,%esp
  800e66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e69:	53                   	push   %ebx
  800e6a:	e8 a1 0b 00 00       	call   801a10 <strlen>
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e77:	7f 67                	jg     800ee0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7f:	50                   	push   %eax
  800e80:	e8 8e f8 ff ff       	call   800713 <fd_alloc>
  800e85:	83 c4 10             	add    $0x10,%esp
		return r;
  800e88:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	78 57                	js     800ee5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	53                   	push   %ebx
  800e92:	68 00 50 80 00       	push   $0x805000
  800e97:	e8 ad 0b 00 00       	call   801a49 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ea4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ea7:	b8 01 00 00 00       	mov    $0x1,%eax
  800eac:	e8 f6 fd ff ff       	call   800ca7 <fsipc>
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	79 14                	jns    800ece <open+0x6f>
		fd_close(fd, 0);
  800eba:	83 ec 08             	sub    $0x8,%esp
  800ebd:	6a 00                	push   $0x0
  800ebf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec2:	e8 47 f9 ff ff       	call   80080e <fd_close>
		return r;
  800ec7:	83 c4 10             	add    $0x10,%esp
  800eca:	89 da                	mov    %ebx,%edx
  800ecc:	eb 17                	jmp    800ee5 <open+0x86>
	}

	return fd2num(fd);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed4:	e8 13 f8 ff ff       	call   8006ec <fd2num>
  800ed9:	89 c2                	mov    %eax,%edx
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	eb 05                	jmp    800ee5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ee0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ee5:	89 d0                	mov    %edx,%eax
  800ee7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ef2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef7:	b8 08 00 00 00       	mov    $0x8,%eax
  800efc:	e8 a6 fd ff ff       	call   800ca7 <fsipc>
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f0b:	83 ec 0c             	sub    $0xc,%esp
  800f0e:	ff 75 08             	pushl  0x8(%ebp)
  800f11:	e8 e6 f7 ff ff       	call   8006fc <fd2data>
  800f16:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f18:	83 c4 08             	add    $0x8,%esp
  800f1b:	68 93 23 80 00       	push   $0x802393
  800f20:	53                   	push   %ebx
  800f21:	e8 23 0b 00 00       	call   801a49 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f26:	8b 46 04             	mov    0x4(%esi),%eax
  800f29:	2b 06                	sub    (%esi),%eax
  800f2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f31:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f38:	00 00 00 
	stat->st_dev = &devpipe;
  800f3b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f42:	30 80 00 
	return 0;
}
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	53                   	push   %ebx
  800f55:	83 ec 0c             	sub    $0xc,%esp
  800f58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f5b:	53                   	push   %ebx
  800f5c:	6a 00                	push   $0x0
  800f5e:	e8 a3 f2 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f63:	89 1c 24             	mov    %ebx,(%esp)
  800f66:	e8 91 f7 ff ff       	call   8006fc <fd2data>
  800f6b:	83 c4 08             	add    $0x8,%esp
  800f6e:	50                   	push   %eax
  800f6f:	6a 00                	push   $0x0
  800f71:	e8 90 f2 ff ff       	call   800206 <sys_page_unmap>
}
  800f76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	57                   	push   %edi
  800f7f:	56                   	push   %esi
  800f80:	53                   	push   %ebx
  800f81:	83 ec 1c             	sub    $0x1c,%esp
  800f84:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f87:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f89:	a1 04 40 80 00       	mov    0x804004,%eax
  800f8e:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f94:	83 ec 0c             	sub    $0xc,%esp
  800f97:	ff 75 e0             	pushl  -0x20(%ebp)
  800f9a:	e8 a2 0f 00 00       	call   801f41 <pageref>
  800f9f:	89 c3                	mov    %eax,%ebx
  800fa1:	89 3c 24             	mov    %edi,(%esp)
  800fa4:	e8 98 0f 00 00       	call   801f41 <pageref>
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	39 c3                	cmp    %eax,%ebx
  800fae:	0f 94 c1             	sete   %cl
  800fb1:	0f b6 c9             	movzbl %cl,%ecx
  800fb4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800fb7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fbd:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  800fc3:	39 ce                	cmp    %ecx,%esi
  800fc5:	74 1e                	je     800fe5 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800fc7:	39 c3                	cmp    %eax,%ebx
  800fc9:	75 be                	jne    800f89 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fcb:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  800fd1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd4:	50                   	push   %eax
  800fd5:	56                   	push   %esi
  800fd6:	68 9a 23 80 00       	push   $0x80239a
  800fdb:	e8 e4 04 00 00       	call   8014c4 <cprintf>
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	eb a4                	jmp    800f89 <_pipeisclosed+0xe>
	}
}
  800fe5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	53                   	push   %ebx
  800ff6:	83 ec 28             	sub    $0x28,%esp
  800ff9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800ffc:	56                   	push   %esi
  800ffd:	e8 fa f6 ff ff       	call   8006fc <fd2data>
  801002:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	bf 00 00 00 00       	mov    $0x0,%edi
  80100c:	eb 4b                	jmp    801059 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80100e:	89 da                	mov    %ebx,%edx
  801010:	89 f0                	mov    %esi,%eax
  801012:	e8 64 ff ff ff       	call   800f7b <_pipeisclosed>
  801017:	85 c0                	test   %eax,%eax
  801019:	75 48                	jne    801063 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80101b:	e8 42 f1 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801020:	8b 43 04             	mov    0x4(%ebx),%eax
  801023:	8b 0b                	mov    (%ebx),%ecx
  801025:	8d 51 20             	lea    0x20(%ecx),%edx
  801028:	39 d0                	cmp    %edx,%eax
  80102a:	73 e2                	jae    80100e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80102c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80102f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801033:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801036:	89 c2                	mov    %eax,%edx
  801038:	c1 fa 1f             	sar    $0x1f,%edx
  80103b:	89 d1                	mov    %edx,%ecx
  80103d:	c1 e9 1b             	shr    $0x1b,%ecx
  801040:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801043:	83 e2 1f             	and    $0x1f,%edx
  801046:	29 ca                	sub    %ecx,%edx
  801048:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80104c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801050:	83 c0 01             	add    $0x1,%eax
  801053:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801056:	83 c7 01             	add    $0x1,%edi
  801059:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80105c:	75 c2                	jne    801020 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80105e:	8b 45 10             	mov    0x10(%ebp),%eax
  801061:	eb 05                	jmp    801068 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801063:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801068:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 18             	sub    $0x18,%esp
  801079:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80107c:	57                   	push   %edi
  80107d:	e8 7a f6 ff ff       	call   8006fc <fd2data>
  801082:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	bb 00 00 00 00       	mov    $0x0,%ebx
  80108c:	eb 3d                	jmp    8010cb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80108e:	85 db                	test   %ebx,%ebx
  801090:	74 04                	je     801096 <devpipe_read+0x26>
				return i;
  801092:	89 d8                	mov    %ebx,%eax
  801094:	eb 44                	jmp    8010da <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801096:	89 f2                	mov    %esi,%edx
  801098:	89 f8                	mov    %edi,%eax
  80109a:	e8 dc fe ff ff       	call   800f7b <_pipeisclosed>
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	75 32                	jne    8010d5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8010a3:	e8 ba f0 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010a8:	8b 06                	mov    (%esi),%eax
  8010aa:	3b 46 04             	cmp    0x4(%esi),%eax
  8010ad:	74 df                	je     80108e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010af:	99                   	cltd   
  8010b0:	c1 ea 1b             	shr    $0x1b,%edx
  8010b3:	01 d0                	add    %edx,%eax
  8010b5:	83 e0 1f             	and    $0x1f,%eax
  8010b8:	29 d0                	sub    %edx,%eax
  8010ba:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010c5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010c8:	83 c3 01             	add    $0x1,%ebx
  8010cb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010ce:	75 d8                	jne    8010a8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d3:	eb 05                	jmp    8010da <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010d5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dd:	5b                   	pop    %ebx
  8010de:	5e                   	pop    %esi
  8010df:	5f                   	pop    %edi
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	56                   	push   %esi
  8010e6:	53                   	push   %ebx
  8010e7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	e8 20 f6 ff ff       	call   800713 <fd_alloc>
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	89 c2                	mov    %eax,%edx
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	0f 88 2c 01 00 00    	js     80122c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	68 07 04 00 00       	push   $0x407
  801108:	ff 75 f4             	pushl  -0xc(%ebp)
  80110b:	6a 00                	push   $0x0
  80110d:	e8 6f f0 ff ff       	call   800181 <sys_page_alloc>
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	89 c2                	mov    %eax,%edx
  801117:	85 c0                	test   %eax,%eax
  801119:	0f 88 0d 01 00 00    	js     80122c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	e8 e8 f5 ff ff       	call   800713 <fd_alloc>
  80112b:	89 c3                	mov    %eax,%ebx
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	0f 88 e2 00 00 00    	js     80121a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801138:	83 ec 04             	sub    $0x4,%esp
  80113b:	68 07 04 00 00       	push   $0x407
  801140:	ff 75 f0             	pushl  -0x10(%ebp)
  801143:	6a 00                	push   $0x0
  801145:	e8 37 f0 ff ff       	call   800181 <sys_page_alloc>
  80114a:	89 c3                	mov    %eax,%ebx
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	0f 88 c3 00 00 00    	js     80121a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801157:	83 ec 0c             	sub    $0xc,%esp
  80115a:	ff 75 f4             	pushl  -0xc(%ebp)
  80115d:	e8 9a f5 ff ff       	call   8006fc <fd2data>
  801162:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801164:	83 c4 0c             	add    $0xc,%esp
  801167:	68 07 04 00 00       	push   $0x407
  80116c:	50                   	push   %eax
  80116d:	6a 00                	push   $0x0
  80116f:	e8 0d f0 ff ff       	call   800181 <sys_page_alloc>
  801174:	89 c3                	mov    %eax,%ebx
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	85 c0                	test   %eax,%eax
  80117b:	0f 88 89 00 00 00    	js     80120a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	ff 75 f0             	pushl  -0x10(%ebp)
  801187:	e8 70 f5 ff ff       	call   8006fc <fd2data>
  80118c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801193:	50                   	push   %eax
  801194:	6a 00                	push   $0x0
  801196:	56                   	push   %esi
  801197:	6a 00                	push   $0x0
  801199:	e8 26 f0 ff ff       	call   8001c4 <sys_page_map>
  80119e:	89 c3                	mov    %eax,%ebx
  8011a0:	83 c4 20             	add    $0x20,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 55                	js     8011fc <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8011a7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011bc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011d1:	83 ec 0c             	sub    $0xc,%esp
  8011d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d7:	e8 10 f5 ff ff       	call   8006ec <fd2num>
  8011dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011df:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011e1:	83 c4 04             	add    $0x4,%esp
  8011e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8011e7:	e8 00 f5 ff ff       	call   8006ec <fd2num>
  8011ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ef:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fa:	eb 30                	jmp    80122c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011fc:	83 ec 08             	sub    $0x8,%esp
  8011ff:	56                   	push   %esi
  801200:	6a 00                	push   $0x0
  801202:	e8 ff ef ff ff       	call   800206 <sys_page_unmap>
  801207:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80120a:	83 ec 08             	sub    $0x8,%esp
  80120d:	ff 75 f0             	pushl  -0x10(%ebp)
  801210:	6a 00                	push   $0x0
  801212:	e8 ef ef ff ff       	call   800206 <sys_page_unmap>
  801217:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80121a:	83 ec 08             	sub    $0x8,%esp
  80121d:	ff 75 f4             	pushl  -0xc(%ebp)
  801220:	6a 00                	push   $0x0
  801222:	e8 df ef ff ff       	call   800206 <sys_page_unmap>
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80122c:	89 d0                	mov    %edx,%eax
  80122e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801231:	5b                   	pop    %ebx
  801232:	5e                   	pop    %esi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123e:	50                   	push   %eax
  80123f:	ff 75 08             	pushl  0x8(%ebp)
  801242:	e8 1b f5 ff ff       	call   800762 <fd_lookup>
  801247:	83 c4 10             	add    $0x10,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	78 18                	js     801266 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	ff 75 f4             	pushl  -0xc(%ebp)
  801254:	e8 a3 f4 ff ff       	call   8006fc <fd2data>
	return _pipeisclosed(fd, p);
  801259:	89 c2                	mov    %eax,%edx
  80125b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125e:	e8 18 fd ff ff       	call   800f7b <_pipeisclosed>
  801263:	83 c4 10             	add    $0x10,%esp
}
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80126b:	b8 00 00 00 00       	mov    $0x0,%eax
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801278:	68 b2 23 80 00       	push   $0x8023b2
  80127d:	ff 75 0c             	pushl  0xc(%ebp)
  801280:	e8 c4 07 00 00       	call   801a49 <strcpy>
	return 0;
}
  801285:	b8 00 00 00 00       	mov    $0x0,%eax
  80128a:	c9                   	leave  
  80128b:	c3                   	ret    

0080128c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	57                   	push   %edi
  801290:	56                   	push   %esi
  801291:	53                   	push   %ebx
  801292:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801298:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80129d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012a3:	eb 2d                	jmp    8012d2 <devcons_write+0x46>
		m = n - tot;
  8012a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012a8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8012aa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012ad:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8012b2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012b5:	83 ec 04             	sub    $0x4,%esp
  8012b8:	53                   	push   %ebx
  8012b9:	03 45 0c             	add    0xc(%ebp),%eax
  8012bc:	50                   	push   %eax
  8012bd:	57                   	push   %edi
  8012be:	e8 18 09 00 00       	call   801bdb <memmove>
		sys_cputs(buf, m);
  8012c3:	83 c4 08             	add    $0x8,%esp
  8012c6:	53                   	push   %ebx
  8012c7:	57                   	push   %edi
  8012c8:	e8 f8 ed ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012cd:	01 de                	add    %ebx,%esi
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	89 f0                	mov    %esi,%eax
  8012d4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012d7:	72 cc                	jb     8012a5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012dc:	5b                   	pop    %ebx
  8012dd:	5e                   	pop    %esi
  8012de:	5f                   	pop    %edi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012f0:	74 2a                	je     80131c <devcons_read+0x3b>
  8012f2:	eb 05                	jmp    8012f9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012f4:	e8 69 ee ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012f9:	e8 e5 ed ff ff       	call   8000e3 <sys_cgetc>
  8012fe:	85 c0                	test   %eax,%eax
  801300:	74 f2                	je     8012f4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801302:	85 c0                	test   %eax,%eax
  801304:	78 16                	js     80131c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801306:	83 f8 04             	cmp    $0x4,%eax
  801309:	74 0c                	je     801317 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80130b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130e:	88 02                	mov    %al,(%edx)
	return 1;
  801310:	b8 01 00 00 00       	mov    $0x1,%eax
  801315:	eb 05                	jmp    80131c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801317:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801324:	8b 45 08             	mov    0x8(%ebp),%eax
  801327:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80132a:	6a 01                	push   $0x1
  80132c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	e8 90 ed ff ff       	call   8000c5 <sys_cputs>
}
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <getchar>:

int
getchar(void)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801340:	6a 01                	push   $0x1
  801342:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801345:	50                   	push   %eax
  801346:	6a 00                	push   $0x0
  801348:	e8 7e f6 ff ff       	call   8009cb <read>
	if (r < 0)
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	85 c0                	test   %eax,%eax
  801352:	78 0f                	js     801363 <getchar+0x29>
		return r;
	if (r < 1)
  801354:	85 c0                	test   %eax,%eax
  801356:	7e 06                	jle    80135e <getchar+0x24>
		return -E_EOF;
	return c;
  801358:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80135c:	eb 05                	jmp    801363 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80135e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801363:	c9                   	leave  
  801364:	c3                   	ret    

00801365 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80136b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	ff 75 08             	pushl  0x8(%ebp)
  801372:	e8 eb f3 ff ff       	call   800762 <fd_lookup>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 11                	js     80138f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80137e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801381:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801387:	39 10                	cmp    %edx,(%eax)
  801389:	0f 94 c0             	sete   %al
  80138c:	0f b6 c0             	movzbl %al,%eax
}
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <opencons>:

int
opencons(void)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	e8 73 f3 ff ff       	call   800713 <fd_alloc>
  8013a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8013a3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 3e                	js     8013e7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013a9:	83 ec 04             	sub    $0x4,%esp
  8013ac:	68 07 04 00 00       	push   $0x407
  8013b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b4:	6a 00                	push   $0x0
  8013b6:	e8 c6 ed ff ff       	call   800181 <sys_page_alloc>
  8013bb:	83 c4 10             	add    $0x10,%esp
		return r;
  8013be:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 23                	js     8013e7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013c4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013d9:	83 ec 0c             	sub    $0xc,%esp
  8013dc:	50                   	push   %eax
  8013dd:	e8 0a f3 ff ff       	call   8006ec <fd2num>
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	83 c4 10             	add    $0x10,%esp
}
  8013e7:	89 d0                	mov    %edx,%eax
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	56                   	push   %esi
  8013ef:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013f0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013f3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013f9:	e8 45 ed ff ff       	call   800143 <sys_getenvid>
  8013fe:	83 ec 0c             	sub    $0xc,%esp
  801401:	ff 75 0c             	pushl  0xc(%ebp)
  801404:	ff 75 08             	pushl  0x8(%ebp)
  801407:	56                   	push   %esi
  801408:	50                   	push   %eax
  801409:	68 c0 23 80 00       	push   $0x8023c0
  80140e:	e8 b1 00 00 00       	call   8014c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801413:	83 c4 18             	add    $0x18,%esp
  801416:	53                   	push   %ebx
  801417:	ff 75 10             	pushl  0x10(%ebp)
  80141a:	e8 54 00 00 00       	call   801473 <vcprintf>
	cprintf("\n");
  80141f:	c7 04 24 ab 23 80 00 	movl   $0x8023ab,(%esp)
  801426:	e8 99 00 00 00       	call   8014c4 <cprintf>
  80142b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80142e:	cc                   	int3   
  80142f:	eb fd                	jmp    80142e <_panic+0x43>

00801431 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	53                   	push   %ebx
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80143b:	8b 13                	mov    (%ebx),%edx
  80143d:	8d 42 01             	lea    0x1(%edx),%eax
  801440:	89 03                	mov    %eax,(%ebx)
  801442:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801445:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801449:	3d ff 00 00 00       	cmp    $0xff,%eax
  80144e:	75 1a                	jne    80146a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801450:	83 ec 08             	sub    $0x8,%esp
  801453:	68 ff 00 00 00       	push   $0xff
  801458:	8d 43 08             	lea    0x8(%ebx),%eax
  80145b:	50                   	push   %eax
  80145c:	e8 64 ec ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  801461:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801467:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80146a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80146e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80147c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801483:	00 00 00 
	b.cnt = 0;
  801486:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80148d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801490:	ff 75 0c             	pushl  0xc(%ebp)
  801493:	ff 75 08             	pushl  0x8(%ebp)
  801496:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	68 31 14 80 00       	push   $0x801431
  8014a2:	e8 54 01 00 00       	call   8015fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014a7:	83 c4 08             	add    $0x8,%esp
  8014aa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014b6:	50                   	push   %eax
  8014b7:	e8 09 ec ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  8014bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    

008014c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014cd:	50                   	push   %eax
  8014ce:	ff 75 08             	pushl  0x8(%ebp)
  8014d1:	e8 9d ff ff ff       	call   801473 <vcprintf>
	va_end(ap);

	return cnt;
}
  8014d6:	c9                   	leave  
  8014d7:	c3                   	ret    

008014d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	57                   	push   %edi
  8014dc:	56                   	push   %esi
  8014dd:	53                   	push   %ebx
  8014de:	83 ec 1c             	sub    $0x1c,%esp
  8014e1:	89 c7                	mov    %eax,%edi
  8014e3:	89 d6                	mov    %edx,%esi
  8014e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014fc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014ff:	39 d3                	cmp    %edx,%ebx
  801501:	72 05                	jb     801508 <printnum+0x30>
  801503:	39 45 10             	cmp    %eax,0x10(%ebp)
  801506:	77 45                	ja     80154d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801508:	83 ec 0c             	sub    $0xc,%esp
  80150b:	ff 75 18             	pushl  0x18(%ebp)
  80150e:	8b 45 14             	mov    0x14(%ebp),%eax
  801511:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801514:	53                   	push   %ebx
  801515:	ff 75 10             	pushl  0x10(%ebp)
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80151e:	ff 75 e0             	pushl  -0x20(%ebp)
  801521:	ff 75 dc             	pushl  -0x24(%ebp)
  801524:	ff 75 d8             	pushl  -0x28(%ebp)
  801527:	e8 54 0a 00 00       	call   801f80 <__udivdi3>
  80152c:	83 c4 18             	add    $0x18,%esp
  80152f:	52                   	push   %edx
  801530:	50                   	push   %eax
  801531:	89 f2                	mov    %esi,%edx
  801533:	89 f8                	mov    %edi,%eax
  801535:	e8 9e ff ff ff       	call   8014d8 <printnum>
  80153a:	83 c4 20             	add    $0x20,%esp
  80153d:	eb 18                	jmp    801557 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80153f:	83 ec 08             	sub    $0x8,%esp
  801542:	56                   	push   %esi
  801543:	ff 75 18             	pushl  0x18(%ebp)
  801546:	ff d7                	call   *%edi
  801548:	83 c4 10             	add    $0x10,%esp
  80154b:	eb 03                	jmp    801550 <printnum+0x78>
  80154d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801550:	83 eb 01             	sub    $0x1,%ebx
  801553:	85 db                	test   %ebx,%ebx
  801555:	7f e8                	jg     80153f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801557:	83 ec 08             	sub    $0x8,%esp
  80155a:	56                   	push   %esi
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801561:	ff 75 e0             	pushl  -0x20(%ebp)
  801564:	ff 75 dc             	pushl  -0x24(%ebp)
  801567:	ff 75 d8             	pushl  -0x28(%ebp)
  80156a:	e8 41 0b 00 00       	call   8020b0 <__umoddi3>
  80156f:	83 c4 14             	add    $0x14,%esp
  801572:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801579:	50                   	push   %eax
  80157a:	ff d7                	call   *%edi
}
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801582:	5b                   	pop    %ebx
  801583:	5e                   	pop    %esi
  801584:	5f                   	pop    %edi
  801585:	5d                   	pop    %ebp
  801586:	c3                   	ret    

00801587 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80158a:	83 fa 01             	cmp    $0x1,%edx
  80158d:	7e 0e                	jle    80159d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80158f:	8b 10                	mov    (%eax),%edx
  801591:	8d 4a 08             	lea    0x8(%edx),%ecx
  801594:	89 08                	mov    %ecx,(%eax)
  801596:	8b 02                	mov    (%edx),%eax
  801598:	8b 52 04             	mov    0x4(%edx),%edx
  80159b:	eb 22                	jmp    8015bf <getuint+0x38>
	else if (lflag)
  80159d:	85 d2                	test   %edx,%edx
  80159f:	74 10                	je     8015b1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8015a1:	8b 10                	mov    (%eax),%edx
  8015a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015a6:	89 08                	mov    %ecx,(%eax)
  8015a8:	8b 02                	mov    (%edx),%eax
  8015aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8015af:	eb 0e                	jmp    8015bf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015b1:	8b 10                	mov    (%eax),%edx
  8015b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015b6:	89 08                	mov    %ecx,(%eax)
  8015b8:	8b 02                	mov    (%edx),%eax
  8015ba:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    

008015c1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015c7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015cb:	8b 10                	mov    (%eax),%edx
  8015cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8015d0:	73 0a                	jae    8015dc <sprintputch+0x1b>
		*b->buf++ = ch;
  8015d2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015d5:	89 08                	mov    %ecx,(%eax)
  8015d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015da:	88 02                	mov    %al,(%edx)
}
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015e7:	50                   	push   %eax
  8015e8:	ff 75 10             	pushl  0x10(%ebp)
  8015eb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ee:	ff 75 08             	pushl  0x8(%ebp)
  8015f1:	e8 05 00 00 00       	call   8015fb <vprintfmt>
	va_end(ap);
}
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	57                   	push   %edi
  8015ff:	56                   	push   %esi
  801600:	53                   	push   %ebx
  801601:	83 ec 2c             	sub    $0x2c,%esp
  801604:	8b 75 08             	mov    0x8(%ebp),%esi
  801607:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80160a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80160d:	eb 12                	jmp    801621 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80160f:	85 c0                	test   %eax,%eax
  801611:	0f 84 89 03 00 00    	je     8019a0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	53                   	push   %ebx
  80161b:	50                   	push   %eax
  80161c:	ff d6                	call   *%esi
  80161e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801621:	83 c7 01             	add    $0x1,%edi
  801624:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801628:	83 f8 25             	cmp    $0x25,%eax
  80162b:	75 e2                	jne    80160f <vprintfmt+0x14>
  80162d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801631:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801638:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80163f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801646:	ba 00 00 00 00       	mov    $0x0,%edx
  80164b:	eb 07                	jmp    801654 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801650:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801654:	8d 47 01             	lea    0x1(%edi),%eax
  801657:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80165a:	0f b6 07             	movzbl (%edi),%eax
  80165d:	0f b6 c8             	movzbl %al,%ecx
  801660:	83 e8 23             	sub    $0x23,%eax
  801663:	3c 55                	cmp    $0x55,%al
  801665:	0f 87 1a 03 00 00    	ja     801985 <vprintfmt+0x38a>
  80166b:	0f b6 c0             	movzbl %al,%eax
  80166e:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801675:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801678:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80167c:	eb d6                	jmp    801654 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80167e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801681:	b8 00 00 00 00       	mov    $0x0,%eax
  801686:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801689:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80168c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801690:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801693:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801696:	83 fa 09             	cmp    $0x9,%edx
  801699:	77 39                	ja     8016d4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80169b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80169e:	eb e9                	jmp    801689 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8016a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a3:	8d 48 04             	lea    0x4(%eax),%ecx
  8016a6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8016a9:	8b 00                	mov    (%eax),%eax
  8016ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016b1:	eb 27                	jmp    8016da <vprintfmt+0xdf>
  8016b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016b6:	85 c0                	test   %eax,%eax
  8016b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016bd:	0f 49 c8             	cmovns %eax,%ecx
  8016c0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016c6:	eb 8c                	jmp    801654 <vprintfmt+0x59>
  8016c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8016cb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016d2:	eb 80                	jmp    801654 <vprintfmt+0x59>
  8016d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016de:	0f 89 70 ff ff ff    	jns    801654 <vprintfmt+0x59>
				width = precision, precision = -1;
  8016e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016f1:	e9 5e ff ff ff       	jmp    801654 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016f6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016fc:	e9 53 ff ff ff       	jmp    801654 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801701:	8b 45 14             	mov    0x14(%ebp),%eax
  801704:	8d 50 04             	lea    0x4(%eax),%edx
  801707:	89 55 14             	mov    %edx,0x14(%ebp)
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	53                   	push   %ebx
  80170e:	ff 30                	pushl  (%eax)
  801710:	ff d6                	call   *%esi
			break;
  801712:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801715:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801718:	e9 04 ff ff ff       	jmp    801621 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80171d:	8b 45 14             	mov    0x14(%ebp),%eax
  801720:	8d 50 04             	lea    0x4(%eax),%edx
  801723:	89 55 14             	mov    %edx,0x14(%ebp)
  801726:	8b 00                	mov    (%eax),%eax
  801728:	99                   	cltd   
  801729:	31 d0                	xor    %edx,%eax
  80172b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80172d:	83 f8 0f             	cmp    $0xf,%eax
  801730:	7f 0b                	jg     80173d <vprintfmt+0x142>
  801732:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801739:	85 d2                	test   %edx,%edx
  80173b:	75 18                	jne    801755 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80173d:	50                   	push   %eax
  80173e:	68 fb 23 80 00       	push   $0x8023fb
  801743:	53                   	push   %ebx
  801744:	56                   	push   %esi
  801745:	e8 94 fe ff ff       	call   8015de <printfmt>
  80174a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801750:	e9 cc fe ff ff       	jmp    801621 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801755:	52                   	push   %edx
  801756:	68 79 23 80 00       	push   $0x802379
  80175b:	53                   	push   %ebx
  80175c:	56                   	push   %esi
  80175d:	e8 7c fe ff ff       	call   8015de <printfmt>
  801762:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801765:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801768:	e9 b4 fe ff ff       	jmp    801621 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80176d:	8b 45 14             	mov    0x14(%ebp),%eax
  801770:	8d 50 04             	lea    0x4(%eax),%edx
  801773:	89 55 14             	mov    %edx,0x14(%ebp)
  801776:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801778:	85 ff                	test   %edi,%edi
  80177a:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80177f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801782:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801786:	0f 8e 94 00 00 00    	jle    801820 <vprintfmt+0x225>
  80178c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801790:	0f 84 98 00 00 00    	je     80182e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801796:	83 ec 08             	sub    $0x8,%esp
  801799:	ff 75 d0             	pushl  -0x30(%ebp)
  80179c:	57                   	push   %edi
  80179d:	e8 86 02 00 00       	call   801a28 <strnlen>
  8017a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017a5:	29 c1                	sub    %eax,%ecx
  8017a7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8017aa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017ad:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017b4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017b7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017b9:	eb 0f                	jmp    8017ca <vprintfmt+0x1cf>
					putch(padc, putdat);
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	53                   	push   %ebx
  8017bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8017c2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017c4:	83 ef 01             	sub    $0x1,%edi
  8017c7:	83 c4 10             	add    $0x10,%esp
  8017ca:	85 ff                	test   %edi,%edi
  8017cc:	7f ed                	jg     8017bb <vprintfmt+0x1c0>
  8017ce:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017d1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017d4:	85 c9                	test   %ecx,%ecx
  8017d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8017db:	0f 49 c1             	cmovns %ecx,%eax
  8017de:	29 c1                	sub    %eax,%ecx
  8017e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8017e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017e9:	89 cb                	mov    %ecx,%ebx
  8017eb:	eb 4d                	jmp    80183a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017f1:	74 1b                	je     80180e <vprintfmt+0x213>
  8017f3:	0f be c0             	movsbl %al,%eax
  8017f6:	83 e8 20             	sub    $0x20,%eax
  8017f9:	83 f8 5e             	cmp    $0x5e,%eax
  8017fc:	76 10                	jbe    80180e <vprintfmt+0x213>
					putch('?', putdat);
  8017fe:	83 ec 08             	sub    $0x8,%esp
  801801:	ff 75 0c             	pushl  0xc(%ebp)
  801804:	6a 3f                	push   $0x3f
  801806:	ff 55 08             	call   *0x8(%ebp)
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	eb 0d                	jmp    80181b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	ff 75 0c             	pushl  0xc(%ebp)
  801814:	52                   	push   %edx
  801815:	ff 55 08             	call   *0x8(%ebp)
  801818:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80181b:	83 eb 01             	sub    $0x1,%ebx
  80181e:	eb 1a                	jmp    80183a <vprintfmt+0x23f>
  801820:	89 75 08             	mov    %esi,0x8(%ebp)
  801823:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801826:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801829:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80182c:	eb 0c                	jmp    80183a <vprintfmt+0x23f>
  80182e:	89 75 08             	mov    %esi,0x8(%ebp)
  801831:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801834:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801837:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80183a:	83 c7 01             	add    $0x1,%edi
  80183d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801841:	0f be d0             	movsbl %al,%edx
  801844:	85 d2                	test   %edx,%edx
  801846:	74 23                	je     80186b <vprintfmt+0x270>
  801848:	85 f6                	test   %esi,%esi
  80184a:	78 a1                	js     8017ed <vprintfmt+0x1f2>
  80184c:	83 ee 01             	sub    $0x1,%esi
  80184f:	79 9c                	jns    8017ed <vprintfmt+0x1f2>
  801851:	89 df                	mov    %ebx,%edi
  801853:	8b 75 08             	mov    0x8(%ebp),%esi
  801856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801859:	eb 18                	jmp    801873 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	53                   	push   %ebx
  80185f:	6a 20                	push   $0x20
  801861:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801863:	83 ef 01             	sub    $0x1,%edi
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	eb 08                	jmp    801873 <vprintfmt+0x278>
  80186b:	89 df                	mov    %ebx,%edi
  80186d:	8b 75 08             	mov    0x8(%ebp),%esi
  801870:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801873:	85 ff                	test   %edi,%edi
  801875:	7f e4                	jg     80185b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801877:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80187a:	e9 a2 fd ff ff       	jmp    801621 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80187f:	83 fa 01             	cmp    $0x1,%edx
  801882:	7e 16                	jle    80189a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801884:	8b 45 14             	mov    0x14(%ebp),%eax
  801887:	8d 50 08             	lea    0x8(%eax),%edx
  80188a:	89 55 14             	mov    %edx,0x14(%ebp)
  80188d:	8b 50 04             	mov    0x4(%eax),%edx
  801890:	8b 00                	mov    (%eax),%eax
  801892:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801895:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801898:	eb 32                	jmp    8018cc <vprintfmt+0x2d1>
	else if (lflag)
  80189a:	85 d2                	test   %edx,%edx
  80189c:	74 18                	je     8018b6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80189e:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a1:	8d 50 04             	lea    0x4(%eax),%edx
  8018a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a7:	8b 00                	mov    (%eax),%eax
  8018a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018ac:	89 c1                	mov    %eax,%ecx
  8018ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8018b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018b4:	eb 16                	jmp    8018cc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8018b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b9:	8d 50 04             	lea    0x4(%eax),%edx
  8018bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8018bf:	8b 00                	mov    (%eax),%eax
  8018c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018c4:	89 c1                	mov    %eax,%ecx
  8018c6:	c1 f9 1f             	sar    $0x1f,%ecx
  8018c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018d2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018db:	79 74                	jns    801951 <vprintfmt+0x356>
				putch('-', putdat);
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	53                   	push   %ebx
  8018e1:	6a 2d                	push   $0x2d
  8018e3:	ff d6                	call   *%esi
				num = -(long long) num;
  8018e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018eb:	f7 d8                	neg    %eax
  8018ed:	83 d2 00             	adc    $0x0,%edx
  8018f0:	f7 da                	neg    %edx
  8018f2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018fa:	eb 55                	jmp    801951 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8018ff:	e8 83 fc ff ff       	call   801587 <getuint>
			base = 10;
  801904:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801909:	eb 46                	jmp    801951 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80190b:	8d 45 14             	lea    0x14(%ebp),%eax
  80190e:	e8 74 fc ff ff       	call   801587 <getuint>
			base = 8;
  801913:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801918:	eb 37                	jmp    801951 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	53                   	push   %ebx
  80191e:	6a 30                	push   $0x30
  801920:	ff d6                	call   *%esi
			putch('x', putdat);
  801922:	83 c4 08             	add    $0x8,%esp
  801925:	53                   	push   %ebx
  801926:	6a 78                	push   $0x78
  801928:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80192a:	8b 45 14             	mov    0x14(%ebp),%eax
  80192d:	8d 50 04             	lea    0x4(%eax),%edx
  801930:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801933:	8b 00                	mov    (%eax),%eax
  801935:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80193a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80193d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801942:	eb 0d                	jmp    801951 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801944:	8d 45 14             	lea    0x14(%ebp),%eax
  801947:	e8 3b fc ff ff       	call   801587 <getuint>
			base = 16;
  80194c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801951:	83 ec 0c             	sub    $0xc,%esp
  801954:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801958:	57                   	push   %edi
  801959:	ff 75 e0             	pushl  -0x20(%ebp)
  80195c:	51                   	push   %ecx
  80195d:	52                   	push   %edx
  80195e:	50                   	push   %eax
  80195f:	89 da                	mov    %ebx,%edx
  801961:	89 f0                	mov    %esi,%eax
  801963:	e8 70 fb ff ff       	call   8014d8 <printnum>
			break;
  801968:	83 c4 20             	add    $0x20,%esp
  80196b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80196e:	e9 ae fc ff ff       	jmp    801621 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801973:	83 ec 08             	sub    $0x8,%esp
  801976:	53                   	push   %ebx
  801977:	51                   	push   %ecx
  801978:	ff d6                	call   *%esi
			break;
  80197a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801980:	e9 9c fc ff ff       	jmp    801621 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801985:	83 ec 08             	sub    $0x8,%esp
  801988:	53                   	push   %ebx
  801989:	6a 25                	push   $0x25
  80198b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	eb 03                	jmp    801995 <vprintfmt+0x39a>
  801992:	83 ef 01             	sub    $0x1,%edi
  801995:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801999:	75 f7                	jne    801992 <vprintfmt+0x397>
  80199b:	e9 81 fc ff ff       	jmp    801621 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8019a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a3:	5b                   	pop    %ebx
  8019a4:	5e                   	pop    %esi
  8019a5:	5f                   	pop    %edi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 18             	sub    $0x18,%esp
  8019ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019b7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019bb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	74 26                	je     8019ef <vsnprintf+0x47>
  8019c9:	85 d2                	test   %edx,%edx
  8019cb:	7e 22                	jle    8019ef <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019cd:	ff 75 14             	pushl  0x14(%ebp)
  8019d0:	ff 75 10             	pushl  0x10(%ebp)
  8019d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019d6:	50                   	push   %eax
  8019d7:	68 c1 15 80 00       	push   $0x8015c1
  8019dc:	e8 1a fc ff ff       	call   8015fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019e4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	eb 05                	jmp    8019f4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019f4:	c9                   	leave  
  8019f5:	c3                   	ret    

008019f6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019fc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019ff:	50                   	push   %eax
  801a00:	ff 75 10             	pushl  0x10(%ebp)
  801a03:	ff 75 0c             	pushl  0xc(%ebp)
  801a06:	ff 75 08             	pushl  0x8(%ebp)
  801a09:	e8 9a ff ff ff       	call   8019a8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a16:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1b:	eb 03                	jmp    801a20 <strlen+0x10>
		n++;
  801a1d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a20:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a24:	75 f7                	jne    801a1d <strlen+0xd>
		n++;
	return n;
}
  801a26:	5d                   	pop    %ebp
  801a27:	c3                   	ret    

00801a28 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	eb 03                	jmp    801a3b <strnlen+0x13>
		n++;
  801a38:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a3b:	39 c2                	cmp    %eax,%edx
  801a3d:	74 08                	je     801a47 <strnlen+0x1f>
  801a3f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a43:	75 f3                	jne    801a38 <strnlen+0x10>
  801a45:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a47:	5d                   	pop    %ebp
  801a48:	c3                   	ret    

00801a49 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	53                   	push   %ebx
  801a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a53:	89 c2                	mov    %eax,%edx
  801a55:	83 c2 01             	add    $0x1,%edx
  801a58:	83 c1 01             	add    $0x1,%ecx
  801a5b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a5f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a62:	84 db                	test   %bl,%bl
  801a64:	75 ef                	jne    801a55 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a66:	5b                   	pop    %ebx
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	53                   	push   %ebx
  801a6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a70:	53                   	push   %ebx
  801a71:	e8 9a ff ff ff       	call   801a10 <strlen>
  801a76:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a79:	ff 75 0c             	pushl  0xc(%ebp)
  801a7c:	01 d8                	add    %ebx,%eax
  801a7e:	50                   	push   %eax
  801a7f:	e8 c5 ff ff ff       	call   801a49 <strcpy>
	return dst;
}
  801a84:	89 d8                	mov    %ebx,%eax
  801a86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	8b 75 08             	mov    0x8(%ebp),%esi
  801a93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a96:	89 f3                	mov    %esi,%ebx
  801a98:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a9b:	89 f2                	mov    %esi,%edx
  801a9d:	eb 0f                	jmp    801aae <strncpy+0x23>
		*dst++ = *src;
  801a9f:	83 c2 01             	add    $0x1,%edx
  801aa2:	0f b6 01             	movzbl (%ecx),%eax
  801aa5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801aa8:	80 39 01             	cmpb   $0x1,(%ecx)
  801aab:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801aae:	39 da                	cmp    %ebx,%edx
  801ab0:	75 ed                	jne    801a9f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ab2:	89 f0                	mov    %esi,%eax
  801ab4:	5b                   	pop    %ebx
  801ab5:	5e                   	pop    %esi
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    

00801ab8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac3:	8b 55 10             	mov    0x10(%ebp),%edx
  801ac6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ac8:	85 d2                	test   %edx,%edx
  801aca:	74 21                	je     801aed <strlcpy+0x35>
  801acc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ad0:	89 f2                	mov    %esi,%edx
  801ad2:	eb 09                	jmp    801add <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801ad4:	83 c2 01             	add    $0x1,%edx
  801ad7:	83 c1 01             	add    $0x1,%ecx
  801ada:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801add:	39 c2                	cmp    %eax,%edx
  801adf:	74 09                	je     801aea <strlcpy+0x32>
  801ae1:	0f b6 19             	movzbl (%ecx),%ebx
  801ae4:	84 db                	test   %bl,%bl
  801ae6:	75 ec                	jne    801ad4 <strlcpy+0x1c>
  801ae8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801aea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801aed:	29 f0                	sub    %esi,%eax
}
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    

00801af3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801afc:	eb 06                	jmp    801b04 <strcmp+0x11>
		p++, q++;
  801afe:	83 c1 01             	add    $0x1,%ecx
  801b01:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b04:	0f b6 01             	movzbl (%ecx),%eax
  801b07:	84 c0                	test   %al,%al
  801b09:	74 04                	je     801b0f <strcmp+0x1c>
  801b0b:	3a 02                	cmp    (%edx),%al
  801b0d:	74 ef                	je     801afe <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b0f:	0f b6 c0             	movzbl %al,%eax
  801b12:	0f b6 12             	movzbl (%edx),%edx
  801b15:	29 d0                	sub    %edx,%eax
}
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	53                   	push   %ebx
  801b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b20:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b23:	89 c3                	mov    %eax,%ebx
  801b25:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b28:	eb 06                	jmp    801b30 <strncmp+0x17>
		n--, p++, q++;
  801b2a:	83 c0 01             	add    $0x1,%eax
  801b2d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b30:	39 d8                	cmp    %ebx,%eax
  801b32:	74 15                	je     801b49 <strncmp+0x30>
  801b34:	0f b6 08             	movzbl (%eax),%ecx
  801b37:	84 c9                	test   %cl,%cl
  801b39:	74 04                	je     801b3f <strncmp+0x26>
  801b3b:	3a 0a                	cmp    (%edx),%cl
  801b3d:	74 eb                	je     801b2a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b3f:	0f b6 00             	movzbl (%eax),%eax
  801b42:	0f b6 12             	movzbl (%edx),%edx
  801b45:	29 d0                	sub    %edx,%eax
  801b47:	eb 05                	jmp    801b4e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b4e:	5b                   	pop    %ebx
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	8b 45 08             	mov    0x8(%ebp),%eax
  801b57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b5b:	eb 07                	jmp    801b64 <strchr+0x13>
		if (*s == c)
  801b5d:	38 ca                	cmp    %cl,%dl
  801b5f:	74 0f                	je     801b70 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b61:	83 c0 01             	add    $0x1,%eax
  801b64:	0f b6 10             	movzbl (%eax),%edx
  801b67:	84 d2                	test   %dl,%dl
  801b69:	75 f2                	jne    801b5d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	8b 45 08             	mov    0x8(%ebp),%eax
  801b78:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b7c:	eb 03                	jmp    801b81 <strfind+0xf>
  801b7e:	83 c0 01             	add    $0x1,%eax
  801b81:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b84:	38 ca                	cmp    %cl,%dl
  801b86:	74 04                	je     801b8c <strfind+0x1a>
  801b88:	84 d2                	test   %dl,%dl
  801b8a:	75 f2                	jne    801b7e <strfind+0xc>
			break;
	return (char *) s;
}
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    

00801b8e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b9a:	85 c9                	test   %ecx,%ecx
  801b9c:	74 36                	je     801bd4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ba4:	75 28                	jne    801bce <memset+0x40>
  801ba6:	f6 c1 03             	test   $0x3,%cl
  801ba9:	75 23                	jne    801bce <memset+0x40>
		c &= 0xFF;
  801bab:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801baf:	89 d3                	mov    %edx,%ebx
  801bb1:	c1 e3 08             	shl    $0x8,%ebx
  801bb4:	89 d6                	mov    %edx,%esi
  801bb6:	c1 e6 18             	shl    $0x18,%esi
  801bb9:	89 d0                	mov    %edx,%eax
  801bbb:	c1 e0 10             	shl    $0x10,%eax
  801bbe:	09 f0                	or     %esi,%eax
  801bc0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801bc2:	89 d8                	mov    %ebx,%eax
  801bc4:	09 d0                	or     %edx,%eax
  801bc6:	c1 e9 02             	shr    $0x2,%ecx
  801bc9:	fc                   	cld    
  801bca:	f3 ab                	rep stos %eax,%es:(%edi)
  801bcc:	eb 06                	jmp    801bd4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd1:	fc                   	cld    
  801bd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bd4:	89 f8                	mov    %edi,%eax
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5f                   	pop    %edi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	57                   	push   %edi
  801bdf:	56                   	push   %esi
  801be0:	8b 45 08             	mov    0x8(%ebp),%eax
  801be3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801be9:	39 c6                	cmp    %eax,%esi
  801beb:	73 35                	jae    801c22 <memmove+0x47>
  801bed:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bf0:	39 d0                	cmp    %edx,%eax
  801bf2:	73 2e                	jae    801c22 <memmove+0x47>
		s += n;
		d += n;
  801bf4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bf7:	89 d6                	mov    %edx,%esi
  801bf9:	09 fe                	or     %edi,%esi
  801bfb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c01:	75 13                	jne    801c16 <memmove+0x3b>
  801c03:	f6 c1 03             	test   $0x3,%cl
  801c06:	75 0e                	jne    801c16 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801c08:	83 ef 04             	sub    $0x4,%edi
  801c0b:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c0e:	c1 e9 02             	shr    $0x2,%ecx
  801c11:	fd                   	std    
  801c12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c14:	eb 09                	jmp    801c1f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c16:	83 ef 01             	sub    $0x1,%edi
  801c19:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c1c:	fd                   	std    
  801c1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c1f:	fc                   	cld    
  801c20:	eb 1d                	jmp    801c3f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c22:	89 f2                	mov    %esi,%edx
  801c24:	09 c2                	or     %eax,%edx
  801c26:	f6 c2 03             	test   $0x3,%dl
  801c29:	75 0f                	jne    801c3a <memmove+0x5f>
  801c2b:	f6 c1 03             	test   $0x3,%cl
  801c2e:	75 0a                	jne    801c3a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c30:	c1 e9 02             	shr    $0x2,%ecx
  801c33:	89 c7                	mov    %eax,%edi
  801c35:	fc                   	cld    
  801c36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c38:	eb 05                	jmp    801c3f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c3a:	89 c7                	mov    %eax,%edi
  801c3c:	fc                   	cld    
  801c3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c3f:	5e                   	pop    %esi
  801c40:	5f                   	pop    %edi
  801c41:	5d                   	pop    %ebp
  801c42:	c3                   	ret    

00801c43 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c46:	ff 75 10             	pushl  0x10(%ebp)
  801c49:	ff 75 0c             	pushl  0xc(%ebp)
  801c4c:	ff 75 08             	pushl  0x8(%ebp)
  801c4f:	e8 87 ff ff ff       	call   801bdb <memmove>
}
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	56                   	push   %esi
  801c5a:	53                   	push   %ebx
  801c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c61:	89 c6                	mov    %eax,%esi
  801c63:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c66:	eb 1a                	jmp    801c82 <memcmp+0x2c>
		if (*s1 != *s2)
  801c68:	0f b6 08             	movzbl (%eax),%ecx
  801c6b:	0f b6 1a             	movzbl (%edx),%ebx
  801c6e:	38 d9                	cmp    %bl,%cl
  801c70:	74 0a                	je     801c7c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c72:	0f b6 c1             	movzbl %cl,%eax
  801c75:	0f b6 db             	movzbl %bl,%ebx
  801c78:	29 d8                	sub    %ebx,%eax
  801c7a:	eb 0f                	jmp    801c8b <memcmp+0x35>
		s1++, s2++;
  801c7c:	83 c0 01             	add    $0x1,%eax
  801c7f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c82:	39 f0                	cmp    %esi,%eax
  801c84:	75 e2                	jne    801c68 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c86:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c8b:	5b                   	pop    %ebx
  801c8c:	5e                   	pop    %esi
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	53                   	push   %ebx
  801c93:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c96:	89 c1                	mov    %eax,%ecx
  801c98:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c9b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c9f:	eb 0a                	jmp    801cab <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ca1:	0f b6 10             	movzbl (%eax),%edx
  801ca4:	39 da                	cmp    %ebx,%edx
  801ca6:	74 07                	je     801caf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ca8:	83 c0 01             	add    $0x1,%eax
  801cab:	39 c8                	cmp    %ecx,%eax
  801cad:	72 f2                	jb     801ca1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801caf:	5b                   	pop    %ebx
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    

00801cb2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	57                   	push   %edi
  801cb6:	56                   	push   %esi
  801cb7:	53                   	push   %ebx
  801cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cbe:	eb 03                	jmp    801cc3 <strtol+0x11>
		s++;
  801cc0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cc3:	0f b6 01             	movzbl (%ecx),%eax
  801cc6:	3c 20                	cmp    $0x20,%al
  801cc8:	74 f6                	je     801cc0 <strtol+0xe>
  801cca:	3c 09                	cmp    $0x9,%al
  801ccc:	74 f2                	je     801cc0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801cce:	3c 2b                	cmp    $0x2b,%al
  801cd0:	75 0a                	jne    801cdc <strtol+0x2a>
		s++;
  801cd2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801cd5:	bf 00 00 00 00       	mov    $0x0,%edi
  801cda:	eb 11                	jmp    801ced <strtol+0x3b>
  801cdc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ce1:	3c 2d                	cmp    $0x2d,%al
  801ce3:	75 08                	jne    801ced <strtol+0x3b>
		s++, neg = 1;
  801ce5:	83 c1 01             	add    $0x1,%ecx
  801ce8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ced:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cf3:	75 15                	jne    801d0a <strtol+0x58>
  801cf5:	80 39 30             	cmpb   $0x30,(%ecx)
  801cf8:	75 10                	jne    801d0a <strtol+0x58>
  801cfa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cfe:	75 7c                	jne    801d7c <strtol+0xca>
		s += 2, base = 16;
  801d00:	83 c1 02             	add    $0x2,%ecx
  801d03:	bb 10 00 00 00       	mov    $0x10,%ebx
  801d08:	eb 16                	jmp    801d20 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801d0a:	85 db                	test   %ebx,%ebx
  801d0c:	75 12                	jne    801d20 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d0e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d13:	80 39 30             	cmpb   $0x30,(%ecx)
  801d16:	75 08                	jne    801d20 <strtol+0x6e>
		s++, base = 8;
  801d18:	83 c1 01             	add    $0x1,%ecx
  801d1b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
  801d25:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d28:	0f b6 11             	movzbl (%ecx),%edx
  801d2b:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d2e:	89 f3                	mov    %esi,%ebx
  801d30:	80 fb 09             	cmp    $0x9,%bl
  801d33:	77 08                	ja     801d3d <strtol+0x8b>
			dig = *s - '0';
  801d35:	0f be d2             	movsbl %dl,%edx
  801d38:	83 ea 30             	sub    $0x30,%edx
  801d3b:	eb 22                	jmp    801d5f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d3d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d40:	89 f3                	mov    %esi,%ebx
  801d42:	80 fb 19             	cmp    $0x19,%bl
  801d45:	77 08                	ja     801d4f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d47:	0f be d2             	movsbl %dl,%edx
  801d4a:	83 ea 57             	sub    $0x57,%edx
  801d4d:	eb 10                	jmp    801d5f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d4f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d52:	89 f3                	mov    %esi,%ebx
  801d54:	80 fb 19             	cmp    $0x19,%bl
  801d57:	77 16                	ja     801d6f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d59:	0f be d2             	movsbl %dl,%edx
  801d5c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d5f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d62:	7d 0b                	jge    801d6f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d64:	83 c1 01             	add    $0x1,%ecx
  801d67:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d6b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d6d:	eb b9                	jmp    801d28 <strtol+0x76>

	if (endptr)
  801d6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d73:	74 0d                	je     801d82 <strtol+0xd0>
		*endptr = (char *) s;
  801d75:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d78:	89 0e                	mov    %ecx,(%esi)
  801d7a:	eb 06                	jmp    801d82 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d7c:	85 db                	test   %ebx,%ebx
  801d7e:	74 98                	je     801d18 <strtol+0x66>
  801d80:	eb 9e                	jmp    801d20 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d82:	89 c2                	mov    %eax,%edx
  801d84:	f7 da                	neg    %edx
  801d86:	85 ff                	test   %edi,%edi
  801d88:	0f 45 c2             	cmovne %edx,%eax
}
  801d8b:	5b                   	pop    %ebx
  801d8c:	5e                   	pop    %esi
  801d8d:	5f                   	pop    %edi
  801d8e:	5d                   	pop    %ebp
  801d8f:	c3                   	ret    

00801d90 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d96:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d9d:	75 2a                	jne    801dc9 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d9f:	83 ec 04             	sub    $0x4,%esp
  801da2:	6a 07                	push   $0x7
  801da4:	68 00 f0 bf ee       	push   $0xeebff000
  801da9:	6a 00                	push   $0x0
  801dab:	e8 d1 e3 ff ff       	call   800181 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	85 c0                	test   %eax,%eax
  801db5:	79 12                	jns    801dc9 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801db7:	50                   	push   %eax
  801db8:	68 e0 26 80 00       	push   $0x8026e0
  801dbd:	6a 23                	push   $0x23
  801dbf:	68 e4 26 80 00       	push   $0x8026e4
  801dc4:	e8 22 f6 ff ff       	call   8013eb <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcc:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dd1:	83 ec 08             	sub    $0x8,%esp
  801dd4:	68 fb 1d 80 00       	push   $0x801dfb
  801dd9:	6a 00                	push   $0x0
  801ddb:	e8 ec e4 ff ff       	call   8002cc <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	85 c0                	test   %eax,%eax
  801de5:	79 12                	jns    801df9 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801de7:	50                   	push   %eax
  801de8:	68 e0 26 80 00       	push   $0x8026e0
  801ded:	6a 2c                	push   $0x2c
  801def:	68 e4 26 80 00       	push   $0x8026e4
  801df4:	e8 f2 f5 ff ff       	call   8013eb <_panic>
	}
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dfb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dfc:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e01:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e03:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e06:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e0a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e0f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e13:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e15:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e18:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e19:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e1c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e1d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e1e:	c3                   	ret    

00801e1f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	56                   	push   %esi
  801e23:	53                   	push   %ebx
  801e24:	8b 75 08             	mov    0x8(%ebp),%esi
  801e27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	75 12                	jne    801e43 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e31:	83 ec 0c             	sub    $0xc,%esp
  801e34:	68 00 00 c0 ee       	push   $0xeec00000
  801e39:	e8 f3 e4 ff ff       	call   800331 <sys_ipc_recv>
  801e3e:	83 c4 10             	add    $0x10,%esp
  801e41:	eb 0c                	jmp    801e4f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e43:	83 ec 0c             	sub    $0xc,%esp
  801e46:	50                   	push   %eax
  801e47:	e8 e5 e4 ff ff       	call   800331 <sys_ipc_recv>
  801e4c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e4f:	85 f6                	test   %esi,%esi
  801e51:	0f 95 c1             	setne  %cl
  801e54:	85 db                	test   %ebx,%ebx
  801e56:	0f 95 c2             	setne  %dl
  801e59:	84 d1                	test   %dl,%cl
  801e5b:	74 09                	je     801e66 <ipc_recv+0x47>
  801e5d:	89 c2                	mov    %eax,%edx
  801e5f:	c1 ea 1f             	shr    $0x1f,%edx
  801e62:	84 d2                	test   %dl,%dl
  801e64:	75 2d                	jne    801e93 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e66:	85 f6                	test   %esi,%esi
  801e68:	74 0d                	je     801e77 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6f:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801e75:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e77:	85 db                	test   %ebx,%ebx
  801e79:	74 0d                	je     801e88 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e7b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e80:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801e86:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e88:	a1 04 40 80 00       	mov    0x804004,%eax
  801e8d:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801e93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e96:	5b                   	pop    %ebx
  801e97:	5e                   	pop    %esi
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    

00801e9a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	57                   	push   %edi
  801e9e:	56                   	push   %esi
  801e9f:	53                   	push   %ebx
  801ea0:	83 ec 0c             	sub    $0xc,%esp
  801ea3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ea6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ea9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801eac:	85 db                	test   %ebx,%ebx
  801eae:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eb3:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801eb6:	ff 75 14             	pushl  0x14(%ebp)
  801eb9:	53                   	push   %ebx
  801eba:	56                   	push   %esi
  801ebb:	57                   	push   %edi
  801ebc:	e8 4d e4 ff ff       	call   80030e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ec1:	89 c2                	mov    %eax,%edx
  801ec3:	c1 ea 1f             	shr    $0x1f,%edx
  801ec6:	83 c4 10             	add    $0x10,%esp
  801ec9:	84 d2                	test   %dl,%dl
  801ecb:	74 17                	je     801ee4 <ipc_send+0x4a>
  801ecd:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ed0:	74 12                	je     801ee4 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ed2:	50                   	push   %eax
  801ed3:	68 f2 26 80 00       	push   $0x8026f2
  801ed8:	6a 47                	push   $0x47
  801eda:	68 00 27 80 00       	push   $0x802700
  801edf:	e8 07 f5 ff ff       	call   8013eb <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ee4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee7:	75 07                	jne    801ef0 <ipc_send+0x56>
			sys_yield();
  801ee9:	e8 74 e2 ff ff       	call   800162 <sys_yield>
  801eee:	eb c6                	jmp    801eb6 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	75 c2                	jne    801eb6 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ef4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5f                   	pop    %edi
  801efa:	5d                   	pop    %ebp
  801efb:	c3                   	ret    

00801efc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f02:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f07:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f0d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f13:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f19:	39 ca                	cmp    %ecx,%edx
  801f1b:	75 13                	jne    801f30 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f1d:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f23:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f28:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f2e:	eb 0f                	jmp    801f3f <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f30:	83 c0 01             	add    $0x1,%eax
  801f33:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f38:	75 cd                	jne    801f07 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f3f:	5d                   	pop    %ebp
  801f40:	c3                   	ret    

00801f41 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f47:	89 d0                	mov    %edx,%eax
  801f49:	c1 e8 16             	shr    $0x16,%eax
  801f4c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f53:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f58:	f6 c1 01             	test   $0x1,%cl
  801f5b:	74 1d                	je     801f7a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f5d:	c1 ea 0c             	shr    $0xc,%edx
  801f60:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f67:	f6 c2 01             	test   $0x1,%dl
  801f6a:	74 0e                	je     801f7a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f6c:	c1 ea 0c             	shr    $0xc,%edx
  801f6f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f76:	ef 
  801f77:	0f b7 c0             	movzwl %ax,%eax
}
  801f7a:	5d                   	pop    %ebp
  801f7b:	c3                   	ret    
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
