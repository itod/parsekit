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

#import "TDRobotCommandTest.h"

@interface RobotCommand : NSObject {
    NSString *location;
}
@property (copy) NSString *location;
@end

@implementation RobotCommand

- (void)dealloc {
    self.location = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    RobotCommand *c = [[RobotCommand allocWithZone:zone] init];
    c->location = [location copy];
    return c;
}

@synthesize location;
@end

@interface RobotPickCommand : RobotCommand {}
@end
@implementation RobotPickCommand
- (NSString *)description { return [NSString stringWithFormat:@"pick %@", self.location]; }
@end

@interface RobotPlaceCommand : RobotCommand {}
@end
@implementation RobotPlaceCommand
- (NSString *)description { return [NSString stringWithFormat:@"place %@", self.location]; }
@end

@interface RobotScanCommand : RobotCommand {}
@end
@implementation RobotScanCommand
- (NSString *)description { return [NSString stringWithFormat:@"scan %@", self.location]; }
@end

@implementation TDRobotCommandTest

//    e = command*
//    command = pickCommand | placeCommand | scanCommand
//    pickCommand = "pick" "carrier" "from" location
//    placeCommand = "place" "carrier" "at" location
//    scanCommand = "scan" location
//    location = Word

- (PKParser *)location {
    return [PKWord word];
}


- (PKParser *)pickCommand {
    PKSequence *s = [PKSequence sequence];
    [s add:[[PKCaseInsensitiveLiteral literalWithString:@"pick"] discard]];
    [s add:[[PKCaseInsensitiveLiteral literalWithString:@"carrier"] discard]];
    [s add:[[PKCaseInsensitiveLiteral literalWithString:@"from"] discard]];
    [s add:[self location]];
    [s setAssembler:self selector:@selector(parser:didMatchPickCommand:)];
    return s;
}


- (PKParser *)placeCommand {
    PKSequence *s = [PKSequence sequence];
    [s add:[[PKCaseInsensitiveLiteral literalWithString:@"place"] discard]];
    [s add:[[PKCaseInsensitiveLiteral literalWithString:@"carrier"] discard]];
    [s add:[[PKCaseInsensitiveLiteral literalWithString:@"at"] discard]];
    [s add:[self location]];
    [s setAssembler:self selector:@selector(parser:didMatchPlaceCommand:)];
    return s;
}


- (PKParser *)scanCommand {
    PKSequence *s = [PKSequence sequence];
    [s add:[[PKCaseInsensitiveLiteral literalWithString:@"scan"] discard]];
    [s add:[self location]];
    [s setAssembler:self selector:@selector(parser:didMatchScanCommand:)];
    return s;
}


- (PKParser *)command {
    PKAlternation *a = [PKAlternation alternation];
    [a add:[self pickCommand]];
    [a add:[self placeCommand]];
    [a add:[self scanCommand]];
    return a;
}


- (void)testPick {
    NSString *s1 = @"pick carrier from LINE_IN";
    
    PKTokenAssembly *a = [PKTokenAssembly assemblyWithString:s1];
    PKParser *p = [self command];
    PKAssembly *result = [p bestMatchFor:a];

    TDNotNil(result);
    TDEqualObjects(@"[]pick/carrier/from/LINE_IN^", [result description]);

    id target = result.target;
    TDNotNil(target);
    TDEqualObjects(@"pick LINE_IN", [target description]);
}


- (void)testPlace {
    NSString *s2 = @"place carrier at LINE_OUT";
    
    PKTokenAssembly *a = [PKTokenAssembly assemblyWithString:s2];
    PKParser *p = [self command];
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[]place/carrier/at/LINE_OUT^", [result description]);

    id target = result.target;
    TDNotNil(target);
    TDEqualObjects(@"place LINE_OUT", [target description]);
}


- (void)testScan {
    NSString *s3 = @"scan DB101_OUT";
    
    PKTokenAssembly *a = [PKTokenAssembly assemblyWithString:s3];
    PKParser *p = [self command];
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[]scan/DB101_OUT^", [result description]);

    id target = result.target;
    TDNotNil(target);
    TDEqualObjects(@"scan DB101_OUT", [target description]);
}


- (void)parser:(PKParser *)p didMatchPickCommand:(PKAssembly *)a {
    RobotPickCommand *c = [[[RobotPickCommand alloc] init] autorelease];
    PKToken *location = [a pop];
    c.location = location.stringValue;
    a.target = c;
}


- (void)parser:(PKParser *)p didMatchPlaceCommand:(PKAssembly *)a {
    RobotPlaceCommand *c = [[[RobotPlaceCommand alloc] init] autorelease];
    PKToken *location = [a pop];
    c.location = location.stringValue;
    a.target = c;
}


- (void)parser:(PKParser *)p didMatchScanCommand:(PKAssembly *)a {
    RobotScanCommand *c = [[[RobotScanCommand alloc] init] autorelease];
    PKToken *location = [a pop];
    c.location = location.stringValue;
    a.target = c;
}

@end
