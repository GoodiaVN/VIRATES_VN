//
//  CloseButton.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/26.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "CloseButton.h"

@implementation CloseButton
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setupButton];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setupButton];
    }
    return self;
}

- (void)setupButton {
    self.iconSize   = 10.0f;
    self.lineWidth  = 1.0f;
    self.lineColor  = [[UIColor whiteColor] colorWithAlphaComponent:0.54];
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = self.lineWidth;
    path.lineCapStyle = kCGLineCapRound;



    CGRect iconFrame = CGRectMake((rect.size.width - self.iconSize) / 2.0,
                                  (rect.size.height - self.iconSize) / 2.0,
                                  self.iconSize,
                                  self.iconSize);

    [path moveToPoint:iconFrame.origin];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(iconFrame),  CGRectGetMaxY(iconFrame))];
    [path moveToPoint:CGPointMake(CGRectGetMaxX(iconFrame),  CGRectGetMinY(iconFrame))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(iconFrame),  CGRectGetMaxY(iconFrame))];


    [self.lineColor setStroke];
    [path stroke];
}


@end
