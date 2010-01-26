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

#import "PKJSRepetition.h"
#import "PKJSUtils.h"
#import "PKJSParser.h"
#import <ParseKit/PKRepetition.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKRepetition_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKRepetition_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKRepetition_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKRepetition_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKRepetition_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKParser_class(ctx);
        def.staticFunctions = PKRepetition_staticFunctions;
        def.staticValues = PKRepetition_staticValues;
        def.initialize = PKRepetition_initialize;
        def.finalize = PKRepetition_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKRepetition_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKRepetition_class(ctx), data);
}

JSObjectRef PKRepetition_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionConstructorArgc(1, "PKRepetition");
	
	JSValueRef v = argv[0];
	if (!PKJSValueIsInstanceOfClass(ctx, v, "PKParser", ex)) {
		*ex = PKNSStringToJSValue(ctx, @"argument to PKRepeition constructor must be and instance of a PKParser subclass", ex);
	}
    
    PKParser *p = JSObjectGetPrivate((JSObjectRef)v);

    PKRepetition *data = [[PKRepetition alloc] initWithSubparser:p];
    return PKRepetition_new(ctx, data);
}
