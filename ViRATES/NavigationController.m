//
//  NavigationController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/31.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "NavigationController.h"
#import "ArticleViewController.h"
#import "AppDelegate.h"

#define DOWNLOADURL @"http://virates.com/download"
@interface NavigationController ()

@end

@implementation NavigationController

-(id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if(self) {

    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotate {
    if ([self.topViewController respondsToSelector:@selector(shouldAutorotate)]) {
        NSString *className = NSStringFromClass([self.topViewController class]);
        if ([className isEqualToString:@"ArticleViewController"]) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if(appDelegate.orientation) {
                return YES;
            }
            return NO;
        }
    }
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskAll;
}

- (void) onDidRegisterForRemoteNotificationsWithDeviceToken:(NSString *)token {
    NSLog(@"token:%@",token);
}

- (void) onDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"error:%@",error);
}


- (void) onTagsReceived:(NSDictionary *)tags {
    NSLog(@"tags:%@",tags);
}

- (void) onTagsFailedToReceive:(NSError *)error {
    NSLog(@"error2:%@",error);
}


@end
