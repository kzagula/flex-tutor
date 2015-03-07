%{
    /* 
     * This is user code section (text enclosed between '%{' and '%}'). 
     * This section gets included somewhere in the middle of the generated scanner file 
     */

     #include <stdint.h>
%}

    /*  
     * Flex definitions section  
     */

%top {
    /* 
     * This block will be put at the top of the generated scanner file 
     */
}

%option noyywrap 

%%
    /* Flex rules section goes here. If no rules listed, default rule is ECHO everything */ 
%%


    /* User code section goes here, included at the end of flex generated file */

int main ()
{
  return yylex();
}
