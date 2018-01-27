
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 66 05 00 00       	call   800597 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 b1 27 80 00       	push   $0x8027b1
  800049:	68 80 27 80 00       	push   $0x802780
  80004e:	e8 a0 06 00 00       	call   8006f3 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 90 27 80 00       	push   $0x802790
  80005c:	68 94 27 80 00       	push   $0x802794
  800061:	e8 8d 06 00 00       	call   8006f3 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 a4 27 80 00       	push   $0x8027a4
  800077:	e8 77 06 00 00       	call   8006f3 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 a8 27 80 00       	push   $0x8027a8
  80008e:	e8 60 06 00 00       	call   8006f3 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 b2 27 80 00       	push   $0x8027b2
  8000a6:	68 94 27 80 00       	push   $0x802794
  8000ab:	e8 43 06 00 00       	call   8006f3 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 a4 27 80 00       	push   $0x8027a4
  8000c3:	e8 2b 06 00 00       	call   8006f3 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 a8 27 80 00       	push   $0x8027a8
  8000d5:	e8 19 06 00 00       	call   8006f3 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 b6 27 80 00       	push   $0x8027b6
  8000ed:	68 94 27 80 00       	push   $0x802794
  8000f2:	e8 fc 05 00 00       	call   8006f3 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 a4 27 80 00       	push   $0x8027a4
  80010a:	e8 e4 05 00 00       	call   8006f3 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 a8 27 80 00       	push   $0x8027a8
  80011c:	e8 d2 05 00 00       	call   8006f3 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 ba 27 80 00       	push   $0x8027ba
  800134:	68 94 27 80 00       	push   $0x802794
  800139:	e8 b5 05 00 00       	call   8006f3 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 a4 27 80 00       	push   $0x8027a4
  800151:	e8 9d 05 00 00       	call   8006f3 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 a8 27 80 00       	push   $0x8027a8
  800163:	e8 8b 05 00 00       	call   8006f3 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 be 27 80 00       	push   $0x8027be
  80017b:	68 94 27 80 00       	push   $0x802794
  800180:	e8 6e 05 00 00       	call   8006f3 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 a4 27 80 00       	push   $0x8027a4
  800198:	e8 56 05 00 00       	call   8006f3 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 a8 27 80 00       	push   $0x8027a8
  8001aa:	e8 44 05 00 00       	call   8006f3 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 c2 27 80 00       	push   $0x8027c2
  8001c2:	68 94 27 80 00       	push   $0x802794
  8001c7:	e8 27 05 00 00       	call   8006f3 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 a4 27 80 00       	push   $0x8027a4
  8001df:	e8 0f 05 00 00       	call   8006f3 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 a8 27 80 00       	push   $0x8027a8
  8001f1:	e8 fd 04 00 00       	call   8006f3 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 c6 27 80 00       	push   $0x8027c6
  800209:	68 94 27 80 00       	push   $0x802794
  80020e:	e8 e0 04 00 00       	call   8006f3 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 a4 27 80 00       	push   $0x8027a4
  800226:	e8 c8 04 00 00       	call   8006f3 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 a8 27 80 00       	push   $0x8027a8
  800238:	e8 b6 04 00 00       	call   8006f3 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 ca 27 80 00       	push   $0x8027ca
  800250:	68 94 27 80 00       	push   $0x802794
  800255:	e8 99 04 00 00       	call   8006f3 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 a4 27 80 00       	push   $0x8027a4
  80026d:	e8 81 04 00 00       	call   8006f3 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 a8 27 80 00       	push   $0x8027a8
  80027f:	e8 6f 04 00 00       	call   8006f3 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 ce 27 80 00       	push   $0x8027ce
  800297:	68 94 27 80 00       	push   $0x802794
  80029c:	e8 52 04 00 00       	call   8006f3 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 a4 27 80 00       	push   $0x8027a4
  8002b4:	e8 3a 04 00 00       	call   8006f3 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 d5 27 80 00       	push   $0x8027d5
  8002c4:	68 94 27 80 00       	push   $0x802794
  8002c9:	e8 25 04 00 00       	call   8006f3 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 a8 27 80 00       	push   $0x8027a8
  8002e3:	e8 0b 04 00 00       	call   8006f3 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 d5 27 80 00       	push   $0x8027d5
  8002f3:	68 94 27 80 00       	push   $0x802794
  8002f8:	e8 f6 03 00 00       	call   8006f3 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 a4 27 80 00       	push   $0x8027a4
  800312:	e8 dc 03 00 00       	call   8006f3 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 d9 27 80 00       	push   $0x8027d9
  800322:	e8 cc 03 00 00       	call   8006f3 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 a8 27 80 00       	push   $0x8027a8
  800338:	e8 b6 03 00 00       	call   8006f3 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 d9 27 80 00       	push   $0x8027d9
  800348:	e8 a6 03 00 00       	call   8006f3 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 a4 27 80 00       	push   $0x8027a4
  80035a:	e8 94 03 00 00       	call   8006f3 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 a8 27 80 00       	push   $0x8027a8
  80036c:	e8 82 03 00 00       	call   8006f3 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 a4 27 80 00       	push   $0x8027a4
  80037e:	e8 70 03 00 00       	call   8006f3 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 d9 27 80 00       	push   $0x8027d9
  80038e:	e8 60 03 00 00       	call   8006f3 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 40 28 80 00       	push   $0x802840
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 e7 27 80 00       	push   $0x8027e7
  8003c6:	e8 4f 02 00 00       	call   80061a <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 ff 27 80 00       	push   $0x8027ff
  80043b:	68 0d 28 80 00       	push   $0x80280d
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba f8 27 80 00       	mov    $0x8027f8,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 16 0c 00 00       	call   80107b <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 14 28 80 00       	push   $0x802814
  800472:	6a 5c                	push   $0x5c
  800474:	68 e7 27 80 00       	push   $0x8027e7
  800479:	e8 9c 01 00 00       	call   80061a <_panic>
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <umain>:

void
umain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800486:	68 a0 03 80 00       	push   $0x8003a0
  80048b:	e8 3c 0e 00 00       	call   8012cc <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b1:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b7:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004bd:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c3:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c9:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004cf:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004d4:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004ea:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f0:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f6:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004fc:	89 15 14 40 80 00    	mov    %edx,0x804014
  800502:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800508:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80050d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800513:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800519:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80051f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800525:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80052b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800531:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800537:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80053c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 24 40 80 00       	mov    %eax,0x804024
  80054a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800555:	74 10                	je     800567 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	68 74 28 80 00       	push   $0x802874
  80055f:	e8 8f 01 00 00       	call   8006f3 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 27 28 80 00       	push   $0x802827
  800579:	68 38 28 80 00       	push   $0x802838
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba f8 27 80 00       	mov    $0x8027f8,%edx
  800588:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058d:	e8 a1 fa ff ff       	call   800033 <check_regs>
}
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8005a2:	e8 96 0a 00 00       	call   80103d <sys_getenvid>
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8005b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b7:	a3 b0 40 80 00       	mov    %eax,0x8040b0
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005bc:	85 db                	test   %ebx,%ebx
  8005be:	7e 07                	jle    8005c7 <libmain+0x30>
		binaryname = argv[0];
  8005c0:	8b 06                	mov    (%esi),%eax
  8005c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	56                   	push   %esi
  8005cb:	53                   	push   %ebx
  8005cc:	e8 af fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  8005d1:	e8 2a 00 00 00       	call   800600 <exit>
}
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005dc:	5b                   	pop    %ebx
  8005dd:	5e                   	pop    %esi
  8005de:	5d                   	pop    %ebp
  8005df:	c3                   	ret    

008005e0 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8005e0:	55                   	push   %ebp
  8005e1:	89 e5                	mov    %esp,%ebp
  8005e3:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8005e6:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	func();
  8005eb:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8005ed:	e8 4b 0a 00 00       	call   80103d <sys_getenvid>
  8005f2:	83 ec 0c             	sub    $0xc,%esp
  8005f5:	50                   	push   %eax
  8005f6:	e8 91 0c 00 00       	call   80128c <sys_thread_free>
}
  8005fb:	83 c4 10             	add    $0x10,%esp
  8005fe:	c9                   	leave  
  8005ff:	c3                   	ret    

00800600 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800606:	e8 38 12 00 00       	call   801843 <close_all>
	sys_env_destroy(0);
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	6a 00                	push   $0x0
  800610:	e8 e7 09 00 00       	call   800ffc <sys_env_destroy>
}
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	c9                   	leave  
  800619:	c3                   	ret    

0080061a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80061a:	55                   	push   %ebp
  80061b:	89 e5                	mov    %esp,%ebp
  80061d:	56                   	push   %esi
  80061e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80061f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800622:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800628:	e8 10 0a 00 00       	call   80103d <sys_getenvid>
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	ff 75 0c             	pushl  0xc(%ebp)
  800633:	ff 75 08             	pushl  0x8(%ebp)
  800636:	56                   	push   %esi
  800637:	50                   	push   %eax
  800638:	68 a0 28 80 00       	push   $0x8028a0
  80063d:	e8 b1 00 00 00       	call   8006f3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800642:	83 c4 18             	add    $0x18,%esp
  800645:	53                   	push   %ebx
  800646:	ff 75 10             	pushl  0x10(%ebp)
  800649:	e8 54 00 00 00       	call   8006a2 <vcprintf>
	cprintf("\n");
  80064e:	c7 04 24 b0 27 80 00 	movl   $0x8027b0,(%esp)
  800655:	e8 99 00 00 00       	call   8006f3 <cprintf>
  80065a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80065d:	cc                   	int3   
  80065e:	eb fd                	jmp    80065d <_panic+0x43>

00800660 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
  800663:	53                   	push   %ebx
  800664:	83 ec 04             	sub    $0x4,%esp
  800667:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80066a:	8b 13                	mov    (%ebx),%edx
  80066c:	8d 42 01             	lea    0x1(%edx),%eax
  80066f:	89 03                	mov    %eax,(%ebx)
  800671:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800674:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800678:	3d ff 00 00 00       	cmp    $0xff,%eax
  80067d:	75 1a                	jne    800699 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	68 ff 00 00 00       	push   $0xff
  800687:	8d 43 08             	lea    0x8(%ebx),%eax
  80068a:	50                   	push   %eax
  80068b:	e8 2f 09 00 00       	call   800fbf <sys_cputs>
		b->idx = 0;
  800690:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800696:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800699:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80069d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a0:	c9                   	leave  
  8006a1:	c3                   	ret    

008006a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006b2:	00 00 00 
	b.cnt = 0;
  8006b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006bc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006bf:	ff 75 0c             	pushl  0xc(%ebp)
  8006c2:	ff 75 08             	pushl  0x8(%ebp)
  8006c5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006cb:	50                   	push   %eax
  8006cc:	68 60 06 80 00       	push   $0x800660
  8006d1:	e8 54 01 00 00       	call   80082a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006d6:	83 c4 08             	add    $0x8,%esp
  8006d9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006df:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006e5:	50                   	push   %eax
  8006e6:	e8 d4 08 00 00       	call   800fbf <sys_cputs>

	return b.cnt;
}
  8006eb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    

008006f3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006f9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006fc:	50                   	push   %eax
  8006fd:	ff 75 08             	pushl  0x8(%ebp)
  800700:	e8 9d ff ff ff       	call   8006a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
  80070d:	83 ec 1c             	sub    $0x1c,%esp
  800710:	89 c7                	mov    %eax,%edi
  800712:	89 d6                	mov    %edx,%esi
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	8b 55 0c             	mov    0xc(%ebp),%edx
  80071a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800720:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800723:	bb 00 00 00 00       	mov    $0x0,%ebx
  800728:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80072b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80072e:	39 d3                	cmp    %edx,%ebx
  800730:	72 05                	jb     800737 <printnum+0x30>
  800732:	39 45 10             	cmp    %eax,0x10(%ebp)
  800735:	77 45                	ja     80077c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800737:	83 ec 0c             	sub    $0xc,%esp
  80073a:	ff 75 18             	pushl  0x18(%ebp)
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800743:	53                   	push   %ebx
  800744:	ff 75 10             	pushl  0x10(%ebp)
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80074d:	ff 75 e0             	pushl  -0x20(%ebp)
  800750:	ff 75 dc             	pushl  -0x24(%ebp)
  800753:	ff 75 d8             	pushl  -0x28(%ebp)
  800756:	e8 85 1d 00 00       	call   8024e0 <__udivdi3>
  80075b:	83 c4 18             	add    $0x18,%esp
  80075e:	52                   	push   %edx
  80075f:	50                   	push   %eax
  800760:	89 f2                	mov    %esi,%edx
  800762:	89 f8                	mov    %edi,%eax
  800764:	e8 9e ff ff ff       	call   800707 <printnum>
  800769:	83 c4 20             	add    $0x20,%esp
  80076c:	eb 18                	jmp    800786 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	56                   	push   %esi
  800772:	ff 75 18             	pushl  0x18(%ebp)
  800775:	ff d7                	call   *%edi
  800777:	83 c4 10             	add    $0x10,%esp
  80077a:	eb 03                	jmp    80077f <printnum+0x78>
  80077c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80077f:	83 eb 01             	sub    $0x1,%ebx
  800782:	85 db                	test   %ebx,%ebx
  800784:	7f e8                	jg     80076e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	56                   	push   %esi
  80078a:	83 ec 04             	sub    $0x4,%esp
  80078d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800790:	ff 75 e0             	pushl  -0x20(%ebp)
  800793:	ff 75 dc             	pushl  -0x24(%ebp)
  800796:	ff 75 d8             	pushl  -0x28(%ebp)
  800799:	e8 72 1e 00 00       	call   802610 <__umoddi3>
  80079e:	83 c4 14             	add    $0x14,%esp
  8007a1:	0f be 80 c3 28 80 00 	movsbl 0x8028c3(%eax),%eax
  8007a8:	50                   	push   %eax
  8007a9:	ff d7                	call   *%edi
}
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	5f                   	pop    %edi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007b9:	83 fa 01             	cmp    $0x1,%edx
  8007bc:	7e 0e                	jle    8007cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007be:	8b 10                	mov    (%eax),%edx
  8007c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007c3:	89 08                	mov    %ecx,(%eax)
  8007c5:	8b 02                	mov    (%edx),%eax
  8007c7:	8b 52 04             	mov    0x4(%edx),%edx
  8007ca:	eb 22                	jmp    8007ee <getuint+0x38>
	else if (lflag)
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 10                	je     8007e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007d0:	8b 10                	mov    (%eax),%edx
  8007d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007d5:	89 08                	mov    %ecx,(%eax)
  8007d7:	8b 02                	mov    (%edx),%eax
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007de:	eb 0e                	jmp    8007ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007e5:	89 08                	mov    %ecx,(%eax)
  8007e7:	8b 02                	mov    (%edx),%eax
  8007e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007f6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007fa:	8b 10                	mov    (%eax),%edx
  8007fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8007ff:	73 0a                	jae    80080b <sprintputch+0x1b>
		*b->buf++ = ch;
  800801:	8d 4a 01             	lea    0x1(%edx),%ecx
  800804:	89 08                	mov    %ecx,(%eax)
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	88 02                	mov    %al,(%edx)
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80080d:	55                   	push   %ebp
  80080e:	89 e5                	mov    %esp,%ebp
  800810:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800813:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800816:	50                   	push   %eax
  800817:	ff 75 10             	pushl  0x10(%ebp)
  80081a:	ff 75 0c             	pushl  0xc(%ebp)
  80081d:	ff 75 08             	pushl  0x8(%ebp)
  800820:	e8 05 00 00 00       	call   80082a <vprintfmt>
	va_end(ap);
}
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	57                   	push   %edi
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	83 ec 2c             	sub    $0x2c,%esp
  800833:	8b 75 08             	mov    0x8(%ebp),%esi
  800836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800839:	8b 7d 10             	mov    0x10(%ebp),%edi
  80083c:	eb 12                	jmp    800850 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80083e:	85 c0                	test   %eax,%eax
  800840:	0f 84 89 03 00 00    	je     800bcf <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	53                   	push   %ebx
  80084a:	50                   	push   %eax
  80084b:	ff d6                	call   *%esi
  80084d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800850:	83 c7 01             	add    $0x1,%edi
  800853:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800857:	83 f8 25             	cmp    $0x25,%eax
  80085a:	75 e2                	jne    80083e <vprintfmt+0x14>
  80085c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800860:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800867:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80086e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800875:	ba 00 00 00 00       	mov    $0x0,%edx
  80087a:	eb 07                	jmp    800883 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80087f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800883:	8d 47 01             	lea    0x1(%edi),%eax
  800886:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800889:	0f b6 07             	movzbl (%edi),%eax
  80088c:	0f b6 c8             	movzbl %al,%ecx
  80088f:	83 e8 23             	sub    $0x23,%eax
  800892:	3c 55                	cmp    $0x55,%al
  800894:	0f 87 1a 03 00 00    	ja     800bb4 <vprintfmt+0x38a>
  80089a:	0f b6 c0             	movzbl %al,%eax
  80089d:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008a7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008ab:	eb d6                	jmp    800883 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008b8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008bb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8008bf:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8008c2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8008c5:	83 fa 09             	cmp    $0x9,%edx
  8008c8:	77 39                	ja     800903 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008ca:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008cd:	eb e9                	jmp    8008b8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d2:	8d 48 04             	lea    0x4(%eax),%ecx
  8008d5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008d8:	8b 00                	mov    (%eax),%eax
  8008da:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008e0:	eb 27                	jmp    800909 <vprintfmt+0xdf>
  8008e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008e5:	85 c0                	test   %eax,%eax
  8008e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ec:	0f 49 c8             	cmovns %eax,%ecx
  8008ef:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f5:	eb 8c                	jmp    800883 <vprintfmt+0x59>
  8008f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008fa:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800901:	eb 80                	jmp    800883 <vprintfmt+0x59>
  800903:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800906:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800909:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80090d:	0f 89 70 ff ff ff    	jns    800883 <vprintfmt+0x59>
				width = precision, precision = -1;
  800913:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800916:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800919:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800920:	e9 5e ff ff ff       	jmp    800883 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800925:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800928:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80092b:	e9 53 ff ff ff       	jmp    800883 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800930:	8b 45 14             	mov    0x14(%ebp),%eax
  800933:	8d 50 04             	lea    0x4(%eax),%edx
  800936:	89 55 14             	mov    %edx,0x14(%ebp)
  800939:	83 ec 08             	sub    $0x8,%esp
  80093c:	53                   	push   %ebx
  80093d:	ff 30                	pushl  (%eax)
  80093f:	ff d6                	call   *%esi
			break;
  800941:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800944:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800947:	e9 04 ff ff ff       	jmp    800850 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80094c:	8b 45 14             	mov    0x14(%ebp),%eax
  80094f:	8d 50 04             	lea    0x4(%eax),%edx
  800952:	89 55 14             	mov    %edx,0x14(%ebp)
  800955:	8b 00                	mov    (%eax),%eax
  800957:	99                   	cltd   
  800958:	31 d0                	xor    %edx,%eax
  80095a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80095c:	83 f8 0f             	cmp    $0xf,%eax
  80095f:	7f 0b                	jg     80096c <vprintfmt+0x142>
  800961:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  800968:	85 d2                	test   %edx,%edx
  80096a:	75 18                	jne    800984 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80096c:	50                   	push   %eax
  80096d:	68 db 28 80 00       	push   $0x8028db
  800972:	53                   	push   %ebx
  800973:	56                   	push   %esi
  800974:	e8 94 fe ff ff       	call   80080d <printfmt>
  800979:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80097f:	e9 cc fe ff ff       	jmp    800850 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800984:	52                   	push   %edx
  800985:	68 21 2d 80 00       	push   $0x802d21
  80098a:	53                   	push   %ebx
  80098b:	56                   	push   %esi
  80098c:	e8 7c fe ff ff       	call   80080d <printfmt>
  800991:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800994:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800997:	e9 b4 fe ff ff       	jmp    800850 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80099c:	8b 45 14             	mov    0x14(%ebp),%eax
  80099f:	8d 50 04             	lea    0x4(%eax),%edx
  8009a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009a7:	85 ff                	test   %edi,%edi
  8009a9:	b8 d4 28 80 00       	mov    $0x8028d4,%eax
  8009ae:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009b5:	0f 8e 94 00 00 00    	jle    800a4f <vprintfmt+0x225>
  8009bb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009bf:	0f 84 98 00 00 00    	je     800a5d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	ff 75 d0             	pushl  -0x30(%ebp)
  8009cb:	57                   	push   %edi
  8009cc:	e8 86 02 00 00       	call   800c57 <strnlen>
  8009d1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009d4:	29 c1                	sub    %eax,%ecx
  8009d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009d9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009dc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009e3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009e6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e8:	eb 0f                	jmp    8009f9 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009ea:	83 ec 08             	sub    $0x8,%esp
  8009ed:	53                   	push   %ebx
  8009ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8009f1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f3:	83 ef 01             	sub    $0x1,%edi
  8009f6:	83 c4 10             	add    $0x10,%esp
  8009f9:	85 ff                	test   %edi,%edi
  8009fb:	7f ed                	jg     8009ea <vprintfmt+0x1c0>
  8009fd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a00:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a03:	85 c9                	test   %ecx,%ecx
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	0f 49 c1             	cmovns %ecx,%eax
  800a0d:	29 c1                	sub    %eax,%ecx
  800a0f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a12:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a15:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a18:	89 cb                	mov    %ecx,%ebx
  800a1a:	eb 4d                	jmp    800a69 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a1c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a20:	74 1b                	je     800a3d <vprintfmt+0x213>
  800a22:	0f be c0             	movsbl %al,%eax
  800a25:	83 e8 20             	sub    $0x20,%eax
  800a28:	83 f8 5e             	cmp    $0x5e,%eax
  800a2b:	76 10                	jbe    800a3d <vprintfmt+0x213>
					putch('?', putdat);
  800a2d:	83 ec 08             	sub    $0x8,%esp
  800a30:	ff 75 0c             	pushl  0xc(%ebp)
  800a33:	6a 3f                	push   $0x3f
  800a35:	ff 55 08             	call   *0x8(%ebp)
  800a38:	83 c4 10             	add    $0x10,%esp
  800a3b:	eb 0d                	jmp    800a4a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a3d:	83 ec 08             	sub    $0x8,%esp
  800a40:	ff 75 0c             	pushl  0xc(%ebp)
  800a43:	52                   	push   %edx
  800a44:	ff 55 08             	call   *0x8(%ebp)
  800a47:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a4a:	83 eb 01             	sub    $0x1,%ebx
  800a4d:	eb 1a                	jmp    800a69 <vprintfmt+0x23f>
  800a4f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a52:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a55:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a58:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a5b:	eb 0c                	jmp    800a69 <vprintfmt+0x23f>
  800a5d:	89 75 08             	mov    %esi,0x8(%ebp)
  800a60:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a63:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a66:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a69:	83 c7 01             	add    $0x1,%edi
  800a6c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a70:	0f be d0             	movsbl %al,%edx
  800a73:	85 d2                	test   %edx,%edx
  800a75:	74 23                	je     800a9a <vprintfmt+0x270>
  800a77:	85 f6                	test   %esi,%esi
  800a79:	78 a1                	js     800a1c <vprintfmt+0x1f2>
  800a7b:	83 ee 01             	sub    $0x1,%esi
  800a7e:	79 9c                	jns    800a1c <vprintfmt+0x1f2>
  800a80:	89 df                	mov    %ebx,%edi
  800a82:	8b 75 08             	mov    0x8(%ebp),%esi
  800a85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a88:	eb 18                	jmp    800aa2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a8a:	83 ec 08             	sub    $0x8,%esp
  800a8d:	53                   	push   %ebx
  800a8e:	6a 20                	push   $0x20
  800a90:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a92:	83 ef 01             	sub    $0x1,%edi
  800a95:	83 c4 10             	add    $0x10,%esp
  800a98:	eb 08                	jmp    800aa2 <vprintfmt+0x278>
  800a9a:	89 df                	mov    %ebx,%edi
  800a9c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa2:	85 ff                	test   %edi,%edi
  800aa4:	7f e4                	jg     800a8a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aa6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aa9:	e9 a2 fd ff ff       	jmp    800850 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aae:	83 fa 01             	cmp    $0x1,%edx
  800ab1:	7e 16                	jle    800ac9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800ab3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab6:	8d 50 08             	lea    0x8(%eax),%edx
  800ab9:	89 55 14             	mov    %edx,0x14(%ebp)
  800abc:	8b 50 04             	mov    0x4(%eax),%edx
  800abf:	8b 00                	mov    (%eax),%eax
  800ac1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ac4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ac7:	eb 32                	jmp    800afb <vprintfmt+0x2d1>
	else if (lflag)
  800ac9:	85 d2                	test   %edx,%edx
  800acb:	74 18                	je     800ae5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800acd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad0:	8d 50 04             	lea    0x4(%eax),%edx
  800ad3:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad6:	8b 00                	mov    (%eax),%eax
  800ad8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800adb:	89 c1                	mov    %eax,%ecx
  800add:	c1 f9 1f             	sar    $0x1f,%ecx
  800ae0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ae3:	eb 16                	jmp    800afb <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ae5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae8:	8d 50 04             	lea    0x4(%eax),%edx
  800aeb:	89 55 14             	mov    %edx,0x14(%ebp)
  800aee:	8b 00                	mov    (%eax),%eax
  800af0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800af3:	89 c1                	mov    %eax,%ecx
  800af5:	c1 f9 1f             	sar    $0x1f,%ecx
  800af8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800afb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800afe:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b01:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b06:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b0a:	79 74                	jns    800b80 <vprintfmt+0x356>
				putch('-', putdat);
  800b0c:	83 ec 08             	sub    $0x8,%esp
  800b0f:	53                   	push   %ebx
  800b10:	6a 2d                	push   $0x2d
  800b12:	ff d6                	call   *%esi
				num = -(long long) num;
  800b14:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b17:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b1a:	f7 d8                	neg    %eax
  800b1c:	83 d2 00             	adc    $0x0,%edx
  800b1f:	f7 da                	neg    %edx
  800b21:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b24:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b29:	eb 55                	jmp    800b80 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b2b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b2e:	e8 83 fc ff ff       	call   8007b6 <getuint>
			base = 10;
  800b33:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b38:	eb 46                	jmp    800b80 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b3a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b3d:	e8 74 fc ff ff       	call   8007b6 <getuint>
			base = 8;
  800b42:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b47:	eb 37                	jmp    800b80 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b49:	83 ec 08             	sub    $0x8,%esp
  800b4c:	53                   	push   %ebx
  800b4d:	6a 30                	push   $0x30
  800b4f:	ff d6                	call   *%esi
			putch('x', putdat);
  800b51:	83 c4 08             	add    $0x8,%esp
  800b54:	53                   	push   %ebx
  800b55:	6a 78                	push   $0x78
  800b57:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b59:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5c:	8d 50 04             	lea    0x4(%eax),%edx
  800b5f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b62:	8b 00                	mov    (%eax),%eax
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b69:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b6c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b71:	eb 0d                	jmp    800b80 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b73:	8d 45 14             	lea    0x14(%ebp),%eax
  800b76:	e8 3b fc ff ff       	call   8007b6 <getuint>
			base = 16;
  800b7b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b87:	57                   	push   %edi
  800b88:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8b:	51                   	push   %ecx
  800b8c:	52                   	push   %edx
  800b8d:	50                   	push   %eax
  800b8e:	89 da                	mov    %ebx,%edx
  800b90:	89 f0                	mov    %esi,%eax
  800b92:	e8 70 fb ff ff       	call   800707 <printnum>
			break;
  800b97:	83 c4 20             	add    $0x20,%esp
  800b9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b9d:	e9 ae fc ff ff       	jmp    800850 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ba2:	83 ec 08             	sub    $0x8,%esp
  800ba5:	53                   	push   %ebx
  800ba6:	51                   	push   %ecx
  800ba7:	ff d6                	call   *%esi
			break;
  800ba9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800baf:	e9 9c fc ff ff       	jmp    800850 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bb4:	83 ec 08             	sub    $0x8,%esp
  800bb7:	53                   	push   %ebx
  800bb8:	6a 25                	push   $0x25
  800bba:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bbc:	83 c4 10             	add    $0x10,%esp
  800bbf:	eb 03                	jmp    800bc4 <vprintfmt+0x39a>
  800bc1:	83 ef 01             	sub    $0x1,%edi
  800bc4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800bc8:	75 f7                	jne    800bc1 <vprintfmt+0x397>
  800bca:	e9 81 fc ff ff       	jmp    800850 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	83 ec 18             	sub    $0x18,%esp
  800bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800be0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800be3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	74 26                	je     800c1e <vsnprintf+0x47>
  800bf8:	85 d2                	test   %edx,%edx
  800bfa:	7e 22                	jle    800c1e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bfc:	ff 75 14             	pushl  0x14(%ebp)
  800bff:	ff 75 10             	pushl  0x10(%ebp)
  800c02:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c05:	50                   	push   %eax
  800c06:	68 f0 07 80 00       	push   $0x8007f0
  800c0b:	e8 1a fc ff ff       	call   80082a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c13:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c19:	83 c4 10             	add    $0x10,%esp
  800c1c:	eb 05                	jmp    800c23 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c2b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c2e:	50                   	push   %eax
  800c2f:	ff 75 10             	pushl  0x10(%ebp)
  800c32:	ff 75 0c             	pushl  0xc(%ebp)
  800c35:	ff 75 08             	pushl  0x8(%ebp)
  800c38:	e8 9a ff ff ff       	call   800bd7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c45:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4a:	eb 03                	jmp    800c4f <strlen+0x10>
		n++;
  800c4c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c4f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c53:	75 f7                	jne    800c4c <strlen+0xd>
		n++;
	return n;
}
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	eb 03                	jmp    800c6a <strnlen+0x13>
		n++;
  800c67:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6a:	39 c2                	cmp    %eax,%edx
  800c6c:	74 08                	je     800c76 <strnlen+0x1f>
  800c6e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c72:	75 f3                	jne    800c67 <strnlen+0x10>
  800c74:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	53                   	push   %ebx
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c82:	89 c2                	mov    %eax,%edx
  800c84:	83 c2 01             	add    $0x1,%edx
  800c87:	83 c1 01             	add    $0x1,%ecx
  800c8a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c8e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c91:	84 db                	test   %bl,%bl
  800c93:	75 ef                	jne    800c84 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c95:	5b                   	pop    %ebx
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	53                   	push   %ebx
  800c9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c9f:	53                   	push   %ebx
  800ca0:	e8 9a ff ff ff       	call   800c3f <strlen>
  800ca5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ca8:	ff 75 0c             	pushl  0xc(%ebp)
  800cab:	01 d8                	add    %ebx,%eax
  800cad:	50                   	push   %eax
  800cae:	e8 c5 ff ff ff       	call   800c78 <strcpy>
	return dst;
}
  800cb3:	89 d8                	mov    %ebx,%eax
  800cb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	89 f3                	mov    %esi,%ebx
  800cc7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cca:	89 f2                	mov    %esi,%edx
  800ccc:	eb 0f                	jmp    800cdd <strncpy+0x23>
		*dst++ = *src;
  800cce:	83 c2 01             	add    $0x1,%edx
  800cd1:	0f b6 01             	movzbl (%ecx),%eax
  800cd4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cd7:	80 39 01             	cmpb   $0x1,(%ecx)
  800cda:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cdd:	39 da                	cmp    %ebx,%edx
  800cdf:	75 ed                	jne    800cce <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ce1:	89 f0                	mov    %esi,%eax
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	8b 75 08             	mov    0x8(%ebp),%esi
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	8b 55 10             	mov    0x10(%ebp),%edx
  800cf5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cf7:	85 d2                	test   %edx,%edx
  800cf9:	74 21                	je     800d1c <strlcpy+0x35>
  800cfb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cff:	89 f2                	mov    %esi,%edx
  800d01:	eb 09                	jmp    800d0c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d03:	83 c2 01             	add    $0x1,%edx
  800d06:	83 c1 01             	add    $0x1,%ecx
  800d09:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d0c:	39 c2                	cmp    %eax,%edx
  800d0e:	74 09                	je     800d19 <strlcpy+0x32>
  800d10:	0f b6 19             	movzbl (%ecx),%ebx
  800d13:	84 db                	test   %bl,%bl
  800d15:	75 ec                	jne    800d03 <strlcpy+0x1c>
  800d17:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d19:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d1c:	29 f0                	sub    %esi,%eax
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d28:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d2b:	eb 06                	jmp    800d33 <strcmp+0x11>
		p++, q++;
  800d2d:	83 c1 01             	add    $0x1,%ecx
  800d30:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d33:	0f b6 01             	movzbl (%ecx),%eax
  800d36:	84 c0                	test   %al,%al
  800d38:	74 04                	je     800d3e <strcmp+0x1c>
  800d3a:	3a 02                	cmp    (%edx),%al
  800d3c:	74 ef                	je     800d2d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d3e:	0f b6 c0             	movzbl %al,%eax
  800d41:	0f b6 12             	movzbl (%edx),%edx
  800d44:	29 d0                	sub    %edx,%eax
}
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	53                   	push   %ebx
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d52:	89 c3                	mov    %eax,%ebx
  800d54:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d57:	eb 06                	jmp    800d5f <strncmp+0x17>
		n--, p++, q++;
  800d59:	83 c0 01             	add    $0x1,%eax
  800d5c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d5f:	39 d8                	cmp    %ebx,%eax
  800d61:	74 15                	je     800d78 <strncmp+0x30>
  800d63:	0f b6 08             	movzbl (%eax),%ecx
  800d66:	84 c9                	test   %cl,%cl
  800d68:	74 04                	je     800d6e <strncmp+0x26>
  800d6a:	3a 0a                	cmp    (%edx),%cl
  800d6c:	74 eb                	je     800d59 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d6e:	0f b6 00             	movzbl (%eax),%eax
  800d71:	0f b6 12             	movzbl (%edx),%edx
  800d74:	29 d0                	sub    %edx,%eax
  800d76:	eb 05                	jmp    800d7d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d78:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d8a:	eb 07                	jmp    800d93 <strchr+0x13>
		if (*s == c)
  800d8c:	38 ca                	cmp    %cl,%dl
  800d8e:	74 0f                	je     800d9f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d90:	83 c0 01             	add    $0x1,%eax
  800d93:	0f b6 10             	movzbl (%eax),%edx
  800d96:	84 d2                	test   %dl,%dl
  800d98:	75 f2                	jne    800d8c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
  800da7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dab:	eb 03                	jmp    800db0 <strfind+0xf>
  800dad:	83 c0 01             	add    $0x1,%eax
  800db0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800db3:	38 ca                	cmp    %cl,%dl
  800db5:	74 04                	je     800dbb <strfind+0x1a>
  800db7:	84 d2                	test   %dl,%dl
  800db9:	75 f2                	jne    800dad <strfind+0xc>
			break;
	return (char *) s;
}
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dc6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dc9:	85 c9                	test   %ecx,%ecx
  800dcb:	74 36                	je     800e03 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dcd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dd3:	75 28                	jne    800dfd <memset+0x40>
  800dd5:	f6 c1 03             	test   $0x3,%cl
  800dd8:	75 23                	jne    800dfd <memset+0x40>
		c &= 0xFF;
  800dda:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dde:	89 d3                	mov    %edx,%ebx
  800de0:	c1 e3 08             	shl    $0x8,%ebx
  800de3:	89 d6                	mov    %edx,%esi
  800de5:	c1 e6 18             	shl    $0x18,%esi
  800de8:	89 d0                	mov    %edx,%eax
  800dea:	c1 e0 10             	shl    $0x10,%eax
  800ded:	09 f0                	or     %esi,%eax
  800def:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800df1:	89 d8                	mov    %ebx,%eax
  800df3:	09 d0                	or     %edx,%eax
  800df5:	c1 e9 02             	shr    $0x2,%ecx
  800df8:	fc                   	cld    
  800df9:	f3 ab                	rep stos %eax,%es:(%edi)
  800dfb:	eb 06                	jmp    800e03 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e00:	fc                   	cld    
  800e01:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e03:	89 f8                	mov    %edi,%eax
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e18:	39 c6                	cmp    %eax,%esi
  800e1a:	73 35                	jae    800e51 <memmove+0x47>
  800e1c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e1f:	39 d0                	cmp    %edx,%eax
  800e21:	73 2e                	jae    800e51 <memmove+0x47>
		s += n;
		d += n;
  800e23:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e26:	89 d6                	mov    %edx,%esi
  800e28:	09 fe                	or     %edi,%esi
  800e2a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e30:	75 13                	jne    800e45 <memmove+0x3b>
  800e32:	f6 c1 03             	test   $0x3,%cl
  800e35:	75 0e                	jne    800e45 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e37:	83 ef 04             	sub    $0x4,%edi
  800e3a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e3d:	c1 e9 02             	shr    $0x2,%ecx
  800e40:	fd                   	std    
  800e41:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e43:	eb 09                	jmp    800e4e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e45:	83 ef 01             	sub    $0x1,%edi
  800e48:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e4b:	fd                   	std    
  800e4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e4e:	fc                   	cld    
  800e4f:	eb 1d                	jmp    800e6e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e51:	89 f2                	mov    %esi,%edx
  800e53:	09 c2                	or     %eax,%edx
  800e55:	f6 c2 03             	test   $0x3,%dl
  800e58:	75 0f                	jne    800e69 <memmove+0x5f>
  800e5a:	f6 c1 03             	test   $0x3,%cl
  800e5d:	75 0a                	jne    800e69 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e5f:	c1 e9 02             	shr    $0x2,%ecx
  800e62:	89 c7                	mov    %eax,%edi
  800e64:	fc                   	cld    
  800e65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e67:	eb 05                	jmp    800e6e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e69:	89 c7                	mov    %eax,%edi
  800e6b:	fc                   	cld    
  800e6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e75:	ff 75 10             	pushl  0x10(%ebp)
  800e78:	ff 75 0c             	pushl  0xc(%ebp)
  800e7b:	ff 75 08             	pushl  0x8(%ebp)
  800e7e:	e8 87 ff ff ff       	call   800e0a <memmove>
}
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e90:	89 c6                	mov    %eax,%esi
  800e92:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e95:	eb 1a                	jmp    800eb1 <memcmp+0x2c>
		if (*s1 != *s2)
  800e97:	0f b6 08             	movzbl (%eax),%ecx
  800e9a:	0f b6 1a             	movzbl (%edx),%ebx
  800e9d:	38 d9                	cmp    %bl,%cl
  800e9f:	74 0a                	je     800eab <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ea1:	0f b6 c1             	movzbl %cl,%eax
  800ea4:	0f b6 db             	movzbl %bl,%ebx
  800ea7:	29 d8                	sub    %ebx,%eax
  800ea9:	eb 0f                	jmp    800eba <memcmp+0x35>
		s1++, s2++;
  800eab:	83 c0 01             	add    $0x1,%eax
  800eae:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eb1:	39 f0                	cmp    %esi,%eax
  800eb3:	75 e2                	jne    800e97 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800eb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	53                   	push   %ebx
  800ec2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ec5:	89 c1                	mov    %eax,%ecx
  800ec7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800eca:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ece:	eb 0a                	jmp    800eda <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ed0:	0f b6 10             	movzbl (%eax),%edx
  800ed3:	39 da                	cmp    %ebx,%edx
  800ed5:	74 07                	je     800ede <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ed7:	83 c0 01             	add    $0x1,%eax
  800eda:	39 c8                	cmp    %ecx,%eax
  800edc:	72 f2                	jb     800ed0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ede:	5b                   	pop    %ebx
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	57                   	push   %edi
  800ee5:	56                   	push   %esi
  800ee6:	53                   	push   %ebx
  800ee7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eed:	eb 03                	jmp    800ef2 <strtol+0x11>
		s++;
  800eef:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ef2:	0f b6 01             	movzbl (%ecx),%eax
  800ef5:	3c 20                	cmp    $0x20,%al
  800ef7:	74 f6                	je     800eef <strtol+0xe>
  800ef9:	3c 09                	cmp    $0x9,%al
  800efb:	74 f2                	je     800eef <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800efd:	3c 2b                	cmp    $0x2b,%al
  800eff:	75 0a                	jne    800f0b <strtol+0x2a>
		s++;
  800f01:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f04:	bf 00 00 00 00       	mov    $0x0,%edi
  800f09:	eb 11                	jmp    800f1c <strtol+0x3b>
  800f0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f10:	3c 2d                	cmp    $0x2d,%al
  800f12:	75 08                	jne    800f1c <strtol+0x3b>
		s++, neg = 1;
  800f14:	83 c1 01             	add    $0x1,%ecx
  800f17:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f1c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f22:	75 15                	jne    800f39 <strtol+0x58>
  800f24:	80 39 30             	cmpb   $0x30,(%ecx)
  800f27:	75 10                	jne    800f39 <strtol+0x58>
  800f29:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f2d:	75 7c                	jne    800fab <strtol+0xca>
		s += 2, base = 16;
  800f2f:	83 c1 02             	add    $0x2,%ecx
  800f32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f37:	eb 16                	jmp    800f4f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f39:	85 db                	test   %ebx,%ebx
  800f3b:	75 12                	jne    800f4f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f3d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f42:	80 39 30             	cmpb   $0x30,(%ecx)
  800f45:	75 08                	jne    800f4f <strtol+0x6e>
		s++, base = 8;
  800f47:	83 c1 01             	add    $0x1,%ecx
  800f4a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f54:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f57:	0f b6 11             	movzbl (%ecx),%edx
  800f5a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f5d:	89 f3                	mov    %esi,%ebx
  800f5f:	80 fb 09             	cmp    $0x9,%bl
  800f62:	77 08                	ja     800f6c <strtol+0x8b>
			dig = *s - '0';
  800f64:	0f be d2             	movsbl %dl,%edx
  800f67:	83 ea 30             	sub    $0x30,%edx
  800f6a:	eb 22                	jmp    800f8e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f6c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f6f:	89 f3                	mov    %esi,%ebx
  800f71:	80 fb 19             	cmp    $0x19,%bl
  800f74:	77 08                	ja     800f7e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f76:	0f be d2             	movsbl %dl,%edx
  800f79:	83 ea 57             	sub    $0x57,%edx
  800f7c:	eb 10                	jmp    800f8e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f7e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f81:	89 f3                	mov    %esi,%ebx
  800f83:	80 fb 19             	cmp    $0x19,%bl
  800f86:	77 16                	ja     800f9e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f88:	0f be d2             	movsbl %dl,%edx
  800f8b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f8e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f91:	7d 0b                	jge    800f9e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f93:	83 c1 01             	add    $0x1,%ecx
  800f96:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f9a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f9c:	eb b9                	jmp    800f57 <strtol+0x76>

	if (endptr)
  800f9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fa2:	74 0d                	je     800fb1 <strtol+0xd0>
		*endptr = (char *) s;
  800fa4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fa7:	89 0e                	mov    %ecx,(%esi)
  800fa9:	eb 06                	jmp    800fb1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fab:	85 db                	test   %ebx,%ebx
  800fad:	74 98                	je     800f47 <strtol+0x66>
  800faf:	eb 9e                	jmp    800f4f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fb1:	89 c2                	mov    %eax,%edx
  800fb3:	f7 da                	neg    %edx
  800fb5:	85 ff                	test   %edi,%edi
  800fb7:	0f 45 c2             	cmovne %edx,%eax
}
  800fba:	5b                   	pop    %ebx
  800fbb:	5e                   	pop    %esi
  800fbc:	5f                   	pop    %edi
  800fbd:	5d                   	pop    %ebp
  800fbe:	c3                   	ret    

00800fbf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	57                   	push   %edi
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800fca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd0:	89 c3                	mov    %eax,%ebx
  800fd2:	89 c7                	mov    %eax,%edi
  800fd4:	89 c6                	mov    %eax,%esi
  800fd6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_cgetc>:

int
sys_cgetc(void)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe8:	b8 01 00 00 00       	mov    $0x1,%eax
  800fed:	89 d1                	mov    %edx,%ecx
  800fef:	89 d3                	mov    %edx,%ebx
  800ff1:	89 d7                	mov    %edx,%edi
  800ff3:	89 d6                	mov    %edx,%esi
  800ff5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
  801002:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801005:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100a:	b8 03 00 00 00       	mov    $0x3,%eax
  80100f:	8b 55 08             	mov    0x8(%ebp),%edx
  801012:	89 cb                	mov    %ecx,%ebx
  801014:	89 cf                	mov    %ecx,%edi
  801016:	89 ce                	mov    %ecx,%esi
  801018:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80101a:	85 c0                	test   %eax,%eax
  80101c:	7e 17                	jle    801035 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	50                   	push   %eax
  801022:	6a 03                	push   $0x3
  801024:	68 bf 2b 80 00       	push   $0x802bbf
  801029:	6a 23                	push   $0x23
  80102b:	68 dc 2b 80 00       	push   $0x802bdc
  801030:	e8 e5 f5 ff ff       	call   80061a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801035:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	57                   	push   %edi
  801041:	56                   	push   %esi
  801042:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801043:	ba 00 00 00 00       	mov    $0x0,%edx
  801048:	b8 02 00 00 00       	mov    $0x2,%eax
  80104d:	89 d1                	mov    %edx,%ecx
  80104f:	89 d3                	mov    %edx,%ebx
  801051:	89 d7                	mov    %edx,%edi
  801053:	89 d6                	mov    %edx,%esi
  801055:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801057:	5b                   	pop    %ebx
  801058:	5e                   	pop    %esi
  801059:	5f                   	pop    %edi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <sys_yield>:

void
sys_yield(void)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	57                   	push   %edi
  801060:	56                   	push   %esi
  801061:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801062:	ba 00 00 00 00       	mov    $0x0,%edx
  801067:	b8 0b 00 00 00       	mov    $0xb,%eax
  80106c:	89 d1                	mov    %edx,%ecx
  80106e:	89 d3                	mov    %edx,%ebx
  801070:	89 d7                	mov    %edx,%edi
  801072:	89 d6                	mov    %edx,%esi
  801074:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5f                   	pop    %edi
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801084:	be 00 00 00 00       	mov    $0x0,%esi
  801089:	b8 04 00 00 00       	mov    $0x4,%eax
  80108e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801091:	8b 55 08             	mov    0x8(%ebp),%edx
  801094:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801097:	89 f7                	mov    %esi,%edi
  801099:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80109b:	85 c0                	test   %eax,%eax
  80109d:	7e 17                	jle    8010b6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	50                   	push   %eax
  8010a3:	6a 04                	push   $0x4
  8010a5:	68 bf 2b 80 00       	push   $0x802bbf
  8010aa:	6a 23                	push   $0x23
  8010ac:	68 dc 2b 80 00       	push   $0x802bdc
  8010b1:	e8 64 f5 ff ff       	call   80061a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b9:	5b                   	pop    %ebx
  8010ba:	5e                   	pop    %esi
  8010bb:	5f                   	pop    %edi
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	57                   	push   %edi
  8010c2:	56                   	push   %esi
  8010c3:	53                   	push   %ebx
  8010c4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c7:	b8 05 00 00 00       	mov    $0x5,%eax
  8010cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d8:	8b 75 18             	mov    0x18(%ebp),%esi
  8010db:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	7e 17                	jle    8010f8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	50                   	push   %eax
  8010e5:	6a 05                	push   $0x5
  8010e7:	68 bf 2b 80 00       	push   $0x802bbf
  8010ec:	6a 23                	push   $0x23
  8010ee:	68 dc 2b 80 00       	push   $0x802bdc
  8010f3:	e8 22 f5 ff ff       	call   80061a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	57                   	push   %edi
  801104:	56                   	push   %esi
  801105:	53                   	push   %ebx
  801106:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801109:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110e:	b8 06 00 00 00       	mov    $0x6,%eax
  801113:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801116:	8b 55 08             	mov    0x8(%ebp),%edx
  801119:	89 df                	mov    %ebx,%edi
  80111b:	89 de                	mov    %ebx,%esi
  80111d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80111f:	85 c0                	test   %eax,%eax
  801121:	7e 17                	jle    80113a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	50                   	push   %eax
  801127:	6a 06                	push   $0x6
  801129:	68 bf 2b 80 00       	push   $0x802bbf
  80112e:	6a 23                	push   $0x23
  801130:	68 dc 2b 80 00       	push   $0x802bdc
  801135:	e8 e0 f4 ff ff       	call   80061a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	57                   	push   %edi
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801150:	b8 08 00 00 00       	mov    $0x8,%eax
  801155:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801158:	8b 55 08             	mov    0x8(%ebp),%edx
  80115b:	89 df                	mov    %ebx,%edi
  80115d:	89 de                	mov    %ebx,%esi
  80115f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801161:	85 c0                	test   %eax,%eax
  801163:	7e 17                	jle    80117c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	50                   	push   %eax
  801169:	6a 08                	push   $0x8
  80116b:	68 bf 2b 80 00       	push   $0x802bbf
  801170:	6a 23                	push   $0x23
  801172:	68 dc 2b 80 00       	push   $0x802bdc
  801177:	e8 9e f4 ff ff       	call   80061a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	57                   	push   %edi
  801188:	56                   	push   %esi
  801189:	53                   	push   %ebx
  80118a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801192:	b8 09 00 00 00       	mov    $0x9,%eax
  801197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119a:	8b 55 08             	mov    0x8(%ebp),%edx
  80119d:	89 df                	mov    %ebx,%edi
  80119f:	89 de                	mov    %ebx,%esi
  8011a1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	7e 17                	jle    8011be <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a7:	83 ec 0c             	sub    $0xc,%esp
  8011aa:	50                   	push   %eax
  8011ab:	6a 09                	push   $0x9
  8011ad:	68 bf 2b 80 00       	push   $0x802bbf
  8011b2:	6a 23                	push   $0x23
  8011b4:	68 dc 2b 80 00       	push   $0x802bdc
  8011b9:	e8 5c f4 ff ff       	call   80061a <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	57                   	push   %edi
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011df:	89 df                	mov    %ebx,%edi
  8011e1:	89 de                	mov    %ebx,%esi
  8011e3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	7e 17                	jle    801200 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	50                   	push   %eax
  8011ed:	6a 0a                	push   $0xa
  8011ef:	68 bf 2b 80 00       	push   $0x802bbf
  8011f4:	6a 23                	push   $0x23
  8011f6:	68 dc 2b 80 00       	push   $0x802bdc
  8011fb:	e8 1a f4 ff ff       	call   80061a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120e:	be 00 00 00 00       	mov    $0x0,%esi
  801213:	b8 0c 00 00 00       	mov    $0xc,%eax
  801218:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121b:	8b 55 08             	mov    0x8(%ebp),%edx
  80121e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801221:	8b 7d 14             	mov    0x14(%ebp),%edi
  801224:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801226:	5b                   	pop    %ebx
  801227:	5e                   	pop    %esi
  801228:	5f                   	pop    %edi
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	57                   	push   %edi
  80122f:	56                   	push   %esi
  801230:	53                   	push   %ebx
  801231:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801234:	b9 00 00 00 00       	mov    $0x0,%ecx
  801239:	b8 0d 00 00 00       	mov    $0xd,%eax
  80123e:	8b 55 08             	mov    0x8(%ebp),%edx
  801241:	89 cb                	mov    %ecx,%ebx
  801243:	89 cf                	mov    %ecx,%edi
  801245:	89 ce                	mov    %ecx,%esi
  801247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801249:	85 c0                	test   %eax,%eax
  80124b:	7e 17                	jle    801264 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80124d:	83 ec 0c             	sub    $0xc,%esp
  801250:	50                   	push   %eax
  801251:	6a 0d                	push   $0xd
  801253:	68 bf 2b 80 00       	push   $0x802bbf
  801258:	6a 23                	push   $0x23
  80125a:	68 dc 2b 80 00       	push   $0x802bdc
  80125f:	e8 b6 f3 ff ff       	call   80061a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5f                   	pop    %edi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	57                   	push   %edi
  801270:	56                   	push   %esi
  801271:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801272:	b9 00 00 00 00       	mov    $0x0,%ecx
  801277:	b8 0e 00 00 00       	mov    $0xe,%eax
  80127c:	8b 55 08             	mov    0x8(%ebp),%edx
  80127f:	89 cb                	mov    %ecx,%ebx
  801281:	89 cf                	mov    %ecx,%edi
  801283:	89 ce                	mov    %ecx,%esi
  801285:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  801287:	5b                   	pop    %ebx
  801288:	5e                   	pop    %esi
  801289:	5f                   	pop    %edi
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	57                   	push   %edi
  801290:	56                   	push   %esi
  801291:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801292:	b9 00 00 00 00       	mov    $0x0,%ecx
  801297:	b8 0f 00 00 00       	mov    $0xf,%eax
  80129c:	8b 55 08             	mov    0x8(%ebp),%edx
  80129f:	89 cb                	mov    %ecx,%ebx
  8012a1:	89 cf                	mov    %ecx,%edi
  8012a3:	89 ce                	mov    %ecx,%esi
  8012a5:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8012a7:	5b                   	pop    %ebx
  8012a8:	5e                   	pop    %esi
  8012a9:	5f                   	pop    %edi
  8012aa:	5d                   	pop    %ebp
  8012ab:	c3                   	ret    

008012ac <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	57                   	push   %edi
  8012b0:	56                   	push   %esi
  8012b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b7:	b8 10 00 00 00       	mov    $0x10,%eax
  8012bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8012bf:	89 cb                	mov    %ecx,%ebx
  8012c1:	89 cf                	mov    %ecx,%edi
  8012c3:	89 ce                	mov    %ecx,%esi
  8012c5:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8012c7:	5b                   	pop    %ebx
  8012c8:	5e                   	pop    %esi
  8012c9:	5f                   	pop    %edi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    

008012cc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012d2:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012d9:	75 2a                	jne    801305 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8012db:	83 ec 04             	sub    $0x4,%esp
  8012de:	6a 07                	push   $0x7
  8012e0:	68 00 f0 bf ee       	push   $0xeebff000
  8012e5:	6a 00                	push   $0x0
  8012e7:	e8 8f fd ff ff       	call   80107b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	79 12                	jns    801305 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8012f3:	50                   	push   %eax
  8012f4:	68 ea 2b 80 00       	push   $0x802bea
  8012f9:	6a 23                	push   $0x23
  8012fb:	68 ee 2b 80 00       	push   $0x802bee
  801300:	e8 15 f3 ff ff       	call   80061a <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801305:	8b 45 08             	mov    0x8(%ebp),%eax
  801308:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	68 37 13 80 00       	push   $0x801337
  801315:	6a 00                	push   $0x0
  801317:	e8 aa fe ff ff       	call   8011c6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	79 12                	jns    801335 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801323:	50                   	push   %eax
  801324:	68 ea 2b 80 00       	push   $0x802bea
  801329:	6a 2c                	push   $0x2c
  80132b:	68 ee 2b 80 00       	push   $0x802bee
  801330:	e8 e5 f2 ff ff       	call   80061a <_panic>
	}
}
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801337:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801338:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80133d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80133f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801342:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801346:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80134b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80134f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801351:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801354:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801355:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801358:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801359:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80135a:	c3                   	ret    

0080135b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	53                   	push   %ebx
  80135f:	83 ec 04             	sub    $0x4,%esp
  801362:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801365:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  801367:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80136b:	74 11                	je     80137e <pgfault+0x23>
  80136d:	89 d8                	mov    %ebx,%eax
  80136f:	c1 e8 0c             	shr    $0xc,%eax
  801372:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801379:	f6 c4 08             	test   $0x8,%ah
  80137c:	75 14                	jne    801392 <pgfault+0x37>
		panic("faulting access");
  80137e:	83 ec 04             	sub    $0x4,%esp
  801381:	68 fc 2b 80 00       	push   $0x802bfc
  801386:	6a 1e                	push   $0x1e
  801388:	68 0c 2c 80 00       	push   $0x802c0c
  80138d:	e8 88 f2 ff ff       	call   80061a <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  801392:	83 ec 04             	sub    $0x4,%esp
  801395:	6a 07                	push   $0x7
  801397:	68 00 f0 7f 00       	push   $0x7ff000
  80139c:	6a 00                	push   $0x0
  80139e:	e8 d8 fc ff ff       	call   80107b <sys_page_alloc>
	if (r < 0) {
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	79 12                	jns    8013bc <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8013aa:	50                   	push   %eax
  8013ab:	68 17 2c 80 00       	push   $0x802c17
  8013b0:	6a 2c                	push   $0x2c
  8013b2:	68 0c 2c 80 00       	push   $0x802c0c
  8013b7:	e8 5e f2 ff ff       	call   80061a <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  8013bc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  8013c2:	83 ec 04             	sub    $0x4,%esp
  8013c5:	68 00 10 00 00       	push   $0x1000
  8013ca:	53                   	push   %ebx
  8013cb:	68 00 f0 7f 00       	push   $0x7ff000
  8013d0:	e8 9d fa ff ff       	call   800e72 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  8013d5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8013dc:	53                   	push   %ebx
  8013dd:	6a 00                	push   $0x0
  8013df:	68 00 f0 7f 00       	push   $0x7ff000
  8013e4:	6a 00                	push   $0x0
  8013e6:	e8 d3 fc ff ff       	call   8010be <sys_page_map>
	if (r < 0) {
  8013eb:	83 c4 20             	add    $0x20,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	79 12                	jns    801404 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  8013f2:	50                   	push   %eax
  8013f3:	68 17 2c 80 00       	push   $0x802c17
  8013f8:	6a 33                	push   $0x33
  8013fa:	68 0c 2c 80 00       	push   $0x802c0c
  8013ff:	e8 16 f2 ff ff       	call   80061a <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	68 00 f0 7f 00       	push   $0x7ff000
  80140c:	6a 00                	push   $0x0
  80140e:	e8 ed fc ff ff       	call   801100 <sys_page_unmap>
	if (r < 0) {
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	79 12                	jns    80142c <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80141a:	50                   	push   %eax
  80141b:	68 17 2c 80 00       	push   $0x802c17
  801420:	6a 37                	push   $0x37
  801422:	68 0c 2c 80 00       	push   $0x802c0c
  801427:	e8 ee f1 ff ff       	call   80061a <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80142c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	57                   	push   %edi
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80143a:	68 5b 13 80 00       	push   $0x80135b
  80143f:	e8 88 fe ff ff       	call   8012cc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801444:	b8 07 00 00 00       	mov    $0x7,%eax
  801449:	cd 30                	int    $0x30
  80144b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	79 17                	jns    80146c <fork+0x3b>
		panic("fork fault %e");
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	68 30 2c 80 00       	push   $0x802c30
  80145d:	68 84 00 00 00       	push   $0x84
  801462:	68 0c 2c 80 00       	push   $0x802c0c
  801467:	e8 ae f1 ff ff       	call   80061a <_panic>
  80146c:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  80146e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801472:	75 24                	jne    801498 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801474:	e8 c4 fb ff ff       	call   80103d <sys_getenvid>
  801479:	25 ff 03 00 00       	and    $0x3ff,%eax
  80147e:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801484:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801489:	a3 b0 40 80 00       	mov    %eax,0x8040b0
		return 0;
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
  801493:	e9 64 01 00 00       	jmp    8015fc <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	6a 07                	push   $0x7
  80149d:	68 00 f0 bf ee       	push   $0xeebff000
  8014a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014a5:	e8 d1 fb ff ff       	call   80107b <sys_page_alloc>
  8014aa:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8014ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8014b2:	89 d8                	mov    %ebx,%eax
  8014b4:	c1 e8 16             	shr    $0x16,%eax
  8014b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014be:	a8 01                	test   $0x1,%al
  8014c0:	0f 84 fc 00 00 00    	je     8015c2 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8014c6:	89 d8                	mov    %ebx,%eax
  8014c8:	c1 e8 0c             	shr    $0xc,%eax
  8014cb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8014d2:	f6 c2 01             	test   $0x1,%dl
  8014d5:	0f 84 e7 00 00 00    	je     8015c2 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8014db:	89 c6                	mov    %eax,%esi
  8014dd:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8014e0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e7:	f6 c6 04             	test   $0x4,%dh
  8014ea:	74 39                	je     801525 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8014ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014fb:	50                   	push   %eax
  8014fc:	56                   	push   %esi
  8014fd:	57                   	push   %edi
  8014fe:	56                   	push   %esi
  8014ff:	6a 00                	push   $0x0
  801501:	e8 b8 fb ff ff       	call   8010be <sys_page_map>
		if (r < 0) {
  801506:	83 c4 20             	add    $0x20,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	0f 89 b1 00 00 00    	jns    8015c2 <fork+0x191>
		    	panic("sys page map fault %e");
  801511:	83 ec 04             	sub    $0x4,%esp
  801514:	68 3e 2c 80 00       	push   $0x802c3e
  801519:	6a 54                	push   $0x54
  80151b:	68 0c 2c 80 00       	push   $0x802c0c
  801520:	e8 f5 f0 ff ff       	call   80061a <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801525:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80152c:	f6 c2 02             	test   $0x2,%dl
  80152f:	75 0c                	jne    80153d <fork+0x10c>
  801531:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801538:	f6 c4 08             	test   $0x8,%ah
  80153b:	74 5b                	je     801598 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80153d:	83 ec 0c             	sub    $0xc,%esp
  801540:	68 05 08 00 00       	push   $0x805
  801545:	56                   	push   %esi
  801546:	57                   	push   %edi
  801547:	56                   	push   %esi
  801548:	6a 00                	push   $0x0
  80154a:	e8 6f fb ff ff       	call   8010be <sys_page_map>
		if (r < 0) {
  80154f:	83 c4 20             	add    $0x20,%esp
  801552:	85 c0                	test   %eax,%eax
  801554:	79 14                	jns    80156a <fork+0x139>
		    	panic("sys page map fault %e");
  801556:	83 ec 04             	sub    $0x4,%esp
  801559:	68 3e 2c 80 00       	push   $0x802c3e
  80155e:	6a 5b                	push   $0x5b
  801560:	68 0c 2c 80 00       	push   $0x802c0c
  801565:	e8 b0 f0 ff ff       	call   80061a <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	68 05 08 00 00       	push   $0x805
  801572:	56                   	push   %esi
  801573:	6a 00                	push   $0x0
  801575:	56                   	push   %esi
  801576:	6a 00                	push   $0x0
  801578:	e8 41 fb ff ff       	call   8010be <sys_page_map>
		if (r < 0) {
  80157d:	83 c4 20             	add    $0x20,%esp
  801580:	85 c0                	test   %eax,%eax
  801582:	79 3e                	jns    8015c2 <fork+0x191>
		    	panic("sys page map fault %e");
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	68 3e 2c 80 00       	push   $0x802c3e
  80158c:	6a 5f                	push   $0x5f
  80158e:	68 0c 2c 80 00       	push   $0x802c0c
  801593:	e8 82 f0 ff ff       	call   80061a <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801598:	83 ec 0c             	sub    $0xc,%esp
  80159b:	6a 05                	push   $0x5
  80159d:	56                   	push   %esi
  80159e:	57                   	push   %edi
  80159f:	56                   	push   %esi
  8015a0:	6a 00                	push   $0x0
  8015a2:	e8 17 fb ff ff       	call   8010be <sys_page_map>
		if (r < 0) {
  8015a7:	83 c4 20             	add    $0x20,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	79 14                	jns    8015c2 <fork+0x191>
		    	panic("sys page map fault %e");
  8015ae:	83 ec 04             	sub    $0x4,%esp
  8015b1:	68 3e 2c 80 00       	push   $0x802c3e
  8015b6:	6a 64                	push   $0x64
  8015b8:	68 0c 2c 80 00       	push   $0x802c0c
  8015bd:	e8 58 f0 ff ff       	call   80061a <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8015c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015c8:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8015ce:	0f 85 de fe ff ff    	jne    8014b2 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8015d4:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8015d9:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	50                   	push   %eax
  8015e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e6:	57                   	push   %edi
  8015e7:	e8 da fb ff ff       	call   8011c6 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8015ec:	83 c4 08             	add    $0x8,%esp
  8015ef:	6a 02                	push   $0x2
  8015f1:	57                   	push   %edi
  8015f2:	e8 4b fb ff ff       	call   801142 <sys_env_set_status>
	
	return envid;
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8015fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ff:	5b                   	pop    %ebx
  801600:	5e                   	pop    %esi
  801601:	5f                   	pop    %edi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    

00801604 <sfork>:

envid_t
sfork(void)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
	return 0;
}
  801607:	b8 00 00 00 00       	mov    $0x0,%eax
  80160c:	5d                   	pop    %ebp
  80160d:	c3                   	ret    

0080160e <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	56                   	push   %esi
  801612:	53                   	push   %ebx
  801613:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  801616:	89 1d b8 40 80 00    	mov    %ebx,0x8040b8
	cprintf("in fork.c thread create. func: %x\n", func);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	53                   	push   %ebx
  801620:	68 54 2c 80 00       	push   $0x802c54
  801625:	e8 c9 f0 ff ff       	call   8006f3 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80162a:	c7 04 24 e0 05 80 00 	movl   $0x8005e0,(%esp)
  801631:	e8 36 fc ff ff       	call   80126c <sys_thread_create>
  801636:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801638:	83 c4 08             	add    $0x8,%esp
  80163b:	53                   	push   %ebx
  80163c:	68 54 2c 80 00       	push   $0x802c54
  801641:	e8 ad f0 ff ff       	call   8006f3 <cprintf>
	return id;
}
  801646:	89 f0                	mov    %esi,%eax
  801648:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  801655:	ff 75 08             	pushl  0x8(%ebp)
  801658:	e8 2f fc ff ff       	call   80128c <sys_thread_free>
}
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  801668:	ff 75 08             	pushl  0x8(%ebp)
  80166b:	e8 3c fc ff ff       	call   8012ac <sys_thread_join>
}
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	05 00 00 00 30       	add    $0x30000000,%eax
  801680:	c1 e8 0c             	shr    $0xc,%eax
}
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    

00801685 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801688:	8b 45 08             	mov    0x8(%ebp),%eax
  80168b:	05 00 00 00 30       	add    $0x30000000,%eax
  801690:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801695:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	c1 ea 16             	shr    $0x16,%edx
  8016ac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016b3:	f6 c2 01             	test   $0x1,%dl
  8016b6:	74 11                	je     8016c9 <fd_alloc+0x2d>
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	c1 ea 0c             	shr    $0xc,%edx
  8016bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016c4:	f6 c2 01             	test   $0x1,%dl
  8016c7:	75 09                	jne    8016d2 <fd_alloc+0x36>
			*fd_store = fd;
  8016c9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8016cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d0:	eb 17                	jmp    8016e9 <fd_alloc+0x4d>
  8016d2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016d7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016dc:	75 c9                	jne    8016a7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016de:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8016e4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016f1:	83 f8 1f             	cmp    $0x1f,%eax
  8016f4:	77 36                	ja     80172c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016f6:	c1 e0 0c             	shl    $0xc,%eax
  8016f9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016fe:	89 c2                	mov    %eax,%edx
  801700:	c1 ea 16             	shr    $0x16,%edx
  801703:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80170a:	f6 c2 01             	test   $0x1,%dl
  80170d:	74 24                	je     801733 <fd_lookup+0x48>
  80170f:	89 c2                	mov    %eax,%edx
  801711:	c1 ea 0c             	shr    $0xc,%edx
  801714:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80171b:	f6 c2 01             	test   $0x1,%dl
  80171e:	74 1a                	je     80173a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801720:	8b 55 0c             	mov    0xc(%ebp),%edx
  801723:	89 02                	mov    %eax,(%edx)
	return 0;
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
  80172a:	eb 13                	jmp    80173f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80172c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801731:	eb 0c                	jmp    80173f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801733:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801738:	eb 05                	jmp    80173f <fd_lookup+0x54>
  80173a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    

00801741 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	83 ec 08             	sub    $0x8,%esp
  801747:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80174a:	ba f8 2c 80 00       	mov    $0x802cf8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80174f:	eb 13                	jmp    801764 <dev_lookup+0x23>
  801751:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801754:	39 08                	cmp    %ecx,(%eax)
  801756:	75 0c                	jne    801764 <dev_lookup+0x23>
			*dev = devtab[i];
  801758:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80175d:	b8 00 00 00 00       	mov    $0x0,%eax
  801762:	eb 31                	jmp    801795 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801764:	8b 02                	mov    (%edx),%eax
  801766:	85 c0                	test   %eax,%eax
  801768:	75 e7                	jne    801751 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80176a:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80176f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801775:	83 ec 04             	sub    $0x4,%esp
  801778:	51                   	push   %ecx
  801779:	50                   	push   %eax
  80177a:	68 78 2c 80 00       	push   $0x802c78
  80177f:	e8 6f ef ff ff       	call   8006f3 <cprintf>
	*dev = 0;
  801784:	8b 45 0c             	mov    0xc(%ebp),%eax
  801787:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801795:	c9                   	leave  
  801796:	c3                   	ret    

00801797 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	56                   	push   %esi
  80179b:	53                   	push   %ebx
  80179c:	83 ec 10             	sub    $0x10,%esp
  80179f:	8b 75 08             	mov    0x8(%ebp),%esi
  8017a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a8:	50                   	push   %eax
  8017a9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8017af:	c1 e8 0c             	shr    $0xc,%eax
  8017b2:	50                   	push   %eax
  8017b3:	e8 33 ff ff ff       	call   8016eb <fd_lookup>
  8017b8:	83 c4 08             	add    $0x8,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 05                	js     8017c4 <fd_close+0x2d>
	    || fd != fd2)
  8017bf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8017c2:	74 0c                	je     8017d0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8017c4:	84 db                	test   %bl,%bl
  8017c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cb:	0f 44 c2             	cmove  %edx,%eax
  8017ce:	eb 41                	jmp    801811 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	ff 36                	pushl  (%esi)
  8017d9:	e8 63 ff ff ff       	call   801741 <dev_lookup>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 1a                	js     801801 <fd_close+0x6a>
		if (dev->dev_close)
  8017e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ea:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8017ed:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	74 0b                	je     801801 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8017f6:	83 ec 0c             	sub    $0xc,%esp
  8017f9:	56                   	push   %esi
  8017fa:	ff d0                	call   *%eax
  8017fc:	89 c3                	mov    %eax,%ebx
  8017fe:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801801:	83 ec 08             	sub    $0x8,%esp
  801804:	56                   	push   %esi
  801805:	6a 00                	push   $0x0
  801807:	e8 f4 f8 ff ff       	call   801100 <sys_page_unmap>
	return r;
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	89 d8                	mov    %ebx,%eax
}
  801811:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801814:	5b                   	pop    %ebx
  801815:	5e                   	pop    %esi
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80181e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801821:	50                   	push   %eax
  801822:	ff 75 08             	pushl  0x8(%ebp)
  801825:	e8 c1 fe ff ff       	call   8016eb <fd_lookup>
  80182a:	83 c4 08             	add    $0x8,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	78 10                	js     801841 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	6a 01                	push   $0x1
  801836:	ff 75 f4             	pushl  -0xc(%ebp)
  801839:	e8 59 ff ff ff       	call   801797 <fd_close>
  80183e:	83 c4 10             	add    $0x10,%esp
}
  801841:	c9                   	leave  
  801842:	c3                   	ret    

00801843 <close_all>:

void
close_all(void)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	53                   	push   %ebx
  801847:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80184a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80184f:	83 ec 0c             	sub    $0xc,%esp
  801852:	53                   	push   %ebx
  801853:	e8 c0 ff ff ff       	call   801818 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801858:	83 c3 01             	add    $0x1,%ebx
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	83 fb 20             	cmp    $0x20,%ebx
  801861:	75 ec                	jne    80184f <close_all+0xc>
		close(i);
}
  801863:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	57                   	push   %edi
  80186c:	56                   	push   %esi
  80186d:	53                   	push   %ebx
  80186e:	83 ec 2c             	sub    $0x2c,%esp
  801871:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801874:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801877:	50                   	push   %eax
  801878:	ff 75 08             	pushl  0x8(%ebp)
  80187b:	e8 6b fe ff ff       	call   8016eb <fd_lookup>
  801880:	83 c4 08             	add    $0x8,%esp
  801883:	85 c0                	test   %eax,%eax
  801885:	0f 88 c1 00 00 00    	js     80194c <dup+0xe4>
		return r;
	close(newfdnum);
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	56                   	push   %esi
  80188f:	e8 84 ff ff ff       	call   801818 <close>

	newfd = INDEX2FD(newfdnum);
  801894:	89 f3                	mov    %esi,%ebx
  801896:	c1 e3 0c             	shl    $0xc,%ebx
  801899:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80189f:	83 c4 04             	add    $0x4,%esp
  8018a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018a5:	e8 db fd ff ff       	call   801685 <fd2data>
  8018aa:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8018ac:	89 1c 24             	mov    %ebx,(%esp)
  8018af:	e8 d1 fd ff ff       	call   801685 <fd2data>
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8018ba:	89 f8                	mov    %edi,%eax
  8018bc:	c1 e8 16             	shr    $0x16,%eax
  8018bf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018c6:	a8 01                	test   $0x1,%al
  8018c8:	74 37                	je     801901 <dup+0x99>
  8018ca:	89 f8                	mov    %edi,%eax
  8018cc:	c1 e8 0c             	shr    $0xc,%eax
  8018cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018d6:	f6 c2 01             	test   $0x1,%dl
  8018d9:	74 26                	je     801901 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8018ea:	50                   	push   %eax
  8018eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8018ee:	6a 00                	push   $0x0
  8018f0:	57                   	push   %edi
  8018f1:	6a 00                	push   $0x0
  8018f3:	e8 c6 f7 ff ff       	call   8010be <sys_page_map>
  8018f8:	89 c7                	mov    %eax,%edi
  8018fa:	83 c4 20             	add    $0x20,%esp
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	78 2e                	js     80192f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801901:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801904:	89 d0                	mov    %edx,%eax
  801906:	c1 e8 0c             	shr    $0xc,%eax
  801909:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801910:	83 ec 0c             	sub    $0xc,%esp
  801913:	25 07 0e 00 00       	and    $0xe07,%eax
  801918:	50                   	push   %eax
  801919:	53                   	push   %ebx
  80191a:	6a 00                	push   $0x0
  80191c:	52                   	push   %edx
  80191d:	6a 00                	push   $0x0
  80191f:	e8 9a f7 ff ff       	call   8010be <sys_page_map>
  801924:	89 c7                	mov    %eax,%edi
  801926:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801929:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80192b:	85 ff                	test   %edi,%edi
  80192d:	79 1d                	jns    80194c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80192f:	83 ec 08             	sub    $0x8,%esp
  801932:	53                   	push   %ebx
  801933:	6a 00                	push   $0x0
  801935:	e8 c6 f7 ff ff       	call   801100 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80193a:	83 c4 08             	add    $0x8,%esp
  80193d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801940:	6a 00                	push   $0x0
  801942:	e8 b9 f7 ff ff       	call   801100 <sys_page_unmap>
	return r;
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	89 f8                	mov    %edi,%eax
}
  80194c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5f                   	pop    %edi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	53                   	push   %ebx
  801958:	83 ec 14             	sub    $0x14,%esp
  80195b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	53                   	push   %ebx
  801963:	e8 83 fd ff ff       	call   8016eb <fd_lookup>
  801968:	83 c4 08             	add    $0x8,%esp
  80196b:	89 c2                	mov    %eax,%edx
  80196d:	85 c0                	test   %eax,%eax
  80196f:	78 70                	js     8019e1 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801977:	50                   	push   %eax
  801978:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197b:	ff 30                	pushl  (%eax)
  80197d:	e8 bf fd ff ff       	call   801741 <dev_lookup>
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	85 c0                	test   %eax,%eax
  801987:	78 4f                	js     8019d8 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801989:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80198c:	8b 42 08             	mov    0x8(%edx),%eax
  80198f:	83 e0 03             	and    $0x3,%eax
  801992:	83 f8 01             	cmp    $0x1,%eax
  801995:	75 24                	jne    8019bb <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801997:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80199c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8019a2:	83 ec 04             	sub    $0x4,%esp
  8019a5:	53                   	push   %ebx
  8019a6:	50                   	push   %eax
  8019a7:	68 bc 2c 80 00       	push   $0x802cbc
  8019ac:	e8 42 ed ff ff       	call   8006f3 <cprintf>
		return -E_INVAL;
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8019b9:	eb 26                	jmp    8019e1 <read+0x8d>
	}
	if (!dev->dev_read)
  8019bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019be:	8b 40 08             	mov    0x8(%eax),%eax
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	74 17                	je     8019dc <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8019c5:	83 ec 04             	sub    $0x4,%esp
  8019c8:	ff 75 10             	pushl  0x10(%ebp)
  8019cb:	ff 75 0c             	pushl  0xc(%ebp)
  8019ce:	52                   	push   %edx
  8019cf:	ff d0                	call   *%eax
  8019d1:	89 c2                	mov    %eax,%edx
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	eb 09                	jmp    8019e1 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d8:	89 c2                	mov    %eax,%edx
  8019da:	eb 05                	jmp    8019e1 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8019e1:	89 d0                	mov    %edx,%eax
  8019e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	57                   	push   %edi
  8019ec:	56                   	push   %esi
  8019ed:	53                   	push   %ebx
  8019ee:	83 ec 0c             	sub    $0xc,%esp
  8019f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019fc:	eb 21                	jmp    801a1f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019fe:	83 ec 04             	sub    $0x4,%esp
  801a01:	89 f0                	mov    %esi,%eax
  801a03:	29 d8                	sub    %ebx,%eax
  801a05:	50                   	push   %eax
  801a06:	89 d8                	mov    %ebx,%eax
  801a08:	03 45 0c             	add    0xc(%ebp),%eax
  801a0b:	50                   	push   %eax
  801a0c:	57                   	push   %edi
  801a0d:	e8 42 ff ff ff       	call   801954 <read>
		if (m < 0)
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	85 c0                	test   %eax,%eax
  801a17:	78 10                	js     801a29 <readn+0x41>
			return m;
		if (m == 0)
  801a19:	85 c0                	test   %eax,%eax
  801a1b:	74 0a                	je     801a27 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a1d:	01 c3                	add    %eax,%ebx
  801a1f:	39 f3                	cmp    %esi,%ebx
  801a21:	72 db                	jb     8019fe <readn+0x16>
  801a23:	89 d8                	mov    %ebx,%eax
  801a25:	eb 02                	jmp    801a29 <readn+0x41>
  801a27:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5f                   	pop    %edi
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    

00801a31 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	53                   	push   %ebx
  801a35:	83 ec 14             	sub    $0x14,%esp
  801a38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a3e:	50                   	push   %eax
  801a3f:	53                   	push   %ebx
  801a40:	e8 a6 fc ff ff       	call   8016eb <fd_lookup>
  801a45:	83 c4 08             	add    $0x8,%esp
  801a48:	89 c2                	mov    %eax,%edx
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	78 6b                	js     801ab9 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a4e:	83 ec 08             	sub    $0x8,%esp
  801a51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a54:	50                   	push   %eax
  801a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a58:	ff 30                	pushl  (%eax)
  801a5a:	e8 e2 fc ff ff       	call   801741 <dev_lookup>
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	85 c0                	test   %eax,%eax
  801a64:	78 4a                	js     801ab0 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a69:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a6d:	75 24                	jne    801a93 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a6f:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801a74:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801a7a:	83 ec 04             	sub    $0x4,%esp
  801a7d:	53                   	push   %ebx
  801a7e:	50                   	push   %eax
  801a7f:	68 d8 2c 80 00       	push   $0x802cd8
  801a84:	e8 6a ec ff ff       	call   8006f3 <cprintf>
		return -E_INVAL;
  801a89:	83 c4 10             	add    $0x10,%esp
  801a8c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a91:	eb 26                	jmp    801ab9 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a93:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a96:	8b 52 0c             	mov    0xc(%edx),%edx
  801a99:	85 d2                	test   %edx,%edx
  801a9b:	74 17                	je     801ab4 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a9d:	83 ec 04             	sub    $0x4,%esp
  801aa0:	ff 75 10             	pushl  0x10(%ebp)
  801aa3:	ff 75 0c             	pushl  0xc(%ebp)
  801aa6:	50                   	push   %eax
  801aa7:	ff d2                	call   *%edx
  801aa9:	89 c2                	mov    %eax,%edx
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	eb 09                	jmp    801ab9 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab0:	89 c2                	mov    %eax,%edx
  801ab2:	eb 05                	jmp    801ab9 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801ab4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801ab9:	89 d0                	mov    %edx,%eax
  801abb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <seek>:

int
seek(int fdnum, off_t offset)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ac6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ac9:	50                   	push   %eax
  801aca:	ff 75 08             	pushl  0x8(%ebp)
  801acd:	e8 19 fc ff ff       	call   8016eb <fd_lookup>
  801ad2:	83 c4 08             	add    $0x8,%esp
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	78 0e                	js     801ae7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801ad9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801adc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801adf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    

00801ae9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	53                   	push   %ebx
  801aed:	83 ec 14             	sub    $0x14,%esp
  801af0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801af3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801af6:	50                   	push   %eax
  801af7:	53                   	push   %ebx
  801af8:	e8 ee fb ff ff       	call   8016eb <fd_lookup>
  801afd:	83 c4 08             	add    $0x8,%esp
  801b00:	89 c2                	mov    %eax,%edx
  801b02:	85 c0                	test   %eax,%eax
  801b04:	78 68                	js     801b6e <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b06:	83 ec 08             	sub    $0x8,%esp
  801b09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b0c:	50                   	push   %eax
  801b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b10:	ff 30                	pushl  (%eax)
  801b12:	e8 2a fc ff ff       	call   801741 <dev_lookup>
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 47                	js     801b65 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b21:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b25:	75 24                	jne    801b4b <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b27:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b2c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	53                   	push   %ebx
  801b36:	50                   	push   %eax
  801b37:	68 98 2c 80 00       	push   $0x802c98
  801b3c:	e8 b2 eb ff ff       	call   8006f3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b41:	83 c4 10             	add    $0x10,%esp
  801b44:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801b49:	eb 23                	jmp    801b6e <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801b4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b4e:	8b 52 18             	mov    0x18(%edx),%edx
  801b51:	85 d2                	test   %edx,%edx
  801b53:	74 14                	je     801b69 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b55:	83 ec 08             	sub    $0x8,%esp
  801b58:	ff 75 0c             	pushl  0xc(%ebp)
  801b5b:	50                   	push   %eax
  801b5c:	ff d2                	call   *%edx
  801b5e:	89 c2                	mov    %eax,%edx
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	eb 09                	jmp    801b6e <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b65:	89 c2                	mov    %eax,%edx
  801b67:	eb 05                	jmp    801b6e <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b69:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801b6e:	89 d0                	mov    %edx,%eax
  801b70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	53                   	push   %ebx
  801b79:	83 ec 14             	sub    $0x14,%esp
  801b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b82:	50                   	push   %eax
  801b83:	ff 75 08             	pushl  0x8(%ebp)
  801b86:	e8 60 fb ff ff       	call   8016eb <fd_lookup>
  801b8b:	83 c4 08             	add    $0x8,%esp
  801b8e:	89 c2                	mov    %eax,%edx
  801b90:	85 c0                	test   %eax,%eax
  801b92:	78 58                	js     801bec <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b94:	83 ec 08             	sub    $0x8,%esp
  801b97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9a:	50                   	push   %eax
  801b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b9e:	ff 30                	pushl  (%eax)
  801ba0:	e8 9c fb ff ff       	call   801741 <dev_lookup>
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	78 37                	js     801be3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801baf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801bb3:	74 32                	je     801be7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801bb5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801bb8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801bbf:	00 00 00 
	stat->st_isdir = 0;
  801bc2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bc9:	00 00 00 
	stat->st_dev = dev;
  801bcc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801bd2:	83 ec 08             	sub    $0x8,%esp
  801bd5:	53                   	push   %ebx
  801bd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd9:	ff 50 14             	call   *0x14(%eax)
  801bdc:	89 c2                	mov    %eax,%edx
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	eb 09                	jmp    801bec <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801be3:	89 c2                	mov    %eax,%edx
  801be5:	eb 05                	jmp    801bec <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801be7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bec:	89 d0                	mov    %edx,%eax
  801bee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    

00801bf3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bf8:	83 ec 08             	sub    $0x8,%esp
  801bfb:	6a 00                	push   $0x0
  801bfd:	ff 75 08             	pushl  0x8(%ebp)
  801c00:	e8 e3 01 00 00       	call   801de8 <open>
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	85 c0                	test   %eax,%eax
  801c0c:	78 1b                	js     801c29 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801c0e:	83 ec 08             	sub    $0x8,%esp
  801c11:	ff 75 0c             	pushl  0xc(%ebp)
  801c14:	50                   	push   %eax
  801c15:	e8 5b ff ff ff       	call   801b75 <fstat>
  801c1a:	89 c6                	mov    %eax,%esi
	close(fd);
  801c1c:	89 1c 24             	mov    %ebx,(%esp)
  801c1f:	e8 f4 fb ff ff       	call   801818 <close>
	return r;
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	89 f0                	mov    %esi,%eax
}
  801c29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2c:	5b                   	pop    %ebx
  801c2d:	5e                   	pop    %esi
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    

00801c30 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	89 c6                	mov    %eax,%esi
  801c37:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801c39:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801c40:	75 12                	jne    801c54 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c42:	83 ec 0c             	sub    $0xc,%esp
  801c45:	6a 01                	push   $0x1
  801c47:	e8 05 08 00 00       	call   802451 <ipc_find_env>
  801c4c:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801c51:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c54:	6a 07                	push   $0x7
  801c56:	68 00 50 80 00       	push   $0x805000
  801c5b:	56                   	push   %esi
  801c5c:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801c62:	e8 88 07 00 00       	call   8023ef <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c67:	83 c4 0c             	add    $0xc,%esp
  801c6a:	6a 00                	push   $0x0
  801c6c:	53                   	push   %ebx
  801c6d:	6a 00                	push   $0x0
  801c6f:	e8 00 07 00 00       	call   802374 <ipc_recv>
}
  801c74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c77:	5b                   	pop    %ebx
  801c78:	5e                   	pop    %esi
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c81:	8b 45 08             	mov    0x8(%ebp),%eax
  801c84:	8b 40 0c             	mov    0xc(%eax),%eax
  801c87:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c94:	ba 00 00 00 00       	mov    $0x0,%edx
  801c99:	b8 02 00 00 00       	mov    $0x2,%eax
  801c9e:	e8 8d ff ff ff       	call   801c30 <fsipc>
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cab:	8b 45 08             	mov    0x8(%ebp),%eax
  801cae:	8b 40 0c             	mov    0xc(%eax),%eax
  801cb1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbb:	b8 06 00 00 00       	mov    $0x6,%eax
  801cc0:	e8 6b ff ff ff       	call   801c30 <fsipc>
}
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	53                   	push   %ebx
  801ccb:	83 ec 04             	sub    $0x4,%esp
  801cce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd4:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cdc:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce1:	b8 05 00 00 00       	mov    $0x5,%eax
  801ce6:	e8 45 ff ff ff       	call   801c30 <fsipc>
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	78 2c                	js     801d1b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cef:	83 ec 08             	sub    $0x8,%esp
  801cf2:	68 00 50 80 00       	push   $0x805000
  801cf7:	53                   	push   %ebx
  801cf8:	e8 7b ef ff ff       	call   800c78 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cfd:	a1 80 50 80 00       	mov    0x805080,%eax
  801d02:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d08:	a1 84 50 80 00       	mov    0x805084,%eax
  801d0d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d1e:	c9                   	leave  
  801d1f:	c3                   	ret    

00801d20 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	83 ec 0c             	sub    $0xc,%esp
  801d26:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d29:	8b 55 08             	mov    0x8(%ebp),%edx
  801d2c:	8b 52 0c             	mov    0xc(%edx),%edx
  801d2f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801d35:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d3a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801d3f:	0f 47 c2             	cmova  %edx,%eax
  801d42:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801d47:	50                   	push   %eax
  801d48:	ff 75 0c             	pushl  0xc(%ebp)
  801d4b:	68 08 50 80 00       	push   $0x805008
  801d50:	e8 b5 f0 ff ff       	call   800e0a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801d55:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5a:	b8 04 00 00 00       	mov    $0x4,%eax
  801d5f:	e8 cc fe ff ff       	call   801c30 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    

00801d66 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	56                   	push   %esi
  801d6a:	53                   	push   %ebx
  801d6b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d71:	8b 40 0c             	mov    0xc(%eax),%eax
  801d74:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d79:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d84:	b8 03 00 00 00       	mov    $0x3,%eax
  801d89:	e8 a2 fe ff ff       	call   801c30 <fsipc>
  801d8e:	89 c3                	mov    %eax,%ebx
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 4b                	js     801ddf <devfile_read+0x79>
		return r;
	assert(r <= n);
  801d94:	39 c6                	cmp    %eax,%esi
  801d96:	73 16                	jae    801dae <devfile_read+0x48>
  801d98:	68 08 2d 80 00       	push   $0x802d08
  801d9d:	68 0f 2d 80 00       	push   $0x802d0f
  801da2:	6a 7c                	push   $0x7c
  801da4:	68 24 2d 80 00       	push   $0x802d24
  801da9:	e8 6c e8 ff ff       	call   80061a <_panic>
	assert(r <= PGSIZE);
  801dae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801db3:	7e 16                	jle    801dcb <devfile_read+0x65>
  801db5:	68 2f 2d 80 00       	push   $0x802d2f
  801dba:	68 0f 2d 80 00       	push   $0x802d0f
  801dbf:	6a 7d                	push   $0x7d
  801dc1:	68 24 2d 80 00       	push   $0x802d24
  801dc6:	e8 4f e8 ff ff       	call   80061a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801dcb:	83 ec 04             	sub    $0x4,%esp
  801dce:	50                   	push   %eax
  801dcf:	68 00 50 80 00       	push   $0x805000
  801dd4:	ff 75 0c             	pushl  0xc(%ebp)
  801dd7:	e8 2e f0 ff ff       	call   800e0a <memmove>
	return r;
  801ddc:	83 c4 10             	add    $0x10,%esp
}
  801ddf:	89 d8                	mov    %ebx,%eax
  801de1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    

00801de8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	53                   	push   %ebx
  801dec:	83 ec 20             	sub    $0x20,%esp
  801def:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801df2:	53                   	push   %ebx
  801df3:	e8 47 ee ff ff       	call   800c3f <strlen>
  801df8:	83 c4 10             	add    $0x10,%esp
  801dfb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e00:	7f 67                	jg     801e69 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e02:	83 ec 0c             	sub    $0xc,%esp
  801e05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e08:	50                   	push   %eax
  801e09:	e8 8e f8 ff ff       	call   80169c <fd_alloc>
  801e0e:	83 c4 10             	add    $0x10,%esp
		return r;
  801e11:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e13:	85 c0                	test   %eax,%eax
  801e15:	78 57                	js     801e6e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e17:	83 ec 08             	sub    $0x8,%esp
  801e1a:	53                   	push   %ebx
  801e1b:	68 00 50 80 00       	push   $0x805000
  801e20:	e8 53 ee ff ff       	call   800c78 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e28:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e30:	b8 01 00 00 00       	mov    $0x1,%eax
  801e35:	e8 f6 fd ff ff       	call   801c30 <fsipc>
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	83 c4 10             	add    $0x10,%esp
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	79 14                	jns    801e57 <open+0x6f>
		fd_close(fd, 0);
  801e43:	83 ec 08             	sub    $0x8,%esp
  801e46:	6a 00                	push   $0x0
  801e48:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4b:	e8 47 f9 ff ff       	call   801797 <fd_close>
		return r;
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	89 da                	mov    %ebx,%edx
  801e55:	eb 17                	jmp    801e6e <open+0x86>
	}

	return fd2num(fd);
  801e57:	83 ec 0c             	sub    $0xc,%esp
  801e5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5d:	e8 13 f8 ff ff       	call   801675 <fd2num>
  801e62:	89 c2                	mov    %eax,%edx
  801e64:	83 c4 10             	add    $0x10,%esp
  801e67:	eb 05                	jmp    801e6e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e69:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e6e:	89 d0                	mov    %edx,%eax
  801e70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e73:	c9                   	leave  
  801e74:	c3                   	ret    

00801e75 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e75:	55                   	push   %ebp
  801e76:	89 e5                	mov    %esp,%ebp
  801e78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e80:	b8 08 00 00 00       	mov    $0x8,%eax
  801e85:	e8 a6 fd ff ff       	call   801c30 <fsipc>
}
  801e8a:	c9                   	leave  
  801e8b:	c3                   	ret    

00801e8c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	56                   	push   %esi
  801e90:	53                   	push   %ebx
  801e91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e94:	83 ec 0c             	sub    $0xc,%esp
  801e97:	ff 75 08             	pushl  0x8(%ebp)
  801e9a:	e8 e6 f7 ff ff       	call   801685 <fd2data>
  801e9f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ea1:	83 c4 08             	add    $0x8,%esp
  801ea4:	68 3b 2d 80 00       	push   $0x802d3b
  801ea9:	53                   	push   %ebx
  801eaa:	e8 c9 ed ff ff       	call   800c78 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801eaf:	8b 46 04             	mov    0x4(%esi),%eax
  801eb2:	2b 06                	sub    (%esi),%eax
  801eb4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801eba:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ec1:	00 00 00 
	stat->st_dev = &devpipe;
  801ec4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ecb:	30 80 00 
	return 0;
}
  801ece:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed6:	5b                   	pop    %ebx
  801ed7:	5e                   	pop    %esi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    

00801eda <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	53                   	push   %ebx
  801ede:	83 ec 0c             	sub    $0xc,%esp
  801ee1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ee4:	53                   	push   %ebx
  801ee5:	6a 00                	push   $0x0
  801ee7:	e8 14 f2 ff ff       	call   801100 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801eec:	89 1c 24             	mov    %ebx,(%esp)
  801eef:	e8 91 f7 ff ff       	call   801685 <fd2data>
  801ef4:	83 c4 08             	add    $0x8,%esp
  801ef7:	50                   	push   %eax
  801ef8:	6a 00                	push   $0x0
  801efa:	e8 01 f2 ff ff       	call   801100 <sys_page_unmap>
}
  801eff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f02:	c9                   	leave  
  801f03:	c3                   	ret    

00801f04 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	57                   	push   %edi
  801f08:	56                   	push   %esi
  801f09:	53                   	push   %ebx
  801f0a:	83 ec 1c             	sub    $0x1c,%esp
  801f0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f10:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f12:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801f17:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f1d:	83 ec 0c             	sub    $0xc,%esp
  801f20:	ff 75 e0             	pushl  -0x20(%ebp)
  801f23:	e8 6e 05 00 00       	call   802496 <pageref>
  801f28:	89 c3                	mov    %eax,%ebx
  801f2a:	89 3c 24             	mov    %edi,(%esp)
  801f2d:	e8 64 05 00 00       	call   802496 <pageref>
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	39 c3                	cmp    %eax,%ebx
  801f37:	0f 94 c1             	sete   %cl
  801f3a:	0f b6 c9             	movzbl %cl,%ecx
  801f3d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f40:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801f46:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801f4c:	39 ce                	cmp    %ecx,%esi
  801f4e:	74 1e                	je     801f6e <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801f50:	39 c3                	cmp    %eax,%ebx
  801f52:	75 be                	jne    801f12 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f54:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801f5a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f5d:	50                   	push   %eax
  801f5e:	56                   	push   %esi
  801f5f:	68 42 2d 80 00       	push   $0x802d42
  801f64:	e8 8a e7 ff ff       	call   8006f3 <cprintf>
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	eb a4                	jmp    801f12 <_pipeisclosed+0xe>
	}
}
  801f6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5f                   	pop    %edi
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    

00801f79 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	57                   	push   %edi
  801f7d:	56                   	push   %esi
  801f7e:	53                   	push   %ebx
  801f7f:	83 ec 28             	sub    $0x28,%esp
  801f82:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f85:	56                   	push   %esi
  801f86:	e8 fa f6 ff ff       	call   801685 <fd2data>
  801f8b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8d:	83 c4 10             	add    $0x10,%esp
  801f90:	bf 00 00 00 00       	mov    $0x0,%edi
  801f95:	eb 4b                	jmp    801fe2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f97:	89 da                	mov    %ebx,%edx
  801f99:	89 f0                	mov    %esi,%eax
  801f9b:	e8 64 ff ff ff       	call   801f04 <_pipeisclosed>
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	75 48                	jne    801fec <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fa4:	e8 b3 f0 ff ff       	call   80105c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fa9:	8b 43 04             	mov    0x4(%ebx),%eax
  801fac:	8b 0b                	mov    (%ebx),%ecx
  801fae:	8d 51 20             	lea    0x20(%ecx),%edx
  801fb1:	39 d0                	cmp    %edx,%eax
  801fb3:	73 e2                	jae    801f97 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fbc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fbf:	89 c2                	mov    %eax,%edx
  801fc1:	c1 fa 1f             	sar    $0x1f,%edx
  801fc4:	89 d1                	mov    %edx,%ecx
  801fc6:	c1 e9 1b             	shr    $0x1b,%ecx
  801fc9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fcc:	83 e2 1f             	and    $0x1f,%edx
  801fcf:	29 ca                	sub    %ecx,%edx
  801fd1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fd5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fd9:	83 c0 01             	add    $0x1,%eax
  801fdc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fdf:	83 c7 01             	add    $0x1,%edi
  801fe2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fe5:	75 c2                	jne    801fa9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fe7:	8b 45 10             	mov    0x10(%ebp),%eax
  801fea:	eb 05                	jmp    801ff1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fec:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ff1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff4:	5b                   	pop    %ebx
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	57                   	push   %edi
  801ffd:	56                   	push   %esi
  801ffe:	53                   	push   %ebx
  801fff:	83 ec 18             	sub    $0x18,%esp
  802002:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802005:	57                   	push   %edi
  802006:	e8 7a f6 ff ff       	call   801685 <fd2data>
  80200b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80200d:	83 c4 10             	add    $0x10,%esp
  802010:	bb 00 00 00 00       	mov    $0x0,%ebx
  802015:	eb 3d                	jmp    802054 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802017:	85 db                	test   %ebx,%ebx
  802019:	74 04                	je     80201f <devpipe_read+0x26>
				return i;
  80201b:	89 d8                	mov    %ebx,%eax
  80201d:	eb 44                	jmp    802063 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80201f:	89 f2                	mov    %esi,%edx
  802021:	89 f8                	mov    %edi,%eax
  802023:	e8 dc fe ff ff       	call   801f04 <_pipeisclosed>
  802028:	85 c0                	test   %eax,%eax
  80202a:	75 32                	jne    80205e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80202c:	e8 2b f0 ff ff       	call   80105c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802031:	8b 06                	mov    (%esi),%eax
  802033:	3b 46 04             	cmp    0x4(%esi),%eax
  802036:	74 df                	je     802017 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802038:	99                   	cltd   
  802039:	c1 ea 1b             	shr    $0x1b,%edx
  80203c:	01 d0                	add    %edx,%eax
  80203e:	83 e0 1f             	and    $0x1f,%eax
  802041:	29 d0                	sub    %edx,%eax
  802043:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802048:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80204b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80204e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802051:	83 c3 01             	add    $0x1,%ebx
  802054:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802057:	75 d8                	jne    802031 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802059:	8b 45 10             	mov    0x10(%ebp),%eax
  80205c:	eb 05                	jmp    802063 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80205e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802063:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802066:	5b                   	pop    %ebx
  802067:	5e                   	pop    %esi
  802068:	5f                   	pop    %edi
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    

0080206b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	56                   	push   %esi
  80206f:	53                   	push   %ebx
  802070:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802073:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802076:	50                   	push   %eax
  802077:	e8 20 f6 ff ff       	call   80169c <fd_alloc>
  80207c:	83 c4 10             	add    $0x10,%esp
  80207f:	89 c2                	mov    %eax,%edx
  802081:	85 c0                	test   %eax,%eax
  802083:	0f 88 2c 01 00 00    	js     8021b5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802089:	83 ec 04             	sub    $0x4,%esp
  80208c:	68 07 04 00 00       	push   $0x407
  802091:	ff 75 f4             	pushl  -0xc(%ebp)
  802094:	6a 00                	push   $0x0
  802096:	e8 e0 ef ff ff       	call   80107b <sys_page_alloc>
  80209b:	83 c4 10             	add    $0x10,%esp
  80209e:	89 c2                	mov    %eax,%edx
  8020a0:	85 c0                	test   %eax,%eax
  8020a2:	0f 88 0d 01 00 00    	js     8021b5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020a8:	83 ec 0c             	sub    $0xc,%esp
  8020ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020ae:	50                   	push   %eax
  8020af:	e8 e8 f5 ff ff       	call   80169c <fd_alloc>
  8020b4:	89 c3                	mov    %eax,%ebx
  8020b6:	83 c4 10             	add    $0x10,%esp
  8020b9:	85 c0                	test   %eax,%eax
  8020bb:	0f 88 e2 00 00 00    	js     8021a3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c1:	83 ec 04             	sub    $0x4,%esp
  8020c4:	68 07 04 00 00       	push   $0x407
  8020c9:	ff 75 f0             	pushl  -0x10(%ebp)
  8020cc:	6a 00                	push   $0x0
  8020ce:	e8 a8 ef ff ff       	call   80107b <sys_page_alloc>
  8020d3:	89 c3                	mov    %eax,%ebx
  8020d5:	83 c4 10             	add    $0x10,%esp
  8020d8:	85 c0                	test   %eax,%eax
  8020da:	0f 88 c3 00 00 00    	js     8021a3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020e0:	83 ec 0c             	sub    $0xc,%esp
  8020e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e6:	e8 9a f5 ff ff       	call   801685 <fd2data>
  8020eb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ed:	83 c4 0c             	add    $0xc,%esp
  8020f0:	68 07 04 00 00       	push   $0x407
  8020f5:	50                   	push   %eax
  8020f6:	6a 00                	push   $0x0
  8020f8:	e8 7e ef ff ff       	call   80107b <sys_page_alloc>
  8020fd:	89 c3                	mov    %eax,%ebx
  8020ff:	83 c4 10             	add    $0x10,%esp
  802102:	85 c0                	test   %eax,%eax
  802104:	0f 88 89 00 00 00    	js     802193 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80210a:	83 ec 0c             	sub    $0xc,%esp
  80210d:	ff 75 f0             	pushl  -0x10(%ebp)
  802110:	e8 70 f5 ff ff       	call   801685 <fd2data>
  802115:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80211c:	50                   	push   %eax
  80211d:	6a 00                	push   $0x0
  80211f:	56                   	push   %esi
  802120:	6a 00                	push   $0x0
  802122:	e8 97 ef ff ff       	call   8010be <sys_page_map>
  802127:	89 c3                	mov    %eax,%ebx
  802129:	83 c4 20             	add    $0x20,%esp
  80212c:	85 c0                	test   %eax,%eax
  80212e:	78 55                	js     802185 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802130:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802136:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802139:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80213b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802145:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80214b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80214e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802150:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802153:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80215a:	83 ec 0c             	sub    $0xc,%esp
  80215d:	ff 75 f4             	pushl  -0xc(%ebp)
  802160:	e8 10 f5 ff ff       	call   801675 <fd2num>
  802165:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802168:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80216a:	83 c4 04             	add    $0x4,%esp
  80216d:	ff 75 f0             	pushl  -0x10(%ebp)
  802170:	e8 00 f5 ff ff       	call   801675 <fd2num>
  802175:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802178:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80217b:	83 c4 10             	add    $0x10,%esp
  80217e:	ba 00 00 00 00       	mov    $0x0,%edx
  802183:	eb 30                	jmp    8021b5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802185:	83 ec 08             	sub    $0x8,%esp
  802188:	56                   	push   %esi
  802189:	6a 00                	push   $0x0
  80218b:	e8 70 ef ff ff       	call   801100 <sys_page_unmap>
  802190:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802193:	83 ec 08             	sub    $0x8,%esp
  802196:	ff 75 f0             	pushl  -0x10(%ebp)
  802199:	6a 00                	push   $0x0
  80219b:	e8 60 ef ff ff       	call   801100 <sys_page_unmap>
  8021a0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021a3:	83 ec 08             	sub    $0x8,%esp
  8021a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a9:	6a 00                	push   $0x0
  8021ab:	e8 50 ef ff ff       	call   801100 <sys_page_unmap>
  8021b0:	83 c4 10             	add    $0x10,%esp
  8021b3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ba:	5b                   	pop    %ebx
  8021bb:	5e                   	pop    %esi
  8021bc:	5d                   	pop    %ebp
  8021bd:	c3                   	ret    

008021be <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021be:	55                   	push   %ebp
  8021bf:	89 e5                	mov    %esp,%ebp
  8021c1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c7:	50                   	push   %eax
  8021c8:	ff 75 08             	pushl  0x8(%ebp)
  8021cb:	e8 1b f5 ff ff       	call   8016eb <fd_lookup>
  8021d0:	83 c4 10             	add    $0x10,%esp
  8021d3:	85 c0                	test   %eax,%eax
  8021d5:	78 18                	js     8021ef <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021d7:	83 ec 0c             	sub    $0xc,%esp
  8021da:	ff 75 f4             	pushl  -0xc(%ebp)
  8021dd:	e8 a3 f4 ff ff       	call   801685 <fd2data>
	return _pipeisclosed(fd, p);
  8021e2:	89 c2                	mov    %eax,%edx
  8021e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e7:	e8 18 fd ff ff       	call   801f04 <_pipeisclosed>
  8021ec:	83 c4 10             	add    $0x10,%esp
}
  8021ef:	c9                   	leave  
  8021f0:	c3                   	ret    

008021f1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f9:	5d                   	pop    %ebp
  8021fa:	c3                   	ret    

008021fb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802201:	68 5a 2d 80 00       	push   $0x802d5a
  802206:	ff 75 0c             	pushl  0xc(%ebp)
  802209:	e8 6a ea ff ff       	call   800c78 <strcpy>
	return 0;
}
  80220e:	b8 00 00 00 00       	mov    $0x0,%eax
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	57                   	push   %edi
  802219:	56                   	push   %esi
  80221a:	53                   	push   %ebx
  80221b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802221:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802226:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80222c:	eb 2d                	jmp    80225b <devcons_write+0x46>
		m = n - tot;
  80222e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802231:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802233:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802236:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80223b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80223e:	83 ec 04             	sub    $0x4,%esp
  802241:	53                   	push   %ebx
  802242:	03 45 0c             	add    0xc(%ebp),%eax
  802245:	50                   	push   %eax
  802246:	57                   	push   %edi
  802247:	e8 be eb ff ff       	call   800e0a <memmove>
		sys_cputs(buf, m);
  80224c:	83 c4 08             	add    $0x8,%esp
  80224f:	53                   	push   %ebx
  802250:	57                   	push   %edi
  802251:	e8 69 ed ff ff       	call   800fbf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802256:	01 de                	add    %ebx,%esi
  802258:	83 c4 10             	add    $0x10,%esp
  80225b:	89 f0                	mov    %esi,%eax
  80225d:	3b 75 10             	cmp    0x10(%ebp),%esi
  802260:	72 cc                	jb     80222e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802265:	5b                   	pop    %ebx
  802266:	5e                   	pop    %esi
  802267:	5f                   	pop    %edi
  802268:	5d                   	pop    %ebp
  802269:	c3                   	ret    

0080226a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	83 ec 08             	sub    $0x8,%esp
  802270:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802275:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802279:	74 2a                	je     8022a5 <devcons_read+0x3b>
  80227b:	eb 05                	jmp    802282 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80227d:	e8 da ed ff ff       	call   80105c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802282:	e8 56 ed ff ff       	call   800fdd <sys_cgetc>
  802287:	85 c0                	test   %eax,%eax
  802289:	74 f2                	je     80227d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80228b:	85 c0                	test   %eax,%eax
  80228d:	78 16                	js     8022a5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80228f:	83 f8 04             	cmp    $0x4,%eax
  802292:	74 0c                	je     8022a0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802294:	8b 55 0c             	mov    0xc(%ebp),%edx
  802297:	88 02                	mov    %al,(%edx)
	return 1;
  802299:	b8 01 00 00 00       	mov    $0x1,%eax
  80229e:	eb 05                	jmp    8022a5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022a0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    

008022a7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022a7:	55                   	push   %ebp
  8022a8:	89 e5                	mov    %esp,%ebp
  8022aa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022b3:	6a 01                	push   $0x1
  8022b5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022b8:	50                   	push   %eax
  8022b9:	e8 01 ed ff ff       	call   800fbf <sys_cputs>
}
  8022be:	83 c4 10             	add    $0x10,%esp
  8022c1:	c9                   	leave  
  8022c2:	c3                   	ret    

008022c3 <getchar>:

int
getchar(void)
{
  8022c3:	55                   	push   %ebp
  8022c4:	89 e5                	mov    %esp,%ebp
  8022c6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022c9:	6a 01                	push   $0x1
  8022cb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ce:	50                   	push   %eax
  8022cf:	6a 00                	push   $0x0
  8022d1:	e8 7e f6 ff ff       	call   801954 <read>
	if (r < 0)
  8022d6:	83 c4 10             	add    $0x10,%esp
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	78 0f                	js     8022ec <getchar+0x29>
		return r;
	if (r < 1)
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	7e 06                	jle    8022e7 <getchar+0x24>
		return -E_EOF;
	return c;
  8022e1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022e5:	eb 05                	jmp    8022ec <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022e7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022ec:	c9                   	leave  
  8022ed:	c3                   	ret    

008022ee <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022ee:	55                   	push   %ebp
  8022ef:	89 e5                	mov    %esp,%ebp
  8022f1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f7:	50                   	push   %eax
  8022f8:	ff 75 08             	pushl  0x8(%ebp)
  8022fb:	e8 eb f3 ff ff       	call   8016eb <fd_lookup>
  802300:	83 c4 10             	add    $0x10,%esp
  802303:	85 c0                	test   %eax,%eax
  802305:	78 11                	js     802318 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802307:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802310:	39 10                	cmp    %edx,(%eax)
  802312:	0f 94 c0             	sete   %al
  802315:	0f b6 c0             	movzbl %al,%eax
}
  802318:	c9                   	leave  
  802319:	c3                   	ret    

0080231a <opencons>:

int
opencons(void)
{
  80231a:	55                   	push   %ebp
  80231b:	89 e5                	mov    %esp,%ebp
  80231d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802323:	50                   	push   %eax
  802324:	e8 73 f3 ff ff       	call   80169c <fd_alloc>
  802329:	83 c4 10             	add    $0x10,%esp
		return r;
  80232c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80232e:	85 c0                	test   %eax,%eax
  802330:	78 3e                	js     802370 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802332:	83 ec 04             	sub    $0x4,%esp
  802335:	68 07 04 00 00       	push   $0x407
  80233a:	ff 75 f4             	pushl  -0xc(%ebp)
  80233d:	6a 00                	push   $0x0
  80233f:	e8 37 ed ff ff       	call   80107b <sys_page_alloc>
  802344:	83 c4 10             	add    $0x10,%esp
		return r;
  802347:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802349:	85 c0                	test   %eax,%eax
  80234b:	78 23                	js     802370 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80234d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802353:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802356:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802362:	83 ec 0c             	sub    $0xc,%esp
  802365:	50                   	push   %eax
  802366:	e8 0a f3 ff ff       	call   801675 <fd2num>
  80236b:	89 c2                	mov    %eax,%edx
  80236d:	83 c4 10             	add    $0x10,%esp
}
  802370:	89 d0                	mov    %edx,%eax
  802372:	c9                   	leave  
  802373:	c3                   	ret    

00802374 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802374:	55                   	push   %ebp
  802375:	89 e5                	mov    %esp,%ebp
  802377:	56                   	push   %esi
  802378:	53                   	push   %ebx
  802379:	8b 75 08             	mov    0x8(%ebp),%esi
  80237c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802382:	85 c0                	test   %eax,%eax
  802384:	75 12                	jne    802398 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802386:	83 ec 0c             	sub    $0xc,%esp
  802389:	68 00 00 c0 ee       	push   $0xeec00000
  80238e:	e8 98 ee ff ff       	call   80122b <sys_ipc_recv>
  802393:	83 c4 10             	add    $0x10,%esp
  802396:	eb 0c                	jmp    8023a4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802398:	83 ec 0c             	sub    $0xc,%esp
  80239b:	50                   	push   %eax
  80239c:	e8 8a ee ff ff       	call   80122b <sys_ipc_recv>
  8023a1:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8023a4:	85 f6                	test   %esi,%esi
  8023a6:	0f 95 c1             	setne  %cl
  8023a9:	85 db                	test   %ebx,%ebx
  8023ab:	0f 95 c2             	setne  %dl
  8023ae:	84 d1                	test   %dl,%cl
  8023b0:	74 09                	je     8023bb <ipc_recv+0x47>
  8023b2:	89 c2                	mov    %eax,%edx
  8023b4:	c1 ea 1f             	shr    $0x1f,%edx
  8023b7:	84 d2                	test   %dl,%dl
  8023b9:	75 2d                	jne    8023e8 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8023bb:	85 f6                	test   %esi,%esi
  8023bd:	74 0d                	je     8023cc <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8023bf:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8023c4:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8023ca:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8023cc:	85 db                	test   %ebx,%ebx
  8023ce:	74 0d                	je     8023dd <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8023d0:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8023d5:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8023db:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8023dd:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8023e2:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8023e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023eb:	5b                   	pop    %ebx
  8023ec:	5e                   	pop    %esi
  8023ed:	5d                   	pop    %ebp
  8023ee:	c3                   	ret    

008023ef <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023ef:	55                   	push   %ebp
  8023f0:	89 e5                	mov    %esp,%ebp
  8023f2:	57                   	push   %edi
  8023f3:	56                   	push   %esi
  8023f4:	53                   	push   %ebx
  8023f5:	83 ec 0c             	sub    $0xc,%esp
  8023f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802401:	85 db                	test   %ebx,%ebx
  802403:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802408:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80240b:	ff 75 14             	pushl  0x14(%ebp)
  80240e:	53                   	push   %ebx
  80240f:	56                   	push   %esi
  802410:	57                   	push   %edi
  802411:	e8 f2 ed ff ff       	call   801208 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802416:	89 c2                	mov    %eax,%edx
  802418:	c1 ea 1f             	shr    $0x1f,%edx
  80241b:	83 c4 10             	add    $0x10,%esp
  80241e:	84 d2                	test   %dl,%dl
  802420:	74 17                	je     802439 <ipc_send+0x4a>
  802422:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802425:	74 12                	je     802439 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802427:	50                   	push   %eax
  802428:	68 66 2d 80 00       	push   $0x802d66
  80242d:	6a 47                	push   $0x47
  80242f:	68 74 2d 80 00       	push   $0x802d74
  802434:	e8 e1 e1 ff ff       	call   80061a <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802439:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80243c:	75 07                	jne    802445 <ipc_send+0x56>
			sys_yield();
  80243e:	e8 19 ec ff ff       	call   80105c <sys_yield>
  802443:	eb c6                	jmp    80240b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802445:	85 c0                	test   %eax,%eax
  802447:	75 c2                	jne    80240b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802449:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80244c:	5b                   	pop    %ebx
  80244d:	5e                   	pop    %esi
  80244e:	5f                   	pop    %edi
  80244f:	5d                   	pop    %ebp
  802450:	c3                   	ret    

00802451 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802451:	55                   	push   %ebp
  802452:	89 e5                	mov    %esp,%ebp
  802454:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802457:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80245c:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802462:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802468:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  80246e:	39 ca                	cmp    %ecx,%edx
  802470:	75 13                	jne    802485 <ipc_find_env+0x34>
			return envs[i].env_id;
  802472:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802478:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80247d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802483:	eb 0f                	jmp    802494 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802485:	83 c0 01             	add    $0x1,%eax
  802488:	3d 00 04 00 00       	cmp    $0x400,%eax
  80248d:	75 cd                	jne    80245c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80248f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802494:	5d                   	pop    %ebp
  802495:	c3                   	ret    

00802496 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802496:	55                   	push   %ebp
  802497:	89 e5                	mov    %esp,%ebp
  802499:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80249c:	89 d0                	mov    %edx,%eax
  80249e:	c1 e8 16             	shr    $0x16,%eax
  8024a1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024a8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024ad:	f6 c1 01             	test   $0x1,%cl
  8024b0:	74 1d                	je     8024cf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024b2:	c1 ea 0c             	shr    $0xc,%edx
  8024b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024bc:	f6 c2 01             	test   $0x1,%dl
  8024bf:	74 0e                	je     8024cf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024c1:	c1 ea 0c             	shr    $0xc,%edx
  8024c4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024cb:	ef 
  8024cc:	0f b7 c0             	movzwl %ax,%eax
}
  8024cf:	5d                   	pop    %ebp
  8024d0:	c3                   	ret    
  8024d1:	66 90                	xchg   %ax,%ax
  8024d3:	66 90                	xchg   %ax,%ax
  8024d5:	66 90                	xchg   %ax,%ax
  8024d7:	66 90                	xchg   %ax,%ax
  8024d9:	66 90                	xchg   %ax,%ax
  8024db:	66 90                	xchg   %ax,%ax
  8024dd:	66 90                	xchg   %ax,%ax
  8024df:	90                   	nop

008024e0 <__udivdi3>:
  8024e0:	55                   	push   %ebp
  8024e1:	57                   	push   %edi
  8024e2:	56                   	push   %esi
  8024e3:	53                   	push   %ebx
  8024e4:	83 ec 1c             	sub    $0x1c,%esp
  8024e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024f7:	85 f6                	test   %esi,%esi
  8024f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024fd:	89 ca                	mov    %ecx,%edx
  8024ff:	89 f8                	mov    %edi,%eax
  802501:	75 3d                	jne    802540 <__udivdi3+0x60>
  802503:	39 cf                	cmp    %ecx,%edi
  802505:	0f 87 c5 00 00 00    	ja     8025d0 <__udivdi3+0xf0>
  80250b:	85 ff                	test   %edi,%edi
  80250d:	89 fd                	mov    %edi,%ebp
  80250f:	75 0b                	jne    80251c <__udivdi3+0x3c>
  802511:	b8 01 00 00 00       	mov    $0x1,%eax
  802516:	31 d2                	xor    %edx,%edx
  802518:	f7 f7                	div    %edi
  80251a:	89 c5                	mov    %eax,%ebp
  80251c:	89 c8                	mov    %ecx,%eax
  80251e:	31 d2                	xor    %edx,%edx
  802520:	f7 f5                	div    %ebp
  802522:	89 c1                	mov    %eax,%ecx
  802524:	89 d8                	mov    %ebx,%eax
  802526:	89 cf                	mov    %ecx,%edi
  802528:	f7 f5                	div    %ebp
  80252a:	89 c3                	mov    %eax,%ebx
  80252c:	89 d8                	mov    %ebx,%eax
  80252e:	89 fa                	mov    %edi,%edx
  802530:	83 c4 1c             	add    $0x1c,%esp
  802533:	5b                   	pop    %ebx
  802534:	5e                   	pop    %esi
  802535:	5f                   	pop    %edi
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    
  802538:	90                   	nop
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	39 ce                	cmp    %ecx,%esi
  802542:	77 74                	ja     8025b8 <__udivdi3+0xd8>
  802544:	0f bd fe             	bsr    %esi,%edi
  802547:	83 f7 1f             	xor    $0x1f,%edi
  80254a:	0f 84 98 00 00 00    	je     8025e8 <__udivdi3+0x108>
  802550:	bb 20 00 00 00       	mov    $0x20,%ebx
  802555:	89 f9                	mov    %edi,%ecx
  802557:	89 c5                	mov    %eax,%ebp
  802559:	29 fb                	sub    %edi,%ebx
  80255b:	d3 e6                	shl    %cl,%esi
  80255d:	89 d9                	mov    %ebx,%ecx
  80255f:	d3 ed                	shr    %cl,%ebp
  802561:	89 f9                	mov    %edi,%ecx
  802563:	d3 e0                	shl    %cl,%eax
  802565:	09 ee                	or     %ebp,%esi
  802567:	89 d9                	mov    %ebx,%ecx
  802569:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80256d:	89 d5                	mov    %edx,%ebp
  80256f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802573:	d3 ed                	shr    %cl,%ebp
  802575:	89 f9                	mov    %edi,%ecx
  802577:	d3 e2                	shl    %cl,%edx
  802579:	89 d9                	mov    %ebx,%ecx
  80257b:	d3 e8                	shr    %cl,%eax
  80257d:	09 c2                	or     %eax,%edx
  80257f:	89 d0                	mov    %edx,%eax
  802581:	89 ea                	mov    %ebp,%edx
  802583:	f7 f6                	div    %esi
  802585:	89 d5                	mov    %edx,%ebp
  802587:	89 c3                	mov    %eax,%ebx
  802589:	f7 64 24 0c          	mull   0xc(%esp)
  80258d:	39 d5                	cmp    %edx,%ebp
  80258f:	72 10                	jb     8025a1 <__udivdi3+0xc1>
  802591:	8b 74 24 08          	mov    0x8(%esp),%esi
  802595:	89 f9                	mov    %edi,%ecx
  802597:	d3 e6                	shl    %cl,%esi
  802599:	39 c6                	cmp    %eax,%esi
  80259b:	73 07                	jae    8025a4 <__udivdi3+0xc4>
  80259d:	39 d5                	cmp    %edx,%ebp
  80259f:	75 03                	jne    8025a4 <__udivdi3+0xc4>
  8025a1:	83 eb 01             	sub    $0x1,%ebx
  8025a4:	31 ff                	xor    %edi,%edi
  8025a6:	89 d8                	mov    %ebx,%eax
  8025a8:	89 fa                	mov    %edi,%edx
  8025aa:	83 c4 1c             	add    $0x1c,%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5f                   	pop    %edi
  8025b0:	5d                   	pop    %ebp
  8025b1:	c3                   	ret    
  8025b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025b8:	31 ff                	xor    %edi,%edi
  8025ba:	31 db                	xor    %ebx,%ebx
  8025bc:	89 d8                	mov    %ebx,%eax
  8025be:	89 fa                	mov    %edi,%edx
  8025c0:	83 c4 1c             	add    $0x1c,%esp
  8025c3:	5b                   	pop    %ebx
  8025c4:	5e                   	pop    %esi
  8025c5:	5f                   	pop    %edi
  8025c6:	5d                   	pop    %ebp
  8025c7:	c3                   	ret    
  8025c8:	90                   	nop
  8025c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025d0:	89 d8                	mov    %ebx,%eax
  8025d2:	f7 f7                	div    %edi
  8025d4:	31 ff                	xor    %edi,%edi
  8025d6:	89 c3                	mov    %eax,%ebx
  8025d8:	89 d8                	mov    %ebx,%eax
  8025da:	89 fa                	mov    %edi,%edx
  8025dc:	83 c4 1c             	add    $0x1c,%esp
  8025df:	5b                   	pop    %ebx
  8025e0:	5e                   	pop    %esi
  8025e1:	5f                   	pop    %edi
  8025e2:	5d                   	pop    %ebp
  8025e3:	c3                   	ret    
  8025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e8:	39 ce                	cmp    %ecx,%esi
  8025ea:	72 0c                	jb     8025f8 <__udivdi3+0x118>
  8025ec:	31 db                	xor    %ebx,%ebx
  8025ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025f2:	0f 87 34 ff ff ff    	ja     80252c <__udivdi3+0x4c>
  8025f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025fd:	e9 2a ff ff ff       	jmp    80252c <__udivdi3+0x4c>
  802602:	66 90                	xchg   %ax,%ax
  802604:	66 90                	xchg   %ax,%ax
  802606:	66 90                	xchg   %ax,%ax
  802608:	66 90                	xchg   %ax,%ax
  80260a:	66 90                	xchg   %ax,%ax
  80260c:	66 90                	xchg   %ax,%ax
  80260e:	66 90                	xchg   %ax,%ax

00802610 <__umoddi3>:
  802610:	55                   	push   %ebp
  802611:	57                   	push   %edi
  802612:	56                   	push   %esi
  802613:	53                   	push   %ebx
  802614:	83 ec 1c             	sub    $0x1c,%esp
  802617:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80261b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80261f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802623:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802627:	85 d2                	test   %edx,%edx
  802629:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80262d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802631:	89 f3                	mov    %esi,%ebx
  802633:	89 3c 24             	mov    %edi,(%esp)
  802636:	89 74 24 04          	mov    %esi,0x4(%esp)
  80263a:	75 1c                	jne    802658 <__umoddi3+0x48>
  80263c:	39 f7                	cmp    %esi,%edi
  80263e:	76 50                	jbe    802690 <__umoddi3+0x80>
  802640:	89 c8                	mov    %ecx,%eax
  802642:	89 f2                	mov    %esi,%edx
  802644:	f7 f7                	div    %edi
  802646:	89 d0                	mov    %edx,%eax
  802648:	31 d2                	xor    %edx,%edx
  80264a:	83 c4 1c             	add    $0x1c,%esp
  80264d:	5b                   	pop    %ebx
  80264e:	5e                   	pop    %esi
  80264f:	5f                   	pop    %edi
  802650:	5d                   	pop    %ebp
  802651:	c3                   	ret    
  802652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802658:	39 f2                	cmp    %esi,%edx
  80265a:	89 d0                	mov    %edx,%eax
  80265c:	77 52                	ja     8026b0 <__umoddi3+0xa0>
  80265e:	0f bd ea             	bsr    %edx,%ebp
  802661:	83 f5 1f             	xor    $0x1f,%ebp
  802664:	75 5a                	jne    8026c0 <__umoddi3+0xb0>
  802666:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80266a:	0f 82 e0 00 00 00    	jb     802750 <__umoddi3+0x140>
  802670:	39 0c 24             	cmp    %ecx,(%esp)
  802673:	0f 86 d7 00 00 00    	jbe    802750 <__umoddi3+0x140>
  802679:	8b 44 24 08          	mov    0x8(%esp),%eax
  80267d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802681:	83 c4 1c             	add    $0x1c,%esp
  802684:	5b                   	pop    %ebx
  802685:	5e                   	pop    %esi
  802686:	5f                   	pop    %edi
  802687:	5d                   	pop    %ebp
  802688:	c3                   	ret    
  802689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802690:	85 ff                	test   %edi,%edi
  802692:	89 fd                	mov    %edi,%ebp
  802694:	75 0b                	jne    8026a1 <__umoddi3+0x91>
  802696:	b8 01 00 00 00       	mov    $0x1,%eax
  80269b:	31 d2                	xor    %edx,%edx
  80269d:	f7 f7                	div    %edi
  80269f:	89 c5                	mov    %eax,%ebp
  8026a1:	89 f0                	mov    %esi,%eax
  8026a3:	31 d2                	xor    %edx,%edx
  8026a5:	f7 f5                	div    %ebp
  8026a7:	89 c8                	mov    %ecx,%eax
  8026a9:	f7 f5                	div    %ebp
  8026ab:	89 d0                	mov    %edx,%eax
  8026ad:	eb 99                	jmp    802648 <__umoddi3+0x38>
  8026af:	90                   	nop
  8026b0:	89 c8                	mov    %ecx,%eax
  8026b2:	89 f2                	mov    %esi,%edx
  8026b4:	83 c4 1c             	add    $0x1c,%esp
  8026b7:	5b                   	pop    %ebx
  8026b8:	5e                   	pop    %esi
  8026b9:	5f                   	pop    %edi
  8026ba:	5d                   	pop    %ebp
  8026bb:	c3                   	ret    
  8026bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	8b 34 24             	mov    (%esp),%esi
  8026c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026c8:	89 e9                	mov    %ebp,%ecx
  8026ca:	29 ef                	sub    %ebp,%edi
  8026cc:	d3 e0                	shl    %cl,%eax
  8026ce:	89 f9                	mov    %edi,%ecx
  8026d0:	89 f2                	mov    %esi,%edx
  8026d2:	d3 ea                	shr    %cl,%edx
  8026d4:	89 e9                	mov    %ebp,%ecx
  8026d6:	09 c2                	or     %eax,%edx
  8026d8:	89 d8                	mov    %ebx,%eax
  8026da:	89 14 24             	mov    %edx,(%esp)
  8026dd:	89 f2                	mov    %esi,%edx
  8026df:	d3 e2                	shl    %cl,%edx
  8026e1:	89 f9                	mov    %edi,%ecx
  8026e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026eb:	d3 e8                	shr    %cl,%eax
  8026ed:	89 e9                	mov    %ebp,%ecx
  8026ef:	89 c6                	mov    %eax,%esi
  8026f1:	d3 e3                	shl    %cl,%ebx
  8026f3:	89 f9                	mov    %edi,%ecx
  8026f5:	89 d0                	mov    %edx,%eax
  8026f7:	d3 e8                	shr    %cl,%eax
  8026f9:	89 e9                	mov    %ebp,%ecx
  8026fb:	09 d8                	or     %ebx,%eax
  8026fd:	89 d3                	mov    %edx,%ebx
  8026ff:	89 f2                	mov    %esi,%edx
  802701:	f7 34 24             	divl   (%esp)
  802704:	89 d6                	mov    %edx,%esi
  802706:	d3 e3                	shl    %cl,%ebx
  802708:	f7 64 24 04          	mull   0x4(%esp)
  80270c:	39 d6                	cmp    %edx,%esi
  80270e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802712:	89 d1                	mov    %edx,%ecx
  802714:	89 c3                	mov    %eax,%ebx
  802716:	72 08                	jb     802720 <__umoddi3+0x110>
  802718:	75 11                	jne    80272b <__umoddi3+0x11b>
  80271a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80271e:	73 0b                	jae    80272b <__umoddi3+0x11b>
  802720:	2b 44 24 04          	sub    0x4(%esp),%eax
  802724:	1b 14 24             	sbb    (%esp),%edx
  802727:	89 d1                	mov    %edx,%ecx
  802729:	89 c3                	mov    %eax,%ebx
  80272b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80272f:	29 da                	sub    %ebx,%edx
  802731:	19 ce                	sbb    %ecx,%esi
  802733:	89 f9                	mov    %edi,%ecx
  802735:	89 f0                	mov    %esi,%eax
  802737:	d3 e0                	shl    %cl,%eax
  802739:	89 e9                	mov    %ebp,%ecx
  80273b:	d3 ea                	shr    %cl,%edx
  80273d:	89 e9                	mov    %ebp,%ecx
  80273f:	d3 ee                	shr    %cl,%esi
  802741:	09 d0                	or     %edx,%eax
  802743:	89 f2                	mov    %esi,%edx
  802745:	83 c4 1c             	add    $0x1c,%esp
  802748:	5b                   	pop    %ebx
  802749:	5e                   	pop    %esi
  80274a:	5f                   	pop    %edi
  80274b:	5d                   	pop    %ebp
  80274c:	c3                   	ret    
  80274d:	8d 76 00             	lea    0x0(%esi),%esi
  802750:	29 f9                	sub    %edi,%ecx
  802752:	19 d6                	sbb    %edx,%esi
  802754:	89 74 24 04          	mov    %esi,0x4(%esp)
  802758:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80275c:	e9 18 ff ff ff       	jmp    802679 <__umoddi3+0x69>
