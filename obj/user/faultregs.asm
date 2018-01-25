
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
  800044:	68 31 27 80 00       	push   $0x802731
  800049:	68 00 27 80 00       	push   $0x802700
  80004e:	e8 a1 06 00 00       	call   8006f4 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 10 27 80 00       	push   $0x802710
  80005c:	68 14 27 80 00       	push   $0x802714
  800061:	e8 8e 06 00 00       	call   8006f4 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 24 27 80 00       	push   $0x802724
  800077:	e8 78 06 00 00       	call   8006f4 <cprintf>
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
  800089:	68 28 27 80 00       	push   $0x802728
  80008e:	e8 61 06 00 00       	call   8006f4 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 32 27 80 00       	push   $0x802732
  8000a6:	68 14 27 80 00       	push   $0x802714
  8000ab:	e8 44 06 00 00       	call   8006f4 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 24 27 80 00       	push   $0x802724
  8000c3:	e8 2c 06 00 00       	call   8006f4 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 28 27 80 00       	push   $0x802728
  8000d5:	e8 1a 06 00 00       	call   8006f4 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 36 27 80 00       	push   $0x802736
  8000ed:	68 14 27 80 00       	push   $0x802714
  8000f2:	e8 fd 05 00 00       	call   8006f4 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 24 27 80 00       	push   $0x802724
  80010a:	e8 e5 05 00 00       	call   8006f4 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 28 27 80 00       	push   $0x802728
  80011c:	e8 d3 05 00 00       	call   8006f4 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 3a 27 80 00       	push   $0x80273a
  800134:	68 14 27 80 00       	push   $0x802714
  800139:	e8 b6 05 00 00       	call   8006f4 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 24 27 80 00       	push   $0x802724
  800151:	e8 9e 05 00 00       	call   8006f4 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 28 27 80 00       	push   $0x802728
  800163:	e8 8c 05 00 00       	call   8006f4 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 3e 27 80 00       	push   $0x80273e
  80017b:	68 14 27 80 00       	push   $0x802714
  800180:	e8 6f 05 00 00       	call   8006f4 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 24 27 80 00       	push   $0x802724
  800198:	e8 57 05 00 00       	call   8006f4 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 28 27 80 00       	push   $0x802728
  8001aa:	e8 45 05 00 00       	call   8006f4 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 42 27 80 00       	push   $0x802742
  8001c2:	68 14 27 80 00       	push   $0x802714
  8001c7:	e8 28 05 00 00       	call   8006f4 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 24 27 80 00       	push   $0x802724
  8001df:	e8 10 05 00 00       	call   8006f4 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 28 27 80 00       	push   $0x802728
  8001f1:	e8 fe 04 00 00       	call   8006f4 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 46 27 80 00       	push   $0x802746
  800209:	68 14 27 80 00       	push   $0x802714
  80020e:	e8 e1 04 00 00       	call   8006f4 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 24 27 80 00       	push   $0x802724
  800226:	e8 c9 04 00 00       	call   8006f4 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 28 27 80 00       	push   $0x802728
  800238:	e8 b7 04 00 00       	call   8006f4 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 4a 27 80 00       	push   $0x80274a
  800250:	68 14 27 80 00       	push   $0x802714
  800255:	e8 9a 04 00 00       	call   8006f4 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 24 27 80 00       	push   $0x802724
  80026d:	e8 82 04 00 00       	call   8006f4 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 28 27 80 00       	push   $0x802728
  80027f:	e8 70 04 00 00       	call   8006f4 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 4e 27 80 00       	push   $0x80274e
  800297:	68 14 27 80 00       	push   $0x802714
  80029c:	e8 53 04 00 00       	call   8006f4 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 24 27 80 00       	push   $0x802724
  8002b4:	e8 3b 04 00 00       	call   8006f4 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 55 27 80 00       	push   $0x802755
  8002c4:	68 14 27 80 00       	push   $0x802714
  8002c9:	e8 26 04 00 00       	call   8006f4 <cprintf>
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
  8002de:	68 28 27 80 00       	push   $0x802728
  8002e3:	e8 0c 04 00 00       	call   8006f4 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 55 27 80 00       	push   $0x802755
  8002f3:	68 14 27 80 00       	push   $0x802714
  8002f8:	e8 f7 03 00 00       	call   8006f4 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 24 27 80 00       	push   $0x802724
  800312:	e8 dd 03 00 00       	call   8006f4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 59 27 80 00       	push   $0x802759
  800322:	e8 cd 03 00 00       	call   8006f4 <cprintf>
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
  800333:	68 28 27 80 00       	push   $0x802728
  800338:	e8 b7 03 00 00       	call   8006f4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 59 27 80 00       	push   $0x802759
  800348:	e8 a7 03 00 00       	call   8006f4 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 24 27 80 00       	push   $0x802724
  80035a:	e8 95 03 00 00       	call   8006f4 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 28 27 80 00       	push   $0x802728
  80036c:	e8 83 03 00 00       	call   8006f4 <cprintf>
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
  800379:	68 24 27 80 00       	push   $0x802724
  80037e:	e8 71 03 00 00       	call   8006f4 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 59 27 80 00       	push   $0x802759
  80038e:	e8 61 03 00 00       	call   8006f4 <cprintf>
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
  8003ba:	68 c0 27 80 00       	push   $0x8027c0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 67 27 80 00       	push   $0x802767
  8003c6:	e8 50 02 00 00       	call   80061b <_panic>
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
  800436:	68 7f 27 80 00       	push   $0x80277f
  80043b:	68 8d 27 80 00       	push   $0x80278d
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba 78 27 80 00       	mov    $0x802778,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 17 0c 00 00       	call   80107c <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 94 27 80 00       	push   $0x802794
  800472:	6a 5c                	push   $0x5c
  800474:	68 67 27 80 00       	push   $0x802767
  800479:	e8 9d 01 00 00       	call   80061b <_panic>
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
  80048b:	e8 1d 0e 00 00       	call   8012ad <set_pgfault_handler>

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
  80055a:	68 f4 27 80 00       	push   $0x8027f4
  80055f:	e8 90 01 00 00       	call   8006f4 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 a7 27 80 00       	push   $0x8027a7
  800579:	68 b8 27 80 00       	push   $0x8027b8
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba 78 27 80 00       	mov    $0x802778,%edx
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
  8005a2:	e8 97 0a 00 00       	call   80103e <sys_getenvid>
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	89 c2                	mov    %eax,%edx
  8005ae:	c1 e2 07             	shl    $0x7,%edx
  8005b1:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8005b8:	a3 b0 40 80 00       	mov    %eax,0x8040b0
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005bd:	85 db                	test   %ebx,%ebx
  8005bf:	7e 07                	jle    8005c8 <libmain+0x31>
		binaryname = argv[0];
  8005c1:	8b 06                	mov    (%esi),%eax
  8005c3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	56                   	push   %esi
  8005cc:	53                   	push   %ebx
  8005cd:	e8 ae fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  8005d2:	e8 2a 00 00 00       	call   800601 <exit>
}
  8005d7:	83 c4 10             	add    $0x10,%esp
  8005da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005dd:	5b                   	pop    %ebx
  8005de:	5e                   	pop    %esi
  8005df:	5d                   	pop    %ebp
  8005e0:	c3                   	ret    

008005e1 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8005e7:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	func();
  8005ec:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8005ee:	e8 4b 0a 00 00       	call   80103e <sys_getenvid>
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	50                   	push   %eax
  8005f7:	e8 91 0c 00 00       	call   80128d <sys_thread_free>
}
  8005fc:	83 c4 10             	add    $0x10,%esp
  8005ff:	c9                   	leave  
  800600:	c3                   	ret    

00800601 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800601:	55                   	push   %ebp
  800602:	89 e5                	mov    %esp,%ebp
  800604:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800607:	e8 ed 11 00 00       	call   8017f9 <close_all>
	sys_env_destroy(0);
  80060c:	83 ec 0c             	sub    $0xc,%esp
  80060f:	6a 00                	push   $0x0
  800611:	e8 e7 09 00 00       	call   800ffd <sys_env_destroy>
}
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	c9                   	leave  
  80061a:	c3                   	ret    

0080061b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80061b:	55                   	push   %ebp
  80061c:	89 e5                	mov    %esp,%ebp
  80061e:	56                   	push   %esi
  80061f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800620:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800623:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800629:	e8 10 0a 00 00       	call   80103e <sys_getenvid>
  80062e:	83 ec 0c             	sub    $0xc,%esp
  800631:	ff 75 0c             	pushl  0xc(%ebp)
  800634:	ff 75 08             	pushl  0x8(%ebp)
  800637:	56                   	push   %esi
  800638:	50                   	push   %eax
  800639:	68 20 28 80 00       	push   $0x802820
  80063e:	e8 b1 00 00 00       	call   8006f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800643:	83 c4 18             	add    $0x18,%esp
  800646:	53                   	push   %ebx
  800647:	ff 75 10             	pushl  0x10(%ebp)
  80064a:	e8 54 00 00 00       	call   8006a3 <vcprintf>
	cprintf("\n");
  80064f:	c7 04 24 30 27 80 00 	movl   $0x802730,(%esp)
  800656:	e8 99 00 00 00       	call   8006f4 <cprintf>
  80065b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80065e:	cc                   	int3   
  80065f:	eb fd                	jmp    80065e <_panic+0x43>

00800661 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	53                   	push   %ebx
  800665:	83 ec 04             	sub    $0x4,%esp
  800668:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80066b:	8b 13                	mov    (%ebx),%edx
  80066d:	8d 42 01             	lea    0x1(%edx),%eax
  800670:	89 03                	mov    %eax,(%ebx)
  800672:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800675:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800679:	3d ff 00 00 00       	cmp    $0xff,%eax
  80067e:	75 1a                	jne    80069a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	68 ff 00 00 00       	push   $0xff
  800688:	8d 43 08             	lea    0x8(%ebx),%eax
  80068b:	50                   	push   %eax
  80068c:	e8 2f 09 00 00       	call   800fc0 <sys_cputs>
		b->idx = 0;
  800691:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800697:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80069a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80069e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a1:	c9                   	leave  
  8006a2:	c3                   	ret    

008006a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006b3:	00 00 00 
	b.cnt = 0;
  8006b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006c0:	ff 75 0c             	pushl  0xc(%ebp)
  8006c3:	ff 75 08             	pushl  0x8(%ebp)
  8006c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006cc:	50                   	push   %eax
  8006cd:	68 61 06 80 00       	push   $0x800661
  8006d2:	e8 54 01 00 00       	call   80082b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006d7:	83 c4 08             	add    $0x8,%esp
  8006da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006e6:	50                   	push   %eax
  8006e7:	e8 d4 08 00 00       	call   800fc0 <sys_cputs>

	return b.cnt;
}
  8006ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006fd:	50                   	push   %eax
  8006fe:	ff 75 08             	pushl  0x8(%ebp)
  800701:	e8 9d ff ff ff       	call   8006a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800706:	c9                   	leave  
  800707:	c3                   	ret    

00800708 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	57                   	push   %edi
  80070c:	56                   	push   %esi
  80070d:	53                   	push   %ebx
  80070e:	83 ec 1c             	sub    $0x1c,%esp
  800711:	89 c7                	mov    %eax,%edi
  800713:	89 d6                	mov    %edx,%esi
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	8b 55 0c             	mov    0xc(%ebp),%edx
  80071b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800721:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800724:	bb 00 00 00 00       	mov    $0x0,%ebx
  800729:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80072c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80072f:	39 d3                	cmp    %edx,%ebx
  800731:	72 05                	jb     800738 <printnum+0x30>
  800733:	39 45 10             	cmp    %eax,0x10(%ebp)
  800736:	77 45                	ja     80077d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800738:	83 ec 0c             	sub    $0xc,%esp
  80073b:	ff 75 18             	pushl  0x18(%ebp)
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800744:	53                   	push   %ebx
  800745:	ff 75 10             	pushl  0x10(%ebp)
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80074e:	ff 75 e0             	pushl  -0x20(%ebp)
  800751:	ff 75 dc             	pushl  -0x24(%ebp)
  800754:	ff 75 d8             	pushl  -0x28(%ebp)
  800757:	e8 14 1d 00 00       	call   802470 <__udivdi3>
  80075c:	83 c4 18             	add    $0x18,%esp
  80075f:	52                   	push   %edx
  800760:	50                   	push   %eax
  800761:	89 f2                	mov    %esi,%edx
  800763:	89 f8                	mov    %edi,%eax
  800765:	e8 9e ff ff ff       	call   800708 <printnum>
  80076a:	83 c4 20             	add    $0x20,%esp
  80076d:	eb 18                	jmp    800787 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	56                   	push   %esi
  800773:	ff 75 18             	pushl  0x18(%ebp)
  800776:	ff d7                	call   *%edi
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 03                	jmp    800780 <printnum+0x78>
  80077d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800780:	83 eb 01             	sub    $0x1,%ebx
  800783:	85 db                	test   %ebx,%ebx
  800785:	7f e8                	jg     80076f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	56                   	push   %esi
  80078b:	83 ec 04             	sub    $0x4,%esp
  80078e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800791:	ff 75 e0             	pushl  -0x20(%ebp)
  800794:	ff 75 dc             	pushl  -0x24(%ebp)
  800797:	ff 75 d8             	pushl  -0x28(%ebp)
  80079a:	e8 01 1e 00 00       	call   8025a0 <__umoddi3>
  80079f:	83 c4 14             	add    $0x14,%esp
  8007a2:	0f be 80 43 28 80 00 	movsbl 0x802843(%eax),%eax
  8007a9:	50                   	push   %eax
  8007aa:	ff d7                	call   *%edi
}
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b2:	5b                   	pop    %ebx
  8007b3:	5e                   	pop    %esi
  8007b4:	5f                   	pop    %edi
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007ba:	83 fa 01             	cmp    $0x1,%edx
  8007bd:	7e 0e                	jle    8007cd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007bf:	8b 10                	mov    (%eax),%edx
  8007c1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007c4:	89 08                	mov    %ecx,(%eax)
  8007c6:	8b 02                	mov    (%edx),%eax
  8007c8:	8b 52 04             	mov    0x4(%edx),%edx
  8007cb:	eb 22                	jmp    8007ef <getuint+0x38>
	else if (lflag)
  8007cd:	85 d2                	test   %edx,%edx
  8007cf:	74 10                	je     8007e1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007d1:	8b 10                	mov    (%eax),%edx
  8007d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007d6:	89 08                	mov    %ecx,(%eax)
  8007d8:	8b 02                	mov    (%edx),%eax
  8007da:	ba 00 00 00 00       	mov    $0x0,%edx
  8007df:	eb 0e                	jmp    8007ef <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007e1:	8b 10                	mov    (%eax),%edx
  8007e3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007e6:	89 08                	mov    %ecx,(%eax)
  8007e8:	8b 02                	mov    (%edx),%eax
  8007ea:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007f7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007fb:	8b 10                	mov    (%eax),%edx
  8007fd:	3b 50 04             	cmp    0x4(%eax),%edx
  800800:	73 0a                	jae    80080c <sprintputch+0x1b>
		*b->buf++ = ch;
  800802:	8d 4a 01             	lea    0x1(%edx),%ecx
  800805:	89 08                	mov    %ecx,(%eax)
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	88 02                	mov    %al,(%edx)
}
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800814:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800817:	50                   	push   %eax
  800818:	ff 75 10             	pushl  0x10(%ebp)
  80081b:	ff 75 0c             	pushl  0xc(%ebp)
  80081e:	ff 75 08             	pushl  0x8(%ebp)
  800821:	e8 05 00 00 00       	call   80082b <vprintfmt>
	va_end(ap);
}
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	57                   	push   %edi
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	83 ec 2c             	sub    $0x2c,%esp
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80083d:	eb 12                	jmp    800851 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80083f:	85 c0                	test   %eax,%eax
  800841:	0f 84 89 03 00 00    	je     800bd0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	53                   	push   %ebx
  80084b:	50                   	push   %eax
  80084c:	ff d6                	call   *%esi
  80084e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800851:	83 c7 01             	add    $0x1,%edi
  800854:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800858:	83 f8 25             	cmp    $0x25,%eax
  80085b:	75 e2                	jne    80083f <vprintfmt+0x14>
  80085d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800861:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800868:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80086f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800876:	ba 00 00 00 00       	mov    $0x0,%edx
  80087b:	eb 07                	jmp    800884 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800880:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800884:	8d 47 01             	lea    0x1(%edi),%eax
  800887:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80088a:	0f b6 07             	movzbl (%edi),%eax
  80088d:	0f b6 c8             	movzbl %al,%ecx
  800890:	83 e8 23             	sub    $0x23,%eax
  800893:	3c 55                	cmp    $0x55,%al
  800895:	0f 87 1a 03 00 00    	ja     800bb5 <vprintfmt+0x38a>
  80089b:	0f b6 c0             	movzbl %al,%eax
  80089e:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
  8008a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008a8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008ac:	eb d6                	jmp    800884 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008b9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008bc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8008c0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8008c3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8008c6:	83 fa 09             	cmp    $0x9,%edx
  8008c9:	77 39                	ja     800904 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008cb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008ce:	eb e9                	jmp    8008b9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d3:	8d 48 04             	lea    0x4(%eax),%ecx
  8008d6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008d9:	8b 00                	mov    (%eax),%eax
  8008db:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008e1:	eb 27                	jmp    80090a <vprintfmt+0xdf>
  8008e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ed:	0f 49 c8             	cmovns %eax,%ecx
  8008f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f6:	eb 8c                	jmp    800884 <vprintfmt+0x59>
  8008f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008fb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800902:	eb 80                	jmp    800884 <vprintfmt+0x59>
  800904:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800907:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80090a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80090e:	0f 89 70 ff ff ff    	jns    800884 <vprintfmt+0x59>
				width = precision, precision = -1;
  800914:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800917:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80091a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800921:	e9 5e ff ff ff       	jmp    800884 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800926:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80092c:	e9 53 ff ff ff       	jmp    800884 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800931:	8b 45 14             	mov    0x14(%ebp),%eax
  800934:	8d 50 04             	lea    0x4(%eax),%edx
  800937:	89 55 14             	mov    %edx,0x14(%ebp)
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	53                   	push   %ebx
  80093e:	ff 30                	pushl  (%eax)
  800940:	ff d6                	call   *%esi
			break;
  800942:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800945:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800948:	e9 04 ff ff ff       	jmp    800851 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80094d:	8b 45 14             	mov    0x14(%ebp),%eax
  800950:	8d 50 04             	lea    0x4(%eax),%edx
  800953:	89 55 14             	mov    %edx,0x14(%ebp)
  800956:	8b 00                	mov    (%eax),%eax
  800958:	99                   	cltd   
  800959:	31 d0                	xor    %edx,%eax
  80095b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80095d:	83 f8 0f             	cmp    $0xf,%eax
  800960:	7f 0b                	jg     80096d <vprintfmt+0x142>
  800962:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  800969:	85 d2                	test   %edx,%edx
  80096b:	75 18                	jne    800985 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80096d:	50                   	push   %eax
  80096e:	68 5b 28 80 00       	push   $0x80285b
  800973:	53                   	push   %ebx
  800974:	56                   	push   %esi
  800975:	e8 94 fe ff ff       	call   80080e <printfmt>
  80097a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800980:	e9 cc fe ff ff       	jmp    800851 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800985:	52                   	push   %edx
  800986:	68 a1 2c 80 00       	push   $0x802ca1
  80098b:	53                   	push   %ebx
  80098c:	56                   	push   %esi
  80098d:	e8 7c fe ff ff       	call   80080e <printfmt>
  800992:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800995:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800998:	e9 b4 fe ff ff       	jmp    800851 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80099d:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a0:	8d 50 04             	lea    0x4(%eax),%edx
  8009a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009a8:	85 ff                	test   %edi,%edi
  8009aa:	b8 54 28 80 00       	mov    $0x802854,%eax
  8009af:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009b6:	0f 8e 94 00 00 00    	jle    800a50 <vprintfmt+0x225>
  8009bc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009c0:	0f 84 98 00 00 00    	je     800a5e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c6:	83 ec 08             	sub    $0x8,%esp
  8009c9:	ff 75 d0             	pushl  -0x30(%ebp)
  8009cc:	57                   	push   %edi
  8009cd:	e8 86 02 00 00       	call   800c58 <strnlen>
  8009d2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009d5:	29 c1                	sub    %eax,%ecx
  8009d7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009da:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009dd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009e4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009e7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e9:	eb 0f                	jmp    8009fa <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009eb:	83 ec 08             	sub    $0x8,%esp
  8009ee:	53                   	push   %ebx
  8009ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8009f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f4:	83 ef 01             	sub    $0x1,%edi
  8009f7:	83 c4 10             	add    $0x10,%esp
  8009fa:	85 ff                	test   %edi,%edi
  8009fc:	7f ed                	jg     8009eb <vprintfmt+0x1c0>
  8009fe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a01:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a04:	85 c9                	test   %ecx,%ecx
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	0f 49 c1             	cmovns %ecx,%eax
  800a0e:	29 c1                	sub    %eax,%ecx
  800a10:	89 75 08             	mov    %esi,0x8(%ebp)
  800a13:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a16:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a19:	89 cb                	mov    %ecx,%ebx
  800a1b:	eb 4d                	jmp    800a6a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a1d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a21:	74 1b                	je     800a3e <vprintfmt+0x213>
  800a23:	0f be c0             	movsbl %al,%eax
  800a26:	83 e8 20             	sub    $0x20,%eax
  800a29:	83 f8 5e             	cmp    $0x5e,%eax
  800a2c:	76 10                	jbe    800a3e <vprintfmt+0x213>
					putch('?', putdat);
  800a2e:	83 ec 08             	sub    $0x8,%esp
  800a31:	ff 75 0c             	pushl  0xc(%ebp)
  800a34:	6a 3f                	push   $0x3f
  800a36:	ff 55 08             	call   *0x8(%ebp)
  800a39:	83 c4 10             	add    $0x10,%esp
  800a3c:	eb 0d                	jmp    800a4b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a3e:	83 ec 08             	sub    $0x8,%esp
  800a41:	ff 75 0c             	pushl  0xc(%ebp)
  800a44:	52                   	push   %edx
  800a45:	ff 55 08             	call   *0x8(%ebp)
  800a48:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a4b:	83 eb 01             	sub    $0x1,%ebx
  800a4e:	eb 1a                	jmp    800a6a <vprintfmt+0x23f>
  800a50:	89 75 08             	mov    %esi,0x8(%ebp)
  800a53:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a56:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a59:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a5c:	eb 0c                	jmp    800a6a <vprintfmt+0x23f>
  800a5e:	89 75 08             	mov    %esi,0x8(%ebp)
  800a61:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a64:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a67:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a6a:	83 c7 01             	add    $0x1,%edi
  800a6d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a71:	0f be d0             	movsbl %al,%edx
  800a74:	85 d2                	test   %edx,%edx
  800a76:	74 23                	je     800a9b <vprintfmt+0x270>
  800a78:	85 f6                	test   %esi,%esi
  800a7a:	78 a1                	js     800a1d <vprintfmt+0x1f2>
  800a7c:	83 ee 01             	sub    $0x1,%esi
  800a7f:	79 9c                	jns    800a1d <vprintfmt+0x1f2>
  800a81:	89 df                	mov    %ebx,%edi
  800a83:	8b 75 08             	mov    0x8(%ebp),%esi
  800a86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a89:	eb 18                	jmp    800aa3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a8b:	83 ec 08             	sub    $0x8,%esp
  800a8e:	53                   	push   %ebx
  800a8f:	6a 20                	push   $0x20
  800a91:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a93:	83 ef 01             	sub    $0x1,%edi
  800a96:	83 c4 10             	add    $0x10,%esp
  800a99:	eb 08                	jmp    800aa3 <vprintfmt+0x278>
  800a9b:	89 df                	mov    %ebx,%edi
  800a9d:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aa3:	85 ff                	test   %edi,%edi
  800aa5:	7f e4                	jg     800a8b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aa7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aaa:	e9 a2 fd ff ff       	jmp    800851 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800aaf:	83 fa 01             	cmp    $0x1,%edx
  800ab2:	7e 16                	jle    800aca <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800ab4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab7:	8d 50 08             	lea    0x8(%eax),%edx
  800aba:	89 55 14             	mov    %edx,0x14(%ebp)
  800abd:	8b 50 04             	mov    0x4(%eax),%edx
  800ac0:	8b 00                	mov    (%eax),%eax
  800ac2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ac5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ac8:	eb 32                	jmp    800afc <vprintfmt+0x2d1>
	else if (lflag)
  800aca:	85 d2                	test   %edx,%edx
  800acc:	74 18                	je     800ae6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800ace:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad1:	8d 50 04             	lea    0x4(%eax),%edx
  800ad4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ad7:	8b 00                	mov    (%eax),%eax
  800ad9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800adc:	89 c1                	mov    %eax,%ecx
  800ade:	c1 f9 1f             	sar    $0x1f,%ecx
  800ae1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ae4:	eb 16                	jmp    800afc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ae6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae9:	8d 50 04             	lea    0x4(%eax),%edx
  800aec:	89 55 14             	mov    %edx,0x14(%ebp)
  800aef:	8b 00                	mov    (%eax),%eax
  800af1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800af4:	89 c1                	mov    %eax,%ecx
  800af6:	c1 f9 1f             	sar    $0x1f,%ecx
  800af9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800afc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800aff:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b02:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b07:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b0b:	79 74                	jns    800b81 <vprintfmt+0x356>
				putch('-', putdat);
  800b0d:	83 ec 08             	sub    $0x8,%esp
  800b10:	53                   	push   %ebx
  800b11:	6a 2d                	push   $0x2d
  800b13:	ff d6                	call   *%esi
				num = -(long long) num;
  800b15:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b18:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b1b:	f7 d8                	neg    %eax
  800b1d:	83 d2 00             	adc    $0x0,%edx
  800b20:	f7 da                	neg    %edx
  800b22:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b25:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b2a:	eb 55                	jmp    800b81 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b2c:	8d 45 14             	lea    0x14(%ebp),%eax
  800b2f:	e8 83 fc ff ff       	call   8007b7 <getuint>
			base = 10;
  800b34:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b39:	eb 46                	jmp    800b81 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b3b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b3e:	e8 74 fc ff ff       	call   8007b7 <getuint>
			base = 8;
  800b43:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b48:	eb 37                	jmp    800b81 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b4a:	83 ec 08             	sub    $0x8,%esp
  800b4d:	53                   	push   %ebx
  800b4e:	6a 30                	push   $0x30
  800b50:	ff d6                	call   *%esi
			putch('x', putdat);
  800b52:	83 c4 08             	add    $0x8,%esp
  800b55:	53                   	push   %ebx
  800b56:	6a 78                	push   $0x78
  800b58:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5d:	8d 50 04             	lea    0x4(%eax),%edx
  800b60:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b63:	8b 00                	mov    (%eax),%eax
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b6a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b6d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b72:	eb 0d                	jmp    800b81 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b74:	8d 45 14             	lea    0x14(%ebp),%eax
  800b77:	e8 3b fc ff ff       	call   8007b7 <getuint>
			base = 16;
  800b7c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b88:	57                   	push   %edi
  800b89:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8c:	51                   	push   %ecx
  800b8d:	52                   	push   %edx
  800b8e:	50                   	push   %eax
  800b8f:	89 da                	mov    %ebx,%edx
  800b91:	89 f0                	mov    %esi,%eax
  800b93:	e8 70 fb ff ff       	call   800708 <printnum>
			break;
  800b98:	83 c4 20             	add    $0x20,%esp
  800b9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b9e:	e9 ae fc ff ff       	jmp    800851 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ba3:	83 ec 08             	sub    $0x8,%esp
  800ba6:	53                   	push   %ebx
  800ba7:	51                   	push   %ecx
  800ba8:	ff d6                	call   *%esi
			break;
  800baa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bb0:	e9 9c fc ff ff       	jmp    800851 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bb5:	83 ec 08             	sub    $0x8,%esp
  800bb8:	53                   	push   %ebx
  800bb9:	6a 25                	push   $0x25
  800bbb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bbd:	83 c4 10             	add    $0x10,%esp
  800bc0:	eb 03                	jmp    800bc5 <vprintfmt+0x39a>
  800bc2:	83 ef 01             	sub    $0x1,%edi
  800bc5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800bc9:	75 f7                	jne    800bc2 <vprintfmt+0x397>
  800bcb:	e9 81 fc ff ff       	jmp    800851 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	83 ec 18             	sub    $0x18,%esp
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800be4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800be7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800beb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	74 26                	je     800c1f <vsnprintf+0x47>
  800bf9:	85 d2                	test   %edx,%edx
  800bfb:	7e 22                	jle    800c1f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bfd:	ff 75 14             	pushl  0x14(%ebp)
  800c00:	ff 75 10             	pushl  0x10(%ebp)
  800c03:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c06:	50                   	push   %eax
  800c07:	68 f1 07 80 00       	push   $0x8007f1
  800c0c:	e8 1a fc ff ff       	call   80082b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c11:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c14:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1a:	83 c4 10             	add    $0x10,%esp
  800c1d:	eb 05                	jmp    800c24 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c2c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c2f:	50                   	push   %eax
  800c30:	ff 75 10             	pushl  0x10(%ebp)
  800c33:	ff 75 0c             	pushl  0xc(%ebp)
  800c36:	ff 75 08             	pushl  0x8(%ebp)
  800c39:	e8 9a ff ff ff       	call   800bd8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4b:	eb 03                	jmp    800c50 <strlen+0x10>
		n++;
  800c4d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c50:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c54:	75 f7                	jne    800c4d <strlen+0xd>
		n++;
	return n;
}
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	eb 03                	jmp    800c6b <strnlen+0x13>
		n++;
  800c68:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6b:	39 c2                	cmp    %eax,%edx
  800c6d:	74 08                	je     800c77 <strnlen+0x1f>
  800c6f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c73:	75 f3                	jne    800c68 <strnlen+0x10>
  800c75:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	53                   	push   %ebx
  800c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c83:	89 c2                	mov    %eax,%edx
  800c85:	83 c2 01             	add    $0x1,%edx
  800c88:	83 c1 01             	add    $0x1,%ecx
  800c8b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c8f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c92:	84 db                	test   %bl,%bl
  800c94:	75 ef                	jne    800c85 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c96:	5b                   	pop    %ebx
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	53                   	push   %ebx
  800c9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ca0:	53                   	push   %ebx
  800ca1:	e8 9a ff ff ff       	call   800c40 <strlen>
  800ca6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800ca9:	ff 75 0c             	pushl  0xc(%ebp)
  800cac:	01 d8                	add    %ebx,%eax
  800cae:	50                   	push   %eax
  800caf:	e8 c5 ff ff ff       	call   800c79 <strcpy>
	return dst;
}
  800cb4:	89 d8                	mov    %ebx,%eax
  800cb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cb9:	c9                   	leave  
  800cba:	c3                   	ret    

00800cbb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	89 f3                	mov    %esi,%ebx
  800cc8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ccb:	89 f2                	mov    %esi,%edx
  800ccd:	eb 0f                	jmp    800cde <strncpy+0x23>
		*dst++ = *src;
  800ccf:	83 c2 01             	add    $0x1,%edx
  800cd2:	0f b6 01             	movzbl (%ecx),%eax
  800cd5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cd8:	80 39 01             	cmpb   $0x1,(%ecx)
  800cdb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cde:	39 da                	cmp    %ebx,%edx
  800ce0:	75 ed                	jne    800ccf <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ce2:	89 f0                	mov    %esi,%eax
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	8b 75 08             	mov    0x8(%ebp),%esi
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 10             	mov    0x10(%ebp),%edx
  800cf6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cf8:	85 d2                	test   %edx,%edx
  800cfa:	74 21                	je     800d1d <strlcpy+0x35>
  800cfc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d00:	89 f2                	mov    %esi,%edx
  800d02:	eb 09                	jmp    800d0d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d04:	83 c2 01             	add    $0x1,%edx
  800d07:	83 c1 01             	add    $0x1,%ecx
  800d0a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d0d:	39 c2                	cmp    %eax,%edx
  800d0f:	74 09                	je     800d1a <strlcpy+0x32>
  800d11:	0f b6 19             	movzbl (%ecx),%ebx
  800d14:	84 db                	test   %bl,%bl
  800d16:	75 ec                	jne    800d04 <strlcpy+0x1c>
  800d18:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d1a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d1d:	29 f0                	sub    %esi,%eax
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d29:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d2c:	eb 06                	jmp    800d34 <strcmp+0x11>
		p++, q++;
  800d2e:	83 c1 01             	add    $0x1,%ecx
  800d31:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d34:	0f b6 01             	movzbl (%ecx),%eax
  800d37:	84 c0                	test   %al,%al
  800d39:	74 04                	je     800d3f <strcmp+0x1c>
  800d3b:	3a 02                	cmp    (%edx),%al
  800d3d:	74 ef                	je     800d2e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d3f:	0f b6 c0             	movzbl %al,%eax
  800d42:	0f b6 12             	movzbl (%edx),%edx
  800d45:	29 d0                	sub    %edx,%eax
}
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	53                   	push   %ebx
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d53:	89 c3                	mov    %eax,%ebx
  800d55:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d58:	eb 06                	jmp    800d60 <strncmp+0x17>
		n--, p++, q++;
  800d5a:	83 c0 01             	add    $0x1,%eax
  800d5d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d60:	39 d8                	cmp    %ebx,%eax
  800d62:	74 15                	je     800d79 <strncmp+0x30>
  800d64:	0f b6 08             	movzbl (%eax),%ecx
  800d67:	84 c9                	test   %cl,%cl
  800d69:	74 04                	je     800d6f <strncmp+0x26>
  800d6b:	3a 0a                	cmp    (%edx),%cl
  800d6d:	74 eb                	je     800d5a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d6f:	0f b6 00             	movzbl (%eax),%eax
  800d72:	0f b6 12             	movzbl (%edx),%edx
  800d75:	29 d0                	sub    %edx,%eax
  800d77:	eb 05                	jmp    800d7e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d79:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d8b:	eb 07                	jmp    800d94 <strchr+0x13>
		if (*s == c)
  800d8d:	38 ca                	cmp    %cl,%dl
  800d8f:	74 0f                	je     800da0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d91:	83 c0 01             	add    $0x1,%eax
  800d94:	0f b6 10             	movzbl (%eax),%edx
  800d97:	84 d2                	test   %dl,%dl
  800d99:	75 f2                	jne    800d8d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
  800da8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dac:	eb 03                	jmp    800db1 <strfind+0xf>
  800dae:	83 c0 01             	add    $0x1,%eax
  800db1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800db4:	38 ca                	cmp    %cl,%dl
  800db6:	74 04                	je     800dbc <strfind+0x1a>
  800db8:	84 d2                	test   %dl,%dl
  800dba:	75 f2                	jne    800dae <strfind+0xc>
			break;
	return (char *) s;
}
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dc7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dca:	85 c9                	test   %ecx,%ecx
  800dcc:	74 36                	je     800e04 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dd4:	75 28                	jne    800dfe <memset+0x40>
  800dd6:	f6 c1 03             	test   $0x3,%cl
  800dd9:	75 23                	jne    800dfe <memset+0x40>
		c &= 0xFF;
  800ddb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ddf:	89 d3                	mov    %edx,%ebx
  800de1:	c1 e3 08             	shl    $0x8,%ebx
  800de4:	89 d6                	mov    %edx,%esi
  800de6:	c1 e6 18             	shl    $0x18,%esi
  800de9:	89 d0                	mov    %edx,%eax
  800deb:	c1 e0 10             	shl    $0x10,%eax
  800dee:	09 f0                	or     %esi,%eax
  800df0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800df2:	89 d8                	mov    %ebx,%eax
  800df4:	09 d0                	or     %edx,%eax
  800df6:	c1 e9 02             	shr    $0x2,%ecx
  800df9:	fc                   	cld    
  800dfa:	f3 ab                	rep stos %eax,%es:(%edi)
  800dfc:	eb 06                	jmp    800e04 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e01:	fc                   	cld    
  800e02:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e04:	89 f8                	mov    %edi,%eax
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e19:	39 c6                	cmp    %eax,%esi
  800e1b:	73 35                	jae    800e52 <memmove+0x47>
  800e1d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e20:	39 d0                	cmp    %edx,%eax
  800e22:	73 2e                	jae    800e52 <memmove+0x47>
		s += n;
		d += n;
  800e24:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e27:	89 d6                	mov    %edx,%esi
  800e29:	09 fe                	or     %edi,%esi
  800e2b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e31:	75 13                	jne    800e46 <memmove+0x3b>
  800e33:	f6 c1 03             	test   $0x3,%cl
  800e36:	75 0e                	jne    800e46 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e38:	83 ef 04             	sub    $0x4,%edi
  800e3b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e3e:	c1 e9 02             	shr    $0x2,%ecx
  800e41:	fd                   	std    
  800e42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e44:	eb 09                	jmp    800e4f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e46:	83 ef 01             	sub    $0x1,%edi
  800e49:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e4c:	fd                   	std    
  800e4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e4f:	fc                   	cld    
  800e50:	eb 1d                	jmp    800e6f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e52:	89 f2                	mov    %esi,%edx
  800e54:	09 c2                	or     %eax,%edx
  800e56:	f6 c2 03             	test   $0x3,%dl
  800e59:	75 0f                	jne    800e6a <memmove+0x5f>
  800e5b:	f6 c1 03             	test   $0x3,%cl
  800e5e:	75 0a                	jne    800e6a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e60:	c1 e9 02             	shr    $0x2,%ecx
  800e63:	89 c7                	mov    %eax,%edi
  800e65:	fc                   	cld    
  800e66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e68:	eb 05                	jmp    800e6f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e6a:	89 c7                	mov    %eax,%edi
  800e6c:	fc                   	cld    
  800e6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e76:	ff 75 10             	pushl  0x10(%ebp)
  800e79:	ff 75 0c             	pushl  0xc(%ebp)
  800e7c:	ff 75 08             	pushl  0x8(%ebp)
  800e7f:	e8 87 ff ff ff       	call   800e0b <memmove>
}
  800e84:	c9                   	leave  
  800e85:	c3                   	ret    

00800e86 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e91:	89 c6                	mov    %eax,%esi
  800e93:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e96:	eb 1a                	jmp    800eb2 <memcmp+0x2c>
		if (*s1 != *s2)
  800e98:	0f b6 08             	movzbl (%eax),%ecx
  800e9b:	0f b6 1a             	movzbl (%edx),%ebx
  800e9e:	38 d9                	cmp    %bl,%cl
  800ea0:	74 0a                	je     800eac <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ea2:	0f b6 c1             	movzbl %cl,%eax
  800ea5:	0f b6 db             	movzbl %bl,%ebx
  800ea8:	29 d8                	sub    %ebx,%eax
  800eaa:	eb 0f                	jmp    800ebb <memcmp+0x35>
		s1++, s2++;
  800eac:	83 c0 01             	add    $0x1,%eax
  800eaf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eb2:	39 f0                	cmp    %esi,%eax
  800eb4:	75 e2                	jne    800e98 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800eb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ebb:	5b                   	pop    %ebx
  800ebc:	5e                   	pop    %esi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    

00800ebf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	53                   	push   %ebx
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ec6:	89 c1                	mov    %eax,%ecx
  800ec8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ecb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ecf:	eb 0a                	jmp    800edb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ed1:	0f b6 10             	movzbl (%eax),%edx
  800ed4:	39 da                	cmp    %ebx,%edx
  800ed6:	74 07                	je     800edf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ed8:	83 c0 01             	add    $0x1,%eax
  800edb:	39 c8                	cmp    %ecx,%eax
  800edd:	72 f2                	jb     800ed1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800edf:	5b                   	pop    %ebx
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eee:	eb 03                	jmp    800ef3 <strtol+0x11>
		s++;
  800ef0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ef3:	0f b6 01             	movzbl (%ecx),%eax
  800ef6:	3c 20                	cmp    $0x20,%al
  800ef8:	74 f6                	je     800ef0 <strtol+0xe>
  800efa:	3c 09                	cmp    $0x9,%al
  800efc:	74 f2                	je     800ef0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800efe:	3c 2b                	cmp    $0x2b,%al
  800f00:	75 0a                	jne    800f0c <strtol+0x2a>
		s++;
  800f02:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f05:	bf 00 00 00 00       	mov    $0x0,%edi
  800f0a:	eb 11                	jmp    800f1d <strtol+0x3b>
  800f0c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f11:	3c 2d                	cmp    $0x2d,%al
  800f13:	75 08                	jne    800f1d <strtol+0x3b>
		s++, neg = 1;
  800f15:	83 c1 01             	add    $0x1,%ecx
  800f18:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f1d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f23:	75 15                	jne    800f3a <strtol+0x58>
  800f25:	80 39 30             	cmpb   $0x30,(%ecx)
  800f28:	75 10                	jne    800f3a <strtol+0x58>
  800f2a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f2e:	75 7c                	jne    800fac <strtol+0xca>
		s += 2, base = 16;
  800f30:	83 c1 02             	add    $0x2,%ecx
  800f33:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f38:	eb 16                	jmp    800f50 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f3a:	85 db                	test   %ebx,%ebx
  800f3c:	75 12                	jne    800f50 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f3e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f43:	80 39 30             	cmpb   $0x30,(%ecx)
  800f46:	75 08                	jne    800f50 <strtol+0x6e>
		s++, base = 8;
  800f48:	83 c1 01             	add    $0x1,%ecx
  800f4b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f50:	b8 00 00 00 00       	mov    $0x0,%eax
  800f55:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f58:	0f b6 11             	movzbl (%ecx),%edx
  800f5b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f5e:	89 f3                	mov    %esi,%ebx
  800f60:	80 fb 09             	cmp    $0x9,%bl
  800f63:	77 08                	ja     800f6d <strtol+0x8b>
			dig = *s - '0';
  800f65:	0f be d2             	movsbl %dl,%edx
  800f68:	83 ea 30             	sub    $0x30,%edx
  800f6b:	eb 22                	jmp    800f8f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f6d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f70:	89 f3                	mov    %esi,%ebx
  800f72:	80 fb 19             	cmp    $0x19,%bl
  800f75:	77 08                	ja     800f7f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f77:	0f be d2             	movsbl %dl,%edx
  800f7a:	83 ea 57             	sub    $0x57,%edx
  800f7d:	eb 10                	jmp    800f8f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f7f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f82:	89 f3                	mov    %esi,%ebx
  800f84:	80 fb 19             	cmp    $0x19,%bl
  800f87:	77 16                	ja     800f9f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f89:	0f be d2             	movsbl %dl,%edx
  800f8c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f8f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f92:	7d 0b                	jge    800f9f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f94:	83 c1 01             	add    $0x1,%ecx
  800f97:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f9b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f9d:	eb b9                	jmp    800f58 <strtol+0x76>

	if (endptr)
  800f9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fa3:	74 0d                	je     800fb2 <strtol+0xd0>
		*endptr = (char *) s;
  800fa5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fa8:	89 0e                	mov    %ecx,(%esi)
  800faa:	eb 06                	jmp    800fb2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fac:	85 db                	test   %ebx,%ebx
  800fae:	74 98                	je     800f48 <strtol+0x66>
  800fb0:	eb 9e                	jmp    800f50 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fb2:	89 c2                	mov    %eax,%edx
  800fb4:	f7 da                	neg    %edx
  800fb6:	85 ff                	test   %edi,%edi
  800fb8:	0f 45 c2             	cmovne %edx,%eax
}
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fce:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd1:	89 c3                	mov    %eax,%ebx
  800fd3:	89 c7                	mov    %eax,%edi
  800fd5:	89 c6                	mov    %eax,%esi
  800fd7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fd9:	5b                   	pop    %ebx
  800fda:	5e                   	pop    %esi
  800fdb:	5f                   	pop    %edi
  800fdc:	5d                   	pop    %ebp
  800fdd:	c3                   	ret    

00800fde <sys_cgetc>:

int
sys_cgetc(void)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	57                   	push   %edi
  800fe2:	56                   	push   %esi
  800fe3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fee:	89 d1                	mov    %edx,%ecx
  800ff0:	89 d3                	mov    %edx,%ebx
  800ff2:	89 d7                	mov    %edx,%edi
  800ff4:	89 d6                	mov    %edx,%esi
  800ff6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
  801003:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801006:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100b:	b8 03 00 00 00       	mov    $0x3,%eax
  801010:	8b 55 08             	mov    0x8(%ebp),%edx
  801013:	89 cb                	mov    %ecx,%ebx
  801015:	89 cf                	mov    %ecx,%edi
  801017:	89 ce                	mov    %ecx,%esi
  801019:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80101b:	85 c0                	test   %eax,%eax
  80101d:	7e 17                	jle    801036 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	50                   	push   %eax
  801023:	6a 03                	push   $0x3
  801025:	68 3f 2b 80 00       	push   $0x802b3f
  80102a:	6a 23                	push   $0x23
  80102c:	68 5c 2b 80 00       	push   $0x802b5c
  801031:	e8 e5 f5 ff ff       	call   80061b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801036:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801039:	5b                   	pop    %ebx
  80103a:	5e                   	pop    %esi
  80103b:	5f                   	pop    %edi
  80103c:	5d                   	pop    %ebp
  80103d:	c3                   	ret    

0080103e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801044:	ba 00 00 00 00       	mov    $0x0,%edx
  801049:	b8 02 00 00 00       	mov    $0x2,%eax
  80104e:	89 d1                	mov    %edx,%ecx
  801050:	89 d3                	mov    %edx,%ebx
  801052:	89 d7                	mov    %edx,%edi
  801054:	89 d6                	mov    %edx,%esi
  801056:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sys_yield>:

void
sys_yield(void)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801063:	ba 00 00 00 00       	mov    $0x0,%edx
  801068:	b8 0b 00 00 00       	mov    $0xb,%eax
  80106d:	89 d1                	mov    %edx,%ecx
  80106f:	89 d3                	mov    %edx,%ebx
  801071:	89 d7                	mov    %edx,%edi
  801073:	89 d6                	mov    %edx,%esi
  801075:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801077:	5b                   	pop    %ebx
  801078:	5e                   	pop    %esi
  801079:	5f                   	pop    %edi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    

0080107c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	57                   	push   %edi
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
  801082:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801085:	be 00 00 00 00       	mov    $0x0,%esi
  80108a:	b8 04 00 00 00       	mov    $0x4,%eax
  80108f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801092:	8b 55 08             	mov    0x8(%ebp),%edx
  801095:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801098:	89 f7                	mov    %esi,%edi
  80109a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80109c:	85 c0                	test   %eax,%eax
  80109e:	7e 17                	jle    8010b7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	50                   	push   %eax
  8010a4:	6a 04                	push   $0x4
  8010a6:	68 3f 2b 80 00       	push   $0x802b3f
  8010ab:	6a 23                	push   $0x23
  8010ad:	68 5c 2b 80 00       	push   $0x802b5c
  8010b2:	e8 64 f5 ff ff       	call   80061b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ba:	5b                   	pop    %ebx
  8010bb:	5e                   	pop    %esi
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	57                   	push   %edi
  8010c3:	56                   	push   %esi
  8010c4:	53                   	push   %ebx
  8010c5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8010cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d9:	8b 75 18             	mov    0x18(%ebp),%esi
  8010dc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	7e 17                	jle    8010f9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	50                   	push   %eax
  8010e6:	6a 05                	push   $0x5
  8010e8:	68 3f 2b 80 00       	push   $0x802b3f
  8010ed:	6a 23                	push   $0x23
  8010ef:	68 5c 2b 80 00       	push   $0x802b5c
  8010f4:	e8 22 f5 ff ff       	call   80061b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	57                   	push   %edi
  801105:	56                   	push   %esi
  801106:	53                   	push   %ebx
  801107:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110f:	b8 06 00 00 00       	mov    $0x6,%eax
  801114:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801117:	8b 55 08             	mov    0x8(%ebp),%edx
  80111a:	89 df                	mov    %ebx,%edi
  80111c:	89 de                	mov    %ebx,%esi
  80111e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801120:	85 c0                	test   %eax,%eax
  801122:	7e 17                	jle    80113b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	50                   	push   %eax
  801128:	6a 06                	push   $0x6
  80112a:	68 3f 2b 80 00       	push   $0x802b3f
  80112f:	6a 23                	push   $0x23
  801131:	68 5c 2b 80 00       	push   $0x802b5c
  801136:	e8 e0 f4 ff ff       	call   80061b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80113b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801151:	b8 08 00 00 00       	mov    $0x8,%eax
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	89 df                	mov    %ebx,%edi
  80115e:	89 de                	mov    %ebx,%esi
  801160:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801162:	85 c0                	test   %eax,%eax
  801164:	7e 17                	jle    80117d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801166:	83 ec 0c             	sub    $0xc,%esp
  801169:	50                   	push   %eax
  80116a:	6a 08                	push   $0x8
  80116c:	68 3f 2b 80 00       	push   $0x802b3f
  801171:	6a 23                	push   $0x23
  801173:	68 5c 2b 80 00       	push   $0x802b5c
  801178:	e8 9e f4 ff ff       	call   80061b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80117d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801180:	5b                   	pop    %ebx
  801181:	5e                   	pop    %esi
  801182:	5f                   	pop    %edi
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	57                   	push   %edi
  801189:	56                   	push   %esi
  80118a:	53                   	push   %ebx
  80118b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80118e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801193:	b8 09 00 00 00       	mov    $0x9,%eax
  801198:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119b:	8b 55 08             	mov    0x8(%ebp),%edx
  80119e:	89 df                	mov    %ebx,%edi
  8011a0:	89 de                	mov    %ebx,%esi
  8011a2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	7e 17                	jle    8011bf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a8:	83 ec 0c             	sub    $0xc,%esp
  8011ab:	50                   	push   %eax
  8011ac:	6a 09                	push   $0x9
  8011ae:	68 3f 2b 80 00       	push   $0x802b3f
  8011b3:	6a 23                	push   $0x23
  8011b5:	68 5c 2b 80 00       	push   $0x802b5c
  8011ba:	e8 5c f4 ff ff       	call   80061b <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8011bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e0:	89 df                	mov    %ebx,%edi
  8011e2:	89 de                	mov    %ebx,%esi
  8011e4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	7e 17                	jle    801201 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ea:	83 ec 0c             	sub    $0xc,%esp
  8011ed:	50                   	push   %eax
  8011ee:	6a 0a                	push   $0xa
  8011f0:	68 3f 2b 80 00       	push   $0x802b3f
  8011f5:	6a 23                	push   $0x23
  8011f7:	68 5c 2b 80 00       	push   $0x802b5c
  8011fc:	e8 1a f4 ff ff       	call   80061b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5f                   	pop    %edi
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	57                   	push   %edi
  80120d:	56                   	push   %esi
  80120e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120f:	be 00 00 00 00       	mov    $0x0,%esi
  801214:	b8 0c 00 00 00       	mov    $0xc,%eax
  801219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80121c:	8b 55 08             	mov    0x8(%ebp),%edx
  80121f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801222:	8b 7d 14             	mov    0x14(%ebp),%edi
  801225:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	57                   	push   %edi
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
  801232:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801235:	b9 00 00 00 00       	mov    $0x0,%ecx
  80123a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80123f:	8b 55 08             	mov    0x8(%ebp),%edx
  801242:	89 cb                	mov    %ecx,%ebx
  801244:	89 cf                	mov    %ecx,%edi
  801246:	89 ce                	mov    %ecx,%esi
  801248:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80124a:	85 c0                	test   %eax,%eax
  80124c:	7e 17                	jle    801265 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	50                   	push   %eax
  801252:	6a 0d                	push   $0xd
  801254:	68 3f 2b 80 00       	push   $0x802b3f
  801259:	6a 23                	push   $0x23
  80125b:	68 5c 2b 80 00       	push   $0x802b5c
  801260:	e8 b6 f3 ff ff       	call   80061b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801265:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5f                   	pop    %edi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	57                   	push   %edi
  801271:	56                   	push   %esi
  801272:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801273:	b9 00 00 00 00       	mov    $0x0,%ecx
  801278:	b8 0e 00 00 00       	mov    $0xe,%eax
  80127d:	8b 55 08             	mov    0x8(%ebp),%edx
  801280:	89 cb                	mov    %ecx,%ebx
  801282:	89 cf                	mov    %ecx,%edi
  801284:	89 ce                	mov    %ecx,%esi
  801286:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	57                   	push   %edi
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801293:	b9 00 00 00 00       	mov    $0x0,%ecx
  801298:	b8 0f 00 00 00       	mov    $0xf,%eax
  80129d:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a0:	89 cb                	mov    %ecx,%ebx
  8012a2:	89 cf                	mov    %ecx,%edi
  8012a4:	89 ce                	mov    %ecx,%esi
  8012a6:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8012a8:	5b                   	pop    %ebx
  8012a9:	5e                   	pop    %esi
  8012aa:	5f                   	pop    %edi
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012b3:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  8012ba:	75 2a                	jne    8012e6 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  8012bc:	83 ec 04             	sub    $0x4,%esp
  8012bf:	6a 07                	push   $0x7
  8012c1:	68 00 f0 bf ee       	push   $0xeebff000
  8012c6:	6a 00                	push   $0x0
  8012c8:	e8 af fd ff ff       	call   80107c <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  8012cd:	83 c4 10             	add    $0x10,%esp
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	79 12                	jns    8012e6 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  8012d4:	50                   	push   %eax
  8012d5:	68 6a 2b 80 00       	push   $0x802b6a
  8012da:	6a 23                	push   $0x23
  8012dc:	68 6e 2b 80 00       	push   $0x802b6e
  8012e1:	e8 35 f3 ff ff       	call   80061b <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e9:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	68 18 13 80 00       	push   $0x801318
  8012f6:	6a 00                	push   $0x0
  8012f8:	e8 ca fe ff ff       	call   8011c7 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	79 12                	jns    801316 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801304:	50                   	push   %eax
  801305:	68 6a 2b 80 00       	push   $0x802b6a
  80130a:	6a 2c                	push   $0x2c
  80130c:	68 6e 2b 80 00       	push   $0x802b6e
  801311:	e8 05 f3 ff ff       	call   80061b <_panic>
	}
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801318:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801319:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  80131e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801320:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801323:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801327:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  80132c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801330:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801332:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801335:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801336:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801339:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  80133a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80133b:	c3                   	ret    

0080133c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	53                   	push   %ebx
  801340:	83 ec 04             	sub    $0x4,%esp
  801343:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801346:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  801348:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80134c:	74 11                	je     80135f <pgfault+0x23>
  80134e:	89 d8                	mov    %ebx,%eax
  801350:	c1 e8 0c             	shr    $0xc,%eax
  801353:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135a:	f6 c4 08             	test   $0x8,%ah
  80135d:	75 14                	jne    801373 <pgfault+0x37>
		panic("faulting access");
  80135f:	83 ec 04             	sub    $0x4,%esp
  801362:	68 7c 2b 80 00       	push   $0x802b7c
  801367:	6a 1e                	push   $0x1e
  801369:	68 8c 2b 80 00       	push   $0x802b8c
  80136e:	e8 a8 f2 ff ff       	call   80061b <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  801373:	83 ec 04             	sub    $0x4,%esp
  801376:	6a 07                	push   $0x7
  801378:	68 00 f0 7f 00       	push   $0x7ff000
  80137d:	6a 00                	push   $0x0
  80137f:	e8 f8 fc ff ff       	call   80107c <sys_page_alloc>
	if (r < 0) {
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	79 12                	jns    80139d <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80138b:	50                   	push   %eax
  80138c:	68 97 2b 80 00       	push   $0x802b97
  801391:	6a 2c                	push   $0x2c
  801393:	68 8c 2b 80 00       	push   $0x802b8c
  801398:	e8 7e f2 ff ff       	call   80061b <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80139d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  8013a3:	83 ec 04             	sub    $0x4,%esp
  8013a6:	68 00 10 00 00       	push   $0x1000
  8013ab:	53                   	push   %ebx
  8013ac:	68 00 f0 7f 00       	push   $0x7ff000
  8013b1:	e8 bd fa ff ff       	call   800e73 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  8013b6:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8013bd:	53                   	push   %ebx
  8013be:	6a 00                	push   $0x0
  8013c0:	68 00 f0 7f 00       	push   $0x7ff000
  8013c5:	6a 00                	push   $0x0
  8013c7:	e8 f3 fc ff ff       	call   8010bf <sys_page_map>
	if (r < 0) {
  8013cc:	83 c4 20             	add    $0x20,%esp
  8013cf:	85 c0                	test   %eax,%eax
  8013d1:	79 12                	jns    8013e5 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  8013d3:	50                   	push   %eax
  8013d4:	68 97 2b 80 00       	push   $0x802b97
  8013d9:	6a 33                	push   $0x33
  8013db:	68 8c 2b 80 00       	push   $0x802b8c
  8013e0:	e8 36 f2 ff ff       	call   80061b <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	68 00 f0 7f 00       	push   $0x7ff000
  8013ed:	6a 00                	push   $0x0
  8013ef:	e8 0d fd ff ff       	call   801101 <sys_page_unmap>
	if (r < 0) {
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	79 12                	jns    80140d <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8013fb:	50                   	push   %eax
  8013fc:	68 97 2b 80 00       	push   $0x802b97
  801401:	6a 37                	push   $0x37
  801403:	68 8c 2b 80 00       	push   $0x802b8c
  801408:	e8 0e f2 ff ff       	call   80061b <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80140d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	57                   	push   %edi
  801416:	56                   	push   %esi
  801417:	53                   	push   %ebx
  801418:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80141b:	68 3c 13 80 00       	push   $0x80133c
  801420:	e8 88 fe ff ff       	call   8012ad <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801425:	b8 07 00 00 00       	mov    $0x7,%eax
  80142a:	cd 30                	int    $0x30
  80142c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	85 c0                	test   %eax,%eax
  801434:	79 17                	jns    80144d <fork+0x3b>
		panic("fork fault %e");
  801436:	83 ec 04             	sub    $0x4,%esp
  801439:	68 b0 2b 80 00       	push   $0x802bb0
  80143e:	68 84 00 00 00       	push   $0x84
  801443:	68 8c 2b 80 00       	push   $0x802b8c
  801448:	e8 ce f1 ff ff       	call   80061b <_panic>
  80144d:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  80144f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801453:	75 25                	jne    80147a <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  801455:	e8 e4 fb ff ff       	call   80103e <sys_getenvid>
  80145a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80145f:	89 c2                	mov    %eax,%edx
  801461:	c1 e2 07             	shl    $0x7,%edx
  801464:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80146b:	a3 b0 40 80 00       	mov    %eax,0x8040b0
		return 0;
  801470:	b8 00 00 00 00       	mov    $0x0,%eax
  801475:	e9 61 01 00 00       	jmp    8015db <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	6a 07                	push   $0x7
  80147f:	68 00 f0 bf ee       	push   $0xeebff000
  801484:	ff 75 e4             	pushl  -0x1c(%ebp)
  801487:	e8 f0 fb ff ff       	call   80107c <sys_page_alloc>
  80148c:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80148f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  801494:	89 d8                	mov    %ebx,%eax
  801496:	c1 e8 16             	shr    $0x16,%eax
  801499:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014a0:	a8 01                	test   $0x1,%al
  8014a2:	0f 84 fc 00 00 00    	je     8015a4 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  8014a8:	89 d8                	mov    %ebx,%eax
  8014aa:	c1 e8 0c             	shr    $0xc,%eax
  8014ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  8014b4:	f6 c2 01             	test   $0x1,%dl
  8014b7:	0f 84 e7 00 00 00    	je     8015a4 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  8014bd:	89 c6                	mov    %eax,%esi
  8014bf:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  8014c2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c9:	f6 c6 04             	test   $0x4,%dh
  8014cc:	74 39                	je     801507 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  8014ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d5:	83 ec 0c             	sub    $0xc,%esp
  8014d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014dd:	50                   	push   %eax
  8014de:	56                   	push   %esi
  8014df:	57                   	push   %edi
  8014e0:	56                   	push   %esi
  8014e1:	6a 00                	push   $0x0
  8014e3:	e8 d7 fb ff ff       	call   8010bf <sys_page_map>
		if (r < 0) {
  8014e8:	83 c4 20             	add    $0x20,%esp
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	0f 89 b1 00 00 00    	jns    8015a4 <fork+0x192>
		    	panic("sys page map fault %e");
  8014f3:	83 ec 04             	sub    $0x4,%esp
  8014f6:	68 be 2b 80 00       	push   $0x802bbe
  8014fb:	6a 54                	push   $0x54
  8014fd:	68 8c 2b 80 00       	push   $0x802b8c
  801502:	e8 14 f1 ff ff       	call   80061b <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801507:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80150e:	f6 c2 02             	test   $0x2,%dl
  801511:	75 0c                	jne    80151f <fork+0x10d>
  801513:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151a:	f6 c4 08             	test   $0x8,%ah
  80151d:	74 5b                	je     80157a <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80151f:	83 ec 0c             	sub    $0xc,%esp
  801522:	68 05 08 00 00       	push   $0x805
  801527:	56                   	push   %esi
  801528:	57                   	push   %edi
  801529:	56                   	push   %esi
  80152a:	6a 00                	push   $0x0
  80152c:	e8 8e fb ff ff       	call   8010bf <sys_page_map>
		if (r < 0) {
  801531:	83 c4 20             	add    $0x20,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	79 14                	jns    80154c <fork+0x13a>
		    	panic("sys page map fault %e");
  801538:	83 ec 04             	sub    $0x4,%esp
  80153b:	68 be 2b 80 00       	push   $0x802bbe
  801540:	6a 5b                	push   $0x5b
  801542:	68 8c 2b 80 00       	push   $0x802b8c
  801547:	e8 cf f0 ff ff       	call   80061b <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  80154c:	83 ec 0c             	sub    $0xc,%esp
  80154f:	68 05 08 00 00       	push   $0x805
  801554:	56                   	push   %esi
  801555:	6a 00                	push   $0x0
  801557:	56                   	push   %esi
  801558:	6a 00                	push   $0x0
  80155a:	e8 60 fb ff ff       	call   8010bf <sys_page_map>
		if (r < 0) {
  80155f:	83 c4 20             	add    $0x20,%esp
  801562:	85 c0                	test   %eax,%eax
  801564:	79 3e                	jns    8015a4 <fork+0x192>
		    	panic("sys page map fault %e");
  801566:	83 ec 04             	sub    $0x4,%esp
  801569:	68 be 2b 80 00       	push   $0x802bbe
  80156e:	6a 5f                	push   $0x5f
  801570:	68 8c 2b 80 00       	push   $0x802b8c
  801575:	e8 a1 f0 ff ff       	call   80061b <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	6a 05                	push   $0x5
  80157f:	56                   	push   %esi
  801580:	57                   	push   %edi
  801581:	56                   	push   %esi
  801582:	6a 00                	push   $0x0
  801584:	e8 36 fb ff ff       	call   8010bf <sys_page_map>
		if (r < 0) {
  801589:	83 c4 20             	add    $0x20,%esp
  80158c:	85 c0                	test   %eax,%eax
  80158e:	79 14                	jns    8015a4 <fork+0x192>
		    	panic("sys page map fault %e");
  801590:	83 ec 04             	sub    $0x4,%esp
  801593:	68 be 2b 80 00       	push   $0x802bbe
  801598:	6a 64                	push   $0x64
  80159a:	68 8c 2b 80 00       	push   $0x802b8c
  80159f:	e8 77 f0 ff ff       	call   80061b <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8015a4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8015aa:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8015b0:	0f 85 de fe ff ff    	jne    801494 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  8015b6:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8015bb:	8b 40 70             	mov    0x70(%eax),%eax
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	50                   	push   %eax
  8015c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015c5:	57                   	push   %edi
  8015c6:	e8 fc fb ff ff       	call   8011c7 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	6a 02                	push   $0x2
  8015d0:	57                   	push   %edi
  8015d1:	e8 6d fb ff ff       	call   801143 <sys_env_set_status>
	
	return envid;
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8015db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015de:	5b                   	pop    %ebx
  8015df:	5e                   	pop    %esi
  8015e0:	5f                   	pop    %edi
  8015e1:	5d                   	pop    %ebp
  8015e2:	c3                   	ret    

008015e3 <sfork>:

envid_t
sfork(void)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8015e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    

008015ed <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	56                   	push   %esi
  8015f1:	53                   	push   %ebx
  8015f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8015f5:	89 1d b8 40 80 00    	mov    %ebx,0x8040b8
	cprintf("in fork.c thread create. func: %x\n", func);
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	68 d4 2b 80 00       	push   $0x802bd4
  801604:	e8 eb f0 ff ff       	call   8006f4 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  801609:	c7 04 24 e1 05 80 00 	movl   $0x8005e1,(%esp)
  801610:	e8 58 fc ff ff       	call   80126d <sys_thread_create>
  801615:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  801617:	83 c4 08             	add    $0x8,%esp
  80161a:	53                   	push   %ebx
  80161b:	68 d4 2b 80 00       	push   $0x802bd4
  801620:	e8 cf f0 ff ff       	call   8006f4 <cprintf>
	return id;
	//return 0;
}
  801625:	89 f0                	mov    %esi,%eax
  801627:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162a:	5b                   	pop    %ebx
  80162b:	5e                   	pop    %esi
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    

0080162e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801631:	8b 45 08             	mov    0x8(%ebp),%eax
  801634:	05 00 00 00 30       	add    $0x30000000,%eax
  801639:	c1 e8 0c             	shr    $0xc,%eax
}
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801641:	8b 45 08             	mov    0x8(%ebp),%eax
  801644:	05 00 00 00 30       	add    $0x30000000,%eax
  801649:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80164e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80165b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801660:	89 c2                	mov    %eax,%edx
  801662:	c1 ea 16             	shr    $0x16,%edx
  801665:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80166c:	f6 c2 01             	test   $0x1,%dl
  80166f:	74 11                	je     801682 <fd_alloc+0x2d>
  801671:	89 c2                	mov    %eax,%edx
  801673:	c1 ea 0c             	shr    $0xc,%edx
  801676:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80167d:	f6 c2 01             	test   $0x1,%dl
  801680:	75 09                	jne    80168b <fd_alloc+0x36>
			*fd_store = fd;
  801682:	89 01                	mov    %eax,(%ecx)
			return 0;
  801684:	b8 00 00 00 00       	mov    $0x0,%eax
  801689:	eb 17                	jmp    8016a2 <fd_alloc+0x4d>
  80168b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801690:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801695:	75 c9                	jne    801660 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801697:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80169d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016a2:	5d                   	pop    %ebp
  8016a3:	c3                   	ret    

008016a4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016aa:	83 f8 1f             	cmp    $0x1f,%eax
  8016ad:	77 36                	ja     8016e5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016af:	c1 e0 0c             	shl    $0xc,%eax
  8016b2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	c1 ea 16             	shr    $0x16,%edx
  8016bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016c3:	f6 c2 01             	test   $0x1,%dl
  8016c6:	74 24                	je     8016ec <fd_lookup+0x48>
  8016c8:	89 c2                	mov    %eax,%edx
  8016ca:	c1 ea 0c             	shr    $0xc,%edx
  8016cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016d4:	f6 c2 01             	test   $0x1,%dl
  8016d7:	74 1a                	je     8016f3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016dc:	89 02                	mov    %eax,(%edx)
	return 0;
  8016de:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e3:	eb 13                	jmp    8016f8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ea:	eb 0c                	jmp    8016f8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016f1:	eb 05                	jmp    8016f8 <fd_lookup+0x54>
  8016f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801703:	ba 78 2c 80 00       	mov    $0x802c78,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801708:	eb 13                	jmp    80171d <dev_lookup+0x23>
  80170a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80170d:	39 08                	cmp    %ecx,(%eax)
  80170f:	75 0c                	jne    80171d <dev_lookup+0x23>
			*dev = devtab[i];
  801711:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801714:	89 01                	mov    %eax,(%ecx)
			return 0;
  801716:	b8 00 00 00 00       	mov    $0x0,%eax
  80171b:	eb 2e                	jmp    80174b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80171d:	8b 02                	mov    (%edx),%eax
  80171f:	85 c0                	test   %eax,%eax
  801721:	75 e7                	jne    80170a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801723:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801728:	8b 40 54             	mov    0x54(%eax),%eax
  80172b:	83 ec 04             	sub    $0x4,%esp
  80172e:	51                   	push   %ecx
  80172f:	50                   	push   %eax
  801730:	68 f8 2b 80 00       	push   $0x802bf8
  801735:	e8 ba ef ff ff       	call   8006f4 <cprintf>
	*dev = 0;
  80173a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80174b:	c9                   	leave  
  80174c:	c3                   	ret    

0080174d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
  801752:	83 ec 10             	sub    $0x10,%esp
  801755:	8b 75 08             	mov    0x8(%ebp),%esi
  801758:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80175b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175e:	50                   	push   %eax
  80175f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801765:	c1 e8 0c             	shr    $0xc,%eax
  801768:	50                   	push   %eax
  801769:	e8 36 ff ff ff       	call   8016a4 <fd_lookup>
  80176e:	83 c4 08             	add    $0x8,%esp
  801771:	85 c0                	test   %eax,%eax
  801773:	78 05                	js     80177a <fd_close+0x2d>
	    || fd != fd2)
  801775:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801778:	74 0c                	je     801786 <fd_close+0x39>
		return (must_exist ? r : 0);
  80177a:	84 db                	test   %bl,%bl
  80177c:	ba 00 00 00 00       	mov    $0x0,%edx
  801781:	0f 44 c2             	cmove  %edx,%eax
  801784:	eb 41                	jmp    8017c7 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178c:	50                   	push   %eax
  80178d:	ff 36                	pushl  (%esi)
  80178f:	e8 66 ff ff ff       	call   8016fa <dev_lookup>
  801794:	89 c3                	mov    %eax,%ebx
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 1a                	js     8017b7 <fd_close+0x6a>
		if (dev->dev_close)
  80179d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8017a3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	74 0b                	je     8017b7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8017ac:	83 ec 0c             	sub    $0xc,%esp
  8017af:	56                   	push   %esi
  8017b0:	ff d0                	call   *%eax
  8017b2:	89 c3                	mov    %eax,%ebx
  8017b4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017b7:	83 ec 08             	sub    $0x8,%esp
  8017ba:	56                   	push   %esi
  8017bb:	6a 00                	push   $0x0
  8017bd:	e8 3f f9 ff ff       	call   801101 <sys_page_unmap>
	return r;
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	89 d8                	mov    %ebx,%eax
}
  8017c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ca:	5b                   	pop    %ebx
  8017cb:	5e                   	pop    %esi
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d7:	50                   	push   %eax
  8017d8:	ff 75 08             	pushl  0x8(%ebp)
  8017db:	e8 c4 fe ff ff       	call   8016a4 <fd_lookup>
  8017e0:	83 c4 08             	add    $0x8,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 10                	js     8017f7 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	6a 01                	push   $0x1
  8017ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ef:	e8 59 ff ff ff       	call   80174d <fd_close>
  8017f4:	83 c4 10             	add    $0x10,%esp
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <close_all>:

void
close_all(void)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801800:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801805:	83 ec 0c             	sub    $0xc,%esp
  801808:	53                   	push   %ebx
  801809:	e8 c0 ff ff ff       	call   8017ce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80180e:	83 c3 01             	add    $0x1,%ebx
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	83 fb 20             	cmp    $0x20,%ebx
  801817:	75 ec                	jne    801805 <close_all+0xc>
		close(i);
}
  801819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181c:	c9                   	leave  
  80181d:	c3                   	ret    

0080181e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	57                   	push   %edi
  801822:	56                   	push   %esi
  801823:	53                   	push   %ebx
  801824:	83 ec 2c             	sub    $0x2c,%esp
  801827:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80182a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80182d:	50                   	push   %eax
  80182e:	ff 75 08             	pushl  0x8(%ebp)
  801831:	e8 6e fe ff ff       	call   8016a4 <fd_lookup>
  801836:	83 c4 08             	add    $0x8,%esp
  801839:	85 c0                	test   %eax,%eax
  80183b:	0f 88 c1 00 00 00    	js     801902 <dup+0xe4>
		return r;
	close(newfdnum);
  801841:	83 ec 0c             	sub    $0xc,%esp
  801844:	56                   	push   %esi
  801845:	e8 84 ff ff ff       	call   8017ce <close>

	newfd = INDEX2FD(newfdnum);
  80184a:	89 f3                	mov    %esi,%ebx
  80184c:	c1 e3 0c             	shl    $0xc,%ebx
  80184f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801855:	83 c4 04             	add    $0x4,%esp
  801858:	ff 75 e4             	pushl  -0x1c(%ebp)
  80185b:	e8 de fd ff ff       	call   80163e <fd2data>
  801860:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801862:	89 1c 24             	mov    %ebx,(%esp)
  801865:	e8 d4 fd ff ff       	call   80163e <fd2data>
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801870:	89 f8                	mov    %edi,%eax
  801872:	c1 e8 16             	shr    $0x16,%eax
  801875:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80187c:	a8 01                	test   $0x1,%al
  80187e:	74 37                	je     8018b7 <dup+0x99>
  801880:	89 f8                	mov    %edi,%eax
  801882:	c1 e8 0c             	shr    $0xc,%eax
  801885:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80188c:	f6 c2 01             	test   $0x1,%dl
  80188f:	74 26                	je     8018b7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801891:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801898:	83 ec 0c             	sub    $0xc,%esp
  80189b:	25 07 0e 00 00       	and    $0xe07,%eax
  8018a0:	50                   	push   %eax
  8018a1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8018a4:	6a 00                	push   $0x0
  8018a6:	57                   	push   %edi
  8018a7:	6a 00                	push   $0x0
  8018a9:	e8 11 f8 ff ff       	call   8010bf <sys_page_map>
  8018ae:	89 c7                	mov    %eax,%edi
  8018b0:	83 c4 20             	add    $0x20,%esp
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 2e                	js     8018e5 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018ba:	89 d0                	mov    %edx,%eax
  8018bc:	c1 e8 0c             	shr    $0xc,%eax
  8018bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018c6:	83 ec 0c             	sub    $0xc,%esp
  8018c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8018ce:	50                   	push   %eax
  8018cf:	53                   	push   %ebx
  8018d0:	6a 00                	push   $0x0
  8018d2:	52                   	push   %edx
  8018d3:	6a 00                	push   $0x0
  8018d5:	e8 e5 f7 ff ff       	call   8010bf <sys_page_map>
  8018da:	89 c7                	mov    %eax,%edi
  8018dc:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8018df:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018e1:	85 ff                	test   %edi,%edi
  8018e3:	79 1d                	jns    801902 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	53                   	push   %ebx
  8018e9:	6a 00                	push   $0x0
  8018eb:	e8 11 f8 ff ff       	call   801101 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8018f0:	83 c4 08             	add    $0x8,%esp
  8018f3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8018f6:	6a 00                	push   $0x0
  8018f8:	e8 04 f8 ff ff       	call   801101 <sys_page_unmap>
	return r;
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	89 f8                	mov    %edi,%eax
}
  801902:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801905:	5b                   	pop    %ebx
  801906:	5e                   	pop    %esi
  801907:	5f                   	pop    %edi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	53                   	push   %ebx
  80190e:	83 ec 14             	sub    $0x14,%esp
  801911:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801914:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801917:	50                   	push   %eax
  801918:	53                   	push   %ebx
  801919:	e8 86 fd ff ff       	call   8016a4 <fd_lookup>
  80191e:	83 c4 08             	add    $0x8,%esp
  801921:	89 c2                	mov    %eax,%edx
  801923:	85 c0                	test   %eax,%eax
  801925:	78 6d                	js     801994 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192d:	50                   	push   %eax
  80192e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801931:	ff 30                	pushl  (%eax)
  801933:	e8 c2 fd ff ff       	call   8016fa <dev_lookup>
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 4c                	js     80198b <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80193f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801942:	8b 42 08             	mov    0x8(%edx),%eax
  801945:	83 e0 03             	and    $0x3,%eax
  801948:	83 f8 01             	cmp    $0x1,%eax
  80194b:	75 21                	jne    80196e <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80194d:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801952:	8b 40 54             	mov    0x54(%eax),%eax
  801955:	83 ec 04             	sub    $0x4,%esp
  801958:	53                   	push   %ebx
  801959:	50                   	push   %eax
  80195a:	68 3c 2c 80 00       	push   $0x802c3c
  80195f:	e8 90 ed ff ff       	call   8006f4 <cprintf>
		return -E_INVAL;
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80196c:	eb 26                	jmp    801994 <read+0x8a>
	}
	if (!dev->dev_read)
  80196e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801971:	8b 40 08             	mov    0x8(%eax),%eax
  801974:	85 c0                	test   %eax,%eax
  801976:	74 17                	je     80198f <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  801978:	83 ec 04             	sub    $0x4,%esp
  80197b:	ff 75 10             	pushl  0x10(%ebp)
  80197e:	ff 75 0c             	pushl  0xc(%ebp)
  801981:	52                   	push   %edx
  801982:	ff d0                	call   *%eax
  801984:	89 c2                	mov    %eax,%edx
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	eb 09                	jmp    801994 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80198b:	89 c2                	mov    %eax,%edx
  80198d:	eb 05                	jmp    801994 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80198f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  801994:	89 d0                	mov    %edx,%eax
  801996:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	57                   	push   %edi
  80199f:	56                   	push   %esi
  8019a0:	53                   	push   %ebx
  8019a1:	83 ec 0c             	sub    $0xc,%esp
  8019a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019af:	eb 21                	jmp    8019d2 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019b1:	83 ec 04             	sub    $0x4,%esp
  8019b4:	89 f0                	mov    %esi,%eax
  8019b6:	29 d8                	sub    %ebx,%eax
  8019b8:	50                   	push   %eax
  8019b9:	89 d8                	mov    %ebx,%eax
  8019bb:	03 45 0c             	add    0xc(%ebp),%eax
  8019be:	50                   	push   %eax
  8019bf:	57                   	push   %edi
  8019c0:	e8 45 ff ff ff       	call   80190a <read>
		if (m < 0)
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 10                	js     8019dc <readn+0x41>
			return m;
		if (m == 0)
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	74 0a                	je     8019da <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019d0:	01 c3                	add    %eax,%ebx
  8019d2:	39 f3                	cmp    %esi,%ebx
  8019d4:	72 db                	jb     8019b1 <readn+0x16>
  8019d6:	89 d8                	mov    %ebx,%eax
  8019d8:	eb 02                	jmp    8019dc <readn+0x41>
  8019da:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8019dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019df:	5b                   	pop    %ebx
  8019e0:	5e                   	pop    %esi
  8019e1:	5f                   	pop    %edi
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    

008019e4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	53                   	push   %ebx
  8019e8:	83 ec 14             	sub    $0x14,%esp
  8019eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f1:	50                   	push   %eax
  8019f2:	53                   	push   %ebx
  8019f3:	e8 ac fc ff ff       	call   8016a4 <fd_lookup>
  8019f8:	83 c4 08             	add    $0x8,%esp
  8019fb:	89 c2                	mov    %eax,%edx
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 68                	js     801a69 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a01:	83 ec 08             	sub    $0x8,%esp
  801a04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a07:	50                   	push   %eax
  801a08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0b:	ff 30                	pushl  (%eax)
  801a0d:	e8 e8 fc ff ff       	call   8016fa <dev_lookup>
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	85 c0                	test   %eax,%eax
  801a17:	78 47                	js     801a60 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a20:	75 21                	jne    801a43 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a22:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801a27:	8b 40 54             	mov    0x54(%eax),%eax
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	53                   	push   %ebx
  801a2e:	50                   	push   %eax
  801a2f:	68 58 2c 80 00       	push   $0x802c58
  801a34:	e8 bb ec ff ff       	call   8006f4 <cprintf>
		return -E_INVAL;
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801a41:	eb 26                	jmp    801a69 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a46:	8b 52 0c             	mov    0xc(%edx),%edx
  801a49:	85 d2                	test   %edx,%edx
  801a4b:	74 17                	je     801a64 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a4d:	83 ec 04             	sub    $0x4,%esp
  801a50:	ff 75 10             	pushl  0x10(%ebp)
  801a53:	ff 75 0c             	pushl  0xc(%ebp)
  801a56:	50                   	push   %eax
  801a57:	ff d2                	call   *%edx
  801a59:	89 c2                	mov    %eax,%edx
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	eb 09                	jmp    801a69 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a60:	89 c2                	mov    %eax,%edx
  801a62:	eb 05                	jmp    801a69 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a64:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801a69:	89 d0                	mov    %edx,%eax
  801a6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6e:	c9                   	leave  
  801a6f:	c3                   	ret    

00801a70 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a76:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a79:	50                   	push   %eax
  801a7a:	ff 75 08             	pushl  0x8(%ebp)
  801a7d:	e8 22 fc ff ff       	call   8016a4 <fd_lookup>
  801a82:	83 c4 08             	add    $0x8,%esp
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 0e                	js     801a97 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801a89:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a8f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801a92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    

00801a99 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 14             	sub    $0x14,%esp
  801aa0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aa6:	50                   	push   %eax
  801aa7:	53                   	push   %ebx
  801aa8:	e8 f7 fb ff ff       	call   8016a4 <fd_lookup>
  801aad:	83 c4 08             	add    $0x8,%esp
  801ab0:	89 c2                	mov    %eax,%edx
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	78 65                	js     801b1b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ab6:	83 ec 08             	sub    $0x8,%esp
  801ab9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abc:	50                   	push   %eax
  801abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac0:	ff 30                	pushl  (%eax)
  801ac2:	e8 33 fc ff ff       	call   8016fa <dev_lookup>
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 44                	js     801b12 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ace:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ad5:	75 21                	jne    801af8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ad7:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801adc:	8b 40 54             	mov    0x54(%eax),%eax
  801adf:	83 ec 04             	sub    $0x4,%esp
  801ae2:	53                   	push   %ebx
  801ae3:	50                   	push   %eax
  801ae4:	68 18 2c 80 00       	push   $0x802c18
  801ae9:	e8 06 ec ff ff       	call   8006f4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801af6:	eb 23                	jmp    801b1b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801af8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801afb:	8b 52 18             	mov    0x18(%edx),%edx
  801afe:	85 d2                	test   %edx,%edx
  801b00:	74 14                	je     801b16 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b02:	83 ec 08             	sub    $0x8,%esp
  801b05:	ff 75 0c             	pushl  0xc(%ebp)
  801b08:	50                   	push   %eax
  801b09:	ff d2                	call   *%edx
  801b0b:	89 c2                	mov    %eax,%edx
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	eb 09                	jmp    801b1b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b12:	89 c2                	mov    %eax,%edx
  801b14:	eb 05                	jmp    801b1b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b16:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801b1b:	89 d0                	mov    %edx,%eax
  801b1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b20:	c9                   	leave  
  801b21:	c3                   	ret    

00801b22 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	53                   	push   %ebx
  801b26:	83 ec 14             	sub    $0x14,%esp
  801b29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b2f:	50                   	push   %eax
  801b30:	ff 75 08             	pushl  0x8(%ebp)
  801b33:	e8 6c fb ff ff       	call   8016a4 <fd_lookup>
  801b38:	83 c4 08             	add    $0x8,%esp
  801b3b:	89 c2                	mov    %eax,%edx
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	78 58                	js     801b99 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b41:	83 ec 08             	sub    $0x8,%esp
  801b44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b47:	50                   	push   %eax
  801b48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4b:	ff 30                	pushl  (%eax)
  801b4d:	e8 a8 fb ff ff       	call   8016fa <dev_lookup>
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	85 c0                	test   %eax,%eax
  801b57:	78 37                	js     801b90 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b60:	74 32                	je     801b94 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b62:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b65:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b6c:	00 00 00 
	stat->st_isdir = 0;
  801b6f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b76:	00 00 00 
	stat->st_dev = dev;
  801b79:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b7f:	83 ec 08             	sub    $0x8,%esp
  801b82:	53                   	push   %ebx
  801b83:	ff 75 f0             	pushl  -0x10(%ebp)
  801b86:	ff 50 14             	call   *0x14(%eax)
  801b89:	89 c2                	mov    %eax,%edx
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	eb 09                	jmp    801b99 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b90:	89 c2                	mov    %eax,%edx
  801b92:	eb 05                	jmp    801b99 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801b94:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801b99:	89 d0                	mov    %edx,%eax
  801b9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9e:	c9                   	leave  
  801b9f:	c3                   	ret    

00801ba0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	56                   	push   %esi
  801ba4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ba5:	83 ec 08             	sub    $0x8,%esp
  801ba8:	6a 00                	push   $0x0
  801baa:	ff 75 08             	pushl  0x8(%ebp)
  801bad:	e8 e3 01 00 00       	call   801d95 <open>
  801bb2:	89 c3                	mov    %eax,%ebx
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	78 1b                	js     801bd6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801bbb:	83 ec 08             	sub    $0x8,%esp
  801bbe:	ff 75 0c             	pushl  0xc(%ebp)
  801bc1:	50                   	push   %eax
  801bc2:	e8 5b ff ff ff       	call   801b22 <fstat>
  801bc7:	89 c6                	mov    %eax,%esi
	close(fd);
  801bc9:	89 1c 24             	mov    %ebx,(%esp)
  801bcc:	e8 fd fb ff ff       	call   8017ce <close>
	return r;
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	89 f0                	mov    %esi,%eax
}
  801bd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd9:	5b                   	pop    %ebx
  801bda:	5e                   	pop    %esi
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	56                   	push   %esi
  801be1:	53                   	push   %ebx
  801be2:	89 c6                	mov    %eax,%esi
  801be4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801be6:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801bed:	75 12                	jne    801c01 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801bef:	83 ec 0c             	sub    $0xc,%esp
  801bf2:	6a 01                	push   $0x1
  801bf4:	e8 f9 07 00 00       	call   8023f2 <ipc_find_env>
  801bf9:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  801bfe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c01:	6a 07                	push   $0x7
  801c03:	68 00 50 80 00       	push   $0x805000
  801c08:	56                   	push   %esi
  801c09:	ff 35 ac 40 80 00    	pushl  0x8040ac
  801c0f:	e8 7c 07 00 00       	call   802390 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c14:	83 c4 0c             	add    $0xc,%esp
  801c17:	6a 00                	push   $0x0
  801c19:	53                   	push   %ebx
  801c1a:	6a 00                	push   $0x0
  801c1c:	e8 f7 06 00 00       	call   802318 <ipc_recv>
}
  801c21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    

00801c28 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c31:	8b 40 0c             	mov    0xc(%eax),%eax
  801c34:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c41:	ba 00 00 00 00       	mov    $0x0,%edx
  801c46:	b8 02 00 00 00       	mov    $0x2,%eax
  801c4b:	e8 8d ff ff ff       	call   801bdd <fsipc>
}
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c58:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5b:	8b 40 0c             	mov    0xc(%eax),%eax
  801c5e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c63:	ba 00 00 00 00       	mov    $0x0,%edx
  801c68:	b8 06 00 00 00       	mov    $0x6,%eax
  801c6d:	e8 6b ff ff ff       	call   801bdd <fsipc>
}
  801c72:	c9                   	leave  
  801c73:	c3                   	ret    

00801c74 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	53                   	push   %ebx
  801c78:	83 ec 04             	sub    $0x4,%esp
  801c7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	8b 40 0c             	mov    0xc(%eax),%eax
  801c84:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c89:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8e:	b8 05 00 00 00       	mov    $0x5,%eax
  801c93:	e8 45 ff ff ff       	call   801bdd <fsipc>
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 2c                	js     801cc8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c9c:	83 ec 08             	sub    $0x8,%esp
  801c9f:	68 00 50 80 00       	push   $0x805000
  801ca4:	53                   	push   %ebx
  801ca5:	e8 cf ef ff ff       	call   800c79 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801caa:	a1 80 50 80 00       	mov    0x805080,%eax
  801caf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cb5:	a1 84 50 80 00       	mov    0x805084,%eax
  801cba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ccb:	c9                   	leave  
  801ccc:	c3                   	ret    

00801ccd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	83 ec 0c             	sub    $0xc,%esp
  801cd3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  801cd9:	8b 52 0c             	mov    0xc(%edx),%edx
  801cdc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801ce2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ce7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801cec:	0f 47 c2             	cmova  %edx,%eax
  801cef:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801cf4:	50                   	push   %eax
  801cf5:	ff 75 0c             	pushl  0xc(%ebp)
  801cf8:	68 08 50 80 00       	push   $0x805008
  801cfd:	e8 09 f1 ff ff       	call   800e0b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801d02:	ba 00 00 00 00       	mov    $0x0,%edx
  801d07:	b8 04 00 00 00       	mov    $0x4,%eax
  801d0c:	e8 cc fe ff ff       	call   801bdd <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1e:	8b 40 0c             	mov    0xc(%eax),%eax
  801d21:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801d26:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d2c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d31:	b8 03 00 00 00       	mov    $0x3,%eax
  801d36:	e8 a2 fe ff ff       	call   801bdd <fsipc>
  801d3b:	89 c3                	mov    %eax,%ebx
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	78 4b                	js     801d8c <devfile_read+0x79>
		return r;
	assert(r <= n);
  801d41:	39 c6                	cmp    %eax,%esi
  801d43:	73 16                	jae    801d5b <devfile_read+0x48>
  801d45:	68 88 2c 80 00       	push   $0x802c88
  801d4a:	68 8f 2c 80 00       	push   $0x802c8f
  801d4f:	6a 7c                	push   $0x7c
  801d51:	68 a4 2c 80 00       	push   $0x802ca4
  801d56:	e8 c0 e8 ff ff       	call   80061b <_panic>
	assert(r <= PGSIZE);
  801d5b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801d60:	7e 16                	jle    801d78 <devfile_read+0x65>
  801d62:	68 af 2c 80 00       	push   $0x802caf
  801d67:	68 8f 2c 80 00       	push   $0x802c8f
  801d6c:	6a 7d                	push   $0x7d
  801d6e:	68 a4 2c 80 00       	push   $0x802ca4
  801d73:	e8 a3 e8 ff ff       	call   80061b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d78:	83 ec 04             	sub    $0x4,%esp
  801d7b:	50                   	push   %eax
  801d7c:	68 00 50 80 00       	push   $0x805000
  801d81:	ff 75 0c             	pushl  0xc(%ebp)
  801d84:	e8 82 f0 ff ff       	call   800e0b <memmove>
	return r;
  801d89:	83 c4 10             	add    $0x10,%esp
}
  801d8c:	89 d8                	mov    %ebx,%eax
  801d8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d91:	5b                   	pop    %ebx
  801d92:	5e                   	pop    %esi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	53                   	push   %ebx
  801d99:	83 ec 20             	sub    $0x20,%esp
  801d9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801d9f:	53                   	push   %ebx
  801da0:	e8 9b ee ff ff       	call   800c40 <strlen>
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801dad:	7f 67                	jg     801e16 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801daf:	83 ec 0c             	sub    $0xc,%esp
  801db2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db5:	50                   	push   %eax
  801db6:	e8 9a f8 ff ff       	call   801655 <fd_alloc>
  801dbb:	83 c4 10             	add    $0x10,%esp
		return r;
  801dbe:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	78 57                	js     801e1b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	53                   	push   %ebx
  801dc8:	68 00 50 80 00       	push   $0x805000
  801dcd:	e8 a7 ee ff ff       	call   800c79 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801dda:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ddd:	b8 01 00 00 00       	mov    $0x1,%eax
  801de2:	e8 f6 fd ff ff       	call   801bdd <fsipc>
  801de7:	89 c3                	mov    %eax,%ebx
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	85 c0                	test   %eax,%eax
  801dee:	79 14                	jns    801e04 <open+0x6f>
		fd_close(fd, 0);
  801df0:	83 ec 08             	sub    $0x8,%esp
  801df3:	6a 00                	push   $0x0
  801df5:	ff 75 f4             	pushl  -0xc(%ebp)
  801df8:	e8 50 f9 ff ff       	call   80174d <fd_close>
		return r;
  801dfd:	83 c4 10             	add    $0x10,%esp
  801e00:	89 da                	mov    %ebx,%edx
  801e02:	eb 17                	jmp    801e1b <open+0x86>
	}

	return fd2num(fd);
  801e04:	83 ec 0c             	sub    $0xc,%esp
  801e07:	ff 75 f4             	pushl  -0xc(%ebp)
  801e0a:	e8 1f f8 ff ff       	call   80162e <fd2num>
  801e0f:	89 c2                	mov    %eax,%edx
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	eb 05                	jmp    801e1b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e16:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e1b:	89 d0                	mov    %edx,%eax
  801e1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    

00801e22 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e28:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2d:	b8 08 00 00 00       	mov    $0x8,%eax
  801e32:	e8 a6 fd ff ff       	call   801bdd <fsipc>
}
  801e37:	c9                   	leave  
  801e38:	c3                   	ret    

00801e39 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e39:	55                   	push   %ebp
  801e3a:	89 e5                	mov    %esp,%ebp
  801e3c:	56                   	push   %esi
  801e3d:	53                   	push   %ebx
  801e3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	ff 75 08             	pushl  0x8(%ebp)
  801e47:	e8 f2 f7 ff ff       	call   80163e <fd2data>
  801e4c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e4e:	83 c4 08             	add    $0x8,%esp
  801e51:	68 bb 2c 80 00       	push   $0x802cbb
  801e56:	53                   	push   %ebx
  801e57:	e8 1d ee ff ff       	call   800c79 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e5c:	8b 46 04             	mov    0x4(%esi),%eax
  801e5f:	2b 06                	sub    (%esi),%eax
  801e61:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e67:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e6e:	00 00 00 
	stat->st_dev = &devpipe;
  801e71:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801e78:	30 80 00 
	return 0;
}
  801e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5d                   	pop    %ebp
  801e86:	c3                   	ret    

00801e87 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e87:	55                   	push   %ebp
  801e88:	89 e5                	mov    %esp,%ebp
  801e8a:	53                   	push   %ebx
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e91:	53                   	push   %ebx
  801e92:	6a 00                	push   $0x0
  801e94:	e8 68 f2 ff ff       	call   801101 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e99:	89 1c 24             	mov    %ebx,(%esp)
  801e9c:	e8 9d f7 ff ff       	call   80163e <fd2data>
  801ea1:	83 c4 08             	add    $0x8,%esp
  801ea4:	50                   	push   %eax
  801ea5:	6a 00                	push   $0x0
  801ea7:	e8 55 f2 ff ff       	call   801101 <sys_page_unmap>
}
  801eac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	57                   	push   %edi
  801eb5:	56                   	push   %esi
  801eb6:	53                   	push   %ebx
  801eb7:	83 ec 1c             	sub    $0x1c,%esp
  801eba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ebd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ebf:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801ec4:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	ff 75 e0             	pushl  -0x20(%ebp)
  801ecd:	e8 60 05 00 00       	call   802432 <pageref>
  801ed2:	89 c3                	mov    %eax,%ebx
  801ed4:	89 3c 24             	mov    %edi,(%esp)
  801ed7:	e8 56 05 00 00       	call   802432 <pageref>
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	39 c3                	cmp    %eax,%ebx
  801ee1:	0f 94 c1             	sete   %cl
  801ee4:	0f b6 c9             	movzbl %cl,%ecx
  801ee7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801eea:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801ef0:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801ef3:	39 ce                	cmp    %ecx,%esi
  801ef5:	74 1b                	je     801f12 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ef7:	39 c3                	cmp    %eax,%ebx
  801ef9:	75 c4                	jne    801ebf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801efb:	8b 42 64             	mov    0x64(%edx),%eax
  801efe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f01:	50                   	push   %eax
  801f02:	56                   	push   %esi
  801f03:	68 c2 2c 80 00       	push   $0x802cc2
  801f08:	e8 e7 e7 ff ff       	call   8006f4 <cprintf>
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	eb ad                	jmp    801ebf <_pipeisclosed+0xe>
	}
}
  801f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    

00801f1d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	57                   	push   %edi
  801f21:	56                   	push   %esi
  801f22:	53                   	push   %ebx
  801f23:	83 ec 28             	sub    $0x28,%esp
  801f26:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f29:	56                   	push   %esi
  801f2a:	e8 0f f7 ff ff       	call   80163e <fd2data>
  801f2f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f31:	83 c4 10             	add    $0x10,%esp
  801f34:	bf 00 00 00 00       	mov    $0x0,%edi
  801f39:	eb 4b                	jmp    801f86 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f3b:	89 da                	mov    %ebx,%edx
  801f3d:	89 f0                	mov    %esi,%eax
  801f3f:	e8 6d ff ff ff       	call   801eb1 <_pipeisclosed>
  801f44:	85 c0                	test   %eax,%eax
  801f46:	75 48                	jne    801f90 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f48:	e8 10 f1 ff ff       	call   80105d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f4d:	8b 43 04             	mov    0x4(%ebx),%eax
  801f50:	8b 0b                	mov    (%ebx),%ecx
  801f52:	8d 51 20             	lea    0x20(%ecx),%edx
  801f55:	39 d0                	cmp    %edx,%eax
  801f57:	73 e2                	jae    801f3b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f5c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f60:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f63:	89 c2                	mov    %eax,%edx
  801f65:	c1 fa 1f             	sar    $0x1f,%edx
  801f68:	89 d1                	mov    %edx,%ecx
  801f6a:	c1 e9 1b             	shr    $0x1b,%ecx
  801f6d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f70:	83 e2 1f             	and    $0x1f,%edx
  801f73:	29 ca                	sub    %ecx,%edx
  801f75:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f79:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f7d:	83 c0 01             	add    $0x1,%eax
  801f80:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f83:	83 c7 01             	add    $0x1,%edi
  801f86:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f89:	75 c2                	jne    801f4d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f8b:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8e:	eb 05                	jmp    801f95 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5e                   	pop    %esi
  801f9a:	5f                   	pop    %edi
  801f9b:	5d                   	pop    %ebp
  801f9c:	c3                   	ret    

00801f9d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	57                   	push   %edi
  801fa1:	56                   	push   %esi
  801fa2:	53                   	push   %ebx
  801fa3:	83 ec 18             	sub    $0x18,%esp
  801fa6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fa9:	57                   	push   %edi
  801faa:	e8 8f f6 ff ff       	call   80163e <fd2data>
  801faf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fb9:	eb 3d                	jmp    801ff8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fbb:	85 db                	test   %ebx,%ebx
  801fbd:	74 04                	je     801fc3 <devpipe_read+0x26>
				return i;
  801fbf:	89 d8                	mov    %ebx,%eax
  801fc1:	eb 44                	jmp    802007 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fc3:	89 f2                	mov    %esi,%edx
  801fc5:	89 f8                	mov    %edi,%eax
  801fc7:	e8 e5 fe ff ff       	call   801eb1 <_pipeisclosed>
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	75 32                	jne    802002 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fd0:	e8 88 f0 ff ff       	call   80105d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fd5:	8b 06                	mov    (%esi),%eax
  801fd7:	3b 46 04             	cmp    0x4(%esi),%eax
  801fda:	74 df                	je     801fbb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fdc:	99                   	cltd   
  801fdd:	c1 ea 1b             	shr    $0x1b,%edx
  801fe0:	01 d0                	add    %edx,%eax
  801fe2:	83 e0 1f             	and    $0x1f,%eax
  801fe5:	29 d0                	sub    %edx,%eax
  801fe7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fef:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ff2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff5:	83 c3 01             	add    $0x1,%ebx
  801ff8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ffb:	75 d8                	jne    801fd5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ffd:	8b 45 10             	mov    0x10(%ebp),%eax
  802000:	eb 05                	jmp    802007 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802002:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80200a:	5b                   	pop    %ebx
  80200b:	5e                   	pop    %esi
  80200c:	5f                   	pop    %edi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    

0080200f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802017:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201a:	50                   	push   %eax
  80201b:	e8 35 f6 ff ff       	call   801655 <fd_alloc>
  802020:	83 c4 10             	add    $0x10,%esp
  802023:	89 c2                	mov    %eax,%edx
  802025:	85 c0                	test   %eax,%eax
  802027:	0f 88 2c 01 00 00    	js     802159 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80202d:	83 ec 04             	sub    $0x4,%esp
  802030:	68 07 04 00 00       	push   $0x407
  802035:	ff 75 f4             	pushl  -0xc(%ebp)
  802038:	6a 00                	push   $0x0
  80203a:	e8 3d f0 ff ff       	call   80107c <sys_page_alloc>
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	89 c2                	mov    %eax,%edx
  802044:	85 c0                	test   %eax,%eax
  802046:	0f 88 0d 01 00 00    	js     802159 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80204c:	83 ec 0c             	sub    $0xc,%esp
  80204f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802052:	50                   	push   %eax
  802053:	e8 fd f5 ff ff       	call   801655 <fd_alloc>
  802058:	89 c3                	mov    %eax,%ebx
  80205a:	83 c4 10             	add    $0x10,%esp
  80205d:	85 c0                	test   %eax,%eax
  80205f:	0f 88 e2 00 00 00    	js     802147 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802065:	83 ec 04             	sub    $0x4,%esp
  802068:	68 07 04 00 00       	push   $0x407
  80206d:	ff 75 f0             	pushl  -0x10(%ebp)
  802070:	6a 00                	push   $0x0
  802072:	e8 05 f0 ff ff       	call   80107c <sys_page_alloc>
  802077:	89 c3                	mov    %eax,%ebx
  802079:	83 c4 10             	add    $0x10,%esp
  80207c:	85 c0                	test   %eax,%eax
  80207e:	0f 88 c3 00 00 00    	js     802147 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802084:	83 ec 0c             	sub    $0xc,%esp
  802087:	ff 75 f4             	pushl  -0xc(%ebp)
  80208a:	e8 af f5 ff ff       	call   80163e <fd2data>
  80208f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802091:	83 c4 0c             	add    $0xc,%esp
  802094:	68 07 04 00 00       	push   $0x407
  802099:	50                   	push   %eax
  80209a:	6a 00                	push   $0x0
  80209c:	e8 db ef ff ff       	call   80107c <sys_page_alloc>
  8020a1:	89 c3                	mov    %eax,%ebx
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	0f 88 89 00 00 00    	js     802137 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ae:	83 ec 0c             	sub    $0xc,%esp
  8020b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8020b4:	e8 85 f5 ff ff       	call   80163e <fd2data>
  8020b9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020c0:	50                   	push   %eax
  8020c1:	6a 00                	push   $0x0
  8020c3:	56                   	push   %esi
  8020c4:	6a 00                	push   $0x0
  8020c6:	e8 f4 ef ff ff       	call   8010bf <sys_page_map>
  8020cb:	89 c3                	mov    %eax,%ebx
  8020cd:	83 c4 20             	add    $0x20,%esp
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	78 55                	js     802129 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020d4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020dd:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020e9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8020ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020f7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020fe:	83 ec 0c             	sub    $0xc,%esp
  802101:	ff 75 f4             	pushl  -0xc(%ebp)
  802104:	e8 25 f5 ff ff       	call   80162e <fd2num>
  802109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80210c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80210e:	83 c4 04             	add    $0x4,%esp
  802111:	ff 75 f0             	pushl  -0x10(%ebp)
  802114:	e8 15 f5 ff ff       	call   80162e <fd2num>
  802119:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80211c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80211f:	83 c4 10             	add    $0x10,%esp
  802122:	ba 00 00 00 00       	mov    $0x0,%edx
  802127:	eb 30                	jmp    802159 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802129:	83 ec 08             	sub    $0x8,%esp
  80212c:	56                   	push   %esi
  80212d:	6a 00                	push   $0x0
  80212f:	e8 cd ef ff ff       	call   801101 <sys_page_unmap>
  802134:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802137:	83 ec 08             	sub    $0x8,%esp
  80213a:	ff 75 f0             	pushl  -0x10(%ebp)
  80213d:	6a 00                	push   $0x0
  80213f:	e8 bd ef ff ff       	call   801101 <sys_page_unmap>
  802144:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802147:	83 ec 08             	sub    $0x8,%esp
  80214a:	ff 75 f4             	pushl  -0xc(%ebp)
  80214d:	6a 00                	push   $0x0
  80214f:	e8 ad ef ff ff       	call   801101 <sys_page_unmap>
  802154:	83 c4 10             	add    $0x10,%esp
  802157:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802159:	89 d0                	mov    %edx,%eax
  80215b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80215e:	5b                   	pop    %ebx
  80215f:	5e                   	pop    %esi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    

00802162 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802168:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80216b:	50                   	push   %eax
  80216c:	ff 75 08             	pushl  0x8(%ebp)
  80216f:	e8 30 f5 ff ff       	call   8016a4 <fd_lookup>
  802174:	83 c4 10             	add    $0x10,%esp
  802177:	85 c0                	test   %eax,%eax
  802179:	78 18                	js     802193 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80217b:	83 ec 0c             	sub    $0xc,%esp
  80217e:	ff 75 f4             	pushl  -0xc(%ebp)
  802181:	e8 b8 f4 ff ff       	call   80163e <fd2data>
	return _pipeisclosed(fd, p);
  802186:	89 c2                	mov    %eax,%edx
  802188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218b:	e8 21 fd ff ff       	call   801eb1 <_pipeisclosed>
  802190:	83 c4 10             	add    $0x10,%esp
}
  802193:	c9                   	leave  
  802194:	c3                   	ret    

00802195 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802195:	55                   	push   %ebp
  802196:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802198:	b8 00 00 00 00       	mov    $0x0,%eax
  80219d:	5d                   	pop    %ebp
  80219e:	c3                   	ret    

0080219f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80219f:	55                   	push   %ebp
  8021a0:	89 e5                	mov    %esp,%ebp
  8021a2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021a5:	68 da 2c 80 00       	push   $0x802cda
  8021aa:	ff 75 0c             	pushl  0xc(%ebp)
  8021ad:	e8 c7 ea ff ff       	call   800c79 <strcpy>
	return 0;
}
  8021b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b7:	c9                   	leave  
  8021b8:	c3                   	ret    

008021b9 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021b9:	55                   	push   %ebp
  8021ba:	89 e5                	mov    %esp,%ebp
  8021bc:	57                   	push   %edi
  8021bd:	56                   	push   %esi
  8021be:	53                   	push   %ebx
  8021bf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021c5:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ca:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d0:	eb 2d                	jmp    8021ff <devcons_write+0x46>
		m = n - tot;
  8021d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021d5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021d7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021da:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021df:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021e2:	83 ec 04             	sub    $0x4,%esp
  8021e5:	53                   	push   %ebx
  8021e6:	03 45 0c             	add    0xc(%ebp),%eax
  8021e9:	50                   	push   %eax
  8021ea:	57                   	push   %edi
  8021eb:	e8 1b ec ff ff       	call   800e0b <memmove>
		sys_cputs(buf, m);
  8021f0:	83 c4 08             	add    $0x8,%esp
  8021f3:	53                   	push   %ebx
  8021f4:	57                   	push   %edi
  8021f5:	e8 c6 ed ff ff       	call   800fc0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021fa:	01 de                	add    %ebx,%esi
  8021fc:	83 c4 10             	add    $0x10,%esp
  8021ff:	89 f0                	mov    %esi,%eax
  802201:	3b 75 10             	cmp    0x10(%ebp),%esi
  802204:	72 cc                	jb     8021d2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802209:	5b                   	pop    %ebx
  80220a:	5e                   	pop    %esi
  80220b:	5f                   	pop    %edi
  80220c:	5d                   	pop    %ebp
  80220d:	c3                   	ret    

0080220e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80220e:	55                   	push   %ebp
  80220f:	89 e5                	mov    %esp,%ebp
  802211:	83 ec 08             	sub    $0x8,%esp
  802214:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802219:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80221d:	74 2a                	je     802249 <devcons_read+0x3b>
  80221f:	eb 05                	jmp    802226 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802221:	e8 37 ee ff ff       	call   80105d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802226:	e8 b3 ed ff ff       	call   800fde <sys_cgetc>
  80222b:	85 c0                	test   %eax,%eax
  80222d:	74 f2                	je     802221 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80222f:	85 c0                	test   %eax,%eax
  802231:	78 16                	js     802249 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802233:	83 f8 04             	cmp    $0x4,%eax
  802236:	74 0c                	je     802244 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80223b:	88 02                	mov    %al,(%edx)
	return 1;
  80223d:	b8 01 00 00 00       	mov    $0x1,%eax
  802242:	eb 05                	jmp    802249 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802244:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802249:	c9                   	leave  
  80224a:	c3                   	ret    

0080224b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802251:	8b 45 08             	mov    0x8(%ebp),%eax
  802254:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802257:	6a 01                	push   $0x1
  802259:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80225c:	50                   	push   %eax
  80225d:	e8 5e ed ff ff       	call   800fc0 <sys_cputs>
}
  802262:	83 c4 10             	add    $0x10,%esp
  802265:	c9                   	leave  
  802266:	c3                   	ret    

00802267 <getchar>:

int
getchar(void)
{
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
  80226a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80226d:	6a 01                	push   $0x1
  80226f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802272:	50                   	push   %eax
  802273:	6a 00                	push   $0x0
  802275:	e8 90 f6 ff ff       	call   80190a <read>
	if (r < 0)
  80227a:	83 c4 10             	add    $0x10,%esp
  80227d:	85 c0                	test   %eax,%eax
  80227f:	78 0f                	js     802290 <getchar+0x29>
		return r;
	if (r < 1)
  802281:	85 c0                	test   %eax,%eax
  802283:	7e 06                	jle    80228b <getchar+0x24>
		return -E_EOF;
	return c;
  802285:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802289:	eb 05                	jmp    802290 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80228b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229b:	50                   	push   %eax
  80229c:	ff 75 08             	pushl  0x8(%ebp)
  80229f:	e8 00 f4 ff ff       	call   8016a4 <fd_lookup>
  8022a4:	83 c4 10             	add    $0x10,%esp
  8022a7:	85 c0                	test   %eax,%eax
  8022a9:	78 11                	js     8022bc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ae:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022b4:	39 10                	cmp    %edx,(%eax)
  8022b6:	0f 94 c0             	sete   %al
  8022b9:	0f b6 c0             	movzbl %al,%eax
}
  8022bc:	c9                   	leave  
  8022bd:	c3                   	ret    

008022be <opencons>:

int
opencons(void)
{
  8022be:	55                   	push   %ebp
  8022bf:	89 e5                	mov    %esp,%ebp
  8022c1:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c7:	50                   	push   %eax
  8022c8:	e8 88 f3 ff ff       	call   801655 <fd_alloc>
  8022cd:	83 c4 10             	add    $0x10,%esp
		return r;
  8022d0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022d2:	85 c0                	test   %eax,%eax
  8022d4:	78 3e                	js     802314 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d6:	83 ec 04             	sub    $0x4,%esp
  8022d9:	68 07 04 00 00       	push   $0x407
  8022de:	ff 75 f4             	pushl  -0xc(%ebp)
  8022e1:	6a 00                	push   $0x0
  8022e3:	e8 94 ed ff ff       	call   80107c <sys_page_alloc>
  8022e8:	83 c4 10             	add    $0x10,%esp
		return r;
  8022eb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022ed:	85 c0                	test   %eax,%eax
  8022ef:	78 23                	js     802314 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022f1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fa:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802306:	83 ec 0c             	sub    $0xc,%esp
  802309:	50                   	push   %eax
  80230a:	e8 1f f3 ff ff       	call   80162e <fd2num>
  80230f:	89 c2                	mov    %eax,%edx
  802311:	83 c4 10             	add    $0x10,%esp
}
  802314:	89 d0                	mov    %edx,%eax
  802316:	c9                   	leave  
  802317:	c3                   	ret    

00802318 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802318:	55                   	push   %ebp
  802319:	89 e5                	mov    %esp,%ebp
  80231b:	56                   	push   %esi
  80231c:	53                   	push   %ebx
  80231d:	8b 75 08             	mov    0x8(%ebp),%esi
  802320:	8b 45 0c             	mov    0xc(%ebp),%eax
  802323:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802326:	85 c0                	test   %eax,%eax
  802328:	75 12                	jne    80233c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80232a:	83 ec 0c             	sub    $0xc,%esp
  80232d:	68 00 00 c0 ee       	push   $0xeec00000
  802332:	e8 f5 ee ff ff       	call   80122c <sys_ipc_recv>
  802337:	83 c4 10             	add    $0x10,%esp
  80233a:	eb 0c                	jmp    802348 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80233c:	83 ec 0c             	sub    $0xc,%esp
  80233f:	50                   	push   %eax
  802340:	e8 e7 ee ff ff       	call   80122c <sys_ipc_recv>
  802345:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802348:	85 f6                	test   %esi,%esi
  80234a:	0f 95 c1             	setne  %cl
  80234d:	85 db                	test   %ebx,%ebx
  80234f:	0f 95 c2             	setne  %dl
  802352:	84 d1                	test   %dl,%cl
  802354:	74 09                	je     80235f <ipc_recv+0x47>
  802356:	89 c2                	mov    %eax,%edx
  802358:	c1 ea 1f             	shr    $0x1f,%edx
  80235b:	84 d2                	test   %dl,%dl
  80235d:	75 2a                	jne    802389 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80235f:	85 f6                	test   %esi,%esi
  802361:	74 0d                	je     802370 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802363:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802368:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  80236e:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802370:	85 db                	test   %ebx,%ebx
  802372:	74 0d                	je     802381 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802374:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802379:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  80237f:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802381:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802386:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  802389:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80238c:	5b                   	pop    %ebx
  80238d:	5e                   	pop    %esi
  80238e:	5d                   	pop    %ebp
  80238f:	c3                   	ret    

00802390 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802390:	55                   	push   %ebp
  802391:	89 e5                	mov    %esp,%ebp
  802393:	57                   	push   %edi
  802394:	56                   	push   %esi
  802395:	53                   	push   %ebx
  802396:	83 ec 0c             	sub    $0xc,%esp
  802399:	8b 7d 08             	mov    0x8(%ebp),%edi
  80239c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80239f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8023a2:	85 db                	test   %ebx,%ebx
  8023a4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023a9:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8023ac:	ff 75 14             	pushl  0x14(%ebp)
  8023af:	53                   	push   %ebx
  8023b0:	56                   	push   %esi
  8023b1:	57                   	push   %edi
  8023b2:	e8 52 ee ff ff       	call   801209 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8023b7:	89 c2                	mov    %eax,%edx
  8023b9:	c1 ea 1f             	shr    $0x1f,%edx
  8023bc:	83 c4 10             	add    $0x10,%esp
  8023bf:	84 d2                	test   %dl,%dl
  8023c1:	74 17                	je     8023da <ipc_send+0x4a>
  8023c3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023c6:	74 12                	je     8023da <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8023c8:	50                   	push   %eax
  8023c9:	68 e6 2c 80 00       	push   $0x802ce6
  8023ce:	6a 47                	push   $0x47
  8023d0:	68 f4 2c 80 00       	push   $0x802cf4
  8023d5:	e8 41 e2 ff ff       	call   80061b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8023da:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023dd:	75 07                	jne    8023e6 <ipc_send+0x56>
			sys_yield();
  8023df:	e8 79 ec ff ff       	call   80105d <sys_yield>
  8023e4:	eb c6                	jmp    8023ac <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8023e6:	85 c0                	test   %eax,%eax
  8023e8:	75 c2                	jne    8023ac <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8023ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5e                   	pop    %esi
  8023ef:	5f                   	pop    %edi
  8023f0:	5d                   	pop    %ebp
  8023f1:	c3                   	ret    

008023f2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023f2:	55                   	push   %ebp
  8023f3:	89 e5                	mov    %esp,%ebp
  8023f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023f8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023fd:	89 c2                	mov    %eax,%edx
  8023ff:	c1 e2 07             	shl    $0x7,%edx
  802402:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  802409:	8b 52 5c             	mov    0x5c(%edx),%edx
  80240c:	39 ca                	cmp    %ecx,%edx
  80240e:	75 11                	jne    802421 <ipc_find_env+0x2f>
			return envs[i].env_id;
  802410:	89 c2                	mov    %eax,%edx
  802412:	c1 e2 07             	shl    $0x7,%edx
  802415:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80241c:	8b 40 54             	mov    0x54(%eax),%eax
  80241f:	eb 0f                	jmp    802430 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802421:	83 c0 01             	add    $0x1,%eax
  802424:	3d 00 04 00 00       	cmp    $0x400,%eax
  802429:	75 d2                	jne    8023fd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80242b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802430:	5d                   	pop    %ebp
  802431:	c3                   	ret    

00802432 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802432:	55                   	push   %ebp
  802433:	89 e5                	mov    %esp,%ebp
  802435:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802438:	89 d0                	mov    %edx,%eax
  80243a:	c1 e8 16             	shr    $0x16,%eax
  80243d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802444:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802449:	f6 c1 01             	test   $0x1,%cl
  80244c:	74 1d                	je     80246b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80244e:	c1 ea 0c             	shr    $0xc,%edx
  802451:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802458:	f6 c2 01             	test   $0x1,%dl
  80245b:	74 0e                	je     80246b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80245d:	c1 ea 0c             	shr    $0xc,%edx
  802460:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802467:	ef 
  802468:	0f b7 c0             	movzwl %ax,%eax
}
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    
  80246d:	66 90                	xchg   %ax,%ax
  80246f:	90                   	nop

00802470 <__udivdi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	53                   	push   %ebx
  802474:	83 ec 1c             	sub    $0x1c,%esp
  802477:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80247b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80247f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802487:	85 f6                	test   %esi,%esi
  802489:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80248d:	89 ca                	mov    %ecx,%edx
  80248f:	89 f8                	mov    %edi,%eax
  802491:	75 3d                	jne    8024d0 <__udivdi3+0x60>
  802493:	39 cf                	cmp    %ecx,%edi
  802495:	0f 87 c5 00 00 00    	ja     802560 <__udivdi3+0xf0>
  80249b:	85 ff                	test   %edi,%edi
  80249d:	89 fd                	mov    %edi,%ebp
  80249f:	75 0b                	jne    8024ac <__udivdi3+0x3c>
  8024a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a6:	31 d2                	xor    %edx,%edx
  8024a8:	f7 f7                	div    %edi
  8024aa:	89 c5                	mov    %eax,%ebp
  8024ac:	89 c8                	mov    %ecx,%eax
  8024ae:	31 d2                	xor    %edx,%edx
  8024b0:	f7 f5                	div    %ebp
  8024b2:	89 c1                	mov    %eax,%ecx
  8024b4:	89 d8                	mov    %ebx,%eax
  8024b6:	89 cf                	mov    %ecx,%edi
  8024b8:	f7 f5                	div    %ebp
  8024ba:	89 c3                	mov    %eax,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	39 ce                	cmp    %ecx,%esi
  8024d2:	77 74                	ja     802548 <__udivdi3+0xd8>
  8024d4:	0f bd fe             	bsr    %esi,%edi
  8024d7:	83 f7 1f             	xor    $0x1f,%edi
  8024da:	0f 84 98 00 00 00    	je     802578 <__udivdi3+0x108>
  8024e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	89 c5                	mov    %eax,%ebp
  8024e9:	29 fb                	sub    %edi,%ebx
  8024eb:	d3 e6                	shl    %cl,%esi
  8024ed:	89 d9                	mov    %ebx,%ecx
  8024ef:	d3 ed                	shr    %cl,%ebp
  8024f1:	89 f9                	mov    %edi,%ecx
  8024f3:	d3 e0                	shl    %cl,%eax
  8024f5:	09 ee                	or     %ebp,%esi
  8024f7:	89 d9                	mov    %ebx,%ecx
  8024f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024fd:	89 d5                	mov    %edx,%ebp
  8024ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802503:	d3 ed                	shr    %cl,%ebp
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e2                	shl    %cl,%edx
  802509:	89 d9                	mov    %ebx,%ecx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	09 c2                	or     %eax,%edx
  80250f:	89 d0                	mov    %edx,%eax
  802511:	89 ea                	mov    %ebp,%edx
  802513:	f7 f6                	div    %esi
  802515:	89 d5                	mov    %edx,%ebp
  802517:	89 c3                	mov    %eax,%ebx
  802519:	f7 64 24 0c          	mull   0xc(%esp)
  80251d:	39 d5                	cmp    %edx,%ebp
  80251f:	72 10                	jb     802531 <__udivdi3+0xc1>
  802521:	8b 74 24 08          	mov    0x8(%esp),%esi
  802525:	89 f9                	mov    %edi,%ecx
  802527:	d3 e6                	shl    %cl,%esi
  802529:	39 c6                	cmp    %eax,%esi
  80252b:	73 07                	jae    802534 <__udivdi3+0xc4>
  80252d:	39 d5                	cmp    %edx,%ebp
  80252f:	75 03                	jne    802534 <__udivdi3+0xc4>
  802531:	83 eb 01             	sub    $0x1,%ebx
  802534:	31 ff                	xor    %edi,%edi
  802536:	89 d8                	mov    %ebx,%eax
  802538:	89 fa                	mov    %edi,%edx
  80253a:	83 c4 1c             	add    $0x1c,%esp
  80253d:	5b                   	pop    %ebx
  80253e:	5e                   	pop    %esi
  80253f:	5f                   	pop    %edi
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    
  802542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802548:	31 ff                	xor    %edi,%edi
  80254a:	31 db                	xor    %ebx,%ebx
  80254c:	89 d8                	mov    %ebx,%eax
  80254e:	89 fa                	mov    %edi,%edx
  802550:	83 c4 1c             	add    $0x1c,%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5f                   	pop    %edi
  802556:	5d                   	pop    %ebp
  802557:	c3                   	ret    
  802558:	90                   	nop
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	89 d8                	mov    %ebx,%eax
  802562:	f7 f7                	div    %edi
  802564:	31 ff                	xor    %edi,%edi
  802566:	89 c3                	mov    %eax,%ebx
  802568:	89 d8                	mov    %ebx,%eax
  80256a:	89 fa                	mov    %edi,%edx
  80256c:	83 c4 1c             	add    $0x1c,%esp
  80256f:	5b                   	pop    %ebx
  802570:	5e                   	pop    %esi
  802571:	5f                   	pop    %edi
  802572:	5d                   	pop    %ebp
  802573:	c3                   	ret    
  802574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802578:	39 ce                	cmp    %ecx,%esi
  80257a:	72 0c                	jb     802588 <__udivdi3+0x118>
  80257c:	31 db                	xor    %ebx,%ebx
  80257e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802582:	0f 87 34 ff ff ff    	ja     8024bc <__udivdi3+0x4c>
  802588:	bb 01 00 00 00       	mov    $0x1,%ebx
  80258d:	e9 2a ff ff ff       	jmp    8024bc <__udivdi3+0x4c>
  802592:	66 90                	xchg   %ax,%ax
  802594:	66 90                	xchg   %ax,%ax
  802596:	66 90                	xchg   %ax,%ax
  802598:	66 90                	xchg   %ax,%ax
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__umoddi3>:
  8025a0:	55                   	push   %ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
  8025a4:	83 ec 1c             	sub    $0x1c,%esp
  8025a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025b7:	85 d2                	test   %edx,%edx
  8025b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025c1:	89 f3                	mov    %esi,%ebx
  8025c3:	89 3c 24             	mov    %edi,(%esp)
  8025c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ca:	75 1c                	jne    8025e8 <__umoddi3+0x48>
  8025cc:	39 f7                	cmp    %esi,%edi
  8025ce:	76 50                	jbe    802620 <__umoddi3+0x80>
  8025d0:	89 c8                	mov    %ecx,%eax
  8025d2:	89 f2                	mov    %esi,%edx
  8025d4:	f7 f7                	div    %edi
  8025d6:	89 d0                	mov    %edx,%eax
  8025d8:	31 d2                	xor    %edx,%edx
  8025da:	83 c4 1c             	add    $0x1c,%esp
  8025dd:	5b                   	pop    %ebx
  8025de:	5e                   	pop    %esi
  8025df:	5f                   	pop    %edi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    
  8025e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e8:	39 f2                	cmp    %esi,%edx
  8025ea:	89 d0                	mov    %edx,%eax
  8025ec:	77 52                	ja     802640 <__umoddi3+0xa0>
  8025ee:	0f bd ea             	bsr    %edx,%ebp
  8025f1:	83 f5 1f             	xor    $0x1f,%ebp
  8025f4:	75 5a                	jne    802650 <__umoddi3+0xb0>
  8025f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025fa:	0f 82 e0 00 00 00    	jb     8026e0 <__umoddi3+0x140>
  802600:	39 0c 24             	cmp    %ecx,(%esp)
  802603:	0f 86 d7 00 00 00    	jbe    8026e0 <__umoddi3+0x140>
  802609:	8b 44 24 08          	mov    0x8(%esp),%eax
  80260d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802611:	83 c4 1c             	add    $0x1c,%esp
  802614:	5b                   	pop    %ebx
  802615:	5e                   	pop    %esi
  802616:	5f                   	pop    %edi
  802617:	5d                   	pop    %ebp
  802618:	c3                   	ret    
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	85 ff                	test   %edi,%edi
  802622:	89 fd                	mov    %edi,%ebp
  802624:	75 0b                	jne    802631 <__umoddi3+0x91>
  802626:	b8 01 00 00 00       	mov    $0x1,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	f7 f7                	div    %edi
  80262f:	89 c5                	mov    %eax,%ebp
  802631:	89 f0                	mov    %esi,%eax
  802633:	31 d2                	xor    %edx,%edx
  802635:	f7 f5                	div    %ebp
  802637:	89 c8                	mov    %ecx,%eax
  802639:	f7 f5                	div    %ebp
  80263b:	89 d0                	mov    %edx,%eax
  80263d:	eb 99                	jmp    8025d8 <__umoddi3+0x38>
  80263f:	90                   	nop
  802640:	89 c8                	mov    %ecx,%eax
  802642:	89 f2                	mov    %esi,%edx
  802644:	83 c4 1c             	add    $0x1c,%esp
  802647:	5b                   	pop    %ebx
  802648:	5e                   	pop    %esi
  802649:	5f                   	pop    %edi
  80264a:	5d                   	pop    %ebp
  80264b:	c3                   	ret    
  80264c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802650:	8b 34 24             	mov    (%esp),%esi
  802653:	bf 20 00 00 00       	mov    $0x20,%edi
  802658:	89 e9                	mov    %ebp,%ecx
  80265a:	29 ef                	sub    %ebp,%edi
  80265c:	d3 e0                	shl    %cl,%eax
  80265e:	89 f9                	mov    %edi,%ecx
  802660:	89 f2                	mov    %esi,%edx
  802662:	d3 ea                	shr    %cl,%edx
  802664:	89 e9                	mov    %ebp,%ecx
  802666:	09 c2                	or     %eax,%edx
  802668:	89 d8                	mov    %ebx,%eax
  80266a:	89 14 24             	mov    %edx,(%esp)
  80266d:	89 f2                	mov    %esi,%edx
  80266f:	d3 e2                	shl    %cl,%edx
  802671:	89 f9                	mov    %edi,%ecx
  802673:	89 54 24 04          	mov    %edx,0x4(%esp)
  802677:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80267b:	d3 e8                	shr    %cl,%eax
  80267d:	89 e9                	mov    %ebp,%ecx
  80267f:	89 c6                	mov    %eax,%esi
  802681:	d3 e3                	shl    %cl,%ebx
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 d0                	mov    %edx,%eax
  802687:	d3 e8                	shr    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	09 d8                	or     %ebx,%eax
  80268d:	89 d3                	mov    %edx,%ebx
  80268f:	89 f2                	mov    %esi,%edx
  802691:	f7 34 24             	divl   (%esp)
  802694:	89 d6                	mov    %edx,%esi
  802696:	d3 e3                	shl    %cl,%ebx
  802698:	f7 64 24 04          	mull   0x4(%esp)
  80269c:	39 d6                	cmp    %edx,%esi
  80269e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026a2:	89 d1                	mov    %edx,%ecx
  8026a4:	89 c3                	mov    %eax,%ebx
  8026a6:	72 08                	jb     8026b0 <__umoddi3+0x110>
  8026a8:	75 11                	jne    8026bb <__umoddi3+0x11b>
  8026aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ae:	73 0b                	jae    8026bb <__umoddi3+0x11b>
  8026b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026b4:	1b 14 24             	sbb    (%esp),%edx
  8026b7:	89 d1                	mov    %edx,%ecx
  8026b9:	89 c3                	mov    %eax,%ebx
  8026bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026bf:	29 da                	sub    %ebx,%edx
  8026c1:	19 ce                	sbb    %ecx,%esi
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 f0                	mov    %esi,%eax
  8026c7:	d3 e0                	shl    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	d3 ea                	shr    %cl,%edx
  8026cd:	89 e9                	mov    %ebp,%ecx
  8026cf:	d3 ee                	shr    %cl,%esi
  8026d1:	09 d0                	or     %edx,%eax
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	83 c4 1c             	add    $0x1c,%esp
  8026d8:	5b                   	pop    %ebx
  8026d9:	5e                   	pop    %esi
  8026da:	5f                   	pop    %edi
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    
  8026dd:	8d 76 00             	lea    0x0(%esi),%esi
  8026e0:	29 f9                	sub    %edi,%ecx
  8026e2:	19 d6                	sbb    %edx,%esi
  8026e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ec:	e9 18 ff ff ff       	jmp    802609 <__umoddi3+0x69>
