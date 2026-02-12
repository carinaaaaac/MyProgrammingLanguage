#include "ASTnode.hpp"
#include <cstdlib>
extern SymbolTable* globalScope;

Value ASTNode::evaluate(SymbolTable* scope){
    //frunza
    if(!left && !right){

        if(label.size() >= 2 && label.front() == '"' && label.back() == '"'){
            return Value::String(label.substr(1, label.size() - 2));
        }
        if(label=="true") return Value::Bool(true);
        if(label=="false") return Value::Bool(false);

        if(!label.empty() && (isdigit(label[0]) || (label[0]=='-' && label.size()>1 ))){
            return Value::Int(stoi(label));
        }

        if(label.find('.')!=string::npos){
            return Value::Float(stof(label));
        }

        SymbolEntry* entry=scope->lookup(label);
        if(entry){
            if(entry->varType=="integer"){
                return Value::Int(stoi(entry->value));
            }
            else if(entry->varType=="float"){
                return Value::Float(stof(entry->value));
            }
            else if(entry->varType=="bool"){
                return Value::Bool(entry->value=="true");
            }
            else if(entry->varType=="text"){
                return Value::String(entry->value);
            }

            return Value();
        }
    }

    if(label == "dot"){
        SymbolEntry* objEntry = scope->lookup(left->label);
        if(!objEntry) return Value::Error();
        SymbolEntry* member = globalScope->lookupMember(objEntry->varType, right->label);
        if(!member) return Value::Error();
        if(member->varType=="integer"){
            return Value::Int(stoi(member->value));
        }
        else if(member->varType=="float"){
            return Value::Float(stof(member->value));
        }
        else if(member->varType=="bool"){
            return Value::Bool(member->value=="true");
        }
        else if(member->varType=="text"){
            return Value::String(member->value);
        }
        return Value::Error();
    }

    if(label==":="){
        Value v= right->evaluate(scope);
        if(left->label == "dot"){
            SymbolEntry* objEntry = scope->lookup(left->left->label);
            if(objEntry){
                SymbolEntry* member = globalScope->lookupMember(objEntry->varType, left->right->label);
                if(member){
                    if(v.type==ValueType::INT) member->value=to_string(v.intValue);
                    else if(v.type==ValueType::FLOAT) member->value=to_string(v.floatValue);
                    else if(v.type==ValueType::BOOL) member->value=(v.boolValue ? "true" : "false");
                    else if(v.type==ValueType::STRING) member->value=v.stringValue;
                }
            }
        } else {
            SymbolEntry* entry=scope->lookup(left->label);
            if(entry){
                if(v.type==ValueType::INT) entry->value=to_string(v.intValue);
                else if(v.type==ValueType::FLOAT) entry->value=to_string(v.floatValue);
                else if(v.type==ValueType::BOOL) entry->value=(v.boolValue ? "true" : "false");
                else if(v.type==ValueType::STRING) entry->value=v.stringValue;
            }
        }
        return v;
    }

    if(label=="Print"){
        Value v = left->evaluate(scope);
        v.print();
        cout<<"\n";
        return v;
    }

    if(label=="uminus" ){
        Value v=left->evaluate(scope);
        if(v.type==ValueType::INT) return Value::Int(-v.intValue);
        if(v.type==ValueType::FLOAT) return Value::Float(-v.floatValue);
        return Value::Error();
    }

    if(label=="not" && left && !right){
        Value v=left->evaluate(scope);
        if(v.type==ValueType::BOOL) return Value::Bool(!v.boolValue);
        return Value::Error();
    }

    Value a=left->evaluate(scope);
    Value b=right->evaluate(scope);

    if(label=="+") {
        if(a.type==ValueType::FLOAT || b.type==ValueType::FLOAT){
            float af = (a.type==ValueType::FLOAT) ? a.floatValue : static_cast<float>(a.intValue);
            float bf = (b.type==ValueType::FLOAT) ? b.floatValue : static_cast<float>(b.intValue);
            return Value::Float(af + bf);
        }
        return Value::Int(a.intValue + b.intValue);
    }
    if(label=="-") {
        if(a.type==ValueType::FLOAT || b.type==ValueType::FLOAT){
            float af = (a.type==ValueType::FLOAT) ? a.floatValue : static_cast<float>(a.intValue);
            float bf = (b.type==ValueType::FLOAT) ? b.floatValue : static_cast<float>(b.intValue);
            return Value::Float(af - bf);
        }
        return Value::Int(a.intValue - b.intValue);
    }
    if(label=="*") {
        if(a.type==ValueType::FLOAT || b.type==ValueType::FLOAT){
            float af = (a.type==ValueType::FLOAT) ? a.floatValue : static_cast<float>(a.intValue);
            float bf = (b.type==ValueType::FLOAT) ? b.floatValue : static_cast<float>(b.intValue);
            return Value::Float(af * bf);
        }
        return Value::Int(a.intValue * b.intValue);
    }
    if(label=="/") {
        if(a.type==ValueType::FLOAT || b.type==ValueType::FLOAT){
            float af = (a.type==ValueType::FLOAT) ? a.floatValue : static_cast<float>(a.intValue);
            float bf = (b.type==ValueType::FLOAT) ? b.floatValue : static_cast<float>(b.intValue);
            return Value::Float(af / bf);
        }
        return Value::Int(a.intValue / b.intValue);}
    if(label=="<") return Value::Bool(a.intValue < b.intValue);
    if(label==">") return Value::Bool(a.intValue > b.intValue);
    if(label=="==") return Value::Bool(a.intValue == b.intValue);
    if(label=="and") return Value::Bool(a.boolValue && b.boolValue);
    if(label=="or") return Value::Bool(a.boolValue || b.boolValue);
    return Value::Error();
}