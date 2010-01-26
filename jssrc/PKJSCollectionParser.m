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

#import "PKCollectionParser.h"
#import "PKJSUtils.h"
#import "PKJSParser.h"
#import <ParseKit/PKCollectionParser.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKCollectionParser_add(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKCollectionParser_class, "add");
    PKPreconditionMethodArgc(1, "add");
    
    PKCollectionParser *data = JSObjectGetPrivate(this);
    
    JSObjectRef arg = (JSObjectRef)argv[0];
    PKParser *p = (PKParser *)JSObjectGetPrivate(arg);
    [data add:p];
    return JSValueMakeUndefined(ctx);
}

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKCollectionParser_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKCollectionParser_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKCollectionParser_staticFunctions[] = {
{ "add", PKCollectionParser_add, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKCollectionParser_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKCollectionParser_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKParser_class(ctx);
        def.staticFunctions = PKCollectionParser_staticFunctions;
        def.staticValues = PKCollectionParser_staticValues;
        def.initialize = PKCollectionParser_initialize;
        def.finalize = PKCollectionParser_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKCollectionParser_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKCollectionParser_class(ctx), data);
}
