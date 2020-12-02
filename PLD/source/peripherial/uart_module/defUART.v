`ifndef DEFUART_H
 `define DEFUART_H
 
 `define dAdW 12 //bus address wight 
 
 `define defU_FIFOtx 	0	// Write data to trnasmit FIFO 
 `define defU_FIFOrx 	0	// Read data from receive FIFO
 `define defU_CR 		1	// CONTROL REGISTER
 `define defU_FCR 		2	// FIFO STATUS/CONTROL REGISTER
 `define defU_TxCntL 	3	// Number of byte in transmit FIFO lower byte
 `define defU_TxCntH 	4	// Number of byte in transmit FIFO high byte
 `define defU_RxCntL 	5	// Number of byte in receive FIFO lower byte
 `define defU_RxCntH 	6	// Number of byte in receive FIFO high byte
 `define defU_ISR 		7	// INTERRUPT STATUS REGISTER
 `define defU_ESR 		8	// Error STATUS REGISTER
 `define defU_DLL 		9	// Clock divisor lath register  lower byte
 `define defU_DLH 		10	// Clock divisor lath register  high byte
 
 
  typedef struct packed{
	logic bit_7; //r
	logic InLoop;			// Internal Loop TX to RX
	logic ErrInt; 		    // Rx Error Status Interrupt
	logic TxInt;			// Tx Empty Interrupt
	logic RxInt;			// Rx Data Available Interrupt
	logic [2:0] PrTp;		// Parity Type
 } CONTROL_REGISTER;	// CR
 
   typedef struct packed{
	logic bit_7; //r
	logic TxComp; 		// Tx Complete
	logic RxClear; 		// RX FIFO Clear Flag
	logic TxClear; 		// TX FIFO Clear Flag
	logic RxEmpty; 		// RX FIFO Empty Flag
	logic RxFull;		// RX FIFO Full Flag
	logic TxEmpty;		// TX FIFO Empty  Flag
	logic TxFull;		// TX FIFO Full Flag
 } FIFO_STATUS_CONTROL_REGISTER;	// FCR

  typedef struct packed{
	logic [7 - 3:0] bit7_4; //r
	logic ErrInt;			  // Rx Error Status
	logic TxInt;			  // Tx FIFO empty
	logic RxInt;			  // Rx data availble
 } INTERRUPT_STATUS_REGISTER; // ISR
 
  typedef struct packed{
	logic [7 - 4:0] bit7_5; //r
	logic Brk;			  // Rx Break Error
	logic Frm;			  // Rx Frame Error
	logic Prt;			  // Rx Parity Error
	logic Ovrn;			  // Rx FIFO Overrun
 } ERROR_STATUS_REGISTER; // ESR 
 
 `define BR9600		768
 `define BR14400	512
 `define BR19200	384
 `define BR28800	256
 `define BR38400	192
 `define BR57600	128
 `define BR76800	96
 `define BR115200	64
 `define BR230400	32
 `define BR460800	16
 `define BR921600	8
 `define BR1843200  4
 
 `endif