    INCLUDE <p18f47q10.inc>
    
;<editor-fold desc="Macros" defaultstate="collapsed">
TRIG MACRO
    CALL trig
    ENDM
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
;<editor-fold desc="Serial Macros">
sendCommand MACRO command
 MOVLW command
 MOVWF TX1REG, ACCESS
 BTFSS TX1STA, TRMT, ACCESS
 GOTO $-2
 ENDM
;</editor-fold>

   
    
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
    CALL    D1uSec
    bcf     LATB,SDI1
    bcf     LATC,SDI1
    CALL    D1uSec
    bcf     LATB,SCL1
    bcf     LATC,SCL1
    CALL    D1uSec
    CALL    D1uSec
    bsf     LATB,SDI1
    bsf     LATC,SDI1
    MOVLW   d'9'
resloop
    CALL    D1uSec
    bsf     LATB,SCL1
    bsf     LATC,SCL1
    CALL    D1uSec
    bcf     LATB,SCL1
    bcf     LATC,SCL1
    decfsz  WREG
    bra     resloop
    CALL    D1uSec
    CALL    D1uSec
    bcf     LATB,SDI1
    bcf     LATC,SDI1
    CALL    D1uSec
    bsf     LATB,SCL1
    bsf     LATC,SCL1
    CALL    D1uSec
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
    CLRF    D10msA,ACCESS
    MOVLW   .210
    MOVWF   D10msB,ACCESS
rms
    decfsz  D10msA,1,ACCESS
    GOTO    rms
    decfsz  D10msB,1,ACCESS
    GOTO    rms
    return
;</editor-fold>
;<editor-fold desc="Serial Functions">
waitForBlock
    CALL TimeoutReset
    MOVLW 0x00
wait1:
    CPFSGT isrptr, ACCESS
    GOTO inct1
wait2:
    CPFSEQ isrptr, ACCESS
    GOTO inct2
    MOVLW 0x55 ;rem
    MOVWF LATA, ACCESS;rem
    ;HALT;rem
    CALL checksum
    sendCommand 'C'
    CALL TimeoutReset
    MOVLW 0x00
cs:
    CPFSGT isrptr, ACCESS
    GOTO inctcs
inct1:
    CALL TimeoutInc
    BZ endf
    GOTO wait1
inct2:
    CALL TimeoutInc
    BZ endf
    GOTO wait2
inctcs:
    CALL TimeoutInc
    BZ endf
    GOTO cs
    LFSR FSR0, 0x100
    MOVFF INDF0, WREG
    CPFSEQ check, ACCESS
    GOTO checkError
    CALL SendBlockToRam
    MOVLW 0x00
    CALL incBlocks
    CPFSEQ blocksL, ACCESS
    GOTO checkMSB
    sendCommand 'N'
    GOTO endf
checkMSB:
    MOVLW 0x03
    CPFSEQ blocksH, ACCESS
    GOTO endf
    sendCommand 'X'
    GOTO endf
checkError:
    sendCommand 'R'
endf:
    MOVLW 0xFF;rem
    MOVWF LATA, ACCESS;rem
   ;HALT;rem
    RETURN

checksum
    MOVLW 0xFF
    MOVWF counter
    LFSR FSR0, 0x100
    MOVLW 0x00
    
nextNum:
    ADDWF POSTINC0, REGW, ACCESS
    DECFSZ counter, ACCESS
    GOTO nextNum
    MOVFF WREG, check
    RETURN
    
incBlocks
    MOVLW 0x00
    INCF blocksL, REGF, ACCESS
    CPFSEQ blocksL, ACCESS
    GOTO noMSB
    INCF blocksH, REGF, ACCESS
noMSB:
    RETURN
   
SendBlockToRam
    I2C1Start
    CALL I2C1WaitIdle
    MOVLW 0xFF
    MOVWF counter, ACCESS
    LFSR FSR0, 0x100
    BCF STATUS, C, ACCESS
    RLCF blocksH, REGF, ACCESS
    MOVFF blocksH, WREG
    IORLW 0xA0
    SendW1
    MOVFF blocksL, WREG
    SendW1
    MOVLW 0x00
    SendW1
nextSend:
    SendReg1 POSTINC0
    DECFSZ counter, ACCESS
    GOTO nextSend
    I2C1Stop
    RETURN
    

    
;<editor-fold desc="I2C1 Setup" defaultstate="collapsed">
    MOVLB 0x0E
    MOVLW 0x13
    MOVWF SSP1CLKPPS
    MOVLW 0x14
    MOVWF SSP1DATPPS
    MOVLW 0x0F
    MOVWF RC3PPS
    MOVLW 0x10
    MOVWF RC4PPS
    MOVLW 0x17    
    MOVWF RX1PPS
    MOVLW 0x09
    MOVWF RC6PPS
;</editor-fold>

    end
