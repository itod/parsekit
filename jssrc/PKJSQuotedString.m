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

#import "PKJSQuotedString.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKQuotedString.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKQuotedString_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKQuotedString_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKQuotedString_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKQuotedString_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKQuotedString_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKQuotedString_staticFunctions;
        def.staticValues = PKQuotedString_staticValues;
        def.initialize = PKQuotedString_initialize;
        def.finalize = PKQuotedString_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKQuotedString_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKQuotedString_class(ctx), data);
}

JSObjectRef PKQuotedString_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKQuotedString *data = [[PKQuotedString alloc] init];
    return PKQuotedString_new(ctx, data);
}
