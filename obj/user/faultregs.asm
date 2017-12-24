
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
  800044:	68 31 24 80 00       	push   $0x802431
  800049:	68 00 24 80 00       	push   $0x802400
  80004e:	e8 c5 06 00 00       	call   800718 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 10 24 80 00       	push   $0x802410
  80005c:	68 14 24 80 00       	push   $0x802414
  800061:	e8 b2 06 00 00       	call   800718 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 24 24 80 00       	push   $0x802424
  800077:	e8 9c 06 00 00       	call   800718 <cprintf>
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
  800089:	68 28 24 80 00       	push   $0x802428
  80008e:	e8 85 06 00 00       	call   800718 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 32 24 80 00       	push   $0x802432
  8000a6:	68 14 24 80 00       	push   $0x802414
  8000ab:	e8 68 06 00 00       	call   800718 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 24 24 80 00       	push   $0x802424
  8000c3:	e8 50 06 00 00       	call   800718 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 28 24 80 00       	push   $0x802428
  8000d5:	e8 3e 06 00 00       	call   800718 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 36 24 80 00       	push   $0x802436
  8000ed:	68 14 24 80 00       	push   $0x802414
  8000f2:	e8 21 06 00 00       	call   800718 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 24 24 80 00       	push   $0x802424
  80010a:	e8 09 06 00 00       	call   800718 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 28 24 80 00       	push   $0x802428
  80011c:	e8 f7 05 00 00       	call   800718 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 3a 24 80 00       	push   $0x80243a
  800134:	68 14 24 80 00       	push   $0x802414
  800139:	e8 da 05 00 00       	call   800718 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 24 24 80 00       	push   $0x802424
  800151:	e8 c2 05 00 00       	call   800718 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 28 24 80 00       	push   $0x802428
  800163:	e8 b0 05 00 00       	call   800718 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 3e 24 80 00       	push   $0x80243e
  80017b:	68 14 24 80 00       	push   $0x802414
  800180:	e8 93 05 00 00       	call   800718 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 24 24 80 00       	push   $0x802424
  800198:	e8 7b 05 00 00       	call   800718 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 28 24 80 00       	push   $0x802428
  8001aa:	e8 69 05 00 00       	call   800718 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 42 24 80 00       	push   $0x802442
  8001c2:	68 14 24 80 00       	push   $0x802414
  8001c7:	e8 4c 05 00 00       	call   800718 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 24 24 80 00       	push   $0x802424
  8001df:	e8 34 05 00 00       	call   800718 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 28 24 80 00       	push   $0x802428
  8001f1:	e8 22 05 00 00       	call   800718 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 46 24 80 00       	push   $0x802446
  800209:	68 14 24 80 00       	push   $0x802414
  80020e:	e8 05 05 00 00       	call   800718 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 24 24 80 00       	push   $0x802424
  800226:	e8 ed 04 00 00       	call   800718 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 28 24 80 00       	push   $0x802428
  800238:	e8 db 04 00 00       	call   800718 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 4a 24 80 00       	push   $0x80244a
  800250:	68 14 24 80 00       	push   $0x802414
  800255:	e8 be 04 00 00       	call   800718 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 24 24 80 00       	push   $0x802424
  80026d:	e8 a6 04 00 00       	call   800718 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 28 24 80 00       	push   $0x802428
  80027f:	e8 94 04 00 00       	call   800718 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 4e 24 80 00       	push   $0x80244e
  800297:	68 14 24 80 00       	push   $0x802414
  80029c:	e8 77 04 00 00       	call   800718 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 24 24 80 00       	push   $0x802424
  8002b4:	e8 5f 04 00 00       	call   800718 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 55 24 80 00       	push   $0x802455
  8002c4:	68 14 24 80 00       	push   $0x802414
  8002c9:	e8 4a 04 00 00       	call   800718 <cprintf>
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
  8002de:	68 28 24 80 00       	push   $0x802428
  8002e3:	e8 30 04 00 00       	call   800718 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 55 24 80 00       	push   $0x802455
  8002f3:	68 14 24 80 00       	push   $0x802414
  8002f8:	e8 1b 04 00 00       	call   800718 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 24 24 80 00       	push   $0x802424
  800312:	e8 01 04 00 00       	call   800718 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 59 24 80 00       	push   $0x802459
  800322:	e8 f1 03 00 00       	call   800718 <cprintf>
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
  800333:	68 28 24 80 00       	push   $0x802428
  800338:	e8 db 03 00 00       	call   800718 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 59 24 80 00       	push   $0x802459
  800348:	e8 cb 03 00 00       	call   800718 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 24 24 80 00       	push   $0x802424
  80035a:	e8 b9 03 00 00       	call   800718 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 28 24 80 00       	push   $0x802428
  80036c:	e8 a7 03 00 00       	call   800718 <cprintf>
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
  800379:	68 24 24 80 00       	push   $0x802424
  80037e:	e8 95 03 00 00       	call   800718 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 59 24 80 00       	push   $0x802459
  80038e:	e8 85 03 00 00       	call   800718 <cprintf>
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
  8003ba:	68 c0 24 80 00       	push   $0x8024c0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 67 24 80 00       	push   $0x802467
  8003c6:	e8 74 02 00 00       	call   80063f <_panic>
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
  800436:	68 7f 24 80 00       	push   $0x80247f
  80043b:	68 8d 24 80 00       	push   $0x80248d
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba 78 24 80 00       	mov    $0x802478,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 3b 0c 00 00       	call   8010a0 <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 94 24 80 00       	push   $0x802494
  800472:	6a 5c                	push   $0x5c
  800474:	68 67 24 80 00       	push   $0x802467
  800479:	e8 c1 01 00 00       	call   80063f <_panic>
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
  80048b:	e8 01 0e 00 00       	call   801291 <set_pgfault_handler>

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
  80055a:	68 f4 24 80 00       	push   $0x8024f4
  80055f:	e8 b4 01 00 00       	call   800718 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 a7 24 80 00       	push   $0x8024a7
  800579:	68 b8 24 80 00       	push   $0x8024b8
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba 78 24 80 00       	mov    $0x802478,%edx
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
  8005aa:	e8 b3 0a 00 00       	call   801062 <sys_getenvid>
  8005af:	8b 3d b0 40 80 00    	mov    0x8040b0,%edi
  8005b5:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8005ba:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  8005bf:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  8005c4:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  8005c7:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  8005cd:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  8005d0:	39 c8                	cmp    %ecx,%eax
  8005d2:	0f 44 fb             	cmove  %ebx,%edi
  8005d5:	b9 01 00 00 00       	mov    $0x1,%ecx
  8005da:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8005dd:	83 c2 01             	add    $0x1,%edx
  8005e0:	83 c3 7c             	add    $0x7c,%ebx
  8005e3:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8005e9:	75 d9                	jne    8005c4 <libmain+0x2d>
  8005eb:	89 f0                	mov    %esi,%eax
  8005ed:	84 c0                	test   %al,%al
  8005ef:	74 06                	je     8005f7 <libmain+0x60>
  8005f1:	89 3d b0 40 80 00    	mov    %edi,0x8040b0
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005f7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8005fb:	7e 0a                	jle    800607 <libmain+0x70>
		binaryname = argv[0];
  8005fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800600:	8b 00                	mov    (%eax),%eax
  800602:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	ff 75 0c             	pushl  0xc(%ebp)
  80060d:	ff 75 08             	pushl  0x8(%ebp)
  800610:	e8 6b fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  800615:	e8 0b 00 00 00       	call   800625 <exit>
}
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800620:	5b                   	pop    %ebx
  800621:	5e                   	pop    %esi
  800622:	5f                   	pop    %edi
  800623:	5d                   	pop    %ebp
  800624:	c3                   	ret    

00800625 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800625:	55                   	push   %ebp
  800626:	89 e5                	mov    %esp,%ebp
  800628:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80062b:	e8 bb 0e 00 00       	call   8014eb <close_all>
	sys_env_destroy(0);
  800630:	83 ec 0c             	sub    $0xc,%esp
  800633:	6a 00                	push   $0x0
  800635:	e8 e7 09 00 00       	call   801021 <sys_env_destroy>
}
  80063a:	83 c4 10             	add    $0x10,%esp
  80063d:	c9                   	leave  
  80063e:	c3                   	ret    

0080063f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	56                   	push   %esi
  800643:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800644:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800647:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80064d:	e8 10 0a 00 00       	call   801062 <sys_getenvid>
  800652:	83 ec 0c             	sub    $0xc,%esp
  800655:	ff 75 0c             	pushl  0xc(%ebp)
  800658:	ff 75 08             	pushl  0x8(%ebp)
  80065b:	56                   	push   %esi
  80065c:	50                   	push   %eax
  80065d:	68 20 25 80 00       	push   $0x802520
  800662:	e8 b1 00 00 00       	call   800718 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800667:	83 c4 18             	add    $0x18,%esp
  80066a:	53                   	push   %ebx
  80066b:	ff 75 10             	pushl  0x10(%ebp)
  80066e:	e8 54 00 00 00       	call   8006c7 <vcprintf>
	cprintf("\n");
  800673:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  80067a:	e8 99 00 00 00       	call   800718 <cprintf>
  80067f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800682:	cc                   	int3   
  800683:	eb fd                	jmp    800682 <_panic+0x43>

00800685 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	53                   	push   %ebx
  800689:	83 ec 04             	sub    $0x4,%esp
  80068c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80068f:	8b 13                	mov    (%ebx),%edx
  800691:	8d 42 01             	lea    0x1(%edx),%eax
  800694:	89 03                	mov    %eax,(%ebx)
  800696:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800699:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80069d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006a2:	75 1a                	jne    8006be <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	68 ff 00 00 00       	push   $0xff
  8006ac:	8d 43 08             	lea    0x8(%ebx),%eax
  8006af:	50                   	push   %eax
  8006b0:	e8 2f 09 00 00       	call   800fe4 <sys_cputs>
		b->idx = 0;
  8006b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006bb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8006be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c5:	c9                   	leave  
  8006c6:	c3                   	ret    

008006c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006c7:	55                   	push   %ebp
  8006c8:	89 e5                	mov    %esp,%ebp
  8006ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006d7:	00 00 00 
	b.cnt = 0;
  8006da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	ff 75 08             	pushl  0x8(%ebp)
  8006ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006f0:	50                   	push   %eax
  8006f1:	68 85 06 80 00       	push   $0x800685
  8006f6:	e8 54 01 00 00       	call   80084f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006fb:	83 c4 08             	add    $0x8,%esp
  8006fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800704:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	e8 d4 08 00 00       	call   800fe4 <sys_cputs>

	return b.cnt;
}
  800710:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80071e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800721:	50                   	push   %eax
  800722:	ff 75 08             	pushl  0x8(%ebp)
  800725:	e8 9d ff ff ff       	call   8006c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	57                   	push   %edi
  800730:	56                   	push   %esi
  800731:	53                   	push   %ebx
  800732:	83 ec 1c             	sub    $0x1c,%esp
  800735:	89 c7                	mov    %eax,%edi
  800737:	89 d6                	mov    %edx,%esi
  800739:	8b 45 08             	mov    0x8(%ebp),%eax
  80073c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800742:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800745:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800748:	bb 00 00 00 00       	mov    $0x0,%ebx
  80074d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800750:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800753:	39 d3                	cmp    %edx,%ebx
  800755:	72 05                	jb     80075c <printnum+0x30>
  800757:	39 45 10             	cmp    %eax,0x10(%ebp)
  80075a:	77 45                	ja     8007a1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80075c:	83 ec 0c             	sub    $0xc,%esp
  80075f:	ff 75 18             	pushl  0x18(%ebp)
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800768:	53                   	push   %ebx
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800772:	ff 75 e0             	pushl  -0x20(%ebp)
  800775:	ff 75 dc             	pushl  -0x24(%ebp)
  800778:	ff 75 d8             	pushl  -0x28(%ebp)
  80077b:	e8 e0 19 00 00       	call   802160 <__udivdi3>
  800780:	83 c4 18             	add    $0x18,%esp
  800783:	52                   	push   %edx
  800784:	50                   	push   %eax
  800785:	89 f2                	mov    %esi,%edx
  800787:	89 f8                	mov    %edi,%eax
  800789:	e8 9e ff ff ff       	call   80072c <printnum>
  80078e:	83 c4 20             	add    $0x20,%esp
  800791:	eb 18                	jmp    8007ab <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800793:	83 ec 08             	sub    $0x8,%esp
  800796:	56                   	push   %esi
  800797:	ff 75 18             	pushl  0x18(%ebp)
  80079a:	ff d7                	call   *%edi
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	eb 03                	jmp    8007a4 <printnum+0x78>
  8007a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007a4:	83 eb 01             	sub    $0x1,%ebx
  8007a7:	85 db                	test   %ebx,%ebx
  8007a9:	7f e8                	jg     800793 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	56                   	push   %esi
  8007af:	83 ec 04             	sub    $0x4,%esp
  8007b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8007bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8007be:	e8 cd 1a 00 00       	call   802290 <__umoddi3>
  8007c3:	83 c4 14             	add    $0x14,%esp
  8007c6:	0f be 80 43 25 80 00 	movsbl 0x802543(%eax),%eax
  8007cd:	50                   	push   %eax
  8007ce:	ff d7                	call   *%edi
}
  8007d0:	83 c4 10             	add    $0x10,%esp
  8007d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	5f                   	pop    %edi
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007de:	83 fa 01             	cmp    $0x1,%edx
  8007e1:	7e 0e                	jle    8007f1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007e3:	8b 10                	mov    (%eax),%edx
  8007e5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007e8:	89 08                	mov    %ecx,(%eax)
  8007ea:	8b 02                	mov    (%edx),%eax
  8007ec:	8b 52 04             	mov    0x4(%edx),%edx
  8007ef:	eb 22                	jmp    800813 <getuint+0x38>
	else if (lflag)
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	74 10                	je     800805 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007f5:	8b 10                	mov    (%eax),%edx
  8007f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007fa:	89 08                	mov    %ecx,(%eax)
  8007fc:	8b 02                	mov    (%edx),%eax
  8007fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800803:	eb 0e                	jmp    800813 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800805:	8b 10                	mov    (%eax),%edx
  800807:	8d 4a 04             	lea    0x4(%edx),%ecx
  80080a:	89 08                	mov    %ecx,(%eax)
  80080c:	8b 02                	mov    (%edx),%eax
  80080e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80081b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80081f:	8b 10                	mov    (%eax),%edx
  800821:	3b 50 04             	cmp    0x4(%eax),%edx
  800824:	73 0a                	jae    800830 <sprintputch+0x1b>
		*b->buf++ = ch;
  800826:	8d 4a 01             	lea    0x1(%edx),%ecx
  800829:	89 08                	mov    %ecx,(%eax)
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	88 02                	mov    %al,(%edx)
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800838:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80083b:	50                   	push   %eax
  80083c:	ff 75 10             	pushl  0x10(%ebp)
  80083f:	ff 75 0c             	pushl  0xc(%ebp)
  800842:	ff 75 08             	pushl  0x8(%ebp)
  800845:	e8 05 00 00 00       	call   80084f <vprintfmt>
	va_end(ap);
}
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	57                   	push   %edi
  800853:	56                   	push   %esi
  800854:	53                   	push   %ebx
  800855:	83 ec 2c             	sub    $0x2c,%esp
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80085e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800861:	eb 12                	jmp    800875 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800863:	85 c0                	test   %eax,%eax
  800865:	0f 84 89 03 00 00    	je     800bf4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	53                   	push   %ebx
  80086f:	50                   	push   %eax
  800870:	ff d6                	call   *%esi
  800872:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800875:	83 c7 01             	add    $0x1,%edi
  800878:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80087c:	83 f8 25             	cmp    $0x25,%eax
  80087f:	75 e2                	jne    800863 <vprintfmt+0x14>
  800881:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800885:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80088c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800893:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80089a:	ba 00 00 00 00       	mov    $0x0,%edx
  80089f:	eb 07                	jmp    8008a8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008a4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a8:	8d 47 01             	lea    0x1(%edi),%eax
  8008ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008ae:	0f b6 07             	movzbl (%edi),%eax
  8008b1:	0f b6 c8             	movzbl %al,%ecx
  8008b4:	83 e8 23             	sub    $0x23,%eax
  8008b7:	3c 55                	cmp    $0x55,%al
  8008b9:	0f 87 1a 03 00 00    	ja     800bd9 <vprintfmt+0x38a>
  8008bf:	0f b6 c0             	movzbl %al,%eax
  8008c2:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  8008c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008cc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008d0:	eb d6                	jmp    8008a8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008dd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008e0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8008e4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8008e7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8008ea:	83 fa 09             	cmp    $0x9,%edx
  8008ed:	77 39                	ja     800928 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008ef:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008f2:	eb e9                	jmp    8008dd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f7:	8d 48 04             	lea    0x4(%eax),%ecx
  8008fa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008fd:	8b 00                	mov    (%eax),%eax
  8008ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800902:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800905:	eb 27                	jmp    80092e <vprintfmt+0xdf>
  800907:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80090a:	85 c0                	test   %eax,%eax
  80090c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800911:	0f 49 c8             	cmovns %eax,%ecx
  800914:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800917:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80091a:	eb 8c                	jmp    8008a8 <vprintfmt+0x59>
  80091c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80091f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800926:	eb 80                	jmp    8008a8 <vprintfmt+0x59>
  800928:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80092b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80092e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800932:	0f 89 70 ff ff ff    	jns    8008a8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800938:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80093b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80093e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800945:	e9 5e ff ff ff       	jmp    8008a8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80094a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800950:	e9 53 ff ff ff       	jmp    8008a8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800955:	8b 45 14             	mov    0x14(%ebp),%eax
  800958:	8d 50 04             	lea    0x4(%eax),%edx
  80095b:	89 55 14             	mov    %edx,0x14(%ebp)
  80095e:	83 ec 08             	sub    $0x8,%esp
  800961:	53                   	push   %ebx
  800962:	ff 30                	pushl  (%eax)
  800964:	ff d6                	call   *%esi
			break;
  800966:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800969:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80096c:	e9 04 ff ff ff       	jmp    800875 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800971:	8b 45 14             	mov    0x14(%ebp),%eax
  800974:	8d 50 04             	lea    0x4(%eax),%edx
  800977:	89 55 14             	mov    %edx,0x14(%ebp)
  80097a:	8b 00                	mov    (%eax),%eax
  80097c:	99                   	cltd   
  80097d:	31 d0                	xor    %edx,%eax
  80097f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800981:	83 f8 0f             	cmp    $0xf,%eax
  800984:	7f 0b                	jg     800991 <vprintfmt+0x142>
  800986:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  80098d:	85 d2                	test   %edx,%edx
  80098f:	75 18                	jne    8009a9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800991:	50                   	push   %eax
  800992:	68 5b 25 80 00       	push   $0x80255b
  800997:	53                   	push   %ebx
  800998:	56                   	push   %esi
  800999:	e8 94 fe ff ff       	call   800832 <printfmt>
  80099e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009a4:	e9 cc fe ff ff       	jmp    800875 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009a9:	52                   	push   %edx
  8009aa:	68 25 29 80 00       	push   $0x802925
  8009af:	53                   	push   %ebx
  8009b0:	56                   	push   %esi
  8009b1:	e8 7c fe ff ff       	call   800832 <printfmt>
  8009b6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009bc:	e9 b4 fe ff ff       	jmp    800875 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c4:	8d 50 04             	lea    0x4(%eax),%edx
  8009c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ca:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009cc:	85 ff                	test   %edi,%edi
  8009ce:	b8 54 25 80 00       	mov    $0x802554,%eax
  8009d3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009da:	0f 8e 94 00 00 00    	jle    800a74 <vprintfmt+0x225>
  8009e0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009e4:	0f 84 98 00 00 00    	je     800a82 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ea:	83 ec 08             	sub    $0x8,%esp
  8009ed:	ff 75 d0             	pushl  -0x30(%ebp)
  8009f0:	57                   	push   %edi
  8009f1:	e8 86 02 00 00       	call   800c7c <strnlen>
  8009f6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009f9:	29 c1                	sub    %eax,%ecx
  8009fb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009fe:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a01:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a05:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a08:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a0b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a0d:	eb 0f                	jmp    800a1e <vprintfmt+0x1cf>
					putch(padc, putdat);
  800a0f:	83 ec 08             	sub    $0x8,%esp
  800a12:	53                   	push   %ebx
  800a13:	ff 75 e0             	pushl  -0x20(%ebp)
  800a16:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a18:	83 ef 01             	sub    $0x1,%edi
  800a1b:	83 c4 10             	add    $0x10,%esp
  800a1e:	85 ff                	test   %edi,%edi
  800a20:	7f ed                	jg     800a0f <vprintfmt+0x1c0>
  800a22:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a25:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a28:	85 c9                	test   %ecx,%ecx
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	0f 49 c1             	cmovns %ecx,%eax
  800a32:	29 c1                	sub    %eax,%ecx
  800a34:	89 75 08             	mov    %esi,0x8(%ebp)
  800a37:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a3a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a3d:	89 cb                	mov    %ecx,%ebx
  800a3f:	eb 4d                	jmp    800a8e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a41:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a45:	74 1b                	je     800a62 <vprintfmt+0x213>
  800a47:	0f be c0             	movsbl %al,%eax
  800a4a:	83 e8 20             	sub    $0x20,%eax
  800a4d:	83 f8 5e             	cmp    $0x5e,%eax
  800a50:	76 10                	jbe    800a62 <vprintfmt+0x213>
					putch('?', putdat);
  800a52:	83 ec 08             	sub    $0x8,%esp
  800a55:	ff 75 0c             	pushl  0xc(%ebp)
  800a58:	6a 3f                	push   $0x3f
  800a5a:	ff 55 08             	call   *0x8(%ebp)
  800a5d:	83 c4 10             	add    $0x10,%esp
  800a60:	eb 0d                	jmp    800a6f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a62:	83 ec 08             	sub    $0x8,%esp
  800a65:	ff 75 0c             	pushl  0xc(%ebp)
  800a68:	52                   	push   %edx
  800a69:	ff 55 08             	call   *0x8(%ebp)
  800a6c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a6f:	83 eb 01             	sub    $0x1,%ebx
  800a72:	eb 1a                	jmp    800a8e <vprintfmt+0x23f>
  800a74:	89 75 08             	mov    %esi,0x8(%ebp)
  800a77:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a7a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a7d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a80:	eb 0c                	jmp    800a8e <vprintfmt+0x23f>
  800a82:	89 75 08             	mov    %esi,0x8(%ebp)
  800a85:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a88:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a8b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a8e:	83 c7 01             	add    $0x1,%edi
  800a91:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a95:	0f be d0             	movsbl %al,%edx
  800a98:	85 d2                	test   %edx,%edx
  800a9a:	74 23                	je     800abf <vprintfmt+0x270>
  800a9c:	85 f6                	test   %esi,%esi
  800a9e:	78 a1                	js     800a41 <vprintfmt+0x1f2>
  800aa0:	83 ee 01             	sub    $0x1,%esi
  800aa3:	79 9c                	jns    800a41 <vprintfmt+0x1f2>
  800aa5:	89 df                	mov    %ebx,%edi
  800aa7:	8b 75 08             	mov    0x8(%ebp),%esi
  800aaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aad:	eb 18                	jmp    800ac7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aaf:	83 ec 08             	sub    $0x8,%esp
  800ab2:	53                   	push   %ebx
  800ab3:	6a 20                	push   $0x20
  800ab5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ab7:	83 ef 01             	sub    $0x1,%edi
  800aba:	83 c4 10             	add    $0x10,%esp
  800abd:	eb 08                	jmp    800ac7 <vprintfmt+0x278>
  800abf:	89 df                	mov    %ebx,%edi
  800ac1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac7:	85 ff                	test   %edi,%edi
  800ac9:	7f e4                	jg     800aaf <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800acb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ace:	e9 a2 fd ff ff       	jmp    800875 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800ad3:	83 fa 01             	cmp    $0x1,%edx
  800ad6:	7e 16                	jle    800aee <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800ad8:	8b 45 14             	mov    0x14(%ebp),%eax
  800adb:	8d 50 08             	lea    0x8(%eax),%edx
  800ade:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae1:	8b 50 04             	mov    0x4(%eax),%edx
  800ae4:	8b 00                	mov    (%eax),%eax
  800ae6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aec:	eb 32                	jmp    800b20 <vprintfmt+0x2d1>
	else if (lflag)
  800aee:	85 d2                	test   %edx,%edx
  800af0:	74 18                	je     800b0a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800af2:	8b 45 14             	mov    0x14(%ebp),%eax
  800af5:	8d 50 04             	lea    0x4(%eax),%edx
  800af8:	89 55 14             	mov    %edx,0x14(%ebp)
  800afb:	8b 00                	mov    (%eax),%eax
  800afd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b00:	89 c1                	mov    %eax,%ecx
  800b02:	c1 f9 1f             	sar    $0x1f,%ecx
  800b05:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b08:	eb 16                	jmp    800b20 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800b0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0d:	8d 50 04             	lea    0x4(%eax),%edx
  800b10:	89 55 14             	mov    %edx,0x14(%ebp)
  800b13:	8b 00                	mov    (%eax),%eax
  800b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b18:	89 c1                	mov    %eax,%ecx
  800b1a:	c1 f9 1f             	sar    $0x1f,%ecx
  800b1d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b20:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b23:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b26:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b2b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b2f:	79 74                	jns    800ba5 <vprintfmt+0x356>
				putch('-', putdat);
  800b31:	83 ec 08             	sub    $0x8,%esp
  800b34:	53                   	push   %ebx
  800b35:	6a 2d                	push   $0x2d
  800b37:	ff d6                	call   *%esi
				num = -(long long) num;
  800b39:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b3f:	f7 d8                	neg    %eax
  800b41:	83 d2 00             	adc    $0x0,%edx
  800b44:	f7 da                	neg    %edx
  800b46:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b49:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b4e:	eb 55                	jmp    800ba5 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b50:	8d 45 14             	lea    0x14(%ebp),%eax
  800b53:	e8 83 fc ff ff       	call   8007db <getuint>
			base = 10;
  800b58:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b5d:	eb 46                	jmp    800ba5 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b5f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b62:	e8 74 fc ff ff       	call   8007db <getuint>
			base = 8;
  800b67:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b6c:	eb 37                	jmp    800ba5 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b6e:	83 ec 08             	sub    $0x8,%esp
  800b71:	53                   	push   %ebx
  800b72:	6a 30                	push   $0x30
  800b74:	ff d6                	call   *%esi
			putch('x', putdat);
  800b76:	83 c4 08             	add    $0x8,%esp
  800b79:	53                   	push   %ebx
  800b7a:	6a 78                	push   $0x78
  800b7c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b81:	8d 50 04             	lea    0x4(%eax),%edx
  800b84:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b87:	8b 00                	mov    (%eax),%eax
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b8e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b91:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b96:	eb 0d                	jmp    800ba5 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b98:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9b:	e8 3b fc ff ff       	call   8007db <getuint>
			base = 16;
  800ba0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bac:	57                   	push   %edi
  800bad:	ff 75 e0             	pushl  -0x20(%ebp)
  800bb0:	51                   	push   %ecx
  800bb1:	52                   	push   %edx
  800bb2:	50                   	push   %eax
  800bb3:	89 da                	mov    %ebx,%edx
  800bb5:	89 f0                	mov    %esi,%eax
  800bb7:	e8 70 fb ff ff       	call   80072c <printnum>
			break;
  800bbc:	83 c4 20             	add    $0x20,%esp
  800bbf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bc2:	e9 ae fc ff ff       	jmp    800875 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bc7:	83 ec 08             	sub    $0x8,%esp
  800bca:	53                   	push   %ebx
  800bcb:	51                   	push   %ecx
  800bcc:	ff d6                	call   *%esi
			break;
  800bce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bd4:	e9 9c fc ff ff       	jmp    800875 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bd9:	83 ec 08             	sub    $0x8,%esp
  800bdc:	53                   	push   %ebx
  800bdd:	6a 25                	push   $0x25
  800bdf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800be1:	83 c4 10             	add    $0x10,%esp
  800be4:	eb 03                	jmp    800be9 <vprintfmt+0x39a>
  800be6:	83 ef 01             	sub    $0x1,%edi
  800be9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800bed:	75 f7                	jne    800be6 <vprintfmt+0x397>
  800bef:	e9 81 fc ff ff       	jmp    800875 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 18             	sub    $0x18,%esp
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c08:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c0b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c0f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c19:	85 c0                	test   %eax,%eax
  800c1b:	74 26                	je     800c43 <vsnprintf+0x47>
  800c1d:	85 d2                	test   %edx,%edx
  800c1f:	7e 22                	jle    800c43 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c21:	ff 75 14             	pushl  0x14(%ebp)
  800c24:	ff 75 10             	pushl  0x10(%ebp)
  800c27:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c2a:	50                   	push   %eax
  800c2b:	68 15 08 80 00       	push   $0x800815
  800c30:	e8 1a fc ff ff       	call   80084f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c35:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c38:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	eb 05                	jmp    800c48 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c48:	c9                   	leave  
  800c49:	c3                   	ret    

00800c4a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c50:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c53:	50                   	push   %eax
  800c54:	ff 75 10             	pushl  0x10(%ebp)
  800c57:	ff 75 0c             	pushl  0xc(%ebp)
  800c5a:	ff 75 08             	pushl  0x8(%ebp)
  800c5d:	e8 9a ff ff ff       	call   800bfc <vsnprintf>
	va_end(ap);

	return rc;
}
  800c62:	c9                   	leave  
  800c63:	c3                   	ret    

00800c64 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6f:	eb 03                	jmp    800c74 <strlen+0x10>
		n++;
  800c71:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c74:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c78:	75 f7                	jne    800c71 <strlen+0xd>
		n++;
	return n;
}
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c82:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c85:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8a:	eb 03                	jmp    800c8f <strnlen+0x13>
		n++;
  800c8c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c8f:	39 c2                	cmp    %eax,%edx
  800c91:	74 08                	je     800c9b <strnlen+0x1f>
  800c93:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c97:	75 f3                	jne    800c8c <strnlen+0x10>
  800c99:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	53                   	push   %ebx
  800ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ca7:	89 c2                	mov    %eax,%edx
  800ca9:	83 c2 01             	add    $0x1,%edx
  800cac:	83 c1 01             	add    $0x1,%ecx
  800caf:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cb3:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cb6:	84 db                	test   %bl,%bl
  800cb8:	75 ef                	jne    800ca9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cba:	5b                   	pop    %ebx
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	53                   	push   %ebx
  800cc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cc4:	53                   	push   %ebx
  800cc5:	e8 9a ff ff ff       	call   800c64 <strlen>
  800cca:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ccd:	ff 75 0c             	pushl  0xc(%ebp)
  800cd0:	01 d8                	add    %ebx,%eax
  800cd2:	50                   	push   %eax
  800cd3:	e8 c5 ff ff ff       	call   800c9d <strcpy>
	return dst;
}
  800cd8:	89 d8                	mov    %ebx,%eax
  800cda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cdd:	c9                   	leave  
  800cde:	c3                   	ret    

00800cdf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	89 f3                	mov    %esi,%ebx
  800cec:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cef:	89 f2                	mov    %esi,%edx
  800cf1:	eb 0f                	jmp    800d02 <strncpy+0x23>
		*dst++ = *src;
  800cf3:	83 c2 01             	add    $0x1,%edx
  800cf6:	0f b6 01             	movzbl (%ecx),%eax
  800cf9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cfc:	80 39 01             	cmpb   $0x1,(%ecx)
  800cff:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d02:	39 da                	cmp    %ebx,%edx
  800d04:	75 ed                	jne    800cf3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d06:	89 f0                	mov    %esi,%eax
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	8b 75 08             	mov    0x8(%ebp),%esi
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 10             	mov    0x10(%ebp),%edx
  800d1a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d1c:	85 d2                	test   %edx,%edx
  800d1e:	74 21                	je     800d41 <strlcpy+0x35>
  800d20:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d24:	89 f2                	mov    %esi,%edx
  800d26:	eb 09                	jmp    800d31 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d28:	83 c2 01             	add    $0x1,%edx
  800d2b:	83 c1 01             	add    $0x1,%ecx
  800d2e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d31:	39 c2                	cmp    %eax,%edx
  800d33:	74 09                	je     800d3e <strlcpy+0x32>
  800d35:	0f b6 19             	movzbl (%ecx),%ebx
  800d38:	84 db                	test   %bl,%bl
  800d3a:	75 ec                	jne    800d28 <strlcpy+0x1c>
  800d3c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d3e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d41:	29 f0                	sub    %esi,%eax
}
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d50:	eb 06                	jmp    800d58 <strcmp+0x11>
		p++, q++;
  800d52:	83 c1 01             	add    $0x1,%ecx
  800d55:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d58:	0f b6 01             	movzbl (%ecx),%eax
  800d5b:	84 c0                	test   %al,%al
  800d5d:	74 04                	je     800d63 <strcmp+0x1c>
  800d5f:	3a 02                	cmp    (%edx),%al
  800d61:	74 ef                	je     800d52 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d63:	0f b6 c0             	movzbl %al,%eax
  800d66:	0f b6 12             	movzbl (%edx),%edx
  800d69:	29 d0                	sub    %edx,%eax
}
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	53                   	push   %ebx
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d77:	89 c3                	mov    %eax,%ebx
  800d79:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d7c:	eb 06                	jmp    800d84 <strncmp+0x17>
		n--, p++, q++;
  800d7e:	83 c0 01             	add    $0x1,%eax
  800d81:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d84:	39 d8                	cmp    %ebx,%eax
  800d86:	74 15                	je     800d9d <strncmp+0x30>
  800d88:	0f b6 08             	movzbl (%eax),%ecx
  800d8b:	84 c9                	test   %cl,%cl
  800d8d:	74 04                	je     800d93 <strncmp+0x26>
  800d8f:	3a 0a                	cmp    (%edx),%cl
  800d91:	74 eb                	je     800d7e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d93:	0f b6 00             	movzbl (%eax),%eax
  800d96:	0f b6 12             	movzbl (%edx),%edx
  800d99:	29 d0                	sub    %edx,%eax
  800d9b:	eb 05                	jmp    800da2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d9d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800da2:	5b                   	pop    %ebx
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800daf:	eb 07                	jmp    800db8 <strchr+0x13>
		if (*s == c)
  800db1:	38 ca                	cmp    %cl,%dl
  800db3:	74 0f                	je     800dc4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800db5:	83 c0 01             	add    $0x1,%eax
  800db8:	0f b6 10             	movzbl (%eax),%edx
  800dbb:	84 d2                	test   %dl,%dl
  800dbd:	75 f2                	jne    800db1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800dbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dd0:	eb 03                	jmp    800dd5 <strfind+0xf>
  800dd2:	83 c0 01             	add    $0x1,%eax
  800dd5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800dd8:	38 ca                	cmp    %cl,%dl
  800dda:	74 04                	je     800de0 <strfind+0x1a>
  800ddc:	84 d2                	test   %dl,%dl
  800dde:	75 f2                	jne    800dd2 <strfind+0xc>
			break;
	return (char *) s;
}
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800deb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dee:	85 c9                	test   %ecx,%ecx
  800df0:	74 36                	je     800e28 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800df2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800df8:	75 28                	jne    800e22 <memset+0x40>
  800dfa:	f6 c1 03             	test   $0x3,%cl
  800dfd:	75 23                	jne    800e22 <memset+0x40>
		c &= 0xFF;
  800dff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e03:	89 d3                	mov    %edx,%ebx
  800e05:	c1 e3 08             	shl    $0x8,%ebx
  800e08:	89 d6                	mov    %edx,%esi
  800e0a:	c1 e6 18             	shl    $0x18,%esi
  800e0d:	89 d0                	mov    %edx,%eax
  800e0f:	c1 e0 10             	shl    $0x10,%eax
  800e12:	09 f0                	or     %esi,%eax
  800e14:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e16:	89 d8                	mov    %ebx,%eax
  800e18:	09 d0                	or     %edx,%eax
  800e1a:	c1 e9 02             	shr    $0x2,%ecx
  800e1d:	fc                   	cld    
  800e1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800e20:	eb 06                	jmp    800e28 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e25:	fc                   	cld    
  800e26:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e28:	89 f8                	mov    %edi,%eax
  800e2a:	5b                   	pop    %ebx
  800e2b:	5e                   	pop    %esi
  800e2c:	5f                   	pop    %edi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
  800e33:	56                   	push   %esi
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e3d:	39 c6                	cmp    %eax,%esi
  800e3f:	73 35                	jae    800e76 <memmove+0x47>
  800e41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e44:	39 d0                	cmp    %edx,%eax
  800e46:	73 2e                	jae    800e76 <memmove+0x47>
		s += n;
		d += n;
  800e48:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e4b:	89 d6                	mov    %edx,%esi
  800e4d:	09 fe                	or     %edi,%esi
  800e4f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e55:	75 13                	jne    800e6a <memmove+0x3b>
  800e57:	f6 c1 03             	test   $0x3,%cl
  800e5a:	75 0e                	jne    800e6a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e5c:	83 ef 04             	sub    $0x4,%edi
  800e5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e62:	c1 e9 02             	shr    $0x2,%ecx
  800e65:	fd                   	std    
  800e66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e68:	eb 09                	jmp    800e73 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e6a:	83 ef 01             	sub    $0x1,%edi
  800e6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e70:	fd                   	std    
  800e71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e73:	fc                   	cld    
  800e74:	eb 1d                	jmp    800e93 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e76:	89 f2                	mov    %esi,%edx
  800e78:	09 c2                	or     %eax,%edx
  800e7a:	f6 c2 03             	test   $0x3,%dl
  800e7d:	75 0f                	jne    800e8e <memmove+0x5f>
  800e7f:	f6 c1 03             	test   $0x3,%cl
  800e82:	75 0a                	jne    800e8e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e84:	c1 e9 02             	shr    $0x2,%ecx
  800e87:	89 c7                	mov    %eax,%edi
  800e89:	fc                   	cld    
  800e8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e8c:	eb 05                	jmp    800e93 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e8e:	89 c7                	mov    %eax,%edi
  800e90:	fc                   	cld    
  800e91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e9a:	ff 75 10             	pushl  0x10(%ebp)
  800e9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ea0:	ff 75 08             	pushl  0x8(%ebp)
  800ea3:	e8 87 ff ff ff       	call   800e2f <memmove>
}
  800ea8:	c9                   	leave  
  800ea9:	c3                   	ret    

00800eaa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb5:	89 c6                	mov    %eax,%esi
  800eb7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eba:	eb 1a                	jmp    800ed6 <memcmp+0x2c>
		if (*s1 != *s2)
  800ebc:	0f b6 08             	movzbl (%eax),%ecx
  800ebf:	0f b6 1a             	movzbl (%edx),%ebx
  800ec2:	38 d9                	cmp    %bl,%cl
  800ec4:	74 0a                	je     800ed0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ec6:	0f b6 c1             	movzbl %cl,%eax
  800ec9:	0f b6 db             	movzbl %bl,%ebx
  800ecc:	29 d8                	sub    %ebx,%eax
  800ece:	eb 0f                	jmp    800edf <memcmp+0x35>
		s1++, s2++;
  800ed0:	83 c0 01             	add    $0x1,%eax
  800ed3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ed6:	39 f0                	cmp    %esi,%eax
  800ed8:	75 e2                	jne    800ebc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800edf:	5b                   	pop    %ebx
  800ee0:	5e                   	pop    %esi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	53                   	push   %ebx
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800eea:	89 c1                	mov    %eax,%ecx
  800eec:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800eef:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ef3:	eb 0a                	jmp    800eff <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ef5:	0f b6 10             	movzbl (%eax),%edx
  800ef8:	39 da                	cmp    %ebx,%edx
  800efa:	74 07                	je     800f03 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800efc:	83 c0 01             	add    $0x1,%eax
  800eff:	39 c8                	cmp    %ecx,%eax
  800f01:	72 f2                	jb     800ef5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f03:	5b                   	pop    %ebx
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f12:	eb 03                	jmp    800f17 <strtol+0x11>
		s++;
  800f14:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f17:	0f b6 01             	movzbl (%ecx),%eax
  800f1a:	3c 20                	cmp    $0x20,%al
  800f1c:	74 f6                	je     800f14 <strtol+0xe>
  800f1e:	3c 09                	cmp    $0x9,%al
  800f20:	74 f2                	je     800f14 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f22:	3c 2b                	cmp    $0x2b,%al
  800f24:	75 0a                	jne    800f30 <strtol+0x2a>
		s++;
  800f26:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f29:	bf 00 00 00 00       	mov    $0x0,%edi
  800f2e:	eb 11                	jmp    800f41 <strtol+0x3b>
  800f30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f35:	3c 2d                	cmp    $0x2d,%al
  800f37:	75 08                	jne    800f41 <strtol+0x3b>
		s++, neg = 1;
  800f39:	83 c1 01             	add    $0x1,%ecx
  800f3c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f41:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f47:	75 15                	jne    800f5e <strtol+0x58>
  800f49:	80 39 30             	cmpb   $0x30,(%ecx)
  800f4c:	75 10                	jne    800f5e <strtol+0x58>
  800f4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f52:	75 7c                	jne    800fd0 <strtol+0xca>
		s += 2, base = 16;
  800f54:	83 c1 02             	add    $0x2,%ecx
  800f57:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f5c:	eb 16                	jmp    800f74 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f5e:	85 db                	test   %ebx,%ebx
  800f60:	75 12                	jne    800f74 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f62:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f67:	80 39 30             	cmpb   $0x30,(%ecx)
  800f6a:	75 08                	jne    800f74 <strtol+0x6e>
		s++, base = 8;
  800f6c:	83 c1 01             	add    $0x1,%ecx
  800f6f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
  800f79:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f7c:	0f b6 11             	movzbl (%ecx),%edx
  800f7f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f82:	89 f3                	mov    %esi,%ebx
  800f84:	80 fb 09             	cmp    $0x9,%bl
  800f87:	77 08                	ja     800f91 <strtol+0x8b>
			dig = *s - '0';
  800f89:	0f be d2             	movsbl %dl,%edx
  800f8c:	83 ea 30             	sub    $0x30,%edx
  800f8f:	eb 22                	jmp    800fb3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f91:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f94:	89 f3                	mov    %esi,%ebx
  800f96:	80 fb 19             	cmp    $0x19,%bl
  800f99:	77 08                	ja     800fa3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f9b:	0f be d2             	movsbl %dl,%edx
  800f9e:	83 ea 57             	sub    $0x57,%edx
  800fa1:	eb 10                	jmp    800fb3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fa3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fa6:	89 f3                	mov    %esi,%ebx
  800fa8:	80 fb 19             	cmp    $0x19,%bl
  800fab:	77 16                	ja     800fc3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800fad:	0f be d2             	movsbl %dl,%edx
  800fb0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fb3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fb6:	7d 0b                	jge    800fc3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800fb8:	83 c1 01             	add    $0x1,%ecx
  800fbb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fbf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800fc1:	eb b9                	jmp    800f7c <strtol+0x76>

	if (endptr)
  800fc3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fc7:	74 0d                	je     800fd6 <strtol+0xd0>
		*endptr = (char *) s;
  800fc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fcc:	89 0e                	mov    %ecx,(%esi)
  800fce:	eb 06                	jmp    800fd6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fd0:	85 db                	test   %ebx,%ebx
  800fd2:	74 98                	je     800f6c <strtol+0x66>
  800fd4:	eb 9e                	jmp    800f74 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fd6:	89 c2                	mov    %eax,%edx
  800fd8:	f7 da                	neg    %edx
  800fda:	85 ff                	test   %edi,%edi
  800fdc:	0f 45 c2             	cmovne %edx,%eax
}
  800fdf:	5b                   	pop    %ebx
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	57                   	push   %edi
  800fe8:	56                   	push   %esi
  800fe9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fea:	b8 00 00 00 00       	mov    $0x0,%eax
  800fef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff5:	89 c3                	mov    %eax,%ebx
  800ff7:	89 c7                	mov    %eax,%edi
  800ff9:	89 c6                	mov    %eax,%esi
  800ffb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ffd:	5b                   	pop    %ebx
  800ffe:	5e                   	pop    %esi
  800fff:	5f                   	pop    %edi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <sys_cgetc>:

int
sys_cgetc(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	57                   	push   %edi
  801006:	56                   	push   %esi
  801007:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801008:	ba 00 00 00 00       	mov    $0x0,%edx
  80100d:	b8 01 00 00 00       	mov    $0x1,%eax
  801012:	89 d1                	mov    %edx,%ecx
  801014:	89 d3                	mov    %edx,%ebx
  801016:	89 d7                	mov    %edx,%edi
  801018:	89 d6                	mov    %edx,%esi
  80101a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5f                   	pop    %edi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	57                   	push   %edi
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80102f:	b8 03 00 00 00       	mov    $0x3,%eax
  801034:	8b 55 08             	mov    0x8(%ebp),%edx
  801037:	89 cb                	mov    %ecx,%ebx
  801039:	89 cf                	mov    %ecx,%edi
  80103b:	89 ce                	mov    %ecx,%esi
  80103d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80103f:	85 c0                	test   %eax,%eax
  801041:	7e 17                	jle    80105a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	50                   	push   %eax
  801047:	6a 03                	push   $0x3
  801049:	68 3f 28 80 00       	push   $0x80283f
  80104e:	6a 23                	push   $0x23
  801050:	68 5c 28 80 00       	push   $0x80285c
  801055:	e8 e5 f5 ff ff       	call   80063f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80105a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5f                   	pop    %edi
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	57                   	push   %edi
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801068:	ba 00 00 00 00       	mov    $0x0,%edx
  80106d:	b8 02 00 00 00       	mov    $0x2,%eax
  801072:	89 d1                	mov    %edx,%ecx
  801074:	89 d3                	mov    %edx,%ebx
  801076:	89 d7                	mov    %edx,%edi
  801078:	89 d6                	mov    %edx,%esi
  80107a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <sys_yield>:

void
sys_yield(void)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	57                   	push   %edi
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801087:	ba 00 00 00 00       	mov    $0x0,%edx
  80108c:	b8 0b 00 00 00       	mov    $0xb,%eax
  801091:	89 d1                	mov    %edx,%ecx
  801093:	89 d3                	mov    %edx,%ebx
  801095:	89 d7                	mov    %edx,%edi
  801097:	89 d6                	mov    %edx,%esi
  801099:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5f                   	pop    %edi
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a9:	be 00 00 00 00       	mov    $0x0,%esi
  8010ae:	b8 04 00 00 00       	mov    $0x4,%eax
  8010b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010bc:	89 f7                	mov    %esi,%edi
  8010be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	7e 17                	jle    8010db <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	50                   	push   %eax
  8010c8:	6a 04                	push   $0x4
  8010ca:	68 3f 28 80 00       	push   $0x80283f
  8010cf:	6a 23                	push   $0x23
  8010d1:	68 5c 28 80 00       	push   $0x80285c
  8010d6:	e8 64 f5 ff ff       	call   80063f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ec:	b8 05 00 00 00       	mov    $0x5,%eax
  8010f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010fd:	8b 75 18             	mov    0x18(%ebp),%esi
  801100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801102:	85 c0                	test   %eax,%eax
  801104:	7e 17                	jle    80111d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801106:	83 ec 0c             	sub    $0xc,%esp
  801109:	50                   	push   %eax
  80110a:	6a 05                	push   $0x5
  80110c:	68 3f 28 80 00       	push   $0x80283f
  801111:	6a 23                	push   $0x23
  801113:	68 5c 28 80 00       	push   $0x80285c
  801118:	e8 22 f5 ff ff       	call   80063f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80111d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801120:	5b                   	pop    %ebx
  801121:	5e                   	pop    %esi
  801122:	5f                   	pop    %edi
  801123:	5d                   	pop    %ebp
  801124:	c3                   	ret    

00801125 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801125:	55                   	push   %ebp
  801126:	89 e5                	mov    %esp,%ebp
  801128:	57                   	push   %edi
  801129:	56                   	push   %esi
  80112a:	53                   	push   %ebx
  80112b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801133:	b8 06 00 00 00       	mov    $0x6,%eax
  801138:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113b:	8b 55 08             	mov    0x8(%ebp),%edx
  80113e:	89 df                	mov    %ebx,%edi
  801140:	89 de                	mov    %ebx,%esi
  801142:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801144:	85 c0                	test   %eax,%eax
  801146:	7e 17                	jle    80115f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801148:	83 ec 0c             	sub    $0xc,%esp
  80114b:	50                   	push   %eax
  80114c:	6a 06                	push   $0x6
  80114e:	68 3f 28 80 00       	push   $0x80283f
  801153:	6a 23                	push   $0x23
  801155:	68 5c 28 80 00       	push   $0x80285c
  80115a:	e8 e0 f4 ff ff       	call   80063f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80115f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801162:	5b                   	pop    %ebx
  801163:	5e                   	pop    %esi
  801164:	5f                   	pop    %edi
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801170:	bb 00 00 00 00       	mov    $0x0,%ebx
  801175:	b8 08 00 00 00       	mov    $0x8,%eax
  80117a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117d:	8b 55 08             	mov    0x8(%ebp),%edx
  801180:	89 df                	mov    %ebx,%edi
  801182:	89 de                	mov    %ebx,%esi
  801184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801186:	85 c0                	test   %eax,%eax
  801188:	7e 17                	jle    8011a1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118a:	83 ec 0c             	sub    $0xc,%esp
  80118d:	50                   	push   %eax
  80118e:	6a 08                	push   $0x8
  801190:	68 3f 28 80 00       	push   $0x80283f
  801195:	6a 23                	push   $0x23
  801197:	68 5c 28 80 00       	push   $0x80285c
  80119c:	e8 9e f4 ff ff       	call   80063f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	57                   	push   %edi
  8011ad:	56                   	push   %esi
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b7:	b8 09 00 00 00       	mov    $0x9,%eax
  8011bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c2:	89 df                	mov    %ebx,%edi
  8011c4:	89 de                	mov    %ebx,%esi
  8011c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	7e 17                	jle    8011e3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011cc:	83 ec 0c             	sub    $0xc,%esp
  8011cf:	50                   	push   %eax
  8011d0:	6a 09                	push   $0x9
  8011d2:	68 3f 28 80 00       	push   $0x80283f
  8011d7:	6a 23                	push   $0x23
  8011d9:	68 5c 28 80 00       	push   $0x80285c
  8011de:	e8 5c f4 ff ff       	call   80063f <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	57                   	push   %edi
  8011ef:	56                   	push   %esi
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801201:	8b 55 08             	mov    0x8(%ebp),%edx
  801204:	89 df                	mov    %ebx,%edi
  801206:	89 de                	mov    %ebx,%esi
  801208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80120a:	85 c0                	test   %eax,%eax
  80120c:	7e 17                	jle    801225 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80120e:	83 ec 0c             	sub    $0xc,%esp
  801211:	50                   	push   %eax
  801212:	6a 0a                	push   $0xa
  801214:	68 3f 28 80 00       	push   $0x80283f
  801219:	6a 23                	push   $0x23
  80121b:	68 5c 28 80 00       	push   $0x80285c
  801220:	e8 1a f4 ff ff       	call   80063f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801233:	be 00 00 00 00       	mov    $0x0,%esi
  801238:	b8 0c 00 00 00       	mov    $0xc,%eax
  80123d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801240:	8b 55 08             	mov    0x8(%ebp),%edx
  801243:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801246:	8b 7d 14             	mov    0x14(%ebp),%edi
  801249:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	57                   	push   %edi
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801259:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125e:	b8 0d 00 00 00       	mov    $0xd,%eax
  801263:	8b 55 08             	mov    0x8(%ebp),%edx
  801266:	89 cb                	mov    %ecx,%ebx
  801268:	89 cf                	mov    %ecx,%edi
  80126a:	89 ce                	mov    %ecx,%esi
  80126c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80126e:	85 c0                	test   %eax,%eax
  801270:	7e 17                	jle    801289 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801272:	83 ec 0c             	sub    $0xc,%esp
  801275:	50                   	push   %eax
  801276:	6a 0d                	push   $0xd
  801278:	68 3f 28 80 00       	push   $0x80283f
  80127d:	6a 23                	push   $0x23
  80127f:	68 5c 28 80 00       	push   $0x80285c
  801284:	e8 b6 f3 ff ff       	call   80063f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801289:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128c:	5b                   	pop    %ebx
  80128d:	5e                   	pop    %esi
  80128e:	5f                   	pop    %edi
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    

00801291 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801297:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  80129e:	75 2a                	jne    8012ca <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8012a0:	83 ec 04             	sub    $0x4,%esp
  8012a3:	6a 07                	push   $0x7
  8012a5:	68 00 f0 bf ee       	push   $0xeebff000
  8012aa:	6a 00                	push   $0x0
  8012ac:	e8 ef fd ff ff       	call   8010a0 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	79 12                	jns    8012ca <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8012b8:	50                   	push   %eax
  8012b9:	68 6a 28 80 00       	push   $0x80286a
  8012be:	6a 23                	push   $0x23
  8012c0:	68 6e 28 80 00       	push   $0x80286e
  8012c5:	e8 75 f3 ff ff       	call   80063f <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cd:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	68 fc 12 80 00       	push   $0x8012fc
  8012da:	6a 00                	push   $0x0
  8012dc:	e8 0a ff ff ff       	call   8011eb <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8012e1:	83 c4 10             	add    $0x10,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	79 12                	jns    8012fa <set_pgfault_handler+0x69>
		panic("%e\n", r);
  8012e8:	50                   	push   %eax
  8012e9:	68 6a 28 80 00       	push   $0x80286a
  8012ee:	6a 2c                	push   $0x2c
  8012f0:	68 6e 28 80 00       	push   $0x80286e
  8012f5:	e8 45 f3 ff ff       	call   80063f <_panic>
	}
}
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    

008012fc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012fc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012fd:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  801302:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801304:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801307:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80130b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801310:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801314:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801316:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801319:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80131a:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80131d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80131e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80131f:	c3                   	ret    

00801320 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801323:	8b 45 08             	mov    0x8(%ebp),%eax
  801326:	05 00 00 00 30       	add    $0x30000000,%eax
  80132b:	c1 e8 0c             	shr    $0xc,%eax
}
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801333:	8b 45 08             	mov    0x8(%ebp),%eax
  801336:	05 00 00 00 30       	add    $0x30000000,%eax
  80133b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801340:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801352:	89 c2                	mov    %eax,%edx
  801354:	c1 ea 16             	shr    $0x16,%edx
  801357:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80135e:	f6 c2 01             	test   $0x1,%dl
  801361:	74 11                	je     801374 <fd_alloc+0x2d>
  801363:	89 c2                	mov    %eax,%edx
  801365:	c1 ea 0c             	shr    $0xc,%edx
  801368:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136f:	f6 c2 01             	test   $0x1,%dl
  801372:	75 09                	jne    80137d <fd_alloc+0x36>
			*fd_store = fd;
  801374:	89 01                	mov    %eax,(%ecx)
			return 0;
  801376:	b8 00 00 00 00       	mov    $0x0,%eax
  80137b:	eb 17                	jmp    801394 <fd_alloc+0x4d>
  80137d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801382:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801387:	75 c9                	jne    801352 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801389:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80138f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801394:	5d                   	pop    %ebp
  801395:	c3                   	ret    

00801396 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80139c:	83 f8 1f             	cmp    $0x1f,%eax
  80139f:	77 36                	ja     8013d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013a1:	c1 e0 0c             	shl    $0xc,%eax
  8013a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	c1 ea 16             	shr    $0x16,%edx
  8013ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013b5:	f6 c2 01             	test   $0x1,%dl
  8013b8:	74 24                	je     8013de <fd_lookup+0x48>
  8013ba:	89 c2                	mov    %eax,%edx
  8013bc:	c1 ea 0c             	shr    $0xc,%edx
  8013bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c6:	f6 c2 01             	test   $0x1,%dl
  8013c9:	74 1a                	je     8013e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8013d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d5:	eb 13                	jmp    8013ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013dc:	eb 0c                	jmp    8013ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e3:	eb 05                	jmp    8013ea <fd_lookup+0x54>
  8013e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f5:	ba fc 28 80 00       	mov    $0x8028fc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013fa:	eb 13                	jmp    80140f <dev_lookup+0x23>
  8013fc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013ff:	39 08                	cmp    %ecx,(%eax)
  801401:	75 0c                	jne    80140f <dev_lookup+0x23>
			*dev = devtab[i];
  801403:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801406:	89 01                	mov    %eax,(%ecx)
			return 0;
  801408:	b8 00 00 00 00       	mov    $0x0,%eax
  80140d:	eb 2e                	jmp    80143d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80140f:	8b 02                	mov    (%edx),%eax
  801411:	85 c0                	test   %eax,%eax
  801413:	75 e7                	jne    8013fc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801415:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80141a:	8b 40 48             	mov    0x48(%eax),%eax
  80141d:	83 ec 04             	sub    $0x4,%esp
  801420:	51                   	push   %ecx
  801421:	50                   	push   %eax
  801422:	68 7c 28 80 00       	push   $0x80287c
  801427:	e8 ec f2 ff ff       	call   800718 <cprintf>
	*dev = 0;
  80142c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80142f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	56                   	push   %esi
  801443:	53                   	push   %ebx
  801444:	83 ec 10             	sub    $0x10,%esp
  801447:	8b 75 08             	mov    0x8(%ebp),%esi
  80144a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80144d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801457:	c1 e8 0c             	shr    $0xc,%eax
  80145a:	50                   	push   %eax
  80145b:	e8 36 ff ff ff       	call   801396 <fd_lookup>
  801460:	83 c4 08             	add    $0x8,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	78 05                	js     80146c <fd_close+0x2d>
	    || fd != fd2)
  801467:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80146a:	74 0c                	je     801478 <fd_close+0x39>
		return (must_exist ? r : 0);
  80146c:	84 db                	test   %bl,%bl
  80146e:	ba 00 00 00 00       	mov    $0x0,%edx
  801473:	0f 44 c2             	cmove  %edx,%eax
  801476:	eb 41                	jmp    8014b9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147e:	50                   	push   %eax
  80147f:	ff 36                	pushl  (%esi)
  801481:	e8 66 ff ff ff       	call   8013ec <dev_lookup>
  801486:	89 c3                	mov    %eax,%ebx
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 1a                	js     8014a9 <fd_close+0x6a>
		if (dev->dev_close)
  80148f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801492:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801495:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80149a:	85 c0                	test   %eax,%eax
  80149c:	74 0b                	je     8014a9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80149e:	83 ec 0c             	sub    $0xc,%esp
  8014a1:	56                   	push   %esi
  8014a2:	ff d0                	call   *%eax
  8014a4:	89 c3                	mov    %eax,%ebx
  8014a6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	56                   	push   %esi
  8014ad:	6a 00                	push   $0x0
  8014af:	e8 71 fc ff ff       	call   801125 <sys_page_unmap>
	return r;
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	89 d8                	mov    %ebx,%eax
}
  8014b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bc:	5b                   	pop    %ebx
  8014bd:	5e                   	pop    %esi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	ff 75 08             	pushl  0x8(%ebp)
  8014cd:	e8 c4 fe ff ff       	call   801396 <fd_lookup>
  8014d2:	83 c4 08             	add    $0x8,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 10                	js     8014e9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	6a 01                	push   $0x1
  8014de:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e1:	e8 59 ff ff ff       	call   80143f <fd_close>
  8014e6:	83 c4 10             	add    $0x10,%esp
}
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <close_all>:

void
close_all(void)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	53                   	push   %ebx
  8014ef:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014f7:	83 ec 0c             	sub    $0xc,%esp
  8014fa:	53                   	push   %ebx
  8014fb:	e8 c0 ff ff ff       	call   8014c0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801500:	83 c3 01             	add    $0x1,%ebx
  801503:	83 c4 10             	add    $0x10,%esp
  801506:	83 fb 20             	cmp    $0x20,%ebx
  801509:	75 ec                	jne    8014f7 <close_all+0xc>
		close(i);
}
  80150b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	57                   	push   %edi
  801514:	56                   	push   %esi
  801515:	53                   	push   %ebx
  801516:	83 ec 2c             	sub    $0x2c,%esp
  801519:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80151c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80151f:	50                   	push   %eax
  801520:	ff 75 08             	pushl  0x8(%ebp)
  801523:	e8 6e fe ff ff       	call   801396 <fd_lookup>
  801528:	83 c4 08             	add    $0x8,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	0f 88 c1 00 00 00    	js     8015f4 <dup+0xe4>
		return r;
	close(newfdnum);
  801533:	83 ec 0c             	sub    $0xc,%esp
  801536:	56                   	push   %esi
  801537:	e8 84 ff ff ff       	call   8014c0 <close>

	newfd = INDEX2FD(newfdnum);
  80153c:	89 f3                	mov    %esi,%ebx
  80153e:	c1 e3 0c             	shl    $0xc,%ebx
  801541:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801547:	83 c4 04             	add    $0x4,%esp
  80154a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80154d:	e8 de fd ff ff       	call   801330 <fd2data>
  801552:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801554:	89 1c 24             	mov    %ebx,(%esp)
  801557:	e8 d4 fd ff ff       	call   801330 <fd2data>
  80155c:	83 c4 10             	add    $0x10,%esp
  80155f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801562:	89 f8                	mov    %edi,%eax
  801564:	c1 e8 16             	shr    $0x16,%eax
  801567:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80156e:	a8 01                	test   $0x1,%al
  801570:	74 37                	je     8015a9 <dup+0x99>
  801572:	89 f8                	mov    %edi,%eax
  801574:	c1 e8 0c             	shr    $0xc,%eax
  801577:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80157e:	f6 c2 01             	test   $0x1,%dl
  801581:	74 26                	je     8015a9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801583:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	25 07 0e 00 00       	and    $0xe07,%eax
  801592:	50                   	push   %eax
  801593:	ff 75 d4             	pushl  -0x2c(%ebp)
  801596:	6a 00                	push   $0x0
  801598:	57                   	push   %edi
  801599:	6a 00                	push   $0x0
  80159b:	e8 43 fb ff ff       	call   8010e3 <sys_page_map>
  8015a0:	89 c7                	mov    %eax,%edi
  8015a2:	83 c4 20             	add    $0x20,%esp
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 2e                	js     8015d7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015ac:	89 d0                	mov    %edx,%eax
  8015ae:	c1 e8 0c             	shr    $0xc,%eax
  8015b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015b8:	83 ec 0c             	sub    $0xc,%esp
  8015bb:	25 07 0e 00 00       	and    $0xe07,%eax
  8015c0:	50                   	push   %eax
  8015c1:	53                   	push   %ebx
  8015c2:	6a 00                	push   $0x0
  8015c4:	52                   	push   %edx
  8015c5:	6a 00                	push   $0x0
  8015c7:	e8 17 fb ff ff       	call   8010e3 <sys_page_map>
  8015cc:	89 c7                	mov    %eax,%edi
  8015ce:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015d1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015d3:	85 ff                	test   %edi,%edi
  8015d5:	79 1d                	jns    8015f4 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	53                   	push   %ebx
  8015db:	6a 00                	push   $0x0
  8015dd:	e8 43 fb ff ff       	call   801125 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015e2:	83 c4 08             	add    $0x8,%esp
  8015e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015e8:	6a 00                	push   $0x0
  8015ea:	e8 36 fb ff ff       	call   801125 <sys_page_unmap>
	return r;
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	89 f8                	mov    %edi,%eax
}
  8015f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f7:	5b                   	pop    %ebx
  8015f8:	5e                   	pop    %esi
  8015f9:	5f                   	pop    %edi
  8015fa:	5d                   	pop    %ebp
  8015fb:	c3                   	ret    

008015fc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	53                   	push   %ebx
  801600:	83 ec 14             	sub    $0x14,%esp
  801603:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801606:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	53                   	push   %ebx
  80160b:	e8 86 fd ff ff       	call   801396 <fd_lookup>
  801610:	83 c4 08             	add    $0x8,%esp
  801613:	89 c2                	mov    %eax,%edx
  801615:	85 c0                	test   %eax,%eax
  801617:	78 6d                	js     801686 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801623:	ff 30                	pushl  (%eax)
  801625:	e8 c2 fd ff ff       	call   8013ec <dev_lookup>
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	85 c0                	test   %eax,%eax
  80162f:	78 4c                	js     80167d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801631:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801634:	8b 42 08             	mov    0x8(%edx),%eax
  801637:	83 e0 03             	and    $0x3,%eax
  80163a:	83 f8 01             	cmp    $0x1,%eax
  80163d:	75 21                	jne    801660 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80163f:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801644:	8b 40 48             	mov    0x48(%eax),%eax
  801647:	83 ec 04             	sub    $0x4,%esp
  80164a:	53                   	push   %ebx
  80164b:	50                   	push   %eax
  80164c:	68 c0 28 80 00       	push   $0x8028c0
  801651:	e8 c2 f0 ff ff       	call   800718 <cprintf>
		return -E_INVAL;
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165e:	eb 26                	jmp    801686 <read+0x8a>
	}
	if (!dev->dev_read)
  801660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801663:	8b 40 08             	mov    0x8(%eax),%eax
  801666:	85 c0                	test   %eax,%eax
  801668:	74 17                	je     801681 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  80166a:	83 ec 04             	sub    $0x4,%esp
  80166d:	ff 75 10             	pushl  0x10(%ebp)
  801670:	ff 75 0c             	pushl  0xc(%ebp)
  801673:	52                   	push   %edx
  801674:	ff d0                	call   *%eax
  801676:	89 c2                	mov    %eax,%edx
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	eb 09                	jmp    801686 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167d:	89 c2                	mov    %eax,%edx
  80167f:	eb 05                	jmp    801686 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801681:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801686:	89 d0                	mov    %edx,%eax
  801688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	57                   	push   %edi
  801691:	56                   	push   %esi
  801692:	53                   	push   %ebx
  801693:	83 ec 0c             	sub    $0xc,%esp
  801696:	8b 7d 08             	mov    0x8(%ebp),%edi
  801699:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80169c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a1:	eb 21                	jmp    8016c4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	89 f0                	mov    %esi,%eax
  8016a8:	29 d8                	sub    %ebx,%eax
  8016aa:	50                   	push   %eax
  8016ab:	89 d8                	mov    %ebx,%eax
  8016ad:	03 45 0c             	add    0xc(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	57                   	push   %edi
  8016b2:	e8 45 ff ff ff       	call   8015fc <read>
		if (m < 0)
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 10                	js     8016ce <readn+0x41>
			return m;
		if (m == 0)
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	74 0a                	je     8016cc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016c2:	01 c3                	add    %eax,%ebx
  8016c4:	39 f3                	cmp    %esi,%ebx
  8016c6:	72 db                	jb     8016a3 <readn+0x16>
  8016c8:	89 d8                	mov    %ebx,%eax
  8016ca:	eb 02                	jmp    8016ce <readn+0x41>
  8016cc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d1:	5b                   	pop    %ebx
  8016d2:	5e                   	pop    %esi
  8016d3:	5f                   	pop    %edi
  8016d4:	5d                   	pop    %ebp
  8016d5:	c3                   	ret    

008016d6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 14             	sub    $0x14,%esp
  8016dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e3:	50                   	push   %eax
  8016e4:	53                   	push   %ebx
  8016e5:	e8 ac fc ff ff       	call   801396 <fd_lookup>
  8016ea:	83 c4 08             	add    $0x8,%esp
  8016ed:	89 c2                	mov    %eax,%edx
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 68                	js     80175b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f9:	50                   	push   %eax
  8016fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fd:	ff 30                	pushl  (%eax)
  8016ff:	e8 e8 fc ff ff       	call   8013ec <dev_lookup>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 47                	js     801752 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801712:	75 21                	jne    801735 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801714:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801719:	8b 40 48             	mov    0x48(%eax),%eax
  80171c:	83 ec 04             	sub    $0x4,%esp
  80171f:	53                   	push   %ebx
  801720:	50                   	push   %eax
  801721:	68 dc 28 80 00       	push   $0x8028dc
  801726:	e8 ed ef ff ff       	call   800718 <cprintf>
		return -E_INVAL;
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801733:	eb 26                	jmp    80175b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801735:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801738:	8b 52 0c             	mov    0xc(%edx),%edx
  80173b:	85 d2                	test   %edx,%edx
  80173d:	74 17                	je     801756 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80173f:	83 ec 04             	sub    $0x4,%esp
  801742:	ff 75 10             	pushl  0x10(%ebp)
  801745:	ff 75 0c             	pushl  0xc(%ebp)
  801748:	50                   	push   %eax
  801749:	ff d2                	call   *%edx
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	eb 09                	jmp    80175b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801752:	89 c2                	mov    %eax,%edx
  801754:	eb 05                	jmp    80175b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801756:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80175b:	89 d0                	mov    %edx,%eax
  80175d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <seek>:

int
seek(int fdnum, off_t offset)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801768:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	ff 75 08             	pushl  0x8(%ebp)
  80176f:	e8 22 fc ff ff       	call   801396 <fd_lookup>
  801774:	83 c4 08             	add    $0x8,%esp
  801777:	85 c0                	test   %eax,%eax
  801779:	78 0e                	js     801789 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80177b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80177e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801781:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801789:	c9                   	leave  
  80178a:	c3                   	ret    

0080178b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	53                   	push   %ebx
  80178f:	83 ec 14             	sub    $0x14,%esp
  801792:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801795:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801798:	50                   	push   %eax
  801799:	53                   	push   %ebx
  80179a:	e8 f7 fb ff ff       	call   801396 <fd_lookup>
  80179f:	83 c4 08             	add    $0x8,%esp
  8017a2:	89 c2                	mov    %eax,%edx
  8017a4:	85 c0                	test   %eax,%eax
  8017a6:	78 65                	js     80180d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a8:	83 ec 08             	sub    $0x8,%esp
  8017ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ae:	50                   	push   %eax
  8017af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b2:	ff 30                	pushl  (%eax)
  8017b4:	e8 33 fc ff ff       	call   8013ec <dev_lookup>
  8017b9:	83 c4 10             	add    $0x10,%esp
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 44                	js     801804 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017c7:	75 21                	jne    8017ea <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017c9:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017ce:	8b 40 48             	mov    0x48(%eax),%eax
  8017d1:	83 ec 04             	sub    $0x4,%esp
  8017d4:	53                   	push   %ebx
  8017d5:	50                   	push   %eax
  8017d6:	68 9c 28 80 00       	push   $0x80289c
  8017db:	e8 38 ef ff ff       	call   800718 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017e8:	eb 23                	jmp    80180d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ed:	8b 52 18             	mov    0x18(%edx),%edx
  8017f0:	85 d2                	test   %edx,%edx
  8017f2:	74 14                	je     801808 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017f4:	83 ec 08             	sub    $0x8,%esp
  8017f7:	ff 75 0c             	pushl  0xc(%ebp)
  8017fa:	50                   	push   %eax
  8017fb:	ff d2                	call   *%edx
  8017fd:	89 c2                	mov    %eax,%edx
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	eb 09                	jmp    80180d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801804:	89 c2                	mov    %eax,%edx
  801806:	eb 05                	jmp    80180d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801808:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80180d:	89 d0                	mov    %edx,%eax
  80180f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801812:	c9                   	leave  
  801813:	c3                   	ret    

00801814 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	53                   	push   %ebx
  801818:	83 ec 14             	sub    $0x14,%esp
  80181b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801821:	50                   	push   %eax
  801822:	ff 75 08             	pushl  0x8(%ebp)
  801825:	e8 6c fb ff ff       	call   801396 <fd_lookup>
  80182a:	83 c4 08             	add    $0x8,%esp
  80182d:	89 c2                	mov    %eax,%edx
  80182f:	85 c0                	test   %eax,%eax
  801831:	78 58                	js     80188b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801839:	50                   	push   %eax
  80183a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183d:	ff 30                	pushl  (%eax)
  80183f:	e8 a8 fb ff ff       	call   8013ec <dev_lookup>
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	85 c0                	test   %eax,%eax
  801849:	78 37                	js     801882 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80184b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801852:	74 32                	je     801886 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801854:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801857:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80185e:	00 00 00 
	stat->st_isdir = 0;
  801861:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801868:	00 00 00 
	stat->st_dev = dev;
  80186b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	53                   	push   %ebx
  801875:	ff 75 f0             	pushl  -0x10(%ebp)
  801878:	ff 50 14             	call   *0x14(%eax)
  80187b:	89 c2                	mov    %eax,%edx
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	eb 09                	jmp    80188b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801882:	89 c2                	mov    %eax,%edx
  801884:	eb 05                	jmp    80188b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801886:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80188b:	89 d0                	mov    %edx,%eax
  80188d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	56                   	push   %esi
  801896:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	6a 00                	push   $0x0
  80189c:	ff 75 08             	pushl  0x8(%ebp)
  80189f:	e8 e3 01 00 00       	call   801a87 <open>
  8018a4:	89 c3                	mov    %eax,%ebx
  8018a6:	83 c4 10             	add    $0x10,%esp
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	78 1b                	js     8018c8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018ad:	83 ec 08             	sub    $0x8,%esp
  8018b0:	ff 75 0c             	pushl  0xc(%ebp)
  8018b3:	50                   	push   %eax
  8018b4:	e8 5b ff ff ff       	call   801814 <fstat>
  8018b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8018bb:	89 1c 24             	mov    %ebx,(%esp)
  8018be:	e8 fd fb ff ff       	call   8014c0 <close>
	return r;
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	89 f0                	mov    %esi,%eax
}
  8018c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5e                   	pop    %esi
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	56                   	push   %esi
  8018d3:	53                   	push   %ebx
  8018d4:	89 c6                	mov    %eax,%esi
  8018d6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018d8:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8018df:	75 12                	jne    8018f3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	6a 01                	push   $0x1
  8018e6:	e8 f3 07 00 00       	call   8020de <ipc_find_env>
  8018eb:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018f0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018f3:	6a 07                	push   $0x7
  8018f5:	68 00 50 80 00       	push   $0x805000
  8018fa:	56                   	push   %esi
  8018fb:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801901:	e8 76 07 00 00       	call   80207c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801906:	83 c4 0c             	add    $0xc,%esp
  801909:	6a 00                	push   $0x0
  80190b:	53                   	push   %ebx
  80190c:	6a 00                	push   $0x0
  80190e:	e8 f7 06 00 00       	call   80200a <ipc_recv>
}
  801913:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801916:	5b                   	pop    %ebx
  801917:	5e                   	pop    %esi
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	8b 40 0c             	mov    0xc(%eax),%eax
  801926:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80192b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801933:	ba 00 00 00 00       	mov    $0x0,%edx
  801938:	b8 02 00 00 00       	mov    $0x2,%eax
  80193d:	e8 8d ff ff ff       	call   8018cf <fsipc>
}
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80194a:	8b 45 08             	mov    0x8(%ebp),%eax
  80194d:	8b 40 0c             	mov    0xc(%eax),%eax
  801950:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801955:	ba 00 00 00 00       	mov    $0x0,%edx
  80195a:	b8 06 00 00 00       	mov    $0x6,%eax
  80195f:	e8 6b ff ff ff       	call   8018cf <fsipc>
}
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	53                   	push   %ebx
  80196a:	83 ec 04             	sub    $0x4,%esp
  80196d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801970:	8b 45 08             	mov    0x8(%ebp),%eax
  801973:	8b 40 0c             	mov    0xc(%eax),%eax
  801976:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80197b:	ba 00 00 00 00       	mov    $0x0,%edx
  801980:	b8 05 00 00 00       	mov    $0x5,%eax
  801985:	e8 45 ff ff ff       	call   8018cf <fsipc>
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 2c                	js     8019ba <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80198e:	83 ec 08             	sub    $0x8,%esp
  801991:	68 00 50 80 00       	push   $0x805000
  801996:	53                   	push   %ebx
  801997:	e8 01 f3 ff ff       	call   800c9d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80199c:	a1 80 50 80 00       	mov    0x805080,%eax
  8019a1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019a7:	a1 84 50 80 00       	mov    0x805084,%eax
  8019ac:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019bd:	c9                   	leave  
  8019be:	c3                   	ret    

008019bf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8019cb:	8b 52 0c             	mov    0xc(%edx),%edx
  8019ce:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8019d4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019d9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019de:	0f 47 c2             	cmova  %edx,%eax
  8019e1:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019e6:	50                   	push   %eax
  8019e7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ea:	68 08 50 80 00       	push   $0x805008
  8019ef:	e8 3b f4 ff ff       	call   800e2f <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  8019f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f9:	b8 04 00 00 00       	mov    $0x4,%eax
  8019fe:	e8 cc fe ff ff       	call   8018cf <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    

00801a05 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	56                   	push   %esi
  801a09:	53                   	push   %ebx
  801a0a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a10:	8b 40 0c             	mov    0xc(%eax),%eax
  801a13:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a18:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a23:	b8 03 00 00 00       	mov    $0x3,%eax
  801a28:	e8 a2 fe ff ff       	call   8018cf <fsipc>
  801a2d:	89 c3                	mov    %eax,%ebx
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	78 4b                	js     801a7e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a33:	39 c6                	cmp    %eax,%esi
  801a35:	73 16                	jae    801a4d <devfile_read+0x48>
  801a37:	68 0c 29 80 00       	push   $0x80290c
  801a3c:	68 13 29 80 00       	push   $0x802913
  801a41:	6a 7c                	push   $0x7c
  801a43:	68 28 29 80 00       	push   $0x802928
  801a48:	e8 f2 eb ff ff       	call   80063f <_panic>
	assert(r <= PGSIZE);
  801a4d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a52:	7e 16                	jle    801a6a <devfile_read+0x65>
  801a54:	68 33 29 80 00       	push   $0x802933
  801a59:	68 13 29 80 00       	push   $0x802913
  801a5e:	6a 7d                	push   $0x7d
  801a60:	68 28 29 80 00       	push   $0x802928
  801a65:	e8 d5 eb ff ff       	call   80063f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a6a:	83 ec 04             	sub    $0x4,%esp
  801a6d:	50                   	push   %eax
  801a6e:	68 00 50 80 00       	push   $0x805000
  801a73:	ff 75 0c             	pushl  0xc(%ebp)
  801a76:	e8 b4 f3 ff ff       	call   800e2f <memmove>
	return r;
  801a7b:	83 c4 10             	add    $0x10,%esp
}
  801a7e:	89 d8                	mov    %ebx,%eax
  801a80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a83:	5b                   	pop    %ebx
  801a84:	5e                   	pop    %esi
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	53                   	push   %ebx
  801a8b:	83 ec 20             	sub    $0x20,%esp
  801a8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a91:	53                   	push   %ebx
  801a92:	e8 cd f1 ff ff       	call   800c64 <strlen>
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a9f:	7f 67                	jg     801b08 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa7:	50                   	push   %eax
  801aa8:	e8 9a f8 ff ff       	call   801347 <fd_alloc>
  801aad:	83 c4 10             	add    $0x10,%esp
		return r;
  801ab0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 57                	js     801b0d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ab6:	83 ec 08             	sub    $0x8,%esp
  801ab9:	53                   	push   %ebx
  801aba:	68 00 50 80 00       	push   $0x805000
  801abf:	e8 d9 f1 ff ff       	call   800c9d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801acc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801acf:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad4:	e8 f6 fd ff ff       	call   8018cf <fsipc>
  801ad9:	89 c3                	mov    %eax,%ebx
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	79 14                	jns    801af6 <open+0x6f>
		fd_close(fd, 0);
  801ae2:	83 ec 08             	sub    $0x8,%esp
  801ae5:	6a 00                	push   $0x0
  801ae7:	ff 75 f4             	pushl  -0xc(%ebp)
  801aea:	e8 50 f9 ff ff       	call   80143f <fd_close>
		return r;
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	89 da                	mov    %ebx,%edx
  801af4:	eb 17                	jmp    801b0d <open+0x86>
	}

	return fd2num(fd);
  801af6:	83 ec 0c             	sub    $0xc,%esp
  801af9:	ff 75 f4             	pushl  -0xc(%ebp)
  801afc:	e8 1f f8 ff ff       	call   801320 <fd2num>
  801b01:	89 c2                	mov    %eax,%edx
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	eb 05                	jmp    801b0d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b08:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b0d:	89 d0                	mov    %edx,%eax
  801b0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b12:	c9                   	leave  
  801b13:	c3                   	ret    

00801b14 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1f:	b8 08 00 00 00       	mov    $0x8,%eax
  801b24:	e8 a6 fd ff ff       	call   8018cf <fsipc>
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b33:	83 ec 0c             	sub    $0xc,%esp
  801b36:	ff 75 08             	pushl  0x8(%ebp)
  801b39:	e8 f2 f7 ff ff       	call   801330 <fd2data>
  801b3e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b40:	83 c4 08             	add    $0x8,%esp
  801b43:	68 3f 29 80 00       	push   $0x80293f
  801b48:	53                   	push   %ebx
  801b49:	e8 4f f1 ff ff       	call   800c9d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b4e:	8b 46 04             	mov    0x4(%esi),%eax
  801b51:	2b 06                	sub    (%esi),%eax
  801b53:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b59:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b60:	00 00 00 
	stat->st_dev = &devpipe;
  801b63:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b6a:	30 80 00 
	return 0;
}
  801b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	53                   	push   %ebx
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b83:	53                   	push   %ebx
  801b84:	6a 00                	push   $0x0
  801b86:	e8 9a f5 ff ff       	call   801125 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b8b:	89 1c 24             	mov    %ebx,(%esp)
  801b8e:	e8 9d f7 ff ff       	call   801330 <fd2data>
  801b93:	83 c4 08             	add    $0x8,%esp
  801b96:	50                   	push   %eax
  801b97:	6a 00                	push   $0x0
  801b99:	e8 87 f5 ff ff       	call   801125 <sys_page_unmap>
}
  801b9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba1:	c9                   	leave  
  801ba2:	c3                   	ret    

00801ba3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	57                   	push   %edi
  801ba7:	56                   	push   %esi
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 1c             	sub    $0x1c,%esp
  801bac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801baf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bb1:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801bb6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bb9:	83 ec 0c             	sub    $0xc,%esp
  801bbc:	ff 75 e0             	pushl  -0x20(%ebp)
  801bbf:	e8 53 05 00 00       	call   802117 <pageref>
  801bc4:	89 c3                	mov    %eax,%ebx
  801bc6:	89 3c 24             	mov    %edi,(%esp)
  801bc9:	e8 49 05 00 00       	call   802117 <pageref>
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	39 c3                	cmp    %eax,%ebx
  801bd3:	0f 94 c1             	sete   %cl
  801bd6:	0f b6 c9             	movzbl %cl,%ecx
  801bd9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bdc:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801be2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801be5:	39 ce                	cmp    %ecx,%esi
  801be7:	74 1b                	je     801c04 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801be9:	39 c3                	cmp    %eax,%ebx
  801beb:	75 c4                	jne    801bb1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bed:	8b 42 58             	mov    0x58(%edx),%eax
  801bf0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bf3:	50                   	push   %eax
  801bf4:	56                   	push   %esi
  801bf5:	68 46 29 80 00       	push   $0x802946
  801bfa:	e8 19 eb ff ff       	call   800718 <cprintf>
  801bff:	83 c4 10             	add    $0x10,%esp
  801c02:	eb ad                	jmp    801bb1 <_pipeisclosed+0xe>
	}
}
  801c04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0a:	5b                   	pop    %ebx
  801c0b:	5e                   	pop    %esi
  801c0c:	5f                   	pop    %edi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	57                   	push   %edi
  801c13:	56                   	push   %esi
  801c14:	53                   	push   %ebx
  801c15:	83 ec 28             	sub    $0x28,%esp
  801c18:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c1b:	56                   	push   %esi
  801c1c:	e8 0f f7 ff ff       	call   801330 <fd2data>
  801c21:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	bf 00 00 00 00       	mov    $0x0,%edi
  801c2b:	eb 4b                	jmp    801c78 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c2d:	89 da                	mov    %ebx,%edx
  801c2f:	89 f0                	mov    %esi,%eax
  801c31:	e8 6d ff ff ff       	call   801ba3 <_pipeisclosed>
  801c36:	85 c0                	test   %eax,%eax
  801c38:	75 48                	jne    801c82 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c3a:	e8 42 f4 ff ff       	call   801081 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c3f:	8b 43 04             	mov    0x4(%ebx),%eax
  801c42:	8b 0b                	mov    (%ebx),%ecx
  801c44:	8d 51 20             	lea    0x20(%ecx),%edx
  801c47:	39 d0                	cmp    %edx,%eax
  801c49:	73 e2                	jae    801c2d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c4e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c52:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c55:	89 c2                	mov    %eax,%edx
  801c57:	c1 fa 1f             	sar    $0x1f,%edx
  801c5a:	89 d1                	mov    %edx,%ecx
  801c5c:	c1 e9 1b             	shr    $0x1b,%ecx
  801c5f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c62:	83 e2 1f             	and    $0x1f,%edx
  801c65:	29 ca                	sub    %ecx,%edx
  801c67:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c6b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c6f:	83 c0 01             	add    $0x1,%eax
  801c72:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c75:	83 c7 01             	add    $0x1,%edi
  801c78:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c7b:	75 c2                	jne    801c3f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c80:	eb 05                	jmp    801c87 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c82:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8a:	5b                   	pop    %ebx
  801c8b:	5e                   	pop    %esi
  801c8c:	5f                   	pop    %edi
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	57                   	push   %edi
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	83 ec 18             	sub    $0x18,%esp
  801c98:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c9b:	57                   	push   %edi
  801c9c:	e8 8f f6 ff ff       	call   801330 <fd2data>
  801ca1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca3:	83 c4 10             	add    $0x10,%esp
  801ca6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cab:	eb 3d                	jmp    801cea <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cad:	85 db                	test   %ebx,%ebx
  801caf:	74 04                	je     801cb5 <devpipe_read+0x26>
				return i;
  801cb1:	89 d8                	mov    %ebx,%eax
  801cb3:	eb 44                	jmp    801cf9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cb5:	89 f2                	mov    %esi,%edx
  801cb7:	89 f8                	mov    %edi,%eax
  801cb9:	e8 e5 fe ff ff       	call   801ba3 <_pipeisclosed>
  801cbe:	85 c0                	test   %eax,%eax
  801cc0:	75 32                	jne    801cf4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cc2:	e8 ba f3 ff ff       	call   801081 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cc7:	8b 06                	mov    (%esi),%eax
  801cc9:	3b 46 04             	cmp    0x4(%esi),%eax
  801ccc:	74 df                	je     801cad <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cce:	99                   	cltd   
  801ccf:	c1 ea 1b             	shr    $0x1b,%edx
  801cd2:	01 d0                	add    %edx,%eax
  801cd4:	83 e0 1f             	and    $0x1f,%eax
  801cd7:	29 d0                	sub    %edx,%eax
  801cd9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ce4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce7:	83 c3 01             	add    $0x1,%ebx
  801cea:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ced:	75 d8                	jne    801cc7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cef:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf2:	eb 05                	jmp    801cf9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cfc:	5b                   	pop    %ebx
  801cfd:	5e                   	pop    %esi
  801cfe:	5f                   	pop    %edi
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	56                   	push   %esi
  801d05:	53                   	push   %ebx
  801d06:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0c:	50                   	push   %eax
  801d0d:	e8 35 f6 ff ff       	call   801347 <fd_alloc>
  801d12:	83 c4 10             	add    $0x10,%esp
  801d15:	89 c2                	mov    %eax,%edx
  801d17:	85 c0                	test   %eax,%eax
  801d19:	0f 88 2c 01 00 00    	js     801e4b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	68 07 04 00 00       	push   $0x407
  801d27:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 6f f3 ff ff       	call   8010a0 <sys_page_alloc>
  801d31:	83 c4 10             	add    $0x10,%esp
  801d34:	89 c2                	mov    %eax,%edx
  801d36:	85 c0                	test   %eax,%eax
  801d38:	0f 88 0d 01 00 00    	js     801e4b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d44:	50                   	push   %eax
  801d45:	e8 fd f5 ff ff       	call   801347 <fd_alloc>
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	0f 88 e2 00 00 00    	js     801e39 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d57:	83 ec 04             	sub    $0x4,%esp
  801d5a:	68 07 04 00 00       	push   $0x407
  801d5f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d62:	6a 00                	push   $0x0
  801d64:	e8 37 f3 ff ff       	call   8010a0 <sys_page_alloc>
  801d69:	89 c3                	mov    %eax,%ebx
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	85 c0                	test   %eax,%eax
  801d70:	0f 88 c3 00 00 00    	js     801e39 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7c:	e8 af f5 ff ff       	call   801330 <fd2data>
  801d81:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d83:	83 c4 0c             	add    $0xc,%esp
  801d86:	68 07 04 00 00       	push   $0x407
  801d8b:	50                   	push   %eax
  801d8c:	6a 00                	push   $0x0
  801d8e:	e8 0d f3 ff ff       	call   8010a0 <sys_page_alloc>
  801d93:	89 c3                	mov    %eax,%ebx
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	0f 88 89 00 00 00    	js     801e29 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da0:	83 ec 0c             	sub    $0xc,%esp
  801da3:	ff 75 f0             	pushl  -0x10(%ebp)
  801da6:	e8 85 f5 ff ff       	call   801330 <fd2data>
  801dab:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801db2:	50                   	push   %eax
  801db3:	6a 00                	push   $0x0
  801db5:	56                   	push   %esi
  801db6:	6a 00                	push   $0x0
  801db8:	e8 26 f3 ff ff       	call   8010e3 <sys_page_map>
  801dbd:	89 c3                	mov    %eax,%ebx
  801dbf:	83 c4 20             	add    $0x20,%esp
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	78 55                	js     801e1b <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dc6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ddb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801de6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df0:	83 ec 0c             	sub    $0xc,%esp
  801df3:	ff 75 f4             	pushl  -0xc(%ebp)
  801df6:	e8 25 f5 ff ff       	call   801320 <fd2num>
  801dfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dfe:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e00:	83 c4 04             	add    $0x4,%esp
  801e03:	ff 75 f0             	pushl  -0x10(%ebp)
  801e06:	e8 15 f5 ff ff       	call   801320 <fd2num>
  801e0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e0e:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	ba 00 00 00 00       	mov    $0x0,%edx
  801e19:	eb 30                	jmp    801e4b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e1b:	83 ec 08             	sub    $0x8,%esp
  801e1e:	56                   	push   %esi
  801e1f:	6a 00                	push   $0x0
  801e21:	e8 ff f2 ff ff       	call   801125 <sys_page_unmap>
  801e26:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e29:	83 ec 08             	sub    $0x8,%esp
  801e2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801e2f:	6a 00                	push   $0x0
  801e31:	e8 ef f2 ff ff       	call   801125 <sys_page_unmap>
  801e36:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e39:	83 ec 08             	sub    $0x8,%esp
  801e3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e3f:	6a 00                	push   $0x0
  801e41:	e8 df f2 ff ff       	call   801125 <sys_page_unmap>
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5d:	50                   	push   %eax
  801e5e:	ff 75 08             	pushl  0x8(%ebp)
  801e61:	e8 30 f5 ff ff       	call   801396 <fd_lookup>
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	85 c0                	test   %eax,%eax
  801e6b:	78 18                	js     801e85 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e6d:	83 ec 0c             	sub    $0xc,%esp
  801e70:	ff 75 f4             	pushl  -0xc(%ebp)
  801e73:	e8 b8 f4 ff ff       	call   801330 <fd2data>
	return _pipeisclosed(fd, p);
  801e78:	89 c2                	mov    %eax,%edx
  801e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7d:	e8 21 fd ff ff       	call   801ba3 <_pipeisclosed>
  801e82:	83 c4 10             	add    $0x10,%esp
}
  801e85:	c9                   	leave  
  801e86:	c3                   	ret    

00801e87 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e97:	68 5e 29 80 00       	push   $0x80295e
  801e9c:	ff 75 0c             	pushl  0xc(%ebp)
  801e9f:	e8 f9 ed ff ff       	call   800c9d <strcpy>
	return 0;
}
  801ea4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	57                   	push   %edi
  801eaf:	56                   	push   %esi
  801eb0:	53                   	push   %ebx
  801eb1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eb7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ebc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec2:	eb 2d                	jmp    801ef1 <devcons_write+0x46>
		m = n - tot;
  801ec4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ec7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ec9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ecc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ed1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed4:	83 ec 04             	sub    $0x4,%esp
  801ed7:	53                   	push   %ebx
  801ed8:	03 45 0c             	add    0xc(%ebp),%eax
  801edb:	50                   	push   %eax
  801edc:	57                   	push   %edi
  801edd:	e8 4d ef ff ff       	call   800e2f <memmove>
		sys_cputs(buf, m);
  801ee2:	83 c4 08             	add    $0x8,%esp
  801ee5:	53                   	push   %ebx
  801ee6:	57                   	push   %edi
  801ee7:	e8 f8 f0 ff ff       	call   800fe4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eec:	01 de                	add    %ebx,%esi
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	89 f0                	mov    %esi,%eax
  801ef3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ef6:	72 cc                	jb     801ec4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efb:	5b                   	pop    %ebx
  801efc:	5e                   	pop    %esi
  801efd:	5f                   	pop    %edi
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	83 ec 08             	sub    $0x8,%esp
  801f06:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f0f:	74 2a                	je     801f3b <devcons_read+0x3b>
  801f11:	eb 05                	jmp    801f18 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f13:	e8 69 f1 ff ff       	call   801081 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f18:	e8 e5 f0 ff ff       	call   801002 <sys_cgetc>
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	74 f2                	je     801f13 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f21:	85 c0                	test   %eax,%eax
  801f23:	78 16                	js     801f3b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f25:	83 f8 04             	cmp    $0x4,%eax
  801f28:	74 0c                	je     801f36 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f2d:	88 02                	mov    %al,(%edx)
	return 1;
  801f2f:	b8 01 00 00 00       	mov    $0x1,%eax
  801f34:	eb 05                	jmp    801f3b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f36:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f3b:	c9                   	leave  
  801f3c:	c3                   	ret    

00801f3d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f43:	8b 45 08             	mov    0x8(%ebp),%eax
  801f46:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f49:	6a 01                	push   $0x1
  801f4b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f4e:	50                   	push   %eax
  801f4f:	e8 90 f0 ff ff       	call   800fe4 <sys_cputs>
}
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	c9                   	leave  
  801f58:	c3                   	ret    

00801f59 <getchar>:

int
getchar(void)
{
  801f59:	55                   	push   %ebp
  801f5a:	89 e5                	mov    %esp,%ebp
  801f5c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f5f:	6a 01                	push   $0x1
  801f61:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f64:	50                   	push   %eax
  801f65:	6a 00                	push   $0x0
  801f67:	e8 90 f6 ff ff       	call   8015fc <read>
	if (r < 0)
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	78 0f                	js     801f82 <getchar+0x29>
		return r;
	if (r < 1)
  801f73:	85 c0                	test   %eax,%eax
  801f75:	7e 06                	jle    801f7d <getchar+0x24>
		return -E_EOF;
	return c;
  801f77:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f7b:	eb 05                	jmp    801f82 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f7d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f82:	c9                   	leave  
  801f83:	c3                   	ret    

00801f84 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8d:	50                   	push   %eax
  801f8e:	ff 75 08             	pushl  0x8(%ebp)
  801f91:	e8 00 f4 ff ff       	call   801396 <fd_lookup>
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	85 c0                	test   %eax,%eax
  801f9b:	78 11                	js     801fae <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa6:	39 10                	cmp    %edx,(%eax)
  801fa8:	0f 94 c0             	sete   %al
  801fab:	0f b6 c0             	movzbl %al,%eax
}
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <opencons>:

int
opencons(void)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb9:	50                   	push   %eax
  801fba:	e8 88 f3 ff ff       	call   801347 <fd_alloc>
  801fbf:	83 c4 10             	add    $0x10,%esp
		return r;
  801fc2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	78 3e                	js     802006 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fc8:	83 ec 04             	sub    $0x4,%esp
  801fcb:	68 07 04 00 00       	push   $0x407
  801fd0:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd3:	6a 00                	push   $0x0
  801fd5:	e8 c6 f0 ff ff       	call   8010a0 <sys_page_alloc>
  801fda:	83 c4 10             	add    $0x10,%esp
		return r;
  801fdd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	78 23                	js     802006 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fe3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ff8:	83 ec 0c             	sub    $0xc,%esp
  801ffb:	50                   	push   %eax
  801ffc:	e8 1f f3 ff ff       	call   801320 <fd2num>
  802001:	89 c2                	mov    %eax,%edx
  802003:	83 c4 10             	add    $0x10,%esp
}
  802006:	89 d0                	mov    %edx,%eax
  802008:	c9                   	leave  
  802009:	c3                   	ret    

0080200a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	56                   	push   %esi
  80200e:	53                   	push   %ebx
  80200f:	8b 75 08             	mov    0x8(%ebp),%esi
  802012:	8b 45 0c             	mov    0xc(%ebp),%eax
  802015:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802018:	85 c0                	test   %eax,%eax
  80201a:	75 12                	jne    80202e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80201c:	83 ec 0c             	sub    $0xc,%esp
  80201f:	68 00 00 c0 ee       	push   $0xeec00000
  802024:	e8 27 f2 ff ff       	call   801250 <sys_ipc_recv>
  802029:	83 c4 10             	add    $0x10,%esp
  80202c:	eb 0c                	jmp    80203a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80202e:	83 ec 0c             	sub    $0xc,%esp
  802031:	50                   	push   %eax
  802032:	e8 19 f2 ff ff       	call   801250 <sys_ipc_recv>
  802037:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80203a:	85 f6                	test   %esi,%esi
  80203c:	0f 95 c1             	setne  %cl
  80203f:	85 db                	test   %ebx,%ebx
  802041:	0f 95 c2             	setne  %dl
  802044:	84 d1                	test   %dl,%cl
  802046:	74 09                	je     802051 <ipc_recv+0x47>
  802048:	89 c2                	mov    %eax,%edx
  80204a:	c1 ea 1f             	shr    $0x1f,%edx
  80204d:	84 d2                	test   %dl,%dl
  80204f:	75 24                	jne    802075 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802051:	85 f6                	test   %esi,%esi
  802053:	74 0a                	je     80205f <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  802055:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80205a:	8b 40 74             	mov    0x74(%eax),%eax
  80205d:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80205f:	85 db                	test   %ebx,%ebx
  802061:	74 0a                	je     80206d <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  802063:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802068:	8b 40 78             	mov    0x78(%eax),%eax
  80206b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80206d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802072:	8b 40 70             	mov    0x70(%eax),%eax
}
  802075:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802078:	5b                   	pop    %ebx
  802079:	5e                   	pop    %esi
  80207a:	5d                   	pop    %ebp
  80207b:	c3                   	ret    

0080207c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	57                   	push   %edi
  802080:	56                   	push   %esi
  802081:	53                   	push   %ebx
  802082:	83 ec 0c             	sub    $0xc,%esp
  802085:	8b 7d 08             	mov    0x8(%ebp),%edi
  802088:	8b 75 0c             	mov    0xc(%ebp),%esi
  80208b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  80208e:	85 db                	test   %ebx,%ebx
  802090:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802095:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802098:	ff 75 14             	pushl  0x14(%ebp)
  80209b:	53                   	push   %ebx
  80209c:	56                   	push   %esi
  80209d:	57                   	push   %edi
  80209e:	e8 8a f1 ff ff       	call   80122d <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020a3:	89 c2                	mov    %eax,%edx
  8020a5:	c1 ea 1f             	shr    $0x1f,%edx
  8020a8:	83 c4 10             	add    $0x10,%esp
  8020ab:	84 d2                	test   %dl,%dl
  8020ad:	74 17                	je     8020c6 <ipc_send+0x4a>
  8020af:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020b2:	74 12                	je     8020c6 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020b4:	50                   	push   %eax
  8020b5:	68 6a 29 80 00       	push   $0x80296a
  8020ba:	6a 47                	push   $0x47
  8020bc:	68 78 29 80 00       	push   $0x802978
  8020c1:	e8 79 e5 ff ff       	call   80063f <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020c6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c9:	75 07                	jne    8020d2 <ipc_send+0x56>
			sys_yield();
  8020cb:	e8 b1 ef ff ff       	call   801081 <sys_yield>
  8020d0:	eb c6                	jmp    802098 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020d2:	85 c0                	test   %eax,%eax
  8020d4:	75 c2                	jne    802098 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d9:	5b                   	pop    %ebx
  8020da:	5e                   	pop    %esi
  8020db:	5f                   	pop    %edi
  8020dc:	5d                   	pop    %ebp
  8020dd:	c3                   	ret    

008020de <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020e4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020e9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020ec:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020f2:	8b 52 50             	mov    0x50(%edx),%edx
  8020f5:	39 ca                	cmp    %ecx,%edx
  8020f7:	75 0d                	jne    802106 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802101:	8b 40 48             	mov    0x48(%eax),%eax
  802104:	eb 0f                	jmp    802115 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802106:	83 c0 01             	add    $0x1,%eax
  802109:	3d 00 04 00 00       	cmp    $0x400,%eax
  80210e:	75 d9                	jne    8020e9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802110:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802115:	5d                   	pop    %ebp
  802116:	c3                   	ret    

00802117 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802117:	55                   	push   %ebp
  802118:	89 e5                	mov    %esp,%ebp
  80211a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211d:	89 d0                	mov    %edx,%eax
  80211f:	c1 e8 16             	shr    $0x16,%eax
  802122:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802129:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212e:	f6 c1 01             	test   $0x1,%cl
  802131:	74 1d                	je     802150 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802133:	c1 ea 0c             	shr    $0xc,%edx
  802136:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80213d:	f6 c2 01             	test   $0x1,%dl
  802140:	74 0e                	je     802150 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802142:	c1 ea 0c             	shr    $0xc,%edx
  802145:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80214c:	ef 
  80214d:	0f b7 c0             	movzwl %ax,%eax
}
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__udivdi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80216b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80216f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 f6                	test   %esi,%esi
  802179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80217d:	89 ca                	mov    %ecx,%edx
  80217f:	89 f8                	mov    %edi,%eax
  802181:	75 3d                	jne    8021c0 <__udivdi3+0x60>
  802183:	39 cf                	cmp    %ecx,%edi
  802185:	0f 87 c5 00 00 00    	ja     802250 <__udivdi3+0xf0>
  80218b:	85 ff                	test   %edi,%edi
  80218d:	89 fd                	mov    %edi,%ebp
  80218f:	75 0b                	jne    80219c <__udivdi3+0x3c>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	31 d2                	xor    %edx,%edx
  802198:	f7 f7                	div    %edi
  80219a:	89 c5                	mov    %eax,%ebp
  80219c:	89 c8                	mov    %ecx,%eax
  80219e:	31 d2                	xor    %edx,%edx
  8021a0:	f7 f5                	div    %ebp
  8021a2:	89 c1                	mov    %eax,%ecx
  8021a4:	89 d8                	mov    %ebx,%eax
  8021a6:	89 cf                	mov    %ecx,%edi
  8021a8:	f7 f5                	div    %ebp
  8021aa:	89 c3                	mov    %eax,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	39 ce                	cmp    %ecx,%esi
  8021c2:	77 74                	ja     802238 <__udivdi3+0xd8>
  8021c4:	0f bd fe             	bsr    %esi,%edi
  8021c7:	83 f7 1f             	xor    $0x1f,%edi
  8021ca:	0f 84 98 00 00 00    	je     802268 <__udivdi3+0x108>
  8021d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	89 c5                	mov    %eax,%ebp
  8021d9:	29 fb                	sub    %edi,%ebx
  8021db:	d3 e6                	shl    %cl,%esi
  8021dd:	89 d9                	mov    %ebx,%ecx
  8021df:	d3 ed                	shr    %cl,%ebp
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	d3 e0                	shl    %cl,%eax
  8021e5:	09 ee                	or     %ebp,%esi
  8021e7:	89 d9                	mov    %ebx,%ecx
  8021e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ed:	89 d5                	mov    %edx,%ebp
  8021ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021f3:	d3 ed                	shr    %cl,%ebp
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	d3 e2                	shl    %cl,%edx
  8021f9:	89 d9                	mov    %ebx,%ecx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	09 c2                	or     %eax,%edx
  8021ff:	89 d0                	mov    %edx,%eax
  802201:	89 ea                	mov    %ebp,%edx
  802203:	f7 f6                	div    %esi
  802205:	89 d5                	mov    %edx,%ebp
  802207:	89 c3                	mov    %eax,%ebx
  802209:	f7 64 24 0c          	mull   0xc(%esp)
  80220d:	39 d5                	cmp    %edx,%ebp
  80220f:	72 10                	jb     802221 <__udivdi3+0xc1>
  802211:	8b 74 24 08          	mov    0x8(%esp),%esi
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e6                	shl    %cl,%esi
  802219:	39 c6                	cmp    %eax,%esi
  80221b:	73 07                	jae    802224 <__udivdi3+0xc4>
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	75 03                	jne    802224 <__udivdi3+0xc4>
  802221:	83 eb 01             	sub    $0x1,%ebx
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 d8                	mov    %ebx,%eax
  802228:	89 fa                	mov    %edi,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	31 ff                	xor    %edi,%edi
  80223a:	31 db                	xor    %ebx,%ebx
  80223c:	89 d8                	mov    %ebx,%eax
  80223e:	89 fa                	mov    %edi,%edx
  802240:	83 c4 1c             	add    $0x1c,%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	90                   	nop
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 d8                	mov    %ebx,%eax
  802252:	f7 f7                	div    %edi
  802254:	31 ff                	xor    %edi,%edi
  802256:	89 c3                	mov    %eax,%ebx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 fa                	mov    %edi,%edx
  80225c:	83 c4 1c             	add    $0x1c,%esp
  80225f:	5b                   	pop    %ebx
  802260:	5e                   	pop    %esi
  802261:	5f                   	pop    %edi
  802262:	5d                   	pop    %ebp
  802263:	c3                   	ret    
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	39 ce                	cmp    %ecx,%esi
  80226a:	72 0c                	jb     802278 <__udivdi3+0x118>
  80226c:	31 db                	xor    %ebx,%ebx
  80226e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802272:	0f 87 34 ff ff ff    	ja     8021ac <__udivdi3+0x4c>
  802278:	bb 01 00 00 00       	mov    $0x1,%ebx
  80227d:	e9 2a ff ff ff       	jmp    8021ac <__udivdi3+0x4c>
  802282:	66 90                	xchg   %ax,%ax
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	53                   	push   %ebx
  802294:	83 ec 1c             	sub    $0x1c,%esp
  802297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80229b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80229f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022a7:	85 d2                	test   %edx,%edx
  8022a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b1:	89 f3                	mov    %esi,%ebx
  8022b3:	89 3c 24             	mov    %edi,(%esp)
  8022b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ba:	75 1c                	jne    8022d8 <__umoddi3+0x48>
  8022bc:	39 f7                	cmp    %esi,%edi
  8022be:	76 50                	jbe    802310 <__umoddi3+0x80>
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	f7 f7                	div    %edi
  8022c6:	89 d0                	mov    %edx,%eax
  8022c8:	31 d2                	xor    %edx,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	89 d0                	mov    %edx,%eax
  8022dc:	77 52                	ja     802330 <__umoddi3+0xa0>
  8022de:	0f bd ea             	bsr    %edx,%ebp
  8022e1:	83 f5 1f             	xor    $0x1f,%ebp
  8022e4:	75 5a                	jne    802340 <__umoddi3+0xb0>
  8022e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ea:	0f 82 e0 00 00 00    	jb     8023d0 <__umoddi3+0x140>
  8022f0:	39 0c 24             	cmp    %ecx,(%esp)
  8022f3:	0f 86 d7 00 00 00    	jbe    8023d0 <__umoddi3+0x140>
  8022f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	85 ff                	test   %edi,%edi
  802312:	89 fd                	mov    %edi,%ebp
  802314:	75 0b                	jne    802321 <__umoddi3+0x91>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f7                	div    %edi
  80231f:	89 c5                	mov    %eax,%ebp
  802321:	89 f0                	mov    %esi,%eax
  802323:	31 d2                	xor    %edx,%edx
  802325:	f7 f5                	div    %ebp
  802327:	89 c8                	mov    %ecx,%eax
  802329:	f7 f5                	div    %ebp
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	eb 99                	jmp    8022c8 <__umoddi3+0x38>
  80232f:	90                   	nop
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	83 c4 1c             	add    $0x1c,%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5f                   	pop    %edi
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	8b 34 24             	mov    (%esp),%esi
  802343:	bf 20 00 00 00       	mov    $0x20,%edi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	29 ef                	sub    %ebp,%edi
  80234c:	d3 e0                	shl    %cl,%eax
  80234e:	89 f9                	mov    %edi,%ecx
  802350:	89 f2                	mov    %esi,%edx
  802352:	d3 ea                	shr    %cl,%edx
  802354:	89 e9                	mov    %ebp,%ecx
  802356:	09 c2                	or     %eax,%edx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 14 24             	mov    %edx,(%esp)
  80235d:	89 f2                	mov    %esi,%edx
  80235f:	d3 e2                	shl    %cl,%edx
  802361:	89 f9                	mov    %edi,%ecx
  802363:	89 54 24 04          	mov    %edx,0x4(%esp)
  802367:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	89 c6                	mov    %eax,%esi
  802371:	d3 e3                	shl    %cl,%ebx
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 d0                	mov    %edx,%eax
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	09 d8                	or     %ebx,%eax
  80237d:	89 d3                	mov    %edx,%ebx
  80237f:	89 f2                	mov    %esi,%edx
  802381:	f7 34 24             	divl   (%esp)
  802384:	89 d6                	mov    %edx,%esi
  802386:	d3 e3                	shl    %cl,%ebx
  802388:	f7 64 24 04          	mull   0x4(%esp)
  80238c:	39 d6                	cmp    %edx,%esi
  80238e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802392:	89 d1                	mov    %edx,%ecx
  802394:	89 c3                	mov    %eax,%ebx
  802396:	72 08                	jb     8023a0 <__umoddi3+0x110>
  802398:	75 11                	jne    8023ab <__umoddi3+0x11b>
  80239a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80239e:	73 0b                	jae    8023ab <__umoddi3+0x11b>
  8023a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023a4:	1b 14 24             	sbb    (%esp),%edx
  8023a7:	89 d1                	mov    %edx,%ecx
  8023a9:	89 c3                	mov    %eax,%ebx
  8023ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023af:	29 da                	sub    %ebx,%edx
  8023b1:	19 ce                	sbb    %ecx,%esi
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 f0                	mov    %esi,%eax
  8023b7:	d3 e0                	shl    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	d3 ea                	shr    %cl,%edx
  8023bd:	89 e9                	mov    %ebp,%ecx
  8023bf:	d3 ee                	shr    %cl,%esi
  8023c1:	09 d0                	or     %edx,%eax
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	83 c4 1c             	add    $0x1c,%esp
  8023c8:	5b                   	pop    %ebx
  8023c9:	5e                   	pop    %esi
  8023ca:	5f                   	pop    %edi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    
  8023cd:	8d 76 00             	lea    0x0(%esi),%esi
  8023d0:	29 f9                	sub    %edi,%ecx
  8023d2:	19 d6                	sbb    %edx,%esi
  8023d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023dc:	e9 18 ff ff ff       	jmp    8022f9 <__umoddi3+0x69>
