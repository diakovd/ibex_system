// See LICENSE for license details.

#ifndef _IBEX_CORE_H
#define _IBEX_CORE_H

#include "UART.h"
#include "Timer.h"
#include "Timer.h"
//#include "encoding.h"

/****************************************************************************
 * IBEX_CORE definitions
 *****************************************************************************/

// Memory map
#define IO_BASE_ADDR 0x4000
#define IO_SIZE      0x0000c
#define UART0_BASE_ADDR (IO_BASE_ADDR + IO_SIZE)
#define UART0_SIZE   0x00014
#define Timer_BASE_ADDR (UART0_BASE_ADDR + UART0_SIZE)
#define Timer_SIZE   0x00060
#define Timer1_BASE_ADDR (Timer_BASE_ADDR + Timer_SIZE)
#define Timer1_SIZE   0x00060

// IOF masks

// Interrupt numbers

// Helper functions
#define _REG64(p, i) (*(volatile uint64_t *)((p) + (i)))
#define _REG32(p, i) (*(volatile uint32_t *)((p) + (i)))
#define _REG16(p, i) (*(volatile uint16_t *)((p) + (i)))
#define _REG8(p, i) (*(volatile uint8_t *)((p) + (i)))

// Bulk set bits in `reg` to either 0 or 1.
// E.g. SET_BITS(MY_REG, 0x00000007, 0) would generate MY_REG &= ~0x7
// E.g. SET_BITS(MY_REG, 0x00000007, 1) would generate MY_REG |= 0x7
#define SET_BITS(reg, mask, value) if ((value) == 0) { (reg) &= ~(mask); } else { (reg) |= (mask); }
#define IO_REG32(offset) _REG32(IO_BASE_ADDR, offset)
#define IO_REG8(offset)  _REG8(IO_BASE_ADDR, offset)
#define UART0_REG(offset)  _REG8(UART0_BASE_ADDR, offset)
#define Timer_REG(offset)  _REG32(Timer_BASE_ADDR, offset)
#define Timer1_REG(offset)  _REG32(Timer1_BASE_ADDR, offset)

#define IRQ_M_SOFT   3
#define IRQ_M_TIMER  7

#define MIP_MSIP            (1 << IRQ_M_SOFT)
#define MIP_MTIP            (1 << IRQ_M_TIMER)
#define MSTATUS_MIE         0x00000008

#define set_csr(reg, bit) ({ unsigned long __tmp; \
  if (__builtin_constant_p(bit) && (unsigned long)(bit) < 32) \
    asm volatile ("csrrs %0, " #reg ", %1" : "=r"(__tmp) : "i"(bit)); \
  else \
    asm volatile ("csrrs %0, " #reg ", %1" : "=r"(__tmp) : "r"(bit)); \
  __tmp; })

#define clear_csr(reg, bit) ({ unsigned long __tmp; \
  if (__builtin_constant_p(bit) && (unsigned long)(bit) < 32) \
    asm volatile ("csrrc %0, " #reg ", %1" : "=r"(__tmp) : "i"(bit)); \
  else \
    asm volatile ("csrrc %0, " #reg ", %1" : "=r"(__tmp) : "r"(bit)); \
  __tmp; })


// Misc

#endif
