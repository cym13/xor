#include <errno.h>
#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define BUFSIZE 4096

static const char help_msg[] =
    "Fast file XOR-ing\n"
    "\n"
    "Usage: xor [options] FILES...\n"
    "\n"
    "Arguments:\n"
    "    FILES   Files to be XOR-ed together.\n"
    "            Smaller files are padded with NUL bytes.\n"
    "\n"
    "Options:\n"
    "    -h, --help          Print this help and exit\n"
    "    -v, --version       Print the version and exit\n"
    "\n"
    "    -s, --string STR    XOR against fixed, repeated string\n"
    "    -o, --output FILE   Write output to FILE ; default: stdout";

static const char vernum[] = "2.0.0";

typedef struct {
    bool   string;
    char*  string_arg;
    bool   output;
    char*  output_arg;
    char** files;
} options_t;

size_t fsize(const FILE* file) {
    int fd = fileno((FILE*)file);
    struct stat buf;

    if (fstat(fd, &buf) < 0) {
        printf("%s\n", strerror(errno));
        exit(1);
    }

    return buf.st_size;
}

int main(int argc, char *argv[])
{
    if (argc == 1) {
        puts(help_msg);
        return 1;
    }

    options_t options = {
        .string     = false,
        .string_arg = NULL,
        .output     = false,
        .output_arg = NULL,
        .files      = NULL,
    };

    int c;
    while (1) {
        int option_index = 0;

        static struct option getopt_options[] = {
            {"help",    no_argument,       0, 0},
            {"version", no_argument,       0, 0},
            {"string",  required_argument, 0, 0},
            {"output",  required_argument, 0, 0},
            {0,         0,                 0, 0}
        };

        c = getopt_long(argc, argv, "hvs:o:", getopt_options, &option_index);

        if (c == -1)
            break;

        switch (c) {
            case (0):
                if (!strcmp("help", getopt_options[option_index].name)) {
                    puts(help_msg);
                    return 0;
                }

                if (!strcmp("version", getopt_options[option_index].name)) {
                    puts(vernum);
                    return 0;
                }

                if (!strcmp("string", getopt_options[option_index].name)) {
                    options.string     = true;
                    options.string_arg = optarg;
                    break;
                }

                if (!strcmp("output", getopt_options[option_index].name)) {
                    options.output     = true;
                    options.output_arg = optarg;
                    break;
                }

                break;

            case ('h'):
                puts(help_msg);
                return 0;

            case ('v'):
                puts(vernum);
                return 0;

            case ('s'):
                options.string     = true;
                options.string_arg = optarg;
                break;

            case ('o'):
                options.output     = true;
                options.output_arg = optarg;
                break;

            default:
                return 1;
        }
    }

    if (optind > argc) {
        puts(help_msg);
        return 1;
    }

    options.files = argv + optind;

    FILE** input_files = calloc(argc - optind + 1, sizeof(FILE*));

    for (size_t i=0 ; options.files[i] != NULL ; i++) {
        if ((input_files[i] = fopen(options.files[i], "r")) == NULL) {
            printf("%s\n", strerror(errno));
            return 1;
        }
    }

    size_t limit = 0;
    for (size_t i=0 ; input_files[i] != NULL ; i++) {
        size_t size = fsize(input_files[i]);
        limit = limit > size ? limit : size;
    }

    char inbuf[BUFSIZE];
    char outbuf[BUFSIZE];

    FILE* outfile = stdout;
    if (options.output)
        outfile = fopen(options.output_arg,  "w");

    size_t written = 0;
    while (written < limit) {
        if (options.string) {
            size_t string_length = strlen(options.string_arg);

            for (size_t i=0 ; i<BUFSIZE ; i++)
                outbuf[i] = options.string_arg[i % string_length];
        }
        else {
            memset(outbuf, 0, BUFSIZE);
        }

        for (size_t i=0 ; input_files[i] != NULL ; i++) {
            size_t read = fread(inbuf, sizeof(char), BUFSIZE, input_files[i]);

            for (size_t j=0 ; j < read ; j++)
                outbuf[j] ^= inbuf[j];
        }

        written += fwrite(outbuf,
                          sizeof(char),
                          BUFSIZE < limit-written ? BUFSIZE : limit-written,
                          outfile);
    }

    free(input_files);
    return 0;
}
