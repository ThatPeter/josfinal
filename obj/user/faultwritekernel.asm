
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
  8000b1:	e8 66 0a 00 00       	call   800b1c <close_all>
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
  80012a:	68 8a 24 80 00       	push   $0x80248a
  80012f:	6a 23                	push   $0x23
  800131:	68 a7 24 80 00       	push   $0x8024a7
  800136:	e8 12 15 00 00       	call   80164d <_panic>

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
  8001ab:	68 8a 24 80 00       	push   $0x80248a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 a7 24 80 00       	push   $0x8024a7
  8001b7:	e8 91 14 00 00       	call   80164d <_panic>

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
  8001ed:	68 8a 24 80 00       	push   $0x80248a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 a7 24 80 00       	push   $0x8024a7
  8001f9:	e8 4f 14 00 00       	call   80164d <_panic>

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
  80022f:	68 8a 24 80 00       	push   $0x80248a
  800234:	6a 23                	push   $0x23
  800236:	68 a7 24 80 00       	push   $0x8024a7
  80023b:	e8 0d 14 00 00       	call   80164d <_panic>

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
  800271:	68 8a 24 80 00       	push   $0x80248a
  800276:	6a 23                	push   $0x23
  800278:	68 a7 24 80 00       	push   $0x8024a7
  80027d:	e8 cb 13 00 00       	call   80164d <_panic>

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
  8002b3:	68 8a 24 80 00       	push   $0x80248a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 a7 24 80 00       	push   $0x8024a7
  8002bf:	e8 89 13 00 00       	call   80164d <_panic>
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
  8002f5:	68 8a 24 80 00       	push   $0x80248a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 a7 24 80 00       	push   $0x8024a7
  800301:	e8 47 13 00 00       	call   80164d <_panic>

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
  800359:	68 8a 24 80 00       	push   $0x80248a
  80035e:	6a 23                	push   $0x23
  800360:	68 a7 24 80 00       	push   $0x8024a7
  800365:	e8 e3 12 00 00       	call   80164d <_panic>

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
  8003f8:	68 b5 24 80 00       	push   $0x8024b5
  8003fd:	6a 1f                	push   $0x1f
  8003ff:	68 c5 24 80 00       	push   $0x8024c5
  800404:	e8 44 12 00 00       	call   80164d <_panic>
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
  800422:	68 d0 24 80 00       	push   $0x8024d0
  800427:	6a 2d                	push   $0x2d
  800429:	68 c5 24 80 00       	push   $0x8024c5
  80042e:	e8 1a 12 00 00       	call   80164d <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800433:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800439:	83 ec 04             	sub    $0x4,%esp
  80043c:	68 00 10 00 00       	push   $0x1000
  800441:	53                   	push   %ebx
  800442:	68 00 f0 7f 00       	push   $0x7ff000
  800447:	e8 59 1a 00 00       	call   801ea5 <memcpy>

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
  80046a:	68 d0 24 80 00       	push   $0x8024d0
  80046f:	6a 34                	push   $0x34
  800471:	68 c5 24 80 00       	push   $0x8024c5
  800476:	e8 d2 11 00 00       	call   80164d <_panic>
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
  800492:	68 d0 24 80 00       	push   $0x8024d0
  800497:	6a 38                	push   $0x38
  800499:	68 c5 24 80 00       	push   $0x8024c5
  80049e:	e8 aa 11 00 00       	call   80164d <_panic>
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
  8004b6:	e8 37 1b 00 00       	call   801ff2 <set_pgfault_handler>
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
  8004cf:	68 e9 24 80 00       	push   $0x8024e9
  8004d4:	68 85 00 00 00       	push   $0x85
  8004d9:	68 c5 24 80 00       	push   $0x8024c5
  8004de:	e8 6a 11 00 00       	call   80164d <_panic>
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
  80058b:	68 f7 24 80 00       	push   $0x8024f7
  800590:	6a 55                	push   $0x55
  800592:	68 c5 24 80 00       	push   $0x8024c5
  800597:	e8 b1 10 00 00       	call   80164d <_panic>
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
  8005d0:	68 f7 24 80 00       	push   $0x8024f7
  8005d5:	6a 5c                	push   $0x5c
  8005d7:	68 c5 24 80 00       	push   $0x8024c5
  8005dc:	e8 6c 10 00 00       	call   80164d <_panic>
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
  8005fe:	68 f7 24 80 00       	push   $0x8024f7
  800603:	6a 60                	push   $0x60
  800605:	68 c5 24 80 00       	push   $0x8024c5
  80060a:	e8 3e 10 00 00       	call   80164d <_panic>
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
  800628:	68 f7 24 80 00       	push   $0x8024f7
  80062d:	6a 65                	push   $0x65
  80062f:	68 c5 24 80 00       	push   $0x8024c5
  800634:	e8 14 10 00 00       	call   80164d <_panic>
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
  800697:	68 88 25 80 00       	push   $0x802588
  80069c:	e8 85 10 00 00       	call   801726 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006a1:	c7 04 24 8b 00 80 00 	movl   $0x80008b,(%esp)
  8006a8:	e8 c5 fc ff ff       	call   800372 <sys_thread_create>
  8006ad:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	68 88 25 80 00       	push   $0x802588
  8006b8:	e8 69 10 00 00       	call   801726 <cprintf>
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

008006ec <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	56                   	push   %esi
  8006f0:	53                   	push   %ebx
  8006f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006f7:	83 ec 04             	sub    $0x4,%esp
  8006fa:	6a 07                	push   $0x7
  8006fc:	6a 00                	push   $0x0
  8006fe:	56                   	push   %esi
  8006ff:	e8 7d fa ff ff       	call   800181 <sys_page_alloc>
	if (r < 0) {
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	85 c0                	test   %eax,%eax
  800709:	79 15                	jns    800720 <queue_append+0x34>
		panic("%e\n", r);
  80070b:	50                   	push   %eax
  80070c:	68 83 25 80 00       	push   $0x802583
  800711:	68 c4 00 00 00       	push   $0xc4
  800716:	68 c5 24 80 00       	push   $0x8024c5
  80071b:	e8 2d 0f 00 00       	call   80164d <_panic>
	}	
	wt->envid = envid;
  800720:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  800726:	83 ec 04             	sub    $0x4,%esp
  800729:	ff 33                	pushl  (%ebx)
  80072b:	56                   	push   %esi
  80072c:	68 ac 25 80 00       	push   $0x8025ac
  800731:	e8 f0 0f 00 00       	call   801726 <cprintf>
	if (queue->first == NULL) {
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	83 3b 00             	cmpl   $0x0,(%ebx)
  80073c:	75 29                	jne    800767 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  80073e:	83 ec 0c             	sub    $0xc,%esp
  800741:	68 0d 25 80 00       	push   $0x80250d
  800746:	e8 db 0f 00 00       	call   801726 <cprintf>
		queue->first = wt;
  80074b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  800751:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800758:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80075f:	00 00 00 
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	eb 2b                	jmp    800792 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  800767:	83 ec 0c             	sub    $0xc,%esp
  80076a:	68 27 25 80 00       	push   $0x802527
  80076f:	e8 b2 0f 00 00       	call   801726 <cprintf>
		queue->last->next = wt;
  800774:	8b 43 04             	mov    0x4(%ebx),%eax
  800777:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  80077e:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800785:	00 00 00 
		queue->last = wt;
  800788:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  80078f:	83 c4 10             	add    $0x10,%esp
	}
}
  800792:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800795:	5b                   	pop    %ebx
  800796:	5e                   	pop    %esi
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	53                   	push   %ebx
  80079d:	83 ec 04             	sub    $0x4,%esp
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8007a3:	8b 02                	mov    (%edx),%eax
  8007a5:	85 c0                	test   %eax,%eax
  8007a7:	75 17                	jne    8007c0 <queue_pop+0x27>
		panic("queue empty!\n");
  8007a9:	83 ec 04             	sub    $0x4,%esp
  8007ac:	68 45 25 80 00       	push   $0x802545
  8007b1:	68 d8 00 00 00       	push   $0xd8
  8007b6:	68 c5 24 80 00       	push   $0x8024c5
  8007bb:	e8 8d 0e 00 00       	call   80164d <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8007c0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c3:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8007c5:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	68 53 25 80 00       	push   $0x802553
  8007d0:	e8 51 0f 00 00       	call   801726 <cprintf>
	return envid;
}
  8007d5:	89 d8                	mov    %ebx,%eax
  8007d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	83 ec 04             	sub    $0x4,%esp
  8007e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8007e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8007eb:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	74 5a                	je     80084c <mutex_lock+0x70>
  8007f2:	8b 43 04             	mov    0x4(%ebx),%eax
  8007f5:	83 38 00             	cmpl   $0x0,(%eax)
  8007f8:	75 52                	jne    80084c <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8007fa:	83 ec 0c             	sub    $0xc,%esp
  8007fd:	68 d4 25 80 00       	push   $0x8025d4
  800802:	e8 1f 0f 00 00       	call   801726 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  800807:	8b 5b 04             	mov    0x4(%ebx),%ebx
  80080a:	e8 34 f9 ff ff       	call   800143 <sys_getenvid>
  80080f:	83 c4 08             	add    $0x8,%esp
  800812:	53                   	push   %ebx
  800813:	50                   	push   %eax
  800814:	e8 d3 fe ff ff       	call   8006ec <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800819:	e8 25 f9 ff ff       	call   800143 <sys_getenvid>
  80081e:	83 c4 08             	add    $0x8,%esp
  800821:	6a 04                	push   $0x4
  800823:	50                   	push   %eax
  800824:	e8 1f fa ff ff       	call   800248 <sys_env_set_status>
		if (r < 0) {
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	85 c0                	test   %eax,%eax
  80082e:	79 15                	jns    800845 <mutex_lock+0x69>
			panic("%e\n", r);
  800830:	50                   	push   %eax
  800831:	68 83 25 80 00       	push   $0x802583
  800836:	68 eb 00 00 00       	push   $0xeb
  80083b:	68 c5 24 80 00       	push   $0x8024c5
  800840:	e8 08 0e 00 00       	call   80164d <_panic>
		}
		sys_yield();
  800845:	e8 18 f9 ff ff       	call   800162 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80084a:	eb 18                	jmp    800864 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80084c:	83 ec 0c             	sub    $0xc,%esp
  80084f:	68 f4 25 80 00       	push   $0x8025f4
  800854:	e8 cd 0e 00 00       	call   801726 <cprintf>
	mtx->owner = sys_getenvid();}
  800859:	e8 e5 f8 ff ff       	call   800143 <sys_getenvid>
  80085e:	89 43 08             	mov    %eax,0x8(%ebx)
  800861:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  800864:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	83 ec 04             	sub    $0x4,%esp
  800870:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800873:	b8 00 00 00 00       	mov    $0x0,%eax
  800878:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  80087b:	8b 43 04             	mov    0x4(%ebx),%eax
  80087e:	83 38 00             	cmpl   $0x0,(%eax)
  800881:	74 33                	je     8008b6 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  800883:	83 ec 0c             	sub    $0xc,%esp
  800886:	50                   	push   %eax
  800887:	e8 0d ff ff ff       	call   800799 <queue_pop>
  80088c:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	6a 02                	push   $0x2
  800894:	50                   	push   %eax
  800895:	e8 ae f9 ff ff       	call   800248 <sys_env_set_status>
		if (r < 0) {
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	85 c0                	test   %eax,%eax
  80089f:	79 15                	jns    8008b6 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8008a1:	50                   	push   %eax
  8008a2:	68 83 25 80 00       	push   $0x802583
  8008a7:	68 00 01 00 00       	push   $0x100
  8008ac:	68 c5 24 80 00       	push   $0x8024c5
  8008b1:	e8 97 0d 00 00       	call   80164d <_panic>
		}
	}

	asm volatile("pause");
  8008b6:	f3 90                	pause  
	//sys_yield();
}
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	53                   	push   %ebx
  8008c1:	83 ec 04             	sub    $0x4,%esp
  8008c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8008c7:	e8 77 f8 ff ff       	call   800143 <sys_getenvid>
  8008cc:	83 ec 04             	sub    $0x4,%esp
  8008cf:	6a 07                	push   $0x7
  8008d1:	53                   	push   %ebx
  8008d2:	50                   	push   %eax
  8008d3:	e8 a9 f8 ff ff       	call   800181 <sys_page_alloc>
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	79 15                	jns    8008f4 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8008df:	50                   	push   %eax
  8008e0:	68 6e 25 80 00       	push   $0x80256e
  8008e5:	68 0d 01 00 00       	push   $0x10d
  8008ea:	68 c5 24 80 00       	push   $0x8024c5
  8008ef:	e8 59 0d 00 00       	call   80164d <_panic>
	}	
	mtx->locked = 0;
  8008f4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8008fa:	8b 43 04             	mov    0x4(%ebx),%eax
  8008fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800903:	8b 43 04             	mov    0x4(%ebx),%eax
  800906:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80090d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  800914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800917:	c9                   	leave  
  800918:	c3                   	ret    

00800919 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  80091f:	e8 1f f8 ff ff       	call   800143 <sys_getenvid>
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	ff 75 08             	pushl  0x8(%ebp)
  80092a:	50                   	push   %eax
  80092b:	e8 d6 f8 ff ff       	call   800206 <sys_page_unmap>
	if (r < 0) {
  800930:	83 c4 10             	add    $0x10,%esp
  800933:	85 c0                	test   %eax,%eax
  800935:	79 15                	jns    80094c <mutex_destroy+0x33>
		panic("%e\n", r);
  800937:	50                   	push   %eax
  800938:	68 83 25 80 00       	push   $0x802583
  80093d:	68 1a 01 00 00       	push   $0x11a
  800942:	68 c5 24 80 00       	push   $0x8024c5
  800947:	e8 01 0d 00 00       	call   80164d <_panic>
	}
}
  80094c:	c9                   	leave  
  80094d:	c3                   	ret    

0080094e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	05 00 00 00 30       	add    $0x30000000,%eax
  800959:	c1 e8 0c             	shr    $0xc,%eax
}
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	05 00 00 00 30       	add    $0x30000000,%eax
  800969:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80096e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800980:	89 c2                	mov    %eax,%edx
  800982:	c1 ea 16             	shr    $0x16,%edx
  800985:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80098c:	f6 c2 01             	test   $0x1,%dl
  80098f:	74 11                	je     8009a2 <fd_alloc+0x2d>
  800991:	89 c2                	mov    %eax,%edx
  800993:	c1 ea 0c             	shr    $0xc,%edx
  800996:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80099d:	f6 c2 01             	test   $0x1,%dl
  8009a0:	75 09                	jne    8009ab <fd_alloc+0x36>
			*fd_store = fd;
  8009a2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a9:	eb 17                	jmp    8009c2 <fd_alloc+0x4d>
  8009ab:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8009b0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8009b5:	75 c9                	jne    800980 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8009b7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8009bd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8009ca:	83 f8 1f             	cmp    $0x1f,%eax
  8009cd:	77 36                	ja     800a05 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8009cf:	c1 e0 0c             	shl    $0xc,%eax
  8009d2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8009d7:	89 c2                	mov    %eax,%edx
  8009d9:	c1 ea 16             	shr    $0x16,%edx
  8009dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8009e3:	f6 c2 01             	test   $0x1,%dl
  8009e6:	74 24                	je     800a0c <fd_lookup+0x48>
  8009e8:	89 c2                	mov    %eax,%edx
  8009ea:	c1 ea 0c             	shr    $0xc,%edx
  8009ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009f4:	f6 c2 01             	test   $0x1,%dl
  8009f7:	74 1a                	je     800a13 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fc:	89 02                	mov    %eax,(%edx)
	return 0;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800a03:	eb 13                	jmp    800a18 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a0a:	eb 0c                	jmp    800a18 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a0c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a11:	eb 05                	jmp    800a18 <fd_lookup+0x54>
  800a13:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	83 ec 08             	sub    $0x8,%esp
  800a20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a23:	ba 90 26 80 00       	mov    $0x802690,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800a28:	eb 13                	jmp    800a3d <dev_lookup+0x23>
  800a2a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800a2d:	39 08                	cmp    %ecx,(%eax)
  800a2f:	75 0c                	jne    800a3d <dev_lookup+0x23>
			*dev = devtab[i];
  800a31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a34:	89 01                	mov    %eax,(%ecx)
			return 0;
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	eb 31                	jmp    800a6e <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800a3d:	8b 02                	mov    (%edx),%eax
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	75 e7                	jne    800a2a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800a43:	a1 04 40 80 00       	mov    0x804004,%eax
  800a48:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a4e:	83 ec 04             	sub    $0x4,%esp
  800a51:	51                   	push   %ecx
  800a52:	50                   	push   %eax
  800a53:	68 14 26 80 00       	push   $0x802614
  800a58:	e8 c9 0c 00 00       	call   801726 <cprintf>
	*dev = 0;
  800a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a66:	83 c4 10             	add    $0x10,%esp
  800a69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	83 ec 10             	sub    $0x10,%esp
  800a78:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a81:	50                   	push   %eax
  800a82:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a88:	c1 e8 0c             	shr    $0xc,%eax
  800a8b:	50                   	push   %eax
  800a8c:	e8 33 ff ff ff       	call   8009c4 <fd_lookup>
  800a91:	83 c4 08             	add    $0x8,%esp
  800a94:	85 c0                	test   %eax,%eax
  800a96:	78 05                	js     800a9d <fd_close+0x2d>
	    || fd != fd2)
  800a98:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a9b:	74 0c                	je     800aa9 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a9d:	84 db                	test   %bl,%bl
  800a9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa4:	0f 44 c2             	cmove  %edx,%eax
  800aa7:	eb 41                	jmp    800aea <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800aa9:	83 ec 08             	sub    $0x8,%esp
  800aac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aaf:	50                   	push   %eax
  800ab0:	ff 36                	pushl  (%esi)
  800ab2:	e8 63 ff ff ff       	call   800a1a <dev_lookup>
  800ab7:	89 c3                	mov    %eax,%ebx
  800ab9:	83 c4 10             	add    $0x10,%esp
  800abc:	85 c0                	test   %eax,%eax
  800abe:	78 1a                	js     800ada <fd_close+0x6a>
		if (dev->dev_close)
  800ac0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ac6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800acb:	85 c0                	test   %eax,%eax
  800acd:	74 0b                	je     800ada <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800acf:	83 ec 0c             	sub    $0xc,%esp
  800ad2:	56                   	push   %esi
  800ad3:	ff d0                	call   *%eax
  800ad5:	89 c3                	mov    %eax,%ebx
  800ad7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ada:	83 ec 08             	sub    $0x8,%esp
  800add:	56                   	push   %esi
  800ade:	6a 00                	push   $0x0
  800ae0:	e8 21 f7 ff ff       	call   800206 <sys_page_unmap>
	return r;
  800ae5:	83 c4 10             	add    $0x10,%esp
  800ae8:	89 d8                	mov    %ebx,%eax
}
  800aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800af7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800afa:	50                   	push   %eax
  800afb:	ff 75 08             	pushl  0x8(%ebp)
  800afe:	e8 c1 fe ff ff       	call   8009c4 <fd_lookup>
  800b03:	83 c4 08             	add    $0x8,%esp
  800b06:	85 c0                	test   %eax,%eax
  800b08:	78 10                	js     800b1a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800b0a:	83 ec 08             	sub    $0x8,%esp
  800b0d:	6a 01                	push   $0x1
  800b0f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b12:	e8 59 ff ff ff       	call   800a70 <fd_close>
  800b17:	83 c4 10             	add    $0x10,%esp
}
  800b1a:	c9                   	leave  
  800b1b:	c3                   	ret    

00800b1c <close_all>:

void
close_all(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	53                   	push   %ebx
  800b20:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800b23:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800b28:	83 ec 0c             	sub    $0xc,%esp
  800b2b:	53                   	push   %ebx
  800b2c:	e8 c0 ff ff ff       	call   800af1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b31:	83 c3 01             	add    $0x1,%ebx
  800b34:	83 c4 10             	add    $0x10,%esp
  800b37:	83 fb 20             	cmp    $0x20,%ebx
  800b3a:	75 ec                	jne    800b28 <close_all+0xc>
		close(i);
}
  800b3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	83 ec 2c             	sub    $0x2c,%esp
  800b4a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b4d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b50:	50                   	push   %eax
  800b51:	ff 75 08             	pushl  0x8(%ebp)
  800b54:	e8 6b fe ff ff       	call   8009c4 <fd_lookup>
  800b59:	83 c4 08             	add    $0x8,%esp
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	0f 88 c1 00 00 00    	js     800c25 <dup+0xe4>
		return r;
	close(newfdnum);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	56                   	push   %esi
  800b68:	e8 84 ff ff ff       	call   800af1 <close>

	newfd = INDEX2FD(newfdnum);
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	c1 e3 0c             	shl    $0xc,%ebx
  800b72:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b78:	83 c4 04             	add    $0x4,%esp
  800b7b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b7e:	e8 db fd ff ff       	call   80095e <fd2data>
  800b83:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b85:	89 1c 24             	mov    %ebx,(%esp)
  800b88:	e8 d1 fd ff ff       	call   80095e <fd2data>
  800b8d:	83 c4 10             	add    $0x10,%esp
  800b90:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b93:	89 f8                	mov    %edi,%eax
  800b95:	c1 e8 16             	shr    $0x16,%eax
  800b98:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b9f:	a8 01                	test   $0x1,%al
  800ba1:	74 37                	je     800bda <dup+0x99>
  800ba3:	89 f8                	mov    %edi,%eax
  800ba5:	c1 e8 0c             	shr    $0xc,%eax
  800ba8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800baf:	f6 c2 01             	test   $0x1,%dl
  800bb2:	74 26                	je     800bda <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800bb4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	25 07 0e 00 00       	and    $0xe07,%eax
  800bc3:	50                   	push   %eax
  800bc4:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bc7:	6a 00                	push   $0x0
  800bc9:	57                   	push   %edi
  800bca:	6a 00                	push   $0x0
  800bcc:	e8 f3 f5 ff ff       	call   8001c4 <sys_page_map>
  800bd1:	89 c7                	mov    %eax,%edi
  800bd3:	83 c4 20             	add    $0x20,%esp
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	78 2e                	js     800c08 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bda:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800bdd:	89 d0                	mov    %edx,%eax
  800bdf:	c1 e8 0c             	shr    $0xc,%eax
  800be2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	25 07 0e 00 00       	and    $0xe07,%eax
  800bf1:	50                   	push   %eax
  800bf2:	53                   	push   %ebx
  800bf3:	6a 00                	push   $0x0
  800bf5:	52                   	push   %edx
  800bf6:	6a 00                	push   $0x0
  800bf8:	e8 c7 f5 ff ff       	call   8001c4 <sys_page_map>
  800bfd:	89 c7                	mov    %eax,%edi
  800bff:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800c02:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c04:	85 ff                	test   %edi,%edi
  800c06:	79 1d                	jns    800c25 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c08:	83 ec 08             	sub    $0x8,%esp
  800c0b:	53                   	push   %ebx
  800c0c:	6a 00                	push   $0x0
  800c0e:	e8 f3 f5 ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c13:	83 c4 08             	add    $0x8,%esp
  800c16:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c19:	6a 00                	push   $0x0
  800c1b:	e8 e6 f5 ff ff       	call   800206 <sys_page_unmap>
	return r;
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	89 f8                	mov    %edi,%eax
}
  800c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	53                   	push   %ebx
  800c31:	83 ec 14             	sub    $0x14,%esp
  800c34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c37:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c3a:	50                   	push   %eax
  800c3b:	53                   	push   %ebx
  800c3c:	e8 83 fd ff ff       	call   8009c4 <fd_lookup>
  800c41:	83 c4 08             	add    $0x8,%esp
  800c44:	89 c2                	mov    %eax,%edx
  800c46:	85 c0                	test   %eax,%eax
  800c48:	78 70                	js     800cba <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c4a:	83 ec 08             	sub    $0x8,%esp
  800c4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c50:	50                   	push   %eax
  800c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c54:	ff 30                	pushl  (%eax)
  800c56:	e8 bf fd ff ff       	call   800a1a <dev_lookup>
  800c5b:	83 c4 10             	add    $0x10,%esp
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	78 4f                	js     800cb1 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c62:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c65:	8b 42 08             	mov    0x8(%edx),%eax
  800c68:	83 e0 03             	and    $0x3,%eax
  800c6b:	83 f8 01             	cmp    $0x1,%eax
  800c6e:	75 24                	jne    800c94 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c70:	a1 04 40 80 00       	mov    0x804004,%eax
  800c75:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800c7b:	83 ec 04             	sub    $0x4,%esp
  800c7e:	53                   	push   %ebx
  800c7f:	50                   	push   %eax
  800c80:	68 55 26 80 00       	push   $0x802655
  800c85:	e8 9c 0a 00 00       	call   801726 <cprintf>
		return -E_INVAL;
  800c8a:	83 c4 10             	add    $0x10,%esp
  800c8d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c92:	eb 26                	jmp    800cba <read+0x8d>
	}
	if (!dev->dev_read)
  800c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c97:	8b 40 08             	mov    0x8(%eax),%eax
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	74 17                	je     800cb5 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c9e:	83 ec 04             	sub    $0x4,%esp
  800ca1:	ff 75 10             	pushl  0x10(%ebp)
  800ca4:	ff 75 0c             	pushl  0xc(%ebp)
  800ca7:	52                   	push   %edx
  800ca8:	ff d0                	call   *%eax
  800caa:	89 c2                	mov    %eax,%edx
  800cac:	83 c4 10             	add    $0x10,%esp
  800caf:	eb 09                	jmp    800cba <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cb1:	89 c2                	mov    %eax,%edx
  800cb3:	eb 05                	jmp    800cba <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800cb5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800cba:	89 d0                	mov    %edx,%eax
  800cbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cbf:	c9                   	leave  
  800cc0:	c3                   	ret    

00800cc1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ccd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	eb 21                	jmp    800cf8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800cd7:	83 ec 04             	sub    $0x4,%esp
  800cda:	89 f0                	mov    %esi,%eax
  800cdc:	29 d8                	sub    %ebx,%eax
  800cde:	50                   	push   %eax
  800cdf:	89 d8                	mov    %ebx,%eax
  800ce1:	03 45 0c             	add    0xc(%ebp),%eax
  800ce4:	50                   	push   %eax
  800ce5:	57                   	push   %edi
  800ce6:	e8 42 ff ff ff       	call   800c2d <read>
		if (m < 0)
  800ceb:	83 c4 10             	add    $0x10,%esp
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	78 10                	js     800d02 <readn+0x41>
			return m;
		if (m == 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	74 0a                	je     800d00 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cf6:	01 c3                	add    %eax,%ebx
  800cf8:	39 f3                	cmp    %esi,%ebx
  800cfa:	72 db                	jb     800cd7 <readn+0x16>
  800cfc:	89 d8                	mov    %ebx,%eax
  800cfe:	eb 02                	jmp    800d02 <readn+0x41>
  800d00:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 14             	sub    $0x14,%esp
  800d11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d17:	50                   	push   %eax
  800d18:	53                   	push   %ebx
  800d19:	e8 a6 fc ff ff       	call   8009c4 <fd_lookup>
  800d1e:	83 c4 08             	add    $0x8,%esp
  800d21:	89 c2                	mov    %eax,%edx
  800d23:	85 c0                	test   %eax,%eax
  800d25:	78 6b                	js     800d92 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d27:	83 ec 08             	sub    $0x8,%esp
  800d2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d2d:	50                   	push   %eax
  800d2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d31:	ff 30                	pushl  (%eax)
  800d33:	e8 e2 fc ff ff       	call   800a1a <dev_lookup>
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	78 4a                	js     800d89 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d42:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d46:	75 24                	jne    800d6c <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d48:	a1 04 40 80 00       	mov    0x804004,%eax
  800d4d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	53                   	push   %ebx
  800d57:	50                   	push   %eax
  800d58:	68 71 26 80 00       	push   $0x802671
  800d5d:	e8 c4 09 00 00       	call   801726 <cprintf>
		return -E_INVAL;
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d6a:	eb 26                	jmp    800d92 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d6f:	8b 52 0c             	mov    0xc(%edx),%edx
  800d72:	85 d2                	test   %edx,%edx
  800d74:	74 17                	je     800d8d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d76:	83 ec 04             	sub    $0x4,%esp
  800d79:	ff 75 10             	pushl  0x10(%ebp)
  800d7c:	ff 75 0c             	pushl  0xc(%ebp)
  800d7f:	50                   	push   %eax
  800d80:	ff d2                	call   *%edx
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	83 c4 10             	add    $0x10,%esp
  800d87:	eb 09                	jmp    800d92 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d89:	89 c2                	mov    %eax,%edx
  800d8b:	eb 05                	jmp    800d92 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d8d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d92:	89 d0                	mov    %edx,%eax
  800d94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    

00800d99 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d9f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800da2:	50                   	push   %eax
  800da3:	ff 75 08             	pushl  0x8(%ebp)
  800da6:	e8 19 fc ff ff       	call   8009c4 <fd_lookup>
  800dab:	83 c4 08             	add    $0x8,%esp
  800dae:	85 c0                	test   %eax,%eax
  800db0:	78 0e                	js     800dc0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800db2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800db5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800dbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc0:	c9                   	leave  
  800dc1:	c3                   	ret    

00800dc2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 14             	sub    $0x14,%esp
  800dc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dcc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dcf:	50                   	push   %eax
  800dd0:	53                   	push   %ebx
  800dd1:	e8 ee fb ff ff       	call   8009c4 <fd_lookup>
  800dd6:	83 c4 08             	add    $0x8,%esp
  800dd9:	89 c2                	mov    %eax,%edx
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	78 68                	js     800e47 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ddf:	83 ec 08             	sub    $0x8,%esp
  800de2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800de5:	50                   	push   %eax
  800de6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de9:	ff 30                	pushl  (%eax)
  800deb:	e8 2a fc ff ff       	call   800a1a <dev_lookup>
  800df0:	83 c4 10             	add    $0x10,%esp
  800df3:	85 c0                	test   %eax,%eax
  800df5:	78 47                	js     800e3e <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800dfe:	75 24                	jne    800e24 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800e00:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800e05:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	53                   	push   %ebx
  800e0f:	50                   	push   %eax
  800e10:	68 34 26 80 00       	push   $0x802634
  800e15:	e8 0c 09 00 00       	call   801726 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800e1a:	83 c4 10             	add    $0x10,%esp
  800e1d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e22:	eb 23                	jmp    800e47 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800e24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e27:	8b 52 18             	mov    0x18(%edx),%edx
  800e2a:	85 d2                	test   %edx,%edx
  800e2c:	74 14                	je     800e42 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	ff 75 0c             	pushl  0xc(%ebp)
  800e34:	50                   	push   %eax
  800e35:	ff d2                	call   *%edx
  800e37:	89 c2                	mov    %eax,%edx
  800e39:	83 c4 10             	add    $0x10,%esp
  800e3c:	eb 09                	jmp    800e47 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e3e:	89 c2                	mov    %eax,%edx
  800e40:	eb 05                	jmp    800e47 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800e42:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800e47:	89 d0                	mov    %edx,%eax
  800e49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4c:	c9                   	leave  
  800e4d:	c3                   	ret    

00800e4e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	53                   	push   %ebx
  800e52:	83 ec 14             	sub    $0x14,%esp
  800e55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e58:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e5b:	50                   	push   %eax
  800e5c:	ff 75 08             	pushl  0x8(%ebp)
  800e5f:	e8 60 fb ff ff       	call   8009c4 <fd_lookup>
  800e64:	83 c4 08             	add    $0x8,%esp
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	78 58                	js     800ec5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e73:	50                   	push   %eax
  800e74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e77:	ff 30                	pushl  (%eax)
  800e79:	e8 9c fb ff ff       	call   800a1a <dev_lookup>
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	85 c0                	test   %eax,%eax
  800e83:	78 37                	js     800ebc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e88:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e8c:	74 32                	je     800ec0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e8e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e91:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e98:	00 00 00 
	stat->st_isdir = 0;
  800e9b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ea2:	00 00 00 
	stat->st_dev = dev;
  800ea5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800eab:	83 ec 08             	sub    $0x8,%esp
  800eae:	53                   	push   %ebx
  800eaf:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb2:	ff 50 14             	call   *0x14(%eax)
  800eb5:	89 c2                	mov    %eax,%edx
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	eb 09                	jmp    800ec5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ebc:	89 c2                	mov    %eax,%edx
  800ebe:	eb 05                	jmp    800ec5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ec0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800ec5:	89 d0                	mov    %edx,%eax
  800ec7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ed1:	83 ec 08             	sub    $0x8,%esp
  800ed4:	6a 00                	push   $0x0
  800ed6:	ff 75 08             	pushl  0x8(%ebp)
  800ed9:	e8 e3 01 00 00       	call   8010c1 <open>
  800ede:	89 c3                	mov    %eax,%ebx
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	78 1b                	js     800f02 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800ee7:	83 ec 08             	sub    $0x8,%esp
  800eea:	ff 75 0c             	pushl  0xc(%ebp)
  800eed:	50                   	push   %eax
  800eee:	e8 5b ff ff ff       	call   800e4e <fstat>
  800ef3:	89 c6                	mov    %eax,%esi
	close(fd);
  800ef5:	89 1c 24             	mov    %ebx,(%esp)
  800ef8:	e8 f4 fb ff ff       	call   800af1 <close>
	return r;
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	89 f0                	mov    %esi,%eax
}
  800f02:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	89 c6                	mov    %eax,%esi
  800f10:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800f12:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800f19:	75 12                	jne    800f2d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800f1b:	83 ec 0c             	sub    $0xc,%esp
  800f1e:	6a 01                	push   $0x1
  800f20:	e8 39 12 00 00       	call   80215e <ipc_find_env>
  800f25:	a3 00 40 80 00       	mov    %eax,0x804000
  800f2a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800f2d:	6a 07                	push   $0x7
  800f2f:	68 00 50 80 00       	push   $0x805000
  800f34:	56                   	push   %esi
  800f35:	ff 35 00 40 80 00    	pushl  0x804000
  800f3b:	e8 bc 11 00 00       	call   8020fc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800f40:	83 c4 0c             	add    $0xc,%esp
  800f43:	6a 00                	push   $0x0
  800f45:	53                   	push   %ebx
  800f46:	6a 00                	push   $0x0
  800f48:	e8 34 11 00 00       	call   802081 <ipc_recv>
}
  800f4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    

00800f54 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5d:	8b 40 0c             	mov    0xc(%eax),%eax
  800f60:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f68:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f72:	b8 02 00 00 00       	mov    $0x2,%eax
  800f77:	e8 8d ff ff ff       	call   800f09 <fsipc>
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
  800f87:	8b 40 0c             	mov    0xc(%eax),%eax
  800f8a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f94:	b8 06 00 00 00       	mov    $0x6,%eax
  800f99:	e8 6b ff ff ff       	call   800f09 <fsipc>
}
  800f9e:	c9                   	leave  
  800f9f:	c3                   	ret    

00800fa0 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800faa:	8b 45 08             	mov    0x8(%ebp),%eax
  800fad:	8b 40 0c             	mov    0xc(%eax),%eax
  800fb0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800fb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fba:	b8 05 00 00 00       	mov    $0x5,%eax
  800fbf:	e8 45 ff ff ff       	call   800f09 <fsipc>
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 2c                	js     800ff4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800fc8:	83 ec 08             	sub    $0x8,%esp
  800fcb:	68 00 50 80 00       	push   $0x805000
  800fd0:	53                   	push   %ebx
  800fd1:	e8 d5 0c 00 00       	call   801cab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800fd6:	a1 80 50 80 00       	mov    0x805080,%eax
  800fdb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800fe1:	a1 84 50 80 00       	mov    0x805084,%eax
  800fe6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800fec:	83 c4 10             	add    $0x10,%esp
  800fef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801002:	8b 55 08             	mov    0x8(%ebp),%edx
  801005:	8b 52 0c             	mov    0xc(%edx),%edx
  801008:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80100e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801013:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801018:	0f 47 c2             	cmova  %edx,%eax
  80101b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801020:	50                   	push   %eax
  801021:	ff 75 0c             	pushl  0xc(%ebp)
  801024:	68 08 50 80 00       	push   $0x805008
  801029:	e8 0f 0e 00 00       	call   801e3d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  80102e:	ba 00 00 00 00       	mov    $0x0,%edx
  801033:	b8 04 00 00 00       	mov    $0x4,%eax
  801038:	e8 cc fe ff ff       	call   800f09 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  80103d:	c9                   	leave  
  80103e:	c3                   	ret    

0080103f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
  801044:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801047:	8b 45 08             	mov    0x8(%ebp),%eax
  80104a:	8b 40 0c             	mov    0xc(%eax),%eax
  80104d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801052:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801058:	ba 00 00 00 00       	mov    $0x0,%edx
  80105d:	b8 03 00 00 00       	mov    $0x3,%eax
  801062:	e8 a2 fe ff ff       	call   800f09 <fsipc>
  801067:	89 c3                	mov    %eax,%ebx
  801069:	85 c0                	test   %eax,%eax
  80106b:	78 4b                	js     8010b8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80106d:	39 c6                	cmp    %eax,%esi
  80106f:	73 16                	jae    801087 <devfile_read+0x48>
  801071:	68 a0 26 80 00       	push   $0x8026a0
  801076:	68 a7 26 80 00       	push   $0x8026a7
  80107b:	6a 7c                	push   $0x7c
  80107d:	68 bc 26 80 00       	push   $0x8026bc
  801082:	e8 c6 05 00 00       	call   80164d <_panic>
	assert(r <= PGSIZE);
  801087:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80108c:	7e 16                	jle    8010a4 <devfile_read+0x65>
  80108e:	68 c7 26 80 00       	push   $0x8026c7
  801093:	68 a7 26 80 00       	push   $0x8026a7
  801098:	6a 7d                	push   $0x7d
  80109a:	68 bc 26 80 00       	push   $0x8026bc
  80109f:	e8 a9 05 00 00       	call   80164d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8010a4:	83 ec 04             	sub    $0x4,%esp
  8010a7:	50                   	push   %eax
  8010a8:	68 00 50 80 00       	push   $0x805000
  8010ad:	ff 75 0c             	pushl  0xc(%ebp)
  8010b0:	e8 88 0d 00 00       	call   801e3d <memmove>
	return r;
  8010b5:	83 c4 10             	add    $0x10,%esp
}
  8010b8:	89 d8                	mov    %ebx,%eax
  8010ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010bd:	5b                   	pop    %ebx
  8010be:	5e                   	pop    %esi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	53                   	push   %ebx
  8010c5:	83 ec 20             	sub    $0x20,%esp
  8010c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8010cb:	53                   	push   %ebx
  8010cc:	e8 a1 0b 00 00       	call   801c72 <strlen>
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010d9:	7f 67                	jg     801142 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e1:	50                   	push   %eax
  8010e2:	e8 8e f8 ff ff       	call   800975 <fd_alloc>
  8010e7:	83 c4 10             	add    $0x10,%esp
		return r;
  8010ea:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 57                	js     801147 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8010f0:	83 ec 08             	sub    $0x8,%esp
  8010f3:	53                   	push   %ebx
  8010f4:	68 00 50 80 00       	push   $0x805000
  8010f9:	e8 ad 0b 00 00       	call   801cab <strcpy>
	fsipcbuf.open.req_omode = mode;
  8010fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801101:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801106:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801109:	b8 01 00 00 00       	mov    $0x1,%eax
  80110e:	e8 f6 fd ff ff       	call   800f09 <fsipc>
  801113:	89 c3                	mov    %eax,%ebx
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	85 c0                	test   %eax,%eax
  80111a:	79 14                	jns    801130 <open+0x6f>
		fd_close(fd, 0);
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	6a 00                	push   $0x0
  801121:	ff 75 f4             	pushl  -0xc(%ebp)
  801124:	e8 47 f9 ff ff       	call   800a70 <fd_close>
		return r;
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	89 da                	mov    %ebx,%edx
  80112e:	eb 17                	jmp    801147 <open+0x86>
	}

	return fd2num(fd);
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	ff 75 f4             	pushl  -0xc(%ebp)
  801136:	e8 13 f8 ff ff       	call   80094e <fd2num>
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	eb 05                	jmp    801147 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801142:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801147:	89 d0                	mov    %edx,%eax
  801149:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    

0080114e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801154:	ba 00 00 00 00       	mov    $0x0,%edx
  801159:	b8 08 00 00 00       	mov    $0x8,%eax
  80115e:	e8 a6 fd ff ff       	call   800f09 <fsipc>
}
  801163:	c9                   	leave  
  801164:	c3                   	ret    

00801165 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	ff 75 08             	pushl  0x8(%ebp)
  801173:	e8 e6 f7 ff ff       	call   80095e <fd2data>
  801178:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80117a:	83 c4 08             	add    $0x8,%esp
  80117d:	68 d3 26 80 00       	push   $0x8026d3
  801182:	53                   	push   %ebx
  801183:	e8 23 0b 00 00       	call   801cab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801188:	8b 46 04             	mov    0x4(%esi),%eax
  80118b:	2b 06                	sub    (%esi),%eax
  80118d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801193:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80119a:	00 00 00 
	stat->st_dev = &devpipe;
  80119d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8011a4:	30 80 00 
	return 0;
}
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011af:	5b                   	pop    %ebx
  8011b0:	5e                   	pop    %esi
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8011bd:	53                   	push   %ebx
  8011be:	6a 00                	push   $0x0
  8011c0:	e8 41 f0 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8011c5:	89 1c 24             	mov    %ebx,(%esp)
  8011c8:	e8 91 f7 ff ff       	call   80095e <fd2data>
  8011cd:	83 c4 08             	add    $0x8,%esp
  8011d0:	50                   	push   %eax
  8011d1:	6a 00                	push   $0x0
  8011d3:	e8 2e f0 ff ff       	call   800206 <sys_page_unmap>
}
  8011d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    

008011dd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 1c             	sub    $0x1c,%esp
  8011e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011e9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8011eb:	a1 04 40 80 00       	mov    0x804004,%eax
  8011f0:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8011f6:	83 ec 0c             	sub    $0xc,%esp
  8011f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011fc:	e8 a2 0f 00 00       	call   8021a3 <pageref>
  801201:	89 c3                	mov    %eax,%ebx
  801203:	89 3c 24             	mov    %edi,(%esp)
  801206:	e8 98 0f 00 00       	call   8021a3 <pageref>
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	39 c3                	cmp    %eax,%ebx
  801210:	0f 94 c1             	sete   %cl
  801213:	0f b6 c9             	movzbl %cl,%ecx
  801216:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801219:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80121f:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801225:	39 ce                	cmp    %ecx,%esi
  801227:	74 1e                	je     801247 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801229:	39 c3                	cmp    %eax,%ebx
  80122b:	75 be                	jne    8011eb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80122d:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801233:	ff 75 e4             	pushl  -0x1c(%ebp)
  801236:	50                   	push   %eax
  801237:	56                   	push   %esi
  801238:	68 da 26 80 00       	push   $0x8026da
  80123d:	e8 e4 04 00 00       	call   801726 <cprintf>
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	eb a4                	jmp    8011eb <_pipeisclosed+0xe>
	}
}
  801247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80124a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 28             	sub    $0x28,%esp
  80125b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80125e:	56                   	push   %esi
  80125f:	e8 fa f6 ff ff       	call   80095e <fd2data>
  801264:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	bf 00 00 00 00       	mov    $0x0,%edi
  80126e:	eb 4b                	jmp    8012bb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801270:	89 da                	mov    %ebx,%edx
  801272:	89 f0                	mov    %esi,%eax
  801274:	e8 64 ff ff ff       	call   8011dd <_pipeisclosed>
  801279:	85 c0                	test   %eax,%eax
  80127b:	75 48                	jne    8012c5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80127d:	e8 e0 ee ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801282:	8b 43 04             	mov    0x4(%ebx),%eax
  801285:	8b 0b                	mov    (%ebx),%ecx
  801287:	8d 51 20             	lea    0x20(%ecx),%edx
  80128a:	39 d0                	cmp    %edx,%eax
  80128c:	73 e2                	jae    801270 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80128e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801291:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801295:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801298:	89 c2                	mov    %eax,%edx
  80129a:	c1 fa 1f             	sar    $0x1f,%edx
  80129d:	89 d1                	mov    %edx,%ecx
  80129f:	c1 e9 1b             	shr    $0x1b,%ecx
  8012a2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8012a5:	83 e2 1f             	and    $0x1f,%edx
  8012a8:	29 ca                	sub    %ecx,%edx
  8012aa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8012ae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8012b2:	83 c0 01             	add    $0x1,%eax
  8012b5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012b8:	83 c7 01             	add    $0x1,%edi
  8012bb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8012be:	75 c2                	jne    801282 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8012c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c3:	eb 05                	jmp    8012ca <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8012ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012cd:	5b                   	pop    %ebx
  8012ce:	5e                   	pop    %esi
  8012cf:	5f                   	pop    %edi
  8012d0:	5d                   	pop    %ebp
  8012d1:	c3                   	ret    

008012d2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 18             	sub    $0x18,%esp
  8012db:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8012de:	57                   	push   %edi
  8012df:	e8 7a f6 ff ff       	call   80095e <fd2data>
  8012e4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ee:	eb 3d                	jmp    80132d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8012f0:	85 db                	test   %ebx,%ebx
  8012f2:	74 04                	je     8012f8 <devpipe_read+0x26>
				return i;
  8012f4:	89 d8                	mov    %ebx,%eax
  8012f6:	eb 44                	jmp    80133c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8012f8:	89 f2                	mov    %esi,%edx
  8012fa:	89 f8                	mov    %edi,%eax
  8012fc:	e8 dc fe ff ff       	call   8011dd <_pipeisclosed>
  801301:	85 c0                	test   %eax,%eax
  801303:	75 32                	jne    801337 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801305:	e8 58 ee ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80130a:	8b 06                	mov    (%esi),%eax
  80130c:	3b 46 04             	cmp    0x4(%esi),%eax
  80130f:	74 df                	je     8012f0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801311:	99                   	cltd   
  801312:	c1 ea 1b             	shr    $0x1b,%edx
  801315:	01 d0                	add    %edx,%eax
  801317:	83 e0 1f             	and    $0x1f,%eax
  80131a:	29 d0                	sub    %edx,%eax
  80131c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801321:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801324:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801327:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80132a:	83 c3 01             	add    $0x1,%ebx
  80132d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801330:	75 d8                	jne    80130a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801332:	8b 45 10             	mov    0x10(%ebp),%eax
  801335:	eb 05                	jmp    80133c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801337:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80133c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80133f:	5b                   	pop    %ebx
  801340:	5e                   	pop    %esi
  801341:	5f                   	pop    %edi
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	56                   	push   %esi
  801348:	53                   	push   %ebx
  801349:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80134c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	e8 20 f6 ff ff       	call   800975 <fd_alloc>
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	89 c2                	mov    %eax,%edx
  80135a:	85 c0                	test   %eax,%eax
  80135c:	0f 88 2c 01 00 00    	js     80148e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801362:	83 ec 04             	sub    $0x4,%esp
  801365:	68 07 04 00 00       	push   $0x407
  80136a:	ff 75 f4             	pushl  -0xc(%ebp)
  80136d:	6a 00                	push   $0x0
  80136f:	e8 0d ee ff ff       	call   800181 <sys_page_alloc>
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	89 c2                	mov    %eax,%edx
  801379:	85 c0                	test   %eax,%eax
  80137b:	0f 88 0d 01 00 00    	js     80148e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801381:	83 ec 0c             	sub    $0xc,%esp
  801384:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801387:	50                   	push   %eax
  801388:	e8 e8 f5 ff ff       	call   800975 <fd_alloc>
  80138d:	89 c3                	mov    %eax,%ebx
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	0f 88 e2 00 00 00    	js     80147c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80139a:	83 ec 04             	sub    $0x4,%esp
  80139d:	68 07 04 00 00       	push   $0x407
  8013a2:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a5:	6a 00                	push   $0x0
  8013a7:	e8 d5 ed ff ff       	call   800181 <sys_page_alloc>
  8013ac:	89 c3                	mov    %eax,%ebx
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	0f 88 c3 00 00 00    	js     80147c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8013b9:	83 ec 0c             	sub    $0xc,%esp
  8013bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8013bf:	e8 9a f5 ff ff       	call   80095e <fd2data>
  8013c4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013c6:	83 c4 0c             	add    $0xc,%esp
  8013c9:	68 07 04 00 00       	push   $0x407
  8013ce:	50                   	push   %eax
  8013cf:	6a 00                	push   $0x0
  8013d1:	e8 ab ed ff ff       	call   800181 <sys_page_alloc>
  8013d6:	89 c3                	mov    %eax,%ebx
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	0f 88 89 00 00 00    	js     80146c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e9:	e8 70 f5 ff ff       	call   80095e <fd2data>
  8013ee:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8013f5:	50                   	push   %eax
  8013f6:	6a 00                	push   $0x0
  8013f8:	56                   	push   %esi
  8013f9:	6a 00                	push   $0x0
  8013fb:	e8 c4 ed ff ff       	call   8001c4 <sys_page_map>
  801400:	89 c3                	mov    %eax,%ebx
  801402:	83 c4 20             	add    $0x20,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	78 55                	js     80145e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801409:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80140f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801412:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801414:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801417:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80141e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801424:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801427:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801429:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801433:	83 ec 0c             	sub    $0xc,%esp
  801436:	ff 75 f4             	pushl  -0xc(%ebp)
  801439:	e8 10 f5 ff ff       	call   80094e <fd2num>
  80143e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801441:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801443:	83 c4 04             	add    $0x4,%esp
  801446:	ff 75 f0             	pushl  -0x10(%ebp)
  801449:	e8 00 f5 ff ff       	call   80094e <fd2num>
  80144e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801451:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	ba 00 00 00 00       	mov    $0x0,%edx
  80145c:	eb 30                	jmp    80148e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	56                   	push   %esi
  801462:	6a 00                	push   $0x0
  801464:	e8 9d ed ff ff       	call   800206 <sys_page_unmap>
  801469:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	ff 75 f0             	pushl  -0x10(%ebp)
  801472:	6a 00                	push   $0x0
  801474:	e8 8d ed ff ff       	call   800206 <sys_page_unmap>
  801479:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80147c:	83 ec 08             	sub    $0x8,%esp
  80147f:	ff 75 f4             	pushl  -0xc(%ebp)
  801482:	6a 00                	push   $0x0
  801484:	e8 7d ed ff ff       	call   800206 <sys_page_unmap>
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80148e:	89 d0                	mov    %edx,%eax
  801490:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801493:	5b                   	pop    %ebx
  801494:	5e                   	pop    %esi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80149d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a0:	50                   	push   %eax
  8014a1:	ff 75 08             	pushl  0x8(%ebp)
  8014a4:	e8 1b f5 ff ff       	call   8009c4 <fd_lookup>
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 18                	js     8014c8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8014b0:	83 ec 0c             	sub    $0xc,%esp
  8014b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b6:	e8 a3 f4 ff ff       	call   80095e <fd2data>
	return _pipeisclosed(fd, p);
  8014bb:	89 c2                	mov    %eax,%edx
  8014bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c0:	e8 18 fd ff ff       	call   8011dd <_pipeisclosed>
  8014c5:	83 c4 10             	add    $0x10,%esp
}
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8014cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d2:	5d                   	pop    %ebp
  8014d3:	c3                   	ret    

008014d4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8014da:	68 f2 26 80 00       	push   $0x8026f2
  8014df:	ff 75 0c             	pushl  0xc(%ebp)
  8014e2:	e8 c4 07 00 00       	call   801cab <strcpy>
	return 0;
}
  8014e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	57                   	push   %edi
  8014f2:	56                   	push   %esi
  8014f3:	53                   	push   %ebx
  8014f4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014fa:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014ff:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801505:	eb 2d                	jmp    801534 <devcons_write+0x46>
		m = n - tot;
  801507:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80150a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80150c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80150f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801514:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	53                   	push   %ebx
  80151b:	03 45 0c             	add    0xc(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	57                   	push   %edi
  801520:	e8 18 09 00 00       	call   801e3d <memmove>
		sys_cputs(buf, m);
  801525:	83 c4 08             	add    $0x8,%esp
  801528:	53                   	push   %ebx
  801529:	57                   	push   %edi
  80152a:	e8 96 eb ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80152f:	01 de                	add    %ebx,%esi
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	89 f0                	mov    %esi,%eax
  801536:	3b 75 10             	cmp    0x10(%ebp),%esi
  801539:	72 cc                	jb     801507 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80153b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5e                   	pop    %esi
  801540:	5f                   	pop    %edi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    

00801543 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	83 ec 08             	sub    $0x8,%esp
  801549:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80154e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801552:	74 2a                	je     80157e <devcons_read+0x3b>
  801554:	eb 05                	jmp    80155b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801556:	e8 07 ec ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80155b:	e8 83 eb ff ff       	call   8000e3 <sys_cgetc>
  801560:	85 c0                	test   %eax,%eax
  801562:	74 f2                	je     801556 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801564:	85 c0                	test   %eax,%eax
  801566:	78 16                	js     80157e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801568:	83 f8 04             	cmp    $0x4,%eax
  80156b:	74 0c                	je     801579 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80156d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801570:	88 02                	mov    %al,(%edx)
	return 1;
  801572:	b8 01 00 00 00       	mov    $0x1,%eax
  801577:	eb 05                	jmp    80157e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801579:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801586:	8b 45 08             	mov    0x8(%ebp),%eax
  801589:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80158c:	6a 01                	push   $0x1
  80158e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	e8 2e eb ff ff       	call   8000c5 <sys_cputs>
}
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	c9                   	leave  
  80159b:	c3                   	ret    

0080159c <getchar>:

int
getchar(void)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8015a2:	6a 01                	push   $0x1
  8015a4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	6a 00                	push   $0x0
  8015aa:	e8 7e f6 ff ff       	call   800c2d <read>
	if (r < 0)
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 0f                	js     8015c5 <getchar+0x29>
		return r;
	if (r < 1)
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	7e 06                	jle    8015c0 <getchar+0x24>
		return -E_EOF;
	return c;
  8015ba:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8015be:	eb 05                	jmp    8015c5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8015c0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d0:	50                   	push   %eax
  8015d1:	ff 75 08             	pushl  0x8(%ebp)
  8015d4:	e8 eb f3 ff ff       	call   8009c4 <fd_lookup>
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 11                	js     8015f1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8015e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015e9:	39 10                	cmp    %edx,(%eax)
  8015eb:	0f 94 c0             	sete   %al
  8015ee:	0f b6 c0             	movzbl %al,%eax
}
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <opencons>:

int
opencons(void)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	e8 73 f3 ff ff       	call   800975 <fd_alloc>
  801602:	83 c4 10             	add    $0x10,%esp
		return r;
  801605:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801607:	85 c0                	test   %eax,%eax
  801609:	78 3e                	js     801649 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80160b:	83 ec 04             	sub    $0x4,%esp
  80160e:	68 07 04 00 00       	push   $0x407
  801613:	ff 75 f4             	pushl  -0xc(%ebp)
  801616:	6a 00                	push   $0x0
  801618:	e8 64 eb ff ff       	call   800181 <sys_page_alloc>
  80161d:	83 c4 10             	add    $0x10,%esp
		return r;
  801620:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801622:	85 c0                	test   %eax,%eax
  801624:	78 23                	js     801649 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801626:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80162c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801631:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801634:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80163b:	83 ec 0c             	sub    $0xc,%esp
  80163e:	50                   	push   %eax
  80163f:	e8 0a f3 ff ff       	call   80094e <fd2num>
  801644:	89 c2                	mov    %eax,%edx
  801646:	83 c4 10             	add    $0x10,%esp
}
  801649:	89 d0                	mov    %edx,%eax
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	56                   	push   %esi
  801651:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801652:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801655:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80165b:	e8 e3 ea ff ff       	call   800143 <sys_getenvid>
  801660:	83 ec 0c             	sub    $0xc,%esp
  801663:	ff 75 0c             	pushl  0xc(%ebp)
  801666:	ff 75 08             	pushl  0x8(%ebp)
  801669:	56                   	push   %esi
  80166a:	50                   	push   %eax
  80166b:	68 00 27 80 00       	push   $0x802700
  801670:	e8 b1 00 00 00       	call   801726 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801675:	83 c4 18             	add    $0x18,%esp
  801678:	53                   	push   %ebx
  801679:	ff 75 10             	pushl  0x10(%ebp)
  80167c:	e8 54 00 00 00       	call   8016d5 <vcprintf>
	cprintf("\n");
  801681:	c7 04 24 51 25 80 00 	movl   $0x802551,(%esp)
  801688:	e8 99 00 00 00       	call   801726 <cprintf>
  80168d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801690:	cc                   	int3   
  801691:	eb fd                	jmp    801690 <_panic+0x43>

00801693 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	83 ec 04             	sub    $0x4,%esp
  80169a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80169d:	8b 13                	mov    (%ebx),%edx
  80169f:	8d 42 01             	lea    0x1(%edx),%eax
  8016a2:	89 03                	mov    %eax,(%ebx)
  8016a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8016ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8016b0:	75 1a                	jne    8016cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8016b2:	83 ec 08             	sub    $0x8,%esp
  8016b5:	68 ff 00 00 00       	push   $0xff
  8016ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8016bd:	50                   	push   %eax
  8016be:	e8 02 ea ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8016c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8016cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8016d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8016de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016e5:	00 00 00 
	b.cnt = 0;
  8016e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016f2:	ff 75 0c             	pushl  0xc(%ebp)
  8016f5:	ff 75 08             	pushl  0x8(%ebp)
  8016f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8016fe:	50                   	push   %eax
  8016ff:	68 93 16 80 00       	push   $0x801693
  801704:	e8 54 01 00 00       	call   80185d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801709:	83 c4 08             	add    $0x8,%esp
  80170c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801712:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801718:	50                   	push   %eax
  801719:	e8 a7 e9 ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  80171e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80172c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80172f:	50                   	push   %eax
  801730:	ff 75 08             	pushl  0x8(%ebp)
  801733:	e8 9d ff ff ff       	call   8016d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	57                   	push   %edi
  80173e:	56                   	push   %esi
  80173f:	53                   	push   %ebx
  801740:	83 ec 1c             	sub    $0x1c,%esp
  801743:	89 c7                	mov    %eax,%edi
  801745:	89 d6                	mov    %edx,%esi
  801747:	8b 45 08             	mov    0x8(%ebp),%eax
  80174a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80174d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801750:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801753:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801756:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80175e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801761:	39 d3                	cmp    %edx,%ebx
  801763:	72 05                	jb     80176a <printnum+0x30>
  801765:	39 45 10             	cmp    %eax,0x10(%ebp)
  801768:	77 45                	ja     8017af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80176a:	83 ec 0c             	sub    $0xc,%esp
  80176d:	ff 75 18             	pushl  0x18(%ebp)
  801770:	8b 45 14             	mov    0x14(%ebp),%eax
  801773:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801776:	53                   	push   %ebx
  801777:	ff 75 10             	pushl  0x10(%ebp)
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801780:	ff 75 e0             	pushl  -0x20(%ebp)
  801783:	ff 75 dc             	pushl  -0x24(%ebp)
  801786:	ff 75 d8             	pushl  -0x28(%ebp)
  801789:	e8 52 0a 00 00       	call   8021e0 <__udivdi3>
  80178e:	83 c4 18             	add    $0x18,%esp
  801791:	52                   	push   %edx
  801792:	50                   	push   %eax
  801793:	89 f2                	mov    %esi,%edx
  801795:	89 f8                	mov    %edi,%eax
  801797:	e8 9e ff ff ff       	call   80173a <printnum>
  80179c:	83 c4 20             	add    $0x20,%esp
  80179f:	eb 18                	jmp    8017b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8017a1:	83 ec 08             	sub    $0x8,%esp
  8017a4:	56                   	push   %esi
  8017a5:	ff 75 18             	pushl  0x18(%ebp)
  8017a8:	ff d7                	call   *%edi
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	eb 03                	jmp    8017b2 <printnum+0x78>
  8017af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017b2:	83 eb 01             	sub    $0x1,%ebx
  8017b5:	85 db                	test   %ebx,%ebx
  8017b7:	7f e8                	jg     8017a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	56                   	push   %esi
  8017bd:	83 ec 04             	sub    $0x4,%esp
  8017c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8017c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8017c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8017cc:	e8 3f 0b 00 00       	call   802310 <__umoddi3>
  8017d1:	83 c4 14             	add    $0x14,%esp
  8017d4:	0f be 80 23 27 80 00 	movsbl 0x802723(%eax),%eax
  8017db:	50                   	push   %eax
  8017dc:	ff d7                	call   *%edi
}
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e4:	5b                   	pop    %ebx
  8017e5:	5e                   	pop    %esi
  8017e6:	5f                   	pop    %edi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017ec:	83 fa 01             	cmp    $0x1,%edx
  8017ef:	7e 0e                	jle    8017ff <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017f1:	8b 10                	mov    (%eax),%edx
  8017f3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017f6:	89 08                	mov    %ecx,(%eax)
  8017f8:	8b 02                	mov    (%edx),%eax
  8017fa:	8b 52 04             	mov    0x4(%edx),%edx
  8017fd:	eb 22                	jmp    801821 <getuint+0x38>
	else if (lflag)
  8017ff:	85 d2                	test   %edx,%edx
  801801:	74 10                	je     801813 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801803:	8b 10                	mov    (%eax),%edx
  801805:	8d 4a 04             	lea    0x4(%edx),%ecx
  801808:	89 08                	mov    %ecx,(%eax)
  80180a:	8b 02                	mov    (%edx),%eax
  80180c:	ba 00 00 00 00       	mov    $0x0,%edx
  801811:	eb 0e                	jmp    801821 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801813:	8b 10                	mov    (%eax),%edx
  801815:	8d 4a 04             	lea    0x4(%edx),%ecx
  801818:	89 08                	mov    %ecx,(%eax)
  80181a:	8b 02                	mov    (%edx),%eax
  80181c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801829:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80182d:	8b 10                	mov    (%eax),%edx
  80182f:	3b 50 04             	cmp    0x4(%eax),%edx
  801832:	73 0a                	jae    80183e <sprintputch+0x1b>
		*b->buf++ = ch;
  801834:	8d 4a 01             	lea    0x1(%edx),%ecx
  801837:	89 08                	mov    %ecx,(%eax)
  801839:	8b 45 08             	mov    0x8(%ebp),%eax
  80183c:	88 02                	mov    %al,(%edx)
}
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    

00801840 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801846:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801849:	50                   	push   %eax
  80184a:	ff 75 10             	pushl  0x10(%ebp)
  80184d:	ff 75 0c             	pushl  0xc(%ebp)
  801850:	ff 75 08             	pushl  0x8(%ebp)
  801853:	e8 05 00 00 00       	call   80185d <vprintfmt>
	va_end(ap);
}
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	57                   	push   %edi
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	83 ec 2c             	sub    $0x2c,%esp
  801866:	8b 75 08             	mov    0x8(%ebp),%esi
  801869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80186c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80186f:	eb 12                	jmp    801883 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801871:	85 c0                	test   %eax,%eax
  801873:	0f 84 89 03 00 00    	je     801c02 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801879:	83 ec 08             	sub    $0x8,%esp
  80187c:	53                   	push   %ebx
  80187d:	50                   	push   %eax
  80187e:	ff d6                	call   *%esi
  801880:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801883:	83 c7 01             	add    $0x1,%edi
  801886:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80188a:	83 f8 25             	cmp    $0x25,%eax
  80188d:	75 e2                	jne    801871 <vprintfmt+0x14>
  80188f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801893:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80189a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8018a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ad:	eb 07                	jmp    8018b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b6:	8d 47 01             	lea    0x1(%edi),%eax
  8018b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018bc:	0f b6 07             	movzbl (%edi),%eax
  8018bf:	0f b6 c8             	movzbl %al,%ecx
  8018c2:	83 e8 23             	sub    $0x23,%eax
  8018c5:	3c 55                	cmp    $0x55,%al
  8018c7:	0f 87 1a 03 00 00    	ja     801be7 <vprintfmt+0x38a>
  8018cd:	0f b6 c0             	movzbl %al,%eax
  8018d0:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  8018d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8018da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8018de:	eb d6                	jmp    8018b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8018ee:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8018f2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8018f5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8018f8:	83 fa 09             	cmp    $0x9,%edx
  8018fb:	77 39                	ja     801936 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801900:	eb e9                	jmp    8018eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801902:	8b 45 14             	mov    0x14(%ebp),%eax
  801905:	8d 48 04             	lea    0x4(%eax),%ecx
  801908:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80190b:	8b 00                	mov    (%eax),%eax
  80190d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801910:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801913:	eb 27                	jmp    80193c <vprintfmt+0xdf>
  801915:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801918:	85 c0                	test   %eax,%eax
  80191a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80191f:	0f 49 c8             	cmovns %eax,%ecx
  801922:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801928:	eb 8c                	jmp    8018b6 <vprintfmt+0x59>
  80192a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80192d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801934:	eb 80                	jmp    8018b6 <vprintfmt+0x59>
  801936:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801939:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80193c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801940:	0f 89 70 ff ff ff    	jns    8018b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  801946:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801949:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80194c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801953:	e9 5e ff ff ff       	jmp    8018b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801958:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80195b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80195e:	e9 53 ff ff ff       	jmp    8018b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801963:	8b 45 14             	mov    0x14(%ebp),%eax
  801966:	8d 50 04             	lea    0x4(%eax),%edx
  801969:	89 55 14             	mov    %edx,0x14(%ebp)
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	53                   	push   %ebx
  801970:	ff 30                	pushl  (%eax)
  801972:	ff d6                	call   *%esi
			break;
  801974:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801977:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80197a:	e9 04 ff ff ff       	jmp    801883 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80197f:	8b 45 14             	mov    0x14(%ebp),%eax
  801982:	8d 50 04             	lea    0x4(%eax),%edx
  801985:	89 55 14             	mov    %edx,0x14(%ebp)
  801988:	8b 00                	mov    (%eax),%eax
  80198a:	99                   	cltd   
  80198b:	31 d0                	xor    %edx,%eax
  80198d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80198f:	83 f8 0f             	cmp    $0xf,%eax
  801992:	7f 0b                	jg     80199f <vprintfmt+0x142>
  801994:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  80199b:	85 d2                	test   %edx,%edx
  80199d:	75 18                	jne    8019b7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80199f:	50                   	push   %eax
  8019a0:	68 3b 27 80 00       	push   $0x80273b
  8019a5:	53                   	push   %ebx
  8019a6:	56                   	push   %esi
  8019a7:	e8 94 fe ff ff       	call   801840 <printfmt>
  8019ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019b2:	e9 cc fe ff ff       	jmp    801883 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8019b7:	52                   	push   %edx
  8019b8:	68 b9 26 80 00       	push   $0x8026b9
  8019bd:	53                   	push   %ebx
  8019be:	56                   	push   %esi
  8019bf:	e8 7c fe ff ff       	call   801840 <printfmt>
  8019c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019ca:	e9 b4 fe ff ff       	jmp    801883 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8019cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d2:	8d 50 04             	lea    0x4(%eax),%edx
  8019d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8019da:	85 ff                	test   %edi,%edi
  8019dc:	b8 34 27 80 00       	mov    $0x802734,%eax
  8019e1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8019e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019e8:	0f 8e 94 00 00 00    	jle    801a82 <vprintfmt+0x225>
  8019ee:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8019f2:	0f 84 98 00 00 00    	je     801a90 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8019f8:	83 ec 08             	sub    $0x8,%esp
  8019fb:	ff 75 d0             	pushl  -0x30(%ebp)
  8019fe:	57                   	push   %edi
  8019ff:	e8 86 02 00 00       	call   801c8a <strnlen>
  801a04:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801a07:	29 c1                	sub    %eax,%ecx
  801a09:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801a0c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801a0f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801a13:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a16:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801a19:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a1b:	eb 0f                	jmp    801a2c <vprintfmt+0x1cf>
					putch(padc, putdat);
  801a1d:	83 ec 08             	sub    $0x8,%esp
  801a20:	53                   	push   %ebx
  801a21:	ff 75 e0             	pushl  -0x20(%ebp)
  801a24:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a26:	83 ef 01             	sub    $0x1,%edi
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	85 ff                	test   %edi,%edi
  801a2e:	7f ed                	jg     801a1d <vprintfmt+0x1c0>
  801a30:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801a33:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801a36:	85 c9                	test   %ecx,%ecx
  801a38:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3d:	0f 49 c1             	cmovns %ecx,%eax
  801a40:	29 c1                	sub    %eax,%ecx
  801a42:	89 75 08             	mov    %esi,0x8(%ebp)
  801a45:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a48:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a4b:	89 cb                	mov    %ecx,%ebx
  801a4d:	eb 4d                	jmp    801a9c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a4f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a53:	74 1b                	je     801a70 <vprintfmt+0x213>
  801a55:	0f be c0             	movsbl %al,%eax
  801a58:	83 e8 20             	sub    $0x20,%eax
  801a5b:	83 f8 5e             	cmp    $0x5e,%eax
  801a5e:	76 10                	jbe    801a70 <vprintfmt+0x213>
					putch('?', putdat);
  801a60:	83 ec 08             	sub    $0x8,%esp
  801a63:	ff 75 0c             	pushl  0xc(%ebp)
  801a66:	6a 3f                	push   $0x3f
  801a68:	ff 55 08             	call   *0x8(%ebp)
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	eb 0d                	jmp    801a7d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	ff 75 0c             	pushl  0xc(%ebp)
  801a76:	52                   	push   %edx
  801a77:	ff 55 08             	call   *0x8(%ebp)
  801a7a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a7d:	83 eb 01             	sub    $0x1,%ebx
  801a80:	eb 1a                	jmp    801a9c <vprintfmt+0x23f>
  801a82:	89 75 08             	mov    %esi,0x8(%ebp)
  801a85:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a88:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a8b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a8e:	eb 0c                	jmp    801a9c <vprintfmt+0x23f>
  801a90:	89 75 08             	mov    %esi,0x8(%ebp)
  801a93:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a96:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a99:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a9c:	83 c7 01             	add    $0x1,%edi
  801a9f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801aa3:	0f be d0             	movsbl %al,%edx
  801aa6:	85 d2                	test   %edx,%edx
  801aa8:	74 23                	je     801acd <vprintfmt+0x270>
  801aaa:	85 f6                	test   %esi,%esi
  801aac:	78 a1                	js     801a4f <vprintfmt+0x1f2>
  801aae:	83 ee 01             	sub    $0x1,%esi
  801ab1:	79 9c                	jns    801a4f <vprintfmt+0x1f2>
  801ab3:	89 df                	mov    %ebx,%edi
  801ab5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801abb:	eb 18                	jmp    801ad5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801abd:	83 ec 08             	sub    $0x8,%esp
  801ac0:	53                   	push   %ebx
  801ac1:	6a 20                	push   $0x20
  801ac3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801ac5:	83 ef 01             	sub    $0x1,%edi
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	eb 08                	jmp    801ad5 <vprintfmt+0x278>
  801acd:	89 df                	mov    %ebx,%edi
  801acf:	8b 75 08             	mov    0x8(%ebp),%esi
  801ad2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ad5:	85 ff                	test   %edi,%edi
  801ad7:	7f e4                	jg     801abd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ad9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801adc:	e9 a2 fd ff ff       	jmp    801883 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801ae1:	83 fa 01             	cmp    $0x1,%edx
  801ae4:	7e 16                	jle    801afc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801ae6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae9:	8d 50 08             	lea    0x8(%eax),%edx
  801aec:	89 55 14             	mov    %edx,0x14(%ebp)
  801aef:	8b 50 04             	mov    0x4(%eax),%edx
  801af2:	8b 00                	mov    (%eax),%eax
  801af4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801af7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801afa:	eb 32                	jmp    801b2e <vprintfmt+0x2d1>
	else if (lflag)
  801afc:	85 d2                	test   %edx,%edx
  801afe:	74 18                	je     801b18 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801b00:	8b 45 14             	mov    0x14(%ebp),%eax
  801b03:	8d 50 04             	lea    0x4(%eax),%edx
  801b06:	89 55 14             	mov    %edx,0x14(%ebp)
  801b09:	8b 00                	mov    (%eax),%eax
  801b0b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b0e:	89 c1                	mov    %eax,%ecx
  801b10:	c1 f9 1f             	sar    $0x1f,%ecx
  801b13:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801b16:	eb 16                	jmp    801b2e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801b18:	8b 45 14             	mov    0x14(%ebp),%eax
  801b1b:	8d 50 04             	lea    0x4(%eax),%edx
  801b1e:	89 55 14             	mov    %edx,0x14(%ebp)
  801b21:	8b 00                	mov    (%eax),%eax
  801b23:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b26:	89 c1                	mov    %eax,%ecx
  801b28:	c1 f9 1f             	sar    $0x1f,%ecx
  801b2b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b2e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b31:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801b34:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b39:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b3d:	79 74                	jns    801bb3 <vprintfmt+0x356>
				putch('-', putdat);
  801b3f:	83 ec 08             	sub    $0x8,%esp
  801b42:	53                   	push   %ebx
  801b43:	6a 2d                	push   $0x2d
  801b45:	ff d6                	call   *%esi
				num = -(long long) num;
  801b47:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b4a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b4d:	f7 d8                	neg    %eax
  801b4f:	83 d2 00             	adc    $0x0,%edx
  801b52:	f7 da                	neg    %edx
  801b54:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b57:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b5c:	eb 55                	jmp    801bb3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b5e:	8d 45 14             	lea    0x14(%ebp),%eax
  801b61:	e8 83 fc ff ff       	call   8017e9 <getuint>
			base = 10;
  801b66:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b6b:	eb 46                	jmp    801bb3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b6d:	8d 45 14             	lea    0x14(%ebp),%eax
  801b70:	e8 74 fc ff ff       	call   8017e9 <getuint>
			base = 8;
  801b75:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b7a:	eb 37                	jmp    801bb3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b7c:	83 ec 08             	sub    $0x8,%esp
  801b7f:	53                   	push   %ebx
  801b80:	6a 30                	push   $0x30
  801b82:	ff d6                	call   *%esi
			putch('x', putdat);
  801b84:	83 c4 08             	add    $0x8,%esp
  801b87:	53                   	push   %ebx
  801b88:	6a 78                	push   $0x78
  801b8a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b8c:	8b 45 14             	mov    0x14(%ebp),%eax
  801b8f:	8d 50 04             	lea    0x4(%eax),%edx
  801b92:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b95:	8b 00                	mov    (%eax),%eax
  801b97:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b9c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b9f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801ba4:	eb 0d                	jmp    801bb3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ba6:	8d 45 14             	lea    0x14(%ebp),%eax
  801ba9:	e8 3b fc ff ff       	call   8017e9 <getuint>
			base = 16;
  801bae:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801bba:	57                   	push   %edi
  801bbb:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbe:	51                   	push   %ecx
  801bbf:	52                   	push   %edx
  801bc0:	50                   	push   %eax
  801bc1:	89 da                	mov    %ebx,%edx
  801bc3:	89 f0                	mov    %esi,%eax
  801bc5:	e8 70 fb ff ff       	call   80173a <printnum>
			break;
  801bca:	83 c4 20             	add    $0x20,%esp
  801bcd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bd0:	e9 ae fc ff ff       	jmp    801883 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	53                   	push   %ebx
  801bd9:	51                   	push   %ecx
  801bda:	ff d6                	call   *%esi
			break;
  801bdc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bdf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801be2:	e9 9c fc ff ff       	jmp    801883 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801be7:	83 ec 08             	sub    $0x8,%esp
  801bea:	53                   	push   %ebx
  801beb:	6a 25                	push   $0x25
  801bed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801bef:	83 c4 10             	add    $0x10,%esp
  801bf2:	eb 03                	jmp    801bf7 <vprintfmt+0x39a>
  801bf4:	83 ef 01             	sub    $0x1,%edi
  801bf7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801bfb:	75 f7                	jne    801bf4 <vprintfmt+0x397>
  801bfd:	e9 81 fc ff ff       	jmp    801883 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	83 ec 18             	sub    $0x18,%esp
  801c10:	8b 45 08             	mov    0x8(%ebp),%eax
  801c13:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c19:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c1d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c27:	85 c0                	test   %eax,%eax
  801c29:	74 26                	je     801c51 <vsnprintf+0x47>
  801c2b:	85 d2                	test   %edx,%edx
  801c2d:	7e 22                	jle    801c51 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c2f:	ff 75 14             	pushl  0x14(%ebp)
  801c32:	ff 75 10             	pushl  0x10(%ebp)
  801c35:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c38:	50                   	push   %eax
  801c39:	68 23 18 80 00       	push   $0x801823
  801c3e:	e8 1a fc ff ff       	call   80185d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c46:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	eb 05                	jmp    801c56 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c5e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c61:	50                   	push   %eax
  801c62:	ff 75 10             	pushl  0x10(%ebp)
  801c65:	ff 75 0c             	pushl  0xc(%ebp)
  801c68:	ff 75 08             	pushl  0x8(%ebp)
  801c6b:	e8 9a ff ff ff       	call   801c0a <vsnprintf>
	va_end(ap);

	return rc;
}
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c78:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7d:	eb 03                	jmp    801c82 <strlen+0x10>
		n++;
  801c7f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c82:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c86:	75 f7                	jne    801c7f <strlen+0xd>
		n++;
	return n;
}
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c90:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c93:	ba 00 00 00 00       	mov    $0x0,%edx
  801c98:	eb 03                	jmp    801c9d <strnlen+0x13>
		n++;
  801c9a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c9d:	39 c2                	cmp    %eax,%edx
  801c9f:	74 08                	je     801ca9 <strnlen+0x1f>
  801ca1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801ca5:	75 f3                	jne    801c9a <strnlen+0x10>
  801ca7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	53                   	push   %ebx
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801cb5:	89 c2                	mov    %eax,%edx
  801cb7:	83 c2 01             	add    $0x1,%edx
  801cba:	83 c1 01             	add    $0x1,%ecx
  801cbd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801cc1:	88 5a ff             	mov    %bl,-0x1(%edx)
  801cc4:	84 db                	test   %bl,%bl
  801cc6:	75 ef                	jne    801cb7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801cc8:	5b                   	pop    %ebx
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    

00801ccb <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	53                   	push   %ebx
  801ccf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801cd2:	53                   	push   %ebx
  801cd3:	e8 9a ff ff ff       	call   801c72 <strlen>
  801cd8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801cdb:	ff 75 0c             	pushl  0xc(%ebp)
  801cde:	01 d8                	add    %ebx,%eax
  801ce0:	50                   	push   %eax
  801ce1:	e8 c5 ff ff ff       	call   801cab <strcpy>
	return dst;
}
  801ce6:	89 d8                	mov    %ebx,%eax
  801ce8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	56                   	push   %esi
  801cf1:	53                   	push   %ebx
  801cf2:	8b 75 08             	mov    0x8(%ebp),%esi
  801cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf8:	89 f3                	mov    %esi,%ebx
  801cfa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cfd:	89 f2                	mov    %esi,%edx
  801cff:	eb 0f                	jmp    801d10 <strncpy+0x23>
		*dst++ = *src;
  801d01:	83 c2 01             	add    $0x1,%edx
  801d04:	0f b6 01             	movzbl (%ecx),%eax
  801d07:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d0a:	80 39 01             	cmpb   $0x1,(%ecx)
  801d0d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d10:	39 da                	cmp    %ebx,%edx
  801d12:	75 ed                	jne    801d01 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d14:	89 f0                	mov    %esi,%eax
  801d16:	5b                   	pop    %ebx
  801d17:	5e                   	pop    %esi
  801d18:	5d                   	pop    %ebp
  801d19:	c3                   	ret    

00801d1a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	56                   	push   %esi
  801d1e:	53                   	push   %ebx
  801d1f:	8b 75 08             	mov    0x8(%ebp),%esi
  801d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d25:	8b 55 10             	mov    0x10(%ebp),%edx
  801d28:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d2a:	85 d2                	test   %edx,%edx
  801d2c:	74 21                	je     801d4f <strlcpy+0x35>
  801d2e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	eb 09                	jmp    801d3f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d36:	83 c2 01             	add    $0x1,%edx
  801d39:	83 c1 01             	add    $0x1,%ecx
  801d3c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801d3f:	39 c2                	cmp    %eax,%edx
  801d41:	74 09                	je     801d4c <strlcpy+0x32>
  801d43:	0f b6 19             	movzbl (%ecx),%ebx
  801d46:	84 db                	test   %bl,%bl
  801d48:	75 ec                	jne    801d36 <strlcpy+0x1c>
  801d4a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d4c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d4f:	29 f0                	sub    %esi,%eax
}
  801d51:	5b                   	pop    %ebx
  801d52:	5e                   	pop    %esi
  801d53:	5d                   	pop    %ebp
  801d54:	c3                   	ret    

00801d55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d5e:	eb 06                	jmp    801d66 <strcmp+0x11>
		p++, q++;
  801d60:	83 c1 01             	add    $0x1,%ecx
  801d63:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d66:	0f b6 01             	movzbl (%ecx),%eax
  801d69:	84 c0                	test   %al,%al
  801d6b:	74 04                	je     801d71 <strcmp+0x1c>
  801d6d:	3a 02                	cmp    (%edx),%al
  801d6f:	74 ef                	je     801d60 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d71:	0f b6 c0             	movzbl %al,%eax
  801d74:	0f b6 12             	movzbl (%edx),%edx
  801d77:	29 d0                	sub    %edx,%eax
}
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    

00801d7b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d7b:	55                   	push   %ebp
  801d7c:	89 e5                	mov    %esp,%ebp
  801d7e:	53                   	push   %ebx
  801d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d82:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d85:	89 c3                	mov    %eax,%ebx
  801d87:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d8a:	eb 06                	jmp    801d92 <strncmp+0x17>
		n--, p++, q++;
  801d8c:	83 c0 01             	add    $0x1,%eax
  801d8f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d92:	39 d8                	cmp    %ebx,%eax
  801d94:	74 15                	je     801dab <strncmp+0x30>
  801d96:	0f b6 08             	movzbl (%eax),%ecx
  801d99:	84 c9                	test   %cl,%cl
  801d9b:	74 04                	je     801da1 <strncmp+0x26>
  801d9d:	3a 0a                	cmp    (%edx),%cl
  801d9f:	74 eb                	je     801d8c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801da1:	0f b6 00             	movzbl (%eax),%eax
  801da4:	0f b6 12             	movzbl (%edx),%edx
  801da7:	29 d0                	sub    %edx,%eax
  801da9:	eb 05                	jmp    801db0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801dab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801db0:	5b                   	pop    %ebx
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    

00801db3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	8b 45 08             	mov    0x8(%ebp),%eax
  801db9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801dbd:	eb 07                	jmp    801dc6 <strchr+0x13>
		if (*s == c)
  801dbf:	38 ca                	cmp    %cl,%dl
  801dc1:	74 0f                	je     801dd2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801dc3:	83 c0 01             	add    $0x1,%eax
  801dc6:	0f b6 10             	movzbl (%eax),%edx
  801dc9:	84 d2                	test   %dl,%dl
  801dcb:	75 f2                	jne    801dbf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801dcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    

00801dd4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dda:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801dde:	eb 03                	jmp    801de3 <strfind+0xf>
  801de0:	83 c0 01             	add    $0x1,%eax
  801de3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801de6:	38 ca                	cmp    %cl,%dl
  801de8:	74 04                	je     801dee <strfind+0x1a>
  801dea:	84 d2                	test   %dl,%dl
  801dec:	75 f2                	jne    801de0 <strfind+0xc>
			break;
	return (char *) s;
}
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    

00801df0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	57                   	push   %edi
  801df4:	56                   	push   %esi
  801df5:	53                   	push   %ebx
  801df6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801df9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801dfc:	85 c9                	test   %ecx,%ecx
  801dfe:	74 36                	je     801e36 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801e00:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801e06:	75 28                	jne    801e30 <memset+0x40>
  801e08:	f6 c1 03             	test   $0x3,%cl
  801e0b:	75 23                	jne    801e30 <memset+0x40>
		c &= 0xFF;
  801e0d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e11:	89 d3                	mov    %edx,%ebx
  801e13:	c1 e3 08             	shl    $0x8,%ebx
  801e16:	89 d6                	mov    %edx,%esi
  801e18:	c1 e6 18             	shl    $0x18,%esi
  801e1b:	89 d0                	mov    %edx,%eax
  801e1d:	c1 e0 10             	shl    $0x10,%eax
  801e20:	09 f0                	or     %esi,%eax
  801e22:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801e24:	89 d8                	mov    %ebx,%eax
  801e26:	09 d0                	or     %edx,%eax
  801e28:	c1 e9 02             	shr    $0x2,%ecx
  801e2b:	fc                   	cld    
  801e2c:	f3 ab                	rep stos %eax,%es:(%edi)
  801e2e:	eb 06                	jmp    801e36 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e33:	fc                   	cld    
  801e34:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e36:	89 f8                	mov    %edi,%eax
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    

00801e3d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	57                   	push   %edi
  801e41:	56                   	push   %esi
  801e42:	8b 45 08             	mov    0x8(%ebp),%eax
  801e45:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e4b:	39 c6                	cmp    %eax,%esi
  801e4d:	73 35                	jae    801e84 <memmove+0x47>
  801e4f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e52:	39 d0                	cmp    %edx,%eax
  801e54:	73 2e                	jae    801e84 <memmove+0x47>
		s += n;
		d += n;
  801e56:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e59:	89 d6                	mov    %edx,%esi
  801e5b:	09 fe                	or     %edi,%esi
  801e5d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e63:	75 13                	jne    801e78 <memmove+0x3b>
  801e65:	f6 c1 03             	test   $0x3,%cl
  801e68:	75 0e                	jne    801e78 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e6a:	83 ef 04             	sub    $0x4,%edi
  801e6d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e70:	c1 e9 02             	shr    $0x2,%ecx
  801e73:	fd                   	std    
  801e74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e76:	eb 09                	jmp    801e81 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e78:	83 ef 01             	sub    $0x1,%edi
  801e7b:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e7e:	fd                   	std    
  801e7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e81:	fc                   	cld    
  801e82:	eb 1d                	jmp    801ea1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e84:	89 f2                	mov    %esi,%edx
  801e86:	09 c2                	or     %eax,%edx
  801e88:	f6 c2 03             	test   $0x3,%dl
  801e8b:	75 0f                	jne    801e9c <memmove+0x5f>
  801e8d:	f6 c1 03             	test   $0x3,%cl
  801e90:	75 0a                	jne    801e9c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e92:	c1 e9 02             	shr    $0x2,%ecx
  801e95:	89 c7                	mov    %eax,%edi
  801e97:	fc                   	cld    
  801e98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e9a:	eb 05                	jmp    801ea1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e9c:	89 c7                	mov    %eax,%edi
  801e9e:	fc                   	cld    
  801e9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801ea1:	5e                   	pop    %esi
  801ea2:	5f                   	pop    %edi
  801ea3:	5d                   	pop    %ebp
  801ea4:	c3                   	ret    

00801ea5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801ea8:	ff 75 10             	pushl  0x10(%ebp)
  801eab:	ff 75 0c             	pushl  0xc(%ebp)
  801eae:	ff 75 08             	pushl  0x8(%ebp)
  801eb1:	e8 87 ff ff ff       	call   801e3d <memmove>
}
  801eb6:	c9                   	leave  
  801eb7:	c3                   	ret    

00801eb8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	56                   	push   %esi
  801ebc:	53                   	push   %ebx
  801ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec3:	89 c6                	mov    %eax,%esi
  801ec5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ec8:	eb 1a                	jmp    801ee4 <memcmp+0x2c>
		if (*s1 != *s2)
  801eca:	0f b6 08             	movzbl (%eax),%ecx
  801ecd:	0f b6 1a             	movzbl (%edx),%ebx
  801ed0:	38 d9                	cmp    %bl,%cl
  801ed2:	74 0a                	je     801ede <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ed4:	0f b6 c1             	movzbl %cl,%eax
  801ed7:	0f b6 db             	movzbl %bl,%ebx
  801eda:	29 d8                	sub    %ebx,%eax
  801edc:	eb 0f                	jmp    801eed <memcmp+0x35>
		s1++, s2++;
  801ede:	83 c0 01             	add    $0x1,%eax
  801ee1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ee4:	39 f0                	cmp    %esi,%eax
  801ee6:	75 e2                	jne    801eca <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ee8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eed:	5b                   	pop    %ebx
  801eee:	5e                   	pop    %esi
  801eef:	5d                   	pop    %ebp
  801ef0:	c3                   	ret    

00801ef1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	53                   	push   %ebx
  801ef5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801ef8:	89 c1                	mov    %eax,%ecx
  801efa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801efd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f01:	eb 0a                	jmp    801f0d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801f03:	0f b6 10             	movzbl (%eax),%edx
  801f06:	39 da                	cmp    %ebx,%edx
  801f08:	74 07                	je     801f11 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f0a:	83 c0 01             	add    $0x1,%eax
  801f0d:	39 c8                	cmp    %ecx,%eax
  801f0f:	72 f2                	jb     801f03 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801f11:	5b                   	pop    %ebx
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    

00801f14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	57                   	push   %edi
  801f18:	56                   	push   %esi
  801f19:	53                   	push   %ebx
  801f1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f20:	eb 03                	jmp    801f25 <strtol+0x11>
		s++;
  801f22:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f25:	0f b6 01             	movzbl (%ecx),%eax
  801f28:	3c 20                	cmp    $0x20,%al
  801f2a:	74 f6                	je     801f22 <strtol+0xe>
  801f2c:	3c 09                	cmp    $0x9,%al
  801f2e:	74 f2                	je     801f22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801f30:	3c 2b                	cmp    $0x2b,%al
  801f32:	75 0a                	jne    801f3e <strtol+0x2a>
		s++;
  801f34:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f37:	bf 00 00 00 00       	mov    $0x0,%edi
  801f3c:	eb 11                	jmp    801f4f <strtol+0x3b>
  801f3e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801f43:	3c 2d                	cmp    $0x2d,%al
  801f45:	75 08                	jne    801f4f <strtol+0x3b>
		s++, neg = 1;
  801f47:	83 c1 01             	add    $0x1,%ecx
  801f4a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f55:	75 15                	jne    801f6c <strtol+0x58>
  801f57:	80 39 30             	cmpb   $0x30,(%ecx)
  801f5a:	75 10                	jne    801f6c <strtol+0x58>
  801f5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f60:	75 7c                	jne    801fde <strtol+0xca>
		s += 2, base = 16;
  801f62:	83 c1 02             	add    $0x2,%ecx
  801f65:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f6a:	eb 16                	jmp    801f82 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f6c:	85 db                	test   %ebx,%ebx
  801f6e:	75 12                	jne    801f82 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f70:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f75:	80 39 30             	cmpb   $0x30,(%ecx)
  801f78:	75 08                	jne    801f82 <strtol+0x6e>
		s++, base = 8;
  801f7a:	83 c1 01             	add    $0x1,%ecx
  801f7d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f82:	b8 00 00 00 00       	mov    $0x0,%eax
  801f87:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f8a:	0f b6 11             	movzbl (%ecx),%edx
  801f8d:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f90:	89 f3                	mov    %esi,%ebx
  801f92:	80 fb 09             	cmp    $0x9,%bl
  801f95:	77 08                	ja     801f9f <strtol+0x8b>
			dig = *s - '0';
  801f97:	0f be d2             	movsbl %dl,%edx
  801f9a:	83 ea 30             	sub    $0x30,%edx
  801f9d:	eb 22                	jmp    801fc1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f9f:	8d 72 9f             	lea    -0x61(%edx),%esi
  801fa2:	89 f3                	mov    %esi,%ebx
  801fa4:	80 fb 19             	cmp    $0x19,%bl
  801fa7:	77 08                	ja     801fb1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801fa9:	0f be d2             	movsbl %dl,%edx
  801fac:	83 ea 57             	sub    $0x57,%edx
  801faf:	eb 10                	jmp    801fc1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801fb1:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fb4:	89 f3                	mov    %esi,%ebx
  801fb6:	80 fb 19             	cmp    $0x19,%bl
  801fb9:	77 16                	ja     801fd1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801fbb:	0f be d2             	movsbl %dl,%edx
  801fbe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801fc1:	3b 55 10             	cmp    0x10(%ebp),%edx
  801fc4:	7d 0b                	jge    801fd1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801fc6:	83 c1 01             	add    $0x1,%ecx
  801fc9:	0f af 45 10          	imul   0x10(%ebp),%eax
  801fcd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801fcf:	eb b9                	jmp    801f8a <strtol+0x76>

	if (endptr)
  801fd1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801fd5:	74 0d                	je     801fe4 <strtol+0xd0>
		*endptr = (char *) s;
  801fd7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fda:	89 0e                	mov    %ecx,(%esi)
  801fdc:	eb 06                	jmp    801fe4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801fde:	85 db                	test   %ebx,%ebx
  801fe0:	74 98                	je     801f7a <strtol+0x66>
  801fe2:	eb 9e                	jmp    801f82 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801fe4:	89 c2                	mov    %eax,%edx
  801fe6:	f7 da                	neg    %edx
  801fe8:	85 ff                	test   %edi,%edi
  801fea:	0f 45 c2             	cmovne %edx,%eax
}
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    

00801ff2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
  801ff5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ff8:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fff:	75 2a                	jne    80202b <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802001:	83 ec 04             	sub    $0x4,%esp
  802004:	6a 07                	push   $0x7
  802006:	68 00 f0 bf ee       	push   $0xeebff000
  80200b:	6a 00                	push   $0x0
  80200d:	e8 6f e1 ff ff       	call   800181 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	85 c0                	test   %eax,%eax
  802017:	79 12                	jns    80202b <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802019:	50                   	push   %eax
  80201a:	68 83 25 80 00       	push   $0x802583
  80201f:	6a 23                	push   $0x23
  802021:	68 20 2a 80 00       	push   $0x802a20
  802026:	e8 22 f6 ff ff       	call   80164d <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80202b:	8b 45 08             	mov    0x8(%ebp),%eax
  80202e:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802033:	83 ec 08             	sub    $0x8,%esp
  802036:	68 5d 20 80 00       	push   $0x80205d
  80203b:	6a 00                	push   $0x0
  80203d:	e8 8a e2 ff ff       	call   8002cc <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802042:	83 c4 10             	add    $0x10,%esp
  802045:	85 c0                	test   %eax,%eax
  802047:	79 12                	jns    80205b <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802049:	50                   	push   %eax
  80204a:	68 83 25 80 00       	push   $0x802583
  80204f:	6a 2c                	push   $0x2c
  802051:	68 20 2a 80 00       	push   $0x802a20
  802056:	e8 f2 f5 ff ff       	call   80164d <_panic>
	}
}
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    

0080205d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80205d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80205e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802063:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802065:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802068:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80206c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802071:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802075:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802077:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80207a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80207b:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80207e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80207f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802080:	c3                   	ret    

00802081 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	56                   	push   %esi
  802085:	53                   	push   %ebx
  802086:	8b 75 08             	mov    0x8(%ebp),%esi
  802089:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  80208f:	85 c0                	test   %eax,%eax
  802091:	75 12                	jne    8020a5 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802093:	83 ec 0c             	sub    $0xc,%esp
  802096:	68 00 00 c0 ee       	push   $0xeec00000
  80209b:	e8 91 e2 ff ff       	call   800331 <sys_ipc_recv>
  8020a0:	83 c4 10             	add    $0x10,%esp
  8020a3:	eb 0c                	jmp    8020b1 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020a5:	83 ec 0c             	sub    $0xc,%esp
  8020a8:	50                   	push   %eax
  8020a9:	e8 83 e2 ff ff       	call   800331 <sys_ipc_recv>
  8020ae:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020b1:	85 f6                	test   %esi,%esi
  8020b3:	0f 95 c1             	setne  %cl
  8020b6:	85 db                	test   %ebx,%ebx
  8020b8:	0f 95 c2             	setne  %dl
  8020bb:	84 d1                	test   %dl,%cl
  8020bd:	74 09                	je     8020c8 <ipc_recv+0x47>
  8020bf:	89 c2                	mov    %eax,%edx
  8020c1:	c1 ea 1f             	shr    $0x1f,%edx
  8020c4:	84 d2                	test   %dl,%dl
  8020c6:	75 2d                	jne    8020f5 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020c8:	85 f6                	test   %esi,%esi
  8020ca:	74 0d                	je     8020d9 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8020d1:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020d7:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020d9:	85 db                	test   %ebx,%ebx
  8020db:	74 0d                	je     8020ea <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e2:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8020e8:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ef:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8020f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f8:	5b                   	pop    %ebx
  8020f9:	5e                   	pop    %esi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    

008020fc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	57                   	push   %edi
  802100:	56                   	push   %esi
  802101:	53                   	push   %ebx
  802102:	83 ec 0c             	sub    $0xc,%esp
  802105:	8b 7d 08             	mov    0x8(%ebp),%edi
  802108:	8b 75 0c             	mov    0xc(%ebp),%esi
  80210b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80210e:	85 db                	test   %ebx,%ebx
  802110:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802115:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802118:	ff 75 14             	pushl  0x14(%ebp)
  80211b:	53                   	push   %ebx
  80211c:	56                   	push   %esi
  80211d:	57                   	push   %edi
  80211e:	e8 eb e1 ff ff       	call   80030e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802123:	89 c2                	mov    %eax,%edx
  802125:	c1 ea 1f             	shr    $0x1f,%edx
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	84 d2                	test   %dl,%dl
  80212d:	74 17                	je     802146 <ipc_send+0x4a>
  80212f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802132:	74 12                	je     802146 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802134:	50                   	push   %eax
  802135:	68 2e 2a 80 00       	push   $0x802a2e
  80213a:	6a 47                	push   $0x47
  80213c:	68 3c 2a 80 00       	push   $0x802a3c
  802141:	e8 07 f5 ff ff       	call   80164d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802146:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802149:	75 07                	jne    802152 <ipc_send+0x56>
			sys_yield();
  80214b:	e8 12 e0 ff ff       	call   800162 <sys_yield>
  802150:	eb c6                	jmp    802118 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802152:	85 c0                	test   %eax,%eax
  802154:	75 c2                	jne    802118 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802159:	5b                   	pop    %ebx
  80215a:	5e                   	pop    %esi
  80215b:	5f                   	pop    %edi
  80215c:	5d                   	pop    %ebp
  80215d:	c3                   	ret    

0080215e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80215e:	55                   	push   %ebp
  80215f:	89 e5                	mov    %esp,%ebp
  802161:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802164:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802169:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  80216f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802175:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  80217b:	39 ca                	cmp    %ecx,%edx
  80217d:	75 13                	jne    802192 <ipc_find_env+0x34>
			return envs[i].env_id;
  80217f:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802185:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80218a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802190:	eb 0f                	jmp    8021a1 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802192:	83 c0 01             	add    $0x1,%eax
  802195:	3d 00 04 00 00       	cmp    $0x400,%eax
  80219a:	75 cd                	jne    802169 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80219c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021a1:	5d                   	pop    %ebp
  8021a2:	c3                   	ret    

008021a3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a9:	89 d0                	mov    %edx,%eax
  8021ab:	c1 e8 16             	shr    $0x16,%eax
  8021ae:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021b5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ba:	f6 c1 01             	test   $0x1,%cl
  8021bd:	74 1d                	je     8021dc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021bf:	c1 ea 0c             	shr    $0xc,%edx
  8021c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021c9:	f6 c2 01             	test   $0x1,%dl
  8021cc:	74 0e                	je     8021dc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ce:	c1 ea 0c             	shr    $0xc,%edx
  8021d1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021d8:	ef 
  8021d9:	0f b7 c0             	movzwl %ax,%eax
}
  8021dc:	5d                   	pop    %ebp
  8021dd:	c3                   	ret    
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
