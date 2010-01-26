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

#import "PKJSLowercaseWord.h"
#import "PKJSUtils.h"
#import "PKJSWord.h"
#import <ParseKit/PKLowercaseWord.h>

#pragma mark -
#pragma mark Methods

#pragma mark -
#pragma mark Properties

#pragma mark -
#pragma mark Initializer/Finalizer

static void PKLowercaseWord_initialize(JSContextRef ctx, JSObjectRef this) {
    
}

static void PKLowercaseWord_finalize(JSObjectRef this) {
    // released in PKParser_finalize
}

static JSStaticFunction PKLowercaseWord_staticFunctions[] = {
{ 0, 0, 0 }
};

static JSStaticValue PKLowercaseWord_staticValues[] = {        
{ 0, 0, 0, 0 }
};

#pragma mark -
#pragma mark Public

JSClassRef PKLowercaseWord_class(JSContextRef ctx) {
    static JSClassRef jsClass = NULL;
    if (!jsClass) {                
        JSClassDefinition def = kJSClassDefinitionEmpty;
        def.parentClass = PKWord_class(ctx);
        def.staticFunctions = PKLowercaseWord_staticFunctions;
        def.staticValues = PKLowercaseWord_staticValues;
        def.initialize = PKLowercaseWord_initialize;
        def.finalize = PKLowercaseWord_finalize;
        jsClass = JSClassCreate(&def);
    }
    return jsClass;
}

JSObjectRef PKLowercaseWord_new(JSContextRef ctx, void *data) {
    return JSObjectMake(ctx, PKLowercaseWord_class(ctx), data);
}

JSObjectRef PKLowercaseWord_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef *ex) {
    PKPreconditionConstructorArgc(1, "PKLowercaseWord");
    
    NSString *s = PKJSValueGetNSString(ctx, argv[0], ex);
    
    PKLowercaseWord *data = [[PKLowercaseWord alloc] initWithString:s];
    return PKLowercaseWord_new(ctx, data);
}
