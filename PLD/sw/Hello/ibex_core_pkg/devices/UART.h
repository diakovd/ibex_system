#ifndef _IBEX_CORE_UART_H
#define _IBEX_CORE_UART_H 
 
   #define dFIFOtx_UART	0	// Write data to trnasmit FIFO 
   #define dFIFOrx_UART 0	// Read data from receive FIFO
   #define dCR_UART 	1	// CONTROL REGISTER
   #define dFCR_UART 	2	// FIFO STATUS/CONTROL REGISTER
   #define dTxCntL_UART	3	// Number of byte in transmit FIFO lower byte
   #define dTxCntH_UART	4	// Number of byte in transmit FIFO high byte
   #define dRxCntL_UART	5	// Number of byte in receive FIFO lower byte
   #define dRxCntH_UART	6	// Number of byte in receive FIFO high byte
   #define dISR_UART 	7	// INTERRUPT STATUS REGISTER
   #define dESR_UART 	8	// Error STATUS REGISTER
   #define dDLL_UART 	9	// Clock divisor lath register  lower byte
   #define dDLH_UART 	10	// Clock divisor lath register  high byte
 
  #define BR9600	768
  #define BR14400	512
  #define BR19200	384
  #define BR28800	256
  #define BR38400	192
  #define BR57600	128
  #define BR76800	96
  #define BR115200	64
  #define BR230400	32
  #define BR460800	16
  #define BR921600	8
  #define BR1843200     4

 #endif /* _IBEX_CORE_UART_H */