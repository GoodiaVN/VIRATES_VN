//
//  ActionButtonView.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/10/15.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ActionButtonView.h"

@implementation ActionButtonView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (instancetype)view {
    NSString *className = NSStringFromClass([self class]);
    return [[[NSBundle mainBundle] loadNibNamed:className owner:nil options:0] firstObject];
}


@end
