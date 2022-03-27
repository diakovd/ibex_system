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
#include "../ibex_core_pkg/ibex_core.h"
//#include "include/const.h"
//#include "include/gd32vf103.h"
#include "include/mtime.h"
//#include "__SEGGER_RTL.h"
#include "__SEGGER_RTL_Int.h"

#define CORECLOCK 40000000

struct __SEGGER_RTL_FILE_impl {         // NOTE: Provides implementation for FILE
  int stub; // only needed so impl has size != 0.
};

static FILE __SEGGER_RTL_stdin_file  = { 0 };  // stdin reads from UART
static FILE __SEGGER_RTL_stdout_file = { 0 };  // stdout writes to UART
static FILE __SEGGER_RTL_stderr_file = { 0 };  // stderr writes to UART

FILE *stdin  = &__SEGGER_RTL_stdin_file;  // NOTE: Provide implementation of stdin for RTL.
FILE *stdout = &__SEGGER_RTL_stdout_file; // NOTE: Provide implementation of stdout for RTL.
FILE *stderr = &__SEGGER_RTL_stderr_file; // NOTE: Provide implementation of stderr for RTL.
static int          _stdin_ungot  = EOF;

/*********************************************************************
*
*       main()
*
*  Function description
*   Application entry point.
*/
uint32_t x,i;
uint8_t messege[] = "Super Puper Word!!! ";

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
      handle_TIMER_interrupt(0xffff); //0xffff
      clear_csr(mip, MIP_MTIP);
    }
  //else while (1);
  return epc;
}

uint8_t CR;

void init_timer(void) {
  uint32_t TMS;
  uint32_t CMC;
  uint32_t ECR;

  Timer_REG(dTmPrSh) = 0xffff;

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
  Timer_REG(dECR) = ECR;

  //Set Interrupt 
  Timer_REG(dIEC) =  0x1; //Period match

}

void init_timer1(void) {
  uint32_t TMS;

  //set PWM out
  Timer1_REG(dTmPrSh)   = 0xff;
  Timer1_REG(dTmCmpSh)  = 0x7f;
  Timer1_REG(dTmCmpSh1) = 0x60;

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
  CR = 0;
  CR = CR | 0x01;  //Set Odd parity
 //CR = CR | (1'b1 << 3); //set Rx Data Available Interrupt
 //CR = CR | (0x1 << 4); //set Tx Empty Interrupt
 //CR = CR | (0x1 << 5); //set Rx Error Status Interrupt
 //CR = CR | (1'b1 << 6); //Internal Loop TX to RX

  UART0_REG(dCR_UART) = CR; //Set Odd parity
  UART0_REG(dDLL_UART) = BR115200 & 0xFF; //Set 
  UART0_REG(dDLH_UART) = BR115200 >> 8; //Set 
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

uint64_t  Begin_Time;

int __SEGGER_RTL_X_file_write (__SEGGER_RTL_FILE *__stream, const char *__s, unsigned __len)
{
  //HAL_UART_Transmit(&huart1, __s, __len, 10);
  int i,j;
  uint8_t st;
  for(i = 0; i < __len; i++) {
//	j = UART0_REG(dFCR_UART);  
//	IO_REG32(0) = j;  
	while(dTxFull & UART0_REG(dFCR_UART)){
//		j = UART0_REG(dFCR_UART);  
//		IO_REG32(0) = j; 		
	}; //wait not full fifo tx
	UART0_REG(dFIFOtx_UART) = __s[i];
  }
  return 0;
}

 int __SEGGER_RTL_X_file_stat(__SEGGER_RTL_FILE *stream)
 {
	  if (stream == stdin || stream == stdout || stream == stderr) {
		return 0;       // NOTE: stdin, stdout, and stderr are assumed to be valid.
	  } else {
		return EOF;
	  }
 }                                // Get file status.               >= 0: OK. < 0: Invalid file stream.
 int __SEGGER_RTL_X_file_bufsize(__SEGGER_RTL_FILE *stream) {
  (void)stream;
  return 1;
 }                              // Get stream buffer size.        == 1: Unbuffered I/O. > 1: Size of buffer.
 int __SEGGER_RTL_X_file_read(__SEGGER_RTL_FILE * stream, char * s, unsigned len){
  return 0;
 };       // Read data from file stream.    >= 0: OK. < 0: Failed to read.
 int __SEGGER_RTL_X_file_unget(__SEGGER_RTL_FILE *stream, int c){
	  if (stream == stdin) {
		if (c != EOF && _stdin_ungot == EOF) {
		  _stdin_ungot = c;
		} else {
		  c = EOF;
		}
	  } else {
		c = EOF;
	  }
	  return c;
 };                        // Push character back to stream. >= 0: OK. < 0: Error.

void main(void) {
 

 //Timer initialization
//  init_timer();
//  init_timer1();
//  init_intrupt();
    init_UART();
	

	extern void dhry();
	dhry();

	return 0;
}

/*
 *************************************************************************
 *
 *                   "DHRYSTONE" Benchmark Program
 *                   -----------------------------
 *
 *  Version:    C, Version 2.1
 *
 *  File:       dhry_1.c (part 2 of 3)
 *
 *  Date:       May 25, 1988
 *
 *  Author:     Reinhold P. Weicker
 *
 *************************************************************************
 */


#define Mic_secs_Per_Second     1000000.0
                /* Berkeley UNIX C returns process times in seconds/HZ */

#ifdef  NOSTRUCTASSIGN
#define structassign(d, s)      memcpy(&(d), &(s), sizeof(d))
#else
#define structassign(d, s)      d = s
#endif

#ifdef  NOENUM
#define Ident_1 0
#define Ident_2 1
#define Ident_3 2
#define Ident_4 3
#define Ident_5 4
  typedef int   Enumeration;
#else
  typedef       enum    {Ident_1, Ident_2, Ident_3, Ident_4, Ident_5}
                Enumeration;
#endif
        /* for boolean and enumeration types in Ada, Pascal */

/* General definitions: */


#define Null 0 
                /* Value of a Null pointer */
#define true  1
#define false 0

typedef int     One_Thirty;
typedef int     One_Fifty;
typedef char    Capital_Letter;
typedef int     Boolean;
typedef char    Str_30 [51];
typedef int     Arr_1_Dim [25];        /* <-- changed from 50 */
typedef int     Arr_2_Dim [25] [25];   /* <-- changed from 50 */

typedef struct record {
    struct record *Ptr_Comp;
    Enumeration    Discr;
    union {
        struct {
            Enumeration Enum_Comp;
            int         Int_Comp;
            char        Str_Comp [41];
        } var_1;
        struct {
            Enumeration E_Comp_2;
            char        Str_2_Comp [41];
        } var_2;
        struct {
            char        Ch_1_Comp;
            char        Ch_2_Comp;
        } var_3;
    } variant;
} Rec_Type, *Rec_Pointer;

/*  Prototypes of function defined in dhry21b.c and called from dhry21a.c.
 */
void Proc_6( Enumeration Enum_Val_Par, Enumeration * Enum_Ref_Par );
void Proc_7( One_Fifty Int_1_Par_Val, One_Fifty Int_2_Par_Val,
                                                      One_Fifty * Int_Par_Ref );
void Proc_8( Arr_1_Dim Arr_1_Par_Ref, Arr_2_Dim Arr_2_Par_Ref,
                                         int Int_1_Par_Val, int Int_2_Par_Val );
Enumeration Func_1( Capital_Letter Ch_1_Par_Val, Capital_Letter Ch_2_Par_Val );
Boolean Func_2( Str_30 Str_1_Par_Ref, Str_30 Str_2_Par_Ref );


/* Global Variables: */

Rec_Pointer     Ptr_Glob,
                Next_Ptr_Glob;
int             Int_Glob;
Boolean         Bool_Glob;
char            Ch_1_Glob,
                Ch_2_Glob;
int             Arr_1_Glob [25];        /* <-- changed from 50 */
int             Arr_2_Glob [25] [25];   /* <-- changed from 50 */

char Reg_Define[] = "Register option selected.";

#ifndef ROPT
#define REG
        /* REG becomes defined as empty */
        /* i.e. no register variables   */
#else
#define REG register
#endif


/* variables for time measurement: */

#define Too_Small_Time 2000000
                /* Measurements should last at least 2 seconds */

uint64_t      Begin_Time,
              End_Time,
              User_Time;

double        Microseconds,
              Dhrystones_Per_Second,
              Vax_Mips;

/* end of variables for time measurement */

void Proc_1( REG Rec_Pointer Ptr_Val_Par );
void Proc_2( One_Fifty * Int_Par_Ref );
void Proc_3( Rec_Pointer * Ptr_Ref_Par );
void Proc_4( void );
void Proc_5( void );

  /* main program, corresponds to procedures        */
  /* Main and Proc_0 in the Ada version             */
void dhry() {

        One_Fifty       Int_1_Loc;
  REG   One_Fifty       Int_2_Loc;
        One_Fifty       Int_3_Loc;
  REG   char            Ch_Index;
        Enumeration     Enum_Loc;
        Str_30          Str_1_Loc;
        Str_30          Str_2_Loc;
  REG   int             Run_Index;
#define  Number_Of_Runs  1000000

  /* Initializations */

  puts("Dhrystone Benchmark, Version 2.1 (Language: C)");
  static Rec_Type t1, t2;
  Next_Ptr_Glob = (Rec_Pointer)&t1;
  Ptr_Glob = (Rec_Pointer)&t2;

  Ptr_Glob->Ptr_Comp                    = Next_Ptr_Glob;
  Ptr_Glob->Discr                       = Ident_1;
  Ptr_Glob->variant.var_1.Enum_Comp     = Ident_3;
  Ptr_Glob->variant.var_1.Int_Comp      = 40;
  strcpy (Ptr_Glob->variant.var_1.Str_Comp, 
          "DHRYSTONE PROGRAM, SOME STRING");
  strcpy (Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");

  Arr_2_Glob [8][7] = 10;
        /* Was missing in published program. Without this statement,    */
        /* Arr_2_Glob [8][7] would have an undefined value.             */
        /* Warning: With 16-Bit processors and Number_Of_Runs > 32000,  */
        /* overflow may occur for this array element.                   */

  
  /***************/
  /* Start timer */
  /***************/
 
  Begin_Time = get_us();
  printf("Execution starts...\n");

  for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index)
  {
    Proc_5();
    Proc_4();
      /* Ch_1_Glob == 'A', Ch_2_Glob == 'B', Bool_Glob == true */
    Int_1_Loc = 2;
    Int_2_Loc = 3;
    strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
    Enum_Loc = Ident_2;
    Bool_Glob = ! Func_2 (Str_1_Loc, Str_2_Loc);
      /* Bool_Glob == 1 */
    while (Int_1_Loc < Int_2_Loc)  /* loop body executed once */
    {
      Int_3_Loc = 5 * Int_1_Loc - Int_2_Loc;
        /* Int_3_Loc == 7 */
      Proc_7 (Int_1_Loc, Int_2_Loc, &Int_3_Loc);
        /* Int_3_Loc == 7 */
      Int_1_Loc += 1;
    } /* while */
      /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Proc_8 (Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
      /* Int_Glob == 5 */
    Proc_1 (Ptr_Glob);
    for (Ch_Index = 'A'; Ch_Index <= Ch_2_Glob; ++Ch_Index)
                             /* loop body executed twice */
    {
      if (Enum_Loc == Func_1 (Ch_Index, 'C'))
          /* then, not executed */
        {
        Proc_6 (Ident_1, &Enum_Loc);
        strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
        Int_2_Loc = Run_Index;
        Int_Glob = Run_Index;
        }
    }
      /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
    Int_2_Loc = Int_2_Loc * Int_1_Loc;
    Int_1_Loc = Int_2_Loc / Int_3_Loc;
    Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
      /* Int_1_Loc == 1, Int_2_Loc == 13, Int_3_Loc == 7 */
    Proc_2 (&Int_1_Loc);
      /* Int_1_Loc == 5 */

  } /* loop "for Run_Index" */

  /**************/
  /* Stop timer */
  /**************/

  End_Time = get_us();

  printf ("\r\n");
  printf ("Final values of the variables used in the benchmark:\r\n");
  printf ("\r\n");
  printf ("Int_Glob:            %d\r\n", Int_Glob);
  printf ("        should be:   %d\r\n", 5);
  printf ("Bool_Glob:           %d\r\n", Bool_Glob);
  printf ("        should be:   %d\r\n", 1);
  printf ("Ch_1_Glob:           %c\r\n", Ch_1_Glob);
  printf ("        should be:   %c\r\n", 'A');
  printf ("Ch_2_Glob:           %c\r\n", Ch_2_Glob);
  printf ("        should be:   %c\r\n", 'B');
  printf ("Arr_1_Glob[8]:       %d\r\n", Arr_1_Glob[8]);
  printf ("        should be:   %d\r\n", 7);
  printf ("Arr_2_Glob[8][7]:    %d\r\n", Arr_2_Glob[8][7]);
  printf ("        should be:   Number_Of_Runs + 10\r\n");
  printf ("Ptr_Glob->\r\n");
  printf ("  Ptr_Comp:          %d\r\n", (int) Ptr_Glob->Ptr_Comp);
  printf ("        should be:   (implementation-dependent)\r\n");
  printf ("  Discr:             %d\r\n", Ptr_Glob->Discr);
  printf ("        should be:   %d\r\n", 0);
  printf ("  Enum_Comp:         %d\r\n", Ptr_Glob->variant.var_1.Enum_Comp);
  printf ("        should be:   %d\r\n", 2);
  printf ("  Int_Comp:          %d\r\n", Ptr_Glob->variant.var_1.Int_Comp);
  printf ("        should be:   %d\r\n", 17);
  printf ("  Str_Comp:          %s\r\n", Ptr_Glob->variant.var_1.Str_Comp);
  printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\r\n");
  printf ("Next_Ptr_Glob->\r\n");
  printf ("  Ptr_Comp:          %d\r\n", (int) Next_Ptr_Glob->Ptr_Comp);
  printf ("        should be:   (implementation-dependent), same as above\r\n");
  printf ("  Discr:             %d\r\n", Next_Ptr_Glob->Discr);
  printf ("        should be:   %d\r\n", 0);
  printf ("  Enum_Comp:         %d\r\n", Next_Ptr_Glob->variant.var_1.Enum_Comp);
  printf ("        should be:   %d\r\n", 1);
  printf ("  Int_Comp:          %d\r\n", Next_Ptr_Glob->variant.var_1.Int_Comp);
  printf ("        should be:   %d\r\n", 18);
  printf ("  Str_Comp:          %s\r\n", Next_Ptr_Glob->variant.var_1.Str_Comp);
  printf ("        should be:   DHRYSTONE PROGRAM, SOME STRING\r\n");
  printf ("Int_1_Loc:           %d\r\n", Int_1_Loc);
  printf ("        should be:   %d\r\n", 5);
  printf ("Int_2_Loc:           %d\r\n", Int_2_Loc);
  printf ("        should be:   %d\r\n", 13);
  printf ("Int_3_Loc:           %d\r\n", Int_3_Loc);
  printf ("        should be:   %d\r\n", 7);
  printf ("Enum_Loc:            %d\r\n", Enum_Loc);
  printf ("        should be:   %d\r\n", 1);
  printf ("Str_1_Loc:           %s\r\n", Str_1_Loc);
  printf ("        should be:   DHRYSTONE PROGRAM, 1'ST STRING\r\n");
  printf ("Str_2_Loc:           %s\r\n", Str_2_Loc);
  printf ("        should be:   DHRYSTONE PROGRAM, 2'ND STRING\r\n");
  printf ("\r\n");
  User_Time = End_Time - Begin_Time;
  printf("Execution ends (after %lu ms)\n", (uint32_t) (User_Time/1000LL));

  if (User_Time < Too_Small_Time)
  {
    puts("Measured time too small to obtain meaningful results");
    puts("Please increase number of runs");
  }
  else
  {
    Microseconds = (double) User_Time / (double) Number_Of_Runs;
    Dhrystones_Per_Second = (double) Number_Of_Runs / ((double)User_Time/1000000.0);
    Vax_Mips = Dhrystones_Per_Second / 1757.0;
  
/*
#ifdef ROPT
    printf ("Register option selected?  YES\r\n");
#else
    printf ("Register option selected?  NO\r\n");
    strcpy(Reg_Define, "Register option not selected.");
#endif
*/
    printf("Microseconds for one run through Dhrystone: ");
    printf("%lu\n", (uint32_t) Microseconds);
    printf("Dhrystones per Second: ");
    printf("%lu\n", (uint32_t) Dhrystones_Per_Second);
    printf("VAX MIPS rating = ");
    printf("%lu\n", (uint32_t) Vax_Mips);
  }
}

void Proc_1( REG Rec_Pointer Ptr_Val_Par )
/******************/
    /* executed once */
{
  REG Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;  
                                        /* == Ptr_Glob_Next */
  /* Local variable, initialized with Ptr_Val_Par->Ptr_Comp,    */
  /* corresponds to "rename" in Ada, "with" in Pascal           */
  
  structassign (*Ptr_Val_Par->Ptr_Comp, *Ptr_Glob);
  Ptr_Val_Par->variant.var_1.Int_Comp = 5;
  Next_Record->variant.var_1.Int_Comp 
        = Ptr_Val_Par->variant.var_1.Int_Comp;
  Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
  Proc_3 (&Next_Record->Ptr_Comp);
    /* Ptr_Val_Par->Ptr_Comp->Ptr_Comp 
                        == Ptr_Glob->Ptr_Comp */
  if (Next_Record->Discr == Ident_1)
    /* then, executed */
  {
    Next_Record->variant.var_1.Int_Comp = 6;
    Proc_6 (Ptr_Val_Par->variant.var_1.Enum_Comp, 
           &Next_Record->variant.var_1.Enum_Comp);
    Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
    Proc_7 (Next_Record->variant.var_1.Int_Comp, 10, 
           &Next_Record->variant.var_1.Int_Comp);
  }
  else /* not executed */
    structassign (*Ptr_Val_Par, *Ptr_Val_Par->Ptr_Comp);
} /* Proc_1 */


void Proc_2( One_Fifty * Int_Par_Ref )
/******************/
    /* executed once */
    /* *Int_Par_Ref == 1, becomes 4 */
{
  One_Fifty  Int_Loc;
  Enumeration   Enum_Loc;

  Int_Loc = *Int_Par_Ref + 10;
  do /* executed once */
    if (Ch_1_Glob == 'A')
      /* then, executed */
    {
      Int_Loc -= 1;
      *Int_Par_Ref = Int_Loc - Int_Glob;
      Enum_Loc = Ident_1;
    } /* if */
  while (Enum_Loc != Ident_1); /* true */
} /* Proc_2 */


void Proc_3( Rec_Pointer * Ptr_Ref_Par )
/******************/
    /* executed once */
    /* Ptr_Ref_Par becomes Ptr_Glob */
{
  if (Ptr_Glob != Null)
    /* then, executed */
    *Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;
  Proc_7 (10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
} /* Proc_3 */


void Proc_4( void ) /* without parameters */
/*******/
    /* executed once */
{
  Boolean Bool_Loc;

  Bool_Loc = Ch_1_Glob == 'A';
  Bool_Glob = Bool_Loc | Bool_Glob;
  Ch_2_Glob = 'B';
} /* Proc_4 */


void Proc_5( void ) /* without parameters */
/*******/
    /* executed once */
{
  Ch_1_Glob = 'A';
  Bool_Glob = false;
} /* Proc_5 */


        /* Procedure for the assignment of structures,          */
        /* if the C compiler doesn't support this feature       */
#ifdef  NOSTRUCTASSIGN
memcpy (d, s, l)
register char   *d;
register char   *s;
register int    l;
{
        while (l--) *d++ = *s++;
}
#endif

/*
 *************************************************************************
 *
 *                   "DHRYSTONE" Benchmark Program
 *                   -----------------------------
 *
 *  Version:    C, Version 2.1
 *
 *  File:       dhry_2.c (part 3 of 3)
 *
 *  Date:       May 25, 1988
 *
 *  Author:     Reinhold P. Weicker
 *
 *************************************************************************
 */


Boolean Func_3( Enumeration Enum_Par_Val );

void Proc_6( Enumeration Enum_Val_Par, Enumeration * Enum_Ref_Par )
/*********************************/
    /* executed once */
    /* Enum_Val_Par == Ident_3, Enum_Ref_Par becomes Ident_2 */
{
  *Enum_Ref_Par = Enum_Val_Par;
  if (! Func_3 (Enum_Val_Par))
    /* then, not executed */
    *Enum_Ref_Par = Ident_4;
  switch (Enum_Val_Par)
  {
    case Ident_1: 
      *Enum_Ref_Par = Ident_1;
      break;
    case Ident_2: 
      if (Int_Glob > 100)
        /* then */
      *Enum_Ref_Par = Ident_1;
      else *Enum_Ref_Par = Ident_4;
      break;
    case Ident_3: /* executed */
      *Enum_Ref_Par = Ident_2;
      break;
    case Ident_4: break;
    case Ident_5: 
      *Enum_Ref_Par = Ident_3;
      break;
  } /* switch */
} /* Proc_6 */


void Proc_7( One_Fifty Int_1_Par_Val, One_Fifty Int_2_Par_Val,
                                                       One_Fifty * Int_Par_Ref )
/**********************************************/
    /* executed three times                                      */
    /* first call:      Int_1_Par_Val == 2, Int_2_Par_Val == 3,  */
    /*                  Int_Par_Ref becomes 7                    */
    /* second call:     Int_1_Par_Val == 10, Int_2_Par_Val == 5, */
    /*                  Int_Par_Ref becomes 17                   */
    /* third call:      Int_1_Par_Val == 6, Int_2_Par_Val == 10, */
    /*                  Int_Par_Ref becomes 18                   */
{
  One_Fifty Int_Loc;

  Int_Loc = Int_1_Par_Val + 2;
  *Int_Par_Ref = Int_2_Par_Val + Int_Loc;
} /* Proc_7 */


void Proc_8( Arr_1_Dim Arr_1_Par_Ref, Arr_2_Dim Arr_2_Par_Ref,
                                          int Int_1_Par_Val, int Int_2_Par_Val )
/*********************************************************************/
    /* executed once      */
    /* Int_Par_Val_1 == 3 */
    /* Int_Par_Val_2 == 7 */
{
  REG One_Fifty Int_Index;
  REG One_Fifty Int_Loc;

  Int_Loc = Int_1_Par_Val + 5;
  Arr_1_Par_Ref [Int_Loc] = Int_2_Par_Val;
  Arr_1_Par_Ref [Int_Loc+1] = Arr_1_Par_Ref [Int_Loc];
  Arr_1_Par_Ref [Int_Loc+15] = Int_Loc;
  for (Int_Index = Int_Loc; Int_Index <= Int_Loc+1; ++Int_Index)
    Arr_2_Par_Ref [Int_Loc] [Int_Index] = Int_Loc;
  Arr_2_Par_Ref [Int_Loc] [Int_Loc-1] += 1;
  Arr_2_Par_Ref [Int_Loc+10] [Int_Loc] = Arr_1_Par_Ref [Int_Loc];
  Int_Glob = 5;
} /* Proc_8 */


Enumeration Func_1 ( Capital_Letter Ch_1_Par_Val, Capital_Letter Ch_2_Par_Val )
/*************************************************/
    /* executed three times                                         */
    /* first call:      Ch_1_Par_Val == 'H', Ch_2_Par_Val == 'R'    */
    /* second call:     Ch_1_Par_Val == 'A', Ch_2_Par_Val == 'C'    */
    /* third call:      Ch_1_Par_Val == 'B', Ch_2_Par_Val == 'C'    */
{
  Capital_Letter        Ch_1_Loc;
  Capital_Letter        Ch_2_Loc;

  Ch_1_Loc = Ch_1_Par_Val;
  Ch_2_Loc = Ch_1_Loc;
  if (Ch_2_Loc != Ch_2_Par_Val)
    /* then, executed */
    return (Ident_1);
  else  /* not executed */
  {
    Ch_1_Glob = Ch_1_Loc;
    return (Ident_2);
   }
} /* Func_1 */


Boolean Func_2( Str_30 Str_1_Par_Ref, Str_30 Str_2_Par_Ref )
/*************************************************/
    /* executed once */
    /* Str_1_Par_Ref == "DHRYSTONE PROGRAM, 1'ST STRING" */
    /* Str_2_Par_Ref == "DHRYSTONE PROGRAM, 2'ND STRING" */
{
  REG One_Thirty        Int_Loc;
      Capital_Letter    Ch_Loc;

  Int_Loc = 2;
  while (Int_Loc <= 2) /* loop body executed once */
    if (Func_1 (Str_1_Par_Ref[Int_Loc],
                Str_2_Par_Ref[Int_Loc+1]) == Ident_1)
      /* then, executed */
    {
      Ch_Loc = 'A';
      Int_Loc += 1;
    } /* if, while */
  if (Ch_Loc >= 'W' && Ch_Loc < 'Z')
    /* then, not executed */
    Int_Loc = 7;
  if (Ch_Loc == 'R')
    /* then, not executed */
    return (true);
  else /* executed */
  {
    if (strcmp (Str_1_Par_Ref, Str_2_Par_Ref) > 0)
      /* then, not executed */
    {
      Int_Loc += 7;
      Int_Glob = Int_Loc;
      return (true);
    }
    else /* executed */
      return (false);
  } /* if Ch_Loc */
} /* Func_2 */


Boolean Func_3( Enumeration Enum_Par_Val )
/***************************/
    /* executed once        */
    /* Enum_Par_Val == Ident_3 */
{
  Enumeration Enum_Loc;

  Enum_Loc = Enum_Par_Val;
  if (Enum_Loc == Ident_3)
    /* then, executed */
    return (true);
  else /* not executed */
    return (false);
} /* Func_3 */

/*************************** End of file ****************************/
