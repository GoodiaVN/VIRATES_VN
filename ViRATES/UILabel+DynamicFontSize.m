//
//  UILabel+DynamicFontSize.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/09/26.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "UILabel+DynamicFontSize.h"
#import <FXLabel/FXLabel.h>

@implementation UILabel (DynamicFontSize)
#define CATEGORY_DYNAMIC_FONT_SIZE_MAXIMUM_VALUE 18
#define CATEGORY_DYNAMIC_FONT_SIZE_MINIMUM_VALUE 8

-(void) adjustFontSizeToFillItsContents
{
    NSString* text = self.text;

    for (int i = CATEGORY_DYNAMIC_FONT_SIZE_MAXIMUM_VALUE; i>CATEGORY_DYNAMIC_FONT_SIZE_MINIMUM_VALUE; i--) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        UIFont *font = [UIFont fontWithName:self.font.fontName size:(CGFloat)i];

        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByWordWrapping];
        [style setAlignment:NSTextAlignmentRight];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font,NSParagraphStyleAttributeName:style}];

        CGRect rectSize = [attributedText boundingRectWithSize:CGSizeMake(screenRect.size.width-24, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        if (ceil(rectSize.size.height) <= 64/*ラベルの高さ*/) {
            self.font = [UIFont fontWithName:self.font.fontName size:(CGFloat)i-1];
            break;
        }
    }
}
@end
