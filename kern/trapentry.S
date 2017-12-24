/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
.data
	.p2align 2
	.globl TRAPHANDLERS
TRAPHANDLERS:
.text

TRAPHANDLER_NOEC(TH_DIVIDE, T_DIVIDE)	// fault
TRAPHANDLER_NOEC(TH_DEBUG, T_DEBUG)	// fault/trap
TRAPHANDLER_NOEC(TH_NMI, T_NMI)		//
TRAPHANDLER_NOEC(TH_BRKPT, T_BRKPT)	// trap
TRAPHANDLER_NOEC(TH_OFLOW, T_OFLOW)	// trap
TRAPHANDLER_NOEC(TH_BOUND, T_BOUND)	// fault
TRAPHANDLER_NOEC(TH_ILLOP, T_ILLOP)	// fault
TRAPHANDLER_NOEC(TH_DEVICE, T_DEVICE)	// fault
TRAPHANDLER     (TH_DBLFLT, T_DBLFLT)	// abort
//TRAPHANDLER_NOEC(TH_COPROC, T_COPROC) // abort	
TRAPHANDLER     (TH_TSS, T_TSS)		// fault
TRAPHANDLER     (TH_SEGNP, T_SEGNP)	// fault
TRAPHANDLER     (TH_STACK, T_STACK)	// fault
TRAPHANDLER     (TH_GPFLT, T_GPFLT)	// fault/abort
TRAPHANDLER     (TH_PGFLT, T_PGFLT)	// fault
//TRAPHANDLER_NOEC(TH_RES, T_RES)	
TRAPHANDLER_NOEC(TH_FPERR, T_FPERR)	// fault
TRAPHANDLER     (TH_ALIGN, T_ALIGN)	//
TRAPHANDLER_NOEC(TH_MCHK, T_MCHK)	//
TRAPHANDLER_NOEC(TH_SIMDERR, T_SIMDERR) //

TRAPHANDLER_NOEC(TH_SYSCALL, T_SYSCALL) // trap

TRAPHANDLER_NOEC(TH_IRQ_TIMER, IRQ_OFFSET+IRQ_TIMER)	// 0
TRAPHANDLER_NOEC(TH_IRQ_KBD, IRQ_OFFSET+IRQ_KBD)	// 1
TRAPHANDLER_NOEC(TH_IRQ_2, IRQ_OFFSET+2)
TRAPHANDLER_NOEC(TH_IRQ_3, IRQ_OFFSET+3)
TRAPHANDLER_NOEC(TH_IRQ_SERIAL, IRQ_OFFSET+IRQ_SERIAL)	// 4
TRAPHANDLER_NOEC(TH_IRQ_5, IRQ_OFFSET+5)
TRAPHANDLER_NOEC(TH_IRQ_6, IRQ_OFFSET+6)
TRAPHANDLER_NOEC(TH_IRQ_SPURIOUS, IRQ_OFFSET+IRQ_SPURIOUS) // 7
TRAPHANDLER_NOEC(TH_IRQ_8, IRQ_OFFSET+8)
TRAPHANDLER_NOEC(TH_IRQ_9, IRQ_OFFSET+9)
TRAPHANDLER_NOEC(TH_IRQ_10, IRQ_OFFSET+10)
TRAPHANDLER_NOEC(TH_IRQ_11, IRQ_OFFSET+11)
TRAPHANDLER_NOEC(TH_IRQ_12, IRQ_OFFSET+12)
TRAPHANDLER_NOEC(TH_IRQ_13, IRQ_OFFSET+13)
TRAPHANDLER_NOEC(TH_IRQ_IDE, IRQ_OFFSET+IRQ_IDE)	// 14
TRAPHANDLER_NOEC(TH_IRQ_15, IRQ_OFFSET+15)
TRAPHANDLER_NOEC(TH_IRQ_ERROR, IRQ_OFFSET+IRQ_ERROR)	// 19

/*
 * Lab 3: Your code here for _alltraps
 */

.text
_alltraps:
	pushl	%ds
	pushl	%es
	pushal
	mov	$GD_KD, %eax
	mov	%ax, %es
	mov	%ax, %ds
	pushl	%esp
	call	trap

