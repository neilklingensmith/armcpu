


conv:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -march=armv6-m -mfloat-abi=soft -O2 -g -c -nostartfiles -no-pie -Wl,--build-id=none -o conv.o -nostartfiles conv.c
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -march=armv6-m -O2 -g -c -nostartfiles -no-pie -Wl,--build-id=none -o convmain.o -nostartfiles convmain.c
	arm-none-eabi-gcc --specs=nano.specs -mthumb -march=armv6-m -nostartfiles -g -no-pie -Wl,--build-id=none -o conv.elf -nostartfiles convmain.o conv.o -T cpu-himem.ld -lc -lm -lgcc
	arm-none-eabi-objcopy -O verilog conv.elf loadfile_all.img


blinky:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -nostartfiles -no-pie -Wl,--build-id=none -o blinky.elf -nostartfiles blinky.c -T cpu-himem.ld
	arm-none-eabi-objcopy -O verilog blinky.elf loadfile_all.img


branchtest:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -nostartfiles -g -o branchtest.elf branchtest.c -T cpu.ld
	arm-none-eabi-objcopy -O verilog branchtest.elf loadfile_all.img

rot13:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -nostartfiles -no-pie -Wl,--build-id=none -o rot13.elf -nostartfiles rot13.c -T cpu.ld
#	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -nostartfiles -o rot13.elf rot13.c -T cpu.ld
	arm-none-eabi-objcopy -O verilog rot13.elf loadfile_all.img

pushtest:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -c pushtest.s -Tcpu.ld
	arm-none-eabi-objcopy -O verilog pushtest.o loadfile_all.img


ldsttest:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -c ldsttest.s -Tcpu.ld
	arm-none-eabi-objcopy -O verilog ldsttest.o loadfile_all.img


bltest:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -c bltest.s -Tcpu.ld
	arm-none-eabi-objcopy -O verilog bltest.o loadfile_all.img


imm:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -c addsubcmpmovimmtest.s -Tcpu.ld
	arm-none-eabi-objcopy -O verilog addsubcmpmovimmtest.o loadfile_all.img


addtest:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -c addtest.s -Tcpu.ld
	arm-none-eabi-objcopy -O verilog addtest.o loadfile_all.img


ldliteraltest:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -c ldliteraltest.s -Tcpu.ld
	arm-none-eabi-objcopy -O verilog ldliteraltest.o loadfile_all.img


movregtest:
	arm-none-eabi-gcc -mthumb -mcpu=cortex-m0plus -c movregtest.s -Tcpu.ld
	arm-none-eabi-objcopy -O verilog movregtest.o loadfile_all.img

