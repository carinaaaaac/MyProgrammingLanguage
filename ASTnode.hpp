#pragma once
#include <string>
#include <memory>
#include "valoare.hpp"
#include "symbol_table.hpp"

class ASTNode {
public:
    string  label; //etichetele nodurilor
    unique_ptr<ASTNode> left;
    unique_ptr<ASTNode> right;

    ASTNode(string lbl) : label(lbl) {}
    ASTNode(string lbl, ASTNode* l, ASTNode* r) : label(lbl), left(l), right(r) {}
    Value evaluate(SymbolTable* currentScope);

};