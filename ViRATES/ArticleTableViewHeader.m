//
//  ArticleTableViewHeader.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/04.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ArticleTableViewHeader.h"

#define kShadowColor    [UIColor blackColor]
#define kShadowOffset   CGSizeMake(0.0f, 0.0f)
#define kShadowBlur1    4.5
#define kShadowBlur2    2

@implementation ArticleTableViewHeader

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.shadowColor     = nil;
    self.titleLabel.shadowOffset    = kShadowOffset;
    self.titleLabel.shadowColor     = kShadowColor;
    self.titleLabel.shadowBlur      = kShadowBlur1;
    self.titleLabel.lineSpacing     = 0.3;
}

+ (instancetype)view {
    NSString *className = NSStringFromClass([self class]);
    return [[[NSBundle mainBundle] loadNibNamed:className owner:nil options:0] firstObject];
}

@end
