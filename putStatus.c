#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "caca.h"
#include "common-image.h"

int main(int argc, char **argv){
    caca_canvas_t *cv;
    void *export;
    size_t len;
    struct image *img;
    unsigned int width = 128, height = 16, iconWidth = 32, messageHeight = 10, linei;

    if(argc < 2){
        fprintf(stderr, "%s: wrong argument count\n", argv[0]);
		fprintf(stderr, "%s <icon_path>\n", argv[0]);
        return 1;
    }

    cv = caca_create_canvas(0, 0);

    img = load_image(argv[1]);
    if(!img){
        fprintf(stderr, "%s: unable to load %s\n", argv[0], argv[1]);
        caca_free_canvas(cv);
        return 1;
    }

    caca_set_canvas_size(cv, width, height);
    caca_set_color_ansi(cv, CACA_DEFAULT, CACA_TRANSPARENT);
    caca_clear_canvas(cv);
    caca_set_dither_algorithm(img->dither, "none");

    caca_dither_bitmap(cv, 0, 0, iconWidth, iconWidth/2, img->dither, img->pixels);

    unload_image(img);

	for(linei=0; linei<messageHeight; linei++){
		char str[65];
		sprintf(str, "LINELINELINELINELINELINELINELINELINELINELINELINELINELINELINE%d", linei);
		caca_put_str(cv, iconWidth + 1, linei + (height - messageHeight) / 2, str);
	}
	
    export = caca_export_canvas_to_memory(cv, "ansi", &len);
    if(export){
        fwrite(export, len, 1, stdout);
        free(export);
    }

    caca_free_canvas(cv);

    return 0;
}
