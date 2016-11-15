//
//  ActionViewController.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/10/15.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ActionViewController;

@protocol ActionViewDelegete <NSObject>
@optional
- (void)actionView:(ActionViewController *)actionSheetCtrl didSelectMenuAtIndex:(NSInteger)index;
@end

@interface ActionViewController : UIViewController

@property (nonatomic, assign) id<ActionViewDelegete> delegate;
@property (nonatomic, readonly) BOOL isShowing;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                       rootView:(UIView *)rootView;

- (void)showMenu;
- (void)hideMenu;
@end
