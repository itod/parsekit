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

#import "PKJSAny.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKAny.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKAny_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKAny_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKAny_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKAny_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKAny_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKAny_staticFunctions;
        def.staticValues = PKAny_staticValues;
        def.initialize = PKAny_initialize;
        def.finalize = PKAny_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKAny_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKAny_class(ctx), data);
}

JSObjectRef PKAny_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKAny *data = [[PKAny alloc] init];
    return PKAny_new(ctx, data);
}
