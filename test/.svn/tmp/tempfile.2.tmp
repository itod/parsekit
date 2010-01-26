//
//  TDJavaScriptParser.m
//  TDParseKit
//
//  Created by Todd Ditchendorf on 3/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDJavaScriptParser.h"

@interface TDParser ()
- (void)setTokenizer:(TDTokenizer *)t;
@end

@interface TDJavaScriptParser ()
- (TDAlternation *)zeroOrOne:(TDParser *)p;
- (TDAlternation *)oneOrMore:(TDParser *)p;
@end

@implementation TDJavaScriptParser

- (id)init {
    if (self = [super initWithSubparser:self.elementParser]) {
        self.tokenizer = [TDTokenizer tokenizer];
        
        // JS supports scientific number notation (exponents like 4E+12 or 2.0e-42)
        tokenizer.numberState = [[[TDScientificNumberState alloc] init] autorelease];

        // Nums cannot end with '.' (e.g. 32. must be 32.0)
        tokenizer.numberState.allowsTrailingDot = NO;
        
        [tokenizer setTokenizerState:tokenizer.numberState from:'-' to:'-'];
        [tokenizer setTokenizerState:tokenizer.numberState from:'.' to:'.'];
        [tokenizer setTokenizerState:tokenizer.numberState from:'0' to:'9'];

        // Words can start with '_'
        [tokenizer setTokenizerState:tokenizer.wordState from:'_' to:'_'];

        // Words cannot contain '-'
        [tokenizer.wordState setWordChars:NO from:'-' to:'-'];

        // Comments
        tokenizer.commentState.reportsCommentTokens = YES;
        [tokenizer setTokenizerState:tokenizer.commentState from:'/' to:'/'];

        // single-line Comments
        [tokenizer.commentState addSingleLineStartMarker:@"//"];
        
        // multi-line Comments
        [tokenizer.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
        
        [tokenizer.symbolState add:@"||"];
        [tokenizer.symbolState add:@"&&"];
        [tokenizer.symbolState add:@"!="];
        [tokenizer.symbolState add:@"!=="];
        [tokenizer.symbolState add:@"=="];
        [tokenizer.symbolState add:@"==="];
        [tokenizer.symbolState add:@"<="];
        [tokenizer.symbolState add:@">="];
        [tokenizer.symbolState add:@"++"];
        [tokenizer.symbolState add:@"--"];
        [tokenizer.symbolState add:@"+="];
        [tokenizer.symbolState add:@"-="];
        [tokenizer.symbolState add:@"*="];
        [tokenizer.symbolState add:@"/="];
        [tokenizer.symbolState add:@"%="];
        [tokenizer.symbolState add:@"<<"];
        [tokenizer.symbolState add:@">>"];
        [tokenizer.symbolState add:@">>>"];
        [tokenizer.symbolState add:@"<<="];
        [tokenizer.symbolState add:@">>="];
        [tokenizer.symbolState add:@">>>="];
        [tokenizer.symbolState add:@"&="];
        [tokenizer.symbolState add:@"^="];
    }
    return self;
}


- (void)dealloc {    
    self.assignmentOpParser = nil;
    self.relationalOpParser = nil;
    self.equalityOpParser = nil;
    self.shiftOpParser = nil;
    self.incrementOpParser = nil;
    self.unaryOpParser = nil;
    self.multiplicativeOpParser = nil;
    self.programParser = nil;
    self.elementParser = nil;
    self.funcParser = nil;
    self.paramListOptParser = nil;
    self.paramListParser = nil;
    self.commaIdentifierParser = nil;
    self.compoundStmtParser = nil;
    self.stmtsParser = nil;
    self.stmtParser = nil;
    self.ifStmtParser = nil;
    self.ifElseStmtParser = nil;
    self.whileStmtParser = nil;
    self.forParenStmtParser = nil;
    self.forBeginStmtParser = nil;
    self.forInStmtParser = nil;
    self.breakStmtParser = nil;
    self.continueStmtParser = nil;
    self.withStmtParser = nil;
    self.returnStmtParser = nil;
    self.variablesOrExprStmtParser = nil;
    self.conditionParser = nil;
    self.forParenParser = nil;
    self.forBeginParser = nil;
    self.variablesOrExprParser = nil;
    self.varVariablesParser = nil;
    self.variablesParser = nil;
    self.commaVariableParser = nil;
    self.variableParser = nil;
    self.assignmentParser = nil;
    self.exprOptParser = nil;
    self.exprParser = nil;
    self.commaAssignmentExprParser = nil;
    self.assignmentExprParser = nil;
    self.assignmentOpConditionalExprParser = nil;
    self.conditionalExprParser = nil;
    self.ternaryExprParser = nil;
    self.orExprParser = nil;
    self.orAndExprParser = nil;
    self.andExprParser = nil;
    self.andBitwiseOrExprParser = nil;
    self.bitwiseOrExprParser = nil;
    self.pipeBitwiseXorExprParser = nil;
    self.bitwiseXorExprParser = nil;
    self.caretBitwiseAndExprParser = nil;
    self.bitwiseAndExprParser = nil;
    self.ampEqualityExprParser = nil;
    self.equalityExprParser = nil;
    self.equalityOpRelationalExprParser = nil;
    self.relationalExprParser = nil;
    self.relationalOpShiftExprParser = nil;
    self.shiftExprParser = nil;
    self.shiftOpAdditiveExprParser = nil;
    self.additiveExprParser = nil;
    self.plusOrMinusExprParser = nil;
    self.plusExprParser = nil;
    self.minusExprParser = nil;
    self.multiplicativeExprParser = nil;
    self.multiplicativeOpUnaryExprParser = nil;
    self.unaryExprParser = nil;
    self.unaryExpr1Parser = nil;
    self.unaryExpr2Parser = nil;
    self.unaryExpr3Parser = nil;
    self.unaryExpr4Parser = nil;
    self.unaryExpr5Parser = nil;
    self.unaryExpr6Parser = nil;
    self.constructorCallParser = nil;
    self.parenArgListOptParenParser = nil;
    self.memberExprParser = nil;
    self.memberExprExtParser = nil;
    self.dotMemberExprParser = nil;
    self.bracketMemberExprParser = nil;
    self.argListOptParser = nil;
    self.argListParser = nil;
    self.primaryExprParser = nil;
    self.parenExprParenParser = nil;

    self.funcLiteralParser = nil;
    self.arrayLiteralParser = nil;
    self.objectLiteralParser = nil;

    self.identifierParser = nil;
    self.stringParser = nil;
    self.numberParser = nil;

    self.ifParser = nil;
    self.elseParser = nil;
    self.whileParser = nil;
    self.forParser = nil;
    self.inParser = nil;
    self.breakParser = nil;
    self.continueParser = nil;
    self.withParser = nil;
    self.returnParser = nil;
    self.varParser = nil;
    self.deleteParser = nil;
    self.newParser = nil;
    self.thisParser = nil;
    self.falseParser = nil;
    self.trueParser = nil;
    self.nullParser = nil;
    self.undefinedParser = nil;
    self.voidParser = nil;
    self.typeofParser = nil;
    self.instanceofParser = nil;
    self.functionParser = nil;
    
    self.orParser = nil;
    self.andParser = nil;
    self.neParser = nil;
    self.isNotParser = nil;
    self.eqParser = nil;
    self.isParser = nil;
    self.leParser = nil;
    self.geParser = nil;
    self.plusPlusParser = nil;
    self.minusMinusParser = nil;
    self.plusEqParser = nil;
    self.minusEqParser = nil;
    self.timesEqParser = nil;
    self.divEqParser = nil;
    self.modEqParser = nil;
    self.shiftLeftParser = nil;
    self.shiftRightParser = nil;
    self.shiftRightExtParser = nil;
    self.shiftLeftEqParser = nil;
    self.shiftRightEqParser = nil;
    self.shiftRightExtEqParser = nil;
    self.andEqParser = nil;
    self.xorEqParser = nil;
    self.orEqParser = nil;
    
    self.openCurlyParser = nil;
    self.closeCurlyParser = nil;
    self.openParenParser = nil;
    self.closeParenParser = nil;
    self.openBracketParser = nil;
    self.closeBracketParser = nil;
    self.commaParser = nil;
    self.dotParser = nil;
    self.semiOptParser = nil;
    self.semiParser = nil;
    self.colonParser = nil;
    self.equalsParser = nil;
    self.notParser = nil;
    self.ltParser = nil;
    self.gtParser = nil;
    self.ampParser = nil;
    self.pipeParser = nil;
    self.caretParser = nil;
    self.tildeParser = nil;
    self.questionParser = nil;
    self.plusParser = nil;
    self.minusParser = nil;
    self.timesParser = nil;
    self.divParser = nil;
    self.modParser = nil;

    [super dealloc];
}


- (TDAlternation *)zeroOrOne:(TDParser *)p {
    TDAlternation *a = [TDAlternation alternation];
    [a add:[TDEmpty empty]];
    [a add:p];
    return a;
}


- (TDAlternation *)oneOrMore:(TDParser *)p {
    TDAlternation *s = [TDSequence sequence];
    [s add:p];
    [s add:[TDRepetition repetitionWithSubparser:p]];
    return s;
}


// assignmentOperator  = equals | plusEq | minusEq | timesEq | divEq | modEq | shiftLeftEq | shiftRightEq | shiftRightExtEq | andEq | xorEq | orEq;
- (TDCollectionParser *)assignmentOpParser {
    if (!assignmentOpParser) {
        self.assignmentOpParser = [TDAlternation alternation];
        assignmentOpParser.name = @"assignmentOperator";
        [assignmentOpParser add:self.equalsParser];
        [assignmentOpParser add:self.plusEqParser];
        [assignmentOpParser add:self.minusEqParser];
        [assignmentOpParser add:self.timesEqParser];
        [assignmentOpParser add:self.divEqParser];
        [assignmentOpParser add:self.modEqParser];
        [assignmentOpParser add:self.shiftLeftEqParser];
        [assignmentOpParser add:self.shiftRightEqParser];
        [assignmentOpParser add:self.shiftRightExtEqParser];
        [assignmentOpParser add:self.andEqParser];
        [assignmentOpParser add:self.orEqParser];
        [assignmentOpParser add:self.xorEqParser];
    }
    return assignmentOpParser;
}


// relationalOperator  = lt | gt | ge | le | instanceof;
- (TDCollectionParser *)relationalOpParser {
    if (!relationalOpParser) {
        self.relationalOpParser = [TDAlternation alternation];
        relationalOpParser.name = @"relationalOperator";
        [relationalOpParser add:self.ltParser];
        [relationalOpParser add:self.gtParser];
        [relationalOpParser add:self.geParser];
        [relationalOpParser add:self.leParser];
        [relationalOpParser add:self.instanceofParser];
    }
    return relationalOpParser;
}


// equalityOp    = eq | ne | is | isnot;
- (TDCollectionParser *)equalityOpParser {
    if (!equalityOpParser) {
        self.equalityOpParser = [TDAlternation alternation];;
        equalityOpParser.name = @"equalityOp";
        [equalityOpParser add:self.eqParser];
        [equalityOpParser add:self.neParser];
        [equalityOpParser add:self.isParser];
        [equalityOpParser add:self.isNotParser];
    }
    return equalityOpParser;
}


//shiftOp         = shiftLeft | shiftRight | shiftRightExt;
- (TDCollectionParser *)shiftOpParser {
    if (!shiftOpParser) {
        self.shiftOpParser = [TDAlternation alternation];
        shiftOpParser.name = @"shiftOp";
        [shiftOpParser add:self.shiftLeftParser];
        [shiftOpParser add:self.shiftRightParser];
        [shiftOpParser add:self.shiftRightExtParser];
    }
    return shiftOpParser;
}


//incrementOperator   = plusPlus | minusMinus;
- (TDCollectionParser *)incrementOpParser {
    if (!incrementOpParser) {
        self.incrementOpParser = [TDAlternation alternation];
        incrementOpParser.name = @"incrementOp";
        [incrementOpParser add:self.plusPlusParser];
        [incrementOpParser add:self.minusMinusParser];
    }
    return incrementOpParser;
}


//unaryOperator       = tilde | delete | typeof | void;
- (TDCollectionParser *)unaryOpParser {
    if (!unaryOpParser) {
        self.unaryOpParser = [TDAlternation alternation];
        unaryOpParser.name = @"unaryOp";
        [unaryOpParser add:self.tildeParser];
        [unaryOpParser add:self.deleteParser];
        [unaryOpParser add:self.typeofParser];
        [unaryOpParser add:self.voidParser];
    }
    return unaryOpParser;
}


// multiplicativeOperator = times | div | mod;
- (TDCollectionParser *)multiplicativeOpParser {
    if (!multiplicativeOpParser) {
        self.multiplicativeOpParser = [TDAlternation alternation];
        multiplicativeOpParser.name = @"multiplicativeOperator";
        [multiplicativeOpParser add:self.timesParser];
        [multiplicativeOpParser add:self.divParser];
        [multiplicativeOpParser add:self.modParser];
    }
    return multiplicativeOpParser;
}



// Program:
//           empty
//           Element Program
//
//program             = element*;
- (TDCollectionParser *)programParser {
    if (!programParser) {
        self.programParser = [TDRepetition repetitionWithSubparser:self.elementParser];
        programParser.name = @"program";
    }
    return programParser;
}


//  Element:
//           function Identifier ( ParameterListOpt ) CompoundStatement
//           Statement
//
//element             = func | stmt;
- (TDCollectionParser *)elementParser {
    if (!elementParser) {
        self.elementParser = [TDAlternation alternation];
        elementParser.name = @"element";
        [elementParser add:self.funcParser];
        [elementParser add:self.stmtParser];
    }
    return elementParser;
}


//func                = function identifier openParen paramListOpt closeParen compoundStmt;
- (TDCollectionParser *)funcParser {
    if (!funcParser) {
        self.funcParser = [TDSequence sequence];
        funcParser.name = @"func";
        [funcParser add:self.functionParser];
        [funcParser add:self.identifierParser];
        [funcParser add:self.openParenParser];
        [funcParser add:self.paramListOptParser];
        [funcParser add:self.closeParenParser];
        [funcParser add:self.compoundStmtParser];
    }
    return funcParser;
}


//  ParameterListOpt:
//           empty
//           ParameterList
//
//paramListOpt        = Empty | paramList;
- (TDCollectionParser *)paramListOptParser {
    if (!paramListOptParser) {
        self.paramListOptParser = [TDAlternation alternation];
        paramListOptParser.name = @"paramListOpt";
        [paramListOptParser add:[self zeroOrOne:self.paramListParser]];
    }
    return paramListOptParser;
}


//  ParameterList:
//           Identifier
//           Identifier , ParameterList
//
//paramList           = identifier commaIdentifier*;
- (TDCollectionParser *)paramListParser {
    if (!paramListParser) {
        self.paramListParser = [TDSequence sequence];
        paramListParser.name = @"paramList";
        [paramListParser add:self.identifierParser];
        [paramListParser add:[TDRepetition repetitionWithSubparser:self.commaIdentifierParser]];
    }
    return paramListParser;
}


//commaIdentifier     = comma identifier;
- (TDCollectionParser *)commaIdentifierParser {
    if (!commaIdentifierParser) {
        self.commaIdentifierParser = [TDSequence sequence];
        commaIdentifierParser.name = @"commaIdentifier";
        [commaIdentifierParser add:self.commaParser];
        [commaIdentifierParser add:self.identifierParser];
    }
    return commaIdentifierParser;
}


//  CompoundStatement:
//           { Statements }
//
//compoundStmt        = openCurly stmts closeCurly;
- (TDCollectionParser *)compoundStmtParser {
    if (!compoundStmtParser) {
        self.compoundStmtParser = [TDSequence sequence];
        compoundStmtParser.name = @"compoundStmt";
        [compoundStmtParser add:self.openCurlyParser];
        [compoundStmtParser add:self.stmtsParser];
        [compoundStmtParser add:self.closeCurlyParser];
    }
    return compoundStmtParser;
}


//  Statements:
//           empty
//           Statement Statements
//
//stmts               = stmt*;
- (TDCollectionParser *)stmtsParser {
    if (!stmtsParser) {
        self.stmtsParser = [TDRepetition repetitionWithSubparser:self.stmtParser];
        stmtsParser.name = @"stmts";
    }
    return stmtsParser;
}


//  Statement:
//           ;
//           if Condition Statement
//           if Condition Statement else Statement
//           while Condition Statement
//           ForParen ; ExpressionOpt ; ExpressionOpt ) Statement
//           ForBegin ; ExpressionOpt ; ExpressionOpt ) Statement
//           ForBegin in Expression ) Statement
//           break ;
//           continue ;
//           with ( Expression ) Statement
//           return ExpressionOpt ;
//           CompoundStatement
//           VariablesOrExpression ;
//
//stmt                = semi | ifStmt | ifElseStmt | whileStmt | forParenStmt | forBeginStmt | forInStmt | breakStmt | continueStmt | withStmt | returnStmt | compoundStmt | variablesOrExprStmt;
- (TDCollectionParser *)stmtParser {
    if (!stmtParser) {
        self.stmtParser = [TDAlternation alternation];
        stmtParser.name = @"stmt";
        [stmtParser add:self.semiParser];
        [stmtParser add:self.ifStmtParser];
        [stmtParser add:self.ifElseStmtParser];
        [stmtParser add:self.whileStmtParser];
        [stmtParser add:self.forParenStmtParser];
        [stmtParser add:self.forBeginStmtParser];
        [stmtParser add:self.forInStmtParser];
        [stmtParser add:self.breakStmtParser];
        [stmtParser add:self.continueStmtParser];
        [stmtParser add:self.withStmtParser];
        [stmtParser add:self.returnStmtParser];
        [stmtParser add:self.compoundStmtParser];
        [stmtParser add:self.variablesOrExprStmtParser];        
    }
    return stmtParser;
}


//           if Condition Statement
//ifStmt              = if condition stmt;
- (TDCollectionParser *)ifStmtParser {
    if (!ifStmtParser) {
        self.ifStmtParser = [TDSequence sequence];
        ifStmtParser.name = @"ifStmt";
        [ifStmtParser add:self.ifParser];
        [ifStmtParser add:self.conditionParser];
        [ifStmtParser add:self.stmtParser];
    }
    return ifStmtParser;
}


//           if Condition Statement else Statement
//ifElseStmt          = if condition stmt else stmt;
- (TDCollectionParser *)ifElseStmtParser {
    if (!ifElseStmtParser) {
        self.ifElseStmtParser = [TDSequence sequence];
        ifElseStmtParser.name = @"ifElseStmt";
        [ifElseStmtParser add:self.ifParser];
        [ifElseStmtParser add:self.conditionParser];
        [ifElseStmtParser add:self.stmtParser];
        [ifElseStmtParser add:self.elseParser];
        [ifElseStmtParser add:self.stmtParser];
    }
    return ifElseStmtParser;
}


//           while Condition Statement
//whileStmt           = while condition stmt;
- (TDCollectionParser *)whileStmtParser {
    if (!whileStmtParser) {
        self.whileStmtParser = [TDSequence sequence];
        whileStmtParser.name = @"whileStmt";
        [whileStmtParser add:self.whileParser];
        [whileStmtParser add:self.conditionParser];
        [whileStmtParser add:self.stmtParser];
    }
    return whileStmtParser;
}


//           ForParen ; ExpressionOpt ; ExpressionOpt ) Statement
//forParenStmt        = forParen semi exprOpt semi exprOpt closeParen stmt;
- (TDCollectionParser *)forParenStmtParser {
    if (!forParenStmtParser) {
        self.forParenStmtParser = [TDSequence sequence];
        forParenStmtParser.name = @"forParenStmt";
        [forParenStmtParser add:self.forParenParser];
        [forParenStmtParser add:self.semiParser];
        [forParenStmtParser add:self.exprOptParser];
        [forParenStmtParser add:self.semiParser];
        [forParenStmtParser add:self.exprOptParser];
        [forParenStmtParser add:self.closeParenParser];
        [forParenStmtParser add:self.stmtParser];
    }
    return forParenStmtParser;
}


//           ForBegin ; ExpressionOpt ; ExpressionOpt ) Statement
//forBeginStmt        = forBegin semi exprOpt semi exprOpt closeParen stmt;
- (TDCollectionParser *)forBeginStmtParser {
    if (!forBeginStmtParser) {
        self.forBeginStmtParser = [TDSequence sequence];
        forBeginStmtParser.name = @"forBeginStmt";
        [forBeginStmtParser add:self.forBeginParser];
        [forBeginStmtParser add:self.semiParser];
        [forBeginStmtParser add:self.exprOptParser];
        [forBeginStmtParser add:self.semiParser];
        [forBeginStmtParser add:self.exprOptParser];
        [forBeginStmtParser add:self.closeParenParser];
        [forBeginStmtParser add:self.stmtParser];
    }
    return forBeginStmtParser;
}


//           ForBegin in Expression ) Statement
//forInStmt           = forBegin in expr closeParen stmt;
- (TDCollectionParser *)forInStmtParser {
    if (!forInStmtParser) {
        self.forInStmtParser = [TDSequence sequence];
        forInStmtParser.name = @"forInStmt";
        [forInStmtParser add:self.forBeginParser];
        [forInStmtParser add:self.inParser];
        [forInStmtParser add:self.exprParser];
        [forInStmtParser add:self.closeParenParser];
        [forInStmtParser add:self.stmtParser];
    }
    return forInStmtParser;
}


//           break ;
//breakStmt           = break semi;
- (TDCollectionParser *)breakStmtParser {
    if (!breakStmtParser) {
        self.breakStmtParser = [TDSequence sequence];
        breakStmtParser.name = @"breakStmt";
        [breakStmtParser add:self.breakParser];
        [breakStmtParser add:self.semiOptParser];
    }
    return breakStmtParser;
}


//continueStmt        = continue semi;
- (TDCollectionParser *)continueStmtParser {
    if (!continueStmtParser) {
        self.continueStmtParser = [TDSequence sequence];
        continueStmtParser.name = @"continueStmt";
        [continueStmtParser add:self.continueParser];
        [continueStmtParser add:self.semiOptParser];
    }
    return continueStmtParser;
}


//           with ( Expression ) Statement
//withStmt            = with openParen expr closeParen stmt;
- (TDCollectionParser *)withStmtParser {
    if (!withStmtParser) {
        self.withStmtParser = [TDSequence sequence];
        withStmtParser.name = @"withStmt";
        [withStmtParser add:self.withParser];
        [withStmtParser add:self.openParenParser];
        [withStmtParser add:self.exprParser];
        [withStmtParser add:self.closeParenParser];
        [withStmtParser add:self.stmtParser];
    }
    return withStmtParser;
}


//           return ExpressionOpt ;
//returnStmt          = return exprOpt semi;
- (TDCollectionParser *)returnStmtParser {
    if (!returnStmtParser) {
        self.returnStmtParser = [TDSequence sequence];
        returnStmtParser.name = @"returnStmt";
        [returnStmtParser add:self.returnParser];
        [returnStmtParser add:self.exprOptParser];
        [returnStmtParser add:self.semiOptParser];
    }
    return returnStmtParser;
}


//           VariablesOrExpression ;
//variablesOrExprStmt = variablesOrExpr semi;
- (TDCollectionParser *)variablesOrExprStmtParser {
    if (!variablesOrExprStmtParser) {
        self.variablesOrExprStmtParser = [TDSequence sequence];
        variablesOrExprStmtParser.name = @"variablesOrExprStmt";
        [variablesOrExprStmtParser add:self.variablesOrExprParser];
        [variablesOrExprStmtParser add:self.semiOptParser];
    }
    return variablesOrExprStmtParser;
}


//  Condition:
//           ( Expression )
//
//condition           = openParen expr closeParen;
- (TDCollectionParser *)conditionParser {
    if (!conditionParser) {
        self.conditionParser = [TDSequence sequence];
        conditionParser.name = @"condition";
        [conditionParser add:self.openParenParser];
        [conditionParser add:self.exprParser];
        [conditionParser add:self.closeParenParser];
    }
    return conditionParser;
}


//  ForParen:
//           for (
//
//forParen            = for openParen;
- (TDCollectionParser *)forParenParser {
    if (!forParenParser) {
        self.forParenParser = [TDSequence sequence];
        forParenParser.name = @"forParen";
        [forParenParser add:self.forParser];
        [forParenParser add:self.openParenParser];
    }
    return forParenParser;
}


//  ForBegin:
//           ForParen VariablesOrExpression
//
//forBegin            = forParen variablesOrExpr;
- (TDCollectionParser *)forBeginParser {
    if (!forBeginParser) {
        self.forBeginParser = [TDSequence sequence];
        forBeginParser.name = @"forBegin";
        [forBeginParser add:self.forParenParser];
        [forBeginParser add:self.variablesOrExprParser];
    }
    return forBeginParser;
}


//  VariablesOrExpression:
//           var Variables
//           Expression
//
//variablesOrExpr     = varVariables | expr;
- (TDCollectionParser *)variablesOrExprParser {
    if (!variablesOrExprParser) {
        self.variablesOrExprParser = [TDAlternation alternation];
        variablesOrExprParser.name = @"variablesOrExpr";
        [variablesOrExprParser add:self.varVariablesParser];
        [variablesOrExprParser add:self.exprParser];
    }
    return variablesOrExprParser;
}


//varVariables        = var variables;
- (TDCollectionParser *)varVariablesParser {
    if (!varVariablesParser) {
        self.varVariablesParser = [TDSequence sequence];
        varVariablesParser.name = @"varVariables";
        [varVariablesParser add:self.varParser];
        [varVariablesParser add:self.variablesParser];
    }
    return varVariablesParser;
}


//  Variables:
//           Variable
//           Variable , Variables
//
//variables           = variable commaVariable*;
- (TDCollectionParser *)variablesParser {
    if (!variablesParser) {
        self.variablesParser = [TDSequence sequence];
        variablesParser.name = @"variables";
        [variablesParser add:self.variableParser];
        [variablesParser add:[TDRepetition repetitionWithSubparser:self.commaVariableParser]];
    }
    return variablesParser;
}


//commaVariable       = comma variable;
- (TDCollectionParser *)commaVariableParser {
    if (!commaVariableParser) {
        self.commaVariableParser = [TDSequence sequence];
        commaVariableParser.name = @"commaVariable";
        [commaVariableParser add:self.commaParser];
        [commaVariableParser add:self.variableParser];
    }
    return commaVariableParser;
}


//  Variable:
//           Identifier
//           Identifier = AssignmentExpression
//
//variable            = identifier assignment?;
- (TDCollectionParser *)variableParser {
    if (!variableParser) {
        self.variableParser = [TDSequence sequence];
        variableParser.name = @"variableParser";
        [variableParser add:self.identifierParser];
        [variableParser add:[self zeroOrOne:self.assignmentParser]];
    }
    return variableParser;
}


//assignment          = equals assignmentExpr;
- (TDCollectionParser *)assignmentParser {
    if (!assignmentParser) {
        self.assignmentParser = [TDSequence sequence];
        assignmentParser.name = @"assignment";
        [assignmentParser add:self.equalsParser];
        [assignmentParser add:self.assignmentExprParser];
    }
    return assignmentParser;
}


//  ExpressionOpt:
//           empty
//           Expression
//
//    exprOpt             = Empty | expr;
- (TDCollectionParser *)exprOptParser {
    if (!exprOptParser) {
        self.exprOptParser = [self zeroOrOne:self.exprParser];
        exprOptParser.name = @"exprOpt";
    }
    return exprOptParser;
}


//  Expression:
//           AssignmentExpression
//           AssignmentExpression , Expression
//
//expr                = assignmentExpr commaAssignmentExpr*;
- (TDCollectionParser *)exprParser {
    if (!exprParser) {
        self.exprParser = [TDSequence sequence];
        exprParser.name = @"exprParser";
        [exprParser add:self.assignmentExprParser];
        [exprParser add:[TDRepetition repetitionWithSubparser:self.commaAssignmentExprParser]];
    }
    return exprParser;
}


//commaAssignmentExpr           = comma assignmentExpr;
- (TDCollectionParser *)commaAssignmentExprParser {
    if (!commaAssignmentExprParser) {
        self.commaAssignmentExprParser = [TDSequence sequence];
        commaAssignmentExprParser.name = @"commaAssignmentExpr";
        [commaAssignmentExprParser add:self.commaParser];
        [commaAssignmentExprParser add:self.assignmentExprParser];
    }
    return commaAssignmentExprParser;
}


//  AssignmentExpression:
//           ConditionalExpression
//           ConditionalExpression AssignmentOperator AssignmentExpression
//
// assignmentExpr      = conditionalExpr assignmentOpConditionalExpr*;
- (TDCollectionParser *)assignmentExprParser {
    if (!assignmentExprParser) {
        self.assignmentExprParser = [TDSequence sequence];
        assignmentExprParser.name = @"assignmentExpr";
        [assignmentExprParser add:self.conditionalExprParser];
        [assignmentExprParser add:[TDRepetition repetitionWithSubparser:self.assignmentOpConditionalExprParser]];
    }
    return assignmentExprParser;
}


// assignmentOpConditionalExpr     = assignmentOperator conditionalExpr;
- (TDCollectionParser *)assignmentOpConditionalExprParser {
    if (!assignmentOpConditionalExprParser) {
        self.assignmentOpConditionalExprParser = [TDSequence sequence];
        assignmentOpConditionalExprParser.name = @"assignmentOpConditionalExpr";
        [assignmentOpConditionalExprParser add:self.assignmentOpParser];
        [assignmentOpConditionalExprParser add:self.conditionalExprParser];
    }
    return assignmentOpConditionalExprParser;
}


//  ConditionalExpression:
//           OrExpression
//           OrExpression ? AssignmentExpression : AssignmentExpression
//
//    conditionalExpr     = orExpr ternaryExpr?;
- (TDCollectionParser *)conditionalExprParser {
    if (!conditionalExprParser) {
        self.conditionalExprParser = [TDSequence sequence];
        conditionalExprParser.name = @"conditionalExpr";
        [conditionalExprParser add:self.orExprParser];
        [conditionalExprParser add:[self zeroOrOne:self.ternaryExprParser]];
    }
    return conditionalExprParser;
}


//    ternaryExpr         = question assignmentExpr colon assignmentExpr;
- (TDCollectionParser *)ternaryExprParser {
    if (!ternaryExprParser) {
        self.ternaryExprParser = [TDSequence sequence];
        ternaryExprParser.name = @"ternaryExpr";
        [ternaryExprParser add:self.questionParser];
        [ternaryExprParser add:self.assignmentExprParser];
        [ternaryExprParser add:self.colonParser];
        [ternaryExprParser add:self.assignmentExprParser];
    }
    return ternaryExprParser;
}


//  OrExpression:
//           AndExpression
//           AndExpression || OrExpression
//
//    orExpr              = andExpr orAndExpr*;
- (TDCollectionParser *)orExprParser {
    if (!orExprParser) {
        self.orExprParser = [TDSequence sequence];
        orExprParser.name = @"orExpr";
        [orExprParser add:self.andExprParser];
        [orExprParser add:[TDRepetition repetitionWithSubparser:self.orAndExprParser]];
    }
    return orExprParser;
}


//    orAndExpr           = or andExpr;
- (TDCollectionParser *)orAndExprParser {
    if (!orAndExprParser) {
        self.orAndExprParser = [TDSequence sequence];
        orAndExprParser.name = @"orAndExpr";
        [orAndExprParser add:self.orParser];
        [orAndExprParser add:self.andExprParser];
    }
    return orAndExprParser;
}


//  AndExpression:
//           BitwiseOrExpression
//           BitwiseOrExpression && AndExpression
//
//    andExpr             = bitwiseOrExpr andBitwiseOrExprParser*;
- (TDCollectionParser *)andExprParser {
    if (!andExprParser) {
        self.andExprParser = [TDSequence sequence];
        andExprParser.name = @"andExpr";
        [andExprParser add:self.bitwiseOrExprParser];
        [andExprParser add:[TDRepetition repetitionWithSubparser:self.andBitwiseOrExprParser]];
    }
    return andExprParser;
}


//    andBitwiseOrExprParser          = and bitwiseOrExpr;
- (TDCollectionParser *)andBitwiseOrExprParser {
    if (!andBitwiseOrExprParser) {
        self.andBitwiseOrExprParser = [TDSequence sequence];
        andBitwiseOrExprParser.name = @"andBitwiseOrExpr";
        [andBitwiseOrExprParser add:self.andParser];
        [andBitwiseOrExprParser add:self.bitwiseOrExprParser];
    }
    return andBitwiseOrExprParser;
}


//  BitwiseOrExpression:
//           BitwiseXorExpression
//           BitwiseXorExpression | BitwiseOrExpression
//
//    bitwiseOrExpr       = bitwiseXorExpr pipeBitwiseXorExpr*;
- (TDCollectionParser *)bitwiseOrExprParser {
    if (!bitwiseOrExprParser) {
        self.bitwiseOrExprParser = [TDSequence sequence];
        bitwiseOrExprParser.name = @"bitwiseOrExpr";
        [bitwiseOrExprParser add:self.bitwiseXorExprParser];
        [bitwiseOrExprParser add:[TDRepetition repetitionWithSubparser:self.pipeBitwiseXorExprParser]];
    }
    return bitwiseOrExprParser;
}


//    pipeBitwiseXorExprParser   = pipe bitwiseXorExpr;
- (TDCollectionParser *)pipeBitwiseXorExprParser {
    if (!pipeBitwiseXorExprParser) {
        self.pipeBitwiseXorExprParser = [TDSequence sequence];
        pipeBitwiseXorExprParser.name = @"pipeBitwiseXorExpr";
        [pipeBitwiseXorExprParser add:self.pipeParser];
        [pipeBitwiseXorExprParser add:self.bitwiseXorExprParser];
    }
    return pipeBitwiseXorExprParser;
}


//  BitwiseXorExpression:
//           BitwiseAndExpression
//           BitwiseAndExpression ^ BitwiseXorExpression
//
//    bitwiseXorExpr      = bitwiseAndExpr caretBitwiseAndExpr*;
- (TDCollectionParser *)bitwiseXorExprParser {
    if (!bitwiseXorExprParser) {
        self.bitwiseXorExprParser = [TDSequence sequence];
        bitwiseXorExprParser.name = @"bitwiseXorExpr";
        [bitwiseXorExprParser add:self.bitwiseAndExprParser];
        [bitwiseXorExprParser add:[TDRepetition repetitionWithSubparser:self.caretBitwiseAndExprParser]];
    }
    return bitwiseXorExprParser;
}


//    caretBitwiseAndExpr = caret bitwiseAndExpr;
- (TDCollectionParser *)caretBitwiseAndExprParser {
    if (!caretBitwiseAndExprParser) {
        self.caretBitwiseAndExprParser = [TDSequence sequence];
        caretBitwiseAndExprParser.name = @"caretBitwiseAndExpr";
        [caretBitwiseAndExprParser add:self.caretParser];
        [caretBitwiseAndExprParser add:self.bitwiseAndExprParser];
    }
    return caretBitwiseAndExprParser;
}


//  BitwiseAndExpression:
//           EqualityExpression
//           EqualityExpression & BitwiseAndExpression
//
//    bitwiseAndExpr      = equalityExpr ampEqualityExpr*;
- (TDCollectionParser *)bitwiseAndExprParser {
    if (!bitwiseAndExprParser) {
        self.bitwiseAndExprParser = [TDSequence sequence];
        bitwiseAndExprParser.name = @"bitwiseAndExpr";
        [bitwiseAndExprParser add:self.equalityExprParser];
        [bitwiseAndExprParser add:[TDRepetition repetitionWithSubparser:self.ampEqualityExprParser]];
    }
    return bitwiseAndExprParser;
}


//    ampEqualityExpression = amp equalityExpression;
- (TDCollectionParser *)ampEqualityExprParser {
    if (!ampEqualityExprParser) {
        self.ampEqualityExprParser = [TDSequence sequence];
        ampEqualityExprParser.name = @"ampEqualityExpr";
        [ampEqualityExprParser add:self.ampParser];
        [ampEqualityExprParser add:self.equalityExprParser];
    }
    return ampEqualityExprParser;
}


//  EqualityExpression:
//           RelationalExpression
//           RelationalExpression EqualityualityOperator EqualityExpression
//
//    equalityExpr        = relationalExpr equalityOpRelationalExpr*;
- (TDCollectionParser *)equalityExprParser {
    if (!equalityExprParser) {
        self.equalityExprParser = [TDSequence sequence];
        equalityExprParser.name = @"equalityExpr";
        [equalityExprParser add:self.relationalExprParser];
        [equalityExprParser add:[TDRepetition repetitionWithSubparser:self.equalityOpRelationalExprParser]];
    }
    return equalityExprParser;
}


//    equalityOpRelationalExpr = equalityOp relationalExpr;
- (TDCollectionParser *)equalityOpRelationalExprParser {
    if (!equalityOpRelationalExprParser) {
        self.equalityOpRelationalExprParser = [TDSequence sequence];
        equalityOpRelationalExprParser.name = @"equalityOpRelationalExpr";
        [equalityOpRelationalExprParser add:self.equalityOpParser];
        [equalityOpRelationalExprParser add:self.relationalExprParser];
    }
    return equalityOpRelationalExprParser;
}


//  RelationalExpression:
//           ShiftExpression
//           RelationalExpression RelationalationalOperator ShiftExpression
//

//    relationalExpr      = shiftExpr relationalOpShiftExpr*;       /// TODO ????
- (TDCollectionParser *)relationalExprParser {
    if (!relationalExprParser) {
        self.relationalExprParser = [TDSequence sequence];
        relationalExprParser.name = @"relationalExpr";
        [relationalExprParser add:self.shiftExprParser];
        [relationalExprParser add:[TDRepetition repetitionWithSubparser:self.relationalOpShiftExprParser]];
    }
    return relationalExprParser;
}


//    relationalOpShiftExpr   = relationalOperator shiftExpr;
- (TDCollectionParser *)relationalOpShiftExprParser {
    if (!relationalOpShiftExprParser) {
        self.relationalOpShiftExprParser = [TDSequence sequence];
        relationalOpShiftExprParser.name = @"relationalOpShiftExpr";
        [relationalOpShiftExprParser add:self.relationalOpParser];
        [relationalOpShiftExprParser add:self.shiftExprParser];
    }
    return relationalOpShiftExprParser;
}


//  ShiftExpression:
//           AdditiveExpression
//           AdditiveExpression ShiftOperator ShiftExpression
//
//    shiftExpr           = additiveExpr shiftOpAdditiveExpr?;
- (TDCollectionParser *)shiftExprParser {
    if (!shiftExprParser) {
        self.shiftExprParser = [TDSequence sequence];
        shiftExprParser.name = @"shiftExpr";
        [shiftExprParser add:self.additiveExprParser];
        [shiftExprParser add:[TDRepetition repetitionWithSubparser:self.shiftOpAdditiveExprParser]];
    }
    return shiftExprParser;
}


//    shiftOpShiftExpr    = shiftOp additiveExpr;
- (TDCollectionParser *)shiftOpAdditiveExprParser {
    if (!shiftOpAdditiveExprParser) {
        self.shiftOpAdditiveExprParser = [TDSequence sequence];
        shiftOpAdditiveExprParser.name = @"shiftOpShiftExpr";
        [shiftOpAdditiveExprParser add:self.shiftOpParser];
        [shiftOpAdditiveExprParser add:self.additiveExprParser];
    }
    return shiftOpAdditiveExprParser;
}


//  AdditiveExpression:
//           MultiplicativeExpression
//           MultiplicativeExpression + AdditiveExpression
//           MultiplicativeExpression - AdditiveExpression
//
//    additiveExpr        = multiplicativeExpr plusOrMinusExpr*;
- (TDCollectionParser *)additiveExprParser {
    if (!additiveExprParser) {
        self.additiveExprParser = [TDSequence sequence];
        additiveExprParser.name = @"additiveExpr";
        [additiveExprParser add:self.multiplicativeExprParser];
        [additiveExprParser add:[TDRepetition repetitionWithSubparser:self.plusOrMinusExprParser]];
    }
    return additiveExprParser;
}


//    plusOrMinusExpr     = plusExpr | minusExpr;
- (TDCollectionParser *)plusOrMinusExprParser {
    if (!plusOrMinusExprParser) {
        self.plusOrMinusExprParser = [TDAlternation alternation];
        plusOrMinusExprParser.name = @"plusOrMinusExpr";
        [plusOrMinusExprParser add:self.plusExprParser];
        [plusOrMinusExprParser add:self.minusExprParser];
    }
    return plusOrMinusExprParser;
}


//    plusExpr            = plus multiplicativeExprParser;
- (TDCollectionParser *)plusExprParser {
    if (!plusExprParser) {
        self.plusExprParser = [TDSequence sequence];
        plusExprParser.name = @"plusExpr";
        [plusExprParser add:self.plusParser];
        [plusExprParser add:self.multiplicativeExprParser];
    }
    return plusExprParser;
}


//    minusExpr           = minus multiplicativeExprParser;
- (TDCollectionParser *)minusExprParser {
    if (!minusExprParser) {
        self.minusExprParser = [TDSequence sequence];
        minusExprParser.name = @"minusExpr";
        [minusExprParser add:self.minusParser];
        [minusExprParser add:self.multiplicativeExprParser];
    }
    return minusExprParser;
}


//  MultiplicativeExpression:
//           UnaryExpression
//           UnaryExpression MultiplicativeOperator MultiplicativeExpression
//
//    multiplicativeExpr  = unaryExpr multiplicativeOpUnaryExpr*;
- (TDCollectionParser *)multiplicativeExprParser {
    if (!multiplicativeExprParser) {
        self.multiplicativeExprParser = [TDSequence sequence];
        multiplicativeExprParser.name = @"multiplicativeExpr";
        [multiplicativeExprParser add:self.unaryExprParser];
        [multiplicativeExprParser add:[TDRepetition repetitionWithSubparser:self.multiplicativeOpUnaryExprParser]];
    }
    return multiplicativeExprParser;
}


// multiplicativeOpUnaryExpr = multiplicativeOp unaryExpr;
- (TDCollectionParser *)multiplicativeOpUnaryExprParser {
    if (!multiplicativeOpUnaryExprParser) {
        self.multiplicativeOpUnaryExprParser = [TDSequence sequence];
        multiplicativeOpUnaryExprParser.name = @"multiplicativeOpUnaryExpr";
        [multiplicativeOpUnaryExprParser add:self.multiplicativeOpParser];
        [multiplicativeOpUnaryExprParser add:self.unaryExprParser];
    }
    return multiplicativeOpUnaryExprParser;
}


//  UnaryExpression:
//           MemberExpression
//           UnaryOperator UnaryExpression
//           - UnaryExpression
//           IncrementOperator MemberExpression
//           MemberExpression IncrementOperator
//           new Constructor
//           delete MemberExpression
//
//    unaryExpr           = memberExpr | unaryExpr1 | unaryExpr2 | unaryExpr3 | unaryExpr4 | unaryExpr5 | unaryExpr6;
- (TDCollectionParser *)unaryExprParser {
    if (!unaryExprParser) {
        self.unaryExprParser = [TDAlternation alternation];
        unaryExprParser.name = @"unaryExpr";
        [unaryExprParser add:self.memberExprParser];
        [unaryExprParser add:self.unaryExpr1Parser];
        [unaryExprParser add:self.unaryExpr2Parser];
        [unaryExprParser add:self.unaryExpr3Parser];
        [unaryExprParser add:self.unaryExpr4Parser];
        [unaryExprParser add:self.unaryExpr5Parser];
        [unaryExprParser add:self.unaryExpr6Parser];
    }
    return unaryExprParser;
}


//    unaryExpr1          = unaryOperator unaryExpr;
- (TDCollectionParser *)unaryExpr1Parser {
    if (!unaryExpr1Parser) {
        self.unaryExpr1Parser = [TDSequence sequence];
        unaryExpr1Parser.name = @"unaryExpr1";
        [unaryExpr1Parser add:self.unaryOpParser];
        [unaryExpr1Parser add:self.unaryExprParser];
    }
    return unaryExpr1Parser;
}


//    unaryExpr2          = minus unaryExpr;
- (TDCollectionParser *)unaryExpr2Parser {
    if (!unaryExpr2Parser) {
        self.unaryExpr2Parser = [TDSequence sequence];
        unaryExpr2Parser.name = @"unaryExpr2";
        [unaryExpr2Parser add:self.minusParser];
        [unaryExpr2Parser add:self.unaryExprParser];
    }
    return unaryExpr2Parser;
}


//    unaryExpr3          = incrementOperator memberExpr;
- (TDCollectionParser *)unaryExpr3Parser {
    if (!unaryExpr3Parser) {
        self.unaryExpr3Parser = [TDSequence sequence];
        unaryExpr3Parser.name = @"unaryExpr3";
        [unaryExpr3Parser add:self.incrementOpParser];
        [unaryExpr3Parser add:self.memberExprParser];
    }
    return unaryExpr3Parser;
}


//    unaryExpr4          = memberExpr incrementOperator;
- (TDCollectionParser *)unaryExpr4Parser {
    if (!unaryExpr4Parser) {
        self.unaryExpr4Parser = [TDSequence sequence];
        unaryExpr4Parser.name = @"unaryExpr4";
        [unaryExpr4Parser add:self.memberExprParser];
        [unaryExpr4Parser add:self.incrementOpParser];
    }
    return unaryExpr4Parser;
}


//    unaryExpr5          = new constructor;
- (TDCollectionParser *)unaryExpr5Parser {
    if (!unaryExpr5Parser) {
        self.unaryExpr5Parser = [TDSequence sequence];
        unaryExpr5Parser.name = @"unaryExpr5";
        [unaryExpr5Parser add:self.newParser];
        [unaryExpr5Parser add:self.constructorCallParser];
    }
    return unaryExpr5Parser;
}


//    unaryExpr6          = delete memberExpr;
- (TDCollectionParser *)unaryExpr6Parser {
    if (!unaryExpr6Parser) {
        self.unaryExpr6Parser = [TDSequence sequence];
        unaryExpr6Parser.name = @"unaryExpr6";
        [unaryExpr6Parser add:self.deleteParser];
        [unaryExpr6Parser add:self.memberExprParser];
    }
    return unaryExpr6Parser;
}


//  ConstructorCall:
//           Identifier
//           Identifier ( ArgumentListOpt )
//           Identifier . ConstructorCall
//

// constructorCall = identifier parentArgListOptParent? memberExprExt*
- (TDCollectionParser *)constructorCallParser {
    if (!constructorCallParser) {
        self.constructorCallParser = [TDSequence sequence];
        constructorCallParser.name = @"constructorCall";
        [constructorCallParser add:self.identifierParser];
        [constructorCallParser add:[self zeroOrOne:self.parenArgListOptParenParser]];
        [constructorCallParser add:[TDRepetition repetitionWithSubparser:self.memberExprExtParser]];
    }
    return constructorCallParser;
}


//    parenArgListParen   = openParen argListOpt closeParen;
- (TDCollectionParser *)parenArgListOptParenParser {
    if (!parenArgListOptParenParser) {
        self.parenArgListOptParenParser = [TDSequence sequence];
        parenArgListOptParenParser.name = @"parenArgListParen";
        [parenArgListOptParenParser add:self.openParenParser];
        [parenArgListOptParenParser add:self.argListOptParser];
        [parenArgListOptParenParser add:self.closeParenParser];
    }
    return parenArgListOptParenParser;
}


//  MemberExpression:
//           PrimaryExpression
//           PrimaryExpression . MemberExpression
//           PrimaryExpression [ Expression ]
//           PrimaryExpression ( ArgumentListOpt )
//
//    memberExpr          = primaryExpr memberExprExt?;    // TODO ??????
- (TDCollectionParser *)memberExprParser {
    if (!memberExprParser) {
        self.memberExprParser = [TDSequence sequence];
        memberExprParser.name = @"memberExpr";
        [memberExprParser add:self.primaryExprParser];
        [memberExprParser add:[TDRepetition repetitionWithSubparser:self.memberExprExtParser]];
    }
    return memberExprParser;
}


//    memberExprExt = dotMemberExpr | bracketMemberExpr | parenMemberExpr;
- (TDCollectionParser *)memberExprExtParser {
    if (!memberExprExtParser) {
        self.memberExprExtParser = [TDAlternation alternation];
        memberExprExtParser.name = @"memberExprExt";
        [memberExprExtParser add:self.dotMemberExprParser];
        [memberExprExtParser add:self.bracketMemberExprParser];
        [memberExprExtParser add:self.parenArgListOptParenParser];
    }
    return memberExprExtParser;
}


//    dotMemberExpr       = dot memberExpr;
- (TDCollectionParser *)dotMemberExprParser {
    if (!dotMemberExprParser) {
        self.dotMemberExprParser = [TDSequence sequence];
        dotMemberExprParser.name = @"dotMemberExpr";
        [dotMemberExprParser add:self.dotParser];
        [dotMemberExprParser add:self.memberExprParser];
    }
    return dotMemberExprParser;
}


//    bracketMemberExpr   = openBracket expr closeBracket;
- (TDCollectionParser *)bracketMemberExprParser {
    if (!bracketMemberExprParser) {
        self.bracketMemberExprParser = [TDSequence sequence];
        bracketMemberExprParser.name = @"bracketMemberExpr";
        [bracketMemberExprParser add:self.openBracketParser];
        [bracketMemberExprParser add:self.exprParser];
        [bracketMemberExprParser add:self.closeBracketParser];
    }
    return bracketMemberExprParser;
}


//  ArgumentListOpt:
//           empty
//           ArgumentList
//
// argListOpt          = argList?;
- (TDCollectionParser *)argListOptParser {
    if (!argListOptParser) {
        self.argListOptParser = [self zeroOrOne:self.argListParser];
        argListOptParser.name = @"argListOpt";
    }
    return argListOptParser;
}


//  ArgumentList:
//           AssignmentExpression
//           AssignmentExpression , ArgumentList
//
// argList             = assignmentExpr commaAssignmentExpr*;
- (TDCollectionParser *)argListParser {
    if (!argListParser) {
        self.argListParser = [TDSequence sequence];
        argListParser.name = @"argList";
        [argListParser add:self.assignmentExprParser];
        [argListParser add:[TDRepetition repetitionWithSubparser:self.commaAssignmentExprParser]];
    }
    return argListParser;
}


 //  PrimaryExpression:
 //           ( Expression )
 //           funcLiteral
 //           arrayLiteral
 //           Identifier
 //           IntegerLiteral
 //           FloatingPointLiteral
 //           StringLiteral
 //           false
 //           true
 //           null
 //           this
// primaryExpr         = parenExprParen | funcLiteral | arrayLiteral | identifier | Num | QuotedString | false | true | null | undefined | this;
- (TDCollectionParser *)primaryExprParser {
    if (!primaryExprParser) {
        self.primaryExprParser = [TDAlternation alternation];
        primaryExprParser.name = @"primaryExpr";
        [primaryExprParser add:self.parenExprParenParser];
        [primaryExprParser add:self.funcLiteralParser];
        [primaryExprParser add:self.arrayLiteralParser];
        [primaryExprParser add:self.objectLiteralParser];
        [primaryExprParser add:self.identifierParser];
        [primaryExprParser add:self.numberParser];
        [primaryExprParser add:self.stringParser];
        [primaryExprParser add:self.trueParser];
        [primaryExprParser add:self.falseParser];
        [primaryExprParser add:self.nullParser];
        [primaryExprParser add:self.undefinedParser]; // TODO ??
        [primaryExprParser add:self.thisParser];
    }
    return primaryExprParser;
}

 
 
//  parenExprParen      = openParen expr closeParen;
- (TDCollectionParser *)parenExprParenParser {
    if (!parenExprParenParser) {
        self.parenExprParenParser = [TDSequence sequence];
        parenExprParenParser.name = @"parenExprParen";
        [parenExprParenParser add:self.openParenParser];
        [parenExprParenParser add:self.exprParser];
        [parenExprParenParser add:self.closeParenParser];
    }
    return parenExprParenParser;
}


//funcLiteral                = function openParen paramListOpt closeParen compoundStmt;
- (TDCollectionParser *)funcLiteralParser {
    if (!funcLiteralParser) {
        self.funcLiteralParser = [TDSequence sequence];
        funcLiteralParser.name = @"funcLiteral";
        [funcLiteralParser add:self.functionParser];
        [funcLiteralParser add:self.openParenParser];
        [funcLiteralParser add:self.paramListOptParser];
        [funcLiteralParser add:self.closeParenParser];
        [funcLiteralParser add:self.compoundStmtParser];
    }
    return funcLiteralParser;
}


//arrayLiteral                = '[' arrayContents ']';
- (TDCollectionParser *)arrayLiteralParser {
    if (!arrayLiteralParser) {
        self.arrayLiteralParser = [TDTrack track];
        arrayLiteralParser.name = @"arrayLiteralParser";
        
        TDSequence *commaPrimaryExpr = [TDSequence sequence];
        [commaPrimaryExpr add:self.commaParser];
        [commaPrimaryExpr add:self.primaryExprParser];

        TDSequence *arrayContents = [TDSequence sequence];
        [arrayContents add:self.primaryExprParser];
        [arrayContents add:[TDRepetition repetitionWithSubparser:commaPrimaryExpr]];

        TDAlternation *arrayContentsOpt = [TDAlternation alternation];
        [arrayContentsOpt add:[TDEmpty empty]];
        [arrayContentsOpt add:arrayContents];

        [arrayLiteralParser add:self.openBracketParser];
        [arrayLiteralParser add:arrayContentsOpt];
        [arrayLiteralParser add:self.closeBracketParser];
    }
    return arrayLiteralParser;
}


//objectLiteral                = '{' objectContentsOpt '}';
- (TDCollectionParser *)objectLiteralParser {
    if (!objectLiteralParser) {
        self.objectLiteralParser = [TDSequence sequence];
        objectLiteralParser.name = @"objectLiteralParser";

        TDSequence *member = [TDSequence sequence];
        [member add:self.identifierParser];
        [member add:self.colonParser];
        [member add:self.primaryExprParser];

        TDSequence *commaMember = [TDSequence sequence];
        [commaMember add:self.commaParser];
        [commaMember add:member];
        
        TDSequence *objectContents = [TDSequence sequence];
        [objectContents add:member];
        [objectContents add:[TDRepetition repetitionWithSubparser:commaMember]];
        
        TDAlternation *objectContentsOpt = [TDAlternation alternation];
        [objectContentsOpt add:[TDEmpty empty]];
        [objectContentsOpt add:objectContents];
        
        [objectLiteralParser add:self.openCurlyParser];
        [objectLiteralParser add:objectContentsOpt];
        [objectLiteralParser add:self.closeCurlyParser];
    }
    return objectLiteralParser;
}


//  identifier          = Word;
- (TDParser *)identifierParser {
    if (!identifierParser) {
        self.identifierParser = [TDWord word];
        identifierParser.name = @"identifier";
    }
    return identifierParser;
}


- (TDParser *)stringParser {
    if (!stringParser) {
        self.stringParser = [TDQuotedString quotedString];
        stringParser.name = @"string";
    }
    return stringParser;
}


- (TDParser *)numberParser {
    if (!numberParser) {
        self.numberParser = [TDNum num];
        numberParser.name = @"number";
    }
    return numberParser;
}


#pragma mark -
#pragma mark keywords

- (TDParser *)ifParser {
    if (!ifParser) {
        self.ifParser = [TDLiteral literalWithString:@"if"];
        ifParser.name = @"if";
    }
    return ifParser;
}


- (TDParser *)elseParser {
    if (!elseParser) {
        self.elseParser = [TDLiteral literalWithString:@"else"];
        elseParser.name = @"else";
    }
    return elseParser;
}


- (TDParser *)whileParser {
    if (!whileParser) {
        self.whileParser = [TDLiteral literalWithString:@"while"];
        whileParser.name = @"while";
    }
    return whileParser;
}


- (TDParser *)forParser {
    if (!forParser) {
        self.forParser = [TDLiteral literalWithString:@"for"];
        forParser.name = @"for";
    }
    return forParser;
}


- (TDParser *)inParser {
    if (!inParser) {
        self.inParser = [TDLiteral literalWithString:@"in"];
        inParser.name = @"in";
    }
    return inParser;
}


- (TDParser *)breakParser {
    if (!breakParser) {
        self.breakParser = [TDLiteral literalWithString:@"break"];
        breakParser.name = @"break";
    }
    return breakParser;
}


- (TDParser *)continueParser {
    if (!continueParser) {
        self.continueParser = [TDLiteral literalWithString:@"continue"];
        continueParser.name = @"continue";
    }
    return continueParser;
}


- (TDParser *)withParser {
    if (!withParser) {
        self.withParser = [TDLiteral literalWithString:@"with"];
        withParser.name = @"with";
    }
    return withParser;
}


- (TDParser *)returnParser {
    if (!returnParser) {
        self.returnParser = [TDLiteral literalWithString:@"return"];
        returnParser.name = @"return";
    }
    return returnParser;
}


- (TDParser *)varParser {
    if (!varParser) {
        self.varParser = [TDLiteral literalWithString:@"var"];
        varParser.name = @"var";
    }
    return varParser;
}


- (TDParser *)deleteParser {
    if (!deleteParser) {
        self.deleteParser = [TDLiteral literalWithString:@"delete"];
        deleteParser.name = @"delete";
    }
    return deleteParser;
}


- (TDParser *)newParser {
    if (!newParser) {
        self.newParser = [TDLiteral literalWithString:@"new"];
        newParser.name = @"new";
    }
    return newParser;
}


- (TDParser *)thisParser {
    if (!thisParser) {
        self.thisParser = [TDLiteral literalWithString:@"this"];
        thisParser.name = @"this";
    }
    return thisParser;
}


- (TDParser *)falseParser {
    if (!falseParser) {
        self.falseParser = [TDLiteral literalWithString:@"false"];
        falseParser.name = @"false";
    }
    return falseParser;
}


- (TDParser *)trueParser {
    if (!trueParser) {
        self.trueParser = [TDLiteral literalWithString:@"true"];
        trueParser.name = @"true";
    }
    return trueParser;
}


- (TDParser *)nullParser {
    if (!nullParser) {
        self.nullParser = [TDLiteral literalWithString:@"null"];
        nullParser.name = @"null";
    }
    return nullParser;
}


- (TDParser *)undefinedParser {
    if (!undefinedParser) {
        self.undefinedParser = [TDLiteral literalWithString:@"undefined"];
        undefinedParser.name = @"undefined";
    }
    return undefinedParser;
}


- (TDParser *)voidParser {
    if (!voidParser) {
        self.voidParser = [TDLiteral literalWithString:@"void"];
        voidParser.name = @"void";
    }
    return voidParser;
}


- (TDParser *)typeofParser {
    if (!typeofParser) {
        self.typeofParser = [TDLiteral literalWithString:@"typeof"];
        typeofParser.name = @"typeof";
    }
    return typeofParser;
}


- (TDParser *)instanceofParser {
    if (!instanceofParser) {
        self.instanceofParser = [TDLiteral literalWithString:@"instanceof"];
        instanceofParser.name = @"instanceof";
    }
    return instanceofParser;
}


- (TDParser *)functionParser {
    if (!functionParser) {
        self.functionParser = [TDLiteral literalWithString:@"function"];
        functionParser.name = @"function";
    }
    return functionParser;
}


#pragma mark -
#pragma mark single-char symbols

- (TDParser *)orParser {
    if (!orParser) {
        self.orParser = [TDSymbol symbolWithString:@"||"];
        orParser.name = @"or";
    }
    return orParser;
}


- (TDParser *)andParser {
    if (!andParser) {
        self.andParser = [TDSymbol symbolWithString:@"&&"];
        andParser.name = @"and";
    }
    return andParser;
}


- (TDParser *)neParser {
    if (!neParser) {
        self.neParser = [TDSymbol symbolWithString:@"!="];
        neParser.name = @"ne";
    }
    return neParser;
}


- (TDParser *)isNotParser {
    if (!isNotParser) {
        self.isNotParser = [TDSymbol symbolWithString:@"!=="];
        isNotParser.name = @"isNot";
    }
    return isNotParser;
}


- (TDParser *)eqParser {
    if (!eqParser) {
        self.eqParser = [TDSymbol symbolWithString:@"=="];
        eqParser.name = @"eq";
    }
    return eqParser;
}


- (TDParser *)isParser {
    if (!isParser) {
        self.isParser = [TDSymbol symbolWithString:@"==="];
        isParser.name = @"is";
    }
    return isParser;
}


- (TDParser *)leParser {
    if (!leParser) {
        self.leParser = [TDSymbol symbolWithString:@"<="];
        leParser.name = @"le";
    }
    return leParser;
}


- (TDParser *)geParser {
    if (!geParser) {
        self.geParser = [TDSymbol symbolWithString:@">="];
        geParser.name = @"ge";
    }
    return geParser;
}


- (TDParser *)plusPlusParser {
    if (!plusPlusParser) {
        self.plusPlusParser = [TDSymbol symbolWithString:@"++"];
        plusPlusParser.name = @"plusPlus";
    }
    return plusPlusParser;
}


- (TDParser *)minusMinusParser {
    if (!minusMinusParser) {
        self.minusMinusParser = [TDSymbol symbolWithString:@"--"];
        minusMinusParser.name = @"minusMinus";
    }
    return minusMinusParser;
}


- (TDParser *)plusEqParser {
    if (!plusEqParser) {
        self.plusEqParser = [TDSymbol symbolWithString:@"+="];
        plusEqParser.name = @"plusEq";
    }
    return plusEqParser;
}


- (TDParser *)minusEqParser {
    if (!minusEqParser) {
        self.minusEqParser = [TDSymbol symbolWithString:@"-="];
        minusEqParser.name = @"minusEq";
    }
    return minusEqParser;
}


- (TDParser *)timesEqParser {
    if (!timesEqParser) {
        self.timesEqParser = [TDSymbol symbolWithString:@"*="];
        timesEqParser.name = @"timesEq";
    }
    return timesEqParser;
}


- (TDParser *)divEqParser {
    if (!divEqParser) {
        self.divEqParser = [TDSymbol symbolWithString:@"/="];
        divEqParser.name = @"divEq";
    }
    return divEqParser;
}


- (TDParser *)modEqParser {
    if (!modEqParser) {
        self.modEqParser = [TDSymbol symbolWithString:@"%="];
        modEqParser.name = @"modEq";
    }
    return modEqParser;
}


- (TDParser *)shiftLeftParser {
    if (!shiftLeftParser) {
        self.shiftLeftParser = [TDSymbol symbolWithString:@"<<"];
        shiftLeftParser.name = @"shiftLeft";
    }
    return shiftLeftParser;
}


- (TDParser *)shiftRightParser {
    if (!shiftRightParser) {
        self.shiftRightParser = [TDSymbol symbolWithString:@">>"];
        shiftRightParser.name = @"shiftRight";
    }
    return shiftRightParser;
}


- (TDParser *)shiftRightExtParser {
    if (!shiftRightExtParser) {
        self.shiftRightExtParser = [TDSymbol symbolWithString:@">>>"];
        shiftRightExtParser.name = @"shiftRightExt";
    }
    return shiftRightExtParser;
}


- (TDParser *)shiftLeftEqParser {
    if (!shiftLeftEqParser) {
        self.shiftLeftEqParser = [TDSymbol symbolWithString:@"<<="];
        shiftLeftEqParser.name = @"shiftLeftEq";
    }
    return shiftLeftEqParser;
}


- (TDParser *)shiftRightEqParser {
    if (!shiftRightEqParser) {
        self.shiftRightEqParser = [TDSymbol symbolWithString:@">>="];
        shiftRightEqParser.name = @"shiftRightEq";
    }
    return shiftRightEqParser;
}


- (TDParser *)shiftRightExtEqParser {
    if (!shiftRightExtEqParser) {
        self.shiftRightExtEqParser = [TDSymbol symbolWithString:@">>>="];
        shiftRightExtEqParser.name = @"shiftRightExtEq";
    }
    return shiftRightExtEqParser;
}


- (TDParser *)andEqParser {
    if (!andEqParser) {
        self.andEqParser = [TDSymbol symbolWithString:@"&="];
        andEqParser.name = @"andEq";
    }
    return andEqParser;
}


- (TDParser *)xorEqParser {
    if (!xorEqParser) {
        self.xorEqParser = [TDSymbol symbolWithString:@"^="];
        xorEqParser.name = @"xorEq";
    }
    return xorEqParser;
}


- (TDParser *)orEqParser {
    if (!orEqParser) {
        self.orEqParser = [TDSymbol symbolWithString:@"|="];
        orEqParser.name = @"orEq";
    }
    return orEqParser;
}


#pragma mark -
#pragma mark single-char symbols

- (TDParser *)openCurlyParser {
    if (!openCurlyParser) {
        self.openCurlyParser = [TDSymbol symbolWithString:@"{"];
        openCurlyParser.name = @"openCurly";
    }
    return openCurlyParser;
}


- (TDParser *)closeCurlyParser {
    if (!closeCurlyParser) {
        self.closeCurlyParser = [TDSymbol symbolWithString:@"}"];
        closeCurlyParser.name = @"closeCurly";
    }
    return closeCurlyParser;
}


- (TDParser *)openParenParser {
    if (!openParenParser) {
        self.openParenParser = [TDSymbol symbolWithString:@"("];
        openParenParser.name = @"openParen";
    }
    return openParenParser;
}


- (TDParser *)closeParenParser {
    if (!closeParenParser) {
        self.closeParenParser = [TDSymbol symbolWithString:@")"];
        closeParenParser.name = @"closeParen";
    }
    return closeParenParser;
}


- (TDParser *)openBracketParser {
    if (!openBracketParser) {
        self.openBracketParser = [TDSymbol symbolWithString:@"["];
        openBracketParser.name = @"openBracket";
    }
    return openBracketParser;
}


- (TDParser *)closeBracketParser {
    if (!closeBracketParser) {
        self.closeBracketParser = [TDSymbol symbolWithString:@"]"];
        closeBracketParser.name = @"closeBracket";
    }
    return closeBracketParser;
}


- (TDParser *)commaParser {
    if (!commaParser) {
        self.commaParser = [TDSymbol symbolWithString:@","];
        commaParser.name = @"comma";
    }
    return commaParser;
}


- (TDParser *)dotParser {
    if (!dotParser) {
        self.dotParser = [TDSymbol symbolWithString:@"."];
        dotParser.name = @"dot";
    }
    return dotParser;
}


- (TDParser *)semiOptParser {
    if (!semiOptParser) {
        self.semiOptParser = [self zeroOrOne:self.semiParser];
        semiOptParser.name = @"semiOpt";
    }
    return semiOptParser;
}


- (TDParser *)semiParser {
    if (!semiParser) {
        self.semiParser = [TDSymbol symbolWithString:@";"];
        semiParser.name = @"semi";
    }
    return semiParser;
}


- (TDParser *)colonParser {
    if (!colonParser) {
        self.colonParser = [TDSymbol symbolWithString:@":"];
        colonParser.name = @"colon";
    }
    return colonParser;
}


- (TDParser *)equalsParser {
    if (!equalsParser) {
        self.equalsParser = [TDSymbol symbolWithString:@"="];
        equalsParser.name = @"equals";
    }
    return equalsParser;
}


- (TDParser *)notParser {
    if (!notParser) {
        self.notParser = [TDSymbol symbolWithString:@"!"];
        notParser.name = @"not";
    }
    return notParser;
}


- (TDParser *)ltParser {
    if (!ltParser) {
        self.ltParser = [TDSymbol symbolWithString:@"<"];
        ltParser.name = @"lt";
    }
    return ltParser;
}


- (TDParser *)gtParser {
    if (!gtParser) {
        self.gtParser = [TDSymbol symbolWithString:@">"];
        gtParser.name = @"gt";
    }
    return gtParser;
}


- (TDParser *)ampParser {
    if (!ampParser) {
        self.ampParser = [TDSymbol symbolWithString:@"&"];
        ampParser.name = @"amp";
    }
    return ampParser;
}


- (TDParser *)pipeParser {
    if (!pipeParser) {
        self.pipeParser = [TDSymbol symbolWithString:@"|"];
        pipeParser.name = @"pipe";
    }
    return pipeParser;
}


- (TDParser *)caretParser {
    if (!caretParser) {
        self.caretParser = [TDSymbol symbolWithString:@"^"];
        caretParser.name = @"caret";
    }
    return caretParser;
}


- (TDParser *)tildeParser {
    if (!tildeParser) {
        self.tildeParser = [TDSymbol symbolWithString:@"~"];
        tildeParser.name = @"tilde";
    }
    return tildeParser;
}


- (TDParser *)questionParser {
    if (!questionParser) {
        self.questionParser = [TDSymbol symbolWithString:@"?"];
        questionParser.name = @"question";
    }
    return questionParser;
}


- (TDParser *)plusParser {
    if (!plusParser) {
        self.plusParser = [TDSymbol symbolWithString:@"+"];
        plusParser.name = @"plus";
    }
    return plusParser;
}


- (TDParser *)minusParser {
    if (!minusParser) {
        self.minusParser = [TDSymbol symbolWithString:@"-"];
        minusParser.name = @"minus";
    }
    return minusParser;
}


- (TDParser *)timesParser {
    if (!timesParser) {
        self.timesParser = [TDSymbol symbolWithString:@"x"];
        timesParser.name = @"times";
    }
    return timesParser;
}


- (TDParser *)divParser {
    if (!divParser) {
        self.divParser = [TDSymbol symbolWithString:@"/"];
        divParser.name = @"div";
    }
    return divParser;
}


- (TDParser *)modParser {
    if (!modParser) {
        self.modParser = [TDSymbol symbolWithString:@"%"];
        modParser.name = @"mod";
    }
    return modParser;
}

@synthesize assignmentOpParser;
@synthesize relationalOpParser;
@synthesize equalityOpParser;
@synthesize shiftOpParser;
@synthesize incrementOpParser;
@synthesize unaryOpParser;
@synthesize multiplicativeOpParser;

@synthesize programParser;
@synthesize elementParser;
@synthesize funcParser;
@synthesize paramListOptParser;
@synthesize paramListParser;
@synthesize commaIdentifierParser;
@synthesize compoundStmtParser;
@synthesize stmtsParser;
@synthesize stmtParser;
@synthesize ifStmtParser;
@synthesize ifElseStmtParser;
@synthesize whileStmtParser;
@synthesize forParenStmtParser;
@synthesize forBeginStmtParser;
@synthesize forInStmtParser;
@synthesize breakStmtParser;
@synthesize continueStmtParser;
@synthesize withStmtParser;
@synthesize returnStmtParser;
@synthesize variablesOrExprStmtParser;
@synthesize conditionParser;
@synthesize forParenParser;
@synthesize forBeginParser;
@synthesize variablesOrExprParser;
@synthesize varVariablesParser;
@synthesize variablesParser;
@synthesize commaVariableParser;
@synthesize variableParser;
@synthesize assignmentParser;
@synthesize exprOptParser;
@synthesize exprParser;
@synthesize commaAssignmentExprParser;
@synthesize assignmentExprParser;
@synthesize assignmentOpConditionalExprParser;
@synthesize conditionalExprParser;
@synthesize ternaryExprParser;
@synthesize orExprParser;
@synthesize orAndExprParser;
@synthesize andExprParser;
@synthesize andBitwiseOrExprParser;
@synthesize bitwiseOrExprParser;
@synthesize pipeBitwiseXorExprParser;
@synthesize bitwiseXorExprParser;
@synthesize caretBitwiseAndExprParser;
@synthesize bitwiseAndExprParser;
@synthesize ampEqualityExprParser;
@synthesize equalityExprParser;
@synthesize equalityOpRelationalExprParser;
@synthesize relationalExprParser;
@synthesize relationalOpShiftExprParser;
@synthesize shiftExprParser;
@synthesize shiftOpAdditiveExprParser;
@synthesize additiveExprParser;
@synthesize plusOrMinusExprParser;
@synthesize plusExprParser;
@synthesize minusExprParser;
@synthesize multiplicativeExprParser;
@synthesize multiplicativeOpUnaryExprParser;
@synthesize unaryExprParser;
@synthesize unaryExpr1Parser;
@synthesize unaryExpr2Parser;
@synthesize unaryExpr3Parser;
@synthesize unaryExpr4Parser;
@synthesize unaryExpr5Parser;
@synthesize unaryExpr6Parser;
@synthesize constructorCallParser;
@synthesize parenArgListOptParenParser;
@synthesize memberExprParser;
@synthesize memberExprExtParser;
@synthesize dotMemberExprParser;
@synthesize bracketMemberExprParser;
@synthesize argListOptParser;
@synthesize argListParser;
@synthesize primaryExprParser;
@synthesize parenExprParenParser;

@synthesize funcLiteralParser;
@synthesize arrayLiteralParser;
@synthesize objectLiteralParser;

@synthesize identifierParser;
@synthesize stringParser;
@synthesize numberParser;

@synthesize ifParser;
@synthesize elseParser;
@synthesize whileParser;
@synthesize forParser;
@synthesize inParser;
@synthesize breakParser;
@synthesize continueParser;
@synthesize withParser;
@synthesize returnParser;
@synthesize varParser;
@synthesize deleteParser;
@synthesize newParser;
@synthesize thisParser;
@synthesize falseParser;
@synthesize trueParser;
@synthesize nullParser;
@synthesize undefinedParser;
@synthesize voidParser;
@synthesize typeofParser;
@synthesize instanceofParser;
@synthesize functionParser;
            
@synthesize orParser;
@synthesize andParser;
@synthesize neParser;
@synthesize isNotParser;
@synthesize eqParser;
@synthesize isParser;
@synthesize leParser;
@synthesize geParser;
@synthesize plusPlusParser;
@synthesize minusMinusParser;
@synthesize plusEqParser;
@synthesize minusEqParser;
@synthesize timesEqParser;
@synthesize divEqParser;
@synthesize modEqParser;
@synthesize shiftLeftParser;
@synthesize shiftRightParser;
@synthesize shiftRightExtParser;
@synthesize shiftLeftEqParser;
@synthesize shiftRightEqParser;
@synthesize shiftRightExtEqParser;
@synthesize andEqParser;
@synthesize xorEqParser;
@synthesize orEqParser;
            
@synthesize openCurlyParser;
@synthesize closeCurlyParser;
@synthesize openParenParser;
@synthesize closeParenParser;
@synthesize openBracketParser;
@synthesize closeBracketParser;
@synthesize commaParser;
@synthesize dotParser;
@synthesize semiOptParser;
@synthesize semiParser;
@synthesize colonParser;
@synthesize equalsParser;
@synthesize notParser;
@synthesize ltParser;
@synthesize gtParser;
@synthesize ampParser;
@synthesize pipeParser;
@synthesize caretParser;
@synthesize tildeParser;
@synthesize questionParser;
@synthesize plusParser;
@synthesize minusParser;
@synthesize timesParser;
@synthesize divParser;
@synthesize modParser;
@end
