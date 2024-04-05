


    ldr r0, =0x8000
    ldr r1, =0x11223344
    ldr r2, =0x55667788

    sub r0,#4

    str r1,[r0]
    str r1,[r0,#4]
    ldr r3,[r0]
    ldrb r4,[r0]
    ldrb r5,[r0,#1]
    ldrb r5,[r0,#2]
    ldrb r5,[r0,#3]
    ldrb r5,[r0,#4]

    sub r0,#4
    str r2,[r0]
    ldr r3,[r0]
    ldr r3,[r0,#4]
    ldrb r5,[r0]
    ldrb r5,[r0,#1]
    ldrb r5,[r0,#2]
    ldrb r5,[r0,#3]
    ldrb r5,[r0,#4]
    ldrb r5,[r0,#5]
    ldrb r5,[r0,#6]
    ldrb r5,[r0,#7]


    wfe
