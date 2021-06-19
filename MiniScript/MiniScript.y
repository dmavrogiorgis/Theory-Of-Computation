%{
  #include <stdio.h>
  #include <math.h>
  #include "cgen.h"
  
  extern int yylex(void);
  extern int lineNum;
%}

%union{
  char* str;
}

// %define parse.trace
// %debug
%token <str> IDENTIFIER
%token <str> INT_NUM
%token <str> REAL_NUM
%token <str> CONST_STRING
/********************************/
%token KW_NUMBER
%token KW_BOOLEAN
%token KW_STRING 
%token KW_VOID 
%token KW_TRUE 
%token KW_FALSE 
%token KW_VAR 
%token KW_CONST 
%token KW_IF 
%token KW_ELSE 
%token KW_FOR 
%token KW_WHILE 
%token KW_FUNCTION
%token KW_BREAK 
%token KW_CONTINUE 
%token KW_RETURN 
%token KW_NULL 
%token KW_START 

%right KW_NOT 
%left KW_AND 
%left KW_OR 
/********************************/
%left PLUS_OP
%left MINUS_OP
%left MULT_OP
%left DIV_OP
%left MOD_OP
%right POWER_OP
/********************************/
%left EQUAL_OP
%left NOT_EQUAL_OP
%left LESS_OP
%left LESS_EQUAL_OP
/********************************/
%token ASSIGN_OP
/********************************/
%token SEMICOLON
%token COLON 
%token LEFT_PARENTHESIS
%token RIGHT_PARENTHESIS
%token COMMA 
%token LEFT_SQUARE_BRACKET 
%token RIGHT_SQUARE_BRACKET 
%token LEFT_CURLY_BRACKET 
%token RIGHT_CURLY_BRACKET
/********************************/
%token READ_STR
%token READ_NUM
%token WRITE_STR
%token WRITE_NUM
/********************************/
%type <str> data_type_values
%type <str> data_types

%type <str> general_expr
%type <str> not_expr
%type <str> sign_expr
%type <str> factor_expr
%type <str> plus_minus_expr
%type <str> relation_expr
%type <str> logic_expr
%type <str> expr
/**********************************/
%type <str> default_func
/**********************************/
%type <str> declarations
%type <str> var_list
%type <str> var_init
%type <str> const_list
%type <str> const_init
%type <str> dec_ids
/**********************************/
%type <str> main_func
%type <str> func_declaration
%type <str> func_input_list
%type <str> func_return_types
%type <str> func_ids
%type <str> func_input
/**********************************/
%type <str> general_statement
%type <str> complex_statements
%type <str> statement_list
%type <str> statement_declaration
%type <str> statement
%type <str> assign_statement
%type <str> if_statement 
%type <str> else_if
%type <str> optional_else       
%type <str> for_statement 
%type <str> while_statement     
%type <str> break_statement   
%type <str> continue_statement 
%type <str> return_statement    
%type <str> function_statement  
/**********************************/
%type <str> read_string_func
%type <str> read_number_func
%type <str> write_string_func
%type <str> write_number_func
/**********************************/
%type <str> global_list
%type <str> global_declaration
/**********************************/

%type <str> main_body

%start ms_program

%%
/*******************************MAIN BODY OF MINISCRITP******************************************/
ms_program:
  main_body
  {
    if (yyerror_count == 0) {
      printf("\nBISON OUTPUT\n");
      FILE *file = fopen("bisonOUT.c", "w");
      fputs("#include <stdio.h>\n", file);
      fputs("#include <math.h>\n", file);
      fputs(c_prologue, file);
      fprintf(file, "%s\n", $1); 
      /***********************************/
      puts("#include <stdio.h>");
      puts("#include <math.h>");
      puts(c_prologue);
      printf("%s\n", $1); 
    }  
  }
;

main_body: 
  main_func                {$$ = template("%s\n", $1);}
| global_list main_func    {$$ = template("%s\n%s\n", $1, $2);}
| main_func global_list    {$$ = template("%s\n%s\n", $1, $2);}
;

global_list:
  global_declaration                {$$ = template("%s\n", $1);}
| global_list global_declaration    {$$ = template("%s\n%s\n", $1, $2);}
;

global_declaration:
  declarations        {$$ = template("%s", $1);}
| func_declaration    {$$ = template("%s", $1);}
;

/************************************DECLARATIONS************************************************/
declarations:
  KW_VAR var_list COLON data_types SEMICOLON      {$$ = template("%s %s;", $4, $2);}
| KW_CONST const_list COLON data_types SEMICOLON  {$$ = template("const %s %s;", $4, $2);}
;

var_list:
  var_list COMMA var_init   {$$ = template("%s, %s", $1, $3);}
| var_init
;

var_init:
  dec_ids
| dec_ids ASSIGN_OP expr { $$ = template("%s = %s", $1, $3);}
;

const_list:
  const_list COMMA const_init   {$$ = template("%s, %s", $1, $3);}
| const_init
;

const_init:
  dec_ids ASSIGN_OP expr { $$ = template("%s = %s", $1, $3);}
;

dec_ids:
  IDENTIFIER                                                    {$$ = template("%s", $1);}
| IDENTIFIER LEFT_SQUARE_BRACKET INT_NUM RIGHT_SQUARE_BRACKET   {$$ = template("%s[%s]", $1, $3);}
;

data_types:
  KW_NUMBER    { $$ = template("%s", "double"); }
| KW_STRING    { $$ = template("%s", "char*"); }
| KW_BOOLEAN   { $$ = template("%s", "int"); }
;
/************************************FUNCTIONS************************************************/
main_func:
  KW_FUNCTION KW_START LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON KW_VOID LEFT_CURLY_BRACKET statement_list RIGHT_CURLY_BRACKET 
  {$$ = template("int main(){\n   %s\n   return 0;\n}", $8);}
;

func_declaration:
  KW_FUNCTION IDENTIFIER LEFT_PARENTHESIS func_input_list RIGHT_PARENTHESIS COLON func_return_types complex_statements SEMICOLON
  {$$ = template("%s %s(%s)%s", $7, $2, $4, $8);}
;

func_input_list:
  %empty                                            { $$ = template("");}
| KW_VOID                                           {$$ = template("%s", "void");} 
| func_ids COLON data_types                         {$$ = template("%s %s", $3, $1);}
| func_ids COLON data_types COMMA func_input_list   {$$ = template("%s %s, %s", $3, $1, $5);}
;

func_return_types:
  data_types                                            {$$ = template("%s", $1);}
| KW_VOID                                               {$$ = template("%s", "void");}
| LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET data_types   {$$ = template("%s*", $3);}
| LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET KW_VOID      {$$ = template("void*");}
;

func_ids:
  IDENTIFIER                                            {$$ = template("%s", $1);}
| IDENTIFIER LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET   {$$ = template("%s[]", $1);}
;

func_input: 
  %empty                 { $$ = template("");}
| func_input COMMA expr  { $$ = template("%s, %s", $1, $3); }
| expr                   { $$ = template("%s", $1); }
;

/**********************************STATEMENTS**************************************************/
general_statement:
  complex_statements  { $$ = template("%s", $1); }
| statement           { $$ = template("%s\n", $1); }
;

complex_statements: 
  LEFT_CURLY_BRACKET statement_list RIGHT_CURLY_BRACKET   {$$ = template("{\n   %s\n}", $2);}
;

statement_list:
  statement_declaration                  {$$ = template("%s", $1);}
| statement_list statement_declaration   {$$ = template("%s\n   %s", $1, $2);}
;

statement_declaration:
  declarations   {$$ = template("%s", $1);}
| statement      {$$ = template("%s", $1);}
;

statement:
  assign_statement SEMICOLON    {$$ = template("%s;", $1);}
| if_statement                  {$$ = template("%s", $1);} 
| for_statement                 {$$ = template("%s", $1);}
| while_statement               {$$ = template("%s", $1);}
| break_statement               {$$ = template("%s", $1);}
| continue_statement            {$$ = template("%s", $1);}
| return_statement              {$$ = template("%s", $1);}
| function_statement            {$$ = template("%s", $1);}
| default_func SEMICOLON        {$$ = template("%s;", $1);}
;

assign_statement:
  dec_ids ASSIGN_OP expr               {$$ = template("%s = %s", $1, $3);}
| dec_ids ASSIGN_OP read_number_func   {$$ = template("%s = %s", $1, $3);}
| dec_ids ASSIGN_OP read_string_func   {$$ = template("%s = %s", $1, $3);}
;

if_statement:
  KW_IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS general_statement else_if optional_else SEMICOLON   { $$ = template("if(%s) %s %s %s", $3, $5, $6, $7); }
| KW_IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS general_statement optional_else SEMICOLON           { $$ = template("if(%s) %s %s", $3, $5, $6); }
;

else_if:
  KW_ELSE KW_IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS general_statement           { $$ = template("  else if(%s) %s", $4, $6); }
| else_if KW_ELSE KW_IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS general_statement   { $$ = template("%s   else if(%s) %s", $1, $5, $7); }
;

optional_else:
	%empty                      {$$ = template("");}
| KW_ELSE complex_statements  {$$ = template("  else %s",$2);}
;

for_statement:
  KW_FOR LEFT_PARENTHESIS assign_statement SEMICOLON expr SEMICOLON assign_statement RIGHT_PARENTHESIS complex_statements SEMICOLON  
  { 
    $$ = template("for(%s; %s; %s)%s", $3, $5, $7, $9); 
  }
| KW_FOR LEFT_PARENTHESIS assign_statement SEMICOLON SEMICOLON assign_statement RIGHT_PARENTHESIS complex_statements SEMICOLON
  { 
    $$ = template("for(%s; ; %s)%s", $3, $6, $8); 
  }
;

while_statement:
  KW_WHILE expr complex_statements SEMICOLON  { $$ = template("while(%s)%s", $2, $3); }
;

break_statement:
  KW_BREAK SEMICOLON   { $$ = template("break;"); }
;

continue_statement:
  KW_CONTINUE SEMICOLON   { $$ = template("continue;"); }
;

return_statement: 
  KW_RETURN SEMICOLON              { $$ = template("return;"); }
| KW_RETURN KW_NULL SEMICOLON      { $$ = template("return NULL;"); }
| KW_RETURN expr SEMICOLON         { $$ = template("return %s;",$2); }
;

function_statement:
  IDENTIFIER LEFT_PARENTHESIS func_input RIGHT_PARENTHESIS SEMICOLON   { $$ = template("%s(%s);", $1, $3); }
; 


/********************************DEFAULT MINISCRITP FUNCTIONS***********************************/
default_func:
  read_string_func    { $$ = $1; }
| read_number_func    { $$ = $1; }
| write_string_func   { $$ = $1; }
| write_number_func   { $$ = $1; }
;

read_string_func:
  READ_STR LEFT_PARENTHESIS RIGHT_PARENTHESIS    { $$ = template("readString()"); }
;

read_number_func:
  READ_NUM LEFT_PARENTHESIS RIGHT_PARENTHESIS   { $$ = template("readNumber()"); }
;

write_string_func:
  WRITE_STR LEFT_PARENTHESIS IDENTIFIER RIGHT_PARENTHESIS        { $$ = template("writeString(%s)", $3); }
| WRITE_STR LEFT_PARENTHESIS CONST_STRING RIGHT_PARENTHESIS   { $$ = template("writeString(%s)", $3); }
;

write_number_func:
  WRITE_NUM LEFT_PARENTHESIS dec_ids RIGHT_PARENTHESIS    { $$ = template("writeNumber(%s)", $3);}
| WRITE_NUM LEFT_PARENTHESIS INT_NUM RIGHT_PARENTHESIS    { $$ = template("writeNumber(%s)", $3); }
| WRITE_NUM LEFT_PARENTHESIS REAL_NUM RIGHT_PARENTHESIS   { $$ = template("writeNumber(%s)", $3); }
;

/**********************************EXPRESSIONS*************************************************/
data_type_values: 
  IDENTIFIER      { $$ = template("%s", $1); }
| INT_NUM         { $$ = template("%s", $1); }
| REAL_NUM        { $$ = template("%s", $1); }
| CONST_STRING    { $$ = template("%s", $1); }
| KW_TRUE         { $$ = template("%s", "1"); }
| KW_FALSE        { $$ = template("%s", "0"); }
;

general_expr: 
  data_type_values
| IDENTIFIER LEFT_SQUARE_BRACKET expr RIGHT_SQUARE_BRACKET  { $$ = template("%s[%s]",$1, $3); }
| LEFT_PARENTHESIS expr RIGHT_PARENTHESIS                   { $$ = template("(%s)", $2); }
| IDENTIFIER LEFT_PARENTHESIS func_input RIGHT_PARENTHESIS  { $$ = template("%s(%s)", $1, $3); }
;

not_expr: 
  general_expr
| KW_NOT sign_expr  { $$ = template("! %s", $2); }
;

sign_expr:
  not_expr
| PLUS_OP not_expr   { $$ = template("+ %s", $2); }
| MINUS_OP not_expr  { $$ = template("- %s", $2); }
;

factor_expr:
  sign_expr
| factor_expr MULT_OP sign_expr     { $$ = template("%s * %s", $1, $3); }
| factor_expr DIV_OP sign_expr      { $$ = template("%s / %s", $1, $3); }
| factor_expr MOD_OP sign_expr      { $$ = template("(int) %s % (int) %s", $1, $3); }
| factor_expr POWER_OP sign_expr    { $$ = template("pow(%s, %s)", $1, $3); }
;

plus_minus_expr:
  factor_expr
| plus_minus_expr PLUS_OP factor_expr         { $$ = template("%s + %s", $1, $3); }
| plus_minus_expr MINUS_OP factor_expr        { $$ = template("%s - %s", $1, $3); }
;

relation_expr:
  plus_minus_expr
| relation_expr EQUAL_OP plus_minus_expr        { $$ = template("%s == %s", $1, $3); }
| relation_expr NOT_EQUAL_OP plus_minus_expr    { $$ = template("%s != %s", $1, $3); }
| relation_expr LESS_OP plus_minus_expr         { $$ = template("%s < %s", $1, $3); }
| relation_expr LESS_EQUAL_OP plus_minus_expr   { $$ = template("%s <= %s", $1, $3); }
;

logic_expr: 
  relation_expr
| logic_expr KW_AND relation_expr   { $$ = template("%s && %s", $1, $3); }
| logic_expr KW_OR relation_expr    { $$ = template("%s || %s", $1, $3); }
;

expr:
 logic_expr  { $$ = template("%s", $1); }
;


%%

int main () {
  if ( yyparse() == 0 )
    printf("Accepted!\n");
  else
    printf("Rejected!\n");
}
