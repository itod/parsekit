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

#import "PKJSNum.h"
#import "PKJSUtils.h"
#import "PKJSTerminal.h"
#import <ParseKit/PKNumber.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKNum_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKNum_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKNum_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKNum_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKNum_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKTerminal_class(ctx);
        def.staticFunctions = PKNum_staticFunctions;
        def.staticValues = PKNum_staticValues;
        def.initialize = PKNum_initialize;
        def.finalize = PKNum_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKNum_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKNum_class(ctx), data);
}

JSObjectRef PKNum_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKNumber *data = [[PKNumber alloc] init];
    return PKNum_new(ctx, data);
}
