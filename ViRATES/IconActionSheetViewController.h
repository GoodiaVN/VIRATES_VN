//
//  IconActionSheetViewController.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/03.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IconActionSheetViewController;

@protocol IconActionSheetDelegate <NSObject>
@optional
- (void)didTapBackgroundActionSheet:(IconActionSheetViewController *)actionSheetCtrl;
- (void)actionSheet:(IconActionSheetViewController *)actionSheetCtrl didSelectMenuAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface IconActionMenu : NSObject

- (instancetype)initWithImage:(UIImage *)image
                    menuTitle:(NSString *)menuTitle;

@property (strong, nonatomic) UIImage *iconImage;
@property (strong, nonatomic) NSString *menuTitle;

@end

@interface IconActionSheetViewController : UIViewController


@property (nonatomic, assign) id<IconActionSheetDelegate> delegate;
@property (nonatomic, readonly) BOOL isShowing;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                       rootView:(UIView *)rootView;

- (void)addIconAction:(IconActionMenu *)iconAction;

- (void)showMenu;
- (void)hideMenu;


@end
