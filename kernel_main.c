#define VIDEO_WIDTH 80
#define VIDEO_HEIGHT 25
#define VIDEO_RAM 0xb8000

int tty_cursor;		//cursor position
int tty_attribute;	//current symbol attribute

void init_tty(){
	tty_cursor = 0;
	tty_attribute = 7;
}

void clear(){
	char *video = VIDEO_RAM;
	int i;

	for (i = 0; i<VIDEO_HEIGHT*VIDEO_WIDTH; i++){
		*(video+i*2)=' ';
	}
	tty_cursor=0;
}

void putchar(char c){
	char *video = VIDEO_RAM;
	int i;

	switch(c)
