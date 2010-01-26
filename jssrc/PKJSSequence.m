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

#import "PKJSSequence.h"
#import "PKJSUtils.h"
#import "PKJSCollectionParser.h"
#import <ParseKit/PKSequence.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKSequence_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKSequence_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKSequence_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKSequence_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKSequence_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKCollectionParser_class(ctx);
        def.staticFunctions = PKSequence_staticFunctions;
        def.staticValues = PKSequence_staticValues;
        def.initialize = PKSequence_initialize;
        def.finalize = PKSequence_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKSequence_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKSequence_class(ctx), data);
}

JSObjectRef PKSequence_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKSequence *data = [[PKSequence alloc] init];
    return PKSequence_new(ctx, data);
}
