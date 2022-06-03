        /* cs152-miniL phase2 */
%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <sstream>
#include "lib.h"
int yylex(void);
void yyerror(const char *msg);
extern int currLine;
extern int currPos;
extern const char* yytext;
extern FILE * yyin;

std::stringstream output;
SymbolTable st;
Terminals t;
%}

%union{
int num_val;
char* ident_val;
}

%define parse.error verbose
%locations
%start program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN OR AND NOT LT LTE GT GTE EQ NEQ ADD SUB MULT DIV MOD
%token <ident_val> IDENT 
%token <num_val> NUMBER

%type <ident_val> declaration identifiers statement var expression multiplicative_exp term ident bool_expression comp

%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD

%%
program: /*empty*/  %empty {/* printf("program -> epsilon\n"); */} 
        | functions { /* printf( "prog_start -> functions \n" ); */}
        ;
      

functions: /*empty*/  %empty { /* printf( "functions -> epsilon\n"); */ }
	      | function functions { /* printf( /*"functions -> function functions\n"); */} 
        ;

function: FUNCTION IDENT
	{
	    std::string func_name = $2;
            st.add_function_to_symbol_table(func_name); 
            output << "func \n\n\n\n\n\n\n" << func_name << std::endl;
	}
	    
	SEMICOLON BEGIN_PARAMS declarations
	{
	    t.paramCount = 0;
            while(!t.params.empty())
	    {
		output << "= " << t.params.front() << ", " << "$" << t.paramCount++ << std::endl;
		t.params.pop();
	    }	
	} 

	END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
        { /* printf("function -> FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n"); */
	    output << "endfunc" << std::endl;

	}
        ;

declarations: /*empty*/  %empty { /* printf("declarations -> epsilon\n"); */}
        | declaration SEMICOLON declarations 
	    { /* printf("declarations -> declaration SEMICOLON declarations\n"); */}
        ;

declaration: identifiers COLON INTEGER 
	    { /* printf("declaration -> identifiers COLON INTEGER\n"); */ 
		std::string sym = $1;
		Type I = Integer;
		Type A = Array;
		if(st.find(sym, I) || st.find(sym, A))
		{
		    std::string error = "Symbol is already declared: " + sym;
		    yyerror(error.c_str());
		} 
		st.add_variable_to_symbol_table(sym, I, 0, 1);
		
	    }
        | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
	    { /* printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n"); */
		std::string sym = $1;
		Type A = Array;
		Type I = Integer;
		int size = $5;
		if(st.find(sym, A ) || st.find(sym, I))
		{
		    std::string error = "symbol is already declared: " + sym;
		    yyerror(error.c_str());
		} 
		st.add_variable_to_symbol_table(sym, A, 0, size);
		
	    }
        | identifiers COLON ENUM L_PAREN identifiers R_PAREN 
	    { /* printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n"); */
	    }
        | %empty
        ;

identifiers: ident 
	    { /* printf("identifiers -> ident\n"); */ 
		t.params.push($1);
	    }
        | ident COMMA identifiers 
	    { /* printf("identifiers -> ident COMMA identifiers\n"); */ 
                t.params.push($1);
	    }
        ;

ident: IDENT { /* printf("ident -> IDENT %s\n",yytext); */}
        ;
        
statement: var ASSIGN expression { /* printf("statement -> var ASSIGN expression\n"); */ }
        | IF bool_exp THEN statements ENDIF { /* printf("statement -> IF bool_exp THEN statements ENDIF\n"); */}
        | IF bool_exp THEN statements ELSE statements ENDIF { /* printf("statement -> IF bool_exp THEN statements ELSE statements ENDIF\n"); */ }
        | WHILE bool_exp BEGINLOOP statements ENDLOOP {/* printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP\n"); */ }
        | DO BEGINLOOP statements ENDLOOP WHILE bool_exp {/* printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n"); */ }
        | READ vars {/* printf("statement -> READ vars\n"); */}
        | WRITE vars {/* printf("statement -> WRITE vars\n"); */}
        | CONTINUE {/* printf("statement -> CONTINUE\n"); */}
        | RETURN expression {/* printf("statement -> RETURN expression\n"); */}
        ;

statements: /*empty*/  %empty {printf("statements -> epsilon\n");}
        | statement SEMICOLON statements{printf("statements -> statement SEMICOLON statements\n");}
        ;

vars: var {printf("vars -> var\n");}
        | var COMMA vars {printf("vars -> var COMMA vars\n");}
        ;
bool_exp: relation_and_exp {printf("bool_exp -> relation_and_exp\n");}
        | bool_exp OR relation_and_exp {printf("bool_exp -> bool_exp OR relation_and_exp\n");}
        ;

relation_and_exp: relation_exp {printf("relation_and_exp -> relation_exp\n");}
        | relation_and_exp AND relation_exp {printf("relation_and_exp -> relation_exp AND relation_exp\n");}
        ;

relation_exp: NOT exp1 {printf("relation_exp -> NOT relation_exp\n");}
        | exp1 {printf("relation_and_exp -> relation_exp\n");}
        ;

exp1: expression comp expression {printf("relation_exp -> expression comp expression\n");}
        | TRUE {printf("relation_exp -> TRUE\n");}
        | FALSE {printf("relation_exp -> FALSE\n");}
        | L_PAREN bool_exp R_PAREN {printf("relation_exp -> L_PAREN bool_exp R_PAREN\n");}
        ;

comp: EQ {printf("comp -> EQ\n");}
        | NEQ {printf("comp -> NEQ\n");}
        | LT {printf("comp -> LT\n");}
        | GT {printf("comp -> GT\n");}
        | LTE {printf("comp -> LTE\n");}
        | GTE {printf("comp -> GTE\n");}
        ;

expression: multiplicative_exp {printf("expression -> multiplicative_expression\n");}
        |  expression SUB multiplicative_exp {printf("expression -> multiplicative_expression SUB multiplicative_exp\n");}
        |  expression ADD multiplicative_exp {printf("expression -> multiplicative_expression ADD multiplicative_exp\n");}
        ;

multiplicative_exp: term {printf("multiplicative_expression -> term\n");}
        | multiplicative_exp MOD term {printf("multiplicative_expression -> multiplicative_expression MOD term\n");}
        | multiplicative_exp DIV term {printf("multiplicative_expression -> multiplicative_expression DIV term\n");}
        | multiplicative_exp MULT term {printf("multiplicative_expression -> multiplicative_expression MULT term\n");}
        ;

term: var {printf("term -> var\n");}
        | SUB var {printf("term -> SUB var\n");}
        | NUMBER {printf("term -> NUMBER\n");}
        | SUB NUMBER {printf("term -> SUB NUMBER\n");}
        | L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
        | SUB L_PAREN expression R_PAREN {printf("term -> SUB L_PAREN expression R_PAREN\n");}
        | ident L_PAREN preloop R_PAREN {printf("term -> ident L_PAREN preloop R_PAREN\n");}
        ;

preloop: /*empty*/  %empty {printf("preloop -> epsilon\n");}
        | expression COMMA  {printf("preloop -> expression COMMA preloop\n");}
        | expression {printf("preloop -> expression\n");}
        ;

var: ident {printf("var -> ident \n");}
        | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
        ;

%%
int main(int argc, char ** argv){
        if(argc > 1){
                yyin = fopen(argv[1], "r");
                if (yyin == NULL){
                        printf("syntax: %s filename", argv[0]);
                }
        }
        yyparse();
        return 0;
}
void yyerror(const char *msg){
        printf("Error: Line %d, position %d: %s \n", currLine, currPos, msg);
}
