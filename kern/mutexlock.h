#ifndef JOS_INC_MUTEXLOCK_H
#define JOS_INC_MUTEXLOCK_H

#include <inc/types.h>

// Comment this to disable mutexlock debugging
#define DEBUG_MUTEXLOCK


// Mutual exclusion lock.
struct mutexlock {
	unsigned locked;       // Is the lock held?

#ifdef DEBUG_MUTEXLOCK
	// For debugging:
	// mozno staci v env zadefinovat    char *state;            // Name of lock.
	
	
	struct CpuInfo *cpu;   // The CPU holding the lock.
	uintptr_t pcs[10];     // The call stack (an array of program counters)
	                       // that locked the lock.
	struct Env *owner_thread;
#endif
	struct queue {		// queue for waiting threads
		int data;
		struct queue *next;
	} *head=NULL,*tail=NULL;
	
};

//void __mutex_initlock(struct mutexlock *lk, char *name);
void mutex_lock(struct mutexlock *lk);
void mutex_unlock(struct mutexlock *lk);
//void queue_insert(struct mutexlock *lk;
//void queue_remove(struct mutexlock *lk);

//#define mutex_initlock(lock)   __mutex_initlock(lock, #lock)

extern struct mutexlock kernel_lock;

static inline void
lock_kernel(void)
{
	mutex_lock(&kernel_lock);
}

static inline void
unlock_kernel(void)
{
	mutex_unlock(&kernel_lock);

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
}

#endif
