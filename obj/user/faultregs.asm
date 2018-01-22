
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
  800044:	68 71 24 80 00       	push   $0x802471
  800049:	68 40 24 80 00       	push   $0x802440
  80004e:	e8 dd 06 00 00       	call   800730 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 50 24 80 00       	push   $0x802450
  80005c:	68 54 24 80 00       	push   $0x802454
  800061:	e8 ca 06 00 00       	call   800730 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 64 24 80 00       	push   $0x802464
  800077:	e8 b4 06 00 00       	call   800730 <cprintf>
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
  800089:	68 68 24 80 00       	push   $0x802468
  80008e:	e8 9d 06 00 00       	call   800730 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 72 24 80 00       	push   $0x802472
  8000a6:	68 54 24 80 00       	push   $0x802454
  8000ab:	e8 80 06 00 00       	call   800730 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 64 24 80 00       	push   $0x802464
  8000c3:	e8 68 06 00 00       	call   800730 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 68 24 80 00       	push   $0x802468
  8000d5:	e8 56 06 00 00       	call   800730 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 76 24 80 00       	push   $0x802476
  8000ed:	68 54 24 80 00       	push   $0x802454
  8000f2:	e8 39 06 00 00       	call   800730 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 64 24 80 00       	push   $0x802464
  80010a:	e8 21 06 00 00       	call   800730 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 68 24 80 00       	push   $0x802468
  80011c:	e8 0f 06 00 00       	call   800730 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 7a 24 80 00       	push   $0x80247a
  800134:	68 54 24 80 00       	push   $0x802454
  800139:	e8 f2 05 00 00       	call   800730 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 64 24 80 00       	push   $0x802464
  800151:	e8 da 05 00 00       	call   800730 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 68 24 80 00       	push   $0x802468
  800163:	e8 c8 05 00 00       	call   800730 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 7e 24 80 00       	push   $0x80247e
  80017b:	68 54 24 80 00       	push   $0x802454
  800180:	e8 ab 05 00 00       	call   800730 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 64 24 80 00       	push   $0x802464
  800198:	e8 93 05 00 00       	call   800730 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 68 24 80 00       	push   $0x802468
  8001aa:	e8 81 05 00 00       	call   800730 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 82 24 80 00       	push   $0x802482
  8001c2:	68 54 24 80 00       	push   $0x802454
  8001c7:	e8 64 05 00 00       	call   800730 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 64 24 80 00       	push   $0x802464
  8001df:	e8 4c 05 00 00       	call   800730 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 68 24 80 00       	push   $0x802468
  8001f1:	e8 3a 05 00 00       	call   800730 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 86 24 80 00       	push   $0x802486
  800209:	68 54 24 80 00       	push   $0x802454
  80020e:	e8 1d 05 00 00       	call   800730 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 64 24 80 00       	push   $0x802464
  800226:	e8 05 05 00 00       	call   800730 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 68 24 80 00       	push   $0x802468
  800238:	e8 f3 04 00 00       	call   800730 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 8a 24 80 00       	push   $0x80248a
  800250:	68 54 24 80 00       	push   $0x802454
  800255:	e8 d6 04 00 00       	call   800730 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 64 24 80 00       	push   $0x802464
  80026d:	e8 be 04 00 00       	call   800730 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 68 24 80 00       	push   $0x802468
  80027f:	e8 ac 04 00 00       	call   800730 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 8e 24 80 00       	push   $0x80248e
  800297:	68 54 24 80 00       	push   $0x802454
  80029c:	e8 8f 04 00 00       	call   800730 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 64 24 80 00       	push   $0x802464
  8002b4:	e8 77 04 00 00       	call   800730 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 95 24 80 00       	push   $0x802495
  8002c4:	68 54 24 80 00       	push   $0x802454
  8002c9:	e8 62 04 00 00       	call   800730 <cprintf>
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
  8002de:	68 68 24 80 00       	push   $0x802468
  8002e3:	e8 48 04 00 00       	call   800730 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 95 24 80 00       	push   $0x802495
  8002f3:	68 54 24 80 00       	push   $0x802454
  8002f8:	e8 33 04 00 00       	call   800730 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 64 24 80 00       	push   $0x802464
  800312:	e8 19 04 00 00       	call   800730 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 99 24 80 00       	push   $0x802499
  800322:	e8 09 04 00 00       	call   800730 <cprintf>
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
  800333:	68 68 24 80 00       	push   $0x802468
  800338:	e8 f3 03 00 00       	call   800730 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 99 24 80 00       	push   $0x802499
  800348:	e8 e3 03 00 00       	call   800730 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 64 24 80 00       	push   $0x802464
  80035a:	e8 d1 03 00 00       	call   800730 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 68 24 80 00       	push   $0x802468
  80036c:	e8 bf 03 00 00       	call   800730 <cprintf>
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
  800379:	68 64 24 80 00       	push   $0x802464
  80037e:	e8 ad 03 00 00       	call   800730 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 99 24 80 00       	push   $0x802499
  80038e:	e8 9d 03 00 00       	call   800730 <cprintf>
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
  8003ba:	68 00 25 80 00       	push   $0x802500
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 a7 24 80 00       	push   $0x8024a7
  8003c6:	e8 8c 02 00 00       	call   800657 <_panic>
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
  800436:	68 bf 24 80 00       	push   $0x8024bf
  80043b:	68 cd 24 80 00       	push   $0x8024cd
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba b8 24 80 00       	mov    $0x8024b8,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 53 0c 00 00       	call   8010b8 <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 d4 24 80 00       	push   $0x8024d4
  800472:	6a 5c                	push   $0x5c
  800474:	68 a7 24 80 00       	push   $0x8024a7
  800479:	e8 d9 01 00 00       	call   800657 <_panic>
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
  80048b:	e8 39 0e 00 00       	call   8012c9 <set_pgfault_handler>

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
  80055a:	68 34 25 80 00       	push   $0x802534
  80055f:	e8 cc 01 00 00       	call   800730 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 e7 24 80 00       	push   $0x8024e7
  800579:	68 f8 24 80 00       	push   $0x8024f8
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba b8 24 80 00       	mov    $0x8024b8,%edx
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
  80059a:	57                   	push   %edi
  80059b:	56                   	push   %esi
  80059c:	53                   	push   %ebx
  80059d:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8005a0:	c7 05 b0 40 80 00 00 	movl   $0x0,0x8040b0
  8005a7:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8005aa:	e8 cb 0a 00 00       	call   80107a <sys_getenvid>
  8005af:	89 c3                	mov    %eax,%ebx
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	50                   	push   %eax
  8005b5:	68 54 25 80 00       	push   $0x802554
  8005ba:	e8 71 01 00 00       	call   800730 <cprintf>
  8005bf:	8b 3d b0 40 80 00    	mov    0x8040b0,%edi
  8005c5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8005d2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_id == cur_env_id) {
  8005d7:	89 c1                	mov    %eax,%ecx
  8005d9:	c1 e1 07             	shl    $0x7,%ecx
  8005dc:	8d 8c 81 00 00 c0 ee 	lea    -0x11400000(%ecx,%eax,4),%ecx
  8005e3:	8b 49 50             	mov    0x50(%ecx),%ecx
			thisenv = &envs[i];
  8005e6:	39 cb                	cmp    %ecx,%ebx
  8005e8:	0f 44 fa             	cmove  %edx,%edi
  8005eb:	b9 01 00 00 00       	mov    $0x1,%ecx
  8005f0:	0f 44 f1             	cmove  %ecx,%esi
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	cprintf("IN LIBMAIN, CURENV ENV ID: %d\n", cur_env_id);
	size_t i;
	for (i = 0; i < NENV; i++) {
  8005f3:	83 c0 01             	add    $0x1,%eax
  8005f6:	81 c2 84 00 00 00    	add    $0x84,%edx
  8005fc:	3d 00 04 00 00       	cmp    $0x400,%eax
  800601:	75 d4                	jne    8005d7 <libmain+0x40>
  800603:	89 f0                	mov    %esi,%eax
  800605:	84 c0                	test   %al,%al
  800607:	74 06                	je     80060f <libmain+0x78>
  800609:	89 3d b0 40 80 00    	mov    %edi,0x8040b0
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80060f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800613:	7e 0a                	jle    80061f <libmain+0x88>
		binaryname = argv[0];
  800615:	8b 45 0c             	mov    0xc(%ebp),%eax
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	ff 75 0c             	pushl  0xc(%ebp)
  800625:	ff 75 08             	pushl  0x8(%ebp)
  800628:	e8 53 fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  80062d:	e8 0b 00 00 00       	call   80063d <exit>
}
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800638:	5b                   	pop    %ebx
  800639:	5e                   	pop    %esi
  80063a:	5f                   	pop    %edi
  80063b:	5d                   	pop    %ebp
  80063c:	c3                   	ret    

0080063d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800643:	e8 db 0e 00 00       	call   801523 <close_all>
	sys_env_destroy(0);
  800648:	83 ec 0c             	sub    $0xc,%esp
  80064b:	6a 00                	push   $0x0
  80064d:	e8 e7 09 00 00       	call   801039 <sys_env_destroy>
}
  800652:	83 c4 10             	add    $0x10,%esp
  800655:	c9                   	leave  
  800656:	c3                   	ret    

00800657 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	56                   	push   %esi
  80065b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80065c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80065f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800665:	e8 10 0a 00 00       	call   80107a <sys_getenvid>
  80066a:	83 ec 0c             	sub    $0xc,%esp
  80066d:	ff 75 0c             	pushl  0xc(%ebp)
  800670:	ff 75 08             	pushl  0x8(%ebp)
  800673:	56                   	push   %esi
  800674:	50                   	push   %eax
  800675:	68 80 25 80 00       	push   $0x802580
  80067a:	e8 b1 00 00 00       	call   800730 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80067f:	83 c4 18             	add    $0x18,%esp
  800682:	53                   	push   %ebx
  800683:	ff 75 10             	pushl  0x10(%ebp)
  800686:	e8 54 00 00 00       	call   8006df <vcprintf>
	cprintf("\n");
  80068b:	c7 04 24 70 24 80 00 	movl   $0x802470,(%esp)
  800692:	e8 99 00 00 00       	call   800730 <cprintf>
  800697:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80069a:	cc                   	int3   
  80069b:	eb fd                	jmp    80069a <_panic+0x43>

0080069d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	53                   	push   %ebx
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006a7:	8b 13                	mov    (%ebx),%edx
  8006a9:	8d 42 01             	lea    0x1(%edx),%eax
  8006ac:	89 03                	mov    %eax,(%ebx)
  8006ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006b5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006ba:	75 1a                	jne    8006d6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	68 ff 00 00 00       	push   $0xff
  8006c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8006c7:	50                   	push   %eax
  8006c8:	e8 2f 09 00 00       	call   800ffc <sys_cputs>
		b->idx = 0;
  8006cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006d3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8006d6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006ef:	00 00 00 
	b.cnt = 0;
  8006f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006fc:	ff 75 0c             	pushl  0xc(%ebp)
  8006ff:	ff 75 08             	pushl  0x8(%ebp)
  800702:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	68 9d 06 80 00       	push   $0x80069d
  80070e:	e8 54 01 00 00       	call   800867 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800713:	83 c4 08             	add    $0x8,%esp
  800716:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80071c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800722:	50                   	push   %eax
  800723:	e8 d4 08 00 00       	call   800ffc <sys_cputs>

	return b.cnt;
}
  800728:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800736:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800739:	50                   	push   %eax
  80073a:	ff 75 08             	pushl  0x8(%ebp)
  80073d:	e8 9d ff ff ff       	call   8006df <vcprintf>
	va_end(ap);

	return cnt;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	57                   	push   %edi
  800748:	56                   	push   %esi
  800749:	53                   	push   %ebx
  80074a:	83 ec 1c             	sub    $0x1c,%esp
  80074d:	89 c7                	mov    %eax,%edi
  80074f:	89 d6                	mov    %edx,%esi
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
  800757:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80075d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800760:	bb 00 00 00 00       	mov    $0x0,%ebx
  800765:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800768:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80076b:	39 d3                	cmp    %edx,%ebx
  80076d:	72 05                	jb     800774 <printnum+0x30>
  80076f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800772:	77 45                	ja     8007b9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800774:	83 ec 0c             	sub    $0xc,%esp
  800777:	ff 75 18             	pushl  0x18(%ebp)
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800780:	53                   	push   %ebx
  800781:	ff 75 10             	pushl  0x10(%ebp)
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	ff 75 e4             	pushl  -0x1c(%ebp)
  80078a:	ff 75 e0             	pushl  -0x20(%ebp)
  80078d:	ff 75 dc             	pushl  -0x24(%ebp)
  800790:	ff 75 d8             	pushl  -0x28(%ebp)
  800793:	e8 08 1a 00 00       	call   8021a0 <__udivdi3>
  800798:	83 c4 18             	add    $0x18,%esp
  80079b:	52                   	push   %edx
  80079c:	50                   	push   %eax
  80079d:	89 f2                	mov    %esi,%edx
  80079f:	89 f8                	mov    %edi,%eax
  8007a1:	e8 9e ff ff ff       	call   800744 <printnum>
  8007a6:	83 c4 20             	add    $0x20,%esp
  8007a9:	eb 18                	jmp    8007c3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	56                   	push   %esi
  8007af:	ff 75 18             	pushl  0x18(%ebp)
  8007b2:	ff d7                	call   *%edi
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	eb 03                	jmp    8007bc <printnum+0x78>
  8007b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007bc:	83 eb 01             	sub    $0x1,%ebx
  8007bf:	85 db                	test   %ebx,%ebx
  8007c1:	7f e8                	jg     8007ab <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	56                   	push   %esi
  8007c7:	83 ec 04             	sub    $0x4,%esp
  8007ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8007d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8007d6:	e8 f5 1a 00 00       	call   8022d0 <__umoddi3>
  8007db:	83 c4 14             	add    $0x14,%esp
  8007de:	0f be 80 a3 25 80 00 	movsbl 0x8025a3(%eax),%eax
  8007e5:	50                   	push   %eax
  8007e6:	ff d7                	call   *%edi
}
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007f6:	83 fa 01             	cmp    $0x1,%edx
  8007f9:	7e 0e                	jle    800809 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007fb:	8b 10                	mov    (%eax),%edx
  8007fd:	8d 4a 08             	lea    0x8(%edx),%ecx
  800800:	89 08                	mov    %ecx,(%eax)
  800802:	8b 02                	mov    (%edx),%eax
  800804:	8b 52 04             	mov    0x4(%edx),%edx
  800807:	eb 22                	jmp    80082b <getuint+0x38>
	else if (lflag)
  800809:	85 d2                	test   %edx,%edx
  80080b:	74 10                	je     80081d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80080d:	8b 10                	mov    (%eax),%edx
  80080f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800812:	89 08                	mov    %ecx,(%eax)
  800814:	8b 02                	mov    (%edx),%eax
  800816:	ba 00 00 00 00       	mov    $0x0,%edx
  80081b:	eb 0e                	jmp    80082b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80081d:	8b 10                	mov    (%eax),%edx
  80081f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800822:	89 08                	mov    %ecx,(%eax)
  800824:	8b 02                	mov    (%edx),%eax
  800826:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800833:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800837:	8b 10                	mov    (%eax),%edx
  800839:	3b 50 04             	cmp    0x4(%eax),%edx
  80083c:	73 0a                	jae    800848 <sprintputch+0x1b>
		*b->buf++ = ch;
  80083e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800841:	89 08                	mov    %ecx,(%eax)
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	88 02                	mov    %al,(%edx)
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800850:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800853:	50                   	push   %eax
  800854:	ff 75 10             	pushl  0x10(%ebp)
  800857:	ff 75 0c             	pushl  0xc(%ebp)
  80085a:	ff 75 08             	pushl  0x8(%ebp)
  80085d:	e8 05 00 00 00       	call   800867 <vprintfmt>
	va_end(ap);
}
  800862:	83 c4 10             	add    $0x10,%esp
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	57                   	push   %edi
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	83 ec 2c             	sub    $0x2c,%esp
  800870:	8b 75 08             	mov    0x8(%ebp),%esi
  800873:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800876:	8b 7d 10             	mov    0x10(%ebp),%edi
  800879:	eb 12                	jmp    80088d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80087b:	85 c0                	test   %eax,%eax
  80087d:	0f 84 89 03 00 00    	je     800c0c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	50                   	push   %eax
  800888:	ff d6                	call   *%esi
  80088a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80088d:	83 c7 01             	add    $0x1,%edi
  800890:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800894:	83 f8 25             	cmp    $0x25,%eax
  800897:	75 e2                	jne    80087b <vprintfmt+0x14>
  800899:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80089d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008a4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008ab:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b7:	eb 07                	jmp    8008c0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008bc:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c0:	8d 47 01             	lea    0x1(%edi),%eax
  8008c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008c6:	0f b6 07             	movzbl (%edi),%eax
  8008c9:	0f b6 c8             	movzbl %al,%ecx
  8008cc:	83 e8 23             	sub    $0x23,%eax
  8008cf:	3c 55                	cmp    $0x55,%al
  8008d1:	0f 87 1a 03 00 00    	ja     800bf1 <vprintfmt+0x38a>
  8008d7:	0f b6 c0             	movzbl %al,%eax
  8008da:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
  8008e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008e4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008e8:	eb d6                	jmp    8008c0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008f5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008f8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8008fc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8008ff:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800902:	83 fa 09             	cmp    $0x9,%edx
  800905:	77 39                	ja     800940 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800907:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80090a:	eb e9                	jmp    8008f5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8d 48 04             	lea    0x4(%eax),%ecx
  800912:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800915:	8b 00                	mov    (%eax),%eax
  800917:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80091d:	eb 27                	jmp    800946 <vprintfmt+0xdf>
  80091f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800922:	85 c0                	test   %eax,%eax
  800924:	b9 00 00 00 00       	mov    $0x0,%ecx
  800929:	0f 49 c8             	cmovns %eax,%ecx
  80092c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800932:	eb 8c                	jmp    8008c0 <vprintfmt+0x59>
  800934:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800937:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80093e:	eb 80                	jmp    8008c0 <vprintfmt+0x59>
  800940:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800943:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800946:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80094a:	0f 89 70 ff ff ff    	jns    8008c0 <vprintfmt+0x59>
				width = precision, precision = -1;
  800950:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800953:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800956:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80095d:	e9 5e ff ff ff       	jmp    8008c0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800962:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800965:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800968:	e9 53 ff ff ff       	jmp    8008c0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80096d:	8b 45 14             	mov    0x14(%ebp),%eax
  800970:	8d 50 04             	lea    0x4(%eax),%edx
  800973:	89 55 14             	mov    %edx,0x14(%ebp)
  800976:	83 ec 08             	sub    $0x8,%esp
  800979:	53                   	push   %ebx
  80097a:	ff 30                	pushl  (%eax)
  80097c:	ff d6                	call   *%esi
			break;
  80097e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800981:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800984:	e9 04 ff ff ff       	jmp    80088d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800989:	8b 45 14             	mov    0x14(%ebp),%eax
  80098c:	8d 50 04             	lea    0x4(%eax),%edx
  80098f:	89 55 14             	mov    %edx,0x14(%ebp)
  800992:	8b 00                	mov    (%eax),%eax
  800994:	99                   	cltd   
  800995:	31 d0                	xor    %edx,%eax
  800997:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800999:	83 f8 0f             	cmp    $0xf,%eax
  80099c:	7f 0b                	jg     8009a9 <vprintfmt+0x142>
  80099e:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  8009a5:	85 d2                	test   %edx,%edx
  8009a7:	75 18                	jne    8009c1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8009a9:	50                   	push   %eax
  8009aa:	68 bb 25 80 00       	push   $0x8025bb
  8009af:	53                   	push   %ebx
  8009b0:	56                   	push   %esi
  8009b1:	e8 94 fe ff ff       	call   80084a <printfmt>
  8009b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009bc:	e9 cc fe ff ff       	jmp    80088d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009c1:	52                   	push   %edx
  8009c2:	68 85 29 80 00       	push   $0x802985
  8009c7:	53                   	push   %ebx
  8009c8:	56                   	push   %esi
  8009c9:	e8 7c fe ff ff       	call   80084a <printfmt>
  8009ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009d4:	e9 b4 fe ff ff       	jmp    80088d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dc:	8d 50 04             	lea    0x4(%eax),%edx
  8009df:	89 55 14             	mov    %edx,0x14(%ebp)
  8009e2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009e4:	85 ff                	test   %edi,%edi
  8009e6:	b8 b4 25 80 00       	mov    $0x8025b4,%eax
  8009eb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009f2:	0f 8e 94 00 00 00    	jle    800a8c <vprintfmt+0x225>
  8009f8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009fc:	0f 84 98 00 00 00    	je     800a9a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a02:	83 ec 08             	sub    $0x8,%esp
  800a05:	ff 75 d0             	pushl  -0x30(%ebp)
  800a08:	57                   	push   %edi
  800a09:	e8 86 02 00 00       	call   800c94 <strnlen>
  800a0e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a11:	29 c1                	sub    %eax,%ecx
  800a13:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a16:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a19:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a20:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a23:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a25:	eb 0f                	jmp    800a36 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a27:	83 ec 08             	sub    $0x8,%esp
  800a2a:	53                   	push   %ebx
  800a2b:	ff 75 e0             	pushl  -0x20(%ebp)
  800a2e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a30:	83 ef 01             	sub    $0x1,%edi
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	85 ff                	test   %edi,%edi
  800a38:	7f ed                	jg     800a27 <vprintfmt+0x1c0>
  800a3a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a3d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a40:	85 c9                	test   %ecx,%ecx
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	0f 49 c1             	cmovns %ecx,%eax
  800a4a:	29 c1                	sub    %eax,%ecx
  800a4c:	89 75 08             	mov    %esi,0x8(%ebp)
  800a4f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a52:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a55:	89 cb                	mov    %ecx,%ebx
  800a57:	eb 4d                	jmp    800aa6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a59:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a5d:	74 1b                	je     800a7a <vprintfmt+0x213>
  800a5f:	0f be c0             	movsbl %al,%eax
  800a62:	83 e8 20             	sub    $0x20,%eax
  800a65:	83 f8 5e             	cmp    $0x5e,%eax
  800a68:	76 10                	jbe    800a7a <vprintfmt+0x213>
					putch('?', putdat);
  800a6a:	83 ec 08             	sub    $0x8,%esp
  800a6d:	ff 75 0c             	pushl  0xc(%ebp)
  800a70:	6a 3f                	push   $0x3f
  800a72:	ff 55 08             	call   *0x8(%ebp)
  800a75:	83 c4 10             	add    $0x10,%esp
  800a78:	eb 0d                	jmp    800a87 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a7a:	83 ec 08             	sub    $0x8,%esp
  800a7d:	ff 75 0c             	pushl  0xc(%ebp)
  800a80:	52                   	push   %edx
  800a81:	ff 55 08             	call   *0x8(%ebp)
  800a84:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a87:	83 eb 01             	sub    $0x1,%ebx
  800a8a:	eb 1a                	jmp    800aa6 <vprintfmt+0x23f>
  800a8c:	89 75 08             	mov    %esi,0x8(%ebp)
  800a8f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a92:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a95:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a98:	eb 0c                	jmp    800aa6 <vprintfmt+0x23f>
  800a9a:	89 75 08             	mov    %esi,0x8(%ebp)
  800a9d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800aa0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800aa3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800aa6:	83 c7 01             	add    $0x1,%edi
  800aa9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800aad:	0f be d0             	movsbl %al,%edx
  800ab0:	85 d2                	test   %edx,%edx
  800ab2:	74 23                	je     800ad7 <vprintfmt+0x270>
  800ab4:	85 f6                	test   %esi,%esi
  800ab6:	78 a1                	js     800a59 <vprintfmt+0x1f2>
  800ab8:	83 ee 01             	sub    $0x1,%esi
  800abb:	79 9c                	jns    800a59 <vprintfmt+0x1f2>
  800abd:	89 df                	mov    %ebx,%edi
  800abf:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac5:	eb 18                	jmp    800adf <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ac7:	83 ec 08             	sub    $0x8,%esp
  800aca:	53                   	push   %ebx
  800acb:	6a 20                	push   $0x20
  800acd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800acf:	83 ef 01             	sub    $0x1,%edi
  800ad2:	83 c4 10             	add    $0x10,%esp
  800ad5:	eb 08                	jmp    800adf <vprintfmt+0x278>
  800ad7:	89 df                	mov    %ebx,%edi
  800ad9:	8b 75 08             	mov    0x8(%ebp),%esi
  800adc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800adf:	85 ff                	test   %edi,%edi
  800ae1:	7f e4                	jg     800ac7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ae3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ae6:	e9 a2 fd ff ff       	jmp    80088d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aeb:	83 fa 01             	cmp    $0x1,%edx
  800aee:	7e 16                	jle    800b06 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800af0:	8b 45 14             	mov    0x14(%ebp),%eax
  800af3:	8d 50 08             	lea    0x8(%eax),%edx
  800af6:	89 55 14             	mov    %edx,0x14(%ebp)
  800af9:	8b 50 04             	mov    0x4(%eax),%edx
  800afc:	8b 00                	mov    (%eax),%eax
  800afe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b01:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b04:	eb 32                	jmp    800b38 <vprintfmt+0x2d1>
	else if (lflag)
  800b06:	85 d2                	test   %edx,%edx
  800b08:	74 18                	je     800b22 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800b0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0d:	8d 50 04             	lea    0x4(%eax),%edx
  800b10:	89 55 14             	mov    %edx,0x14(%ebp)
  800b13:	8b 00                	mov    (%eax),%eax
  800b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b18:	89 c1                	mov    %eax,%ecx
  800b1a:	c1 f9 1f             	sar    $0x1f,%ecx
  800b1d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b20:	eb 16                	jmp    800b38 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b22:	8b 45 14             	mov    0x14(%ebp),%eax
  800b25:	8d 50 04             	lea    0x4(%eax),%edx
  800b28:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2b:	8b 00                	mov    (%eax),%eax
  800b2d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b30:	89 c1                	mov    %eax,%ecx
  800b32:	c1 f9 1f             	sar    $0x1f,%ecx
  800b35:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b38:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b3e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b43:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b47:	79 74                	jns    800bbd <vprintfmt+0x356>
				putch('-', putdat);
  800b49:	83 ec 08             	sub    $0x8,%esp
  800b4c:	53                   	push   %ebx
  800b4d:	6a 2d                	push   $0x2d
  800b4f:	ff d6                	call   *%esi
				num = -(long long) num;
  800b51:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b54:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b57:	f7 d8                	neg    %eax
  800b59:	83 d2 00             	adc    $0x0,%edx
  800b5c:	f7 da                	neg    %edx
  800b5e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b61:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b66:	eb 55                	jmp    800bbd <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b68:	8d 45 14             	lea    0x14(%ebp),%eax
  800b6b:	e8 83 fc ff ff       	call   8007f3 <getuint>
			base = 10;
  800b70:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b75:	eb 46                	jmp    800bbd <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b77:	8d 45 14             	lea    0x14(%ebp),%eax
  800b7a:	e8 74 fc ff ff       	call   8007f3 <getuint>
			base = 8;
  800b7f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b84:	eb 37                	jmp    800bbd <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b86:	83 ec 08             	sub    $0x8,%esp
  800b89:	53                   	push   %ebx
  800b8a:	6a 30                	push   $0x30
  800b8c:	ff d6                	call   *%esi
			putch('x', putdat);
  800b8e:	83 c4 08             	add    $0x8,%esp
  800b91:	53                   	push   %ebx
  800b92:	6a 78                	push   $0x78
  800b94:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b96:	8b 45 14             	mov    0x14(%ebp),%eax
  800b99:	8d 50 04             	lea    0x4(%eax),%edx
  800b9c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b9f:	8b 00                	mov    (%eax),%eax
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800ba6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800ba9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bae:	eb 0d                	jmp    800bbd <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bb0:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb3:	e8 3b fc ff ff       	call   8007f3 <getuint>
			base = 16;
  800bb8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bc4:	57                   	push   %edi
  800bc5:	ff 75 e0             	pushl  -0x20(%ebp)
  800bc8:	51                   	push   %ecx
  800bc9:	52                   	push   %edx
  800bca:	50                   	push   %eax
  800bcb:	89 da                	mov    %ebx,%edx
  800bcd:	89 f0                	mov    %esi,%eax
  800bcf:	e8 70 fb ff ff       	call   800744 <printnum>
			break;
  800bd4:	83 c4 20             	add    $0x20,%esp
  800bd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bda:	e9 ae fc ff ff       	jmp    80088d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bdf:	83 ec 08             	sub    $0x8,%esp
  800be2:	53                   	push   %ebx
  800be3:	51                   	push   %ecx
  800be4:	ff d6                	call   *%esi
			break;
  800be6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800be9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bec:	e9 9c fc ff ff       	jmp    80088d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bf1:	83 ec 08             	sub    $0x8,%esp
  800bf4:	53                   	push   %ebx
  800bf5:	6a 25                	push   $0x25
  800bf7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bf9:	83 c4 10             	add    $0x10,%esp
  800bfc:	eb 03                	jmp    800c01 <vprintfmt+0x39a>
  800bfe:	83 ef 01             	sub    $0x1,%edi
  800c01:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c05:	75 f7                	jne    800bfe <vprintfmt+0x397>
  800c07:	e9 81 fc ff ff       	jmp    80088d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 18             	sub    $0x18,%esp
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c20:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c23:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c27:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	74 26                	je     800c5b <vsnprintf+0x47>
  800c35:	85 d2                	test   %edx,%edx
  800c37:	7e 22                	jle    800c5b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c39:	ff 75 14             	pushl  0x14(%ebp)
  800c3c:	ff 75 10             	pushl  0x10(%ebp)
  800c3f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c42:	50                   	push   %eax
  800c43:	68 2d 08 80 00       	push   $0x80082d
  800c48:	e8 1a fc ff ff       	call   800867 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c50:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c56:	83 c4 10             	add    $0x10,%esp
  800c59:	eb 05                	jmp    800c60 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c68:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c6b:	50                   	push   %eax
  800c6c:	ff 75 10             	pushl  0x10(%ebp)
  800c6f:	ff 75 0c             	pushl  0xc(%ebp)
  800c72:	ff 75 08             	pushl  0x8(%ebp)
  800c75:	e8 9a ff ff ff       	call   800c14 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c7a:	c9                   	leave  
  800c7b:	c3                   	ret    

00800c7c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c82:	b8 00 00 00 00       	mov    $0x0,%eax
  800c87:	eb 03                	jmp    800c8c <strlen+0x10>
		n++;
  800c89:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c8c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c90:	75 f7                	jne    800c89 <strlen+0xd>
		n++;
	return n;
}
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca2:	eb 03                	jmp    800ca7 <strnlen+0x13>
		n++;
  800ca4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ca7:	39 c2                	cmp    %eax,%edx
  800ca9:	74 08                	je     800cb3 <strnlen+0x1f>
  800cab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800caf:	75 f3                	jne    800ca4 <strnlen+0x10>
  800cb1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	53                   	push   %ebx
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cbf:	89 c2                	mov    %eax,%edx
  800cc1:	83 c2 01             	add    $0x1,%edx
  800cc4:	83 c1 01             	add    $0x1,%ecx
  800cc7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ccb:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cce:	84 db                	test   %bl,%bl
  800cd0:	75 ef                	jne    800cc1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cd2:	5b                   	pop    %ebx
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	53                   	push   %ebx
  800cd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cdc:	53                   	push   %ebx
  800cdd:	e8 9a ff ff ff       	call   800c7c <strlen>
  800ce2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ce5:	ff 75 0c             	pushl  0xc(%ebp)
  800ce8:	01 d8                	add    %ebx,%eax
  800cea:	50                   	push   %eax
  800ceb:	e8 c5 ff ff ff       	call   800cb5 <strcpy>
	return dst;
}
  800cf0:	89 d8                	mov    %ebx,%eax
  800cf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	8b 75 08             	mov    0x8(%ebp),%esi
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	89 f3                	mov    %esi,%ebx
  800d04:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d07:	89 f2                	mov    %esi,%edx
  800d09:	eb 0f                	jmp    800d1a <strncpy+0x23>
		*dst++ = *src;
  800d0b:	83 c2 01             	add    $0x1,%edx
  800d0e:	0f b6 01             	movzbl (%ecx),%eax
  800d11:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d14:	80 39 01             	cmpb   $0x1,(%ecx)
  800d17:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d1a:	39 da                	cmp    %ebx,%edx
  800d1c:	75 ed                	jne    800d0b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d1e:	89 f0                	mov    %esi,%eax
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	8b 75 08             	mov    0x8(%ebp),%esi
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 10             	mov    0x10(%ebp),%edx
  800d32:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d34:	85 d2                	test   %edx,%edx
  800d36:	74 21                	je     800d59 <strlcpy+0x35>
  800d38:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d3c:	89 f2                	mov    %esi,%edx
  800d3e:	eb 09                	jmp    800d49 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d40:	83 c2 01             	add    $0x1,%edx
  800d43:	83 c1 01             	add    $0x1,%ecx
  800d46:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d49:	39 c2                	cmp    %eax,%edx
  800d4b:	74 09                	je     800d56 <strlcpy+0x32>
  800d4d:	0f b6 19             	movzbl (%ecx),%ebx
  800d50:	84 db                	test   %bl,%bl
  800d52:	75 ec                	jne    800d40 <strlcpy+0x1c>
  800d54:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d56:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d59:	29 f0                	sub    %esi,%eax
}
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d65:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d68:	eb 06                	jmp    800d70 <strcmp+0x11>
		p++, q++;
  800d6a:	83 c1 01             	add    $0x1,%ecx
  800d6d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d70:	0f b6 01             	movzbl (%ecx),%eax
  800d73:	84 c0                	test   %al,%al
  800d75:	74 04                	je     800d7b <strcmp+0x1c>
  800d77:	3a 02                	cmp    (%edx),%al
  800d79:	74 ef                	je     800d6a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d7b:	0f b6 c0             	movzbl %al,%eax
  800d7e:	0f b6 12             	movzbl (%edx),%edx
  800d81:	29 d0                	sub    %edx,%eax
}
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	53                   	push   %ebx
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d8f:	89 c3                	mov    %eax,%ebx
  800d91:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d94:	eb 06                	jmp    800d9c <strncmp+0x17>
		n--, p++, q++;
  800d96:	83 c0 01             	add    $0x1,%eax
  800d99:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d9c:	39 d8                	cmp    %ebx,%eax
  800d9e:	74 15                	je     800db5 <strncmp+0x30>
  800da0:	0f b6 08             	movzbl (%eax),%ecx
  800da3:	84 c9                	test   %cl,%cl
  800da5:	74 04                	je     800dab <strncmp+0x26>
  800da7:	3a 0a                	cmp    (%edx),%cl
  800da9:	74 eb                	je     800d96 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dab:	0f b6 00             	movzbl (%eax),%eax
  800dae:	0f b6 12             	movzbl (%edx),%edx
  800db1:	29 d0                	sub    %edx,%eax
  800db3:	eb 05                	jmp    800dba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800db5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dba:	5b                   	pop    %ebx
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dc7:	eb 07                	jmp    800dd0 <strchr+0x13>
		if (*s == c)
  800dc9:	38 ca                	cmp    %cl,%dl
  800dcb:	74 0f                	je     800ddc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dcd:	83 c0 01             	add    $0x1,%eax
  800dd0:	0f b6 10             	movzbl (%eax),%edx
  800dd3:	84 d2                	test   %dl,%dl
  800dd5:	75 f2                	jne    800dc9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800dd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	8b 45 08             	mov    0x8(%ebp),%eax
  800de4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de8:	eb 03                	jmp    800ded <strfind+0xf>
  800dea:	83 c0 01             	add    $0x1,%eax
  800ded:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800df0:	38 ca                	cmp    %cl,%dl
  800df2:	74 04                	je     800df8 <strfind+0x1a>
  800df4:	84 d2                	test   %dl,%dl
  800df6:	75 f2                	jne    800dea <strfind+0xc>
			break;
	return (char *) s;
}
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e06:	85 c9                	test   %ecx,%ecx
  800e08:	74 36                	je     800e40 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e0a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e10:	75 28                	jne    800e3a <memset+0x40>
  800e12:	f6 c1 03             	test   $0x3,%cl
  800e15:	75 23                	jne    800e3a <memset+0x40>
		c &= 0xFF;
  800e17:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e1b:	89 d3                	mov    %edx,%ebx
  800e1d:	c1 e3 08             	shl    $0x8,%ebx
  800e20:	89 d6                	mov    %edx,%esi
  800e22:	c1 e6 18             	shl    $0x18,%esi
  800e25:	89 d0                	mov    %edx,%eax
  800e27:	c1 e0 10             	shl    $0x10,%eax
  800e2a:	09 f0                	or     %esi,%eax
  800e2c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e2e:	89 d8                	mov    %ebx,%eax
  800e30:	09 d0                	or     %edx,%eax
  800e32:	c1 e9 02             	shr    $0x2,%ecx
  800e35:	fc                   	cld    
  800e36:	f3 ab                	rep stos %eax,%es:(%edi)
  800e38:	eb 06                	jmp    800e40 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3d:	fc                   	cld    
  800e3e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e40:	89 f8                	mov    %edi,%eax
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e55:	39 c6                	cmp    %eax,%esi
  800e57:	73 35                	jae    800e8e <memmove+0x47>
  800e59:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e5c:	39 d0                	cmp    %edx,%eax
  800e5e:	73 2e                	jae    800e8e <memmove+0x47>
		s += n;
		d += n;
  800e60:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e63:	89 d6                	mov    %edx,%esi
  800e65:	09 fe                	or     %edi,%esi
  800e67:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e6d:	75 13                	jne    800e82 <memmove+0x3b>
  800e6f:	f6 c1 03             	test   $0x3,%cl
  800e72:	75 0e                	jne    800e82 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e74:	83 ef 04             	sub    $0x4,%edi
  800e77:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e7a:	c1 e9 02             	shr    $0x2,%ecx
  800e7d:	fd                   	std    
  800e7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e80:	eb 09                	jmp    800e8b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e82:	83 ef 01             	sub    $0x1,%edi
  800e85:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e88:	fd                   	std    
  800e89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e8b:	fc                   	cld    
  800e8c:	eb 1d                	jmp    800eab <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e8e:	89 f2                	mov    %esi,%edx
  800e90:	09 c2                	or     %eax,%edx
  800e92:	f6 c2 03             	test   $0x3,%dl
  800e95:	75 0f                	jne    800ea6 <memmove+0x5f>
  800e97:	f6 c1 03             	test   $0x3,%cl
  800e9a:	75 0a                	jne    800ea6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e9c:	c1 e9 02             	shr    $0x2,%ecx
  800e9f:	89 c7                	mov    %eax,%edi
  800ea1:	fc                   	cld    
  800ea2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ea4:	eb 05                	jmp    800eab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ea6:	89 c7                	mov    %eax,%edi
  800ea8:	fc                   	cld    
  800ea9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eab:	5e                   	pop    %esi
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800eb2:	ff 75 10             	pushl  0x10(%ebp)
  800eb5:	ff 75 0c             	pushl  0xc(%ebp)
  800eb8:	ff 75 08             	pushl  0x8(%ebp)
  800ebb:	e8 87 ff ff ff       	call   800e47 <memmove>
}
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	56                   	push   %esi
  800ec6:	53                   	push   %ebx
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ecd:	89 c6                	mov    %eax,%esi
  800ecf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ed2:	eb 1a                	jmp    800eee <memcmp+0x2c>
		if (*s1 != *s2)
  800ed4:	0f b6 08             	movzbl (%eax),%ecx
  800ed7:	0f b6 1a             	movzbl (%edx),%ebx
  800eda:	38 d9                	cmp    %bl,%cl
  800edc:	74 0a                	je     800ee8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ede:	0f b6 c1             	movzbl %cl,%eax
  800ee1:	0f b6 db             	movzbl %bl,%ebx
  800ee4:	29 d8                	sub    %ebx,%eax
  800ee6:	eb 0f                	jmp    800ef7 <memcmp+0x35>
		s1++, s2++;
  800ee8:	83 c0 01             	add    $0x1,%eax
  800eeb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eee:	39 f0                	cmp    %esi,%eax
  800ef0:	75 e2                	jne    800ed4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ef2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	53                   	push   %ebx
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f02:	89 c1                	mov    %eax,%ecx
  800f04:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f07:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f0b:	eb 0a                	jmp    800f17 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f0d:	0f b6 10             	movzbl (%eax),%edx
  800f10:	39 da                	cmp    %ebx,%edx
  800f12:	74 07                	je     800f1b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f14:	83 c0 01             	add    $0x1,%eax
  800f17:	39 c8                	cmp    %ecx,%eax
  800f19:	72 f2                	jb     800f0d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f1b:	5b                   	pop    %ebx
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f2a:	eb 03                	jmp    800f2f <strtol+0x11>
		s++;
  800f2c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f2f:	0f b6 01             	movzbl (%ecx),%eax
  800f32:	3c 20                	cmp    $0x20,%al
  800f34:	74 f6                	je     800f2c <strtol+0xe>
  800f36:	3c 09                	cmp    $0x9,%al
  800f38:	74 f2                	je     800f2c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f3a:	3c 2b                	cmp    $0x2b,%al
  800f3c:	75 0a                	jne    800f48 <strtol+0x2a>
		s++;
  800f3e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f41:	bf 00 00 00 00       	mov    $0x0,%edi
  800f46:	eb 11                	jmp    800f59 <strtol+0x3b>
  800f48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f4d:	3c 2d                	cmp    $0x2d,%al
  800f4f:	75 08                	jne    800f59 <strtol+0x3b>
		s++, neg = 1;
  800f51:	83 c1 01             	add    $0x1,%ecx
  800f54:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f5f:	75 15                	jne    800f76 <strtol+0x58>
  800f61:	80 39 30             	cmpb   $0x30,(%ecx)
  800f64:	75 10                	jne    800f76 <strtol+0x58>
  800f66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f6a:	75 7c                	jne    800fe8 <strtol+0xca>
		s += 2, base = 16;
  800f6c:	83 c1 02             	add    $0x2,%ecx
  800f6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f74:	eb 16                	jmp    800f8c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f76:	85 db                	test   %ebx,%ebx
  800f78:	75 12                	jne    800f8c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f7a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800f82:	75 08                	jne    800f8c <strtol+0x6e>
		s++, base = 8;
  800f84:	83 c1 01             	add    $0x1,%ecx
  800f87:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f91:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f94:	0f b6 11             	movzbl (%ecx),%edx
  800f97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f9a:	89 f3                	mov    %esi,%ebx
  800f9c:	80 fb 09             	cmp    $0x9,%bl
  800f9f:	77 08                	ja     800fa9 <strtol+0x8b>
			dig = *s - '0';
  800fa1:	0f be d2             	movsbl %dl,%edx
  800fa4:	83 ea 30             	sub    $0x30,%edx
  800fa7:	eb 22                	jmp    800fcb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800fa9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fac:	89 f3                	mov    %esi,%ebx
  800fae:	80 fb 19             	cmp    $0x19,%bl
  800fb1:	77 08                	ja     800fbb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800fb3:	0f be d2             	movsbl %dl,%edx
  800fb6:	83 ea 57             	sub    $0x57,%edx
  800fb9:	eb 10                	jmp    800fcb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fbb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fbe:	89 f3                	mov    %esi,%ebx
  800fc0:	80 fb 19             	cmp    $0x19,%bl
  800fc3:	77 16                	ja     800fdb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800fc5:	0f be d2             	movsbl %dl,%edx
  800fc8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fcb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fce:	7d 0b                	jge    800fdb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800fd0:	83 c1 01             	add    $0x1,%ecx
  800fd3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fd7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800fd9:	eb b9                	jmp    800f94 <strtol+0x76>

	if (endptr)
  800fdb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fdf:	74 0d                	je     800fee <strtol+0xd0>
		*endptr = (char *) s;
  800fe1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fe4:	89 0e                	mov    %ecx,(%esi)
  800fe6:	eb 06                	jmp    800fee <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fe8:	85 db                	test   %ebx,%ebx
  800fea:	74 98                	je     800f84 <strtol+0x66>
  800fec:	eb 9e                	jmp    800f8c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fee:	89 c2                	mov    %eax,%edx
  800ff0:	f7 da                	neg    %edx
  800ff2:	85 ff                	test   %edi,%edi
  800ff4:	0f 45 c2             	cmovne %edx,%eax
}
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801002:	b8 00 00 00 00       	mov    $0x0,%eax
  801007:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100a:	8b 55 08             	mov    0x8(%ebp),%edx
  80100d:	89 c3                	mov    %eax,%ebx
  80100f:	89 c7                	mov    %eax,%edi
  801011:	89 c6                	mov    %eax,%esi
  801013:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <sys_cgetc>:

int
sys_cgetc(void)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801020:	ba 00 00 00 00       	mov    $0x0,%edx
  801025:	b8 01 00 00 00       	mov    $0x1,%eax
  80102a:	89 d1                	mov    %edx,%ecx
  80102c:	89 d3                	mov    %edx,%ebx
  80102e:	89 d7                	mov    %edx,%edi
  801030:	89 d6                	mov    %edx,%esi
  801032:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
  80103f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801042:	b9 00 00 00 00       	mov    $0x0,%ecx
  801047:	b8 03 00 00 00       	mov    $0x3,%eax
  80104c:	8b 55 08             	mov    0x8(%ebp),%edx
  80104f:	89 cb                	mov    %ecx,%ebx
  801051:	89 cf                	mov    %ecx,%edi
  801053:	89 ce                	mov    %ecx,%esi
  801055:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801057:	85 c0                	test   %eax,%eax
  801059:	7e 17                	jle    801072 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	50                   	push   %eax
  80105f:	6a 03                	push   $0x3
  801061:	68 9f 28 80 00       	push   $0x80289f
  801066:	6a 23                	push   $0x23
  801068:	68 bc 28 80 00       	push   $0x8028bc
  80106d:	e8 e5 f5 ff ff       	call   800657 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801072:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801075:	5b                   	pop    %ebx
  801076:	5e                   	pop    %esi
  801077:	5f                   	pop    %edi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	57                   	push   %edi
  80107e:	56                   	push   %esi
  80107f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801080:	ba 00 00 00 00       	mov    $0x0,%edx
  801085:	b8 02 00 00 00       	mov    $0x2,%eax
  80108a:	89 d1                	mov    %edx,%ecx
  80108c:	89 d3                	mov    %edx,%ebx
  80108e:	89 d7                	mov    %edx,%edi
  801090:	89 d6                	mov    %edx,%esi
  801092:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <sys_yield>:

void
sys_yield(void)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	57                   	push   %edi
  80109d:	56                   	push   %esi
  80109e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109f:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010a9:	89 d1                	mov    %edx,%ecx
  8010ab:	89 d3                	mov    %edx,%ebx
  8010ad:	89 d7                	mov    %edx,%edi
  8010af:	89 d6                	mov    %edx,%esi
  8010b1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c1:	be 00 00 00 00       	mov    $0x0,%esi
  8010c6:	b8 04 00 00 00       	mov    $0x4,%eax
  8010cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d4:	89 f7                	mov    %esi,%edi
  8010d6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	7e 17                	jle    8010f3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	50                   	push   %eax
  8010e0:	6a 04                	push   $0x4
  8010e2:	68 9f 28 80 00       	push   $0x80289f
  8010e7:	6a 23                	push   $0x23
  8010e9:	68 bc 28 80 00       	push   $0x8028bc
  8010ee:	e8 64 f5 ff ff       	call   800657 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f6:	5b                   	pop    %ebx
  8010f7:	5e                   	pop    %esi
  8010f8:	5f                   	pop    %edi
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801104:	b8 05 00 00 00       	mov    $0x5,%eax
  801109:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110c:	8b 55 08             	mov    0x8(%ebp),%edx
  80110f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801112:	8b 7d 14             	mov    0x14(%ebp),%edi
  801115:	8b 75 18             	mov    0x18(%ebp),%esi
  801118:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80111a:	85 c0                	test   %eax,%eax
  80111c:	7e 17                	jle    801135 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	50                   	push   %eax
  801122:	6a 05                	push   $0x5
  801124:	68 9f 28 80 00       	push   $0x80289f
  801129:	6a 23                	push   $0x23
  80112b:	68 bc 28 80 00       	push   $0x8028bc
  801130:	e8 22 f5 ff ff       	call   800657 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801138:	5b                   	pop    %ebx
  801139:	5e                   	pop    %esi
  80113a:	5f                   	pop    %edi
  80113b:	5d                   	pop    %ebp
  80113c:	c3                   	ret    

0080113d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
  801143:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801146:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114b:	b8 06 00 00 00       	mov    $0x6,%eax
  801150:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801153:	8b 55 08             	mov    0x8(%ebp),%edx
  801156:	89 df                	mov    %ebx,%edi
  801158:	89 de                	mov    %ebx,%esi
  80115a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80115c:	85 c0                	test   %eax,%eax
  80115e:	7e 17                	jle    801177 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801160:	83 ec 0c             	sub    $0xc,%esp
  801163:	50                   	push   %eax
  801164:	6a 06                	push   $0x6
  801166:	68 9f 28 80 00       	push   $0x80289f
  80116b:	6a 23                	push   $0x23
  80116d:	68 bc 28 80 00       	push   $0x8028bc
  801172:	e8 e0 f4 ff ff       	call   800657 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801177:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801188:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118d:	b8 08 00 00 00       	mov    $0x8,%eax
  801192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801195:	8b 55 08             	mov    0x8(%ebp),%edx
  801198:	89 df                	mov    %ebx,%edi
  80119a:	89 de                	mov    %ebx,%esi
  80119c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	7e 17                	jle    8011b9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	50                   	push   %eax
  8011a6:	6a 08                	push   $0x8
  8011a8:	68 9f 28 80 00       	push   $0x80289f
  8011ad:	6a 23                	push   $0x23
  8011af:	68 bc 28 80 00       	push   $0x8028bc
  8011b4:	e8 9e f4 ff ff       	call   800657 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	57                   	push   %edi
  8011c5:	56                   	push   %esi
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cf:	b8 09 00 00 00       	mov    $0x9,%eax
  8011d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011da:	89 df                	mov    %ebx,%edi
  8011dc:	89 de                	mov    %ebx,%esi
  8011de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	7e 17                	jle    8011fb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e4:	83 ec 0c             	sub    $0xc,%esp
  8011e7:	50                   	push   %eax
  8011e8:	6a 09                	push   $0x9
  8011ea:	68 9f 28 80 00       	push   $0x80289f
  8011ef:	6a 23                	push   $0x23
  8011f1:	68 bc 28 80 00       	push   $0x8028bc
  8011f6:	e8 5c f4 ff ff       	call   800657 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fe:	5b                   	pop    %ebx
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	57                   	push   %edi
  801207:	56                   	push   %esi
  801208:	53                   	push   %ebx
  801209:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801211:	b8 0a 00 00 00       	mov    $0xa,%eax
  801216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801219:	8b 55 08             	mov    0x8(%ebp),%edx
  80121c:	89 df                	mov    %ebx,%edi
  80121e:	89 de                	mov    %ebx,%esi
  801220:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801222:	85 c0                	test   %eax,%eax
  801224:	7e 17                	jle    80123d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	50                   	push   %eax
  80122a:	6a 0a                	push   $0xa
  80122c:	68 9f 28 80 00       	push   $0x80289f
  801231:	6a 23                	push   $0x23
  801233:	68 bc 28 80 00       	push   $0x8028bc
  801238:	e8 1a f4 ff ff       	call   800657 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80123d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	57                   	push   %edi
  801249:	56                   	push   %esi
  80124a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124b:	be 00 00 00 00       	mov    $0x0,%esi
  801250:	b8 0c 00 00 00       	mov    $0xc,%eax
  801255:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801258:	8b 55 08             	mov    0x8(%ebp),%edx
  80125b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80125e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801261:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	57                   	push   %edi
  80126c:	56                   	push   %esi
  80126d:	53                   	push   %ebx
  80126e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801271:	b9 00 00 00 00       	mov    $0x0,%ecx
  801276:	b8 0d 00 00 00       	mov    $0xd,%eax
  80127b:	8b 55 08             	mov    0x8(%ebp),%edx
  80127e:	89 cb                	mov    %ecx,%ebx
  801280:	89 cf                	mov    %ecx,%edi
  801282:	89 ce                	mov    %ecx,%esi
  801284:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801286:	85 c0                	test   %eax,%eax
  801288:	7e 17                	jle    8012a1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	50                   	push   %eax
  80128e:	6a 0d                	push   $0xd
  801290:	68 9f 28 80 00       	push   $0x80289f
  801295:	6a 23                	push   $0x23
  801297:	68 bc 28 80 00       	push   $0x8028bc
  80129c:	e8 b6 f3 ff ff       	call   800657 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a4:	5b                   	pop    %ebx
  8012a5:	5e                   	pop    %esi
  8012a6:	5f                   	pop    %edi
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    

008012a9 <sys_thread_create>:

envid_t
sys_thread_create(uintptr_t func)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	57                   	push   %edi
  8012ad:	56                   	push   %esi
  8012ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b4:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012bc:	89 cb                	mov    %ecx,%ebx
  8012be:	89 cf                	mov    %ecx,%edi
  8012c0:	89 ce                	mov    %ecx,%esi
  8012c2:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012cf:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012d6:	75 2a                	jne    801302 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8012d8:	83 ec 04             	sub    $0x4,%esp
  8012db:	6a 07                	push   $0x7
  8012dd:	68 00 f0 bf ee       	push   $0xeebff000
  8012e2:	6a 00                	push   $0x0
  8012e4:	e8 cf fd ff ff       	call   8010b8 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	79 12                	jns    801302 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8012f0:	50                   	push   %eax
  8012f1:	68 ca 28 80 00       	push   $0x8028ca
  8012f6:	6a 23                	push   $0x23
  8012f8:	68 ce 28 80 00       	push   $0x8028ce
  8012fd:	e8 55 f3 ff ff       	call   800657 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801302:	8b 45 08             	mov    0x8(%ebp),%eax
  801305:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	68 34 13 80 00       	push   $0x801334
  801312:	6a 00                	push   $0x0
  801314:	e8 ea fe ff ff       	call   801203 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	79 12                	jns    801332 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801320:	50                   	push   %eax
  801321:	68 ca 28 80 00       	push   $0x8028ca
  801326:	6a 2c                	push   $0x2c
  801328:	68 ce 28 80 00       	push   $0x8028ce
  80132d:	e8 25 f3 ff ff       	call   800657 <_panic>
	}
}
  801332:	c9                   	leave  
  801333:	c3                   	ret    

00801334 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801334:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801335:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80133a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80133c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80133f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801343:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801348:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80134c:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80134e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801351:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801352:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801355:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801356:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801357:	c3                   	ret    

00801358 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80135b:	8b 45 08             	mov    0x8(%ebp),%eax
  80135e:	05 00 00 00 30       	add    $0x30000000,%eax
  801363:	c1 e8 0c             	shr    $0xc,%eax
}
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    

00801368 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80136b:	8b 45 08             	mov    0x8(%ebp),%eax
  80136e:	05 00 00 00 30       	add    $0x30000000,%eax
  801373:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801378:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    

0080137f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801385:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80138a:	89 c2                	mov    %eax,%edx
  80138c:	c1 ea 16             	shr    $0x16,%edx
  80138f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801396:	f6 c2 01             	test   $0x1,%dl
  801399:	74 11                	je     8013ac <fd_alloc+0x2d>
  80139b:	89 c2                	mov    %eax,%edx
  80139d:	c1 ea 0c             	shr    $0xc,%edx
  8013a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a7:	f6 c2 01             	test   $0x1,%dl
  8013aa:	75 09                	jne    8013b5 <fd_alloc+0x36>
			*fd_store = fd;
  8013ac:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b3:	eb 17                	jmp    8013cc <fd_alloc+0x4d>
  8013b5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013ba:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013bf:	75 c9                	jne    80138a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013c1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013c7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    

008013ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013d4:	83 f8 1f             	cmp    $0x1f,%eax
  8013d7:	77 36                	ja     80140f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013d9:	c1 e0 0c             	shl    $0xc,%eax
  8013dc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013e1:	89 c2                	mov    %eax,%edx
  8013e3:	c1 ea 16             	shr    $0x16,%edx
  8013e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ed:	f6 c2 01             	test   $0x1,%dl
  8013f0:	74 24                	je     801416 <fd_lookup+0x48>
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	c1 ea 0c             	shr    $0xc,%edx
  8013f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013fe:	f6 c2 01             	test   $0x1,%dl
  801401:	74 1a                	je     80141d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801403:	8b 55 0c             	mov    0xc(%ebp),%edx
  801406:	89 02                	mov    %eax,(%edx)
	return 0;
  801408:	b8 00 00 00 00       	mov    $0x0,%eax
  80140d:	eb 13                	jmp    801422 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80140f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801414:	eb 0c                	jmp    801422 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801416:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141b:	eb 05                	jmp    801422 <fd_lookup+0x54>
  80141d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80142d:	ba 5c 29 80 00       	mov    $0x80295c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801432:	eb 13                	jmp    801447 <dev_lookup+0x23>
  801434:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801437:	39 08                	cmp    %ecx,(%eax)
  801439:	75 0c                	jne    801447 <dev_lookup+0x23>
			*dev = devtab[i];
  80143b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801440:	b8 00 00 00 00       	mov    $0x0,%eax
  801445:	eb 2e                	jmp    801475 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801447:	8b 02                	mov    (%edx),%eax
  801449:	85 c0                	test   %eax,%eax
  80144b:	75 e7                	jne    801434 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80144d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801452:	8b 40 50             	mov    0x50(%eax),%eax
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	51                   	push   %ecx
  801459:	50                   	push   %eax
  80145a:	68 dc 28 80 00       	push   $0x8028dc
  80145f:	e8 cc f2 ff ff       	call   800730 <cprintf>
	*dev = 0;
  801464:	8b 45 0c             	mov    0xc(%ebp),%eax
  801467:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	56                   	push   %esi
  80147b:	53                   	push   %ebx
  80147c:	83 ec 10             	sub    $0x10,%esp
  80147f:	8b 75 08             	mov    0x8(%ebp),%esi
  801482:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801485:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801488:	50                   	push   %eax
  801489:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80148f:	c1 e8 0c             	shr    $0xc,%eax
  801492:	50                   	push   %eax
  801493:	e8 36 ff ff ff       	call   8013ce <fd_lookup>
  801498:	83 c4 08             	add    $0x8,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 05                	js     8014a4 <fd_close+0x2d>
	    || fd != fd2)
  80149f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014a2:	74 0c                	je     8014b0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014a4:	84 db                	test   %bl,%bl
  8014a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ab:	0f 44 c2             	cmove  %edx,%eax
  8014ae:	eb 41                	jmp    8014f1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b6:	50                   	push   %eax
  8014b7:	ff 36                	pushl  (%esi)
  8014b9:	e8 66 ff ff ff       	call   801424 <dev_lookup>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 1a                	js     8014e1 <fd_close+0x6a>
		if (dev->dev_close)
  8014c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ca:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8014cd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	74 0b                	je     8014e1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	56                   	push   %esi
  8014da:	ff d0                	call   *%eax
  8014dc:	89 c3                	mov    %eax,%ebx
  8014de:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	56                   	push   %esi
  8014e5:	6a 00                	push   $0x0
  8014e7:	e8 51 fc ff ff       	call   80113d <sys_page_unmap>
	return r;
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	89 d8                	mov    %ebx,%eax
}
  8014f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f4:	5b                   	pop    %ebx
  8014f5:	5e                   	pop    %esi
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    

008014f8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801501:	50                   	push   %eax
  801502:	ff 75 08             	pushl  0x8(%ebp)
  801505:	e8 c4 fe ff ff       	call   8013ce <fd_lookup>
  80150a:	83 c4 08             	add    $0x8,%esp
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 10                	js     801521 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	6a 01                	push   $0x1
  801516:	ff 75 f4             	pushl  -0xc(%ebp)
  801519:	e8 59 ff ff ff       	call   801477 <fd_close>
  80151e:	83 c4 10             	add    $0x10,%esp
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <close_all>:

void
close_all(void)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80152a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80152f:	83 ec 0c             	sub    $0xc,%esp
  801532:	53                   	push   %ebx
  801533:	e8 c0 ff ff ff       	call   8014f8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801538:	83 c3 01             	add    $0x1,%ebx
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	83 fb 20             	cmp    $0x20,%ebx
  801541:	75 ec                	jne    80152f <close_all+0xc>
		close(i);
}
  801543:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	57                   	push   %edi
  80154c:	56                   	push   %esi
  80154d:	53                   	push   %ebx
  80154e:	83 ec 2c             	sub    $0x2c,%esp
  801551:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801554:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	ff 75 08             	pushl  0x8(%ebp)
  80155b:	e8 6e fe ff ff       	call   8013ce <fd_lookup>
  801560:	83 c4 08             	add    $0x8,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	0f 88 c1 00 00 00    	js     80162c <dup+0xe4>
		return r;
	close(newfdnum);
  80156b:	83 ec 0c             	sub    $0xc,%esp
  80156e:	56                   	push   %esi
  80156f:	e8 84 ff ff ff       	call   8014f8 <close>

	newfd = INDEX2FD(newfdnum);
  801574:	89 f3                	mov    %esi,%ebx
  801576:	c1 e3 0c             	shl    $0xc,%ebx
  801579:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80157f:	83 c4 04             	add    $0x4,%esp
  801582:	ff 75 e4             	pushl  -0x1c(%ebp)
  801585:	e8 de fd ff ff       	call   801368 <fd2data>
  80158a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80158c:	89 1c 24             	mov    %ebx,(%esp)
  80158f:	e8 d4 fd ff ff       	call   801368 <fd2data>
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80159a:	89 f8                	mov    %edi,%eax
  80159c:	c1 e8 16             	shr    $0x16,%eax
  80159f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015a6:	a8 01                	test   $0x1,%al
  8015a8:	74 37                	je     8015e1 <dup+0x99>
  8015aa:	89 f8                	mov    %edi,%eax
  8015ac:	c1 e8 0c             	shr    $0xc,%eax
  8015af:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015b6:	f6 c2 01             	test   $0x1,%dl
  8015b9:	74 26                	je     8015e1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	25 07 0e 00 00       	and    $0xe07,%eax
  8015ca:	50                   	push   %eax
  8015cb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015ce:	6a 00                	push   $0x0
  8015d0:	57                   	push   %edi
  8015d1:	6a 00                	push   $0x0
  8015d3:	e8 23 fb ff ff       	call   8010fb <sys_page_map>
  8015d8:	89 c7                	mov    %eax,%edi
  8015da:	83 c4 20             	add    $0x20,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 2e                	js     80160f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015e4:	89 d0                	mov    %edx,%eax
  8015e6:	c1 e8 0c             	shr    $0xc,%eax
  8015e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f0:	83 ec 0c             	sub    $0xc,%esp
  8015f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f8:	50                   	push   %eax
  8015f9:	53                   	push   %ebx
  8015fa:	6a 00                	push   $0x0
  8015fc:	52                   	push   %edx
  8015fd:	6a 00                	push   $0x0
  8015ff:	e8 f7 fa ff ff       	call   8010fb <sys_page_map>
  801604:	89 c7                	mov    %eax,%edi
  801606:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801609:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80160b:	85 ff                	test   %edi,%edi
  80160d:	79 1d                	jns    80162c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	53                   	push   %ebx
  801613:	6a 00                	push   $0x0
  801615:	e8 23 fb ff ff       	call   80113d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80161a:	83 c4 08             	add    $0x8,%esp
  80161d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801620:	6a 00                	push   $0x0
  801622:	e8 16 fb ff ff       	call   80113d <sys_page_unmap>
	return r;
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	89 f8                	mov    %edi,%eax
}
  80162c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162f:	5b                   	pop    %ebx
  801630:	5e                   	pop    %esi
  801631:	5f                   	pop    %edi
  801632:	5d                   	pop    %ebp
  801633:	c3                   	ret    

00801634 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	53                   	push   %ebx
  801638:	83 ec 14             	sub    $0x14,%esp
  80163b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801641:	50                   	push   %eax
  801642:	53                   	push   %ebx
  801643:	e8 86 fd ff ff       	call   8013ce <fd_lookup>
  801648:	83 c4 08             	add    $0x8,%esp
  80164b:	89 c2                	mov    %eax,%edx
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 6d                	js     8016be <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801657:	50                   	push   %eax
  801658:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165b:	ff 30                	pushl  (%eax)
  80165d:	e8 c2 fd ff ff       	call   801424 <dev_lookup>
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	85 c0                	test   %eax,%eax
  801667:	78 4c                	js     8016b5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801669:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80166c:	8b 42 08             	mov    0x8(%edx),%eax
  80166f:	83 e0 03             	and    $0x3,%eax
  801672:	83 f8 01             	cmp    $0x1,%eax
  801675:	75 21                	jne    801698 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801677:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80167c:	8b 40 50             	mov    0x50(%eax),%eax
  80167f:	83 ec 04             	sub    $0x4,%esp
  801682:	53                   	push   %ebx
  801683:	50                   	push   %eax
  801684:	68 20 29 80 00       	push   $0x802920
  801689:	e8 a2 f0 ff ff       	call   800730 <cprintf>
		return -E_INVAL;
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801696:	eb 26                	jmp    8016be <read+0x8a>
	}
	if (!dev->dev_read)
  801698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169b:	8b 40 08             	mov    0x8(%eax),%eax
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	74 17                	je     8016b9 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8016a2:	83 ec 04             	sub    $0x4,%esp
  8016a5:	ff 75 10             	pushl  0x10(%ebp)
  8016a8:	ff 75 0c             	pushl  0xc(%ebp)
  8016ab:	52                   	push   %edx
  8016ac:	ff d0                	call   *%eax
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	eb 09                	jmp    8016be <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b5:	89 c2                	mov    %eax,%edx
  8016b7:	eb 05                	jmp    8016be <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8016be:	89 d0                	mov    %edx,%eax
  8016c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	57                   	push   %edi
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 0c             	sub    $0xc,%esp
  8016ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d9:	eb 21                	jmp    8016fc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016db:	83 ec 04             	sub    $0x4,%esp
  8016de:	89 f0                	mov    %esi,%eax
  8016e0:	29 d8                	sub    %ebx,%eax
  8016e2:	50                   	push   %eax
  8016e3:	89 d8                	mov    %ebx,%eax
  8016e5:	03 45 0c             	add    0xc(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	57                   	push   %edi
  8016ea:	e8 45 ff ff ff       	call   801634 <read>
		if (m < 0)
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	78 10                	js     801706 <readn+0x41>
			return m;
		if (m == 0)
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	74 0a                	je     801704 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016fa:	01 c3                	add    %eax,%ebx
  8016fc:	39 f3                	cmp    %esi,%ebx
  8016fe:	72 db                	jb     8016db <readn+0x16>
  801700:	89 d8                	mov    %ebx,%eax
  801702:	eb 02                	jmp    801706 <readn+0x41>
  801704:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801706:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5f                   	pop    %edi
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	83 ec 14             	sub    $0x14,%esp
  801715:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801718:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	53                   	push   %ebx
  80171d:	e8 ac fc ff ff       	call   8013ce <fd_lookup>
  801722:	83 c4 08             	add    $0x8,%esp
  801725:	89 c2                	mov    %eax,%edx
  801727:	85 c0                	test   %eax,%eax
  801729:	78 68                	js     801793 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801731:	50                   	push   %eax
  801732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801735:	ff 30                	pushl  (%eax)
  801737:	e8 e8 fc ff ff       	call   801424 <dev_lookup>
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 47                	js     80178a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801746:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80174a:	75 21                	jne    80176d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80174c:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801751:	8b 40 50             	mov    0x50(%eax),%eax
  801754:	83 ec 04             	sub    $0x4,%esp
  801757:	53                   	push   %ebx
  801758:	50                   	push   %eax
  801759:	68 3c 29 80 00       	push   $0x80293c
  80175e:	e8 cd ef ff ff       	call   800730 <cprintf>
		return -E_INVAL;
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80176b:	eb 26                	jmp    801793 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80176d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801770:	8b 52 0c             	mov    0xc(%edx),%edx
  801773:	85 d2                	test   %edx,%edx
  801775:	74 17                	je     80178e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801777:	83 ec 04             	sub    $0x4,%esp
  80177a:	ff 75 10             	pushl  0x10(%ebp)
  80177d:	ff 75 0c             	pushl  0xc(%ebp)
  801780:	50                   	push   %eax
  801781:	ff d2                	call   *%edx
  801783:	89 c2                	mov    %eax,%edx
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	eb 09                	jmp    801793 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178a:	89 c2                	mov    %eax,%edx
  80178c:	eb 05                	jmp    801793 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80178e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801793:	89 d0                	mov    %edx,%eax
  801795:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <seek>:

int
seek(int fdnum, off_t offset)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017a3:	50                   	push   %eax
  8017a4:	ff 75 08             	pushl  0x8(%ebp)
  8017a7:	e8 22 fc ff ff       	call   8013ce <fd_lookup>
  8017ac:	83 c4 08             	add    $0x8,%esp
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 0e                	js     8017c1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 14             	sub    $0x14,%esp
  8017ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d0:	50                   	push   %eax
  8017d1:	53                   	push   %ebx
  8017d2:	e8 f7 fb ff ff       	call   8013ce <fd_lookup>
  8017d7:	83 c4 08             	add    $0x8,%esp
  8017da:	89 c2                	mov    %eax,%edx
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 65                	js     801845 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e0:	83 ec 08             	sub    $0x8,%esp
  8017e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e6:	50                   	push   %eax
  8017e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ea:	ff 30                	pushl  (%eax)
  8017ec:	e8 33 fc ff ff       	call   801424 <dev_lookup>
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	78 44                	js     80183c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017ff:	75 21                	jne    801822 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801801:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801806:	8b 40 50             	mov    0x50(%eax),%eax
  801809:	83 ec 04             	sub    $0x4,%esp
  80180c:	53                   	push   %ebx
  80180d:	50                   	push   %eax
  80180e:	68 fc 28 80 00       	push   $0x8028fc
  801813:	e8 18 ef ff ff       	call   800730 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801820:	eb 23                	jmp    801845 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801822:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801825:	8b 52 18             	mov    0x18(%edx),%edx
  801828:	85 d2                	test   %edx,%edx
  80182a:	74 14                	je     801840 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	ff 75 0c             	pushl  0xc(%ebp)
  801832:	50                   	push   %eax
  801833:	ff d2                	call   *%edx
  801835:	89 c2                	mov    %eax,%edx
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	eb 09                	jmp    801845 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183c:	89 c2                	mov    %eax,%edx
  80183e:	eb 05                	jmp    801845 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801840:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801845:	89 d0                	mov    %edx,%eax
  801847:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184a:	c9                   	leave  
  80184b:	c3                   	ret    

0080184c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	53                   	push   %ebx
  801850:	83 ec 14             	sub    $0x14,%esp
  801853:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801856:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	ff 75 08             	pushl  0x8(%ebp)
  80185d:	e8 6c fb ff ff       	call   8013ce <fd_lookup>
  801862:	83 c4 08             	add    $0x8,%esp
  801865:	89 c2                	mov    %eax,%edx
  801867:	85 c0                	test   %eax,%eax
  801869:	78 58                	js     8018c3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801871:	50                   	push   %eax
  801872:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801875:	ff 30                	pushl  (%eax)
  801877:	e8 a8 fb ff ff       	call   801424 <dev_lookup>
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 37                	js     8018ba <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801883:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801886:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80188a:	74 32                	je     8018be <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80188c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80188f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801896:	00 00 00 
	stat->st_isdir = 0;
  801899:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a0:	00 00 00 
	stat->st_dev = dev;
  8018a3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	53                   	push   %ebx
  8018ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b0:	ff 50 14             	call   *0x14(%eax)
  8018b3:	89 c2                	mov    %eax,%edx
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	eb 09                	jmp    8018c3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ba:	89 c2                	mov    %eax,%edx
  8018bc:	eb 05                	jmp    8018c3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018c3:	89 d0                	mov    %edx,%eax
  8018c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	56                   	push   %esi
  8018ce:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	6a 00                	push   $0x0
  8018d4:	ff 75 08             	pushl  0x8(%ebp)
  8018d7:	e8 e3 01 00 00       	call   801abf <open>
  8018dc:	89 c3                	mov    %eax,%ebx
  8018de:	83 c4 10             	add    $0x10,%esp
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	78 1b                	js     801900 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	ff 75 0c             	pushl  0xc(%ebp)
  8018eb:	50                   	push   %eax
  8018ec:	e8 5b ff ff ff       	call   80184c <fstat>
  8018f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8018f3:	89 1c 24             	mov    %ebx,(%esp)
  8018f6:	e8 fd fb ff ff       	call   8014f8 <close>
	return r;
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	89 f0                	mov    %esi,%eax
}
  801900:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801903:	5b                   	pop    %ebx
  801904:	5e                   	pop    %esi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	56                   	push   %esi
  80190b:	53                   	push   %ebx
  80190c:	89 c6                	mov    %eax,%esi
  80190e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801910:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801917:	75 12                	jne    80192b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801919:	83 ec 0c             	sub    $0xc,%esp
  80191c:	6a 01                	push   $0x1
  80191e:	e8 f6 07 00 00       	call   802119 <ipc_find_env>
  801923:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801928:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80192b:	6a 07                	push   $0x7
  80192d:	68 00 50 80 00       	push   $0x805000
  801932:	56                   	push   %esi
  801933:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801939:	e8 79 07 00 00       	call   8020b7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80193e:	83 c4 0c             	add    $0xc,%esp
  801941:	6a 00                	push   $0x0
  801943:	53                   	push   %ebx
  801944:	6a 00                	push   $0x0
  801946:	e8 f7 06 00 00       	call   802042 <ipc_recv>
}
  80194b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194e:	5b                   	pop    %ebx
  80194f:	5e                   	pop    %esi
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801958:	8b 45 08             	mov    0x8(%ebp),%eax
  80195b:	8b 40 0c             	mov    0xc(%eax),%eax
  80195e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801963:	8b 45 0c             	mov    0xc(%ebp),%eax
  801966:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80196b:	ba 00 00 00 00       	mov    $0x0,%edx
  801970:	b8 02 00 00 00       	mov    $0x2,%eax
  801975:	e8 8d ff ff ff       	call   801907 <fsipc>
}
  80197a:	c9                   	leave  
  80197b:	c3                   	ret    

0080197c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801982:	8b 45 08             	mov    0x8(%ebp),%eax
  801985:	8b 40 0c             	mov    0xc(%eax),%eax
  801988:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80198d:	ba 00 00 00 00       	mov    $0x0,%edx
  801992:	b8 06 00 00 00       	mov    $0x6,%eax
  801997:	e8 6b ff ff ff       	call   801907 <fsipc>
}
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 04             	sub    $0x4,%esp
  8019a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8019bd:	e8 45 ff ff ff       	call   801907 <fsipc>
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 2c                	js     8019f2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019c6:	83 ec 08             	sub    $0x8,%esp
  8019c9:	68 00 50 80 00       	push   $0x805000
  8019ce:	53                   	push   %ebx
  8019cf:	e8 e1 f2 ff ff       	call   800cb5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019d4:	a1 80 50 80 00       	mov    0x805080,%eax
  8019d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019df:	a1 84 50 80 00       	mov    0x805084,%eax
  8019e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a00:	8b 55 08             	mov    0x8(%ebp),%edx
  801a03:	8b 52 0c             	mov    0xc(%edx),%edx
  801a06:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801a0c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a11:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a16:	0f 47 c2             	cmova  %edx,%eax
  801a19:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a1e:	50                   	push   %eax
  801a1f:	ff 75 0c             	pushl  0xc(%ebp)
  801a22:	68 08 50 80 00       	push   $0x805008
  801a27:	e8 1b f4 ff ff       	call   800e47 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801a2c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a31:	b8 04 00 00 00       	mov    $0x4,%eax
  801a36:	e8 cc fe ff ff       	call   801907 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a3b:	c9                   	leave  
  801a3c:	c3                   	ret    

00801a3d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a45:	8b 45 08             	mov    0x8(%ebp),%eax
  801a48:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a50:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a56:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5b:	b8 03 00 00 00       	mov    $0x3,%eax
  801a60:	e8 a2 fe ff ff       	call   801907 <fsipc>
  801a65:	89 c3                	mov    %eax,%ebx
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 4b                	js     801ab6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a6b:	39 c6                	cmp    %eax,%esi
  801a6d:	73 16                	jae    801a85 <devfile_read+0x48>
  801a6f:	68 6c 29 80 00       	push   $0x80296c
  801a74:	68 73 29 80 00       	push   $0x802973
  801a79:	6a 7c                	push   $0x7c
  801a7b:	68 88 29 80 00       	push   $0x802988
  801a80:	e8 d2 eb ff ff       	call   800657 <_panic>
	assert(r <= PGSIZE);
  801a85:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a8a:	7e 16                	jle    801aa2 <devfile_read+0x65>
  801a8c:	68 93 29 80 00       	push   $0x802993
  801a91:	68 73 29 80 00       	push   $0x802973
  801a96:	6a 7d                	push   $0x7d
  801a98:	68 88 29 80 00       	push   $0x802988
  801a9d:	e8 b5 eb ff ff       	call   800657 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aa2:	83 ec 04             	sub    $0x4,%esp
  801aa5:	50                   	push   %eax
  801aa6:	68 00 50 80 00       	push   $0x805000
  801aab:	ff 75 0c             	pushl  0xc(%ebp)
  801aae:	e8 94 f3 ff ff       	call   800e47 <memmove>
	return r;
  801ab3:	83 c4 10             	add    $0x10,%esp
}
  801ab6:	89 d8                	mov    %ebx,%eax
  801ab8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abb:	5b                   	pop    %ebx
  801abc:	5e                   	pop    %esi
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	53                   	push   %ebx
  801ac3:	83 ec 20             	sub    $0x20,%esp
  801ac6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ac9:	53                   	push   %ebx
  801aca:	e8 ad f1 ff ff       	call   800c7c <strlen>
  801acf:	83 c4 10             	add    $0x10,%esp
  801ad2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ad7:	7f 67                	jg     801b40 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801adf:	50                   	push   %eax
  801ae0:	e8 9a f8 ff ff       	call   80137f <fd_alloc>
  801ae5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ae8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 57                	js     801b45 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	53                   	push   %ebx
  801af2:	68 00 50 80 00       	push   $0x805000
  801af7:	e8 b9 f1 ff ff       	call   800cb5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801afc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b07:	b8 01 00 00 00       	mov    $0x1,%eax
  801b0c:	e8 f6 fd ff ff       	call   801907 <fsipc>
  801b11:	89 c3                	mov    %eax,%ebx
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	85 c0                	test   %eax,%eax
  801b18:	79 14                	jns    801b2e <open+0x6f>
		fd_close(fd, 0);
  801b1a:	83 ec 08             	sub    $0x8,%esp
  801b1d:	6a 00                	push   $0x0
  801b1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b22:	e8 50 f9 ff ff       	call   801477 <fd_close>
		return r;
  801b27:	83 c4 10             	add    $0x10,%esp
  801b2a:	89 da                	mov    %ebx,%edx
  801b2c:	eb 17                	jmp    801b45 <open+0x86>
	}

	return fd2num(fd);
  801b2e:	83 ec 0c             	sub    $0xc,%esp
  801b31:	ff 75 f4             	pushl  -0xc(%ebp)
  801b34:	e8 1f f8 ff ff       	call   801358 <fd2num>
  801b39:	89 c2                	mov    %eax,%edx
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	eb 05                	jmp    801b45 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b40:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b45:	89 d0                	mov    %edx,%eax
  801b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b52:	ba 00 00 00 00       	mov    $0x0,%edx
  801b57:	b8 08 00 00 00       	mov    $0x8,%eax
  801b5c:	e8 a6 fd ff ff       	call   801907 <fsipc>
}
  801b61:	c9                   	leave  
  801b62:	c3                   	ret    

00801b63 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	ff 75 08             	pushl  0x8(%ebp)
  801b71:	e8 f2 f7 ff ff       	call   801368 <fd2data>
  801b76:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b78:	83 c4 08             	add    $0x8,%esp
  801b7b:	68 9f 29 80 00       	push   $0x80299f
  801b80:	53                   	push   %ebx
  801b81:	e8 2f f1 ff ff       	call   800cb5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b86:	8b 46 04             	mov    0x4(%esi),%eax
  801b89:	2b 06                	sub    (%esi),%eax
  801b8b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b91:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b98:	00 00 00 
	stat->st_dev = &devpipe;
  801b9b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ba2:	30 80 00 
	return 0;
}
  801ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  801baa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	53                   	push   %ebx
  801bb5:	83 ec 0c             	sub    $0xc,%esp
  801bb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bbb:	53                   	push   %ebx
  801bbc:	6a 00                	push   $0x0
  801bbe:	e8 7a f5 ff ff       	call   80113d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc3:	89 1c 24             	mov    %ebx,(%esp)
  801bc6:	e8 9d f7 ff ff       	call   801368 <fd2data>
  801bcb:	83 c4 08             	add    $0x8,%esp
  801bce:	50                   	push   %eax
  801bcf:	6a 00                	push   $0x0
  801bd1:	e8 67 f5 ff ff       	call   80113d <sys_page_unmap>
}
  801bd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	57                   	push   %edi
  801bdf:	56                   	push   %esi
  801be0:	53                   	push   %ebx
  801be1:	83 ec 1c             	sub    $0x1c,%esp
  801be4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801be7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801be9:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801bee:	8b 70 60             	mov    0x60(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bf1:	83 ec 0c             	sub    $0xc,%esp
  801bf4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bf7:	e8 5d 05 00 00       	call   802159 <pageref>
  801bfc:	89 c3                	mov    %eax,%ebx
  801bfe:	89 3c 24             	mov    %edi,(%esp)
  801c01:	e8 53 05 00 00       	call   802159 <pageref>
  801c06:	83 c4 10             	add    $0x10,%esp
  801c09:	39 c3                	cmp    %eax,%ebx
  801c0b:	0f 94 c1             	sete   %cl
  801c0e:	0f b6 c9             	movzbl %cl,%ecx
  801c11:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c14:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801c1a:	8b 4a 60             	mov    0x60(%edx),%ecx
		if (n == nn)
  801c1d:	39 ce                	cmp    %ecx,%esi
  801c1f:	74 1b                	je     801c3c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c21:	39 c3                	cmp    %eax,%ebx
  801c23:	75 c4                	jne    801be9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c25:	8b 42 60             	mov    0x60(%edx),%eax
  801c28:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c2b:	50                   	push   %eax
  801c2c:	56                   	push   %esi
  801c2d:	68 a6 29 80 00       	push   $0x8029a6
  801c32:	e8 f9 ea ff ff       	call   800730 <cprintf>
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	eb ad                	jmp    801be9 <_pipeisclosed+0xe>
	}
}
  801c3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c42:	5b                   	pop    %ebx
  801c43:	5e                   	pop    %esi
  801c44:	5f                   	pop    %edi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	57                   	push   %edi
  801c4b:	56                   	push   %esi
  801c4c:	53                   	push   %ebx
  801c4d:	83 ec 28             	sub    $0x28,%esp
  801c50:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c53:	56                   	push   %esi
  801c54:	e8 0f f7 ff ff       	call   801368 <fd2data>
  801c59:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5b:	83 c4 10             	add    $0x10,%esp
  801c5e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c63:	eb 4b                	jmp    801cb0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c65:	89 da                	mov    %ebx,%edx
  801c67:	89 f0                	mov    %esi,%eax
  801c69:	e8 6d ff ff ff       	call   801bdb <_pipeisclosed>
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	75 48                	jne    801cba <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c72:	e8 22 f4 ff ff       	call   801099 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c77:	8b 43 04             	mov    0x4(%ebx),%eax
  801c7a:	8b 0b                	mov    (%ebx),%ecx
  801c7c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c7f:	39 d0                	cmp    %edx,%eax
  801c81:	73 e2                	jae    801c65 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c86:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c8a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c8d:	89 c2                	mov    %eax,%edx
  801c8f:	c1 fa 1f             	sar    $0x1f,%edx
  801c92:	89 d1                	mov    %edx,%ecx
  801c94:	c1 e9 1b             	shr    $0x1b,%ecx
  801c97:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c9a:	83 e2 1f             	and    $0x1f,%edx
  801c9d:	29 ca                	sub    %ecx,%edx
  801c9f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ca3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ca7:	83 c0 01             	add    $0x1,%eax
  801caa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cad:	83 c7 01             	add    $0x1,%edi
  801cb0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801cb3:	75 c2                	jne    801c77 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801cb5:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb8:	eb 05                	jmp    801cbf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cba:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc2:	5b                   	pop    %ebx
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    

00801cc7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	57                   	push   %edi
  801ccb:	56                   	push   %esi
  801ccc:	53                   	push   %ebx
  801ccd:	83 ec 18             	sub    $0x18,%esp
  801cd0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cd3:	57                   	push   %edi
  801cd4:	e8 8f f6 ff ff       	call   801368 <fd2data>
  801cd9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cdb:	83 c4 10             	add    $0x10,%esp
  801cde:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ce3:	eb 3d                	jmp    801d22 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ce5:	85 db                	test   %ebx,%ebx
  801ce7:	74 04                	je     801ced <devpipe_read+0x26>
				return i;
  801ce9:	89 d8                	mov    %ebx,%eax
  801ceb:	eb 44                	jmp    801d31 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ced:	89 f2                	mov    %esi,%edx
  801cef:	89 f8                	mov    %edi,%eax
  801cf1:	e8 e5 fe ff ff       	call   801bdb <_pipeisclosed>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	75 32                	jne    801d2c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cfa:	e8 9a f3 ff ff       	call   801099 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cff:	8b 06                	mov    (%esi),%eax
  801d01:	3b 46 04             	cmp    0x4(%esi),%eax
  801d04:	74 df                	je     801ce5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d06:	99                   	cltd   
  801d07:	c1 ea 1b             	shr    $0x1b,%edx
  801d0a:	01 d0                	add    %edx,%eax
  801d0c:	83 e0 1f             	and    $0x1f,%eax
  801d0f:	29 d0                	sub    %edx,%eax
  801d11:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d19:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d1c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d1f:	83 c3 01             	add    $0x1,%ebx
  801d22:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d25:	75 d8                	jne    801cff <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d27:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2a:	eb 05                	jmp    801d31 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	56                   	push   %esi
  801d3d:	53                   	push   %ebx
  801d3e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d44:	50                   	push   %eax
  801d45:	e8 35 f6 ff ff       	call   80137f <fd_alloc>
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	89 c2                	mov    %eax,%edx
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	0f 88 2c 01 00 00    	js     801e83 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d57:	83 ec 04             	sub    $0x4,%esp
  801d5a:	68 07 04 00 00       	push   $0x407
  801d5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d62:	6a 00                	push   $0x0
  801d64:	e8 4f f3 ff ff       	call   8010b8 <sys_page_alloc>
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	89 c2                	mov    %eax,%edx
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	0f 88 0d 01 00 00    	js     801e83 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d7c:	50                   	push   %eax
  801d7d:	e8 fd f5 ff ff       	call   80137f <fd_alloc>
  801d82:	89 c3                	mov    %eax,%ebx
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	85 c0                	test   %eax,%eax
  801d89:	0f 88 e2 00 00 00    	js     801e71 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8f:	83 ec 04             	sub    $0x4,%esp
  801d92:	68 07 04 00 00       	push   $0x407
  801d97:	ff 75 f0             	pushl  -0x10(%ebp)
  801d9a:	6a 00                	push   $0x0
  801d9c:	e8 17 f3 ff ff       	call   8010b8 <sys_page_alloc>
  801da1:	89 c3                	mov    %eax,%ebx
  801da3:	83 c4 10             	add    $0x10,%esp
  801da6:	85 c0                	test   %eax,%eax
  801da8:	0f 88 c3 00 00 00    	js     801e71 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801dae:	83 ec 0c             	sub    $0xc,%esp
  801db1:	ff 75 f4             	pushl  -0xc(%ebp)
  801db4:	e8 af f5 ff ff       	call   801368 <fd2data>
  801db9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dbb:	83 c4 0c             	add    $0xc,%esp
  801dbe:	68 07 04 00 00       	push   $0x407
  801dc3:	50                   	push   %eax
  801dc4:	6a 00                	push   $0x0
  801dc6:	e8 ed f2 ff ff       	call   8010b8 <sys_page_alloc>
  801dcb:	89 c3                	mov    %eax,%ebx
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	0f 88 89 00 00 00    	js     801e61 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd8:	83 ec 0c             	sub    $0xc,%esp
  801ddb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dde:	e8 85 f5 ff ff       	call   801368 <fd2data>
  801de3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dea:	50                   	push   %eax
  801deb:	6a 00                	push   $0x0
  801ded:	56                   	push   %esi
  801dee:	6a 00                	push   $0x0
  801df0:	e8 06 f3 ff ff       	call   8010fb <sys_page_map>
  801df5:	89 c3                	mov    %eax,%ebx
  801df7:	83 c4 20             	add    $0x20,%esp
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	78 55                	js     801e53 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dfe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e07:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e13:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e1c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e21:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2e:	e8 25 f5 ff ff       	call   801358 <fd2num>
  801e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e36:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e38:	83 c4 04             	add    $0x4,%esp
  801e3b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3e:	e8 15 f5 ff ff       	call   801358 <fd2num>
  801e43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e46:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e51:	eb 30                	jmp    801e83 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e53:	83 ec 08             	sub    $0x8,%esp
  801e56:	56                   	push   %esi
  801e57:	6a 00                	push   $0x0
  801e59:	e8 df f2 ff ff       	call   80113d <sys_page_unmap>
  801e5e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e61:	83 ec 08             	sub    $0x8,%esp
  801e64:	ff 75 f0             	pushl  -0x10(%ebp)
  801e67:	6a 00                	push   $0x0
  801e69:	e8 cf f2 ff ff       	call   80113d <sys_page_unmap>
  801e6e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e71:	83 ec 08             	sub    $0x8,%esp
  801e74:	ff 75 f4             	pushl  -0xc(%ebp)
  801e77:	6a 00                	push   $0x0
  801e79:	e8 bf f2 ff ff       	call   80113d <sys_page_unmap>
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e83:	89 d0                	mov    %edx,%eax
  801e85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    

00801e8c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e95:	50                   	push   %eax
  801e96:	ff 75 08             	pushl  0x8(%ebp)
  801e99:	e8 30 f5 ff ff       	call   8013ce <fd_lookup>
  801e9e:	83 c4 10             	add    $0x10,%esp
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	78 18                	js     801ebd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	ff 75 f4             	pushl  -0xc(%ebp)
  801eab:	e8 b8 f4 ff ff       	call   801368 <fd2data>
	return _pipeisclosed(fd, p);
  801eb0:	89 c2                	mov    %eax,%edx
  801eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb5:	e8 21 fd ff ff       	call   801bdb <_pipeisclosed>
  801eba:	83 c4 10             	add    $0x10,%esp
}
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    

00801ebf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ec2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec7:	5d                   	pop    %ebp
  801ec8:	c3                   	ret    

00801ec9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ecf:	68 be 29 80 00       	push   $0x8029be
  801ed4:	ff 75 0c             	pushl  0xc(%ebp)
  801ed7:	e8 d9 ed ff ff       	call   800cb5 <strcpy>
	return 0;
}
  801edc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    

00801ee3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	57                   	push   %edi
  801ee7:	56                   	push   %esi
  801ee8:	53                   	push   %ebx
  801ee9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eef:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ef4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801efa:	eb 2d                	jmp    801f29 <devcons_write+0x46>
		m = n - tot;
  801efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eff:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f01:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f04:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f09:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f0c:	83 ec 04             	sub    $0x4,%esp
  801f0f:	53                   	push   %ebx
  801f10:	03 45 0c             	add    0xc(%ebp),%eax
  801f13:	50                   	push   %eax
  801f14:	57                   	push   %edi
  801f15:	e8 2d ef ff ff       	call   800e47 <memmove>
		sys_cputs(buf, m);
  801f1a:	83 c4 08             	add    $0x8,%esp
  801f1d:	53                   	push   %ebx
  801f1e:	57                   	push   %edi
  801f1f:	e8 d8 f0 ff ff       	call   800ffc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f24:	01 de                	add    %ebx,%esi
  801f26:	83 c4 10             	add    $0x10,%esp
  801f29:	89 f0                	mov    %esi,%eax
  801f2b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f2e:	72 cc                	jb     801efc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f47:	74 2a                	je     801f73 <devcons_read+0x3b>
  801f49:	eb 05                	jmp    801f50 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f4b:	e8 49 f1 ff ff       	call   801099 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f50:	e8 c5 f0 ff ff       	call   80101a <sys_cgetc>
  801f55:	85 c0                	test   %eax,%eax
  801f57:	74 f2                	je     801f4b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	78 16                	js     801f73 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f5d:	83 f8 04             	cmp    $0x4,%eax
  801f60:	74 0c                	je     801f6e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f65:	88 02                	mov    %al,(%edx)
	return 1;
  801f67:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6c:	eb 05                	jmp    801f73 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f6e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f81:	6a 01                	push   $0x1
  801f83:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f86:	50                   	push   %eax
  801f87:	e8 70 f0 ff ff       	call   800ffc <sys_cputs>
}
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	c9                   	leave  
  801f90:	c3                   	ret    

00801f91 <getchar>:

int
getchar(void)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f97:	6a 01                	push   $0x1
  801f99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f9c:	50                   	push   %eax
  801f9d:	6a 00                	push   $0x0
  801f9f:	e8 90 f6 ff ff       	call   801634 <read>
	if (r < 0)
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	85 c0                	test   %eax,%eax
  801fa9:	78 0f                	js     801fba <getchar+0x29>
		return r;
	if (r < 1)
  801fab:	85 c0                	test   %eax,%eax
  801fad:	7e 06                	jle    801fb5 <getchar+0x24>
		return -E_EOF;
	return c;
  801faf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fb3:	eb 05                	jmp    801fba <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fb5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc5:	50                   	push   %eax
  801fc6:	ff 75 08             	pushl  0x8(%ebp)
  801fc9:	e8 00 f4 ff ff       	call   8013ce <fd_lookup>
  801fce:	83 c4 10             	add    $0x10,%esp
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	78 11                	js     801fe6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fde:	39 10                	cmp    %edx,(%eax)
  801fe0:	0f 94 c0             	sete   %al
  801fe3:	0f b6 c0             	movzbl %al,%eax
}
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    

00801fe8 <opencons>:

int
opencons(void)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff1:	50                   	push   %eax
  801ff2:	e8 88 f3 ff ff       	call   80137f <fd_alloc>
  801ff7:	83 c4 10             	add    $0x10,%esp
		return r;
  801ffa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	78 3e                	js     80203e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802000:	83 ec 04             	sub    $0x4,%esp
  802003:	68 07 04 00 00       	push   $0x407
  802008:	ff 75 f4             	pushl  -0xc(%ebp)
  80200b:	6a 00                	push   $0x0
  80200d:	e8 a6 f0 ff ff       	call   8010b8 <sys_page_alloc>
  802012:	83 c4 10             	add    $0x10,%esp
		return r;
  802015:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802017:	85 c0                	test   %eax,%eax
  802019:	78 23                	js     80203e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80201b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802021:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802024:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802026:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802029:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802030:	83 ec 0c             	sub    $0xc,%esp
  802033:	50                   	push   %eax
  802034:	e8 1f f3 ff ff       	call   801358 <fd2num>
  802039:	89 c2                	mov    %eax,%edx
  80203b:	83 c4 10             	add    $0x10,%esp
}
  80203e:	89 d0                	mov    %edx,%eax
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	56                   	push   %esi
  802046:	53                   	push   %ebx
  802047:	8b 75 08             	mov    0x8(%ebp),%esi
  80204a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802050:	85 c0                	test   %eax,%eax
  802052:	75 12                	jne    802066 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802054:	83 ec 0c             	sub    $0xc,%esp
  802057:	68 00 00 c0 ee       	push   $0xeec00000
  80205c:	e8 07 f2 ff ff       	call   801268 <sys_ipc_recv>
  802061:	83 c4 10             	add    $0x10,%esp
  802064:	eb 0c                	jmp    802072 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802066:	83 ec 0c             	sub    $0xc,%esp
  802069:	50                   	push   %eax
  80206a:	e8 f9 f1 ff ff       	call   801268 <sys_ipc_recv>
  80206f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802072:	85 f6                	test   %esi,%esi
  802074:	0f 95 c1             	setne  %cl
  802077:	85 db                	test   %ebx,%ebx
  802079:	0f 95 c2             	setne  %dl
  80207c:	84 d1                	test   %dl,%cl
  80207e:	74 09                	je     802089 <ipc_recv+0x47>
  802080:	89 c2                	mov    %eax,%edx
  802082:	c1 ea 1f             	shr    $0x1f,%edx
  802085:	84 d2                	test   %dl,%dl
  802087:	75 27                	jne    8020b0 <ipc_recv+0x6e>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802089:	85 f6                	test   %esi,%esi
  80208b:	74 0a                	je     802097 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  80208d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802092:	8b 40 7c             	mov    0x7c(%eax),%eax
  802095:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802097:	85 db                	test   %ebx,%ebx
  802099:	74 0d                	je     8020a8 <ipc_recv+0x66>
		*perm_store = thisenv->env_ipc_perm;
  80209b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8020a0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8020a6:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020a8:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8020ad:	8b 40 78             	mov    0x78(%eax),%eax
}
  8020b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5d                   	pop    %ebp
  8020b6:	c3                   	ret    

008020b7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	57                   	push   %edi
  8020bb:	56                   	push   %esi
  8020bc:	53                   	push   %ebx
  8020bd:	83 ec 0c             	sub    $0xc,%esp
  8020c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020c9:	85 db                	test   %ebx,%ebx
  8020cb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020d0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020d3:	ff 75 14             	pushl  0x14(%ebp)
  8020d6:	53                   	push   %ebx
  8020d7:	56                   	push   %esi
  8020d8:	57                   	push   %edi
  8020d9:	e8 67 f1 ff ff       	call   801245 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020de:	89 c2                	mov    %eax,%edx
  8020e0:	c1 ea 1f             	shr    $0x1f,%edx
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	84 d2                	test   %dl,%dl
  8020e8:	74 17                	je     802101 <ipc_send+0x4a>
  8020ea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ed:	74 12                	je     802101 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020ef:	50                   	push   %eax
  8020f0:	68 ca 29 80 00       	push   $0x8029ca
  8020f5:	6a 47                	push   $0x47
  8020f7:	68 d8 29 80 00       	push   $0x8029d8
  8020fc:	e8 56 e5 ff ff       	call   800657 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802101:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802104:	75 07                	jne    80210d <ipc_send+0x56>
			sys_yield();
  802106:	e8 8e ef ff ff       	call   801099 <sys_yield>
  80210b:	eb c6                	jmp    8020d3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80210d:	85 c0                	test   %eax,%eax
  80210f:	75 c2                	jne    8020d3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    

00802119 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802124:	89 c2                	mov    %eax,%edx
  802126:	c1 e2 07             	shl    $0x7,%edx
  802129:	8d 94 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%edx
  802130:	8b 52 58             	mov    0x58(%edx),%edx
  802133:	39 ca                	cmp    %ecx,%edx
  802135:	75 11                	jne    802148 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802137:	89 c2                	mov    %eax,%edx
  802139:	c1 e2 07             	shl    $0x7,%edx
  80213c:	8d 84 82 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,4),%eax
  802143:	8b 40 50             	mov    0x50(%eax),%eax
  802146:	eb 0f                	jmp    802157 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802148:	83 c0 01             	add    $0x1,%eax
  80214b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802150:	75 d2                	jne    802124 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802152:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    

00802159 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802159:	55                   	push   %ebp
  80215a:	89 e5                	mov    %esp,%ebp
  80215c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80215f:	89 d0                	mov    %edx,%eax
  802161:	c1 e8 16             	shr    $0x16,%eax
  802164:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80216b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802170:	f6 c1 01             	test   $0x1,%cl
  802173:	74 1d                	je     802192 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802175:	c1 ea 0c             	shr    $0xc,%edx
  802178:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80217f:	f6 c2 01             	test   $0x1,%dl
  802182:	74 0e                	je     802192 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802184:	c1 ea 0c             	shr    $0xc,%edx
  802187:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80218e:	ef 
  80218f:	0f b7 c0             	movzwl %ax,%eax
}
  802192:	5d                   	pop    %ebp
  802193:	c3                   	ret    
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__udivdi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 f6                	test   %esi,%esi
  8021b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021bd:	89 ca                	mov    %ecx,%edx
  8021bf:	89 f8                	mov    %edi,%eax
  8021c1:	75 3d                	jne    802200 <__udivdi3+0x60>
  8021c3:	39 cf                	cmp    %ecx,%edi
  8021c5:	0f 87 c5 00 00 00    	ja     802290 <__udivdi3+0xf0>
  8021cb:	85 ff                	test   %edi,%edi
  8021cd:	89 fd                	mov    %edi,%ebp
  8021cf:	75 0b                	jne    8021dc <__udivdi3+0x3c>
  8021d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d6:	31 d2                	xor    %edx,%edx
  8021d8:	f7 f7                	div    %edi
  8021da:	89 c5                	mov    %eax,%ebp
  8021dc:	89 c8                	mov    %ecx,%eax
  8021de:	31 d2                	xor    %edx,%edx
  8021e0:	f7 f5                	div    %ebp
  8021e2:	89 c1                	mov    %eax,%ecx
  8021e4:	89 d8                	mov    %ebx,%eax
  8021e6:	89 cf                	mov    %ecx,%edi
  8021e8:	f7 f5                	div    %ebp
  8021ea:	89 c3                	mov    %eax,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	39 ce                	cmp    %ecx,%esi
  802202:	77 74                	ja     802278 <__udivdi3+0xd8>
  802204:	0f bd fe             	bsr    %esi,%edi
  802207:	83 f7 1f             	xor    $0x1f,%edi
  80220a:	0f 84 98 00 00 00    	je     8022a8 <__udivdi3+0x108>
  802210:	bb 20 00 00 00       	mov    $0x20,%ebx
  802215:	89 f9                	mov    %edi,%ecx
  802217:	89 c5                	mov    %eax,%ebp
  802219:	29 fb                	sub    %edi,%ebx
  80221b:	d3 e6                	shl    %cl,%esi
  80221d:	89 d9                	mov    %ebx,%ecx
  80221f:	d3 ed                	shr    %cl,%ebp
  802221:	89 f9                	mov    %edi,%ecx
  802223:	d3 e0                	shl    %cl,%eax
  802225:	09 ee                	or     %ebp,%esi
  802227:	89 d9                	mov    %ebx,%ecx
  802229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80222d:	89 d5                	mov    %edx,%ebp
  80222f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802233:	d3 ed                	shr    %cl,%ebp
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e2                	shl    %cl,%edx
  802239:	89 d9                	mov    %ebx,%ecx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	09 c2                	or     %eax,%edx
  80223f:	89 d0                	mov    %edx,%eax
  802241:	89 ea                	mov    %ebp,%edx
  802243:	f7 f6                	div    %esi
  802245:	89 d5                	mov    %edx,%ebp
  802247:	89 c3                	mov    %eax,%ebx
  802249:	f7 64 24 0c          	mull   0xc(%esp)
  80224d:	39 d5                	cmp    %edx,%ebp
  80224f:	72 10                	jb     802261 <__udivdi3+0xc1>
  802251:	8b 74 24 08          	mov    0x8(%esp),%esi
  802255:	89 f9                	mov    %edi,%ecx
  802257:	d3 e6                	shl    %cl,%esi
  802259:	39 c6                	cmp    %eax,%esi
  80225b:	73 07                	jae    802264 <__udivdi3+0xc4>
  80225d:	39 d5                	cmp    %edx,%ebp
  80225f:	75 03                	jne    802264 <__udivdi3+0xc4>
  802261:	83 eb 01             	sub    $0x1,%ebx
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 d8                	mov    %ebx,%eax
  802268:	89 fa                	mov    %edi,%edx
  80226a:	83 c4 1c             	add    $0x1c,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802278:	31 ff                	xor    %edi,%edi
  80227a:	31 db                	xor    %ebx,%ebx
  80227c:	89 d8                	mov    %ebx,%eax
  80227e:	89 fa                	mov    %edi,%edx
  802280:	83 c4 1c             	add    $0x1c,%esp
  802283:	5b                   	pop    %ebx
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
  802288:	90                   	nop
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 d8                	mov    %ebx,%eax
  802292:	f7 f7                	div    %edi
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 c3                	mov    %eax,%ebx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 fa                	mov    %edi,%edx
  80229c:	83 c4 1c             	add    $0x1c,%esp
  80229f:	5b                   	pop    %ebx
  8022a0:	5e                   	pop    %esi
  8022a1:	5f                   	pop    %edi
  8022a2:	5d                   	pop    %ebp
  8022a3:	c3                   	ret    
  8022a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	39 ce                	cmp    %ecx,%esi
  8022aa:	72 0c                	jb     8022b8 <__udivdi3+0x118>
  8022ac:	31 db                	xor    %ebx,%ebx
  8022ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022b2:	0f 87 34 ff ff ff    	ja     8021ec <__udivdi3+0x4c>
  8022b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022bd:	e9 2a ff ff ff       	jmp    8021ec <__udivdi3+0x4c>
  8022c2:	66 90                	xchg   %ax,%ax
  8022c4:	66 90                	xchg   %ax,%ax
  8022c6:	66 90                	xchg   %ax,%ax
  8022c8:	66 90                	xchg   %ax,%ax
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <__umoddi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 1c             	sub    $0x1c,%esp
  8022d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022e7:	85 d2                	test   %edx,%edx
  8022e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022f1:	89 f3                	mov    %esi,%ebx
  8022f3:	89 3c 24             	mov    %edi,(%esp)
  8022f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022fa:	75 1c                	jne    802318 <__umoddi3+0x48>
  8022fc:	39 f7                	cmp    %esi,%edi
  8022fe:	76 50                	jbe    802350 <__umoddi3+0x80>
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	f7 f7                	div    %edi
  802306:	89 d0                	mov    %edx,%eax
  802308:	31 d2                	xor    %edx,%edx
  80230a:	83 c4 1c             	add    $0x1c,%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    
  802312:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802318:	39 f2                	cmp    %esi,%edx
  80231a:	89 d0                	mov    %edx,%eax
  80231c:	77 52                	ja     802370 <__umoddi3+0xa0>
  80231e:	0f bd ea             	bsr    %edx,%ebp
  802321:	83 f5 1f             	xor    $0x1f,%ebp
  802324:	75 5a                	jne    802380 <__umoddi3+0xb0>
  802326:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80232a:	0f 82 e0 00 00 00    	jb     802410 <__umoddi3+0x140>
  802330:	39 0c 24             	cmp    %ecx,(%esp)
  802333:	0f 86 d7 00 00 00    	jbe    802410 <__umoddi3+0x140>
  802339:	8b 44 24 08          	mov    0x8(%esp),%eax
  80233d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802341:	83 c4 1c             	add    $0x1c,%esp
  802344:	5b                   	pop    %ebx
  802345:	5e                   	pop    %esi
  802346:	5f                   	pop    %edi
  802347:	5d                   	pop    %ebp
  802348:	c3                   	ret    
  802349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802350:	85 ff                	test   %edi,%edi
  802352:	89 fd                	mov    %edi,%ebp
  802354:	75 0b                	jne    802361 <__umoddi3+0x91>
  802356:	b8 01 00 00 00       	mov    $0x1,%eax
  80235b:	31 d2                	xor    %edx,%edx
  80235d:	f7 f7                	div    %edi
  80235f:	89 c5                	mov    %eax,%ebp
  802361:	89 f0                	mov    %esi,%eax
  802363:	31 d2                	xor    %edx,%edx
  802365:	f7 f5                	div    %ebp
  802367:	89 c8                	mov    %ecx,%eax
  802369:	f7 f5                	div    %ebp
  80236b:	89 d0                	mov    %edx,%eax
  80236d:	eb 99                	jmp    802308 <__umoddi3+0x38>
  80236f:	90                   	nop
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 f2                	mov    %esi,%edx
  802374:	83 c4 1c             	add    $0x1c,%esp
  802377:	5b                   	pop    %ebx
  802378:	5e                   	pop    %esi
  802379:	5f                   	pop    %edi
  80237a:	5d                   	pop    %ebp
  80237b:	c3                   	ret    
  80237c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802380:	8b 34 24             	mov    (%esp),%esi
  802383:	bf 20 00 00 00       	mov    $0x20,%edi
  802388:	89 e9                	mov    %ebp,%ecx
  80238a:	29 ef                	sub    %ebp,%edi
  80238c:	d3 e0                	shl    %cl,%eax
  80238e:	89 f9                	mov    %edi,%ecx
  802390:	89 f2                	mov    %esi,%edx
  802392:	d3 ea                	shr    %cl,%edx
  802394:	89 e9                	mov    %ebp,%ecx
  802396:	09 c2                	or     %eax,%edx
  802398:	89 d8                	mov    %ebx,%eax
  80239a:	89 14 24             	mov    %edx,(%esp)
  80239d:	89 f2                	mov    %esi,%edx
  80239f:	d3 e2                	shl    %cl,%edx
  8023a1:	89 f9                	mov    %edi,%ecx
  8023a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023ab:	d3 e8                	shr    %cl,%eax
  8023ad:	89 e9                	mov    %ebp,%ecx
  8023af:	89 c6                	mov    %eax,%esi
  8023b1:	d3 e3                	shl    %cl,%ebx
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 d0                	mov    %edx,%eax
  8023b7:	d3 e8                	shr    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	09 d8                	or     %ebx,%eax
  8023bd:	89 d3                	mov    %edx,%ebx
  8023bf:	89 f2                	mov    %esi,%edx
  8023c1:	f7 34 24             	divl   (%esp)
  8023c4:	89 d6                	mov    %edx,%esi
  8023c6:	d3 e3                	shl    %cl,%ebx
  8023c8:	f7 64 24 04          	mull   0x4(%esp)
  8023cc:	39 d6                	cmp    %edx,%esi
  8023ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d2:	89 d1                	mov    %edx,%ecx
  8023d4:	89 c3                	mov    %eax,%ebx
  8023d6:	72 08                	jb     8023e0 <__umoddi3+0x110>
  8023d8:	75 11                	jne    8023eb <__umoddi3+0x11b>
  8023da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023de:	73 0b                	jae    8023eb <__umoddi3+0x11b>
  8023e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023e4:	1b 14 24             	sbb    (%esp),%edx
  8023e7:	89 d1                	mov    %edx,%ecx
  8023e9:	89 c3                	mov    %eax,%ebx
  8023eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023ef:	29 da                	sub    %ebx,%edx
  8023f1:	19 ce                	sbb    %ecx,%esi
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 f0                	mov    %esi,%eax
  8023f7:	d3 e0                	shl    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	d3 ea                	shr    %cl,%edx
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	d3 ee                	shr    %cl,%esi
  802401:	09 d0                	or     %edx,%eax
  802403:	89 f2                	mov    %esi,%edx
  802405:	83 c4 1c             	add    $0x1c,%esp
  802408:	5b                   	pop    %ebx
  802409:	5e                   	pop    %esi
  80240a:	5f                   	pop    %edi
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    
  80240d:	8d 76 00             	lea    0x0(%esi),%esi
  802410:	29 f9                	sub    %edi,%ecx
  802412:	19 d6                	sbb    %edx,%esi
  802414:	89 74 24 04          	mov    %esi,0x4(%esp)
  802418:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80241c:	e9 18 ff ff ff       	jmp    802339 <__umoddi3+0x69>
