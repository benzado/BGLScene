//
//  BGLButton.h
//  FingerPaintBall
//
//  Created by Benjamin Ragheb on 10/15/10.
//  Copyright 2010 Heroic Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGLNode.h"
#import "Touchable.h"
#import "BGLUtilities.h"
#import "BGLMatrix.h"


@interface BGLButton : BGLNode <Touchable> {
    CGRect frame;
    id target;
    SEL touchDownAction;
    SEL touchUpInsideAction;
    BOOL enabled;
    BOOL highlighted;
    BGLColor color;
    float vertexPositions[8];
}
@property (nonatomic) CGRect frame;
@property (nonatomic) BGLColor color;
@property (nonatomic, retain) id target;
@property (nonatomic) SEL touchDownAction;
@property (nonatomic) SEL touchUpInsideAction;
@property (nonatomic,readonly,getter=isHighlighted) BOOL highlighted;
@property (nonatomic,getter=isEnabled) BOOL enabled;
@end
