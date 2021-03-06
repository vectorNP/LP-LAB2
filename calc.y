%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

typedef struct variabel{
	char n[10];
	float value;
}variabel;

variabel var[100];
static int count=0;

// float symbols[52];
float symbolVal(char symbol[10]);
void updateSymbolVal(char symbol[10], float val);
void newVar(char symbol[10],float value);
int notval(int a);
int orval(int a,int b);
int andval(int a , int b);
int lt(int a , int b);
int gt(int a , int b);
int et(int a , int b);
int gte(int a , int b);
int lte(int a , int b);
%}

%union {float num; char id[10];}         /* Yacc definitions */
%start line
%token print
%token exit_command
%token comment
%token fi
%token fie
%token aa
%token oo
%token lesst
%token grett
%token lesste
%token grette
%token eqeq
%token <num> number
%token <id> identifier
%type <num> line exp term exptwo expthree brac 
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



exp 	: exp '+' exptwo        	{$$ = $1 + $3;}
       	| exp '-' exptwo        	{$$ = $1 - $3;}
		| exp aa exptwo				{$$ = andval($1,$3);}
		| exp oo exptwo				{$$ = orval($1,$3);}
		| exp lesst exptwo        	{$$ = lt($1,$3);}     
       	| exp grett exptwo        	{$$ = gt($1,$3);}     
		| exp lesste exptwo			{$$ = lte($1,$3);}     
		| exp grette exptwo			{$$ = gte($1,$3);}      
		| exp eqeq exptwo			{$$ = et($1,$3);}  	
		| '!' exptwo				{$$ = notval($2);}
		| exptwo					{$$ = $1;}
		;

exptwo	: exptwo '*' expthree   {$$ = $1 * $3;}
		| expthree				{$$ = $1;}
		;

expthree : expthree '/' brac	{$$ = $1 / $3;}
		 | brac					{$$ = $1;}
		 ;

brac	 : '(' exp ')'			{$$ = $2;}
		 | term					{$$ = $1;}
		 ;



term   	: number                {$$ = $1;}
		| identifier			{$$ = symbolVal($1);} 
        ;





%%                     /* C code */


// + and - are left associative

// exp    	: term                  {$$ = $1;}
//        	| exp '+' term          {$$ = $1 + $3;}
//        	| exp '-' term          {$$ = $1 - $3;}
// 		| '!' term				{$$ = notval($2);}
// 		| exp aa term			{$$ = andval($1,$3);}
// 		| exp oo term			{$$ = orval($1,$3);}
//        	;



// relexp 	: relexp '<' exp        	{$$ = lt($1,$3);}     
//        	| relexp '>' exp        	{$$ = gt($1,$3);}     
// 		| relexp lesste exp			{$$ = et($1,$3);}     
// 		| relexp grette exp			{$$ = gte($1,$3);}      
// 		| relexp eqeq exp			{$$ = lte($1,$3);}      
// 		| exp						{$$ = $1;}	
// 		;








int computeSymbolIndex(char token[10])
{

	int i=0;
	int index=-1;
	for(i =0;i<100;i++){
		if(strcmp(token,var[i].n)==0){
			index=i;
			break;
		}
	}
	return index;

} 

// creates a new variabel 
void newVar(char symbol[10],float value){
	
	count++;
	strcpy(var[count].n,symbol);
	var[count].value =value;

}


/* returns the value of a given symbol */
float symbolVal(char symbol[10])
{
	int bucket = computeSymbolIndex(symbol);
	return var[bucket].value;
}

/* updates the value of a given symbol */
void updateSymbolVal(char symbol[10], float val)
{
	int bucket = computeSymbolIndex(symbol);
	if(bucket ==-1){
		//the variable does not exists so create new one
		newVar(symbol,val);
	}else{
		var[bucket].value = val;
	}
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


int lt(int a , int b){
	if(a < b){
		return 1;
	}else{
		return 0;
	}
}

int gt(int a , int b){
	if(a > b){
		return 1;
	}else{
		return 0;
	}
}

int et(int a , int b){
	if(a == b){
		return 1;
	}else{
		return 0;
	}
}

int lte(int a , int b){
	if(a <= b){
		return 1;
	}else{
		return 0;
	}
}

int gte(int a , int b){
	if(a >= b){
		return 1;
	}else{
		return 0;
	}
}





int main (void) {
	/* init symbol table */
	int i;
	for(i=0; i<100; i++) {
		var[i].value = 0;
		int k=0;
		for (int k=0;k<10;k++){
			var[i].n[k]='\0';
		}
	}

	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 

