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
#include "../ibex_core_pkg/mtimer/mtime.h"

#define CORECLOCK 125000000
/*********************************************************************
*
*       main()
*
*  Function description
*   Application entry point.
*/

#define tmInt   0x1
#define uartInt 0x2

uint32_t x,i, pullInt;
uint8_t messege[] = "Super Puper Word!!! ";
uint8_t sendEV0[] = " ev0 = ";
uint8_t sendEV1[] = " ev1 = ";
uint8_t ISR_uart;
uint32_t ISR_tm;
uint64_t  Begin_Time;

/*
void handle_UART_interrupt()
{
  uint8_t ISR, RxCntL, n, data; 

  if(ISR & 0x1){  //Rx data availble
    RxCntL = UART0_REG(dRxCntL_UART);
    for (n = 0; n < RxCntL; n++) data = UART0_REG(dFIFOrx_UART);
  }
  else if(ISR & 0x2){
    int32_t f = strlen(messege);
    for(i = 0; i < f; i++) UART0_REG(dFIFOtx_UART) = messege[i]; 
  }

}
*/

/*
void handle_TIMER_interrupt(unsigned ticks)
{
   //Write period val
 Timer_REG(dTmPrSh) = ticks;

 //Set Timer Run Bit
 Timer_REG(dTRS) = 0x1;

  //Send Hello word
 int32_t f = strlen(messege);
 for(i = 0; i < f; i++) UART0_REG(dFIFOtx_UART) = messege[i]; //strlen(messege)

}
*/

uintptr_t 
handle_trap(uintptr_t mcause, uintptr_t epc)
{
    if (mcause == 0x80000003){ //UART interrupt
      ISR_uart = UART0_REG(dISR_UART);
      pullInt  = pullInt | uartInt;
      IO_REG32(0x4) = pullInt; 
      IO_REG32(0x4) = ISR_uart;
    }
    else if (mcause == 0x80000007){ //Timer interrupt
      ISR_tm = ISR_tm | Timer_REG(dISR);
      Timer_REG(dISC) = ISR_tm;  
      pullInt  = pullInt | tmInt;
      IO_REG32(0x4) = pullInt;
      IO_REG32(0x4) = ISR_tm;
    }
  return epc;
}

void init_timer(void) {
  uint32_t TMS;
  uint32_t CMC;
  uint32_t ECR;
  uint32_t IEC;

  Timer_REG(dTmPrSh) = 0xffffffff;

  //Set Timer mode
  TMS = 0; //Set TCM Center aligned mode
  TMS = TMS | (0x1 << 2); //Capture Compare Mode
  TMS = TMS | (0x1 << 9); //Capture Compare Mode
  Timer_REG(dTMS) = TMS; 

 //Connection Matrix Control
  CMC = 0;
  CMC = CMC | (0x1 << 4); //External Capture 0 Func??on triggered by Event 0
  CMC = CMC | (0x2 << 6); //External Capture 1 Func??on triggered by Event 1
  Timer_REG(dCMC) = CMC;

 //Connection Matrix Control
  ECR = 1; // Event 0 Edge Selection on rising edge
  ECR = ECR | (0x1 << 2); // Event 1 Edge Selection on rising edge
  ECR = ECR | (0x3 << 9); // Event 0 Low Pass Filter Configuration
  ECR = ECR | (0x3 << 11); // Event 1 Low Pass Filter Configuration

  Timer_REG(dECR) = ECR;

  //Set Interrupt 
  IEC = 0;
  IEC = IEC | tm_Ev0DS | tm_Ev1DS;
  Timer_REG(dIEC) =  IEC; 

}

void init_timer1(void) {
  uint32_t TMS;

  //set PWM out
  Timer1_REG(dTmPrSh)   = 0xff;
  Timer1_REG(dTmCmpSh)  = 0xfe;
  Timer1_REG(dTmCmpSh1) = 0xfe;

  //Set Timer mode
  TMS = 0; //Set TCM Center aligned mode
  Timer1_REG(dTMS) = TMS; 
}

void init_intrupt(void) {

  // Clear interrupts
  clear_csr(mie, MIP_MSIP);
  clear_csr(mie, MIP_MTIP);

  // Enable the Machine-Timer bit in MIE
  set_csr(mie, MIP_MSIP);
  set_csr(mie, MIP_MTIP);

  // Enable interrupts in general.
  set_csr(mstatus, MSTATUS_MIE);
}

void init_UART(void) {
  //UART initialization
  uint8_t CR;

  CR = 0;
  CR = CR | 0x01;  //Set Odd parity
  CR = CR | (0x1 << 3); //set Rx Data Available Interrupt
 //CR = CR | (0x1 << 4); //set Tx Empty Interrupt
 //CR = CR | (0x1 << 5); //set Rx Error Status Interrupt
 //CR = CR | (1'b1 << 6); //Internal Loop TX to RX

  UART0_REG(dCR_UART)  = CR; //Set Odd parity
  UART0_REG(dDLL_UART) = BR921600; //Set 

}

uint32_t get_us()
{
    static uint64_t first = 0;
    if (!first) {
        first = mtimer_mtime();
    }
    uint64_t current = mtimer_mtime();
    return (uint64_t) (4000000LL * (current - first) / CORECLOCK);
}

void main(void) {
 
 Begin_Time = get_us();

 uint32_t i, TmCap1mCap0;
 uint8_t str[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
 float tic = 0.03333;
 uint32_t min = 60000000;
 uint32_t rpm;
 uint8_t RxCntL;
 uint8_t j,state = 0, cmd = 0, cmd_val = 0, cmdRX = 0;
 
 //Timer initialization
  init_timer();
  init_timer1();
  init_intrupt();
  init_UART();
	
  //Run Timer's 
  Timer_REG(dTRS)  = 0x1;
  Timer1_REG(dTRS) = 0x1;

 for(i = 0; i < strlen(messege); i++) UART0_REG(dFIFOtx_UART) = messege[i]; //strlen(messege)

 while(1){  

  if(pullInt & tmInt){
    if(ISR_tm & tm_Ev0DS){
      TmCap1mCap0 = Timer_REG(dTmC1mC0);
      rpm = min/(tic*TmCap1mCap0*20);
 //     IO_REG32(0x4) = TmCap1mCap0;
      for(i = 0; i < 7; i++) UART0_REG(dFIFOtx_UART) = sendEV0[i];
      sprintf(str, "%d", rpm);
      for(i = 0; i < strlen(str); i++) UART0_REG(dFIFOtx_UART) = str[i];
    };

    ISR_tm =ISR_tm & ~tm_Ev0DS;
        
    if(ISR_tm & tm_Ev1DS){
      TmCap1mCap0 = Timer_REG(dTmC3mC2);
      rpm = min/(tic*TmCap1mCap0*20);
//      IO_REG32(0x4) = TmCap1mCap0;
      for(i = 0; i < 7; i++) UART0_REG(dFIFOtx_UART) = sendEV1[i];
      sprintf(str, "%d", rpm);
      for(i = 0; i < strlen(str); i++) UART0_REG(dFIFOtx_UART) = str[i];
    };

    ISR_tm =ISR_tm & ~tm_Ev1DS;
    pullInt = pullInt & (~tmInt);
 //   IO_REG32(0x4) = pullInt; 

  }
  else if (pullInt & uartInt){
    RxCntL = UART0_REG(dRxCntL_UART);
    IO_REG32(0x4) = RxCntL;

    //for (j =0; j < RxCntL; j++) str[j] = UART0_REG(dFIFOrx_UART);
    //for(j = 0; j < RxCntL; j++) UART0_REG(dFIFOtx_UART) = str[j];
    //pullInt = pullInt & (~uartInt);
    //IO_REG32(0x4) = pullInt;

    //RX cmd
    for (j =0; j < RxCntL; j++){
      str[0] = UART0_REG(dFIFOrx_UART);
      IO_REG32(0x4) = str[0];
      switch(state)
      {
        case 0:
          if(str[0] ==  0x63) state = 1; // c
          else state = 0;
          //IO_REG32(0x4) = state;
	  break;
        case 1:
          if(str[0] == 0x6D) state = 2; // m
          else state = 0;
          //IO_REG32(0x4) = state;
	  break;
        case 2:
          if(str[0] == 0x64) state = 3; // d
          else state = 0;
          //IO_REG32(0x4) = state;
	  break;
        case 3:
          cmd =  str[0];
          state = 4;
          //IO_REG32(0x4) = state;
	  break;
        case 4:
          cmd_val =  str[0];
          cmdRX = 1;
          state = 0;
          //IO_REG32(0x4) = state;
	  break;
        default:
          state = 0;
          break;
      }
      IO_REG32(0x4) = state;
    }
    if(UART0_REG(dRxCntL_UART) == 0) pullInt = pullInt & (~uartInt);
  }
  else if (cmdRX != 0){
    if(cmd == 0x1){ //enable Drive
      IO_REG32(0x0) = cmd_val;
      cmdRX = 0;
    }
    else if(cmd == 0x2){ //set PWM ev0
      Timer1_REG(dTmCmpSh)  = cmd_val;
      cmdRX = 0;
    }
    else if(cmd == 0x3){ //set PWM ev1
      Timer1_REG(dTmCmpSh1) = cmd_val;
      cmdRX = 0;
    }
    else{ //cmd unnow
      cmdRX = 0;
    }

  }

 /*
 for (i = 0; i < 4; i++) {
    IO_REG32(0) = i;
  }
*/
 }
}

/*************************** End of file ****************************/
