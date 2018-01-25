
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
  80004d:	e8 f2 00 00 00       	call   800144 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	89 c2                	mov    %eax,%edx
  800059:	c1 e2 07             	shl    $0x7,%edx
  80005c:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800063:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800068:	85 db                	test   %ebx,%ebx
  80006a:	7e 07                	jle    800073 <libmain+0x31>
		binaryname = argv[0];
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800073:	83 ec 08             	sub    $0x8,%esp
  800076:	56                   	push   %esi
  800077:	53                   	push   %ebx
  800078:	e8 b6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007d:	e8 2a 00 00 00       	call   8000ac <exit>
}
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800088:	5b                   	pop    %ebx
  800089:	5e                   	pop    %esi
  80008a:	5d                   	pop    %ebp
  80008b:	c3                   	ret    

0080008c <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800092:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800097:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800099:	e8 a6 00 00 00       	call   800144 <sys_getenvid>
  80009e:	83 ec 0c             	sub    $0xc,%esp
  8000a1:	50                   	push   %eax
  8000a2:	e8 ec 02 00 00       	call   800393 <sys_thread_free>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b2:	e8 b9 07 00 00       	call   800870 <close_all>
	sys_env_destroy(0);
  8000b7:	83 ec 0c             	sub    $0xc,%esp
  8000ba:	6a 00                	push   $0x0
  8000bc:	e8 42 00 00 00       	call   800103 <sys_env_destroy>
}
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    

008000c6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	89 c3                	mov    %eax,%ebx
  8000d9:	89 c7                	mov    %eax,%edi
  8000db:	89 c6                	mov    %eax,%esi
  8000dd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ef:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f4:	89 d1                	mov    %edx,%ecx
  8000f6:	89 d3                	mov    %edx,%ebx
  8000f8:	89 d7                	mov    %edx,%edi
  8000fa:	89 d6                	mov    %edx,%esi
  8000fc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fe:	5b                   	pop    %ebx
  8000ff:	5e                   	pop    %esi
  800100:	5f                   	pop    %edi
  800101:	5d                   	pop    %ebp
  800102:	c3                   	ret    

00800103 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	57                   	push   %edi
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
  800109:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800111:	b8 03 00 00 00       	mov    $0x3,%eax
  800116:	8b 55 08             	mov    0x8(%ebp),%edx
  800119:	89 cb                	mov    %ecx,%ebx
  80011b:	89 cf                	mov    %ecx,%edi
  80011d:	89 ce                	mov    %ecx,%esi
  80011f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800121:	85 c0                	test   %eax,%eax
  800123:	7e 17                	jle    80013c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	50                   	push   %eax
  800129:	6a 03                	push   $0x3
  80012b:	68 ca 21 80 00       	push   $0x8021ca
  800130:	6a 23                	push   $0x23
  800132:	68 e7 21 80 00       	push   $0x8021e7
  800137:	e8 53 12 00 00       	call   80138f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 02 00 00 00       	mov    $0x2,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_yield>:

void
sys_yield(void)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800169:	ba 00 00 00 00       	mov    $0x0,%edx
  80016e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800173:	89 d1                	mov    %edx,%ecx
  800175:	89 d3                	mov    %edx,%ebx
  800177:	89 d7                	mov    %edx,%edi
  800179:	89 d6                	mov    %edx,%esi
  80017b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    

00800182 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	57                   	push   %edi
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
  800188:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018b:	be 00 00 00 00       	mov    $0x0,%esi
  800190:	b8 04 00 00 00       	mov    $0x4,%eax
  800195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800198:	8b 55 08             	mov    0x8(%ebp),%edx
  80019b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019e:	89 f7                	mov    %esi,%edi
  8001a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a2:	85 c0                	test   %eax,%eax
  8001a4:	7e 17                	jle    8001bd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	50                   	push   %eax
  8001aa:	6a 04                	push   $0x4
  8001ac:	68 ca 21 80 00       	push   $0x8021ca
  8001b1:	6a 23                	push   $0x23
  8001b3:	68 e7 21 80 00       	push   $0x8021e7
  8001b8:	e8 d2 11 00 00       	call   80138f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c0:	5b                   	pop    %ebx
  8001c1:	5e                   	pop    %esi
  8001c2:	5f                   	pop    %edi
  8001c3:	5d                   	pop    %ebp
  8001c4:	c3                   	ret    

008001c5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001dc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001df:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e4:	85 c0                	test   %eax,%eax
  8001e6:	7e 17                	jle    8001ff <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e8:	83 ec 0c             	sub    $0xc,%esp
  8001eb:	50                   	push   %eax
  8001ec:	6a 05                	push   $0x5
  8001ee:	68 ca 21 80 00       	push   $0x8021ca
  8001f3:	6a 23                	push   $0x23
  8001f5:	68 e7 21 80 00       	push   $0x8021e7
  8001fa:	e8 90 11 00 00       	call   80138f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800202:	5b                   	pop    %ebx
  800203:	5e                   	pop    %esi
  800204:	5f                   	pop    %edi
  800205:	5d                   	pop    %ebp
  800206:	c3                   	ret    

00800207 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	57                   	push   %edi
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800210:	bb 00 00 00 00       	mov    $0x0,%ebx
  800215:	b8 06 00 00 00       	mov    $0x6,%eax
  80021a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021d:	8b 55 08             	mov    0x8(%ebp),%edx
  800220:	89 df                	mov    %ebx,%edi
  800222:	89 de                	mov    %ebx,%esi
  800224:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	7e 17                	jle    800241 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	50                   	push   %eax
  80022e:	6a 06                	push   $0x6
  800230:	68 ca 21 80 00       	push   $0x8021ca
  800235:	6a 23                	push   $0x23
  800237:	68 e7 21 80 00       	push   $0x8021e7
  80023c:	e8 4e 11 00 00       	call   80138f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800244:	5b                   	pop    %ebx
  800245:	5e                   	pop    %esi
  800246:	5f                   	pop    %edi
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    

00800249 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	57                   	push   %edi
  80024d:	56                   	push   %esi
  80024e:	53                   	push   %ebx
  80024f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800252:	bb 00 00 00 00       	mov    $0x0,%ebx
  800257:	b8 08 00 00 00       	mov    $0x8,%eax
  80025c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025f:	8b 55 08             	mov    0x8(%ebp),%edx
  800262:	89 df                	mov    %ebx,%edi
  800264:	89 de                	mov    %ebx,%esi
  800266:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800268:	85 c0                	test   %eax,%eax
  80026a:	7e 17                	jle    800283 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	50                   	push   %eax
  800270:	6a 08                	push   $0x8
  800272:	68 ca 21 80 00       	push   $0x8021ca
  800277:	6a 23                	push   $0x23
  800279:	68 e7 21 80 00       	push   $0x8021e7
  80027e:	e8 0c 11 00 00       	call   80138f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	b8 09 00 00 00       	mov    $0x9,%eax
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	89 df                	mov    %ebx,%edi
  8002a6:	89 de                	mov    %ebx,%esi
  8002a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7e 17                	jle    8002c5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ae:	83 ec 0c             	sub    $0xc,%esp
  8002b1:	50                   	push   %eax
  8002b2:	6a 09                	push   $0x9
  8002b4:	68 ca 21 80 00       	push   $0x8021ca
  8002b9:	6a 23                	push   $0x23
  8002bb:	68 e7 21 80 00       	push   $0x8021e7
  8002c0:	e8 ca 10 00 00       	call   80138f <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	89 df                	mov    %ebx,%edi
  8002e8:	89 de                	mov    %ebx,%esi
  8002ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	7e 17                	jle    800307 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	50                   	push   %eax
  8002f4:	6a 0a                	push   $0xa
  8002f6:	68 ca 21 80 00       	push   $0x8021ca
  8002fb:	6a 23                	push   $0x23
  8002fd:	68 e7 21 80 00       	push   $0x8021e7
  800302:	e8 88 10 00 00       	call   80138f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800307:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800315:	be 00 00 00 00       	mov    $0x0,%esi
  80031a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800322:	8b 55 08             	mov    0x8(%ebp),%edx
  800325:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800328:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800340:	b8 0d 00 00 00       	mov    $0xd,%eax
  800345:	8b 55 08             	mov    0x8(%ebp),%edx
  800348:	89 cb                	mov    %ecx,%ebx
  80034a:	89 cf                	mov    %ecx,%edi
  80034c:	89 ce                	mov    %ecx,%esi
  80034e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 17                	jle    80036b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800354:	83 ec 0c             	sub    $0xc,%esp
  800357:	50                   	push   %eax
  800358:	6a 0d                	push   $0xd
  80035a:	68 ca 21 80 00       	push   $0x8021ca
  80035f:	6a 23                	push   $0x23
  800361:	68 e7 21 80 00       	push   $0x8021e7
  800366:	e8 24 10 00 00       	call   80138f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	57                   	push   %edi
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800383:	8b 55 08             	mov    0x8(%ebp),%edx
  800386:	89 cb                	mov    %ecx,%ebx
  800388:	89 cf                	mov    %ecx,%edi
  80038a:	89 ce                	mov    %ecx,%esi
  80038c:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	57                   	push   %edi
  800397:	56                   	push   %esi
  800398:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800399:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039e:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a6:	89 cb                	mov    %ecx,%ebx
  8003a8:	89 cf                	mov    %ecx,%edi
  8003aa:	89 ce                	mov    %ecx,%esi
  8003ac:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003ae:	5b                   	pop    %ebx
  8003af:	5e                   	pop    %esi
  8003b0:	5f                   	pop    %edi
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	53                   	push   %ebx
  8003b7:	83 ec 04             	sub    $0x4,%esp
  8003ba:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003bd:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003bf:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003c3:	74 11                	je     8003d6 <pgfault+0x23>
  8003c5:	89 d8                	mov    %ebx,%eax
  8003c7:	c1 e8 0c             	shr    $0xc,%eax
  8003ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003d1:	f6 c4 08             	test   $0x8,%ah
  8003d4:	75 14                	jne    8003ea <pgfault+0x37>
		panic("faulting access");
  8003d6:	83 ec 04             	sub    $0x4,%esp
  8003d9:	68 f5 21 80 00       	push   $0x8021f5
  8003de:	6a 1e                	push   $0x1e
  8003e0:	68 05 22 80 00       	push   $0x802205
  8003e5:	e8 a5 0f 00 00       	call   80138f <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003ea:	83 ec 04             	sub    $0x4,%esp
  8003ed:	6a 07                	push   $0x7
  8003ef:	68 00 f0 7f 00       	push   $0x7ff000
  8003f4:	6a 00                	push   $0x0
  8003f6:	e8 87 fd ff ff       	call   800182 <sys_page_alloc>
	if (r < 0) {
  8003fb:	83 c4 10             	add    $0x10,%esp
  8003fe:	85 c0                	test   %eax,%eax
  800400:	79 12                	jns    800414 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800402:	50                   	push   %eax
  800403:	68 10 22 80 00       	push   $0x802210
  800408:	6a 2c                	push   $0x2c
  80040a:	68 05 22 80 00       	push   $0x802205
  80040f:	e8 7b 0f 00 00       	call   80138f <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800414:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80041a:	83 ec 04             	sub    $0x4,%esp
  80041d:	68 00 10 00 00       	push   $0x1000
  800422:	53                   	push   %ebx
  800423:	68 00 f0 7f 00       	push   $0x7ff000
  800428:	e8 ba 17 00 00       	call   801be7 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80042d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800434:	53                   	push   %ebx
  800435:	6a 00                	push   $0x0
  800437:	68 00 f0 7f 00       	push   $0x7ff000
  80043c:	6a 00                	push   $0x0
  80043e:	e8 82 fd ff ff       	call   8001c5 <sys_page_map>
	if (r < 0) {
  800443:	83 c4 20             	add    $0x20,%esp
  800446:	85 c0                	test   %eax,%eax
  800448:	79 12                	jns    80045c <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80044a:	50                   	push   %eax
  80044b:	68 10 22 80 00       	push   $0x802210
  800450:	6a 33                	push   $0x33
  800452:	68 05 22 80 00       	push   $0x802205
  800457:	e8 33 0f 00 00       	call   80138f <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80045c:	83 ec 08             	sub    $0x8,%esp
  80045f:	68 00 f0 7f 00       	push   $0x7ff000
  800464:	6a 00                	push   $0x0
  800466:	e8 9c fd ff ff       	call   800207 <sys_page_unmap>
	if (r < 0) {
  80046b:	83 c4 10             	add    $0x10,%esp
  80046e:	85 c0                	test   %eax,%eax
  800470:	79 12                	jns    800484 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800472:	50                   	push   %eax
  800473:	68 10 22 80 00       	push   $0x802210
  800478:	6a 37                	push   $0x37
  80047a:	68 05 22 80 00       	push   $0x802205
  80047f:	e8 0b 0f 00 00       	call   80138f <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800484:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800487:	c9                   	leave  
  800488:	c3                   	ret    

00800489 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	57                   	push   %edi
  80048d:	56                   	push   %esi
  80048e:	53                   	push   %ebx
  80048f:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800492:	68 b3 03 80 00       	push   $0x8003b3
  800497:	e8 98 18 00 00       	call   801d34 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80049c:	b8 07 00 00 00       	mov    $0x7,%eax
  8004a1:	cd 30                	int    $0x30
  8004a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	85 c0                	test   %eax,%eax
  8004ab:	79 17                	jns    8004c4 <fork+0x3b>
		panic("fork fault %e");
  8004ad:	83 ec 04             	sub    $0x4,%esp
  8004b0:	68 29 22 80 00       	push   $0x802229
  8004b5:	68 84 00 00 00       	push   $0x84
  8004ba:	68 05 22 80 00       	push   $0x802205
  8004bf:	e8 cb 0e 00 00       	call   80138f <_panic>
  8004c4:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ca:	75 25                	jne    8004f1 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004cc:	e8 73 fc ff ff       	call   800144 <sys_getenvid>
  8004d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d6:	89 c2                	mov    %eax,%edx
  8004d8:	c1 e2 07             	shl    $0x7,%edx
  8004db:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8004e2:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	e9 61 01 00 00       	jmp    800652 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004f1:	83 ec 04             	sub    $0x4,%esp
  8004f4:	6a 07                	push   $0x7
  8004f6:	68 00 f0 bf ee       	push   $0xeebff000
  8004fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004fe:	e8 7f fc ff ff       	call   800182 <sys_page_alloc>
  800503:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800506:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80050b:	89 d8                	mov    %ebx,%eax
  80050d:	c1 e8 16             	shr    $0x16,%eax
  800510:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800517:	a8 01                	test   $0x1,%al
  800519:	0f 84 fc 00 00 00    	je     80061b <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80051f:	89 d8                	mov    %ebx,%eax
  800521:	c1 e8 0c             	shr    $0xc,%eax
  800524:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80052b:	f6 c2 01             	test   $0x1,%dl
  80052e:	0f 84 e7 00 00 00    	je     80061b <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800534:	89 c6                	mov    %eax,%esi
  800536:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800539:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800540:	f6 c6 04             	test   $0x4,%dh
  800543:	74 39                	je     80057e <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800545:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80054c:	83 ec 0c             	sub    $0xc,%esp
  80054f:	25 07 0e 00 00       	and    $0xe07,%eax
  800554:	50                   	push   %eax
  800555:	56                   	push   %esi
  800556:	57                   	push   %edi
  800557:	56                   	push   %esi
  800558:	6a 00                	push   $0x0
  80055a:	e8 66 fc ff ff       	call   8001c5 <sys_page_map>
		if (r < 0) {
  80055f:	83 c4 20             	add    $0x20,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 89 b1 00 00 00    	jns    80061b <fork+0x192>
		    	panic("sys page map fault %e");
  80056a:	83 ec 04             	sub    $0x4,%esp
  80056d:	68 37 22 80 00       	push   $0x802237
  800572:	6a 54                	push   $0x54
  800574:	68 05 22 80 00       	push   $0x802205
  800579:	e8 11 0e 00 00       	call   80138f <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80057e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800585:	f6 c2 02             	test   $0x2,%dl
  800588:	75 0c                	jne    800596 <fork+0x10d>
  80058a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800591:	f6 c4 08             	test   $0x8,%ah
  800594:	74 5b                	je     8005f1 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800596:	83 ec 0c             	sub    $0xc,%esp
  800599:	68 05 08 00 00       	push   $0x805
  80059e:	56                   	push   %esi
  80059f:	57                   	push   %edi
  8005a0:	56                   	push   %esi
  8005a1:	6a 00                	push   $0x0
  8005a3:	e8 1d fc ff ff       	call   8001c5 <sys_page_map>
		if (r < 0) {
  8005a8:	83 c4 20             	add    $0x20,%esp
  8005ab:	85 c0                	test   %eax,%eax
  8005ad:	79 14                	jns    8005c3 <fork+0x13a>
		    	panic("sys page map fault %e");
  8005af:	83 ec 04             	sub    $0x4,%esp
  8005b2:	68 37 22 80 00       	push   $0x802237
  8005b7:	6a 5b                	push   $0x5b
  8005b9:	68 05 22 80 00       	push   $0x802205
  8005be:	e8 cc 0d 00 00       	call   80138f <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005c3:	83 ec 0c             	sub    $0xc,%esp
  8005c6:	68 05 08 00 00       	push   $0x805
  8005cb:	56                   	push   %esi
  8005cc:	6a 00                	push   $0x0
  8005ce:	56                   	push   %esi
  8005cf:	6a 00                	push   $0x0
  8005d1:	e8 ef fb ff ff       	call   8001c5 <sys_page_map>
		if (r < 0) {
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	79 3e                	jns    80061b <fork+0x192>
		    	panic("sys page map fault %e");
  8005dd:	83 ec 04             	sub    $0x4,%esp
  8005e0:	68 37 22 80 00       	push   $0x802237
  8005e5:	6a 5f                	push   $0x5f
  8005e7:	68 05 22 80 00       	push   $0x802205
  8005ec:	e8 9e 0d 00 00       	call   80138f <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	6a 05                	push   $0x5
  8005f6:	56                   	push   %esi
  8005f7:	57                   	push   %edi
  8005f8:	56                   	push   %esi
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 c5 fb ff ff       	call   8001c5 <sys_page_map>
		if (r < 0) {
  800600:	83 c4 20             	add    $0x20,%esp
  800603:	85 c0                	test   %eax,%eax
  800605:	79 14                	jns    80061b <fork+0x192>
		    	panic("sys page map fault %e");
  800607:	83 ec 04             	sub    $0x4,%esp
  80060a:	68 37 22 80 00       	push   $0x802237
  80060f:	6a 64                	push   $0x64
  800611:	68 05 22 80 00       	push   $0x802205
  800616:	e8 74 0d 00 00       	call   80138f <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80061b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800621:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800627:	0f 85 de fe ff ff    	jne    80050b <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80062d:	a1 04 40 80 00       	mov    0x804004,%eax
  800632:	8b 40 70             	mov    0x70(%eax),%eax
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	50                   	push   %eax
  800639:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063c:	57                   	push   %edi
  80063d:	e8 8b fc ff ff       	call   8002cd <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800642:	83 c4 08             	add    $0x8,%esp
  800645:	6a 02                	push   $0x2
  800647:	57                   	push   %edi
  800648:	e8 fc fb ff ff       	call   800249 <sys_env_set_status>
	
	return envid;
  80064d:	83 c4 10             	add    $0x10,%esp
  800650:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800652:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800655:	5b                   	pop    %ebx
  800656:	5e                   	pop    %esi
  800657:	5f                   	pop    %edi
  800658:	5d                   	pop    %ebp
  800659:	c3                   	ret    

0080065a <sfork>:

envid_t
sfork(void)
{
  80065a:	55                   	push   %ebp
  80065b:	89 e5                	mov    %esp,%ebp
	return 0;
}
  80065d:	b8 00 00 00 00       	mov    $0x0,%eax
  800662:	5d                   	pop    %ebp
  800663:	c3                   	ret    

00800664 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800664:	55                   	push   %ebp
  800665:	89 e5                	mov    %esp,%ebp
  800667:	56                   	push   %esi
  800668:	53                   	push   %ebx
  800669:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80066c:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	68 50 22 80 00       	push   $0x802250
  80067b:	e8 e8 0d 00 00       	call   801468 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800680:	c7 04 24 8c 00 80 00 	movl   $0x80008c,(%esp)
  800687:	e8 e7 fc ff ff       	call   800373 <sys_thread_create>
  80068c:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80068e:	83 c4 08             	add    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	68 50 22 80 00       	push   $0x802250
  800697:	e8 cc 0d 00 00       	call   801468 <cprintf>
	return id;
	//return 0;
}
  80069c:	89 f0                	mov    %esi,%eax
  80069e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006a1:	5b                   	pop    %ebx
  8006a2:	5e                   	pop    %esi
  8006a3:	5d                   	pop    %ebp
  8006a4:	c3                   	ret    

008006a5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ab:	05 00 00 00 30       	add    $0x30000000,%eax
  8006b0:	c1 e8 0c             	shr    $0xc,%eax
}
  8006b3:	5d                   	pop    %ebp
  8006b4:	c3                   	ret    

008006b5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	05 00 00 00 30       	add    $0x30000000,%eax
  8006c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006c5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006d7:	89 c2                	mov    %eax,%edx
  8006d9:	c1 ea 16             	shr    $0x16,%edx
  8006dc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006e3:	f6 c2 01             	test   $0x1,%dl
  8006e6:	74 11                	je     8006f9 <fd_alloc+0x2d>
  8006e8:	89 c2                	mov    %eax,%edx
  8006ea:	c1 ea 0c             	shr    $0xc,%edx
  8006ed:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006f4:	f6 c2 01             	test   $0x1,%dl
  8006f7:	75 09                	jne    800702 <fd_alloc+0x36>
			*fd_store = fd;
  8006f9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 17                	jmp    800719 <fd_alloc+0x4d>
  800702:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800707:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80070c:	75 c9                	jne    8006d7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80070e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800714:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800721:	83 f8 1f             	cmp    $0x1f,%eax
  800724:	77 36                	ja     80075c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800726:	c1 e0 0c             	shl    $0xc,%eax
  800729:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80072e:	89 c2                	mov    %eax,%edx
  800730:	c1 ea 16             	shr    $0x16,%edx
  800733:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80073a:	f6 c2 01             	test   $0x1,%dl
  80073d:	74 24                	je     800763 <fd_lookup+0x48>
  80073f:	89 c2                	mov    %eax,%edx
  800741:	c1 ea 0c             	shr    $0xc,%edx
  800744:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80074b:	f6 c2 01             	test   $0x1,%dl
  80074e:	74 1a                	je     80076a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800750:	8b 55 0c             	mov    0xc(%ebp),%edx
  800753:	89 02                	mov    %eax,(%edx)
	return 0;
  800755:	b8 00 00 00 00       	mov    $0x0,%eax
  80075a:	eb 13                	jmp    80076f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800761:	eb 0c                	jmp    80076f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800763:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800768:	eb 05                	jmp    80076f <fd_lookup+0x54>
  80076a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077a:	ba f0 22 80 00       	mov    $0x8022f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80077f:	eb 13                	jmp    800794 <dev_lookup+0x23>
  800781:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800784:	39 08                	cmp    %ecx,(%eax)
  800786:	75 0c                	jne    800794 <dev_lookup+0x23>
			*dev = devtab[i];
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	eb 2e                	jmp    8007c2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800794:	8b 02                	mov    (%edx),%eax
  800796:	85 c0                	test   %eax,%eax
  800798:	75 e7                	jne    800781 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80079a:	a1 04 40 80 00       	mov    0x804004,%eax
  80079f:	8b 40 54             	mov    0x54(%eax),%eax
  8007a2:	83 ec 04             	sub    $0x4,%esp
  8007a5:	51                   	push   %ecx
  8007a6:	50                   	push   %eax
  8007a7:	68 74 22 80 00       	push   $0x802274
  8007ac:	e8 b7 0c 00 00       	call   801468 <cprintf>
	*dev = 0;
  8007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	56                   	push   %esi
  8007c8:	53                   	push   %ebx
  8007c9:	83 ec 10             	sub    $0x10,%esp
  8007cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007dc:	c1 e8 0c             	shr    $0xc,%eax
  8007df:	50                   	push   %eax
  8007e0:	e8 36 ff ff ff       	call   80071b <fd_lookup>
  8007e5:	83 c4 08             	add    $0x8,%esp
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	78 05                	js     8007f1 <fd_close+0x2d>
	    || fd != fd2)
  8007ec:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007ef:	74 0c                	je     8007fd <fd_close+0x39>
		return (must_exist ? r : 0);
  8007f1:	84 db                	test   %bl,%bl
  8007f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f8:	0f 44 c2             	cmove  %edx,%eax
  8007fb:	eb 41                	jmp    80083e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800803:	50                   	push   %eax
  800804:	ff 36                	pushl  (%esi)
  800806:	e8 66 ff ff ff       	call   800771 <dev_lookup>
  80080b:	89 c3                	mov    %eax,%ebx
  80080d:	83 c4 10             	add    $0x10,%esp
  800810:	85 c0                	test   %eax,%eax
  800812:	78 1a                	js     80082e <fd_close+0x6a>
		if (dev->dev_close)
  800814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800817:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80081a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80081f:	85 c0                	test   %eax,%eax
  800821:	74 0b                	je     80082e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800823:	83 ec 0c             	sub    $0xc,%esp
  800826:	56                   	push   %esi
  800827:	ff d0                	call   *%eax
  800829:	89 c3                	mov    %eax,%ebx
  80082b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	56                   	push   %esi
  800832:	6a 00                	push   $0x0
  800834:	e8 ce f9 ff ff       	call   800207 <sys_page_unmap>
	return r;
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	89 d8                	mov    %ebx,%eax
}
  80083e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800841:	5b                   	pop    %ebx
  800842:	5e                   	pop    %esi
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80084b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084e:	50                   	push   %eax
  80084f:	ff 75 08             	pushl  0x8(%ebp)
  800852:	e8 c4 fe ff ff       	call   80071b <fd_lookup>
  800857:	83 c4 08             	add    $0x8,%esp
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 10                	js     80086e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	6a 01                	push   $0x1
  800863:	ff 75 f4             	pushl  -0xc(%ebp)
  800866:	e8 59 ff ff ff       	call   8007c4 <fd_close>
  80086b:	83 c4 10             	add    $0x10,%esp
}
  80086e:	c9                   	leave  
  80086f:	c3                   	ret    

00800870 <close_all>:

void
close_all(void)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	53                   	push   %ebx
  800874:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800877:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80087c:	83 ec 0c             	sub    $0xc,%esp
  80087f:	53                   	push   %ebx
  800880:	e8 c0 ff ff ff       	call   800845 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800885:	83 c3 01             	add    $0x1,%ebx
  800888:	83 c4 10             	add    $0x10,%esp
  80088b:	83 fb 20             	cmp    $0x20,%ebx
  80088e:	75 ec                	jne    80087c <close_all+0xc>
		close(i);
}
  800890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	57                   	push   %edi
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	83 ec 2c             	sub    $0x2c,%esp
  80089e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008a4:	50                   	push   %eax
  8008a5:	ff 75 08             	pushl  0x8(%ebp)
  8008a8:	e8 6e fe ff ff       	call   80071b <fd_lookup>
  8008ad:	83 c4 08             	add    $0x8,%esp
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	0f 88 c1 00 00 00    	js     800979 <dup+0xe4>
		return r;
	close(newfdnum);
  8008b8:	83 ec 0c             	sub    $0xc,%esp
  8008bb:	56                   	push   %esi
  8008bc:	e8 84 ff ff ff       	call   800845 <close>

	newfd = INDEX2FD(newfdnum);
  8008c1:	89 f3                	mov    %esi,%ebx
  8008c3:	c1 e3 0c             	shl    $0xc,%ebx
  8008c6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008cc:	83 c4 04             	add    $0x4,%esp
  8008cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008d2:	e8 de fd ff ff       	call   8006b5 <fd2data>
  8008d7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008d9:	89 1c 24             	mov    %ebx,(%esp)
  8008dc:	e8 d4 fd ff ff       	call   8006b5 <fd2data>
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008e7:	89 f8                	mov    %edi,%eax
  8008e9:	c1 e8 16             	shr    $0x16,%eax
  8008ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008f3:	a8 01                	test   $0x1,%al
  8008f5:	74 37                	je     80092e <dup+0x99>
  8008f7:	89 f8                	mov    %edi,%eax
  8008f9:	c1 e8 0c             	shr    $0xc,%eax
  8008fc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800903:	f6 c2 01             	test   $0x1,%dl
  800906:	74 26                	je     80092e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800908:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80090f:	83 ec 0c             	sub    $0xc,%esp
  800912:	25 07 0e 00 00       	and    $0xe07,%eax
  800917:	50                   	push   %eax
  800918:	ff 75 d4             	pushl  -0x2c(%ebp)
  80091b:	6a 00                	push   $0x0
  80091d:	57                   	push   %edi
  80091e:	6a 00                	push   $0x0
  800920:	e8 a0 f8 ff ff       	call   8001c5 <sys_page_map>
  800925:	89 c7                	mov    %eax,%edi
  800927:	83 c4 20             	add    $0x20,%esp
  80092a:	85 c0                	test   %eax,%eax
  80092c:	78 2e                	js     80095c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80092e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800931:	89 d0                	mov    %edx,%eax
  800933:	c1 e8 0c             	shr    $0xc,%eax
  800936:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80093d:	83 ec 0c             	sub    $0xc,%esp
  800940:	25 07 0e 00 00       	and    $0xe07,%eax
  800945:	50                   	push   %eax
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	52                   	push   %edx
  80094a:	6a 00                	push   $0x0
  80094c:	e8 74 f8 ff ff       	call   8001c5 <sys_page_map>
  800951:	89 c7                	mov    %eax,%edi
  800953:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800956:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800958:	85 ff                	test   %edi,%edi
  80095a:	79 1d                	jns    800979 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80095c:	83 ec 08             	sub    $0x8,%esp
  80095f:	53                   	push   %ebx
  800960:	6a 00                	push   $0x0
  800962:	e8 a0 f8 ff ff       	call   800207 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800967:	83 c4 08             	add    $0x8,%esp
  80096a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80096d:	6a 00                	push   $0x0
  80096f:	e8 93 f8 ff ff       	call   800207 <sys_page_unmap>
	return r;
  800974:	83 c4 10             	add    $0x10,%esp
  800977:	89 f8                	mov    %edi,%eax
}
  800979:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	53                   	push   %ebx
  800985:	83 ec 14             	sub    $0x14,%esp
  800988:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80098b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80098e:	50                   	push   %eax
  80098f:	53                   	push   %ebx
  800990:	e8 86 fd ff ff       	call   80071b <fd_lookup>
  800995:	83 c4 08             	add    $0x8,%esp
  800998:	89 c2                	mov    %eax,%edx
  80099a:	85 c0                	test   %eax,%eax
  80099c:	78 6d                	js     800a0b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a4:	50                   	push   %eax
  8009a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a8:	ff 30                	pushl  (%eax)
  8009aa:	e8 c2 fd ff ff       	call   800771 <dev_lookup>
  8009af:	83 c4 10             	add    $0x10,%esp
  8009b2:	85 c0                	test   %eax,%eax
  8009b4:	78 4c                	js     800a02 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009b9:	8b 42 08             	mov    0x8(%edx),%eax
  8009bc:	83 e0 03             	and    $0x3,%eax
  8009bf:	83 f8 01             	cmp    $0x1,%eax
  8009c2:	75 21                	jne    8009e5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c9:	8b 40 54             	mov    0x54(%eax),%eax
  8009cc:	83 ec 04             	sub    $0x4,%esp
  8009cf:	53                   	push   %ebx
  8009d0:	50                   	push   %eax
  8009d1:	68 b5 22 80 00       	push   $0x8022b5
  8009d6:	e8 8d 0a 00 00       	call   801468 <cprintf>
		return -E_INVAL;
  8009db:	83 c4 10             	add    $0x10,%esp
  8009de:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009e3:	eb 26                	jmp    800a0b <read+0x8a>
	}
	if (!dev->dev_read)
  8009e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e8:	8b 40 08             	mov    0x8(%eax),%eax
  8009eb:	85 c0                	test   %eax,%eax
  8009ed:	74 17                	je     800a06 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009ef:	83 ec 04             	sub    $0x4,%esp
  8009f2:	ff 75 10             	pushl  0x10(%ebp)
  8009f5:	ff 75 0c             	pushl  0xc(%ebp)
  8009f8:	52                   	push   %edx
  8009f9:	ff d0                	call   *%eax
  8009fb:	89 c2                	mov    %eax,%edx
  8009fd:	83 c4 10             	add    $0x10,%esp
  800a00:	eb 09                	jmp    800a0b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a02:	89 c2                	mov    %eax,%edx
  800a04:	eb 05                	jmp    800a0b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a06:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a0b:	89 d0                	mov    %edx,%eax
  800a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	57                   	push   %edi
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	83 ec 0c             	sub    $0xc,%esp
  800a1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a26:	eb 21                	jmp    800a49 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a28:	83 ec 04             	sub    $0x4,%esp
  800a2b:	89 f0                	mov    %esi,%eax
  800a2d:	29 d8                	sub    %ebx,%eax
  800a2f:	50                   	push   %eax
  800a30:	89 d8                	mov    %ebx,%eax
  800a32:	03 45 0c             	add    0xc(%ebp),%eax
  800a35:	50                   	push   %eax
  800a36:	57                   	push   %edi
  800a37:	e8 45 ff ff ff       	call   800981 <read>
		if (m < 0)
  800a3c:	83 c4 10             	add    $0x10,%esp
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	78 10                	js     800a53 <readn+0x41>
			return m;
		if (m == 0)
  800a43:	85 c0                	test   %eax,%eax
  800a45:	74 0a                	je     800a51 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a47:	01 c3                	add    %eax,%ebx
  800a49:	39 f3                	cmp    %esi,%ebx
  800a4b:	72 db                	jb     800a28 <readn+0x16>
  800a4d:	89 d8                	mov    %ebx,%eax
  800a4f:	eb 02                	jmp    800a53 <readn+0x41>
  800a51:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 14             	sub    $0x14,%esp
  800a62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a65:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a68:	50                   	push   %eax
  800a69:	53                   	push   %ebx
  800a6a:	e8 ac fc ff ff       	call   80071b <fd_lookup>
  800a6f:	83 c4 08             	add    $0x8,%esp
  800a72:	89 c2                	mov    %eax,%edx
  800a74:	85 c0                	test   %eax,%eax
  800a76:	78 68                	js     800ae0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a78:	83 ec 08             	sub    $0x8,%esp
  800a7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a7e:	50                   	push   %eax
  800a7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a82:	ff 30                	pushl  (%eax)
  800a84:	e8 e8 fc ff ff       	call   800771 <dev_lookup>
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	78 47                	js     800ad7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a93:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a97:	75 21                	jne    800aba <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a99:	a1 04 40 80 00       	mov    0x804004,%eax
  800a9e:	8b 40 54             	mov    0x54(%eax),%eax
  800aa1:	83 ec 04             	sub    $0x4,%esp
  800aa4:	53                   	push   %ebx
  800aa5:	50                   	push   %eax
  800aa6:	68 d1 22 80 00       	push   $0x8022d1
  800aab:	e8 b8 09 00 00       	call   801468 <cprintf>
		return -E_INVAL;
  800ab0:	83 c4 10             	add    $0x10,%esp
  800ab3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ab8:	eb 26                	jmp    800ae0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800aba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800abd:	8b 52 0c             	mov    0xc(%edx),%edx
  800ac0:	85 d2                	test   %edx,%edx
  800ac2:	74 17                	je     800adb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ac4:	83 ec 04             	sub    $0x4,%esp
  800ac7:	ff 75 10             	pushl  0x10(%ebp)
  800aca:	ff 75 0c             	pushl  0xc(%ebp)
  800acd:	50                   	push   %eax
  800ace:	ff d2                	call   *%edx
  800ad0:	89 c2                	mov    %eax,%edx
  800ad2:	83 c4 10             	add    $0x10,%esp
  800ad5:	eb 09                	jmp    800ae0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ad7:	89 c2                	mov    %eax,%edx
  800ad9:	eb 05                	jmp    800ae0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800adb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ae0:	89 d0                	mov    %edx,%eax
  800ae2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <seek>:

int
seek(int fdnum, off_t offset)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800aed:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800af0:	50                   	push   %eax
  800af1:	ff 75 08             	pushl  0x8(%ebp)
  800af4:	e8 22 fc ff ff       	call   80071b <fd_lookup>
  800af9:	83 c4 08             	add    $0x8,%esp
  800afc:	85 c0                	test   %eax,%eax
  800afe:	78 0e                	js     800b0e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b00:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b06:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0e:	c9                   	leave  
  800b0f:	c3                   	ret    

00800b10 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	53                   	push   %ebx
  800b14:	83 ec 14             	sub    $0x14,%esp
  800b17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b1d:	50                   	push   %eax
  800b1e:	53                   	push   %ebx
  800b1f:	e8 f7 fb ff ff       	call   80071b <fd_lookup>
  800b24:	83 c4 08             	add    $0x8,%esp
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	78 65                	js     800b92 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b2d:	83 ec 08             	sub    $0x8,%esp
  800b30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b33:	50                   	push   %eax
  800b34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b37:	ff 30                	pushl  (%eax)
  800b39:	e8 33 fc ff ff       	call   800771 <dev_lookup>
  800b3e:	83 c4 10             	add    $0x10,%esp
  800b41:	85 c0                	test   %eax,%eax
  800b43:	78 44                	js     800b89 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b48:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b4c:	75 21                	jne    800b6f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b4e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b53:	8b 40 54             	mov    0x54(%eax),%eax
  800b56:	83 ec 04             	sub    $0x4,%esp
  800b59:	53                   	push   %ebx
  800b5a:	50                   	push   %eax
  800b5b:	68 94 22 80 00       	push   $0x802294
  800b60:	e8 03 09 00 00       	call   801468 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b65:	83 c4 10             	add    $0x10,%esp
  800b68:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b6d:	eb 23                	jmp    800b92 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b72:	8b 52 18             	mov    0x18(%edx),%edx
  800b75:	85 d2                	test   %edx,%edx
  800b77:	74 14                	je     800b8d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b79:	83 ec 08             	sub    $0x8,%esp
  800b7c:	ff 75 0c             	pushl  0xc(%ebp)
  800b7f:	50                   	push   %eax
  800b80:	ff d2                	call   *%edx
  800b82:	89 c2                	mov    %eax,%edx
  800b84:	83 c4 10             	add    $0x10,%esp
  800b87:	eb 09                	jmp    800b92 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b89:	89 c2                	mov    %eax,%edx
  800b8b:	eb 05                	jmp    800b92 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b8d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b92:	89 d0                	mov    %edx,%eax
  800b94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	53                   	push   %ebx
  800b9d:	83 ec 14             	sub    $0x14,%esp
  800ba0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ba3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ba6:	50                   	push   %eax
  800ba7:	ff 75 08             	pushl  0x8(%ebp)
  800baa:	e8 6c fb ff ff       	call   80071b <fd_lookup>
  800baf:	83 c4 08             	add    $0x8,%esp
  800bb2:	89 c2                	mov    %eax,%edx
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	78 58                	js     800c10 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bb8:	83 ec 08             	sub    $0x8,%esp
  800bbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bbe:	50                   	push   %eax
  800bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc2:	ff 30                	pushl  (%eax)
  800bc4:	e8 a8 fb ff ff       	call   800771 <dev_lookup>
  800bc9:	83 c4 10             	add    $0x10,%esp
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	78 37                	js     800c07 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bd3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bd7:	74 32                	je     800c0b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bd9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800bdc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800be3:	00 00 00 
	stat->st_isdir = 0;
  800be6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bed:	00 00 00 
	stat->st_dev = dev;
  800bf0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bf6:	83 ec 08             	sub    $0x8,%esp
  800bf9:	53                   	push   %ebx
  800bfa:	ff 75 f0             	pushl  -0x10(%ebp)
  800bfd:	ff 50 14             	call   *0x14(%eax)
  800c00:	89 c2                	mov    %eax,%edx
  800c02:	83 c4 10             	add    $0x10,%esp
  800c05:	eb 09                	jmp    800c10 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c07:	89 c2                	mov    %eax,%edx
  800c09:	eb 05                	jmp    800c10 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c0b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c10:	89 d0                	mov    %edx,%eax
  800c12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c1c:	83 ec 08             	sub    $0x8,%esp
  800c1f:	6a 00                	push   $0x0
  800c21:	ff 75 08             	pushl  0x8(%ebp)
  800c24:	e8 e3 01 00 00       	call   800e0c <open>
  800c29:	89 c3                	mov    %eax,%ebx
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	78 1b                	js     800c4d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c32:	83 ec 08             	sub    $0x8,%esp
  800c35:	ff 75 0c             	pushl  0xc(%ebp)
  800c38:	50                   	push   %eax
  800c39:	e8 5b ff ff ff       	call   800b99 <fstat>
  800c3e:	89 c6                	mov    %eax,%esi
	close(fd);
  800c40:	89 1c 24             	mov    %ebx,(%esp)
  800c43:	e8 fd fb ff ff       	call   800845 <close>
	return r;
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	89 f0                	mov    %esi,%eax
}
  800c4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	89 c6                	mov    %eax,%esi
  800c5b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c5d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c64:	75 12                	jne    800c78 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	6a 01                	push   $0x1
  800c6b:	e8 2d 12 00 00       	call   801e9d <ipc_find_env>
  800c70:	a3 00 40 80 00       	mov    %eax,0x804000
  800c75:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c78:	6a 07                	push   $0x7
  800c7a:	68 00 50 80 00       	push   $0x805000
  800c7f:	56                   	push   %esi
  800c80:	ff 35 00 40 80 00    	pushl  0x804000
  800c86:	e8 b0 11 00 00       	call   801e3b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c8b:	83 c4 0c             	add    $0xc,%esp
  800c8e:	6a 00                	push   $0x0
  800c90:	53                   	push   %ebx
  800c91:	6a 00                	push   $0x0
  800c93:	e8 2b 11 00 00       	call   801dc3 <ipc_recv>
}
  800c98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca8:	8b 40 0c             	mov    0xc(%eax),%eax
  800cab:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbd:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc2:	e8 8d ff ff ff       	call   800c54 <fsipc>
}
  800cc7:	c9                   	leave  
  800cc8:	c3                   	ret    

00800cc9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	8b 40 0c             	mov    0xc(%eax),%eax
  800cd5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce4:	e8 6b ff ff ff       	call   800c54 <fsipc>
}
  800ce9:	c9                   	leave  
  800cea:	c3                   	ret    

00800ceb <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	53                   	push   %ebx
  800cef:	83 ec 04             	sub    $0x4,%esp
  800cf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	8b 40 0c             	mov    0xc(%eax),%eax
  800cfb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d00:	ba 00 00 00 00       	mov    $0x0,%edx
  800d05:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0a:	e8 45 ff ff ff       	call   800c54 <fsipc>
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	78 2c                	js     800d3f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d13:	83 ec 08             	sub    $0x8,%esp
  800d16:	68 00 50 80 00       	push   $0x805000
  800d1b:	53                   	push   %ebx
  800d1c:	e8 cc 0c 00 00       	call   8019ed <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d21:	a1 80 50 80 00       	mov    0x805080,%eax
  800d26:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d2c:	a1 84 50 80 00       	mov    0x805084,%eax
  800d31:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d37:	83 c4 10             	add    $0x10,%esp
  800d3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	8b 52 0c             	mov    0xc(%edx),%edx
  800d53:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d59:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d5e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d63:	0f 47 c2             	cmova  %edx,%eax
  800d66:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d6b:	50                   	push   %eax
  800d6c:	ff 75 0c             	pushl  0xc(%ebp)
  800d6f:	68 08 50 80 00       	push   $0x805008
  800d74:	e8 06 0e 00 00       	call   801b7f <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d79:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7e:	b8 04 00 00 00       	mov    $0x4,%eax
  800d83:	e8 cc fe ff ff       	call   800c54 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d88:	c9                   	leave  
  800d89:	c3                   	ret    

00800d8a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	8b 40 0c             	mov    0xc(%eax),%eax
  800d98:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800d9d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800da3:	ba 00 00 00 00       	mov    $0x0,%edx
  800da8:	b8 03 00 00 00       	mov    $0x3,%eax
  800dad:	e8 a2 fe ff ff       	call   800c54 <fsipc>
  800db2:	89 c3                	mov    %eax,%ebx
  800db4:	85 c0                	test   %eax,%eax
  800db6:	78 4b                	js     800e03 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800db8:	39 c6                	cmp    %eax,%esi
  800dba:	73 16                	jae    800dd2 <devfile_read+0x48>
  800dbc:	68 00 23 80 00       	push   $0x802300
  800dc1:	68 07 23 80 00       	push   $0x802307
  800dc6:	6a 7c                	push   $0x7c
  800dc8:	68 1c 23 80 00       	push   $0x80231c
  800dcd:	e8 bd 05 00 00       	call   80138f <_panic>
	assert(r <= PGSIZE);
  800dd2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800dd7:	7e 16                	jle    800def <devfile_read+0x65>
  800dd9:	68 27 23 80 00       	push   $0x802327
  800dde:	68 07 23 80 00       	push   $0x802307
  800de3:	6a 7d                	push   $0x7d
  800de5:	68 1c 23 80 00       	push   $0x80231c
  800dea:	e8 a0 05 00 00       	call   80138f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800def:	83 ec 04             	sub    $0x4,%esp
  800df2:	50                   	push   %eax
  800df3:	68 00 50 80 00       	push   $0x805000
  800df8:	ff 75 0c             	pushl  0xc(%ebp)
  800dfb:	e8 7f 0d 00 00       	call   801b7f <memmove>
	return r;
  800e00:	83 c4 10             	add    $0x10,%esp
}
  800e03:	89 d8                	mov    %ebx,%eax
  800e05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5d                   	pop    %ebp
  800e0b:	c3                   	ret    

00800e0c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 20             	sub    $0x20,%esp
  800e13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e16:	53                   	push   %ebx
  800e17:	e8 98 0b 00 00       	call   8019b4 <strlen>
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e24:	7f 67                	jg     800e8d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e2c:	50                   	push   %eax
  800e2d:	e8 9a f8 ff ff       	call   8006cc <fd_alloc>
  800e32:	83 c4 10             	add    $0x10,%esp
		return r;
  800e35:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e37:	85 c0                	test   %eax,%eax
  800e39:	78 57                	js     800e92 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e3b:	83 ec 08             	sub    $0x8,%esp
  800e3e:	53                   	push   %ebx
  800e3f:	68 00 50 80 00       	push   $0x805000
  800e44:	e8 a4 0b 00 00       	call   8019ed <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e54:	b8 01 00 00 00       	mov    $0x1,%eax
  800e59:	e8 f6 fd ff ff       	call   800c54 <fsipc>
  800e5e:	89 c3                	mov    %eax,%ebx
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	85 c0                	test   %eax,%eax
  800e65:	79 14                	jns    800e7b <open+0x6f>
		fd_close(fd, 0);
  800e67:	83 ec 08             	sub    $0x8,%esp
  800e6a:	6a 00                	push   $0x0
  800e6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6f:	e8 50 f9 ff ff       	call   8007c4 <fd_close>
		return r;
  800e74:	83 c4 10             	add    $0x10,%esp
  800e77:	89 da                	mov    %ebx,%edx
  800e79:	eb 17                	jmp    800e92 <open+0x86>
	}

	return fd2num(fd);
  800e7b:	83 ec 0c             	sub    $0xc,%esp
  800e7e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e81:	e8 1f f8 ff ff       	call   8006a5 <fd2num>
  800e86:	89 c2                	mov    %eax,%edx
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	eb 05                	jmp    800e92 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e8d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e92:	89 d0                	mov    %edx,%eax
  800e94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e97:	c9                   	leave  
  800e98:	c3                   	ret    

00800e99 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800e9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea9:	e8 a6 fd ff ff       	call   800c54 <fsipc>
}
  800eae:	c9                   	leave  
  800eaf:	c3                   	ret    

00800eb0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
  800eb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	ff 75 08             	pushl  0x8(%ebp)
  800ebe:	e8 f2 f7 ff ff       	call   8006b5 <fd2data>
  800ec3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ec5:	83 c4 08             	add    $0x8,%esp
  800ec8:	68 33 23 80 00       	push   $0x802333
  800ecd:	53                   	push   %ebx
  800ece:	e8 1a 0b 00 00       	call   8019ed <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ed3:	8b 46 04             	mov    0x4(%esi),%eax
  800ed6:	2b 06                	sub    (%esi),%eax
  800ed8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ede:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ee5:	00 00 00 
	stat->st_dev = &devpipe;
  800ee8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800eef:	30 80 00 
	return 0;
}
  800ef2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	53                   	push   %ebx
  800f02:	83 ec 0c             	sub    $0xc,%esp
  800f05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f08:	53                   	push   %ebx
  800f09:	6a 00                	push   $0x0
  800f0b:	e8 f7 f2 ff ff       	call   800207 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f10:	89 1c 24             	mov    %ebx,(%esp)
  800f13:	e8 9d f7 ff ff       	call   8006b5 <fd2data>
  800f18:	83 c4 08             	add    $0x8,%esp
  800f1b:	50                   	push   %eax
  800f1c:	6a 00                	push   $0x0
  800f1e:	e8 e4 f2 ff ff       	call   800207 <sys_page_unmap>
}
  800f23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f26:	c9                   	leave  
  800f27:	c3                   	ret    

00800f28 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 1c             	sub    $0x1c,%esp
  800f31:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f34:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f36:	a1 04 40 80 00       	mov    0x804004,%eax
  800f3b:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	ff 75 e0             	pushl  -0x20(%ebp)
  800f44:	e8 94 0f 00 00       	call   801edd <pageref>
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	89 3c 24             	mov    %edi,(%esp)
  800f4e:	e8 8a 0f 00 00       	call   801edd <pageref>
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	39 c3                	cmp    %eax,%ebx
  800f58:	0f 94 c1             	sete   %cl
  800f5b:	0f b6 c9             	movzbl %cl,%ecx
  800f5e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f61:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f67:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  800f6a:	39 ce                	cmp    %ecx,%esi
  800f6c:	74 1b                	je     800f89 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800f6e:	39 c3                	cmp    %eax,%ebx
  800f70:	75 c4                	jne    800f36 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f72:	8b 42 64             	mov    0x64(%edx),%eax
  800f75:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f78:	50                   	push   %eax
  800f79:	56                   	push   %esi
  800f7a:	68 3a 23 80 00       	push   $0x80233a
  800f7f:	e8 e4 04 00 00       	call   801468 <cprintf>
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	eb ad                	jmp    800f36 <_pipeisclosed+0xe>
	}
}
  800f89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	57                   	push   %edi
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 28             	sub    $0x28,%esp
  800f9d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fa0:	56                   	push   %esi
  800fa1:	e8 0f f7 ff ff       	call   8006b5 <fd2data>
  800fa6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb0:	eb 4b                	jmp    800ffd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fb2:	89 da                	mov    %ebx,%edx
  800fb4:	89 f0                	mov    %esi,%eax
  800fb6:	e8 6d ff ff ff       	call   800f28 <_pipeisclosed>
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	75 48                	jne    801007 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fbf:	e8 9f f1 ff ff       	call   800163 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fc4:	8b 43 04             	mov    0x4(%ebx),%eax
  800fc7:	8b 0b                	mov    (%ebx),%ecx
  800fc9:	8d 51 20             	lea    0x20(%ecx),%edx
  800fcc:	39 d0                	cmp    %edx,%eax
  800fce:	73 e2                	jae    800fb2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fd7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fda:	89 c2                	mov    %eax,%edx
  800fdc:	c1 fa 1f             	sar    $0x1f,%edx
  800fdf:	89 d1                	mov    %edx,%ecx
  800fe1:	c1 e9 1b             	shr    $0x1b,%ecx
  800fe4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800fe7:	83 e2 1f             	and    $0x1f,%edx
  800fea:	29 ca                	sub    %ecx,%edx
  800fec:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ff0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ff4:	83 c0 01             	add    $0x1,%eax
  800ff7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ffa:	83 c7 01             	add    $0x1,%edi
  800ffd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801000:	75 c2                	jne    800fc4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801002:	8b 45 10             	mov    0x10(%ebp),%eax
  801005:	eb 05                	jmp    80100c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801007:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80100c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100f:	5b                   	pop    %ebx
  801010:	5e                   	pop    %esi
  801011:	5f                   	pop    %edi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	57                   	push   %edi
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
  80101a:	83 ec 18             	sub    $0x18,%esp
  80101d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801020:	57                   	push   %edi
  801021:	e8 8f f6 ff ff       	call   8006b5 <fd2data>
  801026:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801030:	eb 3d                	jmp    80106f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801032:	85 db                	test   %ebx,%ebx
  801034:	74 04                	je     80103a <devpipe_read+0x26>
				return i;
  801036:	89 d8                	mov    %ebx,%eax
  801038:	eb 44                	jmp    80107e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80103a:	89 f2                	mov    %esi,%edx
  80103c:	89 f8                	mov    %edi,%eax
  80103e:	e8 e5 fe ff ff       	call   800f28 <_pipeisclosed>
  801043:	85 c0                	test   %eax,%eax
  801045:	75 32                	jne    801079 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801047:	e8 17 f1 ff ff       	call   800163 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80104c:	8b 06                	mov    (%esi),%eax
  80104e:	3b 46 04             	cmp    0x4(%esi),%eax
  801051:	74 df                	je     801032 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801053:	99                   	cltd   
  801054:	c1 ea 1b             	shr    $0x1b,%edx
  801057:	01 d0                	add    %edx,%eax
  801059:	83 e0 1f             	and    $0x1f,%eax
  80105c:	29 d0                	sub    %edx,%eax
  80105e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801063:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801066:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801069:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80106c:	83 c3 01             	add    $0x1,%ebx
  80106f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801072:	75 d8                	jne    80104c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801074:	8b 45 10             	mov    0x10(%ebp),%eax
  801077:	eb 05                	jmp    80107e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801079:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80107e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801081:	5b                   	pop    %ebx
  801082:	5e                   	pop    %esi
  801083:	5f                   	pop    %edi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
  80108b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80108e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801091:	50                   	push   %eax
  801092:	e8 35 f6 ff ff       	call   8006cc <fd_alloc>
  801097:	83 c4 10             	add    $0x10,%esp
  80109a:	89 c2                	mov    %eax,%edx
  80109c:	85 c0                	test   %eax,%eax
  80109e:	0f 88 2c 01 00 00    	js     8011d0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010a4:	83 ec 04             	sub    $0x4,%esp
  8010a7:	68 07 04 00 00       	push   $0x407
  8010ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8010af:	6a 00                	push   $0x0
  8010b1:	e8 cc f0 ff ff       	call   800182 <sys_page_alloc>
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	89 c2                	mov    %eax,%edx
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	0f 88 0d 01 00 00    	js     8011d0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	e8 fd f5 ff ff       	call   8006cc <fd_alloc>
  8010cf:	89 c3                	mov    %eax,%ebx
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	0f 88 e2 00 00 00    	js     8011be <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010dc:	83 ec 04             	sub    $0x4,%esp
  8010df:	68 07 04 00 00       	push   $0x407
  8010e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8010e7:	6a 00                	push   $0x0
  8010e9:	e8 94 f0 ff ff       	call   800182 <sys_page_alloc>
  8010ee:	89 c3                	mov    %eax,%ebx
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	0f 88 c3 00 00 00    	js     8011be <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801101:	e8 af f5 ff ff       	call   8006b5 <fd2data>
  801106:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801108:	83 c4 0c             	add    $0xc,%esp
  80110b:	68 07 04 00 00       	push   $0x407
  801110:	50                   	push   %eax
  801111:	6a 00                	push   $0x0
  801113:	e8 6a f0 ff ff       	call   800182 <sys_page_alloc>
  801118:	89 c3                	mov    %eax,%ebx
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	0f 88 89 00 00 00    	js     8011ae <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801125:	83 ec 0c             	sub    $0xc,%esp
  801128:	ff 75 f0             	pushl  -0x10(%ebp)
  80112b:	e8 85 f5 ff ff       	call   8006b5 <fd2data>
  801130:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801137:	50                   	push   %eax
  801138:	6a 00                	push   $0x0
  80113a:	56                   	push   %esi
  80113b:	6a 00                	push   $0x0
  80113d:	e8 83 f0 ff ff       	call   8001c5 <sys_page_map>
  801142:	89 c3                	mov    %eax,%ebx
  801144:	83 c4 20             	add    $0x20,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	78 55                	js     8011a0 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80114b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801151:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801154:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801156:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801159:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801160:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801166:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801169:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80116b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801175:	83 ec 0c             	sub    $0xc,%esp
  801178:	ff 75 f4             	pushl  -0xc(%ebp)
  80117b:	e8 25 f5 ff ff       	call   8006a5 <fd2num>
  801180:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801183:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801185:	83 c4 04             	add    $0x4,%esp
  801188:	ff 75 f0             	pushl  -0x10(%ebp)
  80118b:	e8 15 f5 ff ff       	call   8006a5 <fd2num>
  801190:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801193:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	ba 00 00 00 00       	mov    $0x0,%edx
  80119e:	eb 30                	jmp    8011d0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	56                   	push   %esi
  8011a4:	6a 00                	push   $0x0
  8011a6:	e8 5c f0 ff ff       	call   800207 <sys_page_unmap>
  8011ab:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8011b4:	6a 00                	push   $0x0
  8011b6:	e8 4c f0 ff ff       	call   800207 <sys_page_unmap>
  8011bb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011be:	83 ec 08             	sub    $0x8,%esp
  8011c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8011c4:	6a 00                	push   $0x0
  8011c6:	e8 3c f0 ff ff       	call   800207 <sys_page_unmap>
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011d0:	89 d0                	mov    %edx,%eax
  8011d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	ff 75 08             	pushl  0x8(%ebp)
  8011e6:	e8 30 f5 ff ff       	call   80071b <fd_lookup>
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 18                	js     80120a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011f2:	83 ec 0c             	sub    $0xc,%esp
  8011f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f8:	e8 b8 f4 ff ff       	call   8006b5 <fd2data>
	return _pipeisclosed(fd, p);
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801202:	e8 21 fd ff ff       	call   800f28 <_pipeisclosed>
  801207:	83 c4 10             	add    $0x10,%esp
}
  80120a:	c9                   	leave  
  80120b:	c3                   	ret    

0080120c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80120f:	b8 00 00 00 00       	mov    $0x0,%eax
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80121c:	68 52 23 80 00       	push   $0x802352
  801221:	ff 75 0c             	pushl  0xc(%ebp)
  801224:	e8 c4 07 00 00       	call   8019ed <strcpy>
	return 0;
}
  801229:	b8 00 00 00 00       	mov    $0x0,%eax
  80122e:	c9                   	leave  
  80122f:	c3                   	ret    

00801230 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80123c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801241:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801247:	eb 2d                	jmp    801276 <devcons_write+0x46>
		m = n - tot;
  801249:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80124c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80124e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801251:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801256:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801259:	83 ec 04             	sub    $0x4,%esp
  80125c:	53                   	push   %ebx
  80125d:	03 45 0c             	add    0xc(%ebp),%eax
  801260:	50                   	push   %eax
  801261:	57                   	push   %edi
  801262:	e8 18 09 00 00       	call   801b7f <memmove>
		sys_cputs(buf, m);
  801267:	83 c4 08             	add    $0x8,%esp
  80126a:	53                   	push   %ebx
  80126b:	57                   	push   %edi
  80126c:	e8 55 ee ff ff       	call   8000c6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801271:	01 de                	add    %ebx,%esi
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	89 f0                	mov    %esi,%eax
  801278:	3b 75 10             	cmp    0x10(%ebp),%esi
  80127b:	72 cc                	jb     801249 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80127d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801280:	5b                   	pop    %ebx
  801281:	5e                   	pop    %esi
  801282:	5f                   	pop    %edi
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    

00801285 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801290:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801294:	74 2a                	je     8012c0 <devcons_read+0x3b>
  801296:	eb 05                	jmp    80129d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801298:	e8 c6 ee ff ff       	call   800163 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80129d:	e8 42 ee ff ff       	call   8000e4 <sys_cgetc>
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	74 f2                	je     801298 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 16                	js     8012c0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012aa:	83 f8 04             	cmp    $0x4,%eax
  8012ad:	74 0c                	je     8012bb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b2:	88 02                	mov    %al,(%edx)
	return 1;
  8012b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b9:	eb 05                	jmp    8012c0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012bb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012ce:	6a 01                	push   $0x1
  8012d0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012d3:	50                   	push   %eax
  8012d4:	e8 ed ed ff ff       	call   8000c6 <sys_cputs>
}
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <getchar>:

int
getchar(void)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012e4:	6a 01                	push   $0x1
  8012e6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012e9:	50                   	push   %eax
  8012ea:	6a 00                	push   $0x0
  8012ec:	e8 90 f6 ff ff       	call   800981 <read>
	if (r < 0)
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 0f                	js     801307 <getchar+0x29>
		return r;
	if (r < 1)
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	7e 06                	jle    801302 <getchar+0x24>
		return -E_EOF;
	return c;
  8012fc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801300:	eb 05                	jmp    801307 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801302:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801307:	c9                   	leave  
  801308:	c3                   	ret    

00801309 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80130f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801312:	50                   	push   %eax
  801313:	ff 75 08             	pushl  0x8(%ebp)
  801316:	e8 00 f4 ff ff       	call   80071b <fd_lookup>
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 11                	js     801333 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801322:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801325:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80132b:	39 10                	cmp    %edx,(%eax)
  80132d:	0f 94 c0             	sete   %al
  801330:	0f b6 c0             	movzbl %al,%eax
}
  801333:	c9                   	leave  
  801334:	c3                   	ret    

00801335 <opencons>:

int
opencons(void)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80133b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	e8 88 f3 ff ff       	call   8006cc <fd_alloc>
  801344:	83 c4 10             	add    $0x10,%esp
		return r;
  801347:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801349:	85 c0                	test   %eax,%eax
  80134b:	78 3e                	js     80138b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80134d:	83 ec 04             	sub    $0x4,%esp
  801350:	68 07 04 00 00       	push   $0x407
  801355:	ff 75 f4             	pushl  -0xc(%ebp)
  801358:	6a 00                	push   $0x0
  80135a:	e8 23 ee ff ff       	call   800182 <sys_page_alloc>
  80135f:	83 c4 10             	add    $0x10,%esp
		return r;
  801362:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801364:	85 c0                	test   %eax,%eax
  801366:	78 23                	js     80138b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801368:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80136e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801371:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801373:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801376:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80137d:	83 ec 0c             	sub    $0xc,%esp
  801380:	50                   	push   %eax
  801381:	e8 1f f3 ff ff       	call   8006a5 <fd2num>
  801386:	89 c2                	mov    %eax,%edx
  801388:	83 c4 10             	add    $0x10,%esp
}
  80138b:	89 d0                	mov    %edx,%eax
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801394:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801397:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80139d:	e8 a2 ed ff ff       	call   800144 <sys_getenvid>
  8013a2:	83 ec 0c             	sub    $0xc,%esp
  8013a5:	ff 75 0c             	pushl  0xc(%ebp)
  8013a8:	ff 75 08             	pushl  0x8(%ebp)
  8013ab:	56                   	push   %esi
  8013ac:	50                   	push   %eax
  8013ad:	68 60 23 80 00       	push   $0x802360
  8013b2:	e8 b1 00 00 00       	call   801468 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013b7:	83 c4 18             	add    $0x18,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	ff 75 10             	pushl  0x10(%ebp)
  8013be:	e8 54 00 00 00       	call   801417 <vcprintf>
	cprintf("\n");
  8013c3:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  8013ca:	e8 99 00 00 00       	call   801468 <cprintf>
  8013cf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013d2:	cc                   	int3   
  8013d3:	eb fd                	jmp    8013d2 <_panic+0x43>

008013d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	53                   	push   %ebx
  8013d9:	83 ec 04             	sub    $0x4,%esp
  8013dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013df:	8b 13                	mov    (%ebx),%edx
  8013e1:	8d 42 01             	lea    0x1(%edx),%eax
  8013e4:	89 03                	mov    %eax,(%ebx)
  8013e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013f2:	75 1a                	jne    80140e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	68 ff 00 00 00       	push   $0xff
  8013fc:	8d 43 08             	lea    0x8(%ebx),%eax
  8013ff:	50                   	push   %eax
  801400:	e8 c1 ec ff ff       	call   8000c6 <sys_cputs>
		b->idx = 0;
  801405:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80140b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80140e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801412:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801420:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801427:	00 00 00 
	b.cnt = 0;
  80142a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801431:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801434:	ff 75 0c             	pushl  0xc(%ebp)
  801437:	ff 75 08             	pushl  0x8(%ebp)
  80143a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	68 d5 13 80 00       	push   $0x8013d5
  801446:	e8 54 01 00 00       	call   80159f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80144b:	83 c4 08             	add    $0x8,%esp
  80144e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801454:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80145a:	50                   	push   %eax
  80145b:	e8 66 ec ff ff       	call   8000c6 <sys_cputs>

	return b.cnt;
}
  801460:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80146e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801471:	50                   	push   %eax
  801472:	ff 75 08             	pushl  0x8(%ebp)
  801475:	e8 9d ff ff ff       	call   801417 <vcprintf>
	va_end(ap);

	return cnt;
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	57                   	push   %edi
  801480:	56                   	push   %esi
  801481:	53                   	push   %ebx
  801482:	83 ec 1c             	sub    $0x1c,%esp
  801485:	89 c7                	mov    %eax,%edi
  801487:	89 d6                	mov    %edx,%esi
  801489:	8b 45 08             	mov    0x8(%ebp),%eax
  80148c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801492:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801495:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801498:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014a0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014a3:	39 d3                	cmp    %edx,%ebx
  8014a5:	72 05                	jb     8014ac <printnum+0x30>
  8014a7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014aa:	77 45                	ja     8014f1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014ac:	83 ec 0c             	sub    $0xc,%esp
  8014af:	ff 75 18             	pushl  0x18(%ebp)
  8014b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014b8:	53                   	push   %ebx
  8014b9:	ff 75 10             	pushl  0x10(%ebp)
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8014c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8014c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8014cb:	e8 50 0a 00 00       	call   801f20 <__udivdi3>
  8014d0:	83 c4 18             	add    $0x18,%esp
  8014d3:	52                   	push   %edx
  8014d4:	50                   	push   %eax
  8014d5:	89 f2                	mov    %esi,%edx
  8014d7:	89 f8                	mov    %edi,%eax
  8014d9:	e8 9e ff ff ff       	call   80147c <printnum>
  8014de:	83 c4 20             	add    $0x20,%esp
  8014e1:	eb 18                	jmp    8014fb <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014e3:	83 ec 08             	sub    $0x8,%esp
  8014e6:	56                   	push   %esi
  8014e7:	ff 75 18             	pushl  0x18(%ebp)
  8014ea:	ff d7                	call   *%edi
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	eb 03                	jmp    8014f4 <printnum+0x78>
  8014f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014f4:	83 eb 01             	sub    $0x1,%ebx
  8014f7:	85 db                	test   %ebx,%ebx
  8014f9:	7f e8                	jg     8014e3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014fb:	83 ec 08             	sub    $0x8,%esp
  8014fe:	56                   	push   %esi
  8014ff:	83 ec 04             	sub    $0x4,%esp
  801502:	ff 75 e4             	pushl  -0x1c(%ebp)
  801505:	ff 75 e0             	pushl  -0x20(%ebp)
  801508:	ff 75 dc             	pushl  -0x24(%ebp)
  80150b:	ff 75 d8             	pushl  -0x28(%ebp)
  80150e:	e8 3d 0b 00 00       	call   802050 <__umoddi3>
  801513:	83 c4 14             	add    $0x14,%esp
  801516:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  80151d:	50                   	push   %eax
  80151e:	ff d7                	call   *%edi
}
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5f                   	pop    %edi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    

0080152b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80152e:	83 fa 01             	cmp    $0x1,%edx
  801531:	7e 0e                	jle    801541 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801533:	8b 10                	mov    (%eax),%edx
  801535:	8d 4a 08             	lea    0x8(%edx),%ecx
  801538:	89 08                	mov    %ecx,(%eax)
  80153a:	8b 02                	mov    (%edx),%eax
  80153c:	8b 52 04             	mov    0x4(%edx),%edx
  80153f:	eb 22                	jmp    801563 <getuint+0x38>
	else if (lflag)
  801541:	85 d2                	test   %edx,%edx
  801543:	74 10                	je     801555 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801545:	8b 10                	mov    (%eax),%edx
  801547:	8d 4a 04             	lea    0x4(%edx),%ecx
  80154a:	89 08                	mov    %ecx,(%eax)
  80154c:	8b 02                	mov    (%edx),%eax
  80154e:	ba 00 00 00 00       	mov    $0x0,%edx
  801553:	eb 0e                	jmp    801563 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801555:	8b 10                	mov    (%eax),%edx
  801557:	8d 4a 04             	lea    0x4(%edx),%ecx
  80155a:	89 08                	mov    %ecx,(%eax)
  80155c:	8b 02                	mov    (%edx),%eax
  80155e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801563:	5d                   	pop    %ebp
  801564:	c3                   	ret    

00801565 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80156b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80156f:	8b 10                	mov    (%eax),%edx
  801571:	3b 50 04             	cmp    0x4(%eax),%edx
  801574:	73 0a                	jae    801580 <sprintputch+0x1b>
		*b->buf++ = ch;
  801576:	8d 4a 01             	lea    0x1(%edx),%ecx
  801579:	89 08                	mov    %ecx,(%eax)
  80157b:	8b 45 08             	mov    0x8(%ebp),%eax
  80157e:	88 02                	mov    %al,(%edx)
}
  801580:	5d                   	pop    %ebp
  801581:	c3                   	ret    

00801582 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801588:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80158b:	50                   	push   %eax
  80158c:	ff 75 10             	pushl  0x10(%ebp)
  80158f:	ff 75 0c             	pushl  0xc(%ebp)
  801592:	ff 75 08             	pushl  0x8(%ebp)
  801595:	e8 05 00 00 00       	call   80159f <vprintfmt>
	va_end(ap);
}
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    

0080159f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	57                   	push   %edi
  8015a3:	56                   	push   %esi
  8015a4:	53                   	push   %ebx
  8015a5:	83 ec 2c             	sub    $0x2c,%esp
  8015a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015b1:	eb 12                	jmp    8015c5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	0f 84 89 03 00 00    	je     801944 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015bb:	83 ec 08             	sub    $0x8,%esp
  8015be:	53                   	push   %ebx
  8015bf:	50                   	push   %eax
  8015c0:	ff d6                	call   *%esi
  8015c2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015c5:	83 c7 01             	add    $0x1,%edi
  8015c8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015cc:	83 f8 25             	cmp    $0x25,%eax
  8015cf:	75 e2                	jne    8015b3 <vprintfmt+0x14>
  8015d1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015d5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015dc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015e3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ef:	eb 07                	jmp    8015f8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015f4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f8:	8d 47 01             	lea    0x1(%edi),%eax
  8015fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015fe:	0f b6 07             	movzbl (%edi),%eax
  801601:	0f b6 c8             	movzbl %al,%ecx
  801604:	83 e8 23             	sub    $0x23,%eax
  801607:	3c 55                	cmp    $0x55,%al
  801609:	0f 87 1a 03 00 00    	ja     801929 <vprintfmt+0x38a>
  80160f:	0f b6 c0             	movzbl %al,%eax
  801612:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  801619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80161c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801620:	eb d6                	jmp    8015f8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801625:	b8 00 00 00 00       	mov    $0x0,%eax
  80162a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80162d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801630:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801634:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801637:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80163a:	83 fa 09             	cmp    $0x9,%edx
  80163d:	77 39                	ja     801678 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80163f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801642:	eb e9                	jmp    80162d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801644:	8b 45 14             	mov    0x14(%ebp),%eax
  801647:	8d 48 04             	lea    0x4(%eax),%ecx
  80164a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80164d:	8b 00                	mov    (%eax),%eax
  80164f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801655:	eb 27                	jmp    80167e <vprintfmt+0xdf>
  801657:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80165a:	85 c0                	test   %eax,%eax
  80165c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801661:	0f 49 c8             	cmovns %eax,%ecx
  801664:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80166a:	eb 8c                	jmp    8015f8 <vprintfmt+0x59>
  80166c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80166f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801676:	eb 80                	jmp    8015f8 <vprintfmt+0x59>
  801678:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80167b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80167e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801682:	0f 89 70 ff ff ff    	jns    8015f8 <vprintfmt+0x59>
				width = precision, precision = -1;
  801688:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80168b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80168e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801695:	e9 5e ff ff ff       	jmp    8015f8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80169a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80169d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016a0:	e9 53 ff ff ff       	jmp    8015f8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a8:	8d 50 04             	lea    0x4(%eax),%edx
  8016ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	53                   	push   %ebx
  8016b2:	ff 30                	pushl  (%eax)
  8016b4:	ff d6                	call   *%esi
			break;
  8016b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016bc:	e9 04 ff ff ff       	jmp    8015c5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c4:	8d 50 04             	lea    0x4(%eax),%edx
  8016c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ca:	8b 00                	mov    (%eax),%eax
  8016cc:	99                   	cltd   
  8016cd:	31 d0                	xor    %edx,%eax
  8016cf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016d1:	83 f8 0f             	cmp    $0xf,%eax
  8016d4:	7f 0b                	jg     8016e1 <vprintfmt+0x142>
  8016d6:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8016dd:	85 d2                	test   %edx,%edx
  8016df:	75 18                	jne    8016f9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016e1:	50                   	push   %eax
  8016e2:	68 9b 23 80 00       	push   $0x80239b
  8016e7:	53                   	push   %ebx
  8016e8:	56                   	push   %esi
  8016e9:	e8 94 fe ff ff       	call   801582 <printfmt>
  8016ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016f4:	e9 cc fe ff ff       	jmp    8015c5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8016f9:	52                   	push   %edx
  8016fa:	68 19 23 80 00       	push   $0x802319
  8016ff:	53                   	push   %ebx
  801700:	56                   	push   %esi
  801701:	e8 7c fe ff ff       	call   801582 <printfmt>
  801706:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801709:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80170c:	e9 b4 fe ff ff       	jmp    8015c5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801711:	8b 45 14             	mov    0x14(%ebp),%eax
  801714:	8d 50 04             	lea    0x4(%eax),%edx
  801717:	89 55 14             	mov    %edx,0x14(%ebp)
  80171a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80171c:	85 ff                	test   %edi,%edi
  80171e:	b8 94 23 80 00       	mov    $0x802394,%eax
  801723:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801726:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80172a:	0f 8e 94 00 00 00    	jle    8017c4 <vprintfmt+0x225>
  801730:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801734:	0f 84 98 00 00 00    	je     8017d2 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80173a:	83 ec 08             	sub    $0x8,%esp
  80173d:	ff 75 d0             	pushl  -0x30(%ebp)
  801740:	57                   	push   %edi
  801741:	e8 86 02 00 00       	call   8019cc <strnlen>
  801746:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801749:	29 c1                	sub    %eax,%ecx
  80174b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80174e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801751:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801755:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801758:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80175b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80175d:	eb 0f                	jmp    80176e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	53                   	push   %ebx
  801763:	ff 75 e0             	pushl  -0x20(%ebp)
  801766:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801768:	83 ef 01             	sub    $0x1,%edi
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	85 ff                	test   %edi,%edi
  801770:	7f ed                	jg     80175f <vprintfmt+0x1c0>
  801772:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801775:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801778:	85 c9                	test   %ecx,%ecx
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
  80177f:	0f 49 c1             	cmovns %ecx,%eax
  801782:	29 c1                	sub    %eax,%ecx
  801784:	89 75 08             	mov    %esi,0x8(%ebp)
  801787:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80178a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80178d:	89 cb                	mov    %ecx,%ebx
  80178f:	eb 4d                	jmp    8017de <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801791:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801795:	74 1b                	je     8017b2 <vprintfmt+0x213>
  801797:	0f be c0             	movsbl %al,%eax
  80179a:	83 e8 20             	sub    $0x20,%eax
  80179d:	83 f8 5e             	cmp    $0x5e,%eax
  8017a0:	76 10                	jbe    8017b2 <vprintfmt+0x213>
					putch('?', putdat);
  8017a2:	83 ec 08             	sub    $0x8,%esp
  8017a5:	ff 75 0c             	pushl  0xc(%ebp)
  8017a8:	6a 3f                	push   $0x3f
  8017aa:	ff 55 08             	call   *0x8(%ebp)
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	eb 0d                	jmp    8017bf <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	ff 75 0c             	pushl  0xc(%ebp)
  8017b8:	52                   	push   %edx
  8017b9:	ff 55 08             	call   *0x8(%ebp)
  8017bc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017bf:	83 eb 01             	sub    $0x1,%ebx
  8017c2:	eb 1a                	jmp    8017de <vprintfmt+0x23f>
  8017c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8017c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017d0:	eb 0c                	jmp    8017de <vprintfmt+0x23f>
  8017d2:	89 75 08             	mov    %esi,0x8(%ebp)
  8017d5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017de:	83 c7 01             	add    $0x1,%edi
  8017e1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017e5:	0f be d0             	movsbl %al,%edx
  8017e8:	85 d2                	test   %edx,%edx
  8017ea:	74 23                	je     80180f <vprintfmt+0x270>
  8017ec:	85 f6                	test   %esi,%esi
  8017ee:	78 a1                	js     801791 <vprintfmt+0x1f2>
  8017f0:	83 ee 01             	sub    $0x1,%esi
  8017f3:	79 9c                	jns    801791 <vprintfmt+0x1f2>
  8017f5:	89 df                	mov    %ebx,%edi
  8017f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8017fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017fd:	eb 18                	jmp    801817 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8017ff:	83 ec 08             	sub    $0x8,%esp
  801802:	53                   	push   %ebx
  801803:	6a 20                	push   $0x20
  801805:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801807:	83 ef 01             	sub    $0x1,%edi
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	eb 08                	jmp    801817 <vprintfmt+0x278>
  80180f:	89 df                	mov    %ebx,%edi
  801811:	8b 75 08             	mov    0x8(%ebp),%esi
  801814:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801817:	85 ff                	test   %edi,%edi
  801819:	7f e4                	jg     8017ff <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80181e:	e9 a2 fd ff ff       	jmp    8015c5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801823:	83 fa 01             	cmp    $0x1,%edx
  801826:	7e 16                	jle    80183e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801828:	8b 45 14             	mov    0x14(%ebp),%eax
  80182b:	8d 50 08             	lea    0x8(%eax),%edx
  80182e:	89 55 14             	mov    %edx,0x14(%ebp)
  801831:	8b 50 04             	mov    0x4(%eax),%edx
  801834:	8b 00                	mov    (%eax),%eax
  801836:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801839:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80183c:	eb 32                	jmp    801870 <vprintfmt+0x2d1>
	else if (lflag)
  80183e:	85 d2                	test   %edx,%edx
  801840:	74 18                	je     80185a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801842:	8b 45 14             	mov    0x14(%ebp),%eax
  801845:	8d 50 04             	lea    0x4(%eax),%edx
  801848:	89 55 14             	mov    %edx,0x14(%ebp)
  80184b:	8b 00                	mov    (%eax),%eax
  80184d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801850:	89 c1                	mov    %eax,%ecx
  801852:	c1 f9 1f             	sar    $0x1f,%ecx
  801855:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801858:	eb 16                	jmp    801870 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80185a:	8b 45 14             	mov    0x14(%ebp),%eax
  80185d:	8d 50 04             	lea    0x4(%eax),%edx
  801860:	89 55 14             	mov    %edx,0x14(%ebp)
  801863:	8b 00                	mov    (%eax),%eax
  801865:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801868:	89 c1                	mov    %eax,%ecx
  80186a:	c1 f9 1f             	sar    $0x1f,%ecx
  80186d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801870:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801873:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801876:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80187b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80187f:	79 74                	jns    8018f5 <vprintfmt+0x356>
				putch('-', putdat);
  801881:	83 ec 08             	sub    $0x8,%esp
  801884:	53                   	push   %ebx
  801885:	6a 2d                	push   $0x2d
  801887:	ff d6                	call   *%esi
				num = -(long long) num;
  801889:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80188c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80188f:	f7 d8                	neg    %eax
  801891:	83 d2 00             	adc    $0x0,%edx
  801894:	f7 da                	neg    %edx
  801896:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801899:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80189e:	eb 55                	jmp    8018f5 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8018a3:	e8 83 fc ff ff       	call   80152b <getuint>
			base = 10;
  8018a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018ad:	eb 46                	jmp    8018f5 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018af:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b2:	e8 74 fc ff ff       	call   80152b <getuint>
			base = 8;
  8018b7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018bc:	eb 37                	jmp    8018f5 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	53                   	push   %ebx
  8018c2:	6a 30                	push   $0x30
  8018c4:	ff d6                	call   *%esi
			putch('x', putdat);
  8018c6:	83 c4 08             	add    $0x8,%esp
  8018c9:	53                   	push   %ebx
  8018ca:	6a 78                	push   $0x78
  8018cc:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d1:	8d 50 04             	lea    0x4(%eax),%edx
  8018d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018d7:	8b 00                	mov    (%eax),%eax
  8018d9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018de:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018e1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018e6:	eb 0d                	jmp    8018f5 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018e8:	8d 45 14             	lea    0x14(%ebp),%eax
  8018eb:	e8 3b fc ff ff       	call   80152b <getuint>
			base = 16;
  8018f0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018f5:	83 ec 0c             	sub    $0xc,%esp
  8018f8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8018fc:	57                   	push   %edi
  8018fd:	ff 75 e0             	pushl  -0x20(%ebp)
  801900:	51                   	push   %ecx
  801901:	52                   	push   %edx
  801902:	50                   	push   %eax
  801903:	89 da                	mov    %ebx,%edx
  801905:	89 f0                	mov    %esi,%eax
  801907:	e8 70 fb ff ff       	call   80147c <printnum>
			break;
  80190c:	83 c4 20             	add    $0x20,%esp
  80190f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801912:	e9 ae fc ff ff       	jmp    8015c5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	53                   	push   %ebx
  80191b:	51                   	push   %ecx
  80191c:	ff d6                	call   *%esi
			break;
  80191e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801921:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801924:	e9 9c fc ff ff       	jmp    8015c5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801929:	83 ec 08             	sub    $0x8,%esp
  80192c:	53                   	push   %ebx
  80192d:	6a 25                	push   $0x25
  80192f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	eb 03                	jmp    801939 <vprintfmt+0x39a>
  801936:	83 ef 01             	sub    $0x1,%edi
  801939:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80193d:	75 f7                	jne    801936 <vprintfmt+0x397>
  80193f:	e9 81 fc ff ff       	jmp    8015c5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801944:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801947:	5b                   	pop    %ebx
  801948:	5e                   	pop    %esi
  801949:	5f                   	pop    %edi
  80194a:	5d                   	pop    %ebp
  80194b:	c3                   	ret    

0080194c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 18             	sub    $0x18,%esp
  801952:	8b 45 08             	mov    0x8(%ebp),%eax
  801955:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801958:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80195b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80195f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801962:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801969:	85 c0                	test   %eax,%eax
  80196b:	74 26                	je     801993 <vsnprintf+0x47>
  80196d:	85 d2                	test   %edx,%edx
  80196f:	7e 22                	jle    801993 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801971:	ff 75 14             	pushl  0x14(%ebp)
  801974:	ff 75 10             	pushl  0x10(%ebp)
  801977:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80197a:	50                   	push   %eax
  80197b:	68 65 15 80 00       	push   $0x801565
  801980:	e8 1a fc ff ff       	call   80159f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801985:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801988:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80198b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198e:	83 c4 10             	add    $0x10,%esp
  801991:	eb 05                	jmp    801998 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801993:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801998:	c9                   	leave  
  801999:	c3                   	ret    

0080199a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019a0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019a3:	50                   	push   %eax
  8019a4:	ff 75 10             	pushl  0x10(%ebp)
  8019a7:	ff 75 0c             	pushl  0xc(%ebp)
  8019aa:	ff 75 08             	pushl  0x8(%ebp)
  8019ad:	e8 9a ff ff ff       	call   80194c <vsnprintf>
	va_end(ap);

	return rc;
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    

008019b4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bf:	eb 03                	jmp    8019c4 <strlen+0x10>
		n++;
  8019c1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019c4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019c8:	75 f7                	jne    8019c1 <strlen+0xd>
		n++;
	return n;
}
  8019ca:	5d                   	pop    %ebp
  8019cb:	c3                   	ret    

008019cc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019cc:	55                   	push   %ebp
  8019cd:	89 e5                	mov    %esp,%ebp
  8019cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019d2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019da:	eb 03                	jmp    8019df <strnlen+0x13>
		n++;
  8019dc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019df:	39 c2                	cmp    %eax,%edx
  8019e1:	74 08                	je     8019eb <strnlen+0x1f>
  8019e3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019e7:	75 f3                	jne    8019dc <strnlen+0x10>
  8019e9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    

008019ed <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	53                   	push   %ebx
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019f7:	89 c2                	mov    %eax,%edx
  8019f9:	83 c2 01             	add    $0x1,%edx
  8019fc:	83 c1 01             	add    $0x1,%ecx
  8019ff:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a03:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a06:	84 db                	test   %bl,%bl
  801a08:	75 ef                	jne    8019f9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a0a:	5b                   	pop    %ebx
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	53                   	push   %ebx
  801a11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a14:	53                   	push   %ebx
  801a15:	e8 9a ff ff ff       	call   8019b4 <strlen>
  801a1a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a1d:	ff 75 0c             	pushl  0xc(%ebp)
  801a20:	01 d8                	add    %ebx,%eax
  801a22:	50                   	push   %eax
  801a23:	e8 c5 ff ff ff       	call   8019ed <strcpy>
	return dst;
}
  801a28:	89 d8                	mov    %ebx,%eax
  801a2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
  801a34:	8b 75 08             	mov    0x8(%ebp),%esi
  801a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3a:	89 f3                	mov    %esi,%ebx
  801a3c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a3f:	89 f2                	mov    %esi,%edx
  801a41:	eb 0f                	jmp    801a52 <strncpy+0x23>
		*dst++ = *src;
  801a43:	83 c2 01             	add    $0x1,%edx
  801a46:	0f b6 01             	movzbl (%ecx),%eax
  801a49:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a4c:	80 39 01             	cmpb   $0x1,(%ecx)
  801a4f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a52:	39 da                	cmp    %ebx,%edx
  801a54:	75 ed                	jne    801a43 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a56:	89 f0                	mov    %esi,%eax
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	8b 75 08             	mov    0x8(%ebp),%esi
  801a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a67:	8b 55 10             	mov    0x10(%ebp),%edx
  801a6a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a6c:	85 d2                	test   %edx,%edx
  801a6e:	74 21                	je     801a91 <strlcpy+0x35>
  801a70:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a74:	89 f2                	mov    %esi,%edx
  801a76:	eb 09                	jmp    801a81 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a78:	83 c2 01             	add    $0x1,%edx
  801a7b:	83 c1 01             	add    $0x1,%ecx
  801a7e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a81:	39 c2                	cmp    %eax,%edx
  801a83:	74 09                	je     801a8e <strlcpy+0x32>
  801a85:	0f b6 19             	movzbl (%ecx),%ebx
  801a88:	84 db                	test   %bl,%bl
  801a8a:	75 ec                	jne    801a78 <strlcpy+0x1c>
  801a8c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a8e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a91:	29 f0                	sub    %esi,%eax
}
  801a93:	5b                   	pop    %ebx
  801a94:	5e                   	pop    %esi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a9d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801aa0:	eb 06                	jmp    801aa8 <strcmp+0x11>
		p++, q++;
  801aa2:	83 c1 01             	add    $0x1,%ecx
  801aa5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801aa8:	0f b6 01             	movzbl (%ecx),%eax
  801aab:	84 c0                	test   %al,%al
  801aad:	74 04                	je     801ab3 <strcmp+0x1c>
  801aaf:	3a 02                	cmp    (%edx),%al
  801ab1:	74 ef                	je     801aa2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ab3:	0f b6 c0             	movzbl %al,%eax
  801ab6:	0f b6 12             	movzbl (%edx),%edx
  801ab9:	29 d0                	sub    %edx,%eax
}
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	53                   	push   %ebx
  801ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac7:	89 c3                	mov    %eax,%ebx
  801ac9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801acc:	eb 06                	jmp    801ad4 <strncmp+0x17>
		n--, p++, q++;
  801ace:	83 c0 01             	add    $0x1,%eax
  801ad1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ad4:	39 d8                	cmp    %ebx,%eax
  801ad6:	74 15                	je     801aed <strncmp+0x30>
  801ad8:	0f b6 08             	movzbl (%eax),%ecx
  801adb:	84 c9                	test   %cl,%cl
  801add:	74 04                	je     801ae3 <strncmp+0x26>
  801adf:	3a 0a                	cmp    (%edx),%cl
  801ae1:	74 eb                	je     801ace <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ae3:	0f b6 00             	movzbl (%eax),%eax
  801ae6:	0f b6 12             	movzbl (%edx),%edx
  801ae9:	29 d0                	sub    %edx,%eax
  801aeb:	eb 05                	jmp    801af2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801aed:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801af2:	5b                   	pop    %ebx
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	8b 45 08             	mov    0x8(%ebp),%eax
  801afb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801aff:	eb 07                	jmp    801b08 <strchr+0x13>
		if (*s == c)
  801b01:	38 ca                	cmp    %cl,%dl
  801b03:	74 0f                	je     801b14 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b05:	83 c0 01             	add    $0x1,%eax
  801b08:	0f b6 10             	movzbl (%eax),%edx
  801b0b:	84 d2                	test   %dl,%dl
  801b0d:	75 f2                	jne    801b01 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b20:	eb 03                	jmp    801b25 <strfind+0xf>
  801b22:	83 c0 01             	add    $0x1,%eax
  801b25:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b28:	38 ca                	cmp    %cl,%dl
  801b2a:	74 04                	je     801b30 <strfind+0x1a>
  801b2c:	84 d2                	test   %dl,%dl
  801b2e:	75 f2                	jne    801b22 <strfind+0xc>
			break;
	return (char *) s;
}
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    

00801b32 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b32:	55                   	push   %ebp
  801b33:	89 e5                	mov    %esp,%ebp
  801b35:	57                   	push   %edi
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b3b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b3e:	85 c9                	test   %ecx,%ecx
  801b40:	74 36                	je     801b78 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b42:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b48:	75 28                	jne    801b72 <memset+0x40>
  801b4a:	f6 c1 03             	test   $0x3,%cl
  801b4d:	75 23                	jne    801b72 <memset+0x40>
		c &= 0xFF;
  801b4f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b53:	89 d3                	mov    %edx,%ebx
  801b55:	c1 e3 08             	shl    $0x8,%ebx
  801b58:	89 d6                	mov    %edx,%esi
  801b5a:	c1 e6 18             	shl    $0x18,%esi
  801b5d:	89 d0                	mov    %edx,%eax
  801b5f:	c1 e0 10             	shl    $0x10,%eax
  801b62:	09 f0                	or     %esi,%eax
  801b64:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b66:	89 d8                	mov    %ebx,%eax
  801b68:	09 d0                	or     %edx,%eax
  801b6a:	c1 e9 02             	shr    $0x2,%ecx
  801b6d:	fc                   	cld    
  801b6e:	f3 ab                	rep stos %eax,%es:(%edi)
  801b70:	eb 06                	jmp    801b78 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b75:	fc                   	cld    
  801b76:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b78:	89 f8                	mov    %edi,%eax
  801b7a:	5b                   	pop    %ebx
  801b7b:	5e                   	pop    %esi
  801b7c:	5f                   	pop    %edi
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    

00801b7f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	57                   	push   %edi
  801b83:	56                   	push   %esi
  801b84:	8b 45 08             	mov    0x8(%ebp),%eax
  801b87:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b8d:	39 c6                	cmp    %eax,%esi
  801b8f:	73 35                	jae    801bc6 <memmove+0x47>
  801b91:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b94:	39 d0                	cmp    %edx,%eax
  801b96:	73 2e                	jae    801bc6 <memmove+0x47>
		s += n;
		d += n;
  801b98:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b9b:	89 d6                	mov    %edx,%esi
  801b9d:	09 fe                	or     %edi,%esi
  801b9f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801ba5:	75 13                	jne    801bba <memmove+0x3b>
  801ba7:	f6 c1 03             	test   $0x3,%cl
  801baa:	75 0e                	jne    801bba <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bac:	83 ef 04             	sub    $0x4,%edi
  801baf:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bb2:	c1 e9 02             	shr    $0x2,%ecx
  801bb5:	fd                   	std    
  801bb6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bb8:	eb 09                	jmp    801bc3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bba:	83 ef 01             	sub    $0x1,%edi
  801bbd:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bc0:	fd                   	std    
  801bc1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bc3:	fc                   	cld    
  801bc4:	eb 1d                	jmp    801be3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bc6:	89 f2                	mov    %esi,%edx
  801bc8:	09 c2                	or     %eax,%edx
  801bca:	f6 c2 03             	test   $0x3,%dl
  801bcd:	75 0f                	jne    801bde <memmove+0x5f>
  801bcf:	f6 c1 03             	test   $0x3,%cl
  801bd2:	75 0a                	jne    801bde <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bd4:	c1 e9 02             	shr    $0x2,%ecx
  801bd7:	89 c7                	mov    %eax,%edi
  801bd9:	fc                   	cld    
  801bda:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bdc:	eb 05                	jmp    801be3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bde:	89 c7                	mov    %eax,%edi
  801be0:	fc                   	cld    
  801be1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801be3:	5e                   	pop    %esi
  801be4:	5f                   	pop    %edi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801bea:	ff 75 10             	pushl  0x10(%ebp)
  801bed:	ff 75 0c             	pushl  0xc(%ebp)
  801bf0:	ff 75 08             	pushl  0x8(%ebp)
  801bf3:	e8 87 ff ff ff       	call   801b7f <memmove>
}
  801bf8:	c9                   	leave  
  801bf9:	c3                   	ret    

00801bfa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bfa:	55                   	push   %ebp
  801bfb:	89 e5                	mov    %esp,%ebp
  801bfd:	56                   	push   %esi
  801bfe:	53                   	push   %ebx
  801bff:	8b 45 08             	mov    0x8(%ebp),%eax
  801c02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c05:	89 c6                	mov    %eax,%esi
  801c07:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c0a:	eb 1a                	jmp    801c26 <memcmp+0x2c>
		if (*s1 != *s2)
  801c0c:	0f b6 08             	movzbl (%eax),%ecx
  801c0f:	0f b6 1a             	movzbl (%edx),%ebx
  801c12:	38 d9                	cmp    %bl,%cl
  801c14:	74 0a                	je     801c20 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c16:	0f b6 c1             	movzbl %cl,%eax
  801c19:	0f b6 db             	movzbl %bl,%ebx
  801c1c:	29 d8                	sub    %ebx,%eax
  801c1e:	eb 0f                	jmp    801c2f <memcmp+0x35>
		s1++, s2++;
  801c20:	83 c0 01             	add    $0x1,%eax
  801c23:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c26:	39 f0                	cmp    %esi,%eax
  801c28:	75 e2                	jne    801c0c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	53                   	push   %ebx
  801c37:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c3a:	89 c1                	mov    %eax,%ecx
  801c3c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c3f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c43:	eb 0a                	jmp    801c4f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c45:	0f b6 10             	movzbl (%eax),%edx
  801c48:	39 da                	cmp    %ebx,%edx
  801c4a:	74 07                	je     801c53 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c4c:	83 c0 01             	add    $0x1,%eax
  801c4f:	39 c8                	cmp    %ecx,%eax
  801c51:	72 f2                	jb     801c45 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c53:	5b                   	pop    %ebx
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	57                   	push   %edi
  801c5a:	56                   	push   %esi
  801c5b:	53                   	push   %ebx
  801c5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c62:	eb 03                	jmp    801c67 <strtol+0x11>
		s++;
  801c64:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c67:	0f b6 01             	movzbl (%ecx),%eax
  801c6a:	3c 20                	cmp    $0x20,%al
  801c6c:	74 f6                	je     801c64 <strtol+0xe>
  801c6e:	3c 09                	cmp    $0x9,%al
  801c70:	74 f2                	je     801c64 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c72:	3c 2b                	cmp    $0x2b,%al
  801c74:	75 0a                	jne    801c80 <strtol+0x2a>
		s++;
  801c76:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c79:	bf 00 00 00 00       	mov    $0x0,%edi
  801c7e:	eb 11                	jmp    801c91 <strtol+0x3b>
  801c80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c85:	3c 2d                	cmp    $0x2d,%al
  801c87:	75 08                	jne    801c91 <strtol+0x3b>
		s++, neg = 1;
  801c89:	83 c1 01             	add    $0x1,%ecx
  801c8c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c91:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c97:	75 15                	jne    801cae <strtol+0x58>
  801c99:	80 39 30             	cmpb   $0x30,(%ecx)
  801c9c:	75 10                	jne    801cae <strtol+0x58>
  801c9e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ca2:	75 7c                	jne    801d20 <strtol+0xca>
		s += 2, base = 16;
  801ca4:	83 c1 02             	add    $0x2,%ecx
  801ca7:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cac:	eb 16                	jmp    801cc4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cae:	85 db                	test   %ebx,%ebx
  801cb0:	75 12                	jne    801cc4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cb2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cb7:	80 39 30             	cmpb   $0x30,(%ecx)
  801cba:	75 08                	jne    801cc4 <strtol+0x6e>
		s++, base = 8;
  801cbc:	83 c1 01             	add    $0x1,%ecx
  801cbf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ccc:	0f b6 11             	movzbl (%ecx),%edx
  801ccf:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cd2:	89 f3                	mov    %esi,%ebx
  801cd4:	80 fb 09             	cmp    $0x9,%bl
  801cd7:	77 08                	ja     801ce1 <strtol+0x8b>
			dig = *s - '0';
  801cd9:	0f be d2             	movsbl %dl,%edx
  801cdc:	83 ea 30             	sub    $0x30,%edx
  801cdf:	eb 22                	jmp    801d03 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ce1:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ce4:	89 f3                	mov    %esi,%ebx
  801ce6:	80 fb 19             	cmp    $0x19,%bl
  801ce9:	77 08                	ja     801cf3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ceb:	0f be d2             	movsbl %dl,%edx
  801cee:	83 ea 57             	sub    $0x57,%edx
  801cf1:	eb 10                	jmp    801d03 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801cf3:	8d 72 bf             	lea    -0x41(%edx),%esi
  801cf6:	89 f3                	mov    %esi,%ebx
  801cf8:	80 fb 19             	cmp    $0x19,%bl
  801cfb:	77 16                	ja     801d13 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801cfd:	0f be d2             	movsbl %dl,%edx
  801d00:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d03:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d06:	7d 0b                	jge    801d13 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d08:	83 c1 01             	add    $0x1,%ecx
  801d0b:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d0f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d11:	eb b9                	jmp    801ccc <strtol+0x76>

	if (endptr)
  801d13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d17:	74 0d                	je     801d26 <strtol+0xd0>
		*endptr = (char *) s;
  801d19:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d1c:	89 0e                	mov    %ecx,(%esi)
  801d1e:	eb 06                	jmp    801d26 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d20:	85 db                	test   %ebx,%ebx
  801d22:	74 98                	je     801cbc <strtol+0x66>
  801d24:	eb 9e                	jmp    801cc4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d26:	89 c2                	mov    %eax,%edx
  801d28:	f7 da                	neg    %edx
  801d2a:	85 ff                	test   %edi,%edi
  801d2c:	0f 45 c2             	cmovne %edx,%eax
}
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5f                   	pop    %edi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    

00801d34 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
  801d37:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d3a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d41:	75 2a                	jne    801d6d <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d43:	83 ec 04             	sub    $0x4,%esp
  801d46:	6a 07                	push   $0x7
  801d48:	68 00 f0 bf ee       	push   $0xeebff000
  801d4d:	6a 00                	push   $0x0
  801d4f:	e8 2e e4 ff ff       	call   800182 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 c0                	test   %eax,%eax
  801d59:	79 12                	jns    801d6d <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d5b:	50                   	push   %eax
  801d5c:	68 80 26 80 00       	push   $0x802680
  801d61:	6a 23                	push   $0x23
  801d63:	68 84 26 80 00       	push   $0x802684
  801d68:	e8 22 f6 ff ff       	call   80138f <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d70:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d75:	83 ec 08             	sub    $0x8,%esp
  801d78:	68 9f 1d 80 00       	push   $0x801d9f
  801d7d:	6a 00                	push   $0x0
  801d7f:	e8 49 e5 ff ff       	call   8002cd <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	85 c0                	test   %eax,%eax
  801d89:	79 12                	jns    801d9d <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d8b:	50                   	push   %eax
  801d8c:	68 80 26 80 00       	push   $0x802680
  801d91:	6a 2c                	push   $0x2c
  801d93:	68 84 26 80 00       	push   $0x802684
  801d98:	e8 f2 f5 ff ff       	call   80138f <_panic>
	}
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d9f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801da0:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801da5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801da7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801daa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dae:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801db3:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801db7:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801db9:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dbc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dbd:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dc0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dc1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dc2:	c3                   	ret    

00801dc3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	56                   	push   %esi
  801dc7:	53                   	push   %ebx
  801dc8:	8b 75 08             	mov    0x8(%ebp),%esi
  801dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	75 12                	jne    801de7 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801dd5:	83 ec 0c             	sub    $0xc,%esp
  801dd8:	68 00 00 c0 ee       	push   $0xeec00000
  801ddd:	e8 50 e5 ff ff       	call   800332 <sys_ipc_recv>
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	eb 0c                	jmp    801df3 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801de7:	83 ec 0c             	sub    $0xc,%esp
  801dea:	50                   	push   %eax
  801deb:	e8 42 e5 ff ff       	call   800332 <sys_ipc_recv>
  801df0:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801df3:	85 f6                	test   %esi,%esi
  801df5:	0f 95 c1             	setne  %cl
  801df8:	85 db                	test   %ebx,%ebx
  801dfa:	0f 95 c2             	setne  %dl
  801dfd:	84 d1                	test   %dl,%cl
  801dff:	74 09                	je     801e0a <ipc_recv+0x47>
  801e01:	89 c2                	mov    %eax,%edx
  801e03:	c1 ea 1f             	shr    $0x1f,%edx
  801e06:	84 d2                	test   %dl,%dl
  801e08:	75 2a                	jne    801e34 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e0a:	85 f6                	test   %esi,%esi
  801e0c:	74 0d                	je     801e1b <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e0e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e13:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e19:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e1b:	85 db                	test   %ebx,%ebx
  801e1d:	74 0d                	je     801e2c <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e1f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e24:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e2a:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e2c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e31:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e37:	5b                   	pop    %ebx
  801e38:	5e                   	pop    %esi
  801e39:	5d                   	pop    %ebp
  801e3a:	c3                   	ret    

00801e3b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	57                   	push   %edi
  801e3f:	56                   	push   %esi
  801e40:	53                   	push   %ebx
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e47:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e4d:	85 db                	test   %ebx,%ebx
  801e4f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e54:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e57:	ff 75 14             	pushl  0x14(%ebp)
  801e5a:	53                   	push   %ebx
  801e5b:	56                   	push   %esi
  801e5c:	57                   	push   %edi
  801e5d:	e8 ad e4 ff ff       	call   80030f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e62:	89 c2                	mov    %eax,%edx
  801e64:	c1 ea 1f             	shr    $0x1f,%edx
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	84 d2                	test   %dl,%dl
  801e6c:	74 17                	je     801e85 <ipc_send+0x4a>
  801e6e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e71:	74 12                	je     801e85 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e73:	50                   	push   %eax
  801e74:	68 92 26 80 00       	push   $0x802692
  801e79:	6a 47                	push   $0x47
  801e7b:	68 a0 26 80 00       	push   $0x8026a0
  801e80:	e8 0a f5 ff ff       	call   80138f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e85:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e88:	75 07                	jne    801e91 <ipc_send+0x56>
			sys_yield();
  801e8a:	e8 d4 e2 ff ff       	call   800163 <sys_yield>
  801e8f:	eb c6                	jmp    801e57 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e91:	85 c0                	test   %eax,%eax
  801e93:	75 c2                	jne    801e57 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ea8:	89 c2                	mov    %eax,%edx
  801eaa:	c1 e2 07             	shl    $0x7,%edx
  801ead:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801eb4:	8b 52 5c             	mov    0x5c(%edx),%edx
  801eb7:	39 ca                	cmp    %ecx,%edx
  801eb9:	75 11                	jne    801ecc <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ebb:	89 c2                	mov    %eax,%edx
  801ebd:	c1 e2 07             	shl    $0x7,%edx
  801ec0:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ec7:	8b 40 54             	mov    0x54(%eax),%eax
  801eca:	eb 0f                	jmp    801edb <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ecc:	83 c0 01             	add    $0x1,%eax
  801ecf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ed4:	75 d2                	jne    801ea8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ed6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801edb:	5d                   	pop    %ebp
  801edc:	c3                   	ret    

00801edd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801edd:	55                   	push   %ebp
  801ede:	89 e5                	mov    %esp,%ebp
  801ee0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ee3:	89 d0                	mov    %edx,%eax
  801ee5:	c1 e8 16             	shr    $0x16,%eax
  801ee8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eef:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef4:	f6 c1 01             	test   $0x1,%cl
  801ef7:	74 1d                	je     801f16 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ef9:	c1 ea 0c             	shr    $0xc,%edx
  801efc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f03:	f6 c2 01             	test   $0x1,%dl
  801f06:	74 0e                	je     801f16 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f08:	c1 ea 0c             	shr    $0xc,%edx
  801f0b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f12:	ef 
  801f13:	0f b7 c0             	movzwl %ax,%eax
}
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    
  801f18:	66 90                	xchg   %ax,%ax
  801f1a:	66 90                	xchg   %ax,%ax
  801f1c:	66 90                	xchg   %ax,%ax
  801f1e:	66 90                	xchg   %ax,%ax

00801f20 <__udivdi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
  801f27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f37:	85 f6                	test   %esi,%esi
  801f39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f3d:	89 ca                	mov    %ecx,%edx
  801f3f:	89 f8                	mov    %edi,%eax
  801f41:	75 3d                	jne    801f80 <__udivdi3+0x60>
  801f43:	39 cf                	cmp    %ecx,%edi
  801f45:	0f 87 c5 00 00 00    	ja     802010 <__udivdi3+0xf0>
  801f4b:	85 ff                	test   %edi,%edi
  801f4d:	89 fd                	mov    %edi,%ebp
  801f4f:	75 0b                	jne    801f5c <__udivdi3+0x3c>
  801f51:	b8 01 00 00 00       	mov    $0x1,%eax
  801f56:	31 d2                	xor    %edx,%edx
  801f58:	f7 f7                	div    %edi
  801f5a:	89 c5                	mov    %eax,%ebp
  801f5c:	89 c8                	mov    %ecx,%eax
  801f5e:	31 d2                	xor    %edx,%edx
  801f60:	f7 f5                	div    %ebp
  801f62:	89 c1                	mov    %eax,%ecx
  801f64:	89 d8                	mov    %ebx,%eax
  801f66:	89 cf                	mov    %ecx,%edi
  801f68:	f7 f5                	div    %ebp
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	89 d8                	mov    %ebx,%eax
  801f6e:	89 fa                	mov    %edi,%edx
  801f70:	83 c4 1c             	add    $0x1c,%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
  801f78:	90                   	nop
  801f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f80:	39 ce                	cmp    %ecx,%esi
  801f82:	77 74                	ja     801ff8 <__udivdi3+0xd8>
  801f84:	0f bd fe             	bsr    %esi,%edi
  801f87:	83 f7 1f             	xor    $0x1f,%edi
  801f8a:	0f 84 98 00 00 00    	je     802028 <__udivdi3+0x108>
  801f90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	89 c5                	mov    %eax,%ebp
  801f99:	29 fb                	sub    %edi,%ebx
  801f9b:	d3 e6                	shl    %cl,%esi
  801f9d:	89 d9                	mov    %ebx,%ecx
  801f9f:	d3 ed                	shr    %cl,%ebp
  801fa1:	89 f9                	mov    %edi,%ecx
  801fa3:	d3 e0                	shl    %cl,%eax
  801fa5:	09 ee                	or     %ebp,%esi
  801fa7:	89 d9                	mov    %ebx,%ecx
  801fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fad:	89 d5                	mov    %edx,%ebp
  801faf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fb3:	d3 ed                	shr    %cl,%ebp
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e2                	shl    %cl,%edx
  801fb9:	89 d9                	mov    %ebx,%ecx
  801fbb:	d3 e8                	shr    %cl,%eax
  801fbd:	09 c2                	or     %eax,%edx
  801fbf:	89 d0                	mov    %edx,%eax
  801fc1:	89 ea                	mov    %ebp,%edx
  801fc3:	f7 f6                	div    %esi
  801fc5:	89 d5                	mov    %edx,%ebp
  801fc7:	89 c3                	mov    %eax,%ebx
  801fc9:	f7 64 24 0c          	mull   0xc(%esp)
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	72 10                	jb     801fe1 <__udivdi3+0xc1>
  801fd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e6                	shl    %cl,%esi
  801fd9:	39 c6                	cmp    %eax,%esi
  801fdb:	73 07                	jae    801fe4 <__udivdi3+0xc4>
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	75 03                	jne    801fe4 <__udivdi3+0xc4>
  801fe1:	83 eb 01             	sub    $0x1,%ebx
  801fe4:	31 ff                	xor    %edi,%edi
  801fe6:	89 d8                	mov    %ebx,%eax
  801fe8:	89 fa                	mov    %edi,%edx
  801fea:	83 c4 1c             	add    $0x1c,%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
  801ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff8:	31 ff                	xor    %edi,%edi
  801ffa:	31 db                	xor    %ebx,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	89 d8                	mov    %ebx,%eax
  802012:	f7 f7                	div    %edi
  802014:	31 ff                	xor    %edi,%edi
  802016:	89 c3                	mov    %eax,%ebx
  802018:	89 d8                	mov    %ebx,%eax
  80201a:	89 fa                	mov    %edi,%edx
  80201c:	83 c4 1c             	add    $0x1c,%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    
  802024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802028:	39 ce                	cmp    %ecx,%esi
  80202a:	72 0c                	jb     802038 <__udivdi3+0x118>
  80202c:	31 db                	xor    %ebx,%ebx
  80202e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802032:	0f 87 34 ff ff ff    	ja     801f6c <__udivdi3+0x4c>
  802038:	bb 01 00 00 00       	mov    $0x1,%ebx
  80203d:	e9 2a ff ff ff       	jmp    801f6c <__udivdi3+0x4c>
  802042:	66 90                	xchg   %ax,%ax
  802044:	66 90                	xchg   %ax,%ax
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__umoddi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80205b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80205f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 d2                	test   %edx,%edx
  802069:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80206d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802071:	89 f3                	mov    %esi,%ebx
  802073:	89 3c 24             	mov    %edi,(%esp)
  802076:	89 74 24 04          	mov    %esi,0x4(%esp)
  80207a:	75 1c                	jne    802098 <__umoddi3+0x48>
  80207c:	39 f7                	cmp    %esi,%edi
  80207e:	76 50                	jbe    8020d0 <__umoddi3+0x80>
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	f7 f7                	div    %edi
  802086:	89 d0                	mov    %edx,%eax
  802088:	31 d2                	xor    %edx,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	39 f2                	cmp    %esi,%edx
  80209a:	89 d0                	mov    %edx,%eax
  80209c:	77 52                	ja     8020f0 <__umoddi3+0xa0>
  80209e:	0f bd ea             	bsr    %edx,%ebp
  8020a1:	83 f5 1f             	xor    $0x1f,%ebp
  8020a4:	75 5a                	jne    802100 <__umoddi3+0xb0>
  8020a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020aa:	0f 82 e0 00 00 00    	jb     802190 <__umoddi3+0x140>
  8020b0:	39 0c 24             	cmp    %ecx,(%esp)
  8020b3:	0f 86 d7 00 00 00    	jbe    802190 <__umoddi3+0x140>
  8020b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020c1:	83 c4 1c             	add    $0x1c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	85 ff                	test   %edi,%edi
  8020d2:	89 fd                	mov    %edi,%ebp
  8020d4:	75 0b                	jne    8020e1 <__umoddi3+0x91>
  8020d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	f7 f7                	div    %edi
  8020df:	89 c5                	mov    %eax,%ebp
  8020e1:	89 f0                	mov    %esi,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  8020e5:	f7 f5                	div    %ebp
  8020e7:	89 c8                	mov    %ecx,%eax
  8020e9:	f7 f5                	div    %ebp
  8020eb:	89 d0                	mov    %edx,%eax
  8020ed:	eb 99                	jmp    802088 <__umoddi3+0x38>
  8020ef:	90                   	nop
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	83 c4 1c             	add    $0x1c,%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    
  8020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802100:	8b 34 24             	mov    (%esp),%esi
  802103:	bf 20 00 00 00       	mov    $0x20,%edi
  802108:	89 e9                	mov    %ebp,%ecx
  80210a:	29 ef                	sub    %ebp,%edi
  80210c:	d3 e0                	shl    %cl,%eax
  80210e:	89 f9                	mov    %edi,%ecx
  802110:	89 f2                	mov    %esi,%edx
  802112:	d3 ea                	shr    %cl,%edx
  802114:	89 e9                	mov    %ebp,%ecx
  802116:	09 c2                	or     %eax,%edx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 14 24             	mov    %edx,(%esp)
  80211d:	89 f2                	mov    %esi,%edx
  80211f:	d3 e2                	shl    %cl,%edx
  802121:	89 f9                	mov    %edi,%ecx
  802123:	89 54 24 04          	mov    %edx,0x4(%esp)
  802127:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	89 e9                	mov    %ebp,%ecx
  80212f:	89 c6                	mov    %eax,%esi
  802131:	d3 e3                	shl    %cl,%ebx
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 d0                	mov    %edx,%eax
  802137:	d3 e8                	shr    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	09 d8                	or     %ebx,%eax
  80213d:	89 d3                	mov    %edx,%ebx
  80213f:	89 f2                	mov    %esi,%edx
  802141:	f7 34 24             	divl   (%esp)
  802144:	89 d6                	mov    %edx,%esi
  802146:	d3 e3                	shl    %cl,%ebx
  802148:	f7 64 24 04          	mull   0x4(%esp)
  80214c:	39 d6                	cmp    %edx,%esi
  80214e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802152:	89 d1                	mov    %edx,%ecx
  802154:	89 c3                	mov    %eax,%ebx
  802156:	72 08                	jb     802160 <__umoddi3+0x110>
  802158:	75 11                	jne    80216b <__umoddi3+0x11b>
  80215a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80215e:	73 0b                	jae    80216b <__umoddi3+0x11b>
  802160:	2b 44 24 04          	sub    0x4(%esp),%eax
  802164:	1b 14 24             	sbb    (%esp),%edx
  802167:	89 d1                	mov    %edx,%ecx
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80216f:	29 da                	sub    %ebx,%edx
  802171:	19 ce                	sbb    %ecx,%esi
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 f0                	mov    %esi,%eax
  802177:	d3 e0                	shl    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	d3 ea                	shr    %cl,%edx
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	d3 ee                	shr    %cl,%esi
  802181:	09 d0                	or     %edx,%eax
  802183:	89 f2                	mov    %esi,%edx
  802185:	83 c4 1c             	add    $0x1c,%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    
  80218d:	8d 76 00             	lea    0x0(%esi),%esi
  802190:	29 f9                	sub    %edi,%ecx
  802192:	19 d6                	sbb    %edx,%esi
  802194:	89 74 24 04          	mov    %esi,0x4(%esp)
  802198:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80219c:	e9 18 ff ff ff       	jmp    8020b9 <__umoddi3+0x69>
