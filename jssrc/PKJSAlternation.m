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

#import "PKJSAlternation.h"
#import "PKJSUtils.h"
#import "PKJSCollectionParser.h"
#import <ParseKit/PKAlternation.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKAlternation_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKAlternation_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKAlternation_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKAlternation_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKAlternation_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKCollectionParser_class(ctx);
        def.staticFunctions = PKAlternation_staticFunctions;
        def.staticValues = PKAlternation_staticValues;
        def.initialize = PKAlternation_initialize;
        def.finalize = PKAlternation_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKAlternation_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKAlternation_class(ctx), data);
}

JSObjectRef PKAlternation_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKAlternation *data = [[PKAlternation alloc] init];
    return PKAlternation_new(ctx, data);
}
