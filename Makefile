.PHONY: all clean

all:
	$(CA65_PATH)/ca65 src/main.asm
	$(CA65_PATH)/ca65 src/reset.asm
	$(CA65_PATH)/ca65 src/player.asm
	$(CA65_PATH)/ca65 src/enemy.asm
	$(CA65_PATH)/ca65 src/bullets.asm
	$(CA65_PATH)/ca65 src/background.asm
	$(CA65_PATH)/ca65 src/collisions.asm
	$(CA65_PATH)/ca65 src/random.asm
	$(CA65_PATH)/ca65 src/utils.asm
	$(CA65_PATH)/ca65 src/levels.asm
	$(CA65_PATH)/ld65 src/reset.o \
		 src/player.o \
		 src/enemy.o \
		 src/bullets.o \
		 src/background.o \
		 src/collisions.o \
		 src/random.o \
		 src/utils.o \
		 src/levels.o \
		 src/main.o -C nes.cfg --dbgfile artifacts/vapor.dbg -o artifacts/vapor.nes

clean:
	rm -f src/*.o