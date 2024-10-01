
void main();

char stack[256];

void __attribute__((naked)) _start() {
    asm("mov sp,%0"
        : /* output */
        : "r"(stack+sizeof(stack)) /* input */
        : /* clobber */);
    main();
}

void delay(unsigned int d) {
    unsigned int i, j;
    for(i = 0; i < 0xfff; i++){
        for(j = 0; j < d; j++) {
            asm("nop");
        }
    }
}
void main() {

    while(1) {
        delay(0xff0);
        *(unsigned int*)0xf000000 = -1;
        delay(0xff0);
        *(unsigned int*)0xf000000 = 0;
    }
}
