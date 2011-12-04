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

#import "XPathAssembler.h"
#import <ParseKit/ParseKit.h>
#import "XPathContext.h"

@implementation XPathAssembler

- (id)init {
    if (self = [super init]) {
        self.context = [[[XPathContext alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.context = nil;
    [super dealloc];
}


- (void)resetWithReader:(PKReader *)r {
    [context resetWithCurrentNode:nil];
}


- (void)parser:(PKParser *)p didMatchAxisSpecifier:(PKAssembly *)a {
    //NSLog(@"\n\n %s\n\n %@ \n\n", _cmd, a);
    
    //PKToken *tok = [a pop];
    
}


- (void)parser:(PKParser *)p didMatchNodeTest:(PKAssembly *)a {
    //NSLog(@"\n\n %s\n\n %@ \n\n", _cmd, a);
}


- (void)parser:(PKParser *)p didMatchPredicate:(PKAssembly *)a {
    //NSLog(@"\n\n %s\n\n %@ \n\n", _cmd, a);
}

// [4] Step ::=       AxisSpecifier NodeTest Predicate* | AbbreviatedStep    
- (void)parser:(PKParser *)p didMatchStep:(PKAssembly *)a {
    //NSLog(@"\n\n %s\n\n %@ \n\n", _cmd, a);
}



@synthesize context;
@end
