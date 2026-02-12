#pragma once

#include<iostream>
#include<string>
#include<vector>
#include<utility>
#include<ostream>
#include<memory>

using namespace std;

struct Parameter {
    string type;
    string name;
};

enum class SymbolKind {
    Variable,
    Function,
    Class
};

struct SymbolEntry {
    SymbolKind kind;

    string name;

    string varType;
    string value;

    string returnType;
    vector<Parameter> params;
};

class SymbolTable {

    private:
        string name; //identifica scopul si permite afisarea clara : global, clasa, functie
        SymbolTable* parent; 
        vector<SymbolEntry> locals;
        vector<unique_ptr<SymbolTable>> children;

        static void indent(ostream &out, int n);

    public:
        explicit SymbolTable(string scopeName, SymbolTable* parentScope);

        const string& getName() const;
        SymbolTable* getParent() const;

        SymbolTable* createChild(string childName);
        void addVariable(const string& name, const string& type, const string& value="-");
        void addFunction(const string& name, const string& returnType, const vector<Parameter>& params);
        void addClass(const string& name);

        void printAll(ostream& out, int indent=0) const;
        SymbolEntry* lookup(const string& name);
        SymbolEntry* lookupLocal(const string& name);
        SymbolEntry* lookupClass(const string& class_name);
        SymbolEntry* lookupMember(const string& class_name, const string& member_name);
        SymbolEntry* getParentFunction();

};