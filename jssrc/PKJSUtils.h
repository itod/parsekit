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

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#define PKPreconditionInstaceOf(cls, meth)
#define PKPreconditionMethodArgc(n, meth)
#define PKPreconditionConstructorArgc(n, meth)

NSString *PKJSStringGetNSString(JSStringRef str);

JSValueRef PKCFTypeToJSValue(JSContextRef ctx, CFTypeRef value, JSValueRef *ex);
JSValueRef PKCFStringToJSValue(JSContextRef ctx, CFStringRef cfStr, JSValueRef *ex);
JSValueRef PKNSStringToJSValue(JSContextRef ctx, NSString *nsStr, JSValueRef *ex);
JSObjectRef PKCFArrayToJSObject(JSContextRef ctx, CFArrayRef cfArray, JSValueRef *ex);
JSObjectRef PKNSArrayToJSObject(JSContextRef ctx, NSArray *nsArray, JSValueRef *ex);
JSObjectRef PKCFDictionaryToJSObject(JSContextRef ctx, CFDictionaryRef cfDict, JSValueRef *ex);
JSObjectRef PKNSDictionaryToJSObject(JSContextRef ctx, NSDictionary *nsDict, JSValueRef *ex);

CFTypeRef PKJSValueCopyCFType(JSContextRef ctx, JSValueRef value, JSValueRef *ex);
id PKJSValueGetId(JSContextRef ctx, JSValueRef value, JSValueRef *ex);
CFStringRef PKJSValueCopyCFString(JSContextRef ctx, JSValueRef value, JSValueRef *ex);
NSString *PKJSValueGetNSString(JSContextRef ctx, JSValueRef value, JSValueRef *ex);
CFArrayRef PKJSObjectCopyCFArray(JSContextRef ctx, JSObjectRef obj, JSValueRef *ex);
CFDictionaryRef PKJSObjectCopyCFDictionary(JSContextRef ctx, JSObjectRef obj, JSValueRef *ex);

JSObjectRef PKNSErrorToJSObject(JSContextRef ctx, NSError *nsErr, JSValueRef *ex);
bool PKJSValueIsInstanceOfClass(JSContextRef ctx, JSValueRef value, char *className, JSValueRef* ex);

JSValueRef PKEvaluateScript(JSGlobalContextRef ctx, NSString *script, NSString *sourceURLString, NSString **outErrMsg);
BOOL PKBooleanForScript(JSGlobalContextRef ctx, NSString *script, NSString *sourceURLString, NSString **outErrMsg);