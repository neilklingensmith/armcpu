
#define NULL (void*)0

void main(int argc, char **argv);


void __attribute__((naked)) _start() {
    asm("ldr r0,=0x8000");
    asm("mov sp,r0");
    main(1,NULL);
}




void main(int argc, char ** argv) {
    int testresult = 0;
    unsigned int num = (unsigned int)argc;

    volatile unsigned int *port = (unsigned int*)0x6000;

    if(num-argc > 0x0000ffff) {
        *port = 0xDEADBEEF;
    } else if(num < 0x00ffffff) {
        *port = 0xBEEFCAFE;
    }

    num = *port;

    if(num > 0x0000ffff) {
        *port++;
    }

}


