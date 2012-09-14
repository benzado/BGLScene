//
//  BGLTextNode.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/22/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGLNode.h"
#import "BGLFont.h"
#import "BGLMatrix.h"
#import "BGLUtilities.h"

@class BGLAnimation;

@interface BGLTextNode : BGLNode {
    BGLFontRef font;
    BGLTextRef text;
    BGLColor color;
}
@property (nonatomic) BGLColor color;
@property (nonatomic,readonly) float width;
@property (nonatomic,readonly) float height;
- (id)initWithFontName:(NSString *)fontName;
- (void)setString:(NSString *)string;
- (BGLAnimation *)pulseAnimation;
- (void)centerAt:(BGLVector3)position;
- (void)leftAlignAt:(BGLVector3)position;
- (void)rightAlignAt:(BGLVector3)position;
@end
