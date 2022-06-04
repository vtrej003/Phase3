        /* cs152-miniL phase2 */
%{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string.h>
#include <string>
#include <vector>
#include <sstream>
#include <fstream>
#include <map>
#include <stack>
using namespace std;





int yylex(void);
void yyerror(const char *msg);
extern int currLine;
extern int currPos;
extern const char* yytext;
extern FILE * yyin;

int countfortemp = 0;
int countforlabels = 0;
int countforparam = 0;
bool maincheck = 0;

ostringstream out;

enum symbols{INT,ARR,FUNC};

struct Symbol
{
        string name;
        int size,val;
        symbols sym;

        Symbol(): val(0), size(0), name(), sym(){};
};

struct Function
{
        string name;
        vector<Symbol> declarations;
};

vector <Function> symbol_table;

Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool findsym(string &value){
        Function *find = get_function();
        for(int i=0; i < find->declarations.size(); i++) {
        Symbol *s = &find->declarations[i];
                if (s->name == value) {
      return true;
    }
  }
  string message = "Symbol " + value + " not found";
  yyerror(message.c_str());
  return false;
}
bool findfunc(string &value){
       
        for(int i=0; i < symbol_table.size(); i++) {
        Function *s = &symbol_table[i];
                if (s->name == value) {
      return true;
    }
  }
  string message = "Function " + value + " not found";
  yyerror(message.c_str());
  return false;
}

void add_function_to_symbol_table(string &value) {
  if(!findfunc(value)){
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
  }
  else{
          string message = "Function is already declared: " + value;
          yyerror(message.c_str());
  }
}

void add_variable_to_symbol_table(string &symbolname, int value, int sizes, symbols t) {
  if (!findsym(symbolname)){
  Symbol s;
  s.name = symbolname;
  s.val = value;
  s.size = sizes;
  s.sym = t;
  Function *f = get_function();
  f->declarations.push_back(s);
  }
  else{
          string message = "Symbol is already declared: " + symbolname;
          yyerror(message.c_str());
  }
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

string temps(){
        stringstream temp;
        temp << countfortemp++;
        string output = "temp_" + temp.str();
        return output;
}

string labels(){
        stringstream temp;
        temp << countforlabels++;
        string output = "label_" + temp.str();
        return output;
}

stack<string> params;
stack<string> idents;
stack<string> label;
stack<string> functions;
stack<string> vals;





%}

%union{
int num_val;
char* ident_val;

struct types{
        char name[256];
        char ind[256];
        int types;
        int vals;
        int sizes;
} attribute;
}

%error-verbose
%locations
%start program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN OR AND NOT LT LTE GT GTE EQ NEQ ADD SUB MULT DIV MOD



%token <ident_val> IDENT
%token <num_val> NUMBER


%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD




%type <attribute> statement bool_exp relation_exp relation_and_exp expression multiplicative_exp term var 
%type <ident_val> comp


%%
program: functions {if(!maincheck){yyerror("main does not exist");}}
        ;


functions: /*empty*/ {printf("functions -> epsilon\n");}
	      | function functions {printf("functions -> function functions\n");} 
        ;

function: FUNCTION IDENT {
                string val = $2;
                string function = "func " + val; 
                add_function_to_symbol_table(function);
                
               
        }
        SEMICOLON BEGIN_PARAMS declarations {
                while(!params.empty()){
                        string para = params.top();
                        out << "= " << para << ", " << countforparam++ << endl;
                        params.pop();
                }
        }
        END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statement END_BODY
        {
                out << "endfunc" << endl;
                while(!params.empty()){
                        params.pop();
                }
        }
        ;

declarations: /*empty*/ {printf("declarations -> epsilon\n");}
        | declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
        ;

declaration: identifiers COLON INTEGER {
                while(!idents.empty()){
                        string temp = idents.top();
                        add_variable_to_symbol_table(temp,0,0,INT);
                        idents.pop();
                }
        }
        | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {
                while(!idents.empty()){
                        string temp = idents.top();
                        
                        add_variable_to_symbol_table(temp,0,$5,ARR);
                        idents.pop();
                        }
        }
        | identifiers COLON ENUM L_PAREN{
                while (!idents.empty()){
                        string temp = idents.top();
                        add_variable_to_symbol_table(temp,0,0,ARR);
                        idents.pop();
                }
        } 
        identifiers R_PAREN {
                while (!idents.empty()){
                        string temp = idents.top();
                        add_variable_to_symbol_table(temp,0,0,ARR);
                        idents.pop();
                }
        }
        ;

identifiers: IDENT {
             
                idents.push($1);
                params.push($1);
        }
        | IDENT COMMA identifiers {
              
                idents.push($1);
                params.push($1);}
        ;

        
statement: var ASSIGN expression {
               if ($1.types == INT){
                       cout << "a";
               }
        }
        | IF bool_exp THEN {
                string begin = labels();
                string end = labels();
                label.push(begin);
                string output = $2.name;
        }
        
        statement ENDIF statement SEMICOLON statement ELSE statement ENDIF{
                string begin = labels();
                string end = labels();
                label.push(begin);
             

        }
        
        | WHILE bool_exp BEGINLOOP statement ENDLOOP {printf("statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP\n");}
        | DO BEGINLOOP statement ENDLOOP WHILE bool_exp {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp\n");}
        | READ var {printf("statement -> READ vars\n");}
        | WRITE var {printf("statement -> WRITE vars\n");}
        | CONTINUE {printf("statement -> CONTINUE\n");}
        | RETURN expression {printf("statement -> RETURN expression\n");}
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
        | IDENT L_PAREN preloop R_PAREN {printf("term -> ident L_PAREN preloop R_PAREN\n");}
        ;

preloop: /*empty*/ {printf("preloop -> epsilon\n");}
        | expression COMMA preloop {printf("preloop -> expression COMMA preloop\n");}
        | expression {printf("preloop -> expression\n");}
        ;

var: IDENT {printf("var -> ident \n");}
        | IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
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
