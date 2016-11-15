//
//  AppDelegate.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/06/29.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) NavigationController *navigationController;

@property(nonatomic) BOOL orientation;


@end

