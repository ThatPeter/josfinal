
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
  800044:	68 51 27 80 00       	push   $0x802751
  800049:	68 20 27 80 00       	push   $0x802720
  80004e:	e8 a0 06 00 00       	call   8006f3 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 30 27 80 00       	push   $0x802730
  80005c:	68 34 27 80 00       	push   $0x802734
  800061:	e8 8d 06 00 00       	call   8006f3 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 44 27 80 00       	push   $0x802744
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
  800089:	68 48 27 80 00       	push   $0x802748
  80008e:	e8 60 06 00 00       	call   8006f3 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 52 27 80 00       	push   $0x802752
  8000a6:	68 34 27 80 00       	push   $0x802734
  8000ab:	e8 43 06 00 00       	call   8006f3 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 44 27 80 00       	push   $0x802744
  8000c3:	e8 2b 06 00 00       	call   8006f3 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 48 27 80 00       	push   $0x802748
  8000d5:	e8 19 06 00 00       	call   8006f3 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 56 27 80 00       	push   $0x802756
  8000ed:	68 34 27 80 00       	push   $0x802734
  8000f2:	e8 fc 05 00 00       	call   8006f3 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 44 27 80 00       	push   $0x802744
  80010a:	e8 e4 05 00 00       	call   8006f3 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 48 27 80 00       	push   $0x802748
  80011c:	e8 d2 05 00 00       	call   8006f3 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 5a 27 80 00       	push   $0x80275a
  800134:	68 34 27 80 00       	push   $0x802734
  800139:	e8 b5 05 00 00       	call   8006f3 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 44 27 80 00       	push   $0x802744
  800151:	e8 9d 05 00 00       	call   8006f3 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 48 27 80 00       	push   $0x802748
  800163:	e8 8b 05 00 00       	call   8006f3 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 5e 27 80 00       	push   $0x80275e
  80017b:	68 34 27 80 00       	push   $0x802734
  800180:	e8 6e 05 00 00       	call   8006f3 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 44 27 80 00       	push   $0x802744
  800198:	e8 56 05 00 00       	call   8006f3 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 48 27 80 00       	push   $0x802748
  8001aa:	e8 44 05 00 00       	call   8006f3 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 62 27 80 00       	push   $0x802762
  8001c2:	68 34 27 80 00       	push   $0x802734
  8001c7:	e8 27 05 00 00       	call   8006f3 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 44 27 80 00       	push   $0x802744
  8001df:	e8 0f 05 00 00       	call   8006f3 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 48 27 80 00       	push   $0x802748
  8001f1:	e8 fd 04 00 00       	call   8006f3 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 66 27 80 00       	push   $0x802766
  800209:	68 34 27 80 00       	push   $0x802734
  80020e:	e8 e0 04 00 00       	call   8006f3 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 44 27 80 00       	push   $0x802744
  800226:	e8 c8 04 00 00       	call   8006f3 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 48 27 80 00       	push   $0x802748
  800238:	e8 b6 04 00 00       	call   8006f3 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 6a 27 80 00       	push   $0x80276a
  800250:	68 34 27 80 00       	push   $0x802734
  800255:	e8 99 04 00 00       	call   8006f3 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 44 27 80 00       	push   $0x802744
  80026d:	e8 81 04 00 00       	call   8006f3 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 48 27 80 00       	push   $0x802748
  80027f:	e8 6f 04 00 00       	call   8006f3 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 6e 27 80 00       	push   $0x80276e
  800297:	68 34 27 80 00       	push   $0x802734
  80029c:	e8 52 04 00 00       	call   8006f3 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 44 27 80 00       	push   $0x802744
  8002b4:	e8 3a 04 00 00       	call   8006f3 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 75 27 80 00       	push   $0x802775
  8002c4:	68 34 27 80 00       	push   $0x802734
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
  8002de:	68 48 27 80 00       	push   $0x802748
  8002e3:	e8 0b 04 00 00       	call   8006f3 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 75 27 80 00       	push   $0x802775
  8002f3:	68 34 27 80 00       	push   $0x802734
  8002f8:	e8 f6 03 00 00       	call   8006f3 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 44 27 80 00       	push   $0x802744
  800312:	e8 dc 03 00 00       	call   8006f3 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 79 27 80 00       	push   $0x802779
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
  800333:	68 48 27 80 00       	push   $0x802748
  800338:	e8 b6 03 00 00       	call   8006f3 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 79 27 80 00       	push   $0x802779
  800348:	e8 a6 03 00 00       	call   8006f3 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 44 27 80 00       	push   $0x802744
  80035a:	e8 94 03 00 00       	call   8006f3 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 48 27 80 00       	push   $0x802748
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
  800379:	68 44 27 80 00       	push   $0x802744
  80037e:	e8 70 03 00 00       	call   8006f3 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 79 27 80 00       	push   $0x802779
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
  8003ba:	68 e0 27 80 00       	push   $0x8027e0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 87 27 80 00       	push   $0x802787
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
  800436:	68 9f 27 80 00       	push   $0x80279f
  80043b:	68 ad 27 80 00       	push   $0x8027ad
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba 98 27 80 00       	mov    $0x802798,%edx
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
  80046d:	68 b4 27 80 00       	push   $0x8027b4
  800472:	6a 5c                	push   $0x5c
  800474:	68 87 27 80 00       	push   $0x802787
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
  80048b:	e8 1c 0e 00 00       	call   8012ac <set_pgfault_handler>

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
  80055a:	68 14 28 80 00       	push   $0x802814
  80055f:	e8 8f 01 00 00       	call   8006f3 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 c7 27 80 00       	push   $0x8027c7
  800579:	68 d8 27 80 00       	push   $0x8027d8
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba 98 27 80 00       	mov    $0x802798,%edx
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
  8005ac:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  800606:	e8 ef 11 00 00       	call   8017fa <close_all>
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
  800638:	68 40 28 80 00       	push   $0x802840
  80063d:	e8 b1 00 00 00       	call   8006f3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800642:	83 c4 18             	add    $0x18,%esp
  800645:	53                   	push   %ebx
  800646:	ff 75 10             	pushl  0x10(%ebp)
  800649:	e8 54 00 00 00       	call   8006a2 <vcprintf>
	cprintf("\n");
  80064e:	c7 04 24 50 27 80 00 	movl   $0x802750,(%esp)
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
  800756:	e8 25 1d 00 00       	call   802480 <__udivdi3>
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
  800799:	e8 12 1e 00 00       	call   8025b0 <__umoddi3>
  80079e:	83 c4 14             	add    $0x14,%esp
  8007a1:	0f be 80 63 28 80 00 	movsbl 0x802863(%eax),%eax
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
  80089d:	ff 24 85 a0 29 80 00 	jmp    *0x8029a0(,%eax,4)
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
  800961:	8b 14 85 00 2b 80 00 	mov    0x802b00(,%eax,4),%edx
  800968:	85 d2                	test   %edx,%edx
  80096a:	75 18                	jne    800984 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80096c:	50                   	push   %eax
  80096d:	68 7b 28 80 00       	push   $0x80287b
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
  800985:	68 c1 2c 80 00       	push   $0x802cc1
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
  8009a9:	b8 74 28 80 00       	mov    $0x802874,%eax
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
  801024:	68 5f 2b 80 00       	push   $0x802b5f
  801029:	6a 23                	push   $0x23
  80102b:	68 7c 2b 80 00       	push   $0x802b7c
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
  8010a5:	68 5f 2b 80 00       	push   $0x802b5f
  8010aa:	6a 23                	push   $0x23
  8010ac:	68 7c 2b 80 00       	push   $0x802b7c
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
  8010e7:	68 5f 2b 80 00       	push   $0x802b5f
  8010ec:	6a 23                	push   $0x23
  8010ee:	68 7c 2b 80 00       	push   $0x802b7c
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
  801129:	68 5f 2b 80 00       	push   $0x802b5f
  80112e:	6a 23                	push   $0x23
  801130:	68 7c 2b 80 00       	push   $0x802b7c
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
  80116b:	68 5f 2b 80 00       	push   $0x802b5f
  801170:	6a 23                	push   $0x23
  801172:	68 7c 2b 80 00       	push   $0x802b7c
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
  8011ad:	68 5f 2b 80 00       	push   $0x802b5f
  8011b2:	6a 23                	push   $0x23
  8011b4:	68 7c 2b 80 00       	push   $0x802b7c
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
  8011ef:	68 5f 2b 80 00       	push   $0x802b5f
  8011f4:	6a 23                	push   $0x23
  8011f6:	68 7c 2b 80 00       	push   $0x802b7c
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
  801253:	68 5f 2b 80 00       	push   $0x802b5f
  801258:	6a 23                	push   $0x23
  80125a:	68 7c 2b 80 00       	push   $0x802b7c
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

008012ac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012ac:	55                   	push   %ebp
  8012ad:	89 e5                	mov    %esp,%ebp
  8012af:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012b2:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012b9:	75 2a                	jne    8012e5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8012bb:	83 ec 04             	sub    $0x4,%esp
  8012be:	6a 07                	push   $0x7
  8012c0:	68 00 f0 bf ee       	push   $0xeebff000
  8012c5:	6a 00                	push   $0x0
  8012c7:	e8 af fd ff ff       	call   80107b <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	79 12                	jns    8012e5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8012d3:	50                   	push   %eax
  8012d4:	68 8a 2b 80 00       	push   $0x802b8a
  8012d9:	6a 23                	push   $0x23
  8012db:	68 8e 2b 80 00       	push   $0x802b8e
  8012e0:	e8 35 f3 ff ff       	call   80061a <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e8:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	68 17 13 80 00       	push   $0x801317
  8012f5:	6a 00                	push   $0x0
  8012f7:	e8 ca fe ff ff       	call   8011c6 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	79 12                	jns    801315 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801303:	50                   	push   %eax
  801304:	68 8a 2b 80 00       	push   $0x802b8a
  801309:	6a 2c                	push   $0x2c
  80130b:	68 8e 2b 80 00       	push   $0x802b8e
  801310:	e8 05 f3 ff ff       	call   80061a <_panic>
	}
}
  801315:	c9                   	leave  
  801316:	c3                   	ret    

00801317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801318:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80131d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80131f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801322:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801326:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80132b:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80132f:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801331:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801334:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801335:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801338:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801339:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80133a:	c3                   	ret    

0080133b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	53                   	push   %ebx
  80133f:	83 ec 04             	sub    $0x4,%esp
  801342:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801345:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  801347:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80134b:	74 11                	je     80135e <pgfault+0x23>
  80134d:	89 d8                	mov    %ebx,%eax
  80134f:	c1 e8 0c             	shr    $0xc,%eax
  801352:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801359:	f6 c4 08             	test   $0x8,%ah
  80135c:	75 14                	jne    801372 <pgfault+0x37>
		panic("faulting access");
  80135e:	83 ec 04             	sub    $0x4,%esp
  801361:	68 9c 2b 80 00       	push   $0x802b9c
  801366:	6a 1e                	push   $0x1e
  801368:	68 ac 2b 80 00       	push   $0x802bac
  80136d:	e8 a8 f2 ff ff       	call   80061a <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  801372:	83 ec 04             	sub    $0x4,%esp
  801375:	6a 07                	push   $0x7
  801377:	68 00 f0 7f 00       	push   $0x7ff000
  80137c:	6a 00                	push   $0x0
  80137e:	e8 f8 fc ff ff       	call   80107b <sys_page_alloc>
	if (r < 0) {
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	79 12                	jns    80139c <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80138a:	50                   	push   %eax
  80138b:	68 b7 2b 80 00       	push   $0x802bb7
  801390:	6a 2c                	push   $0x2c
  801392:	68 ac 2b 80 00       	push   $0x802bac
  801397:	e8 7e f2 ff ff       	call   80061a <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80139c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  8013a2:	83 ec 04             	sub    $0x4,%esp
  8013a5:	68 00 10 00 00       	push   $0x1000
  8013aa:	53                   	push   %ebx
  8013ab:	68 00 f0 7f 00       	push   $0x7ff000
  8013b0:	e8 bd fa ff ff       	call   800e72 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  8013b5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8013bc:	53                   	push   %ebx
  8013bd:	6a 00                	push   $0x0
  8013bf:	68 00 f0 7f 00       	push   $0x7ff000
  8013c4:	6a 00                	push   $0x0
  8013c6:	e8 f3 fc ff ff       	call   8010be <sys_page_map>
	if (r < 0) {
  8013cb:	83 c4 20             	add    $0x20,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	79 12                	jns    8013e4 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  8013d2:	50                   	push   %eax
  8013d3:	68 b7 2b 80 00       	push   $0x802bb7
  8013d8:	6a 33                	push   $0x33
  8013da:	68 ac 2b 80 00       	push   $0x802bac
  8013df:	e8 36 f2 ff ff       	call   80061a <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	68 00 f0 7f 00       	push   $0x7ff000
  8013ec:	6a 00                	push   $0x0
  8013ee:	e8 0d fd ff ff       	call   801100 <sys_page_unmap>
	if (r < 0) {
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	79 12                	jns    80140c <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8013fa:	50                   	push   %eax
  8013fb:	68 b7 2b 80 00       	push   $0x802bb7
  801400:	6a 37                	push   $0x37
  801402:	68 ac 2b 80 00       	push   $0x802bac
  801407:	e8 0e f2 ff ff       	call   80061a <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	57                   	push   %edi
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80141a:	68 3b 13 80 00       	push   $0x80133b
  80141f:	e8 88 fe ff ff       	call   8012ac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801424:	b8 07 00 00 00       	mov    $0x7,%eax
  801429:	cd 30                	int    $0x30
  80142b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	85 c0                	test   %eax,%eax
  801433:	79 17                	jns    80144c <fork+0x3b>
		panic("fork fault %e");
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	68 d0 2b 80 00       	push   $0x802bd0
  80143d:	68 84 00 00 00       	push   $0x84
  801442:	68 ac 2b 80 00       	push   $0x802bac
  801447:	e8 ce f1 ff ff       	call   80061a <_panic>
  80144c:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  80144e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801452:	75 24                	jne    801478 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  801454:	e8 e4 fb ff ff       	call   80103d <sys_getenvid>
  801459:	25 ff 03 00 00       	and    $0x3ff,%eax
  80145e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801464:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801469:	a3 b0 40 80 00       	mov    %eax,0x8040b0
		return 0;
  80146e:	b8 00 00 00 00       	mov    $0x0,%eax
  801473:	e9 64 01 00 00       	jmp    8015dc <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	6a 07                	push   $0x7
  80147d:	68 00 f0 bf ee       	push   $0xeebff000
  801482:	ff 75 e4             	pushl  -0x1c(%ebp)
  801485:	e8 f1 fb ff ff       	call   80107b <sys_page_alloc>
  80148a:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80148d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801492:	89 d8                	mov    %ebx,%eax
  801494:	c1 e8 16             	shr    $0x16,%eax
  801497:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149e:	a8 01                	test   $0x1,%al
  8014a0:	0f 84 fc 00 00 00    	je     8015a2 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8014a6:	89 d8                	mov    %ebx,%eax
  8014a8:	c1 e8 0c             	shr    $0xc,%eax
  8014ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8014b2:	f6 c2 01             	test   $0x1,%dl
  8014b5:	0f 84 e7 00 00 00    	je     8015a2 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8014bb:	89 c6                	mov    %eax,%esi
  8014bd:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8014c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c7:	f6 c6 04             	test   $0x4,%dh
  8014ca:	74 39                	je     801505 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8014cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014db:	50                   	push   %eax
  8014dc:	56                   	push   %esi
  8014dd:	57                   	push   %edi
  8014de:	56                   	push   %esi
  8014df:	6a 00                	push   $0x0
  8014e1:	e8 d8 fb ff ff       	call   8010be <sys_page_map>
		if (r < 0) {
  8014e6:	83 c4 20             	add    $0x20,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	0f 89 b1 00 00 00    	jns    8015a2 <fork+0x191>
		    	panic("sys page map fault %e");
  8014f1:	83 ec 04             	sub    $0x4,%esp
  8014f4:	68 de 2b 80 00       	push   $0x802bde
  8014f9:	6a 54                	push   $0x54
  8014fb:	68 ac 2b 80 00       	push   $0x802bac
  801500:	e8 15 f1 ff ff       	call   80061a <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801505:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80150c:	f6 c2 02             	test   $0x2,%dl
  80150f:	75 0c                	jne    80151d <fork+0x10c>
  801511:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801518:	f6 c4 08             	test   $0x8,%ah
  80151b:	74 5b                	je     801578 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80151d:	83 ec 0c             	sub    $0xc,%esp
  801520:	68 05 08 00 00       	push   $0x805
  801525:	56                   	push   %esi
  801526:	57                   	push   %edi
  801527:	56                   	push   %esi
  801528:	6a 00                	push   $0x0
  80152a:	e8 8f fb ff ff       	call   8010be <sys_page_map>
		if (r < 0) {
  80152f:	83 c4 20             	add    $0x20,%esp
  801532:	85 c0                	test   %eax,%eax
  801534:	79 14                	jns    80154a <fork+0x139>
		    	panic("sys page map fault %e");
  801536:	83 ec 04             	sub    $0x4,%esp
  801539:	68 de 2b 80 00       	push   $0x802bde
  80153e:	6a 5b                	push   $0x5b
  801540:	68 ac 2b 80 00       	push   $0x802bac
  801545:	e8 d0 f0 ff ff       	call   80061a <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80154a:	83 ec 0c             	sub    $0xc,%esp
  80154d:	68 05 08 00 00       	push   $0x805
  801552:	56                   	push   %esi
  801553:	6a 00                	push   $0x0
  801555:	56                   	push   %esi
  801556:	6a 00                	push   $0x0
  801558:	e8 61 fb ff ff       	call   8010be <sys_page_map>
		if (r < 0) {
  80155d:	83 c4 20             	add    $0x20,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	79 3e                	jns    8015a2 <fork+0x191>
		    	panic("sys page map fault %e");
  801564:	83 ec 04             	sub    $0x4,%esp
  801567:	68 de 2b 80 00       	push   $0x802bde
  80156c:	6a 5f                	push   $0x5f
  80156e:	68 ac 2b 80 00       	push   $0x802bac
  801573:	e8 a2 f0 ff ff       	call   80061a <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  801578:	83 ec 0c             	sub    $0xc,%esp
  80157b:	6a 05                	push   $0x5
  80157d:	56                   	push   %esi
  80157e:	57                   	push   %edi
  80157f:	56                   	push   %esi
  801580:	6a 00                	push   $0x0
  801582:	e8 37 fb ff ff       	call   8010be <sys_page_map>
		if (r < 0) {
  801587:	83 c4 20             	add    $0x20,%esp
  80158a:	85 c0                	test   %eax,%eax
  80158c:	79 14                	jns    8015a2 <fork+0x191>
		    	panic("sys page map fault %e");
  80158e:	83 ec 04             	sub    $0x4,%esp
  801591:	68 de 2b 80 00       	push   $0x802bde
  801596:	6a 64                	push   $0x64
  801598:	68 ac 2b 80 00       	push   $0x802bac
  80159d:	e8 78 f0 ff ff       	call   80061a <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8015a2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015a8:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8015ae:	0f 85 de fe ff ff    	jne    801492 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8015b4:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8015b9:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	50                   	push   %eax
  8015c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015c6:	57                   	push   %edi
  8015c7:	e8 fa fb ff ff       	call   8011c6 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8015cc:	83 c4 08             	add    $0x8,%esp
  8015cf:	6a 02                	push   $0x2
  8015d1:	57                   	push   %edi
  8015d2:	e8 6b fb ff ff       	call   801142 <sys_env_set_status>
	
	return envid;
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8015dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015df:	5b                   	pop    %ebx
  8015e0:	5e                   	pop    %esi
  8015e1:	5f                   	pop    %edi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <sfork>:

envid_t
sfork(void)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8015e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	56                   	push   %esi
  8015f2:	53                   	push   %ebx
  8015f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8015f6:	89 1d b8 40 80 00    	mov    %ebx,0x8040b8
	cprintf("in fork.c thread create. func: %x\n", func);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	53                   	push   %ebx
  801600:	68 f4 2b 80 00       	push   $0x802bf4
  801605:	e8 e9 f0 ff ff       	call   8006f3 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80160a:	c7 04 24 e0 05 80 00 	movl   $0x8005e0,(%esp)
  801611:	e8 56 fc ff ff       	call   80126c <sys_thread_create>
  801616:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801618:	83 c4 08             	add    $0x8,%esp
  80161b:	53                   	push   %ebx
  80161c:	68 f4 2b 80 00       	push   $0x802bf4
  801621:	e8 cd f0 ff ff       	call   8006f3 <cprintf>
	return id;
}
  801626:	89 f0                	mov    %esi,%eax
  801628:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801632:	8b 45 08             	mov    0x8(%ebp),%eax
  801635:	05 00 00 00 30       	add    $0x30000000,%eax
  80163a:	c1 e8 0c             	shr    $0xc,%eax
}
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801642:	8b 45 08             	mov    0x8(%ebp),%eax
  801645:	05 00 00 00 30       	add    $0x30000000,%eax
  80164a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80164f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    

00801656 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80165c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801661:	89 c2                	mov    %eax,%edx
  801663:	c1 ea 16             	shr    $0x16,%edx
  801666:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80166d:	f6 c2 01             	test   $0x1,%dl
  801670:	74 11                	je     801683 <fd_alloc+0x2d>
  801672:	89 c2                	mov    %eax,%edx
  801674:	c1 ea 0c             	shr    $0xc,%edx
  801677:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80167e:	f6 c2 01             	test   $0x1,%dl
  801681:	75 09                	jne    80168c <fd_alloc+0x36>
			*fd_store = fd;
  801683:	89 01                	mov    %eax,(%ecx)
			return 0;
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
  80168a:	eb 17                	jmp    8016a3 <fd_alloc+0x4d>
  80168c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801691:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801696:	75 c9                	jne    801661 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801698:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80169e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016ab:	83 f8 1f             	cmp    $0x1f,%eax
  8016ae:	77 36                	ja     8016e6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016b0:	c1 e0 0c             	shl    $0xc,%eax
  8016b3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	c1 ea 16             	shr    $0x16,%edx
  8016bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016c4:	f6 c2 01             	test   $0x1,%dl
  8016c7:	74 24                	je     8016ed <fd_lookup+0x48>
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	c1 ea 0c             	shr    $0xc,%edx
  8016ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016d5:	f6 c2 01             	test   $0x1,%dl
  8016d8:	74 1a                	je     8016f4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016dd:	89 02                	mov    %eax,(%edx)
	return 0;
  8016df:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e4:	eb 13                	jmp    8016f9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016eb:	eb 0c                	jmp    8016f9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f2:	eb 05                	jmp    8016f9 <fd_lookup+0x54>
  8016f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801704:	ba 98 2c 80 00       	mov    $0x802c98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801709:	eb 13                	jmp    80171e <dev_lookup+0x23>
  80170b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80170e:	39 08                	cmp    %ecx,(%eax)
  801710:	75 0c                	jne    80171e <dev_lookup+0x23>
			*dev = devtab[i];
  801712:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801715:	89 01                	mov    %eax,(%ecx)
			return 0;
  801717:	b8 00 00 00 00       	mov    $0x0,%eax
  80171c:	eb 2e                	jmp    80174c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80171e:	8b 02                	mov    (%edx),%eax
  801720:	85 c0                	test   %eax,%eax
  801722:	75 e7                	jne    80170b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801724:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801729:	8b 40 7c             	mov    0x7c(%eax),%eax
  80172c:	83 ec 04             	sub    $0x4,%esp
  80172f:	51                   	push   %ecx
  801730:	50                   	push   %eax
  801731:	68 18 2c 80 00       	push   $0x802c18
  801736:	e8 b8 ef ff ff       	call   8006f3 <cprintf>
	*dev = 0;
  80173b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
  801753:	83 ec 10             	sub    $0x10,%esp
  801756:	8b 75 08             	mov    0x8(%ebp),%esi
  801759:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80175c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175f:	50                   	push   %eax
  801760:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801766:	c1 e8 0c             	shr    $0xc,%eax
  801769:	50                   	push   %eax
  80176a:	e8 36 ff ff ff       	call   8016a5 <fd_lookup>
  80176f:	83 c4 08             	add    $0x8,%esp
  801772:	85 c0                	test   %eax,%eax
  801774:	78 05                	js     80177b <fd_close+0x2d>
	    || fd != fd2)
  801776:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801779:	74 0c                	je     801787 <fd_close+0x39>
		return (must_exist ? r : 0);
  80177b:	84 db                	test   %bl,%bl
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	0f 44 c2             	cmove  %edx,%eax
  801785:	eb 41                	jmp    8017c8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	ff 36                	pushl  (%esi)
  801790:	e8 66 ff ff ff       	call   8016fb <dev_lookup>
  801795:	89 c3                	mov    %eax,%ebx
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 1a                	js     8017b8 <fd_close+0x6a>
		if (dev->dev_close)
  80179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8017a4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	74 0b                	je     8017b8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8017ad:	83 ec 0c             	sub    $0xc,%esp
  8017b0:	56                   	push   %esi
  8017b1:	ff d0                	call   *%eax
  8017b3:	89 c3                	mov    %eax,%ebx
  8017b5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017b8:	83 ec 08             	sub    $0x8,%esp
  8017bb:	56                   	push   %esi
  8017bc:	6a 00                	push   $0x0
  8017be:	e8 3d f9 ff ff       	call   801100 <sys_page_unmap>
	return r;
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	89 d8                	mov    %ebx,%eax
}
  8017c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5e                   	pop    %esi
  8017cd:	5d                   	pop    %ebp
  8017ce:	c3                   	ret    

008017cf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d8:	50                   	push   %eax
  8017d9:	ff 75 08             	pushl  0x8(%ebp)
  8017dc:	e8 c4 fe ff ff       	call   8016a5 <fd_lookup>
  8017e1:	83 c4 08             	add    $0x8,%esp
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 10                	js     8017f8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8017e8:	83 ec 08             	sub    $0x8,%esp
  8017eb:	6a 01                	push   $0x1
  8017ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8017f0:	e8 59 ff ff ff       	call   80174e <fd_close>
  8017f5:	83 c4 10             	add    $0x10,%esp
}
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    

008017fa <close_all>:

void
close_all(void)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	53                   	push   %ebx
  8017fe:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801801:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801806:	83 ec 0c             	sub    $0xc,%esp
  801809:	53                   	push   %ebx
  80180a:	e8 c0 ff ff ff       	call   8017cf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80180f:	83 c3 01             	add    $0x1,%ebx
  801812:	83 c4 10             	add    $0x10,%esp
  801815:	83 fb 20             	cmp    $0x20,%ebx
  801818:	75 ec                	jne    801806 <close_all+0xc>
		close(i);
}
  80181a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181d:	c9                   	leave  
  80181e:	c3                   	ret    

0080181f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	57                   	push   %edi
  801823:	56                   	push   %esi
  801824:	53                   	push   %ebx
  801825:	83 ec 2c             	sub    $0x2c,%esp
  801828:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80182b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80182e:	50                   	push   %eax
  80182f:	ff 75 08             	pushl  0x8(%ebp)
  801832:	e8 6e fe ff ff       	call   8016a5 <fd_lookup>
  801837:	83 c4 08             	add    $0x8,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	0f 88 c1 00 00 00    	js     801903 <dup+0xe4>
		return r;
	close(newfdnum);
  801842:	83 ec 0c             	sub    $0xc,%esp
  801845:	56                   	push   %esi
  801846:	e8 84 ff ff ff       	call   8017cf <close>

	newfd = INDEX2FD(newfdnum);
  80184b:	89 f3                	mov    %esi,%ebx
  80184d:	c1 e3 0c             	shl    $0xc,%ebx
  801850:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801856:	83 c4 04             	add    $0x4,%esp
  801859:	ff 75 e4             	pushl  -0x1c(%ebp)
  80185c:	e8 de fd ff ff       	call   80163f <fd2data>
  801861:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801863:	89 1c 24             	mov    %ebx,(%esp)
  801866:	e8 d4 fd ff ff       	call   80163f <fd2data>
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801871:	89 f8                	mov    %edi,%eax
  801873:	c1 e8 16             	shr    $0x16,%eax
  801876:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80187d:	a8 01                	test   $0x1,%al
  80187f:	74 37                	je     8018b8 <dup+0x99>
  801881:	89 f8                	mov    %edi,%eax
  801883:	c1 e8 0c             	shr    $0xc,%eax
  801886:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80188d:	f6 c2 01             	test   $0x1,%dl
  801890:	74 26                	je     8018b8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801892:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801899:	83 ec 0c             	sub    $0xc,%esp
  80189c:	25 07 0e 00 00       	and    $0xe07,%eax
  8018a1:	50                   	push   %eax
  8018a2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8018a5:	6a 00                	push   $0x0
  8018a7:	57                   	push   %edi
  8018a8:	6a 00                	push   $0x0
  8018aa:	e8 0f f8 ff ff       	call   8010be <sys_page_map>
  8018af:	89 c7                	mov    %eax,%edi
  8018b1:	83 c4 20             	add    $0x20,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 2e                	js     8018e6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018bb:	89 d0                	mov    %edx,%eax
  8018bd:	c1 e8 0c             	shr    $0xc,%eax
  8018c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018c7:	83 ec 0c             	sub    $0xc,%esp
  8018ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8018cf:	50                   	push   %eax
  8018d0:	53                   	push   %ebx
  8018d1:	6a 00                	push   $0x0
  8018d3:	52                   	push   %edx
  8018d4:	6a 00                	push   $0x0
  8018d6:	e8 e3 f7 ff ff       	call   8010be <sys_page_map>
  8018db:	89 c7                	mov    %eax,%edi
  8018dd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8018e0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018e2:	85 ff                	test   %edi,%edi
  8018e4:	79 1d                	jns    801903 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	53                   	push   %ebx
  8018ea:	6a 00                	push   $0x0
  8018ec:	e8 0f f8 ff ff       	call   801100 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8018f1:	83 c4 08             	add    $0x8,%esp
  8018f4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8018f7:	6a 00                	push   $0x0
  8018f9:	e8 02 f8 ff ff       	call   801100 <sys_page_unmap>
	return r;
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	89 f8                	mov    %edi,%eax
}
  801903:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5f                   	pop    %edi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	53                   	push   %ebx
  80190f:	83 ec 14             	sub    $0x14,%esp
  801912:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801915:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801918:	50                   	push   %eax
  801919:	53                   	push   %ebx
  80191a:	e8 86 fd ff ff       	call   8016a5 <fd_lookup>
  80191f:	83 c4 08             	add    $0x8,%esp
  801922:	89 c2                	mov    %eax,%edx
  801924:	85 c0                	test   %eax,%eax
  801926:	78 6d                	js     801995 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801928:	83 ec 08             	sub    $0x8,%esp
  80192b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192e:	50                   	push   %eax
  80192f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801932:	ff 30                	pushl  (%eax)
  801934:	e8 c2 fd ff ff       	call   8016fb <dev_lookup>
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 4c                	js     80198c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801940:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801943:	8b 42 08             	mov    0x8(%edx),%eax
  801946:	83 e0 03             	and    $0x3,%eax
  801949:	83 f8 01             	cmp    $0x1,%eax
  80194c:	75 21                	jne    80196f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80194e:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801953:	8b 40 7c             	mov    0x7c(%eax),%eax
  801956:	83 ec 04             	sub    $0x4,%esp
  801959:	53                   	push   %ebx
  80195a:	50                   	push   %eax
  80195b:	68 5c 2c 80 00       	push   $0x802c5c
  801960:	e8 8e ed ff ff       	call   8006f3 <cprintf>
		return -E_INVAL;
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80196d:	eb 26                	jmp    801995 <read+0x8a>
	}
	if (!dev->dev_read)
  80196f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801972:	8b 40 08             	mov    0x8(%eax),%eax
  801975:	85 c0                	test   %eax,%eax
  801977:	74 17                	je     801990 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801979:	83 ec 04             	sub    $0x4,%esp
  80197c:	ff 75 10             	pushl  0x10(%ebp)
  80197f:	ff 75 0c             	pushl  0xc(%ebp)
  801982:	52                   	push   %edx
  801983:	ff d0                	call   *%eax
  801985:	89 c2                	mov    %eax,%edx
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	eb 09                	jmp    801995 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80198c:	89 c2                	mov    %eax,%edx
  80198e:	eb 05                	jmp    801995 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801990:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801995:	89 d0                	mov    %edx,%eax
  801997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	57                   	push   %edi
  8019a0:	56                   	push   %esi
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 0c             	sub    $0xc,%esp
  8019a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b0:	eb 21                	jmp    8019d3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019b2:	83 ec 04             	sub    $0x4,%esp
  8019b5:	89 f0                	mov    %esi,%eax
  8019b7:	29 d8                	sub    %ebx,%eax
  8019b9:	50                   	push   %eax
  8019ba:	89 d8                	mov    %ebx,%eax
  8019bc:	03 45 0c             	add    0xc(%ebp),%eax
  8019bf:	50                   	push   %eax
  8019c0:	57                   	push   %edi
  8019c1:	e8 45 ff ff ff       	call   80190b <read>
		if (m < 0)
  8019c6:	83 c4 10             	add    $0x10,%esp
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	78 10                	js     8019dd <readn+0x41>
			return m;
		if (m == 0)
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	74 0a                	je     8019db <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019d1:	01 c3                	add    %eax,%ebx
  8019d3:	39 f3                	cmp    %esi,%ebx
  8019d5:	72 db                	jb     8019b2 <readn+0x16>
  8019d7:	89 d8                	mov    %ebx,%eax
  8019d9:	eb 02                	jmp    8019dd <readn+0x41>
  8019db:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8019dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e0:	5b                   	pop    %ebx
  8019e1:	5e                   	pop    %esi
  8019e2:	5f                   	pop    %edi
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	53                   	push   %ebx
  8019e9:	83 ec 14             	sub    $0x14,%esp
  8019ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f2:	50                   	push   %eax
  8019f3:	53                   	push   %ebx
  8019f4:	e8 ac fc ff ff       	call   8016a5 <fd_lookup>
  8019f9:	83 c4 08             	add    $0x8,%esp
  8019fc:	89 c2                	mov    %eax,%edx
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 68                	js     801a6a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a02:	83 ec 08             	sub    $0x8,%esp
  801a05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a08:	50                   	push   %eax
  801a09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0c:	ff 30                	pushl  (%eax)
  801a0e:	e8 e8 fc ff ff       	call   8016fb <dev_lookup>
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 47                	js     801a61 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a21:	75 21                	jne    801a44 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a23:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801a28:	8b 40 7c             	mov    0x7c(%eax),%eax
  801a2b:	83 ec 04             	sub    $0x4,%esp
  801a2e:	53                   	push   %ebx
  801a2f:	50                   	push   %eax
  801a30:	68 78 2c 80 00       	push   $0x802c78
  801a35:	e8 b9 ec ff ff       	call   8006f3 <cprintf>
		return -E_INVAL;
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a42:	eb 26                	jmp    801a6a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a47:	8b 52 0c             	mov    0xc(%edx),%edx
  801a4a:	85 d2                	test   %edx,%edx
  801a4c:	74 17                	je     801a65 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a4e:	83 ec 04             	sub    $0x4,%esp
  801a51:	ff 75 10             	pushl  0x10(%ebp)
  801a54:	ff 75 0c             	pushl  0xc(%ebp)
  801a57:	50                   	push   %eax
  801a58:	ff d2                	call   *%edx
  801a5a:	89 c2                	mov    %eax,%edx
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	eb 09                	jmp    801a6a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a61:	89 c2                	mov    %eax,%edx
  801a63:	eb 05                	jmp    801a6a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a65:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801a6a:	89 d0                	mov    %edx,%eax
  801a6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a77:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	ff 75 08             	pushl  0x8(%ebp)
  801a7e:	e8 22 fc ff ff       	call   8016a5 <fd_lookup>
  801a83:	83 c4 08             	add    $0x8,%esp
  801a86:	85 c0                	test   %eax,%eax
  801a88:	78 0e                	js     801a98 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801a8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a90:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 14             	sub    $0x14,%esp
  801aa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa7:	50                   	push   %eax
  801aa8:	53                   	push   %ebx
  801aa9:	e8 f7 fb ff ff       	call   8016a5 <fd_lookup>
  801aae:	83 c4 08             	add    $0x8,%esp
  801ab1:	89 c2                	mov    %eax,%edx
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 65                	js     801b1c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab7:	83 ec 08             	sub    $0x8,%esp
  801aba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abd:	50                   	push   %eax
  801abe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac1:	ff 30                	pushl  (%eax)
  801ac3:	e8 33 fc ff ff       	call   8016fb <dev_lookup>
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	85 c0                	test   %eax,%eax
  801acd:	78 44                	js     801b13 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801acf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ad6:	75 21                	jne    801af9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ad8:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801add:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ae0:	83 ec 04             	sub    $0x4,%esp
  801ae3:	53                   	push   %ebx
  801ae4:	50                   	push   %eax
  801ae5:	68 38 2c 80 00       	push   $0x802c38
  801aea:	e8 04 ec ff ff       	call   8006f3 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801af7:	eb 23                	jmp    801b1c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801af9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801afc:	8b 52 18             	mov    0x18(%edx),%edx
  801aff:	85 d2                	test   %edx,%edx
  801b01:	74 14                	je     801b17 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b03:	83 ec 08             	sub    $0x8,%esp
  801b06:	ff 75 0c             	pushl  0xc(%ebp)
  801b09:	50                   	push   %eax
  801b0a:	ff d2                	call   *%edx
  801b0c:	89 c2                	mov    %eax,%edx
  801b0e:	83 c4 10             	add    $0x10,%esp
  801b11:	eb 09                	jmp    801b1c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b13:	89 c2                	mov    %eax,%edx
  801b15:	eb 05                	jmp    801b1c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b17:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801b1c:	89 d0                	mov    %edx,%eax
  801b1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b21:	c9                   	leave  
  801b22:	c3                   	ret    

00801b23 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	53                   	push   %ebx
  801b27:	83 ec 14             	sub    $0x14,%esp
  801b2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b30:	50                   	push   %eax
  801b31:	ff 75 08             	pushl  0x8(%ebp)
  801b34:	e8 6c fb ff ff       	call   8016a5 <fd_lookup>
  801b39:	83 c4 08             	add    $0x8,%esp
  801b3c:	89 c2                	mov    %eax,%edx
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 58                	js     801b9a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b42:	83 ec 08             	sub    $0x8,%esp
  801b45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b48:	50                   	push   %eax
  801b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4c:	ff 30                	pushl  (%eax)
  801b4e:	e8 a8 fb ff ff       	call   8016fb <dev_lookup>
  801b53:	83 c4 10             	add    $0x10,%esp
  801b56:	85 c0                	test   %eax,%eax
  801b58:	78 37                	js     801b91 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b61:	74 32                	je     801b95 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b63:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b66:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b6d:	00 00 00 
	stat->st_isdir = 0;
  801b70:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b77:	00 00 00 
	stat->st_dev = dev;
  801b7a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b80:	83 ec 08             	sub    $0x8,%esp
  801b83:	53                   	push   %ebx
  801b84:	ff 75 f0             	pushl  -0x10(%ebp)
  801b87:	ff 50 14             	call   *0x14(%eax)
  801b8a:	89 c2                	mov    %eax,%edx
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	eb 09                	jmp    801b9a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b91:	89 c2                	mov    %eax,%edx
  801b93:	eb 05                	jmp    801b9a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b95:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b9a:	89 d0                	mov    %edx,%eax
  801b9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9f:	c9                   	leave  
  801ba0:	c3                   	ret    

00801ba1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	56                   	push   %esi
  801ba5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ba6:	83 ec 08             	sub    $0x8,%esp
  801ba9:	6a 00                	push   $0x0
  801bab:	ff 75 08             	pushl  0x8(%ebp)
  801bae:	e8 e3 01 00 00       	call   801d96 <open>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	78 1b                	js     801bd7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801bbc:	83 ec 08             	sub    $0x8,%esp
  801bbf:	ff 75 0c             	pushl  0xc(%ebp)
  801bc2:	50                   	push   %eax
  801bc3:	e8 5b ff ff ff       	call   801b23 <fstat>
  801bc8:	89 c6                	mov    %eax,%esi
	close(fd);
  801bca:	89 1c 24             	mov    %ebx,(%esp)
  801bcd:	e8 fd fb ff ff       	call   8017cf <close>
	return r;
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	89 f0                	mov    %esi,%eax
}
  801bd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5e                   	pop    %esi
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	89 c6                	mov    %eax,%esi
  801be5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801be7:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801bee:	75 12                	jne    801c02 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	6a 01                	push   $0x1
  801bf5:	e8 05 08 00 00       	call   8023ff <ipc_find_env>
  801bfa:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801bff:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c02:	6a 07                	push   $0x7
  801c04:	68 00 50 80 00       	push   $0x805000
  801c09:	56                   	push   %esi
  801c0a:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801c10:	e8 88 07 00 00       	call   80239d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c15:	83 c4 0c             	add    $0xc,%esp
  801c18:	6a 00                	push   $0x0
  801c1a:	53                   	push   %ebx
  801c1b:	6a 00                	push   $0x0
  801c1d:	e8 00 07 00 00       	call   802322 <ipc_recv>
}
  801c22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c25:	5b                   	pop    %ebx
  801c26:	5e                   	pop    %esi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c32:	8b 40 0c             	mov    0xc(%eax),%eax
  801c35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c42:	ba 00 00 00 00       	mov    $0x0,%edx
  801c47:	b8 02 00 00 00       	mov    $0x2,%eax
  801c4c:	e8 8d ff ff ff       	call   801bde <fsipc>
}
  801c51:	c9                   	leave  
  801c52:	c3                   	ret    

00801c53 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c59:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801c5f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c64:	ba 00 00 00 00       	mov    $0x0,%edx
  801c69:	b8 06 00 00 00       	mov    $0x6,%eax
  801c6e:	e8 6b ff ff ff       	call   801bde <fsipc>
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	53                   	push   %ebx
  801c79:	83 ec 04             	sub    $0x4,%esp
  801c7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c82:	8b 40 0c             	mov    0xc(%eax),%eax
  801c85:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8f:	b8 05 00 00 00       	mov    $0x5,%eax
  801c94:	e8 45 ff ff ff       	call   801bde <fsipc>
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	78 2c                	js     801cc9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c9d:	83 ec 08             	sub    $0x8,%esp
  801ca0:	68 00 50 80 00       	push   $0x805000
  801ca5:	53                   	push   %ebx
  801ca6:	e8 cd ef ff ff       	call   800c78 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cab:	a1 80 50 80 00       	mov    0x805080,%eax
  801cb0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cb6:	a1 84 50 80 00       	mov    0x805084,%eax
  801cbb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801cc1:	83 c4 10             	add    $0x10,%esp
  801cc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    

00801cce <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 0c             	sub    $0xc,%esp
  801cd4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  801cda:	8b 52 0c             	mov    0xc(%edx),%edx
  801cdd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801ce3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ce8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ced:	0f 47 c2             	cmova  %edx,%eax
  801cf0:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801cf5:	50                   	push   %eax
  801cf6:	ff 75 0c             	pushl  0xc(%ebp)
  801cf9:	68 08 50 80 00       	push   $0x805008
  801cfe:	e8 07 f1 ff ff       	call   800e0a <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801d03:	ba 00 00 00 00       	mov    $0x0,%edx
  801d08:	b8 04 00 00 00       	mov    $0x4,%eax
  801d0d:	e8 cc fe ff ff       	call   801bde <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801d12:	c9                   	leave  
  801d13:	c3                   	ret    

00801d14 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	56                   	push   %esi
  801d18:	53                   	push   %ebx
  801d19:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1f:	8b 40 0c             	mov    0xc(%eax),%eax
  801d22:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d27:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d32:	b8 03 00 00 00       	mov    $0x3,%eax
  801d37:	e8 a2 fe ff ff       	call   801bde <fsipc>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 4b                	js     801d8d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801d42:	39 c6                	cmp    %eax,%esi
  801d44:	73 16                	jae    801d5c <devfile_read+0x48>
  801d46:	68 a8 2c 80 00       	push   $0x802ca8
  801d4b:	68 af 2c 80 00       	push   $0x802caf
  801d50:	6a 7c                	push   $0x7c
  801d52:	68 c4 2c 80 00       	push   $0x802cc4
  801d57:	e8 be e8 ff ff       	call   80061a <_panic>
	assert(r <= PGSIZE);
  801d5c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d61:	7e 16                	jle    801d79 <devfile_read+0x65>
  801d63:	68 cf 2c 80 00       	push   $0x802ccf
  801d68:	68 af 2c 80 00       	push   $0x802caf
  801d6d:	6a 7d                	push   $0x7d
  801d6f:	68 c4 2c 80 00       	push   $0x802cc4
  801d74:	e8 a1 e8 ff ff       	call   80061a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d79:	83 ec 04             	sub    $0x4,%esp
  801d7c:	50                   	push   %eax
  801d7d:	68 00 50 80 00       	push   $0x805000
  801d82:	ff 75 0c             	pushl  0xc(%ebp)
  801d85:	e8 80 f0 ff ff       	call   800e0a <memmove>
	return r;
  801d8a:	83 c4 10             	add    $0x10,%esp
}
  801d8d:	89 d8                	mov    %ebx,%eax
  801d8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d92:	5b                   	pop    %ebx
  801d93:	5e                   	pop    %esi
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    

00801d96 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	53                   	push   %ebx
  801d9a:	83 ec 20             	sub    $0x20,%esp
  801d9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801da0:	53                   	push   %ebx
  801da1:	e8 99 ee ff ff       	call   800c3f <strlen>
  801da6:	83 c4 10             	add    $0x10,%esp
  801da9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801dae:	7f 67                	jg     801e17 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801db0:	83 ec 0c             	sub    $0xc,%esp
  801db3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db6:	50                   	push   %eax
  801db7:	e8 9a f8 ff ff       	call   801656 <fd_alloc>
  801dbc:	83 c4 10             	add    $0x10,%esp
		return r;
  801dbf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	78 57                	js     801e1c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801dc5:	83 ec 08             	sub    $0x8,%esp
  801dc8:	53                   	push   %ebx
  801dc9:	68 00 50 80 00       	push   $0x805000
  801dce:	e8 a5 ee ff ff       	call   800c78 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ddb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dde:	b8 01 00 00 00       	mov    $0x1,%eax
  801de3:	e8 f6 fd ff ff       	call   801bde <fsipc>
  801de8:	89 c3                	mov    %eax,%ebx
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	85 c0                	test   %eax,%eax
  801def:	79 14                	jns    801e05 <open+0x6f>
		fd_close(fd, 0);
  801df1:	83 ec 08             	sub    $0x8,%esp
  801df4:	6a 00                	push   $0x0
  801df6:	ff 75 f4             	pushl  -0xc(%ebp)
  801df9:	e8 50 f9 ff ff       	call   80174e <fd_close>
		return r;
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	89 da                	mov    %ebx,%edx
  801e03:	eb 17                	jmp    801e1c <open+0x86>
	}

	return fd2num(fd);
  801e05:	83 ec 0c             	sub    $0xc,%esp
  801e08:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0b:	e8 1f f8 ff ff       	call   80162f <fd2num>
  801e10:	89 c2                	mov    %eax,%edx
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	eb 05                	jmp    801e1c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e17:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e1c:	89 d0                	mov    %edx,%eax
  801e1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e29:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2e:	b8 08 00 00 00       	mov    $0x8,%eax
  801e33:	e8 a6 fd ff ff       	call   801bde <fsipc>
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	56                   	push   %esi
  801e3e:	53                   	push   %ebx
  801e3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e42:	83 ec 0c             	sub    $0xc,%esp
  801e45:	ff 75 08             	pushl  0x8(%ebp)
  801e48:	e8 f2 f7 ff ff       	call   80163f <fd2data>
  801e4d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e4f:	83 c4 08             	add    $0x8,%esp
  801e52:	68 db 2c 80 00       	push   $0x802cdb
  801e57:	53                   	push   %ebx
  801e58:	e8 1b ee ff ff       	call   800c78 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e5d:	8b 46 04             	mov    0x4(%esi),%eax
  801e60:	2b 06                	sub    (%esi),%eax
  801e62:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e68:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e6f:	00 00 00 
	stat->st_dev = &devpipe;
  801e72:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801e79:	30 80 00 
	return 0;
}
  801e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5e                   	pop    %esi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    

00801e88 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	53                   	push   %ebx
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e92:	53                   	push   %ebx
  801e93:	6a 00                	push   $0x0
  801e95:	e8 66 f2 ff ff       	call   801100 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e9a:	89 1c 24             	mov    %ebx,(%esp)
  801e9d:	e8 9d f7 ff ff       	call   80163f <fd2data>
  801ea2:	83 c4 08             	add    $0x8,%esp
  801ea5:	50                   	push   %eax
  801ea6:	6a 00                	push   $0x0
  801ea8:	e8 53 f2 ff ff       	call   801100 <sys_page_unmap>
}
  801ead:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	57                   	push   %edi
  801eb6:	56                   	push   %esi
  801eb7:	53                   	push   %ebx
  801eb8:	83 ec 1c             	sub    $0x1c,%esp
  801ebb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ebe:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ec0:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801ec5:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ecb:	83 ec 0c             	sub    $0xc,%esp
  801ece:	ff 75 e0             	pushl  -0x20(%ebp)
  801ed1:	e8 6b 05 00 00       	call   802441 <pageref>
  801ed6:	89 c3                	mov    %eax,%ebx
  801ed8:	89 3c 24             	mov    %edi,(%esp)
  801edb:	e8 61 05 00 00       	call   802441 <pageref>
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	39 c3                	cmp    %eax,%ebx
  801ee5:	0f 94 c1             	sete   %cl
  801ee8:	0f b6 c9             	movzbl %cl,%ecx
  801eeb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801eee:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801ef4:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  801efa:	39 ce                	cmp    %ecx,%esi
  801efc:	74 1e                	je     801f1c <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801efe:	39 c3                	cmp    %eax,%ebx
  801f00:	75 be                	jne    801ec0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f02:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  801f08:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f0b:	50                   	push   %eax
  801f0c:	56                   	push   %esi
  801f0d:	68 e2 2c 80 00       	push   $0x802ce2
  801f12:	e8 dc e7 ff ff       	call   8006f3 <cprintf>
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	eb a4                	jmp    801ec0 <_pipeisclosed+0xe>
	}
}
  801f1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5f                   	pop    %edi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	57                   	push   %edi
  801f2b:	56                   	push   %esi
  801f2c:	53                   	push   %ebx
  801f2d:	83 ec 28             	sub    $0x28,%esp
  801f30:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f33:	56                   	push   %esi
  801f34:	e8 06 f7 ff ff       	call   80163f <fd2data>
  801f39:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	bf 00 00 00 00       	mov    $0x0,%edi
  801f43:	eb 4b                	jmp    801f90 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f45:	89 da                	mov    %ebx,%edx
  801f47:	89 f0                	mov    %esi,%eax
  801f49:	e8 64 ff ff ff       	call   801eb2 <_pipeisclosed>
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	75 48                	jne    801f9a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f52:	e8 05 f1 ff ff       	call   80105c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f57:	8b 43 04             	mov    0x4(%ebx),%eax
  801f5a:	8b 0b                	mov    (%ebx),%ecx
  801f5c:	8d 51 20             	lea    0x20(%ecx),%edx
  801f5f:	39 d0                	cmp    %edx,%eax
  801f61:	73 e2                	jae    801f45 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f66:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f6a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f6d:	89 c2                	mov    %eax,%edx
  801f6f:	c1 fa 1f             	sar    $0x1f,%edx
  801f72:	89 d1                	mov    %edx,%ecx
  801f74:	c1 e9 1b             	shr    $0x1b,%ecx
  801f77:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f7a:	83 e2 1f             	and    $0x1f,%edx
  801f7d:	29 ca                	sub    %ecx,%edx
  801f7f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f83:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f87:	83 c0 01             	add    $0x1,%eax
  801f8a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8d:	83 c7 01             	add    $0x1,%edi
  801f90:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f93:	75 c2                	jne    801f57 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f95:	8b 45 10             	mov    0x10(%ebp),%eax
  801f98:	eb 05                	jmp    801f9f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f9a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa2:	5b                   	pop    %ebx
  801fa3:	5e                   	pop    %esi
  801fa4:	5f                   	pop    %edi
  801fa5:	5d                   	pop    %ebp
  801fa6:	c3                   	ret    

00801fa7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	57                   	push   %edi
  801fab:	56                   	push   %esi
  801fac:	53                   	push   %ebx
  801fad:	83 ec 18             	sub    $0x18,%esp
  801fb0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fb3:	57                   	push   %edi
  801fb4:	e8 86 f6 ff ff       	call   80163f <fd2data>
  801fb9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fbb:	83 c4 10             	add    $0x10,%esp
  801fbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc3:	eb 3d                	jmp    802002 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fc5:	85 db                	test   %ebx,%ebx
  801fc7:	74 04                	je     801fcd <devpipe_read+0x26>
				return i;
  801fc9:	89 d8                	mov    %ebx,%eax
  801fcb:	eb 44                	jmp    802011 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fcd:	89 f2                	mov    %esi,%edx
  801fcf:	89 f8                	mov    %edi,%eax
  801fd1:	e8 dc fe ff ff       	call   801eb2 <_pipeisclosed>
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	75 32                	jne    80200c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fda:	e8 7d f0 ff ff       	call   80105c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fdf:	8b 06                	mov    (%esi),%eax
  801fe1:	3b 46 04             	cmp    0x4(%esi),%eax
  801fe4:	74 df                	je     801fc5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fe6:	99                   	cltd   
  801fe7:	c1 ea 1b             	shr    $0x1b,%edx
  801fea:	01 d0                	add    %edx,%eax
  801fec:	83 e0 1f             	and    $0x1f,%eax
  801fef:	29 d0                	sub    %edx,%eax
  801ff1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ff6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ff9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ffc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fff:	83 c3 01             	add    $0x1,%ebx
  802002:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802005:	75 d8                	jne    801fdf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802007:	8b 45 10             	mov    0x10(%ebp),%eax
  80200a:	eb 05                	jmp    802011 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80200c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802011:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802014:	5b                   	pop    %ebx
  802015:	5e                   	pop    %esi
  802016:	5f                   	pop    %edi
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    

00802019 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	56                   	push   %esi
  80201d:	53                   	push   %ebx
  80201e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802021:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802024:	50                   	push   %eax
  802025:	e8 2c f6 ff ff       	call   801656 <fd_alloc>
  80202a:	83 c4 10             	add    $0x10,%esp
  80202d:	89 c2                	mov    %eax,%edx
  80202f:	85 c0                	test   %eax,%eax
  802031:	0f 88 2c 01 00 00    	js     802163 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802037:	83 ec 04             	sub    $0x4,%esp
  80203a:	68 07 04 00 00       	push   $0x407
  80203f:	ff 75 f4             	pushl  -0xc(%ebp)
  802042:	6a 00                	push   $0x0
  802044:	e8 32 f0 ff ff       	call   80107b <sys_page_alloc>
  802049:	83 c4 10             	add    $0x10,%esp
  80204c:	89 c2                	mov    %eax,%edx
  80204e:	85 c0                	test   %eax,%eax
  802050:	0f 88 0d 01 00 00    	js     802163 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802056:	83 ec 0c             	sub    $0xc,%esp
  802059:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80205c:	50                   	push   %eax
  80205d:	e8 f4 f5 ff ff       	call   801656 <fd_alloc>
  802062:	89 c3                	mov    %eax,%ebx
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	85 c0                	test   %eax,%eax
  802069:	0f 88 e2 00 00 00    	js     802151 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80206f:	83 ec 04             	sub    $0x4,%esp
  802072:	68 07 04 00 00       	push   $0x407
  802077:	ff 75 f0             	pushl  -0x10(%ebp)
  80207a:	6a 00                	push   $0x0
  80207c:	e8 fa ef ff ff       	call   80107b <sys_page_alloc>
  802081:	89 c3                	mov    %eax,%ebx
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	85 c0                	test   %eax,%eax
  802088:	0f 88 c3 00 00 00    	js     802151 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80208e:	83 ec 0c             	sub    $0xc,%esp
  802091:	ff 75 f4             	pushl  -0xc(%ebp)
  802094:	e8 a6 f5 ff ff       	call   80163f <fd2data>
  802099:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209b:	83 c4 0c             	add    $0xc,%esp
  80209e:	68 07 04 00 00       	push   $0x407
  8020a3:	50                   	push   %eax
  8020a4:	6a 00                	push   $0x0
  8020a6:	e8 d0 ef ff ff       	call   80107b <sys_page_alloc>
  8020ab:	89 c3                	mov    %eax,%ebx
  8020ad:	83 c4 10             	add    $0x10,%esp
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	0f 88 89 00 00 00    	js     802141 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b8:	83 ec 0c             	sub    $0xc,%esp
  8020bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8020be:	e8 7c f5 ff ff       	call   80163f <fd2data>
  8020c3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020ca:	50                   	push   %eax
  8020cb:	6a 00                	push   $0x0
  8020cd:	56                   	push   %esi
  8020ce:	6a 00                	push   $0x0
  8020d0:	e8 e9 ef ff ff       	call   8010be <sys_page_map>
  8020d5:	89 c3                	mov    %eax,%ebx
  8020d7:	83 c4 20             	add    $0x20,%esp
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	78 55                	js     802133 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020de:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020f3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020fc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802101:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802108:	83 ec 0c             	sub    $0xc,%esp
  80210b:	ff 75 f4             	pushl  -0xc(%ebp)
  80210e:	e8 1c f5 ff ff       	call   80162f <fd2num>
  802113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802116:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802118:	83 c4 04             	add    $0x4,%esp
  80211b:	ff 75 f0             	pushl  -0x10(%ebp)
  80211e:	e8 0c f5 ff ff       	call   80162f <fd2num>
  802123:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802126:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	ba 00 00 00 00       	mov    $0x0,%edx
  802131:	eb 30                	jmp    802163 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802133:	83 ec 08             	sub    $0x8,%esp
  802136:	56                   	push   %esi
  802137:	6a 00                	push   $0x0
  802139:	e8 c2 ef ff ff       	call   801100 <sys_page_unmap>
  80213e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802141:	83 ec 08             	sub    $0x8,%esp
  802144:	ff 75 f0             	pushl  -0x10(%ebp)
  802147:	6a 00                	push   $0x0
  802149:	e8 b2 ef ff ff       	call   801100 <sys_page_unmap>
  80214e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802151:	83 ec 08             	sub    $0x8,%esp
  802154:	ff 75 f4             	pushl  -0xc(%ebp)
  802157:	6a 00                	push   $0x0
  802159:	e8 a2 ef ff ff       	call   801100 <sys_page_unmap>
  80215e:	83 c4 10             	add    $0x10,%esp
  802161:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802163:	89 d0                	mov    %edx,%eax
  802165:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    

0080216c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802172:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802175:	50                   	push   %eax
  802176:	ff 75 08             	pushl  0x8(%ebp)
  802179:	e8 27 f5 ff ff       	call   8016a5 <fd_lookup>
  80217e:	83 c4 10             	add    $0x10,%esp
  802181:	85 c0                	test   %eax,%eax
  802183:	78 18                	js     80219d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802185:	83 ec 0c             	sub    $0xc,%esp
  802188:	ff 75 f4             	pushl  -0xc(%ebp)
  80218b:	e8 af f4 ff ff       	call   80163f <fd2data>
	return _pipeisclosed(fd, p);
  802190:	89 c2                	mov    %eax,%edx
  802192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802195:	e8 18 fd ff ff       	call   801eb2 <_pipeisclosed>
  80219a:	83 c4 10             	add    $0x10,%esp
}
  80219d:	c9                   	leave  
  80219e:	c3                   	ret    

0080219f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80219f:	55                   	push   %ebp
  8021a0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    

008021a9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021a9:	55                   	push   %ebp
  8021aa:	89 e5                	mov    %esp,%ebp
  8021ac:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021af:	68 fa 2c 80 00       	push   $0x802cfa
  8021b4:	ff 75 0c             	pushl  0xc(%ebp)
  8021b7:	e8 bc ea ff ff       	call   800c78 <strcpy>
	return 0;
}
  8021bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c1:	c9                   	leave  
  8021c2:	c3                   	ret    

008021c3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021c3:	55                   	push   %ebp
  8021c4:	89 e5                	mov    %esp,%ebp
  8021c6:	57                   	push   %edi
  8021c7:	56                   	push   %esi
  8021c8:	53                   	push   %ebx
  8021c9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021cf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021d4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021da:	eb 2d                	jmp    802209 <devcons_write+0x46>
		m = n - tot;
  8021dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021df:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021e1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021e4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021e9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ec:	83 ec 04             	sub    $0x4,%esp
  8021ef:	53                   	push   %ebx
  8021f0:	03 45 0c             	add    0xc(%ebp),%eax
  8021f3:	50                   	push   %eax
  8021f4:	57                   	push   %edi
  8021f5:	e8 10 ec ff ff       	call   800e0a <memmove>
		sys_cputs(buf, m);
  8021fa:	83 c4 08             	add    $0x8,%esp
  8021fd:	53                   	push   %ebx
  8021fe:	57                   	push   %edi
  8021ff:	e8 bb ed ff ff       	call   800fbf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802204:	01 de                	add    %ebx,%esi
  802206:	83 c4 10             	add    $0x10,%esp
  802209:	89 f0                	mov    %esi,%eax
  80220b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80220e:	72 cc                	jb     8021dc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    

00802218 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802218:	55                   	push   %ebp
  802219:	89 e5                	mov    %esp,%ebp
  80221b:	83 ec 08             	sub    $0x8,%esp
  80221e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802223:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802227:	74 2a                	je     802253 <devcons_read+0x3b>
  802229:	eb 05                	jmp    802230 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80222b:	e8 2c ee ff ff       	call   80105c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802230:	e8 a8 ed ff ff       	call   800fdd <sys_cgetc>
  802235:	85 c0                	test   %eax,%eax
  802237:	74 f2                	je     80222b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802239:	85 c0                	test   %eax,%eax
  80223b:	78 16                	js     802253 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80223d:	83 f8 04             	cmp    $0x4,%eax
  802240:	74 0c                	je     80224e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802242:	8b 55 0c             	mov    0xc(%ebp),%edx
  802245:	88 02                	mov    %al,(%edx)
	return 1;
  802247:	b8 01 00 00 00       	mov    $0x1,%eax
  80224c:	eb 05                	jmp    802253 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80224e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802253:	c9                   	leave  
  802254:	c3                   	ret    

00802255 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80225b:	8b 45 08             	mov    0x8(%ebp),%eax
  80225e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802261:	6a 01                	push   $0x1
  802263:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802266:	50                   	push   %eax
  802267:	e8 53 ed ff ff       	call   800fbf <sys_cputs>
}
  80226c:	83 c4 10             	add    $0x10,%esp
  80226f:	c9                   	leave  
  802270:	c3                   	ret    

00802271 <getchar>:

int
getchar(void)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802277:	6a 01                	push   $0x1
  802279:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80227c:	50                   	push   %eax
  80227d:	6a 00                	push   $0x0
  80227f:	e8 87 f6 ff ff       	call   80190b <read>
	if (r < 0)
  802284:	83 c4 10             	add    $0x10,%esp
  802287:	85 c0                	test   %eax,%eax
  802289:	78 0f                	js     80229a <getchar+0x29>
		return r;
	if (r < 1)
  80228b:	85 c0                	test   %eax,%eax
  80228d:	7e 06                	jle    802295 <getchar+0x24>
		return -E_EOF;
	return c;
  80228f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802293:	eb 05                	jmp    80229a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802295:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80229a:	c9                   	leave  
  80229b:	c3                   	ret    

0080229c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a5:	50                   	push   %eax
  8022a6:	ff 75 08             	pushl  0x8(%ebp)
  8022a9:	e8 f7 f3 ff ff       	call   8016a5 <fd_lookup>
  8022ae:	83 c4 10             	add    $0x10,%esp
  8022b1:	85 c0                	test   %eax,%eax
  8022b3:	78 11                	js     8022c6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022be:	39 10                	cmp    %edx,(%eax)
  8022c0:	0f 94 c0             	sete   %al
  8022c3:	0f b6 c0             	movzbl %al,%eax
}
  8022c6:	c9                   	leave  
  8022c7:	c3                   	ret    

008022c8 <opencons>:

int
opencons(void)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d1:	50                   	push   %eax
  8022d2:	e8 7f f3 ff ff       	call   801656 <fd_alloc>
  8022d7:	83 c4 10             	add    $0x10,%esp
		return r;
  8022da:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022dc:	85 c0                	test   %eax,%eax
  8022de:	78 3e                	js     80231e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022e0:	83 ec 04             	sub    $0x4,%esp
  8022e3:	68 07 04 00 00       	push   $0x407
  8022e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8022eb:	6a 00                	push   $0x0
  8022ed:	e8 89 ed ff ff       	call   80107b <sys_page_alloc>
  8022f2:	83 c4 10             	add    $0x10,%esp
		return r;
  8022f5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	78 23                	js     80231e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022fb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802301:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802304:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802306:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802309:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802310:	83 ec 0c             	sub    $0xc,%esp
  802313:	50                   	push   %eax
  802314:	e8 16 f3 ff ff       	call   80162f <fd2num>
  802319:	89 c2                	mov    %eax,%edx
  80231b:	83 c4 10             	add    $0x10,%esp
}
  80231e:	89 d0                	mov    %edx,%eax
  802320:	c9                   	leave  
  802321:	c3                   	ret    

00802322 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802322:	55                   	push   %ebp
  802323:	89 e5                	mov    %esp,%ebp
  802325:	56                   	push   %esi
  802326:	53                   	push   %ebx
  802327:	8b 75 08             	mov    0x8(%ebp),%esi
  80232a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80232d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802330:	85 c0                	test   %eax,%eax
  802332:	75 12                	jne    802346 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802334:	83 ec 0c             	sub    $0xc,%esp
  802337:	68 00 00 c0 ee       	push   $0xeec00000
  80233c:	e8 ea ee ff ff       	call   80122b <sys_ipc_recv>
  802341:	83 c4 10             	add    $0x10,%esp
  802344:	eb 0c                	jmp    802352 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802346:	83 ec 0c             	sub    $0xc,%esp
  802349:	50                   	push   %eax
  80234a:	e8 dc ee ff ff       	call   80122b <sys_ipc_recv>
  80234f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802352:	85 f6                	test   %esi,%esi
  802354:	0f 95 c1             	setne  %cl
  802357:	85 db                	test   %ebx,%ebx
  802359:	0f 95 c2             	setne  %dl
  80235c:	84 d1                	test   %dl,%cl
  80235e:	74 09                	je     802369 <ipc_recv+0x47>
  802360:	89 c2                	mov    %eax,%edx
  802362:	c1 ea 1f             	shr    $0x1f,%edx
  802365:	84 d2                	test   %dl,%dl
  802367:	75 2d                	jne    802396 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802369:	85 f6                	test   %esi,%esi
  80236b:	74 0d                	je     80237a <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80236d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802372:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  802378:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80237a:	85 db                	test   %ebx,%ebx
  80237c:	74 0d                	je     80238b <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80237e:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802383:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  802389:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80238b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802390:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  802396:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802399:	5b                   	pop    %ebx
  80239a:	5e                   	pop    %esi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    

0080239d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80239d:	55                   	push   %ebp
  80239e:	89 e5                	mov    %esp,%ebp
  8023a0:	57                   	push   %edi
  8023a1:	56                   	push   %esi
  8023a2:	53                   	push   %ebx
  8023a3:	83 ec 0c             	sub    $0xc,%esp
  8023a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8023af:	85 db                	test   %ebx,%ebx
  8023b1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023b6:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8023b9:	ff 75 14             	pushl  0x14(%ebp)
  8023bc:	53                   	push   %ebx
  8023bd:	56                   	push   %esi
  8023be:	57                   	push   %edi
  8023bf:	e8 44 ee ff ff       	call   801208 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8023c4:	89 c2                	mov    %eax,%edx
  8023c6:	c1 ea 1f             	shr    $0x1f,%edx
  8023c9:	83 c4 10             	add    $0x10,%esp
  8023cc:	84 d2                	test   %dl,%dl
  8023ce:	74 17                	je     8023e7 <ipc_send+0x4a>
  8023d0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023d3:	74 12                	je     8023e7 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8023d5:	50                   	push   %eax
  8023d6:	68 06 2d 80 00       	push   $0x802d06
  8023db:	6a 47                	push   $0x47
  8023dd:	68 14 2d 80 00       	push   $0x802d14
  8023e2:	e8 33 e2 ff ff       	call   80061a <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8023e7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023ea:	75 07                	jne    8023f3 <ipc_send+0x56>
			sys_yield();
  8023ec:	e8 6b ec ff ff       	call   80105c <sys_yield>
  8023f1:	eb c6                	jmp    8023b9 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8023f3:	85 c0                	test   %eax,%eax
  8023f5:	75 c2                	jne    8023b9 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8023f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023fa:	5b                   	pop    %ebx
  8023fb:	5e                   	pop    %esi
  8023fc:	5f                   	pop    %edi
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    

008023ff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802405:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80240a:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  802410:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802416:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80241c:	39 ca                	cmp    %ecx,%edx
  80241e:	75 10                	jne    802430 <ipc_find_env+0x31>
			return envs[i].env_id;
  802420:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  802426:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80242b:	8b 40 7c             	mov    0x7c(%eax),%eax
  80242e:	eb 0f                	jmp    80243f <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802430:	83 c0 01             	add    $0x1,%eax
  802433:	3d 00 04 00 00       	cmp    $0x400,%eax
  802438:	75 d0                	jne    80240a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80243a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80243f:	5d                   	pop    %ebp
  802440:	c3                   	ret    

00802441 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802441:	55                   	push   %ebp
  802442:	89 e5                	mov    %esp,%ebp
  802444:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802447:	89 d0                	mov    %edx,%eax
  802449:	c1 e8 16             	shr    $0x16,%eax
  80244c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802453:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802458:	f6 c1 01             	test   $0x1,%cl
  80245b:	74 1d                	je     80247a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80245d:	c1 ea 0c             	shr    $0xc,%edx
  802460:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802467:	f6 c2 01             	test   $0x1,%dl
  80246a:	74 0e                	je     80247a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80246c:	c1 ea 0c             	shr    $0xc,%edx
  80246f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802476:	ef 
  802477:	0f b7 c0             	movzwl %ax,%eax
}
  80247a:	5d                   	pop    %ebp
  80247b:	c3                   	ret    
  80247c:	66 90                	xchg   %ax,%ax
  80247e:	66 90                	xchg   %ax,%ax

00802480 <__udivdi3>:
  802480:	55                   	push   %ebp
  802481:	57                   	push   %edi
  802482:	56                   	push   %esi
  802483:	53                   	push   %ebx
  802484:	83 ec 1c             	sub    $0x1c,%esp
  802487:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80248b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80248f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802493:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802497:	85 f6                	test   %esi,%esi
  802499:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80249d:	89 ca                	mov    %ecx,%edx
  80249f:	89 f8                	mov    %edi,%eax
  8024a1:	75 3d                	jne    8024e0 <__udivdi3+0x60>
  8024a3:	39 cf                	cmp    %ecx,%edi
  8024a5:	0f 87 c5 00 00 00    	ja     802570 <__udivdi3+0xf0>
  8024ab:	85 ff                	test   %edi,%edi
  8024ad:	89 fd                	mov    %edi,%ebp
  8024af:	75 0b                	jne    8024bc <__udivdi3+0x3c>
  8024b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b6:	31 d2                	xor    %edx,%edx
  8024b8:	f7 f7                	div    %edi
  8024ba:	89 c5                	mov    %eax,%ebp
  8024bc:	89 c8                	mov    %ecx,%eax
  8024be:	31 d2                	xor    %edx,%edx
  8024c0:	f7 f5                	div    %ebp
  8024c2:	89 c1                	mov    %eax,%ecx
  8024c4:	89 d8                	mov    %ebx,%eax
  8024c6:	89 cf                	mov    %ecx,%edi
  8024c8:	f7 f5                	div    %ebp
  8024ca:	89 c3                	mov    %eax,%ebx
  8024cc:	89 d8                	mov    %ebx,%eax
  8024ce:	89 fa                	mov    %edi,%edx
  8024d0:	83 c4 1c             	add    $0x1c,%esp
  8024d3:	5b                   	pop    %ebx
  8024d4:	5e                   	pop    %esi
  8024d5:	5f                   	pop    %edi
  8024d6:	5d                   	pop    %ebp
  8024d7:	c3                   	ret    
  8024d8:	90                   	nop
  8024d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	39 ce                	cmp    %ecx,%esi
  8024e2:	77 74                	ja     802558 <__udivdi3+0xd8>
  8024e4:	0f bd fe             	bsr    %esi,%edi
  8024e7:	83 f7 1f             	xor    $0x1f,%edi
  8024ea:	0f 84 98 00 00 00    	je     802588 <__udivdi3+0x108>
  8024f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024f5:	89 f9                	mov    %edi,%ecx
  8024f7:	89 c5                	mov    %eax,%ebp
  8024f9:	29 fb                	sub    %edi,%ebx
  8024fb:	d3 e6                	shl    %cl,%esi
  8024fd:	89 d9                	mov    %ebx,%ecx
  8024ff:	d3 ed                	shr    %cl,%ebp
  802501:	89 f9                	mov    %edi,%ecx
  802503:	d3 e0                	shl    %cl,%eax
  802505:	09 ee                	or     %ebp,%esi
  802507:	89 d9                	mov    %ebx,%ecx
  802509:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80250d:	89 d5                	mov    %edx,%ebp
  80250f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802513:	d3 ed                	shr    %cl,%ebp
  802515:	89 f9                	mov    %edi,%ecx
  802517:	d3 e2                	shl    %cl,%edx
  802519:	89 d9                	mov    %ebx,%ecx
  80251b:	d3 e8                	shr    %cl,%eax
  80251d:	09 c2                	or     %eax,%edx
  80251f:	89 d0                	mov    %edx,%eax
  802521:	89 ea                	mov    %ebp,%edx
  802523:	f7 f6                	div    %esi
  802525:	89 d5                	mov    %edx,%ebp
  802527:	89 c3                	mov    %eax,%ebx
  802529:	f7 64 24 0c          	mull   0xc(%esp)
  80252d:	39 d5                	cmp    %edx,%ebp
  80252f:	72 10                	jb     802541 <__udivdi3+0xc1>
  802531:	8b 74 24 08          	mov    0x8(%esp),%esi
  802535:	89 f9                	mov    %edi,%ecx
  802537:	d3 e6                	shl    %cl,%esi
  802539:	39 c6                	cmp    %eax,%esi
  80253b:	73 07                	jae    802544 <__udivdi3+0xc4>
  80253d:	39 d5                	cmp    %edx,%ebp
  80253f:	75 03                	jne    802544 <__udivdi3+0xc4>
  802541:	83 eb 01             	sub    $0x1,%ebx
  802544:	31 ff                	xor    %edi,%edi
  802546:	89 d8                	mov    %ebx,%eax
  802548:	89 fa                	mov    %edi,%edx
  80254a:	83 c4 1c             	add    $0x1c,%esp
  80254d:	5b                   	pop    %ebx
  80254e:	5e                   	pop    %esi
  80254f:	5f                   	pop    %edi
  802550:	5d                   	pop    %ebp
  802551:	c3                   	ret    
  802552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802558:	31 ff                	xor    %edi,%edi
  80255a:	31 db                	xor    %ebx,%ebx
  80255c:	89 d8                	mov    %ebx,%eax
  80255e:	89 fa                	mov    %edi,%edx
  802560:	83 c4 1c             	add    $0x1c,%esp
  802563:	5b                   	pop    %ebx
  802564:	5e                   	pop    %esi
  802565:	5f                   	pop    %edi
  802566:	5d                   	pop    %ebp
  802567:	c3                   	ret    
  802568:	90                   	nop
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	89 d8                	mov    %ebx,%eax
  802572:	f7 f7                	div    %edi
  802574:	31 ff                	xor    %edi,%edi
  802576:	89 c3                	mov    %eax,%ebx
  802578:	89 d8                	mov    %ebx,%eax
  80257a:	89 fa                	mov    %edi,%edx
  80257c:	83 c4 1c             	add    $0x1c,%esp
  80257f:	5b                   	pop    %ebx
  802580:	5e                   	pop    %esi
  802581:	5f                   	pop    %edi
  802582:	5d                   	pop    %ebp
  802583:	c3                   	ret    
  802584:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802588:	39 ce                	cmp    %ecx,%esi
  80258a:	72 0c                	jb     802598 <__udivdi3+0x118>
  80258c:	31 db                	xor    %ebx,%ebx
  80258e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802592:	0f 87 34 ff ff ff    	ja     8024cc <__udivdi3+0x4c>
  802598:	bb 01 00 00 00       	mov    $0x1,%ebx
  80259d:	e9 2a ff ff ff       	jmp    8024cc <__udivdi3+0x4c>
  8025a2:	66 90                	xchg   %ax,%ax
  8025a4:	66 90                	xchg   %ax,%ax
  8025a6:	66 90                	xchg   %ax,%ax
  8025a8:	66 90                	xchg   %ax,%ax
  8025aa:	66 90                	xchg   %ax,%ax
  8025ac:	66 90                	xchg   %ax,%ax
  8025ae:	66 90                	xchg   %ax,%ax

008025b0 <__umoddi3>:
  8025b0:	55                   	push   %ebp
  8025b1:	57                   	push   %edi
  8025b2:	56                   	push   %esi
  8025b3:	53                   	push   %ebx
  8025b4:	83 ec 1c             	sub    $0x1c,%esp
  8025b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025c7:	85 d2                	test   %edx,%edx
  8025c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025d1:	89 f3                	mov    %esi,%ebx
  8025d3:	89 3c 24             	mov    %edi,(%esp)
  8025d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025da:	75 1c                	jne    8025f8 <__umoddi3+0x48>
  8025dc:	39 f7                	cmp    %esi,%edi
  8025de:	76 50                	jbe    802630 <__umoddi3+0x80>
  8025e0:	89 c8                	mov    %ecx,%eax
  8025e2:	89 f2                	mov    %esi,%edx
  8025e4:	f7 f7                	div    %edi
  8025e6:	89 d0                	mov    %edx,%eax
  8025e8:	31 d2                	xor    %edx,%edx
  8025ea:	83 c4 1c             	add    $0x1c,%esp
  8025ed:	5b                   	pop    %ebx
  8025ee:	5e                   	pop    %esi
  8025ef:	5f                   	pop    %edi
  8025f0:	5d                   	pop    %ebp
  8025f1:	c3                   	ret    
  8025f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025f8:	39 f2                	cmp    %esi,%edx
  8025fa:	89 d0                	mov    %edx,%eax
  8025fc:	77 52                	ja     802650 <__umoddi3+0xa0>
  8025fe:	0f bd ea             	bsr    %edx,%ebp
  802601:	83 f5 1f             	xor    $0x1f,%ebp
  802604:	75 5a                	jne    802660 <__umoddi3+0xb0>
  802606:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80260a:	0f 82 e0 00 00 00    	jb     8026f0 <__umoddi3+0x140>
  802610:	39 0c 24             	cmp    %ecx,(%esp)
  802613:	0f 86 d7 00 00 00    	jbe    8026f0 <__umoddi3+0x140>
  802619:	8b 44 24 08          	mov    0x8(%esp),%eax
  80261d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802621:	83 c4 1c             	add    $0x1c,%esp
  802624:	5b                   	pop    %ebx
  802625:	5e                   	pop    %esi
  802626:	5f                   	pop    %edi
  802627:	5d                   	pop    %ebp
  802628:	c3                   	ret    
  802629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802630:	85 ff                	test   %edi,%edi
  802632:	89 fd                	mov    %edi,%ebp
  802634:	75 0b                	jne    802641 <__umoddi3+0x91>
  802636:	b8 01 00 00 00       	mov    $0x1,%eax
  80263b:	31 d2                	xor    %edx,%edx
  80263d:	f7 f7                	div    %edi
  80263f:	89 c5                	mov    %eax,%ebp
  802641:	89 f0                	mov    %esi,%eax
  802643:	31 d2                	xor    %edx,%edx
  802645:	f7 f5                	div    %ebp
  802647:	89 c8                	mov    %ecx,%eax
  802649:	f7 f5                	div    %ebp
  80264b:	89 d0                	mov    %edx,%eax
  80264d:	eb 99                	jmp    8025e8 <__umoddi3+0x38>
  80264f:	90                   	nop
  802650:	89 c8                	mov    %ecx,%eax
  802652:	89 f2                	mov    %esi,%edx
  802654:	83 c4 1c             	add    $0x1c,%esp
  802657:	5b                   	pop    %ebx
  802658:	5e                   	pop    %esi
  802659:	5f                   	pop    %edi
  80265a:	5d                   	pop    %ebp
  80265b:	c3                   	ret    
  80265c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802660:	8b 34 24             	mov    (%esp),%esi
  802663:	bf 20 00 00 00       	mov    $0x20,%edi
  802668:	89 e9                	mov    %ebp,%ecx
  80266a:	29 ef                	sub    %ebp,%edi
  80266c:	d3 e0                	shl    %cl,%eax
  80266e:	89 f9                	mov    %edi,%ecx
  802670:	89 f2                	mov    %esi,%edx
  802672:	d3 ea                	shr    %cl,%edx
  802674:	89 e9                	mov    %ebp,%ecx
  802676:	09 c2                	or     %eax,%edx
  802678:	89 d8                	mov    %ebx,%eax
  80267a:	89 14 24             	mov    %edx,(%esp)
  80267d:	89 f2                	mov    %esi,%edx
  80267f:	d3 e2                	shl    %cl,%edx
  802681:	89 f9                	mov    %edi,%ecx
  802683:	89 54 24 04          	mov    %edx,0x4(%esp)
  802687:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80268b:	d3 e8                	shr    %cl,%eax
  80268d:	89 e9                	mov    %ebp,%ecx
  80268f:	89 c6                	mov    %eax,%esi
  802691:	d3 e3                	shl    %cl,%ebx
  802693:	89 f9                	mov    %edi,%ecx
  802695:	89 d0                	mov    %edx,%eax
  802697:	d3 e8                	shr    %cl,%eax
  802699:	89 e9                	mov    %ebp,%ecx
  80269b:	09 d8                	or     %ebx,%eax
  80269d:	89 d3                	mov    %edx,%ebx
  80269f:	89 f2                	mov    %esi,%edx
  8026a1:	f7 34 24             	divl   (%esp)
  8026a4:	89 d6                	mov    %edx,%esi
  8026a6:	d3 e3                	shl    %cl,%ebx
  8026a8:	f7 64 24 04          	mull   0x4(%esp)
  8026ac:	39 d6                	cmp    %edx,%esi
  8026ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026b2:	89 d1                	mov    %edx,%ecx
  8026b4:	89 c3                	mov    %eax,%ebx
  8026b6:	72 08                	jb     8026c0 <__umoddi3+0x110>
  8026b8:	75 11                	jne    8026cb <__umoddi3+0x11b>
  8026ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026be:	73 0b                	jae    8026cb <__umoddi3+0x11b>
  8026c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026c4:	1b 14 24             	sbb    (%esp),%edx
  8026c7:	89 d1                	mov    %edx,%ecx
  8026c9:	89 c3                	mov    %eax,%ebx
  8026cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026cf:	29 da                	sub    %ebx,%edx
  8026d1:	19 ce                	sbb    %ecx,%esi
  8026d3:	89 f9                	mov    %edi,%ecx
  8026d5:	89 f0                	mov    %esi,%eax
  8026d7:	d3 e0                	shl    %cl,%eax
  8026d9:	89 e9                	mov    %ebp,%ecx
  8026db:	d3 ea                	shr    %cl,%edx
  8026dd:	89 e9                	mov    %ebp,%ecx
  8026df:	d3 ee                	shr    %cl,%esi
  8026e1:	09 d0                	or     %edx,%eax
  8026e3:	89 f2                	mov    %esi,%edx
  8026e5:	83 c4 1c             	add    $0x1c,%esp
  8026e8:	5b                   	pop    %ebx
  8026e9:	5e                   	pop    %esi
  8026ea:	5f                   	pop    %edi
  8026eb:	5d                   	pop    %ebp
  8026ec:	c3                   	ret    
  8026ed:	8d 76 00             	lea    0x0(%esi),%esi
  8026f0:	29 f9                	sub    %edi,%ecx
  8026f2:	19 d6                	sbb    %edx,%esi
  8026f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026fc:	e9 18 ff ff ff       	jmp    802619 <__umoddi3+0x69>
