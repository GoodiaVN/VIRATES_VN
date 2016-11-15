//
//  TagView.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/28.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "TagView.h"
#import "CloseButton.h"

@implementation TagView

@synthesize cornerRadius = _cornerRadius;
@synthesize borderWidth = _borderWidth;
@synthesize textColor =_textColor;
@synthesize selectedTextColor = _selectedTextColor;
@synthesize paddingY = _paddingY;
@synthesize paddingX = _paddingX;
@synthesize tagBackgroundColor = _tagBackgroundColor;
@synthesize textFont = _textFont;

@synthesize enableRemoveButton = _enableRemoveButton;
@synthesize removeButtonIconSize = _removeButtonIconSize;
@synthesize removeIconLineWidth = _removeIconLineWidth;
@synthesize removeIconLineColor = _removeIconLineColor;

#pragma mark - init

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectZero];
    if(self) {
        [self setTitle:title forState:UIControlStateNormal];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self setupDefaultValue];
    CGSize intrinsicSize = [self intrinsicContentSize];
    self.frame = CGRectMake(0, 0, intrinsicSize.width, intrinsicSize.height);
    self.removeButton = [[CloseButton alloc] init];
    [self addSubview:self.removeButton];
    self.removeButton.tagView   = self;
}

- (void)setupDefaultValue {
    self.cornerRadius = 0;
    self.borderWidth = 0;
    self.textColor = [UIColor whiteColor];
    self.selectedTextColor = [UIColor whiteColor];
    self.paddingY = 2;
    self.paddingX = 5;
    self.tagBackgroundColor = [UIColor grayColor];
    self.textFont = [UIFont systemFontOfSize:16];
    self.enableRemoveButton = NO;
    self.removeButtonIconSize = 6;
    self.removeIconLineWidth = 3;
    self.removeIconLineColor = [[UIColor whiteColor] colorWithAlphaComponent:0.54];
}


#pragma mark - layout
- (void)updateRightInsets {

    UIEdgeInsets insets = [self titleEdgeInsets];
    if( _enableRemoveButton ){
        insets.right = _paddingX + _removeButtonIconSize + _paddingX;
    } else {
        insets.right = _paddingX;
    }

    [self setTitleEdgeInsets:insets];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];

    size.height = self.titleLabel.font.pointSize + _paddingY * 2;
    size.width += _paddingX * 2;

    if( _enableRemoveButton ) {
        size.width += _removeButtonIconSize + _paddingX;
    }

    return size;
}

- (void)reloadStyles {
    if( self.highlighted ) {
        if( self.highlightedBackgroundColor != nil ) {
            self.backgroundColor = self.highlightedBackgroundColor;
        }
    } else if( self.selected ) {
        self.backgroundColor = (self.selectedBackgroundColor != nil) ? self.selectedBackgroundColor : self.tagBackgroundColor;
        if(self.selectedBorderColor != nil){
            self.layer.borderColor = self.selectedBorderColor.CGColor;
        } else if(self.borderColor != nil){
            self.layer.borderColor = self.borderColor.CGColor;
        }

        [self setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
    } else {
        self.backgroundColor = self.tagBackgroundColor;
        if(self.borderColor != nil) {
            self.layer.borderColor = self.borderColor.CGColor;
        }
        [self setTitleColor:self.textColor forState:UIControlStateNormal];
    }
}

# pragma mark - Setters

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = self.cornerRadius > 0;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self reloadStyles];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self reloadStyles];
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    _selectedTextColor = selectedTextColor;
    [self reloadStyles];
}

- (void)setPaddingY:(CGFloat)paddingY {
    _paddingY = paddingY;
    UIEdgeInsets insets = [self titleEdgeInsets];
    insets.top = paddingY;
    insets.bottom = paddingY;
    [self setTitleEdgeInsets:insets];
}

- (void)setPaddingX:(CGFloat)paddingX {
    _paddingX = paddingX;
    UIEdgeInsets insets = [self titleEdgeInsets];
    insets.left = paddingX;
    [self setTitleEdgeInsets:insets];
    [self updateRightInsets];
}

- (void)setTagBackgroundColor:(UIColor *)tagBackgroundColor {
    _tagBackgroundColor = tagBackgroundColor;
    [self reloadStyles];
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    [self reloadStyles];
}

- (void)setSelectedBorderColor:(UIColor *)selectedBorderColor {
    _selectedBorderColor = selectedBorderColor;
    [self reloadStyles];
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    _selectedBackgroundColor = selectedBackgroundColor;
    [self reloadStyles];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    [self.titleLabel setFont:textFont];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self reloadStyles];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self reloadStyles];
}

- (void)setEnableRemoveButton:(BOOL)enableRemoveButton {
    _enableRemoveButton = enableRemoveButton;
    self.removeButton.hidden = !enableRemoveButton;
    if( enableRemoveButton ){
        CGRect frame = self.removeButton.frame;
        frame.size.width = _paddingX + _removeButtonIconSize + _paddingX;
        frame.size.height = self.frame.size.height;
        frame.origin.x = self.frame.size.width - _removeButtonIconSize;
        frame.origin.y = 0;
        self.removeButton.frame = frame;
    }
    [self updateRightInsets];
}

- (void)setRemoveButtonIconSize:(CGFloat)removeButtonIconSize {
    _removeButtonIconSize = removeButtonIconSize;
    self.removeButton.iconSize = removeButtonIconSize;
    [self updateRightInsets];
}

- (void)setRemoveIconLineWidth:(CGFloat)removeIconLineWidth {
    _removeIconLineWidth = removeIconLineWidth;
    self.removeButton.lineWidth = removeIconLineWidth;
}

- (void)setRemoveIconLineColor:(UIColor *)removeIconLineColor {
    _removeIconLineColor = removeIconLineColor;
    self.removeButton.lineColor = removeIconLineColor;
}



@end
