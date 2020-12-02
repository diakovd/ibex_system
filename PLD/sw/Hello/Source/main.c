/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************
*                                                                    *
*            (c) 2014 - 2019 SEGGER Microcontroller GmbH             *
*                                                                    *
*           www.segger.com     Support: support@segger.com           *
*                                                                    *
**********************************************************************
*                                                                    *
* All rights reserved.                                               *
*                                                                    *
* Redistribution and use in source and binary forms, with or         *
* without modification, are permitted provided that the following    *
* conditions are met:                                                *
*                                                                    *
* - Redistributions of source code must retain the above copyright   *
*   notice, this list of conditions and the following disclaimer.    *
*                                                                    *
* - Neither the name of SEGGER Microcontroller GmbH                  *
*   nor the names of its contributors may be used to endorse or      *
*   promote products derived from this software without specific     *
*   prior written permission.                                        *
*                                                                    *
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND             *
* CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,        *
* INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF           *
* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE           *
* DISCLAIMED.                                                        *
* IN NO EVENT SHALL SEGGER Microcontroller GmbH BE LIABLE FOR        *
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR           *
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT  *
* OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;    *
* OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF      *
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT          *
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE  *
* USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH   *
* DAMAGE.                                                            *
*                                                                    *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Generic application start
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "ibex_core.h"

/*********************************************************************
*
*       main()
*
*  Function description
*   Application entry point.
*/
uint32_t x,i;
uint8_t messege[] = "Super Puper Word";

void
handle_UART_interrupt()
{
  uint8_t ISR, RxCntL, n, data; 


  ISR = UART0_REG(dISR_UART);
  IO_REG32(0) = ISR;

  if(ISR & 0x1){  //Rx data availble
    RxCntL = UART0_REG(dRxCntL_UART);
    for (n = 0; n < RxCntL; n++) data = UART0_REG(dFIFOrx_UART);
  }
  else if(ISR & 0x2){
    int32_t f = strlen(messege);
    for(i = 0; i < f; i++) UART0_REG(dFIFOtx_UART) = messege[i]; //strlen(messege)
  }
}

void
handle_TIMER_interrupt(unsigned ticks)
{
   //Write period val
 Timer_REG(dTmPr)   = ticks;
 Timer_REG(dTmPrSh) = ticks;

 //Set Timer Run Bit
 Timer_REG(dTRS) = 0x1;

  //Send Hello word
 int32_t f = strlen(messege);
 for(i = 0; i < f; i++) UART0_REG(dFIFOtx_UART) = messege[i]; //strlen(messege)

}

uintptr_t
handle_trap(uintptr_t mcause, uintptr_t epc)
{
    if (mcause == 0x80000003){ //UART interrupt
      handle_UART_interrupt();
    }
    else if (mcause == 0x80000007){ //Timer interrupt
      Timer_REG(dISC) = 1;  
      handle_TIMER_interrupt(0xffff);
    }
  //else while (1);
  return epc;
}

uint8_t CR;
uint32_t TMS;


void main(void) {
 
 uint32_t i;

 //UART initialization
 CR = 0;
 CR = CR | 0x01;  //Set Odd parity
 //CR = CR | (1'b1 << 3); //set Rx Data Available Interrupt
 //CR = CR | (0x1 << 4); //set Tx Empty Interrupt
 //CR = CR | (0x1 << 5); //set Rx Error Status Interrupt
 //CR = CR | (1'b1 << 6); //Internal Loop TX to RX

 UART0_REG(dCR_UART) = CR; //Set Odd parity
 UART0_REG(dDLL_UART) = BR921600; //Set 

 //Timer initialization
   //Write period val
 Timer_REG(dTmPr)   = 0xfffff;
 Timer_REG(dTmPrSh) = 0xfffff;

 //Set Timer mode
 TMS = 0; //Set TCM Center aligned mode
 TMS = TMS | (0x1 << 1); //Single shot mode
 Timer_REG(dTMS) = TMS; 


  //Set Interrupt 
  Timer_REG(dIEC) =  0x1; //Period match
	
  //Set Timer Run Bit
  Timer_REG(dTRS) = 0x1;

  // Clear interrupts
  clear_csr(mie, MIP_MSIP);
  clear_csr(mie, MIP_MTIP);

  // Enable the Machine-Timer bit in MIE
  set_csr(mie, MIP_MSIP);
  set_csr(mie, MIP_MTIP);

  // Enable interrupts in general.
  set_csr(mstatus, MSTATUS_MIE);

  //Send Hello word 

 int32_t f = strlen(messege);
 for(i = 0; i < f; i++) UART0_REG(dFIFOtx_UART) = messege[i]; //strlen(messege)

 while(1){
 /*
 for (i = 0; i < 4; i++) {
    IO_REG32(0) = i;
  }
*/
 }
}

/*************************** End of file ****************************/
