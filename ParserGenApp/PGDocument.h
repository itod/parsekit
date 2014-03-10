//
//  PGDocument.h
//  ParserGenApp
//
//  Created by Todd Ditchendorf on 4/15/13.
//
//

#import <Cocoa/Cocoa.h>

@interface PGDocument : NSDocument

- (IBAction)generate:(id)sender;
- (IBAction)browse:(id)sender;
- (IBAction)reveal:(id)sender;

@property (nonatomic, copy) NSString *destinationPath;
@property (nonatomic, copy) NSString *parserName;
@property (nonatomic, copy) NSString *grammar;
@property (nonatomic, assign) BOOL busy;
@property (nonatomic, retain) NSError *error;

@property (nonatomic, assign) BOOL enableARC;
@property (nonatomic, assign) BOOL enableHybridDFA;
@property (nonatomic, assign) BOOL enableMemoization;
@property (nonatomic, assign) BOOL enableAutomaticErrorRecovery;
@property (nonatomic, assign) NSInteger preassemblerSettingBehavior;
@property (nonatomic, assign) NSInteger assemblerSettingBehavior;

@property (nonatomic, retain) IBOutlet NSTextView *textView;
@end
