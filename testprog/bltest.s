

    ldr r0,=0x8000
    mov sp,r0
    bl main
    nop
    nop
    nop

main:
    sub sp,#12
    add r7,sp,#0
    nop
    nop
