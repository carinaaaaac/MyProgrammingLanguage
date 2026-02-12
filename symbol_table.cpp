#include "symbol_table.hpp"
using namespace std;

SymbolTable::SymbolTable(string scopeName, SymbolTable* parentScope): name(scopeName), parent(parentScope) {}

const string& SymbolTable::getName() const {
    return name;
}

SymbolTable* SymbolTable::getParent() const {
    return parent;
}

SymbolTable* SymbolTable::createChild(string childName) {
    children.push_back(make_unique<SymbolTable>(childName,this));
    return children.back().get();
}

void SymbolTable::addVariable(const string& varName, const string& type, const string& value) {
    SymbolEntry entry;
    entry.kind=SymbolKind::Variable;
    entry.name=varName;
    entry.varType=type;
    entry.value=value;

    locals.push_back(entry);
}

void SymbolTable::addFunction(const string &fName, const string& returnType, const vector<Parameter>& params) {
    SymbolEntry entry;
    entry.kind=SymbolKind::Function;
    entry.name=fName;
    entry.returnType=returnType;
    entry.params=params;
    
    locals.push_back(entry);
}

void SymbolTable::addClass(const string& cName) {
    SymbolEntry entry;
    entry.kind=SymbolKind::Class;
    entry.name=cName;
    locals.push_back(entry);
}

void SymbolTable::indent(ostream& out, int n) {
    for(int i=0;i<n;++i)
        out<<' ';
}

void SymbolTable::printAll(ostream &out, int indentLevel) const{
    indent(out,indentLevel);

    out<<"Scope: "<<name;
    if(parent!=nullptr) {
        out<<" (parent: "<<parent->getName()<<")";
    }
    out<<"\n";

    for(const auto& sym:locals) {
        indent(out, indentLevel+2);

        if (sym.kind==SymbolKind::Variable) {
            out<<"var "<<sym.name<<" : "<<sym.varType<<" = "<<sym.value<<"\n";
        }
        else if (sym.kind==SymbolKind::Function) {
            out<<"function "<<sym.name<<" -> "<<sym.returnType<<"(";

            for(size_t i=0;i<sym.params.size();++i) {
                out<<sym.params[i].type<<" "<<sym.params[i].name;
                if(i+1<sym.params.size())
                    out<<", ";
            }

            out<<")\n";
        }
        else if(sym.kind==SymbolKind::Class) {
            out<<"class "<<sym.name<<"\n";
        }
    }
    out<<"\n";

    for(const auto& child : children) {
        child->printAll(out, indentLevel+2);
    }
}
SymbolEntry* SymbolTable::lookupLocal(const string& name){
    for(auto& entry : locals){
        if(entry.name == name){
            return &entry;
        }
    }
    return nullptr;
}
SymbolEntry* SymbolTable::lookup(const string& name){
    for(SymbolTable* current=this; current!=nullptr; current=current->parent){
        SymbolEntry* entry = current->lookupLocal(name);
        if(entry != nullptr){
            return entry;
        }
    }
    return nullptr;
}
SymbolEntry* SymbolTable::lookupClass(const string& class_name){
    for(auto & entry : locals){
        if(entry.kind==SymbolKind::Class && entry.name==class_name){
            return &entry;
        }
    }
    return nullptr;
}
SymbolEntry* SymbolTable::lookupMember(const string& class_name, const string& member_name){
    for(auto& child : children){
        if(child->getName() == "class " + class_name){
            for(auto& entry : child->locals){
                if(entry.name == member_name){
                    return &entry;
                }
            }
        }
    }
    return nullptr;
}
SymbolEntry* SymbolTable::getParentFunction(){
    SymbolTable* scope= this;
    while(scope)
    {
        for(auto& entry : scope->locals){
            if(entry.kind == SymbolKind::Function){
                return &entry;
            }
        }
        scope=scope->parent;
    }
    return nullptr;
}