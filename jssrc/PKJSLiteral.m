//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PKLiteral.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKLiteral.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKLiteral_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKLiteral_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKLiteral_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKLiteral_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKLiteral_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKLiteral_staticFunctions;
        def.staticValues = PKLiteral_staticValues;
        def.initialize = PKLiteral_initialize;
        def.finalize = PKLiteral_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKLiteral_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKLiteral_class(ctx), data);
}

JSObjectRef PKLiteral_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionConstructorArgc(1, "PKLiteral");
    
    NSString *s = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKLiteral *data = [[PKLiteral alloc] initWithString:s];
    return PKLiteral_new(ctx, data);
}
