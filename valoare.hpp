#pragma once
#include <string>
#include <iostream>

using namespace std;

enum class ValueType{
    INT,
    FLOAT,
    BOOL,
    STRING,
    VOID,
    ERROR
};

class Value{
public:
    ValueType type;
    int intValue;
    float floatValue;
    bool boolValue;
    string stringValue;

    Value() : type(ValueType::VOID) {}
    static Value Int(int v){
        Value val;
        val.type=ValueType::INT;
        val.intValue=v;
        return val;
    }
    static Value Float(float v){
        Value val;
        val.type=ValueType::FLOAT;
        val.floatValue=v;
        return val;
    }
    static Value Bool(bool v){
        Value val;
        val.type=ValueType::BOOL;
        val.boolValue=v;
        return val;
    }
    static Value String(const string& v){
        Value val;
        val.type=ValueType::STRING;
        val.stringValue=v;
        return val; 
    }
    static Value Error(){
        Value val;
        val.type=ValueType::ERROR;
        return val;
    }

    void print() const {
        switch(type){
            case ValueType::INT:
                cout<<intValue;
                break;
            case ValueType::FLOAT:
                cout<<floatValue;
                break;
            case ValueType::BOOL:
                cout<<(boolValue ? "true" : "false");
                break;
            case ValueType::STRING:
                cout<<stringValue;
                break;
            case ValueType::VOID:
                cout<<"void";
                break;
            case ValueType::ERROR:
                cout<<"error";
                break;
        }
    }
};