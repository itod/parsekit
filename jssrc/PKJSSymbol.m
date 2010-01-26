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

#import "PKJSSymbol.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKSymbol.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKSymbol_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKSymbol_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKSymbol_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKSymbol_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKSymbol_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKSymbol_staticFunctions;
        def.staticValues = PKSymbol_staticValues;
        def.initialize = PKSymbol_initialize;
        def.finalize = PKSymbol_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKSymbol_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKSymbol_class(ctx), data);
}

JSObjectRef PKSymbol_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    NSString *s = nil;
    
    if (argc > 0) {
        s = PKJSValueGetNSString(ctx, argv[0], ex);
    }
    
    PKSymbol *data = [[PKSymbol alloc] initWithString:s];
    return PKSymbol_new(ctx, data);
}
