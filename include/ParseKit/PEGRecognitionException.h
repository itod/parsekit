//
//  PEGRecognitionException.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/28/13.
//
//

#import <Foundation/Foundation.h>

@interface PEGRecognitionException : NSException

- (id)init; // use me

@property (nonatomic, retain) NSString *currentReason;
@end
