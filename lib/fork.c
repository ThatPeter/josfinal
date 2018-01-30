// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>
#include <inc/x86.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

volatile uintptr_t eip;
//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
		panic("faulting access");
	}


	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
	if (r < 0) {
		panic("sys page alloc failed %e", r);
	}
	addr = ROUNDDOWN(addr, PGSIZE);
	memcpy(PFTEMP, addr, PGSIZE);

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
	if (r < 0) {
		panic("sys page alloc failed %e", r);
	}
	r = sys_page_unmap(0, PFTEMP);
	if (r < 0) {
		panic("sys page alloc failed %e", r);
	}
	//panic("pgfault not implemented");
	return;
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
		if (r < 0) {
		    	panic("sys page map fault %e");
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
		if (r < 0) {
		    	panic("sys page map fault %e");
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
		if (r < 0) {
		    	panic("sys page map fault %e");
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
		if (r < 0) {
		    	panic("sys page map fault %e");
		}
	}
	//panic("duppage not implemented");
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
	envid_t envid = sys_exofork();

	if (envid < 0) {
		panic("fork fault %e");
	}
	
	if (!envid) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);

	sys_env_set_status(envid, ENV_RUNNABLE);
	
	return envid;
	//panic("fork not implemented");
}

envid_t
sfork(void)
{
	return 0;
}
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
	eip = (uintptr_t )func;
	cprintf("in fork.c thread create. func: %x\n", func);
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
	cprintf("in fork.c thread create. func: %x\n", func);
	return id;
}

void 	
thread_interrupt(envid_t thread_id) 
{
	sys_thread_free(thread_id);
}

void 
thread_join(envid_t thread_id) 
{
	sys_thread_join(thread_id);
}

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
	if (r < 0) {
		panic("%e\n", r);
	}	
	wt->envid = envid;
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
	if (queue->first == NULL) {
		cprintf("In append queue is empty\n");
		queue->first = wt;
		queue->last = wt;
		wt->next = NULL;
	} else {
		cprintf("In append queue is not empty\n");
		queue->last->next = wt;
		wt->next = NULL;
		queue->last = wt;
	}
}

envid_t 
queue_pop(struct waiting_queue* queue) {
	if(queue->first == NULL) {
		panic("queue empty!\n");
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
	envid_t envid = popped->envid;
	cprintf("In popping queue - id: %d\n", envid);
	return envid;
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
		queue_append(sys_getenvid(), mtx->queue);		
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
	mtx->owner = sys_getenvid();}
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}

void 
mutex_unlock(struct Mutex* mtx)
{
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
		mtx->owner = queue_pop(mtx->queue);
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
		if (r < 0) {
			panic("%e\n", r);
		}
	}

	asm volatile("pause");
	//sys_yield();
}


void 
mutex_init(struct Mutex* mtx)
{	int r;
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
		panic("panic at mutex init: %e\n", r);
	}	
	mtx->locked = 0;
	mtx->queue->first = NULL;
	mtx->queue->last = NULL;
	mtx->owner = 0;
}

void 
mutex_destroy(struct Mutex* mtx)
{
	int r = sys_page_unmap(sys_getenvid(), mtx);
	if (r < 0) {
		panic("%e\n", r);
	}
}

