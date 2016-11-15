//
//  TagListView.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/29.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TagView;
@class TagListView;

@protocol TagListViewDelegate <NSObject>
@optional
- (void)tagPressedWithTitle:(NSString *)title tagView:(TagView *)tagView tagListView:(TagListView *)tagListView;
- (void)tagRemoveButtonPressedWithTitle:(NSString *)title tagView:(TagView *)tagView tagListView:(TagListView *)tagListView;
@end

IB_DESIGNABLE

@interface TagListView : UIView

@property (nonatomic) IBInspectable UIColor *textColor;
@property (nonatomic) IBInspectable UIColor *selectedTextColor;
@property (nonatomic) IBInspectable UIColor *tagBackgroundColor;
@property (nonatomic) IBInspectable UIColor *tagHighlightedBackgroundColor;
@property (nonatomic) IBInspectable UIColor *tagSelectedBackgroundColor;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable UIColor *selectedBorderColor;
@property (nonatomic) IBInspectable CGFloat paddingY;
@property (nonatomic) IBInspectable CGFloat paddingX;
@property (nonatomic) IBInspectable CGFloat marginY;
@property (nonatomic) IBInspectable CGFloat marginX;
@property (nonatomic) UIFont *textFont;

@property (nonatomic) IBInspectable BOOL enableRemoveButton;
@property (nonatomic) IBInspectable CGFloat removeButtonIconSize;
@property (nonatomic) IBInspectable CGFloat removeIconLineWidth;
@property (nonatomic) IBInspectable UIColor *removeIconLineColor;

@property (nonatomic, assign) id<TagListViewDelegate> delegate;

// Delegate variables
@property (nonatomic) CGFloat tagViewHeight;
@property (nonatomic) NSMutableArray *tagViews;
@property (nonatomic) int rows;

- (TagView *)addTag:(NSString *)title;
- (void)removeTag:(NSString *)title;
- (void)removeTheMostOldestTag;
- (void)removeAllTags;

@end
