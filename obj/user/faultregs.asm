
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
  800044:	68 f5 2e 80 00       	push   $0x802ef5
  800049:	68 e0 29 80 00       	push   $0x8029e0
  80004e:	e8 a0 06 00 00       	call   8006f3 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 f0 29 80 00       	push   $0x8029f0
  80005c:	68 f4 29 80 00       	push   $0x8029f4
  800061:	e8 8d 06 00 00       	call   8006f3 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 04 2a 80 00       	push   $0x802a04
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
  800089:	68 08 2a 80 00       	push   $0x802a08
  80008e:	e8 60 06 00 00       	call   8006f3 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 12 2a 80 00       	push   $0x802a12
  8000a6:	68 f4 29 80 00       	push   $0x8029f4
  8000ab:	e8 43 06 00 00       	call   8006f3 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 04 2a 80 00       	push   $0x802a04
  8000c3:	e8 2b 06 00 00       	call   8006f3 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 08 2a 80 00       	push   $0x802a08
  8000d5:	e8 19 06 00 00       	call   8006f3 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 16 2a 80 00       	push   $0x802a16
  8000ed:	68 f4 29 80 00       	push   $0x8029f4
  8000f2:	e8 fc 05 00 00       	call   8006f3 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 04 2a 80 00       	push   $0x802a04
  80010a:	e8 e4 05 00 00       	call   8006f3 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 08 2a 80 00       	push   $0x802a08
  80011c:	e8 d2 05 00 00       	call   8006f3 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 1a 2a 80 00       	push   $0x802a1a
  800134:	68 f4 29 80 00       	push   $0x8029f4
  800139:	e8 b5 05 00 00       	call   8006f3 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 04 2a 80 00       	push   $0x802a04
  800151:	e8 9d 05 00 00       	call   8006f3 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 08 2a 80 00       	push   $0x802a08
  800163:	e8 8b 05 00 00       	call   8006f3 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 1e 2a 80 00       	push   $0x802a1e
  80017b:	68 f4 29 80 00       	push   $0x8029f4
  800180:	e8 6e 05 00 00       	call   8006f3 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 04 2a 80 00       	push   $0x802a04
  800198:	e8 56 05 00 00       	call   8006f3 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 08 2a 80 00       	push   $0x802a08
  8001aa:	e8 44 05 00 00       	call   8006f3 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 22 2a 80 00       	push   $0x802a22
  8001c2:	68 f4 29 80 00       	push   $0x8029f4
  8001c7:	e8 27 05 00 00       	call   8006f3 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 04 2a 80 00       	push   $0x802a04
  8001df:	e8 0f 05 00 00       	call   8006f3 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 08 2a 80 00       	push   $0x802a08
  8001f1:	e8 fd 04 00 00       	call   8006f3 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 26 2a 80 00       	push   $0x802a26
  800209:	68 f4 29 80 00       	push   $0x8029f4
  80020e:	e8 e0 04 00 00       	call   8006f3 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 04 2a 80 00       	push   $0x802a04
  800226:	e8 c8 04 00 00       	call   8006f3 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 08 2a 80 00       	push   $0x802a08
  800238:	e8 b6 04 00 00       	call   8006f3 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 2a 2a 80 00       	push   $0x802a2a
  800250:	68 f4 29 80 00       	push   $0x8029f4
  800255:	e8 99 04 00 00       	call   8006f3 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 04 2a 80 00       	push   $0x802a04
  80026d:	e8 81 04 00 00       	call   8006f3 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 08 2a 80 00       	push   $0x802a08
  80027f:	e8 6f 04 00 00       	call   8006f3 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 2e 2a 80 00       	push   $0x802a2e
  800297:	68 f4 29 80 00       	push   $0x8029f4
  80029c:	e8 52 04 00 00       	call   8006f3 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 04 2a 80 00       	push   $0x802a04
  8002b4:	e8 3a 04 00 00       	call   8006f3 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 35 2a 80 00       	push   $0x802a35
  8002c4:	68 f4 29 80 00       	push   $0x8029f4
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
  8002de:	68 08 2a 80 00       	push   $0x802a08
  8002e3:	e8 0b 04 00 00       	call   8006f3 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 35 2a 80 00       	push   $0x802a35
  8002f3:	68 f4 29 80 00       	push   $0x8029f4
  8002f8:	e8 f6 03 00 00       	call   8006f3 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 04 2a 80 00       	push   $0x802a04
  800312:	e8 dc 03 00 00       	call   8006f3 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 39 2a 80 00       	push   $0x802a39
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
  800333:	68 08 2a 80 00       	push   $0x802a08
  800338:	e8 b6 03 00 00       	call   8006f3 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 39 2a 80 00       	push   $0x802a39
  800348:	e8 a6 03 00 00       	call   8006f3 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 04 2a 80 00       	push   $0x802a04
  80035a:	e8 94 03 00 00       	call   8006f3 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 08 2a 80 00       	push   $0x802a08
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
  800379:	68 04 2a 80 00       	push   $0x802a04
  80037e:	e8 70 03 00 00       	call   8006f3 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 39 2a 80 00       	push   $0x802a39
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
  8003ba:	68 a0 2a 80 00       	push   $0x802aa0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 47 2a 80 00       	push   $0x802a47
  8003c6:	e8 4f 02 00 00       	call   80061a <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 50 80 00    	mov    %edx,0x805040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 50 80 00    	mov    %edx,0x805044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 50 80 00    	mov    %edx,0x805048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 50 80 00    	mov    %edx,0x80504c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 50 80 00    	mov    %edx,0x805050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 50 80 00    	mov    %edx,0x805054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 50 80 00    	mov    %edx,0x805058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 50 80 00    	mov    %edx,0x80505c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 50 80 00    	mov    %edx,0x805060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 64 50 80 00    	mov    %edx,0x805064
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 68 50 80 00       	mov    %eax,0x805068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 5f 2a 80 00       	push   $0x802a5f
  80043b:	68 6d 2a 80 00       	push   $0x802a6d
  800440:	b9 40 50 80 00       	mov    $0x805040,%ecx
  800445:	ba 58 2a 80 00       	mov    $0x802a58,%edx
  80044a:	b8 80 50 80 00       	mov    $0x805080,%eax
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
  80046d:	68 74 2a 80 00       	push   $0x802a74
  800472:	6a 5c                	push   $0x5c
  800474:	68 47 2a 80 00       	push   $0x802a47
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
  80049a:	a3 a4 50 80 00       	mov    %eax,0x8050a4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 a0 50 80 00       	mov    %eax,0x8050a0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d 80 50 80 00    	mov    %edi,0x805080
  8004b1:	89 35 84 50 80 00    	mov    %esi,0x805084
  8004b7:	89 2d 88 50 80 00    	mov    %ebp,0x805088
  8004bd:	89 1d 90 50 80 00    	mov    %ebx,0x805090
  8004c3:	89 15 94 50 80 00    	mov    %edx,0x805094
  8004c9:	89 0d 98 50 80 00    	mov    %ecx,0x805098
  8004cf:	a3 9c 50 80 00       	mov    %eax,0x80509c
  8004d4:	89 25 a8 50 80 00    	mov    %esp,0x8050a8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 00 50 80 00    	mov    %edi,0x805000
  8004ea:	89 35 04 50 80 00    	mov    %esi,0x805004
  8004f0:	89 2d 08 50 80 00    	mov    %ebp,0x805008
  8004f6:	89 1d 10 50 80 00    	mov    %ebx,0x805010
  8004fc:	89 15 14 50 80 00    	mov    %edx,0x805014
  800502:	89 0d 18 50 80 00    	mov    %ecx,0x805018
  800508:	a3 1c 50 80 00       	mov    %eax,0x80501c
  80050d:	89 25 28 50 80 00    	mov    %esp,0x805028
  800513:	8b 3d 80 50 80 00    	mov    0x805080,%edi
  800519:	8b 35 84 50 80 00    	mov    0x805084,%esi
  80051f:	8b 2d 88 50 80 00    	mov    0x805088,%ebp
  800525:	8b 1d 90 50 80 00    	mov    0x805090,%ebx
  80052b:	8b 15 94 50 80 00    	mov    0x805094,%edx
  800531:	8b 0d 98 50 80 00    	mov    0x805098,%ecx
  800537:	a1 9c 50 80 00       	mov    0x80509c,%eax
  80053c:	8b 25 a8 50 80 00    	mov    0x8050a8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 24 50 80 00       	mov    %eax,0x805024
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
  80055a:	68 d4 2a 80 00       	push   $0x802ad4
  80055f:	e8 8f 01 00 00       	call   8006f3 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 50 80 00       	mov    0x8050a0,%eax
  80056c:	a3 20 50 80 00       	mov    %eax,0x805020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 87 2a 80 00       	push   $0x802a87
  800579:	68 98 2a 80 00       	push   $0x802a98
  80057e:	b9 00 50 80 00       	mov    $0x805000,%ecx
  800583:	ba 58 2a 80 00       	mov    $0x802a58,%edx
  800588:	b8 80 50 80 00       	mov    $0x805080,%eax
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
  8005b7:	a3 b0 50 80 00       	mov    %eax,0x8050b0
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005bc:	85 db                	test   %ebx,%ebx
  8005be:	7e 07                	jle    8005c7 <libmain+0x30>
		binaryname = argv[0];
  8005c0:	8b 06                	mov    (%esi),%eax
  8005c2:	a3 00 40 80 00       	mov    %eax,0x804000

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
  8005e6:	a1 b8 50 80 00       	mov    0x8050b8,%eax
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
  800606:	e8 9a 14 00 00       	call   801aa5 <close_all>
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
  800622:	8b 35 00 40 80 00    	mov    0x804000,%esi
  800628:	e8 10 0a 00 00       	call   80103d <sys_getenvid>
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	ff 75 0c             	pushl  0xc(%ebp)
  800633:	ff 75 08             	pushl  0x8(%ebp)
  800636:	56                   	push   %esi
  800637:	50                   	push   %eax
  800638:	68 00 2b 80 00       	push   $0x802b00
  80063d:	e8 b1 00 00 00       	call   8006f3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800642:	83 c4 18             	add    $0x18,%esp
  800645:	53                   	push   %ebx
  800646:	ff 75 10             	pushl  0x10(%ebp)
  800649:	e8 54 00 00 00       	call   8006a2 <vcprintf>
	cprintf("\n");
  80064e:	c7 04 24 f4 2e 80 00 	movl   $0x802ef4,(%esp)
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
  800756:	e8 e5 1f 00 00       	call   802740 <__udivdi3>
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
  800799:	e8 d2 20 00 00       	call   802870 <__umoddi3>
  80079e:	83 c4 14             	add    $0x14,%esp
  8007a1:	0f be 80 23 2b 80 00 	movsbl 0x802b23(%eax),%eax
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
  80089d:	ff 24 85 60 2c 80 00 	jmp    *0x802c60(,%eax,4)
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
  800961:	8b 14 85 c0 2d 80 00 	mov    0x802dc0(,%eax,4),%edx
  800968:	85 d2                	test   %edx,%edx
  80096a:	75 18                	jne    800984 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80096c:	50                   	push   %eax
  80096d:	68 3b 2b 80 00       	push   $0x802b3b
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
  800985:	68 61 30 80 00       	push   $0x803061
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
  8009a9:	b8 34 2b 80 00       	mov    $0x802b34,%eax
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
  801024:	68 1f 2e 80 00       	push   $0x802e1f
  801029:	6a 23                	push   $0x23
  80102b:	68 3c 2e 80 00       	push   $0x802e3c
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
  8010a5:	68 1f 2e 80 00       	push   $0x802e1f
  8010aa:	6a 23                	push   $0x23
  8010ac:	68 3c 2e 80 00       	push   $0x802e3c
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
  8010e7:	68 1f 2e 80 00       	push   $0x802e1f
  8010ec:	6a 23                	push   $0x23
  8010ee:	68 3c 2e 80 00       	push   $0x802e3c
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
  801129:	68 1f 2e 80 00       	push   $0x802e1f
  80112e:	6a 23                	push   $0x23
  801130:	68 3c 2e 80 00       	push   $0x802e3c
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
  80116b:	68 1f 2e 80 00       	push   $0x802e1f
  801170:	6a 23                	push   $0x23
  801172:	68 3c 2e 80 00       	push   $0x802e3c
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
  8011ad:	68 1f 2e 80 00       	push   $0x802e1f
  8011b2:	6a 23                	push   $0x23
  8011b4:	68 3c 2e 80 00       	push   $0x802e3c
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
  8011ef:	68 1f 2e 80 00       	push   $0x802e1f
  8011f4:	6a 23                	push   $0x23
  8011f6:	68 3c 2e 80 00       	push   $0x802e3c
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
  801253:	68 1f 2e 80 00       	push   $0x802e1f
  801258:	6a 23                	push   $0x23
  80125a:	68 3c 2e 80 00       	push   $0x802e3c
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
  8012d2:	83 3d b4 50 80 00 00 	cmpl   $0x0,0x8050b4
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
  8012f4:	68 26 2f 80 00       	push   $0x802f26
  8012f9:	6a 23                	push   $0x23
  8012fb:	68 4a 2e 80 00       	push   $0x802e4a
  801300:	e8 15 f3 ff ff       	call   80061a <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801305:	8b 45 08             	mov    0x8(%ebp),%eax
  801308:	a3 b4 50 80 00       	mov    %eax,0x8050b4
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
  801324:	68 26 2f 80 00       	push   $0x802f26
  801329:	6a 2c                	push   $0x2c
  80132b:	68 4a 2e 80 00       	push   $0x802e4a
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
  801338:	a1 b4 50 80 00       	mov    0x8050b4,%eax
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
  801381:	68 58 2e 80 00       	push   $0x802e58
  801386:	6a 1f                	push   $0x1f
  801388:	68 68 2e 80 00       	push   $0x802e68
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
  8013ab:	68 73 2e 80 00       	push   $0x802e73
  8013b0:	6a 2d                	push   $0x2d
  8013b2:	68 68 2e 80 00       	push   $0x802e68
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
  8013f3:	68 73 2e 80 00       	push   $0x802e73
  8013f8:	6a 34                	push   $0x34
  8013fa:	68 68 2e 80 00       	push   $0x802e68
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
  80141b:	68 73 2e 80 00       	push   $0x802e73
  801420:	6a 38                	push   $0x38
  801422:	68 68 2e 80 00       	push   $0x802e68
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
  801458:	68 8c 2e 80 00       	push   $0x802e8c
  80145d:	68 85 00 00 00       	push   $0x85
  801462:	68 68 2e 80 00       	push   $0x802e68
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
  801489:	a3 b0 50 80 00       	mov    %eax,0x8050b0
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
  801514:	68 9a 2e 80 00       	push   $0x802e9a
  801519:	6a 55                	push   $0x55
  80151b:	68 68 2e 80 00       	push   $0x802e68
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
  801559:	68 9a 2e 80 00       	push   $0x802e9a
  80155e:	6a 5c                	push   $0x5c
  801560:	68 68 2e 80 00       	push   $0x802e68
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
  801587:	68 9a 2e 80 00       	push   $0x802e9a
  80158c:	6a 60                	push   $0x60
  80158e:	68 68 2e 80 00       	push   $0x802e68
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
  8015b1:	68 9a 2e 80 00       	push   $0x802e9a
  8015b6:	6a 65                	push   $0x65
  8015b8:	68 68 2e 80 00       	push   $0x802e68
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
  8015d4:	a1 b0 50 80 00       	mov    0x8050b0,%eax
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
  801616:	89 1d b8 50 80 00    	mov    %ebx,0x8050b8
	cprintf("in fork.c thread create. func: %x\n", func);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	53                   	push   %ebx
  801620:	68 2c 2f 80 00       	push   $0x802f2c
  801625:	e8 c9 f0 ff ff       	call   8006f3 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80162a:	c7 04 24 e0 05 80 00 	movl   $0x8005e0,(%esp)
  801631:	e8 36 fc ff ff       	call   80126c <sys_thread_create>
  801636:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801638:	83 c4 08             	add    $0x8,%esp
  80163b:	53                   	push   %ebx
  80163c:	68 2c 2f 80 00       	push   $0x802f2c
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

00801675 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	56                   	push   %esi
  801679:	53                   	push   %ebx
  80167a:	8b 75 08             	mov    0x8(%ebp),%esi
  80167d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  801680:	83 ec 04             	sub    $0x4,%esp
  801683:	6a 07                	push   $0x7
  801685:	6a 00                	push   $0x0
  801687:	56                   	push   %esi
  801688:	e8 ee f9 ff ff       	call   80107b <sys_page_alloc>
	if (r < 0) {
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	85 c0                	test   %eax,%eax
  801692:	79 15                	jns    8016a9 <queue_append+0x34>
		panic("%e\n", r);
  801694:	50                   	push   %eax
  801695:	68 26 2f 80 00       	push   $0x802f26
  80169a:	68 c4 00 00 00       	push   $0xc4
  80169f:	68 68 2e 80 00       	push   $0x802e68
  8016a4:	e8 71 ef ff ff       	call   80061a <_panic>
	}	
	wt->envid = envid;
  8016a9:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  8016af:	83 ec 04             	sub    $0x4,%esp
  8016b2:	ff 33                	pushl  (%ebx)
  8016b4:	56                   	push   %esi
  8016b5:	68 50 2f 80 00       	push   $0x802f50
  8016ba:	e8 34 f0 ff ff       	call   8006f3 <cprintf>
	if (queue->first == NULL) {
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	83 3b 00             	cmpl   $0x0,(%ebx)
  8016c5:	75 29                	jne    8016f0 <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  8016c7:	83 ec 0c             	sub    $0xc,%esp
  8016ca:	68 b0 2e 80 00       	push   $0x802eb0
  8016cf:	e8 1f f0 ff ff       	call   8006f3 <cprintf>
		queue->first = wt;
  8016d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  8016da:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  8016e1:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8016e8:	00 00 00 
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	eb 2b                	jmp    80171b <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	68 ca 2e 80 00       	push   $0x802eca
  8016f8:	e8 f6 ef ff ff       	call   8006f3 <cprintf>
		queue->last->next = wt;
  8016fd:	8b 43 04             	mov    0x4(%ebx),%eax
  801700:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  801707:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80170e:	00 00 00 
		queue->last = wt;
  801711:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  801718:	83 c4 10             	add    $0x10,%esp
	}
}
  80171b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	53                   	push   %ebx
  801726:	83 ec 04             	sub    $0x4,%esp
  801729:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80172c:	8b 02                	mov    (%edx),%eax
  80172e:	85 c0                	test   %eax,%eax
  801730:	75 17                	jne    801749 <queue_pop+0x27>
		panic("queue empty!\n");
  801732:	83 ec 04             	sub    $0x4,%esp
  801735:	68 e8 2e 80 00       	push   $0x802ee8
  80173a:	68 d8 00 00 00       	push   $0xd8
  80173f:	68 68 2e 80 00       	push   $0x802e68
  801744:	e8 d1 ee ff ff       	call   80061a <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  801749:	8b 48 04             	mov    0x4(%eax),%ecx
  80174c:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  80174e:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	53                   	push   %ebx
  801754:	68 f6 2e 80 00       	push   $0x802ef6
  801759:	e8 95 ef ff ff       	call   8006f3 <cprintf>
	return envid;
}
  80175e:	89 d8                	mov    %ebx,%eax
  801760:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801763:	c9                   	leave  
  801764:	c3                   	ret    

00801765 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	53                   	push   %ebx
  801769:	83 ec 04             	sub    $0x4,%esp
  80176c:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80176f:	b8 01 00 00 00       	mov    $0x1,%eax
  801774:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  801777:	85 c0                	test   %eax,%eax
  801779:	74 5a                	je     8017d5 <mutex_lock+0x70>
  80177b:	8b 43 04             	mov    0x4(%ebx),%eax
  80177e:	83 38 00             	cmpl   $0x0,(%eax)
  801781:	75 52                	jne    8017d5 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  801783:	83 ec 0c             	sub    $0xc,%esp
  801786:	68 78 2f 80 00       	push   $0x802f78
  80178b:	e8 63 ef ff ff       	call   8006f3 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  801790:	8b 5b 04             	mov    0x4(%ebx),%ebx
  801793:	e8 a5 f8 ff ff       	call   80103d <sys_getenvid>
  801798:	83 c4 08             	add    $0x8,%esp
  80179b:	53                   	push   %ebx
  80179c:	50                   	push   %eax
  80179d:	e8 d3 fe ff ff       	call   801675 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8017a2:	e8 96 f8 ff ff       	call   80103d <sys_getenvid>
  8017a7:	83 c4 08             	add    $0x8,%esp
  8017aa:	6a 04                	push   $0x4
  8017ac:	50                   	push   %eax
  8017ad:	e8 90 f9 ff ff       	call   801142 <sys_env_set_status>
		if (r < 0) {
  8017b2:	83 c4 10             	add    $0x10,%esp
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	79 15                	jns    8017ce <mutex_lock+0x69>
			panic("%e\n", r);
  8017b9:	50                   	push   %eax
  8017ba:	68 26 2f 80 00       	push   $0x802f26
  8017bf:	68 eb 00 00 00       	push   $0xeb
  8017c4:	68 68 2e 80 00       	push   $0x802e68
  8017c9:	e8 4c ee ff ff       	call   80061a <_panic>
		}
		sys_yield();
  8017ce:	e8 89 f8 ff ff       	call   80105c <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8017d3:	eb 18                	jmp    8017ed <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  8017d5:	83 ec 0c             	sub    $0xc,%esp
  8017d8:	68 98 2f 80 00       	push   $0x802f98
  8017dd:	e8 11 ef ff ff       	call   8006f3 <cprintf>
	mtx->owner = sys_getenvid();}
  8017e2:	e8 56 f8 ff ff       	call   80103d <sys_getenvid>
  8017e7:	89 43 08             	mov    %eax,0x8(%ebx)
  8017ea:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  8017ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 04             	sub    $0x4,%esp
  8017f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8017fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801801:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  801804:	8b 43 04             	mov    0x4(%ebx),%eax
  801807:	83 38 00             	cmpl   $0x0,(%eax)
  80180a:	74 33                	je     80183f <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80180c:	83 ec 0c             	sub    $0xc,%esp
  80180f:	50                   	push   %eax
  801810:	e8 0d ff ff ff       	call   801722 <queue_pop>
  801815:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  801818:	83 c4 08             	add    $0x8,%esp
  80181b:	6a 02                	push   $0x2
  80181d:	50                   	push   %eax
  80181e:	e8 1f f9 ff ff       	call   801142 <sys_env_set_status>
		if (r < 0) {
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	85 c0                	test   %eax,%eax
  801828:	79 15                	jns    80183f <mutex_unlock+0x4d>
			panic("%e\n", r);
  80182a:	50                   	push   %eax
  80182b:	68 26 2f 80 00       	push   $0x802f26
  801830:	68 00 01 00 00       	push   $0x100
  801835:	68 68 2e 80 00       	push   $0x802e68
  80183a:	e8 db ed ff ff       	call   80061a <_panic>
		}
	}

	asm volatile("pause");
  80183f:	f3 90                	pause  
	//sys_yield();
}
  801841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	53                   	push   %ebx
  80184a:	83 ec 04             	sub    $0x4,%esp
  80184d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  801850:	e8 e8 f7 ff ff       	call   80103d <sys_getenvid>
  801855:	83 ec 04             	sub    $0x4,%esp
  801858:	6a 07                	push   $0x7
  80185a:	53                   	push   %ebx
  80185b:	50                   	push   %eax
  80185c:	e8 1a f8 ff ff       	call   80107b <sys_page_alloc>
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	85 c0                	test   %eax,%eax
  801866:	79 15                	jns    80187d <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  801868:	50                   	push   %eax
  801869:	68 11 2f 80 00       	push   $0x802f11
  80186e:	68 0d 01 00 00       	push   $0x10d
  801873:	68 68 2e 80 00       	push   $0x802e68
  801878:	e8 9d ed ff ff       	call   80061a <_panic>
	}	
	mtx->locked = 0;
  80187d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  801883:	8b 43 04             	mov    0x4(%ebx),%eax
  801886:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  80188c:	8b 43 04             	mov    0x4(%ebx),%eax
  80188f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  801896:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80189d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  8018a8:	e8 90 f7 ff ff       	call   80103d <sys_getenvid>
  8018ad:	83 ec 08             	sub    $0x8,%esp
  8018b0:	ff 75 08             	pushl  0x8(%ebp)
  8018b3:	50                   	push   %eax
  8018b4:	e8 47 f8 ff ff       	call   801100 <sys_page_unmap>
	if (r < 0) {
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	79 15                	jns    8018d5 <mutex_destroy+0x33>
		panic("%e\n", r);
  8018c0:	50                   	push   %eax
  8018c1:	68 26 2f 80 00       	push   $0x802f26
  8018c6:	68 1a 01 00 00       	push   $0x11a
  8018cb:	68 68 2e 80 00       	push   $0x802e68
  8018d0:	e8 45 ed ff ff       	call   80061a <_panic>
	}
}
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	05 00 00 00 30       	add    $0x30000000,%eax
  8018e2:	c1 e8 0c             	shr    $0xc,%eax
}
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	05 00 00 00 30       	add    $0x30000000,%eax
  8018f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8018f7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801904:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801909:	89 c2                	mov    %eax,%edx
  80190b:	c1 ea 16             	shr    $0x16,%edx
  80190e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801915:	f6 c2 01             	test   $0x1,%dl
  801918:	74 11                	je     80192b <fd_alloc+0x2d>
  80191a:	89 c2                	mov    %eax,%edx
  80191c:	c1 ea 0c             	shr    $0xc,%edx
  80191f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801926:	f6 c2 01             	test   $0x1,%dl
  801929:	75 09                	jne    801934 <fd_alloc+0x36>
			*fd_store = fd;
  80192b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
  801932:	eb 17                	jmp    80194b <fd_alloc+0x4d>
  801934:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801939:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80193e:	75 c9                	jne    801909 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801940:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801946:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    

0080194d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801953:	83 f8 1f             	cmp    $0x1f,%eax
  801956:	77 36                	ja     80198e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801958:	c1 e0 0c             	shl    $0xc,%eax
  80195b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801960:	89 c2                	mov    %eax,%edx
  801962:	c1 ea 16             	shr    $0x16,%edx
  801965:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80196c:	f6 c2 01             	test   $0x1,%dl
  80196f:	74 24                	je     801995 <fd_lookup+0x48>
  801971:	89 c2                	mov    %eax,%edx
  801973:	c1 ea 0c             	shr    $0xc,%edx
  801976:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80197d:	f6 c2 01             	test   $0x1,%dl
  801980:	74 1a                	je     80199c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801982:	8b 55 0c             	mov    0xc(%ebp),%edx
  801985:	89 02                	mov    %eax,(%edx)
	return 0;
  801987:	b8 00 00 00 00       	mov    $0x0,%eax
  80198c:	eb 13                	jmp    8019a1 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80198e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801993:	eb 0c                	jmp    8019a1 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801995:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80199a:	eb 05                	jmp    8019a1 <fd_lookup+0x54>
  80199c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 08             	sub    $0x8,%esp
  8019a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ac:	ba 38 30 80 00       	mov    $0x803038,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8019b1:	eb 13                	jmp    8019c6 <dev_lookup+0x23>
  8019b3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8019b6:	39 08                	cmp    %ecx,(%eax)
  8019b8:	75 0c                	jne    8019c6 <dev_lookup+0x23>
			*dev = devtab[i];
  8019ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019bd:	89 01                	mov    %eax,(%ecx)
			return 0;
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c4:	eb 31                	jmp    8019f7 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8019c6:	8b 02                	mov    (%edx),%eax
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	75 e7                	jne    8019b3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8019cc:	a1 b0 50 80 00       	mov    0x8050b0,%eax
  8019d1:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8019d7:	83 ec 04             	sub    $0x4,%esp
  8019da:	51                   	push   %ecx
  8019db:	50                   	push   %eax
  8019dc:	68 b8 2f 80 00       	push   $0x802fb8
  8019e1:	e8 0d ed ff ff       	call   8006f3 <cprintf>
	*dev = 0;
  8019e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    

008019f9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	56                   	push   %esi
  8019fd:	53                   	push   %ebx
  8019fe:	83 ec 10             	sub    $0x10,%esp
  801a01:	8b 75 08             	mov    0x8(%ebp),%esi
  801a04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a0a:	50                   	push   %eax
  801a0b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801a11:	c1 e8 0c             	shr    $0xc,%eax
  801a14:	50                   	push   %eax
  801a15:	e8 33 ff ff ff       	call   80194d <fd_lookup>
  801a1a:	83 c4 08             	add    $0x8,%esp
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	78 05                	js     801a26 <fd_close+0x2d>
	    || fd != fd2)
  801a21:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a24:	74 0c                	je     801a32 <fd_close+0x39>
		return (must_exist ? r : 0);
  801a26:	84 db                	test   %bl,%bl
  801a28:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2d:	0f 44 c2             	cmove  %edx,%eax
  801a30:	eb 41                	jmp    801a73 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a32:	83 ec 08             	sub    $0x8,%esp
  801a35:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a38:	50                   	push   %eax
  801a39:	ff 36                	pushl  (%esi)
  801a3b:	e8 63 ff ff ff       	call   8019a3 <dev_lookup>
  801a40:	89 c3                	mov    %eax,%ebx
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 1a                	js     801a63 <fd_close+0x6a>
		if (dev->dev_close)
  801a49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a4c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801a4f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801a54:	85 c0                	test   %eax,%eax
  801a56:	74 0b                	je     801a63 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	56                   	push   %esi
  801a5c:	ff d0                	call   *%eax
  801a5e:	89 c3                	mov    %eax,%ebx
  801a60:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a63:	83 ec 08             	sub    $0x8,%esp
  801a66:	56                   	push   %esi
  801a67:	6a 00                	push   $0x0
  801a69:	e8 92 f6 ff ff       	call   801100 <sys_page_unmap>
	return r;
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	89 d8                	mov    %ebx,%eax
}
  801a73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    

00801a7a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a83:	50                   	push   %eax
  801a84:	ff 75 08             	pushl  0x8(%ebp)
  801a87:	e8 c1 fe ff ff       	call   80194d <fd_lookup>
  801a8c:	83 c4 08             	add    $0x8,%esp
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	78 10                	js     801aa3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	6a 01                	push   $0x1
  801a98:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9b:	e8 59 ff ff ff       	call   8019f9 <fd_close>
  801aa0:	83 c4 10             	add    $0x10,%esp
}
  801aa3:	c9                   	leave  
  801aa4:	c3                   	ret    

00801aa5 <close_all>:

void
close_all(void)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801aac:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	53                   	push   %ebx
  801ab5:	e8 c0 ff ff ff       	call   801a7a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801aba:	83 c3 01             	add    $0x1,%ebx
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	83 fb 20             	cmp    $0x20,%ebx
  801ac3:	75 ec                	jne    801ab1 <close_all+0xc>
		close(i);
}
  801ac5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac8:	c9                   	leave  
  801ac9:	c3                   	ret    

00801aca <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	57                   	push   %edi
  801ace:	56                   	push   %esi
  801acf:	53                   	push   %ebx
  801ad0:	83 ec 2c             	sub    $0x2c,%esp
  801ad3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ad6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801ad9:	50                   	push   %eax
  801ada:	ff 75 08             	pushl  0x8(%ebp)
  801add:	e8 6b fe ff ff       	call   80194d <fd_lookup>
  801ae2:	83 c4 08             	add    $0x8,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	0f 88 c1 00 00 00    	js     801bae <dup+0xe4>
		return r;
	close(newfdnum);
  801aed:	83 ec 0c             	sub    $0xc,%esp
  801af0:	56                   	push   %esi
  801af1:	e8 84 ff ff ff       	call   801a7a <close>

	newfd = INDEX2FD(newfdnum);
  801af6:	89 f3                	mov    %esi,%ebx
  801af8:	c1 e3 0c             	shl    $0xc,%ebx
  801afb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801b01:	83 c4 04             	add    $0x4,%esp
  801b04:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b07:	e8 db fd ff ff       	call   8018e7 <fd2data>
  801b0c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801b0e:	89 1c 24             	mov    %ebx,(%esp)
  801b11:	e8 d1 fd ff ff       	call   8018e7 <fd2data>
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801b1c:	89 f8                	mov    %edi,%eax
  801b1e:	c1 e8 16             	shr    $0x16,%eax
  801b21:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b28:	a8 01                	test   $0x1,%al
  801b2a:	74 37                	je     801b63 <dup+0x99>
  801b2c:	89 f8                	mov    %edi,%eax
  801b2e:	c1 e8 0c             	shr    $0xc,%eax
  801b31:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801b38:	f6 c2 01             	test   $0x1,%dl
  801b3b:	74 26                	je     801b63 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801b3d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b44:	83 ec 0c             	sub    $0xc,%esp
  801b47:	25 07 0e 00 00       	and    $0xe07,%eax
  801b4c:	50                   	push   %eax
  801b4d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801b50:	6a 00                	push   $0x0
  801b52:	57                   	push   %edi
  801b53:	6a 00                	push   $0x0
  801b55:	e8 64 f5 ff ff       	call   8010be <sys_page_map>
  801b5a:	89 c7                	mov    %eax,%edi
  801b5c:	83 c4 20             	add    $0x20,%esp
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	78 2e                	js     801b91 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b63:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b66:	89 d0                	mov    %edx,%eax
  801b68:	c1 e8 0c             	shr    $0xc,%eax
  801b6b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	25 07 0e 00 00       	and    $0xe07,%eax
  801b7a:	50                   	push   %eax
  801b7b:	53                   	push   %ebx
  801b7c:	6a 00                	push   $0x0
  801b7e:	52                   	push   %edx
  801b7f:	6a 00                	push   $0x0
  801b81:	e8 38 f5 ff ff       	call   8010be <sys_page_map>
  801b86:	89 c7                	mov    %eax,%edi
  801b88:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801b8b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b8d:	85 ff                	test   %edi,%edi
  801b8f:	79 1d                	jns    801bae <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b91:	83 ec 08             	sub    $0x8,%esp
  801b94:	53                   	push   %ebx
  801b95:	6a 00                	push   $0x0
  801b97:	e8 64 f5 ff ff       	call   801100 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b9c:	83 c4 08             	add    $0x8,%esp
  801b9f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801ba2:	6a 00                	push   $0x0
  801ba4:	e8 57 f5 ff ff       	call   801100 <sys_page_unmap>
	return r;
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	89 f8                	mov    %edi,%eax
}
  801bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5f                   	pop    %edi
  801bb4:	5d                   	pop    %ebp
  801bb5:	c3                   	ret    

00801bb6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	53                   	push   %ebx
  801bba:	83 ec 14             	sub    $0x14,%esp
  801bbd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bc0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc3:	50                   	push   %eax
  801bc4:	53                   	push   %ebx
  801bc5:	e8 83 fd ff ff       	call   80194d <fd_lookup>
  801bca:	83 c4 08             	add    $0x8,%esp
  801bcd:	89 c2                	mov    %eax,%edx
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	78 70                	js     801c43 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bd3:	83 ec 08             	sub    $0x8,%esp
  801bd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd9:	50                   	push   %eax
  801bda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bdd:	ff 30                	pushl  (%eax)
  801bdf:	e8 bf fd ff ff       	call   8019a3 <dev_lookup>
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 4f                	js     801c3a <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801beb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bee:	8b 42 08             	mov    0x8(%edx),%eax
  801bf1:	83 e0 03             	and    $0x3,%eax
  801bf4:	83 f8 01             	cmp    $0x1,%eax
  801bf7:	75 24                	jne    801c1d <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801bf9:	a1 b0 50 80 00       	mov    0x8050b0,%eax
  801bfe:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	53                   	push   %ebx
  801c08:	50                   	push   %eax
  801c09:	68 fc 2f 80 00       	push   $0x802ffc
  801c0e:	e8 e0 ea ff ff       	call   8006f3 <cprintf>
		return -E_INVAL;
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c1b:	eb 26                	jmp    801c43 <read+0x8d>
	}
	if (!dev->dev_read)
  801c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c20:	8b 40 08             	mov    0x8(%eax),%eax
  801c23:	85 c0                	test   %eax,%eax
  801c25:	74 17                	je     801c3e <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801c27:	83 ec 04             	sub    $0x4,%esp
  801c2a:	ff 75 10             	pushl  0x10(%ebp)
  801c2d:	ff 75 0c             	pushl  0xc(%ebp)
  801c30:	52                   	push   %edx
  801c31:	ff d0                	call   *%eax
  801c33:	89 c2                	mov    %eax,%edx
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	eb 09                	jmp    801c43 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c3a:	89 c2                	mov    %eax,%edx
  801c3c:	eb 05                	jmp    801c43 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801c3e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801c43:	89 d0                	mov    %edx,%eax
  801c45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c48:	c9                   	leave  
  801c49:	c3                   	ret    

00801c4a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	57                   	push   %edi
  801c4e:	56                   	push   %esi
  801c4f:	53                   	push   %ebx
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c56:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c59:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c5e:	eb 21                	jmp    801c81 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c60:	83 ec 04             	sub    $0x4,%esp
  801c63:	89 f0                	mov    %esi,%eax
  801c65:	29 d8                	sub    %ebx,%eax
  801c67:	50                   	push   %eax
  801c68:	89 d8                	mov    %ebx,%eax
  801c6a:	03 45 0c             	add    0xc(%ebp),%eax
  801c6d:	50                   	push   %eax
  801c6e:	57                   	push   %edi
  801c6f:	e8 42 ff ff ff       	call   801bb6 <read>
		if (m < 0)
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	85 c0                	test   %eax,%eax
  801c79:	78 10                	js     801c8b <readn+0x41>
			return m;
		if (m == 0)
  801c7b:	85 c0                	test   %eax,%eax
  801c7d:	74 0a                	je     801c89 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c7f:	01 c3                	add    %eax,%ebx
  801c81:	39 f3                	cmp    %esi,%ebx
  801c83:	72 db                	jb     801c60 <readn+0x16>
  801c85:	89 d8                	mov    %ebx,%eax
  801c87:	eb 02                	jmp    801c8b <readn+0x41>
  801c89:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5e                   	pop    %esi
  801c90:	5f                   	pop    %edi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	53                   	push   %ebx
  801c97:	83 ec 14             	sub    $0x14,%esp
  801c9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca0:	50                   	push   %eax
  801ca1:	53                   	push   %ebx
  801ca2:	e8 a6 fc ff ff       	call   80194d <fd_lookup>
  801ca7:	83 c4 08             	add    $0x8,%esp
  801caa:	89 c2                	mov    %eax,%edx
  801cac:	85 c0                	test   %eax,%eax
  801cae:	78 6b                	js     801d1b <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cb0:	83 ec 08             	sub    $0x8,%esp
  801cb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb6:	50                   	push   %eax
  801cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cba:	ff 30                	pushl  (%eax)
  801cbc:	e8 e2 fc ff ff       	call   8019a3 <dev_lookup>
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	78 4a                	js     801d12 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ccb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ccf:	75 24                	jne    801cf5 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801cd1:	a1 b0 50 80 00       	mov    0x8050b0,%eax
  801cd6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801cdc:	83 ec 04             	sub    $0x4,%esp
  801cdf:	53                   	push   %ebx
  801ce0:	50                   	push   %eax
  801ce1:	68 18 30 80 00       	push   $0x803018
  801ce6:	e8 08 ea ff ff       	call   8006f3 <cprintf>
		return -E_INVAL;
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801cf3:	eb 26                	jmp    801d1b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801cf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf8:	8b 52 0c             	mov    0xc(%edx),%edx
  801cfb:	85 d2                	test   %edx,%edx
  801cfd:	74 17                	je     801d16 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801cff:	83 ec 04             	sub    $0x4,%esp
  801d02:	ff 75 10             	pushl  0x10(%ebp)
  801d05:	ff 75 0c             	pushl  0xc(%ebp)
  801d08:	50                   	push   %eax
  801d09:	ff d2                	call   *%edx
  801d0b:	89 c2                	mov    %eax,%edx
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	eb 09                	jmp    801d1b <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d12:	89 c2                	mov    %eax,%edx
  801d14:	eb 05                	jmp    801d1b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801d16:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <seek>:

int
seek(int fdnum, off_t offset)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d28:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801d2b:	50                   	push   %eax
  801d2c:	ff 75 08             	pushl  0x8(%ebp)
  801d2f:	e8 19 fc ff ff       	call   80194d <fd_lookup>
  801d34:	83 c4 08             	add    $0x8,%esp
  801d37:	85 c0                	test   %eax,%eax
  801d39:	78 0e                	js     801d49 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801d3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d41:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801d44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    

00801d4b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	53                   	push   %ebx
  801d4f:	83 ec 14             	sub    $0x14,%esp
  801d52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d55:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d58:	50                   	push   %eax
  801d59:	53                   	push   %ebx
  801d5a:	e8 ee fb ff ff       	call   80194d <fd_lookup>
  801d5f:	83 c4 08             	add    $0x8,%esp
  801d62:	89 c2                	mov    %eax,%edx
  801d64:	85 c0                	test   %eax,%eax
  801d66:	78 68                	js     801dd0 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d68:	83 ec 08             	sub    $0x8,%esp
  801d6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6e:	50                   	push   %eax
  801d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d72:	ff 30                	pushl  (%eax)
  801d74:	e8 2a fc ff ff       	call   8019a3 <dev_lookup>
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	78 47                	js     801dc7 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d83:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801d87:	75 24                	jne    801dad <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801d89:	a1 b0 50 80 00       	mov    0x8050b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801d8e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801d94:	83 ec 04             	sub    $0x4,%esp
  801d97:	53                   	push   %ebx
  801d98:	50                   	push   %eax
  801d99:	68 d8 2f 80 00       	push   $0x802fd8
  801d9e:	e8 50 e9 ff ff       	call   8006f3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801dab:	eb 23                	jmp    801dd0 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  801dad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801db0:	8b 52 18             	mov    0x18(%edx),%edx
  801db3:	85 d2                	test   %edx,%edx
  801db5:	74 14                	je     801dcb <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801db7:	83 ec 08             	sub    $0x8,%esp
  801dba:	ff 75 0c             	pushl  0xc(%ebp)
  801dbd:	50                   	push   %eax
  801dbe:	ff d2                	call   *%edx
  801dc0:	89 c2                	mov    %eax,%edx
  801dc2:	83 c4 10             	add    $0x10,%esp
  801dc5:	eb 09                	jmp    801dd0 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801dc7:	89 c2                	mov    %eax,%edx
  801dc9:	eb 05                	jmp    801dd0 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801dcb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801dd0:	89 d0                	mov    %edx,%eax
  801dd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd5:	c9                   	leave  
  801dd6:	c3                   	ret    

00801dd7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	53                   	push   %ebx
  801ddb:	83 ec 14             	sub    $0x14,%esp
  801dde:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801de1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801de4:	50                   	push   %eax
  801de5:	ff 75 08             	pushl  0x8(%ebp)
  801de8:	e8 60 fb ff ff       	call   80194d <fd_lookup>
  801ded:	83 c4 08             	add    $0x8,%esp
  801df0:	89 c2                	mov    %eax,%edx
  801df2:	85 c0                	test   %eax,%eax
  801df4:	78 58                	js     801e4e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801df6:	83 ec 08             	sub    $0x8,%esp
  801df9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e00:	ff 30                	pushl  (%eax)
  801e02:	e8 9c fb ff ff       	call   8019a3 <dev_lookup>
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	85 c0                	test   %eax,%eax
  801e0c:	78 37                	js     801e45 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e11:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801e15:	74 32                	je     801e49 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801e17:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801e1a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801e21:	00 00 00 
	stat->st_isdir = 0;
  801e24:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e2b:	00 00 00 
	stat->st_dev = dev;
  801e2e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801e34:	83 ec 08             	sub    $0x8,%esp
  801e37:	53                   	push   %ebx
  801e38:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3b:	ff 50 14             	call   *0x14(%eax)
  801e3e:	89 c2                	mov    %eax,%edx
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	eb 09                	jmp    801e4e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e45:	89 c2                	mov    %eax,%edx
  801e47:	eb 05                	jmp    801e4e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801e49:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801e4e:	89 d0                	mov    %edx,%eax
  801e50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    

00801e55 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	56                   	push   %esi
  801e59:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801e5a:	83 ec 08             	sub    $0x8,%esp
  801e5d:	6a 00                	push   $0x0
  801e5f:	ff 75 08             	pushl  0x8(%ebp)
  801e62:	e8 e3 01 00 00       	call   80204a <open>
  801e67:	89 c3                	mov    %eax,%ebx
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	78 1b                	js     801e8b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801e70:	83 ec 08             	sub    $0x8,%esp
  801e73:	ff 75 0c             	pushl  0xc(%ebp)
  801e76:	50                   	push   %eax
  801e77:	e8 5b ff ff ff       	call   801dd7 <fstat>
  801e7c:	89 c6                	mov    %eax,%esi
	close(fd);
  801e7e:	89 1c 24             	mov    %ebx,(%esp)
  801e81:	e8 f4 fb ff ff       	call   801a7a <close>
	return r;
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	89 f0                	mov    %esi,%eax
}
  801e8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8e:	5b                   	pop    %ebx
  801e8f:	5e                   	pop    %esi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    

00801e92 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	89 c6                	mov    %eax,%esi
  801e99:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801e9b:	83 3d ac 50 80 00 00 	cmpl   $0x0,0x8050ac
  801ea2:	75 12                	jne    801eb6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ea4:	83 ec 0c             	sub    $0xc,%esp
  801ea7:	6a 01                	push   $0x1
  801ea9:	e8 05 08 00 00       	call   8026b3 <ipc_find_env>
  801eae:	a3 ac 50 80 00       	mov    %eax,0x8050ac
  801eb3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801eb6:	6a 07                	push   $0x7
  801eb8:	68 00 60 80 00       	push   $0x806000
  801ebd:	56                   	push   %esi
  801ebe:	ff 35 ac 50 80 00    	pushl  0x8050ac
  801ec4:	e8 88 07 00 00       	call   802651 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ec9:	83 c4 0c             	add    $0xc,%esp
  801ecc:	6a 00                	push   $0x0
  801ece:	53                   	push   %ebx
  801ecf:	6a 00                	push   $0x0
  801ed1:	e8 00 07 00 00       	call   8025d6 <ipc_recv>
}
  801ed6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed9:	5b                   	pop    %ebx
  801eda:	5e                   	pop    %esi
  801edb:	5d                   	pop    %ebp
  801edc:	c3                   	ret    

00801edd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801edd:	55                   	push   %ebp
  801ede:	89 e5                	mov    %esp,%ebp
  801ee0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ee9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef1:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ef6:	ba 00 00 00 00       	mov    $0x0,%edx
  801efb:	b8 02 00 00 00       	mov    $0x2,%eax
  801f00:	e8 8d ff ff ff       	call   801e92 <fsipc>
}
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f10:	8b 40 0c             	mov    0xc(%eax),%eax
  801f13:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801f18:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1d:	b8 06 00 00 00       	mov    $0x6,%eax
  801f22:	e8 6b ff ff ff       	call   801e92 <fsipc>
}
  801f27:	c9                   	leave  
  801f28:	c3                   	ret    

00801f29 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	53                   	push   %ebx
  801f2d:	83 ec 04             	sub    $0x4,%esp
  801f30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801f33:	8b 45 08             	mov    0x8(%ebp),%eax
  801f36:	8b 40 0c             	mov    0xc(%eax),%eax
  801f39:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f43:	b8 05 00 00 00       	mov    $0x5,%eax
  801f48:	e8 45 ff ff ff       	call   801e92 <fsipc>
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	78 2c                	js     801f7d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801f51:	83 ec 08             	sub    $0x8,%esp
  801f54:	68 00 60 80 00       	push   $0x806000
  801f59:	53                   	push   %ebx
  801f5a:	e8 19 ed ff ff       	call   800c78 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801f5f:	a1 80 60 80 00       	mov    0x806080,%eax
  801f64:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801f6a:	a1 84 60 80 00       	mov    0x806084,%eax
  801f6f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f80:	c9                   	leave  
  801f81:	c3                   	ret    

00801f82 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	83 ec 0c             	sub    $0xc,%esp
  801f88:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801f8b:	8b 55 08             	mov    0x8(%ebp),%edx
  801f8e:	8b 52 0c             	mov    0xc(%edx),%edx
  801f91:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801f97:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801f9c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801fa1:	0f 47 c2             	cmova  %edx,%eax
  801fa4:	a3 04 60 80 00       	mov    %eax,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801fa9:	50                   	push   %eax
  801faa:	ff 75 0c             	pushl  0xc(%ebp)
  801fad:	68 08 60 80 00       	push   $0x806008
  801fb2:	e8 53 ee ff ff       	call   800e0a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801fb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801fbc:	b8 04 00 00 00       	mov    $0x4,%eax
  801fc1:	e8 cc fe ff ff       	call   801e92 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd3:	8b 40 0c             	mov    0xc(%eax),%eax
  801fd6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801fdb:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801fe1:	ba 00 00 00 00       	mov    $0x0,%edx
  801fe6:	b8 03 00 00 00       	mov    $0x3,%eax
  801feb:	e8 a2 fe ff ff       	call   801e92 <fsipc>
  801ff0:	89 c3                	mov    %eax,%ebx
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	78 4b                	js     802041 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ff6:	39 c6                	cmp    %eax,%esi
  801ff8:	73 16                	jae    802010 <devfile_read+0x48>
  801ffa:	68 48 30 80 00       	push   $0x803048
  801fff:	68 4f 30 80 00       	push   $0x80304f
  802004:	6a 7c                	push   $0x7c
  802006:	68 64 30 80 00       	push   $0x803064
  80200b:	e8 0a e6 ff ff       	call   80061a <_panic>
	assert(r <= PGSIZE);
  802010:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802015:	7e 16                	jle    80202d <devfile_read+0x65>
  802017:	68 6f 30 80 00       	push   $0x80306f
  80201c:	68 4f 30 80 00       	push   $0x80304f
  802021:	6a 7d                	push   $0x7d
  802023:	68 64 30 80 00       	push   $0x803064
  802028:	e8 ed e5 ff ff       	call   80061a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80202d:	83 ec 04             	sub    $0x4,%esp
  802030:	50                   	push   %eax
  802031:	68 00 60 80 00       	push   $0x806000
  802036:	ff 75 0c             	pushl  0xc(%ebp)
  802039:	e8 cc ed ff ff       	call   800e0a <memmove>
	return r;
  80203e:	83 c4 10             	add    $0x10,%esp
}
  802041:	89 d8                	mov    %ebx,%eax
  802043:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802046:	5b                   	pop    %ebx
  802047:	5e                   	pop    %esi
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    

0080204a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	53                   	push   %ebx
  80204e:	83 ec 20             	sub    $0x20,%esp
  802051:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802054:	53                   	push   %ebx
  802055:	e8 e5 eb ff ff       	call   800c3f <strlen>
  80205a:	83 c4 10             	add    $0x10,%esp
  80205d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802062:	7f 67                	jg     8020cb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802064:	83 ec 0c             	sub    $0xc,%esp
  802067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206a:	50                   	push   %eax
  80206b:	e8 8e f8 ff ff       	call   8018fe <fd_alloc>
  802070:	83 c4 10             	add    $0x10,%esp
		return r;
  802073:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802075:	85 c0                	test   %eax,%eax
  802077:	78 57                	js     8020d0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802079:	83 ec 08             	sub    $0x8,%esp
  80207c:	53                   	push   %ebx
  80207d:	68 00 60 80 00       	push   $0x806000
  802082:	e8 f1 eb ff ff       	call   800c78 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802087:	8b 45 0c             	mov    0xc(%ebp),%eax
  80208a:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80208f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802092:	b8 01 00 00 00       	mov    $0x1,%eax
  802097:	e8 f6 fd ff ff       	call   801e92 <fsipc>
  80209c:	89 c3                	mov    %eax,%ebx
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	79 14                	jns    8020b9 <open+0x6f>
		fd_close(fd, 0);
  8020a5:	83 ec 08             	sub    $0x8,%esp
  8020a8:	6a 00                	push   $0x0
  8020aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ad:	e8 47 f9 ff ff       	call   8019f9 <fd_close>
		return r;
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	89 da                	mov    %ebx,%edx
  8020b7:	eb 17                	jmp    8020d0 <open+0x86>
	}

	return fd2num(fd);
  8020b9:	83 ec 0c             	sub    $0xc,%esp
  8020bc:	ff 75 f4             	pushl  -0xc(%ebp)
  8020bf:	e8 13 f8 ff ff       	call   8018d7 <fd2num>
  8020c4:	89 c2                	mov    %eax,%edx
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	eb 05                	jmp    8020d0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8020cb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8020d0:	89 d0                	mov    %edx,%eax
  8020d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020d5:	c9                   	leave  
  8020d6:	c3                   	ret    

008020d7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8020dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8020e7:	e8 a6 fd ff ff       	call   801e92 <fsipc>
}
  8020ec:	c9                   	leave  
  8020ed:	c3                   	ret    

008020ee <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	56                   	push   %esi
  8020f2:	53                   	push   %ebx
  8020f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8020f6:	83 ec 0c             	sub    $0xc,%esp
  8020f9:	ff 75 08             	pushl  0x8(%ebp)
  8020fc:	e8 e6 f7 ff ff       	call   8018e7 <fd2data>
  802101:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802103:	83 c4 08             	add    $0x8,%esp
  802106:	68 7b 30 80 00       	push   $0x80307b
  80210b:	53                   	push   %ebx
  80210c:	e8 67 eb ff ff       	call   800c78 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802111:	8b 46 04             	mov    0x4(%esi),%eax
  802114:	2b 06                	sub    (%esi),%eax
  802116:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80211c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802123:	00 00 00 
	stat->st_dev = &devpipe;
  802126:	c7 83 88 00 00 00 20 	movl   $0x804020,0x88(%ebx)
  80212d:	40 80 00 
	return 0;
}
  802130:	b8 00 00 00 00       	mov    $0x0,%eax
  802135:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802138:	5b                   	pop    %ebx
  802139:	5e                   	pop    %esi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    

0080213c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80213c:	55                   	push   %ebp
  80213d:	89 e5                	mov    %esp,%ebp
  80213f:	53                   	push   %ebx
  802140:	83 ec 0c             	sub    $0xc,%esp
  802143:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802146:	53                   	push   %ebx
  802147:	6a 00                	push   $0x0
  802149:	e8 b2 ef ff ff       	call   801100 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80214e:	89 1c 24             	mov    %ebx,(%esp)
  802151:	e8 91 f7 ff ff       	call   8018e7 <fd2data>
  802156:	83 c4 08             	add    $0x8,%esp
  802159:	50                   	push   %eax
  80215a:	6a 00                	push   $0x0
  80215c:	e8 9f ef ff ff       	call   801100 <sys_page_unmap>
}
  802161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802164:	c9                   	leave  
  802165:	c3                   	ret    

00802166 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	57                   	push   %edi
  80216a:	56                   	push   %esi
  80216b:	53                   	push   %ebx
  80216c:	83 ec 1c             	sub    $0x1c,%esp
  80216f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802172:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802174:	a1 b0 50 80 00       	mov    0x8050b0,%eax
  802179:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80217f:	83 ec 0c             	sub    $0xc,%esp
  802182:	ff 75 e0             	pushl  -0x20(%ebp)
  802185:	e8 6e 05 00 00       	call   8026f8 <pageref>
  80218a:	89 c3                	mov    %eax,%ebx
  80218c:	89 3c 24             	mov    %edi,(%esp)
  80218f:	e8 64 05 00 00       	call   8026f8 <pageref>
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	39 c3                	cmp    %eax,%ebx
  802199:	0f 94 c1             	sete   %cl
  80219c:	0f b6 c9             	movzbl %cl,%ecx
  80219f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8021a2:	8b 15 b0 50 80 00    	mov    0x8050b0,%edx
  8021a8:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  8021ae:	39 ce                	cmp    %ecx,%esi
  8021b0:	74 1e                	je     8021d0 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8021b2:	39 c3                	cmp    %eax,%ebx
  8021b4:	75 be                	jne    802174 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021b6:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  8021bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8021bf:	50                   	push   %eax
  8021c0:	56                   	push   %esi
  8021c1:	68 82 30 80 00       	push   $0x803082
  8021c6:	e8 28 e5 ff ff       	call   8006f3 <cprintf>
  8021cb:	83 c4 10             	add    $0x10,%esp
  8021ce:	eb a4                	jmp    802174 <_pipeisclosed+0xe>
	}
}
  8021d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d6:	5b                   	pop    %ebx
  8021d7:	5e                   	pop    %esi
  8021d8:	5f                   	pop    %edi
  8021d9:	5d                   	pop    %ebp
  8021da:	c3                   	ret    

008021db <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	57                   	push   %edi
  8021df:	56                   	push   %esi
  8021e0:	53                   	push   %ebx
  8021e1:	83 ec 28             	sub    $0x28,%esp
  8021e4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8021e7:	56                   	push   %esi
  8021e8:	e8 fa f6 ff ff       	call   8018e7 <fd2data>
  8021ed:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021ef:	83 c4 10             	add    $0x10,%esp
  8021f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8021f7:	eb 4b                	jmp    802244 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8021f9:	89 da                	mov    %ebx,%edx
  8021fb:	89 f0                	mov    %esi,%eax
  8021fd:	e8 64 ff ff ff       	call   802166 <_pipeisclosed>
  802202:	85 c0                	test   %eax,%eax
  802204:	75 48                	jne    80224e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802206:	e8 51 ee ff ff       	call   80105c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80220b:	8b 43 04             	mov    0x4(%ebx),%eax
  80220e:	8b 0b                	mov    (%ebx),%ecx
  802210:	8d 51 20             	lea    0x20(%ecx),%edx
  802213:	39 d0                	cmp    %edx,%eax
  802215:	73 e2                	jae    8021f9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80221a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80221e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802221:	89 c2                	mov    %eax,%edx
  802223:	c1 fa 1f             	sar    $0x1f,%edx
  802226:	89 d1                	mov    %edx,%ecx
  802228:	c1 e9 1b             	shr    $0x1b,%ecx
  80222b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80222e:	83 e2 1f             	and    $0x1f,%edx
  802231:	29 ca                	sub    %ecx,%edx
  802233:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802237:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80223b:	83 c0 01             	add    $0x1,%eax
  80223e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802241:	83 c7 01             	add    $0x1,%edi
  802244:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802247:	75 c2                	jne    80220b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802249:	8b 45 10             	mov    0x10(%ebp),%eax
  80224c:	eb 05                	jmp    802253 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80224e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802256:	5b                   	pop    %ebx
  802257:	5e                   	pop    %esi
  802258:	5f                   	pop    %edi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    

0080225b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	57                   	push   %edi
  80225f:	56                   	push   %esi
  802260:	53                   	push   %ebx
  802261:	83 ec 18             	sub    $0x18,%esp
  802264:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802267:	57                   	push   %edi
  802268:	e8 7a f6 ff ff       	call   8018e7 <fd2data>
  80226d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80226f:	83 c4 10             	add    $0x10,%esp
  802272:	bb 00 00 00 00       	mov    $0x0,%ebx
  802277:	eb 3d                	jmp    8022b6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802279:	85 db                	test   %ebx,%ebx
  80227b:	74 04                	je     802281 <devpipe_read+0x26>
				return i;
  80227d:	89 d8                	mov    %ebx,%eax
  80227f:	eb 44                	jmp    8022c5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802281:	89 f2                	mov    %esi,%edx
  802283:	89 f8                	mov    %edi,%eax
  802285:	e8 dc fe ff ff       	call   802166 <_pipeisclosed>
  80228a:	85 c0                	test   %eax,%eax
  80228c:	75 32                	jne    8022c0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80228e:	e8 c9 ed ff ff       	call   80105c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802293:	8b 06                	mov    (%esi),%eax
  802295:	3b 46 04             	cmp    0x4(%esi),%eax
  802298:	74 df                	je     802279 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80229a:	99                   	cltd   
  80229b:	c1 ea 1b             	shr    $0x1b,%edx
  80229e:	01 d0                	add    %edx,%eax
  8022a0:	83 e0 1f             	and    $0x1f,%eax
  8022a3:	29 d0                	sub    %edx,%eax
  8022a5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8022aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022ad:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8022b0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022b3:	83 c3 01             	add    $0x1,%ebx
  8022b6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022b9:	75 d8                	jne    802293 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8022be:	eb 05                	jmp    8022c5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022c0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    

008022cd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022cd:	55                   	push   %ebp
  8022ce:	89 e5                	mov    %esp,%ebp
  8022d0:	56                   	push   %esi
  8022d1:	53                   	push   %ebx
  8022d2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d8:	50                   	push   %eax
  8022d9:	e8 20 f6 ff ff       	call   8018fe <fd_alloc>
  8022de:	83 c4 10             	add    $0x10,%esp
  8022e1:	89 c2                	mov    %eax,%edx
  8022e3:	85 c0                	test   %eax,%eax
  8022e5:	0f 88 2c 01 00 00    	js     802417 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022eb:	83 ec 04             	sub    $0x4,%esp
  8022ee:	68 07 04 00 00       	push   $0x407
  8022f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f6:	6a 00                	push   $0x0
  8022f8:	e8 7e ed ff ff       	call   80107b <sys_page_alloc>
  8022fd:	83 c4 10             	add    $0x10,%esp
  802300:	89 c2                	mov    %eax,%edx
  802302:	85 c0                	test   %eax,%eax
  802304:	0f 88 0d 01 00 00    	js     802417 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80230a:	83 ec 0c             	sub    $0xc,%esp
  80230d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802310:	50                   	push   %eax
  802311:	e8 e8 f5 ff ff       	call   8018fe <fd_alloc>
  802316:	89 c3                	mov    %eax,%ebx
  802318:	83 c4 10             	add    $0x10,%esp
  80231b:	85 c0                	test   %eax,%eax
  80231d:	0f 88 e2 00 00 00    	js     802405 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802323:	83 ec 04             	sub    $0x4,%esp
  802326:	68 07 04 00 00       	push   $0x407
  80232b:	ff 75 f0             	pushl  -0x10(%ebp)
  80232e:	6a 00                	push   $0x0
  802330:	e8 46 ed ff ff       	call   80107b <sys_page_alloc>
  802335:	89 c3                	mov    %eax,%ebx
  802337:	83 c4 10             	add    $0x10,%esp
  80233a:	85 c0                	test   %eax,%eax
  80233c:	0f 88 c3 00 00 00    	js     802405 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802342:	83 ec 0c             	sub    $0xc,%esp
  802345:	ff 75 f4             	pushl  -0xc(%ebp)
  802348:	e8 9a f5 ff ff       	call   8018e7 <fd2data>
  80234d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80234f:	83 c4 0c             	add    $0xc,%esp
  802352:	68 07 04 00 00       	push   $0x407
  802357:	50                   	push   %eax
  802358:	6a 00                	push   $0x0
  80235a:	e8 1c ed ff ff       	call   80107b <sys_page_alloc>
  80235f:	89 c3                	mov    %eax,%ebx
  802361:	83 c4 10             	add    $0x10,%esp
  802364:	85 c0                	test   %eax,%eax
  802366:	0f 88 89 00 00 00    	js     8023f5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80236c:	83 ec 0c             	sub    $0xc,%esp
  80236f:	ff 75 f0             	pushl  -0x10(%ebp)
  802372:	e8 70 f5 ff ff       	call   8018e7 <fd2data>
  802377:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80237e:	50                   	push   %eax
  80237f:	6a 00                	push   $0x0
  802381:	56                   	push   %esi
  802382:	6a 00                	push   $0x0
  802384:	e8 35 ed ff ff       	call   8010be <sys_page_map>
  802389:	89 c3                	mov    %eax,%ebx
  80238b:	83 c4 20             	add    $0x20,%esp
  80238e:	85 c0                	test   %eax,%eax
  802390:	78 55                	js     8023e7 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802392:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802398:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80239d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023a7:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8023ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023b0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023b5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023bc:	83 ec 0c             	sub    $0xc,%esp
  8023bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c2:	e8 10 f5 ff ff       	call   8018d7 <fd2num>
  8023c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023ca:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023cc:	83 c4 04             	add    $0x4,%esp
  8023cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8023d2:	e8 00 f5 ff ff       	call   8018d7 <fd2num>
  8023d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023da:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8023dd:	83 c4 10             	add    $0x10,%esp
  8023e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8023e5:	eb 30                	jmp    802417 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8023e7:	83 ec 08             	sub    $0x8,%esp
  8023ea:	56                   	push   %esi
  8023eb:	6a 00                	push   $0x0
  8023ed:	e8 0e ed ff ff       	call   801100 <sys_page_unmap>
  8023f2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8023f5:	83 ec 08             	sub    $0x8,%esp
  8023f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8023fb:	6a 00                	push   $0x0
  8023fd:	e8 fe ec ff ff       	call   801100 <sys_page_unmap>
  802402:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802405:	83 ec 08             	sub    $0x8,%esp
  802408:	ff 75 f4             	pushl  -0xc(%ebp)
  80240b:	6a 00                	push   $0x0
  80240d:	e8 ee ec ff ff       	call   801100 <sys_page_unmap>
  802412:	83 c4 10             	add    $0x10,%esp
  802415:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802417:	89 d0                	mov    %edx,%eax
  802419:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80241c:	5b                   	pop    %ebx
  80241d:	5e                   	pop    %esi
  80241e:	5d                   	pop    %ebp
  80241f:	c3                   	ret    

00802420 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802420:	55                   	push   %ebp
  802421:	89 e5                	mov    %esp,%ebp
  802423:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802426:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802429:	50                   	push   %eax
  80242a:	ff 75 08             	pushl  0x8(%ebp)
  80242d:	e8 1b f5 ff ff       	call   80194d <fd_lookup>
  802432:	83 c4 10             	add    $0x10,%esp
  802435:	85 c0                	test   %eax,%eax
  802437:	78 18                	js     802451 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802439:	83 ec 0c             	sub    $0xc,%esp
  80243c:	ff 75 f4             	pushl  -0xc(%ebp)
  80243f:	e8 a3 f4 ff ff       	call   8018e7 <fd2data>
	return _pipeisclosed(fd, p);
  802444:	89 c2                	mov    %eax,%edx
  802446:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802449:	e8 18 fd ff ff       	call   802166 <_pipeisclosed>
  80244e:	83 c4 10             	add    $0x10,%esp
}
  802451:	c9                   	leave  
  802452:	c3                   	ret    

00802453 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802453:	55                   	push   %ebp
  802454:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802456:	b8 00 00 00 00       	mov    $0x0,%eax
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    

0080245d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80245d:	55                   	push   %ebp
  80245e:	89 e5                	mov    %esp,%ebp
  802460:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802463:	68 9a 30 80 00       	push   $0x80309a
  802468:	ff 75 0c             	pushl  0xc(%ebp)
  80246b:	e8 08 e8 ff ff       	call   800c78 <strcpy>
	return 0;
}
  802470:	b8 00 00 00 00       	mov    $0x0,%eax
  802475:	c9                   	leave  
  802476:	c3                   	ret    

00802477 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802477:	55                   	push   %ebp
  802478:	89 e5                	mov    %esp,%ebp
  80247a:	57                   	push   %edi
  80247b:	56                   	push   %esi
  80247c:	53                   	push   %ebx
  80247d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802483:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802488:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80248e:	eb 2d                	jmp    8024bd <devcons_write+0x46>
		m = n - tot;
  802490:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802493:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802495:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802498:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80249d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024a0:	83 ec 04             	sub    $0x4,%esp
  8024a3:	53                   	push   %ebx
  8024a4:	03 45 0c             	add    0xc(%ebp),%eax
  8024a7:	50                   	push   %eax
  8024a8:	57                   	push   %edi
  8024a9:	e8 5c e9 ff ff       	call   800e0a <memmove>
		sys_cputs(buf, m);
  8024ae:	83 c4 08             	add    $0x8,%esp
  8024b1:	53                   	push   %ebx
  8024b2:	57                   	push   %edi
  8024b3:	e8 07 eb ff ff       	call   800fbf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024b8:	01 de                	add    %ebx,%esi
  8024ba:	83 c4 10             	add    $0x10,%esp
  8024bd:	89 f0                	mov    %esi,%eax
  8024bf:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024c2:	72 cc                	jb     802490 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024c7:	5b                   	pop    %ebx
  8024c8:	5e                   	pop    %esi
  8024c9:	5f                   	pop    %edi
  8024ca:	5d                   	pop    %ebp
  8024cb:	c3                   	ret    

008024cc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024cc:	55                   	push   %ebp
  8024cd:	89 e5                	mov    %esp,%ebp
  8024cf:	83 ec 08             	sub    $0x8,%esp
  8024d2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8024d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024db:	74 2a                	je     802507 <devcons_read+0x3b>
  8024dd:	eb 05                	jmp    8024e4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024df:	e8 78 eb ff ff       	call   80105c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8024e4:	e8 f4 ea ff ff       	call   800fdd <sys_cgetc>
  8024e9:	85 c0                	test   %eax,%eax
  8024eb:	74 f2                	je     8024df <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8024ed:	85 c0                	test   %eax,%eax
  8024ef:	78 16                	js     802507 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024f1:	83 f8 04             	cmp    $0x4,%eax
  8024f4:	74 0c                	je     802502 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8024f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024f9:	88 02                	mov    %al,(%edx)
	return 1;
  8024fb:	b8 01 00 00 00       	mov    $0x1,%eax
  802500:	eb 05                	jmp    802507 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802502:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802507:	c9                   	leave  
  802508:	c3                   	ret    

00802509 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802509:	55                   	push   %ebp
  80250a:	89 e5                	mov    %esp,%ebp
  80250c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80250f:	8b 45 08             	mov    0x8(%ebp),%eax
  802512:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802515:	6a 01                	push   $0x1
  802517:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80251a:	50                   	push   %eax
  80251b:	e8 9f ea ff ff       	call   800fbf <sys_cputs>
}
  802520:	83 c4 10             	add    $0x10,%esp
  802523:	c9                   	leave  
  802524:	c3                   	ret    

00802525 <getchar>:

int
getchar(void)
{
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
  802528:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80252b:	6a 01                	push   $0x1
  80252d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802530:	50                   	push   %eax
  802531:	6a 00                	push   $0x0
  802533:	e8 7e f6 ff ff       	call   801bb6 <read>
	if (r < 0)
  802538:	83 c4 10             	add    $0x10,%esp
  80253b:	85 c0                	test   %eax,%eax
  80253d:	78 0f                	js     80254e <getchar+0x29>
		return r;
	if (r < 1)
  80253f:	85 c0                	test   %eax,%eax
  802541:	7e 06                	jle    802549 <getchar+0x24>
		return -E_EOF;
	return c;
  802543:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802547:	eb 05                	jmp    80254e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802549:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80254e:	c9                   	leave  
  80254f:	c3                   	ret    

00802550 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802550:	55                   	push   %ebp
  802551:	89 e5                	mov    %esp,%ebp
  802553:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802556:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802559:	50                   	push   %eax
  80255a:	ff 75 08             	pushl  0x8(%ebp)
  80255d:	e8 eb f3 ff ff       	call   80194d <fd_lookup>
  802562:	83 c4 10             	add    $0x10,%esp
  802565:	85 c0                	test   %eax,%eax
  802567:	78 11                	js     80257a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802569:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80256c:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802572:	39 10                	cmp    %edx,(%eax)
  802574:	0f 94 c0             	sete   %al
  802577:	0f b6 c0             	movzbl %al,%eax
}
  80257a:	c9                   	leave  
  80257b:	c3                   	ret    

0080257c <opencons>:

int
opencons(void)
{
  80257c:	55                   	push   %ebp
  80257d:	89 e5                	mov    %esp,%ebp
  80257f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802582:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802585:	50                   	push   %eax
  802586:	e8 73 f3 ff ff       	call   8018fe <fd_alloc>
  80258b:	83 c4 10             	add    $0x10,%esp
		return r;
  80258e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802590:	85 c0                	test   %eax,%eax
  802592:	78 3e                	js     8025d2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802594:	83 ec 04             	sub    $0x4,%esp
  802597:	68 07 04 00 00       	push   $0x407
  80259c:	ff 75 f4             	pushl  -0xc(%ebp)
  80259f:	6a 00                	push   $0x0
  8025a1:	e8 d5 ea ff ff       	call   80107b <sys_page_alloc>
  8025a6:	83 c4 10             	add    $0x10,%esp
		return r;
  8025a9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025ab:	85 c0                	test   %eax,%eax
  8025ad:	78 23                	js     8025d2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8025af:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8025b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025b8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025bd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025c4:	83 ec 0c             	sub    $0xc,%esp
  8025c7:	50                   	push   %eax
  8025c8:	e8 0a f3 ff ff       	call   8018d7 <fd2num>
  8025cd:	89 c2                	mov    %eax,%edx
  8025cf:	83 c4 10             	add    $0x10,%esp
}
  8025d2:	89 d0                	mov    %edx,%eax
  8025d4:	c9                   	leave  
  8025d5:	c3                   	ret    

008025d6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025d6:	55                   	push   %ebp
  8025d7:	89 e5                	mov    %esp,%ebp
  8025d9:	56                   	push   %esi
  8025da:	53                   	push   %ebx
  8025db:	8b 75 08             	mov    0x8(%ebp),%esi
  8025de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	75 12                	jne    8025fa <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8025e8:	83 ec 0c             	sub    $0xc,%esp
  8025eb:	68 00 00 c0 ee       	push   $0xeec00000
  8025f0:	e8 36 ec ff ff       	call   80122b <sys_ipc_recv>
  8025f5:	83 c4 10             	add    $0x10,%esp
  8025f8:	eb 0c                	jmp    802606 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8025fa:	83 ec 0c             	sub    $0xc,%esp
  8025fd:	50                   	push   %eax
  8025fe:	e8 28 ec ff ff       	call   80122b <sys_ipc_recv>
  802603:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802606:	85 f6                	test   %esi,%esi
  802608:	0f 95 c1             	setne  %cl
  80260b:	85 db                	test   %ebx,%ebx
  80260d:	0f 95 c2             	setne  %dl
  802610:	84 d1                	test   %dl,%cl
  802612:	74 09                	je     80261d <ipc_recv+0x47>
  802614:	89 c2                	mov    %eax,%edx
  802616:	c1 ea 1f             	shr    $0x1f,%edx
  802619:	84 d2                	test   %dl,%dl
  80261b:	75 2d                	jne    80264a <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80261d:	85 f6                	test   %esi,%esi
  80261f:	74 0d                	je     80262e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802621:	a1 b0 50 80 00       	mov    0x8050b0,%eax
  802626:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80262c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80262e:	85 db                	test   %ebx,%ebx
  802630:	74 0d                	je     80263f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802632:	a1 b0 50 80 00       	mov    0x8050b0,%eax
  802637:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80263d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80263f:	a1 b0 50 80 00       	mov    0x8050b0,%eax
  802644:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  80264a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80264d:	5b                   	pop    %ebx
  80264e:	5e                   	pop    %esi
  80264f:	5d                   	pop    %ebp
  802650:	c3                   	ret    

00802651 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802651:	55                   	push   %ebp
  802652:	89 e5                	mov    %esp,%ebp
  802654:	57                   	push   %edi
  802655:	56                   	push   %esi
  802656:	53                   	push   %ebx
  802657:	83 ec 0c             	sub    $0xc,%esp
  80265a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80265d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802660:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802663:	85 db                	test   %ebx,%ebx
  802665:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80266a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80266d:	ff 75 14             	pushl  0x14(%ebp)
  802670:	53                   	push   %ebx
  802671:	56                   	push   %esi
  802672:	57                   	push   %edi
  802673:	e8 90 eb ff ff       	call   801208 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802678:	89 c2                	mov    %eax,%edx
  80267a:	c1 ea 1f             	shr    $0x1f,%edx
  80267d:	83 c4 10             	add    $0x10,%esp
  802680:	84 d2                	test   %dl,%dl
  802682:	74 17                	je     80269b <ipc_send+0x4a>
  802684:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802687:	74 12                	je     80269b <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802689:	50                   	push   %eax
  80268a:	68 a6 30 80 00       	push   $0x8030a6
  80268f:	6a 47                	push   $0x47
  802691:	68 b4 30 80 00       	push   $0x8030b4
  802696:	e8 7f df ff ff       	call   80061a <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80269b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80269e:	75 07                	jne    8026a7 <ipc_send+0x56>
			sys_yield();
  8026a0:	e8 b7 e9 ff ff       	call   80105c <sys_yield>
  8026a5:	eb c6                	jmp    80266d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8026a7:	85 c0                	test   %eax,%eax
  8026a9:	75 c2                	jne    80266d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8026ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026ae:	5b                   	pop    %ebx
  8026af:	5e                   	pop    %esi
  8026b0:	5f                   	pop    %edi
  8026b1:	5d                   	pop    %ebp
  8026b2:	c3                   	ret    

008026b3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026b3:	55                   	push   %ebp
  8026b4:	89 e5                	mov    %esp,%ebp
  8026b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8026b9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026be:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  8026c4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026ca:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  8026d0:	39 ca                	cmp    %ecx,%edx
  8026d2:	75 13                	jne    8026e7 <ipc_find_env+0x34>
			return envs[i].env_id;
  8026d4:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8026da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8026df:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8026e5:	eb 0f                	jmp    8026f6 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026e7:	83 c0 01             	add    $0x1,%eax
  8026ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026ef:	75 cd                	jne    8026be <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8026f6:	5d                   	pop    %ebp
  8026f7:	c3                   	ret    

008026f8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026f8:	55                   	push   %ebp
  8026f9:	89 e5                	mov    %esp,%ebp
  8026fb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026fe:	89 d0                	mov    %edx,%eax
  802700:	c1 e8 16             	shr    $0x16,%eax
  802703:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80270a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80270f:	f6 c1 01             	test   $0x1,%cl
  802712:	74 1d                	je     802731 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802714:	c1 ea 0c             	shr    $0xc,%edx
  802717:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80271e:	f6 c2 01             	test   $0x1,%dl
  802721:	74 0e                	je     802731 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802723:	c1 ea 0c             	shr    $0xc,%edx
  802726:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80272d:	ef 
  80272e:	0f b7 c0             	movzwl %ax,%eax
}
  802731:	5d                   	pop    %ebp
  802732:	c3                   	ret    
  802733:	66 90                	xchg   %ax,%ax
  802735:	66 90                	xchg   %ax,%ax
  802737:	66 90                	xchg   %ax,%ax
  802739:	66 90                	xchg   %ax,%ax
  80273b:	66 90                	xchg   %ax,%ax
  80273d:	66 90                	xchg   %ax,%ax
  80273f:	90                   	nop

00802740 <__udivdi3>:
  802740:	55                   	push   %ebp
  802741:	57                   	push   %edi
  802742:	56                   	push   %esi
  802743:	53                   	push   %ebx
  802744:	83 ec 1c             	sub    $0x1c,%esp
  802747:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80274b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80274f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802753:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802757:	85 f6                	test   %esi,%esi
  802759:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80275d:	89 ca                	mov    %ecx,%edx
  80275f:	89 f8                	mov    %edi,%eax
  802761:	75 3d                	jne    8027a0 <__udivdi3+0x60>
  802763:	39 cf                	cmp    %ecx,%edi
  802765:	0f 87 c5 00 00 00    	ja     802830 <__udivdi3+0xf0>
  80276b:	85 ff                	test   %edi,%edi
  80276d:	89 fd                	mov    %edi,%ebp
  80276f:	75 0b                	jne    80277c <__udivdi3+0x3c>
  802771:	b8 01 00 00 00       	mov    $0x1,%eax
  802776:	31 d2                	xor    %edx,%edx
  802778:	f7 f7                	div    %edi
  80277a:	89 c5                	mov    %eax,%ebp
  80277c:	89 c8                	mov    %ecx,%eax
  80277e:	31 d2                	xor    %edx,%edx
  802780:	f7 f5                	div    %ebp
  802782:	89 c1                	mov    %eax,%ecx
  802784:	89 d8                	mov    %ebx,%eax
  802786:	89 cf                	mov    %ecx,%edi
  802788:	f7 f5                	div    %ebp
  80278a:	89 c3                	mov    %eax,%ebx
  80278c:	89 d8                	mov    %ebx,%eax
  80278e:	89 fa                	mov    %edi,%edx
  802790:	83 c4 1c             	add    $0x1c,%esp
  802793:	5b                   	pop    %ebx
  802794:	5e                   	pop    %esi
  802795:	5f                   	pop    %edi
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    
  802798:	90                   	nop
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	39 ce                	cmp    %ecx,%esi
  8027a2:	77 74                	ja     802818 <__udivdi3+0xd8>
  8027a4:	0f bd fe             	bsr    %esi,%edi
  8027a7:	83 f7 1f             	xor    $0x1f,%edi
  8027aa:	0f 84 98 00 00 00    	je     802848 <__udivdi3+0x108>
  8027b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8027b5:	89 f9                	mov    %edi,%ecx
  8027b7:	89 c5                	mov    %eax,%ebp
  8027b9:	29 fb                	sub    %edi,%ebx
  8027bb:	d3 e6                	shl    %cl,%esi
  8027bd:	89 d9                	mov    %ebx,%ecx
  8027bf:	d3 ed                	shr    %cl,%ebp
  8027c1:	89 f9                	mov    %edi,%ecx
  8027c3:	d3 e0                	shl    %cl,%eax
  8027c5:	09 ee                	or     %ebp,%esi
  8027c7:	89 d9                	mov    %ebx,%ecx
  8027c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8027cd:	89 d5                	mov    %edx,%ebp
  8027cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027d3:	d3 ed                	shr    %cl,%ebp
  8027d5:	89 f9                	mov    %edi,%ecx
  8027d7:	d3 e2                	shl    %cl,%edx
  8027d9:	89 d9                	mov    %ebx,%ecx
  8027db:	d3 e8                	shr    %cl,%eax
  8027dd:	09 c2                	or     %eax,%edx
  8027df:	89 d0                	mov    %edx,%eax
  8027e1:	89 ea                	mov    %ebp,%edx
  8027e3:	f7 f6                	div    %esi
  8027e5:	89 d5                	mov    %edx,%ebp
  8027e7:	89 c3                	mov    %eax,%ebx
  8027e9:	f7 64 24 0c          	mull   0xc(%esp)
  8027ed:	39 d5                	cmp    %edx,%ebp
  8027ef:	72 10                	jb     802801 <__udivdi3+0xc1>
  8027f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8027f5:	89 f9                	mov    %edi,%ecx
  8027f7:	d3 e6                	shl    %cl,%esi
  8027f9:	39 c6                	cmp    %eax,%esi
  8027fb:	73 07                	jae    802804 <__udivdi3+0xc4>
  8027fd:	39 d5                	cmp    %edx,%ebp
  8027ff:	75 03                	jne    802804 <__udivdi3+0xc4>
  802801:	83 eb 01             	sub    $0x1,%ebx
  802804:	31 ff                	xor    %edi,%edi
  802806:	89 d8                	mov    %ebx,%eax
  802808:	89 fa                	mov    %edi,%edx
  80280a:	83 c4 1c             	add    $0x1c,%esp
  80280d:	5b                   	pop    %ebx
  80280e:	5e                   	pop    %esi
  80280f:	5f                   	pop    %edi
  802810:	5d                   	pop    %ebp
  802811:	c3                   	ret    
  802812:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802818:	31 ff                	xor    %edi,%edi
  80281a:	31 db                	xor    %ebx,%ebx
  80281c:	89 d8                	mov    %ebx,%eax
  80281e:	89 fa                	mov    %edi,%edx
  802820:	83 c4 1c             	add    $0x1c,%esp
  802823:	5b                   	pop    %ebx
  802824:	5e                   	pop    %esi
  802825:	5f                   	pop    %edi
  802826:	5d                   	pop    %ebp
  802827:	c3                   	ret    
  802828:	90                   	nop
  802829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802830:	89 d8                	mov    %ebx,%eax
  802832:	f7 f7                	div    %edi
  802834:	31 ff                	xor    %edi,%edi
  802836:	89 c3                	mov    %eax,%ebx
  802838:	89 d8                	mov    %ebx,%eax
  80283a:	89 fa                	mov    %edi,%edx
  80283c:	83 c4 1c             	add    $0x1c,%esp
  80283f:	5b                   	pop    %ebx
  802840:	5e                   	pop    %esi
  802841:	5f                   	pop    %edi
  802842:	5d                   	pop    %ebp
  802843:	c3                   	ret    
  802844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802848:	39 ce                	cmp    %ecx,%esi
  80284a:	72 0c                	jb     802858 <__udivdi3+0x118>
  80284c:	31 db                	xor    %ebx,%ebx
  80284e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802852:	0f 87 34 ff ff ff    	ja     80278c <__udivdi3+0x4c>
  802858:	bb 01 00 00 00       	mov    $0x1,%ebx
  80285d:	e9 2a ff ff ff       	jmp    80278c <__udivdi3+0x4c>
  802862:	66 90                	xchg   %ax,%ax
  802864:	66 90                	xchg   %ax,%ax
  802866:	66 90                	xchg   %ax,%ax
  802868:	66 90                	xchg   %ax,%ax
  80286a:	66 90                	xchg   %ax,%ax
  80286c:	66 90                	xchg   %ax,%ax
  80286e:	66 90                	xchg   %ax,%ax

00802870 <__umoddi3>:
  802870:	55                   	push   %ebp
  802871:	57                   	push   %edi
  802872:	56                   	push   %esi
  802873:	53                   	push   %ebx
  802874:	83 ec 1c             	sub    $0x1c,%esp
  802877:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80287b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80287f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802883:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802887:	85 d2                	test   %edx,%edx
  802889:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80288d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802891:	89 f3                	mov    %esi,%ebx
  802893:	89 3c 24             	mov    %edi,(%esp)
  802896:	89 74 24 04          	mov    %esi,0x4(%esp)
  80289a:	75 1c                	jne    8028b8 <__umoddi3+0x48>
  80289c:	39 f7                	cmp    %esi,%edi
  80289e:	76 50                	jbe    8028f0 <__umoddi3+0x80>
  8028a0:	89 c8                	mov    %ecx,%eax
  8028a2:	89 f2                	mov    %esi,%edx
  8028a4:	f7 f7                	div    %edi
  8028a6:	89 d0                	mov    %edx,%eax
  8028a8:	31 d2                	xor    %edx,%edx
  8028aa:	83 c4 1c             	add    $0x1c,%esp
  8028ad:	5b                   	pop    %ebx
  8028ae:	5e                   	pop    %esi
  8028af:	5f                   	pop    %edi
  8028b0:	5d                   	pop    %ebp
  8028b1:	c3                   	ret    
  8028b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028b8:	39 f2                	cmp    %esi,%edx
  8028ba:	89 d0                	mov    %edx,%eax
  8028bc:	77 52                	ja     802910 <__umoddi3+0xa0>
  8028be:	0f bd ea             	bsr    %edx,%ebp
  8028c1:	83 f5 1f             	xor    $0x1f,%ebp
  8028c4:	75 5a                	jne    802920 <__umoddi3+0xb0>
  8028c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8028ca:	0f 82 e0 00 00 00    	jb     8029b0 <__umoddi3+0x140>
  8028d0:	39 0c 24             	cmp    %ecx,(%esp)
  8028d3:	0f 86 d7 00 00 00    	jbe    8029b0 <__umoddi3+0x140>
  8028d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8028dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028e1:	83 c4 1c             	add    $0x1c,%esp
  8028e4:	5b                   	pop    %ebx
  8028e5:	5e                   	pop    %esi
  8028e6:	5f                   	pop    %edi
  8028e7:	5d                   	pop    %ebp
  8028e8:	c3                   	ret    
  8028e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028f0:	85 ff                	test   %edi,%edi
  8028f2:	89 fd                	mov    %edi,%ebp
  8028f4:	75 0b                	jne    802901 <__umoddi3+0x91>
  8028f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8028fb:	31 d2                	xor    %edx,%edx
  8028fd:	f7 f7                	div    %edi
  8028ff:	89 c5                	mov    %eax,%ebp
  802901:	89 f0                	mov    %esi,%eax
  802903:	31 d2                	xor    %edx,%edx
  802905:	f7 f5                	div    %ebp
  802907:	89 c8                	mov    %ecx,%eax
  802909:	f7 f5                	div    %ebp
  80290b:	89 d0                	mov    %edx,%eax
  80290d:	eb 99                	jmp    8028a8 <__umoddi3+0x38>
  80290f:	90                   	nop
  802910:	89 c8                	mov    %ecx,%eax
  802912:	89 f2                	mov    %esi,%edx
  802914:	83 c4 1c             	add    $0x1c,%esp
  802917:	5b                   	pop    %ebx
  802918:	5e                   	pop    %esi
  802919:	5f                   	pop    %edi
  80291a:	5d                   	pop    %ebp
  80291b:	c3                   	ret    
  80291c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802920:	8b 34 24             	mov    (%esp),%esi
  802923:	bf 20 00 00 00       	mov    $0x20,%edi
  802928:	89 e9                	mov    %ebp,%ecx
  80292a:	29 ef                	sub    %ebp,%edi
  80292c:	d3 e0                	shl    %cl,%eax
  80292e:	89 f9                	mov    %edi,%ecx
  802930:	89 f2                	mov    %esi,%edx
  802932:	d3 ea                	shr    %cl,%edx
  802934:	89 e9                	mov    %ebp,%ecx
  802936:	09 c2                	or     %eax,%edx
  802938:	89 d8                	mov    %ebx,%eax
  80293a:	89 14 24             	mov    %edx,(%esp)
  80293d:	89 f2                	mov    %esi,%edx
  80293f:	d3 e2                	shl    %cl,%edx
  802941:	89 f9                	mov    %edi,%ecx
  802943:	89 54 24 04          	mov    %edx,0x4(%esp)
  802947:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80294b:	d3 e8                	shr    %cl,%eax
  80294d:	89 e9                	mov    %ebp,%ecx
  80294f:	89 c6                	mov    %eax,%esi
  802951:	d3 e3                	shl    %cl,%ebx
  802953:	89 f9                	mov    %edi,%ecx
  802955:	89 d0                	mov    %edx,%eax
  802957:	d3 e8                	shr    %cl,%eax
  802959:	89 e9                	mov    %ebp,%ecx
  80295b:	09 d8                	or     %ebx,%eax
  80295d:	89 d3                	mov    %edx,%ebx
  80295f:	89 f2                	mov    %esi,%edx
  802961:	f7 34 24             	divl   (%esp)
  802964:	89 d6                	mov    %edx,%esi
  802966:	d3 e3                	shl    %cl,%ebx
  802968:	f7 64 24 04          	mull   0x4(%esp)
  80296c:	39 d6                	cmp    %edx,%esi
  80296e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802972:	89 d1                	mov    %edx,%ecx
  802974:	89 c3                	mov    %eax,%ebx
  802976:	72 08                	jb     802980 <__umoddi3+0x110>
  802978:	75 11                	jne    80298b <__umoddi3+0x11b>
  80297a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80297e:	73 0b                	jae    80298b <__umoddi3+0x11b>
  802980:	2b 44 24 04          	sub    0x4(%esp),%eax
  802984:	1b 14 24             	sbb    (%esp),%edx
  802987:	89 d1                	mov    %edx,%ecx
  802989:	89 c3                	mov    %eax,%ebx
  80298b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80298f:	29 da                	sub    %ebx,%edx
  802991:	19 ce                	sbb    %ecx,%esi
  802993:	89 f9                	mov    %edi,%ecx
  802995:	89 f0                	mov    %esi,%eax
  802997:	d3 e0                	shl    %cl,%eax
  802999:	89 e9                	mov    %ebp,%ecx
  80299b:	d3 ea                	shr    %cl,%edx
  80299d:	89 e9                	mov    %ebp,%ecx
  80299f:	d3 ee                	shr    %cl,%esi
  8029a1:	09 d0                	or     %edx,%eax
  8029a3:	89 f2                	mov    %esi,%edx
  8029a5:	83 c4 1c             	add    $0x1c,%esp
  8029a8:	5b                   	pop    %ebx
  8029a9:	5e                   	pop    %esi
  8029aa:	5f                   	pop    %edi
  8029ab:	5d                   	pop    %ebp
  8029ac:	c3                   	ret    
  8029ad:	8d 76 00             	lea    0x0(%esi),%esi
  8029b0:	29 f9                	sub    %edi,%ecx
  8029b2:	19 d6                	sbb    %edx,%esi
  8029b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029bc:	e9 18 ff ff ff       	jmp    8028d9 <__umoddi3+0x69>
