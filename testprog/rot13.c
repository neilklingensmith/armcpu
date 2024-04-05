
void main();

char stack[256];

void __attribute__((naked)) _start() {
    asm("mov sp,%0"
        : /* output */
        : "r"(stack+sizeof(stack)) /* input */
        : /* clobber */);
    main();
}

void rot13(char *text) {
    while(*text) {
        *text = (((*text - 'a') % 26) + 'a');
        text++;
    }
}


char string[] = "thisisateststringfortheencryptionalgorithminthisprogram";

void main() {

    rot13(string);
    while(1);
}
