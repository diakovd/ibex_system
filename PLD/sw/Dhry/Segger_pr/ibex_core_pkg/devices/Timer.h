#ifndef _IBEX_CORE_TIMER_H
#define _IBEX_CORE_TIMER_H 
 
 #define dTRS 		0x0
 #define dTCFS 		0x4
 #define dTRSt 		0x8
 #define dTMS 		0xC
 #define dECR 		0x10
 #define dCMC 		0x14
 #define dISR 		0x18
 #define dIEC 		0x1C
 #define dISC 		0x20
 #define dPLC		0x24
 #define dTmVal 	0x28
 #define dTmPr  	0x2C
 #define dTmPrSh 	0x30
 #define dTmCap0	0x34
 #define dTmCap1	0x38
 #define dTmCap2	0x3C
 #define dTmCap3	0x40
 #define dTmC1mC0       0x44
 #define dTmC3mC2       0x48
 #define dTmCmp 	0x4C
 #define dTmCmpSh	0x50
 #define dTmCmp1 	0x54
 #define dTmCmpSh1	0x58

 
 //Interrupt Enable/Clear/Status bit
 #define tm_PMup 0x1
 #define tm_OMdw 0x2
 #define tm_CMup 0x4
 #define tm_CMdw 0x8
 #define tm_Ev0DS 0x10
 #define tm_Ev1DS 0x20
 #define tm_Ev2DS 0x40

 //Event control register bit


 #endif /* _IBEX_CORE_TIMER_H */