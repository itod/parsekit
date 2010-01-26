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

#import "PKJSWordState.h"
#import "PKJSUtils.h"
#import "PKJSTokenizerState.h"
#import <ParseKit/PKWordState.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKWordState_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKWordState_class, "toString");
    return PKNSStringToJSValue(ctx, @"[object PKWordState]", ex);
}

static JSValueRef PKWordState_setWordChars(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKWordState_class, "setWordChars");
    PKPreconditionMethodArgc(3, "PKWordState.setWordChars");

    BOOL yn = JSValueToBoolean(ctx, argv[0]);
    NSString *start = PKJSValueGetNSString(ctx, argv[1], ex);
    NSString *end = PKJSValueGetNSString(ctx, argv[2], ex);
    
    PKWordState *data = JSObjectGetPrivate(this);
    [data setWordChars:yn from:[start characterAtIndex:0] to:[end characterAtIndex:0]];
    
    return JSValueMakeUndefined(ctx);
}

static JSValueRef PKWordState_isWordChar(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKWordState_class, "isWordChar");
    PKPreconditionMethodArgc(1, "PKWordState.isWordChar");
    
    NSInteger c = (NSInteger)JSValueToNumber(ctx, argv[0], ex);
    
    PKWordState *data = JSObjectGetPrivate(this);
    BOOL yn = [data isWordChar:c];
    
    return JSValueMakeBoolean(ctx, yn);
}

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKWordState_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKWordState_finalize(JSObjectRef this) {
    // released in PKTokenizerState_finalize
}

static JSStaticFunction PKWordState_staticFunctions[] = {
{ "toString", PKWordState_toString, kJSPropertyAttributeDontDelete },
{ "setWordChars", PKWordState_setWordChars, kJSPropertyAttributeDontDelete },
{ "isWordChar", PKWordState_isWordChar, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKWordState_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKWordState_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTokenizerState_class(ctx);
        def.staticFunctions = PKWordState_staticFunctions;
        def.staticValues = PKWordState_staticValues;
        def.initialize = PKWordState_initialize;
        def.finalize = PKWordState_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKWordState_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKWordState_class(ctx), data);
}

JSObjectRef PKWordState_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKWordState *data = [[PKWordState alloc] init];
    return PKWordState_new(ctx, data);
}
