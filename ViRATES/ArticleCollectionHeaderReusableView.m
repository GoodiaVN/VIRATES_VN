//
//  ArticleCollectionHeaderReusableView.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/02.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ArticleCollectionHeaderReusableView.h"

#define kShadowColor    [UIColor blackColor]
#define kShadowOffset   CGSizeMake(0.0f, 0.0f)
#define kShadowBlur1    4.5
#define kShadowBlur2    2

@implementation ArticleCollectionHeaderReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.totalCommentLabel.text     = @"0";

    self.titleLabel.shadowColor     = nil;
    self.titleLabel.shadowOffset    = kShadowOffset;
    self.titleLabel.shadowColor     = kShadowColor;
    self.titleLabel.shadowBlur      = kShadowBlur1;
    self.titleLabel.lineSpacing     = 0.3;

    self.totalCommentLabel.shadowColor  = nil;
    self.totalCommentLabel.shadowOffset = kShadowOffset;
    self.totalCommentLabel.shadowColor  = kShadowColor;
    self.totalCommentLabel.shadowBlur   = kShadowBlur2;
}

@end
