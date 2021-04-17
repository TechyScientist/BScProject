     INCLUDE <p18f47q10.inc>
    
VA EQU 0    ;Constant for Virtul Access Memory
SDI1 EQU RC4
SCL1 EQU RC3
;SCL2 EQU RB2
;SDA2 EQU RB1
 
TRIG MACRO
    CALL trig
    ENDM
 
;<editor-fold defaultstate="collapsed" desc="Configuration Bits">
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
    
    
    ; CONFIG4H
    CONFIG  WRTC = OFF           
    CONFIG  WRTB = OFF      
    CONFIG  WRTD = OFF       
    CONFIG  SCANE = ON            
    CONFIG  LVP = ON
    ;</editor-fold>
   
;<editor-fold defaultstate="collapsed" desc="I2C1 Slave Macros">
SendReg1 MACRO FileReg
    MOVFF WREG, FileReg
    CALL I2C1Put
    CALL I2C1WaitIdle
    ENDM
 
Send1 MACRO SendB
    MOVLW   SendB
    CALL    I2C1Put
    CALL    I2C1WaitIdle
    ENDM

SendW1 MACRO
    CALL    I2C1Put
    CALL    I2C1WaitIdle
    ENDM      
        
Recv1 MACRO
    I2C1RecEnable
    CALL I2C1WaitData
    CALL I2C1WaitData
    MOVF SSP1BUF,w
    ENDM
        
I2C1Start MACRO 
    BSF SSP1CON2,SEN_SSP1CON2
    ENDM

I2C1Restart MACRO
    BSF SSP1CON2,RSEN
    ENDM
 

I2C1Stop MACRO
    BSF SSP1CON2,PEN
    ENDM
 
I2C1ACK MACRO
    BCF SSP1CON2,ACKDT ; acknowledge bit state to send
    BSF SSP1CON2,ACKEN ; initiate acknowledge sequence    
    BTFSC SSP1CON2,ACKEN ; ack cycle complete??
    GOTO $-2 ; no, so loop again
    ENDM
    
I2C1NACK MACRO
    BSF SSP1CON2,ACKDT ; acknowledge bit state to send
    BSF SSP1CON2,ACKEN ; initiate acknowledge sequence    
    BTFSC SSP1CON2,ACKEN ; ack cycle complete??
    GOTO $-2 ; no, so loop again
    ENDM
 
I2C1RecEnable MACRO 
    BSF SSP1CON2,RCEN 
    ENDM
 
I2C1Disable MACRO
    BCF SSP1CON1,SSPEN
    ENDM
    
I2C1Get MACRO
    MOVF SSP1BUF,w
    ENDM
    ;</editor-fold>
;<editor-fold defaultstate="collapsed" desc="I2C2 Slave Macros">
SendReg2 MACRO FileReg
    MOVFF WREG, FileReg
    CALL I2C2Put
    CALL I2C2WaitIdle
    ENDM
 
Send2 MACRO SendB
    MOVLW   SendB
    CALL    I2C2Put
    CALL    I2C2WaitIdle
    ENDM

SendW2 MACRO
    CALL    I2C2Put
    CALL    I2C2WaitIdle
    ENDM      
        
Recv2 MACRO
    I2C2RecEnable
    CALL I2C1WaitIdle
    CALL I2C1WaitData
    MOVF SSP2BUF,w
    ENDM
        
I2C2Start MACRO 
    BSF SSP2CON2,SEN_SSP2CON2
    ENDM

I2C2Restart MACRO
    BSF SSP2CON2,RSEN
    ENDM
 

I2C2Stop MACRO
    BSF SSP2CON2,PEN
    ENDM
 
I2C2ACK MACRO
    BCF SSP2CON2,ACKDT ; acknowledge bit state to send
    BSF SSP2CON2,ACKEN ; initiate acknowledge sequence    
    BTFSC SSP2CON2,ACKEN ; ack cycle complete??
    GOTO $-2 ; no, so loop again
    ENDM
    
I2C2NACK MACRO
    BSF SSP2CON2,ACKDT ; acknowledge bit state to send
    BSF SSP2CON2,ACKEN ; initiate acknowledge sequence    
    BTFSC SSP2CON2,ACKEN ; ack cycle complete??
    GOTO $-2 ; no, so loop again
    ENDM
 
I2C2RecEnable MACRO 
    BSF SSP2CON2,RCEN 
    ENDM
 
I2C2Disable MACRO
    BCF SSP2CON1,SSPEN
    ENDM
    
I2C2Get MACRO
    MOVF SSP2BUF,w
    ENDM
    ;</editor-fold>
    
    cblock 0x00

    val
    t
    D10msA
    D10msB
    endc
    

    org 0

    MOVLB 0x0e
    MOVLW 0x13
    MOVWF SSP1CLKPPS
    MOVLW 0x14
    MOVWF SSP1DATPPS
    MOVLW 0x0F
    MOVWF RC3PPS
    MOVLW 0x10
    MOVWF RC4PPS
    
    MOVLB   0x0f
    clrf    TRISA
    clrf    PORTA
    movlw   0xff
    movwf   TRISC
    clrf    ANSELC
    movlw   b'00011000'
    movwf   INLVLC
    clrf    SLRCONB

    call    softReset
    I2C1Disable

    call D10mSec
    call D10mSec
    
    call    I2C1Setup
       
    I2C1Start
    call    I2C1WaitIdle
    I2C1Stop
    call    I2C1WaitIdle  
    
spin
    I2C1Start
    call    I2C1WaitIdle

    call D10mSec
    call D10mSec
    
    
    Send1    0x98 ; I2C address + R/W=0
    Send1    0x10 ; command to send a 16 bit data word to be converted
    Send1    0X80 ; MBS of data to convert
    Send1    0xFF ; LBS of data to convert
    goto stall
    TRIG
    Send1    0xA0
    Send1    0x00
    Send1    0x00
    Send1    0x55
    Send1    0x00
    Send1    0x55
    Send1    0xff
    Send1    0x55
    Send1    0x55
    Send1    0x55
    Send1    0x55
   
    I2C1Stop
    call    I2C1WaitIdle
    goto spin
skip 
    I2C1Start
    call    I2C1WaitIdle
    TRIG
    Send1    0xA0
    Send1    0x00
    Send1    0x00
    

;    I2Cstop
;    call    I2CwaitForIdle
   
    TRIG
    I2C1Start
    call    I2C1WaitIdle
    Send1    0xA1
    Recv1
    I2C1ACK
    Recv1
    I2C1ACK
    Recv1
    I2C1ACK
    Recv1
    I2C1ACK
    Recv1
    I2C1ACK
    Recv1
    I2C1ACK
    Recv1
    I2C1ACK
    Recv1
    I2C1NACK

;   movwf   val,VA
;    I2C1Stop
;    call    I2C1WaitIdle
    I2C1Stop
    call    I2C1WaitIdle
    call    D10mSec
    call    D10mSec
    call    D10mSec
    goto    spin
    
    ;clrf    val,VA
    I2C1Start
    call    I2C1WaitIdle       
    Send1    0x98 ; I2C address + R/W=0
    Send1    0x10 ; command to send a 16 bit data word to be converted
    movff    val,WREG
    SendW1
    Send1    0x00 ; LBS of data to convert
    
    
stall
    goto stall 
   
    
    
;<editor-fold defaultstate="collapsed" desc="I2C1 Master Functions">
    
I2C1WaitIdle
    MOVF SSP1CON2,w
    ANDLW 0x1f ;Any of these? SEN,PEN,RSEN,RCEN,ACKEN
    BTFSS STATUS,Z
    BRA I2C1WaitIdle
    BTFSC SSP1STAT,R_W ; transmission in progress?
    BRA I2C1WaitIdle
    RETURN
    
I2C1WaitData  
    BTFSS SSP1STAT,BF
    GOTO I2C1WaitData
    RETURN
    
I2C1Setup
    MOVLW 0x28 ; enable MSSP as master
    MOVWF SSP1CON1
    MOVLW 0xff
    MOVWF SSP1ADD
    RETURN
    
I2C1Put ;return 0 is okay, otherwise -1
    MOVWF SSP1BUF
    BTFSS SSP1CON1,WCOL
    RETLW 0
    BCF SSP1CON1,WCOL ; clear collision flag
    RETLW -1
    
I2C1GotAck ; return 0 if okay, -1 otherwise
    BTFSC SSP1CON2,ACKSTAT 
    RETLW -1
    RETLW 0
;</editor-fold>
;<editor-fold defaultstate="collapsed" desc="I2C2 Master Functions">
    
I2C2WaitIdle
    MOVF SSP2CON2,w
    ANDLW 0x1f ;Any of these? SEN,PEN,RSEN,RCEN,ACKEN
    BTFSS STATUS,Z
    BRA I2C2WaitIdle
    BTFSC SSP2STAT,R_W ; transmission in progress?
    BRA I2C2WaitIdle
    RETURN
    
I2C2WaitData  
    BTFSS SSP2STAT,BF
    GOTO I2C2WaitData
    RETURN
    
I2C2Setup
    MOVLW 0x28 ; enable MSSP as master
    MOVWF SSP2CON1
    MOVLW 0xff
    MOVWF SSP2ADD
    RETURN
    
I2C2Put ;return 0 is okay, otherwise -1
    MOVWF SSP2BUF
    BTFSS SSP2CON1,WCOL
    RETLW 0
    BCF SSP2CON1,WCOL ; clear collision flag
    RETLW -1
    
I2C2GotAck ; return 0 if okay, -1 otherwise
    BTFSC SSP2CON2,ACKSTAT 
    RETLW -1
    RETLW 0
;</editor-fold>
;<editor-fold defaultstate="collapsed" desc="Helper Functions">
softReset
    bsf     LATB,SDI1
    bsf     LATB,SCL1
    bsf     LATC,SDI1
    bsf     LATC,SCL1
    bcf     TRISB,SDI1
    bcf     TRISB,SCL1
    bcf     TRISC,SDI1
    bcf     TRISC,SCL1
    call    D1uSec
    bcf     LATB,SDI1
    bcf     LATC,SDI1
    call    D1uSec
    bcf     LATB,SCL1
    bcf     LATC,SCL1
    call    D1uSec
    call    D1uSec
    bsf     LATB,SDI1
    bsf     LATC,SDI1
    movlw   d'9'
resloop
    call    D1uSec
    bsf     LATB,SCL1
    bsf     LATC,SCL1
    call    D1uSec
    bcf     LATB,SCL1
    bcf     LATC,SCL1
    decfsz  WREG
    bra     resloop
    call    D1uSec
    call    D1uSec
    bcf     LATB,SDI1
    bcf     LATC,SDI1
    call    D1uSec
    bsf     LATB,SCL1
    bsf     LATC,SCL1
    call    D1uSec
    bsf     LATB,SDI1
    bsf     TRISB,SDI1
    bsf     TRISB,SCL1
    bsf     LATC,SDI1
    bsf     TRISC,SDI1
    bsf     TRISC,SCL1
    return
    
    
D1uSec
    nop
    nop
    nop
    nop
    return
   
    
trig
    comf    LATA
    return
    
    
D10mSec
    clrf    D10msA,VA
    movlw   .210
    movwf   D10msB,VA
rms
    decfsz  D10msA,1,VA
    goto    rms
    decfsz  D10msB,1,VA
    goto    rms
    return
;</editor-fold>
    
    end
