%{
     #include <stdio.h>
     #include <stdlib.h>
     #include <string.h>
     #include "SyntaxAnalyzer.tab.h"
     #include <math.h>

     #define YYSTYPE char*

     int line = 1;
%}

delim                                   ([ \t]|(" "))
bl                                      {delim}+
bl0                                     {delim}*
numberN                                 [0-9]
numberNN                                [1-9]
lettre                                  [a-zA-Z]

openParentheses                         (\()
closeParentheses                        (\))
openSquareBrackets                      (\[)
closeSquareBrackets                     (\])
openBraces                              (\{)
closeBraces                             (\})
COMMENT_LINE                            "//"

identifier                              ([A-Za-z_][A-Za-z0-9_]*)
integerLiteral                          ({numberNN}{numberN}*)
booleanLiteral                          "true"|"false"
illegalIdentifier                       {numberN}({lettre}|{numberN})*

dataType                                {primtiveType}|tableType
primtiveType                            "int"|"bool"|"String"|"byte"|"char"|"short"|"long"|"float"|"double"
tableType                               ({primtiveType}{bl}{openSquareBrackets}{bl0}{closeSquareBrackets})

%%

{bl}                                    /* pas d'actions */
"\n"                                    line++;

"public"                                { yylval = (int)strdup(yytext); return PUBLIC;            }
"static"                                { yylval = (int)strdup(yytext); return STATIC;            }
"class"                                 { yylval = (int)strdup(yytext); return CLASS;             }
"void"                                  { yylval = (int)strdup(yytext); return VOID;              }
"main"                                  { yylval = (int)strdup(yytext); return MAIN;              }
"extends"                               { yylval = (int)strdup(yytext); return EXTENDS;           }
"return"                                { yylval = (int)strdup(yytext); return RETURN;            }
"System.out.println"                    { yylval = (int)strdup(yytext); return SOP;               }
"length"                                { yylval = (int)strdup(yytext); return LENGTH;            }
"this"                                  { yylval = (int)strdup(yytext); return THIS;              }
"new"                                   { yylval = (int)strdup(yytext); return NEW;               }

"if"                                    { yylval = (int)strdup(yytext); return IF;                }
"else"                                  { yylval = (int)strdup(yytext); return ELSE;              }
"while"                                 { yylval = (int)strdup(yytext); return WHILE;             }

"int"                                   { yylval = (int)strdup(yytext); return INTEGER;           }
"String"                                { yylval = (int)strdup(yytext); return STRING;            }
{dataType}                              { yylval = (int)strdup(yytext); return DATATYPE;          }

{openParentheses}                       { yylval = (int)strdup(yytext); return OPENPARENT;        }
{closeParentheses}                      { yylval = (int)strdup(yytext); return CLOSEPARENT;       }
{openSquareBrackets}                    { yylval = (int)strdup(yytext); return OPENSQRBRACK;      }
{closeSquareBrackets}                   { yylval = (int)strdup(yytext); return CLOSESQRBRACK;     }
{openBraces}                            { yylval = (int)strdup(yytext); return OPENBRAC;          }
{closeBraces}                           { yylval = (int)strdup(yytext); return CLOSEBRAC;         }

"&&"                                    { yylval = (int)strdup(yytext); return AND;               }
"||"                                    { yylval = (int)strdup(yytext); return OR;                }

"."                                     { yylval = (int)strdup(yytext); return DOT;               }
";"                                     { yylval = (int)strdup(yytext); return SEMICOLON;         }
","                                     { yylval = (int)strdup(yytext); return COMMA;             }
"\""                                    { yylval = (int)strdup(yytext); return DOUBLEQUOTE;       }
"\'"                                    { yylval = (int)strdup(yytext); return SINGLEQUOTE;       }

"+"                                     { yylval = (int)strdup(yytext); return PLUS;              }
"-"                                     { yylval = (int)strdup(yytext); return MINUS;             }
"*"                                     { yylval = (int)strdup(yytext); return MULTIPLY;          }
"!"                                     { yylval = (int)strdup(yytext); return NOT;               }
"="                                     { yylval = (int)strdup(yytext); return EQUAL;             }
"\/"                                    { yylval = (int)strdup(yytext); return DIV;               }

"<"|">"|"<="|">="|"=="|"!="             { yylval = (int)strdup(yytext); return COMPOP;            }



{booleanLiteral}                        { yylval = (int)strdup(yytext); return BOOLVALUE;         }
{integerLiteral}                        { yylval = (int)strdup(yytext); return INTEGERVALUE;      }
{identifier}                            { yylval = (int)strdup(yytext); return IDENT;             }
{illegalIdentifier}                     { printf("\nLEXICAL ERROR on character %d (line %d): Illegal Identifier\n\n", yytext[0], line);   }


"/*"                                    {
                                             int isComment = 1;
                                             char c;
                                             while(isComment) {
                                                  c = input();
                                                  if(c == '*') {
                                                       char ch = input();
                                                       if(ch == '/') isComment = 0;
                                                       else unput(ch);
                                                  }
                                                  else if(c == '\n') line++;
                                                  else if(c == EOF) {
                                                       printf("\nLEXICAL ERROR (line %d): Unterminated comment", line);
                                                       isComment = 0;
                                                  }
                                             }
                                        }

%%

int yywrap()
{
 return(1);
}