
%{

    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include "symtab.h"
    #include "codeGenerator.h"

    #define YYSTYPE char*

    int yyparse(void);
    int yyerror(char const *msg);
    int yylex(void);

    extern int line;

    int classID = 0;
    int level = 0;
    bool isParam = false;
    int FuncCallIndec = -1;
    int expression_level = 0;


    int address = 0;
    int code_index = -1;
    char* fun_name = "";
    char* class_name = "";
    char* math_op = "";
    char* com_op = "";
    int retour = 0;

    #define YYERROR_VERBOSE 1


%}

%token  PUBLIC
%token  STATIC
%token  CLASS
%token  VOID
%token  MAIN
%token  EXTENDS
%token  RETURN
%token  SOP
%token  LENGTH
%token  THIS
%token  NEW
%token  IF
%token  ELSE
%token  WHILE
%token  INTEGER
%token  STRING
%token  DATATYPE
%token  OPENPARENT
%token  CLOSEPARENT
%token  OPENSQRBRACK
%token  CLOSESQRBRACK
%token  OPENBRAC
%token  CLOSEBRAC
%token  AND
%token  OR
%token  DOT
%token  SEMICOLON
%token  COMMA
%token  DOUBLEQUOTE
%token  SINGLEQUOTE
%token  PLUS
%token  MINUS
%token  MULTIPLY
%token  NOT
%token  EQUAL
%token  DIV
%token  COMPOP
%token  BOOLVALUE
%token  INTEGERVALUE
%token  IDENT


%start program

%%

program              : MainClass ClassDeclaration           { verifMainFunction();verifCode(); printf("Analyze finished with success \n");}


MainMethodParam      : _STRING _OPENSQRBRACK _CLOSESQRBRACK _IDENT
                        {
                            code_index = addNode("main","DECLARATION","METHOD","void",0,classID);
                            setParam($4,strcat($1,"[]"));

                            addCodeLine("ENTREE",code_index,"main","");
                        }
                        | error _OPENSQRBRACK _CLOSESQRBRACK _IDENT                                 { yyerror (" String is needed  "); YYABORT}
                        | _STRING error _CLOSESQRBRACK _IDENT                                       { yyerror (" Open brackets is needed  "); YYABORT}
                        | _STRING _OPENSQRBRACK error _IDENT                                        { yyerror (" CLose brackets is needed  "); YYABORT}
                        | _STRING _OPENSQRBRACK _CLOSESQRBRACK error                                { yyerror (" Identifier is needed  "); YYABORT}
                        ;

MainClass            : ClassScope _OPENBRAC _PUBLIC _STATIC _VOID _MAIN _OPENPARENT MainMethodParam _CLOSEPARENT _OPENBRAC Statement _CLOSEBRAC _CLOSEBRAC     { addCodeLine("SORTIE",-1,"main",""); addCodeLine("SORTIE",-1,"","CLASS");}
                        | ClassScope error _PUBLIC _STATIC _VOID _MAIN _OPENPARENT MainMethodParam _CLOSEPARENT _OPENBRAC Statement _CLOSEBRAC _CLOSEBRAC      { yyerror (" Open brackets is needed  "); YYABORT}
                        | ClassScope _OPENBRAC error _STATIC _VOID _MAIN _OPENPARENT MainMethodParam _CLOSEPARENT _OPENBRAC Statement _CLOSEBRAC _CLOSEBRAC    { yyerror (" Public is needed  "); YYABORT}
                        | ClassScope _OPENBRAC _PUBLIC error _VOID _MAIN _OPENPARENT MainMethodParam _CLOSEPARENT _OPENBRAC Statement _CLOSEBRAC _CLOSEBRAC    { yyerror (" Static is needed  "); YYABORT}
                        | ClassScope _OPENBRAC _PUBLIC _STATIC error _MAIN _OPENPARENT MainMethodParam _CLOSEPARENT _OPENBRAC Statement _CLOSEBRAC _CLOSEBRAC  { yyerror (" Void is needed  "); YYABORT}
                        | ClassScope _OPENBRAC _PUBLIC _STATIC _VOID error _OPENPARENT MainMethodParam _CLOSEPARENT _OPENBRAC Statement _CLOSEBRAC _CLOSEBRAC  { yyerror (" Main is needed  "); YYABORT}
                        | ClassScope _OPENBRAC _PUBLIC _STATIC _VOID _MAIN error MainMethodParam _CLOSEPARENT _OPENBRAC Statement _CLOSEBRAC _CLOSEBRAC        { yyerror (" Open parentheses is needed  "); YYABORT}
                        | ClassScope _OPENBRAC _PUBLIC _STATIC _VOID _MAIN _OPENPARENT MainMethodParam error _OPENBRAC Statement _CLOSEBRAC _CLOSEBRAC         { yyerror (" Close parentheses is needed  "); YYABORT}
                        | ClassScope _OPENBRAC _PUBLIC _STATIC _VOID _MAIN _OPENPARENT MainMethodParam _CLOSEPARENT error Statement _CLOSEBRAC _CLOSEBRAC      { yyerror (" Open brackets is needed  "); YYABORT}
                        | ClassScope _OPENBRAC _PUBLIC _STATIC _VOID _MAIN _OPENPARENT MainMethodParam _CLOSEPARENT _OPENBRAC error _CLOSEBRAC _CLOSEBRAC      { yyerror (" Statement is needed  "); YYABORT}
                        | ClassScope _OPENBRAC _PUBLIC _STATIC _VOID _MAIN _OPENPARENT MainMethodParam _CLOSEPARENT _OPENBRAC Statement error _CLOSEBRAC       { yyerror (" Close brackets is needed  "); YYABORT}
                        | ClassScope _OPENBRAC _PUBLIC _STATIC _VOID _MAIN _OPENPARENT MainMethodParam _CLOSEPARENT _OPENBRAC Statement _CLOSEBRAC error       { yyerror (" close brackets is needed  "); YYABORT}
                        ;

SectionE_I           : _EXTENDS _IDENT
                        {
                            addNode($2,"EXTENSION","CLASS","IDENT",0,classID);
                            level = 0;
                        }
                        | error _IDENT        { yyerror (" Extends is needed  "); YYABORT}
                        | _EXTENDS error      { yyerror (" Identifier is needed  "); YYABORT}
                        |       {level = 0;}
                        ;

ClassScope           : _CLASS _IDENT
                        {
                            classID +=1;

                            code_index  = checkClass($2,classID);
                            class_name = $2;
                            addCodeLine("ENTREE",code_index,"","CLASS");
                        }
                        | error _IDENT   { yyerror (" Class is needed  "); YYABORT}
                        | _CLASS error   { yyerror (" Identifier is needed  "); YYABORT}
                        ;

ClassDeclaration     : ClassScope  SectionE_I _OPENBRAC VarDeclaration MethodDeclaration _CLOSEBRAC
                        {
                            addCodeLine("SORTIE",-1,"","CLASS");
                            addCodeLine("RETOUR",retour+1,"","");
                        }
                        ClassDeclaration
                        | error SectionE_I _OPENBRAC VarDeclaration MethodDeclaration _CLOSEBRAC ClassDeclaration
                        | ClassScope SectionE_I error VarDeclaration MethodDeclaration _CLOSEBRAC ClassDeclaration    { yyerror (" Open brackets is needed  "); YYABORT}
                        | ClassScope SectionE_I _OPENBRAC VarDeclaration MethodDeclaration error ClassDeclaration     { yyerror (" Close brackets is needed  "); YYABORT}
                        |
                        ;

Type                 : _DATATYPE _IDENT
                        {
                            if(isParam)
                                setParam($2,$1);
                            else {
                                code_index = checkVariable($2,$1,level,classID);
                                addCodeLine("LDC",code_index,"","");
                                addCodeLine("STORE",address,"","");
                                address++;
                            }
                        }
                        /*| _IDENT _IDENT
                        {
                            if(isParam)
                                setParam($2,$1);
                            else {
                                code_index = checkVariable($2,$1,level,classID);
                                addCodeLine("LDC",code_index,"","");
                                addCodeLine("STORE",address,"","");
                                address++;
                            }

                        } */
                        | _INTEGER _IDENT
                        {
                            if(isParam)
                                setParam($2,$1);
                            else {
                                code_index = checkVariable($2,$1,level,classID);
                                addCodeLine("LDC",code_index,"","");
                                addCodeLine("STORE",address,"","");
                                address++;
                            }

                        }
                        | error _IDENT                    { yyerror (" Valid Type is needed  "); YYABORT}
                       
                        | _DATATYPE error                 { yyerror (" Identifier is needed  "); YYABORT}
                        | _INTEGER error                  { yyerror (" Identifier is needed  "); YYABORT}
                        ;

MethodType           : _DATATYPE _IDENT
                        {
                            code_index = checkMethod($2,$1,classID);
                            isParam = true;

                            fun_name = $2;
                            addCodeLine("ENTREE",code_index,$2,"");
                        }
                        /*| _IDENT _IDENT
                        {
                            code_index = checkMethod($2,$1,classID);
                            isParam = true;

                            fun_name = $2;
                            addCodeLine("ENTREE",code_index,$2,"");
                        }*/
                        | _INTEGER _IDENT
                        {
                            code_index = checkMethod($2,$1,classID);
                            isParam = true;

                            fun_name = $2;
                            addCodeLine("ENTREE",code_index,$2,"");
                        }
                        | error _IDENT                    { yyerror (" Valid Type is needed  "); YYABORT}
                        | _DATATYPE error                 { yyerror (" Identifier is needed  "); YYABORT}
                        | _INTEGER error                  { yyerror (" Identifier is needed  "); YYABORT}
                        ;

VarDeclaration       : Type _SEMICOLON VarDeclaration
                        |
                        | Type error VarDeclaration       { yyerror (" Semi colon is needed  "); YYABORT}
                        ;

SectionC_T           : _COMMA Type SectionC_T
                        | error Type SectionC_T           { yyerror (" Comma is needed  "); YYABORT}
                        |
                        ;

SectionT_SCT         :  Type SectionC_T { isParam = false; level = 1;}
                        |               { isParam = false; level = 1;}
                        ;

MethodDeclaration    : _PUBLIC MethodType _OPENPARENT SectionT_SCT _CLOSEPARENT _OPENBRAC VarDeclaration Statement _RETURN Expression _SEMICOLON _CLOSEBRAC
                        {
                            addCodeLine("SORTIE",-1,fun_name,"");
                        }
                        MethodDeclaration
                        | error MethodType _OPENPARENT SectionT_SCT _CLOSEPARENT _OPENBRAC VarDeclaration Statement _RETURN Expression _SEMICOLON _CLOSEBRAC MethodDeclaration   { yyerror (" Public is needed  "); YYABORT}
                        | _PUBLIC error error SectionT_SCT _CLOSEPARENT _OPENBRAC VarDeclaration Statement _RETURN Expression _SEMICOLON _CLOSEBRAC MethodDeclaration       { yyerror (" Open parentheses is needed  "); YYABORT}
                        | _PUBLIC MethodType _OPENPARENT SectionT_SCT error _OPENBRAC VarDeclaration Statement _RETURN Expression _SEMICOLON _CLOSEBRAC MethodDeclaration        { yyerror (" Close parentheses is needed  "); YYABORT}
                        | _PUBLIC MethodType _OPENPARENT SectionT_SCT _CLOSEPARENT error VarDeclaration Statement _RETURN Expression _SEMICOLON _CLOSEBRAC MethodDeclaration     { yyerror (" Open brackets is needed  "); YYABORT}
                        | _PUBLIC MethodType _OPENPARENT SectionT_SCT _CLOSEPARENT _OPENBRAC VarDeclaration Statement error Expression _SEMICOLON _CLOSEBRAC MethodDeclaration   { yyerror (" Return is needed  "); YYABORT}
                        | _PUBLIC MethodType _OPENPARENT SectionT_SCT _CLOSEPARENT _OPENBRAC VarDeclaration Statement _RETURN Expression error _CLOSEBRAC MethodDeclaration      { yyerror (" Semi colon is needed  "); YYABORT}
                        | _PUBLIC MethodType _OPENPARENT SectionT_SCT _CLOSEPARENT _OPENBRAC VarDeclaration Statement _RETURN Expression _SEMICOLON error MethodDeclaration      { yyerror (" Close brackets is needed  "); YYABORT}
                        |
                        ;

Statement            : _OPENBRAC Statement Statement _CLOSEBRAC
                        | error Statement Statement _CLOSEBRAC                                               { yyerror (" Open brackets is needed  "); YYABORT}
                        | _OPENBRAC Statement Statement error                                                { yyerror (" Close brackets is needed  "); YYABORT}
                        | _IF _OPENPARENT Expression _CLOSEPARENT Statement Statement
                        {
                            addCodeLine("SAUT",-1,"","ELSE");
                        }
                        _ELSE Statement Statement
                        {
                            addCodeLine("SAUT",-1,"","DONE_IF");
                        }
                        | error _OPENPARENT Expression _CLOSEPARENT Statement _ELSE Statement               { yyerror (" If brackets is needed  "); YYABORT}
                        | _IF error Expression _CLOSEPARENT Statement _ELSE Statement                       { yyerror (" Open parentheses brackets is needed  "); YYABORT}
                        | _IF _OPENPARENT Expression error Statement _ELSE Statement                        { yyerror (" Close parentheses is needed  "); YYABORT}
                        | _IF _OPENPARENT Expression _CLOSEPARENT Statement error Statement                 { yyerror (" Else is needed  "); YYABORT}
                        | _WHILE _OPENPARENT Expression _CLOSEPARENT
                        {
                            ifElseChange();
                        }
                        Statement
                        {
                            addCodeLine("TANTQUE",-1,"","");
                        }
                        | error _OPENPARENT Expression _CLOSEPARENT Statement                               { yyerror (" While is needed  "); YYABORT}
                        | _WHILE error Expression _CLOSEPARENT Statement                                    { yyerror (" Open parentheses is needed  "); YYABORT}
                        | _WHILE _OPENPARENT Expression error Statement                                     { yyerror (" Close parentheses is needed  "); YYABORT}
                        | _SOP _OPENPARENT Expression _CLOSEPARENT _SEMICOLON Statement
                        | error _OPENPARENT Expression _CLOSEPARENT _SEMICOLON Statement                              { yyerror (" System.out.println is needed  "); YYABORT}
                        | _SOP error Expression _CLOSEPARENT _SEMICOLON Statement                                     { yyerror (" Open parentheses is needed  "); YYABORT}
                        | _SOP _OPENPARENT Expression error _SEMICOLON Statement                                      { yyerror (" Close parentheses is needed  "); YYABORT}
                        | _SOP _OPENPARENT Expression _CLOSEPARENT error Statement                                    { yyerror (" Semi colon is needed  "); YYABORT}
                        | _IDENT _EQUAL Expression _SEMICOLON
                        {
                            addCodeLine("STORE",-1,"","");
                            code_index = checkDeclaration($1,"ASSIGNMENT","VARIABLE",level,classID);
                            addCodeLine_variable("STORE",$1);
                        }
                        Statement
                        | error _EQUAL Expression _SEMICOLON Statement                                      { yyerror (" Identifier is needed  "); YYABORT}
                        | _IDENT error Expression _SEMICOLON Statement                                      { yyerror (" Equal operator is needed  "); YYABORT}
                        | _IDENT _EQUAL Expression error Statement                                          { yyerror (" Semi colon is needed  "); YYABORT}
                        | _IDENT _OPENSQRBRACK Expression _CLOSESQRBRACK _EQUAL Expression _SEMICOLON Statement
                        {
                            checkDeclaration($1,"ASSIGNMENT","VARIABLE",level,classID)

                        }
                        | error _OPENSQRBRACK Expression _CLOSESQRBRACK _EQUAL Expression _SEMICOLON Statement        { yyerror (" Identifier is needed  "); YYABORT}
                        | _IDENT error Expression _CLOSESQRBRACK _EQUAL Expression _SEMICOLON Statement               { yyerror (" Open brackets is needed  "); YYABORT}
                        | _IDENT _OPENSQRBRACK Expression error _EQUAL Expression _SEMICOLON  Statement               { yyerror (" Close brackets is needed  "); YYABORT}
                        | _IDENT _OPENSQRBRACK Expression _CLOSESQRBRACK error Expression _SEMICOLON  Statement       { yyerror (" Equal operator is needed  "); YYABORT}
                        | _IDENT _OPENSQRBRACK Expression _CLOSESQRBRACK _EQUAL Expression error  Statement           { yyerror (" Semi colon is needed  "); YYABORT}
                        |
                        ;

SectionC_E           : _COMMA Expression SectionC_E
                        | error Expression SectionC_E            { yyerror (" Comma is needed  "); YYABORT}
                        |
                        ;

LogicOperator        : _AND                      {com_op = "&&";}
                        | _COMPOP                {com_op = $1;}
                        ;

MathOperator         : _PLUS                    { math_op = "+";}
                        | _MINUS                { math_op = "-";}
                        | _MULTIPLY             { math_op = "*";}
                        | _DIV                  { math_op = "/";}
                        ;

SectionE_SCE         : Expression SectionC_E
                        {
                            FuncCallIndec = -1;
                            expression_level=0;
                        }
                        |
                        {
                            FuncCallIndec = -1;
                            expression_level=0;
                        }
                        ;

UseFunction          : _DOT _IDENT
                        {
                            FuncCallIndec = addNode($2,"USE","METHOD","DOT_IDENT",0,classID);

                            retour = addCodeLine("APPEL",FuncCallIndec,$2,"");
                        }
                        | error _IDENT                                                                   { yyerror (" Dot is needed  "); YYABORT}
                        | _DOT  error                                                                    { yyerror (" Identifier is needed  "); YYABORT}
                        ;

Expression           : Expression
                        {
                            if(FuncCallIndec != -1) {
                                removeParam(FuncCallIndec);
                            }
                            char * end;
                            long value = strtol($1,&end,10 );
                            if(end != NULL){
                                addCodeLine_ldv("LDV",$1);
                            }
                        }
                        MathOperator Expression
                        {
                            if(FuncCallIndec != -1){
                                removeParam(FuncCallIndec);
                                insertCallParam(FuncCallIndec,"EXP","int");
                            }
                            char * end;
                            long value = strtol($4,&end,10);
                            printf("%s\n",end);
                            if(strcmp(end,"") != 0){
                                addCodeLine_ldv("LDV",$4);
                            }
                            if(strcmp(math_op,"+") == 0)
                                addCodeLine("ADD",-1,"","");
                            else if(strcmp(math_op,"*") == 0)
                                addCodeLine("MUL",-1,"","");
                            else if(strcmp(math_op,"/") == 0)
                                addCodeLine("DIV",-1,"","");
                            else
                                addCodeLine("SUB",-1,"","");
                        }
                        | Expression
                        {
                            if(FuncCallIndec != -1) {
                                removeParam(FuncCallIndec);
                            }
                            char * end;
                            long value = strtol($1,&end,10 );
                            if(end != NULL){
                                addCodeLine_ldv("LDV",$1);
                            }
                        }
                        LogicOperator Expression
                        {

                            if(FuncCallIndec != -1) {
                                removeParam(FuncCallIndec);
                                insertCallParam(FuncCallIndec,"EXP","bool");
                            }

                            char * end;
                            long value = strtol($4,&end,10);
                            printf("%s\n",end);
                            if(strcmp(end,"") != 0){
                                addCodeLine_ldv("LDV",$4);
                            }

                            if(strcmp(com_op,"<") == 0)
                                addCodeLine("INF",-1,"","");
                            else if(strcmp(com_op,"<=")== 0)
                                addCodeLine("INFE",-1,"","");
                            else if(strcmp(com_op,">")== 0)
                                addCodeLine("SUP",-1,"","");
                            else if(strcmp(com_op,">=")== 0)
                                addCodeLine("SUPE",-1,"","");
                            else if(strcmp(com_op,">=") == 0)
                                addCodeLine("SUPE",-1,"","");
                            else
                                addCodeLine("EGAL",-1,"","");

                            addCodeLine("SIFAUX",-1,"","");
                        }
                        | Expression error Expression                                                    { yyerror (" Comparison operator is needed  "); YYABORT}
                        | Expression _OPENSQRBRACK Expression _CLOSESQRBRACK
                        {

                            if(FuncCallIndec != -1) {
                                insertCallParam(FuncCallIndec,"EXP","int[]");
                            }

                        }
                        | Expression error Expression _CLOSESQRBRACK                                     { yyerror (" Open brackets is needed  "); YYABORT}
                        | Expression _OPENSQRBRACK Expression error                                      { yyerror (" Close brackets is needed  "); YYABORT}
                        | Expression _DOT _LENGTH
                        {
                            if(FuncCallIndec != -1) {
                                insertCallParam(FuncCallIndec,"EXP","int");
                            }

                        }
                        | Expression error _LENGTH                                                       { yyerror (" Dot is needed  "); YYABORT}
                        | Expression _DOT error                                                          { yyerror (" Length is needed  "); YYABORT}
                        | Expression UseFunction _OPENPARENT SectionE_SCE _CLOSEPARENT
                        | Expression UseFunction error SectionE_SCE _CLOSEPARENT                         { yyerror (" Open parentheses is needed  "); YYABORT}
                        | Expression UseFunction _OPENPARENT SectionE_SCE error                          { yyerror (" Close parentheses is needed  "); YYABORT}
                        | _INTEGERVALUE
                        {
                            if(FuncCallIndec != -1 && expression_level < 1)
                                insertCallParam(FuncCallIndec,$1,"int");
                            else {
                                addCodeLine("LDC",strtol($1, NULL, 10),"","INTEGER_VALUE");
                                
                            }

                        }
                        | _MINUS _INTEGERVALUE
                        {

                            if(FuncCallIndec != -1 && expression_level < 1)
                                insertCallParam(FuncCallIndec,strcat("-",$2),"int");
                            else{
                                addCodeLine("LDC",-strtol($2, NULL, 10),"","INTEGER_VALUE");
                                addCodeLine("STORE",-1,"","");
                               
                            }
                        }
                        | _BOOLVALUE
                        {
                            if(FuncCallIndec != -1 && expression_level < 1)
                                insertCallParam(FuncCallIndec,$1,"bool");
                            else {
                                if (strcmp($1,"true") == 0)
                                {
                                    addCodeLine("LDC",1,"","BOOLEAN_VALUE");
                                    addCodeLine("STORE",-1,"","");
                                    
                                }
                                else {
                                    addCodeLine("LDC",0,"","BOOLEAN_VALUE");
                                    addCodeLine("STORE",-1,"","");
                                    
                                }
                            }
                        }
                        | _IDENT
                        {
                            if(FuncCallIndec != -1 && expression_level < 1)
                              insertCallParam(FuncCallIndec,$1,"IDENT");

                            code_index = checkDeclaration($1,"USE","VARIABLE",level,classID);
                            
                        }
                        | _THIS
                        | _NEW _INTEGER _OPENSQRBRACK Expression _CLOSEBRAC
                        | error _INTEGER _OPENSQRBRACK Expression _CLOSEBRAC                             { yyerror (" New is needed  "); YYABORT}
                        | _NEW error _OPENSQRBRACK Expression _CLOSEBRAC                                 { yyerror (" Integer type is needed  "); YYABORT}
                        | _NEW _INTEGER error Expression _CLOSEBRAC                                      { yyerror (" Open brackets is needed  "); YYABORT}
                        | _NEW _INTEGER _OPENSQRBRACK Expression error                                   { yyerror (" Close brackets is needed  "); YYABORT}
                        | _NEW _IDENT _OPENPARENT _CLOSEPARENT
                        {
                            addNode($2,"INSTANTIATION","VARIABLE","NEW_IDENT",0,classID);
                        }
                        | error _IDENT _OPENPARENT _CLOSEPARENT                                          { yyerror (" New is needed  "); YYABORT}
                        | _NEW error _OPENPARENT _CLOSEPARENT                                            { yyerror (" Identifier is needed  "); YYABORT}
                        | _NEW _IDENT error _CLOSEPARENT                                                 { yyerror (" Open parentheses is needed  "); YYABORT}
                        | _NEW _IDENT _OPENPARENT error                                                  { yyerror (" Close parentheses is needed  "); YYABORT}
                        | _NOT Expression
                        | error Expression                                                               { yyerror (" Not operator is needed  "); YYABORT}
                        | _OPENPARENT Expression _CLOSEPARENT
                        | error Expression _CLOSEPARENT                                                  { yyerror (" open parentheses is needed  "); YYABORT}
                        | _OPENPARENT Expression error                                                   { yyerror (" Close parentheses is needed  "); YYABORT}
                        | error                                                                          { yyerror (" Integer Value or boolean value or identifier or this   is needed  "); YYABORT}
                        ;

%%

    int yyerror(char const *msg) {

        fprintf(stderr, "%s %d\n", msg,line);
        return 0;
    }

    extern FILE *yyin;

    int main()
    {
        yyparse();
    }