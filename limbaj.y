%code requires {
  #include <iostream>
  #include <string>
  #include <vector>
  using namespace std;
  #include "symbol_table.hpp"
  #include "ASTnode.hpp"

  struct ExprInfo {
     ASTNode* node;
     string* type;
  };
  static void freeExpr(ExprInfo* e) {
     if(!e) return;
     delete e->node;
     delete e->type;
     delete e;
}
}

%{
#include <iostream>
#include <fstream>
#include <cstdlib>
#include "symbol_table.hpp"
#include "ASTnode.hpp"
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
extern int yylex();
void yyerror(const char * s);
int errorCount = 0;

SymbolTable* globalScope=nullptr;
SymbolTable* currentScope=nullptr;

%}

%union {
     ExprInfo* Expr;
     string* Str;
     int Int;
     float Float;
     vector<Parameter>* Params;
}

%token BPROGRAM EPROGRAM 
%token BMAIN EMAIN
%token ASSIGN 
%token BIF THEN ELSE EIF 
%token BWHILE DO EWHILE
%token BFOR FROM TO EFOR
%token TRUE FALSE
%token AND OR NOT
%token EQ NEQ LE GE LT GT 
%token PLUS MINUS MUL DIV 
%token BCLASS ECLASS PRIVATE PUBLIC PROTECTED 
%token NEW RETURN 
%token DOT COMMA
%token LEFTP RIGHTP LEFTB RIGHTB
%token PRINT
%token<Str> ID TYPE STRING_S
%token<Int> INT_NR
%token<Float> FLOAT_NR 

%type<Expr> expression
%type<Expr> bool_expression
%type<Expr> function_call
%type<Params> call_parametres
%type<Params> list_param

%start program

%left OR 
%left AND
%right NOT
%left EQ NEQ LT LE GT GE
%left PLUS MINUS
%left MUL DIV
%right UMINUS

%%
program : BPROGRAM global_declarations main_block EPROGRAM {if (errorCount == 0) cout<< "The program is correct!" << endl;}
      ;

global_declarations :  decl { currentScope=globalScope; }
	      |  global_declarations decl   
	      ;

decl       :  TYPE ID ';' {   if(currentScope->lookupLocal(*$2) != nullptr){
                                   cout<<"Eroare de semantica: variabila '"<<*$2<<"' este deja declarata la linia "<<yylineno<<endl;
                                   errorCount++;
                              }
                              else
                              {
                                   currentScope->addVariable(*$2,*$1,"-");
                              }
                              delete $1;
                              delete $2;
                          }
               | TYPE ID LEFTP RIGHTP ';' 
               {
                    if(currentScope->lookupLocal(*$2)){
                    cout<<"Eroare de semantica: functia '"<<*$2<<"' este deja declarata la linia "<<yylineno<<endl;
                    errorCount++;
                    } 
                    else {
                         vector<Parameter> params; 
                         currentScope->addFunction(*$2, *$1, params);
                         
                         delete $1;
                         delete $2;
                         }
          }
              | TYPE ID LEFTP list_param RIGHTP ';'
               {
                    if(currentScope->lookupLocal(*$2)){
                                   cout<<"Eroare de semantica: functia '"<<*$2<<"' este deja declarata la linia "<<yylineno<<endl;
                                   errorCount++;
                              }
                    else
                    {
                         vector<Parameter> params = *$4;

                         currentScope->addFunction(*$2, *$1, params);
                         delete $4;
                    }
                    delete $1;
                    delete $2;
               }
               | TYPE ID LEFTP RIGHTP LEFTB 
               {
                     if(currentScope->lookupLocal(*$2)){
                         cout<<"Eroare de semantica: functia '"<<*$2<<"' este deja declarata la linia "<<yylineno<<endl;
                         errorCount++;
                    } 
                    else {
                         vector<Parameter> params;
                         currentScope->addFunction(*$2, *$1, params);
                         currentScope=currentScope->createChild("function "+*$2);
                         delete $1;
                         delete $2;
                         }
               }
               list RIGHTB  
               {
                    if(currentScope)
                         currentScope=currentScope->getParent();
               }
               | TYPE ID  LEFTP list_param RIGHTP LEFTB 
               {
                     if(currentScope->lookupLocal(*$2)){
                                   cout<<"Eroare de semantica: functia '"<<*$2<<"' este deja declarata la linia "<<yylineno<<endl;
                                   errorCount++;
                              }
                    else
                    {
                         vector<Parameter> params = *$4;

                         currentScope->addFunction(*$2, *$1, params);

                         currentScope = currentScope->createChild("function " + *$2);

                         for (const auto& p : params) {
                              currentScope->addVariable(p.name, p.type, "-");
                         }

                         delete $1;
                         delete $2;
                         delete $4;
                    }
               }
               list RIGHTB
               {
                   currentScope=currentScope->getParent();
               }
               
              | BCLASS ID 
               {
                    if(currentScope->lookupLocal(*$2)){
                                   cout<<"Eroare de semantica: clasa '"<<*$2<<"' este deja declarata la linia "<<yylineno<<endl;
                                   errorCount++;
                              }
                    else
                    {
                         currentScope->addClass(*$2);
                         currentScope=currentScope->createChild("class "+*$2);
                    }
               }
               LEFTB class_body RIGHTB ECLASS 
               {
                    currentScope=currentScope->getParent();
                    delete $2;
                    
               }
               | ID ID ';'
               {
                    if(!globalScope->lookup(*$1) || globalScope->lookup(*$1)->kind != SymbolKind::Class) {
                         cout << "Eroare de semantica: clasa '" << *$1 << "' nedeclarata la linia " << yylineno << endl;
                         errorCount++;
                    } 
                    else if(currentScope->lookupLocal(*$2)){
                         cout<<"Eroare de semantica: obiectul '"<<*$2<<"' este deja declarat la linia "<<yylineno<<endl;
                         errorCount++;
                    }
                    else
                    {
                         currentScope->addVariable(*$2,*$1,"object");
                         delete $1;
                         delete $2;
                    }
               }
           ;

list_param : TYPE ID 
               {
                    //cout << currentScope->getName() << endl;
                    $$=new vector<Parameter>();
                    $$->push_back({*$1,*$2});
                    delete $1;
                    delete $2;
               }
            | list_param COMMA TYPE ID
               {
                    //cout << currentScope->getName() << endl;
                    $$=$1;
                    $$->push_back({*$3,*$4});
                    delete $3;
                    delete $4;
               }
            ;
            

      
class_body : class_body class_member | class_member ;

class_member : TYPE ID ';'
               {
                    currentScope->addVariable(*$2,*$1,"-");
                    delete $1;
                    delete $2;
               }
               
              | TYPE ID LEFTP list_param RIGHTP ';'
               {
                    vector<Parameter> params=*$4;

                    currentScope->addFunction(*$2, *$1, params);

                    /*SymbolTable* saved=currentScope;
                    currentScope=currentScope->createChild("function "+*$2);

                    for(const auto& p : params) {
                         currentScope->addVariable(p.name, p.type, "-");
                    }
                    currentScope=saved;*/

                    delete $1;
                    delete $2;
                    delete $4;
               }
              
              | acces_specifier TYPE ID ';'
               {
                    currentScope->addVariable(*$3,*$2,"-");
                    delete $2;
                    delete $3;
               }
               
              | acces_specifier TYPE ID LEFTP list_param RIGHTP ';'
                 {
                    currentScope->addFunction(*$3, *$2, *$5);
                    delete $2;
                    delete $3;
                 }
              | acces_specifier TYPE ID LEFTP RIGHTP LEFTB 
              {
                    vector<Parameter> params;
                    currentScope->addFunction(*$3, *$2, params);
                    currentScope=currentScope->createChild("function "+*$3);
                    delete $2;
                    delete $3;
              }
              list RIGHTB
                 {
                    if(currentScope)
                         currentScope=currentScope->getParent();
                 }
              | acces_specifier TYPE ID LEFTP list_param RIGHTP LEFTB 
              {
                    vector<Parameter> params = *$5;

                         currentScope->addFunction(*$3, *$2, params);

                         currentScope = currentScope->createChild("function " + *$3);

                         for (const auto& p : params) {
                              currentScope->addVariable(p.name, p.type, "-");
                         }
                    delete $2;
                    delete $3;
                    delete $5;
              }
              list RIGHTB
                 {
                    if(currentScope)
                         currentScope=currentScope->getParent();
                 }
              | acces_specifier TYPE ID LEFTP RIGHTP ';'
                 {
                    currentScope->addFunction(*$3, *$2, {});
                    delete $2;
                    delete $3;
                 }
              ;

acces_specifier: PRIVATE
                | PUBLIC
                | PROTECTED
                ;

main_block : BMAIN list EMAIN
     ;
     

list :  statement  
     | list statement 
     ;

statement: assign
         | decl
         | function_call 	 
         | if_statement 
         | while_statement
         | for_statement
         | print_statement 
         | return_statement
         ;
     
assign : ID ASSIGN expression ';'
          {
               auto* entry=currentScope->lookup(*$1);
               if(!entry){
                    cout<<"Eroare de semantica: variabila '"<<*$1<<"' nedeclarata la linia "<<yylineno<<endl;
                    errorCount++;
               }
               else if(*($3->type) != entry->varType){
                    cout<<"Eroare de semantica: asignare de tip incompatibil pentru variabila '"<<*$1<<"' la linia "<<yylineno<<endl;
                   // cout << "Tip variabila: " << entry->varType << ", tip expresie: " << *($3->type) << endl;
                    errorCount++;
               }

               ASTNode* root=new ASTNode(":=", new ASTNode(*$1), $3->node);
               $3->node=nullptr;
               root->evaluate(currentScope);
               delete root;
               delete $1;
               freeExpr($3);
          }
          | ID ASSIGN bool_expression ';'
          {
               auto* entry=currentScope->lookup(*$1);
               if(!entry){
                    cout<<"Eroare de semantica: variabila '"<<*$1<<"' nedeclarata la linia "<<yylineno<<endl;
                    errorCount++;
               }
               else if(*($3->type) != entry->varType){
                    cout<<"Eroare de semantica: asignare de tip incompatibil pentru variabila '"<<*$1<<"' la linia "<<yylineno<<endl;
                    errorCount++;
               }

               ASTNode* root=new ASTNode(":=", new ASTNode(*$1), $3->node);
               $3->node=nullptr;
               root->evaluate(currentScope);
               delete root;
               delete $1;
               freeExpr($3);
          }
          | ID DOT ID ASSIGN expression ';'
          {
               SymbolEntry* obj=currentScope->lookup(*$1);
               if(!obj)
               {
                    cout<<"Eroare de semantica: obiectul "<<*$1<<" nedeclarat la linia "<<yylineno<<endl;
                    errorCount++;
               }
               else
               {
                    SymbolEntry* member=globalScope->lookupMember(obj->varType, *$3);
                    if(!member)
                    {
                         cout<<"Eroare de semantica: clasa "<<obj->varType<<" nu are niciun membru "<<*$3<<" la linia "<<yylineno<<endl;
                         errorCount++;
                    }
                    else if(*($5->type) != member->varType)
                    {
                         cout<<"Eroare de semantica: asignare de tip incompatibil pentru membrul "<<*$3<<" al clasei "<<obj->varType<<" la linia "<<yylineno<<endl;
                         errorCount++;
                    }
                    else
                    {
                         ASTNode* memberNode = new ASTNode("dot", new ASTNode(*$1), new ASTNode(*$3));
                         ASTNode* root=new ASTNode(":=", memberNode, $5->node);
                         $5->node=nullptr;
                         root->evaluate(currentScope);
                         delete root;
                    }
               }
               delete $1;
               delete $3;
               freeExpr($5);
          }
        ;  




function_call
    : ID LEFTP call_parametres RIGHTP
      {
           SymbolEntry* entry = currentScope->lookup(*$1);
           if(!entry || entry->kind != SymbolKind::Function){
                cout<<"Eroare de semantica: functia '"<<*$1<<"' nedeclarata la linia "<<yylineno<<endl;
                errorCount++;
                $$ = new ExprInfo{ new ASTNode("error"), new string("error") };
           } else {
                if(entry->params.size() != $3->size()){
                    cout<<"Eroare de semantica: numar incorect de parametrii pentru functia '"<<*$1<<"' la linia "<<yylineno<<endl;
                    errorCount++;
                    $$ = new ExprInfo{ new ASTNode("error"), new string("error") };
                } else {
                    bool ok = true;
                    for(size_t i=0; i<entry->params.size(); i++){
                         if(entry->params[i].type != (*$3)[i].type){
                              cout<<"Eroare de semantica: tip de parametru incorect pentru parametrul "<<i+1<<" al functiei '"<<*$1<<"' la linia "<<yylineno<<endl;
                              errorCount++;
                              ok = false;
                         }
                    }
                    if(ok) $$ = new ExprInfo{ new ASTNode(*$1), new string(entry->returnType) };
                    else   $$ = new ExprInfo{ new ASTNode("error"), new string("error") };
                }
           }
           delete $1;
           delete $3;
      }
    | ID DOT ID LEFTP call_parametres RIGHTP
      {
           SymbolEntry* obj = currentScope->lookup(*$1);
           if(!obj){
                cout<<"Eroare de semantica: obiectul "<<*$1<<" nedeclarat la linia "<<yylineno<<endl;
                errorCount++;
                $$ = new ExprInfo{ new ASTNode("error"), new string("error") };
           } else {
                SymbolEntry* member = globalScope->lookupMember(obj->varType, *$3);
                if(!member || member->kind != SymbolKind::Function){
                     cout<<"Eroare de semantica: metoda '"<<*$3<<"' nedeclarata in clasa "<<obj->varType<<" la linia "<<yylineno<<endl;
                     errorCount++;
                     $$ = new ExprInfo{ new ASTNode("error"), new string("error") };
                } else {
                     if(member->params.size() != $5->size()){
                          cout<<"Eroare de semantica: numar incorect de parametrii pentru metoda '"<<*$3<<"' la linia "<<yylineno<<endl;
                          errorCount++;
                          $$ = new ExprInfo{ new ASTNode("error"), new string("error") };
                     } else {
                          bool ok = true;
                          for(size_t i=0;i<member->params.size();i++){
                               if(member->params[i].type != (*$5)[i].type){
                                    cout<<"Eroare de semantica: tip de parametru incorect pentru parametrul "<<i+1<<" al metodei '"<<*$3<<"' la linia "<<yylineno<<endl;
                                    errorCount++;
                                    ok = false;
                               }
                          }
                          if(ok) $$ = new ExprInfo{ new ASTNode(*$1 + string(".") + *$3), new string(member->returnType) };
                          else   $$ = new ExprInfo{ new ASTNode("error"), new string("error") };
                     }
                }
           }
           delete $1;
           delete $3;
           delete $5;
      }
    ;

if_statement: BIF bool_expression THEN statement EIF ';'
               {freeExpr($2); }
               | BIF bool_expression THEN list ELSE list EIF ';'
               {freeExpr($2);}
               ;

for_statement : BFOR ID FROM expression TO expression DO list EFOR ';'
               {
                    delete $2;
                    freeExpr($4);
                    freeExpr($6);
               }          
          ;

print_statement: PRINT LEFTP expression RIGHTP ';'
               {
                    ASTNode* root=new ASTNode("Print", $3->node, nullptr);
                    $3->node=nullptr;
                    root->evaluate(currentScope);
                    delete root;
                    freeExpr($3);
               }
               | PRINT LEFTP bool_expression RIGHTP ';'
               {
                    ASTNode* root=new ASTNode("Print", $3->node, nullptr);
                    $3->node=nullptr;
                    root->evaluate(currentScope);
                    delete root;
                    freeExpr($3);
               }
               ;

return_statement: RETURN expression ';'{
                    SymbolEntry* f=currentScope->getParentFunction();
                    if(f && f->varType == "void"){
                         cout<<"Eroare de semantica: return intr-o functie void la linia "<<yylineno<<endl;
                         errorCount++;
                    }
                    freeExpr($2);
                    }
                    | RETURN ';' {
                    SymbolEntry* f=currentScope->getParentFunction();
                    if(f && f->varType != "void"){
                         cout<<"Eroare de semantica: return fara valoare intr-o functie non-void la linia "<<yylineno<<endl;
                         errorCount++;
                         }
                    }
                    ;

call_parametres : expression{
                    $$ = new vector<Parameter>();
                    Parameter p;
                    p.type=*($1->type);
                    p.name="";
                    $$->push_back(p);
                    freeExpr($1);
}
           | call_parametres COMMA expression{
                    $$ = $1;
                    Parameter p;
                    p.type=*($3->type);
                    p.name="";
                    $$->push_back(p);
                    freeExpr($3);
           }
           ;

expression: INT_NR { $$=new ExprInfo{new ASTNode(to_string($1)), new string("integer")};}
          | FLOAT_NR { $$ = new ExprInfo{new ASTNode(to_string($1)), new string("float")};}
          | STRING_S { $$ = new ExprInfo{new ASTNode("\"" + *$1 + "\""), new string("text")}; delete $1;}
          | TRUE { $$ = new ExprInfo{new ASTNode("true"), new string("bool")};}
          | FALSE { $$ = new ExprInfo{new ASTNode("false"), new string("bool")};}
          | ID {
               if(!currentScope->lookup(*$1)){
                    cout<<"Eroare de semantica: '"<<*$1<<"' nedeclarat la linia "<<yylineno<<endl;
                    errorCount++;
                    $$ = new ExprInfo{new ASTNode(*$1), new string("error")};
               }
               else{
                    SymbolEntry* entry=currentScope->lookup(*$1);
                    $$ = new ExprInfo{new ASTNode(*$1), new string(entry->varType)};
               }
               delete $1;
               }
          | ID DOT ID
               {
                    SymbolEntry* obj=currentScope->lookup(*$1);
                    if(!obj)
                    {
                         cout<<"Eroare de semantica: obiectul "<<*$1<<" nedeclarat la linia "<<yylineno<<endl;
                         errorCount++;
                         $$ = new ExprInfo{new ASTNode("error"), new string("error")};
                    }
                    else
                    {
                         SymbolEntry* member=globalScope->lookupMember(obj->varType, *$3);
                         if(!member)
                         {
                              cout<<"Eroare de semantica: clasa "<<obj->varType<<" nu are niciun membru "<<*$3<<" la linia "<<yylineno<<endl;
                              errorCount++;
                              $$ = new ExprInfo{new ASTNode("error"), new string("error")};
                         }
                         else{
                              $$ = new ExprInfo{new ASTNode("dot", new ASTNode(*$1), new ASTNode(*$3)), new string(member->varType)};
                         }
                    }
                    delete $1;
                    delete $3;
               }
          | NEW ID 
               {
                    $$ = new ExprInfo{
        new ASTNode("new " + *$2),
        new string(*$2)
    };
                    delete $2;
               }
          | function_call {}
          | expression PLUS expression {
               if(*($1->type) != *($3->type)) {
                    cout<<"Eroare de semantica: tipuri incompatibile pentru operatorul '+' la linia "<<yylineno<<endl;
                    errorCount++;
                    $$ = new ExprInfo{ new ASTNode("+", $1->node, $3->node), new string("error") };               
               }
               else {
                    $$ = new ExprInfo{new ASTNode("+", $1->node, $3->node), new string (*($1->type))};
               }
               $1->node=nullptr;
               $3->node=nullptr;
               freeExpr($1);
               freeExpr($3);
          }
          | expression MINUS expression{
               if(*($1->type) != *($3->type)){
                    cout<<"Eroare de semantica: tipuri incompatibile pentru operatorul '-' la linia "<<yylineno<<endl;
                    errorCount++;
                    $$ = new ExprInfo{ new ASTNode("-", $1->node, $3->node), new string("error") };              
               }
               else{
                    $$ = new ExprInfo{ new ASTNode("-", $1->node, $3->node), new string(*($1->type)) };
               }
               $1->node=nullptr;
               $3->node=nullptr;
               freeExpr($1);
               freeExpr($3);
          }
          
          | MINUS expression %prec UMINUS 
          { 
               if(*($2->type)!="integer" && *($2->type)!="float"){
                    cout<<"Eroare de semantica: unary '-' pe tip invalid la linia "<<yylineno<<endl;
                    errorCount++;
                    $$ = new ExprInfo{ new ASTNode("uminus", $2->node, nullptr), new string("error") };
               }
               else {
                    $$=new ExprInfo{new ASTNode("uminus", $2->node, nullptr), new string(*($2->type))};
               }
               $2->node=nullptr;
               freeExpr($2);
          }
          | expression MUL expression{
               if(*($1->type) != *($3->type)){
                    cout<<"Eroare de semantica: tipuri incompatibile pentru operatorul '*' la linia "<<yylineno<<endl;
                    errorCount++;
                    $$ = new ExprInfo{ new ASTNode("*", $1->node, $3->node), new string("error") };               
               }
               else{
                              $$ = new ExprInfo{ new ASTNode("*", $1->node, $3->node), new string(*($1->type)) };
               }
               $1->node=nullptr;
               $3->node=nullptr;
               freeExpr($1);
               freeExpr($3);
          }
          | expression DIV expression{
               if(*($1->type) != *($3->type)){
                    cout<<"Eroare de semantica: tipuri incompatibile pentru operatorul '/' la linia "<<yylineno<<endl;
                    errorCount++;
                    $$ = new ExprInfo{ new ASTNode("/", $1->node, $3->node), new string("error") };     
               }
               else {
                    $$ = new ExprInfo{ new ASTNode("/", $1->node, $3->node), new string(*($1->type)) };    
               }
               $1->node=nullptr;
               $3->node=nullptr;
               freeExpr($1);
               freeExpr($3);
          }
          | expression AND expression {
               if(*($1->type)!="bool" || *($3->type)!="bool"){
                    cout<<"Eroare de semantica: operator AND pe tip nebool la linia "<<yylineno<<endl;
                    errorCount++;
                    $$ = new ExprInfo{new ASTNode("and", $1->node, $3->node), new string("error")};
               } else {
                    $$ = new ExprInfo{new ASTNode("and", $1->node, $3->node), new string("bool")};
               }
               $1->node=nullptr; $3->node=nullptr;
               freeExpr($1); freeExpr($3);
          }
          | expression OR expression { 
               if(*($1->type)!="bool" || *($3->type)!="bool"){
                    cout<<"Eroare de semantica: operator OR pe tip nebool la linia "<<yylineno<<endl;
                    errorCount++;
                    $$ = new ExprInfo{new ASTNode("or", $1->node, $3->node), new string("error")};
               } else {
                    $$ = new ExprInfo{new ASTNode("or", $1->node, $3->node), new string("bool")};
               }
               $1->node=nullptr; $3->node=nullptr;
               freeExpr($1); freeExpr($3);
          }
          | LEFTP expression RIGHTP { $$ =$2;}
          | NOT expression { 
               if(*($2->type) != "bool"){
                    cout<<"Eroare de semantica: 'not' pe tip invalid la linia "<<yylineno<<endl;
                    errorCount++;
                    $$ = new ExprInfo{ new ASTNode("not", $2->node, nullptr), new string("error") };
               } else {
                    $$ = new ExprInfo{ new ASTNode("not", $2->node, nullptr), new string("bool") };
               }
               $2->node=nullptr;
               freeExpr($2);
          }
          ; 

while_statement: BWHILE bool_expression DO list EWHILE
               {freeExpr($2);}
               ;

bool_expression: expression EQ expression 
               {
                    $$=new ExprInfo{new ASTNode("==", $1->node, $3->node), new string("bool")};
                    $1->node=nullptr;
                    $3->node=nullptr;
                    freeExpr($1);
                    freeExpr($3);
               }
               | expression NEQ expression
               {
                    $$=new ExprInfo{new ASTNode("!=", $1->node, $3->node), new string("bool")};
                    $1->node=nullptr;
                    $3->node=nullptr;
                    freeExpr($1);
                    freeExpr($3);
               }
               | expression LT expression
               {
                    $$=new ExprInfo{new ASTNode("<", $1->node, $3->node), new string("bool")};
                    $1->node=nullptr;
                    $3->node=nullptr;
                    freeExpr($1);
                    freeExpr($3);
               }
               | expression LE expression
               {
                    $$=new ExprInfo{new ASTNode("<=", $1->node, $3->node), new string("bool")};
                    $1->node=nullptr;
                    $3->node=nullptr;
                    freeExpr($1);
                    freeExpr($3);
               }
               | expression GT expression
               {
                    $$=new ExprInfo{new ASTNode(">", $1->node, $3->node), new string("bool")};
                    $1->node=nullptr;
                    $3->node=nullptr;
                    freeExpr($1);
                    freeExpr($3);
               }
               | expression GE expression
               {
                    $$=new ExprInfo{new ASTNode(">=", $1->node, $3->node), new string("bool")};
                    $1->node=nullptr;
                    $3->node=nullptr;
                    freeExpr($1);
                    freeExpr($3);
               }
               | bool_expression AND bool_expression 
               {
                    $$=new ExprInfo{new ASTNode("and", $1->node, $3->node), new string("bool")};
                    $1->node=nullptr;
                    $3->node=nullptr;
                    freeExpr($1);
                    freeExpr($3);
               }
               | bool_expression OR bool_expression
               {
                    $$=new ExprInfo{new ASTNode("or", $1->node, $3->node), new string("bool")};
                    $1->node=nullptr;
                    $3->node=nullptr;
                    freeExpr($1);
                    freeExpr($3);
               }
               | NOT bool_expression
               {
                    $$=new ExprInfo{new ASTNode("not", $2->node, nullptr), new string("bool")};
                    $2->node=nullptr;
                    freeExpr($2);
               }
               | LEFTP bool_expression RIGHTP
               {
                    $$=$2;
               }
               ;

%%
void yyerror(const char * s){
     cout << "error:" << s << " at line: " << yylineno << endl;
}

int main(int argc, char** argv){
     yyin=fopen(argv[1],"r");

     globalScope=new SymbolTable("global", nullptr);
     currentScope=globalScope;
     yyparse();
     ofstream fout("tables.txt");
     if(fout.is_open()) {
          globalScope->printAll(fout);
          fout.close();
     }

     delete globalScope;
     return (errorCount == 0) ? 0 : 1;
}