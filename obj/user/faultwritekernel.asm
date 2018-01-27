
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
  800057:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8000b1:	e8 bb 07 00 00       	call   800871 <close_all>
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
  80012a:	68 ca 21 80 00       	push   $0x8021ca
  80012f:	6a 23                	push   $0x23
  800131:	68 e7 21 80 00       	push   $0x8021e7
  800136:	e8 5e 12 00 00       	call   801399 <_panic>

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
  8001ab:	68 ca 21 80 00       	push   $0x8021ca
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 e7 21 80 00       	push   $0x8021e7
  8001b7:	e8 dd 11 00 00       	call   801399 <_panic>

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
  8001ed:	68 ca 21 80 00       	push   $0x8021ca
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 e7 21 80 00       	push   $0x8021e7
  8001f9:	e8 9b 11 00 00       	call   801399 <_panic>

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
  80022f:	68 ca 21 80 00       	push   $0x8021ca
  800234:	6a 23                	push   $0x23
  800236:	68 e7 21 80 00       	push   $0x8021e7
  80023b:	e8 59 11 00 00       	call   801399 <_panic>

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
  800271:	68 ca 21 80 00       	push   $0x8021ca
  800276:	6a 23                	push   $0x23
  800278:	68 e7 21 80 00       	push   $0x8021e7
  80027d:	e8 17 11 00 00       	call   801399 <_panic>

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
  8002b3:	68 ca 21 80 00       	push   $0x8021ca
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 e7 21 80 00       	push   $0x8021e7
  8002bf:	e8 d5 10 00 00       	call   801399 <_panic>
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
  8002f5:	68 ca 21 80 00       	push   $0x8021ca
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 e7 21 80 00       	push   $0x8021e7
  800301:	e8 93 10 00 00       	call   801399 <_panic>

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
  800359:	68 ca 21 80 00       	push   $0x8021ca
  80035e:	6a 23                	push   $0x23
  800360:	68 e7 21 80 00       	push   $0x8021e7
  800365:	e8 2f 10 00 00       	call   801399 <_panic>

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

008003b2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	53                   	push   %ebx
  8003b6:	83 ec 04             	sub    $0x4,%esp
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003bc:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003be:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003c2:	74 11                	je     8003d5 <pgfault+0x23>
  8003c4:	89 d8                	mov    %ebx,%eax
  8003c6:	c1 e8 0c             	shr    $0xc,%eax
  8003c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003d0:	f6 c4 08             	test   $0x8,%ah
  8003d3:	75 14                	jne    8003e9 <pgfault+0x37>
		panic("faulting access");
  8003d5:	83 ec 04             	sub    $0x4,%esp
  8003d8:	68 f5 21 80 00       	push   $0x8021f5
  8003dd:	6a 1e                	push   $0x1e
  8003df:	68 05 22 80 00       	push   $0x802205
  8003e4:	e8 b0 0f 00 00       	call   801399 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003e9:	83 ec 04             	sub    $0x4,%esp
  8003ec:	6a 07                	push   $0x7
  8003ee:	68 00 f0 7f 00       	push   $0x7ff000
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 87 fd ff ff       	call   800181 <sys_page_alloc>
	if (r < 0) {
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	85 c0                	test   %eax,%eax
  8003ff:	79 12                	jns    800413 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800401:	50                   	push   %eax
  800402:	68 10 22 80 00       	push   $0x802210
  800407:	6a 2c                	push   $0x2c
  800409:	68 05 22 80 00       	push   $0x802205
  80040e:	e8 86 0f 00 00       	call   801399 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800413:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800419:	83 ec 04             	sub    $0x4,%esp
  80041c:	68 00 10 00 00       	push   $0x1000
  800421:	53                   	push   %ebx
  800422:	68 00 f0 7f 00       	push   $0x7ff000
  800427:	e8 c5 17 00 00       	call   801bf1 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80042c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800433:	53                   	push   %ebx
  800434:	6a 00                	push   $0x0
  800436:	68 00 f0 7f 00       	push   $0x7ff000
  80043b:	6a 00                	push   $0x0
  80043d:	e8 82 fd ff ff       	call   8001c4 <sys_page_map>
	if (r < 0) {
  800442:	83 c4 20             	add    $0x20,%esp
  800445:	85 c0                	test   %eax,%eax
  800447:	79 12                	jns    80045b <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800449:	50                   	push   %eax
  80044a:	68 10 22 80 00       	push   $0x802210
  80044f:	6a 33                	push   $0x33
  800451:	68 05 22 80 00       	push   $0x802205
  800456:	e8 3e 0f 00 00       	call   801399 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	68 00 f0 7f 00       	push   $0x7ff000
  800463:	6a 00                	push   $0x0
  800465:	e8 9c fd ff ff       	call   800206 <sys_page_unmap>
	if (r < 0) {
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	85 c0                	test   %eax,%eax
  80046f:	79 12                	jns    800483 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800471:	50                   	push   %eax
  800472:	68 10 22 80 00       	push   $0x802210
  800477:	6a 37                	push   $0x37
  800479:	68 05 22 80 00       	push   $0x802205
  80047e:	e8 16 0f 00 00       	call   801399 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800483:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800486:	c9                   	leave  
  800487:	c3                   	ret    

00800488 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	57                   	push   %edi
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800491:	68 b2 03 80 00       	push   $0x8003b2
  800496:	e8 a3 18 00 00       	call   801d3e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80049b:	b8 07 00 00 00       	mov    $0x7,%eax
  8004a0:	cd 30                	int    $0x30
  8004a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	79 17                	jns    8004c3 <fork+0x3b>
		panic("fork fault %e");
  8004ac:	83 ec 04             	sub    $0x4,%esp
  8004af:	68 29 22 80 00       	push   $0x802229
  8004b4:	68 84 00 00 00       	push   $0x84
  8004b9:	68 05 22 80 00       	push   $0x802205
  8004be:	e8 d6 0e 00 00       	call   801399 <_panic>
  8004c3:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c9:	75 24                	jne    8004ef <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004cb:	e8 73 fc ff ff       	call   800143 <sys_getenvid>
  8004d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d5:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8004db:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004e0:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ea:	e9 64 01 00 00       	jmp    800653 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004ef:	83 ec 04             	sub    $0x4,%esp
  8004f2:	6a 07                	push   $0x7
  8004f4:	68 00 f0 bf ee       	push   $0xeebff000
  8004f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004fc:	e8 80 fc ff ff       	call   800181 <sys_page_alloc>
  800501:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800504:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800509:	89 d8                	mov    %ebx,%eax
  80050b:	c1 e8 16             	shr    $0x16,%eax
  80050e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800515:	a8 01                	test   $0x1,%al
  800517:	0f 84 fc 00 00 00    	je     800619 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80051d:	89 d8                	mov    %ebx,%eax
  80051f:	c1 e8 0c             	shr    $0xc,%eax
  800522:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800529:	f6 c2 01             	test   $0x1,%dl
  80052c:	0f 84 e7 00 00 00    	je     800619 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800532:	89 c6                	mov    %eax,%esi
  800534:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800537:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80053e:	f6 c6 04             	test   $0x4,%dh
  800541:	74 39                	je     80057c <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800543:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80054a:	83 ec 0c             	sub    $0xc,%esp
  80054d:	25 07 0e 00 00       	and    $0xe07,%eax
  800552:	50                   	push   %eax
  800553:	56                   	push   %esi
  800554:	57                   	push   %edi
  800555:	56                   	push   %esi
  800556:	6a 00                	push   $0x0
  800558:	e8 67 fc ff ff       	call   8001c4 <sys_page_map>
		if (r < 0) {
  80055d:	83 c4 20             	add    $0x20,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	0f 89 b1 00 00 00    	jns    800619 <fork+0x191>
		    	panic("sys page map fault %e");
  800568:	83 ec 04             	sub    $0x4,%esp
  80056b:	68 37 22 80 00       	push   $0x802237
  800570:	6a 54                	push   $0x54
  800572:	68 05 22 80 00       	push   $0x802205
  800577:	e8 1d 0e 00 00       	call   801399 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80057c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800583:	f6 c2 02             	test   $0x2,%dl
  800586:	75 0c                	jne    800594 <fork+0x10c>
  800588:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80058f:	f6 c4 08             	test   $0x8,%ah
  800592:	74 5b                	je     8005ef <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800594:	83 ec 0c             	sub    $0xc,%esp
  800597:	68 05 08 00 00       	push   $0x805
  80059c:	56                   	push   %esi
  80059d:	57                   	push   %edi
  80059e:	56                   	push   %esi
  80059f:	6a 00                	push   $0x0
  8005a1:	e8 1e fc ff ff       	call   8001c4 <sys_page_map>
		if (r < 0) {
  8005a6:	83 c4 20             	add    $0x20,%esp
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	79 14                	jns    8005c1 <fork+0x139>
		    	panic("sys page map fault %e");
  8005ad:	83 ec 04             	sub    $0x4,%esp
  8005b0:	68 37 22 80 00       	push   $0x802237
  8005b5:	6a 5b                	push   $0x5b
  8005b7:	68 05 22 80 00       	push   $0x802205
  8005bc:	e8 d8 0d 00 00       	call   801399 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	68 05 08 00 00       	push   $0x805
  8005c9:	56                   	push   %esi
  8005ca:	6a 00                	push   $0x0
  8005cc:	56                   	push   %esi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 f0 fb ff ff       	call   8001c4 <sys_page_map>
		if (r < 0) {
  8005d4:	83 c4 20             	add    $0x20,%esp
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	79 3e                	jns    800619 <fork+0x191>
		    	panic("sys page map fault %e");
  8005db:	83 ec 04             	sub    $0x4,%esp
  8005de:	68 37 22 80 00       	push   $0x802237
  8005e3:	6a 5f                	push   $0x5f
  8005e5:	68 05 22 80 00       	push   $0x802205
  8005ea:	e8 aa 0d 00 00       	call   801399 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	6a 05                	push   $0x5
  8005f4:	56                   	push   %esi
  8005f5:	57                   	push   %edi
  8005f6:	56                   	push   %esi
  8005f7:	6a 00                	push   $0x0
  8005f9:	e8 c6 fb ff ff       	call   8001c4 <sys_page_map>
		if (r < 0) {
  8005fe:	83 c4 20             	add    $0x20,%esp
  800601:	85 c0                	test   %eax,%eax
  800603:	79 14                	jns    800619 <fork+0x191>
		    	panic("sys page map fault %e");
  800605:	83 ec 04             	sub    $0x4,%esp
  800608:	68 37 22 80 00       	push   $0x802237
  80060d:	6a 64                	push   $0x64
  80060f:	68 05 22 80 00       	push   $0x802205
  800614:	e8 80 0d 00 00       	call   801399 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800619:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80061f:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800625:	0f 85 de fe ff ff    	jne    800509 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80062b:	a1 04 40 80 00       	mov    0x804004,%eax
  800630:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	50                   	push   %eax
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063d:	57                   	push   %edi
  80063e:	e8 89 fc ff ff       	call   8002cc <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800643:	83 c4 08             	add    $0x8,%esp
  800646:	6a 02                	push   $0x2
  800648:	57                   	push   %edi
  800649:	e8 fa fb ff ff       	call   800248 <sys_env_set_status>
	
	return envid;
  80064e:	83 c4 10             	add    $0x10,%esp
  800651:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800653:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800656:	5b                   	pop    %ebx
  800657:	5e                   	pop    %esi
  800658:	5f                   	pop    %edi
  800659:	5d                   	pop    %ebp
  80065a:	c3                   	ret    

0080065b <sfork>:

envid_t
sfork(void)
{
  80065b:	55                   	push   %ebp
  80065c:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80065e:	b8 00 00 00 00       	mov    $0x0,%eax
  800663:	5d                   	pop    %ebp
  800664:	c3                   	ret    

00800665 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	56                   	push   %esi
  800669:	53                   	push   %ebx
  80066a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80066d:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	68 50 22 80 00       	push   $0x802250
  80067c:	e8 f1 0d 00 00       	call   801472 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800681:	c7 04 24 8b 00 80 00 	movl   $0x80008b,(%esp)
  800688:	e8 e5 fc ff ff       	call   800372 <sys_thread_create>
  80068d:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	53                   	push   %ebx
  800693:	68 50 22 80 00       	push   $0x802250
  800698:	e8 d5 0d 00 00       	call   801472 <cprintf>
	return id;
}
  80069d:	89 f0                	mov    %esi,%eax
  80069f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006a2:	5b                   	pop    %ebx
  8006a3:	5e                   	pop    %esi
  8006a4:	5d                   	pop    %ebp
  8006a5:	c3                   	ret    

008006a6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006a6:	55                   	push   %ebp
  8006a7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ac:	05 00 00 00 30       	add    $0x30000000,%eax
  8006b1:	c1 e8 0c             	shr    $0xc,%eax
}
  8006b4:	5d                   	pop    %ebp
  8006b5:	c3                   	ret    

008006b6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	05 00 00 00 30       	add    $0x30000000,%eax
  8006c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006c6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006cb:	5d                   	pop    %ebp
  8006cc:	c3                   	ret    

008006cd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006d8:	89 c2                	mov    %eax,%edx
  8006da:	c1 ea 16             	shr    $0x16,%edx
  8006dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006e4:	f6 c2 01             	test   $0x1,%dl
  8006e7:	74 11                	je     8006fa <fd_alloc+0x2d>
  8006e9:	89 c2                	mov    %eax,%edx
  8006eb:	c1 ea 0c             	shr    $0xc,%edx
  8006ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006f5:	f6 c2 01             	test   $0x1,%dl
  8006f8:	75 09                	jne    800703 <fd_alloc+0x36>
			*fd_store = fd;
  8006fa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8006fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800701:	eb 17                	jmp    80071a <fd_alloc+0x4d>
  800703:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800708:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80070d:	75 c9                	jne    8006d8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80070f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800715:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800722:	83 f8 1f             	cmp    $0x1f,%eax
  800725:	77 36                	ja     80075d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800727:	c1 e0 0c             	shl    $0xc,%eax
  80072a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80072f:	89 c2                	mov    %eax,%edx
  800731:	c1 ea 16             	shr    $0x16,%edx
  800734:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80073b:	f6 c2 01             	test   $0x1,%dl
  80073e:	74 24                	je     800764 <fd_lookup+0x48>
  800740:	89 c2                	mov    %eax,%edx
  800742:	c1 ea 0c             	shr    $0xc,%edx
  800745:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80074c:	f6 c2 01             	test   $0x1,%dl
  80074f:	74 1a                	je     80076b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
  800754:	89 02                	mov    %eax,(%edx)
	return 0;
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	eb 13                	jmp    800770 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800762:	eb 0c                	jmp    800770 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800764:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800769:	eb 05                	jmp    800770 <fd_lookup+0x54>
  80076b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077b:	ba f0 22 80 00       	mov    $0x8022f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800780:	eb 13                	jmp    800795 <dev_lookup+0x23>
  800782:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800785:	39 08                	cmp    %ecx,(%eax)
  800787:	75 0c                	jne    800795 <dev_lookup+0x23>
			*dev = devtab[i];
  800789:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
  800793:	eb 2e                	jmp    8007c3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800795:	8b 02                	mov    (%edx),%eax
  800797:	85 c0                	test   %eax,%eax
  800799:	75 e7                	jne    800782 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80079b:	a1 04 40 80 00       	mov    0x804004,%eax
  8007a0:	8b 40 7c             	mov    0x7c(%eax),%eax
  8007a3:	83 ec 04             	sub    $0x4,%esp
  8007a6:	51                   	push   %ecx
  8007a7:	50                   	push   %eax
  8007a8:	68 74 22 80 00       	push   $0x802274
  8007ad:	e8 c0 0c 00 00       	call   801472 <cprintf>
	*dev = 0;
  8007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 10             	sub    $0x10,%esp
  8007cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d6:	50                   	push   %eax
  8007d7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007dd:	c1 e8 0c             	shr    $0xc,%eax
  8007e0:	50                   	push   %eax
  8007e1:	e8 36 ff ff ff       	call   80071c <fd_lookup>
  8007e6:	83 c4 08             	add    $0x8,%esp
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 05                	js     8007f2 <fd_close+0x2d>
	    || fd != fd2)
  8007ed:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007f0:	74 0c                	je     8007fe <fd_close+0x39>
		return (must_exist ? r : 0);
  8007f2:	84 db                	test   %bl,%bl
  8007f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f9:	0f 44 c2             	cmove  %edx,%eax
  8007fc:	eb 41                	jmp    80083f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	ff 36                	pushl  (%esi)
  800807:	e8 66 ff ff ff       	call   800772 <dev_lookup>
  80080c:	89 c3                	mov    %eax,%ebx
  80080e:	83 c4 10             	add    $0x10,%esp
  800811:	85 c0                	test   %eax,%eax
  800813:	78 1a                	js     80082f <fd_close+0x6a>
		if (dev->dev_close)
  800815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800818:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80081b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800820:	85 c0                	test   %eax,%eax
  800822:	74 0b                	je     80082f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800824:	83 ec 0c             	sub    $0xc,%esp
  800827:	56                   	push   %esi
  800828:	ff d0                	call   *%eax
  80082a:	89 c3                	mov    %eax,%ebx
  80082c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	56                   	push   %esi
  800833:	6a 00                	push   $0x0
  800835:	e8 cc f9 ff ff       	call   800206 <sys_page_unmap>
	return r;
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	89 d8                	mov    %ebx,%eax
}
  80083f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80084c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084f:	50                   	push   %eax
  800850:	ff 75 08             	pushl  0x8(%ebp)
  800853:	e8 c4 fe ff ff       	call   80071c <fd_lookup>
  800858:	83 c4 08             	add    $0x8,%esp
  80085b:	85 c0                	test   %eax,%eax
  80085d:	78 10                	js     80086f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	6a 01                	push   $0x1
  800864:	ff 75 f4             	pushl  -0xc(%ebp)
  800867:	e8 59 ff ff ff       	call   8007c5 <fd_close>
  80086c:	83 c4 10             	add    $0x10,%esp
}
  80086f:	c9                   	leave  
  800870:	c3                   	ret    

00800871 <close_all>:

void
close_all(void)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800878:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80087d:	83 ec 0c             	sub    $0xc,%esp
  800880:	53                   	push   %ebx
  800881:	e8 c0 ff ff ff       	call   800846 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800886:	83 c3 01             	add    $0x1,%ebx
  800889:	83 c4 10             	add    $0x10,%esp
  80088c:	83 fb 20             	cmp    $0x20,%ebx
  80088f:	75 ec                	jne    80087d <close_all+0xc>
		close(i);
}
  800891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800894:	c9                   	leave  
  800895:	c3                   	ret    

00800896 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	57                   	push   %edi
  80089a:	56                   	push   %esi
  80089b:	53                   	push   %ebx
  80089c:	83 ec 2c             	sub    $0x2c,%esp
  80089f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008a5:	50                   	push   %eax
  8008a6:	ff 75 08             	pushl  0x8(%ebp)
  8008a9:	e8 6e fe ff ff       	call   80071c <fd_lookup>
  8008ae:	83 c4 08             	add    $0x8,%esp
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	0f 88 c1 00 00 00    	js     80097a <dup+0xe4>
		return r;
	close(newfdnum);
  8008b9:	83 ec 0c             	sub    $0xc,%esp
  8008bc:	56                   	push   %esi
  8008bd:	e8 84 ff ff ff       	call   800846 <close>

	newfd = INDEX2FD(newfdnum);
  8008c2:	89 f3                	mov    %esi,%ebx
  8008c4:	c1 e3 0c             	shl    $0xc,%ebx
  8008c7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008cd:	83 c4 04             	add    $0x4,%esp
  8008d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008d3:	e8 de fd ff ff       	call   8006b6 <fd2data>
  8008d8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008da:	89 1c 24             	mov    %ebx,(%esp)
  8008dd:	e8 d4 fd ff ff       	call   8006b6 <fd2data>
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008e8:	89 f8                	mov    %edi,%eax
  8008ea:	c1 e8 16             	shr    $0x16,%eax
  8008ed:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008f4:	a8 01                	test   $0x1,%al
  8008f6:	74 37                	je     80092f <dup+0x99>
  8008f8:	89 f8                	mov    %edi,%eax
  8008fa:	c1 e8 0c             	shr    $0xc,%eax
  8008fd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800904:	f6 c2 01             	test   $0x1,%dl
  800907:	74 26                	je     80092f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800909:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800910:	83 ec 0c             	sub    $0xc,%esp
  800913:	25 07 0e 00 00       	and    $0xe07,%eax
  800918:	50                   	push   %eax
  800919:	ff 75 d4             	pushl  -0x2c(%ebp)
  80091c:	6a 00                	push   $0x0
  80091e:	57                   	push   %edi
  80091f:	6a 00                	push   $0x0
  800921:	e8 9e f8 ff ff       	call   8001c4 <sys_page_map>
  800926:	89 c7                	mov    %eax,%edi
  800928:	83 c4 20             	add    $0x20,%esp
  80092b:	85 c0                	test   %eax,%eax
  80092d:	78 2e                	js     80095d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80092f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800932:	89 d0                	mov    %edx,%eax
  800934:	c1 e8 0c             	shr    $0xc,%eax
  800937:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80093e:	83 ec 0c             	sub    $0xc,%esp
  800941:	25 07 0e 00 00       	and    $0xe07,%eax
  800946:	50                   	push   %eax
  800947:	53                   	push   %ebx
  800948:	6a 00                	push   $0x0
  80094a:	52                   	push   %edx
  80094b:	6a 00                	push   $0x0
  80094d:	e8 72 f8 ff ff       	call   8001c4 <sys_page_map>
  800952:	89 c7                	mov    %eax,%edi
  800954:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800957:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800959:	85 ff                	test   %edi,%edi
  80095b:	79 1d                	jns    80097a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80095d:	83 ec 08             	sub    $0x8,%esp
  800960:	53                   	push   %ebx
  800961:	6a 00                	push   $0x0
  800963:	e8 9e f8 ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800968:	83 c4 08             	add    $0x8,%esp
  80096b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80096e:	6a 00                	push   $0x0
  800970:	e8 91 f8 ff ff       	call   800206 <sys_page_unmap>
	return r;
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	89 f8                	mov    %edi,%eax
}
  80097a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	83 ec 14             	sub    $0x14,%esp
  800989:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80098c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80098f:	50                   	push   %eax
  800990:	53                   	push   %ebx
  800991:	e8 86 fd ff ff       	call   80071c <fd_lookup>
  800996:	83 c4 08             	add    $0x8,%esp
  800999:	89 c2                	mov    %eax,%edx
  80099b:	85 c0                	test   %eax,%eax
  80099d:	78 6d                	js     800a0c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80099f:	83 ec 08             	sub    $0x8,%esp
  8009a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a5:	50                   	push   %eax
  8009a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a9:	ff 30                	pushl  (%eax)
  8009ab:	e8 c2 fd ff ff       	call   800772 <dev_lookup>
  8009b0:	83 c4 10             	add    $0x10,%esp
  8009b3:	85 c0                	test   %eax,%eax
  8009b5:	78 4c                	js     800a03 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009ba:	8b 42 08             	mov    0x8(%edx),%eax
  8009bd:	83 e0 03             	and    $0x3,%eax
  8009c0:	83 f8 01             	cmp    $0x1,%eax
  8009c3:	75 21                	jne    8009e6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009c5:	a1 04 40 80 00       	mov    0x804004,%eax
  8009ca:	8b 40 7c             	mov    0x7c(%eax),%eax
  8009cd:	83 ec 04             	sub    $0x4,%esp
  8009d0:	53                   	push   %ebx
  8009d1:	50                   	push   %eax
  8009d2:	68 b5 22 80 00       	push   $0x8022b5
  8009d7:	e8 96 0a 00 00       	call   801472 <cprintf>
		return -E_INVAL;
  8009dc:	83 c4 10             	add    $0x10,%esp
  8009df:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009e4:	eb 26                	jmp    800a0c <read+0x8a>
	}
	if (!dev->dev_read)
  8009e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e9:	8b 40 08             	mov    0x8(%eax),%eax
  8009ec:	85 c0                	test   %eax,%eax
  8009ee:	74 17                	je     800a07 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009f0:	83 ec 04             	sub    $0x4,%esp
  8009f3:	ff 75 10             	pushl  0x10(%ebp)
  8009f6:	ff 75 0c             	pushl  0xc(%ebp)
  8009f9:	52                   	push   %edx
  8009fa:	ff d0                	call   *%eax
  8009fc:	89 c2                	mov    %eax,%edx
  8009fe:	83 c4 10             	add    $0x10,%esp
  800a01:	eb 09                	jmp    800a0c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a03:	89 c2                	mov    %eax,%edx
  800a05:	eb 05                	jmp    800a0c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a07:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a0c:	89 d0                	mov    %edx,%eax
  800a0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	57                   	push   %edi
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	83 ec 0c             	sub    $0xc,%esp
  800a1c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a27:	eb 21                	jmp    800a4a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a29:	83 ec 04             	sub    $0x4,%esp
  800a2c:	89 f0                	mov    %esi,%eax
  800a2e:	29 d8                	sub    %ebx,%eax
  800a30:	50                   	push   %eax
  800a31:	89 d8                	mov    %ebx,%eax
  800a33:	03 45 0c             	add    0xc(%ebp),%eax
  800a36:	50                   	push   %eax
  800a37:	57                   	push   %edi
  800a38:	e8 45 ff ff ff       	call   800982 <read>
		if (m < 0)
  800a3d:	83 c4 10             	add    $0x10,%esp
  800a40:	85 c0                	test   %eax,%eax
  800a42:	78 10                	js     800a54 <readn+0x41>
			return m;
		if (m == 0)
  800a44:	85 c0                	test   %eax,%eax
  800a46:	74 0a                	je     800a52 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a48:	01 c3                	add    %eax,%ebx
  800a4a:	39 f3                	cmp    %esi,%ebx
  800a4c:	72 db                	jb     800a29 <readn+0x16>
  800a4e:	89 d8                	mov    %ebx,%eax
  800a50:	eb 02                	jmp    800a54 <readn+0x41>
  800a52:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a57:	5b                   	pop    %ebx
  800a58:	5e                   	pop    %esi
  800a59:	5f                   	pop    %edi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 14             	sub    $0x14,%esp
  800a63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a66:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a69:	50                   	push   %eax
  800a6a:	53                   	push   %ebx
  800a6b:	e8 ac fc ff ff       	call   80071c <fd_lookup>
  800a70:	83 c4 08             	add    $0x8,%esp
  800a73:	89 c2                	mov    %eax,%edx
  800a75:	85 c0                	test   %eax,%eax
  800a77:	78 68                	js     800ae1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a79:	83 ec 08             	sub    $0x8,%esp
  800a7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a7f:	50                   	push   %eax
  800a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a83:	ff 30                	pushl  (%eax)
  800a85:	e8 e8 fc ff ff       	call   800772 <dev_lookup>
  800a8a:	83 c4 10             	add    $0x10,%esp
  800a8d:	85 c0                	test   %eax,%eax
  800a8f:	78 47                	js     800ad8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a94:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a98:	75 21                	jne    800abb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a9a:	a1 04 40 80 00       	mov    0x804004,%eax
  800a9f:	8b 40 7c             	mov    0x7c(%eax),%eax
  800aa2:	83 ec 04             	sub    $0x4,%esp
  800aa5:	53                   	push   %ebx
  800aa6:	50                   	push   %eax
  800aa7:	68 d1 22 80 00       	push   $0x8022d1
  800aac:	e8 c1 09 00 00       	call   801472 <cprintf>
		return -E_INVAL;
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ab9:	eb 26                	jmp    800ae1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800abb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800abe:	8b 52 0c             	mov    0xc(%edx),%edx
  800ac1:	85 d2                	test   %edx,%edx
  800ac3:	74 17                	je     800adc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ac5:	83 ec 04             	sub    $0x4,%esp
  800ac8:	ff 75 10             	pushl  0x10(%ebp)
  800acb:	ff 75 0c             	pushl  0xc(%ebp)
  800ace:	50                   	push   %eax
  800acf:	ff d2                	call   *%edx
  800ad1:	89 c2                	mov    %eax,%edx
  800ad3:	83 c4 10             	add    $0x10,%esp
  800ad6:	eb 09                	jmp    800ae1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ad8:	89 c2                	mov    %eax,%edx
  800ada:	eb 05                	jmp    800ae1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800adc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ae1:	89 d0                	mov    %edx,%eax
  800ae3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae6:	c9                   	leave  
  800ae7:	c3                   	ret    

00800ae8 <seek>:

int
seek(int fdnum, off_t offset)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800aee:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800af1:	50                   	push   %eax
  800af2:	ff 75 08             	pushl  0x8(%ebp)
  800af5:	e8 22 fc ff ff       	call   80071c <fd_lookup>
  800afa:	83 c4 08             	add    $0x8,%esp
  800afd:	85 c0                	test   %eax,%eax
  800aff:	78 0e                	js     800b0f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b01:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b07:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0f:	c9                   	leave  
  800b10:	c3                   	ret    

00800b11 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	53                   	push   %ebx
  800b15:	83 ec 14             	sub    $0x14,%esp
  800b18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b1e:	50                   	push   %eax
  800b1f:	53                   	push   %ebx
  800b20:	e8 f7 fb ff ff       	call   80071c <fd_lookup>
  800b25:	83 c4 08             	add    $0x8,%esp
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	78 65                	js     800b93 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b2e:	83 ec 08             	sub    $0x8,%esp
  800b31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b34:	50                   	push   %eax
  800b35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b38:	ff 30                	pushl  (%eax)
  800b3a:	e8 33 fc ff ff       	call   800772 <dev_lookup>
  800b3f:	83 c4 10             	add    $0x10,%esp
  800b42:	85 c0                	test   %eax,%eax
  800b44:	78 44                	js     800b8a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b49:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b4d:	75 21                	jne    800b70 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b4f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b54:	8b 40 7c             	mov    0x7c(%eax),%eax
  800b57:	83 ec 04             	sub    $0x4,%esp
  800b5a:	53                   	push   %ebx
  800b5b:	50                   	push   %eax
  800b5c:	68 94 22 80 00       	push   $0x802294
  800b61:	e8 0c 09 00 00       	call   801472 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b66:	83 c4 10             	add    $0x10,%esp
  800b69:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b6e:	eb 23                	jmp    800b93 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b73:	8b 52 18             	mov    0x18(%edx),%edx
  800b76:	85 d2                	test   %edx,%edx
  800b78:	74 14                	je     800b8e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b7a:	83 ec 08             	sub    $0x8,%esp
  800b7d:	ff 75 0c             	pushl  0xc(%ebp)
  800b80:	50                   	push   %eax
  800b81:	ff d2                	call   *%edx
  800b83:	89 c2                	mov    %eax,%edx
  800b85:	83 c4 10             	add    $0x10,%esp
  800b88:	eb 09                	jmp    800b93 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b8a:	89 c2                	mov    %eax,%edx
  800b8c:	eb 05                	jmp    800b93 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b8e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b93:	89 d0                	mov    %edx,%eax
  800b95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 14             	sub    $0x14,%esp
  800ba1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ba4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ba7:	50                   	push   %eax
  800ba8:	ff 75 08             	pushl  0x8(%ebp)
  800bab:	e8 6c fb ff ff       	call   80071c <fd_lookup>
  800bb0:	83 c4 08             	add    $0x8,%esp
  800bb3:	89 c2                	mov    %eax,%edx
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	78 58                	js     800c11 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bb9:	83 ec 08             	sub    $0x8,%esp
  800bbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bbf:	50                   	push   %eax
  800bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc3:	ff 30                	pushl  (%eax)
  800bc5:	e8 a8 fb ff ff       	call   800772 <dev_lookup>
  800bca:	83 c4 10             	add    $0x10,%esp
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	78 37                	js     800c08 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bd8:	74 32                	je     800c0c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bda:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800bdd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800be4:	00 00 00 
	stat->st_isdir = 0;
  800be7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bee:	00 00 00 
	stat->st_dev = dev;
  800bf1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bf7:	83 ec 08             	sub    $0x8,%esp
  800bfa:	53                   	push   %ebx
  800bfb:	ff 75 f0             	pushl  -0x10(%ebp)
  800bfe:	ff 50 14             	call   *0x14(%eax)
  800c01:	89 c2                	mov    %eax,%edx
  800c03:	83 c4 10             	add    $0x10,%esp
  800c06:	eb 09                	jmp    800c11 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c08:	89 c2                	mov    %eax,%edx
  800c0a:	eb 05                	jmp    800c11 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c0c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c11:	89 d0                	mov    %edx,%eax
  800c13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c1d:	83 ec 08             	sub    $0x8,%esp
  800c20:	6a 00                	push   $0x0
  800c22:	ff 75 08             	pushl  0x8(%ebp)
  800c25:	e8 e3 01 00 00       	call   800e0d <open>
  800c2a:	89 c3                	mov    %eax,%ebx
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	78 1b                	js     800c4e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c33:	83 ec 08             	sub    $0x8,%esp
  800c36:	ff 75 0c             	pushl  0xc(%ebp)
  800c39:	50                   	push   %eax
  800c3a:	e8 5b ff ff ff       	call   800b9a <fstat>
  800c3f:	89 c6                	mov    %eax,%esi
	close(fd);
  800c41:	89 1c 24             	mov    %ebx,(%esp)
  800c44:	e8 fd fb ff ff       	call   800846 <close>
	return r;
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	89 f0                	mov    %esi,%eax
}
  800c4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	89 c6                	mov    %eax,%esi
  800c5c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c5e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c65:	75 12                	jne    800c79 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	6a 01                	push   $0x1
  800c6c:	e8 39 12 00 00       	call   801eaa <ipc_find_env>
  800c71:	a3 00 40 80 00       	mov    %eax,0x804000
  800c76:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c79:	6a 07                	push   $0x7
  800c7b:	68 00 50 80 00       	push   $0x805000
  800c80:	56                   	push   %esi
  800c81:	ff 35 00 40 80 00    	pushl  0x804000
  800c87:	e8 bc 11 00 00       	call   801e48 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c8c:	83 c4 0c             	add    $0xc,%esp
  800c8f:	6a 00                	push   $0x0
  800c91:	53                   	push   %ebx
  800c92:	6a 00                	push   $0x0
  800c94:	e8 34 11 00 00       	call   801dcd <ipc_recv>
}
  800c99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca9:	8b 40 0c             	mov    0xc(%eax),%eax
  800cac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbe:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc3:	e8 8d ff ff ff       	call   800c55 <fsipc>
}
  800cc8:	c9                   	leave  
  800cc9:	c3                   	ret    

00800cca <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	8b 40 0c             	mov    0xc(%eax),%eax
  800cd6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce5:	e8 6b ff ff ff       	call   800c55 <fsipc>
}
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    

00800cec <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 04             	sub    $0x4,%esp
  800cf3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf9:	8b 40 0c             	mov    0xc(%eax),%eax
  800cfc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d01:	ba 00 00 00 00       	mov    $0x0,%edx
  800d06:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0b:	e8 45 ff ff ff       	call   800c55 <fsipc>
  800d10:	85 c0                	test   %eax,%eax
  800d12:	78 2c                	js     800d40 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d14:	83 ec 08             	sub    $0x8,%esp
  800d17:	68 00 50 80 00       	push   $0x805000
  800d1c:	53                   	push   %ebx
  800d1d:	e8 d5 0c 00 00       	call   8019f7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d22:	a1 80 50 80 00       	mov    0x805080,%eax
  800d27:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d2d:	a1 84 50 80 00       	mov    0x805084,%eax
  800d32:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d38:	83 c4 10             	add    $0x10,%esp
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 52 0c             	mov    0xc(%edx),%edx
  800d54:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d5a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d5f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d64:	0f 47 c2             	cmova  %edx,%eax
  800d67:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d6c:	50                   	push   %eax
  800d6d:	ff 75 0c             	pushl  0xc(%ebp)
  800d70:	68 08 50 80 00       	push   $0x805008
  800d75:	e8 0f 0e 00 00       	call   801b89 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d84:	e8 cc fe ff ff       	call   800c55 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    

00800d8b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d93:	8b 45 08             	mov    0x8(%ebp),%eax
  800d96:	8b 40 0c             	mov    0xc(%eax),%eax
  800d99:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800d9e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800da4:	ba 00 00 00 00       	mov    $0x0,%edx
  800da9:	b8 03 00 00 00       	mov    $0x3,%eax
  800dae:	e8 a2 fe ff ff       	call   800c55 <fsipc>
  800db3:	89 c3                	mov    %eax,%ebx
  800db5:	85 c0                	test   %eax,%eax
  800db7:	78 4b                	js     800e04 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800db9:	39 c6                	cmp    %eax,%esi
  800dbb:	73 16                	jae    800dd3 <devfile_read+0x48>
  800dbd:	68 00 23 80 00       	push   $0x802300
  800dc2:	68 07 23 80 00       	push   $0x802307
  800dc7:	6a 7c                	push   $0x7c
  800dc9:	68 1c 23 80 00       	push   $0x80231c
  800dce:	e8 c6 05 00 00       	call   801399 <_panic>
	assert(r <= PGSIZE);
  800dd3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800dd8:	7e 16                	jle    800df0 <devfile_read+0x65>
  800dda:	68 27 23 80 00       	push   $0x802327
  800ddf:	68 07 23 80 00       	push   $0x802307
  800de4:	6a 7d                	push   $0x7d
  800de6:	68 1c 23 80 00       	push   $0x80231c
  800deb:	e8 a9 05 00 00       	call   801399 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800df0:	83 ec 04             	sub    $0x4,%esp
  800df3:	50                   	push   %eax
  800df4:	68 00 50 80 00       	push   $0x805000
  800df9:	ff 75 0c             	pushl  0xc(%ebp)
  800dfc:	e8 88 0d 00 00       	call   801b89 <memmove>
	return r;
  800e01:	83 c4 10             	add    $0x10,%esp
}
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	53                   	push   %ebx
  800e11:	83 ec 20             	sub    $0x20,%esp
  800e14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e17:	53                   	push   %ebx
  800e18:	e8 a1 0b 00 00       	call   8019be <strlen>
  800e1d:	83 c4 10             	add    $0x10,%esp
  800e20:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e25:	7f 67                	jg     800e8e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e2d:	50                   	push   %eax
  800e2e:	e8 9a f8 ff ff       	call   8006cd <fd_alloc>
  800e33:	83 c4 10             	add    $0x10,%esp
		return r;
  800e36:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	78 57                	js     800e93 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	53                   	push   %ebx
  800e40:	68 00 50 80 00       	push   $0x805000
  800e45:	e8 ad 0b 00 00       	call   8019f7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e55:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5a:	e8 f6 fd ff ff       	call   800c55 <fsipc>
  800e5f:	89 c3                	mov    %eax,%ebx
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	79 14                	jns    800e7c <open+0x6f>
		fd_close(fd, 0);
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	6a 00                	push   $0x0
  800e6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e70:	e8 50 f9 ff ff       	call   8007c5 <fd_close>
		return r;
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	89 da                	mov    %ebx,%edx
  800e7a:	eb 17                	jmp    800e93 <open+0x86>
	}

	return fd2num(fd);
  800e7c:	83 ec 0c             	sub    $0xc,%esp
  800e7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e82:	e8 1f f8 ff ff       	call   8006a6 <fd2num>
  800e87:	89 c2                	mov    %eax,%edx
  800e89:	83 c4 10             	add    $0x10,%esp
  800e8c:	eb 05                	jmp    800e93 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e8e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e93:	89 d0                	mov    %edx,%eax
  800e95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ea0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea5:	b8 08 00 00 00       	mov    $0x8,%eax
  800eaa:	e8 a6 fd ff ff       	call   800c55 <fsipc>
}
  800eaf:	c9                   	leave  
  800eb0:	c3                   	ret    

00800eb1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	ff 75 08             	pushl  0x8(%ebp)
  800ebf:	e8 f2 f7 ff ff       	call   8006b6 <fd2data>
  800ec4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ec6:	83 c4 08             	add    $0x8,%esp
  800ec9:	68 33 23 80 00       	push   $0x802333
  800ece:	53                   	push   %ebx
  800ecf:	e8 23 0b 00 00       	call   8019f7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ed4:	8b 46 04             	mov    0x4(%esi),%eax
  800ed7:	2b 06                	sub    (%esi),%eax
  800ed9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800edf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ee6:	00 00 00 
	stat->st_dev = &devpipe;
  800ee9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ef0:	30 80 00 
	return 0;
}
  800ef3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	53                   	push   %ebx
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f09:	53                   	push   %ebx
  800f0a:	6a 00                	push   $0x0
  800f0c:	e8 f5 f2 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f11:	89 1c 24             	mov    %ebx,(%esp)
  800f14:	e8 9d f7 ff ff       	call   8006b6 <fd2data>
  800f19:	83 c4 08             	add    $0x8,%esp
  800f1c:	50                   	push   %eax
  800f1d:	6a 00                	push   $0x0
  800f1f:	e8 e2 f2 ff ff       	call   800206 <sys_page_unmap>
}
  800f24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 1c             	sub    $0x1c,%esp
  800f32:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f35:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f37:	a1 04 40 80 00       	mov    0x804004,%eax
  800f3c:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	ff 75 e0             	pushl  -0x20(%ebp)
  800f48:	e8 9f 0f 00 00       	call   801eec <pageref>
  800f4d:	89 c3                	mov    %eax,%ebx
  800f4f:	89 3c 24             	mov    %edi,(%esp)
  800f52:	e8 95 0f 00 00       	call   801eec <pageref>
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	39 c3                	cmp    %eax,%ebx
  800f5c:	0f 94 c1             	sete   %cl
  800f5f:	0f b6 c9             	movzbl %cl,%ecx
  800f62:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f65:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f6b:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  800f71:	39 ce                	cmp    %ecx,%esi
  800f73:	74 1e                	je     800f93 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800f75:	39 c3                	cmp    %eax,%ebx
  800f77:	75 be                	jne    800f37 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f79:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  800f7f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f82:	50                   	push   %eax
  800f83:	56                   	push   %esi
  800f84:	68 3a 23 80 00       	push   $0x80233a
  800f89:	e8 e4 04 00 00       	call   801472 <cprintf>
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	eb a4                	jmp    800f37 <_pipeisclosed+0xe>
	}
}
  800f93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f99:	5b                   	pop    %ebx
  800f9a:	5e                   	pop    %esi
  800f9b:	5f                   	pop    %edi
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    

00800f9e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 28             	sub    $0x28,%esp
  800fa7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800faa:	56                   	push   %esi
  800fab:	e8 06 f7 ff ff       	call   8006b6 <fd2data>
  800fb0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	bf 00 00 00 00       	mov    $0x0,%edi
  800fba:	eb 4b                	jmp    801007 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fbc:	89 da                	mov    %ebx,%edx
  800fbe:	89 f0                	mov    %esi,%eax
  800fc0:	e8 64 ff ff ff       	call   800f29 <_pipeisclosed>
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	75 48                	jne    801011 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fc9:	e8 94 f1 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fce:	8b 43 04             	mov    0x4(%ebx),%eax
  800fd1:	8b 0b                	mov    (%ebx),%ecx
  800fd3:	8d 51 20             	lea    0x20(%ecx),%edx
  800fd6:	39 d0                	cmp    %edx,%eax
  800fd8:	73 e2                	jae    800fbc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fe1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fe4:	89 c2                	mov    %eax,%edx
  800fe6:	c1 fa 1f             	sar    $0x1f,%edx
  800fe9:	89 d1                	mov    %edx,%ecx
  800feb:	c1 e9 1b             	shr    $0x1b,%ecx
  800fee:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ff1:	83 e2 1f             	and    $0x1f,%edx
  800ff4:	29 ca                	sub    %ecx,%edx
  800ff6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ffa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ffe:	83 c0 01             	add    $0x1,%eax
  801001:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801004:	83 c7 01             	add    $0x1,%edi
  801007:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80100a:	75 c2                	jne    800fce <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80100c:	8b 45 10             	mov    0x10(%ebp),%eax
  80100f:	eb 05                	jmp    801016 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801011:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801016:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801019:	5b                   	pop    %ebx
  80101a:	5e                   	pop    %esi
  80101b:	5f                   	pop    %edi
  80101c:	5d                   	pop    %ebp
  80101d:	c3                   	ret    

0080101e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 18             	sub    $0x18,%esp
  801027:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80102a:	57                   	push   %edi
  80102b:	e8 86 f6 ff ff       	call   8006b6 <fd2data>
  801030:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103a:	eb 3d                	jmp    801079 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80103c:	85 db                	test   %ebx,%ebx
  80103e:	74 04                	je     801044 <devpipe_read+0x26>
				return i;
  801040:	89 d8                	mov    %ebx,%eax
  801042:	eb 44                	jmp    801088 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801044:	89 f2                	mov    %esi,%edx
  801046:	89 f8                	mov    %edi,%eax
  801048:	e8 dc fe ff ff       	call   800f29 <_pipeisclosed>
  80104d:	85 c0                	test   %eax,%eax
  80104f:	75 32                	jne    801083 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801051:	e8 0c f1 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801056:	8b 06                	mov    (%esi),%eax
  801058:	3b 46 04             	cmp    0x4(%esi),%eax
  80105b:	74 df                	je     80103c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80105d:	99                   	cltd   
  80105e:	c1 ea 1b             	shr    $0x1b,%edx
  801061:	01 d0                	add    %edx,%eax
  801063:	83 e0 1f             	and    $0x1f,%eax
  801066:	29 d0                	sub    %edx,%eax
  801068:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80106d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801070:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801073:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801076:	83 c3 01             	add    $0x1,%ebx
  801079:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80107c:	75 d8                	jne    801056 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80107e:	8b 45 10             	mov    0x10(%ebp),%eax
  801081:	eb 05                	jmp    801088 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801083:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	56                   	push   %esi
  801094:	53                   	push   %ebx
  801095:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801098:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80109b:	50                   	push   %eax
  80109c:	e8 2c f6 ff ff       	call   8006cd <fd_alloc>
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	89 c2                	mov    %eax,%edx
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	0f 88 2c 01 00 00    	js     8011da <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	68 07 04 00 00       	push   $0x407
  8010b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 c1 f0 ff ff       	call   800181 <sys_page_alloc>
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	89 c2                	mov    %eax,%edx
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	0f 88 0d 01 00 00    	js     8011da <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d3:	50                   	push   %eax
  8010d4:	e8 f4 f5 ff ff       	call   8006cd <fd_alloc>
  8010d9:	89 c3                	mov    %eax,%ebx
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	0f 88 e2 00 00 00    	js     8011c8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010e6:	83 ec 04             	sub    $0x4,%esp
  8010e9:	68 07 04 00 00       	push   $0x407
  8010ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8010f1:	6a 00                	push   $0x0
  8010f3:	e8 89 f0 ff ff       	call   800181 <sys_page_alloc>
  8010f8:	89 c3                	mov    %eax,%ebx
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	0f 88 c3 00 00 00    	js     8011c8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801105:	83 ec 0c             	sub    $0xc,%esp
  801108:	ff 75 f4             	pushl  -0xc(%ebp)
  80110b:	e8 a6 f5 ff ff       	call   8006b6 <fd2data>
  801110:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801112:	83 c4 0c             	add    $0xc,%esp
  801115:	68 07 04 00 00       	push   $0x407
  80111a:	50                   	push   %eax
  80111b:	6a 00                	push   $0x0
  80111d:	e8 5f f0 ff ff       	call   800181 <sys_page_alloc>
  801122:	89 c3                	mov    %eax,%ebx
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	0f 88 89 00 00 00    	js     8011b8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	ff 75 f0             	pushl  -0x10(%ebp)
  801135:	e8 7c f5 ff ff       	call   8006b6 <fd2data>
  80113a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801141:	50                   	push   %eax
  801142:	6a 00                	push   $0x0
  801144:	56                   	push   %esi
  801145:	6a 00                	push   $0x0
  801147:	e8 78 f0 ff ff       	call   8001c4 <sys_page_map>
  80114c:	89 c3                	mov    %eax,%ebx
  80114e:	83 c4 20             	add    $0x20,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	78 55                	js     8011aa <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801155:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80115b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801160:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801163:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80116a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801170:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801173:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801175:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801178:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	ff 75 f4             	pushl  -0xc(%ebp)
  801185:	e8 1c f5 ff ff       	call   8006a6 <fd2num>
  80118a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80118f:	83 c4 04             	add    $0x4,%esp
  801192:	ff 75 f0             	pushl  -0x10(%ebp)
  801195:	e8 0c f5 ff ff       	call   8006a6 <fd2num>
  80119a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a8:	eb 30                	jmp    8011da <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	56                   	push   %esi
  8011ae:	6a 00                	push   $0x0
  8011b0:	e8 51 f0 ff ff       	call   800206 <sys_page_unmap>
  8011b5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011b8:	83 ec 08             	sub    $0x8,%esp
  8011bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8011be:	6a 00                	push   $0x0
  8011c0:	e8 41 f0 ff ff       	call   800206 <sys_page_unmap>
  8011c5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ce:	6a 00                	push   $0x0
  8011d0:	e8 31 f0 ff ff       	call   800206 <sys_page_unmap>
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011da:	89 d0                	mov    %edx,%eax
  8011dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ec:	50                   	push   %eax
  8011ed:	ff 75 08             	pushl  0x8(%ebp)
  8011f0:	e8 27 f5 ff ff       	call   80071c <fd_lookup>
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 18                	js     801214 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011fc:	83 ec 0c             	sub    $0xc,%esp
  8011ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801202:	e8 af f4 ff ff       	call   8006b6 <fd2data>
	return _pipeisclosed(fd, p);
  801207:	89 c2                	mov    %eax,%edx
  801209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120c:	e8 18 fd ff ff       	call   800f29 <_pipeisclosed>
  801211:	83 c4 10             	add    $0x10,%esp
}
  801214:	c9                   	leave  
  801215:	c3                   	ret    

00801216 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801219:	b8 00 00 00 00       	mov    $0x0,%eax
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801226:	68 52 23 80 00       	push   $0x802352
  80122b:	ff 75 0c             	pushl  0xc(%ebp)
  80122e:	e8 c4 07 00 00       	call   8019f7 <strcpy>
	return 0;
}
  801233:	b8 00 00 00 00       	mov    $0x0,%eax
  801238:	c9                   	leave  
  801239:	c3                   	ret    

0080123a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	57                   	push   %edi
  80123e:	56                   	push   %esi
  80123f:	53                   	push   %ebx
  801240:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801246:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80124b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801251:	eb 2d                	jmp    801280 <devcons_write+0x46>
		m = n - tot;
  801253:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801256:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801258:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80125b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801260:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801263:	83 ec 04             	sub    $0x4,%esp
  801266:	53                   	push   %ebx
  801267:	03 45 0c             	add    0xc(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	57                   	push   %edi
  80126c:	e8 18 09 00 00       	call   801b89 <memmove>
		sys_cputs(buf, m);
  801271:	83 c4 08             	add    $0x8,%esp
  801274:	53                   	push   %ebx
  801275:	57                   	push   %edi
  801276:	e8 4a ee ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80127b:	01 de                	add    %ebx,%esi
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	89 f0                	mov    %esi,%eax
  801282:	3b 75 10             	cmp    0x10(%ebp),%esi
  801285:	72 cc                	jb     801253 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128a:	5b                   	pop    %ebx
  80128b:	5e                   	pop    %esi
  80128c:	5f                   	pop    %edi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80129a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80129e:	74 2a                	je     8012ca <devcons_read+0x3b>
  8012a0:	eb 05                	jmp    8012a7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012a2:	e8 bb ee ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012a7:	e8 37 ee ff ff       	call   8000e3 <sys_cgetc>
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	74 f2                	je     8012a2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 16                	js     8012ca <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012b4:	83 f8 04             	cmp    $0x4,%eax
  8012b7:	74 0c                	je     8012c5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bc:	88 02                	mov    %al,(%edx)
	return 1;
  8012be:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c3:	eb 05                	jmp    8012ca <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    

008012cc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012d8:	6a 01                	push   $0x1
  8012da:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012dd:	50                   	push   %eax
  8012de:	e8 e2 ed ff ff       	call   8000c5 <sys_cputs>
}
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	c9                   	leave  
  8012e7:	c3                   	ret    

008012e8 <getchar>:

int
getchar(void)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012ee:	6a 01                	push   $0x1
  8012f0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	6a 00                	push   $0x0
  8012f6:	e8 87 f6 ff ff       	call   800982 <read>
	if (r < 0)
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 0f                	js     801311 <getchar+0x29>
		return r;
	if (r < 1)
  801302:	85 c0                	test   %eax,%eax
  801304:	7e 06                	jle    80130c <getchar+0x24>
		return -E_EOF;
	return c;
  801306:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80130a:	eb 05                	jmp    801311 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80130c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801311:	c9                   	leave  
  801312:	c3                   	ret    

00801313 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801313:	55                   	push   %ebp
  801314:	89 e5                	mov    %esp,%ebp
  801316:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801319:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	ff 75 08             	pushl  0x8(%ebp)
  801320:	e8 f7 f3 ff ff       	call   80071c <fd_lookup>
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 11                	js     80133d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80132c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801335:	39 10                	cmp    %edx,(%eax)
  801337:	0f 94 c0             	sete   %al
  80133a:	0f b6 c0             	movzbl %al,%eax
}
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <opencons>:

int
opencons(void)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801345:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801348:	50                   	push   %eax
  801349:	e8 7f f3 ff ff       	call   8006cd <fd_alloc>
  80134e:	83 c4 10             	add    $0x10,%esp
		return r;
  801351:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801353:	85 c0                	test   %eax,%eax
  801355:	78 3e                	js     801395 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801357:	83 ec 04             	sub    $0x4,%esp
  80135a:	68 07 04 00 00       	push   $0x407
  80135f:	ff 75 f4             	pushl  -0xc(%ebp)
  801362:	6a 00                	push   $0x0
  801364:	e8 18 ee ff ff       	call   800181 <sys_page_alloc>
  801369:	83 c4 10             	add    $0x10,%esp
		return r;
  80136c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 23                	js     801395 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801372:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801378:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80137d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801380:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801387:	83 ec 0c             	sub    $0xc,%esp
  80138a:	50                   	push   %eax
  80138b:	e8 16 f3 ff ff       	call   8006a6 <fd2num>
  801390:	89 c2                	mov    %eax,%edx
  801392:	83 c4 10             	add    $0x10,%esp
}
  801395:	89 d0                	mov    %edx,%eax
  801397:	c9                   	leave  
  801398:	c3                   	ret    

00801399 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	56                   	push   %esi
  80139d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80139e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013a1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013a7:	e8 97 ed ff ff       	call   800143 <sys_getenvid>
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	ff 75 0c             	pushl  0xc(%ebp)
  8013b2:	ff 75 08             	pushl  0x8(%ebp)
  8013b5:	56                   	push   %esi
  8013b6:	50                   	push   %eax
  8013b7:	68 60 23 80 00       	push   $0x802360
  8013bc:	e8 b1 00 00 00       	call   801472 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013c1:	83 c4 18             	add    $0x18,%esp
  8013c4:	53                   	push   %ebx
  8013c5:	ff 75 10             	pushl  0x10(%ebp)
  8013c8:	e8 54 00 00 00       	call   801421 <vcprintf>
	cprintf("\n");
  8013cd:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  8013d4:	e8 99 00 00 00       	call   801472 <cprintf>
  8013d9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013dc:	cc                   	int3   
  8013dd:	eb fd                	jmp    8013dc <_panic+0x43>

008013df <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 04             	sub    $0x4,%esp
  8013e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013e9:	8b 13                	mov    (%ebx),%edx
  8013eb:	8d 42 01             	lea    0x1(%edx),%eax
  8013ee:	89 03                	mov    %eax,(%ebx)
  8013f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013f7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013fc:	75 1a                	jne    801418 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	68 ff 00 00 00       	push   $0xff
  801406:	8d 43 08             	lea    0x8(%ebx),%eax
  801409:	50                   	push   %eax
  80140a:	e8 b6 ec ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  80140f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801415:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801418:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80141c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141f:	c9                   	leave  
  801420:	c3                   	ret    

00801421 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80142a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801431:	00 00 00 
	b.cnt = 0;
  801434:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80143b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80143e:	ff 75 0c             	pushl  0xc(%ebp)
  801441:	ff 75 08             	pushl  0x8(%ebp)
  801444:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	68 df 13 80 00       	push   $0x8013df
  801450:	e8 54 01 00 00       	call   8015a9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801455:	83 c4 08             	add    $0x8,%esp
  801458:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80145e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801464:	50                   	push   %eax
  801465:	e8 5b ec ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  80146a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801470:	c9                   	leave  
  801471:	c3                   	ret    

00801472 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801478:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80147b:	50                   	push   %eax
  80147c:	ff 75 08             	pushl  0x8(%ebp)
  80147f:	e8 9d ff ff ff       	call   801421 <vcprintf>
	va_end(ap);

	return cnt;
}
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	57                   	push   %edi
  80148a:	56                   	push   %esi
  80148b:	53                   	push   %ebx
  80148c:	83 ec 1c             	sub    $0x1c,%esp
  80148f:	89 c7                	mov    %eax,%edi
  801491:	89 d6                	mov    %edx,%esi
  801493:	8b 45 08             	mov    0x8(%ebp),%eax
  801496:	8b 55 0c             	mov    0xc(%ebp),%edx
  801499:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80149f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014aa:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014ad:	39 d3                	cmp    %edx,%ebx
  8014af:	72 05                	jb     8014b6 <printnum+0x30>
  8014b1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014b4:	77 45                	ja     8014fb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014b6:	83 ec 0c             	sub    $0xc,%esp
  8014b9:	ff 75 18             	pushl  0x18(%ebp)
  8014bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bf:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014c2:	53                   	push   %ebx
  8014c3:	ff 75 10             	pushl  0x10(%ebp)
  8014c6:	83 ec 08             	sub    $0x8,%esp
  8014c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8014cf:	ff 75 dc             	pushl  -0x24(%ebp)
  8014d2:	ff 75 d8             	pushl  -0x28(%ebp)
  8014d5:	e8 56 0a 00 00       	call   801f30 <__udivdi3>
  8014da:	83 c4 18             	add    $0x18,%esp
  8014dd:	52                   	push   %edx
  8014de:	50                   	push   %eax
  8014df:	89 f2                	mov    %esi,%edx
  8014e1:	89 f8                	mov    %edi,%eax
  8014e3:	e8 9e ff ff ff       	call   801486 <printnum>
  8014e8:	83 c4 20             	add    $0x20,%esp
  8014eb:	eb 18                	jmp    801505 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	56                   	push   %esi
  8014f1:	ff 75 18             	pushl  0x18(%ebp)
  8014f4:	ff d7                	call   *%edi
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	eb 03                	jmp    8014fe <printnum+0x78>
  8014fb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014fe:	83 eb 01             	sub    $0x1,%ebx
  801501:	85 db                	test   %ebx,%ebx
  801503:	7f e8                	jg     8014ed <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801505:	83 ec 08             	sub    $0x8,%esp
  801508:	56                   	push   %esi
  801509:	83 ec 04             	sub    $0x4,%esp
  80150c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80150f:	ff 75 e0             	pushl  -0x20(%ebp)
  801512:	ff 75 dc             	pushl  -0x24(%ebp)
  801515:	ff 75 d8             	pushl  -0x28(%ebp)
  801518:	e8 43 0b 00 00       	call   802060 <__umoddi3>
  80151d:	83 c4 14             	add    $0x14,%esp
  801520:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  801527:	50                   	push   %eax
  801528:	ff d7                	call   *%edi
}
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801530:	5b                   	pop    %ebx
  801531:	5e                   	pop    %esi
  801532:	5f                   	pop    %edi
  801533:	5d                   	pop    %ebp
  801534:	c3                   	ret    

00801535 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801535:	55                   	push   %ebp
  801536:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801538:	83 fa 01             	cmp    $0x1,%edx
  80153b:	7e 0e                	jle    80154b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80153d:	8b 10                	mov    (%eax),%edx
  80153f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801542:	89 08                	mov    %ecx,(%eax)
  801544:	8b 02                	mov    (%edx),%eax
  801546:	8b 52 04             	mov    0x4(%edx),%edx
  801549:	eb 22                	jmp    80156d <getuint+0x38>
	else if (lflag)
  80154b:	85 d2                	test   %edx,%edx
  80154d:	74 10                	je     80155f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80154f:	8b 10                	mov    (%eax),%edx
  801551:	8d 4a 04             	lea    0x4(%edx),%ecx
  801554:	89 08                	mov    %ecx,(%eax)
  801556:	8b 02                	mov    (%edx),%eax
  801558:	ba 00 00 00 00       	mov    $0x0,%edx
  80155d:	eb 0e                	jmp    80156d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80155f:	8b 10                	mov    (%eax),%edx
  801561:	8d 4a 04             	lea    0x4(%edx),%ecx
  801564:	89 08                	mov    %ecx,(%eax)
  801566:	8b 02                	mov    (%edx),%eax
  801568:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    

0080156f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801575:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801579:	8b 10                	mov    (%eax),%edx
  80157b:	3b 50 04             	cmp    0x4(%eax),%edx
  80157e:	73 0a                	jae    80158a <sprintputch+0x1b>
		*b->buf++ = ch;
  801580:	8d 4a 01             	lea    0x1(%edx),%ecx
  801583:	89 08                	mov    %ecx,(%eax)
  801585:	8b 45 08             	mov    0x8(%ebp),%eax
  801588:	88 02                	mov    %al,(%edx)
}
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801592:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801595:	50                   	push   %eax
  801596:	ff 75 10             	pushl  0x10(%ebp)
  801599:	ff 75 0c             	pushl  0xc(%ebp)
  80159c:	ff 75 08             	pushl  0x8(%ebp)
  80159f:	e8 05 00 00 00       	call   8015a9 <vprintfmt>
	va_end(ap);
}
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	57                   	push   %edi
  8015ad:	56                   	push   %esi
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 2c             	sub    $0x2c,%esp
  8015b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015b8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015bb:	eb 12                	jmp    8015cf <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	0f 84 89 03 00 00    	je     80194e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	50                   	push   %eax
  8015ca:	ff d6                	call   *%esi
  8015cc:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015cf:	83 c7 01             	add    $0x1,%edi
  8015d2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015d6:	83 f8 25             	cmp    $0x25,%eax
  8015d9:	75 e2                	jne    8015bd <vprintfmt+0x14>
  8015db:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015df:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015e6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015ed:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f9:	eb 07                	jmp    801602 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015fe:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801602:	8d 47 01             	lea    0x1(%edi),%eax
  801605:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801608:	0f b6 07             	movzbl (%edi),%eax
  80160b:	0f b6 c8             	movzbl %al,%ecx
  80160e:	83 e8 23             	sub    $0x23,%eax
  801611:	3c 55                	cmp    $0x55,%al
  801613:	0f 87 1a 03 00 00    	ja     801933 <vprintfmt+0x38a>
  801619:	0f b6 c0             	movzbl %al,%eax
  80161c:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  801623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801626:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80162a:	eb d6                	jmp    801602 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80162c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80162f:	b8 00 00 00 00       	mov    $0x0,%eax
  801634:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801637:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80163a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80163e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801641:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801644:	83 fa 09             	cmp    $0x9,%edx
  801647:	77 39                	ja     801682 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801649:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80164c:	eb e9                	jmp    801637 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80164e:	8b 45 14             	mov    0x14(%ebp),%eax
  801651:	8d 48 04             	lea    0x4(%eax),%ecx
  801654:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801657:	8b 00                	mov    (%eax),%eax
  801659:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80165c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80165f:	eb 27                	jmp    801688 <vprintfmt+0xdf>
  801661:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801664:	85 c0                	test   %eax,%eax
  801666:	b9 00 00 00 00       	mov    $0x0,%ecx
  80166b:	0f 49 c8             	cmovns %eax,%ecx
  80166e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801674:	eb 8c                	jmp    801602 <vprintfmt+0x59>
  801676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801679:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801680:	eb 80                	jmp    801602 <vprintfmt+0x59>
  801682:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801685:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801688:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80168c:	0f 89 70 ff ff ff    	jns    801602 <vprintfmt+0x59>
				width = precision, precision = -1;
  801692:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801695:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801698:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80169f:	e9 5e ff ff ff       	jmp    801602 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016a4:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016aa:	e9 53 ff ff ff       	jmp    801602 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016af:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b2:	8d 50 04             	lea    0x4(%eax),%edx
  8016b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	53                   	push   %ebx
  8016bc:	ff 30                	pushl  (%eax)
  8016be:	ff d6                	call   *%esi
			break;
  8016c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016c6:	e9 04 ff ff ff       	jmp    8015cf <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ce:	8d 50 04             	lea    0x4(%eax),%edx
  8016d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d4:	8b 00                	mov    (%eax),%eax
  8016d6:	99                   	cltd   
  8016d7:	31 d0                	xor    %edx,%eax
  8016d9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016db:	83 f8 0f             	cmp    $0xf,%eax
  8016de:	7f 0b                	jg     8016eb <vprintfmt+0x142>
  8016e0:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8016e7:	85 d2                	test   %edx,%edx
  8016e9:	75 18                	jne    801703 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016eb:	50                   	push   %eax
  8016ec:	68 9b 23 80 00       	push   $0x80239b
  8016f1:	53                   	push   %ebx
  8016f2:	56                   	push   %esi
  8016f3:	e8 94 fe ff ff       	call   80158c <printfmt>
  8016f8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016fe:	e9 cc fe ff ff       	jmp    8015cf <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801703:	52                   	push   %edx
  801704:	68 19 23 80 00       	push   $0x802319
  801709:	53                   	push   %ebx
  80170a:	56                   	push   %esi
  80170b:	e8 7c fe ff ff       	call   80158c <printfmt>
  801710:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801716:	e9 b4 fe ff ff       	jmp    8015cf <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80171b:	8b 45 14             	mov    0x14(%ebp),%eax
  80171e:	8d 50 04             	lea    0x4(%eax),%edx
  801721:	89 55 14             	mov    %edx,0x14(%ebp)
  801724:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801726:	85 ff                	test   %edi,%edi
  801728:	b8 94 23 80 00       	mov    $0x802394,%eax
  80172d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801730:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801734:	0f 8e 94 00 00 00    	jle    8017ce <vprintfmt+0x225>
  80173a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80173e:	0f 84 98 00 00 00    	je     8017dc <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801744:	83 ec 08             	sub    $0x8,%esp
  801747:	ff 75 d0             	pushl  -0x30(%ebp)
  80174a:	57                   	push   %edi
  80174b:	e8 86 02 00 00       	call   8019d6 <strnlen>
  801750:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801753:	29 c1                	sub    %eax,%ecx
  801755:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801758:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80175b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80175f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801762:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801765:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801767:	eb 0f                	jmp    801778 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801769:	83 ec 08             	sub    $0x8,%esp
  80176c:	53                   	push   %ebx
  80176d:	ff 75 e0             	pushl  -0x20(%ebp)
  801770:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801772:	83 ef 01             	sub    $0x1,%edi
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	85 ff                	test   %edi,%edi
  80177a:	7f ed                	jg     801769 <vprintfmt+0x1c0>
  80177c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80177f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801782:	85 c9                	test   %ecx,%ecx
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
  801789:	0f 49 c1             	cmovns %ecx,%eax
  80178c:	29 c1                	sub    %eax,%ecx
  80178e:	89 75 08             	mov    %esi,0x8(%ebp)
  801791:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801794:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801797:	89 cb                	mov    %ecx,%ebx
  801799:	eb 4d                	jmp    8017e8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80179b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80179f:	74 1b                	je     8017bc <vprintfmt+0x213>
  8017a1:	0f be c0             	movsbl %al,%eax
  8017a4:	83 e8 20             	sub    $0x20,%eax
  8017a7:	83 f8 5e             	cmp    $0x5e,%eax
  8017aa:	76 10                	jbe    8017bc <vprintfmt+0x213>
					putch('?', putdat);
  8017ac:	83 ec 08             	sub    $0x8,%esp
  8017af:	ff 75 0c             	pushl  0xc(%ebp)
  8017b2:	6a 3f                	push   $0x3f
  8017b4:	ff 55 08             	call   *0x8(%ebp)
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	eb 0d                	jmp    8017c9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017bc:	83 ec 08             	sub    $0x8,%esp
  8017bf:	ff 75 0c             	pushl  0xc(%ebp)
  8017c2:	52                   	push   %edx
  8017c3:	ff 55 08             	call   *0x8(%ebp)
  8017c6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017c9:	83 eb 01             	sub    $0x1,%ebx
  8017cc:	eb 1a                	jmp    8017e8 <vprintfmt+0x23f>
  8017ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8017d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017d7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017da:	eb 0c                	jmp    8017e8 <vprintfmt+0x23f>
  8017dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8017df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017e5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017e8:	83 c7 01             	add    $0x1,%edi
  8017eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017ef:	0f be d0             	movsbl %al,%edx
  8017f2:	85 d2                	test   %edx,%edx
  8017f4:	74 23                	je     801819 <vprintfmt+0x270>
  8017f6:	85 f6                	test   %esi,%esi
  8017f8:	78 a1                	js     80179b <vprintfmt+0x1f2>
  8017fa:	83 ee 01             	sub    $0x1,%esi
  8017fd:	79 9c                	jns    80179b <vprintfmt+0x1f2>
  8017ff:	89 df                	mov    %ebx,%edi
  801801:	8b 75 08             	mov    0x8(%ebp),%esi
  801804:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801807:	eb 18                	jmp    801821 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801809:	83 ec 08             	sub    $0x8,%esp
  80180c:	53                   	push   %ebx
  80180d:	6a 20                	push   $0x20
  80180f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801811:	83 ef 01             	sub    $0x1,%edi
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	eb 08                	jmp    801821 <vprintfmt+0x278>
  801819:	89 df                	mov    %ebx,%edi
  80181b:	8b 75 08             	mov    0x8(%ebp),%esi
  80181e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801821:	85 ff                	test   %edi,%edi
  801823:	7f e4                	jg     801809 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801825:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801828:	e9 a2 fd ff ff       	jmp    8015cf <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80182d:	83 fa 01             	cmp    $0x1,%edx
  801830:	7e 16                	jle    801848 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801832:	8b 45 14             	mov    0x14(%ebp),%eax
  801835:	8d 50 08             	lea    0x8(%eax),%edx
  801838:	89 55 14             	mov    %edx,0x14(%ebp)
  80183b:	8b 50 04             	mov    0x4(%eax),%edx
  80183e:	8b 00                	mov    (%eax),%eax
  801840:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801843:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801846:	eb 32                	jmp    80187a <vprintfmt+0x2d1>
	else if (lflag)
  801848:	85 d2                	test   %edx,%edx
  80184a:	74 18                	je     801864 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80184c:	8b 45 14             	mov    0x14(%ebp),%eax
  80184f:	8d 50 04             	lea    0x4(%eax),%edx
  801852:	89 55 14             	mov    %edx,0x14(%ebp)
  801855:	8b 00                	mov    (%eax),%eax
  801857:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80185a:	89 c1                	mov    %eax,%ecx
  80185c:	c1 f9 1f             	sar    $0x1f,%ecx
  80185f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801862:	eb 16                	jmp    80187a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801864:	8b 45 14             	mov    0x14(%ebp),%eax
  801867:	8d 50 04             	lea    0x4(%eax),%edx
  80186a:	89 55 14             	mov    %edx,0x14(%ebp)
  80186d:	8b 00                	mov    (%eax),%eax
  80186f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801872:	89 c1                	mov    %eax,%ecx
  801874:	c1 f9 1f             	sar    $0x1f,%ecx
  801877:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80187a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80187d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801880:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801885:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801889:	79 74                	jns    8018ff <vprintfmt+0x356>
				putch('-', putdat);
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	53                   	push   %ebx
  80188f:	6a 2d                	push   $0x2d
  801891:	ff d6                	call   *%esi
				num = -(long long) num;
  801893:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801896:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801899:	f7 d8                	neg    %eax
  80189b:	83 d2 00             	adc    $0x0,%edx
  80189e:	f7 da                	neg    %edx
  8018a0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018a8:	eb 55                	jmp    8018ff <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8018ad:	e8 83 fc ff ff       	call   801535 <getuint>
			base = 10;
  8018b2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018b7:	eb 46                	jmp    8018ff <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8018bc:	e8 74 fc ff ff       	call   801535 <getuint>
			base = 8;
  8018c1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018c6:	eb 37                	jmp    8018ff <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	53                   	push   %ebx
  8018cc:	6a 30                	push   $0x30
  8018ce:	ff d6                	call   *%esi
			putch('x', putdat);
  8018d0:	83 c4 08             	add    $0x8,%esp
  8018d3:	53                   	push   %ebx
  8018d4:	6a 78                	push   $0x78
  8018d6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018db:	8d 50 04             	lea    0x4(%eax),%edx
  8018de:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018e1:	8b 00                	mov    (%eax),%eax
  8018e3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018e8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018eb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018f0:	eb 0d                	jmp    8018ff <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018f2:	8d 45 14             	lea    0x14(%ebp),%eax
  8018f5:	e8 3b fc ff ff       	call   801535 <getuint>
			base = 16;
  8018fa:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018ff:	83 ec 0c             	sub    $0xc,%esp
  801902:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801906:	57                   	push   %edi
  801907:	ff 75 e0             	pushl  -0x20(%ebp)
  80190a:	51                   	push   %ecx
  80190b:	52                   	push   %edx
  80190c:	50                   	push   %eax
  80190d:	89 da                	mov    %ebx,%edx
  80190f:	89 f0                	mov    %esi,%eax
  801911:	e8 70 fb ff ff       	call   801486 <printnum>
			break;
  801916:	83 c4 20             	add    $0x20,%esp
  801919:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80191c:	e9 ae fc ff ff       	jmp    8015cf <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801921:	83 ec 08             	sub    $0x8,%esp
  801924:	53                   	push   %ebx
  801925:	51                   	push   %ecx
  801926:	ff d6                	call   *%esi
			break;
  801928:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80192e:	e9 9c fc ff ff       	jmp    8015cf <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	53                   	push   %ebx
  801937:	6a 25                	push   $0x25
  801939:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80193b:	83 c4 10             	add    $0x10,%esp
  80193e:	eb 03                	jmp    801943 <vprintfmt+0x39a>
  801940:	83 ef 01             	sub    $0x1,%edi
  801943:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801947:	75 f7                	jne    801940 <vprintfmt+0x397>
  801949:	e9 81 fc ff ff       	jmp    8015cf <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80194e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801951:	5b                   	pop    %ebx
  801952:	5e                   	pop    %esi
  801953:	5f                   	pop    %edi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 18             	sub    $0x18,%esp
  80195c:	8b 45 08             	mov    0x8(%ebp),%eax
  80195f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801962:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801965:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801969:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80196c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801973:	85 c0                	test   %eax,%eax
  801975:	74 26                	je     80199d <vsnprintf+0x47>
  801977:	85 d2                	test   %edx,%edx
  801979:	7e 22                	jle    80199d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80197b:	ff 75 14             	pushl  0x14(%ebp)
  80197e:	ff 75 10             	pushl  0x10(%ebp)
  801981:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801984:	50                   	push   %eax
  801985:	68 6f 15 80 00       	push   $0x80156f
  80198a:	e8 1a fc ff ff       	call   8015a9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80198f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801992:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801995:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801998:	83 c4 10             	add    $0x10,%esp
  80199b:	eb 05                	jmp    8019a2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80199d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019a2:	c9                   	leave  
  8019a3:	c3                   	ret    

008019a4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019aa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019ad:	50                   	push   %eax
  8019ae:	ff 75 10             	pushl  0x10(%ebp)
  8019b1:	ff 75 0c             	pushl  0xc(%ebp)
  8019b4:	ff 75 08             	pushl  0x8(%ebp)
  8019b7:	e8 9a ff ff ff       	call   801956 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019bc:	c9                   	leave  
  8019bd:	c3                   	ret    

008019be <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019be:	55                   	push   %ebp
  8019bf:	89 e5                	mov    %esp,%ebp
  8019c1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c9:	eb 03                	jmp    8019ce <strlen+0x10>
		n++;
  8019cb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019ce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019d2:	75 f7                	jne    8019cb <strlen+0xd>
		n++;
	return n;
}
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    

008019d6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019df:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e4:	eb 03                	jmp    8019e9 <strnlen+0x13>
		n++;
  8019e6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019e9:	39 c2                	cmp    %eax,%edx
  8019eb:	74 08                	je     8019f5 <strnlen+0x1f>
  8019ed:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019f1:	75 f3                	jne    8019e6 <strnlen+0x10>
  8019f3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019f5:	5d                   	pop    %ebp
  8019f6:	c3                   	ret    

008019f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	53                   	push   %ebx
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a01:	89 c2                	mov    %eax,%edx
  801a03:	83 c2 01             	add    $0x1,%edx
  801a06:	83 c1 01             	add    $0x1,%ecx
  801a09:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a0d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a10:	84 db                	test   %bl,%bl
  801a12:	75 ef                	jne    801a03 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a14:	5b                   	pop    %ebx
  801a15:	5d                   	pop    %ebp
  801a16:	c3                   	ret    

00801a17 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	53                   	push   %ebx
  801a1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a1e:	53                   	push   %ebx
  801a1f:	e8 9a ff ff ff       	call   8019be <strlen>
  801a24:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a27:	ff 75 0c             	pushl  0xc(%ebp)
  801a2a:	01 d8                	add    %ebx,%eax
  801a2c:	50                   	push   %eax
  801a2d:	e8 c5 ff ff ff       	call   8019f7 <strcpy>
	return dst;
}
  801a32:	89 d8                	mov    %ebx,%eax
  801a34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    

00801a39 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
  801a3e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a44:	89 f3                	mov    %esi,%ebx
  801a46:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a49:	89 f2                	mov    %esi,%edx
  801a4b:	eb 0f                	jmp    801a5c <strncpy+0x23>
		*dst++ = *src;
  801a4d:	83 c2 01             	add    $0x1,%edx
  801a50:	0f b6 01             	movzbl (%ecx),%eax
  801a53:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a56:	80 39 01             	cmpb   $0x1,(%ecx)
  801a59:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a5c:	39 da                	cmp    %ebx,%edx
  801a5e:	75 ed                	jne    801a4d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a60:	89 f0                	mov    %esi,%eax
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	56                   	push   %esi
  801a6a:	53                   	push   %ebx
  801a6b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a71:	8b 55 10             	mov    0x10(%ebp),%edx
  801a74:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a76:	85 d2                	test   %edx,%edx
  801a78:	74 21                	je     801a9b <strlcpy+0x35>
  801a7a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a7e:	89 f2                	mov    %esi,%edx
  801a80:	eb 09                	jmp    801a8b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a82:	83 c2 01             	add    $0x1,%edx
  801a85:	83 c1 01             	add    $0x1,%ecx
  801a88:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a8b:	39 c2                	cmp    %eax,%edx
  801a8d:	74 09                	je     801a98 <strlcpy+0x32>
  801a8f:	0f b6 19             	movzbl (%ecx),%ebx
  801a92:	84 db                	test   %bl,%bl
  801a94:	75 ec                	jne    801a82 <strlcpy+0x1c>
  801a96:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a98:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a9b:	29 f0                	sub    %esi,%eax
}
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    

00801aa1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801aaa:	eb 06                	jmp    801ab2 <strcmp+0x11>
		p++, q++;
  801aac:	83 c1 01             	add    $0x1,%ecx
  801aaf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ab2:	0f b6 01             	movzbl (%ecx),%eax
  801ab5:	84 c0                	test   %al,%al
  801ab7:	74 04                	je     801abd <strcmp+0x1c>
  801ab9:	3a 02                	cmp    (%edx),%al
  801abb:	74 ef                	je     801aac <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801abd:	0f b6 c0             	movzbl %al,%eax
  801ac0:	0f b6 12             	movzbl (%edx),%edx
  801ac3:	29 d0                	sub    %edx,%eax
}
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    

00801ac7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	53                   	push   %ebx
  801acb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ace:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ad1:	89 c3                	mov    %eax,%ebx
  801ad3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ad6:	eb 06                	jmp    801ade <strncmp+0x17>
		n--, p++, q++;
  801ad8:	83 c0 01             	add    $0x1,%eax
  801adb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ade:	39 d8                	cmp    %ebx,%eax
  801ae0:	74 15                	je     801af7 <strncmp+0x30>
  801ae2:	0f b6 08             	movzbl (%eax),%ecx
  801ae5:	84 c9                	test   %cl,%cl
  801ae7:	74 04                	je     801aed <strncmp+0x26>
  801ae9:	3a 0a                	cmp    (%edx),%cl
  801aeb:	74 eb                	je     801ad8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801aed:	0f b6 00             	movzbl (%eax),%eax
  801af0:	0f b6 12             	movzbl (%edx),%edx
  801af3:	29 d0                	sub    %edx,%eax
  801af5:	eb 05                	jmp    801afc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801af7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801afc:	5b                   	pop    %ebx
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    

00801aff <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	8b 45 08             	mov    0x8(%ebp),%eax
  801b05:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b09:	eb 07                	jmp    801b12 <strchr+0x13>
		if (*s == c)
  801b0b:	38 ca                	cmp    %cl,%dl
  801b0d:	74 0f                	je     801b1e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b0f:	83 c0 01             	add    $0x1,%eax
  801b12:	0f b6 10             	movzbl (%eax),%edx
  801b15:	84 d2                	test   %dl,%dl
  801b17:	75 f2                	jne    801b0b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b2a:	eb 03                	jmp    801b2f <strfind+0xf>
  801b2c:	83 c0 01             	add    $0x1,%eax
  801b2f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b32:	38 ca                	cmp    %cl,%dl
  801b34:	74 04                	je     801b3a <strfind+0x1a>
  801b36:	84 d2                	test   %dl,%dl
  801b38:	75 f2                	jne    801b2c <strfind+0xc>
			break;
	return (char *) s;
}
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	57                   	push   %edi
  801b40:	56                   	push   %esi
  801b41:	53                   	push   %ebx
  801b42:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b48:	85 c9                	test   %ecx,%ecx
  801b4a:	74 36                	je     801b82 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b4c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b52:	75 28                	jne    801b7c <memset+0x40>
  801b54:	f6 c1 03             	test   $0x3,%cl
  801b57:	75 23                	jne    801b7c <memset+0x40>
		c &= 0xFF;
  801b59:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b5d:	89 d3                	mov    %edx,%ebx
  801b5f:	c1 e3 08             	shl    $0x8,%ebx
  801b62:	89 d6                	mov    %edx,%esi
  801b64:	c1 e6 18             	shl    $0x18,%esi
  801b67:	89 d0                	mov    %edx,%eax
  801b69:	c1 e0 10             	shl    $0x10,%eax
  801b6c:	09 f0                	or     %esi,%eax
  801b6e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b70:	89 d8                	mov    %ebx,%eax
  801b72:	09 d0                	or     %edx,%eax
  801b74:	c1 e9 02             	shr    $0x2,%ecx
  801b77:	fc                   	cld    
  801b78:	f3 ab                	rep stos %eax,%es:(%edi)
  801b7a:	eb 06                	jmp    801b82 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7f:	fc                   	cld    
  801b80:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b82:	89 f8                	mov    %edi,%eax
  801b84:	5b                   	pop    %ebx
  801b85:	5e                   	pop    %esi
  801b86:	5f                   	pop    %edi
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	57                   	push   %edi
  801b8d:	56                   	push   %esi
  801b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b91:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b97:	39 c6                	cmp    %eax,%esi
  801b99:	73 35                	jae    801bd0 <memmove+0x47>
  801b9b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b9e:	39 d0                	cmp    %edx,%eax
  801ba0:	73 2e                	jae    801bd0 <memmove+0x47>
		s += n;
		d += n;
  801ba2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ba5:	89 d6                	mov    %edx,%esi
  801ba7:	09 fe                	or     %edi,%esi
  801ba9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801baf:	75 13                	jne    801bc4 <memmove+0x3b>
  801bb1:	f6 c1 03             	test   $0x3,%cl
  801bb4:	75 0e                	jne    801bc4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bb6:	83 ef 04             	sub    $0x4,%edi
  801bb9:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bbc:	c1 e9 02             	shr    $0x2,%ecx
  801bbf:	fd                   	std    
  801bc0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bc2:	eb 09                	jmp    801bcd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bc4:	83 ef 01             	sub    $0x1,%edi
  801bc7:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bca:	fd                   	std    
  801bcb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bcd:	fc                   	cld    
  801bce:	eb 1d                	jmp    801bed <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bd0:	89 f2                	mov    %esi,%edx
  801bd2:	09 c2                	or     %eax,%edx
  801bd4:	f6 c2 03             	test   $0x3,%dl
  801bd7:	75 0f                	jne    801be8 <memmove+0x5f>
  801bd9:	f6 c1 03             	test   $0x3,%cl
  801bdc:	75 0a                	jne    801be8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bde:	c1 e9 02             	shr    $0x2,%ecx
  801be1:	89 c7                	mov    %eax,%edi
  801be3:	fc                   	cld    
  801be4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801be6:	eb 05                	jmp    801bed <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801be8:	89 c7                	mov    %eax,%edi
  801bea:	fc                   	cld    
  801beb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801bed:	5e                   	pop    %esi
  801bee:	5f                   	pop    %edi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801bf4:	ff 75 10             	pushl  0x10(%ebp)
  801bf7:	ff 75 0c             	pushl  0xc(%ebp)
  801bfa:	ff 75 08             	pushl  0x8(%ebp)
  801bfd:	e8 87 ff ff ff       	call   801b89 <memmove>
}
  801c02:	c9                   	leave  
  801c03:	c3                   	ret    

00801c04 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
  801c09:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c0f:	89 c6                	mov    %eax,%esi
  801c11:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c14:	eb 1a                	jmp    801c30 <memcmp+0x2c>
		if (*s1 != *s2)
  801c16:	0f b6 08             	movzbl (%eax),%ecx
  801c19:	0f b6 1a             	movzbl (%edx),%ebx
  801c1c:	38 d9                	cmp    %bl,%cl
  801c1e:	74 0a                	je     801c2a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c20:	0f b6 c1             	movzbl %cl,%eax
  801c23:	0f b6 db             	movzbl %bl,%ebx
  801c26:	29 d8                	sub    %ebx,%eax
  801c28:	eb 0f                	jmp    801c39 <memcmp+0x35>
		s1++, s2++;
  801c2a:	83 c0 01             	add    $0x1,%eax
  801c2d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c30:	39 f0                	cmp    %esi,%eax
  801c32:	75 e2                	jne    801c16 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c39:	5b                   	pop    %ebx
  801c3a:	5e                   	pop    %esi
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	53                   	push   %ebx
  801c41:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c44:	89 c1                	mov    %eax,%ecx
  801c46:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c49:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c4d:	eb 0a                	jmp    801c59 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c4f:	0f b6 10             	movzbl (%eax),%edx
  801c52:	39 da                	cmp    %ebx,%edx
  801c54:	74 07                	je     801c5d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c56:	83 c0 01             	add    $0x1,%eax
  801c59:	39 c8                	cmp    %ecx,%eax
  801c5b:	72 f2                	jb     801c4f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c5d:	5b                   	pop    %ebx
  801c5e:	5d                   	pop    %ebp
  801c5f:	c3                   	ret    

00801c60 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	57                   	push   %edi
  801c64:	56                   	push   %esi
  801c65:	53                   	push   %ebx
  801c66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c6c:	eb 03                	jmp    801c71 <strtol+0x11>
		s++;
  801c6e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c71:	0f b6 01             	movzbl (%ecx),%eax
  801c74:	3c 20                	cmp    $0x20,%al
  801c76:	74 f6                	je     801c6e <strtol+0xe>
  801c78:	3c 09                	cmp    $0x9,%al
  801c7a:	74 f2                	je     801c6e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c7c:	3c 2b                	cmp    $0x2b,%al
  801c7e:	75 0a                	jne    801c8a <strtol+0x2a>
		s++;
  801c80:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c83:	bf 00 00 00 00       	mov    $0x0,%edi
  801c88:	eb 11                	jmp    801c9b <strtol+0x3b>
  801c8a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c8f:	3c 2d                	cmp    $0x2d,%al
  801c91:	75 08                	jne    801c9b <strtol+0x3b>
		s++, neg = 1;
  801c93:	83 c1 01             	add    $0x1,%ecx
  801c96:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c9b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ca1:	75 15                	jne    801cb8 <strtol+0x58>
  801ca3:	80 39 30             	cmpb   $0x30,(%ecx)
  801ca6:	75 10                	jne    801cb8 <strtol+0x58>
  801ca8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cac:	75 7c                	jne    801d2a <strtol+0xca>
		s += 2, base = 16;
  801cae:	83 c1 02             	add    $0x2,%ecx
  801cb1:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cb6:	eb 16                	jmp    801cce <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cb8:	85 db                	test   %ebx,%ebx
  801cba:	75 12                	jne    801cce <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cbc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cc1:	80 39 30             	cmpb   $0x30,(%ecx)
  801cc4:	75 08                	jne    801cce <strtol+0x6e>
		s++, base = 8;
  801cc6:	83 c1 01             	add    $0x1,%ecx
  801cc9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cce:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cd6:	0f b6 11             	movzbl (%ecx),%edx
  801cd9:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cdc:	89 f3                	mov    %esi,%ebx
  801cde:	80 fb 09             	cmp    $0x9,%bl
  801ce1:	77 08                	ja     801ceb <strtol+0x8b>
			dig = *s - '0';
  801ce3:	0f be d2             	movsbl %dl,%edx
  801ce6:	83 ea 30             	sub    $0x30,%edx
  801ce9:	eb 22                	jmp    801d0d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ceb:	8d 72 9f             	lea    -0x61(%edx),%esi
  801cee:	89 f3                	mov    %esi,%ebx
  801cf0:	80 fb 19             	cmp    $0x19,%bl
  801cf3:	77 08                	ja     801cfd <strtol+0x9d>
			dig = *s - 'a' + 10;
  801cf5:	0f be d2             	movsbl %dl,%edx
  801cf8:	83 ea 57             	sub    $0x57,%edx
  801cfb:	eb 10                	jmp    801d0d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801cfd:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d00:	89 f3                	mov    %esi,%ebx
  801d02:	80 fb 19             	cmp    $0x19,%bl
  801d05:	77 16                	ja     801d1d <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d07:	0f be d2             	movsbl %dl,%edx
  801d0a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d0d:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d10:	7d 0b                	jge    801d1d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d12:	83 c1 01             	add    $0x1,%ecx
  801d15:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d19:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d1b:	eb b9                	jmp    801cd6 <strtol+0x76>

	if (endptr)
  801d1d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d21:	74 0d                	je     801d30 <strtol+0xd0>
		*endptr = (char *) s;
  801d23:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d26:	89 0e                	mov    %ecx,(%esi)
  801d28:	eb 06                	jmp    801d30 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d2a:	85 db                	test   %ebx,%ebx
  801d2c:	74 98                	je     801cc6 <strtol+0x66>
  801d2e:	eb 9e                	jmp    801cce <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d30:	89 c2                	mov    %eax,%edx
  801d32:	f7 da                	neg    %edx
  801d34:	85 ff                	test   %edi,%edi
  801d36:	0f 45 c2             	cmovne %edx,%eax
}
  801d39:	5b                   	pop    %ebx
  801d3a:	5e                   	pop    %esi
  801d3b:	5f                   	pop    %edi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d44:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d4b:	75 2a                	jne    801d77 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d4d:	83 ec 04             	sub    $0x4,%esp
  801d50:	6a 07                	push   $0x7
  801d52:	68 00 f0 bf ee       	push   $0xeebff000
  801d57:	6a 00                	push   $0x0
  801d59:	e8 23 e4 ff ff       	call   800181 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	79 12                	jns    801d77 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d65:	50                   	push   %eax
  801d66:	68 80 26 80 00       	push   $0x802680
  801d6b:	6a 23                	push   $0x23
  801d6d:	68 84 26 80 00       	push   $0x802684
  801d72:	e8 22 f6 ff ff       	call   801399 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d77:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7a:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d7f:	83 ec 08             	sub    $0x8,%esp
  801d82:	68 a9 1d 80 00       	push   $0x801da9
  801d87:	6a 00                	push   $0x0
  801d89:	e8 3e e5 ff ff       	call   8002cc <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	85 c0                	test   %eax,%eax
  801d93:	79 12                	jns    801da7 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d95:	50                   	push   %eax
  801d96:	68 80 26 80 00       	push   $0x802680
  801d9b:	6a 2c                	push   $0x2c
  801d9d:	68 84 26 80 00       	push   $0x802684
  801da2:	e8 f2 f5 ff ff       	call   801399 <_panic>
	}
}
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801da9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801daa:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801daf:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801db1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801db4:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801db8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dbd:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dc1:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dc3:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dc6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dc7:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dca:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dcb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dcc:	c3                   	ret    

00801dcd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	56                   	push   %esi
  801dd1:	53                   	push   %ebx
  801dd2:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	75 12                	jne    801df1 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ddf:	83 ec 0c             	sub    $0xc,%esp
  801de2:	68 00 00 c0 ee       	push   $0xeec00000
  801de7:	e8 45 e5 ff ff       	call   800331 <sys_ipc_recv>
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	eb 0c                	jmp    801dfd <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801df1:	83 ec 0c             	sub    $0xc,%esp
  801df4:	50                   	push   %eax
  801df5:	e8 37 e5 ff ff       	call   800331 <sys_ipc_recv>
  801dfa:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801dfd:	85 f6                	test   %esi,%esi
  801dff:	0f 95 c1             	setne  %cl
  801e02:	85 db                	test   %ebx,%ebx
  801e04:	0f 95 c2             	setne  %dl
  801e07:	84 d1                	test   %dl,%cl
  801e09:	74 09                	je     801e14 <ipc_recv+0x47>
  801e0b:	89 c2                	mov    %eax,%edx
  801e0d:	c1 ea 1f             	shr    $0x1f,%edx
  801e10:	84 d2                	test   %dl,%dl
  801e12:	75 2d                	jne    801e41 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e14:	85 f6                	test   %esi,%esi
  801e16:	74 0d                	je     801e25 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e18:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e23:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e25:	85 db                	test   %ebx,%ebx
  801e27:	74 0d                	je     801e36 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e29:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e34:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e36:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	57                   	push   %edi
  801e4c:	56                   	push   %esi
  801e4d:	53                   	push   %ebx
  801e4e:	83 ec 0c             	sub    $0xc,%esp
  801e51:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e5a:	85 db                	test   %ebx,%ebx
  801e5c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e61:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e64:	ff 75 14             	pushl  0x14(%ebp)
  801e67:	53                   	push   %ebx
  801e68:	56                   	push   %esi
  801e69:	57                   	push   %edi
  801e6a:	e8 9f e4 ff ff       	call   80030e <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e6f:	89 c2                	mov    %eax,%edx
  801e71:	c1 ea 1f             	shr    $0x1f,%edx
  801e74:	83 c4 10             	add    $0x10,%esp
  801e77:	84 d2                	test   %dl,%dl
  801e79:	74 17                	je     801e92 <ipc_send+0x4a>
  801e7b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e7e:	74 12                	je     801e92 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e80:	50                   	push   %eax
  801e81:	68 92 26 80 00       	push   $0x802692
  801e86:	6a 47                	push   $0x47
  801e88:	68 a0 26 80 00       	push   $0x8026a0
  801e8d:	e8 07 f5 ff ff       	call   801399 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e92:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e95:	75 07                	jne    801e9e <ipc_send+0x56>
			sys_yield();
  801e97:	e8 c6 e2 ff ff       	call   800162 <sys_yield>
  801e9c:	eb c6                	jmp    801e64 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	75 c2                	jne    801e64 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ea2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ea5:	5b                   	pop    %ebx
  801ea6:	5e                   	pop    %esi
  801ea7:	5f                   	pop    %edi
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eb0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eb5:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ebb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ec1:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ec7:	39 ca                	cmp    %ecx,%edx
  801ec9:	75 10                	jne    801edb <ipc_find_env+0x31>
			return envs[i].env_id;
  801ecb:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801ed1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ed6:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ed9:	eb 0f                	jmp    801eea <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801edb:	83 c0 01             	add    $0x1,%eax
  801ede:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee3:	75 d0                	jne    801eb5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef2:	89 d0                	mov    %edx,%eax
  801ef4:	c1 e8 16             	shr    $0x16,%eax
  801ef7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f03:	f6 c1 01             	test   $0x1,%cl
  801f06:	74 1d                	je     801f25 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f08:	c1 ea 0c             	shr    $0xc,%edx
  801f0b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f12:	f6 c2 01             	test   $0x1,%dl
  801f15:	74 0e                	je     801f25 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f17:	c1 ea 0c             	shr    $0xc,%edx
  801f1a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f21:	ef 
  801f22:	0f b7 c0             	movzwl %ax,%eax
}
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    
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
