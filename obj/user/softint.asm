
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	57                   	push   %edi
  80003e:	56                   	push   %esi
  80003f:	53                   	push   %ebx
  800040:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800043:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80004a:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80004d:	e8 0e 01 00 00       	call   800160 <sys_getenvid>
  800052:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800058:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80005d:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800062:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800067:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80006a:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800070:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800073:	39 c8                	cmp    %ecx,%eax
  800075:	0f 44 fb             	cmove  %ebx,%edi
  800078:	b9 01 00 00 00       	mov    $0x1,%ecx
  80007d:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800080:	83 c2 01             	add    $0x1,%edx
  800083:	83 c3 7c             	add    $0x7c,%ebx
  800086:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80008c:	75 d9                	jne    800067 <libmain+0x2d>
  80008e:	89 f0                	mov    %esi,%eax
  800090:	84 c0                	test   %al,%al
  800092:	74 06                	je     80009a <libmain+0x60>
  800094:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80009e:	7e 0a                	jle    8000aa <libmain+0x70>
		binaryname = argv[0];
  8000a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a3:	8b 00                	mov    (%eax),%eax
  8000a5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000aa:	83 ec 08             	sub    $0x8,%esp
  8000ad:	ff 75 0c             	pushl  0xc(%ebp)
  8000b0:	ff 75 08             	pushl  0x8(%ebp)
  8000b3:	e8 7b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ce:	e8 87 04 00 00       	call   80055a <close_all>
	sys_env_destroy(0);
  8000d3:	83 ec 0c             	sub    $0xc,%esp
  8000d6:	6a 00                	push   $0x0
  8000d8:	e8 42 00 00 00       	call   80011f <sys_env_destroy>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    

008000e2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	89 c3                	mov    %eax,%ebx
  8000f5:	89 c7                	mov    %eax,%edi
  8000f7:	89 c6                	mov    %eax,%esi
  8000f9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_cgetc>:

int
sys_cgetc(void)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	57                   	push   %edi
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800106:	ba 00 00 00 00       	mov    $0x0,%edx
  80010b:	b8 01 00 00 00       	mov    $0x1,%eax
  800110:	89 d1                	mov    %edx,%ecx
  800112:	89 d3                	mov    %edx,%ebx
  800114:	89 d7                	mov    %edx,%edi
  800116:	89 d6                	mov    %edx,%esi
  800118:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011a:	5b                   	pop    %ebx
  80011b:	5e                   	pop    %esi
  80011c:	5f                   	pop    %edi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	57                   	push   %edi
  800123:	56                   	push   %esi
  800124:	53                   	push   %ebx
  800125:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800128:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012d:	b8 03 00 00 00       	mov    $0x3,%eax
  800132:	8b 55 08             	mov    0x8(%ebp),%edx
  800135:	89 cb                	mov    %ecx,%ebx
  800137:	89 cf                	mov    %ecx,%edi
  800139:	89 ce                	mov    %ecx,%esi
  80013b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80013d:	85 c0                	test   %eax,%eax
  80013f:	7e 17                	jle    800158 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800141:	83 ec 0c             	sub    $0xc,%esp
  800144:	50                   	push   %eax
  800145:	6a 03                	push   $0x3
  800147:	68 0a 1e 80 00       	push   $0x801e0a
  80014c:	6a 23                	push   $0x23
  80014e:	68 27 1e 80 00       	push   $0x801e27
  800153:	e8 21 0f 00 00       	call   801079 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800158:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015b:	5b                   	pop    %ebx
  80015c:	5e                   	pop    %esi
  80015d:	5f                   	pop    %edi
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800166:	ba 00 00 00 00       	mov    $0x0,%edx
  80016b:	b8 02 00 00 00       	mov    $0x2,%eax
  800170:	89 d1                	mov    %edx,%ecx
  800172:	89 d3                	mov    %edx,%ebx
  800174:	89 d7                	mov    %edx,%edi
  800176:	89 d6                	mov    %edx,%esi
  800178:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017a:	5b                   	pop    %ebx
  80017b:	5e                   	pop    %esi
  80017c:	5f                   	pop    %edi
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    

0080017f <sys_yield>:

void
sys_yield(void)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800185:	ba 00 00 00 00       	mov    $0x0,%edx
  80018a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80018f:	89 d1                	mov    %edx,%ecx
  800191:	89 d3                	mov    %edx,%ebx
  800193:	89 d7                	mov    %edx,%edi
  800195:	89 d6                	mov    %edx,%esi
  800197:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	be 00 00 00 00       	mov    $0x0,%esi
  8001ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ba:	89 f7                	mov    %esi,%edi
  8001bc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	7e 17                	jle    8001d9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	50                   	push   %eax
  8001c6:	6a 04                	push   $0x4
  8001c8:	68 0a 1e 80 00       	push   $0x801e0a
  8001cd:	6a 23                	push   $0x23
  8001cf:	68 27 1e 80 00       	push   $0x801e27
  8001d4:	e8 a0 0e 00 00       	call   801079 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5e                   	pop    %esi
  8001de:	5f                   	pop    %edi
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    

008001e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001fb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800200:	85 c0                	test   %eax,%eax
  800202:	7e 17                	jle    80021b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800204:	83 ec 0c             	sub    $0xc,%esp
  800207:	50                   	push   %eax
  800208:	6a 05                	push   $0x5
  80020a:	68 0a 1e 80 00       	push   $0x801e0a
  80020f:	6a 23                	push   $0x23
  800211:	68 27 1e 80 00       	push   $0x801e27
  800216:	e8 5e 0e 00 00       	call   801079 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800231:	b8 06 00 00 00       	mov    $0x6,%eax
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	8b 55 08             	mov    0x8(%ebp),%edx
  80023c:	89 df                	mov    %ebx,%edi
  80023e:	89 de                	mov    %ebx,%esi
  800240:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800242:	85 c0                	test   %eax,%eax
  800244:	7e 17                	jle    80025d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	50                   	push   %eax
  80024a:	6a 06                	push   $0x6
  80024c:	68 0a 1e 80 00       	push   $0x801e0a
  800251:	6a 23                	push   $0x23
  800253:	68 27 1e 80 00       	push   $0x801e27
  800258:	e8 1c 0e 00 00       	call   801079 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5f                   	pop    %edi
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800273:	b8 08 00 00 00       	mov    $0x8,%eax
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	8b 55 08             	mov    0x8(%ebp),%edx
  80027e:	89 df                	mov    %ebx,%edi
  800280:	89 de                	mov    %ebx,%esi
  800282:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800284:	85 c0                	test   %eax,%eax
  800286:	7e 17                	jle    80029f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800288:	83 ec 0c             	sub    $0xc,%esp
  80028b:	50                   	push   %eax
  80028c:	6a 08                	push   $0x8
  80028e:	68 0a 1e 80 00       	push   $0x801e0a
  800293:	6a 23                	push   $0x23
  800295:	68 27 1e 80 00       	push   $0x801e27
  80029a:	e8 da 0d 00 00       	call   801079 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80029f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a2:	5b                   	pop    %ebx
  8002a3:	5e                   	pop    %esi
  8002a4:	5f                   	pop    %edi
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b5:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	89 df                	mov    %ebx,%edi
  8002c2:	89 de                	mov    %ebx,%esi
  8002c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c6:	85 c0                	test   %eax,%eax
  8002c8:	7e 17                	jle    8002e1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ca:	83 ec 0c             	sub    $0xc,%esp
  8002cd:	50                   	push   %eax
  8002ce:	6a 09                	push   $0x9
  8002d0:	68 0a 1e 80 00       	push   $0x801e0a
  8002d5:	6a 23                	push   $0x23
  8002d7:	68 27 1e 80 00       	push   $0x801e27
  8002dc:	e8 98 0d 00 00       	call   801079 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	57                   	push   %edi
  8002ed:	56                   	push   %esi
  8002ee:	53                   	push   %ebx
  8002ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800302:	89 df                	mov    %ebx,%edi
  800304:	89 de                	mov    %ebx,%esi
  800306:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800308:	85 c0                	test   %eax,%eax
  80030a:	7e 17                	jle    800323 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80030c:	83 ec 0c             	sub    $0xc,%esp
  80030f:	50                   	push   %eax
  800310:	6a 0a                	push   $0xa
  800312:	68 0a 1e 80 00       	push   $0x801e0a
  800317:	6a 23                	push   $0x23
  800319:	68 27 1e 80 00       	push   $0x801e27
  80031e:	e8 56 0d 00 00       	call   801079 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800323:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800326:	5b                   	pop    %ebx
  800327:	5e                   	pop    %esi
  800328:	5f                   	pop    %edi
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	57                   	push   %edi
  80032f:	56                   	push   %esi
  800330:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800331:	be 00 00 00 00       	mov    $0x0,%esi
  800336:	b8 0c 00 00 00       	mov    $0xc,%eax
  80033b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033e:	8b 55 08             	mov    0x8(%ebp),%edx
  800341:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800344:	8b 7d 14             	mov    0x14(%ebp),%edi
  800347:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	57                   	push   %edi
  800352:	56                   	push   %esi
  800353:	53                   	push   %ebx
  800354:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800357:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800361:	8b 55 08             	mov    0x8(%ebp),%edx
  800364:	89 cb                	mov    %ecx,%ebx
  800366:	89 cf                	mov    %ecx,%edi
  800368:	89 ce                	mov    %ecx,%esi
  80036a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80036c:	85 c0                	test   %eax,%eax
  80036e:	7e 17                	jle    800387 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	50                   	push   %eax
  800374:	6a 0d                	push   $0xd
  800376:	68 0a 1e 80 00       	push   $0x801e0a
  80037b:	6a 23                	push   $0x23
  80037d:	68 27 1e 80 00       	push   $0x801e27
  800382:	e8 f2 0c 00 00       	call   801079 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800387:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	05 00 00 00 30       	add    $0x30000000,%eax
  80039a:	c1 e8 0c             	shr    $0xc,%eax
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	05 00 00 00 30       	add    $0x30000000,%eax
  8003aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003af:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c1:	89 c2                	mov    %eax,%edx
  8003c3:	c1 ea 16             	shr    $0x16,%edx
  8003c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003cd:	f6 c2 01             	test   $0x1,%dl
  8003d0:	74 11                	je     8003e3 <fd_alloc+0x2d>
  8003d2:	89 c2                	mov    %eax,%edx
  8003d4:	c1 ea 0c             	shr    $0xc,%edx
  8003d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003de:	f6 c2 01             	test   $0x1,%dl
  8003e1:	75 09                	jne    8003ec <fd_alloc+0x36>
			*fd_store = fd;
  8003e3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ea:	eb 17                	jmp    800403 <fd_alloc+0x4d>
  8003ec:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f6:	75 c9                	jne    8003c1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003fe:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800403:	5d                   	pop    %ebp
  800404:	c3                   	ret    

00800405 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040b:	83 f8 1f             	cmp    $0x1f,%eax
  80040e:	77 36                	ja     800446 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800410:	c1 e0 0c             	shl    $0xc,%eax
  800413:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800418:	89 c2                	mov    %eax,%edx
  80041a:	c1 ea 16             	shr    $0x16,%edx
  80041d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800424:	f6 c2 01             	test   $0x1,%dl
  800427:	74 24                	je     80044d <fd_lookup+0x48>
  800429:	89 c2                	mov    %eax,%edx
  80042b:	c1 ea 0c             	shr    $0xc,%edx
  80042e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800435:	f6 c2 01             	test   $0x1,%dl
  800438:	74 1a                	je     800454 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80043a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043d:	89 02                	mov    %eax,(%edx)
	return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 13                	jmp    800459 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800446:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044b:	eb 0c                	jmp    800459 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800452:	eb 05                	jmp    800459 <fd_lookup+0x54>
  800454:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800459:	5d                   	pop    %ebp
  80045a:	c3                   	ret    

0080045b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045b:	55                   	push   %ebp
  80045c:	89 e5                	mov    %esp,%ebp
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800464:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800469:	eb 13                	jmp    80047e <dev_lookup+0x23>
  80046b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80046e:	39 08                	cmp    %ecx,(%eax)
  800470:	75 0c                	jne    80047e <dev_lookup+0x23>
			*dev = devtab[i];
  800472:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800475:	89 01                	mov    %eax,(%ecx)
			return 0;
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	eb 2e                	jmp    8004ac <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80047e:	8b 02                	mov    (%edx),%eax
  800480:	85 c0                	test   %eax,%eax
  800482:	75 e7                	jne    80046b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800484:	a1 04 40 80 00       	mov    0x804004,%eax
  800489:	8b 40 48             	mov    0x48(%eax),%eax
  80048c:	83 ec 04             	sub    $0x4,%esp
  80048f:	51                   	push   %ecx
  800490:	50                   	push   %eax
  800491:	68 38 1e 80 00       	push   $0x801e38
  800496:	e8 b7 0c 00 00       	call   801152 <cprintf>
	*dev = 0;
  80049b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ac:	c9                   	leave  
  8004ad:	c3                   	ret    

008004ae <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	56                   	push   %esi
  8004b2:	53                   	push   %ebx
  8004b3:	83 ec 10             	sub    $0x10,%esp
  8004b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004bf:	50                   	push   %eax
  8004c0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c6:	c1 e8 0c             	shr    $0xc,%eax
  8004c9:	50                   	push   %eax
  8004ca:	e8 36 ff ff ff       	call   800405 <fd_lookup>
  8004cf:	83 c4 08             	add    $0x8,%esp
  8004d2:	85 c0                	test   %eax,%eax
  8004d4:	78 05                	js     8004db <fd_close+0x2d>
	    || fd != fd2)
  8004d6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004d9:	74 0c                	je     8004e7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004db:	84 db                	test   %bl,%bl
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	0f 44 c2             	cmove  %edx,%eax
  8004e5:	eb 41                	jmp    800528 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ed:	50                   	push   %eax
  8004ee:	ff 36                	pushl  (%esi)
  8004f0:	e8 66 ff ff ff       	call   80045b <dev_lookup>
  8004f5:	89 c3                	mov    %eax,%ebx
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	78 1a                	js     800518 <fd_close+0x6a>
		if (dev->dev_close)
  8004fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800501:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800504:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800509:	85 c0                	test   %eax,%eax
  80050b:	74 0b                	je     800518 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80050d:	83 ec 0c             	sub    $0xc,%esp
  800510:	56                   	push   %esi
  800511:	ff d0                	call   *%eax
  800513:	89 c3                	mov    %eax,%ebx
  800515:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	56                   	push   %esi
  80051c:	6a 00                	push   $0x0
  80051e:	e8 00 fd ff ff       	call   800223 <sys_page_unmap>
	return r;
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	89 d8                	mov    %ebx,%eax
}
  800528:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052b:	5b                   	pop    %ebx
  80052c:	5e                   	pop    %esi
  80052d:	5d                   	pop    %ebp
  80052e:	c3                   	ret    

0080052f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800538:	50                   	push   %eax
  800539:	ff 75 08             	pushl  0x8(%ebp)
  80053c:	e8 c4 fe ff ff       	call   800405 <fd_lookup>
  800541:	83 c4 08             	add    $0x8,%esp
  800544:	85 c0                	test   %eax,%eax
  800546:	78 10                	js     800558 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	6a 01                	push   $0x1
  80054d:	ff 75 f4             	pushl  -0xc(%ebp)
  800550:	e8 59 ff ff ff       	call   8004ae <fd_close>
  800555:	83 c4 10             	add    $0x10,%esp
}
  800558:	c9                   	leave  
  800559:	c3                   	ret    

0080055a <close_all>:

void
close_all(void)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	53                   	push   %ebx
  80055e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800561:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800566:	83 ec 0c             	sub    $0xc,%esp
  800569:	53                   	push   %ebx
  80056a:	e8 c0 ff ff ff       	call   80052f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80056f:	83 c3 01             	add    $0x1,%ebx
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	83 fb 20             	cmp    $0x20,%ebx
  800578:	75 ec                	jne    800566 <close_all+0xc>
		close(i);
}
  80057a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057d:	c9                   	leave  
  80057e:	c3                   	ret    

0080057f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	57                   	push   %edi
  800583:	56                   	push   %esi
  800584:	53                   	push   %ebx
  800585:	83 ec 2c             	sub    $0x2c,%esp
  800588:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80058e:	50                   	push   %eax
  80058f:	ff 75 08             	pushl  0x8(%ebp)
  800592:	e8 6e fe ff ff       	call   800405 <fd_lookup>
  800597:	83 c4 08             	add    $0x8,%esp
  80059a:	85 c0                	test   %eax,%eax
  80059c:	0f 88 c1 00 00 00    	js     800663 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a2:	83 ec 0c             	sub    $0xc,%esp
  8005a5:	56                   	push   %esi
  8005a6:	e8 84 ff ff ff       	call   80052f <close>

	newfd = INDEX2FD(newfdnum);
  8005ab:	89 f3                	mov    %esi,%ebx
  8005ad:	c1 e3 0c             	shl    $0xc,%ebx
  8005b0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b6:	83 c4 04             	add    $0x4,%esp
  8005b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005bc:	e8 de fd ff ff       	call   80039f <fd2data>
  8005c1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c3:	89 1c 24             	mov    %ebx,(%esp)
  8005c6:	e8 d4 fd ff ff       	call   80039f <fd2data>
  8005cb:	83 c4 10             	add    $0x10,%esp
  8005ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d1:	89 f8                	mov    %edi,%eax
  8005d3:	c1 e8 16             	shr    $0x16,%eax
  8005d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005dd:	a8 01                	test   $0x1,%al
  8005df:	74 37                	je     800618 <dup+0x99>
  8005e1:	89 f8                	mov    %edi,%eax
  8005e3:	c1 e8 0c             	shr    $0xc,%eax
  8005e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ed:	f6 c2 01             	test   $0x1,%dl
  8005f0:	74 26                	je     800618 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	25 07 0e 00 00       	and    $0xe07,%eax
  800601:	50                   	push   %eax
  800602:	ff 75 d4             	pushl  -0x2c(%ebp)
  800605:	6a 00                	push   $0x0
  800607:	57                   	push   %edi
  800608:	6a 00                	push   $0x0
  80060a:	e8 d2 fb ff ff       	call   8001e1 <sys_page_map>
  80060f:	89 c7                	mov    %eax,%edi
  800611:	83 c4 20             	add    $0x20,%esp
  800614:	85 c0                	test   %eax,%eax
  800616:	78 2e                	js     800646 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800618:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061b:	89 d0                	mov    %edx,%eax
  80061d:	c1 e8 0c             	shr    $0xc,%eax
  800620:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800627:	83 ec 0c             	sub    $0xc,%esp
  80062a:	25 07 0e 00 00       	and    $0xe07,%eax
  80062f:	50                   	push   %eax
  800630:	53                   	push   %ebx
  800631:	6a 00                	push   $0x0
  800633:	52                   	push   %edx
  800634:	6a 00                	push   $0x0
  800636:	e8 a6 fb ff ff       	call   8001e1 <sys_page_map>
  80063b:	89 c7                	mov    %eax,%edi
  80063d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800640:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800642:	85 ff                	test   %edi,%edi
  800644:	79 1d                	jns    800663 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 00                	push   $0x0
  80064c:	e8 d2 fb ff ff       	call   800223 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800651:	83 c4 08             	add    $0x8,%esp
  800654:	ff 75 d4             	pushl  -0x2c(%ebp)
  800657:	6a 00                	push   $0x0
  800659:	e8 c5 fb ff ff       	call   800223 <sys_page_unmap>
	return r;
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	89 f8                	mov    %edi,%eax
}
  800663:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800666:	5b                   	pop    %ebx
  800667:	5e                   	pop    %esi
  800668:	5f                   	pop    %edi
  800669:	5d                   	pop    %ebp
  80066a:	c3                   	ret    

0080066b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066b:	55                   	push   %ebp
  80066c:	89 e5                	mov    %esp,%ebp
  80066e:	53                   	push   %ebx
  80066f:	83 ec 14             	sub    $0x14,%esp
  800672:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800675:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800678:	50                   	push   %eax
  800679:	53                   	push   %ebx
  80067a:	e8 86 fd ff ff       	call   800405 <fd_lookup>
  80067f:	83 c4 08             	add    $0x8,%esp
  800682:	89 c2                	mov    %eax,%edx
  800684:	85 c0                	test   %eax,%eax
  800686:	78 6d                	js     8006f5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80068e:	50                   	push   %eax
  80068f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800692:	ff 30                	pushl  (%eax)
  800694:	e8 c2 fd ff ff       	call   80045b <dev_lookup>
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	85 c0                	test   %eax,%eax
  80069e:	78 4c                	js     8006ec <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a3:	8b 42 08             	mov    0x8(%edx),%eax
  8006a6:	83 e0 03             	and    $0x3,%eax
  8006a9:	83 f8 01             	cmp    $0x1,%eax
  8006ac:	75 21                	jne    8006cf <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8006b3:	8b 40 48             	mov    0x48(%eax),%eax
  8006b6:	83 ec 04             	sub    $0x4,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	50                   	push   %eax
  8006bb:	68 79 1e 80 00       	push   $0x801e79
  8006c0:	e8 8d 0a 00 00       	call   801152 <cprintf>
		return -E_INVAL;
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006cd:	eb 26                	jmp    8006f5 <read+0x8a>
	}
	if (!dev->dev_read)
  8006cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d2:	8b 40 08             	mov    0x8(%eax),%eax
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	74 17                	je     8006f0 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8006d9:	83 ec 04             	sub    $0x4,%esp
  8006dc:	ff 75 10             	pushl  0x10(%ebp)
  8006df:	ff 75 0c             	pushl  0xc(%ebp)
  8006e2:	52                   	push   %edx
  8006e3:	ff d0                	call   *%eax
  8006e5:	89 c2                	mov    %eax,%edx
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	eb 09                	jmp    8006f5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ec:	89 c2                	mov    %eax,%edx
  8006ee:	eb 05                	jmp    8006f5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8006f5:	89 d0                	mov    %edx,%eax
  8006f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    

008006fc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	57                   	push   %edi
  800700:	56                   	push   %esi
  800701:	53                   	push   %ebx
  800702:	83 ec 0c             	sub    $0xc,%esp
  800705:	8b 7d 08             	mov    0x8(%ebp),%edi
  800708:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800710:	eb 21                	jmp    800733 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800712:	83 ec 04             	sub    $0x4,%esp
  800715:	89 f0                	mov    %esi,%eax
  800717:	29 d8                	sub    %ebx,%eax
  800719:	50                   	push   %eax
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	03 45 0c             	add    0xc(%ebp),%eax
  80071f:	50                   	push   %eax
  800720:	57                   	push   %edi
  800721:	e8 45 ff ff ff       	call   80066b <read>
		if (m < 0)
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	85 c0                	test   %eax,%eax
  80072b:	78 10                	js     80073d <readn+0x41>
			return m;
		if (m == 0)
  80072d:	85 c0                	test   %eax,%eax
  80072f:	74 0a                	je     80073b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800731:	01 c3                	add    %eax,%ebx
  800733:	39 f3                	cmp    %esi,%ebx
  800735:	72 db                	jb     800712 <readn+0x16>
  800737:	89 d8                	mov    %ebx,%eax
  800739:	eb 02                	jmp    80073d <readn+0x41>
  80073b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80073d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800740:	5b                   	pop    %ebx
  800741:	5e                   	pop    %esi
  800742:	5f                   	pop    %edi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	53                   	push   %ebx
  800749:	83 ec 14             	sub    $0x14,%esp
  80074c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80074f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800752:	50                   	push   %eax
  800753:	53                   	push   %ebx
  800754:	e8 ac fc ff ff       	call   800405 <fd_lookup>
  800759:	83 c4 08             	add    $0x8,%esp
  80075c:	89 c2                	mov    %eax,%edx
  80075e:	85 c0                	test   %eax,%eax
  800760:	78 68                	js     8007ca <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800768:	50                   	push   %eax
  800769:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076c:	ff 30                	pushl  (%eax)
  80076e:	e8 e8 fc ff ff       	call   80045b <dev_lookup>
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	85 c0                	test   %eax,%eax
  800778:	78 47                	js     8007c1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800781:	75 21                	jne    8007a4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800783:	a1 04 40 80 00       	mov    0x804004,%eax
  800788:	8b 40 48             	mov    0x48(%eax),%eax
  80078b:	83 ec 04             	sub    $0x4,%esp
  80078e:	53                   	push   %ebx
  80078f:	50                   	push   %eax
  800790:	68 95 1e 80 00       	push   $0x801e95
  800795:	e8 b8 09 00 00       	call   801152 <cprintf>
		return -E_INVAL;
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a2:	eb 26                	jmp    8007ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	74 17                	je     8007c5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ae:	83 ec 04             	sub    $0x4,%esp
  8007b1:	ff 75 10             	pushl  0x10(%ebp)
  8007b4:	ff 75 0c             	pushl  0xc(%ebp)
  8007b7:	50                   	push   %eax
  8007b8:	ff d2                	call   *%edx
  8007ba:	89 c2                	mov    %eax,%edx
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	eb 09                	jmp    8007ca <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c1:	89 c2                	mov    %eax,%edx
  8007c3:	eb 05                	jmp    8007ca <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ca:	89 d0                	mov    %edx,%eax
  8007cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007da:	50                   	push   %eax
  8007db:	ff 75 08             	pushl  0x8(%ebp)
  8007de:	e8 22 fc ff ff       	call   800405 <fd_lookup>
  8007e3:	83 c4 08             	add    $0x8,%esp
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	78 0e                	js     8007f8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	53                   	push   %ebx
  8007fe:	83 ec 14             	sub    $0x14,%esp
  800801:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800804:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800807:	50                   	push   %eax
  800808:	53                   	push   %ebx
  800809:	e8 f7 fb ff ff       	call   800405 <fd_lookup>
  80080e:	83 c4 08             	add    $0x8,%esp
  800811:	89 c2                	mov    %eax,%edx
  800813:	85 c0                	test   %eax,%eax
  800815:	78 65                	js     80087c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800817:	83 ec 08             	sub    $0x8,%esp
  80081a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081d:	50                   	push   %eax
  80081e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800821:	ff 30                	pushl  (%eax)
  800823:	e8 33 fc ff ff       	call   80045b <dev_lookup>
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	85 c0                	test   %eax,%eax
  80082d:	78 44                	js     800873 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800832:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800836:	75 21                	jne    800859 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800838:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083d:	8b 40 48             	mov    0x48(%eax),%eax
  800840:	83 ec 04             	sub    $0x4,%esp
  800843:	53                   	push   %ebx
  800844:	50                   	push   %eax
  800845:	68 58 1e 80 00       	push   $0x801e58
  80084a:	e8 03 09 00 00       	call   801152 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80084f:	83 c4 10             	add    $0x10,%esp
  800852:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800857:	eb 23                	jmp    80087c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800859:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085c:	8b 52 18             	mov    0x18(%edx),%edx
  80085f:	85 d2                	test   %edx,%edx
  800861:	74 14                	je     800877 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800863:	83 ec 08             	sub    $0x8,%esp
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	50                   	push   %eax
  80086a:	ff d2                	call   *%edx
  80086c:	89 c2                	mov    %eax,%edx
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	eb 09                	jmp    80087c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800873:	89 c2                	mov    %eax,%edx
  800875:	eb 05                	jmp    80087c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800877:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80087c:	89 d0                	mov    %edx,%eax
  80087e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	83 ec 14             	sub    $0x14,%esp
  80088a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800890:	50                   	push   %eax
  800891:	ff 75 08             	pushl  0x8(%ebp)
  800894:	e8 6c fb ff ff       	call   800405 <fd_lookup>
  800899:	83 c4 08             	add    $0x8,%esp
  80089c:	89 c2                	mov    %eax,%edx
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	78 58                	js     8008fa <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a2:	83 ec 08             	sub    $0x8,%esp
  8008a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a8:	50                   	push   %eax
  8008a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ac:	ff 30                	pushl  (%eax)
  8008ae:	e8 a8 fb ff ff       	call   80045b <dev_lookup>
  8008b3:	83 c4 10             	add    $0x10,%esp
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 37                	js     8008f1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c1:	74 32                	je     8008f5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008cd:	00 00 00 
	stat->st_isdir = 0;
  8008d0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d7:	00 00 00 
	stat->st_dev = dev;
  8008da:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	53                   	push   %ebx
  8008e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e7:	ff 50 14             	call   *0x14(%eax)
  8008ea:	89 c2                	mov    %eax,%edx
  8008ec:	83 c4 10             	add    $0x10,%esp
  8008ef:	eb 09                	jmp    8008fa <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f1:	89 c2                	mov    %eax,%edx
  8008f3:	eb 05                	jmp    8008fa <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008fa:	89 d0                	mov    %edx,%eax
  8008fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	6a 00                	push   $0x0
  80090b:	ff 75 08             	pushl  0x8(%ebp)
  80090e:	e8 e3 01 00 00       	call   800af6 <open>
  800913:	89 c3                	mov    %eax,%ebx
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	85 c0                	test   %eax,%eax
  80091a:	78 1b                	js     800937 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091c:	83 ec 08             	sub    $0x8,%esp
  80091f:	ff 75 0c             	pushl  0xc(%ebp)
  800922:	50                   	push   %eax
  800923:	e8 5b ff ff ff       	call   800883 <fstat>
  800928:	89 c6                	mov    %eax,%esi
	close(fd);
  80092a:	89 1c 24             	mov    %ebx,(%esp)
  80092d:	e8 fd fb ff ff       	call   80052f <close>
	return r;
  800932:	83 c4 10             	add    $0x10,%esp
  800935:	89 f0                	mov    %esi,%eax
}
  800937:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	89 c6                	mov    %eax,%esi
  800945:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800947:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80094e:	75 12                	jne    800962 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800950:	83 ec 0c             	sub    $0xc,%esp
  800953:	6a 01                	push   $0x1
  800955:	e8 98 11 00 00       	call   801af2 <ipc_find_env>
  80095a:	a3 00 40 80 00       	mov    %eax,0x804000
  80095f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800962:	6a 07                	push   $0x7
  800964:	68 00 50 80 00       	push   $0x805000
  800969:	56                   	push   %esi
  80096a:	ff 35 00 40 80 00    	pushl  0x804000
  800970:	e8 1b 11 00 00       	call   801a90 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800975:	83 c4 0c             	add    $0xc,%esp
  800978:	6a 00                	push   $0x0
  80097a:	53                   	push   %ebx
  80097b:	6a 00                	push   $0x0
  80097d:	e8 9c 10 00 00       	call   801a1e <ipc_recv>
}
  800982:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 40 0c             	mov    0xc(%eax),%eax
  800995:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ac:	e8 8d ff ff ff       	call   80093e <fsipc>
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ce:	e8 6b ff ff ff       	call   80093e <fsipc>
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	53                   	push   %ebx
  8009d9:	83 ec 04             	sub    $0x4,%esp
  8009dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f4:	e8 45 ff ff ff       	call   80093e <fsipc>
  8009f9:	85 c0                	test   %eax,%eax
  8009fb:	78 2c                	js     800a29 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009fd:	83 ec 08             	sub    $0x8,%esp
  800a00:	68 00 50 80 00       	push   $0x805000
  800a05:	53                   	push   %ebx
  800a06:	e8 cc 0c 00 00       	call   8016d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0b:	a1 80 50 80 00       	mov    0x805080,%eax
  800a10:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a16:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a21:	83 c4 10             	add    $0x10,%esp
  800a24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	83 ec 0c             	sub    $0xc,%esp
  800a34:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a37:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3a:	8b 52 0c             	mov    0xc(%edx),%edx
  800a3d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a43:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a48:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a4d:	0f 47 c2             	cmova  %edx,%eax
  800a50:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a55:	50                   	push   %eax
  800a56:	ff 75 0c             	pushl  0xc(%ebp)
  800a59:	68 08 50 80 00       	push   $0x805008
  800a5e:	e8 06 0e 00 00       	call   801869 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 04 00 00 00       	mov    $0x4,%eax
  800a6d:	e8 cc fe ff ff       	call   80093e <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a82:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a87:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	b8 03 00 00 00       	mov    $0x3,%eax
  800a97:	e8 a2 fe ff ff       	call   80093e <fsipc>
  800a9c:	89 c3                	mov    %eax,%ebx
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	78 4b                	js     800aed <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa2:	39 c6                	cmp    %eax,%esi
  800aa4:	73 16                	jae    800abc <devfile_read+0x48>
  800aa6:	68 c4 1e 80 00       	push   $0x801ec4
  800aab:	68 cb 1e 80 00       	push   $0x801ecb
  800ab0:	6a 7c                	push   $0x7c
  800ab2:	68 e0 1e 80 00       	push   $0x801ee0
  800ab7:	e8 bd 05 00 00       	call   801079 <_panic>
	assert(r <= PGSIZE);
  800abc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac1:	7e 16                	jle    800ad9 <devfile_read+0x65>
  800ac3:	68 eb 1e 80 00       	push   $0x801eeb
  800ac8:	68 cb 1e 80 00       	push   $0x801ecb
  800acd:	6a 7d                	push   $0x7d
  800acf:	68 e0 1e 80 00       	push   $0x801ee0
  800ad4:	e8 a0 05 00 00       	call   801079 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad9:	83 ec 04             	sub    $0x4,%esp
  800adc:	50                   	push   %eax
  800add:	68 00 50 80 00       	push   $0x805000
  800ae2:	ff 75 0c             	pushl  0xc(%ebp)
  800ae5:	e8 7f 0d 00 00       	call   801869 <memmove>
	return r;
  800aea:	83 c4 10             	add    $0x10,%esp
}
  800aed:	89 d8                	mov    %ebx,%eax
  800aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	53                   	push   %ebx
  800afa:	83 ec 20             	sub    $0x20,%esp
  800afd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b00:	53                   	push   %ebx
  800b01:	e8 98 0b 00 00       	call   80169e <strlen>
  800b06:	83 c4 10             	add    $0x10,%esp
  800b09:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0e:	7f 67                	jg     800b77 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b16:	50                   	push   %eax
  800b17:	e8 9a f8 ff ff       	call   8003b6 <fd_alloc>
  800b1c:	83 c4 10             	add    $0x10,%esp
		return r;
  800b1f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b21:	85 c0                	test   %eax,%eax
  800b23:	78 57                	js     800b7c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	53                   	push   %ebx
  800b29:	68 00 50 80 00       	push   $0x805000
  800b2e:	e8 a4 0b 00 00       	call   8016d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b43:	e8 f6 fd ff ff       	call   80093e <fsipc>
  800b48:	89 c3                	mov    %eax,%ebx
  800b4a:	83 c4 10             	add    $0x10,%esp
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	79 14                	jns    800b65 <open+0x6f>
		fd_close(fd, 0);
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	6a 00                	push   $0x0
  800b56:	ff 75 f4             	pushl  -0xc(%ebp)
  800b59:	e8 50 f9 ff ff       	call   8004ae <fd_close>
		return r;
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	89 da                	mov    %ebx,%edx
  800b63:	eb 17                	jmp    800b7c <open+0x86>
	}

	return fd2num(fd);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6b:	e8 1f f8 ff ff       	call   80038f <fd2num>
  800b70:	89 c2                	mov    %eax,%edx
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 05                	jmp    800b7c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b77:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b7c:	89 d0                	mov    %edx,%eax
  800b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b93:	e8 a6 fd ff ff       	call   80093e <fsipc>
}
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	ff 75 08             	pushl  0x8(%ebp)
  800ba8:	e8 f2 f7 ff ff       	call   80039f <fd2data>
  800bad:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800baf:	83 c4 08             	add    $0x8,%esp
  800bb2:	68 f7 1e 80 00       	push   $0x801ef7
  800bb7:	53                   	push   %ebx
  800bb8:	e8 1a 0b 00 00       	call   8016d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bbd:	8b 46 04             	mov    0x4(%esi),%eax
  800bc0:	2b 06                	sub    (%esi),%eax
  800bc2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bc8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bcf:	00 00 00 
	stat->st_dev = &devpipe;
  800bd2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bd9:	30 80 00 
	return 0;
}
  800bdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800be1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	53                   	push   %ebx
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf2:	53                   	push   %ebx
  800bf3:	6a 00                	push   $0x0
  800bf5:	e8 29 f6 ff ff       	call   800223 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bfa:	89 1c 24             	mov    %ebx,(%esp)
  800bfd:	e8 9d f7 ff ff       	call   80039f <fd2data>
  800c02:	83 c4 08             	add    $0x8,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 00                	push   $0x0
  800c08:	e8 16 f6 ff ff       	call   800223 <sys_page_unmap>
}
  800c0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 1c             	sub    $0x1c,%esp
  800c1b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c20:	a1 04 40 80 00       	mov    0x804004,%eax
  800c25:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c28:	83 ec 0c             	sub    $0xc,%esp
  800c2b:	ff 75 e0             	pushl  -0x20(%ebp)
  800c2e:	e8 f8 0e 00 00       	call   801b2b <pageref>
  800c33:	89 c3                	mov    %eax,%ebx
  800c35:	89 3c 24             	mov    %edi,(%esp)
  800c38:	e8 ee 0e 00 00       	call   801b2b <pageref>
  800c3d:	83 c4 10             	add    $0x10,%esp
  800c40:	39 c3                	cmp    %eax,%ebx
  800c42:	0f 94 c1             	sete   %cl
  800c45:	0f b6 c9             	movzbl %cl,%ecx
  800c48:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c4b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c51:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c54:	39 ce                	cmp    %ecx,%esi
  800c56:	74 1b                	je     800c73 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c58:	39 c3                	cmp    %eax,%ebx
  800c5a:	75 c4                	jne    800c20 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c5c:	8b 42 58             	mov    0x58(%edx),%eax
  800c5f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c62:	50                   	push   %eax
  800c63:	56                   	push   %esi
  800c64:	68 fe 1e 80 00       	push   $0x801efe
  800c69:	e8 e4 04 00 00       	call   801152 <cprintf>
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	eb ad                	jmp    800c20 <_pipeisclosed+0xe>
	}
}
  800c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 28             	sub    $0x28,%esp
  800c87:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c8a:	56                   	push   %esi
  800c8b:	e8 0f f7 ff ff       	call   80039f <fd2data>
  800c90:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9a:	eb 4b                	jmp    800ce7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c9c:	89 da                	mov    %ebx,%edx
  800c9e:	89 f0                	mov    %esi,%eax
  800ca0:	e8 6d ff ff ff       	call   800c12 <_pipeisclosed>
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	75 48                	jne    800cf1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ca9:	e8 d1 f4 ff ff       	call   80017f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cae:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb1:	8b 0b                	mov    (%ebx),%ecx
  800cb3:	8d 51 20             	lea    0x20(%ecx),%edx
  800cb6:	39 d0                	cmp    %edx,%eax
  800cb8:	73 e2                	jae    800c9c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc4:	89 c2                	mov    %eax,%edx
  800cc6:	c1 fa 1f             	sar    $0x1f,%edx
  800cc9:	89 d1                	mov    %edx,%ecx
  800ccb:	c1 e9 1b             	shr    $0x1b,%ecx
  800cce:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd1:	83 e2 1f             	and    $0x1f,%edx
  800cd4:	29 ca                	sub    %ecx,%edx
  800cd6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cda:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cde:	83 c0 01             	add    $0x1,%eax
  800ce1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce4:	83 c7 01             	add    $0x1,%edi
  800ce7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cea:	75 c2                	jne    800cae <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cec:	8b 45 10             	mov    0x10(%ebp),%eax
  800cef:	eb 05                	jmp    800cf6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 18             	sub    $0x18,%esp
  800d07:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d0a:	57                   	push   %edi
  800d0b:	e8 8f f6 ff ff       	call   80039f <fd2data>
  800d10:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d12:	83 c4 10             	add    $0x10,%esp
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	eb 3d                	jmp    800d59 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d1c:	85 db                	test   %ebx,%ebx
  800d1e:	74 04                	je     800d24 <devpipe_read+0x26>
				return i;
  800d20:	89 d8                	mov    %ebx,%eax
  800d22:	eb 44                	jmp    800d68 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d24:	89 f2                	mov    %esi,%edx
  800d26:	89 f8                	mov    %edi,%eax
  800d28:	e8 e5 fe ff ff       	call   800c12 <_pipeisclosed>
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	75 32                	jne    800d63 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d31:	e8 49 f4 ff ff       	call   80017f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d36:	8b 06                	mov    (%esi),%eax
  800d38:	3b 46 04             	cmp    0x4(%esi),%eax
  800d3b:	74 df                	je     800d1c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d3d:	99                   	cltd   
  800d3e:	c1 ea 1b             	shr    $0x1b,%edx
  800d41:	01 d0                	add    %edx,%eax
  800d43:	83 e0 1f             	and    $0x1f,%eax
  800d46:	29 d0                	sub    %edx,%eax
  800d48:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d53:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d56:	83 c3 01             	add    $0x1,%ebx
  800d59:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d5c:	75 d8                	jne    800d36 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d61:	eb 05                	jmp    800d68 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d63:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d7b:	50                   	push   %eax
  800d7c:	e8 35 f6 ff ff       	call   8003b6 <fd_alloc>
  800d81:	83 c4 10             	add    $0x10,%esp
  800d84:	89 c2                	mov    %eax,%edx
  800d86:	85 c0                	test   %eax,%eax
  800d88:	0f 88 2c 01 00 00    	js     800eba <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8e:	83 ec 04             	sub    $0x4,%esp
  800d91:	68 07 04 00 00       	push   $0x407
  800d96:	ff 75 f4             	pushl  -0xc(%ebp)
  800d99:	6a 00                	push   $0x0
  800d9b:	e8 fe f3 ff ff       	call   80019e <sys_page_alloc>
  800da0:	83 c4 10             	add    $0x10,%esp
  800da3:	89 c2                	mov    %eax,%edx
  800da5:	85 c0                	test   %eax,%eax
  800da7:	0f 88 0d 01 00 00    	js     800eba <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db3:	50                   	push   %eax
  800db4:	e8 fd f5 ff ff       	call   8003b6 <fd_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 e2 00 00 00    	js     800ea8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc6:	83 ec 04             	sub    $0x4,%esp
  800dc9:	68 07 04 00 00       	push   $0x407
  800dce:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd1:	6a 00                	push   $0x0
  800dd3:	e8 c6 f3 ff ff       	call   80019e <sys_page_alloc>
  800dd8:	89 c3                	mov    %eax,%ebx
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	0f 88 c3 00 00 00    	js     800ea8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	ff 75 f4             	pushl  -0xc(%ebp)
  800deb:	e8 af f5 ff ff       	call   80039f <fd2data>
  800df0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 c4 0c             	add    $0xc,%esp
  800df5:	68 07 04 00 00       	push   $0x407
  800dfa:	50                   	push   %eax
  800dfb:	6a 00                	push   $0x0
  800dfd:	e8 9c f3 ff ff       	call   80019e <sys_page_alloc>
  800e02:	89 c3                	mov    %eax,%ebx
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	85 c0                	test   %eax,%eax
  800e09:	0f 88 89 00 00 00    	js     800e98 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e0f:	83 ec 0c             	sub    $0xc,%esp
  800e12:	ff 75 f0             	pushl  -0x10(%ebp)
  800e15:	e8 85 f5 ff ff       	call   80039f <fd2data>
  800e1a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e21:	50                   	push   %eax
  800e22:	6a 00                	push   $0x0
  800e24:	56                   	push   %esi
  800e25:	6a 00                	push   $0x0
  800e27:	e8 b5 f3 ff ff       	call   8001e1 <sys_page_map>
  800e2c:	89 c3                	mov    %eax,%ebx
  800e2e:	83 c4 20             	add    $0x20,%esp
  800e31:	85 c0                	test   %eax,%eax
  800e33:	78 55                	js     800e8a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e35:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e43:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e4a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e53:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e58:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	ff 75 f4             	pushl  -0xc(%ebp)
  800e65:	e8 25 f5 ff ff       	call   80038f <fd2num>
  800e6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e6f:	83 c4 04             	add    $0x4,%esp
  800e72:	ff 75 f0             	pushl  -0x10(%ebp)
  800e75:	e8 15 f5 ff ff       	call   80038f <fd2num>
  800e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	ba 00 00 00 00       	mov    $0x0,%edx
  800e88:	eb 30                	jmp    800eba <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e8a:	83 ec 08             	sub    $0x8,%esp
  800e8d:	56                   	push   %esi
  800e8e:	6a 00                	push   $0x0
  800e90:	e8 8e f3 ff ff       	call   800223 <sys_page_unmap>
  800e95:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e98:	83 ec 08             	sub    $0x8,%esp
  800e9b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e9e:	6a 00                	push   $0x0
  800ea0:	e8 7e f3 ff ff       	call   800223 <sys_page_unmap>
  800ea5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	ff 75 f4             	pushl  -0xc(%ebp)
  800eae:	6a 00                	push   $0x0
  800eb0:	e8 6e f3 ff ff       	call   800223 <sys_page_unmap>
  800eb5:	83 c4 10             	add    $0x10,%esp
  800eb8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eba:	89 d0                	mov    %edx,%eax
  800ebc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecc:	50                   	push   %eax
  800ecd:	ff 75 08             	pushl  0x8(%ebp)
  800ed0:	e8 30 f5 ff ff       	call   800405 <fd_lookup>
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	78 18                	js     800ef4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee2:	e8 b8 f4 ff ff       	call   80039f <fd2data>
	return _pipeisclosed(fd, p);
  800ee7:	89 c2                	mov    %eax,%edx
  800ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eec:	e8 21 fd ff ff       	call   800c12 <_pipeisclosed>
  800ef1:	83 c4 10             	add    $0x10,%esp
}
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f06:	68 16 1f 80 00       	push   $0x801f16
  800f0b:	ff 75 0c             	pushl  0xc(%ebp)
  800f0e:	e8 c4 07 00 00       	call   8016d7 <strcpy>
	return 0;
}
  800f13:	b8 00 00 00 00       	mov    $0x0,%eax
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f26:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f31:	eb 2d                	jmp    800f60 <devcons_write+0x46>
		m = n - tot;
  800f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f36:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f38:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f3b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f40:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	53                   	push   %ebx
  800f47:	03 45 0c             	add    0xc(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	57                   	push   %edi
  800f4c:	e8 18 09 00 00       	call   801869 <memmove>
		sys_cputs(buf, m);
  800f51:	83 c4 08             	add    $0x8,%esp
  800f54:	53                   	push   %ebx
  800f55:	57                   	push   %edi
  800f56:	e8 87 f1 ff ff       	call   8000e2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5b:	01 de                	add    %ebx,%esi
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	89 f0                	mov    %esi,%eax
  800f62:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f65:	72 cc                	jb     800f33 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5f                   	pop    %edi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7e:	74 2a                	je     800faa <devcons_read+0x3b>
  800f80:	eb 05                	jmp    800f87 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f82:	e8 f8 f1 ff ff       	call   80017f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f87:	e8 74 f1 ff ff       	call   800100 <sys_cgetc>
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	74 f2                	je     800f82 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 16                	js     800faa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f94:	83 f8 04             	cmp    $0x4,%eax
  800f97:	74 0c                	je     800fa5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f99:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9c:	88 02                	mov    %al,(%edx)
	return 1;
  800f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa3:	eb 05                	jmp    800faa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fb8:	6a 01                	push   $0x1
  800fba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbd:	50                   	push   %eax
  800fbe:	e8 1f f1 ff ff       	call   8000e2 <sys_cputs>
}
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    

00800fc8 <getchar>:

int
getchar(void)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fce:	6a 01                	push   $0x1
  800fd0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd3:	50                   	push   %eax
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 90 f6 ff ff       	call   80066b <read>
	if (r < 0)
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 0f                	js     800ff1 <getchar+0x29>
		return r;
	if (r < 1)
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	7e 06                	jle    800fec <getchar+0x24>
		return -E_EOF;
	return c;
  800fe6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fea:	eb 05                	jmp    800ff1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffc:	50                   	push   %eax
  800ffd:	ff 75 08             	pushl  0x8(%ebp)
  801000:	e8 00 f4 ff ff       	call   800405 <fd_lookup>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 11                	js     80101d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80100c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801015:	39 10                	cmp    %edx,(%eax)
  801017:	0f 94 c0             	sete   %al
  80101a:	0f b6 c0             	movzbl %al,%eax
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <opencons>:

int
opencons(void)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801025:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801028:	50                   	push   %eax
  801029:	e8 88 f3 ff ff       	call   8003b6 <fd_alloc>
  80102e:	83 c4 10             	add    $0x10,%esp
		return r;
  801031:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801033:	85 c0                	test   %eax,%eax
  801035:	78 3e                	js     801075 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801037:	83 ec 04             	sub    $0x4,%esp
  80103a:	68 07 04 00 00       	push   $0x407
  80103f:	ff 75 f4             	pushl  -0xc(%ebp)
  801042:	6a 00                	push   $0x0
  801044:	e8 55 f1 ff ff       	call   80019e <sys_page_alloc>
  801049:	83 c4 10             	add    $0x10,%esp
		return r;
  80104c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104e:	85 c0                	test   %eax,%eax
  801050:	78 23                	js     801075 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801052:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80105d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801060:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	50                   	push   %eax
  80106b:	e8 1f f3 ff ff       	call   80038f <fd2num>
  801070:	89 c2                	mov    %eax,%edx
  801072:	83 c4 10             	add    $0x10,%esp
}
  801075:	89 d0                	mov    %edx,%eax
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801081:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801087:	e8 d4 f0 ff ff       	call   800160 <sys_getenvid>
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	ff 75 0c             	pushl  0xc(%ebp)
  801092:	ff 75 08             	pushl  0x8(%ebp)
  801095:	56                   	push   %esi
  801096:	50                   	push   %eax
  801097:	68 24 1f 80 00       	push   $0x801f24
  80109c:	e8 b1 00 00 00       	call   801152 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a1:	83 c4 18             	add    $0x18,%esp
  8010a4:	53                   	push   %ebx
  8010a5:	ff 75 10             	pushl  0x10(%ebp)
  8010a8:	e8 54 00 00 00       	call   801101 <vcprintf>
	cprintf("\n");
  8010ad:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  8010b4:	e8 99 00 00 00       	call   801152 <cprintf>
  8010b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010bc:	cc                   	int3   
  8010bd:	eb fd                	jmp    8010bc <_panic+0x43>

008010bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 04             	sub    $0x4,%esp
  8010c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c9:	8b 13                	mov    (%ebx),%edx
  8010cb:	8d 42 01             	lea    0x1(%edx),%eax
  8010ce:	89 03                	mov    %eax,(%ebx)
  8010d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010dc:	75 1a                	jne    8010f8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010de:	83 ec 08             	sub    $0x8,%esp
  8010e1:	68 ff 00 00 00       	push   $0xff
  8010e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e9:	50                   	push   %eax
  8010ea:	e8 f3 ef ff ff       	call   8000e2 <sys_cputs>
		b->idx = 0;
  8010ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010f8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80110a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801111:	00 00 00 
	b.cnt = 0;
  801114:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80111b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80111e:	ff 75 0c             	pushl  0xc(%ebp)
  801121:	ff 75 08             	pushl  0x8(%ebp)
  801124:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	68 bf 10 80 00       	push   $0x8010bf
  801130:	e8 54 01 00 00       	call   801289 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801135:	83 c4 08             	add    $0x8,%esp
  801138:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80113e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801144:	50                   	push   %eax
  801145:	e8 98 ef ff ff       	call   8000e2 <sys_cputs>

	return b.cnt;
}
  80114a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801150:	c9                   	leave  
  801151:	c3                   	ret    

00801152 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801158:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80115b:	50                   	push   %eax
  80115c:	ff 75 08             	pushl  0x8(%ebp)
  80115f:	e8 9d ff ff ff       	call   801101 <vcprintf>
	va_end(ap);

	return cnt;
}
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	57                   	push   %edi
  80116a:	56                   	push   %esi
  80116b:	53                   	push   %ebx
  80116c:	83 ec 1c             	sub    $0x1c,%esp
  80116f:	89 c7                	mov    %eax,%edi
  801171:	89 d6                	mov    %edx,%esi
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	8b 55 0c             	mov    0xc(%ebp),%edx
  801179:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80117f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801182:	bb 00 00 00 00       	mov    $0x0,%ebx
  801187:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80118a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80118d:	39 d3                	cmp    %edx,%ebx
  80118f:	72 05                	jb     801196 <printnum+0x30>
  801191:	39 45 10             	cmp    %eax,0x10(%ebp)
  801194:	77 45                	ja     8011db <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	ff 75 18             	pushl  0x18(%ebp)
  80119c:	8b 45 14             	mov    0x14(%ebp),%eax
  80119f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a2:	53                   	push   %ebx
  8011a3:	ff 75 10             	pushl  0x10(%ebp)
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8011af:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b5:	e8 b6 09 00 00       	call   801b70 <__udivdi3>
  8011ba:	83 c4 18             	add    $0x18,%esp
  8011bd:	52                   	push   %edx
  8011be:	50                   	push   %eax
  8011bf:	89 f2                	mov    %esi,%edx
  8011c1:	89 f8                	mov    %edi,%eax
  8011c3:	e8 9e ff ff ff       	call   801166 <printnum>
  8011c8:	83 c4 20             	add    $0x20,%esp
  8011cb:	eb 18                	jmp    8011e5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	56                   	push   %esi
  8011d1:	ff 75 18             	pushl  0x18(%ebp)
  8011d4:	ff d7                	call   *%edi
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	eb 03                	jmp    8011de <printnum+0x78>
  8011db:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011de:	83 eb 01             	sub    $0x1,%ebx
  8011e1:	85 db                	test   %ebx,%ebx
  8011e3:	7f e8                	jg     8011cd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	56                   	push   %esi
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f8:	e8 a3 0a 00 00       	call   801ca0 <__umoddi3>
  8011fd:	83 c4 14             	add    $0x14,%esp
  801200:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  801207:	50                   	push   %eax
  801208:	ff d7                	call   *%edi
}
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801218:	83 fa 01             	cmp    $0x1,%edx
  80121b:	7e 0e                	jle    80122b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80121d:	8b 10                	mov    (%eax),%edx
  80121f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801222:	89 08                	mov    %ecx,(%eax)
  801224:	8b 02                	mov    (%edx),%eax
  801226:	8b 52 04             	mov    0x4(%edx),%edx
  801229:	eb 22                	jmp    80124d <getuint+0x38>
	else if (lflag)
  80122b:	85 d2                	test   %edx,%edx
  80122d:	74 10                	je     80123f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80122f:	8b 10                	mov    (%eax),%edx
  801231:	8d 4a 04             	lea    0x4(%edx),%ecx
  801234:	89 08                	mov    %ecx,(%eax)
  801236:	8b 02                	mov    (%edx),%eax
  801238:	ba 00 00 00 00       	mov    $0x0,%edx
  80123d:	eb 0e                	jmp    80124d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80123f:	8b 10                	mov    (%eax),%edx
  801241:	8d 4a 04             	lea    0x4(%edx),%ecx
  801244:	89 08                	mov    %ecx,(%eax)
  801246:	8b 02                	mov    (%edx),%eax
  801248:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801255:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801259:	8b 10                	mov    (%eax),%edx
  80125b:	3b 50 04             	cmp    0x4(%eax),%edx
  80125e:	73 0a                	jae    80126a <sprintputch+0x1b>
		*b->buf++ = ch;
  801260:	8d 4a 01             	lea    0x1(%edx),%ecx
  801263:	89 08                	mov    %ecx,(%eax)
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	88 02                	mov    %al,(%edx)
}
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801272:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801275:	50                   	push   %eax
  801276:	ff 75 10             	pushl  0x10(%ebp)
  801279:	ff 75 0c             	pushl  0xc(%ebp)
  80127c:	ff 75 08             	pushl  0x8(%ebp)
  80127f:	e8 05 00 00 00       	call   801289 <vprintfmt>
	va_end(ap);
}
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	c9                   	leave  
  801288:	c3                   	ret    

00801289 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	57                   	push   %edi
  80128d:	56                   	push   %esi
  80128e:	53                   	push   %ebx
  80128f:	83 ec 2c             	sub    $0x2c,%esp
  801292:	8b 75 08             	mov    0x8(%ebp),%esi
  801295:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801298:	8b 7d 10             	mov    0x10(%ebp),%edi
  80129b:	eb 12                	jmp    8012af <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80129d:	85 c0                	test   %eax,%eax
  80129f:	0f 84 89 03 00 00    	je     80162e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012a5:	83 ec 08             	sub    $0x8,%esp
  8012a8:	53                   	push   %ebx
  8012a9:	50                   	push   %eax
  8012aa:	ff d6                	call   *%esi
  8012ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012af:	83 c7 01             	add    $0x1,%edi
  8012b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012b6:	83 f8 25             	cmp    $0x25,%eax
  8012b9:	75 e2                	jne    80129d <vprintfmt+0x14>
  8012bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d9:	eb 07                	jmp    8012e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012db:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012de:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e2:	8d 47 01             	lea    0x1(%edi),%eax
  8012e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e8:	0f b6 07             	movzbl (%edi),%eax
  8012eb:	0f b6 c8             	movzbl %al,%ecx
  8012ee:	83 e8 23             	sub    $0x23,%eax
  8012f1:	3c 55                	cmp    $0x55,%al
  8012f3:	0f 87 1a 03 00 00    	ja     801613 <vprintfmt+0x38a>
  8012f9:	0f b6 c0             	movzbl %al,%eax
  8012fc:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  801303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801306:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80130a:	eb d6                	jmp    8012e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80130f:	b8 00 00 00 00       	mov    $0x0,%eax
  801314:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801317:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80131a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80131e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801321:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801324:	83 fa 09             	cmp    $0x9,%edx
  801327:	77 39                	ja     801362 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801329:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80132c:	eb e9                	jmp    801317 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80132e:	8b 45 14             	mov    0x14(%ebp),%eax
  801331:	8d 48 04             	lea    0x4(%eax),%ecx
  801334:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801337:	8b 00                	mov    (%eax),%eax
  801339:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80133f:	eb 27                	jmp    801368 <vprintfmt+0xdf>
  801341:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801344:	85 c0                	test   %eax,%eax
  801346:	b9 00 00 00 00       	mov    $0x0,%ecx
  80134b:	0f 49 c8             	cmovns %eax,%ecx
  80134e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801354:	eb 8c                	jmp    8012e2 <vprintfmt+0x59>
  801356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801359:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801360:	eb 80                	jmp    8012e2 <vprintfmt+0x59>
  801362:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801365:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801368:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80136c:	0f 89 70 ff ff ff    	jns    8012e2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801372:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801375:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801378:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80137f:	e9 5e ff ff ff       	jmp    8012e2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801384:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80138a:	e9 53 ff ff ff       	jmp    8012e2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80138f:	8b 45 14             	mov    0x14(%ebp),%eax
  801392:	8d 50 04             	lea    0x4(%eax),%edx
  801395:	89 55 14             	mov    %edx,0x14(%ebp)
  801398:	83 ec 08             	sub    $0x8,%esp
  80139b:	53                   	push   %ebx
  80139c:	ff 30                	pushl  (%eax)
  80139e:	ff d6                	call   *%esi
			break;
  8013a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013a6:	e9 04 ff ff ff       	jmp    8012af <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ae:	8d 50 04             	lea    0x4(%eax),%edx
  8013b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b4:	8b 00                	mov    (%eax),%eax
  8013b6:	99                   	cltd   
  8013b7:	31 d0                	xor    %edx,%eax
  8013b9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013bb:	83 f8 0f             	cmp    $0xf,%eax
  8013be:	7f 0b                	jg     8013cb <vprintfmt+0x142>
  8013c0:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013c7:	85 d2                	test   %edx,%edx
  8013c9:	75 18                	jne    8013e3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013cb:	50                   	push   %eax
  8013cc:	68 5f 1f 80 00       	push   $0x801f5f
  8013d1:	53                   	push   %ebx
  8013d2:	56                   	push   %esi
  8013d3:	e8 94 fe ff ff       	call   80126c <printfmt>
  8013d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013de:	e9 cc fe ff ff       	jmp    8012af <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013e3:	52                   	push   %edx
  8013e4:	68 dd 1e 80 00       	push   $0x801edd
  8013e9:	53                   	push   %ebx
  8013ea:	56                   	push   %esi
  8013eb:	e8 7c fe ff ff       	call   80126c <printfmt>
  8013f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013f6:	e9 b4 fe ff ff       	jmp    8012af <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013fe:	8d 50 04             	lea    0x4(%eax),%edx
  801401:	89 55 14             	mov    %edx,0x14(%ebp)
  801404:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801406:	85 ff                	test   %edi,%edi
  801408:	b8 58 1f 80 00       	mov    $0x801f58,%eax
  80140d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801410:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801414:	0f 8e 94 00 00 00    	jle    8014ae <vprintfmt+0x225>
  80141a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80141e:	0f 84 98 00 00 00    	je     8014bc <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	ff 75 d0             	pushl  -0x30(%ebp)
  80142a:	57                   	push   %edi
  80142b:	e8 86 02 00 00       	call   8016b6 <strnlen>
  801430:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801433:	29 c1                	sub    %eax,%ecx
  801435:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801438:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80143b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80143f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801442:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801445:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801447:	eb 0f                	jmp    801458 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	53                   	push   %ebx
  80144d:	ff 75 e0             	pushl  -0x20(%ebp)
  801450:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801452:	83 ef 01             	sub    $0x1,%edi
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	85 ff                	test   %edi,%edi
  80145a:	7f ed                	jg     801449 <vprintfmt+0x1c0>
  80145c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80145f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801462:	85 c9                	test   %ecx,%ecx
  801464:	b8 00 00 00 00       	mov    $0x0,%eax
  801469:	0f 49 c1             	cmovns %ecx,%eax
  80146c:	29 c1                	sub    %eax,%ecx
  80146e:	89 75 08             	mov    %esi,0x8(%ebp)
  801471:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801474:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801477:	89 cb                	mov    %ecx,%ebx
  801479:	eb 4d                	jmp    8014c8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80147b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80147f:	74 1b                	je     80149c <vprintfmt+0x213>
  801481:	0f be c0             	movsbl %al,%eax
  801484:	83 e8 20             	sub    $0x20,%eax
  801487:	83 f8 5e             	cmp    $0x5e,%eax
  80148a:	76 10                	jbe    80149c <vprintfmt+0x213>
					putch('?', putdat);
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	ff 75 0c             	pushl  0xc(%ebp)
  801492:	6a 3f                	push   $0x3f
  801494:	ff 55 08             	call   *0x8(%ebp)
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	eb 0d                	jmp    8014a9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	ff 75 0c             	pushl  0xc(%ebp)
  8014a2:	52                   	push   %edx
  8014a3:	ff 55 08             	call   *0x8(%ebp)
  8014a6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a9:	83 eb 01             	sub    $0x1,%ebx
  8014ac:	eb 1a                	jmp    8014c8 <vprintfmt+0x23f>
  8014ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014ba:	eb 0c                	jmp    8014c8 <vprintfmt+0x23f>
  8014bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8014bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c8:	83 c7 01             	add    $0x1,%edi
  8014cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014cf:	0f be d0             	movsbl %al,%edx
  8014d2:	85 d2                	test   %edx,%edx
  8014d4:	74 23                	je     8014f9 <vprintfmt+0x270>
  8014d6:	85 f6                	test   %esi,%esi
  8014d8:	78 a1                	js     80147b <vprintfmt+0x1f2>
  8014da:	83 ee 01             	sub    $0x1,%esi
  8014dd:	79 9c                	jns    80147b <vprintfmt+0x1f2>
  8014df:	89 df                	mov    %ebx,%edi
  8014e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e7:	eb 18                	jmp    801501 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	53                   	push   %ebx
  8014ed:	6a 20                	push   $0x20
  8014ef:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014f1:	83 ef 01             	sub    $0x1,%edi
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	eb 08                	jmp    801501 <vprintfmt+0x278>
  8014f9:	89 df                	mov    %ebx,%edi
  8014fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8014fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801501:	85 ff                	test   %edi,%edi
  801503:	7f e4                	jg     8014e9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801508:	e9 a2 fd ff ff       	jmp    8012af <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80150d:	83 fa 01             	cmp    $0x1,%edx
  801510:	7e 16                	jle    801528 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801512:	8b 45 14             	mov    0x14(%ebp),%eax
  801515:	8d 50 08             	lea    0x8(%eax),%edx
  801518:	89 55 14             	mov    %edx,0x14(%ebp)
  80151b:	8b 50 04             	mov    0x4(%eax),%edx
  80151e:	8b 00                	mov    (%eax),%eax
  801520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801523:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801526:	eb 32                	jmp    80155a <vprintfmt+0x2d1>
	else if (lflag)
  801528:	85 d2                	test   %edx,%edx
  80152a:	74 18                	je     801544 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80152c:	8b 45 14             	mov    0x14(%ebp),%eax
  80152f:	8d 50 04             	lea    0x4(%eax),%edx
  801532:	89 55 14             	mov    %edx,0x14(%ebp)
  801535:	8b 00                	mov    (%eax),%eax
  801537:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153a:	89 c1                	mov    %eax,%ecx
  80153c:	c1 f9 1f             	sar    $0x1f,%ecx
  80153f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801542:	eb 16                	jmp    80155a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801544:	8b 45 14             	mov    0x14(%ebp),%eax
  801547:	8d 50 04             	lea    0x4(%eax),%edx
  80154a:	89 55 14             	mov    %edx,0x14(%ebp)
  80154d:	8b 00                	mov    (%eax),%eax
  80154f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801552:	89 c1                	mov    %eax,%ecx
  801554:	c1 f9 1f             	sar    $0x1f,%ecx
  801557:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80155a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80155d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801560:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801565:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801569:	79 74                	jns    8015df <vprintfmt+0x356>
				putch('-', putdat);
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	53                   	push   %ebx
  80156f:	6a 2d                	push   $0x2d
  801571:	ff d6                	call   *%esi
				num = -(long long) num;
  801573:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801576:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801579:	f7 d8                	neg    %eax
  80157b:	83 d2 00             	adc    $0x0,%edx
  80157e:	f7 da                	neg    %edx
  801580:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801583:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801588:	eb 55                	jmp    8015df <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80158a:	8d 45 14             	lea    0x14(%ebp),%eax
  80158d:	e8 83 fc ff ff       	call   801215 <getuint>
			base = 10;
  801592:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801597:	eb 46                	jmp    8015df <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801599:	8d 45 14             	lea    0x14(%ebp),%eax
  80159c:	e8 74 fc ff ff       	call   801215 <getuint>
			base = 8;
  8015a1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015a6:	eb 37                	jmp    8015df <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	53                   	push   %ebx
  8015ac:	6a 30                	push   $0x30
  8015ae:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	6a 78                	push   $0x78
  8015b6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bb:	8d 50 04             	lea    0x4(%eax),%edx
  8015be:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015c1:	8b 00                	mov    (%eax),%eax
  8015c3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015cb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015d0:	eb 0d                	jmp    8015df <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d5:	e8 3b fc ff ff       	call   801215 <getuint>
			base = 16;
  8015da:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015df:	83 ec 0c             	sub    $0xc,%esp
  8015e2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015e6:	57                   	push   %edi
  8015e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ea:	51                   	push   %ecx
  8015eb:	52                   	push   %edx
  8015ec:	50                   	push   %eax
  8015ed:	89 da                	mov    %ebx,%edx
  8015ef:	89 f0                	mov    %esi,%eax
  8015f1:	e8 70 fb ff ff       	call   801166 <printnum>
			break;
  8015f6:	83 c4 20             	add    $0x20,%esp
  8015f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015fc:	e9 ae fc ff ff       	jmp    8012af <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801601:	83 ec 08             	sub    $0x8,%esp
  801604:	53                   	push   %ebx
  801605:	51                   	push   %ecx
  801606:	ff d6                	call   *%esi
			break;
  801608:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80160e:	e9 9c fc ff ff       	jmp    8012af <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	53                   	push   %ebx
  801617:	6a 25                	push   $0x25
  801619:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	eb 03                	jmp    801623 <vprintfmt+0x39a>
  801620:	83 ef 01             	sub    $0x1,%edi
  801623:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801627:	75 f7                	jne    801620 <vprintfmt+0x397>
  801629:	e9 81 fc ff ff       	jmp    8012af <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80162e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801631:	5b                   	pop    %ebx
  801632:	5e                   	pop    %esi
  801633:	5f                   	pop    %edi
  801634:	5d                   	pop    %ebp
  801635:	c3                   	ret    

00801636 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	83 ec 18             	sub    $0x18,%esp
  80163c:	8b 45 08             	mov    0x8(%ebp),%eax
  80163f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801642:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801645:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801649:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80164c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801653:	85 c0                	test   %eax,%eax
  801655:	74 26                	je     80167d <vsnprintf+0x47>
  801657:	85 d2                	test   %edx,%edx
  801659:	7e 22                	jle    80167d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80165b:	ff 75 14             	pushl  0x14(%ebp)
  80165e:	ff 75 10             	pushl  0x10(%ebp)
  801661:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	68 4f 12 80 00       	push   $0x80124f
  80166a:	e8 1a fc ff ff       	call   801289 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80166f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801672:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	eb 05                	jmp    801682 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80167d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80168a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80168d:	50                   	push   %eax
  80168e:	ff 75 10             	pushl  0x10(%ebp)
  801691:	ff 75 0c             	pushl  0xc(%ebp)
  801694:	ff 75 08             	pushl  0x8(%ebp)
  801697:	e8 9a ff ff ff       	call   801636 <vsnprintf>
	va_end(ap);

	return rc;
}
  80169c:	c9                   	leave  
  80169d:	c3                   	ret    

0080169e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a9:	eb 03                	jmp    8016ae <strlen+0x10>
		n++;
  8016ab:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b2:	75 f7                	jne    8016ab <strlen+0xd>
		n++;
	return n;
}
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c4:	eb 03                	jmp    8016c9 <strnlen+0x13>
		n++;
  8016c6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c9:	39 c2                	cmp    %eax,%edx
  8016cb:	74 08                	je     8016d5 <strnlen+0x1f>
  8016cd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d1:	75 f3                	jne    8016c6 <strnlen+0x10>
  8016d3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	53                   	push   %ebx
  8016db:	8b 45 08             	mov    0x8(%ebp),%eax
  8016de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	83 c2 01             	add    $0x1,%edx
  8016e6:	83 c1 01             	add    $0x1,%ecx
  8016e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f0:	84 db                	test   %bl,%bl
  8016f2:	75 ef                	jne    8016e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016f4:	5b                   	pop    %ebx
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	53                   	push   %ebx
  8016fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016fe:	53                   	push   %ebx
  8016ff:	e8 9a ff ff ff       	call   80169e <strlen>
  801704:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	01 d8                	add    %ebx,%eax
  80170c:	50                   	push   %eax
  80170d:	e8 c5 ff ff ff       	call   8016d7 <strcpy>
	return dst;
}
  801712:	89 d8                	mov    %ebx,%eax
  801714:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801717:	c9                   	leave  
  801718:	c3                   	ret    

00801719 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	56                   	push   %esi
  80171d:	53                   	push   %ebx
  80171e:	8b 75 08             	mov    0x8(%ebp),%esi
  801721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801724:	89 f3                	mov    %esi,%ebx
  801726:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801729:	89 f2                	mov    %esi,%edx
  80172b:	eb 0f                	jmp    80173c <strncpy+0x23>
		*dst++ = *src;
  80172d:	83 c2 01             	add    $0x1,%edx
  801730:	0f b6 01             	movzbl (%ecx),%eax
  801733:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801736:	80 39 01             	cmpb   $0x1,(%ecx)
  801739:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173c:	39 da                	cmp    %ebx,%edx
  80173e:	75 ed                	jne    80172d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801740:	89 f0                	mov    %esi,%eax
  801742:	5b                   	pop    %ebx
  801743:	5e                   	pop    %esi
  801744:	5d                   	pop    %ebp
  801745:	c3                   	ret    

00801746 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
  80174b:	8b 75 08             	mov    0x8(%ebp),%esi
  80174e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801751:	8b 55 10             	mov    0x10(%ebp),%edx
  801754:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801756:	85 d2                	test   %edx,%edx
  801758:	74 21                	je     80177b <strlcpy+0x35>
  80175a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80175e:	89 f2                	mov    %esi,%edx
  801760:	eb 09                	jmp    80176b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801762:	83 c2 01             	add    $0x1,%edx
  801765:	83 c1 01             	add    $0x1,%ecx
  801768:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80176b:	39 c2                	cmp    %eax,%edx
  80176d:	74 09                	je     801778 <strlcpy+0x32>
  80176f:	0f b6 19             	movzbl (%ecx),%ebx
  801772:	84 db                	test   %bl,%bl
  801774:	75 ec                	jne    801762 <strlcpy+0x1c>
  801776:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801778:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80177b:	29 f0                	sub    %esi,%eax
}
  80177d:	5b                   	pop    %ebx
  80177e:	5e                   	pop    %esi
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801787:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80178a:	eb 06                	jmp    801792 <strcmp+0x11>
		p++, q++;
  80178c:	83 c1 01             	add    $0x1,%ecx
  80178f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801792:	0f b6 01             	movzbl (%ecx),%eax
  801795:	84 c0                	test   %al,%al
  801797:	74 04                	je     80179d <strcmp+0x1c>
  801799:	3a 02                	cmp    (%edx),%al
  80179b:	74 ef                	je     80178c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80179d:	0f b6 c0             	movzbl %al,%eax
  8017a0:	0f b6 12             	movzbl (%edx),%edx
  8017a3:	29 d0                	sub    %edx,%eax
}
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	53                   	push   %ebx
  8017ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b1:	89 c3                	mov    %eax,%ebx
  8017b3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b6:	eb 06                	jmp    8017be <strncmp+0x17>
		n--, p++, q++;
  8017b8:	83 c0 01             	add    $0x1,%eax
  8017bb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017be:	39 d8                	cmp    %ebx,%eax
  8017c0:	74 15                	je     8017d7 <strncmp+0x30>
  8017c2:	0f b6 08             	movzbl (%eax),%ecx
  8017c5:	84 c9                	test   %cl,%cl
  8017c7:	74 04                	je     8017cd <strncmp+0x26>
  8017c9:	3a 0a                	cmp    (%edx),%cl
  8017cb:	74 eb                	je     8017b8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017cd:	0f b6 00             	movzbl (%eax),%eax
  8017d0:	0f b6 12             	movzbl (%edx),%edx
  8017d3:	29 d0                	sub    %edx,%eax
  8017d5:	eb 05                	jmp    8017dc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017dc:	5b                   	pop    %ebx
  8017dd:	5d                   	pop    %ebp
  8017de:	c3                   	ret    

008017df <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e9:	eb 07                	jmp    8017f2 <strchr+0x13>
		if (*s == c)
  8017eb:	38 ca                	cmp    %cl,%dl
  8017ed:	74 0f                	je     8017fe <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017ef:	83 c0 01             	add    $0x1,%eax
  8017f2:	0f b6 10             	movzbl (%eax),%edx
  8017f5:	84 d2                	test   %dl,%dl
  8017f7:	75 f2                	jne    8017eb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    

00801800 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180a:	eb 03                	jmp    80180f <strfind+0xf>
  80180c:	83 c0 01             	add    $0x1,%eax
  80180f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801812:	38 ca                	cmp    %cl,%dl
  801814:	74 04                	je     80181a <strfind+0x1a>
  801816:	84 d2                	test   %dl,%dl
  801818:	75 f2                	jne    80180c <strfind+0xc>
			break;
	return (char *) s;
}
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	57                   	push   %edi
  801820:	56                   	push   %esi
  801821:	53                   	push   %ebx
  801822:	8b 7d 08             	mov    0x8(%ebp),%edi
  801825:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801828:	85 c9                	test   %ecx,%ecx
  80182a:	74 36                	je     801862 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80182c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801832:	75 28                	jne    80185c <memset+0x40>
  801834:	f6 c1 03             	test   $0x3,%cl
  801837:	75 23                	jne    80185c <memset+0x40>
		c &= 0xFF;
  801839:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80183d:	89 d3                	mov    %edx,%ebx
  80183f:	c1 e3 08             	shl    $0x8,%ebx
  801842:	89 d6                	mov    %edx,%esi
  801844:	c1 e6 18             	shl    $0x18,%esi
  801847:	89 d0                	mov    %edx,%eax
  801849:	c1 e0 10             	shl    $0x10,%eax
  80184c:	09 f0                	or     %esi,%eax
  80184e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801850:	89 d8                	mov    %ebx,%eax
  801852:	09 d0                	or     %edx,%eax
  801854:	c1 e9 02             	shr    $0x2,%ecx
  801857:	fc                   	cld    
  801858:	f3 ab                	rep stos %eax,%es:(%edi)
  80185a:	eb 06                	jmp    801862 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185f:	fc                   	cld    
  801860:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801862:	89 f8                	mov    %edi,%eax
  801864:	5b                   	pop    %ebx
  801865:	5e                   	pop    %esi
  801866:	5f                   	pop    %edi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	57                   	push   %edi
  80186d:	56                   	push   %esi
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	8b 75 0c             	mov    0xc(%ebp),%esi
  801874:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801877:	39 c6                	cmp    %eax,%esi
  801879:	73 35                	jae    8018b0 <memmove+0x47>
  80187b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80187e:	39 d0                	cmp    %edx,%eax
  801880:	73 2e                	jae    8018b0 <memmove+0x47>
		s += n;
		d += n;
  801882:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801885:	89 d6                	mov    %edx,%esi
  801887:	09 fe                	or     %edi,%esi
  801889:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80188f:	75 13                	jne    8018a4 <memmove+0x3b>
  801891:	f6 c1 03             	test   $0x3,%cl
  801894:	75 0e                	jne    8018a4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801896:	83 ef 04             	sub    $0x4,%edi
  801899:	8d 72 fc             	lea    -0x4(%edx),%esi
  80189c:	c1 e9 02             	shr    $0x2,%ecx
  80189f:	fd                   	std    
  8018a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a2:	eb 09                	jmp    8018ad <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a4:	83 ef 01             	sub    $0x1,%edi
  8018a7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018aa:	fd                   	std    
  8018ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ad:	fc                   	cld    
  8018ae:	eb 1d                	jmp    8018cd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b0:	89 f2                	mov    %esi,%edx
  8018b2:	09 c2                	or     %eax,%edx
  8018b4:	f6 c2 03             	test   $0x3,%dl
  8018b7:	75 0f                	jne    8018c8 <memmove+0x5f>
  8018b9:	f6 c1 03             	test   $0x3,%cl
  8018bc:	75 0a                	jne    8018c8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018be:	c1 e9 02             	shr    $0x2,%ecx
  8018c1:	89 c7                	mov    %eax,%edi
  8018c3:	fc                   	cld    
  8018c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c6:	eb 05                	jmp    8018cd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018c8:	89 c7                	mov    %eax,%edi
  8018ca:	fc                   	cld    
  8018cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018cd:	5e                   	pop    %esi
  8018ce:	5f                   	pop    %edi
  8018cf:	5d                   	pop    %ebp
  8018d0:	c3                   	ret    

008018d1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d4:	ff 75 10             	pushl  0x10(%ebp)
  8018d7:	ff 75 0c             	pushl  0xc(%ebp)
  8018da:	ff 75 08             	pushl  0x8(%ebp)
  8018dd:	e8 87 ff ff ff       	call   801869 <memmove>
}
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	56                   	push   %esi
  8018e8:	53                   	push   %ebx
  8018e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ef:	89 c6                	mov    %eax,%esi
  8018f1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f4:	eb 1a                	jmp    801910 <memcmp+0x2c>
		if (*s1 != *s2)
  8018f6:	0f b6 08             	movzbl (%eax),%ecx
  8018f9:	0f b6 1a             	movzbl (%edx),%ebx
  8018fc:	38 d9                	cmp    %bl,%cl
  8018fe:	74 0a                	je     80190a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801900:	0f b6 c1             	movzbl %cl,%eax
  801903:	0f b6 db             	movzbl %bl,%ebx
  801906:	29 d8                	sub    %ebx,%eax
  801908:	eb 0f                	jmp    801919 <memcmp+0x35>
		s1++, s2++;
  80190a:	83 c0 01             	add    $0x1,%eax
  80190d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801910:	39 f0                	cmp    %esi,%eax
  801912:	75 e2                	jne    8018f6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	53                   	push   %ebx
  801921:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801924:	89 c1                	mov    %eax,%ecx
  801926:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801929:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80192d:	eb 0a                	jmp    801939 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80192f:	0f b6 10             	movzbl (%eax),%edx
  801932:	39 da                	cmp    %ebx,%edx
  801934:	74 07                	je     80193d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801936:	83 c0 01             	add    $0x1,%eax
  801939:	39 c8                	cmp    %ecx,%eax
  80193b:	72 f2                	jb     80192f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80193d:	5b                   	pop    %ebx
  80193e:	5d                   	pop    %ebp
  80193f:	c3                   	ret    

00801940 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	57                   	push   %edi
  801944:	56                   	push   %esi
  801945:	53                   	push   %ebx
  801946:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801949:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194c:	eb 03                	jmp    801951 <strtol+0x11>
		s++;
  80194e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801951:	0f b6 01             	movzbl (%ecx),%eax
  801954:	3c 20                	cmp    $0x20,%al
  801956:	74 f6                	je     80194e <strtol+0xe>
  801958:	3c 09                	cmp    $0x9,%al
  80195a:	74 f2                	je     80194e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80195c:	3c 2b                	cmp    $0x2b,%al
  80195e:	75 0a                	jne    80196a <strtol+0x2a>
		s++;
  801960:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801963:	bf 00 00 00 00       	mov    $0x0,%edi
  801968:	eb 11                	jmp    80197b <strtol+0x3b>
  80196a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80196f:	3c 2d                	cmp    $0x2d,%al
  801971:	75 08                	jne    80197b <strtol+0x3b>
		s++, neg = 1;
  801973:	83 c1 01             	add    $0x1,%ecx
  801976:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801981:	75 15                	jne    801998 <strtol+0x58>
  801983:	80 39 30             	cmpb   $0x30,(%ecx)
  801986:	75 10                	jne    801998 <strtol+0x58>
  801988:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80198c:	75 7c                	jne    801a0a <strtol+0xca>
		s += 2, base = 16;
  80198e:	83 c1 02             	add    $0x2,%ecx
  801991:	bb 10 00 00 00       	mov    $0x10,%ebx
  801996:	eb 16                	jmp    8019ae <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801998:	85 db                	test   %ebx,%ebx
  80199a:	75 12                	jne    8019ae <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a1:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a4:	75 08                	jne    8019ae <strtol+0x6e>
		s++, base = 8;
  8019a6:	83 c1 01             	add    $0x1,%ecx
  8019a9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019b6:	0f b6 11             	movzbl (%ecx),%edx
  8019b9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019bc:	89 f3                	mov    %esi,%ebx
  8019be:	80 fb 09             	cmp    $0x9,%bl
  8019c1:	77 08                	ja     8019cb <strtol+0x8b>
			dig = *s - '0';
  8019c3:	0f be d2             	movsbl %dl,%edx
  8019c6:	83 ea 30             	sub    $0x30,%edx
  8019c9:	eb 22                	jmp    8019ed <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019cb:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ce:	89 f3                	mov    %esi,%ebx
  8019d0:	80 fb 19             	cmp    $0x19,%bl
  8019d3:	77 08                	ja     8019dd <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019d5:	0f be d2             	movsbl %dl,%edx
  8019d8:	83 ea 57             	sub    $0x57,%edx
  8019db:	eb 10                	jmp    8019ed <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019dd:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e0:	89 f3                	mov    %esi,%ebx
  8019e2:	80 fb 19             	cmp    $0x19,%bl
  8019e5:	77 16                	ja     8019fd <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019e7:	0f be d2             	movsbl %dl,%edx
  8019ea:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019ed:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f0:	7d 0b                	jge    8019fd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019f2:	83 c1 01             	add    $0x1,%ecx
  8019f5:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019fb:	eb b9                	jmp    8019b6 <strtol+0x76>

	if (endptr)
  8019fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a01:	74 0d                	je     801a10 <strtol+0xd0>
		*endptr = (char *) s;
  801a03:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a06:	89 0e                	mov    %ecx,(%esi)
  801a08:	eb 06                	jmp    801a10 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a0a:	85 db                	test   %ebx,%ebx
  801a0c:	74 98                	je     8019a6 <strtol+0x66>
  801a0e:	eb 9e                	jmp    8019ae <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a10:	89 c2                	mov    %eax,%edx
  801a12:	f7 da                	neg    %edx
  801a14:	85 ff                	test   %edi,%edi
  801a16:	0f 45 c2             	cmovne %edx,%eax
}
  801a19:	5b                   	pop    %ebx
  801a1a:	5e                   	pop    %esi
  801a1b:	5f                   	pop    %edi
  801a1c:	5d                   	pop    %ebp
  801a1d:	c3                   	ret    

00801a1e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	56                   	push   %esi
  801a22:	53                   	push   %ebx
  801a23:	8b 75 08             	mov    0x8(%ebp),%esi
  801a26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	75 12                	jne    801a42 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	68 00 00 c0 ee       	push   $0xeec00000
  801a38:	e8 11 e9 ff ff       	call   80034e <sys_ipc_recv>
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	eb 0c                	jmp    801a4e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	50                   	push   %eax
  801a46:	e8 03 e9 ff ff       	call   80034e <sys_ipc_recv>
  801a4b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a4e:	85 f6                	test   %esi,%esi
  801a50:	0f 95 c1             	setne  %cl
  801a53:	85 db                	test   %ebx,%ebx
  801a55:	0f 95 c2             	setne  %dl
  801a58:	84 d1                	test   %dl,%cl
  801a5a:	74 09                	je     801a65 <ipc_recv+0x47>
  801a5c:	89 c2                	mov    %eax,%edx
  801a5e:	c1 ea 1f             	shr    $0x1f,%edx
  801a61:	84 d2                	test   %dl,%dl
  801a63:	75 24                	jne    801a89 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a65:	85 f6                	test   %esi,%esi
  801a67:	74 0a                	je     801a73 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801a69:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6e:	8b 40 74             	mov    0x74(%eax),%eax
  801a71:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801a73:	85 db                	test   %ebx,%ebx
  801a75:	74 0a                	je     801a81 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801a77:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7c:	8b 40 78             	mov    0x78(%eax),%eax
  801a7f:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a81:	a1 04 40 80 00       	mov    0x804004,%eax
  801a86:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8c:	5b                   	pop    %ebx
  801a8d:	5e                   	pop    %esi
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	57                   	push   %edi
  801a94:	56                   	push   %esi
  801a95:	53                   	push   %ebx
  801a96:	83 ec 0c             	sub    $0xc,%esp
  801a99:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801aa2:	85 db                	test   %ebx,%ebx
  801aa4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aa9:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801aac:	ff 75 14             	pushl  0x14(%ebp)
  801aaf:	53                   	push   %ebx
  801ab0:	56                   	push   %esi
  801ab1:	57                   	push   %edi
  801ab2:	e8 74 e8 ff ff       	call   80032b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ab7:	89 c2                	mov    %eax,%edx
  801ab9:	c1 ea 1f             	shr    $0x1f,%edx
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	84 d2                	test   %dl,%dl
  801ac1:	74 17                	je     801ada <ipc_send+0x4a>
  801ac3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ac6:	74 12                	je     801ada <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ac8:	50                   	push   %eax
  801ac9:	68 40 22 80 00       	push   $0x802240
  801ace:	6a 47                	push   $0x47
  801ad0:	68 4e 22 80 00       	push   $0x80224e
  801ad5:	e8 9f f5 ff ff       	call   801079 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ada:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801add:	75 07                	jne    801ae6 <ipc_send+0x56>
			sys_yield();
  801adf:	e8 9b e6 ff ff       	call   80017f <sys_yield>
  801ae4:	eb c6                	jmp    801aac <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	75 c2                	jne    801aac <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5f                   	pop    %edi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801afd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b00:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b06:	8b 52 50             	mov    0x50(%edx),%edx
  801b09:	39 ca                	cmp    %ecx,%edx
  801b0b:	75 0d                	jne    801b1a <ipc_find_env+0x28>
			return envs[i].env_id;
  801b0d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b10:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b15:	8b 40 48             	mov    0x48(%eax),%eax
  801b18:	eb 0f                	jmp    801b29 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b1a:	83 c0 01             	add    $0x1,%eax
  801b1d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b22:	75 d9                	jne    801afd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b31:	89 d0                	mov    %edx,%eax
  801b33:	c1 e8 16             	shr    $0x16,%eax
  801b36:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b3d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b42:	f6 c1 01             	test   $0x1,%cl
  801b45:	74 1d                	je     801b64 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b47:	c1 ea 0c             	shr    $0xc,%edx
  801b4a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b51:	f6 c2 01             	test   $0x1,%dl
  801b54:	74 0e                	je     801b64 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b56:	c1 ea 0c             	shr    $0xc,%edx
  801b59:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b60:	ef 
  801b61:	0f b7 c0             	movzwl %ax,%eax
}
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    
  801b66:	66 90                	xchg   %ax,%ax
  801b68:	66 90                	xchg   %ax,%ax
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
