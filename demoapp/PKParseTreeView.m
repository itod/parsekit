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

#import "PKParseTreeView.h"
#import <ParseKit/ParseKit.h>
#import "PKParseTree.h"
#import "PKRuleNode.h"
#import "PKTokenNode.h"
#import "PKParseTreeAssembler.h"

#define ROW_HEIGHT 50.0
#define CELL_WIDTH 55.0

#define LABEL_MARGIN_Y -2.0

#define FUDGE 0.5
#define PKAlign(x) (floor((x)) + FUDGE)

@interface PKParseTreeView ()
- (void)drawTree:(PKParseTree *)n atPoint:(NSPoint)p;
- (void)drawParentNode:(PKParseTree *)n atPoint:(NSPoint)p;
- (void)drawLeafNode:(PKTokenNode *)n atPoint:(NSPoint)p;

- (PKFloat)widthForNode:(PKParseTree *)n;
- (PKFloat)depthForNode:(PKParseTree *)n;
- (NSString *)labelFromNode:(PKParseTree *)n;
- (void)drawLabel:(NSString *)label atPoint:(NSPoint)p withAttrs:(NSDictionary *)attrs;
@end

@implementation PKParseTreeView

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.leafAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSFont boldSystemFontOfSize:10.0], NSFontAttributeName,
                           [NSColor blackColor], NSForegroundColorAttributeName,
                           nil];
        self.parentAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSFont fontWithName:@"Helvetica Neue Italic" size:11.0], NSFontAttributeName,
                           [NSColor blackColor], NSForegroundColorAttributeName,
                           nil];
    }
    return self;
}


- (void)dealloc {
    self.root = nil;
    self.leafAttrs = nil;
    self.parentAttrs = nil;
    [super dealloc];
}


- (BOOL)isFlipped {
    return YES;
}


- (void)drawParseTree:(PKParseTree *)t {
    self.root = t;
    
    PKFloat w = [self widthForNode:_root] * CELL_WIDTH;
    PKFloat h = [self depthForNode:_root] * ROW_HEIGHT + 120.0;
    
    NSSize minSize = [[self superview] bounds].size;
    w = w < minSize.width ? minSize.width : w;
    h = h < minSize.height ? minSize.height : h;
    [self setFrame:NSMakeRect(0.0, 0.0, w, h)];
    
//    NSRect visRect = [self visibleRect];
//    visRect.origin.x = w / 2.0 - visRect.size.width / 2.0;
//    [self scrollRectToVisible:visRect];
    
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];
    
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
    
    if (_root) {
        [self drawTree:_root atPoint:NSMakePoint(bounds.size.width / 2.0, 20.0)];
    }
}


- (void)drawTree:(PKParseTree *)n atPoint:(NSPoint)p {
    if ([n isKindOfClass:[PKTokenNode class]]) {
        [self drawLeafNode:(id)n atPoint:p];
    } else {
        [self drawParentNode:n atPoint:p];
    }
}


- (void)drawParentNode:(PKParseTree *)n atPoint:(NSPoint)p {
    // draw own label
    [self drawLabel:[self labelFromNode:n] atPoint:NSMakePoint(p.x, p.y) withAttrs:_parentAttrs];

    NSUInteger i = 0;
    NSUInteger c = [[n children] count];

    // get total width
    PKFloat widths[c];
    PKFloat totalWidth = 0.0;
    for (PKParseTree *child in [n children]) {
        widths[i] = [self widthForNode:child] * CELL_WIDTH;
        totalWidth += widths[i++];
    }
    
    
    // draw children
    NSPoint points[c];
    if (1 == c) {
        points[0] = NSMakePoint((p.x), (p.y + ROW_HEIGHT));
        [self drawTree:[[n children] objectAtIndex:0] atPoint:points[0]];
    } else {
        PKFloat x = 0.0;
        PKFloat buff = 0.0;
        for (i = 0; i < c; i++) {
            x = p.x - (totalWidth / 2.0) + buff + (widths[i] / 2.0);
            buff += widths[i];

            points[i] = NSMakePoint((x), (p.y + ROW_HEIGHT));
            [self drawTree:[[n children] objectAtIndex:i] atPoint:points[i]];
        }
    }
    
    // draw lines
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    for (i = 0; i < c; i++) {
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, PKAlign(p.x), PKAlign(p.y + 15.0));
        CGContextAddLineToPoint(ctx, PKAlign(points[i].x), PKAlign(points[i].y - 4.0));
        CGContextStrokePath(ctx);
    }
}


- (void)drawLeafNode:(PKTokenNode *)n atPoint:(NSPoint)p {
    [self drawLabel:[self labelFromNode:n] atPoint:NSMakePoint(p.x, p.y) withAttrs:_leafAttrs];
}


- (PKFloat)widthForNode:(PKParseTree *)n {
    PKFloat res = 0.0;
    for (PKParseTree *child in [n children]) {
        res += [self widthForNode:child];
    }
    return res ? res : 1.0;
}
    
    
- (PKFloat)depthForNode:(PKParseTree *)n {
    PKFloat res = 0.0;
    for (PKParseTree *child in [n children]) {
        PKFloat n = [self depthForNode:child];
        res = n > res ? n : res;
    }
    return res + 1.0;
}


- (NSString *)labelFromNode:(PKParseTree *)n {
    if ([n isKindOfClass:[PKTokenNode class]]) {
        return [[(PKTokenNode *)n token] stringValue];
    } else if ([n isKindOfClass:[PKRuleNode class]]) {
        return [(PKRuleNode *)n name];
    } else {
        return @"root";
    }
}


- (void)drawLabel:(NSString *)label atPoint:(NSPoint)p withAttrs:(NSDictionary *)attrs {
    NSSize labelSize = [label sizeWithAttributes:attrs];
    NSRect maxRect = NSMakeRect(p.x - CELL_WIDTH / 2.0, p.y, CELL_WIDTH, labelSize.height);
    
    if (!NSContainsRect(maxRect, NSMakeRect(maxRect.origin.x, maxRect.origin.y, labelSize.width, labelSize.height))) {
        labelSize = maxRect.size;
    }
    
    p.x -= labelSize.width / 2.0;
    NSRect r = NSMakeRect(p.x, p.y + LABEL_MARGIN_Y, labelSize.width, labelSize.height);
    NSUInteger opts = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin;
    [label drawWithRect:r options:opts attributes:attrs];
}

@end
