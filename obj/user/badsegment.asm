
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
  800041:	57                   	push   %edi
  800042:	56                   	push   %esi
  800043:	53                   	push   %ebx
  800044:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800047:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80004e:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800051:	e8 0e 01 00 00       	call   800164 <sys_getenvid>
  800056:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  80005c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800061:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800066:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  80006b:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80006e:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800074:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800077:	39 c8                	cmp    %ecx,%eax
  800079:	0f 44 fb             	cmove  %ebx,%edi
  80007c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800081:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800084:	83 c2 01             	add    $0x1,%edx
  800087:	83 c3 7c             	add    $0x7c,%ebx
  80008a:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800090:	75 d9                	jne    80006b <libmain+0x2d>
  800092:	89 f0                	mov    %esi,%eax
  800094:	84 c0                	test   %al,%al
  800096:	74 06                	je     80009e <libmain+0x60>
  800098:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000a2:	7e 0a                	jle    8000ae <libmain+0x70>
		binaryname = argv[0];
  8000a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a7:	8b 00                	mov    (%eax),%eax
  8000a9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	ff 75 0c             	pushl  0xc(%ebp)
  8000b4:	ff 75 08             	pushl  0x8(%ebp)
  8000b7:	e8 77 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000bc:	e8 0b 00 00 00       	call   8000cc <exit>
}
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d2:	e8 87 04 00 00       	call   80055e <close_all>
	sys_env_destroy(0);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	6a 00                	push   $0x0
  8000dc:	e8 42 00 00 00       	call   800123 <sys_env_destroy>
}
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	c9                   	leave  
  8000e5:	c3                   	ret    

008000e6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	89 c3                	mov    %eax,%ebx
  8000f9:	89 c7                	mov    %eax,%edi
  8000fb:	89 c6                	mov    %eax,%esi
  8000fd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5f                   	pop    %edi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <sys_cgetc>:

int
sys_cgetc(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	57                   	push   %edi
  800108:	56                   	push   %esi
  800109:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	ba 00 00 00 00       	mov    $0x0,%edx
  80010f:	b8 01 00 00 00       	mov    $0x1,%eax
  800114:	89 d1                	mov    %edx,%ecx
  800116:	89 d3                	mov    %edx,%ebx
  800118:	89 d7                	mov    %edx,%edi
  80011a:	89 d6                	mov    %edx,%esi
  80011c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5f                   	pop    %edi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	57                   	push   %edi
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
  800129:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800131:	b8 03 00 00 00       	mov    $0x3,%eax
  800136:	8b 55 08             	mov    0x8(%ebp),%edx
  800139:	89 cb                	mov    %ecx,%ebx
  80013b:	89 cf                	mov    %ecx,%edi
  80013d:	89 ce                	mov    %ecx,%esi
  80013f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800141:	85 c0                	test   %eax,%eax
  800143:	7e 17                	jle    80015c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800145:	83 ec 0c             	sub    $0xc,%esp
  800148:	50                   	push   %eax
  800149:	6a 03                	push   $0x3
  80014b:	68 0a 1e 80 00       	push   $0x801e0a
  800150:	6a 23                	push   $0x23
  800152:	68 27 1e 80 00       	push   $0x801e27
  800157:	e8 21 0f 00 00       	call   80107d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5f                   	pop    %edi
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	57                   	push   %edi
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016a:	ba 00 00 00 00       	mov    $0x0,%edx
  80016f:	b8 02 00 00 00       	mov    $0x2,%eax
  800174:	89 d1                	mov    %edx,%ecx
  800176:	89 d3                	mov    %edx,%ebx
  800178:	89 d7                	mov    %edx,%edi
  80017a:	89 d6                	mov    %edx,%esi
  80017c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017e:	5b                   	pop    %ebx
  80017f:	5e                   	pop    %esi
  800180:	5f                   	pop    %edi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <sys_yield>:

void
sys_yield(void)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800189:	ba 00 00 00 00       	mov    $0x0,%edx
  80018e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800193:	89 d1                	mov    %edx,%ecx
  800195:	89 d3                	mov    %edx,%ebx
  800197:	89 d7                	mov    %edx,%edi
  800199:	89 d6                	mov    %edx,%esi
  80019b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80019d:	5b                   	pop    %ebx
  80019e:	5e                   	pop    %esi
  80019f:	5f                   	pop    %edi
  8001a0:	5d                   	pop    %ebp
  8001a1:	c3                   	ret    

008001a2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	57                   	push   %edi
  8001a6:	56                   	push   %esi
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ab:	be 00 00 00 00       	mov    $0x0,%esi
  8001b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001be:	89 f7                	mov    %esi,%edi
  8001c0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	7e 17                	jle    8001dd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c6:	83 ec 0c             	sub    $0xc,%esp
  8001c9:	50                   	push   %eax
  8001ca:	6a 04                	push   $0x4
  8001cc:	68 0a 1e 80 00       	push   $0x801e0a
  8001d1:	6a 23                	push   $0x23
  8001d3:	68 27 1e 80 00       	push   $0x801e27
  8001d8:	e8 a0 0e 00 00       	call   80107d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ff:	8b 75 18             	mov    0x18(%ebp),%esi
  800202:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7e 17                	jle    80021f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	83 ec 0c             	sub    $0xc,%esp
  80020b:	50                   	push   %eax
  80020c:	6a 05                	push   $0x5
  80020e:	68 0a 1e 80 00       	push   $0x801e0a
  800213:	6a 23                	push   $0x23
  800215:	68 27 1e 80 00       	push   $0x801e27
  80021a:	e8 5e 0e 00 00       	call   80107d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800222:	5b                   	pop    %ebx
  800223:	5e                   	pop    %esi
  800224:	5f                   	pop    %edi
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	b8 06 00 00 00       	mov    $0x6,%eax
  80023a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	89 df                	mov    %ebx,%edi
  800242:	89 de                	mov    %ebx,%esi
  800244:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800246:	85 c0                	test   %eax,%eax
  800248:	7e 17                	jle    800261 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	50                   	push   %eax
  80024e:	6a 06                	push   $0x6
  800250:	68 0a 1e 80 00       	push   $0x801e0a
  800255:	6a 23                	push   $0x23
  800257:	68 27 1e 80 00       	push   $0x801e27
  80025c:	e8 1c 0e 00 00       	call   80107d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800264:	5b                   	pop    %ebx
  800265:	5e                   	pop    %esi
  800266:	5f                   	pop    %edi
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800272:	bb 00 00 00 00       	mov    $0x0,%ebx
  800277:	b8 08 00 00 00       	mov    $0x8,%eax
  80027c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	89 df                	mov    %ebx,%edi
  800284:	89 de                	mov    %ebx,%esi
  800286:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800288:	85 c0                	test   %eax,%eax
  80028a:	7e 17                	jle    8002a3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	50                   	push   %eax
  800290:	6a 08                	push   $0x8
  800292:	68 0a 1e 80 00       	push   $0x801e0a
  800297:	6a 23                	push   $0x23
  800299:	68 27 1e 80 00       	push   $0x801e27
  80029e:	e8 da 0d 00 00       	call   80107d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a6:	5b                   	pop    %ebx
  8002a7:	5e                   	pop    %esi
  8002a8:	5f                   	pop    %edi
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
  8002b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b9:	b8 09 00 00 00       	mov    $0x9,%eax
  8002be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c4:	89 df                	mov    %ebx,%edi
  8002c6:	89 de                	mov    %ebx,%esi
  8002c8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ca:	85 c0                	test   %eax,%eax
  8002cc:	7e 17                	jle    8002e5 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ce:	83 ec 0c             	sub    $0xc,%esp
  8002d1:	50                   	push   %eax
  8002d2:	6a 09                	push   $0x9
  8002d4:	68 0a 1e 80 00       	push   $0x801e0a
  8002d9:	6a 23                	push   $0x23
  8002db:	68 27 1e 80 00       	push   $0x801e27
  8002e0:	e8 98 0d 00 00       	call   80107d <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e8:	5b                   	pop    %ebx
  8002e9:	5e                   	pop    %esi
  8002ea:	5f                   	pop    %edi
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	57                   	push   %edi
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
  8002f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	89 df                	mov    %ebx,%edi
  800308:	89 de                	mov    %ebx,%esi
  80030a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80030c:	85 c0                	test   %eax,%eax
  80030e:	7e 17                	jle    800327 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	50                   	push   %eax
  800314:	6a 0a                	push   $0xa
  800316:	68 0a 1e 80 00       	push   $0x801e0a
  80031b:	6a 23                	push   $0x23
  80031d:	68 27 1e 80 00       	push   $0x801e27
  800322:	e8 56 0d 00 00       	call   80107d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	57                   	push   %edi
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800335:	be 00 00 00 00       	mov    $0x0,%esi
  80033a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80033f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800342:	8b 55 08             	mov    0x8(%ebp),%edx
  800345:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800348:	8b 7d 14             	mov    0x14(%ebp),%edi
  80034b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	57                   	push   %edi
  800356:	56                   	push   %esi
  800357:	53                   	push   %ebx
  800358:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800360:	b8 0d 00 00 00       	mov    $0xd,%eax
  800365:	8b 55 08             	mov    0x8(%ebp),%edx
  800368:	89 cb                	mov    %ecx,%ebx
  80036a:	89 cf                	mov    %ecx,%edi
  80036c:	89 ce                	mov    %ecx,%esi
  80036e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800370:	85 c0                	test   %eax,%eax
  800372:	7e 17                	jle    80038b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800374:	83 ec 0c             	sub    $0xc,%esp
  800377:	50                   	push   %eax
  800378:	6a 0d                	push   $0xd
  80037a:	68 0a 1e 80 00       	push   $0x801e0a
  80037f:	6a 23                	push   $0x23
  800381:	68 27 1e 80 00       	push   $0x801e27
  800386:	e8 f2 0c 00 00       	call   80107d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800396:	8b 45 08             	mov    0x8(%ebp),%eax
  800399:	05 00 00 00 30       	add    $0x30000000,%eax
  80039e:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c5:	89 c2                	mov    %eax,%edx
  8003c7:	c1 ea 16             	shr    $0x16,%edx
  8003ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d1:	f6 c2 01             	test   $0x1,%dl
  8003d4:	74 11                	je     8003e7 <fd_alloc+0x2d>
  8003d6:	89 c2                	mov    %eax,%edx
  8003d8:	c1 ea 0c             	shr    $0xc,%edx
  8003db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e2:	f6 c2 01             	test   $0x1,%dl
  8003e5:	75 09                	jne    8003f0 <fd_alloc+0x36>
			*fd_store = fd;
  8003e7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ee:	eb 17                	jmp    800407 <fd_alloc+0x4d>
  8003f0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003fa:	75 c9                	jne    8003c5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800402:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040f:	83 f8 1f             	cmp    $0x1f,%eax
  800412:	77 36                	ja     80044a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800414:	c1 e0 0c             	shl    $0xc,%eax
  800417:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80041c:	89 c2                	mov    %eax,%edx
  80041e:	c1 ea 16             	shr    $0x16,%edx
  800421:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800428:	f6 c2 01             	test   $0x1,%dl
  80042b:	74 24                	je     800451 <fd_lookup+0x48>
  80042d:	89 c2                	mov    %eax,%edx
  80042f:	c1 ea 0c             	shr    $0xc,%edx
  800432:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800439:	f6 c2 01             	test   $0x1,%dl
  80043c:	74 1a                	je     800458 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80043e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800441:	89 02                	mov    %eax,(%edx)
	return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 13                	jmp    80045d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044f:	eb 0c                	jmp    80045d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800451:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800456:	eb 05                	jmp    80045d <fd_lookup+0x54>
  800458:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80045d:	5d                   	pop    %ebp
  80045e:	c3                   	ret    

0080045f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800468:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80046d:	eb 13                	jmp    800482 <dev_lookup+0x23>
  80046f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800472:	39 08                	cmp    %ecx,(%eax)
  800474:	75 0c                	jne    800482 <dev_lookup+0x23>
			*dev = devtab[i];
  800476:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800479:	89 01                	mov    %eax,(%ecx)
			return 0;
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	eb 2e                	jmp    8004b0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800482:	8b 02                	mov    (%edx),%eax
  800484:	85 c0                	test   %eax,%eax
  800486:	75 e7                	jne    80046f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800488:	a1 04 40 80 00       	mov    0x804004,%eax
  80048d:	8b 40 48             	mov    0x48(%eax),%eax
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	51                   	push   %ecx
  800494:	50                   	push   %eax
  800495:	68 38 1e 80 00       	push   $0x801e38
  80049a:	e8 b7 0c 00 00       	call   801156 <cprintf>
	*dev = 0;
  80049f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	56                   	push   %esi
  8004b6:	53                   	push   %ebx
  8004b7:	83 ec 10             	sub    $0x10,%esp
  8004ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c3:	50                   	push   %eax
  8004c4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ca:	c1 e8 0c             	shr    $0xc,%eax
  8004cd:	50                   	push   %eax
  8004ce:	e8 36 ff ff ff       	call   800409 <fd_lookup>
  8004d3:	83 c4 08             	add    $0x8,%esp
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	78 05                	js     8004df <fd_close+0x2d>
	    || fd != fd2)
  8004da:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004dd:	74 0c                	je     8004eb <fd_close+0x39>
		return (must_exist ? r : 0);
  8004df:	84 db                	test   %bl,%bl
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e6:	0f 44 c2             	cmove  %edx,%eax
  8004e9:	eb 41                	jmp    80052c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f1:	50                   	push   %eax
  8004f2:	ff 36                	pushl  (%esi)
  8004f4:	e8 66 ff ff ff       	call   80045f <dev_lookup>
  8004f9:	89 c3                	mov    %eax,%ebx
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 c0                	test   %eax,%eax
  800500:	78 1a                	js     80051c <fd_close+0x6a>
		if (dev->dev_close)
  800502:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800505:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80050d:	85 c0                	test   %eax,%eax
  80050f:	74 0b                	je     80051c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800511:	83 ec 0c             	sub    $0xc,%esp
  800514:	56                   	push   %esi
  800515:	ff d0                	call   *%eax
  800517:	89 c3                	mov    %eax,%ebx
  800519:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	56                   	push   %esi
  800520:	6a 00                	push   $0x0
  800522:	e8 00 fd ff ff       	call   800227 <sys_page_unmap>
	return r;
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	89 d8                	mov    %ebx,%eax
}
  80052c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052f:	5b                   	pop    %ebx
  800530:	5e                   	pop    %esi
  800531:	5d                   	pop    %ebp
  800532:	c3                   	ret    

00800533 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800539:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053c:	50                   	push   %eax
  80053d:	ff 75 08             	pushl  0x8(%ebp)
  800540:	e8 c4 fe ff ff       	call   800409 <fd_lookup>
  800545:	83 c4 08             	add    $0x8,%esp
  800548:	85 c0                	test   %eax,%eax
  80054a:	78 10                	js     80055c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	6a 01                	push   $0x1
  800551:	ff 75 f4             	pushl  -0xc(%ebp)
  800554:	e8 59 ff ff ff       	call   8004b2 <fd_close>
  800559:	83 c4 10             	add    $0x10,%esp
}
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    

0080055e <close_all>:

void
close_all(void)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	53                   	push   %ebx
  800562:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800565:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	53                   	push   %ebx
  80056e:	e8 c0 ff ff ff       	call   800533 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800573:	83 c3 01             	add    $0x1,%ebx
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	83 fb 20             	cmp    $0x20,%ebx
  80057c:	75 ec                	jne    80056a <close_all+0xc>
		close(i);
}
  80057e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800581:	c9                   	leave  
  800582:	c3                   	ret    

00800583 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800583:	55                   	push   %ebp
  800584:	89 e5                	mov    %esp,%ebp
  800586:	57                   	push   %edi
  800587:	56                   	push   %esi
  800588:	53                   	push   %ebx
  800589:	83 ec 2c             	sub    $0x2c,%esp
  80058c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800592:	50                   	push   %eax
  800593:	ff 75 08             	pushl  0x8(%ebp)
  800596:	e8 6e fe ff ff       	call   800409 <fd_lookup>
  80059b:	83 c4 08             	add    $0x8,%esp
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	0f 88 c1 00 00 00    	js     800667 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	56                   	push   %esi
  8005aa:	e8 84 ff ff ff       	call   800533 <close>

	newfd = INDEX2FD(newfdnum);
  8005af:	89 f3                	mov    %esi,%ebx
  8005b1:	c1 e3 0c             	shl    $0xc,%ebx
  8005b4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ba:	83 c4 04             	add    $0x4,%esp
  8005bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c0:	e8 de fd ff ff       	call   8003a3 <fd2data>
  8005c5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c7:	89 1c 24             	mov    %ebx,(%esp)
  8005ca:	e8 d4 fd ff ff       	call   8003a3 <fd2data>
  8005cf:	83 c4 10             	add    $0x10,%esp
  8005d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d5:	89 f8                	mov    %edi,%eax
  8005d7:	c1 e8 16             	shr    $0x16,%eax
  8005da:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e1:	a8 01                	test   $0x1,%al
  8005e3:	74 37                	je     80061c <dup+0x99>
  8005e5:	89 f8                	mov    %edi,%eax
  8005e7:	c1 e8 0c             	shr    $0xc,%eax
  8005ea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f1:	f6 c2 01             	test   $0x1,%dl
  8005f4:	74 26                	je     80061c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fd:	83 ec 0c             	sub    $0xc,%esp
  800600:	25 07 0e 00 00       	and    $0xe07,%eax
  800605:	50                   	push   %eax
  800606:	ff 75 d4             	pushl  -0x2c(%ebp)
  800609:	6a 00                	push   $0x0
  80060b:	57                   	push   %edi
  80060c:	6a 00                	push   $0x0
  80060e:	e8 d2 fb ff ff       	call   8001e5 <sys_page_map>
  800613:	89 c7                	mov    %eax,%edi
  800615:	83 c4 20             	add    $0x20,%esp
  800618:	85 c0                	test   %eax,%eax
  80061a:	78 2e                	js     80064a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061f:	89 d0                	mov    %edx,%eax
  800621:	c1 e8 0c             	shr    $0xc,%eax
  800624:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062b:	83 ec 0c             	sub    $0xc,%esp
  80062e:	25 07 0e 00 00       	and    $0xe07,%eax
  800633:	50                   	push   %eax
  800634:	53                   	push   %ebx
  800635:	6a 00                	push   $0x0
  800637:	52                   	push   %edx
  800638:	6a 00                	push   $0x0
  80063a:	e8 a6 fb ff ff       	call   8001e5 <sys_page_map>
  80063f:	89 c7                	mov    %eax,%edi
  800641:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800644:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800646:	85 ff                	test   %edi,%edi
  800648:	79 1d                	jns    800667 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 00                	push   $0x0
  800650:	e8 d2 fb ff ff       	call   800227 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065b:	6a 00                	push   $0x0
  80065d:	e8 c5 fb ff ff       	call   800227 <sys_page_unmap>
	return r;
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	89 f8                	mov    %edi,%eax
}
  800667:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5f                   	pop    %edi
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	53                   	push   %ebx
  800673:	83 ec 14             	sub    $0x14,%esp
  800676:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800679:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067c:	50                   	push   %eax
  80067d:	53                   	push   %ebx
  80067e:	e8 86 fd ff ff       	call   800409 <fd_lookup>
  800683:	83 c4 08             	add    $0x8,%esp
  800686:	89 c2                	mov    %eax,%edx
  800688:	85 c0                	test   %eax,%eax
  80068a:	78 6d                	js     8006f9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800692:	50                   	push   %eax
  800693:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800696:	ff 30                	pushl  (%eax)
  800698:	e8 c2 fd ff ff       	call   80045f <dev_lookup>
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	78 4c                	js     8006f0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a7:	8b 42 08             	mov    0x8(%edx),%eax
  8006aa:	83 e0 03             	and    $0x3,%eax
  8006ad:	83 f8 01             	cmp    $0x1,%eax
  8006b0:	75 21                	jne    8006d3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8006b7:	8b 40 48             	mov    0x48(%eax),%eax
  8006ba:	83 ec 04             	sub    $0x4,%esp
  8006bd:	53                   	push   %ebx
  8006be:	50                   	push   %eax
  8006bf:	68 79 1e 80 00       	push   $0x801e79
  8006c4:	e8 8d 0a 00 00       	call   801156 <cprintf>
		return -E_INVAL;
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006d1:	eb 26                	jmp    8006f9 <read+0x8a>
	}
	if (!dev->dev_read)
  8006d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d6:	8b 40 08             	mov    0x8(%eax),%eax
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	74 17                	je     8006f4 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8006dd:	83 ec 04             	sub    $0x4,%esp
  8006e0:	ff 75 10             	pushl  0x10(%ebp)
  8006e3:	ff 75 0c             	pushl  0xc(%ebp)
  8006e6:	52                   	push   %edx
  8006e7:	ff d0                	call   *%eax
  8006e9:	89 c2                	mov    %eax,%edx
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	eb 09                	jmp    8006f9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f0:	89 c2                	mov    %eax,%edx
  8006f2:	eb 05                	jmp    8006f9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8006f9:	89 d0                	mov    %edx,%eax
  8006fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	57                   	push   %edi
  800704:	56                   	push   %esi
  800705:	53                   	push   %ebx
  800706:	83 ec 0c             	sub    $0xc,%esp
  800709:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800714:	eb 21                	jmp    800737 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800716:	83 ec 04             	sub    $0x4,%esp
  800719:	89 f0                	mov    %esi,%eax
  80071b:	29 d8                	sub    %ebx,%eax
  80071d:	50                   	push   %eax
  80071e:	89 d8                	mov    %ebx,%eax
  800720:	03 45 0c             	add    0xc(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	57                   	push   %edi
  800725:	e8 45 ff ff ff       	call   80066f <read>
		if (m < 0)
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 10                	js     800741 <readn+0x41>
			return m;
		if (m == 0)
  800731:	85 c0                	test   %eax,%eax
  800733:	74 0a                	je     80073f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800735:	01 c3                	add    %eax,%ebx
  800737:	39 f3                	cmp    %esi,%ebx
  800739:	72 db                	jb     800716 <readn+0x16>
  80073b:	89 d8                	mov    %ebx,%eax
  80073d:	eb 02                	jmp    800741 <readn+0x41>
  80073f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800741:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800744:	5b                   	pop    %ebx
  800745:	5e                   	pop    %esi
  800746:	5f                   	pop    %edi
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	53                   	push   %ebx
  80074d:	83 ec 14             	sub    $0x14,%esp
  800750:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800753:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800756:	50                   	push   %eax
  800757:	53                   	push   %ebx
  800758:	e8 ac fc ff ff       	call   800409 <fd_lookup>
  80075d:	83 c4 08             	add    $0x8,%esp
  800760:	89 c2                	mov    %eax,%edx
  800762:	85 c0                	test   %eax,%eax
  800764:	78 68                	js     8007ce <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076c:	50                   	push   %eax
  80076d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800770:	ff 30                	pushl  (%eax)
  800772:	e8 e8 fc ff ff       	call   80045f <dev_lookup>
  800777:	83 c4 10             	add    $0x10,%esp
  80077a:	85 c0                	test   %eax,%eax
  80077c:	78 47                	js     8007c5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800781:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800785:	75 21                	jne    8007a8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800787:	a1 04 40 80 00       	mov    0x804004,%eax
  80078c:	8b 40 48             	mov    0x48(%eax),%eax
  80078f:	83 ec 04             	sub    $0x4,%esp
  800792:	53                   	push   %ebx
  800793:	50                   	push   %eax
  800794:	68 95 1e 80 00       	push   $0x801e95
  800799:	e8 b8 09 00 00       	call   801156 <cprintf>
		return -E_INVAL;
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a6:	eb 26                	jmp    8007ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	74 17                	je     8007c9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b2:	83 ec 04             	sub    $0x4,%esp
  8007b5:	ff 75 10             	pushl  0x10(%ebp)
  8007b8:	ff 75 0c             	pushl  0xc(%ebp)
  8007bb:	50                   	push   %eax
  8007bc:	ff d2                	call   *%edx
  8007be:	89 c2                	mov    %eax,%edx
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	eb 09                	jmp    8007ce <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c5:	89 c2                	mov    %eax,%edx
  8007c7:	eb 05                	jmp    8007ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ce:	89 d0                	mov    %edx,%eax
  8007d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007de:	50                   	push   %eax
  8007df:	ff 75 08             	pushl  0x8(%ebp)
  8007e2:	e8 22 fc ff ff       	call   800409 <fd_lookup>
  8007e7:	83 c4 08             	add    $0x8,%esp
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	78 0e                	js     8007fc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	83 ec 14             	sub    $0x14,%esp
  800805:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800808:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080b:	50                   	push   %eax
  80080c:	53                   	push   %ebx
  80080d:	e8 f7 fb ff ff       	call   800409 <fd_lookup>
  800812:	83 c4 08             	add    $0x8,%esp
  800815:	89 c2                	mov    %eax,%edx
  800817:	85 c0                	test   %eax,%eax
  800819:	78 65                	js     800880 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800825:	ff 30                	pushl  (%eax)
  800827:	e8 33 fc ff ff       	call   80045f <dev_lookup>
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	85 c0                	test   %eax,%eax
  800831:	78 44                	js     800877 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800833:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800836:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80083a:	75 21                	jne    80085d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800841:	8b 40 48             	mov    0x48(%eax),%eax
  800844:	83 ec 04             	sub    $0x4,%esp
  800847:	53                   	push   %ebx
  800848:	50                   	push   %eax
  800849:	68 58 1e 80 00       	push   $0x801e58
  80084e:	e8 03 09 00 00       	call   801156 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80085b:	eb 23                	jmp    800880 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80085d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800860:	8b 52 18             	mov    0x18(%edx),%edx
  800863:	85 d2                	test   %edx,%edx
  800865:	74 14                	je     80087b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	ff 75 0c             	pushl  0xc(%ebp)
  80086d:	50                   	push   %eax
  80086e:	ff d2                	call   *%edx
  800870:	89 c2                	mov    %eax,%edx
  800872:	83 c4 10             	add    $0x10,%esp
  800875:	eb 09                	jmp    800880 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800877:	89 c2                	mov    %eax,%edx
  800879:	eb 05                	jmp    800880 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80087b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800880:	89 d0                	mov    %edx,%eax
  800882:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	83 ec 14             	sub    $0x14,%esp
  80088e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800891:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800894:	50                   	push   %eax
  800895:	ff 75 08             	pushl  0x8(%ebp)
  800898:	e8 6c fb ff ff       	call   800409 <fd_lookup>
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	85 c0                	test   %eax,%eax
  8008a4:	78 58                	js     8008fe <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a6:	83 ec 08             	sub    $0x8,%esp
  8008a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ac:	50                   	push   %eax
  8008ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b0:	ff 30                	pushl  (%eax)
  8008b2:	e8 a8 fb ff ff       	call   80045f <dev_lookup>
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	78 37                	js     8008f5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c5:	74 32                	je     8008f9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ca:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d1:	00 00 00 
	stat->st_isdir = 0;
  8008d4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008db:	00 00 00 
	stat->st_dev = dev;
  8008de:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	53                   	push   %ebx
  8008e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8008eb:	ff 50 14             	call   *0x14(%eax)
  8008ee:	89 c2                	mov    %eax,%edx
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	eb 09                	jmp    8008fe <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f5:	89 c2                	mov    %eax,%edx
  8008f7:	eb 05                	jmp    8008fe <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008fe:	89 d0                	mov    %edx,%eax
  800900:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	6a 00                	push   $0x0
  80090f:	ff 75 08             	pushl  0x8(%ebp)
  800912:	e8 e3 01 00 00       	call   800afa <open>
  800917:	89 c3                	mov    %eax,%ebx
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	85 c0                	test   %eax,%eax
  80091e:	78 1b                	js     80093b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800920:	83 ec 08             	sub    $0x8,%esp
  800923:	ff 75 0c             	pushl  0xc(%ebp)
  800926:	50                   	push   %eax
  800927:	e8 5b ff ff ff       	call   800887 <fstat>
  80092c:	89 c6                	mov    %eax,%esi
	close(fd);
  80092e:	89 1c 24             	mov    %ebx,(%esp)
  800931:	e8 fd fb ff ff       	call   800533 <close>
	return r;
  800936:	83 c4 10             	add    $0x10,%esp
  800939:	89 f0                	mov    %esi,%eax
}
  80093b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	89 c6                	mov    %eax,%esi
  800949:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80094b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800952:	75 12                	jne    800966 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800954:	83 ec 0c             	sub    $0xc,%esp
  800957:	6a 01                	push   $0x1
  800959:	e8 98 11 00 00       	call   801af6 <ipc_find_env>
  80095e:	a3 00 40 80 00       	mov    %eax,0x804000
  800963:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800966:	6a 07                	push   $0x7
  800968:	68 00 50 80 00       	push   $0x805000
  80096d:	56                   	push   %esi
  80096e:	ff 35 00 40 80 00    	pushl  0x804000
  800974:	e8 1b 11 00 00       	call   801a94 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800979:	83 c4 0c             	add    $0xc,%esp
  80097c:	6a 00                	push   $0x0
  80097e:	53                   	push   %ebx
  80097f:	6a 00                	push   $0x0
  800981:	e8 9c 10 00 00       	call   801a22 <ipc_recv>
}
  800986:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 40 0c             	mov    0xc(%eax),%eax
  800999:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b0:	e8 8d ff ff ff       	call   800942 <fsipc>
}
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d2:	e8 6b ff ff ff       	call   800942 <fsipc>
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	53                   	push   %ebx
  8009dd:	83 ec 04             	sub    $0x4,%esp
  8009e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f3:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f8:	e8 45 ff ff ff       	call   800942 <fsipc>
  8009fd:	85 c0                	test   %eax,%eax
  8009ff:	78 2c                	js     800a2d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a01:	83 ec 08             	sub    $0x8,%esp
  800a04:	68 00 50 80 00       	push   $0x805000
  800a09:	53                   	push   %ebx
  800a0a:	e8 cc 0c 00 00       	call   8016db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0f:	a1 80 50 80 00       	mov    0x805080,%eax
  800a14:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a1a:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a25:	83 c4 10             	add    $0x10,%esp
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a30:	c9                   	leave  
  800a31:	c3                   	ret    

00800a32 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	83 ec 0c             	sub    $0xc,%esp
  800a38:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3e:	8b 52 0c             	mov    0xc(%edx),%edx
  800a41:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a47:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a4c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a51:	0f 47 c2             	cmova  %edx,%eax
  800a54:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a59:	50                   	push   %eax
  800a5a:	ff 75 0c             	pushl  0xc(%ebp)
  800a5d:	68 08 50 80 00       	push   $0x805008
  800a62:	e8 06 0e 00 00       	call   80186d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a67:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a71:	e8 cc fe ff ff       	call   800942 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 40 0c             	mov    0xc(%eax),%eax
  800a86:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9b:	e8 a2 fe ff ff       	call   800942 <fsipc>
  800aa0:	89 c3                	mov    %eax,%ebx
  800aa2:	85 c0                	test   %eax,%eax
  800aa4:	78 4b                	js     800af1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa6:	39 c6                	cmp    %eax,%esi
  800aa8:	73 16                	jae    800ac0 <devfile_read+0x48>
  800aaa:	68 c4 1e 80 00       	push   $0x801ec4
  800aaf:	68 cb 1e 80 00       	push   $0x801ecb
  800ab4:	6a 7c                	push   $0x7c
  800ab6:	68 e0 1e 80 00       	push   $0x801ee0
  800abb:	e8 bd 05 00 00       	call   80107d <_panic>
	assert(r <= PGSIZE);
  800ac0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac5:	7e 16                	jle    800add <devfile_read+0x65>
  800ac7:	68 eb 1e 80 00       	push   $0x801eeb
  800acc:	68 cb 1e 80 00       	push   $0x801ecb
  800ad1:	6a 7d                	push   $0x7d
  800ad3:	68 e0 1e 80 00       	push   $0x801ee0
  800ad8:	e8 a0 05 00 00       	call   80107d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800add:	83 ec 04             	sub    $0x4,%esp
  800ae0:	50                   	push   %eax
  800ae1:	68 00 50 80 00       	push   $0x805000
  800ae6:	ff 75 0c             	pushl  0xc(%ebp)
  800ae9:	e8 7f 0d 00 00       	call   80186d <memmove>
	return r;
  800aee:	83 c4 10             	add    $0x10,%esp
}
  800af1:	89 d8                	mov    %ebx,%eax
  800af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	83 ec 20             	sub    $0x20,%esp
  800b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b04:	53                   	push   %ebx
  800b05:	e8 98 0b 00 00       	call   8016a2 <strlen>
  800b0a:	83 c4 10             	add    $0x10,%esp
  800b0d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b12:	7f 67                	jg     800b7b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1a:	50                   	push   %eax
  800b1b:	e8 9a f8 ff ff       	call   8003ba <fd_alloc>
  800b20:	83 c4 10             	add    $0x10,%esp
		return r;
  800b23:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	78 57                	js     800b80 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b29:	83 ec 08             	sub    $0x8,%esp
  800b2c:	53                   	push   %ebx
  800b2d:	68 00 50 80 00       	push   $0x805000
  800b32:	e8 a4 0b 00 00       	call   8016db <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b42:	b8 01 00 00 00       	mov    $0x1,%eax
  800b47:	e8 f6 fd ff ff       	call   800942 <fsipc>
  800b4c:	89 c3                	mov    %eax,%ebx
  800b4e:	83 c4 10             	add    $0x10,%esp
  800b51:	85 c0                	test   %eax,%eax
  800b53:	79 14                	jns    800b69 <open+0x6f>
		fd_close(fd, 0);
  800b55:	83 ec 08             	sub    $0x8,%esp
  800b58:	6a 00                	push   $0x0
  800b5a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5d:	e8 50 f9 ff ff       	call   8004b2 <fd_close>
		return r;
  800b62:	83 c4 10             	add    $0x10,%esp
  800b65:	89 da                	mov    %ebx,%edx
  800b67:	eb 17                	jmp    800b80 <open+0x86>
	}

	return fd2num(fd);
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6f:	e8 1f f8 ff ff       	call   800393 <fd2num>
  800b74:	89 c2                	mov    %eax,%edx
  800b76:	83 c4 10             	add    $0x10,%esp
  800b79:	eb 05                	jmp    800b80 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b80:	89 d0                	mov    %edx,%eax
  800b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 08 00 00 00       	mov    $0x8,%eax
  800b97:	e8 a6 fd ff ff       	call   800942 <fsipc>
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba6:	83 ec 0c             	sub    $0xc,%esp
  800ba9:	ff 75 08             	pushl  0x8(%ebp)
  800bac:	e8 f2 f7 ff ff       	call   8003a3 <fd2data>
  800bb1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bb3:	83 c4 08             	add    $0x8,%esp
  800bb6:	68 f7 1e 80 00       	push   $0x801ef7
  800bbb:	53                   	push   %ebx
  800bbc:	e8 1a 0b 00 00       	call   8016db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bc1:	8b 46 04             	mov    0x4(%esi),%eax
  800bc4:	2b 06                	sub    (%esi),%eax
  800bc6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bcc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bd3:	00 00 00 
	stat->st_dev = &devpipe;
  800bd6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bdd:	30 80 00 
	return 0;
}
  800be0:	b8 00 00 00 00       	mov    $0x0,%eax
  800be5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf6:	53                   	push   %ebx
  800bf7:	6a 00                	push   $0x0
  800bf9:	e8 29 f6 ff ff       	call   800227 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bfe:	89 1c 24             	mov    %ebx,(%esp)
  800c01:	e8 9d f7 ff ff       	call   8003a3 <fd2data>
  800c06:	83 c4 08             	add    $0x8,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 00                	push   $0x0
  800c0c:	e8 16 f6 ff ff       	call   800227 <sys_page_unmap>
}
  800c11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 1c             	sub    $0x1c,%esp
  800c1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c22:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c24:	a1 04 40 80 00       	mov    0x804004,%eax
  800c29:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	ff 75 e0             	pushl  -0x20(%ebp)
  800c32:	e8 f8 0e 00 00       	call   801b2f <pageref>
  800c37:	89 c3                	mov    %eax,%ebx
  800c39:	89 3c 24             	mov    %edi,(%esp)
  800c3c:	e8 ee 0e 00 00       	call   801b2f <pageref>
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	39 c3                	cmp    %eax,%ebx
  800c46:	0f 94 c1             	sete   %cl
  800c49:	0f b6 c9             	movzbl %cl,%ecx
  800c4c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c4f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c55:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c58:	39 ce                	cmp    %ecx,%esi
  800c5a:	74 1b                	je     800c77 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c5c:	39 c3                	cmp    %eax,%ebx
  800c5e:	75 c4                	jne    800c24 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c60:	8b 42 58             	mov    0x58(%edx),%eax
  800c63:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c66:	50                   	push   %eax
  800c67:	56                   	push   %esi
  800c68:	68 fe 1e 80 00       	push   $0x801efe
  800c6d:	e8 e4 04 00 00       	call   801156 <cprintf>
  800c72:	83 c4 10             	add    $0x10,%esp
  800c75:	eb ad                	jmp    800c24 <_pipeisclosed+0xe>
	}
}
  800c77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 28             	sub    $0x28,%esp
  800c8b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c8e:	56                   	push   %esi
  800c8f:	e8 0f f7 ff ff       	call   8003a3 <fd2data>
  800c94:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9e:	eb 4b                	jmp    800ceb <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ca0:	89 da                	mov    %ebx,%edx
  800ca2:	89 f0                	mov    %esi,%eax
  800ca4:	e8 6d ff ff ff       	call   800c16 <_pipeisclosed>
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	75 48                	jne    800cf5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cad:	e8 d1 f4 ff ff       	call   800183 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb2:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb5:	8b 0b                	mov    (%ebx),%ecx
  800cb7:	8d 51 20             	lea    0x20(%ecx),%edx
  800cba:	39 d0                	cmp    %edx,%eax
  800cbc:	73 e2                	jae    800ca0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc8:	89 c2                	mov    %eax,%edx
  800cca:	c1 fa 1f             	sar    $0x1f,%edx
  800ccd:	89 d1                	mov    %edx,%ecx
  800ccf:	c1 e9 1b             	shr    $0x1b,%ecx
  800cd2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd5:	83 e2 1f             	and    $0x1f,%edx
  800cd8:	29 ca                	sub    %ecx,%edx
  800cda:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cde:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ce2:	83 c0 01             	add    $0x1,%eax
  800ce5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce8:	83 c7 01             	add    $0x1,%edi
  800ceb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cee:	75 c2                	jne    800cb2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cf0:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf3:	eb 05                	jmp    800cfa <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 18             	sub    $0x18,%esp
  800d0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d0e:	57                   	push   %edi
  800d0f:	e8 8f f6 ff ff       	call   8003a3 <fd2data>
  800d14:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1e:	eb 3d                	jmp    800d5d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d20:	85 db                	test   %ebx,%ebx
  800d22:	74 04                	je     800d28 <devpipe_read+0x26>
				return i;
  800d24:	89 d8                	mov    %ebx,%eax
  800d26:	eb 44                	jmp    800d6c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d28:	89 f2                	mov    %esi,%edx
  800d2a:	89 f8                	mov    %edi,%eax
  800d2c:	e8 e5 fe ff ff       	call   800c16 <_pipeisclosed>
  800d31:	85 c0                	test   %eax,%eax
  800d33:	75 32                	jne    800d67 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d35:	e8 49 f4 ff ff       	call   800183 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d3a:	8b 06                	mov    (%esi),%eax
  800d3c:	3b 46 04             	cmp    0x4(%esi),%eax
  800d3f:	74 df                	je     800d20 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d41:	99                   	cltd   
  800d42:	c1 ea 1b             	shr    $0x1b,%edx
  800d45:	01 d0                	add    %edx,%eax
  800d47:	83 e0 1f             	and    $0x1f,%eax
  800d4a:	29 d0                	sub    %edx,%eax
  800d4c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d57:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d5a:	83 c3 01             	add    $0x1,%ebx
  800d5d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d60:	75 d8                	jne    800d3a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d62:	8b 45 10             	mov    0x10(%ebp),%eax
  800d65:	eb 05                	jmp    800d6c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d67:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d7f:	50                   	push   %eax
  800d80:	e8 35 f6 ff ff       	call   8003ba <fd_alloc>
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	89 c2                	mov    %eax,%edx
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	0f 88 2c 01 00 00    	js     800ebe <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	68 07 04 00 00       	push   $0x407
  800d9a:	ff 75 f4             	pushl  -0xc(%ebp)
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 fe f3 ff ff       	call   8001a2 <sys_page_alloc>
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	89 c2                	mov    %eax,%edx
  800da9:	85 c0                	test   %eax,%eax
  800dab:	0f 88 0d 01 00 00    	js     800ebe <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db7:	50                   	push   %eax
  800db8:	e8 fd f5 ff ff       	call   8003ba <fd_alloc>
  800dbd:	89 c3                	mov    %eax,%ebx
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	0f 88 e2 00 00 00    	js     800eac <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	68 07 04 00 00       	push   $0x407
  800dd2:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd5:	6a 00                	push   $0x0
  800dd7:	e8 c6 f3 ff ff       	call   8001a2 <sys_page_alloc>
  800ddc:	89 c3                	mov    %eax,%ebx
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	85 c0                	test   %eax,%eax
  800de3:	0f 88 c3 00 00 00    	js     800eac <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de9:	83 ec 0c             	sub    $0xc,%esp
  800dec:	ff 75 f4             	pushl  -0xc(%ebp)
  800def:	e8 af f5 ff ff       	call   8003a3 <fd2data>
  800df4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df6:	83 c4 0c             	add    $0xc,%esp
  800df9:	68 07 04 00 00       	push   $0x407
  800dfe:	50                   	push   %eax
  800dff:	6a 00                	push   $0x0
  800e01:	e8 9c f3 ff ff       	call   8001a2 <sys_page_alloc>
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	83 c4 10             	add    $0x10,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	0f 88 89 00 00 00    	js     800e9c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	ff 75 f0             	pushl  -0x10(%ebp)
  800e19:	e8 85 f5 ff ff       	call   8003a3 <fd2data>
  800e1e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e25:	50                   	push   %eax
  800e26:	6a 00                	push   $0x0
  800e28:	56                   	push   %esi
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 b5 f3 ff ff       	call   8001e5 <sys_page_map>
  800e30:	89 c3                	mov    %eax,%ebx
  800e32:	83 c4 20             	add    $0x20,%esp
  800e35:	85 c0                	test   %eax,%eax
  800e37:	78 55                	js     800e8e <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e39:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e42:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e47:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e4e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e57:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	ff 75 f4             	pushl  -0xc(%ebp)
  800e69:	e8 25 f5 ff ff       	call   800393 <fd2num>
  800e6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e71:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e73:	83 c4 04             	add    $0x4,%esp
  800e76:	ff 75 f0             	pushl  -0x10(%ebp)
  800e79:	e8 15 f5 ff ff       	call   800393 <fd2num>
  800e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e81:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8c:	eb 30                	jmp    800ebe <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	56                   	push   %esi
  800e92:	6a 00                	push   $0x0
  800e94:	e8 8e f3 ff ff       	call   800227 <sys_page_unmap>
  800e99:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e9c:	83 ec 08             	sub    $0x8,%esp
  800e9f:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea2:	6a 00                	push   $0x0
  800ea4:	e8 7e f3 ff ff       	call   800227 <sys_page_unmap>
  800ea9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb2:	6a 00                	push   $0x0
  800eb4:	e8 6e f3 ff ff       	call   800227 <sys_page_unmap>
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ebe:	89 d0                	mov    %edx,%eax
  800ec0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ecd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed0:	50                   	push   %eax
  800ed1:	ff 75 08             	pushl  0x8(%ebp)
  800ed4:	e8 30 f5 ff ff       	call   800409 <fd_lookup>
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	85 c0                	test   %eax,%eax
  800ede:	78 18                	js     800ef8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee6:	e8 b8 f4 ff ff       	call   8003a3 <fd2data>
	return _pipeisclosed(fd, p);
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef0:	e8 21 fd ff ff       	call   800c16 <_pipeisclosed>
  800ef5:	83 c4 10             	add    $0x10,%esp
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800efd:	b8 00 00 00 00       	mov    $0x0,%eax
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f0a:	68 16 1f 80 00       	push   $0x801f16
  800f0f:	ff 75 0c             	pushl  0xc(%ebp)
  800f12:	e8 c4 07 00 00       	call   8016db <strcpy>
	return 0;
}
  800f17:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1c:	c9                   	leave  
  800f1d:	c3                   	ret    

00800f1e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f35:	eb 2d                	jmp    800f64 <devcons_write+0x46>
		m = n - tot;
  800f37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f3c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f3f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f44:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f47:	83 ec 04             	sub    $0x4,%esp
  800f4a:	53                   	push   %ebx
  800f4b:	03 45 0c             	add    0xc(%ebp),%eax
  800f4e:	50                   	push   %eax
  800f4f:	57                   	push   %edi
  800f50:	e8 18 09 00 00       	call   80186d <memmove>
		sys_cputs(buf, m);
  800f55:	83 c4 08             	add    $0x8,%esp
  800f58:	53                   	push   %ebx
  800f59:	57                   	push   %edi
  800f5a:	e8 87 f1 ff ff       	call   8000e6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5f:	01 de                	add    %ebx,%esi
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	89 f0                	mov    %esi,%eax
  800f66:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f69:	72 cc                	jb     800f37 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5f                   	pop    %edi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	83 ec 08             	sub    $0x8,%esp
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f82:	74 2a                	je     800fae <devcons_read+0x3b>
  800f84:	eb 05                	jmp    800f8b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f86:	e8 f8 f1 ff ff       	call   800183 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f8b:	e8 74 f1 ff ff       	call   800104 <sys_cgetc>
  800f90:	85 c0                	test   %eax,%eax
  800f92:	74 f2                	je     800f86 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 16                	js     800fae <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f98:	83 f8 04             	cmp    $0x4,%eax
  800f9b:	74 0c                	je     800fa9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa0:	88 02                	mov    %al,(%edx)
	return 1;
  800fa2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa7:	eb 05                	jmp    800fae <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fbc:	6a 01                	push   $0x1
  800fbe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	e8 1f f1 ff ff       	call   8000e6 <sys_cputs>
}
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    

00800fcc <getchar>:

int
getchar(void)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fd2:	6a 01                	push   $0x1
  800fd4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	6a 00                	push   $0x0
  800fda:	e8 90 f6 ff ff       	call   80066f <read>
	if (r < 0)
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 0f                	js     800ff5 <getchar+0x29>
		return r;
	if (r < 1)
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	7e 06                	jle    800ff0 <getchar+0x24>
		return -E_EOF;
	return c;
  800fea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fee:	eb 05                	jmp    800ff5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ff0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ffd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801000:	50                   	push   %eax
  801001:	ff 75 08             	pushl  0x8(%ebp)
  801004:	e8 00 f4 ff ff       	call   800409 <fd_lookup>
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 11                	js     801021 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801013:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801019:	39 10                	cmp    %edx,(%eax)
  80101b:	0f 94 c0             	sete   %al
  80101e:	0f b6 c0             	movzbl %al,%eax
}
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <opencons>:

int
opencons(void)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801029:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102c:	50                   	push   %eax
  80102d:	e8 88 f3 ff ff       	call   8003ba <fd_alloc>
  801032:	83 c4 10             	add    $0x10,%esp
		return r;
  801035:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801037:	85 c0                	test   %eax,%eax
  801039:	78 3e                	js     801079 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	68 07 04 00 00       	push   $0x407
  801043:	ff 75 f4             	pushl  -0xc(%ebp)
  801046:	6a 00                	push   $0x0
  801048:	e8 55 f1 ff ff       	call   8001a2 <sys_page_alloc>
  80104d:	83 c4 10             	add    $0x10,%esp
		return r;
  801050:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801052:	85 c0                	test   %eax,%eax
  801054:	78 23                	js     801079 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801056:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80105c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801061:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801064:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	50                   	push   %eax
  80106f:	e8 1f f3 ff ff       	call   800393 <fd2num>
  801074:	89 c2                	mov    %eax,%edx
  801076:	83 c4 10             	add    $0x10,%esp
}
  801079:	89 d0                	mov    %edx,%eax
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801082:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801085:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80108b:	e8 d4 f0 ff ff       	call   800164 <sys_getenvid>
  801090:	83 ec 0c             	sub    $0xc,%esp
  801093:	ff 75 0c             	pushl  0xc(%ebp)
  801096:	ff 75 08             	pushl  0x8(%ebp)
  801099:	56                   	push   %esi
  80109a:	50                   	push   %eax
  80109b:	68 24 1f 80 00       	push   $0x801f24
  8010a0:	e8 b1 00 00 00       	call   801156 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a5:	83 c4 18             	add    $0x18,%esp
  8010a8:	53                   	push   %ebx
  8010a9:	ff 75 10             	pushl  0x10(%ebp)
  8010ac:	e8 54 00 00 00       	call   801105 <vcprintf>
	cprintf("\n");
  8010b1:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  8010b8:	e8 99 00 00 00       	call   801156 <cprintf>
  8010bd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c0:	cc                   	int3   
  8010c1:	eb fd                	jmp    8010c0 <_panic+0x43>

008010c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	53                   	push   %ebx
  8010c7:	83 ec 04             	sub    $0x4,%esp
  8010ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010cd:	8b 13                	mov    (%ebx),%edx
  8010cf:	8d 42 01             	lea    0x1(%edx),%eax
  8010d2:	89 03                	mov    %eax,(%ebx)
  8010d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e0:	75 1a                	jne    8010fc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010e2:	83 ec 08             	sub    $0x8,%esp
  8010e5:	68 ff 00 00 00       	push   $0xff
  8010ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ed:	50                   	push   %eax
  8010ee:	e8 f3 ef ff ff       	call   8000e6 <sys_cputs>
		b->idx = 0;
  8010f3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801103:	c9                   	leave  
  801104:	c3                   	ret    

00801105 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80110e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801115:	00 00 00 
	b.cnt = 0;
  801118:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80111f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801122:	ff 75 0c             	pushl  0xc(%ebp)
  801125:	ff 75 08             	pushl  0x8(%ebp)
  801128:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80112e:	50                   	push   %eax
  80112f:	68 c3 10 80 00       	push   $0x8010c3
  801134:	e8 54 01 00 00       	call   80128d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801139:	83 c4 08             	add    $0x8,%esp
  80113c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801142:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	e8 98 ef ff ff       	call   8000e6 <sys_cputs>

	return b.cnt;
}
  80114e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80115c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80115f:	50                   	push   %eax
  801160:	ff 75 08             	pushl  0x8(%ebp)
  801163:	e8 9d ff ff ff       	call   801105 <vcprintf>
	va_end(ap);

	return cnt;
}
  801168:	c9                   	leave  
  801169:	c3                   	ret    

0080116a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	57                   	push   %edi
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	83 ec 1c             	sub    $0x1c,%esp
  801173:	89 c7                	mov    %eax,%edi
  801175:	89 d6                	mov    %edx,%esi
  801177:	8b 45 08             	mov    0x8(%ebp),%eax
  80117a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80117d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801180:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801183:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801186:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80118e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801191:	39 d3                	cmp    %edx,%ebx
  801193:	72 05                	jb     80119a <printnum+0x30>
  801195:	39 45 10             	cmp    %eax,0x10(%ebp)
  801198:	77 45                	ja     8011df <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	ff 75 18             	pushl  0x18(%ebp)
  8011a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a6:	53                   	push   %ebx
  8011a7:	ff 75 10             	pushl  0x10(%ebp)
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b9:	e8 b2 09 00 00       	call   801b70 <__udivdi3>
  8011be:	83 c4 18             	add    $0x18,%esp
  8011c1:	52                   	push   %edx
  8011c2:	50                   	push   %eax
  8011c3:	89 f2                	mov    %esi,%edx
  8011c5:	89 f8                	mov    %edi,%eax
  8011c7:	e8 9e ff ff ff       	call   80116a <printnum>
  8011cc:	83 c4 20             	add    $0x20,%esp
  8011cf:	eb 18                	jmp    8011e9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011d1:	83 ec 08             	sub    $0x8,%esp
  8011d4:	56                   	push   %esi
  8011d5:	ff 75 18             	pushl  0x18(%ebp)
  8011d8:	ff d7                	call   *%edi
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	eb 03                	jmp    8011e2 <printnum+0x78>
  8011df:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011e2:	83 eb 01             	sub    $0x1,%ebx
  8011e5:	85 db                	test   %ebx,%ebx
  8011e7:	7f e8                	jg     8011d1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e9:	83 ec 08             	sub    $0x8,%esp
  8011ec:	56                   	push   %esi
  8011ed:	83 ec 04             	sub    $0x4,%esp
  8011f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8011fc:	e8 9f 0a 00 00       	call   801ca0 <__umoddi3>
  801201:	83 c4 14             	add    $0x14,%esp
  801204:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  80120b:	50                   	push   %eax
  80120c:	ff d7                	call   *%edi
}
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5f                   	pop    %edi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80121c:	83 fa 01             	cmp    $0x1,%edx
  80121f:	7e 0e                	jle    80122f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801221:	8b 10                	mov    (%eax),%edx
  801223:	8d 4a 08             	lea    0x8(%edx),%ecx
  801226:	89 08                	mov    %ecx,(%eax)
  801228:	8b 02                	mov    (%edx),%eax
  80122a:	8b 52 04             	mov    0x4(%edx),%edx
  80122d:	eb 22                	jmp    801251 <getuint+0x38>
	else if (lflag)
  80122f:	85 d2                	test   %edx,%edx
  801231:	74 10                	je     801243 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801233:	8b 10                	mov    (%eax),%edx
  801235:	8d 4a 04             	lea    0x4(%edx),%ecx
  801238:	89 08                	mov    %ecx,(%eax)
  80123a:	8b 02                	mov    (%edx),%eax
  80123c:	ba 00 00 00 00       	mov    $0x0,%edx
  801241:	eb 0e                	jmp    801251 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801243:	8b 10                	mov    (%eax),%edx
  801245:	8d 4a 04             	lea    0x4(%edx),%ecx
  801248:	89 08                	mov    %ecx,(%eax)
  80124a:	8b 02                	mov    (%edx),%eax
  80124c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801259:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80125d:	8b 10                	mov    (%eax),%edx
  80125f:	3b 50 04             	cmp    0x4(%eax),%edx
  801262:	73 0a                	jae    80126e <sprintputch+0x1b>
		*b->buf++ = ch;
  801264:	8d 4a 01             	lea    0x1(%edx),%ecx
  801267:	89 08                	mov    %ecx,(%eax)
  801269:	8b 45 08             	mov    0x8(%ebp),%eax
  80126c:	88 02                	mov    %al,(%edx)
}
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801276:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801279:	50                   	push   %eax
  80127a:	ff 75 10             	pushl  0x10(%ebp)
  80127d:	ff 75 0c             	pushl  0xc(%ebp)
  801280:	ff 75 08             	pushl  0x8(%ebp)
  801283:	e8 05 00 00 00       	call   80128d <vprintfmt>
	va_end(ap);
}
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	c9                   	leave  
  80128c:	c3                   	ret    

0080128d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	57                   	push   %edi
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
  801293:	83 ec 2c             	sub    $0x2c,%esp
  801296:	8b 75 08             	mov    0x8(%ebp),%esi
  801299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80129c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80129f:	eb 12                	jmp    8012b3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	0f 84 89 03 00 00    	je     801632 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	53                   	push   %ebx
  8012ad:	50                   	push   %eax
  8012ae:	ff d6                	call   *%esi
  8012b0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012b3:	83 c7 01             	add    $0x1,%edi
  8012b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012ba:	83 f8 25             	cmp    $0x25,%eax
  8012bd:	75 e2                	jne    8012a1 <vprintfmt+0x14>
  8012bf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012c3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012ca:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012d1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8012dd:	eb 07                	jmp    8012e6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012df:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012e2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e6:	8d 47 01             	lea    0x1(%edi),%eax
  8012e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ec:	0f b6 07             	movzbl (%edi),%eax
  8012ef:	0f b6 c8             	movzbl %al,%ecx
  8012f2:	83 e8 23             	sub    $0x23,%eax
  8012f5:	3c 55                	cmp    $0x55,%al
  8012f7:	0f 87 1a 03 00 00    	ja     801617 <vprintfmt+0x38a>
  8012fd:	0f b6 c0             	movzbl %al,%eax
  801300:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  801307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80130a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80130e:	eb d6                	jmp    8012e6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801313:	b8 00 00 00 00       	mov    $0x0,%eax
  801318:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80131b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80131e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801322:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801325:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801328:	83 fa 09             	cmp    $0x9,%edx
  80132b:	77 39                	ja     801366 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80132d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801330:	eb e9                	jmp    80131b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801332:	8b 45 14             	mov    0x14(%ebp),%eax
  801335:	8d 48 04             	lea    0x4(%eax),%ecx
  801338:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80133b:	8b 00                	mov    (%eax),%eax
  80133d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801343:	eb 27                	jmp    80136c <vprintfmt+0xdf>
  801345:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801348:	85 c0                	test   %eax,%eax
  80134a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80134f:	0f 49 c8             	cmovns %eax,%ecx
  801352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801358:	eb 8c                	jmp    8012e6 <vprintfmt+0x59>
  80135a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80135d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801364:	eb 80                	jmp    8012e6 <vprintfmt+0x59>
  801366:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801369:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80136c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801370:	0f 89 70 ff ff ff    	jns    8012e6 <vprintfmt+0x59>
				width = precision, precision = -1;
  801376:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801379:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80137c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801383:	e9 5e ff ff ff       	jmp    8012e6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801388:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80138e:	e9 53 ff ff ff       	jmp    8012e6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801393:	8b 45 14             	mov    0x14(%ebp),%eax
  801396:	8d 50 04             	lea    0x4(%eax),%edx
  801399:	89 55 14             	mov    %edx,0x14(%ebp)
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	53                   	push   %ebx
  8013a0:	ff 30                	pushl  (%eax)
  8013a2:	ff d6                	call   *%esi
			break;
  8013a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013aa:	e9 04 ff ff ff       	jmp    8012b3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013af:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b2:	8d 50 04             	lea    0x4(%eax),%edx
  8013b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b8:	8b 00                	mov    (%eax),%eax
  8013ba:	99                   	cltd   
  8013bb:	31 d0                	xor    %edx,%eax
  8013bd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013bf:	83 f8 0f             	cmp    $0xf,%eax
  8013c2:	7f 0b                	jg     8013cf <vprintfmt+0x142>
  8013c4:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013cb:	85 d2                	test   %edx,%edx
  8013cd:	75 18                	jne    8013e7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013cf:	50                   	push   %eax
  8013d0:	68 5f 1f 80 00       	push   $0x801f5f
  8013d5:	53                   	push   %ebx
  8013d6:	56                   	push   %esi
  8013d7:	e8 94 fe ff ff       	call   801270 <printfmt>
  8013dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013e2:	e9 cc fe ff ff       	jmp    8012b3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013e7:	52                   	push   %edx
  8013e8:	68 dd 1e 80 00       	push   $0x801edd
  8013ed:	53                   	push   %ebx
  8013ee:	56                   	push   %esi
  8013ef:	e8 7c fe ff ff       	call   801270 <printfmt>
  8013f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013fa:	e9 b4 fe ff ff       	jmp    8012b3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801402:	8d 50 04             	lea    0x4(%eax),%edx
  801405:	89 55 14             	mov    %edx,0x14(%ebp)
  801408:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80140a:	85 ff                	test   %edi,%edi
  80140c:	b8 58 1f 80 00       	mov    $0x801f58,%eax
  801411:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801418:	0f 8e 94 00 00 00    	jle    8014b2 <vprintfmt+0x225>
  80141e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801422:	0f 84 98 00 00 00    	je     8014c0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	ff 75 d0             	pushl  -0x30(%ebp)
  80142e:	57                   	push   %edi
  80142f:	e8 86 02 00 00       	call   8016ba <strnlen>
  801434:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801437:	29 c1                	sub    %eax,%ecx
  801439:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80143c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80143f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801443:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801446:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801449:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80144b:	eb 0f                	jmp    80145c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	53                   	push   %ebx
  801451:	ff 75 e0             	pushl  -0x20(%ebp)
  801454:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801456:	83 ef 01             	sub    $0x1,%edi
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	85 ff                	test   %edi,%edi
  80145e:	7f ed                	jg     80144d <vprintfmt+0x1c0>
  801460:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801463:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801466:	85 c9                	test   %ecx,%ecx
  801468:	b8 00 00 00 00       	mov    $0x0,%eax
  80146d:	0f 49 c1             	cmovns %ecx,%eax
  801470:	29 c1                	sub    %eax,%ecx
  801472:	89 75 08             	mov    %esi,0x8(%ebp)
  801475:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801478:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147b:	89 cb                	mov    %ecx,%ebx
  80147d:	eb 4d                	jmp    8014cc <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80147f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801483:	74 1b                	je     8014a0 <vprintfmt+0x213>
  801485:	0f be c0             	movsbl %al,%eax
  801488:	83 e8 20             	sub    $0x20,%eax
  80148b:	83 f8 5e             	cmp    $0x5e,%eax
  80148e:	76 10                	jbe    8014a0 <vprintfmt+0x213>
					putch('?', putdat);
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	ff 75 0c             	pushl  0xc(%ebp)
  801496:	6a 3f                	push   $0x3f
  801498:	ff 55 08             	call   *0x8(%ebp)
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	eb 0d                	jmp    8014ad <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	ff 75 0c             	pushl  0xc(%ebp)
  8014a6:	52                   	push   %edx
  8014a7:	ff 55 08             	call   *0x8(%ebp)
  8014aa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014ad:	83 eb 01             	sub    $0x1,%ebx
  8014b0:	eb 1a                	jmp    8014cc <vprintfmt+0x23f>
  8014b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014bb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014be:	eb 0c                	jmp    8014cc <vprintfmt+0x23f>
  8014c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014cc:	83 c7 01             	add    $0x1,%edi
  8014cf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014d3:	0f be d0             	movsbl %al,%edx
  8014d6:	85 d2                	test   %edx,%edx
  8014d8:	74 23                	je     8014fd <vprintfmt+0x270>
  8014da:	85 f6                	test   %esi,%esi
  8014dc:	78 a1                	js     80147f <vprintfmt+0x1f2>
  8014de:	83 ee 01             	sub    $0x1,%esi
  8014e1:	79 9c                	jns    80147f <vprintfmt+0x1f2>
  8014e3:	89 df                	mov    %ebx,%edi
  8014e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014eb:	eb 18                	jmp    801505 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	53                   	push   %ebx
  8014f1:	6a 20                	push   $0x20
  8014f3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014f5:	83 ef 01             	sub    $0x1,%edi
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	eb 08                	jmp    801505 <vprintfmt+0x278>
  8014fd:	89 df                	mov    %ebx,%edi
  8014ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801502:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801505:	85 ff                	test   %edi,%edi
  801507:	7f e4                	jg     8014ed <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80150c:	e9 a2 fd ff ff       	jmp    8012b3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801511:	83 fa 01             	cmp    $0x1,%edx
  801514:	7e 16                	jle    80152c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801516:	8b 45 14             	mov    0x14(%ebp),%eax
  801519:	8d 50 08             	lea    0x8(%eax),%edx
  80151c:	89 55 14             	mov    %edx,0x14(%ebp)
  80151f:	8b 50 04             	mov    0x4(%eax),%edx
  801522:	8b 00                	mov    (%eax),%eax
  801524:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801527:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80152a:	eb 32                	jmp    80155e <vprintfmt+0x2d1>
	else if (lflag)
  80152c:	85 d2                	test   %edx,%edx
  80152e:	74 18                	je     801548 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801530:	8b 45 14             	mov    0x14(%ebp),%eax
  801533:	8d 50 04             	lea    0x4(%eax),%edx
  801536:	89 55 14             	mov    %edx,0x14(%ebp)
  801539:	8b 00                	mov    (%eax),%eax
  80153b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153e:	89 c1                	mov    %eax,%ecx
  801540:	c1 f9 1f             	sar    $0x1f,%ecx
  801543:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801546:	eb 16                	jmp    80155e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801548:	8b 45 14             	mov    0x14(%ebp),%eax
  80154b:	8d 50 04             	lea    0x4(%eax),%edx
  80154e:	89 55 14             	mov    %edx,0x14(%ebp)
  801551:	8b 00                	mov    (%eax),%eax
  801553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801556:	89 c1                	mov    %eax,%ecx
  801558:	c1 f9 1f             	sar    $0x1f,%ecx
  80155b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80155e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801561:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801564:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801569:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80156d:	79 74                	jns    8015e3 <vprintfmt+0x356>
				putch('-', putdat);
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	53                   	push   %ebx
  801573:	6a 2d                	push   $0x2d
  801575:	ff d6                	call   *%esi
				num = -(long long) num;
  801577:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80157a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80157d:	f7 d8                	neg    %eax
  80157f:	83 d2 00             	adc    $0x0,%edx
  801582:	f7 da                	neg    %edx
  801584:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801587:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80158c:	eb 55                	jmp    8015e3 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80158e:	8d 45 14             	lea    0x14(%ebp),%eax
  801591:	e8 83 fc ff ff       	call   801219 <getuint>
			base = 10;
  801596:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80159b:	eb 46                	jmp    8015e3 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80159d:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a0:	e8 74 fc ff ff       	call   801219 <getuint>
			base = 8;
  8015a5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015aa:	eb 37                	jmp    8015e3 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	53                   	push   %ebx
  8015b0:	6a 30                	push   $0x30
  8015b2:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	53                   	push   %ebx
  8015b8:	6a 78                	push   $0x78
  8015ba:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bf:	8d 50 04             	lea    0x4(%eax),%edx
  8015c2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015c5:	8b 00                	mov    (%eax),%eax
  8015c7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015cc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015cf:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015d4:	eb 0d                	jmp    8015e3 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d9:	e8 3b fc ff ff       	call   801219 <getuint>
			base = 16;
  8015de:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015ea:	57                   	push   %edi
  8015eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ee:	51                   	push   %ecx
  8015ef:	52                   	push   %edx
  8015f0:	50                   	push   %eax
  8015f1:	89 da                	mov    %ebx,%edx
  8015f3:	89 f0                	mov    %esi,%eax
  8015f5:	e8 70 fb ff ff       	call   80116a <printnum>
			break;
  8015fa:	83 c4 20             	add    $0x20,%esp
  8015fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801600:	e9 ae fc ff ff       	jmp    8012b3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	53                   	push   %ebx
  801609:	51                   	push   %ecx
  80160a:	ff d6                	call   *%esi
			break;
  80160c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801612:	e9 9c fc ff ff       	jmp    8012b3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	53                   	push   %ebx
  80161b:	6a 25                	push   $0x25
  80161d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	eb 03                	jmp    801627 <vprintfmt+0x39a>
  801624:	83 ef 01             	sub    $0x1,%edi
  801627:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80162b:	75 f7                	jne    801624 <vprintfmt+0x397>
  80162d:	e9 81 fc ff ff       	jmp    8012b3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801632:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801635:	5b                   	pop    %ebx
  801636:	5e                   	pop    %esi
  801637:	5f                   	pop    %edi
  801638:	5d                   	pop    %ebp
  801639:	c3                   	ret    

0080163a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	83 ec 18             	sub    $0x18,%esp
  801640:	8b 45 08             	mov    0x8(%ebp),%eax
  801643:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801646:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801649:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80164d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801650:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801657:	85 c0                	test   %eax,%eax
  801659:	74 26                	je     801681 <vsnprintf+0x47>
  80165b:	85 d2                	test   %edx,%edx
  80165d:	7e 22                	jle    801681 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80165f:	ff 75 14             	pushl  0x14(%ebp)
  801662:	ff 75 10             	pushl  0x10(%ebp)
  801665:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	68 53 12 80 00       	push   $0x801253
  80166e:	e8 1a fc ff ff       	call   80128d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801673:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801676:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801679:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	eb 05                	jmp    801686 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801681:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801686:	c9                   	leave  
  801687:	c3                   	ret    

00801688 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80168e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801691:	50                   	push   %eax
  801692:	ff 75 10             	pushl  0x10(%ebp)
  801695:	ff 75 0c             	pushl  0xc(%ebp)
  801698:	ff 75 08             	pushl  0x8(%ebp)
  80169b:	e8 9a ff ff ff       	call   80163a <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ad:	eb 03                	jmp    8016b2 <strlen+0x10>
		n++;
  8016af:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b6:	75 f7                	jne    8016af <strlen+0xd>
		n++;
	return n;
}
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c8:	eb 03                	jmp    8016cd <strnlen+0x13>
		n++;
  8016ca:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016cd:	39 c2                	cmp    %eax,%edx
  8016cf:	74 08                	je     8016d9 <strnlen+0x1f>
  8016d1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d5:	75 f3                	jne    8016ca <strnlen+0x10>
  8016d7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    

008016db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	53                   	push   %ebx
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e5:	89 c2                	mov    %eax,%edx
  8016e7:	83 c2 01             	add    $0x1,%edx
  8016ea:	83 c1 01             	add    $0x1,%ecx
  8016ed:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016f1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f4:	84 db                	test   %bl,%bl
  8016f6:	75 ef                	jne    8016e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016f8:	5b                   	pop    %ebx
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	53                   	push   %ebx
  8016ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801702:	53                   	push   %ebx
  801703:	e8 9a ff ff ff       	call   8016a2 <strlen>
  801708:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80170b:	ff 75 0c             	pushl  0xc(%ebp)
  80170e:	01 d8                	add    %ebx,%eax
  801710:	50                   	push   %eax
  801711:	e8 c5 ff ff ff       	call   8016db <strcpy>
	return dst;
}
  801716:	89 d8                	mov    %ebx,%eax
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	56                   	push   %esi
  801721:	53                   	push   %ebx
  801722:	8b 75 08             	mov    0x8(%ebp),%esi
  801725:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801728:	89 f3                	mov    %esi,%ebx
  80172a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172d:	89 f2                	mov    %esi,%edx
  80172f:	eb 0f                	jmp    801740 <strncpy+0x23>
		*dst++ = *src;
  801731:	83 c2 01             	add    $0x1,%edx
  801734:	0f b6 01             	movzbl (%ecx),%eax
  801737:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80173a:	80 39 01             	cmpb   $0x1,(%ecx)
  80173d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801740:	39 da                	cmp    %ebx,%edx
  801742:	75 ed                	jne    801731 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801744:	89 f0                	mov    %esi,%eax
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	56                   	push   %esi
  80174e:	53                   	push   %ebx
  80174f:	8b 75 08             	mov    0x8(%ebp),%esi
  801752:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801755:	8b 55 10             	mov    0x10(%ebp),%edx
  801758:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80175a:	85 d2                	test   %edx,%edx
  80175c:	74 21                	je     80177f <strlcpy+0x35>
  80175e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801762:	89 f2                	mov    %esi,%edx
  801764:	eb 09                	jmp    80176f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801766:	83 c2 01             	add    $0x1,%edx
  801769:	83 c1 01             	add    $0x1,%ecx
  80176c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80176f:	39 c2                	cmp    %eax,%edx
  801771:	74 09                	je     80177c <strlcpy+0x32>
  801773:	0f b6 19             	movzbl (%ecx),%ebx
  801776:	84 db                	test   %bl,%bl
  801778:	75 ec                	jne    801766 <strlcpy+0x1c>
  80177a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80177c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80177f:	29 f0                	sub    %esi,%eax
}
  801781:	5b                   	pop    %ebx
  801782:	5e                   	pop    %esi
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80178e:	eb 06                	jmp    801796 <strcmp+0x11>
		p++, q++;
  801790:	83 c1 01             	add    $0x1,%ecx
  801793:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801796:	0f b6 01             	movzbl (%ecx),%eax
  801799:	84 c0                	test   %al,%al
  80179b:	74 04                	je     8017a1 <strcmp+0x1c>
  80179d:	3a 02                	cmp    (%edx),%al
  80179f:	74 ef                	je     801790 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a1:	0f b6 c0             	movzbl %al,%eax
  8017a4:	0f b6 12             	movzbl (%edx),%edx
  8017a7:	29 d0                	sub    %edx,%eax
}
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b5:	89 c3                	mov    %eax,%ebx
  8017b7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ba:	eb 06                	jmp    8017c2 <strncmp+0x17>
		n--, p++, q++;
  8017bc:	83 c0 01             	add    $0x1,%eax
  8017bf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017c2:	39 d8                	cmp    %ebx,%eax
  8017c4:	74 15                	je     8017db <strncmp+0x30>
  8017c6:	0f b6 08             	movzbl (%eax),%ecx
  8017c9:	84 c9                	test   %cl,%cl
  8017cb:	74 04                	je     8017d1 <strncmp+0x26>
  8017cd:	3a 0a                	cmp    (%edx),%cl
  8017cf:	74 eb                	je     8017bc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d1:	0f b6 00             	movzbl (%eax),%eax
  8017d4:	0f b6 12             	movzbl (%edx),%edx
  8017d7:	29 d0                	sub    %edx,%eax
  8017d9:	eb 05                	jmp    8017e0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017db:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017e0:	5b                   	pop    %ebx
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    

008017e3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ed:	eb 07                	jmp    8017f6 <strchr+0x13>
		if (*s == c)
  8017ef:	38 ca                	cmp    %cl,%dl
  8017f1:	74 0f                	je     801802 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f3:	83 c0 01             	add    $0x1,%eax
  8017f6:	0f b6 10             	movzbl (%eax),%edx
  8017f9:	84 d2                	test   %dl,%dl
  8017fb:	75 f2                	jne    8017ef <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801802:	5d                   	pop    %ebp
  801803:	c3                   	ret    

00801804 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180e:	eb 03                	jmp    801813 <strfind+0xf>
  801810:	83 c0 01             	add    $0x1,%eax
  801813:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801816:	38 ca                	cmp    %cl,%dl
  801818:	74 04                	je     80181e <strfind+0x1a>
  80181a:	84 d2                	test   %dl,%dl
  80181c:	75 f2                	jne    801810 <strfind+0xc>
			break;
	return (char *) s;
}
  80181e:	5d                   	pop    %ebp
  80181f:	c3                   	ret    

00801820 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	57                   	push   %edi
  801824:	56                   	push   %esi
  801825:	53                   	push   %ebx
  801826:	8b 7d 08             	mov    0x8(%ebp),%edi
  801829:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80182c:	85 c9                	test   %ecx,%ecx
  80182e:	74 36                	je     801866 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801830:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801836:	75 28                	jne    801860 <memset+0x40>
  801838:	f6 c1 03             	test   $0x3,%cl
  80183b:	75 23                	jne    801860 <memset+0x40>
		c &= 0xFF;
  80183d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801841:	89 d3                	mov    %edx,%ebx
  801843:	c1 e3 08             	shl    $0x8,%ebx
  801846:	89 d6                	mov    %edx,%esi
  801848:	c1 e6 18             	shl    $0x18,%esi
  80184b:	89 d0                	mov    %edx,%eax
  80184d:	c1 e0 10             	shl    $0x10,%eax
  801850:	09 f0                	or     %esi,%eax
  801852:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801854:	89 d8                	mov    %ebx,%eax
  801856:	09 d0                	or     %edx,%eax
  801858:	c1 e9 02             	shr    $0x2,%ecx
  80185b:	fc                   	cld    
  80185c:	f3 ab                	rep stos %eax,%es:(%edi)
  80185e:	eb 06                	jmp    801866 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801860:	8b 45 0c             	mov    0xc(%ebp),%eax
  801863:	fc                   	cld    
  801864:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801866:	89 f8                	mov    %edi,%eax
  801868:	5b                   	pop    %ebx
  801869:	5e                   	pop    %esi
  80186a:	5f                   	pop    %edi
  80186b:	5d                   	pop    %ebp
  80186c:	c3                   	ret    

0080186d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	57                   	push   %edi
  801871:	56                   	push   %esi
  801872:	8b 45 08             	mov    0x8(%ebp),%eax
  801875:	8b 75 0c             	mov    0xc(%ebp),%esi
  801878:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80187b:	39 c6                	cmp    %eax,%esi
  80187d:	73 35                	jae    8018b4 <memmove+0x47>
  80187f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801882:	39 d0                	cmp    %edx,%eax
  801884:	73 2e                	jae    8018b4 <memmove+0x47>
		s += n;
		d += n;
  801886:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801889:	89 d6                	mov    %edx,%esi
  80188b:	09 fe                	or     %edi,%esi
  80188d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801893:	75 13                	jne    8018a8 <memmove+0x3b>
  801895:	f6 c1 03             	test   $0x3,%cl
  801898:	75 0e                	jne    8018a8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80189a:	83 ef 04             	sub    $0x4,%edi
  80189d:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a0:	c1 e9 02             	shr    $0x2,%ecx
  8018a3:	fd                   	std    
  8018a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a6:	eb 09                	jmp    8018b1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a8:	83 ef 01             	sub    $0x1,%edi
  8018ab:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018ae:	fd                   	std    
  8018af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b1:	fc                   	cld    
  8018b2:	eb 1d                	jmp    8018d1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b4:	89 f2                	mov    %esi,%edx
  8018b6:	09 c2                	or     %eax,%edx
  8018b8:	f6 c2 03             	test   $0x3,%dl
  8018bb:	75 0f                	jne    8018cc <memmove+0x5f>
  8018bd:	f6 c1 03             	test   $0x3,%cl
  8018c0:	75 0a                	jne    8018cc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018c2:	c1 e9 02             	shr    $0x2,%ecx
  8018c5:	89 c7                	mov    %eax,%edi
  8018c7:	fc                   	cld    
  8018c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ca:	eb 05                	jmp    8018d1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018cc:	89 c7                	mov    %eax,%edi
  8018ce:	fc                   	cld    
  8018cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d1:	5e                   	pop    %esi
  8018d2:	5f                   	pop    %edi
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d8:	ff 75 10             	pushl  0x10(%ebp)
  8018db:	ff 75 0c             	pushl  0xc(%ebp)
  8018de:	ff 75 08             	pushl  0x8(%ebp)
  8018e1:	e8 87 ff ff ff       	call   80186d <memmove>
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	56                   	push   %esi
  8018ec:	53                   	push   %ebx
  8018ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f3:	89 c6                	mov    %eax,%esi
  8018f5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f8:	eb 1a                	jmp    801914 <memcmp+0x2c>
		if (*s1 != *s2)
  8018fa:	0f b6 08             	movzbl (%eax),%ecx
  8018fd:	0f b6 1a             	movzbl (%edx),%ebx
  801900:	38 d9                	cmp    %bl,%cl
  801902:	74 0a                	je     80190e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801904:	0f b6 c1             	movzbl %cl,%eax
  801907:	0f b6 db             	movzbl %bl,%ebx
  80190a:	29 d8                	sub    %ebx,%eax
  80190c:	eb 0f                	jmp    80191d <memcmp+0x35>
		s1++, s2++;
  80190e:	83 c0 01             	add    $0x1,%eax
  801911:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801914:	39 f0                	cmp    %esi,%eax
  801916:	75 e2                	jne    8018fa <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801918:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191d:	5b                   	pop    %ebx
  80191e:	5e                   	pop    %esi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    

00801921 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801928:	89 c1                	mov    %eax,%ecx
  80192a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80192d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801931:	eb 0a                	jmp    80193d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801933:	0f b6 10             	movzbl (%eax),%edx
  801936:	39 da                	cmp    %ebx,%edx
  801938:	74 07                	je     801941 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193a:	83 c0 01             	add    $0x1,%eax
  80193d:	39 c8                	cmp    %ecx,%eax
  80193f:	72 f2                	jb     801933 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801941:	5b                   	pop    %ebx
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	57                   	push   %edi
  801948:	56                   	push   %esi
  801949:	53                   	push   %ebx
  80194a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801950:	eb 03                	jmp    801955 <strtol+0x11>
		s++;
  801952:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801955:	0f b6 01             	movzbl (%ecx),%eax
  801958:	3c 20                	cmp    $0x20,%al
  80195a:	74 f6                	je     801952 <strtol+0xe>
  80195c:	3c 09                	cmp    $0x9,%al
  80195e:	74 f2                	je     801952 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801960:	3c 2b                	cmp    $0x2b,%al
  801962:	75 0a                	jne    80196e <strtol+0x2a>
		s++;
  801964:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801967:	bf 00 00 00 00       	mov    $0x0,%edi
  80196c:	eb 11                	jmp    80197f <strtol+0x3b>
  80196e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801973:	3c 2d                	cmp    $0x2d,%al
  801975:	75 08                	jne    80197f <strtol+0x3b>
		s++, neg = 1;
  801977:	83 c1 01             	add    $0x1,%ecx
  80197a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801985:	75 15                	jne    80199c <strtol+0x58>
  801987:	80 39 30             	cmpb   $0x30,(%ecx)
  80198a:	75 10                	jne    80199c <strtol+0x58>
  80198c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801990:	75 7c                	jne    801a0e <strtol+0xca>
		s += 2, base = 16;
  801992:	83 c1 02             	add    $0x2,%ecx
  801995:	bb 10 00 00 00       	mov    $0x10,%ebx
  80199a:	eb 16                	jmp    8019b2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80199c:	85 db                	test   %ebx,%ebx
  80199e:	75 12                	jne    8019b2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a8:	75 08                	jne    8019b2 <strtol+0x6e>
		s++, base = 8;
  8019aa:	83 c1 01             	add    $0x1,%ecx
  8019ad:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ba:	0f b6 11             	movzbl (%ecx),%edx
  8019bd:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c0:	89 f3                	mov    %esi,%ebx
  8019c2:	80 fb 09             	cmp    $0x9,%bl
  8019c5:	77 08                	ja     8019cf <strtol+0x8b>
			dig = *s - '0';
  8019c7:	0f be d2             	movsbl %dl,%edx
  8019ca:	83 ea 30             	sub    $0x30,%edx
  8019cd:	eb 22                	jmp    8019f1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019cf:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d2:	89 f3                	mov    %esi,%ebx
  8019d4:	80 fb 19             	cmp    $0x19,%bl
  8019d7:	77 08                	ja     8019e1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019d9:	0f be d2             	movsbl %dl,%edx
  8019dc:	83 ea 57             	sub    $0x57,%edx
  8019df:	eb 10                	jmp    8019f1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019e1:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e4:	89 f3                	mov    %esi,%ebx
  8019e6:	80 fb 19             	cmp    $0x19,%bl
  8019e9:	77 16                	ja     801a01 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019eb:	0f be d2             	movsbl %dl,%edx
  8019ee:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019f1:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f4:	7d 0b                	jge    801a01 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019f6:	83 c1 01             	add    $0x1,%ecx
  8019f9:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019fd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019ff:	eb b9                	jmp    8019ba <strtol+0x76>

	if (endptr)
  801a01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a05:	74 0d                	je     801a14 <strtol+0xd0>
		*endptr = (char *) s;
  801a07:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a0a:	89 0e                	mov    %ecx,(%esi)
  801a0c:	eb 06                	jmp    801a14 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a0e:	85 db                	test   %ebx,%ebx
  801a10:	74 98                	je     8019aa <strtol+0x66>
  801a12:	eb 9e                	jmp    8019b2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a14:	89 c2                	mov    %eax,%edx
  801a16:	f7 da                	neg    %edx
  801a18:	85 ff                	test   %edi,%edi
  801a1a:	0f 45 c2             	cmovne %edx,%eax
}
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5f                   	pop    %edi
  801a20:	5d                   	pop    %ebp
  801a21:	c3                   	ret    

00801a22 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a30:	85 c0                	test   %eax,%eax
  801a32:	75 12                	jne    801a46 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	68 00 00 c0 ee       	push   $0xeec00000
  801a3c:	e8 11 e9 ff ff       	call   800352 <sys_ipc_recv>
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	eb 0c                	jmp    801a52 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	50                   	push   %eax
  801a4a:	e8 03 e9 ff ff       	call   800352 <sys_ipc_recv>
  801a4f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a52:	85 f6                	test   %esi,%esi
  801a54:	0f 95 c1             	setne  %cl
  801a57:	85 db                	test   %ebx,%ebx
  801a59:	0f 95 c2             	setne  %dl
  801a5c:	84 d1                	test   %dl,%cl
  801a5e:	74 09                	je     801a69 <ipc_recv+0x47>
  801a60:	89 c2                	mov    %eax,%edx
  801a62:	c1 ea 1f             	shr    $0x1f,%edx
  801a65:	84 d2                	test   %dl,%dl
  801a67:	75 24                	jne    801a8d <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a69:	85 f6                	test   %esi,%esi
  801a6b:	74 0a                	je     801a77 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801a6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a72:	8b 40 74             	mov    0x74(%eax),%eax
  801a75:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801a77:	85 db                	test   %ebx,%ebx
  801a79:	74 0a                	je     801a85 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801a7b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a80:	8b 40 78             	mov    0x78(%eax),%eax
  801a83:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a85:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a90:	5b                   	pop    %ebx
  801a91:	5e                   	pop    %esi
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    

00801a94 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	57                   	push   %edi
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801aa6:	85 db                	test   %ebx,%ebx
  801aa8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aad:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ab0:	ff 75 14             	pushl  0x14(%ebp)
  801ab3:	53                   	push   %ebx
  801ab4:	56                   	push   %esi
  801ab5:	57                   	push   %edi
  801ab6:	e8 74 e8 ff ff       	call   80032f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801abb:	89 c2                	mov    %eax,%edx
  801abd:	c1 ea 1f             	shr    $0x1f,%edx
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	84 d2                	test   %dl,%dl
  801ac5:	74 17                	je     801ade <ipc_send+0x4a>
  801ac7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aca:	74 12                	je     801ade <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801acc:	50                   	push   %eax
  801acd:	68 40 22 80 00       	push   $0x802240
  801ad2:	6a 47                	push   $0x47
  801ad4:	68 4e 22 80 00       	push   $0x80224e
  801ad9:	e8 9f f5 ff ff       	call   80107d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ade:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae1:	75 07                	jne    801aea <ipc_send+0x56>
			sys_yield();
  801ae3:	e8 9b e6 ff ff       	call   800183 <sys_yield>
  801ae8:	eb c6                	jmp    801ab0 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801aea:	85 c0                	test   %eax,%eax
  801aec:	75 c2                	jne    801ab0 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801aee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af1:	5b                   	pop    %ebx
  801af2:	5e                   	pop    %esi
  801af3:	5f                   	pop    %edi
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801afc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b01:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b04:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b0a:	8b 52 50             	mov    0x50(%edx),%edx
  801b0d:	39 ca                	cmp    %ecx,%edx
  801b0f:	75 0d                	jne    801b1e <ipc_find_env+0x28>
			return envs[i].env_id;
  801b11:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b14:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b19:	8b 40 48             	mov    0x48(%eax),%eax
  801b1c:	eb 0f                	jmp    801b2d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b1e:	83 c0 01             	add    $0x1,%eax
  801b21:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b26:	75 d9                	jne    801b01 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b35:	89 d0                	mov    %edx,%eax
  801b37:	c1 e8 16             	shr    $0x16,%eax
  801b3a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b41:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b46:	f6 c1 01             	test   $0x1,%cl
  801b49:	74 1d                	je     801b68 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b4b:	c1 ea 0c             	shr    $0xc,%edx
  801b4e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b55:	f6 c2 01             	test   $0x1,%dl
  801b58:	74 0e                	je     801b68 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b5a:	c1 ea 0c             	shr    $0xc,%edx
  801b5d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b64:	ef 
  801b65:	0f b7 c0             	movzwl %ax,%eax
}
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    
  801b6a:	66 90                	xchg   %ax,%ax
  801b6c:	66 90                	xchg   %ax,%ax
  801b6e:	66 90                	xchg   %ax,%ax

00801b70 <__udivdi3>:
  801b70:	55                   	push   %ebp
  801b71:	57                   	push   %edi
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	83 ec 1c             	sub    $0x1c,%esp
  801b77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b87:	85 f6                	test   %esi,%esi
  801b89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b8d:	89 ca                	mov    %ecx,%edx
  801b8f:	89 f8                	mov    %edi,%eax
  801b91:	75 3d                	jne    801bd0 <__udivdi3+0x60>
  801b93:	39 cf                	cmp    %ecx,%edi
  801b95:	0f 87 c5 00 00 00    	ja     801c60 <__udivdi3+0xf0>
  801b9b:	85 ff                	test   %edi,%edi
  801b9d:	89 fd                	mov    %edi,%ebp
  801b9f:	75 0b                	jne    801bac <__udivdi3+0x3c>
  801ba1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba6:	31 d2                	xor    %edx,%edx
  801ba8:	f7 f7                	div    %edi
  801baa:	89 c5                	mov    %eax,%ebp
  801bac:	89 c8                	mov    %ecx,%eax
  801bae:	31 d2                	xor    %edx,%edx
  801bb0:	f7 f5                	div    %ebp
  801bb2:	89 c1                	mov    %eax,%ecx
  801bb4:	89 d8                	mov    %ebx,%eax
  801bb6:	89 cf                	mov    %ecx,%edi
  801bb8:	f7 f5                	div    %ebp
  801bba:	89 c3                	mov    %eax,%ebx
  801bbc:	89 d8                	mov    %ebx,%eax
  801bbe:	89 fa                	mov    %edi,%edx
  801bc0:	83 c4 1c             	add    $0x1c,%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5f                   	pop    %edi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    
  801bc8:	90                   	nop
  801bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	39 ce                	cmp    %ecx,%esi
  801bd2:	77 74                	ja     801c48 <__udivdi3+0xd8>
  801bd4:	0f bd fe             	bsr    %esi,%edi
  801bd7:	83 f7 1f             	xor    $0x1f,%edi
  801bda:	0f 84 98 00 00 00    	je     801c78 <__udivdi3+0x108>
  801be0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	89 c5                	mov    %eax,%ebp
  801be9:	29 fb                	sub    %edi,%ebx
  801beb:	d3 e6                	shl    %cl,%esi
  801bed:	89 d9                	mov    %ebx,%ecx
  801bef:	d3 ed                	shr    %cl,%ebp
  801bf1:	89 f9                	mov    %edi,%ecx
  801bf3:	d3 e0                	shl    %cl,%eax
  801bf5:	09 ee                	or     %ebp,%esi
  801bf7:	89 d9                	mov    %ebx,%ecx
  801bf9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfd:	89 d5                	mov    %edx,%ebp
  801bff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c03:	d3 ed                	shr    %cl,%ebp
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	d3 e2                	shl    %cl,%edx
  801c09:	89 d9                	mov    %ebx,%ecx
  801c0b:	d3 e8                	shr    %cl,%eax
  801c0d:	09 c2                	or     %eax,%edx
  801c0f:	89 d0                	mov    %edx,%eax
  801c11:	89 ea                	mov    %ebp,%edx
  801c13:	f7 f6                	div    %esi
  801c15:	89 d5                	mov    %edx,%ebp
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	f7 64 24 0c          	mull   0xc(%esp)
  801c1d:	39 d5                	cmp    %edx,%ebp
  801c1f:	72 10                	jb     801c31 <__udivdi3+0xc1>
  801c21:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	d3 e6                	shl    %cl,%esi
  801c29:	39 c6                	cmp    %eax,%esi
  801c2b:	73 07                	jae    801c34 <__udivdi3+0xc4>
  801c2d:	39 d5                	cmp    %edx,%ebp
  801c2f:	75 03                	jne    801c34 <__udivdi3+0xc4>
  801c31:	83 eb 01             	sub    $0x1,%ebx
  801c34:	31 ff                	xor    %edi,%edi
  801c36:	89 d8                	mov    %ebx,%eax
  801c38:	89 fa                	mov    %edi,%edx
  801c3a:	83 c4 1c             	add    $0x1c,%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5f                   	pop    %edi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    
  801c42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c48:	31 ff                	xor    %edi,%edi
  801c4a:	31 db                	xor    %ebx,%ebx
  801c4c:	89 d8                	mov    %ebx,%eax
  801c4e:	89 fa                	mov    %edi,%edx
  801c50:	83 c4 1c             	add    $0x1c,%esp
  801c53:	5b                   	pop    %ebx
  801c54:	5e                   	pop    %esi
  801c55:	5f                   	pop    %edi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    
  801c58:	90                   	nop
  801c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c60:	89 d8                	mov    %ebx,%eax
  801c62:	f7 f7                	div    %edi
  801c64:	31 ff                	xor    %edi,%edi
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	89 d8                	mov    %ebx,%eax
  801c6a:	89 fa                	mov    %edi,%edx
  801c6c:	83 c4 1c             	add    $0x1c,%esp
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5f                   	pop    %edi
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    
  801c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c78:	39 ce                	cmp    %ecx,%esi
  801c7a:	72 0c                	jb     801c88 <__udivdi3+0x118>
  801c7c:	31 db                	xor    %ebx,%ebx
  801c7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c82:	0f 87 34 ff ff ff    	ja     801bbc <__udivdi3+0x4c>
  801c88:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c8d:	e9 2a ff ff ff       	jmp    801bbc <__udivdi3+0x4c>
  801c92:	66 90                	xchg   %ax,%ax
  801c94:	66 90                	xchg   %ax,%ax
  801c96:	66 90                	xchg   %ax,%ax
  801c98:	66 90                	xchg   %ax,%ax
  801c9a:	66 90                	xchg   %ax,%ax
  801c9c:	66 90                	xchg   %ax,%ax
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__umoddi3>:
  801ca0:	55                   	push   %ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 1c             	sub    $0x1c,%esp
  801ca7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801caf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cb7:	85 d2                	test   %edx,%edx
  801cb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cc1:	89 f3                	mov    %esi,%ebx
  801cc3:	89 3c 24             	mov    %edi,(%esp)
  801cc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cca:	75 1c                	jne    801ce8 <__umoddi3+0x48>
  801ccc:	39 f7                	cmp    %esi,%edi
  801cce:	76 50                	jbe    801d20 <__umoddi3+0x80>
  801cd0:	89 c8                	mov    %ecx,%eax
  801cd2:	89 f2                	mov    %esi,%edx
  801cd4:	f7 f7                	div    %edi
  801cd6:	89 d0                	mov    %edx,%eax
  801cd8:	31 d2                	xor    %edx,%edx
  801cda:	83 c4 1c             	add    $0x1c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce8:	39 f2                	cmp    %esi,%edx
  801cea:	89 d0                	mov    %edx,%eax
  801cec:	77 52                	ja     801d40 <__umoddi3+0xa0>
  801cee:	0f bd ea             	bsr    %edx,%ebp
  801cf1:	83 f5 1f             	xor    $0x1f,%ebp
  801cf4:	75 5a                	jne    801d50 <__umoddi3+0xb0>
  801cf6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cfa:	0f 82 e0 00 00 00    	jb     801de0 <__umoddi3+0x140>
  801d00:	39 0c 24             	cmp    %ecx,(%esp)
  801d03:	0f 86 d7 00 00 00    	jbe    801de0 <__umoddi3+0x140>
  801d09:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d11:	83 c4 1c             	add    $0x1c,%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5e                   	pop    %esi
  801d16:	5f                   	pop    %edi
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	85 ff                	test   %edi,%edi
  801d22:	89 fd                	mov    %edi,%ebp
  801d24:	75 0b                	jne    801d31 <__umoddi3+0x91>
  801d26:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2b:	31 d2                	xor    %edx,%edx
  801d2d:	f7 f7                	div    %edi
  801d2f:	89 c5                	mov    %eax,%ebp
  801d31:	89 f0                	mov    %esi,%eax
  801d33:	31 d2                	xor    %edx,%edx
  801d35:	f7 f5                	div    %ebp
  801d37:	89 c8                	mov    %ecx,%eax
  801d39:	f7 f5                	div    %ebp
  801d3b:	89 d0                	mov    %edx,%eax
  801d3d:	eb 99                	jmp    801cd8 <__umoddi3+0x38>
  801d3f:	90                   	nop
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	83 c4 1c             	add    $0x1c,%esp
  801d47:	5b                   	pop    %ebx
  801d48:	5e                   	pop    %esi
  801d49:	5f                   	pop    %edi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    
  801d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d50:	8b 34 24             	mov    (%esp),%esi
  801d53:	bf 20 00 00 00       	mov    $0x20,%edi
  801d58:	89 e9                	mov    %ebp,%ecx
  801d5a:	29 ef                	sub    %ebp,%edi
  801d5c:	d3 e0                	shl    %cl,%eax
  801d5e:	89 f9                	mov    %edi,%ecx
  801d60:	89 f2                	mov    %esi,%edx
  801d62:	d3 ea                	shr    %cl,%edx
  801d64:	89 e9                	mov    %ebp,%ecx
  801d66:	09 c2                	or     %eax,%edx
  801d68:	89 d8                	mov    %ebx,%eax
  801d6a:	89 14 24             	mov    %edx,(%esp)
  801d6d:	89 f2                	mov    %esi,%edx
  801d6f:	d3 e2                	shl    %cl,%edx
  801d71:	89 f9                	mov    %edi,%ecx
  801d73:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d7b:	d3 e8                	shr    %cl,%eax
  801d7d:	89 e9                	mov    %ebp,%ecx
  801d7f:	89 c6                	mov    %eax,%esi
  801d81:	d3 e3                	shl    %cl,%ebx
  801d83:	89 f9                	mov    %edi,%ecx
  801d85:	89 d0                	mov    %edx,%eax
  801d87:	d3 e8                	shr    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	09 d8                	or     %ebx,%eax
  801d8d:	89 d3                	mov    %edx,%ebx
  801d8f:	89 f2                	mov    %esi,%edx
  801d91:	f7 34 24             	divl   (%esp)
  801d94:	89 d6                	mov    %edx,%esi
  801d96:	d3 e3                	shl    %cl,%ebx
  801d98:	f7 64 24 04          	mull   0x4(%esp)
  801d9c:	39 d6                	cmp    %edx,%esi
  801d9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801da2:	89 d1                	mov    %edx,%ecx
  801da4:	89 c3                	mov    %eax,%ebx
  801da6:	72 08                	jb     801db0 <__umoddi3+0x110>
  801da8:	75 11                	jne    801dbb <__umoddi3+0x11b>
  801daa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dae:	73 0b                	jae    801dbb <__umoddi3+0x11b>
  801db0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801db4:	1b 14 24             	sbb    (%esp),%edx
  801db7:	89 d1                	mov    %edx,%ecx
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dbf:	29 da                	sub    %ebx,%edx
  801dc1:	19 ce                	sbb    %ecx,%esi
  801dc3:	89 f9                	mov    %edi,%ecx
  801dc5:	89 f0                	mov    %esi,%eax
  801dc7:	d3 e0                	shl    %cl,%eax
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	d3 ea                	shr    %cl,%edx
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	d3 ee                	shr    %cl,%esi
  801dd1:	09 d0                	or     %edx,%eax
  801dd3:	89 f2                	mov    %esi,%edx
  801dd5:	83 c4 1c             	add    $0x1c,%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5e                   	pop    %esi
  801dda:	5f                   	pop    %edi
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    
  801ddd:	8d 76 00             	lea    0x0(%esi),%esi
  801de0:	29 f9                	sub    %edi,%ecx
  801de2:	19 d6                	sbb    %edx,%esi
  801de4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801de8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dec:	e9 18 ff ff ff       	jmp    801d09 <__umoddi3+0x69>
