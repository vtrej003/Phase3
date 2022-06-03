#pragma once
#include<vector>
#include<string>
#include<stack>
#include<queue>
// Write your class definition here
//
//

enum Type { Integer, Array };

struct Symbol 
{
  std::string name;
  Type type;
  int size;
  int value;
  
};


struct Function 
{
  std::string name;
  std::vector<Symbol> declarations;
};

class SymbolTable
{
    public:
	SymbolTable(){};

        Function *get_function();

        bool find(std::string &value, Type t);

        void add_function_to_symbol_table(std::string &value);

        void add_variable_to_symbol_table(std::string &name, Type t, int value, int size);

        void print_symbol_table(void);

    private:
	std::vector <Function> symbol_table;
};

struct Terminals
{
    std::queue<std::string> params;
    std::stack<std::string> idents;
    std::stack<std::string> functions;
    std::stack<std::string> vals;
    int paramCount, identCount, functionsCount, valsCounts = 0;
};
