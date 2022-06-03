#include "lib.h"

// Write your class implementation
//
Function* SymbolTable::get_function() 
{
    int last = symbol_table.size()-1;
    return &symbol_table[last];
}

bool SymbolTable::find(std::string &value, Type t) 
{
    Function *f = get_function();
    for(int i=0; i < f->declarations.size(); i++) 
    {
        Symbol *s = &f->declarations[i];
	if (s->name == value && s->type == t) 
	{
	    return true;
        }
    }
    return false;
}


void SymbolTable::add_function_to_symbol_table(std::string &value) 
{
    Function f;
    f.name = value;
    symbol_table.push_back(f);
}

void SymbolTable::add_variable_to_symbol_table(std::string &name, Type t, int value, int size) 
{
    Symbol s;
    s.name = name;
    s.type = t;
    s.value = value;
    s.size = size;
    
    Function *f = get_function();
    f->declarations.push_back(s);
}

void SymbolTable::print_symbol_table(void) 
{
    printf("symbol table:\n");
    printf("--------------------\n");
    for(int i=0; i<symbol_table.size(); i++) 
    {
        printf("function: %s\n", symbol_table[i].name.c_str());
        for(int j=0; j<symbol_table[i].declarations.size(); j++) 
        {
            printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
        }
    }
    printf("--------------------\n");
}
