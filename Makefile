.PHONY: all clean

all:
	ca65 src/main.asm
	ca65 src/reset.asm
	ca65 src/player.asm
	ca65 src/enemy.asm
	ca65 src/bullets.asm
	ca65 src/background.asm
	ca65 src/collisions.asm
	ca65 src/random.asm
	ld65 src/reset.o \
		 src/player.o \
		 src/enemy.o \
		 src/bullets.o \
		 src/background.o \
		 src/collisions.o \
		 src/random.o \
		 src/main.o -C nes.cfg --dbgfile artifacts/vapor.dbg -o artifacts/vapor.nes

clean:
	rm -f src/*.o