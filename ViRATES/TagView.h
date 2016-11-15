//
//  TagView.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/28.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CloseButton;

@interface TagView : UIButton

- (instancetype) initWithTitle:(NSString *)title;

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *selectedTextColor;
@property (nonatomic) CGFloat paddingY;
@property (nonatomic) CGFloat paddingX;
@property (nonatomic) UIColor *tagBackgroundColor;
@property (nonatomic) UIColor *highlightedBackgroundColor;
@property (nonatomic) UIColor *selectedBorderColor;
@property (nonatomic) UIColor *selectedBackgroundColor;
@property (nonatomic) UIFont  *textFont;

@property (nonatomic) BOOL enableRemoveButton;
@property (nonatomic) CGFloat removeButtonIconSize;
@property (nonatomic) CGFloat removeIconLineWidth;
@property (nonatomic) UIColor *removeIconLineColor;

@property (nonatomic) CloseButton *removeButton;

@property (nonatomic, copy) void (^onTap)(TagView *);

@end