//
//  TagListView.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/29.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "TagListView.h"
#import "TagView.h"
#import "CloseButton.h"

@implementation TagListView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setupDefaultValue];
    }
    return self;
}


- (void)setupDefaultValue {
    self.cornerRadius = 0;
    self.borderWidth = 0;
    self.textColor = [UIColor whiteColor];
    self.selectedTextColor = [UIColor whiteColor];
    self.paddingY = 2;
    self.paddingX = 5;
    self.marginY = 2;
    self.marginX = 5;
    self.tagBackgroundColor = [UIColor grayColor];
    self.textFont = [UIFont systemFontOfSize:16];
    self.enableRemoveButton = NO;
    self.removeButtonIconSize = 6;
    self.removeIconLineWidth = 1;
    self.removeIconLineColor = [[UIColor whiteColor] colorWithAlphaComponent:0.54];
}

- (NSMutableArray *)tagViews {
    if(!_tagViews) {
        [self setTagViews:[[NSMutableArray alloc] init]];
    }
    return _tagViews;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    for(TagView *tagView in [self tagViews]) {
        [tagView setTextColor:textColor];
    }
}

- (void)setTagBackgroundColor:(UIColor *)tagBackgroundColor {
    _tagBackgroundColor = tagBackgroundColor;
    for(TagView *tagView in [self tagViews]) {
        [tagView setBackgroundColor:tagBackgroundColor];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    for(TagView *tagView in [self tagViews]) {
        [tagView setCornerRadius:cornerRadius];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    for(TagView *tagView in [self tagViews]) {
        [tagView setBorderWidth:borderWidth];
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    for(TagView *tagView in [self tagViews]) {
        [tagView setBorderColor:borderColor];
    }
}

- (void)setPaddingY:(CGFloat)paddingY {
    _paddingY = paddingY;
    for(TagView *tagView in [self tagViews]) {
        [tagView setPaddingY:paddingY];
    }
}

- (void)setPaddingX:(CGFloat)paddingX {
    _paddingX = paddingX;
    for(TagView *tagView in [self tagViews]) {
        [tagView setPaddingX:paddingX];
    }
}

- (void)setMarginY:(CGFloat)marginY {
    _marginY = marginY;
    [self rearrangeViews];
}

- (void)setMarginX:(CGFloat)marginX {
    _marginX = marginX;
    [self rearrangeViews];
}

- (void)setEnableRemoveButton:(BOOL)enableRemoveButton {
    _enableRemoveButton = enableRemoveButton;
    for(TagView *tagView in [self tagViews]) {
        [tagView setEnableRemoveButton:enableRemoveButton];
    }
    [self rearrangeViews];
}

- (void)setRemoveButtonIconSize:(CGFloat)removeButtonIconSize {
    _removeButtonIconSize = removeButtonIconSize;
    for(TagView *tagView in [self tagViews]) {
        [tagView setRemoveButtonIconSize:removeButtonIconSize];
    }
    [self rearrangeViews];
}

- (void)setRemoveIconLineWidth:(CGFloat)removeIconLineWidth {
    _removeIconLineWidth = removeIconLineWidth;
    for(TagView *tagView in [self tagViews]) {
        [tagView setRemoveIconLineWidth:removeIconLineWidth];
    }
    [self rearrangeViews];
}

- (void)setRemoveIconLineColor:(UIColor *)removeIconLineColor {
    _removeIconLineColor = removeIconLineColor;
    for(TagView *tagView in [self tagViews]) {
        [tagView setRemoveIconLineColor:removeIconLineColor];
    }
    [self rearrangeViews];
}

- (void)setRows:(int)rows {
    _rows = rows;
    [self invalidateIntrinsicContentSize];
}

# pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self rearrangeViews];
}

- (void)rearrangeViews {
    for(TagView *tagView in [self tagViews]) {
        [tagView removeFromSuperview];
    }

    int currentRow = 0;
    int currentRowTagCount = 0;
    CGFloat currentRowWidth = 0;
    for(TagView *tagView in [self tagViews]) {
        CGRect tagViewFrame = [tagView frame];
        tagViewFrame.size = [tagView intrinsicContentSize];
        [tagView setFrame:tagViewFrame];
        self.tagViewHeight = tagViewFrame.size.height;

        if (currentRowTagCount == 0 || (currentRowWidth + tagView.frame.size.width + [self marginX] + ( self.enableRemoveButton ? self.removeButtonIconSize : 0)) > self.frame.size.width) {
            currentRow += 1;
            CGRect tempFrame = [tagView frame];
            tempFrame.origin.x = 0;
            tempFrame.origin.y = (currentRow - 1) * ([self tagViewHeight] + [self marginY]);
            [tagView setFrame:tempFrame];

            currentRowTagCount = 1;
            currentRowWidth = tagView.frame.size.width + [self marginX];
        } else {
            CGRect tempFrame = [tagView frame];
            tempFrame.origin.x = currentRowWidth;
            tempFrame.origin.y = (currentRow - 1) * ([self tagViewHeight] + [self marginY]);
            [tagView setFrame:tempFrame];

            currentRowTagCount += 1;
            currentRowWidth += tagView.frame.size.width + [self marginX];
        }

        [self addSubview:tagView];
    }
    self.rows = currentRow;
}

# pragma mark - Manage tags

- (CGSize) intrinsicContentSize {
    CGFloat height = [self rows] * ([self tagViewHeight] + [self marginY]);
    if([self rows] > 0) {
        height -= [self marginY];
    }
    return CGSizeMake(self.frame.size.width, height);
}

- (TagView *)addTag:(NSString *)title {
    TagView *tagView = [[TagView alloc] initWithTitle:title];

    [tagView setTextColor: [self textColor]];
    [tagView setTagBackgroundColor: [self tagBackgroundColor]];
    [tagView setCornerRadius: [self cornerRadius]];
    [tagView setBorderWidth: [self borderWidth]];
    [tagView setBorderColor: [self borderColor]];
    [tagView setPaddingY: [self paddingY]];
    [tagView setPaddingX: [self paddingX]];
    [tagView setTextFont: [self textFont]];
    [tagView setRemoveIconLineWidth:[self removeIconLineWidth]];
    [tagView setRemoveButtonIconSize:[self removeButtonIconSize]];
    [tagView setEnableRemoveButton:[self enableRemoveButton]];
    [tagView setRemoveIconLineColor:[self removeIconLineColor]];

    [tagView addTarget:self action:@selector(tagPressed:) forControlEvents:UIControlEventTouchUpInside];
    [tagView.removeButton addTarget:self action:@selector(removeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self addTagView: tagView];

    return tagView;
}

- (void)addTagView:(TagView *)tagView {
    [[self tagViews] insertObject:tagView atIndex:0];
    [self rearrangeViews];
}

- (void)removeTag:(NSString *)title {
    // Author's note: Loop the array in reversed order to remove items during loop
    for(int index = (int)[[self tagViews] count] - 1 ; index >= 0; index--) {
        TagView *tagView = [[self tagViews] objectAtIndex:index];
        if([[tagView currentTitle] isEqualToString:title]) {
            [tagView removeFromSuperview];
            [[self tagViews] removeObjectAtIndex:index];
        }
    }
}

- (void)removeTheMostOldestTag {
    if([[self tagViews] count] > 0) {
        TagView *tagView = [[self tagViews] objectAtIndex:0];
        [tagView removeFromSuperview];
        [[self tagViews] removeLastObject];
    }
}

- (void)removeAllTags {
    for(TagView *tagView in [self tagViews]) {
        [tagView removeFromSuperview];
    }
    [self setTagViews:[[NSMutableArray alloc] init]];
    [self rearrangeViews];
}

#pragma mark Event

- (void)tagPressed:(TagView *)sender {
    if (sender.onTap) {
        sender.onTap(sender);
    }
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(tagPressedWithTitle:tagView:tagListView:)] ){
        [self.delegate tagPressedWithTitle:sender.currentTitle tagView:sender tagListView:self];
    }
}

- (void)removeButtonPressed:(CloseButton *)closeButton {
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(tagRemoveButtonPressedWithTitle:tagView:tagListView:)] ) {
        TagView *tagView = closeButton.tagView;
        [self.delegate tagRemoveButtonPressedWithTitle:tagView.currentTitle tagView:tagView tagListView:self];
    }
}
@end
