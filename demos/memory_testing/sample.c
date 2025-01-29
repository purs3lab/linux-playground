#include <stdio.h>
int main(int argc, char **argv) {
  char *p;
  printf("Trying to malloc 2 pages..press enter..\n");
  getchar();
  p = malloc(2*4096);
  printf("Got address: %p, Trying to access first page..press enter..\n", p);
  getchar();
  p[0] = 'a';
  printf("Trying to access first page again..press enter..\n");
  getchar();
  p[128] = 'a';
  printf("Trying to access second page (address: %p)..press enter..\n", p + 5000);
  getchar();
  p[5000] = 'a';
  printf("Trying to access invalid memory..press enter..\n");
  getchar();
  p = (char*)0xdeadbeef;
  p[0] = 'a';
  return 0;
}
