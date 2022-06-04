%{
      #include "miniL-parser.hpp"
      int currLine = 1, currPos = 1;
%}

DIGIT           [0-9]

COMMENT         ##.*
IDENTIFIER      [a-zA-Z]([_]*[0-9a-zA-Z]|[0-9][_]*[a-zA-Z])*

INVAILDIDENTIFIER_STARTING [0-9|_][0-9A-Za-z]+
INVAILDIDENTIFIER_ENDING [a-zA-Z][a-zA-Z0-9]*[_]

%%
 
"function"      {return FUNCTION; currPos += yyleng;}
"beginparams"   {return BEGIN_PARAMS; currPos += yyleng;}
"endparams"     {return END_PARAMS; currPos += yyleng;}
"beginlocals"   {return BEGIN_LOCALS; currPos += yyleng;}
"endlocals"     {return END_LOCALS; currPos += yyleng;}
"beginbody"     {return BEGIN_BODY; currPos += yyleng;}
"endbody"       {return END_BODY; currPos += yyleng;}
"integer"       {return INTEGER; currPos += yyleng;}
"array"         {return ARRAY; currPos += yyleng;}
"enum"          {return ENUM; currPos += yyleng;}
"of"            {return OF; currPos += yyleng;}
"if"            {return IF; currPos += yyleng;}
"then"          {return THEN; currPos += yyleng;}
"endif"         {return ENDIF; currPos += yyleng;}
"else"          {return ELSE; currPos += yyleng;}
"while"         {return WHILE; currPos += yyleng;}
"do"            {return DO; currPos += yyleng;}
"beginloop"     {return BEGINLOOP; currPos += yyleng;}
"endloop"       {return ENDLOOP; currPos += yyleng;}
"continue"      {return CONTINUE; currPos += yyleng;}
"read"          {return READ; currPos += yyleng;}
"write"         {return WRITE; currPos += yyleng;}
"and"           {return AND; currPos += yyleng;}
"or"            {return OR; currPos += yyleng;}
"not"           {return NOT; currPos += yyleng;}
"true"          {return TRUE; currPos += yyleng;}
"false"         {return FALSE; currPos += yyleng;}
"return"        {return RETURN; currPos += yyleng;}

"-"     {return SUB; currPos += yyleng;}
"+"     {return ADD; currPos += yyleng;}
"*"     {return MULT; currPos += yyleng;}
"/"     {return DIV; currPos += yyleng;}
"%"     {return MOD; currPos += yyleng;}

"=="    {return EQ; currPos += yyleng;}
"<>"    {return NEQ; currPos += yyleng;}
"<"     {return LT; currPos += yyleng;}
">"     {return GT; currPos += yyleng;}
"<="    {return LTE; currPos += yyleng;}
">="    {return GTE; currPos += yyleng;}

";"     {return SEMICOLON; currPos += yyleng;}
":"     {return COLON; currPos += yyleng;}
","     {return COMMA; currPos += yyleng;}
")"     {return R_PAREN; currPos += yyleng;}
"("     {return L_PAREN; currPos += yyleng;}
"["     {return L_SQUARE_BRACKET; currPos += yyleng;}
"]"     {return R_SQUARE_BRACKET; currPos += yyleng;}
":="    {return ASSIGN; currPos += yyleng;}

{DIGIT}+        {yylval.num_val = atoi(yytext); currPos += yyleng;return NUMBER;}

[ \t]+          {/* ignore spaces */ currPos += yyleng;}
"\n"            {currLine++; currPos = 1;}

{IDENTIFIER}    {yylval.ident_val = strdup(yytext); currPos += yyleng;return IDENT;}
{COMMENT}       {currPos += yyleng;}
{INVAILDIDENTIFIER_STARTING}    {printf("Error at line %d, column %d: identifier \"%s\"\n must begin with a letter ", currLine, currPos, yytext); exit(1);}
{INVAILDIDENTIFIER_ENDING}      {printf("Error at line %d, column %d: identifier \"%s\"\n cannot end with an underscore", currLine, currPos, yytext); exit(1);}

.              {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(1);}

%%
