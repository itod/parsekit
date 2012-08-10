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

#import "PKJSNumberState.h"
#import "PKJSUtils.h"
#import "PKJSTokenizerState.h"
#import <ParseKit/PKNumberState.h>

#pragma mark -
#pragma mark Methods

static JSValueRef PKNumberState_toString(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionInstaceOf(PKNumberState_class, "toString");
    return PKNSStringToJSValue(ctx, @"[object PKNumberState]", ex);
}

#pragma mark -
#pragma mark Properties

static JSValueRef PKNumberState_getAllowsTrailingDecimalSeparator(JSContextRef ctx, JSObjectRef this, JSStringRef propName, JSValueRef *ex) {
    PKNumberState *data = JSObjectGetPrivate(this);
    return JSValueMakeBoolean(ctx, data.allowsTrailingDecimalSeparator);
}

static bool PKNumberState_setAllowsTrailingDecimalSeparator(JSContextRef ctx, JSObjectRef this, JSStringRef propertyName, JSValueRef value, JSValueRef *ex) {
    PKNumberState *data = JSObjectGetPrivate(this);
    data.allowsTrailingDecimalSeparator = JSValueToBoolean(ctx, value);
    return true;
}

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKNumberState_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKNumberState_finalize(JSObjectRef this) {
    // released in PKTokenizerState_finalize
}

static JSStaticFunction PKNumberState_staticFunctions[] = {
{ "toString", PKNumberState_toString, kJSPropertyAttributeDontDelete },
{ 0, 0, 0 }
};

static JSStaticValue PKNumberState_staticValues[] = {        
{ "allowsTrailingDecimalSeparator", PKNumberState_getAllowsTrailingDecimalSeparator, PKNumberState_setAllowsTrailingDecimalSeparator, kJSPropertyAttributeDontDelete }, // Boolean
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKNumberState_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTokenizerState_class(ctx);
        def.staticFunctions = PKNumberState_staticFunctions;
        def.staticValues = PKNumberState_staticValues;
        def.initialize = PKNumberState_initialize;
        def.finalize = PKNumberState_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKNumberState_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKNumberState_class(ctx), data);
}

JSObjectRef PKNumberState_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKNumberState *data = [[PKNumberState alloc] init];
    return PKNumberState_new(ctx, data);
}
