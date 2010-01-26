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

#import "PKJSTerminal.h"
#import "PKJSUtils.h"
#import "PKJSParser.h"
#import <ParseKit/PKTerminal.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKTerminal_discard(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKTerminal_class, "discard");
    
    PKTerminal *data = JSObjectGetPrivate(this);
    [data discard];
    return this;
}

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKTerminal_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKTerminal_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKTerminal_staticFunctions[] = {
{ "discard", PKTerminal_discard, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKTerminal_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKTerminal_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKParser_class(ctx);
        def.staticFunctions = PKTerminal_staticFunctions;
        def.staticValues = PKTerminal_staticValues;
        def.initialize = PKTerminal_initialize;
        def.finalize = PKTerminal_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKTerminal_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKTerminal_class(ctx), data);
}
