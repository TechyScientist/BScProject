;-----------------------------------------------
; LEDTimer.asm
; Author: Johnny Console / George Townsend
; COSC 4086 - Fourth Year Project
; Interrupt driven Timer LED Controller
; Device - PIC18F47Q10
; Peripherals - None
; Interrupt Driven: Yes
;-----------------------------------------------
    INCLUDE <p18f47q10.inc>
    
VA EQU 0			    ;Constant for Virtul Access Memory	    

 ; CONFIG1L
    CONFIG  FEXTOSC = OFF         
    CONFIG  RSTOSC = HFINTOSC_64MHZ

    ; CONFIG1H
    CONFIG  CLKOUTEN = OFF        
    CONFIG  CSWEN = ON            
    CONFIG  FCMEN = ON            

    ; CONFIG2L
    CONFIG  MCLRE = INTMCLR       
    CONFIG  PWRTE = OFF           
    CONFIG  LPBOREN = OFF         
    CONFIG  BOREN = SBORDIS       

    ; CONFIG2H
    CONFIG  BORV = VBOR_190       
    CONFIG  ZCD = OFF             
    CONFIG  PPS1WAY = OFF         
    CONFIG  STVREN = ON           
    CONFIG  XINST = OFF          

    ; CONFIG3L
    CONFIG  WDTCPS = WDTCPS_31    
    CONFIG  WDTE = OFF            

    ; CONFIG3H
    CONFIG  WDTCWS = WDTCWS_7    
    CONFIG  WDTCCS = SC           
  
    ; CONFIG4L
    CONFIG  WRT0 = OFF           
    CONFIG  WRT1 = OFF            
    CONFIG  WRT2 = OFF            
    CONFIG  WRT3 = OFF            
    CONFIG  WRT4 = OFF            
    CONFIG  WRT5 = OFF            
    CONFIG  WRT6 = OFF   
    CONFIG  WRT7 = OFF        

    
    
    ; CONFIG4H
    CONFIG  WRTC = OFF           
    CONFIG  WRTB = OFF      
    CONFIG  WRTD = OFF       
    CONFIG  SCANE = ON            
    CONFIG  LVP = ON

    ORG 0x00
    CALL Init
    GOTO Mainline
    ORG 0x08
    GOTO ISR
    ORG 0x18
    GOTO ISR
    
    
Init:  
    CLRF TRISC, VA
    CLRF ANSELC, VA
    
    MOVLW 0xFF
    MOVWF LATC, VA
	
    MOVLW 0xBF;(2^T0EN | 2^T016BIT | 2^T0OUTPS0 | 2^T0OUTPS1)
    MOVWF T0CON0, VA
    MOVLW 0x40;(2^T0CS1)
    MOVWF T0CON1, VA
 
    BANKSEL IPR0
    BSF IPR0,TMR0IP
    BSF PIE0,TMR0IE
    
    BCF INTCON,IPEN, VA
    BSF INTCON,PEIE_GIEL, VA
    BSF INTCON,GIE_GIEH, VA
    RETURN
    
ISR:
    BANKSEL PIR0	    ;Interrupt Service Routine
    BTFSS   PIR0,TMR0IF	    ;If not timer, return
    RETFIE
    BCF PIR0, TMR0IF
    NEGF LATC, VA		    ;Negate Port C to turn on/off LED
    RETFIE
  
Mainline:
    
    GOTO Mainline	    ;repeat loop
    END
