.PHONY: all clean

all:
	ca65 src/main.asm
	ca65 src/reset.asm
	ca65 src/player.asm
	ca65 src/enemy.asm
	ld65 src/reset.o src/player.o src/enemy.o src/main.o -C nes.cfg -o artifacts/vapor.nes

clean:
	rm -f src/*.o