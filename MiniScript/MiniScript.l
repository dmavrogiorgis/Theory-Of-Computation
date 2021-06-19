%{
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "cgen.h"
#include  "MiniScript.tab.h"

int lineNum = 1;

/********************************/
char* change_single_to_double_quotes(char* strs);
char* trim_Zeros_from_mums(char* strs);

%}

DIGIT       [0-9]
LU_CASE     [a-zA-Z]
UNDERSCORE  [\_]
IDENTIFIER {LU_CASE}({LU_CASE}|{DIGIT}|{UNDERSCORE})*

INT_NUM    {DIGIT}+
DEC_NUM    ("."{INT_NUM})|({INT_NUM}("."{INT_NUM}?)?)
REAL_NUM   {DEC_NUM}([eE][+-]?{INT_NUM})?

SPECIAL_CHARS   ("-"|"+"|"*"|"/"|":"|"_"|"$"|"!"|"#"|"@"|"&"|"~"|"^"|"("|")")
STRING_DIGIT    ({LU_CASE}|{DIGIT}|" "|{SPECIAL_CHARS})
ESC_CHAR        ("\\n"|"\\t"|"\\r"|"\\\\"|"\\\""|"\\\'")

SINGLE_QUOTE_STR    ("\'")({STRING_DIGIT}*{ESC_CHAR}*{STRING_DIGIT}*)*("\'")
DOUBLE_QUOTE_STR    ("\"")({STRING_DIGIT}*{ESC_CHAR}*{STRING_DIGIT}*)*("\"")

CONST_STRING    {SINGLE_QUOTE_STR}|{DOUBLE_QUOTE_STR}

%x comment 
%%
number      {printf("Token KW_NUMBER: %s\n",yytext);
             return KW_NUMBER;}
boolean     {printf("Token KW_BOOLEAN: %s\n",yytext);
             return KW_BOOLEAN;}
string      {printf("Token KW_STRING: %s\n",yytext);
             return KW_STRING;}
void        {printf("Token KW_VOID: %s\n",yytext);
             return KW_VOID;}
true        {printf("Token KW_TRUE: %s\n",yytext);
             return KW_TRUE;}
false       {printf("Token KW_FALSE: %s\n",yytext);
             return KW_FALSE;}
var         {printf("Token KW_VAR: %s\n",yytext);
             return KW_VAR;}
const       {printf("Token KW_CONST: %s\n",yytext);
             return KW_CONST;}
if          {printf("Token KW_IF: %s\n",yytext);
             return KW_IF;}
else        {printf("Token KW_ELSE: %s\n",yytext);
             return KW_ELSE;}
for         {printf("Token KW_FOR: %s\n",yytext);
             return KW_FOR;}
while       {printf("Token KW_WHILE: %s\n",yytext);
             return KW_WHILE;}
function    {printf("Token KW_FUNCTION: %s\n",yytext);
             return KW_FUNCTION;}
break       {printf("Token KW_BREAK: %s\n",yytext);
             return KW_BREAK;}
continue    {printf("Token KW_CONTINUE: %s\n",yytext);
             return KW_CONTINUE;}
not         {printf("Token KW_NOT: %s\n",yytext);
             return KW_NOT;}
and         {printf("Token KW_AND: %s\n",yytext);
             return KW_AND;}
or          {printf("Token KW_OR: %s\n",yytext);
             return KW_OR;}
return      {printf("Token KW_RETURN: %s\n",yytext);
             return KW_RETURN;}
null        {printf("Token KW_NULL: %s\n",yytext);
             return KW_NULL;}
start       {printf("Token KW_START: %s\n",yytext);
             return KW_START;}               


"+"     {printf("Token PLUS_OP: %s\n",yytext);
         return PLUS_OP;}
"-"     {printf("Token MINUS_OP: %s\n",yytext);
         return MINUS_OP;}
"*"     {printf("Token MULT_OP: %s\n",yytext);
         return MULT_OP;}
"/"     {printf("Token DIV_OP: %s\n",yytext);
         return DIV_OP;}
"%"     {printf("Token MOD_OP: %s\n",yytext);
         return MOD_OP;}
"**"    {printf("Token POWER_OP: %s\n",yytext);
         return POWER_OP;}

"=="    {printf("Token EQUAL_OP: %s\n",yytext);
         return EQUAL_OP;}
"!="    {printf("Token NOT_EQUAL_OP: %s\n",yytext);
         return NOT_EQUAL_OP;}
"<"     {printf("Token LESS_OP: %s\n",yytext);
         return LESS_OP;}
"<="    {printf("Token LESS_EQUAL_OP: %s\n",yytext);
         return LESS_EQUAL_OP;}

"="     {printf("Token ASSIGN_OP: %s\n",yytext);
         return ASSIGN_OP;}

";"     {printf("Token SEMICOLON: %s\n",yytext);
         return SEMICOLON;}
"("     {printf("Token LEFT_PARENTHESIS: %s\n",yytext);
         return LEFT_PARENTHESIS;}
")"     {printf("Token RIGHT_PARENTHESIS: %s\n",yytext);
         return RIGHT_PARENTHESIS;}
","     {printf("Token COMMA: %s\n",yytext);
         return COMMA;}
"["     {printf("Token LEFT_SQUARE_BRACKET: %s\n",yytext);
         return LEFT_SQUARE_BRACKET;}
"]"     {printf("Token RIGHT_SQUARE_BRACKET: %s\n",yytext);
         return RIGHT_SQUARE_BRACKET;}
"{"     {printf("Token LEFT_CURLY_BRACKET: %s\n",yytext);
         return LEFT_CURLY_BRACKET;}
"}"     {printf("Token RIGHT_CURLY_BRACKET: %s\n",yytext);
         return RIGHT_CURLY_BRACKET;}
":"     {printf("Token COLON: %s\n",yytext);
         return COLON;}

readString    {printf("Token READ_STR: %s\n", yytext);
               return READ_STR;}
readNumber    {printf("Token READ_NUM: %s\n", yytext);
               return READ_NUM;}
writeString   {printf("Token WRITE_STR: %s\n", yytext);
               return WRITE_STR;}
writeNumber  {printf("Token WRITE_NUM: %s\n", yytext);
               return WRITE_NUM;}

{IDENTIFIER}    {printf("Token IDENTIFIER: %s\n",yytext);
                 yylval.str = strdup(yytext);
                 return IDENTIFIER;}
{INT_NUM}       {printf("Token INT_NUM: %s\n", yytext);
                 yylval.str = strdup(yytext);
                 return INT_NUM;}

{REAL_NUM}      {printf("Token REAL_NUM: %s\n", yytext);
                 yylval.str = strdup(yytext);
                 return REAL_NUM;}

{CONST_STRING}  {char* str = change_single_to_double_quotes(yytext);
                 printf("Token CONST_STRING: %s\n", str);
                 yylval.str = strdup(str);
                 return CONST_STRING;}

"//"[^\n]*  printf("Line comment: %s\n", yytext); /* eat line comments */

"/*"                    {BEGIN(comment);
                         printf("Comment started at line: %d\n", lineNum);}
<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by '/'s */
<comment>\n             ++lineNum;
<comment>"*"+"/"        {BEGIN(INITIAL);
                         printf("Comment ended at line: %d\n", lineNum);}

[ \r\t]+	/* skip whitespace */
\n 			++lineNum;
<<EOF>> 	return EOF;

.           {printf("Lexical Error in line %d: Unrecognized literal < %s >\n", lineNum, yytext);
             exit(-1);}

%%
char* change_single_to_double_quotes(char* strs){
    char *temp = strdup(strs);
    if(*temp){
        if( temp[0] == '"' && temp[yyleng-1] == '"'){
                return temp;    // Constant string is OK!
        }else{
            temp[0] = '"';      // Change the signle to double quotes!
            temp[yyleng-1] = '"';
        }
    }
    return temp;
}