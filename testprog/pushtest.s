
    ldr r0,=0x8000
    mov sp,r0

    ldr r1,=0xAAAAAAAA
    ldr r2,=0xBBBBBBBB
    ldr r3,=0xCCCCCCCC
    ldr r4,=0xDDDDDDDD

    push {r1,r2,r3,r4}

    mov r0,sp

    ldr r4,[r0]
    ldr r5,[r0,#4]
    ldr r6,[r0,#8]
    ldr r7,[r0,#12]
