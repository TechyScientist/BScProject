
     INCLUDE <p18f47q10.inc>
    
VA EQU 0    ;Constant for Virtul Access Memory
SDI1 EQU 4
SCL1 EQU 3
 
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
   
;<editor-fold defaultstate="collapsed" desc="I2C Slave Macros">
SEND MACRO SendB
    movlw   SendB
    call    I2Cput
    call    I2CwaitForIdle
    ENDM

        
RECV MACRO
    I2CrecEnable
    call    I2CwaitForIdle
    call    I2CwaitForData
    movf    SSP1BUF,w
    ENDM
        
I2Cstart macro 
    bsf     SSP1CON2,SEN_SSP1CON2
    endm

I2CreStart macro
    bsf     SSP1CON2,RSEN
    endm
 

I2Cstop macro
    bsf     SSP1CON2,PEN
    endm
 

I2Cack macro
    bcf     SSP1CON2,ACKDT
    bsf     SSP1CON2,ACKEN
    endm

I2CnoAck macro
    bsf     SSP1CON2,ACKDT
    bsf         SSP1CON2,ACKEN
    endm
 
I2CrecEnable macro 
    bsf     SSP1CON2,RCEN 
    endm
 
I2Cdisable macro
    bcf     SSP1CON1,SSPEN
    endm
    
I2Cget macro
    movf    SSP1BUF,w
    endm
    ;</editor-fold>

    
    cblock 0x00

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
    movlw   0xff
    movwf   TRISC
    clrf    ANSELC
    movlw   b'00011000'
    movwf   INLVLC
    clrf    SLRCONB

    call trig
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    
    call    softReset

    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec


    I2Cdisable
    
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    
    call    I2Csetup
    call go
    call go
    
    
   
stall
    goto stall
    
    
go    
   
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    
    
    I2Cstart
    
    call    I2CwaitForIdle

    
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    
    SEND    0x7C
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    SEND    0x80
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    SEND    0x3c
    
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec

    
    SEND    0x80
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    SEND    0x0e
    
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec

    
    SEND    0x80
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    SEND    0x01
   
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec

    
    SEND    0x80
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    SEND    0x06
    
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    
    SEND 0x80
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    SEND 0x01
    
    call pause
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec

    SEND 0x80
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    SEND 0x02
    
    call D10mSec
    call D10mSec
    call D10mSec
    call D10mSec
    
    SEND 0x40
    SEND 'H'
    call pause
    SEND 'e'
    call pause
    SEND 'l'
    call pause
    SEND 'l'
    call pause
    SEND 'o'
    call pause
    SEND ' '
    call pause
    SEND 'w'
    call pause
    SEND 'o'
    call pause
    SEND 'r'
    SEND 'l'
    SEND 'd'
    SEND '!'
   
    I2Cstop
    call    I2CwaitForIdle
   

    call pause 
    call D10mSec 
    return
    
    
   
   
   
pause
    clrf    t,VA
r
    decfsz  t,1,VA
    goto    r
    return

    
    
;<editor-fold defaultstate="collapsed" desc="I2C MMP MASTER MODE FUNCTIONS">
; I2C MMP MASTER MODE FUNCTIONS
    
I2CwaitForIdle
    movf    SSP1CON2,w
    andlw   0x1f ;Any of these? SEN,PEN,RSEN,RCEN,ACKEN
    btfss   STATUS,Z
    bra     I2CwaitForIdle
    btfsc   SSP1STAT,R_W ; transmission in progress?
    bra     I2CwaitForIdle
    return
    
I2CwaitForData  
    btfss   SSP1STAT,BF
    goto    I2CwaitForData
    return
    
I2Csetup
    movlw   0x28 ; enable MSSP as master
    movwf   SSP1CON1
    movlw   0xff
    movwf   SSP1ADD
    return
    
I2Cput ;return 0 is okay, otherwise -1
    movwf   SSP1BUF
    btfss   SSP1CON1,WCOL
    retlw   0
    bcf     SSP1CON1,WCOL ; clear collision flag
    retlw   -1
    
I2CgotAck ; return 0 if okay, -1 otherwise
    btfsc   SSP1CON2,ACKSTAT 
    retlw   -1
    retlw   0


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
    
    
    ;</editor-fold>
   
    
trig
    clrf    PORTA
    comf    LATA
    clrf    PORTA
    return
    
    
D10mSec
    call    xxx
    call    xxx
xxx
    clrf    D10msA,VA
    movlw   .255
    movwf   D10msB,VA
rms
    decfsz  D10msA,1,VA
    goto    rms
    decfsz  D10msB,1,VA
    goto    rms
    return
    
    end



