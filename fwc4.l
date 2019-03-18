%{
#include <stdio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <errno.h>
#include <queue>
#include <stack>


enum { LN, WD, CH, SIZE };

struct fmem {
   void*           p;
   size_t          len;
   size_t          st_size;
   YY_BUFFER_STATE bst;
   fmem() : p(0), len(0), st_size(0), bst(0) {}
};

static int cf[SIZE]; // current file counts
static int ct[SIZE]; // total counts
static std::queue<const char*> fnames; 
static std::stack< fmem > fmem_stack;

void clear_counters()
{
   cf[LN] = cf[WD] = cf[CH] = 0;
}

void print_clear_counters(const char* fname, int c[])
{
   printf("%8d %8d %8d %s\n", c[LN], c[WD], c[CH], fname);
   clear_counters();
}

void update_total()
{
   ct[LN] += cf[LN]; 
   ct[WD] += cf[WD]; 
   ct[CH] += cf[CH];
}

fmem OpenNextFile(FILE* f);

bool HaveMoreFiles() 
{
   while (!fnames.empty())
   {
      if (FILE* f = fopen(fnames.front(), "r"))
      {
         fmem fm = OpenNextFile(f);
         if (fm.p != (void*)-1) 
         {
            fm.bst = yy_scan_bytes((char*)fm.p, fm.st_size);
            fmem_stack.push(fm);
         }
         fclose(f);
         return true;
      }
  
      printf("fwc2: %s: %s: open:\n", fnames.front(), strerror(errno));
      fnames.pop();
   }
   return false;
}

%}

%%
[^ \t\n\r\f\v]+   { cf[WD]++; cf[CH] += yyleng; }
\n                { cf[LN]++; cf[CH]++; }
.                 { cf[CH]++; }
%%


int main (int argc, char* argv[])
{
   // load file names
   for (int i = 1; i < argc; i++) 
      fnames.push(argv[i]);

   // will print total if at least 2 input files were specified
   bool bPrintTotal = fnames.size() >= 2; 

   if (argc < 2 || HaveMoreFiles())
   {
      yylex();
   }

   if (bPrintTotal)
      print_clear_counters("total", ct);
}

int yywrap (void)
{
   update_total();

   if (yyin == stdin)
   {
      print_clear_counters("", cf);
   }
   else 
   {
      if (!fmem_stack.empty())
      {
         fmem fm = fmem_stack.top();
         munmap(fm.p, fm.len);
         yy_delete_buffer(fm.bst);
         fmem_stack.pop();
      }

      print_clear_counters(fnames.front(), cf);
      fnames.pop();
   }

   return HaveMoreFiles() ? 0 : 1; 
}

fmem OpenNextFile(FILE* f)
{
   int fd = fileno(f);
   struct stat st;
   fstat(fd, &st);
   off_t fsize = st.st_size;
   int   psize = getpagesize();
   fmem fm;
   fm.st_size = st.st_size;
   fm.len = (fsize/psize)*psize + psize; 
   fm.p = mmap(NULL, fsize, PROT_READ, MAP_FILE | MAP_PRIVATE, fd, 0);
   //printf("st_size=%lld psize=%d len=%lu\n", st.st_size, psize, fm.len);
   return fm;
}
