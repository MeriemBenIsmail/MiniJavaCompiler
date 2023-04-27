#ifndef CODEGENERATOR_H
#define CODEGENERATOR_H

// LDC : load constant
// LDV : load variable
// STORE : store value
// APPEL : function call 
// ENTREE : function entry
// SORTIE : function exit
// RETOUR : function return
static char * code_op [] = { "LDC", "LDV", "STORE", "APPEL", "ENTREE", "SORTIE", "RETOUR", "ADD", "MUL", "DIV",
                            "SUB", "INF", "INFE", "SUP", "SUPE", "DIF", "EGAL"};

typedef struct entree_code {
    char* code_op;                                        // Code name
    int operande;                                         // value
    char* function_name;      
    char* designation;                   // function name
} ENTREE_CODE;



int  addCodeLine (char *code_op, int operande, char *function_name, char* designation);

int  addCodeVariable (char *code_op, char* name);

int  addCodeLDV (char *code_op, char* name);



int   getNextCode(void);

int   getLastCode(void);


void  verifCode(void);

void  ifElseChange(void);



void print_codetab(void);


#endif