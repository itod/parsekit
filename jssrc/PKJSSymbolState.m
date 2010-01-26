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

#import "PKJSSymbolState.h"
#import "PKJSUtils.h"
#import "PKJSTokenizerState.h"
#import <ParseKit/PKSymbolState.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKSymbolState_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKSymbolState_class, "toString");
    return PKNSStringToJSValue(ctx, @"[object PKSymbolState]", ex);
}

static JSValueRef PKSymbolState_add(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKSymbolState_class, "add");
    PKPreconditionMethodArgc(1, "PKSymbolState.add");
    
    NSString *s = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKSymbolState *data = JSObjectGetPrivate(this);
    [data add:s];
    
    return JSValueMakeUndefined(ctx);
}

static JSValueRef PKSymbolState_remove(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKSymbolState_class, "remove");
    PKPreconditionMethodArgc(1, "PKSymbolState.remove");
    
    NSString *s = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKSymbolState *data = JSObjectGetPrivate(this);
    [data remove:s];
    
    return JSValueMakeUndefined(ctx);
}

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKSymbolState_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKSymbolState_finalize(JSObjectRef this) {
    // released in PKTokenizerState_finalize
}

static JSStaticFunction PKSymbolState_staticFunctions[] = {
{ "toString", PKSymbolState_toString, kJSPropertyAttributeDontDelete },
{ "add", PKSymbolState_add, kJSPropertyAttributeDontDelete },
{ "remove", PKSymbolState_remove, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKSymbolState_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKSymbolState_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTokenizerState_class(ctx);
        def.staticFunctions = PKSymbolState_staticFunctions;
        def.staticValues = PKSymbolState_staticValues;
        def.initialize = PKSymbolState_initialize;
        def.finalize = PKSymbolState_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKSymbolState_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKSymbolState_class(ctx), data);
}

JSObjectRef PKSymbolState_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKSymbolState *data = [[PKSymbolState alloc] init];
    return PKSymbolState_new(ctx, data);
}
