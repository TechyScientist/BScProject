    INCLUDE <p18f47q10.inc>
    ;Serial TX pin = RC6
    ;Serial RX pin = RC7
   
TRIG MACRO
    COMF    LATD,f,ACCESS
    ENDM
    
;<editor-fold defaultstate="collapsed" desc="I2C1 Slave Macros">
SendReg1 MACRO FileReg
    MOVFF FileReg, WREG
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
    MOVF SSP1BUF,w,ACCESS
    ENDM
       
I2C1Start MACRO
    BSF SSP1CON2,SEN_SSP1CON2,ACCESS
    ENDM
 
I2C1Restart MACRO
    BSF SSP1CON2,RSEN,ACCESS
    ENDM
 
I2C1Stop MACRO
    BSF SSP1CON2,PEN,ACCESS
    ENDM
I2C1ACK MACRO
    BCF SSP1CON2,ACKDT,ACCESS  ; acknowledge bit state to send
    BSF SSP1CON2,ACKEN,ACCESS  ; initiate acknowledge sequence   
    BTFSC SSP1CON2,ACKEN,ACCESS  ; ack cycle complete??
    GOTO $-2 ; no, so loop again
    ENDM
   
I2C1NACK MACRO
    BSF SSP1CON2,ACKDT,ACCESS  ; acknowledge bit state to send
    BSF SSP1CON2,ACKEN,ACCESS  ; initiate acknowledge sequence   
    BTFSC SSP1CON2,ACKEN,ACCESS  ; ack cycle complete??
    GOTO $-2 ; no, so loop again
    ENDM
I2C1RecEnable MACRO
    BSF SSP1CON2,RCEN,ACCESS 
    ENDM
I2C1Disable MACRO
    BCF SSP1CON1,SSPEN,ACCESS
    ENDM
   
I2C1Get MACRO
    MOVF SSP1BUF,w,ACCESS
    ENDM
    ;</editor-fold>
;<editor-fold defaultstate="collapsed" desc="I2C2 Slave Macros">
SendReg2 MACRO FileReg
    MOVFF  FileReg,WREG
    CALL I2C2Put
    CALL I2C2WaitIdle
    ENDM
   
NBSendReg2 MACRO FileReg
    MOVFF  FileReg,WREG
    CALL I2C2Put
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
    MOVFF SSP2BUF,WREG
    ENDM
       
I2C2Start MACRO
    MOVFF SSP2CON2,WREG
    BSF WREG,SEN_SSP2CON2,ACCESS
    MOVFF WREG,SSP2CON2
    ENDM
 
I2C2Restart MACRO
    MOVFF SSP2CON2,WREG
    BSF WREG,RSEN,ACCESS
    MOVFF WREG,SSP2CON2
    ENDM
 
I2C2Stop MACRO
    MOVFF SSP2CON2,WREG
    BSF WREG,PEN,ACCESS
    MOVFF WREG,SSP2CON2
    ENDM
I2C2ACK MACRO
    MOVFF SSP2CON2,WREG
    BCF WREG,ACKDT,ACCESS  ; acknowledge bit state to send
    BSF WREG,ACKEN,ACCESS  ; initiate acknowledge sequence
    MOVFF WREG,SSP2CON2
    MOVFF SSP2CON2,WREG
    BTFSC WREG,ACKEN,ACCESS  ; ack cycle complete??
    GOTO $-4 ; no, so loop again
    ENDM
   
I2C2NACK MACRO
    MOVFF SSP2CON2,WREG
    BSF WREG,ACKDT,ACCESS  ; acknowledge bit state to send
    BSF WREG,ACKEN,ACCESS  ; initiate acknowledge sequence
    MOVFF WREG,SSP2CON2
    MOVFF SSP2CON2,WREG
    BTFSC WREG,ACKEN,ACCESS  ; ack cycle complete??
    GOTO $-4 ; no, so loop again
    ENDM
I2C2RecEnable MACRO
    MOVFF SSP2CON2,WREG
    BSF WREG,RCEN,ACCESS
    MOVFF WREG,SSP2CON2
    ENDM
I2C2Disable MACRO
    MOVFF SSP2CON2,WREG
    BCF WREG,SSPEN,ACCESS
    MOVFF WREG,SSP2CON2 
    ENDM
   
I2C2Get MACRO
    MOVFF SSP2BUF,WREG
    MOVF WREG,w,ACCESS
    MOVFF WREG,SSP2BUF  
    ENDM
    ;</editor-fold>
;<editor-fold desc="Serial Macros" defaultstate="collapsed">
sendCommand MACRO command
   BTFSS TX1STA, TRMT, ACCESS
   GOTO $-2
   MOVLW command
   MOVWF TX1REG, ACCESS
   ENDM
;</editor-fold>
;<editor-fold desc="Constants" defaultstate="collapsed">
REGF EQU 1
REGW EQU 0
SDI1 EQU RC4
SCL1 EQU RC3
SDI2 EQU RB2
SCL2 EQU RB1
TX1 EQU RC6
RX1 EQU RC7
OTMR0H EQU 0xFD
OTMR0L EQU 0x60
CHECK EQU 0x100
;</editor-fold>
;<editor-fold defaultstate="collapsed" desc="Configuration Bits">
; CONFIG1L
    CONFIG  FEXTOSC = OFF        
    CONFIG  RSTOSC = HFINTOSC_64MHZ
 
    ; CONFIG1H
    CONFIG  CLKOUTEN = OFF       
    CONFIG  CSWEN = ON           
    CONFIG  FCMEN = ON           
 
    ; CONFIG2L
    CONFIG  MCLRE = EXTMCLR      
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
;<editor-fold desc="Data Constant Block 0x00" defaultstate="collapsed">
    CBLOCK 0x00
    flag2
    flag3
    parity
    stopReq
    val
    t
    D10msA
    D10msB
    isrptr
    counter
    bytectr
    blocksH
    blocksL
    inblkH
    inblkL
    inbytectr
    command
    tor1
    tor2
    tor3
    saveSTATUS
    saveW
    saveFSR0H
    saveFSR0L
    saveBSR
    keepBSR
    dacout
    dacstat
    chksum
    firstByte
    debounce
    KTMR0H
    KTMR0L
    intState
    flip
    ENDC
;</editor-fold>
;<editor-fold desc="Vectors" defaultstate="collapsed">   
    ORG 0x00
    CALL Initialize
    GOTO mainline
    ORG 0x08
    GOTO ISR
    ORG 0x18
    GOTO ISR
;</editor-fold>
;<editor-fold desc="Initialization" defaultstate="collapsed">
Initialize
    CLRF isrptr
    ;Initialize Debug I/O Port
    MOVLB 0x0F
    MOVLW 0x0F
    MOVWF TRISA
    CLRF ANSELA
    CLRF LATA
    BSF LATA, RA4
    MOVWF WPUA
    CLRF TRISD
    CLRF LATD
    CLRF dacstat
    CLRF bytectr
    CLRF parity
    SETF stopReq
    CLRF inblkH
    CLRF inblkL
    CLRF debounce
    MOVLW OTMR0H
    MOVWF KTMR0H
    MOVLW OTMR0L
    MOVWF KTMR0L
;<editor-fold desc="Initialize EUSART1" defaultstate="collapsed">
    MOVLB 0x0E ;Set up PPS registers for EUSART1
    MOVLW 0x17   
    MOVWF RX1PPS
    MOVLW 0x09
    MOVWF RC6PPS
   
    MOVLB 0x0F    ;Set up pins for EUSART1 TX/RX
    CLRF TRISC
    BSF TRISC, 7    ;EUSART1 RX
    BCF TRISC, 6    ;EUSART1 TX
    CLRF ANSELC
    MOVLW d'34'    ;Baud 115200
    MOVWF SP1BRGL
    CLRF SP1BRGH
    CLRF BAUD1CON
    BSF BAUD1CON, BRG16    ;16 bit baud generator
    MOVF RC1REG,W    ;Clear EUSART1 RX register
    BSF RC1STA,SPEN    ;Enable EUSART1
    BSF RC1STA,CREN    ;Enable EUSART1 RX
    BCF TX1STA, TX9    ;Select 8-bit TX
    BSF TX1STA, TXEN    ;Enable EUSART1 TX
    BCF TX1STA, SYNC_TX1STA ;Use Asynchronous Mode
    BCF TX1STA, BRGH    ;Use Low Baud Mode
;</editor-fold>
;<editor-fold desc="Initialize I2C Ports" defaultstate="collapsed">
    MOVLB 0x0E
    MOVLW 0x13
    MOVWF SSP1CLKPPS
    MOVLW 0x09
    MOVWF SSP2CLKPPS
    MOVLW 0x14
    MOVWF SSP1DATPPS
    MOVLW 0x0A
    MOVWF SSP2DATPPS
    MOVLW 0x0F
    MOVWF RC3PPS
    MOVLW 0x12
    MOVWF RB2PPS
    MOVLW 0x10
    MOVWF RC4PPS
    MOVLW 0x11
    MOVWF RB1PPS
    MOVLB 0x0F
    MOVLW 0xFF
    MOVWF TRISC
    MOVWF TRISB
    CLRF ANSELC
    CLRF ANSELB
    MOVLW b'00011000'
    MOVWF INLVLC
    CLRF SLRCONC
    MOVLW b'00000110'
    MOVWF INLVLB
    CLRF SLRCONB
    CALL softReset1
    CALL softReset2
    I2C1Disable
    I2C2Disable
    CALL D10mSec
    CALL D10mSec
    CALL I2C1Setup
    CALL I2C2Setup
    I2C1Start
    I2C2Start
    CALL I2C1WaitIdle
    I2C1Stop
    CALL I2C1WaitIdle
    CALL I2C2WaitIdle
    I2C2Stop
    CALL I2C2WaitIdle  
;</editor-fold>
;<editor-fold desc="Initialize Interrupts" defaultstate="collapsed">
    MOVLB 0x0E
    BCF IPR3,RC1IP
    BCF PIE3,RC1IE
    BCF PIR0,TMR0IF
    BCF PIE0,TMR0IE
    MOVLW 0x90
    MOVWF T0CON0
    MOVLW 0x40
    MOVWF T0CON1
    BCF INTCON,IPEN
    BSF INTCON,PEIE_GIEL
    BSF INTCON,GIE_GIEH
    RETURN
 
;</editor-fold>
 
;</editor-fold>
;<editor-fold desc="Time Out Functions" defaultstate="collapsed">
TimeoutReset
    MOVLB 0x00
    CLRF tor1
    CLRF tor2
    CLRF tor3
    RETURN
TimeoutInc
    MOVLB 0x00
    INCF tor1
    BZ inc2
    RETURN
inc2:
    INCF tor2
    BZ inc3
    RETURN
inc3:
    INCF tor3
    RETURN
;</editor-fold>
;<editor-fold desc="Checksum Function" defaultstate="collapsed">
checksum
    MOVLW 0x00
    MOVWF counter
    LFSR FSR0, 0x100
    MOVLW 0x00
   
nextNum:
    ADDWF POSTINC0, REGW, ACCESS
    DECFSZ counter, REGF, ACCESS
    GOTO nextNum
    RETURN
;</editor-fold>
;<editor-fold defaultstate="collapsed" desc="I2C1 Master Functions">
   
I2C1WaitIdle
    MOVF SSP1CON2,w,ACCESS
    ANDLW 0x1f ;Any of these? SEN,PEN,RSEN,RCEN,ACKEN
    BTFSS STATUS,Z,ACCESS
    BRA I2C1WaitIdle
    BTFSC SSP1STAT,R_W,ACCESS  ; transmission in progress?
    BRA I2C1WaitIdle
    RETURN
   
I2C1WaitData 
    BTFSS SSP1STAT,BF,ACCESS
    GOTO I2C1WaitData
    RETURN
   
I2C1Setup
    MOVLW 0x28 ; enable MSSP as master
    MOVWF SSP1CON1,ACCESS
    MOVLW 0x20
    MOVWF SSP1ADD,ACCESS
    RETURN
   
I2C1Put ;RETURN 0 is okay, otherwise -1
    MOVWF SSP1BUF,ACCESS
    BTFSS SSP1CON1,WCOL,ACCESS
    RETLW 0
    BCF SSP1CON1,WCOL,ACCESS  ; clear collision flag
    RETLW -1
   
I2C1GotAck ; RETURN 0 if okay, -1 otherwise
    BTFSC SSP1CON2,ACKSTAT,ACCESS 
    RETLW -1
    RETLW 0
;</editor-fold>
;<editor-fold defaultstate="collapsed" desc="I2C2 Master Functions">
   
I2C2WaitIdle
    MOVFF SSP2CON2,WREG
    ANDLW 0x1f ;Any of these? SEN,PEN,RSEN,RCEN,ACKEN
    BTFSS STATUS,Z,ACCESS
    BRA I2C2WaitIdle
    MOVFF SSP2STAT,WREG
    BTFSC WREG,R_W,ACCESS  ; transmission in progress?
    BRA I2C2WaitIdle
    RETURN
   
I2C2WaitData 
    MOVFF SSP2STAT,WREG
    BTFSS WREG,BF,ACCESS
    GOTO I2C2WaitData
    RETURN
   
I2C2Setup
    MOVLW 0x28 ; enable MSSP as master
    MOVFF WREG,SSP2CON1
    MOVLW 0x20
    MOVFF WREG,SSP2ADD
    RETURN
   
I2C2Put ;RETURN 0 is okay, otherwise -1
    MOVFF WREG,SSP2BUF
    MOVFF SSP2CON1,WREG
    BTFSS WREG,WCOL,ACCESS
    RETLW 0
    BCF WREG,WCOL,ACCESS  ; clear collision flag
    MOVFF WREG,SSP2CON1
    RETLW -1   
    
I2C2GotAck ; RETURN 0 if okay, -1 otherwise  
    MOVFF SSP2CON2,WREG
    BTFSC WREG,ACKSTAT,ACCESS 
    RETLW -1
    RETLW 0
;</editor-fold>
;<editor-fold defaultstate="collapsed" desc="Helper Functions">
softReset1
    BSF     LATC,SDI1
    BSF     LATC,SCL1
    BCF     TRISC,SDI1
    BCF     TRISC,SCL1
    CALL    D1uSec
    BCF     LATC,SDI1
    CALL    D1uSec
    BCF     LATC,SCL1
    CALL    D1uSec
    CALL    D1uSec
    BSF     LATC,SDI1
    MOVLW   d'9'
resloop1:
    CALL    D1uSec
    BSF     LATC,SCL1
    CALL    D1uSec
    BCF     LATC,SCL1
    DECFSZ  WREG
    BRA     resloop1
    CALL    D1uSec
    CALL    D1uSec
    BCF     LATC,SDI1
    CALL    D1uSec
    BSF     LATC,SCL1
    CALL    D1uSec
    BSF     LATC,SDI1
    BSF     TRISC,SDI1
    BSF     TRISC,SCL1
    RETURN
   
softReset2
    BSF     LATB,SDI2
    BSF     LATB,SCL2
    BCF     TRISB,SDI2
    BCF     TRISB,SCL2
    CALL    D1uSec
    BCF     LATB,SDI2
    CALL    D1uSec
    BCF     LATB,SCL2
    CALL    D1uSec
    CALL    D1uSec
    BSF     LATB,SDI2
    MOVLW   d'9'
resloop2:
    CALL    D1uSec
    BSF     LATB,SCL2
    CALL    D1uSec
    BCF     LATB,SCL2
    DECFSZ  WREG
    BRA     resloop2
    CALL    D1uSec
    CALL    D1uSec
    BCF     LATB,SDI2
    CALL    D1uSec
    BSF     LATB,SCL2
    CALL    D1uSec
    BSF     LATB,SDI2
    BSF     TRISB,SDI2
    BSF     TRISB,SCL2
    RETURN
D1uSec
    NOP
    NOP
    NOP
    NOP
    RETURN
   
 
D20uSec
    MOVLW  4
    GOTO   delPatch 
D1mSec
    MOVLW  .21
    GOTO   delPatch  
D10mSec
    MOVLW   .210
delPatch   
    CLRF    D10msA,ACCESS
    MOVWF   D10msB,ACCESS
rms:
    DECFSZ  D10msA,1,ACCESS
    GOTO    rms
    DECFSZ  D10msB,1,ACCESS
    GOTO    rms
    RETURN
    
INCNVMADDR
    BCF STATUS, C
    RLCF NVMADRL
    BTFSS STATUS, Z
    RETURN
    INCF NVMADRH
    BTFSS STATUS, Z
    RETURN
    INCF NVMADRU
    RETURN
    
initBlkWrt
    MOVLW 0x00
    MOVWF NVMADRU
    MOVLW 0x06
    MOVWF NVMADRH
    MOVLW 0x00
    MOVWF NVMADRL
    RETURN
;</editor-fold>
;<editor-fold desc="DAC Functions">
DACON
    MOVFF BSR, keepBSR
    BCF LATA, RA4
    BSF LATA, RA5
    CLRF stopReq
    call I2C2WaitIdle
    I2C2Start
    CALL I2C2WaitIdle
    Send2 0x98
    Send2 0x10
    MOVLB 0x0E
    MOVFF KTMR0H, TMR0H
    MOVFF KTMR0L, TMR0L
    BSF PIE0,TMR0IE
    MOVFF keepBSR, BSR
    RETURN
   
DACOFF
    MOVFF BSR, keepBSR
    CLRF debounce
    BSF LATA, RA4
    BCF LATA, RA5
    MOVLB 0x0E
    BCF PIE0,TMR0IE
    CALL I2C2WaitIdle
    I2C2Stop
    CALL I2C2WaitIdle
    I2C2Start
    CALL I2C2WaitIdle
    Send2 0x98
    Send2 0x10
    Send2 0x80
    Send2 0
    I2C2Stop
    MOVFF keepBSR, BSR
    RETURN
;</editor-fold>
 ;<editor-fold desc="Serial Functions">
 
     
nextBlkWrt:
; Code sequence to modify one complete sector of PFM
READ_BLOCK:
    MOVFF INTCON,intState
    BCF INTCON, GIE ; disable interrupts
    BSF NVMCON0, NVMEN ; enable NVM
   ; ----- Required Sequence -----
    MOVLW 0BBh
    MOVWF NVMCON2 ; first unlock byte = 0BBh
    MOVLW 44h
    MOVWF NVMCON2 ; second unlock byte = 44h
    BSF NVMCON1, SECRD ; start sector read (CPU stall)
   ; ------------------------------
ERASE_BLOCK: ; NVMADR is already pointing to target block
; ----- Required Sequence -----
    MOVLW 0CCh
    MOVWF NVMCON2 ; first unlock byte = 0CCh
    MOVLW 33h
    MOVWF NVMCON2 ; second unlock byte = 33h
    BSF NVMCON1, SECER ; start sector erase (CPU stall)
; ------------------------------
MODIFY_BLOCK:
    MOVFF NVMADRU,TBLPTRU
    MOVFF NVMADRH,TBLPTRH
    MOVFF NVMADRL,TBLPTRL
    LFSR FSR0, 0x100
    MOVLW 0x00
blkLoop:
    MOVWF flip
    MOVFF POSTINC0, WREG
    BTFSC FSR0L, 0
    XORLW 0x80
    MOVWF TABLAT
    MOVFF flip, WREG
    TBLWT*+
    DECFSZ WREG
    GOTO blkLoop
PROGRAM_MEMORY: ; NVMADR is already pointing to target block
    ; ----- Required Sequence -----
     MOVLW 0DDh
     MOVWF NVMCON2 ; first unlock byte = 0DDh
     MOVLW 22h
     MOVWF NVMCON2 ; second unlock byte = 22h
     BSF NVMCON1, SECWR ; start sector programming (CPU stall)
    ; ------------------------------

     BCF NVMCON0, NVMEN ; disable NVM
     BTFSC intState, GIE ; only re-enable interrupts if they were enabled
     BSF INTCON, GIE ; re-enable interrupts
     INCF NVMADRH
     BTFSS STATUS,Z
     RETURN
     INCF NVMADRU
     RETURN
 
downloadSample
    CLRF isrptr
    SETF stopReq
    MOVLB 0x0E
waitDAC:
    BTFSC PIE0, TMR0IE
    GOTO waitDAC
    CALL initBlkWrt
    MOVF RC1REG, w
    BSF PIE3, RC1IE
    LFSR FSR0, 0x100
    BCF LATA, RA4
    BCF LATA, RA5
    BSF LATA, RA7
waitSet:
    MOVF isrptr
    BTFSC STATUS, Z, ACCESS
    GOTO waitSet
waitZero:
    MOVF isrptr
    BTFSS STATUS, Z, ACCESS
    GOTO waitZero
    CALL checksum
    MOVWF chksum
    MOVFF CHECK, firstByte
    sendCommand 'C'
waitChk:
    MOVF isrptr
    BTFSC STATUS, Z, ACCESS
    GOTO waitChk
    MOVF chksum, w
    LFSR FSR0, 0x100
    CPFSEQ INDF0
    GOTO resend
    MOVFF firstByte, CHECK

    CALL nextBlkWrt
    
    CLRF isrptr
    MOVFF NVMADRU,WREG
    XORLW 0x01
    BTFSS STATUS, Z
    GOTO sendN
    MOVFF NVMADRH,WREG
    XORLW 0xFA
    BTFSC STATUS, Z
    GOTO sendX
sendN:
    sendCommand 'N'
    GOTO waitSet
sendX:
    sendCommand 'X'
    GOTO done
   
resend:
    CLRF isrptr
    sendCommand 'R'
    GOTO waitSet
   
done:
    BCF PIE3, RC1IE
    BCF LATA, RA7
    BSF LATA, RA4
    RETURN
 ;</editor-fold>
 
mainline:
    BTFSS PORTA, RA1
    CALL downloadSample
    BTFSS PORTA, RA2
    GOTO play
    BTFSS PORTA, RA3
    GOTO stop
    GOTO mainline
    
play:
    MOVF debounce, f
    BTFSS STATUS, Z
    GOTO mainline
    INCF debounce
    CALL DACON
    MOVLW 0x00
    MOVFF WREG, TBLPTRU
    MOVLW 0x06
    MOVFF WREG, TBLPTRH
    MOVLW 0x00
    MOVFF WREG, TBLPTRL
    GOTO mainline
    
stop:
    BCF LATA, RA5
    SETF stopReq
    GOTO mainline
    
ISR:
    MOVFF STATUS, saveSTATUS
    MOVFF WREG, saveW
    MOVFF BSR, saveBSR
    MOVFF FSR0H, saveFSR0H
    MOVFF FSR0L, saveFSR0L
    TRIG
    MOVLB 0x0E
    BTFSS PIE0, TMR0IE
    GOTO checkSerial
    BTFSS PIR0, TMR0IF
    GOTO checkSerial
    BCF PIR0, TMR0IF
    MOVFF KTMR0H, TMR0H
    MOVFF KTMR0L, TMR0L
    
    TBLRD*+
    NBSendReg2 TABLAT
    COMF parity
    BTFSS STATUS, Z
    GOTO doMore
    MOVF debounce, f
    BTFSS STATUS, Z
    INCF debounce
    MOVF stopReq
    BTFSS STATUS, Z
    GOTO off
doMore:
    MOVFF TBLPTRU,WREG
    XORLW 0x01
    BTFSS STATUS, Z
    GOTO checkSerial
    MOVFF TBLPTRH,WREG
    XORLW 0xFA
    BTFSC STATUS, Z
off:
    CALL DACOFF
    
checkSerial:
    BTFSS PIR3, RC1IF
    GOTO restore
    MOVLW 0x01
    MOVWF FSR0H
    MOVFF isrptr, FSR0L
    MOVLB 0x00
    MOVFF RC1REG, INDF0
    INCF isrptr
restore:
    MOVFF saveW, WREG
    MOVFF saveBSR, BSR
    MOVFF saveFSR0H, FSR0H
    MOVFF saveFSR0L, FSR0L
    MOVFF saveSTATUS, STATUS
    RETFIE

    org 0x600
    INCLUDE G3.txt

    END
