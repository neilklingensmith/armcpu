

void main();
unsigned int convolve(float *out, float *a, float *b, unsigned int na, unsigned int nb);

char stack[1024];

void __attribute__((naked)) _start() {
    asm("mov sp,%0"
        : /* output */
        : "r"(stack+sizeof(stack)) /* input */
        : /* clobber */);
//    asm("mov sp,r0");
    main();
    asm("wfe");
}


void main() {
    float a[10], b[10], c[20];


    convolve(c, a, b, 10, 10);
}

