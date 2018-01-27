
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 88 00 00 00       	call   8000ca <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 f1 00 00 00       	call   800148 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x30>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 2a 00 00 00       	call   8000b0 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800096:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80009b:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80009d:	e8 a6 00 00 00       	call   800148 <sys_getenvid>
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	50                   	push   %eax
  8000a6:	e8 ec 02 00 00       	call   800397 <sys_thread_free>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b6:	e8 bb 07 00 00       	call   800876 <close_all>
	sys_env_destroy(0);
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	6a 00                	push   $0x0
  8000c0:	e8 42 00 00 00       	call   800107 <sys_env_destroy>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	89 c3                	mov    %eax,%ebx
  8000dd:	89 c7                	mov    %eax,%edi
  8000df:	89 c6                	mov    %eax,%esi
  8000e1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f8:	89 d1                	mov    %edx,%ecx
  8000fa:	89 d3                	mov    %edx,%ebx
  8000fc:	89 d7                	mov    %edx,%edi
  8000fe:	89 d6                	mov    %edx,%esi
  800100:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5f                   	pop    %edi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	57                   	push   %edi
  80010b:	56                   	push   %esi
  80010c:	53                   	push   %ebx
  80010d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800110:	b9 00 00 00 00       	mov    $0x0,%ecx
  800115:	b8 03 00 00 00       	mov    $0x3,%eax
  80011a:	8b 55 08             	mov    0x8(%ebp),%edx
  80011d:	89 cb                	mov    %ecx,%ebx
  80011f:	89 cf                	mov    %ecx,%edi
  800121:	89 ce                	mov    %ecx,%esi
  800123:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800125:	85 c0                	test   %eax,%eax
  800127:	7e 17                	jle    800140 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	50                   	push   %eax
  80012d:	6a 03                	push   $0x3
  80012f:	68 ca 21 80 00       	push   $0x8021ca
  800134:	6a 23                	push   $0x23
  800136:	68 e7 21 80 00       	push   $0x8021e7
  80013b:	e8 5e 12 00 00       	call   80139e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800140:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800143:	5b                   	pop    %ebx
  800144:	5e                   	pop    %esi
  800145:	5f                   	pop    %edi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	57                   	push   %edi
  80014c:	56                   	push   %esi
  80014d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014e:	ba 00 00 00 00       	mov    $0x0,%edx
  800153:	b8 02 00 00 00       	mov    $0x2,%eax
  800158:	89 d1                	mov    %edx,%ecx
  80015a:	89 d3                	mov    %edx,%ebx
  80015c:	89 d7                	mov    %edx,%edi
  80015e:	89 d6                	mov    %edx,%esi
  800160:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800162:	5b                   	pop    %ebx
  800163:	5e                   	pop    %esi
  800164:	5f                   	pop    %edi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <sys_yield>:

void
sys_yield(void)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016d:	ba 00 00 00 00       	mov    $0x0,%edx
  800172:	b8 0b 00 00 00       	mov    $0xb,%eax
  800177:	89 d1                	mov    %edx,%ecx
  800179:	89 d3                	mov    %edx,%ebx
  80017b:	89 d7                	mov    %edx,%edi
  80017d:	89 d6                	mov    %edx,%esi
  80017f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5f                   	pop    %edi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    

00800186 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	57                   	push   %edi
  80018a:	56                   	push   %esi
  80018b:	53                   	push   %ebx
  80018c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018f:	be 00 00 00 00       	mov    $0x0,%esi
  800194:	b8 04 00 00 00       	mov    $0x4,%eax
  800199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019c:	8b 55 08             	mov    0x8(%ebp),%edx
  80019f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a2:	89 f7                	mov    %esi,%edi
  8001a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a6:	85 c0                	test   %eax,%eax
  8001a8:	7e 17                	jle    8001c1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001aa:	83 ec 0c             	sub    $0xc,%esp
  8001ad:	50                   	push   %eax
  8001ae:	6a 04                	push   $0x4
  8001b0:	68 ca 21 80 00       	push   $0x8021ca
  8001b5:	6a 23                	push   $0x23
  8001b7:	68 e7 21 80 00       	push   $0x8021e7
  8001bc:	e8 dd 11 00 00       	call   80139e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001da:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e8:	85 c0                	test   %eax,%eax
  8001ea:	7e 17                	jle    800203 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	50                   	push   %eax
  8001f0:	6a 05                	push   $0x5
  8001f2:	68 ca 21 80 00       	push   $0x8021ca
  8001f7:	6a 23                	push   $0x23
  8001f9:	68 e7 21 80 00       	push   $0x8021e7
  8001fe:	e8 9b 11 00 00       	call   80139e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5f                   	pop    %edi
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    

0080020b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800214:	bb 00 00 00 00       	mov    $0x0,%ebx
  800219:	b8 06 00 00 00       	mov    $0x6,%eax
  80021e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800221:	8b 55 08             	mov    0x8(%ebp),%edx
  800224:	89 df                	mov    %ebx,%edi
  800226:	89 de                	mov    %ebx,%esi
  800228:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80022a:	85 c0                	test   %eax,%eax
  80022c:	7e 17                	jle    800245 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022e:	83 ec 0c             	sub    $0xc,%esp
  800231:	50                   	push   %eax
  800232:	6a 06                	push   $0x6
  800234:	68 ca 21 80 00       	push   $0x8021ca
  800239:	6a 23                	push   $0x23
  80023b:	68 e7 21 80 00       	push   $0x8021e7
  800240:	e8 59 11 00 00       	call   80139e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800245:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800248:	5b                   	pop    %ebx
  800249:	5e                   	pop    %esi
  80024a:	5f                   	pop    %edi
  80024b:	5d                   	pop    %ebp
  80024c:	c3                   	ret    

0080024d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	57                   	push   %edi
  800251:	56                   	push   %esi
  800252:	53                   	push   %ebx
  800253:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	b8 08 00 00 00       	mov    $0x8,%eax
  800260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800263:	8b 55 08             	mov    0x8(%ebp),%edx
  800266:	89 df                	mov    %ebx,%edi
  800268:	89 de                	mov    %ebx,%esi
  80026a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80026c:	85 c0                	test   %eax,%eax
  80026e:	7e 17                	jle    800287 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	50                   	push   %eax
  800274:	6a 08                	push   $0x8
  800276:	68 ca 21 80 00       	push   $0x8021ca
  80027b:	6a 23                	push   $0x23
  80027d:	68 e7 21 80 00       	push   $0x8021e7
  800282:	e8 17 11 00 00       	call   80139e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	57                   	push   %edi
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
  800295:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	7e 17                	jle    8002c9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	83 ec 0c             	sub    $0xc,%esp
  8002b5:	50                   	push   %eax
  8002b6:	6a 09                	push   $0x9
  8002b8:	68 ca 21 80 00       	push   $0x8021ca
  8002bd:	6a 23                	push   $0x23
  8002bf:	68 e7 21 80 00       	push   $0x8021e7
  8002c4:	e8 d5 10 00 00       	call   80139e <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cc:	5b                   	pop    %ebx
  8002cd:	5e                   	pop    %esi
  8002ce:	5f                   	pop    %edi
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ea:	89 df                	mov    %ebx,%edi
  8002ec:	89 de                	mov    %ebx,%esi
  8002ee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f0:	85 c0                	test   %eax,%eax
  8002f2:	7e 17                	jle    80030b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	50                   	push   %eax
  8002f8:	6a 0a                	push   $0xa
  8002fa:	68 ca 21 80 00       	push   $0x8021ca
  8002ff:	6a 23                	push   $0x23
  800301:	68 e7 21 80 00       	push   $0x8021e7
  800306:	e8 93 10 00 00       	call   80139e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80030b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800319:	be 00 00 00 00       	mov    $0x0,%esi
  80031e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800323:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    

00800336 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	57                   	push   %edi
  80033a:	56                   	push   %esi
  80033b:	53                   	push   %ebx
  80033c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800344:	b8 0d 00 00 00       	mov    $0xd,%eax
  800349:	8b 55 08             	mov    0x8(%ebp),%edx
  80034c:	89 cb                	mov    %ecx,%ebx
  80034e:	89 cf                	mov    %ecx,%edi
  800350:	89 ce                	mov    %ecx,%esi
  800352:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800354:	85 c0                	test   %eax,%eax
  800356:	7e 17                	jle    80036f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	50                   	push   %eax
  80035c:	6a 0d                	push   $0xd
  80035e:	68 ca 21 80 00       	push   $0x8021ca
  800363:	6a 23                	push   $0x23
  800365:	68 e7 21 80 00       	push   $0x8021e7
  80036a:	e8 2f 10 00 00       	call   80139e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800372:	5b                   	pop    %ebx
  800373:	5e                   	pop    %esi
  800374:	5f                   	pop    %edi
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	57                   	push   %edi
  80037b:	56                   	push   %esi
  80037c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800382:	b8 0e 00 00 00       	mov    $0xe,%eax
  800387:	8b 55 08             	mov    0x8(%ebp),%edx
  80038a:	89 cb                	mov    %ecx,%ebx
  80038c:	89 cf                	mov    %ecx,%edi
  80038e:	89 ce                	mov    %ecx,%esi
  800390:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003aa:	89 cb                	mov    %ecx,%ebx
  8003ac:	89 cf                	mov    %ecx,%edi
  8003ae:	89 ce                	mov    %ecx,%esi
  8003b0:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003b2:	5b                   	pop    %ebx
  8003b3:	5e                   	pop    %esi
  8003b4:	5f                   	pop    %edi
  8003b5:	5d                   	pop    %ebp
  8003b6:	c3                   	ret    

008003b7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003b7:	55                   	push   %ebp
  8003b8:	89 e5                	mov    %esp,%ebp
  8003ba:	53                   	push   %ebx
  8003bb:	83 ec 04             	sub    $0x4,%esp
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003c1:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003c3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003c7:	74 11                	je     8003da <pgfault+0x23>
  8003c9:	89 d8                	mov    %ebx,%eax
  8003cb:	c1 e8 0c             	shr    $0xc,%eax
  8003ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003d5:	f6 c4 08             	test   $0x8,%ah
  8003d8:	75 14                	jne    8003ee <pgfault+0x37>
		panic("faulting access");
  8003da:	83 ec 04             	sub    $0x4,%esp
  8003dd:	68 f5 21 80 00       	push   $0x8021f5
  8003e2:	6a 1e                	push   $0x1e
  8003e4:	68 05 22 80 00       	push   $0x802205
  8003e9:	e8 b0 0f 00 00       	call   80139e <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003ee:	83 ec 04             	sub    $0x4,%esp
  8003f1:	6a 07                	push   $0x7
  8003f3:	68 00 f0 7f 00       	push   $0x7ff000
  8003f8:	6a 00                	push   $0x0
  8003fa:	e8 87 fd ff ff       	call   800186 <sys_page_alloc>
	if (r < 0) {
  8003ff:	83 c4 10             	add    $0x10,%esp
  800402:	85 c0                	test   %eax,%eax
  800404:	79 12                	jns    800418 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800406:	50                   	push   %eax
  800407:	68 10 22 80 00       	push   $0x802210
  80040c:	6a 2c                	push   $0x2c
  80040e:	68 05 22 80 00       	push   $0x802205
  800413:	e8 86 0f 00 00       	call   80139e <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800418:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80041e:	83 ec 04             	sub    $0x4,%esp
  800421:	68 00 10 00 00       	push   $0x1000
  800426:	53                   	push   %ebx
  800427:	68 00 f0 7f 00       	push   $0x7ff000
  80042c:	e8 c5 17 00 00       	call   801bf6 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800431:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800438:	53                   	push   %ebx
  800439:	6a 00                	push   $0x0
  80043b:	68 00 f0 7f 00       	push   $0x7ff000
  800440:	6a 00                	push   $0x0
  800442:	e8 82 fd ff ff       	call   8001c9 <sys_page_map>
	if (r < 0) {
  800447:	83 c4 20             	add    $0x20,%esp
  80044a:	85 c0                	test   %eax,%eax
  80044c:	79 12                	jns    800460 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80044e:	50                   	push   %eax
  80044f:	68 10 22 80 00       	push   $0x802210
  800454:	6a 33                	push   $0x33
  800456:	68 05 22 80 00       	push   $0x802205
  80045b:	e8 3e 0f 00 00       	call   80139e <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	68 00 f0 7f 00       	push   $0x7ff000
  800468:	6a 00                	push   $0x0
  80046a:	e8 9c fd ff ff       	call   80020b <sys_page_unmap>
	if (r < 0) {
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	85 c0                	test   %eax,%eax
  800474:	79 12                	jns    800488 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800476:	50                   	push   %eax
  800477:	68 10 22 80 00       	push   $0x802210
  80047c:	6a 37                	push   $0x37
  80047e:	68 05 22 80 00       	push   $0x802205
  800483:	e8 16 0f 00 00       	call   80139e <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800488:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80048b:	c9                   	leave  
  80048c:	c3                   	ret    

0080048d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	57                   	push   %edi
  800491:	56                   	push   %esi
  800492:	53                   	push   %ebx
  800493:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800496:	68 b7 03 80 00       	push   $0x8003b7
  80049b:	e8 a3 18 00 00       	call   801d43 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004a0:	b8 07 00 00 00       	mov    $0x7,%eax
  8004a5:	cd 30                	int    $0x30
  8004a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	85 c0                	test   %eax,%eax
  8004af:	79 17                	jns    8004c8 <fork+0x3b>
		panic("fork fault %e");
  8004b1:	83 ec 04             	sub    $0x4,%esp
  8004b4:	68 29 22 80 00       	push   $0x802229
  8004b9:	68 84 00 00 00       	push   $0x84
  8004be:	68 05 22 80 00       	push   $0x802205
  8004c3:	e8 d6 0e 00 00       	call   80139e <_panic>
  8004c8:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ce:	75 24                	jne    8004f4 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004d0:	e8 73 fc ff ff       	call   800148 <sys_getenvid>
  8004d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004da:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8004e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004e5:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ef:	e9 64 01 00 00       	jmp    800658 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004f4:	83 ec 04             	sub    $0x4,%esp
  8004f7:	6a 07                	push   $0x7
  8004f9:	68 00 f0 bf ee       	push   $0xeebff000
  8004fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  800501:	e8 80 fc ff ff       	call   800186 <sys_page_alloc>
  800506:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800509:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80050e:	89 d8                	mov    %ebx,%eax
  800510:	c1 e8 16             	shr    $0x16,%eax
  800513:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80051a:	a8 01                	test   $0x1,%al
  80051c:	0f 84 fc 00 00 00    	je     80061e <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800522:	89 d8                	mov    %ebx,%eax
  800524:	c1 e8 0c             	shr    $0xc,%eax
  800527:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80052e:	f6 c2 01             	test   $0x1,%dl
  800531:	0f 84 e7 00 00 00    	je     80061e <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800537:	89 c6                	mov    %eax,%esi
  800539:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80053c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800543:	f6 c6 04             	test   $0x4,%dh
  800546:	74 39                	je     800581 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800548:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80054f:	83 ec 0c             	sub    $0xc,%esp
  800552:	25 07 0e 00 00       	and    $0xe07,%eax
  800557:	50                   	push   %eax
  800558:	56                   	push   %esi
  800559:	57                   	push   %edi
  80055a:	56                   	push   %esi
  80055b:	6a 00                	push   $0x0
  80055d:	e8 67 fc ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  800562:	83 c4 20             	add    $0x20,%esp
  800565:	85 c0                	test   %eax,%eax
  800567:	0f 89 b1 00 00 00    	jns    80061e <fork+0x191>
		    	panic("sys page map fault %e");
  80056d:	83 ec 04             	sub    $0x4,%esp
  800570:	68 37 22 80 00       	push   $0x802237
  800575:	6a 54                	push   $0x54
  800577:	68 05 22 80 00       	push   $0x802205
  80057c:	e8 1d 0e 00 00       	call   80139e <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800581:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800588:	f6 c2 02             	test   $0x2,%dl
  80058b:	75 0c                	jne    800599 <fork+0x10c>
  80058d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800594:	f6 c4 08             	test   $0x8,%ah
  800597:	74 5b                	je     8005f4 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800599:	83 ec 0c             	sub    $0xc,%esp
  80059c:	68 05 08 00 00       	push   $0x805
  8005a1:	56                   	push   %esi
  8005a2:	57                   	push   %edi
  8005a3:	56                   	push   %esi
  8005a4:	6a 00                	push   $0x0
  8005a6:	e8 1e fc ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  8005ab:	83 c4 20             	add    $0x20,%esp
  8005ae:	85 c0                	test   %eax,%eax
  8005b0:	79 14                	jns    8005c6 <fork+0x139>
		    	panic("sys page map fault %e");
  8005b2:	83 ec 04             	sub    $0x4,%esp
  8005b5:	68 37 22 80 00       	push   $0x802237
  8005ba:	6a 5b                	push   $0x5b
  8005bc:	68 05 22 80 00       	push   $0x802205
  8005c1:	e8 d8 0d 00 00       	call   80139e <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005c6:	83 ec 0c             	sub    $0xc,%esp
  8005c9:	68 05 08 00 00       	push   $0x805
  8005ce:	56                   	push   %esi
  8005cf:	6a 00                	push   $0x0
  8005d1:	56                   	push   %esi
  8005d2:	6a 00                	push   $0x0
  8005d4:	e8 f0 fb ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	79 3e                	jns    80061e <fork+0x191>
		    	panic("sys page map fault %e");
  8005e0:	83 ec 04             	sub    $0x4,%esp
  8005e3:	68 37 22 80 00       	push   $0x802237
  8005e8:	6a 5f                	push   $0x5f
  8005ea:	68 05 22 80 00       	push   $0x802205
  8005ef:	e8 aa 0d 00 00       	call   80139e <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005f4:	83 ec 0c             	sub    $0xc,%esp
  8005f7:	6a 05                	push   $0x5
  8005f9:	56                   	push   %esi
  8005fa:	57                   	push   %edi
  8005fb:	56                   	push   %esi
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 c6 fb ff ff       	call   8001c9 <sys_page_map>
		if (r < 0) {
  800603:	83 c4 20             	add    $0x20,%esp
  800606:	85 c0                	test   %eax,%eax
  800608:	79 14                	jns    80061e <fork+0x191>
		    	panic("sys page map fault %e");
  80060a:	83 ec 04             	sub    $0x4,%esp
  80060d:	68 37 22 80 00       	push   $0x802237
  800612:	6a 64                	push   $0x64
  800614:	68 05 22 80 00       	push   $0x802205
  800619:	e8 80 0d 00 00       	call   80139e <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80061e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800624:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80062a:	0f 85 de fe ff ff    	jne    80050e <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800630:	a1 04 40 80 00       	mov    0x804004,%eax
  800635:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	50                   	push   %eax
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800642:	57                   	push   %edi
  800643:	e8 89 fc ff ff       	call   8002d1 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800648:	83 c4 08             	add    $0x8,%esp
  80064b:	6a 02                	push   $0x2
  80064d:	57                   	push   %edi
  80064e:	e8 fa fb ff ff       	call   80024d <sys_env_set_status>
	
	return envid;
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800658:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065b:	5b                   	pop    %ebx
  80065c:	5e                   	pop    %esi
  80065d:	5f                   	pop    %edi
  80065e:	5d                   	pop    %ebp
  80065f:	c3                   	ret    

00800660 <sfork>:

envid_t
sfork(void)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800663:	b8 00 00 00 00       	mov    $0x0,%eax
  800668:	5d                   	pop    %ebp
  800669:	c3                   	ret    

0080066a <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80066a:	55                   	push   %ebp
  80066b:	89 e5                	mov    %esp,%ebp
  80066d:	56                   	push   %esi
  80066e:	53                   	push   %ebx
  80066f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800672:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	68 50 22 80 00       	push   $0x802250
  800681:	e8 f1 0d 00 00       	call   801477 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800686:	c7 04 24 90 00 80 00 	movl   $0x800090,(%esp)
  80068d:	e8 e5 fc ff ff       	call   800377 <sys_thread_create>
  800692:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800694:	83 c4 08             	add    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	68 50 22 80 00       	push   $0x802250
  80069d:	e8 d5 0d 00 00       	call   801477 <cprintf>
	return id;
}
  8006a2:	89 f0                	mov    %esi,%eax
  8006a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006a7:	5b                   	pop    %ebx
  8006a8:	5e                   	pop    %esi
  8006a9:	5d                   	pop    %ebp
  8006aa:	c3                   	ret    

008006ab <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	05 00 00 00 30       	add    $0x30000000,%eax
  8006b6:	c1 e8 0c             	shr    $0xc,%eax
}
  8006b9:	5d                   	pop    %ebp
  8006ba:	c3                   	ret    

008006bb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	05 00 00 00 30       	add    $0x30000000,%eax
  8006c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006cb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006dd:	89 c2                	mov    %eax,%edx
  8006df:	c1 ea 16             	shr    $0x16,%edx
  8006e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006e9:	f6 c2 01             	test   $0x1,%dl
  8006ec:	74 11                	je     8006ff <fd_alloc+0x2d>
  8006ee:	89 c2                	mov    %eax,%edx
  8006f0:	c1 ea 0c             	shr    $0xc,%edx
  8006f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006fa:	f6 c2 01             	test   $0x1,%dl
  8006fd:	75 09                	jne    800708 <fd_alloc+0x36>
			*fd_store = fd;
  8006ff:	89 01                	mov    %eax,(%ecx)
			return 0;
  800701:	b8 00 00 00 00       	mov    $0x0,%eax
  800706:	eb 17                	jmp    80071f <fd_alloc+0x4d>
  800708:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80070d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800712:	75 c9                	jne    8006dd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800714:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80071a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80071f:	5d                   	pop    %ebp
  800720:	c3                   	ret    

00800721 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800721:	55                   	push   %ebp
  800722:	89 e5                	mov    %esp,%ebp
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800727:	83 f8 1f             	cmp    $0x1f,%eax
  80072a:	77 36                	ja     800762 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80072c:	c1 e0 0c             	shl    $0xc,%eax
  80072f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800734:	89 c2                	mov    %eax,%edx
  800736:	c1 ea 16             	shr    $0x16,%edx
  800739:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800740:	f6 c2 01             	test   $0x1,%dl
  800743:	74 24                	je     800769 <fd_lookup+0x48>
  800745:	89 c2                	mov    %eax,%edx
  800747:	c1 ea 0c             	shr    $0xc,%edx
  80074a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800751:	f6 c2 01             	test   $0x1,%dl
  800754:	74 1a                	je     800770 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800756:	8b 55 0c             	mov    0xc(%ebp),%edx
  800759:	89 02                	mov    %eax,(%edx)
	return 0;
  80075b:	b8 00 00 00 00       	mov    $0x0,%eax
  800760:	eb 13                	jmp    800775 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800767:	eb 0c                	jmp    800775 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076e:	eb 05                	jmp    800775 <fd_lookup+0x54>
  800770:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	83 ec 08             	sub    $0x8,%esp
  80077d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800780:	ba f0 22 80 00       	mov    $0x8022f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800785:	eb 13                	jmp    80079a <dev_lookup+0x23>
  800787:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80078a:	39 08                	cmp    %ecx,(%eax)
  80078c:	75 0c                	jne    80079a <dev_lookup+0x23>
			*dev = devtab[i];
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800791:	89 01                	mov    %eax,(%ecx)
			return 0;
  800793:	b8 00 00 00 00       	mov    $0x0,%eax
  800798:	eb 2e                	jmp    8007c8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80079a:	8b 02                	mov    (%edx),%eax
  80079c:	85 c0                	test   %eax,%eax
  80079e:	75 e7                	jne    800787 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8007a5:	8b 40 7c             	mov    0x7c(%eax),%eax
  8007a8:	83 ec 04             	sub    $0x4,%esp
  8007ab:	51                   	push   %ecx
  8007ac:	50                   	push   %eax
  8007ad:	68 74 22 80 00       	push   $0x802274
  8007b2:	e8 c0 0c 00 00       	call   801477 <cprintf>
	*dev = 0;
  8007b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007c8:	c9                   	leave  
  8007c9:	c3                   	ret    

008007ca <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	56                   	push   %esi
  8007ce:	53                   	push   %ebx
  8007cf:	83 ec 10             	sub    $0x10,%esp
  8007d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007db:	50                   	push   %eax
  8007dc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007e2:	c1 e8 0c             	shr    $0xc,%eax
  8007e5:	50                   	push   %eax
  8007e6:	e8 36 ff ff ff       	call   800721 <fd_lookup>
  8007eb:	83 c4 08             	add    $0x8,%esp
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	78 05                	js     8007f7 <fd_close+0x2d>
	    || fd != fd2)
  8007f2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007f5:	74 0c                	je     800803 <fd_close+0x39>
		return (must_exist ? r : 0);
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fe:	0f 44 c2             	cmove  %edx,%eax
  800801:	eb 41                	jmp    800844 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800809:	50                   	push   %eax
  80080a:	ff 36                	pushl  (%esi)
  80080c:	e8 66 ff ff ff       	call   800777 <dev_lookup>
  800811:	89 c3                	mov    %eax,%ebx
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	85 c0                	test   %eax,%eax
  800818:	78 1a                	js     800834 <fd_close+0x6a>
		if (dev->dev_close)
  80081a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800820:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800825:	85 c0                	test   %eax,%eax
  800827:	74 0b                	je     800834 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800829:	83 ec 0c             	sub    $0xc,%esp
  80082c:	56                   	push   %esi
  80082d:	ff d0                	call   *%eax
  80082f:	89 c3                	mov    %eax,%ebx
  800831:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	56                   	push   %esi
  800838:	6a 00                	push   $0x0
  80083a:	e8 cc f9 ff ff       	call   80020b <sys_page_unmap>
	return r;
  80083f:	83 c4 10             	add    $0x10,%esp
  800842:	89 d8                	mov    %ebx,%eax
}
  800844:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800847:	5b                   	pop    %ebx
  800848:	5e                   	pop    %esi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800851:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800854:	50                   	push   %eax
  800855:	ff 75 08             	pushl  0x8(%ebp)
  800858:	e8 c4 fe ff ff       	call   800721 <fd_lookup>
  80085d:	83 c4 08             	add    $0x8,%esp
  800860:	85 c0                	test   %eax,%eax
  800862:	78 10                	js     800874 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	6a 01                	push   $0x1
  800869:	ff 75 f4             	pushl  -0xc(%ebp)
  80086c:	e8 59 ff ff ff       	call   8007ca <fd_close>
  800871:	83 c4 10             	add    $0x10,%esp
}
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <close_all>:

void
close_all(void)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80087d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800882:	83 ec 0c             	sub    $0xc,%esp
  800885:	53                   	push   %ebx
  800886:	e8 c0 ff ff ff       	call   80084b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80088b:	83 c3 01             	add    $0x1,%ebx
  80088e:	83 c4 10             	add    $0x10,%esp
  800891:	83 fb 20             	cmp    $0x20,%ebx
  800894:	75 ec                	jne    800882 <close_all+0xc>
		close(i);
}
  800896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	57                   	push   %edi
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
  8008a1:	83 ec 2c             	sub    $0x2c,%esp
  8008a4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	ff 75 08             	pushl  0x8(%ebp)
  8008ae:	e8 6e fe ff ff       	call   800721 <fd_lookup>
  8008b3:	83 c4 08             	add    $0x8,%esp
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	0f 88 c1 00 00 00    	js     80097f <dup+0xe4>
		return r;
	close(newfdnum);
  8008be:	83 ec 0c             	sub    $0xc,%esp
  8008c1:	56                   	push   %esi
  8008c2:	e8 84 ff ff ff       	call   80084b <close>

	newfd = INDEX2FD(newfdnum);
  8008c7:	89 f3                	mov    %esi,%ebx
  8008c9:	c1 e3 0c             	shl    $0xc,%ebx
  8008cc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008d2:	83 c4 04             	add    $0x4,%esp
  8008d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008d8:	e8 de fd ff ff       	call   8006bb <fd2data>
  8008dd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008df:	89 1c 24             	mov    %ebx,(%esp)
  8008e2:	e8 d4 fd ff ff       	call   8006bb <fd2data>
  8008e7:	83 c4 10             	add    $0x10,%esp
  8008ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008ed:	89 f8                	mov    %edi,%eax
  8008ef:	c1 e8 16             	shr    $0x16,%eax
  8008f2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008f9:	a8 01                	test   $0x1,%al
  8008fb:	74 37                	je     800934 <dup+0x99>
  8008fd:	89 f8                	mov    %edi,%eax
  8008ff:	c1 e8 0c             	shr    $0xc,%eax
  800902:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800909:	f6 c2 01             	test   $0x1,%dl
  80090c:	74 26                	je     800934 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80090e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	25 07 0e 00 00       	and    $0xe07,%eax
  80091d:	50                   	push   %eax
  80091e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800921:	6a 00                	push   $0x0
  800923:	57                   	push   %edi
  800924:	6a 00                	push   $0x0
  800926:	e8 9e f8 ff ff       	call   8001c9 <sys_page_map>
  80092b:	89 c7                	mov    %eax,%edi
  80092d:	83 c4 20             	add    $0x20,%esp
  800930:	85 c0                	test   %eax,%eax
  800932:	78 2e                	js     800962 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800934:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800937:	89 d0                	mov    %edx,%eax
  800939:	c1 e8 0c             	shr    $0xc,%eax
  80093c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800943:	83 ec 0c             	sub    $0xc,%esp
  800946:	25 07 0e 00 00       	and    $0xe07,%eax
  80094b:	50                   	push   %eax
  80094c:	53                   	push   %ebx
  80094d:	6a 00                	push   $0x0
  80094f:	52                   	push   %edx
  800950:	6a 00                	push   $0x0
  800952:	e8 72 f8 ff ff       	call   8001c9 <sys_page_map>
  800957:	89 c7                	mov    %eax,%edi
  800959:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80095c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80095e:	85 ff                	test   %edi,%edi
  800960:	79 1d                	jns    80097f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800962:	83 ec 08             	sub    $0x8,%esp
  800965:	53                   	push   %ebx
  800966:	6a 00                	push   $0x0
  800968:	e8 9e f8 ff ff       	call   80020b <sys_page_unmap>
	sys_page_unmap(0, nva);
  80096d:	83 c4 08             	add    $0x8,%esp
  800970:	ff 75 d4             	pushl  -0x2c(%ebp)
  800973:	6a 00                	push   $0x0
  800975:	e8 91 f8 ff ff       	call   80020b <sys_page_unmap>
	return r;
  80097a:	83 c4 10             	add    $0x10,%esp
  80097d:	89 f8                	mov    %edi,%eax
}
  80097f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	83 ec 14             	sub    $0x14,%esp
  80098e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800991:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800994:	50                   	push   %eax
  800995:	53                   	push   %ebx
  800996:	e8 86 fd ff ff       	call   800721 <fd_lookup>
  80099b:	83 c4 08             	add    $0x8,%esp
  80099e:	89 c2                	mov    %eax,%edx
  8009a0:	85 c0                	test   %eax,%eax
  8009a2:	78 6d                	js     800a11 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009a4:	83 ec 08             	sub    $0x8,%esp
  8009a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009aa:	50                   	push   %eax
  8009ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ae:	ff 30                	pushl  (%eax)
  8009b0:	e8 c2 fd ff ff       	call   800777 <dev_lookup>
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	85 c0                	test   %eax,%eax
  8009ba:	78 4c                	js     800a08 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009bf:	8b 42 08             	mov    0x8(%edx),%eax
  8009c2:	83 e0 03             	and    $0x3,%eax
  8009c5:	83 f8 01             	cmp    $0x1,%eax
  8009c8:	75 21                	jne    8009eb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8009cf:	8b 40 7c             	mov    0x7c(%eax),%eax
  8009d2:	83 ec 04             	sub    $0x4,%esp
  8009d5:	53                   	push   %ebx
  8009d6:	50                   	push   %eax
  8009d7:	68 b5 22 80 00       	push   $0x8022b5
  8009dc:	e8 96 0a 00 00       	call   801477 <cprintf>
		return -E_INVAL;
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009e9:	eb 26                	jmp    800a11 <read+0x8a>
	}
	if (!dev->dev_read)
  8009eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ee:	8b 40 08             	mov    0x8(%eax),%eax
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	74 17                	je     800a0c <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009f5:	83 ec 04             	sub    $0x4,%esp
  8009f8:	ff 75 10             	pushl  0x10(%ebp)
  8009fb:	ff 75 0c             	pushl  0xc(%ebp)
  8009fe:	52                   	push   %edx
  8009ff:	ff d0                	call   *%eax
  800a01:	89 c2                	mov    %eax,%edx
  800a03:	83 c4 10             	add    $0x10,%esp
  800a06:	eb 09                	jmp    800a11 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a08:	89 c2                	mov    %eax,%edx
  800a0a:	eb 05                	jmp    800a11 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a0c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a11:	89 d0                	mov    %edx,%eax
  800a13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	57                   	push   %edi
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
  800a1e:	83 ec 0c             	sub    $0xc,%esp
  800a21:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a24:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a2c:	eb 21                	jmp    800a4f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a2e:	83 ec 04             	sub    $0x4,%esp
  800a31:	89 f0                	mov    %esi,%eax
  800a33:	29 d8                	sub    %ebx,%eax
  800a35:	50                   	push   %eax
  800a36:	89 d8                	mov    %ebx,%eax
  800a38:	03 45 0c             	add    0xc(%ebp),%eax
  800a3b:	50                   	push   %eax
  800a3c:	57                   	push   %edi
  800a3d:	e8 45 ff ff ff       	call   800987 <read>
		if (m < 0)
  800a42:	83 c4 10             	add    $0x10,%esp
  800a45:	85 c0                	test   %eax,%eax
  800a47:	78 10                	js     800a59 <readn+0x41>
			return m;
		if (m == 0)
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	74 0a                	je     800a57 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a4d:	01 c3                	add    %eax,%ebx
  800a4f:	39 f3                	cmp    %esi,%ebx
  800a51:	72 db                	jb     800a2e <readn+0x16>
  800a53:	89 d8                	mov    %ebx,%eax
  800a55:	eb 02                	jmp    800a59 <readn+0x41>
  800a57:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	53                   	push   %ebx
  800a65:	83 ec 14             	sub    $0x14,%esp
  800a68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a6e:	50                   	push   %eax
  800a6f:	53                   	push   %ebx
  800a70:	e8 ac fc ff ff       	call   800721 <fd_lookup>
  800a75:	83 c4 08             	add    $0x8,%esp
  800a78:	89 c2                	mov    %eax,%edx
  800a7a:	85 c0                	test   %eax,%eax
  800a7c:	78 68                	js     800ae6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a84:	50                   	push   %eax
  800a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a88:	ff 30                	pushl  (%eax)
  800a8a:	e8 e8 fc ff ff       	call   800777 <dev_lookup>
  800a8f:	83 c4 10             	add    $0x10,%esp
  800a92:	85 c0                	test   %eax,%eax
  800a94:	78 47                	js     800add <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a99:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a9d:	75 21                	jne    800ac0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a9f:	a1 04 40 80 00       	mov    0x804004,%eax
  800aa4:	8b 40 7c             	mov    0x7c(%eax),%eax
  800aa7:	83 ec 04             	sub    $0x4,%esp
  800aaa:	53                   	push   %ebx
  800aab:	50                   	push   %eax
  800aac:	68 d1 22 80 00       	push   $0x8022d1
  800ab1:	e8 c1 09 00 00       	call   801477 <cprintf>
		return -E_INVAL;
  800ab6:	83 c4 10             	add    $0x10,%esp
  800ab9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800abe:	eb 26                	jmp    800ae6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ac0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac3:	8b 52 0c             	mov    0xc(%edx),%edx
  800ac6:	85 d2                	test   %edx,%edx
  800ac8:	74 17                	je     800ae1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800aca:	83 ec 04             	sub    $0x4,%esp
  800acd:	ff 75 10             	pushl  0x10(%ebp)
  800ad0:	ff 75 0c             	pushl  0xc(%ebp)
  800ad3:	50                   	push   %eax
  800ad4:	ff d2                	call   *%edx
  800ad6:	89 c2                	mov    %eax,%edx
  800ad8:	83 c4 10             	add    $0x10,%esp
  800adb:	eb 09                	jmp    800ae6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800add:	89 c2                	mov    %eax,%edx
  800adf:	eb 05                	jmp    800ae6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ae1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ae6:	89 d0                	mov    %edx,%eax
  800ae8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <seek>:

int
seek(int fdnum, off_t offset)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800af3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800af6:	50                   	push   %eax
  800af7:	ff 75 08             	pushl  0x8(%ebp)
  800afa:	e8 22 fc ff ff       	call   800721 <fd_lookup>
  800aff:	83 c4 08             	add    $0x8,%esp
  800b02:	85 c0                	test   %eax,%eax
  800b04:	78 0e                	js     800b14 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b06:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b14:	c9                   	leave  
  800b15:	c3                   	ret    

00800b16 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 14             	sub    $0x14,%esp
  800b1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b23:	50                   	push   %eax
  800b24:	53                   	push   %ebx
  800b25:	e8 f7 fb ff ff       	call   800721 <fd_lookup>
  800b2a:	83 c4 08             	add    $0x8,%esp
  800b2d:	89 c2                	mov    %eax,%edx
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	78 65                	js     800b98 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b33:	83 ec 08             	sub    $0x8,%esp
  800b36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b39:	50                   	push   %eax
  800b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3d:	ff 30                	pushl  (%eax)
  800b3f:	e8 33 fc ff ff       	call   800777 <dev_lookup>
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	85 c0                	test   %eax,%eax
  800b49:	78 44                	js     800b8f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b4e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b52:	75 21                	jne    800b75 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b54:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b59:	8b 40 7c             	mov    0x7c(%eax),%eax
  800b5c:	83 ec 04             	sub    $0x4,%esp
  800b5f:	53                   	push   %ebx
  800b60:	50                   	push   %eax
  800b61:	68 94 22 80 00       	push   $0x802294
  800b66:	e8 0c 09 00 00       	call   801477 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b6b:	83 c4 10             	add    $0x10,%esp
  800b6e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b73:	eb 23                	jmp    800b98 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b75:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b78:	8b 52 18             	mov    0x18(%edx),%edx
  800b7b:	85 d2                	test   %edx,%edx
  800b7d:	74 14                	je     800b93 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b7f:	83 ec 08             	sub    $0x8,%esp
  800b82:	ff 75 0c             	pushl  0xc(%ebp)
  800b85:	50                   	push   %eax
  800b86:	ff d2                	call   *%edx
  800b88:	89 c2                	mov    %eax,%edx
  800b8a:	83 c4 10             	add    $0x10,%esp
  800b8d:	eb 09                	jmp    800b98 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b8f:	89 c2                	mov    %eax,%edx
  800b91:	eb 05                	jmp    800b98 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b93:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b98:	89 d0                	mov    %edx,%eax
  800b9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 14             	sub    $0x14,%esp
  800ba6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ba9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bac:	50                   	push   %eax
  800bad:	ff 75 08             	pushl  0x8(%ebp)
  800bb0:	e8 6c fb ff ff       	call   800721 <fd_lookup>
  800bb5:	83 c4 08             	add    $0x8,%esp
  800bb8:	89 c2                	mov    %eax,%edx
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	78 58                	js     800c16 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bbe:	83 ec 08             	sub    $0x8,%esp
  800bc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc4:	50                   	push   %eax
  800bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc8:	ff 30                	pushl  (%eax)
  800bca:	e8 a8 fb ff ff       	call   800777 <dev_lookup>
  800bcf:	83 c4 10             	add    $0x10,%esp
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	78 37                	js     800c0d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bdd:	74 32                	je     800c11 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bdf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800be2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800be9:	00 00 00 
	stat->st_isdir = 0;
  800bec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bf3:	00 00 00 
	stat->st_dev = dev;
  800bf6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bfc:	83 ec 08             	sub    $0x8,%esp
  800bff:	53                   	push   %ebx
  800c00:	ff 75 f0             	pushl  -0x10(%ebp)
  800c03:	ff 50 14             	call   *0x14(%eax)
  800c06:	89 c2                	mov    %eax,%edx
  800c08:	83 c4 10             	add    $0x10,%esp
  800c0b:	eb 09                	jmp    800c16 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c0d:	89 c2                	mov    %eax,%edx
  800c0f:	eb 05                	jmp    800c16 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c11:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c16:	89 d0                	mov    %edx,%eax
  800c18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c22:	83 ec 08             	sub    $0x8,%esp
  800c25:	6a 00                	push   $0x0
  800c27:	ff 75 08             	pushl  0x8(%ebp)
  800c2a:	e8 e3 01 00 00       	call   800e12 <open>
  800c2f:	89 c3                	mov    %eax,%ebx
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	85 c0                	test   %eax,%eax
  800c36:	78 1b                	js     800c53 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c38:	83 ec 08             	sub    $0x8,%esp
  800c3b:	ff 75 0c             	pushl  0xc(%ebp)
  800c3e:	50                   	push   %eax
  800c3f:	e8 5b ff ff ff       	call   800b9f <fstat>
  800c44:	89 c6                	mov    %eax,%esi
	close(fd);
  800c46:	89 1c 24             	mov    %ebx,(%esp)
  800c49:	e8 fd fb ff ff       	call   80084b <close>
	return r;
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	89 f0                	mov    %esi,%eax
}
  800c53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	89 c6                	mov    %eax,%esi
  800c61:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c63:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c6a:	75 12                	jne    800c7e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	6a 01                	push   $0x1
  800c71:	e8 39 12 00 00       	call   801eaf <ipc_find_env>
  800c76:	a3 00 40 80 00       	mov    %eax,0x804000
  800c7b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c7e:	6a 07                	push   $0x7
  800c80:	68 00 50 80 00       	push   $0x805000
  800c85:	56                   	push   %esi
  800c86:	ff 35 00 40 80 00    	pushl  0x804000
  800c8c:	e8 bc 11 00 00       	call   801e4d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c91:	83 c4 0c             	add    $0xc,%esp
  800c94:	6a 00                	push   $0x0
  800c96:	53                   	push   %ebx
  800c97:	6a 00                	push   $0x0
  800c99:	e8 34 11 00 00       	call   801dd2 <ipc_recv>
}
  800c9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	8b 40 0c             	mov    0xc(%eax),%eax
  800cb1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc3:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc8:	e8 8d ff ff ff       	call   800c5a <fsipc>
}
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	8b 40 0c             	mov    0xc(%eax),%eax
  800cdb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cea:	e8 6b ff ff ff       	call   800c5a <fsipc>
}
  800cef:	c9                   	leave  
  800cf0:	c3                   	ret    

00800cf1 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 04             	sub    $0x4,%esp
  800cf8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	8b 40 0c             	mov    0xc(%eax),%eax
  800d01:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d06:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d10:	e8 45 ff ff ff       	call   800c5a <fsipc>
  800d15:	85 c0                	test   %eax,%eax
  800d17:	78 2c                	js     800d45 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d19:	83 ec 08             	sub    $0x8,%esp
  800d1c:	68 00 50 80 00       	push   $0x805000
  800d21:	53                   	push   %ebx
  800d22:	e8 d5 0c 00 00       	call   8019fc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d27:	a1 80 50 80 00       	mov    0x805080,%eax
  800d2c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d32:	a1 84 50 80 00       	mov    0x805084,%eax
  800d37:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d48:	c9                   	leave  
  800d49:	c3                   	ret    

00800d4a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	8b 52 0c             	mov    0xc(%edx),%edx
  800d59:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d5f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d64:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d69:	0f 47 c2             	cmova  %edx,%eax
  800d6c:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d71:	50                   	push   %eax
  800d72:	ff 75 0c             	pushl  0xc(%ebp)
  800d75:	68 08 50 80 00       	push   $0x805008
  800d7a:	e8 0f 0e 00 00       	call   801b8e <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d84:	b8 04 00 00 00       	mov    $0x4,%eax
  800d89:	e8 cc fe ff ff       	call   800c5a <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d98:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9b:	8b 40 0c             	mov    0xc(%eax),%eax
  800d9e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800da3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800da9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dae:	b8 03 00 00 00       	mov    $0x3,%eax
  800db3:	e8 a2 fe ff ff       	call   800c5a <fsipc>
  800db8:	89 c3                	mov    %eax,%ebx
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	78 4b                	js     800e09 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800dbe:	39 c6                	cmp    %eax,%esi
  800dc0:	73 16                	jae    800dd8 <devfile_read+0x48>
  800dc2:	68 00 23 80 00       	push   $0x802300
  800dc7:	68 07 23 80 00       	push   $0x802307
  800dcc:	6a 7c                	push   $0x7c
  800dce:	68 1c 23 80 00       	push   $0x80231c
  800dd3:	e8 c6 05 00 00       	call   80139e <_panic>
	assert(r <= PGSIZE);
  800dd8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ddd:	7e 16                	jle    800df5 <devfile_read+0x65>
  800ddf:	68 27 23 80 00       	push   $0x802327
  800de4:	68 07 23 80 00       	push   $0x802307
  800de9:	6a 7d                	push   $0x7d
  800deb:	68 1c 23 80 00       	push   $0x80231c
  800df0:	e8 a9 05 00 00       	call   80139e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800df5:	83 ec 04             	sub    $0x4,%esp
  800df8:	50                   	push   %eax
  800df9:	68 00 50 80 00       	push   $0x805000
  800dfe:	ff 75 0c             	pushl  0xc(%ebp)
  800e01:	e8 88 0d 00 00       	call   801b8e <memmove>
	return r;
  800e06:	83 c4 10             	add    $0x10,%esp
}
  800e09:	89 d8                	mov    %ebx,%eax
  800e0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	53                   	push   %ebx
  800e16:	83 ec 20             	sub    $0x20,%esp
  800e19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e1c:	53                   	push   %ebx
  800e1d:	e8 a1 0b 00 00       	call   8019c3 <strlen>
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e2a:	7f 67                	jg     800e93 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e32:	50                   	push   %eax
  800e33:	e8 9a f8 ff ff       	call   8006d2 <fd_alloc>
  800e38:	83 c4 10             	add    $0x10,%esp
		return r;
  800e3b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	78 57                	js     800e98 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e41:	83 ec 08             	sub    $0x8,%esp
  800e44:	53                   	push   %ebx
  800e45:	68 00 50 80 00       	push   $0x805000
  800e4a:	e8 ad 0b 00 00       	call   8019fc <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e52:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e57:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5f:	e8 f6 fd ff ff       	call   800c5a <fsipc>
  800e64:	89 c3                	mov    %eax,%ebx
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	79 14                	jns    800e81 <open+0x6f>
		fd_close(fd, 0);
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	6a 00                	push   $0x0
  800e72:	ff 75 f4             	pushl  -0xc(%ebp)
  800e75:	e8 50 f9 ff ff       	call   8007ca <fd_close>
		return r;
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	89 da                	mov    %ebx,%edx
  800e7f:	eb 17                	jmp    800e98 <open+0x86>
	}

	return fd2num(fd);
  800e81:	83 ec 0c             	sub    $0xc,%esp
  800e84:	ff 75 f4             	pushl  -0xc(%ebp)
  800e87:	e8 1f f8 ff ff       	call   8006ab <fd2num>
  800e8c:	89 c2                	mov    %eax,%edx
  800e8e:	83 c4 10             	add    $0x10,%esp
  800e91:	eb 05                	jmp    800e98 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e93:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e98:	89 d0                	mov    %edx,%eax
  800e9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ea5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaa:	b8 08 00 00 00       	mov    $0x8,%eax
  800eaf:	e8 a6 fd ff ff       	call   800c5a <fsipc>
}
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
  800ebb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ebe:	83 ec 0c             	sub    $0xc,%esp
  800ec1:	ff 75 08             	pushl  0x8(%ebp)
  800ec4:	e8 f2 f7 ff ff       	call   8006bb <fd2data>
  800ec9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ecb:	83 c4 08             	add    $0x8,%esp
  800ece:	68 33 23 80 00       	push   $0x802333
  800ed3:	53                   	push   %ebx
  800ed4:	e8 23 0b 00 00       	call   8019fc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ed9:	8b 46 04             	mov    0x4(%esi),%eax
  800edc:	2b 06                	sub    (%esi),%eax
  800ede:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ee4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800eeb:	00 00 00 
	stat->st_dev = &devpipe;
  800eee:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ef5:	30 80 00 
	return 0;
}
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  800efd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	53                   	push   %ebx
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f0e:	53                   	push   %ebx
  800f0f:	6a 00                	push   $0x0
  800f11:	e8 f5 f2 ff ff       	call   80020b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f16:	89 1c 24             	mov    %ebx,(%esp)
  800f19:	e8 9d f7 ff ff       	call   8006bb <fd2data>
  800f1e:	83 c4 08             	add    $0x8,%esp
  800f21:	50                   	push   %eax
  800f22:	6a 00                	push   $0x0
  800f24:	e8 e2 f2 ff ff       	call   80020b <sys_page_unmap>
}
  800f29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    

00800f2e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 1c             	sub    $0x1c,%esp
  800f37:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f3a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f3c:	a1 04 40 80 00       	mov    0x804004,%eax
  800f41:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f47:	83 ec 0c             	sub    $0xc,%esp
  800f4a:	ff 75 e0             	pushl  -0x20(%ebp)
  800f4d:	e8 9f 0f 00 00       	call   801ef1 <pageref>
  800f52:	89 c3                	mov    %eax,%ebx
  800f54:	89 3c 24             	mov    %edi,(%esp)
  800f57:	e8 95 0f 00 00       	call   801ef1 <pageref>
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	39 c3                	cmp    %eax,%ebx
  800f61:	0f 94 c1             	sete   %cl
  800f64:	0f b6 c9             	movzbl %cl,%ecx
  800f67:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f6a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f70:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  800f76:	39 ce                	cmp    %ecx,%esi
  800f78:	74 1e                	je     800f98 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800f7a:	39 c3                	cmp    %eax,%ebx
  800f7c:	75 be                	jne    800f3c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f7e:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  800f84:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f87:	50                   	push   %eax
  800f88:	56                   	push   %esi
  800f89:	68 3a 23 80 00       	push   $0x80233a
  800f8e:	e8 e4 04 00 00       	call   801477 <cprintf>
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	eb a4                	jmp    800f3c <_pipeisclosed+0xe>
	}
}
  800f98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9e:	5b                   	pop    %ebx
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 28             	sub    $0x28,%esp
  800fac:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800faf:	56                   	push   %esi
  800fb0:	e8 06 f7 ff ff       	call   8006bb <fd2data>
  800fb5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	bf 00 00 00 00       	mov    $0x0,%edi
  800fbf:	eb 4b                	jmp    80100c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fc1:	89 da                	mov    %ebx,%edx
  800fc3:	89 f0                	mov    %esi,%eax
  800fc5:	e8 64 ff ff ff       	call   800f2e <_pipeisclosed>
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	75 48                	jne    801016 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fce:	e8 94 f1 ff ff       	call   800167 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fd3:	8b 43 04             	mov    0x4(%ebx),%eax
  800fd6:	8b 0b                	mov    (%ebx),%ecx
  800fd8:	8d 51 20             	lea    0x20(%ecx),%edx
  800fdb:	39 d0                	cmp    %edx,%eax
  800fdd:	73 e2                	jae    800fc1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fe6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fe9:	89 c2                	mov    %eax,%edx
  800feb:	c1 fa 1f             	sar    $0x1f,%edx
  800fee:	89 d1                	mov    %edx,%ecx
  800ff0:	c1 e9 1b             	shr    $0x1b,%ecx
  800ff3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ff6:	83 e2 1f             	and    $0x1f,%edx
  800ff9:	29 ca                	sub    %ecx,%edx
  800ffb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800fff:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801003:	83 c0 01             	add    $0x1,%eax
  801006:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801009:	83 c7 01             	add    $0x1,%edi
  80100c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80100f:	75 c2                	jne    800fd3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801011:	8b 45 10             	mov    0x10(%ebp),%eax
  801014:	eb 05                	jmp    80101b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801016:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80101b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101e:	5b                   	pop    %ebx
  80101f:	5e                   	pop    %esi
  801020:	5f                   	pop    %edi
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	57                   	push   %edi
  801027:	56                   	push   %esi
  801028:	53                   	push   %ebx
  801029:	83 ec 18             	sub    $0x18,%esp
  80102c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80102f:	57                   	push   %edi
  801030:	e8 86 f6 ff ff       	call   8006bb <fd2data>
  801035:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801037:	83 c4 10             	add    $0x10,%esp
  80103a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80103f:	eb 3d                	jmp    80107e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801041:	85 db                	test   %ebx,%ebx
  801043:	74 04                	je     801049 <devpipe_read+0x26>
				return i;
  801045:	89 d8                	mov    %ebx,%eax
  801047:	eb 44                	jmp    80108d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801049:	89 f2                	mov    %esi,%edx
  80104b:	89 f8                	mov    %edi,%eax
  80104d:	e8 dc fe ff ff       	call   800f2e <_pipeisclosed>
  801052:	85 c0                	test   %eax,%eax
  801054:	75 32                	jne    801088 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801056:	e8 0c f1 ff ff       	call   800167 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80105b:	8b 06                	mov    (%esi),%eax
  80105d:	3b 46 04             	cmp    0x4(%esi),%eax
  801060:	74 df                	je     801041 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801062:	99                   	cltd   
  801063:	c1 ea 1b             	shr    $0x1b,%edx
  801066:	01 d0                	add    %edx,%eax
  801068:	83 e0 1f             	and    $0x1f,%eax
  80106b:	29 d0                	sub    %edx,%eax
  80106d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801072:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801075:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801078:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80107b:	83 c3 01             	add    $0x1,%ebx
  80107e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801081:	75 d8                	jne    80105b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801083:	8b 45 10             	mov    0x10(%ebp),%eax
  801086:	eb 05                	jmp    80108d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801088:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
  80109a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80109d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010a0:	50                   	push   %eax
  8010a1:	e8 2c f6 ff ff       	call   8006d2 <fd_alloc>
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	0f 88 2c 01 00 00    	js     8011df <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010b3:	83 ec 04             	sub    $0x4,%esp
  8010b6:	68 07 04 00 00       	push   $0x407
  8010bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8010be:	6a 00                	push   $0x0
  8010c0:	e8 c1 f0 ff ff       	call   800186 <sys_page_alloc>
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	89 c2                	mov    %eax,%edx
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	0f 88 0d 01 00 00    	js     8011df <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d8:	50                   	push   %eax
  8010d9:	e8 f4 f5 ff ff       	call   8006d2 <fd_alloc>
  8010de:	89 c3                	mov    %eax,%ebx
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	0f 88 e2 00 00 00    	js     8011cd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	68 07 04 00 00       	push   $0x407
  8010f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8010f6:	6a 00                	push   $0x0
  8010f8:	e8 89 f0 ff ff       	call   800186 <sys_page_alloc>
  8010fd:	89 c3                	mov    %eax,%ebx
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	85 c0                	test   %eax,%eax
  801104:	0f 88 c3 00 00 00    	js     8011cd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	ff 75 f4             	pushl  -0xc(%ebp)
  801110:	e8 a6 f5 ff ff       	call   8006bb <fd2data>
  801115:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801117:	83 c4 0c             	add    $0xc,%esp
  80111a:	68 07 04 00 00       	push   $0x407
  80111f:	50                   	push   %eax
  801120:	6a 00                	push   $0x0
  801122:	e8 5f f0 ff ff       	call   800186 <sys_page_alloc>
  801127:	89 c3                	mov    %eax,%ebx
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	0f 88 89 00 00 00    	js     8011bd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	ff 75 f0             	pushl  -0x10(%ebp)
  80113a:	e8 7c f5 ff ff       	call   8006bb <fd2data>
  80113f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801146:	50                   	push   %eax
  801147:	6a 00                	push   $0x0
  801149:	56                   	push   %esi
  80114a:	6a 00                	push   $0x0
  80114c:	e8 78 f0 ff ff       	call   8001c9 <sys_page_map>
  801151:	89 c3                	mov    %eax,%ebx
  801153:	83 c4 20             	add    $0x20,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	78 55                	js     8011af <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80115a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801160:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801163:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801168:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80116f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801175:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801178:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80117a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	ff 75 f4             	pushl  -0xc(%ebp)
  80118a:	e8 1c f5 ff ff       	call   8006ab <fd2num>
  80118f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801192:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801194:	83 c4 04             	add    $0x4,%esp
  801197:	ff 75 f0             	pushl  -0x10(%ebp)
  80119a:	e8 0c f5 ff ff       	call   8006ab <fd2num>
  80119f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a2:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ad:	eb 30                	jmp    8011df <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	56                   	push   %esi
  8011b3:	6a 00                	push   $0x0
  8011b5:	e8 51 f0 ff ff       	call   80020b <sys_page_unmap>
  8011ba:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8011c3:	6a 00                	push   $0x0
  8011c5:	e8 41 f0 ff ff       	call   80020b <sys_page_unmap>
  8011ca:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8011d3:	6a 00                	push   $0x0
  8011d5:	e8 31 f0 ff ff       	call   80020b <sys_page_unmap>
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011df:	89 d0                	mov    %edx,%eax
  8011e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e4:	5b                   	pop    %ebx
  8011e5:	5e                   	pop    %esi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f1:	50                   	push   %eax
  8011f2:	ff 75 08             	pushl  0x8(%ebp)
  8011f5:	e8 27 f5 ff ff       	call   800721 <fd_lookup>
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 18                	js     801219 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801201:	83 ec 0c             	sub    $0xc,%esp
  801204:	ff 75 f4             	pushl  -0xc(%ebp)
  801207:	e8 af f4 ff ff       	call   8006bb <fd2data>
	return _pipeisclosed(fd, p);
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801211:	e8 18 fd ff ff       	call   800f2e <_pipeisclosed>
  801216:	83 c4 10             	add    $0x10,%esp
}
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80121e:	b8 00 00 00 00       	mov    $0x0,%eax
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80122b:	68 52 23 80 00       	push   $0x802352
  801230:	ff 75 0c             	pushl  0xc(%ebp)
  801233:	e8 c4 07 00 00       	call   8019fc <strcpy>
	return 0;
}
  801238:	b8 00 00 00 00       	mov    $0x0,%eax
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	57                   	push   %edi
  801243:	56                   	push   %esi
  801244:	53                   	push   %ebx
  801245:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80124b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801250:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801256:	eb 2d                	jmp    801285 <devcons_write+0x46>
		m = n - tot;
  801258:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80125b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80125d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801260:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801265:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801268:	83 ec 04             	sub    $0x4,%esp
  80126b:	53                   	push   %ebx
  80126c:	03 45 0c             	add    0xc(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	57                   	push   %edi
  801271:	e8 18 09 00 00       	call   801b8e <memmove>
		sys_cputs(buf, m);
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	53                   	push   %ebx
  80127a:	57                   	push   %edi
  80127b:	e8 4a ee ff ff       	call   8000ca <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801280:	01 de                	add    %ebx,%esi
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	89 f0                	mov    %esi,%eax
  801287:	3b 75 10             	cmp    0x10(%ebp),%esi
  80128a:	72 cc                	jb     801258 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80128c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    

00801294 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
  801297:	83 ec 08             	sub    $0x8,%esp
  80129a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80129f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012a3:	74 2a                	je     8012cf <devcons_read+0x3b>
  8012a5:	eb 05                	jmp    8012ac <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012a7:	e8 bb ee ff ff       	call   800167 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012ac:	e8 37 ee ff ff       	call   8000e8 <sys_cgetc>
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	74 f2                	je     8012a7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 16                	js     8012cf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012b9:	83 f8 04             	cmp    $0x4,%eax
  8012bc:	74 0c                	je     8012ca <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c1:	88 02                	mov    %al,(%edx)
	return 1;
  8012c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8012c8:	eb 05                	jmp    8012cf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    

008012d1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012da:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012dd:	6a 01                	push   $0x1
  8012df:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012e2:	50                   	push   %eax
  8012e3:	e8 e2 ed ff ff       	call   8000ca <sys_cputs>
}
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	c9                   	leave  
  8012ec:	c3                   	ret    

008012ed <getchar>:

int
getchar(void)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012f3:	6a 01                	push   $0x1
  8012f5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	6a 00                	push   $0x0
  8012fb:	e8 87 f6 ff ff       	call   800987 <read>
	if (r < 0)
  801300:	83 c4 10             	add    $0x10,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 0f                	js     801316 <getchar+0x29>
		return r;
	if (r < 1)
  801307:	85 c0                	test   %eax,%eax
  801309:	7e 06                	jle    801311 <getchar+0x24>
		return -E_EOF;
	return c;
  80130b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80130f:	eb 05                	jmp    801316 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801311:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	ff 75 08             	pushl  0x8(%ebp)
  801325:	e8 f7 f3 ff ff       	call   800721 <fd_lookup>
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	85 c0                	test   %eax,%eax
  80132f:	78 11                	js     801342 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801331:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801334:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80133a:	39 10                	cmp    %edx,(%eax)
  80133c:	0f 94 c0             	sete   %al
  80133f:	0f b6 c0             	movzbl %al,%eax
}
  801342:	c9                   	leave  
  801343:	c3                   	ret    

00801344 <opencons>:

int
opencons(void)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80134a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134d:	50                   	push   %eax
  80134e:	e8 7f f3 ff ff       	call   8006d2 <fd_alloc>
  801353:	83 c4 10             	add    $0x10,%esp
		return r;
  801356:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 3e                	js     80139a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80135c:	83 ec 04             	sub    $0x4,%esp
  80135f:	68 07 04 00 00       	push   $0x407
  801364:	ff 75 f4             	pushl  -0xc(%ebp)
  801367:	6a 00                	push   $0x0
  801369:	e8 18 ee ff ff       	call   800186 <sys_page_alloc>
  80136e:	83 c4 10             	add    $0x10,%esp
		return r;
  801371:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801373:	85 c0                	test   %eax,%eax
  801375:	78 23                	js     80139a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801377:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80137d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801380:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801382:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801385:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80138c:	83 ec 0c             	sub    $0xc,%esp
  80138f:	50                   	push   %eax
  801390:	e8 16 f3 ff ff       	call   8006ab <fd2num>
  801395:	89 c2                	mov    %eax,%edx
  801397:	83 c4 10             	add    $0x10,%esp
}
  80139a:	89 d0                	mov    %edx,%eax
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013a3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013a6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013ac:	e8 97 ed ff ff       	call   800148 <sys_getenvid>
  8013b1:	83 ec 0c             	sub    $0xc,%esp
  8013b4:	ff 75 0c             	pushl  0xc(%ebp)
  8013b7:	ff 75 08             	pushl  0x8(%ebp)
  8013ba:	56                   	push   %esi
  8013bb:	50                   	push   %eax
  8013bc:	68 60 23 80 00       	push   $0x802360
  8013c1:	e8 b1 00 00 00       	call   801477 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013c6:	83 c4 18             	add    $0x18,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	ff 75 10             	pushl  0x10(%ebp)
  8013cd:	e8 54 00 00 00       	call   801426 <vcprintf>
	cprintf("\n");
  8013d2:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  8013d9:	e8 99 00 00 00       	call   801477 <cprintf>
  8013de:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013e1:	cc                   	int3   
  8013e2:	eb fd                	jmp    8013e1 <_panic+0x43>

008013e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	53                   	push   %ebx
  8013e8:	83 ec 04             	sub    $0x4,%esp
  8013eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013ee:	8b 13                	mov    (%ebx),%edx
  8013f0:	8d 42 01             	lea    0x1(%edx),%eax
  8013f3:	89 03                	mov    %eax,(%ebx)
  8013f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  801401:	75 1a                	jne    80141d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	68 ff 00 00 00       	push   $0xff
  80140b:	8d 43 08             	lea    0x8(%ebx),%eax
  80140e:	50                   	push   %eax
  80140f:	e8 b6 ec ff ff       	call   8000ca <sys_cputs>
		b->idx = 0;
  801414:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80141a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80141d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801421:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80142f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801436:	00 00 00 
	b.cnt = 0;
  801439:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801440:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801443:	ff 75 0c             	pushl  0xc(%ebp)
  801446:	ff 75 08             	pushl  0x8(%ebp)
  801449:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	68 e4 13 80 00       	push   $0x8013e4
  801455:	e8 54 01 00 00       	call   8015ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80145a:	83 c4 08             	add    $0x8,%esp
  80145d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801463:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	e8 5b ec ff ff       	call   8000ca <sys_cputs>

	return b.cnt;
}
  80146f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80147d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801480:	50                   	push   %eax
  801481:	ff 75 08             	pushl  0x8(%ebp)
  801484:	e8 9d ff ff ff       	call   801426 <vcprintf>
	va_end(ap);

	return cnt;
}
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	57                   	push   %edi
  80148f:	56                   	push   %esi
  801490:	53                   	push   %ebx
  801491:	83 ec 1c             	sub    $0x1c,%esp
  801494:	89 c7                	mov    %eax,%edi
  801496:	89 d6                	mov    %edx,%esi
  801498:	8b 45 08             	mov    0x8(%ebp),%eax
  80149b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014b2:	39 d3                	cmp    %edx,%ebx
  8014b4:	72 05                	jb     8014bb <printnum+0x30>
  8014b6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014b9:	77 45                	ja     801500 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	ff 75 18             	pushl  0x18(%ebp)
  8014c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014c7:	53                   	push   %ebx
  8014c8:	ff 75 10             	pushl  0x10(%ebp)
  8014cb:	83 ec 08             	sub    $0x8,%esp
  8014ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8014d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8014d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8014da:	e8 51 0a 00 00       	call   801f30 <__udivdi3>
  8014df:	83 c4 18             	add    $0x18,%esp
  8014e2:	52                   	push   %edx
  8014e3:	50                   	push   %eax
  8014e4:	89 f2                	mov    %esi,%edx
  8014e6:	89 f8                	mov    %edi,%eax
  8014e8:	e8 9e ff ff ff       	call   80148b <printnum>
  8014ed:	83 c4 20             	add    $0x20,%esp
  8014f0:	eb 18                	jmp    80150a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014f2:	83 ec 08             	sub    $0x8,%esp
  8014f5:	56                   	push   %esi
  8014f6:	ff 75 18             	pushl  0x18(%ebp)
  8014f9:	ff d7                	call   *%edi
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	eb 03                	jmp    801503 <printnum+0x78>
  801500:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801503:	83 eb 01             	sub    $0x1,%ebx
  801506:	85 db                	test   %ebx,%ebx
  801508:	7f e8                	jg     8014f2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80150a:	83 ec 08             	sub    $0x8,%esp
  80150d:	56                   	push   %esi
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	ff 75 e4             	pushl  -0x1c(%ebp)
  801514:	ff 75 e0             	pushl  -0x20(%ebp)
  801517:	ff 75 dc             	pushl  -0x24(%ebp)
  80151a:	ff 75 d8             	pushl  -0x28(%ebp)
  80151d:	e8 3e 0b 00 00       	call   802060 <__umoddi3>
  801522:	83 c4 14             	add    $0x14,%esp
  801525:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  80152c:	50                   	push   %eax
  80152d:	ff d7                	call   *%edi
}
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801535:	5b                   	pop    %ebx
  801536:	5e                   	pop    %esi
  801537:	5f                   	pop    %edi
  801538:	5d                   	pop    %ebp
  801539:	c3                   	ret    

0080153a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80153d:	83 fa 01             	cmp    $0x1,%edx
  801540:	7e 0e                	jle    801550 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801542:	8b 10                	mov    (%eax),%edx
  801544:	8d 4a 08             	lea    0x8(%edx),%ecx
  801547:	89 08                	mov    %ecx,(%eax)
  801549:	8b 02                	mov    (%edx),%eax
  80154b:	8b 52 04             	mov    0x4(%edx),%edx
  80154e:	eb 22                	jmp    801572 <getuint+0x38>
	else if (lflag)
  801550:	85 d2                	test   %edx,%edx
  801552:	74 10                	je     801564 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801554:	8b 10                	mov    (%eax),%edx
  801556:	8d 4a 04             	lea    0x4(%edx),%ecx
  801559:	89 08                	mov    %ecx,(%eax)
  80155b:	8b 02                	mov    (%edx),%eax
  80155d:	ba 00 00 00 00       	mov    $0x0,%edx
  801562:	eb 0e                	jmp    801572 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801564:	8b 10                	mov    (%eax),%edx
  801566:	8d 4a 04             	lea    0x4(%edx),%ecx
  801569:	89 08                	mov    %ecx,(%eax)
  80156b:	8b 02                	mov    (%edx),%eax
  80156d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    

00801574 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801574:	55                   	push   %ebp
  801575:	89 e5                	mov    %esp,%ebp
  801577:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80157a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80157e:	8b 10                	mov    (%eax),%edx
  801580:	3b 50 04             	cmp    0x4(%eax),%edx
  801583:	73 0a                	jae    80158f <sprintputch+0x1b>
		*b->buf++ = ch;
  801585:	8d 4a 01             	lea    0x1(%edx),%ecx
  801588:	89 08                	mov    %ecx,(%eax)
  80158a:	8b 45 08             	mov    0x8(%ebp),%eax
  80158d:	88 02                	mov    %al,(%edx)
}
  80158f:	5d                   	pop    %ebp
  801590:	c3                   	ret    

00801591 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801597:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80159a:	50                   	push   %eax
  80159b:	ff 75 10             	pushl  0x10(%ebp)
  80159e:	ff 75 0c             	pushl  0xc(%ebp)
  8015a1:	ff 75 08             	pushl  0x8(%ebp)
  8015a4:	e8 05 00 00 00       	call   8015ae <vprintfmt>
	va_end(ap);
}
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	c9                   	leave  
  8015ad:	c3                   	ret    

008015ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	57                   	push   %edi
  8015b2:	56                   	push   %esi
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 2c             	sub    $0x2c,%esp
  8015b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015c0:	eb 12                	jmp    8015d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	0f 84 89 03 00 00    	je     801953 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	53                   	push   %ebx
  8015ce:	50                   	push   %eax
  8015cf:	ff d6                	call   *%esi
  8015d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015d4:	83 c7 01             	add    $0x1,%edi
  8015d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015db:	83 f8 25             	cmp    $0x25,%eax
  8015de:	75 e2                	jne    8015c2 <vprintfmt+0x14>
  8015e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fe:	eb 07                	jmp    801607 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801600:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801603:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801607:	8d 47 01             	lea    0x1(%edi),%eax
  80160a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80160d:	0f b6 07             	movzbl (%edi),%eax
  801610:	0f b6 c8             	movzbl %al,%ecx
  801613:	83 e8 23             	sub    $0x23,%eax
  801616:	3c 55                	cmp    $0x55,%al
  801618:	0f 87 1a 03 00 00    	ja     801938 <vprintfmt+0x38a>
  80161e:	0f b6 c0             	movzbl %al,%eax
  801621:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  801628:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80162b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80162f:	eb d6                	jmp    801607 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801634:	b8 00 00 00 00       	mov    $0x0,%eax
  801639:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80163c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80163f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801643:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801646:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801649:	83 fa 09             	cmp    $0x9,%edx
  80164c:	77 39                	ja     801687 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80164e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801651:	eb e9                	jmp    80163c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801653:	8b 45 14             	mov    0x14(%ebp),%eax
  801656:	8d 48 04             	lea    0x4(%eax),%ecx
  801659:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80165c:	8b 00                	mov    (%eax),%eax
  80165e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801661:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801664:	eb 27                	jmp    80168d <vprintfmt+0xdf>
  801666:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801669:	85 c0                	test   %eax,%eax
  80166b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801670:	0f 49 c8             	cmovns %eax,%ecx
  801673:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801679:	eb 8c                	jmp    801607 <vprintfmt+0x59>
  80167b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80167e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801685:	eb 80                	jmp    801607 <vprintfmt+0x59>
  801687:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80168a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80168d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801691:	0f 89 70 ff ff ff    	jns    801607 <vprintfmt+0x59>
				width = precision, precision = -1;
  801697:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80169a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80169d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016a4:	e9 5e ff ff ff       	jmp    801607 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016af:	e9 53 ff ff ff       	jmp    801607 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b7:	8d 50 04             	lea    0x4(%eax),%edx
  8016ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	53                   	push   %ebx
  8016c1:	ff 30                	pushl  (%eax)
  8016c3:	ff d6                	call   *%esi
			break;
  8016c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016cb:	e9 04 ff ff ff       	jmp    8015d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d3:	8d 50 04             	lea    0x4(%eax),%edx
  8016d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d9:	8b 00                	mov    (%eax),%eax
  8016db:	99                   	cltd   
  8016dc:	31 d0                	xor    %edx,%eax
  8016de:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016e0:	83 f8 0f             	cmp    $0xf,%eax
  8016e3:	7f 0b                	jg     8016f0 <vprintfmt+0x142>
  8016e5:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8016ec:	85 d2                	test   %edx,%edx
  8016ee:	75 18                	jne    801708 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016f0:	50                   	push   %eax
  8016f1:	68 9b 23 80 00       	push   $0x80239b
  8016f6:	53                   	push   %ebx
  8016f7:	56                   	push   %esi
  8016f8:	e8 94 fe ff ff       	call   801591 <printfmt>
  8016fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801700:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801703:	e9 cc fe ff ff       	jmp    8015d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801708:	52                   	push   %edx
  801709:	68 19 23 80 00       	push   $0x802319
  80170e:	53                   	push   %ebx
  80170f:	56                   	push   %esi
  801710:	e8 7c fe ff ff       	call   801591 <printfmt>
  801715:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801718:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80171b:	e9 b4 fe ff ff       	jmp    8015d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801720:	8b 45 14             	mov    0x14(%ebp),%eax
  801723:	8d 50 04             	lea    0x4(%eax),%edx
  801726:	89 55 14             	mov    %edx,0x14(%ebp)
  801729:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80172b:	85 ff                	test   %edi,%edi
  80172d:	b8 94 23 80 00       	mov    $0x802394,%eax
  801732:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801735:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801739:	0f 8e 94 00 00 00    	jle    8017d3 <vprintfmt+0x225>
  80173f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801743:	0f 84 98 00 00 00    	je     8017e1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	ff 75 d0             	pushl  -0x30(%ebp)
  80174f:	57                   	push   %edi
  801750:	e8 86 02 00 00       	call   8019db <strnlen>
  801755:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801758:	29 c1                	sub    %eax,%ecx
  80175a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80175d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801760:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801764:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801767:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80176a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80176c:	eb 0f                	jmp    80177d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80176e:	83 ec 08             	sub    $0x8,%esp
  801771:	53                   	push   %ebx
  801772:	ff 75 e0             	pushl  -0x20(%ebp)
  801775:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801777:	83 ef 01             	sub    $0x1,%edi
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 ff                	test   %edi,%edi
  80177f:	7f ed                	jg     80176e <vprintfmt+0x1c0>
  801781:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801784:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801787:	85 c9                	test   %ecx,%ecx
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
  80178e:	0f 49 c1             	cmovns %ecx,%eax
  801791:	29 c1                	sub    %eax,%ecx
  801793:	89 75 08             	mov    %esi,0x8(%ebp)
  801796:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801799:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80179c:	89 cb                	mov    %ecx,%ebx
  80179e:	eb 4d                	jmp    8017ed <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017a4:	74 1b                	je     8017c1 <vprintfmt+0x213>
  8017a6:	0f be c0             	movsbl %al,%eax
  8017a9:	83 e8 20             	sub    $0x20,%eax
  8017ac:	83 f8 5e             	cmp    $0x5e,%eax
  8017af:	76 10                	jbe    8017c1 <vprintfmt+0x213>
					putch('?', putdat);
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	ff 75 0c             	pushl  0xc(%ebp)
  8017b7:	6a 3f                	push   $0x3f
  8017b9:	ff 55 08             	call   *0x8(%ebp)
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	eb 0d                	jmp    8017ce <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017c1:	83 ec 08             	sub    $0x8,%esp
  8017c4:	ff 75 0c             	pushl  0xc(%ebp)
  8017c7:	52                   	push   %edx
  8017c8:	ff 55 08             	call   *0x8(%ebp)
  8017cb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017ce:	83 eb 01             	sub    $0x1,%ebx
  8017d1:	eb 1a                	jmp    8017ed <vprintfmt+0x23f>
  8017d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8017d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017dc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017df:	eb 0c                	jmp    8017ed <vprintfmt+0x23f>
  8017e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8017e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017ed:	83 c7 01             	add    $0x1,%edi
  8017f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017f4:	0f be d0             	movsbl %al,%edx
  8017f7:	85 d2                	test   %edx,%edx
  8017f9:	74 23                	je     80181e <vprintfmt+0x270>
  8017fb:	85 f6                	test   %esi,%esi
  8017fd:	78 a1                	js     8017a0 <vprintfmt+0x1f2>
  8017ff:	83 ee 01             	sub    $0x1,%esi
  801802:	79 9c                	jns    8017a0 <vprintfmt+0x1f2>
  801804:	89 df                	mov    %ebx,%edi
  801806:	8b 75 08             	mov    0x8(%ebp),%esi
  801809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80180c:	eb 18                	jmp    801826 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	53                   	push   %ebx
  801812:	6a 20                	push   $0x20
  801814:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801816:	83 ef 01             	sub    $0x1,%edi
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	eb 08                	jmp    801826 <vprintfmt+0x278>
  80181e:	89 df                	mov    %ebx,%edi
  801820:	8b 75 08             	mov    0x8(%ebp),%esi
  801823:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801826:	85 ff                	test   %edi,%edi
  801828:	7f e4                	jg     80180e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80182d:	e9 a2 fd ff ff       	jmp    8015d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801832:	83 fa 01             	cmp    $0x1,%edx
  801835:	7e 16                	jle    80184d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801837:	8b 45 14             	mov    0x14(%ebp),%eax
  80183a:	8d 50 08             	lea    0x8(%eax),%edx
  80183d:	89 55 14             	mov    %edx,0x14(%ebp)
  801840:	8b 50 04             	mov    0x4(%eax),%edx
  801843:	8b 00                	mov    (%eax),%eax
  801845:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801848:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80184b:	eb 32                	jmp    80187f <vprintfmt+0x2d1>
	else if (lflag)
  80184d:	85 d2                	test   %edx,%edx
  80184f:	74 18                	je     801869 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801851:	8b 45 14             	mov    0x14(%ebp),%eax
  801854:	8d 50 04             	lea    0x4(%eax),%edx
  801857:	89 55 14             	mov    %edx,0x14(%ebp)
  80185a:	8b 00                	mov    (%eax),%eax
  80185c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80185f:	89 c1                	mov    %eax,%ecx
  801861:	c1 f9 1f             	sar    $0x1f,%ecx
  801864:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801867:	eb 16                	jmp    80187f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801869:	8b 45 14             	mov    0x14(%ebp),%eax
  80186c:	8d 50 04             	lea    0x4(%eax),%edx
  80186f:	89 55 14             	mov    %edx,0x14(%ebp)
  801872:	8b 00                	mov    (%eax),%eax
  801874:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801877:	89 c1                	mov    %eax,%ecx
  801879:	c1 f9 1f             	sar    $0x1f,%ecx
  80187c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80187f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801882:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801885:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80188a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80188e:	79 74                	jns    801904 <vprintfmt+0x356>
				putch('-', putdat);
  801890:	83 ec 08             	sub    $0x8,%esp
  801893:	53                   	push   %ebx
  801894:	6a 2d                	push   $0x2d
  801896:	ff d6                	call   *%esi
				num = -(long long) num;
  801898:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80189b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80189e:	f7 d8                	neg    %eax
  8018a0:	83 d2 00             	adc    $0x0,%edx
  8018a3:	f7 da                	neg    %edx
  8018a5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018ad:	eb 55                	jmp    801904 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018af:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b2:	e8 83 fc ff ff       	call   80153a <getuint>
			base = 10;
  8018b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018bc:	eb 46                	jmp    801904 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018be:	8d 45 14             	lea    0x14(%ebp),%eax
  8018c1:	e8 74 fc ff ff       	call   80153a <getuint>
			base = 8;
  8018c6:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018cb:	eb 37                	jmp    801904 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	53                   	push   %ebx
  8018d1:	6a 30                	push   $0x30
  8018d3:	ff d6                	call   *%esi
			putch('x', putdat);
  8018d5:	83 c4 08             	add    $0x8,%esp
  8018d8:	53                   	push   %ebx
  8018d9:	6a 78                	push   $0x78
  8018db:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e0:	8d 50 04             	lea    0x4(%eax),%edx
  8018e3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018e6:	8b 00                	mov    (%eax),%eax
  8018e8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018ed:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018f0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018f5:	eb 0d                	jmp    801904 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8018fa:	e8 3b fc ff ff       	call   80153a <getuint>
			base = 16;
  8018ff:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801904:	83 ec 0c             	sub    $0xc,%esp
  801907:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80190b:	57                   	push   %edi
  80190c:	ff 75 e0             	pushl  -0x20(%ebp)
  80190f:	51                   	push   %ecx
  801910:	52                   	push   %edx
  801911:	50                   	push   %eax
  801912:	89 da                	mov    %ebx,%edx
  801914:	89 f0                	mov    %esi,%eax
  801916:	e8 70 fb ff ff       	call   80148b <printnum>
			break;
  80191b:	83 c4 20             	add    $0x20,%esp
  80191e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801921:	e9 ae fc ff ff       	jmp    8015d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	53                   	push   %ebx
  80192a:	51                   	push   %ecx
  80192b:	ff d6                	call   *%esi
			break;
  80192d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801930:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801933:	e9 9c fc ff ff       	jmp    8015d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801938:	83 ec 08             	sub    $0x8,%esp
  80193b:	53                   	push   %ebx
  80193c:	6a 25                	push   $0x25
  80193e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	eb 03                	jmp    801948 <vprintfmt+0x39a>
  801945:	83 ef 01             	sub    $0x1,%edi
  801948:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80194c:	75 f7                	jne    801945 <vprintfmt+0x397>
  80194e:	e9 81 fc ff ff       	jmp    8015d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801953:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5f                   	pop    %edi
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	83 ec 18             	sub    $0x18,%esp
  801961:	8b 45 08             	mov    0x8(%ebp),%eax
  801964:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801967:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80196a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80196e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801971:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801978:	85 c0                	test   %eax,%eax
  80197a:	74 26                	je     8019a2 <vsnprintf+0x47>
  80197c:	85 d2                	test   %edx,%edx
  80197e:	7e 22                	jle    8019a2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801980:	ff 75 14             	pushl  0x14(%ebp)
  801983:	ff 75 10             	pushl  0x10(%ebp)
  801986:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801989:	50                   	push   %eax
  80198a:	68 74 15 80 00       	push   $0x801574
  80198f:	e8 1a fc ff ff       	call   8015ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801994:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801997:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80199a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	eb 05                	jmp    8019a7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019b2:	50                   	push   %eax
  8019b3:	ff 75 10             	pushl  0x10(%ebp)
  8019b6:	ff 75 0c             	pushl  0xc(%ebp)
  8019b9:	ff 75 08             	pushl  0x8(%ebp)
  8019bc:	e8 9a ff ff ff       	call   80195b <vsnprintf>
	va_end(ap);

	return rc;
}
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ce:	eb 03                	jmp    8019d3 <strlen+0x10>
		n++;
  8019d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019d7:	75 f7                	jne    8019d0 <strlen+0xd>
		n++;
	return n;
}
  8019d9:	5d                   	pop    %ebp
  8019da:	c3                   	ret    

008019db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e9:	eb 03                	jmp    8019ee <strnlen+0x13>
		n++;
  8019eb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019ee:	39 c2                	cmp    %eax,%edx
  8019f0:	74 08                	je     8019fa <strnlen+0x1f>
  8019f2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019f6:	75 f3                	jne    8019eb <strnlen+0x10>
  8019f8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	53                   	push   %ebx
  801a00:	8b 45 08             	mov    0x8(%ebp),%eax
  801a03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a06:	89 c2                	mov    %eax,%edx
  801a08:	83 c2 01             	add    $0x1,%edx
  801a0b:	83 c1 01             	add    $0x1,%ecx
  801a0e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a12:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a15:	84 db                	test   %bl,%bl
  801a17:	75 ef                	jne    801a08 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a19:	5b                   	pop    %ebx
  801a1a:	5d                   	pop    %ebp
  801a1b:	c3                   	ret    

00801a1c <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	53                   	push   %ebx
  801a20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a23:	53                   	push   %ebx
  801a24:	e8 9a ff ff ff       	call   8019c3 <strlen>
  801a29:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a2c:	ff 75 0c             	pushl  0xc(%ebp)
  801a2f:	01 d8                	add    %ebx,%eax
  801a31:	50                   	push   %eax
  801a32:	e8 c5 ff ff ff       	call   8019fc <strcpy>
	return dst;
}
  801a37:	89 d8                	mov    %ebx,%eax
  801a39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	8b 75 08             	mov    0x8(%ebp),%esi
  801a46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a49:	89 f3                	mov    %esi,%ebx
  801a4b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a4e:	89 f2                	mov    %esi,%edx
  801a50:	eb 0f                	jmp    801a61 <strncpy+0x23>
		*dst++ = *src;
  801a52:	83 c2 01             	add    $0x1,%edx
  801a55:	0f b6 01             	movzbl (%ecx),%eax
  801a58:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a5b:	80 39 01             	cmpb   $0x1,(%ecx)
  801a5e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a61:	39 da                	cmp    %ebx,%edx
  801a63:	75 ed                	jne    801a52 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a65:	89 f0                	mov    %esi,%eax
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	8b 75 08             	mov    0x8(%ebp),%esi
  801a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a76:	8b 55 10             	mov    0x10(%ebp),%edx
  801a79:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a7b:	85 d2                	test   %edx,%edx
  801a7d:	74 21                	je     801aa0 <strlcpy+0x35>
  801a7f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a83:	89 f2                	mov    %esi,%edx
  801a85:	eb 09                	jmp    801a90 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a87:	83 c2 01             	add    $0x1,%edx
  801a8a:	83 c1 01             	add    $0x1,%ecx
  801a8d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a90:	39 c2                	cmp    %eax,%edx
  801a92:	74 09                	je     801a9d <strlcpy+0x32>
  801a94:	0f b6 19             	movzbl (%ecx),%ebx
  801a97:	84 db                	test   %bl,%bl
  801a99:	75 ec                	jne    801a87 <strlcpy+0x1c>
  801a9b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a9d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801aa0:	29 f0                	sub    %esi,%eax
}
  801aa2:	5b                   	pop    %ebx
  801aa3:	5e                   	pop    %esi
  801aa4:	5d                   	pop    %ebp
  801aa5:	c3                   	ret    

00801aa6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aac:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801aaf:	eb 06                	jmp    801ab7 <strcmp+0x11>
		p++, q++;
  801ab1:	83 c1 01             	add    $0x1,%ecx
  801ab4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ab7:	0f b6 01             	movzbl (%ecx),%eax
  801aba:	84 c0                	test   %al,%al
  801abc:	74 04                	je     801ac2 <strcmp+0x1c>
  801abe:	3a 02                	cmp    (%edx),%al
  801ac0:	74 ef                	je     801ab1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ac2:	0f b6 c0             	movzbl %al,%eax
  801ac5:	0f b6 12             	movzbl (%edx),%edx
  801ac8:	29 d0                	sub    %edx,%eax
}
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	53                   	push   %ebx
  801ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ad6:	89 c3                	mov    %eax,%ebx
  801ad8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801adb:	eb 06                	jmp    801ae3 <strncmp+0x17>
		n--, p++, q++;
  801add:	83 c0 01             	add    $0x1,%eax
  801ae0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ae3:	39 d8                	cmp    %ebx,%eax
  801ae5:	74 15                	je     801afc <strncmp+0x30>
  801ae7:	0f b6 08             	movzbl (%eax),%ecx
  801aea:	84 c9                	test   %cl,%cl
  801aec:	74 04                	je     801af2 <strncmp+0x26>
  801aee:	3a 0a                	cmp    (%edx),%cl
  801af0:	74 eb                	je     801add <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801af2:	0f b6 00             	movzbl (%eax),%eax
  801af5:	0f b6 12             	movzbl (%edx),%edx
  801af8:	29 d0                	sub    %edx,%eax
  801afa:	eb 05                	jmp    801b01 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b01:	5b                   	pop    %ebx
  801b02:	5d                   	pop    %ebp
  801b03:	c3                   	ret    

00801b04 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b0e:	eb 07                	jmp    801b17 <strchr+0x13>
		if (*s == c)
  801b10:	38 ca                	cmp    %cl,%dl
  801b12:	74 0f                	je     801b23 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b14:	83 c0 01             	add    $0x1,%eax
  801b17:	0f b6 10             	movzbl (%eax),%edx
  801b1a:	84 d2                	test   %dl,%dl
  801b1c:	75 f2                	jne    801b10 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b2f:	eb 03                	jmp    801b34 <strfind+0xf>
  801b31:	83 c0 01             	add    $0x1,%eax
  801b34:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b37:	38 ca                	cmp    %cl,%dl
  801b39:	74 04                	je     801b3f <strfind+0x1a>
  801b3b:	84 d2                	test   %dl,%dl
  801b3d:	75 f2                	jne    801b31 <strfind+0xc>
			break;
	return (char *) s;
}
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	57                   	push   %edi
  801b45:	56                   	push   %esi
  801b46:	53                   	push   %ebx
  801b47:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b4d:	85 c9                	test   %ecx,%ecx
  801b4f:	74 36                	je     801b87 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b51:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b57:	75 28                	jne    801b81 <memset+0x40>
  801b59:	f6 c1 03             	test   $0x3,%cl
  801b5c:	75 23                	jne    801b81 <memset+0x40>
		c &= 0xFF;
  801b5e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b62:	89 d3                	mov    %edx,%ebx
  801b64:	c1 e3 08             	shl    $0x8,%ebx
  801b67:	89 d6                	mov    %edx,%esi
  801b69:	c1 e6 18             	shl    $0x18,%esi
  801b6c:	89 d0                	mov    %edx,%eax
  801b6e:	c1 e0 10             	shl    $0x10,%eax
  801b71:	09 f0                	or     %esi,%eax
  801b73:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b75:	89 d8                	mov    %ebx,%eax
  801b77:	09 d0                	or     %edx,%eax
  801b79:	c1 e9 02             	shr    $0x2,%ecx
  801b7c:	fc                   	cld    
  801b7d:	f3 ab                	rep stos %eax,%es:(%edi)
  801b7f:	eb 06                	jmp    801b87 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b84:	fc                   	cld    
  801b85:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b87:	89 f8                	mov    %edi,%eax
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5f                   	pop    %edi
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    

00801b8e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	8b 45 08             	mov    0x8(%ebp),%eax
  801b96:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b99:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b9c:	39 c6                	cmp    %eax,%esi
  801b9e:	73 35                	jae    801bd5 <memmove+0x47>
  801ba0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ba3:	39 d0                	cmp    %edx,%eax
  801ba5:	73 2e                	jae    801bd5 <memmove+0x47>
		s += n;
		d += n;
  801ba7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801baa:	89 d6                	mov    %edx,%esi
  801bac:	09 fe                	or     %edi,%esi
  801bae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bb4:	75 13                	jne    801bc9 <memmove+0x3b>
  801bb6:	f6 c1 03             	test   $0x3,%cl
  801bb9:	75 0e                	jne    801bc9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bbb:	83 ef 04             	sub    $0x4,%edi
  801bbe:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bc1:	c1 e9 02             	shr    $0x2,%ecx
  801bc4:	fd                   	std    
  801bc5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bc7:	eb 09                	jmp    801bd2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bc9:	83 ef 01             	sub    $0x1,%edi
  801bcc:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bcf:	fd                   	std    
  801bd0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bd2:	fc                   	cld    
  801bd3:	eb 1d                	jmp    801bf2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bd5:	89 f2                	mov    %esi,%edx
  801bd7:	09 c2                	or     %eax,%edx
  801bd9:	f6 c2 03             	test   $0x3,%dl
  801bdc:	75 0f                	jne    801bed <memmove+0x5f>
  801bde:	f6 c1 03             	test   $0x3,%cl
  801be1:	75 0a                	jne    801bed <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801be3:	c1 e9 02             	shr    $0x2,%ecx
  801be6:	89 c7                	mov    %eax,%edi
  801be8:	fc                   	cld    
  801be9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801beb:	eb 05                	jmp    801bf2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bed:	89 c7                	mov    %eax,%edi
  801bef:	fc                   	cld    
  801bf0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801bf2:	5e                   	pop    %esi
  801bf3:	5f                   	pop    %edi
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801bf9:	ff 75 10             	pushl  0x10(%ebp)
  801bfc:	ff 75 0c             	pushl  0xc(%ebp)
  801bff:	ff 75 08             	pushl  0x8(%ebp)
  801c02:	e8 87 ff ff ff       	call   801b8e <memmove>
}
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	56                   	push   %esi
  801c0d:	53                   	push   %ebx
  801c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c11:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c14:	89 c6                	mov    %eax,%esi
  801c16:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c19:	eb 1a                	jmp    801c35 <memcmp+0x2c>
		if (*s1 != *s2)
  801c1b:	0f b6 08             	movzbl (%eax),%ecx
  801c1e:	0f b6 1a             	movzbl (%edx),%ebx
  801c21:	38 d9                	cmp    %bl,%cl
  801c23:	74 0a                	je     801c2f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c25:	0f b6 c1             	movzbl %cl,%eax
  801c28:	0f b6 db             	movzbl %bl,%ebx
  801c2b:	29 d8                	sub    %ebx,%eax
  801c2d:	eb 0f                	jmp    801c3e <memcmp+0x35>
		s1++, s2++;
  801c2f:	83 c0 01             	add    $0x1,%eax
  801c32:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c35:	39 f0                	cmp    %esi,%eax
  801c37:	75 e2                	jne    801c1b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    

00801c42 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	53                   	push   %ebx
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c49:	89 c1                	mov    %eax,%ecx
  801c4b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c4e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c52:	eb 0a                	jmp    801c5e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c54:	0f b6 10             	movzbl (%eax),%edx
  801c57:	39 da                	cmp    %ebx,%edx
  801c59:	74 07                	je     801c62 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c5b:	83 c0 01             	add    $0x1,%eax
  801c5e:	39 c8                	cmp    %ecx,%eax
  801c60:	72 f2                	jb     801c54 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c62:	5b                   	pop    %ebx
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    

00801c65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	57                   	push   %edi
  801c69:	56                   	push   %esi
  801c6a:	53                   	push   %ebx
  801c6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c71:	eb 03                	jmp    801c76 <strtol+0x11>
		s++;
  801c73:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c76:	0f b6 01             	movzbl (%ecx),%eax
  801c79:	3c 20                	cmp    $0x20,%al
  801c7b:	74 f6                	je     801c73 <strtol+0xe>
  801c7d:	3c 09                	cmp    $0x9,%al
  801c7f:	74 f2                	je     801c73 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c81:	3c 2b                	cmp    $0x2b,%al
  801c83:	75 0a                	jne    801c8f <strtol+0x2a>
		s++;
  801c85:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c88:	bf 00 00 00 00       	mov    $0x0,%edi
  801c8d:	eb 11                	jmp    801ca0 <strtol+0x3b>
  801c8f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c94:	3c 2d                	cmp    $0x2d,%al
  801c96:	75 08                	jne    801ca0 <strtol+0x3b>
		s++, neg = 1;
  801c98:	83 c1 01             	add    $0x1,%ecx
  801c9b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ca0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ca6:	75 15                	jne    801cbd <strtol+0x58>
  801ca8:	80 39 30             	cmpb   $0x30,(%ecx)
  801cab:	75 10                	jne    801cbd <strtol+0x58>
  801cad:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cb1:	75 7c                	jne    801d2f <strtol+0xca>
		s += 2, base = 16;
  801cb3:	83 c1 02             	add    $0x2,%ecx
  801cb6:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cbb:	eb 16                	jmp    801cd3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cbd:	85 db                	test   %ebx,%ebx
  801cbf:	75 12                	jne    801cd3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cc1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cc6:	80 39 30             	cmpb   $0x30,(%ecx)
  801cc9:	75 08                	jne    801cd3 <strtol+0x6e>
		s++, base = 8;
  801ccb:	83 c1 01             	add    $0x1,%ecx
  801cce:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cdb:	0f b6 11             	movzbl (%ecx),%edx
  801cde:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ce1:	89 f3                	mov    %esi,%ebx
  801ce3:	80 fb 09             	cmp    $0x9,%bl
  801ce6:	77 08                	ja     801cf0 <strtol+0x8b>
			dig = *s - '0';
  801ce8:	0f be d2             	movsbl %dl,%edx
  801ceb:	83 ea 30             	sub    $0x30,%edx
  801cee:	eb 22                	jmp    801d12 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801cf0:	8d 72 9f             	lea    -0x61(%edx),%esi
  801cf3:	89 f3                	mov    %esi,%ebx
  801cf5:	80 fb 19             	cmp    $0x19,%bl
  801cf8:	77 08                	ja     801d02 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801cfa:	0f be d2             	movsbl %dl,%edx
  801cfd:	83 ea 57             	sub    $0x57,%edx
  801d00:	eb 10                	jmp    801d12 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d02:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d05:	89 f3                	mov    %esi,%ebx
  801d07:	80 fb 19             	cmp    $0x19,%bl
  801d0a:	77 16                	ja     801d22 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d0c:	0f be d2             	movsbl %dl,%edx
  801d0f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d12:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d15:	7d 0b                	jge    801d22 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d17:	83 c1 01             	add    $0x1,%ecx
  801d1a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d1e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d20:	eb b9                	jmp    801cdb <strtol+0x76>

	if (endptr)
  801d22:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d26:	74 0d                	je     801d35 <strtol+0xd0>
		*endptr = (char *) s;
  801d28:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d2b:	89 0e                	mov    %ecx,(%esi)
  801d2d:	eb 06                	jmp    801d35 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d2f:	85 db                	test   %ebx,%ebx
  801d31:	74 98                	je     801ccb <strtol+0x66>
  801d33:	eb 9e                	jmp    801cd3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d35:	89 c2                	mov    %eax,%edx
  801d37:	f7 da                	neg    %edx
  801d39:	85 ff                	test   %edi,%edi
  801d3b:	0f 45 c2             	cmovne %edx,%eax
}
  801d3e:	5b                   	pop    %ebx
  801d3f:	5e                   	pop    %esi
  801d40:	5f                   	pop    %edi
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d49:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d50:	75 2a                	jne    801d7c <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d52:	83 ec 04             	sub    $0x4,%esp
  801d55:	6a 07                	push   $0x7
  801d57:	68 00 f0 bf ee       	push   $0xeebff000
  801d5c:	6a 00                	push   $0x0
  801d5e:	e8 23 e4 ff ff       	call   800186 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	85 c0                	test   %eax,%eax
  801d68:	79 12                	jns    801d7c <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d6a:	50                   	push   %eax
  801d6b:	68 80 26 80 00       	push   $0x802680
  801d70:	6a 23                	push   $0x23
  801d72:	68 84 26 80 00       	push   $0x802684
  801d77:	e8 22 f6 ff ff       	call   80139e <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7f:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d84:	83 ec 08             	sub    $0x8,%esp
  801d87:	68 ae 1d 80 00       	push   $0x801dae
  801d8c:	6a 00                	push   $0x0
  801d8e:	e8 3e e5 ff ff       	call   8002d1 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	85 c0                	test   %eax,%eax
  801d98:	79 12                	jns    801dac <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d9a:	50                   	push   %eax
  801d9b:	68 80 26 80 00       	push   $0x802680
  801da0:	6a 2c                	push   $0x2c
  801da2:	68 84 26 80 00       	push   $0x802684
  801da7:	e8 f2 f5 ff ff       	call   80139e <_panic>
	}
}
  801dac:	c9                   	leave  
  801dad:	c3                   	ret    

00801dae <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dae:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801daf:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801db4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801db6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801db9:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dbd:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dc2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dc6:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dc8:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dcb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dcc:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dcf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dd0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dd1:	c3                   	ret    

00801dd2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	56                   	push   %esi
  801dd6:	53                   	push   %ebx
  801dd7:	8b 75 08             	mov    0x8(%ebp),%esi
  801dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801de0:	85 c0                	test   %eax,%eax
  801de2:	75 12                	jne    801df6 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801de4:	83 ec 0c             	sub    $0xc,%esp
  801de7:	68 00 00 c0 ee       	push   $0xeec00000
  801dec:	e8 45 e5 ff ff       	call   800336 <sys_ipc_recv>
  801df1:	83 c4 10             	add    $0x10,%esp
  801df4:	eb 0c                	jmp    801e02 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801df6:	83 ec 0c             	sub    $0xc,%esp
  801df9:	50                   	push   %eax
  801dfa:	e8 37 e5 ff ff       	call   800336 <sys_ipc_recv>
  801dff:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e02:	85 f6                	test   %esi,%esi
  801e04:	0f 95 c1             	setne  %cl
  801e07:	85 db                	test   %ebx,%ebx
  801e09:	0f 95 c2             	setne  %dl
  801e0c:	84 d1                	test   %dl,%cl
  801e0e:	74 09                	je     801e19 <ipc_recv+0x47>
  801e10:	89 c2                	mov    %eax,%edx
  801e12:	c1 ea 1f             	shr    $0x1f,%edx
  801e15:	84 d2                	test   %dl,%dl
  801e17:	75 2d                	jne    801e46 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e19:	85 f6                	test   %esi,%esi
  801e1b:	74 0d                	je     801e2a <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e1d:	a1 04 40 80 00       	mov    0x804004,%eax
  801e22:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e28:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e2a:	85 db                	test   %ebx,%ebx
  801e2c:	74 0d                	je     801e3b <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e2e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e33:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e39:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e3b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e40:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e49:	5b                   	pop    %ebx
  801e4a:	5e                   	pop    %esi
  801e4b:	5d                   	pop    %ebp
  801e4c:	c3                   	ret    

00801e4d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	57                   	push   %edi
  801e51:	56                   	push   %esi
  801e52:	53                   	push   %ebx
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e59:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e5f:	85 db                	test   %ebx,%ebx
  801e61:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e66:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e69:	ff 75 14             	pushl  0x14(%ebp)
  801e6c:	53                   	push   %ebx
  801e6d:	56                   	push   %esi
  801e6e:	57                   	push   %edi
  801e6f:	e8 9f e4 ff ff       	call   800313 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e74:	89 c2                	mov    %eax,%edx
  801e76:	c1 ea 1f             	shr    $0x1f,%edx
  801e79:	83 c4 10             	add    $0x10,%esp
  801e7c:	84 d2                	test   %dl,%dl
  801e7e:	74 17                	je     801e97 <ipc_send+0x4a>
  801e80:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e83:	74 12                	je     801e97 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e85:	50                   	push   %eax
  801e86:	68 92 26 80 00       	push   $0x802692
  801e8b:	6a 47                	push   $0x47
  801e8d:	68 a0 26 80 00       	push   $0x8026a0
  801e92:	e8 07 f5 ff ff       	call   80139e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e97:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e9a:	75 07                	jne    801ea3 <ipc_send+0x56>
			sys_yield();
  801e9c:	e8 c6 e2 ff ff       	call   800167 <sys_yield>
  801ea1:	eb c6                	jmp    801e69 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	75 c2                	jne    801e69 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ea7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eaa:	5b                   	pop    %ebx
  801eab:	5e                   	pop    %esi
  801eac:	5f                   	pop    %edi
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    

00801eaf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eb5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eba:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ec0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ec6:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ecc:	39 ca                	cmp    %ecx,%edx
  801ece:	75 10                	jne    801ee0 <ipc_find_env+0x31>
			return envs[i].env_id;
  801ed0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801ed6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801edb:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ede:	eb 0f                	jmp    801eef <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee0:	83 c0 01             	add    $0x1,%eax
  801ee3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee8:	75 d0                	jne    801eba <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801eea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eef:	5d                   	pop    %ebp
  801ef0:	c3                   	ret    

00801ef1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef7:	89 d0                	mov    %edx,%eax
  801ef9:	c1 e8 16             	shr    $0x16,%eax
  801efc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f03:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f08:	f6 c1 01             	test   $0x1,%cl
  801f0b:	74 1d                	je     801f2a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f0d:	c1 ea 0c             	shr    $0xc,%edx
  801f10:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f17:	f6 c2 01             	test   $0x1,%dl
  801f1a:	74 0e                	je     801f2a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f1c:	c1 ea 0c             	shr    $0xc,%edx
  801f1f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f26:	ef 
  801f27:	0f b7 c0             	movzwl %ax,%eax
}
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    
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
