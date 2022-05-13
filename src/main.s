// https://sourceware.org/binutils/docs-2.38/as.html
// https://developer.arm.com/documentation/dui0552
// https://github.com/ARM-software/abi-aa/blob/main/aapcs32/aapcs32.rst
// https://www.st.com/resource/en/reference_manual/cd00171190-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf

.syntax unified
.cpu cortex-m3
.thumb


.section .text.main
.global main
.type main,%function 
main:
    ldr R0,=misDatos
    movs R1,#32
    bl punto4
idle:
    wfi
    b idle
.size main, . - main


.section .text.punto4
.global punto4
.type punto4,%function
punto4:
    // R0: dirección datos, R1: cantidad datos
    // Sacar R1 bytes por PA0..PA7, manteniendo cada byte 1ms
    push {R4-R6,LR}
    movs R4,R0
    movs R5,R1
    movs R6,#0 // contador
    bl inicializa_puerto_a
    bl inicializar_systick
0:
    
    pop {R4-R6,PC}
.size punto4, . - punto4

.set RCC_base, 0x40021000
.set RCC_APB2ENR, 0x18
.set IOPAEN_mask, (1<<2)

.set GPIOA_base, 0x40010800
.set GPIO_CRL, 0x00
.set P0_P7_Salida_PP_2MHz, 0x22222222

.text
inicializa_puerto_a:
    // conecta reloj
    ldr R0,=RCC_base
    ldr R1,[R0,#RCC_APB2ENR]
    orrs R1,#IOPAEN_mask
    str R1,[R0,#RCC_APB2ENR]
    // PA0..PA7 como salidas, push-pull, 2_MHz
    ldr R0,=GPIOA_base
    ldr R1,=P0_P7_Salida_PP_2MHz
    str R1,[R0,#GPIO_CRL]
    bx lr

.set SysTick_base, 0xE000E010
.set SYST_CSR, 0x00
.set SYST_RVR, 0x04
.set SYST_CVR, 0x08
.set RELOJ_reset, 8000000
.set SYST_CSR_Enable_mask, (1<<0)
.set SYST_CSR_Coutflag_mask, (1<<16)
inicializar_systick:
// Program reload value.
    ldr R0,=SysTick_base
    ldr R1,=((1*RELOJ_reset)/1000)
    str R1,[R0,#SYST_RVR]
// Clear current value.
    movs R1,#0
    str R1,[R0,#SYST_CVR]
// Program Control and Status register.
    ldr R1,[R0,#SYST_CSR]
    orrs R1,SYST_CSR_Enable_mask
    str R1,[R0,#SYST_CSR]
    bx LR
delay_1ms:
    // COUNTFLAG Returns 1 if timer counted to 0 since last time this was read.
    ldr R0,=SysTick_base
0:
    ldr R1,[R0,#SYST_CSR]
    tst R1,#SYST_CSR_Coutflag_mask
    beq 0b
    bx lr
.pool
misDatos:
    .ascii "Electronica IV. Practico 1. P_IV"