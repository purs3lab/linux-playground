#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>

#define PAGE_SIZE 4096
#define NUM_PAGES 10

/*
This functions touches all the memory pages in the given buffer.
*/
void access_memory(char *ptr, size_t size) {
    for (size_t i = 0; i < size; i += PAGE_SIZE) {
        ptr[i] = 'A';   // Touching grass
        usleep(100000); // Contemplating life
    }
}

void log_msg(const char *message) {
    time_t now;
    time(&now);
    char buf[20];
    strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S", localtime(&now));
    printf("[%s] %s\n", buf, message);
}

int main() {
    printf("PID: %d\n", getpid());
    log_msg("Touching grass...");
    
    log_msg("Enable Tracing and press enter...");
    getchar();

    // Check the heap region allocations using malloc for 10 pages. 
    log_msg("Testing malloc...");
    char *buf1 = malloc(PAGE_SIZE * NUM_PAGES);
    log_msg("We just mallocced. We will start accessing now. Press enter...");
    getchar();
    
    access_memory(buf1, PAGE_SIZE * NUM_PAGES);

    log_msg("Finished Accessing. Trying to mmap. Press enter...");
    getchar();
    
    // Check the mmap region allocations using mmap for 10 pages.
    log_msg("Testing mmap...");
    char *buf2 = mmap(NULL, PAGE_SIZE * NUM_PAGES,
                     PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS,
                     -1, 0);
    if (buf2 == MAP_FAILED) {
        perror("mmap failed");
        free(buf1);
        return 1;
    }

    log_msg("Finished mmap. Will start accessing now. Press enter...");
    getchar();
    
    access_memory(buf2, PAGE_SIZE * NUM_PAGES);

    log_msg("Will free malloced memory. Press enter...");
    getchar();

    // We are disciplined cavemen so we free the memory we allocated. 
    free(buf1);
    log_msg("Will release mmaped memory. Press enter...");
    getchar();
    munmap(buf2, PAGE_SIZE * NUM_PAGES);
    log_msg("Finished. Press enter...");
    getchar();
    return 0;
}
