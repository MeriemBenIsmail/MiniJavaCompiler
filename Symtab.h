#ifndef SYMTAB_H
#define SYMTAB_H

#define PARAM_NUMBER   5

static char *symbol_kinds[] = { "VARIABLE", "METHOD", "CLASS"};
static char *symbol_functions[] = { "DECLARATION", "PARAMETER", "INSTANTIATION","USE","ASSIGNMENT"};

extern int line;

typedef struct node {
    char* name;                                             // nom variable
    char* function;                                         
    char* kind;                                             // is global or not
    char* type;                                             // type / return type if method
    int initialized;                                        // is initialized or not 
    int level;                                              // variable  = local or global
    char* params_types[PARAM_NUMBER] ;                      // agrs type if function
    char* params_names[PARAM_NUMBER] ;                      // params if function
    int params_init[PARAM_NUMBER] ;                         // agrs init if function
    int param_index ;                                       //  current index
    int class_id;                                           // class id
    int line;

} NODE;

#define SYMBOL_TABLE_LENGTH 300

NODE symbol_table[SYMBOL_TABLE_LENGTH];


void verifMainFunction(void);

// node table modifications

int  addNode(char *name,char* function,char* kind, char* type,int level,int class_id);

int  removeParam(int index);

// selectors

int   getNextEmpty(void);

int   getLastElement(void);

// check

int  checkVariable(char* name,char* type,int level, int class_id);

int  checkClass(char* name,int class_id);

int  checkMethod(char* name,char* return_type,int class_id);

int  checkDeclaration(char *name,char* function, char* kind,int level, int class_id);

void insertCallParam(int index,char* val,char* type);
void setParam(char* name, char* type);

// visualization

void print_symtab(void);


#endif