


_start:

    ldr r0,=0xa5a5a5a5
    ldr r1,=0x11111111
    ldr r2,=0x22222222
    mov r8,r0
    mov r9,r1
    add r9,r8
    add r1,r9
    add r3,r1

    add r0,r1,r2
    add r1,r2,r3
    add r2,r3,r4
    sub r7,r0,r3
    sub r6,r0,r7

    add r1,r2,#5
    add r1,r2,#1
    add r1,r2,#1
    add r1,r2,#1
    add r1,r2,#1
