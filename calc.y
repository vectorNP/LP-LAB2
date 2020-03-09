%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <ctype.h>
float symbols[52];
float symbolVal(char symbol);
void updateSymbolVal(char symbol, float val);
int notval(int a);
int andval(int a , int b);
%}

%union {float num; char id;}         /* Yacc definitions */
%start line
%token print
%token exit_command
%token comment
%token aa
%token oo
%token <num> number
%token <id> identifier
%type <num> line exp term 
%type <id> assignment

%%

/* descriptions of expected inputs     corresponding actions (in C) */

line    : assignment ';'		{;}
		| exit_command ';'		{exit(EXIT_SUCCESS);}
		| print exp ';'			{printf("Printing %.2f\n", $2);}
		| line assignment ';'	{;}
		| line print exp ';'	{printf("Printing %.2f\n", $3);}
		| line exit_command ';'	{exit(EXIT_SUCCESS);}
		| comment				{;}
		| line comment			{;}
        ;

assignment : identifier '=' exp  { updateSymbolVal($1,$3); }
			;
exp    	: term                  {$$ = $1;}
       	| exp '+' term          {$$ = $1 + $3;}
       	| exp '-' term          {$$ = $1 - $3;}
		| '!' term				{$$ = notval($2);}
		| exp aa term			{$$ = andval($1,$3);}
		| exp oo term			{$$ = orval($1,$3);}
       	;
term   	: number                {$$ = $1;}
		| identifier			{$$ = symbolVal($1);} 
        ;





%%                     /* C code */

int computeSymbolIndex(char token)
{
	int idx = -1;
	if(islower(token)) {
		idx = token - 'a' + 26;
	} else if(isupper(token)) {
		idx = token - 'A';
	}
	return idx;
} 

/* returns the value of a given symbol */
float symbolVal(char symbol)
{
	int bucket = computeSymbolIndex(symbol);
	return symbols[bucket];
}

/* updates the value of a given symbol */
void updateSymbolVal(char symbol, float val)
{
	int bucket = computeSymbolIndex(symbol);
	symbols[bucket] = val;
}

int notval(int a){
	if(a>0){
		return 0;
	}else{
		return 1;
	}
}

int andval(int a , int b){
	if(a>0 && b>0){
		return 1;
	}else{
		return 0;
	}
}

int orval(int a , int b){
	if(a==0 && b==0){
		return 0;
	}else{
		return 1;
	}
}



int main (void) {
	/* init symbol table */
	int i;
	for(i=0; i<52; i++) {
		symbols[i] = 0;
	}

	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 

