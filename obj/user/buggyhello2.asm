
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
  800044:	e8 ad 00 00 00       	call   8000f6 <sys_cputs>
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
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800057:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80005e:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800061:	e8 0e 01 00 00       	call   800174 <sys_getenvid>
  800066:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80006c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800071:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800076:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  80007b:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80007e:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800084:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800087:	39 c8                	cmp    %ecx,%eax
  800089:	0f 44 fb             	cmove  %ebx,%edi
  80008c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800091:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800094:	83 c2 01             	add    $0x1,%edx
  800097:	83 c3 7c             	add    $0x7c,%ebx
  80009a:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000a0:	75 d9                	jne    80007b <libmain+0x2d>
  8000a2:	89 f0                	mov    %esi,%eax
  8000a4:	84 c0                	test   %al,%al
  8000a6:	74 06                	je     8000ae <libmain+0x60>
  8000a8:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000b2:	7e 0a                	jle    8000be <libmain+0x70>
		binaryname = argv[0];
  8000b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b7:	8b 00                	mov    (%eax),%eax
  8000b9:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	ff 75 0c             	pushl  0xc(%ebp)
  8000c4:	ff 75 08             	pushl  0x8(%ebp)
  8000c7:	e8 67 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000cc:	e8 0b 00 00 00       	call   8000dc <exit>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e2:	e8 87 04 00 00       	call   80056e <close_all>
	sys_env_destroy(0);
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	6a 00                	push   $0x0
  8000ec:	e8 42 00 00 00       	call   800133 <sys_env_destroy>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    

008000f6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	57                   	push   %edi
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800101:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 c3                	mov    %eax,%ebx
  800109:	89 c7                	mov    %eax,%edi
  80010b:	89 c6                	mov    %eax,%esi
  80010d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_cgetc>:

int
sys_cgetc(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 01 00 00 00       	mov    $0x1,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800141:	b8 03 00 00 00       	mov    $0x3,%eax
  800146:	8b 55 08             	mov    0x8(%ebp),%edx
  800149:	89 cb                	mov    %ecx,%ebx
  80014b:	89 cf                	mov    %ecx,%edi
  80014d:	89 ce                	mov    %ecx,%esi
  80014f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800151:	85 c0                	test   %eax,%eax
  800153:	7e 17                	jle    80016c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	50                   	push   %eax
  800159:	6a 03                	push   $0x3
  80015b:	68 38 1e 80 00       	push   $0x801e38
  800160:	6a 23                	push   $0x23
  800162:	68 55 1e 80 00       	push   $0x801e55
  800167:	e8 21 0f 00 00       	call   80108d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80016c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80016f:	5b                   	pop    %ebx
  800170:	5e                   	pop    %esi
  800171:	5f                   	pop    %edi
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017a:	ba 00 00 00 00       	mov    $0x0,%edx
  80017f:	b8 02 00 00 00       	mov    $0x2,%eax
  800184:	89 d1                	mov    %edx,%ecx
  800186:	89 d3                	mov    %edx,%ebx
  800188:	89 d7                	mov    %edx,%edi
  80018a:	89 d6                	mov    %edx,%esi
  80018c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018e:	5b                   	pop    %ebx
  80018f:	5e                   	pop    %esi
  800190:	5f                   	pop    %edi
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    

00800193 <sys_yield>:

void
sys_yield(void)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	57                   	push   %edi
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800199:	ba 00 00 00 00       	mov    $0x0,%edx
  80019e:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001a3:	89 d1                	mov    %edx,%ecx
  8001a5:	89 d3                	mov    %edx,%ebx
  8001a7:	89 d7                	mov    %edx,%edi
  8001a9:	89 d6                	mov    %edx,%esi
  8001ab:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001ad:	5b                   	pop    %ebx
  8001ae:	5e                   	pop    %esi
  8001af:	5f                   	pop    %edi
  8001b0:	5d                   	pop    %ebp
  8001b1:	c3                   	ret    

008001b2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	57                   	push   %edi
  8001b6:	56                   	push   %esi
  8001b7:	53                   	push   %ebx
  8001b8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bb:	be 00 00 00 00       	mov    $0x0,%esi
  8001c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ce:	89 f7                	mov    %esi,%edi
  8001d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 04                	push   $0x4
  8001dc:	68 38 1e 80 00       	push   $0x801e38
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 55 1e 80 00       	push   $0x801e55
  8001e8:	e8 a0 0e 00 00       	call   80108d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	b8 05 00 00 00       	mov    $0x5,%eax
  800203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800206:	8b 55 08             	mov    0x8(%ebp),%edx
  800209:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80020f:	8b 75 18             	mov    0x18(%ebp),%esi
  800212:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 05                	push   $0x5
  80021e:	68 38 1e 80 00       	push   $0x801e38
  800223:	6a 23                	push   $0x23
  800225:	68 55 1e 80 00       	push   $0x801e55
  80022a:	e8 5e 0e 00 00       	call   80108d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 06 00 00 00       	mov    $0x6,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 06                	push   $0x6
  800260:	68 38 1e 80 00       	push   $0x801e38
  800265:	6a 23                	push   $0x23
  800267:	68 55 1e 80 00       	push   $0x801e55
  80026c:	e8 1c 0e 00 00       	call   80108d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 08 00 00 00       	mov    $0x8,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 08                	push   $0x8
  8002a2:	68 38 1e 80 00       	push   $0x801e38
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 55 1e 80 00       	push   $0x801e55
  8002ae:	e8 da 0d 00 00       	call   80108d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 09                	push   $0x9
  8002e4:	68 38 1e 80 00       	push   $0x801e38
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 55 1e 80 00       	push   $0x801e55
  8002f0:	e8 98 0d 00 00       	call   80108d <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800306:	bb 00 00 00 00       	mov    $0x0,%ebx
  80030b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	89 df                	mov    %ebx,%edi
  800318:	89 de                	mov    %ebx,%esi
  80031a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80031c:	85 c0                	test   %eax,%eax
  80031e:	7e 17                	jle    800337 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	50                   	push   %eax
  800324:	6a 0a                	push   $0xa
  800326:	68 38 1e 80 00       	push   $0x801e38
  80032b:	6a 23                	push   $0x23
  80032d:	68 55 1e 80 00       	push   $0x801e55
  800332:	e8 56 0d 00 00       	call   80108d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800337:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800345:	be 00 00 00 00       	mov    $0x0,%esi
  80034a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800352:	8b 55 08             	mov    0x8(%ebp),%edx
  800355:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800358:	8b 7d 14             	mov    0x14(%ebp),%edi
  80035b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80035d:	5b                   	pop    %ebx
  80035e:	5e                   	pop    %esi
  80035f:	5f                   	pop    %edi
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    

00800362 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	57                   	push   %edi
  800366:	56                   	push   %esi
  800367:	53                   	push   %ebx
  800368:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800370:	b8 0d 00 00 00       	mov    $0xd,%eax
  800375:	8b 55 08             	mov    0x8(%ebp),%edx
  800378:	89 cb                	mov    %ecx,%ebx
  80037a:	89 cf                	mov    %ecx,%edi
  80037c:	89 ce                	mov    %ecx,%esi
  80037e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800380:	85 c0                	test   %eax,%eax
  800382:	7e 17                	jle    80039b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800384:	83 ec 0c             	sub    $0xc,%esp
  800387:	50                   	push   %eax
  800388:	6a 0d                	push   $0xd
  80038a:	68 38 1e 80 00       	push   $0x801e38
  80038f:	6a 23                	push   $0x23
  800391:	68 55 1e 80 00       	push   $0x801e55
  800396:	e8 f2 0c 00 00       	call   80108d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80039b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039e:	5b                   	pop    %ebx
  80039f:	5e                   	pop    %esi
  8003a0:	5f                   	pop    %edi
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ae:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b9:	05 00 00 00 30       	add    $0x30000000,%eax
  8003be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d5:	89 c2                	mov    %eax,%edx
  8003d7:	c1 ea 16             	shr    $0x16,%edx
  8003da:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e1:	f6 c2 01             	test   $0x1,%dl
  8003e4:	74 11                	je     8003f7 <fd_alloc+0x2d>
  8003e6:	89 c2                	mov    %eax,%edx
  8003e8:	c1 ea 0c             	shr    $0xc,%edx
  8003eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f2:	f6 c2 01             	test   $0x1,%dl
  8003f5:	75 09                	jne    800400 <fd_alloc+0x36>
			*fd_store = fd;
  8003f7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fe:	eb 17                	jmp    800417 <fd_alloc+0x4d>
  800400:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800405:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80040a:	75 c9                	jne    8003d5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80040c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800412:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    

00800419 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80041f:	83 f8 1f             	cmp    $0x1f,%eax
  800422:	77 36                	ja     80045a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800424:	c1 e0 0c             	shl    $0xc,%eax
  800427:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80042c:	89 c2                	mov    %eax,%edx
  80042e:	c1 ea 16             	shr    $0x16,%edx
  800431:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800438:	f6 c2 01             	test   $0x1,%dl
  80043b:	74 24                	je     800461 <fd_lookup+0x48>
  80043d:	89 c2                	mov    %eax,%edx
  80043f:	c1 ea 0c             	shr    $0xc,%edx
  800442:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800449:	f6 c2 01             	test   $0x1,%dl
  80044c:	74 1a                	je     800468 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80044e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800451:	89 02                	mov    %eax,(%edx)
	return 0;
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	eb 13                	jmp    80046d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045f:	eb 0c                	jmp    80046d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800466:	eb 05                	jmp    80046d <fd_lookup+0x54>
  800468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80046d:	5d                   	pop    %ebp
  80046e:	c3                   	ret    

0080046f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800478:	ba e0 1e 80 00       	mov    $0x801ee0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80047d:	eb 13                	jmp    800492 <dev_lookup+0x23>
  80047f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800482:	39 08                	cmp    %ecx,(%eax)
  800484:	75 0c                	jne    800492 <dev_lookup+0x23>
			*dev = devtab[i];
  800486:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800489:	89 01                	mov    %eax,(%ecx)
			return 0;
  80048b:	b8 00 00 00 00       	mov    $0x0,%eax
  800490:	eb 2e                	jmp    8004c0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800492:	8b 02                	mov    (%edx),%eax
  800494:	85 c0                	test   %eax,%eax
  800496:	75 e7                	jne    80047f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800498:	a1 04 40 80 00       	mov    0x804004,%eax
  80049d:	8b 40 48             	mov    0x48(%eax),%eax
  8004a0:	83 ec 04             	sub    $0x4,%esp
  8004a3:	51                   	push   %ecx
  8004a4:	50                   	push   %eax
  8004a5:	68 64 1e 80 00       	push   $0x801e64
  8004aa:	e8 b7 0c 00 00       	call   801166 <cprintf>
	*dev = 0;
  8004af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    

008004c2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	56                   	push   %esi
  8004c6:	53                   	push   %ebx
  8004c7:	83 ec 10             	sub    $0x10,%esp
  8004ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004da:	c1 e8 0c             	shr    $0xc,%eax
  8004dd:	50                   	push   %eax
  8004de:	e8 36 ff ff ff       	call   800419 <fd_lookup>
  8004e3:	83 c4 08             	add    $0x8,%esp
  8004e6:	85 c0                	test   %eax,%eax
  8004e8:	78 05                	js     8004ef <fd_close+0x2d>
	    || fd != fd2)
  8004ea:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004ed:	74 0c                	je     8004fb <fd_close+0x39>
		return (must_exist ? r : 0);
  8004ef:	84 db                	test   %bl,%bl
  8004f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f6:	0f 44 c2             	cmove  %edx,%eax
  8004f9:	eb 41                	jmp    80053c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800501:	50                   	push   %eax
  800502:	ff 36                	pushl  (%esi)
  800504:	e8 66 ff ff ff       	call   80046f <dev_lookup>
  800509:	89 c3                	mov    %eax,%ebx
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	85 c0                	test   %eax,%eax
  800510:	78 1a                	js     80052c <fd_close+0x6a>
		if (dev->dev_close)
  800512:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800515:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800518:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80051d:	85 c0                	test   %eax,%eax
  80051f:	74 0b                	je     80052c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800521:	83 ec 0c             	sub    $0xc,%esp
  800524:	56                   	push   %esi
  800525:	ff d0                	call   *%eax
  800527:	89 c3                	mov    %eax,%ebx
  800529:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	56                   	push   %esi
  800530:	6a 00                	push   $0x0
  800532:	e8 00 fd ff ff       	call   800237 <sys_page_unmap>
	return r;
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	89 d8                	mov    %ebx,%eax
}
  80053c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80053f:	5b                   	pop    %ebx
  800540:	5e                   	pop    %esi
  800541:	5d                   	pop    %ebp
  800542:	c3                   	ret    

00800543 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800543:	55                   	push   %ebp
  800544:	89 e5                	mov    %esp,%ebp
  800546:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800549:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80054c:	50                   	push   %eax
  80054d:	ff 75 08             	pushl  0x8(%ebp)
  800550:	e8 c4 fe ff ff       	call   800419 <fd_lookup>
  800555:	83 c4 08             	add    $0x8,%esp
  800558:	85 c0                	test   %eax,%eax
  80055a:	78 10                	js     80056c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	6a 01                	push   $0x1
  800561:	ff 75 f4             	pushl  -0xc(%ebp)
  800564:	e8 59 ff ff ff       	call   8004c2 <fd_close>
  800569:	83 c4 10             	add    $0x10,%esp
}
  80056c:	c9                   	leave  
  80056d:	c3                   	ret    

0080056e <close_all>:

void
close_all(void)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	53                   	push   %ebx
  800572:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800575:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80057a:	83 ec 0c             	sub    $0xc,%esp
  80057d:	53                   	push   %ebx
  80057e:	e8 c0 ff ff ff       	call   800543 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800583:	83 c3 01             	add    $0x1,%ebx
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	83 fb 20             	cmp    $0x20,%ebx
  80058c:	75 ec                	jne    80057a <close_all+0xc>
		close(i);
}
  80058e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800591:	c9                   	leave  
  800592:	c3                   	ret    

00800593 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800593:	55                   	push   %ebp
  800594:	89 e5                	mov    %esp,%ebp
  800596:	57                   	push   %edi
  800597:	56                   	push   %esi
  800598:	53                   	push   %ebx
  800599:	83 ec 2c             	sub    $0x2c,%esp
  80059c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80059f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a2:	50                   	push   %eax
  8005a3:	ff 75 08             	pushl  0x8(%ebp)
  8005a6:	e8 6e fe ff ff       	call   800419 <fd_lookup>
  8005ab:	83 c4 08             	add    $0x8,%esp
  8005ae:	85 c0                	test   %eax,%eax
  8005b0:	0f 88 c1 00 00 00    	js     800677 <dup+0xe4>
		return r;
	close(newfdnum);
  8005b6:	83 ec 0c             	sub    $0xc,%esp
  8005b9:	56                   	push   %esi
  8005ba:	e8 84 ff ff ff       	call   800543 <close>

	newfd = INDEX2FD(newfdnum);
  8005bf:	89 f3                	mov    %esi,%ebx
  8005c1:	c1 e3 0c             	shl    $0xc,%ebx
  8005c4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ca:	83 c4 04             	add    $0x4,%esp
  8005cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d0:	e8 de fd ff ff       	call   8003b3 <fd2data>
  8005d5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005d7:	89 1c 24             	mov    %ebx,(%esp)
  8005da:	e8 d4 fd ff ff       	call   8003b3 <fd2data>
  8005df:	83 c4 10             	add    $0x10,%esp
  8005e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e5:	89 f8                	mov    %edi,%eax
  8005e7:	c1 e8 16             	shr    $0x16,%eax
  8005ea:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f1:	a8 01                	test   $0x1,%al
  8005f3:	74 37                	je     80062c <dup+0x99>
  8005f5:	89 f8                	mov    %edi,%eax
  8005f7:	c1 e8 0c             	shr    $0xc,%eax
  8005fa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800601:	f6 c2 01             	test   $0x1,%dl
  800604:	74 26                	je     80062c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800606:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060d:	83 ec 0c             	sub    $0xc,%esp
  800610:	25 07 0e 00 00       	and    $0xe07,%eax
  800615:	50                   	push   %eax
  800616:	ff 75 d4             	pushl  -0x2c(%ebp)
  800619:	6a 00                	push   $0x0
  80061b:	57                   	push   %edi
  80061c:	6a 00                	push   $0x0
  80061e:	e8 d2 fb ff ff       	call   8001f5 <sys_page_map>
  800623:	89 c7                	mov    %eax,%edi
  800625:	83 c4 20             	add    $0x20,%esp
  800628:	85 c0                	test   %eax,%eax
  80062a:	78 2e                	js     80065a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062f:	89 d0                	mov    %edx,%eax
  800631:	c1 e8 0c             	shr    $0xc,%eax
  800634:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80063b:	83 ec 0c             	sub    $0xc,%esp
  80063e:	25 07 0e 00 00       	and    $0xe07,%eax
  800643:	50                   	push   %eax
  800644:	53                   	push   %ebx
  800645:	6a 00                	push   $0x0
  800647:	52                   	push   %edx
  800648:	6a 00                	push   $0x0
  80064a:	e8 a6 fb ff ff       	call   8001f5 <sys_page_map>
  80064f:	89 c7                	mov    %eax,%edi
  800651:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800654:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800656:	85 ff                	test   %edi,%edi
  800658:	79 1d                	jns    800677 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 00                	push   $0x0
  800660:	e8 d2 fb ff ff       	call   800237 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800665:	83 c4 08             	add    $0x8,%esp
  800668:	ff 75 d4             	pushl  -0x2c(%ebp)
  80066b:	6a 00                	push   $0x0
  80066d:	e8 c5 fb ff ff       	call   800237 <sys_page_unmap>
	return r;
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	89 f8                	mov    %edi,%eax
}
  800677:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067a:	5b                   	pop    %ebx
  80067b:	5e                   	pop    %esi
  80067c:	5f                   	pop    %edi
  80067d:	5d                   	pop    %ebp
  80067e:	c3                   	ret    

0080067f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	53                   	push   %ebx
  800683:	83 ec 14             	sub    $0x14,%esp
  800686:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800689:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80068c:	50                   	push   %eax
  80068d:	53                   	push   %ebx
  80068e:	e8 86 fd ff ff       	call   800419 <fd_lookup>
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	89 c2                	mov    %eax,%edx
  800698:	85 c0                	test   %eax,%eax
  80069a:	78 6d                	js     800709 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a2:	50                   	push   %eax
  8006a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a6:	ff 30                	pushl  (%eax)
  8006a8:	e8 c2 fd ff ff       	call   80046f <dev_lookup>
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	78 4c                	js     800700 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006b7:	8b 42 08             	mov    0x8(%edx),%eax
  8006ba:	83 e0 03             	and    $0x3,%eax
  8006bd:	83 f8 01             	cmp    $0x1,%eax
  8006c0:	75 21                	jne    8006e3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8006c7:	8b 40 48             	mov    0x48(%eax),%eax
  8006ca:	83 ec 04             	sub    $0x4,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	50                   	push   %eax
  8006cf:	68 a5 1e 80 00       	push   $0x801ea5
  8006d4:	e8 8d 0a 00 00       	call   801166 <cprintf>
		return -E_INVAL;
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006e1:	eb 26                	jmp    800709 <read+0x8a>
	}
	if (!dev->dev_read)
  8006e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e6:	8b 40 08             	mov    0x8(%eax),%eax
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 17                	je     800704 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8006ed:	83 ec 04             	sub    $0x4,%esp
  8006f0:	ff 75 10             	pushl  0x10(%ebp)
  8006f3:	ff 75 0c             	pushl  0xc(%ebp)
  8006f6:	52                   	push   %edx
  8006f7:	ff d0                	call   *%eax
  8006f9:	89 c2                	mov    %eax,%edx
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	eb 09                	jmp    800709 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800700:	89 c2                	mov    %eax,%edx
  800702:	eb 05                	jmp    800709 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800704:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800709:	89 d0                	mov    %edx,%eax
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	57                   	push   %edi
  800714:	56                   	push   %esi
  800715:	53                   	push   %ebx
  800716:	83 ec 0c             	sub    $0xc,%esp
  800719:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800724:	eb 21                	jmp    800747 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800726:	83 ec 04             	sub    $0x4,%esp
  800729:	89 f0                	mov    %esi,%eax
  80072b:	29 d8                	sub    %ebx,%eax
  80072d:	50                   	push   %eax
  80072e:	89 d8                	mov    %ebx,%eax
  800730:	03 45 0c             	add    0xc(%ebp),%eax
  800733:	50                   	push   %eax
  800734:	57                   	push   %edi
  800735:	e8 45 ff ff ff       	call   80067f <read>
		if (m < 0)
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	85 c0                	test   %eax,%eax
  80073f:	78 10                	js     800751 <readn+0x41>
			return m;
		if (m == 0)
  800741:	85 c0                	test   %eax,%eax
  800743:	74 0a                	je     80074f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800745:	01 c3                	add    %eax,%ebx
  800747:	39 f3                	cmp    %esi,%ebx
  800749:	72 db                	jb     800726 <readn+0x16>
  80074b:	89 d8                	mov    %ebx,%eax
  80074d:	eb 02                	jmp    800751 <readn+0x41>
  80074f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800751:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800754:	5b                   	pop    %ebx
  800755:	5e                   	pop    %esi
  800756:	5f                   	pop    %edi
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	83 ec 14             	sub    $0x14,%esp
  800760:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800763:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800766:	50                   	push   %eax
  800767:	53                   	push   %ebx
  800768:	e8 ac fc ff ff       	call   800419 <fd_lookup>
  80076d:	83 c4 08             	add    $0x8,%esp
  800770:	89 c2                	mov    %eax,%edx
  800772:	85 c0                	test   %eax,%eax
  800774:	78 68                	js     8007de <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800776:	83 ec 08             	sub    $0x8,%esp
  800779:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077c:	50                   	push   %eax
  80077d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800780:	ff 30                	pushl  (%eax)
  800782:	e8 e8 fc ff ff       	call   80046f <dev_lookup>
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	85 c0                	test   %eax,%eax
  80078c:	78 47                	js     8007d5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800791:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800795:	75 21                	jne    8007b8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800797:	a1 04 40 80 00       	mov    0x804004,%eax
  80079c:	8b 40 48             	mov    0x48(%eax),%eax
  80079f:	83 ec 04             	sub    $0x4,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	50                   	push   %eax
  8007a4:	68 c1 1e 80 00       	push   $0x801ec1
  8007a9:	e8 b8 09 00 00       	call   801166 <cprintf>
		return -E_INVAL;
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007b6:	eb 26                	jmp    8007de <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007bb:	8b 52 0c             	mov    0xc(%edx),%edx
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	74 17                	je     8007d9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c2:	83 ec 04             	sub    $0x4,%esp
  8007c5:	ff 75 10             	pushl  0x10(%ebp)
  8007c8:	ff 75 0c             	pushl  0xc(%ebp)
  8007cb:	50                   	push   %eax
  8007cc:	ff d2                	call   *%edx
  8007ce:	89 c2                	mov    %eax,%edx
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	eb 09                	jmp    8007de <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d5:	89 c2                	mov    %eax,%edx
  8007d7:	eb 05                	jmp    8007de <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007de:	89 d0                	mov    %edx,%eax
  8007e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007eb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007ee:	50                   	push   %eax
  8007ef:	ff 75 08             	pushl  0x8(%ebp)
  8007f2:	e8 22 fc ff ff       	call   800419 <fd_lookup>
  8007f7:	83 c4 08             	add    $0x8,%esp
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	78 0e                	js     80080c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
  800804:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	53                   	push   %ebx
  800812:	83 ec 14             	sub    $0x14,%esp
  800815:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800818:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081b:	50                   	push   %eax
  80081c:	53                   	push   %ebx
  80081d:	e8 f7 fb ff ff       	call   800419 <fd_lookup>
  800822:	83 c4 08             	add    $0x8,%esp
  800825:	89 c2                	mov    %eax,%edx
  800827:	85 c0                	test   %eax,%eax
  800829:	78 65                	js     800890 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800831:	50                   	push   %eax
  800832:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800835:	ff 30                	pushl  (%eax)
  800837:	e8 33 fc ff ff       	call   80046f <dev_lookup>
  80083c:	83 c4 10             	add    $0x10,%esp
  80083f:	85 c0                	test   %eax,%eax
  800841:	78 44                	js     800887 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800843:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800846:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80084a:	75 21                	jne    80086d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80084c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800851:	8b 40 48             	mov    0x48(%eax),%eax
  800854:	83 ec 04             	sub    $0x4,%esp
  800857:	53                   	push   %ebx
  800858:	50                   	push   %eax
  800859:	68 84 1e 80 00       	push   $0x801e84
  80085e:	e8 03 09 00 00       	call   801166 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800863:	83 c4 10             	add    $0x10,%esp
  800866:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80086b:	eb 23                	jmp    800890 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80086d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800870:	8b 52 18             	mov    0x18(%edx),%edx
  800873:	85 d2                	test   %edx,%edx
  800875:	74 14                	je     80088b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800877:	83 ec 08             	sub    $0x8,%esp
  80087a:	ff 75 0c             	pushl  0xc(%ebp)
  80087d:	50                   	push   %eax
  80087e:	ff d2                	call   *%edx
  800880:	89 c2                	mov    %eax,%edx
  800882:	83 c4 10             	add    $0x10,%esp
  800885:	eb 09                	jmp    800890 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800887:	89 c2                	mov    %eax,%edx
  800889:	eb 05                	jmp    800890 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80088b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800890:	89 d0                	mov    %edx,%eax
  800892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	83 ec 14             	sub    $0x14,%esp
  80089e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a4:	50                   	push   %eax
  8008a5:	ff 75 08             	pushl  0x8(%ebp)
  8008a8:	e8 6c fb ff ff       	call   800419 <fd_lookup>
  8008ad:	83 c4 08             	add    $0x8,%esp
  8008b0:	89 c2                	mov    %eax,%edx
  8008b2:	85 c0                	test   %eax,%eax
  8008b4:	78 58                	js     80090e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008bc:	50                   	push   %eax
  8008bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c0:	ff 30                	pushl  (%eax)
  8008c2:	e8 a8 fb ff ff       	call   80046f <dev_lookup>
  8008c7:	83 c4 10             	add    $0x10,%esp
  8008ca:	85 c0                	test   %eax,%eax
  8008cc:	78 37                	js     800905 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d5:	74 32                	je     800909 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008d7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008da:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008e1:	00 00 00 
	stat->st_isdir = 0;
  8008e4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008eb:	00 00 00 
	stat->st_dev = dev;
  8008ee:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	53                   	push   %ebx
  8008f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8008fb:	ff 50 14             	call   *0x14(%eax)
  8008fe:	89 c2                	mov    %eax,%edx
  800900:	83 c4 10             	add    $0x10,%esp
  800903:	eb 09                	jmp    80090e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800905:	89 c2                	mov    %eax,%edx
  800907:	eb 05                	jmp    80090e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800909:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80090e:	89 d0                	mov    %edx,%eax
  800910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80091a:	83 ec 08             	sub    $0x8,%esp
  80091d:	6a 00                	push   $0x0
  80091f:	ff 75 08             	pushl  0x8(%ebp)
  800922:	e8 e3 01 00 00       	call   800b0a <open>
  800927:	89 c3                	mov    %eax,%ebx
  800929:	83 c4 10             	add    $0x10,%esp
  80092c:	85 c0                	test   %eax,%eax
  80092e:	78 1b                	js     80094b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	ff 75 0c             	pushl  0xc(%ebp)
  800936:	50                   	push   %eax
  800937:	e8 5b ff ff ff       	call   800897 <fstat>
  80093c:	89 c6                	mov    %eax,%esi
	close(fd);
  80093e:	89 1c 24             	mov    %ebx,(%esp)
  800941:	e8 fd fb ff ff       	call   800543 <close>
	return r;
  800946:	83 c4 10             	add    $0x10,%esp
  800949:	89 f0                	mov    %esi,%eax
}
  80094b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	89 c6                	mov    %eax,%esi
  800959:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80095b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800962:	75 12                	jne    800976 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800964:	83 ec 0c             	sub    $0xc,%esp
  800967:	6a 01                	push   $0x1
  800969:	e8 98 11 00 00       	call   801b06 <ipc_find_env>
  80096e:	a3 00 40 80 00       	mov    %eax,0x804000
  800973:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800976:	6a 07                	push   $0x7
  800978:	68 00 50 80 00       	push   $0x805000
  80097d:	56                   	push   %esi
  80097e:	ff 35 00 40 80 00    	pushl  0x804000
  800984:	e8 1b 11 00 00       	call   801aa4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800989:	83 c4 0c             	add    $0xc,%esp
  80098c:	6a 00                	push   $0x0
  80098e:	53                   	push   %ebx
  80098f:	6a 00                	push   $0x0
  800991:	e8 9c 10 00 00       	call   801a32 <ipc_recv>
}
  800996:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8009c0:	e8 8d ff ff ff       	call   800952 <fsipc>
}
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009dd:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e2:	e8 6b ff ff ff       	call   800952 <fsipc>
}
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	53                   	push   %ebx
  8009ed:	83 ec 04             	sub    $0x4,%esp
  8009f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800a03:	b8 05 00 00 00       	mov    $0x5,%eax
  800a08:	e8 45 ff ff ff       	call   800952 <fsipc>
  800a0d:	85 c0                	test   %eax,%eax
  800a0f:	78 2c                	js     800a3d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a11:	83 ec 08             	sub    $0x8,%esp
  800a14:	68 00 50 80 00       	push   $0x805000
  800a19:	53                   	push   %ebx
  800a1a:	e8 cc 0c 00 00       	call   8016eb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a1f:	a1 80 50 80 00       	mov    0x805080,%eax
  800a24:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a2a:	a1 84 50 80 00       	mov    0x805084,%eax
  800a2f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a35:	83 c4 10             	add    $0x10,%esp
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a40:	c9                   	leave  
  800a41:	c3                   	ret    

00800a42 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	83 ec 0c             	sub    $0xc,%esp
  800a48:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4e:	8b 52 0c             	mov    0xc(%edx),%edx
  800a51:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a57:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a5c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a61:	0f 47 c2             	cmova  %edx,%eax
  800a64:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a69:	50                   	push   %eax
  800a6a:	ff 75 0c             	pushl  0xc(%ebp)
  800a6d:	68 08 50 80 00       	push   $0x805008
  800a72:	e8 06 0e 00 00       	call   80187d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a77:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a81:	e8 cc fe ff ff       	call   800952 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	8b 40 0c             	mov    0xc(%eax),%eax
  800a96:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a9b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 03 00 00 00       	mov    $0x3,%eax
  800aab:	e8 a2 fe ff ff       	call   800952 <fsipc>
  800ab0:	89 c3                	mov    %eax,%ebx
  800ab2:	85 c0                	test   %eax,%eax
  800ab4:	78 4b                	js     800b01 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab6:	39 c6                	cmp    %eax,%esi
  800ab8:	73 16                	jae    800ad0 <devfile_read+0x48>
  800aba:	68 f0 1e 80 00       	push   $0x801ef0
  800abf:	68 f7 1e 80 00       	push   $0x801ef7
  800ac4:	6a 7c                	push   $0x7c
  800ac6:	68 0c 1f 80 00       	push   $0x801f0c
  800acb:	e8 bd 05 00 00       	call   80108d <_panic>
	assert(r <= PGSIZE);
  800ad0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad5:	7e 16                	jle    800aed <devfile_read+0x65>
  800ad7:	68 17 1f 80 00       	push   $0x801f17
  800adc:	68 f7 1e 80 00       	push   $0x801ef7
  800ae1:	6a 7d                	push   $0x7d
  800ae3:	68 0c 1f 80 00       	push   $0x801f0c
  800ae8:	e8 a0 05 00 00       	call   80108d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aed:	83 ec 04             	sub    $0x4,%esp
  800af0:	50                   	push   %eax
  800af1:	68 00 50 80 00       	push   $0x805000
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	e8 7f 0d 00 00       	call   80187d <memmove>
	return r;
  800afe:	83 c4 10             	add    $0x10,%esp
}
  800b01:	89 d8                	mov    %ebx,%eax
  800b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 20             	sub    $0x20,%esp
  800b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b14:	53                   	push   %ebx
  800b15:	e8 98 0b 00 00       	call   8016b2 <strlen>
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b22:	7f 67                	jg     800b8b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b24:	83 ec 0c             	sub    $0xc,%esp
  800b27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2a:	50                   	push   %eax
  800b2b:	e8 9a f8 ff ff       	call   8003ca <fd_alloc>
  800b30:	83 c4 10             	add    $0x10,%esp
		return r;
  800b33:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	78 57                	js     800b90 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b39:	83 ec 08             	sub    $0x8,%esp
  800b3c:	53                   	push   %ebx
  800b3d:	68 00 50 80 00       	push   $0x805000
  800b42:	e8 a4 0b 00 00       	call   8016eb <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b52:	b8 01 00 00 00       	mov    $0x1,%eax
  800b57:	e8 f6 fd ff ff       	call   800952 <fsipc>
  800b5c:	89 c3                	mov    %eax,%ebx
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	85 c0                	test   %eax,%eax
  800b63:	79 14                	jns    800b79 <open+0x6f>
		fd_close(fd, 0);
  800b65:	83 ec 08             	sub    $0x8,%esp
  800b68:	6a 00                	push   $0x0
  800b6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6d:	e8 50 f9 ff ff       	call   8004c2 <fd_close>
		return r;
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	89 da                	mov    %ebx,%edx
  800b77:	eb 17                	jmp    800b90 <open+0x86>
	}

	return fd2num(fd);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7f:	e8 1f f8 ff ff       	call   8003a3 <fd2num>
  800b84:	89 c2                	mov    %eax,%edx
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	eb 05                	jmp    800b90 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b8b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b90:	89 d0                	mov    %edx,%eax
  800b92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba7:	e8 a6 fd ff ff       	call   800952 <fsipc>
}
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	ff 75 08             	pushl  0x8(%ebp)
  800bbc:	e8 f2 f7 ff ff       	call   8003b3 <fd2data>
  800bc1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bc3:	83 c4 08             	add    $0x8,%esp
  800bc6:	68 23 1f 80 00       	push   $0x801f23
  800bcb:	53                   	push   %ebx
  800bcc:	e8 1a 0b 00 00       	call   8016eb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bd1:	8b 46 04             	mov    0x4(%esi),%eax
  800bd4:	2b 06                	sub    (%esi),%eax
  800bd6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bdc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be3:	00 00 00 
	stat->st_dev = &devpipe;
  800be6:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800bed:	30 80 00 
	return 0;
}
  800bf0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	53                   	push   %ebx
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c06:	53                   	push   %ebx
  800c07:	6a 00                	push   $0x0
  800c09:	e8 29 f6 ff ff       	call   800237 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c0e:	89 1c 24             	mov    %ebx,(%esp)
  800c11:	e8 9d f7 ff ff       	call   8003b3 <fd2data>
  800c16:	83 c4 08             	add    $0x8,%esp
  800c19:	50                   	push   %eax
  800c1a:	6a 00                	push   $0x0
  800c1c:	e8 16 f6 ff ff       	call   800237 <sys_page_unmap>
}
  800c21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 1c             	sub    $0x1c,%esp
  800c2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c32:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c34:	a1 04 40 80 00       	mov    0x804004,%eax
  800c39:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	ff 75 e0             	pushl  -0x20(%ebp)
  800c42:	e8 f8 0e 00 00       	call   801b3f <pageref>
  800c47:	89 c3                	mov    %eax,%ebx
  800c49:	89 3c 24             	mov    %edi,(%esp)
  800c4c:	e8 ee 0e 00 00       	call   801b3f <pageref>
  800c51:	83 c4 10             	add    $0x10,%esp
  800c54:	39 c3                	cmp    %eax,%ebx
  800c56:	0f 94 c1             	sete   %cl
  800c59:	0f b6 c9             	movzbl %cl,%ecx
  800c5c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c5f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c65:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c68:	39 ce                	cmp    %ecx,%esi
  800c6a:	74 1b                	je     800c87 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c6c:	39 c3                	cmp    %eax,%ebx
  800c6e:	75 c4                	jne    800c34 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c70:	8b 42 58             	mov    0x58(%edx),%eax
  800c73:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c76:	50                   	push   %eax
  800c77:	56                   	push   %esi
  800c78:	68 2a 1f 80 00       	push   $0x801f2a
  800c7d:	e8 e4 04 00 00       	call   801166 <cprintf>
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	eb ad                	jmp    800c34 <_pipeisclosed+0xe>
	}
}
  800c87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
  800c98:	83 ec 28             	sub    $0x28,%esp
  800c9b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c9e:	56                   	push   %esi
  800c9f:	e8 0f f7 ff ff       	call   8003b3 <fd2data>
  800ca4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca6:	83 c4 10             	add    $0x10,%esp
  800ca9:	bf 00 00 00 00       	mov    $0x0,%edi
  800cae:	eb 4b                	jmp    800cfb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cb0:	89 da                	mov    %ebx,%edx
  800cb2:	89 f0                	mov    %esi,%eax
  800cb4:	e8 6d ff ff ff       	call   800c26 <_pipeisclosed>
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	75 48                	jne    800d05 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cbd:	e8 d1 f4 ff ff       	call   800193 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cc2:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc5:	8b 0b                	mov    (%ebx),%ecx
  800cc7:	8d 51 20             	lea    0x20(%ecx),%edx
  800cca:	39 d0                	cmp    %edx,%eax
  800ccc:	73 e2                	jae    800cb0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cd5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd8:	89 c2                	mov    %eax,%edx
  800cda:	c1 fa 1f             	sar    $0x1f,%edx
  800cdd:	89 d1                	mov    %edx,%ecx
  800cdf:	c1 e9 1b             	shr    $0x1b,%ecx
  800ce2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ce5:	83 e2 1f             	and    $0x1f,%edx
  800ce8:	29 ca                	sub    %ecx,%edx
  800cea:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cf2:	83 c0 01             	add    $0x1,%eax
  800cf5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf8:	83 c7 01             	add    $0x1,%edi
  800cfb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cfe:	75 c2                	jne    800cc2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d00:	8b 45 10             	mov    0x10(%ebp),%eax
  800d03:	eb 05                	jmp    800d0a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 18             	sub    $0x18,%esp
  800d1b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d1e:	57                   	push   %edi
  800d1f:	e8 8f f6 ff ff       	call   8003b3 <fd2data>
  800d24:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d26:	83 c4 10             	add    $0x10,%esp
  800d29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2e:	eb 3d                	jmp    800d6d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d30:	85 db                	test   %ebx,%ebx
  800d32:	74 04                	je     800d38 <devpipe_read+0x26>
				return i;
  800d34:	89 d8                	mov    %ebx,%eax
  800d36:	eb 44                	jmp    800d7c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d38:	89 f2                	mov    %esi,%edx
  800d3a:	89 f8                	mov    %edi,%eax
  800d3c:	e8 e5 fe ff ff       	call   800c26 <_pipeisclosed>
  800d41:	85 c0                	test   %eax,%eax
  800d43:	75 32                	jne    800d77 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d45:	e8 49 f4 ff ff       	call   800193 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d4a:	8b 06                	mov    (%esi),%eax
  800d4c:	3b 46 04             	cmp    0x4(%esi),%eax
  800d4f:	74 df                	je     800d30 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d51:	99                   	cltd   
  800d52:	c1 ea 1b             	shr    $0x1b,%edx
  800d55:	01 d0                	add    %edx,%eax
  800d57:	83 e0 1f             	and    $0x1f,%eax
  800d5a:	29 d0                	sub    %edx,%eax
  800d5c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d67:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d6a:	83 c3 01             	add    $0x1,%ebx
  800d6d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d70:	75 d8                	jne    800d4a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d72:	8b 45 10             	mov    0x10(%ebp),%eax
  800d75:	eb 05                	jmp    800d7c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d77:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d8f:	50                   	push   %eax
  800d90:	e8 35 f6 ff ff       	call   8003ca <fd_alloc>
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	89 c2                	mov    %eax,%edx
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	0f 88 2c 01 00 00    	js     800ece <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da2:	83 ec 04             	sub    $0x4,%esp
  800da5:	68 07 04 00 00       	push   $0x407
  800daa:	ff 75 f4             	pushl  -0xc(%ebp)
  800dad:	6a 00                	push   $0x0
  800daf:	e8 fe f3 ff ff       	call   8001b2 <sys_page_alloc>
  800db4:	83 c4 10             	add    $0x10,%esp
  800db7:	89 c2                	mov    %eax,%edx
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	0f 88 0d 01 00 00    	js     800ece <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc7:	50                   	push   %eax
  800dc8:	e8 fd f5 ff ff       	call   8003ca <fd_alloc>
  800dcd:	89 c3                	mov    %eax,%ebx
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	0f 88 e2 00 00 00    	js     800ebc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dda:	83 ec 04             	sub    $0x4,%esp
  800ddd:	68 07 04 00 00       	push   $0x407
  800de2:	ff 75 f0             	pushl  -0x10(%ebp)
  800de5:	6a 00                	push   $0x0
  800de7:	e8 c6 f3 ff ff       	call   8001b2 <sys_page_alloc>
  800dec:	89 c3                	mov    %eax,%ebx
  800dee:	83 c4 10             	add    $0x10,%esp
  800df1:	85 c0                	test   %eax,%eax
  800df3:	0f 88 c3 00 00 00    	js     800ebc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df9:	83 ec 0c             	sub    $0xc,%esp
  800dfc:	ff 75 f4             	pushl  -0xc(%ebp)
  800dff:	e8 af f5 ff ff       	call   8003b3 <fd2data>
  800e04:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e06:	83 c4 0c             	add    $0xc,%esp
  800e09:	68 07 04 00 00       	push   $0x407
  800e0e:	50                   	push   %eax
  800e0f:	6a 00                	push   $0x0
  800e11:	e8 9c f3 ff ff       	call   8001b2 <sys_page_alloc>
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	0f 88 89 00 00 00    	js     800eac <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	ff 75 f0             	pushl  -0x10(%ebp)
  800e29:	e8 85 f5 ff ff       	call   8003b3 <fd2data>
  800e2e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e35:	50                   	push   %eax
  800e36:	6a 00                	push   $0x0
  800e38:	56                   	push   %esi
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 b5 f3 ff ff       	call   8001f5 <sys_page_map>
  800e40:	89 c3                	mov    %eax,%ebx
  800e42:	83 c4 20             	add    $0x20,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	78 55                	js     800e9e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e49:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e52:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e57:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e5e:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e67:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	ff 75 f4             	pushl  -0xc(%ebp)
  800e79:	e8 25 f5 ff ff       	call   8003a3 <fd2num>
  800e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e81:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e83:	83 c4 04             	add    $0x4,%esp
  800e86:	ff 75 f0             	pushl  -0x10(%ebp)
  800e89:	e8 15 f5 ff ff       	call   8003a3 <fd2num>
  800e8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e91:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9c:	eb 30                	jmp    800ece <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e9e:	83 ec 08             	sub    $0x8,%esp
  800ea1:	56                   	push   %esi
  800ea2:	6a 00                	push   $0x0
  800ea4:	e8 8e f3 ff ff       	call   800237 <sys_page_unmap>
  800ea9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb2:	6a 00                	push   $0x0
  800eb4:	e8 7e f3 ff ff       	call   800237 <sys_page_unmap>
  800eb9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ebc:	83 ec 08             	sub    $0x8,%esp
  800ebf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec2:	6a 00                	push   $0x0
  800ec4:	e8 6e f3 ff ff       	call   800237 <sys_page_unmap>
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ece:	89 d0                	mov    %edx,%eax
  800ed0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800edd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee0:	50                   	push   %eax
  800ee1:	ff 75 08             	pushl  0x8(%ebp)
  800ee4:	e8 30 f5 ff ff       	call   800419 <fd_lookup>
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	78 18                	js     800f08 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ef0:	83 ec 0c             	sub    $0xc,%esp
  800ef3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef6:	e8 b8 f4 ff ff       	call   8003b3 <fd2data>
	return _pipeisclosed(fd, p);
  800efb:	89 c2                	mov    %eax,%edx
  800efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f00:	e8 21 fd ff ff       	call   800c26 <_pipeisclosed>
  800f05:	83 c4 10             	add    $0x10,%esp
}
  800f08:	c9                   	leave  
  800f09:	c3                   	ret    

00800f0a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    

00800f14 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f1a:	68 42 1f 80 00       	push   $0x801f42
  800f1f:	ff 75 0c             	pushl  0xc(%ebp)
  800f22:	e8 c4 07 00 00       	call   8016eb <strcpy>
	return 0;
}
  800f27:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    

00800f2e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f3f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f45:	eb 2d                	jmp    800f74 <devcons_write+0x46>
		m = n - tot;
  800f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f4c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f4f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f54:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f57:	83 ec 04             	sub    $0x4,%esp
  800f5a:	53                   	push   %ebx
  800f5b:	03 45 0c             	add    0xc(%ebp),%eax
  800f5e:	50                   	push   %eax
  800f5f:	57                   	push   %edi
  800f60:	e8 18 09 00 00       	call   80187d <memmove>
		sys_cputs(buf, m);
  800f65:	83 c4 08             	add    $0x8,%esp
  800f68:	53                   	push   %ebx
  800f69:	57                   	push   %edi
  800f6a:	e8 87 f1 ff ff       	call   8000f6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f6f:	01 de                	add    %ebx,%esi
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	89 f0                	mov    %esi,%eax
  800f76:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f79:	72 cc                	jb     800f47 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f92:	74 2a                	je     800fbe <devcons_read+0x3b>
  800f94:	eb 05                	jmp    800f9b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f96:	e8 f8 f1 ff ff       	call   800193 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f9b:	e8 74 f1 ff ff       	call   800114 <sys_cgetc>
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	74 f2                	je     800f96 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 16                	js     800fbe <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa8:	83 f8 04             	cmp    $0x4,%eax
  800fab:	74 0c                	je     800fb9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb0:	88 02                	mov    %al,(%edx)
	return 1;
  800fb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb7:	eb 05                	jmp    800fbe <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fb9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fcc:	6a 01                	push   $0x1
  800fce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd1:	50                   	push   %eax
  800fd2:	e8 1f f1 ff ff       	call   8000f6 <sys_cputs>
}
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <getchar>:

int
getchar(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fe2:	6a 01                	push   $0x1
  800fe4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 90 f6 ff ff       	call   80067f <read>
	if (r < 0)
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 0f                	js     801005 <getchar+0x29>
		return r;
	if (r < 1)
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	7e 06                	jle    801000 <getchar+0x24>
		return -E_EOF;
	return c;
  800ffa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ffe:	eb 05                	jmp    801005 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801000:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801010:	50                   	push   %eax
  801011:	ff 75 08             	pushl  0x8(%ebp)
  801014:	e8 00 f4 ff ff       	call   800419 <fd_lookup>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 11                	js     801031 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801023:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801029:	39 10                	cmp    %edx,(%eax)
  80102b:	0f 94 c0             	sete   %al
  80102e:	0f b6 c0             	movzbl %al,%eax
}
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <opencons>:

int
opencons(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103c:	50                   	push   %eax
  80103d:	e8 88 f3 ff ff       	call   8003ca <fd_alloc>
  801042:	83 c4 10             	add    $0x10,%esp
		return r;
  801045:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801047:	85 c0                	test   %eax,%eax
  801049:	78 3e                	js     801089 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	68 07 04 00 00       	push   $0x407
  801053:	ff 75 f4             	pushl  -0xc(%ebp)
  801056:	6a 00                	push   $0x0
  801058:	e8 55 f1 ff ff       	call   8001b2 <sys_page_alloc>
  80105d:	83 c4 10             	add    $0x10,%esp
		return r;
  801060:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801062:	85 c0                	test   %eax,%eax
  801064:	78 23                	js     801089 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801066:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80106c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801071:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801074:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	50                   	push   %eax
  80107f:	e8 1f f3 ff ff       	call   8003a3 <fd2num>
  801084:	89 c2                	mov    %eax,%edx
  801086:	83 c4 10             	add    $0x10,%esp
}
  801089:	89 d0                	mov    %edx,%eax
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801092:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801095:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80109b:	e8 d4 f0 ff ff       	call   800174 <sys_getenvid>
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	ff 75 0c             	pushl  0xc(%ebp)
  8010a6:	ff 75 08             	pushl  0x8(%ebp)
  8010a9:	56                   	push   %esi
  8010aa:	50                   	push   %eax
  8010ab:	68 50 1f 80 00       	push   $0x801f50
  8010b0:	e8 b1 00 00 00       	call   801166 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010b5:	83 c4 18             	add    $0x18,%esp
  8010b8:	53                   	push   %ebx
  8010b9:	ff 75 10             	pushl  0x10(%ebp)
  8010bc:	e8 54 00 00 00       	call   801115 <vcprintf>
	cprintf("\n");
  8010c1:	c7 04 24 3b 1f 80 00 	movl   $0x801f3b,(%esp)
  8010c8:	e8 99 00 00 00       	call   801166 <cprintf>
  8010cd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010d0:	cc                   	int3   
  8010d1:	eb fd                	jmp    8010d0 <_panic+0x43>

008010d3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 04             	sub    $0x4,%esp
  8010da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010dd:	8b 13                	mov    (%ebx),%edx
  8010df:	8d 42 01             	lea    0x1(%edx),%eax
  8010e2:	89 03                	mov    %eax,(%ebx)
  8010e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010eb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010f0:	75 1a                	jne    80110c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010f2:	83 ec 08             	sub    $0x8,%esp
  8010f5:	68 ff 00 00 00       	push   $0xff
  8010fa:	8d 43 08             	lea    0x8(%ebx),%eax
  8010fd:	50                   	push   %eax
  8010fe:	e8 f3 ef ff ff       	call   8000f6 <sys_cputs>
		b->idx = 0;
  801103:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801109:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80110c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801110:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801113:	c9                   	leave  
  801114:	c3                   	ret    

00801115 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80111e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801125:	00 00 00 
	b.cnt = 0;
  801128:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80112f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801132:	ff 75 0c             	pushl  0xc(%ebp)
  801135:	ff 75 08             	pushl  0x8(%ebp)
  801138:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80113e:	50                   	push   %eax
  80113f:	68 d3 10 80 00       	push   $0x8010d3
  801144:	e8 54 01 00 00       	call   80129d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801149:	83 c4 08             	add    $0x8,%esp
  80114c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801152:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801158:	50                   	push   %eax
  801159:	e8 98 ef ff ff       	call   8000f6 <sys_cputs>

	return b.cnt;
}
  80115e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80116c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80116f:	50                   	push   %eax
  801170:	ff 75 08             	pushl  0x8(%ebp)
  801173:	e8 9d ff ff ff       	call   801115 <vcprintf>
	va_end(ap);

	return cnt;
}
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 1c             	sub    $0x1c,%esp
  801183:	89 c7                	mov    %eax,%edi
  801185:	89 d6                	mov    %edx,%esi
  801187:	8b 45 08             	mov    0x8(%ebp),%eax
  80118a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801190:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801193:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801196:	bb 00 00 00 00       	mov    $0x0,%ebx
  80119b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80119e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8011a1:	39 d3                	cmp    %edx,%ebx
  8011a3:	72 05                	jb     8011aa <printnum+0x30>
  8011a5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011a8:	77 45                	ja     8011ef <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011aa:	83 ec 0c             	sub    $0xc,%esp
  8011ad:	ff 75 18             	pushl  0x18(%ebp)
  8011b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8011b3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011b6:	53                   	push   %ebx
  8011b7:	ff 75 10             	pushl  0x10(%ebp)
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c9:	e8 b2 09 00 00       	call   801b80 <__udivdi3>
  8011ce:	83 c4 18             	add    $0x18,%esp
  8011d1:	52                   	push   %edx
  8011d2:	50                   	push   %eax
  8011d3:	89 f2                	mov    %esi,%edx
  8011d5:	89 f8                	mov    %edi,%eax
  8011d7:	e8 9e ff ff ff       	call   80117a <printnum>
  8011dc:	83 c4 20             	add    $0x20,%esp
  8011df:	eb 18                	jmp    8011f9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	56                   	push   %esi
  8011e5:	ff 75 18             	pushl  0x18(%ebp)
  8011e8:	ff d7                	call   *%edi
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	eb 03                	jmp    8011f2 <printnum+0x78>
  8011ef:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011f2:	83 eb 01             	sub    $0x1,%ebx
  8011f5:	85 db                	test   %ebx,%ebx
  8011f7:	7f e8                	jg     8011e1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	56                   	push   %esi
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	ff 75 e4             	pushl  -0x1c(%ebp)
  801203:	ff 75 e0             	pushl  -0x20(%ebp)
  801206:	ff 75 dc             	pushl  -0x24(%ebp)
  801209:	ff 75 d8             	pushl  -0x28(%ebp)
  80120c:	e8 9f 0a 00 00       	call   801cb0 <__umoddi3>
  801211:	83 c4 14             	add    $0x14,%esp
  801214:	0f be 80 73 1f 80 00 	movsbl 0x801f73(%eax),%eax
  80121b:	50                   	push   %eax
  80121c:	ff d7                	call   *%edi
}
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80122c:	83 fa 01             	cmp    $0x1,%edx
  80122f:	7e 0e                	jle    80123f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801231:	8b 10                	mov    (%eax),%edx
  801233:	8d 4a 08             	lea    0x8(%edx),%ecx
  801236:	89 08                	mov    %ecx,(%eax)
  801238:	8b 02                	mov    (%edx),%eax
  80123a:	8b 52 04             	mov    0x4(%edx),%edx
  80123d:	eb 22                	jmp    801261 <getuint+0x38>
	else if (lflag)
  80123f:	85 d2                	test   %edx,%edx
  801241:	74 10                	je     801253 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801243:	8b 10                	mov    (%eax),%edx
  801245:	8d 4a 04             	lea    0x4(%edx),%ecx
  801248:	89 08                	mov    %ecx,(%eax)
  80124a:	8b 02                	mov    (%edx),%eax
  80124c:	ba 00 00 00 00       	mov    $0x0,%edx
  801251:	eb 0e                	jmp    801261 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801253:	8b 10                	mov    (%eax),%edx
  801255:	8d 4a 04             	lea    0x4(%edx),%ecx
  801258:	89 08                	mov    %ecx,(%eax)
  80125a:	8b 02                	mov    (%edx),%eax
  80125c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801269:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80126d:	8b 10                	mov    (%eax),%edx
  80126f:	3b 50 04             	cmp    0x4(%eax),%edx
  801272:	73 0a                	jae    80127e <sprintputch+0x1b>
		*b->buf++ = ch;
  801274:	8d 4a 01             	lea    0x1(%edx),%ecx
  801277:	89 08                	mov    %ecx,(%eax)
  801279:	8b 45 08             	mov    0x8(%ebp),%eax
  80127c:	88 02                	mov    %al,(%edx)
}
  80127e:	5d                   	pop    %ebp
  80127f:	c3                   	ret    

00801280 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801280:	55                   	push   %ebp
  801281:	89 e5                	mov    %esp,%ebp
  801283:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801286:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801289:	50                   	push   %eax
  80128a:	ff 75 10             	pushl  0x10(%ebp)
  80128d:	ff 75 0c             	pushl  0xc(%ebp)
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 05 00 00 00       	call   80129d <vprintfmt>
	va_end(ap);
}
  801298:	83 c4 10             	add    $0x10,%esp
  80129b:	c9                   	leave  
  80129c:	c3                   	ret    

0080129d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80129d:	55                   	push   %ebp
  80129e:	89 e5                	mov    %esp,%ebp
  8012a0:	57                   	push   %edi
  8012a1:	56                   	push   %esi
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 2c             	sub    $0x2c,%esp
  8012a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012ac:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012af:	eb 12                	jmp    8012c3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	0f 84 89 03 00 00    	je     801642 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	53                   	push   %ebx
  8012bd:	50                   	push   %eax
  8012be:	ff d6                	call   *%esi
  8012c0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012c3:	83 c7 01             	add    $0x1,%edi
  8012c6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012ca:	83 f8 25             	cmp    $0x25,%eax
  8012cd:	75 e2                	jne    8012b1 <vprintfmt+0x14>
  8012cf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012d3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012e1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ed:	eb 07                	jmp    8012f6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012f2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f6:	8d 47 01             	lea    0x1(%edi),%eax
  8012f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012fc:	0f b6 07             	movzbl (%edi),%eax
  8012ff:	0f b6 c8             	movzbl %al,%ecx
  801302:	83 e8 23             	sub    $0x23,%eax
  801305:	3c 55                	cmp    $0x55,%al
  801307:	0f 87 1a 03 00 00    	ja     801627 <vprintfmt+0x38a>
  80130d:	0f b6 c0             	movzbl %al,%eax
  801310:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801317:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80131a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80131e:	eb d6                	jmp    8012f6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801323:	b8 00 00 00 00       	mov    $0x0,%eax
  801328:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80132b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80132e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801332:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801335:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801338:	83 fa 09             	cmp    $0x9,%edx
  80133b:	77 39                	ja     801376 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80133d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801340:	eb e9                	jmp    80132b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801342:	8b 45 14             	mov    0x14(%ebp),%eax
  801345:	8d 48 04             	lea    0x4(%eax),%ecx
  801348:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80134b:	8b 00                	mov    (%eax),%eax
  80134d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801353:	eb 27                	jmp    80137c <vprintfmt+0xdf>
  801355:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801358:	85 c0                	test   %eax,%eax
  80135a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80135f:	0f 49 c8             	cmovns %eax,%ecx
  801362:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801368:	eb 8c                	jmp    8012f6 <vprintfmt+0x59>
  80136a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80136d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801374:	eb 80                	jmp    8012f6 <vprintfmt+0x59>
  801376:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801379:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80137c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801380:	0f 89 70 ff ff ff    	jns    8012f6 <vprintfmt+0x59>
				width = precision, precision = -1;
  801386:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801389:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80138c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801393:	e9 5e ff ff ff       	jmp    8012f6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801398:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80139e:	e9 53 ff ff ff       	jmp    8012f6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8013a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a6:	8d 50 04             	lea    0x4(%eax),%edx
  8013a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	53                   	push   %ebx
  8013b0:	ff 30                	pushl  (%eax)
  8013b2:	ff d6                	call   *%esi
			break;
  8013b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013ba:	e9 04 ff ff ff       	jmp    8012c3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c2:	8d 50 04             	lea    0x4(%eax),%edx
  8013c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c8:	8b 00                	mov    (%eax),%eax
  8013ca:	99                   	cltd   
  8013cb:	31 d0                	xor    %edx,%eax
  8013cd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013cf:	83 f8 0f             	cmp    $0xf,%eax
  8013d2:	7f 0b                	jg     8013df <vprintfmt+0x142>
  8013d4:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  8013db:	85 d2                	test   %edx,%edx
  8013dd:	75 18                	jne    8013f7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013df:	50                   	push   %eax
  8013e0:	68 8b 1f 80 00       	push   $0x801f8b
  8013e5:	53                   	push   %ebx
  8013e6:	56                   	push   %esi
  8013e7:	e8 94 fe ff ff       	call   801280 <printfmt>
  8013ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013f2:	e9 cc fe ff ff       	jmp    8012c3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013f7:	52                   	push   %edx
  8013f8:	68 09 1f 80 00       	push   $0x801f09
  8013fd:	53                   	push   %ebx
  8013fe:	56                   	push   %esi
  8013ff:	e8 7c fe ff ff       	call   801280 <printfmt>
  801404:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80140a:	e9 b4 fe ff ff       	jmp    8012c3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80140f:	8b 45 14             	mov    0x14(%ebp),%eax
  801412:	8d 50 04             	lea    0x4(%eax),%edx
  801415:	89 55 14             	mov    %edx,0x14(%ebp)
  801418:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80141a:	85 ff                	test   %edi,%edi
  80141c:	b8 84 1f 80 00       	mov    $0x801f84,%eax
  801421:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801424:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801428:	0f 8e 94 00 00 00    	jle    8014c2 <vprintfmt+0x225>
  80142e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801432:	0f 84 98 00 00 00    	je     8014d0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	ff 75 d0             	pushl  -0x30(%ebp)
  80143e:	57                   	push   %edi
  80143f:	e8 86 02 00 00       	call   8016ca <strnlen>
  801444:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801447:	29 c1                	sub    %eax,%ecx
  801449:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80144c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80144f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801453:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801456:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801459:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80145b:	eb 0f                	jmp    80146c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	53                   	push   %ebx
  801461:	ff 75 e0             	pushl  -0x20(%ebp)
  801464:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801466:	83 ef 01             	sub    $0x1,%edi
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	85 ff                	test   %edi,%edi
  80146e:	7f ed                	jg     80145d <vprintfmt+0x1c0>
  801470:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801473:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801476:	85 c9                	test   %ecx,%ecx
  801478:	b8 00 00 00 00       	mov    $0x0,%eax
  80147d:	0f 49 c1             	cmovns %ecx,%eax
  801480:	29 c1                	sub    %eax,%ecx
  801482:	89 75 08             	mov    %esi,0x8(%ebp)
  801485:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801488:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80148b:	89 cb                	mov    %ecx,%ebx
  80148d:	eb 4d                	jmp    8014dc <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80148f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801493:	74 1b                	je     8014b0 <vprintfmt+0x213>
  801495:	0f be c0             	movsbl %al,%eax
  801498:	83 e8 20             	sub    $0x20,%eax
  80149b:	83 f8 5e             	cmp    $0x5e,%eax
  80149e:	76 10                	jbe    8014b0 <vprintfmt+0x213>
					putch('?', putdat);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	ff 75 0c             	pushl  0xc(%ebp)
  8014a6:	6a 3f                	push   $0x3f
  8014a8:	ff 55 08             	call   *0x8(%ebp)
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb 0d                	jmp    8014bd <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	ff 75 0c             	pushl  0xc(%ebp)
  8014b6:	52                   	push   %edx
  8014b7:	ff 55 08             	call   *0x8(%ebp)
  8014ba:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014bd:	83 eb 01             	sub    $0x1,%ebx
  8014c0:	eb 1a                	jmp    8014dc <vprintfmt+0x23f>
  8014c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014cb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014ce:	eb 0c                	jmp    8014dc <vprintfmt+0x23f>
  8014d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8014d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014d9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014dc:	83 c7 01             	add    $0x1,%edi
  8014df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014e3:	0f be d0             	movsbl %al,%edx
  8014e6:	85 d2                	test   %edx,%edx
  8014e8:	74 23                	je     80150d <vprintfmt+0x270>
  8014ea:	85 f6                	test   %esi,%esi
  8014ec:	78 a1                	js     80148f <vprintfmt+0x1f2>
  8014ee:	83 ee 01             	sub    $0x1,%esi
  8014f1:	79 9c                	jns    80148f <vprintfmt+0x1f2>
  8014f3:	89 df                	mov    %ebx,%edi
  8014f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014fb:	eb 18                	jmp    801515 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014fd:	83 ec 08             	sub    $0x8,%esp
  801500:	53                   	push   %ebx
  801501:	6a 20                	push   $0x20
  801503:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801505:	83 ef 01             	sub    $0x1,%edi
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	eb 08                	jmp    801515 <vprintfmt+0x278>
  80150d:	89 df                	mov    %ebx,%edi
  80150f:	8b 75 08             	mov    0x8(%ebp),%esi
  801512:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801515:	85 ff                	test   %edi,%edi
  801517:	7f e4                	jg     8014fd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801519:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80151c:	e9 a2 fd ff ff       	jmp    8012c3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801521:	83 fa 01             	cmp    $0x1,%edx
  801524:	7e 16                	jle    80153c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801526:	8b 45 14             	mov    0x14(%ebp),%eax
  801529:	8d 50 08             	lea    0x8(%eax),%edx
  80152c:	89 55 14             	mov    %edx,0x14(%ebp)
  80152f:	8b 50 04             	mov    0x4(%eax),%edx
  801532:	8b 00                	mov    (%eax),%eax
  801534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801537:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80153a:	eb 32                	jmp    80156e <vprintfmt+0x2d1>
	else if (lflag)
  80153c:	85 d2                	test   %edx,%edx
  80153e:	74 18                	je     801558 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801540:	8b 45 14             	mov    0x14(%ebp),%eax
  801543:	8d 50 04             	lea    0x4(%eax),%edx
  801546:	89 55 14             	mov    %edx,0x14(%ebp)
  801549:	8b 00                	mov    (%eax),%eax
  80154b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154e:	89 c1                	mov    %eax,%ecx
  801550:	c1 f9 1f             	sar    $0x1f,%ecx
  801553:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801556:	eb 16                	jmp    80156e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801558:	8b 45 14             	mov    0x14(%ebp),%eax
  80155b:	8d 50 04             	lea    0x4(%eax),%edx
  80155e:	89 55 14             	mov    %edx,0x14(%ebp)
  801561:	8b 00                	mov    (%eax),%eax
  801563:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801566:	89 c1                	mov    %eax,%ecx
  801568:	c1 f9 1f             	sar    $0x1f,%ecx
  80156b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80156e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801571:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801574:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801579:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80157d:	79 74                	jns    8015f3 <vprintfmt+0x356>
				putch('-', putdat);
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	53                   	push   %ebx
  801583:	6a 2d                	push   $0x2d
  801585:	ff d6                	call   *%esi
				num = -(long long) num;
  801587:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80158a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80158d:	f7 d8                	neg    %eax
  80158f:	83 d2 00             	adc    $0x0,%edx
  801592:	f7 da                	neg    %edx
  801594:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801597:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80159c:	eb 55                	jmp    8015f3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80159e:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a1:	e8 83 fc ff ff       	call   801229 <getuint>
			base = 10;
  8015a6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015ab:	eb 46                	jmp    8015f3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b0:	e8 74 fc ff ff       	call   801229 <getuint>
			base = 8;
  8015b5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015ba:	eb 37                	jmp    8015f3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	6a 30                	push   $0x30
  8015c2:	ff d6                	call   *%esi
			putch('x', putdat);
  8015c4:	83 c4 08             	add    $0x8,%esp
  8015c7:	53                   	push   %ebx
  8015c8:	6a 78                	push   $0x78
  8015ca:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cf:	8d 50 04             	lea    0x4(%eax),%edx
  8015d2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015d5:	8b 00                	mov    (%eax),%eax
  8015d7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015dc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015df:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015e4:	eb 0d                	jmp    8015f3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015e9:	e8 3b fc ff ff       	call   801229 <getuint>
			base = 16;
  8015ee:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015f3:	83 ec 0c             	sub    $0xc,%esp
  8015f6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015fa:	57                   	push   %edi
  8015fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8015fe:	51                   	push   %ecx
  8015ff:	52                   	push   %edx
  801600:	50                   	push   %eax
  801601:	89 da                	mov    %ebx,%edx
  801603:	89 f0                	mov    %esi,%eax
  801605:	e8 70 fb ff ff       	call   80117a <printnum>
			break;
  80160a:	83 c4 20             	add    $0x20,%esp
  80160d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801610:	e9 ae fc ff ff       	jmp    8012c3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	53                   	push   %ebx
  801619:	51                   	push   %ecx
  80161a:	ff d6                	call   *%esi
			break;
  80161c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801622:	e9 9c fc ff ff       	jmp    8012c3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	53                   	push   %ebx
  80162b:	6a 25                	push   $0x25
  80162d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	eb 03                	jmp    801637 <vprintfmt+0x39a>
  801634:	83 ef 01             	sub    $0x1,%edi
  801637:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80163b:	75 f7                	jne    801634 <vprintfmt+0x397>
  80163d:	e9 81 fc ff ff       	jmp    8012c3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801642:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	5f                   	pop    %edi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	83 ec 18             	sub    $0x18,%esp
  801650:	8b 45 08             	mov    0x8(%ebp),%eax
  801653:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801656:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801659:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80165d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801660:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801667:	85 c0                	test   %eax,%eax
  801669:	74 26                	je     801691 <vsnprintf+0x47>
  80166b:	85 d2                	test   %edx,%edx
  80166d:	7e 22                	jle    801691 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80166f:	ff 75 14             	pushl  0x14(%ebp)
  801672:	ff 75 10             	pushl  0x10(%ebp)
  801675:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	68 63 12 80 00       	push   $0x801263
  80167e:	e8 1a fc ff ff       	call   80129d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801683:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801686:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	eb 05                	jmp    801696 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801691:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80169e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016a1:	50                   	push   %eax
  8016a2:	ff 75 10             	pushl  0x10(%ebp)
  8016a5:	ff 75 0c             	pushl  0xc(%ebp)
  8016a8:	ff 75 08             	pushl  0x8(%ebp)
  8016ab:	e8 9a ff ff ff       	call   80164a <vsnprintf>
	va_end(ap);

	return rc;
}
  8016b0:	c9                   	leave  
  8016b1:	c3                   	ret    

008016b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bd:	eb 03                	jmp    8016c2 <strlen+0x10>
		n++;
  8016bf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016c6:	75 f7                	jne    8016bf <strlen+0xd>
		n++;
	return n;
}
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d8:	eb 03                	jmp    8016dd <strnlen+0x13>
		n++;
  8016da:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016dd:	39 c2                	cmp    %eax,%edx
  8016df:	74 08                	je     8016e9 <strnlen+0x1f>
  8016e1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016e5:	75 f3                	jne    8016da <strnlen+0x10>
  8016e7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	53                   	push   %ebx
  8016ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016f5:	89 c2                	mov    %eax,%edx
  8016f7:	83 c2 01             	add    $0x1,%edx
  8016fa:	83 c1 01             	add    $0x1,%ecx
  8016fd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801701:	88 5a ff             	mov    %bl,-0x1(%edx)
  801704:	84 db                	test   %bl,%bl
  801706:	75 ef                	jne    8016f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801708:	5b                   	pop    %ebx
  801709:	5d                   	pop    %ebp
  80170a:	c3                   	ret    

0080170b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	53                   	push   %ebx
  80170f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801712:	53                   	push   %ebx
  801713:	e8 9a ff ff ff       	call   8016b2 <strlen>
  801718:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80171b:	ff 75 0c             	pushl  0xc(%ebp)
  80171e:	01 d8                	add    %ebx,%eax
  801720:	50                   	push   %eax
  801721:	e8 c5 ff ff ff       	call   8016eb <strcpy>
	return dst;
}
  801726:	89 d8                	mov    %ebx,%eax
  801728:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
  801732:	8b 75 08             	mov    0x8(%ebp),%esi
  801735:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801738:	89 f3                	mov    %esi,%ebx
  80173a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173d:	89 f2                	mov    %esi,%edx
  80173f:	eb 0f                	jmp    801750 <strncpy+0x23>
		*dst++ = *src;
  801741:	83 c2 01             	add    $0x1,%edx
  801744:	0f b6 01             	movzbl (%ecx),%eax
  801747:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80174a:	80 39 01             	cmpb   $0x1,(%ecx)
  80174d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801750:	39 da                	cmp    %ebx,%edx
  801752:	75 ed                	jne    801741 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801754:	89 f0                	mov    %esi,%eax
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	56                   	push   %esi
  80175e:	53                   	push   %ebx
  80175f:	8b 75 08             	mov    0x8(%ebp),%esi
  801762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801765:	8b 55 10             	mov    0x10(%ebp),%edx
  801768:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80176a:	85 d2                	test   %edx,%edx
  80176c:	74 21                	je     80178f <strlcpy+0x35>
  80176e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801772:	89 f2                	mov    %esi,%edx
  801774:	eb 09                	jmp    80177f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801776:	83 c2 01             	add    $0x1,%edx
  801779:	83 c1 01             	add    $0x1,%ecx
  80177c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80177f:	39 c2                	cmp    %eax,%edx
  801781:	74 09                	je     80178c <strlcpy+0x32>
  801783:	0f b6 19             	movzbl (%ecx),%ebx
  801786:	84 db                	test   %bl,%bl
  801788:	75 ec                	jne    801776 <strlcpy+0x1c>
  80178a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80178c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80178f:	29 f0                	sub    %esi,%eax
}
  801791:	5b                   	pop    %ebx
  801792:	5e                   	pop    %esi
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179e:	eb 06                	jmp    8017a6 <strcmp+0x11>
		p++, q++;
  8017a0:	83 c1 01             	add    $0x1,%ecx
  8017a3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017a6:	0f b6 01             	movzbl (%ecx),%eax
  8017a9:	84 c0                	test   %al,%al
  8017ab:	74 04                	je     8017b1 <strcmp+0x1c>
  8017ad:	3a 02                	cmp    (%edx),%al
  8017af:	74 ef                	je     8017a0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b1:	0f b6 c0             	movzbl %al,%eax
  8017b4:	0f b6 12             	movzbl (%edx),%edx
  8017b7:	29 d0                	sub    %edx,%eax
}
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	53                   	push   %ebx
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c5:	89 c3                	mov    %eax,%ebx
  8017c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ca:	eb 06                	jmp    8017d2 <strncmp+0x17>
		n--, p++, q++;
  8017cc:	83 c0 01             	add    $0x1,%eax
  8017cf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017d2:	39 d8                	cmp    %ebx,%eax
  8017d4:	74 15                	je     8017eb <strncmp+0x30>
  8017d6:	0f b6 08             	movzbl (%eax),%ecx
  8017d9:	84 c9                	test   %cl,%cl
  8017db:	74 04                	je     8017e1 <strncmp+0x26>
  8017dd:	3a 0a                	cmp    (%edx),%cl
  8017df:	74 eb                	je     8017cc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e1:	0f b6 00             	movzbl (%eax),%eax
  8017e4:	0f b6 12             	movzbl (%edx),%edx
  8017e7:	29 d0                	sub    %edx,%eax
  8017e9:	eb 05                	jmp    8017f0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017eb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017f0:	5b                   	pop    %ebx
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fd:	eb 07                	jmp    801806 <strchr+0x13>
		if (*s == c)
  8017ff:	38 ca                	cmp    %cl,%dl
  801801:	74 0f                	je     801812 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801803:	83 c0 01             	add    $0x1,%eax
  801806:	0f b6 10             	movzbl (%eax),%edx
  801809:	84 d2                	test   %dl,%dl
  80180b:	75 f2                	jne    8017ff <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80180d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181e:	eb 03                	jmp    801823 <strfind+0xf>
  801820:	83 c0 01             	add    $0x1,%eax
  801823:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801826:	38 ca                	cmp    %cl,%dl
  801828:	74 04                	je     80182e <strfind+0x1a>
  80182a:	84 d2                	test   %dl,%dl
  80182c:	75 f2                	jne    801820 <strfind+0xc>
			break;
	return (char *) s;
}
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	57                   	push   %edi
  801834:	56                   	push   %esi
  801835:	53                   	push   %ebx
  801836:	8b 7d 08             	mov    0x8(%ebp),%edi
  801839:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80183c:	85 c9                	test   %ecx,%ecx
  80183e:	74 36                	je     801876 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801840:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801846:	75 28                	jne    801870 <memset+0x40>
  801848:	f6 c1 03             	test   $0x3,%cl
  80184b:	75 23                	jne    801870 <memset+0x40>
		c &= 0xFF;
  80184d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801851:	89 d3                	mov    %edx,%ebx
  801853:	c1 e3 08             	shl    $0x8,%ebx
  801856:	89 d6                	mov    %edx,%esi
  801858:	c1 e6 18             	shl    $0x18,%esi
  80185b:	89 d0                	mov    %edx,%eax
  80185d:	c1 e0 10             	shl    $0x10,%eax
  801860:	09 f0                	or     %esi,%eax
  801862:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801864:	89 d8                	mov    %ebx,%eax
  801866:	09 d0                	or     %edx,%eax
  801868:	c1 e9 02             	shr    $0x2,%ecx
  80186b:	fc                   	cld    
  80186c:	f3 ab                	rep stos %eax,%es:(%edi)
  80186e:	eb 06                	jmp    801876 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801870:	8b 45 0c             	mov    0xc(%ebp),%eax
  801873:	fc                   	cld    
  801874:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801876:	89 f8                	mov    %edi,%eax
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5f                   	pop    %edi
  80187b:	5d                   	pop    %ebp
  80187c:	c3                   	ret    

0080187d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	57                   	push   %edi
  801881:	56                   	push   %esi
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 75 0c             	mov    0xc(%ebp),%esi
  801888:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80188b:	39 c6                	cmp    %eax,%esi
  80188d:	73 35                	jae    8018c4 <memmove+0x47>
  80188f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801892:	39 d0                	cmp    %edx,%eax
  801894:	73 2e                	jae    8018c4 <memmove+0x47>
		s += n;
		d += n;
  801896:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801899:	89 d6                	mov    %edx,%esi
  80189b:	09 fe                	or     %edi,%esi
  80189d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a3:	75 13                	jne    8018b8 <memmove+0x3b>
  8018a5:	f6 c1 03             	test   $0x3,%cl
  8018a8:	75 0e                	jne    8018b8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018aa:	83 ef 04             	sub    $0x4,%edi
  8018ad:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018b0:	c1 e9 02             	shr    $0x2,%ecx
  8018b3:	fd                   	std    
  8018b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b6:	eb 09                	jmp    8018c1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b8:	83 ef 01             	sub    $0x1,%edi
  8018bb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018be:	fd                   	std    
  8018bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c1:	fc                   	cld    
  8018c2:	eb 1d                	jmp    8018e1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c4:	89 f2                	mov    %esi,%edx
  8018c6:	09 c2                	or     %eax,%edx
  8018c8:	f6 c2 03             	test   $0x3,%dl
  8018cb:	75 0f                	jne    8018dc <memmove+0x5f>
  8018cd:	f6 c1 03             	test   $0x3,%cl
  8018d0:	75 0a                	jne    8018dc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018d2:	c1 e9 02             	shr    $0x2,%ecx
  8018d5:	89 c7                	mov    %eax,%edi
  8018d7:	fc                   	cld    
  8018d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018da:	eb 05                	jmp    8018e1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018dc:	89 c7                	mov    %eax,%edi
  8018de:	fc                   	cld    
  8018df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e1:	5e                   	pop    %esi
  8018e2:	5f                   	pop    %edi
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    

008018e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e8:	ff 75 10             	pushl  0x10(%ebp)
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	ff 75 08             	pushl  0x8(%ebp)
  8018f1:	e8 87 ff ff ff       	call   80187d <memmove>
}
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	56                   	push   %esi
  8018fc:	53                   	push   %ebx
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	8b 55 0c             	mov    0xc(%ebp),%edx
  801903:	89 c6                	mov    %eax,%esi
  801905:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801908:	eb 1a                	jmp    801924 <memcmp+0x2c>
		if (*s1 != *s2)
  80190a:	0f b6 08             	movzbl (%eax),%ecx
  80190d:	0f b6 1a             	movzbl (%edx),%ebx
  801910:	38 d9                	cmp    %bl,%cl
  801912:	74 0a                	je     80191e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801914:	0f b6 c1             	movzbl %cl,%eax
  801917:	0f b6 db             	movzbl %bl,%ebx
  80191a:	29 d8                	sub    %ebx,%eax
  80191c:	eb 0f                	jmp    80192d <memcmp+0x35>
		s1++, s2++;
  80191e:	83 c0 01             	add    $0x1,%eax
  801921:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801924:	39 f0                	cmp    %esi,%eax
  801926:	75 e2                	jne    80190a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801928:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192d:	5b                   	pop    %ebx
  80192e:	5e                   	pop    %esi
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	53                   	push   %ebx
  801935:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801938:	89 c1                	mov    %eax,%ecx
  80193a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80193d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801941:	eb 0a                	jmp    80194d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801943:	0f b6 10             	movzbl (%eax),%edx
  801946:	39 da                	cmp    %ebx,%edx
  801948:	74 07                	je     801951 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80194a:	83 c0 01             	add    $0x1,%eax
  80194d:	39 c8                	cmp    %ecx,%eax
  80194f:	72 f2                	jb     801943 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801951:	5b                   	pop    %ebx
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	57                   	push   %edi
  801958:	56                   	push   %esi
  801959:	53                   	push   %ebx
  80195a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801960:	eb 03                	jmp    801965 <strtol+0x11>
		s++;
  801962:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801965:	0f b6 01             	movzbl (%ecx),%eax
  801968:	3c 20                	cmp    $0x20,%al
  80196a:	74 f6                	je     801962 <strtol+0xe>
  80196c:	3c 09                	cmp    $0x9,%al
  80196e:	74 f2                	je     801962 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801970:	3c 2b                	cmp    $0x2b,%al
  801972:	75 0a                	jne    80197e <strtol+0x2a>
		s++;
  801974:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801977:	bf 00 00 00 00       	mov    $0x0,%edi
  80197c:	eb 11                	jmp    80198f <strtol+0x3b>
  80197e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801983:	3c 2d                	cmp    $0x2d,%al
  801985:	75 08                	jne    80198f <strtol+0x3b>
		s++, neg = 1;
  801987:	83 c1 01             	add    $0x1,%ecx
  80198a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801995:	75 15                	jne    8019ac <strtol+0x58>
  801997:	80 39 30             	cmpb   $0x30,(%ecx)
  80199a:	75 10                	jne    8019ac <strtol+0x58>
  80199c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019a0:	75 7c                	jne    801a1e <strtol+0xca>
		s += 2, base = 16;
  8019a2:	83 c1 02             	add    $0x2,%ecx
  8019a5:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019aa:	eb 16                	jmp    8019c2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019ac:	85 db                	test   %ebx,%ebx
  8019ae:	75 12                	jne    8019c2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019b0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019b5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b8:	75 08                	jne    8019c2 <strtol+0x6e>
		s++, base = 8;
  8019ba:	83 c1 01             	add    $0x1,%ecx
  8019bd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ca:	0f b6 11             	movzbl (%ecx),%edx
  8019cd:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019d0:	89 f3                	mov    %esi,%ebx
  8019d2:	80 fb 09             	cmp    $0x9,%bl
  8019d5:	77 08                	ja     8019df <strtol+0x8b>
			dig = *s - '0';
  8019d7:	0f be d2             	movsbl %dl,%edx
  8019da:	83 ea 30             	sub    $0x30,%edx
  8019dd:	eb 22                	jmp    801a01 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019df:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019e2:	89 f3                	mov    %esi,%ebx
  8019e4:	80 fb 19             	cmp    $0x19,%bl
  8019e7:	77 08                	ja     8019f1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019e9:	0f be d2             	movsbl %dl,%edx
  8019ec:	83 ea 57             	sub    $0x57,%edx
  8019ef:	eb 10                	jmp    801a01 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019f1:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019f4:	89 f3                	mov    %esi,%ebx
  8019f6:	80 fb 19             	cmp    $0x19,%bl
  8019f9:	77 16                	ja     801a11 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019fb:	0f be d2             	movsbl %dl,%edx
  8019fe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a01:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a04:	7d 0b                	jge    801a11 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a06:	83 c1 01             	add    $0x1,%ecx
  801a09:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a0d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a0f:	eb b9                	jmp    8019ca <strtol+0x76>

	if (endptr)
  801a11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a15:	74 0d                	je     801a24 <strtol+0xd0>
		*endptr = (char *) s;
  801a17:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a1a:	89 0e                	mov    %ecx,(%esi)
  801a1c:	eb 06                	jmp    801a24 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a1e:	85 db                	test   %ebx,%ebx
  801a20:	74 98                	je     8019ba <strtol+0x66>
  801a22:	eb 9e                	jmp    8019c2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a24:	89 c2                	mov    %eax,%edx
  801a26:	f7 da                	neg    %edx
  801a28:	85 ff                	test   %edi,%edi
  801a2a:	0f 45 c2             	cmovne %edx,%eax
}
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	5f                   	pop    %edi
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    

00801a32 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a40:	85 c0                	test   %eax,%eax
  801a42:	75 12                	jne    801a56 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	68 00 00 c0 ee       	push   $0xeec00000
  801a4c:	e8 11 e9 ff ff       	call   800362 <sys_ipc_recv>
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	eb 0c                	jmp    801a62 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	50                   	push   %eax
  801a5a:	e8 03 e9 ff ff       	call   800362 <sys_ipc_recv>
  801a5f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a62:	85 f6                	test   %esi,%esi
  801a64:	0f 95 c1             	setne  %cl
  801a67:	85 db                	test   %ebx,%ebx
  801a69:	0f 95 c2             	setne  %dl
  801a6c:	84 d1                	test   %dl,%cl
  801a6e:	74 09                	je     801a79 <ipc_recv+0x47>
  801a70:	89 c2                	mov    %eax,%edx
  801a72:	c1 ea 1f             	shr    $0x1f,%edx
  801a75:	84 d2                	test   %dl,%dl
  801a77:	75 24                	jne    801a9d <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a79:	85 f6                	test   %esi,%esi
  801a7b:	74 0a                	je     801a87 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801a7d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a82:	8b 40 74             	mov    0x74(%eax),%eax
  801a85:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801a87:	85 db                	test   %ebx,%ebx
  801a89:	74 0a                	je     801a95 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801a8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a90:	8b 40 78             	mov    0x78(%eax),%eax
  801a93:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a95:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	57                   	push   %edi
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ab6:	85 db                	test   %ebx,%ebx
  801ab8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801abd:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ac0:	ff 75 14             	pushl  0x14(%ebp)
  801ac3:	53                   	push   %ebx
  801ac4:	56                   	push   %esi
  801ac5:	57                   	push   %edi
  801ac6:	e8 74 e8 ff ff       	call   80033f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801acb:	89 c2                	mov    %eax,%edx
  801acd:	c1 ea 1f             	shr    $0x1f,%edx
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	84 d2                	test   %dl,%dl
  801ad5:	74 17                	je     801aee <ipc_send+0x4a>
  801ad7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ada:	74 12                	je     801aee <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801adc:	50                   	push   %eax
  801add:	68 80 22 80 00       	push   $0x802280
  801ae2:	6a 47                	push   $0x47
  801ae4:	68 8e 22 80 00       	push   $0x80228e
  801ae9:	e8 9f f5 ff ff       	call   80108d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801aee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af1:	75 07                	jne    801afa <ipc_send+0x56>
			sys_yield();
  801af3:	e8 9b e6 ff ff       	call   800193 <sys_yield>
  801af8:	eb c6                	jmp    801ac0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801afa:	85 c0                	test   %eax,%eax
  801afc:	75 c2                	jne    801ac0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	5f                   	pop    %edi
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b11:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b14:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b1a:	8b 52 50             	mov    0x50(%edx),%edx
  801b1d:	39 ca                	cmp    %ecx,%edx
  801b1f:	75 0d                	jne    801b2e <ipc_find_env+0x28>
			return envs[i].env_id;
  801b21:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b29:	8b 40 48             	mov    0x48(%eax),%eax
  801b2c:	eb 0f                	jmp    801b3d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b2e:	83 c0 01             	add    $0x1,%eax
  801b31:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b36:	75 d9                	jne    801b11 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b3d:	5d                   	pop    %ebp
  801b3e:	c3                   	ret    

00801b3f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3f:	55                   	push   %ebp
  801b40:	89 e5                	mov    %esp,%ebp
  801b42:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b45:	89 d0                	mov    %edx,%eax
  801b47:	c1 e8 16             	shr    $0x16,%eax
  801b4a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b56:	f6 c1 01             	test   $0x1,%cl
  801b59:	74 1d                	je     801b78 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b5b:	c1 ea 0c             	shr    $0xc,%edx
  801b5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b65:	f6 c2 01             	test   $0x1,%dl
  801b68:	74 0e                	je     801b78 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b6a:	c1 ea 0c             	shr    $0xc,%edx
  801b6d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b74:	ef 
  801b75:	0f b7 c0             	movzwl %ax,%eax
}
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    
  801b7a:	66 90                	xchg   %ax,%ax
  801b7c:	66 90                	xchg   %ax,%ax
  801b7e:	66 90                	xchg   %ax,%ax

00801b80 <__udivdi3>:
  801b80:	55                   	push   %ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 1c             	sub    $0x1c,%esp
  801b87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b97:	85 f6                	test   %esi,%esi
  801b99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b9d:	89 ca                	mov    %ecx,%edx
  801b9f:	89 f8                	mov    %edi,%eax
  801ba1:	75 3d                	jne    801be0 <__udivdi3+0x60>
  801ba3:	39 cf                	cmp    %ecx,%edi
  801ba5:	0f 87 c5 00 00 00    	ja     801c70 <__udivdi3+0xf0>
  801bab:	85 ff                	test   %edi,%edi
  801bad:	89 fd                	mov    %edi,%ebp
  801baf:	75 0b                	jne    801bbc <__udivdi3+0x3c>
  801bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb6:	31 d2                	xor    %edx,%edx
  801bb8:	f7 f7                	div    %edi
  801bba:	89 c5                	mov    %eax,%ebp
  801bbc:	89 c8                	mov    %ecx,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f5                	div    %ebp
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	89 cf                	mov    %ecx,%edi
  801bc8:	f7 f5                	div    %ebp
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	89 fa                	mov    %edi,%edx
  801bd0:	83 c4 1c             	add    $0x1c,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	90                   	nop
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 ce                	cmp    %ecx,%esi
  801be2:	77 74                	ja     801c58 <__udivdi3+0xd8>
  801be4:	0f bd fe             	bsr    %esi,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0x108>
  801bf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	89 c5                	mov    %eax,%ebp
  801bf9:	29 fb                	sub    %edi,%ebx
  801bfb:	d3 e6                	shl    %cl,%esi
  801bfd:	89 d9                	mov    %ebx,%ecx
  801bff:	d3 ed                	shr    %cl,%ebp
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e0                	shl    %cl,%eax
  801c05:	09 ee                	or     %ebp,%esi
  801c07:	89 d9                	mov    %ebx,%ecx
  801c09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0d:	89 d5                	mov    %edx,%ebp
  801c0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c13:	d3 ed                	shr    %cl,%ebp
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e2                	shl    %cl,%edx
  801c19:	89 d9                	mov    %ebx,%ecx
  801c1b:	d3 e8                	shr    %cl,%eax
  801c1d:	09 c2                	or     %eax,%edx
  801c1f:	89 d0                	mov    %edx,%eax
  801c21:	89 ea                	mov    %ebp,%edx
  801c23:	f7 f6                	div    %esi
  801c25:	89 d5                	mov    %edx,%ebp
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	f7 64 24 0c          	mull   0xc(%esp)
  801c2d:	39 d5                	cmp    %edx,%ebp
  801c2f:	72 10                	jb     801c41 <__udivdi3+0xc1>
  801c31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e6                	shl    %cl,%esi
  801c39:	39 c6                	cmp    %eax,%esi
  801c3b:	73 07                	jae    801c44 <__udivdi3+0xc4>
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	75 03                	jne    801c44 <__udivdi3+0xc4>
  801c41:	83 eb 01             	sub    $0x1,%ebx
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 d8                	mov    %ebx,%eax
  801c48:	89 fa                	mov    %edi,%edx
  801c4a:	83 c4 1c             	add    $0x1c,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
  801c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c58:	31 ff                	xor    %edi,%edi
  801c5a:	31 db                	xor    %ebx,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	f7 f7                	div    %edi
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	89 fa                	mov    %edi,%edx
  801c7c:	83 c4 1c             	add    $0x1c,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 ce                	cmp    %ecx,%esi
  801c8a:	72 0c                	jb     801c98 <__udivdi3+0x118>
  801c8c:	31 db                	xor    %ebx,%ebx
  801c8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c92:	0f 87 34 ff ff ff    	ja     801bcc <__udivdi3+0x4c>
  801c98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c9d:	e9 2a ff ff ff       	jmp    801bcc <__udivdi3+0x4c>
  801ca2:	66 90                	xchg   %ax,%ax
  801ca4:	66 90                	xchg   %ax,%ax
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 d2                	test   %edx,%edx
  801cc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cd1:	89 f3                	mov    %esi,%ebx
  801cd3:	89 3c 24             	mov    %edi,(%esp)
  801cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cda:	75 1c                	jne    801cf8 <__umoddi3+0x48>
  801cdc:	39 f7                	cmp    %esi,%edi
  801cde:	76 50                	jbe    801d30 <__umoddi3+0x80>
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	f7 f7                	div    %edi
  801ce6:	89 d0                	mov    %edx,%eax
  801ce8:	31 d2                	xor    %edx,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	89 d0                	mov    %edx,%eax
  801cfc:	77 52                	ja     801d50 <__umoddi3+0xa0>
  801cfe:	0f bd ea             	bsr    %edx,%ebp
  801d01:	83 f5 1f             	xor    $0x1f,%ebp
  801d04:	75 5a                	jne    801d60 <__umoddi3+0xb0>
  801d06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d0a:	0f 82 e0 00 00 00    	jb     801df0 <__umoddi3+0x140>
  801d10:	39 0c 24             	cmp    %ecx,(%esp)
  801d13:	0f 86 d7 00 00 00    	jbe    801df0 <__umoddi3+0x140>
  801d19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	85 ff                	test   %edi,%edi
  801d32:	89 fd                	mov    %edi,%ebp
  801d34:	75 0b                	jne    801d41 <__umoddi3+0x91>
  801d36:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	f7 f7                	div    %edi
  801d3f:	89 c5                	mov    %eax,%ebp
  801d41:	89 f0                	mov    %esi,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f5                	div    %ebp
  801d47:	89 c8                	mov    %ecx,%eax
  801d49:	f7 f5                	div    %ebp
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	eb 99                	jmp    801ce8 <__umoddi3+0x38>
  801d4f:	90                   	nop
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	83 c4 1c             	add    $0x1c,%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	8b 34 24             	mov    (%esp),%esi
  801d63:	bf 20 00 00 00       	mov    $0x20,%edi
  801d68:	89 e9                	mov    %ebp,%ecx
  801d6a:	29 ef                	sub    %ebp,%edi
  801d6c:	d3 e0                	shl    %cl,%eax
  801d6e:	89 f9                	mov    %edi,%ecx
  801d70:	89 f2                	mov    %esi,%edx
  801d72:	d3 ea                	shr    %cl,%edx
  801d74:	89 e9                	mov    %ebp,%ecx
  801d76:	09 c2                	or     %eax,%edx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 14 24             	mov    %edx,(%esp)
  801d7d:	89 f2                	mov    %esi,%edx
  801d7f:	d3 e2                	shl    %cl,%edx
  801d81:	89 f9                	mov    %edi,%ecx
  801d83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d8b:	d3 e8                	shr    %cl,%eax
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	89 c6                	mov    %eax,%esi
  801d91:	d3 e3                	shl    %cl,%ebx
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 d0                	mov    %edx,%eax
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	09 d8                	or     %ebx,%eax
  801d9d:	89 d3                	mov    %edx,%ebx
  801d9f:	89 f2                	mov    %esi,%edx
  801da1:	f7 34 24             	divl   (%esp)
  801da4:	89 d6                	mov    %edx,%esi
  801da6:	d3 e3                	shl    %cl,%ebx
  801da8:	f7 64 24 04          	mull   0x4(%esp)
  801dac:	39 d6                	cmp    %edx,%esi
  801dae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801db2:	89 d1                	mov    %edx,%ecx
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	72 08                	jb     801dc0 <__umoddi3+0x110>
  801db8:	75 11                	jne    801dcb <__umoddi3+0x11b>
  801dba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dbe:	73 0b                	jae    801dcb <__umoddi3+0x11b>
  801dc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dc4:	1b 14 24             	sbb    (%esp),%edx
  801dc7:	89 d1                	mov    %edx,%ecx
  801dc9:	89 c3                	mov    %eax,%ebx
  801dcb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dcf:	29 da                	sub    %ebx,%edx
  801dd1:	19 ce                	sbb    %ecx,%esi
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 f0                	mov    %esi,%eax
  801dd7:	d3 e0                	shl    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	d3 ea                	shr    %cl,%edx
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	d3 ee                	shr    %cl,%esi
  801de1:	09 d0                	or     %edx,%eax
  801de3:	89 f2                	mov    %esi,%edx
  801de5:	83 c4 1c             	add    $0x1c,%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	29 f9                	sub    %edi,%ecx
  801df2:	19 d6                	sbb    %edx,%esi
  801df4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dfc:	e9 18 ff ff ff       	jmp    801d19 <__umoddi3+0x69>
