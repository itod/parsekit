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

#import "PKJSAssemblerAdapter.h"
#import "PKJSTokenAssembly.h"
#import "PKJSCharacterAssembly.h"
#import "PKJSUtils.h"
#import <ParseKit/PKAssembly.h>
#import <ParseKit/PKTokenAssembly.h>
#import <ParseKit/PKCharacterAssembly.h>

@implementation PKJSAssemblerAdapter

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}


- (void)dealloc {
    [self setAssemblerFunction:NULL fromContext:NULL];
    [super dealloc];
}


- (void)parser:(PKParser *)p didMatch:(PKAssembly *)a {
    JSValueRef arg = NULL;
    if ([a isMemberOfClass:[PKTokenAssembly class]]) {
        arg = (JSValueRef)PKTokenAssembly_new(ctx, a);
    } else if ([a isMemberOfClass:[PKCharacterAssembly class]]) {
        arg = (JSValueRef)PKCharacterAssembly_new(ctx, a);
    } else {
        NSAssert(0, @"Should not reach here.");
    }
    
    JSValueRef argv[] = { arg };
    JSObjectRef globalObj = JSContextGetGlobalObject(ctx);
    JSValueRef ex = NULL;
    JSObjectCallAsFunction(ctx, assemblerFunction, globalObj, 1, argv, &ex);
    if (ex) {
        NSString *s = PKJSValueGetNSString(ctx, ex, NULL);
        [NSException raise:@"PKJSException" format:s arguments:NULL];
    }
}


- (JSObjectRef)assemblerFunction {
    return assemblerFunction;
}


- (void)setAssemblerFunction:(JSObjectRef)f fromContext:(JSContextRef)c {
    if (assemblerFunction != f) {
        if (ctx && assemblerFunction) {
            JSValueUnprotect(ctx, assemblerFunction);
            JSGarbageCollect(ctx);
        }
        
        ctx = c;
        assemblerFunction = f;
        if (ctx && assemblerFunction) {
            JSValueProtect(ctx, assemblerFunction);
        }
    }
}

@end
