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

#import <JavaScriptCore/JavaScriptCore.h>

JSObjectRef PKToken_new(JSContextRef ctx, void *data);
JSClassRef PKToken_class(JSContextRef ctx);
JSObjectRef PKToken_construct(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* ex);

// a JS Class method
//JSValueRef PKToken_EOFToken(JSContextRef ctx, JSObjectRef function, JSObjectRef this, size_t argc, const JSValueRef argv[], JSValueRef* ex);

// a JS Class property
JSValueRef PKToken_getEOFToken(JSContextRef ctx);
