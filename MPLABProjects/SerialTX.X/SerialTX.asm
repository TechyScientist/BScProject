    INCLUDE <p18f47q10.inc>
    
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
    
    BANKSEL RX1PPS    ;Configure RC7 as RX1
    MOVLW 0x17    
    MOVWF RX1PPS
    
    BANKSEL RC6PPS    ;Configure RC6 as TX1
    MOVLW 0x09
    MOVWF RC6PPS
    
    BANKSEL ANSELC
    CLRF ANSELC
    BANKSEL TRISC
    BSF TRISC, 7    ;RC7 is Input for RX
    BCF TRISC, 6    ;RC6 is Output for TX

    BANKSEL SP1BRGL    ;Configure Baud Generator
    MOVLW d'103'
    MOVWF SP1BRGL
    CLRF SP1BRGH
    
    BANKSEL BAUD1CON    ;Configure BAUDCON - Set Baud rate
    CLRF BAUD1CON
    
    BANKSEL RC1STA
    BSF RC1STA,SPEN
    BSF RC1STA,CREN
    
    BANKSEL TX1STA    
    BCF TX1STA, TX9    ;Select 8-bit TX
    BSF TX1STA, TXEN    ;TX Enabled
    BCF TX1STA, SYNC_TX1STA ;Use Asynchronous Mode
    BCF TX1STA, BRGH    ;Use Low Baud Mode

repeat:
wait0: BTFSS TX1STA, TRMT   ;While transmitting, wait
    GOTO wait0    
    BANKSEL TX1REG
    MOVLW 'A'    
    MOVWF TX1REG    ;Move Character to transmit register
wait1: BTFSS TX1STA, TRMT   ;While transmitting, wait
    GOTO wait1
    MOVLW 'B'    
    MOVWF TX1REG    ;Move Character to transmit register
wait2: BTFSS TX1STA, TRMT   ;While transmitting, wait
    GOTO wait2
    MOVLW 'C'    
    MOVWF TX1REG    ;Move Character to transmit register
wait3: BTFSS TX1STA, TRMT   ;While transmitting, wait
    GOTO wait3
    MOVLW ' '    
    MOVWF TX1REG

    GOTO repeat    ;repeat loop
    
    END
