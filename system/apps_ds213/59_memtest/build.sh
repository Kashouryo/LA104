#https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads

export PATH="/Users/gabrielvalky/Downloads/gcc-arm-none-eabi-7-2018-q2-update/bin/":"$PATH"
mkdir -p build
cd build

arm-none-eabi-gcc -Os -Werror -fno-common -mcpu=cortex-m3 -mthumb -msoft-float -fno-exceptions -Wno-psabi -MD -c \
  ../testdata.c \
  -I../../../os_library/include/ 

arm-none-eabi-g++ -Os -Werror -fno-common -mcpu=cortex-m3 -mthumb -msoft-float -fno-exceptions -fno-rtti -fno-threadsafe-statics -Wno-psabi -MD -D DS203 -D _ARM -D STM32F10X_HD -c \
  ../main.cpp \
  -I../../../os_library/include/ 

arm-none-eabi-gcc -fPIC -mcpu=cortex-m3 -mthumb -o output.elf -nostartfiles -T ../app.lds \
  ./main.o \
  ./testdata.o \
  -lbios_ds203 -L../../../os_library/build

arm-none-eabi-objdump -d -S output.elf > output.asm
arm-none-eabi-readelf -all output.elf > output.txt

find . -type f -name '*.o' -delete
find . -type f -name '*.d' -delete

../../../../tools/elfstrip/elfstrip output.elf 59memtst.elf

nm --print-size --size-sort -gC output.elf | grep " B " > symbols_ram.txt
nm --print-size --size-sort -gC output.elf | grep " T " > symbols_rom.txt
nm --print-size --size-sort -gC output.elf > symbols_all.txt
#objdump -s -j .dynamic output.elf