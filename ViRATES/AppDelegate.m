//
//  AppDelegate.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/06/29.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "AppDelegate.h"
#import "ArticleViewController.h"
#import "Article.h"
#import "GunosyAds.h"
#import <AVFoundation/AVFoundation.h>

#import <Pushwoosh/PushNotificationManager.h>

@interface AppDelegate () <PushNotificationDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    PushNotificationManager * pushManager = [PushNotificationManager pushManager];
    pushManager.delegate = self;
    // handling push on app start
    [[PushNotificationManager pushManager] handlePushReceived:launchOptions];
    // make sure we count app open in Pushwoosh stats
    [[PushNotificationManager pushManager] sendAppOpen];
    // register for push notifications!
    [[PushNotificationManager pushManager] registerForPushNotifications];

    [[GunosyAds sharedManager] setVerbose:YES];
    [[GunosyAds sharedManager] setMediaID:@"532"];
    [[GunosyAds sharedManager] setMediaUserID:@"ViRATES_IOS"];
    [[GunosyAds sharedManager] setImagePreloadingEnabled:NO];


    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[GunosyAds sharedManager] becomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSDictionary *pushDict = [userInfo objectForKey:@"aps"];
    BOOL isSilentPush = [[pushDict objectForKey:@"content-available"] boolValue];

    if (application.applicationState != UIApplicationStateActive){
        if (isSilentPush) {
            //NSLog(@"Silent push notification:%@", userInfo);

            //load content here

            completionHandler(UIBackgroundFetchResultNewData);
        }
        else {
            [[PushNotificationManager pushManager] handlePushReceived:userInfo];

            completionHandler(UIBackgroundFetchResultNoData);
        }
    }


    NSString *acceptString = [userInfo objectForKey:@"u"];
    if([acceptString length] > 10) {
        [PushNotificationManager clearNotificationCenter];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[acceptString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        ArticleViewController *articleView = [[ArticleViewController alloc] initWithNibName:nil bundle:nil];

        NSArray *tmpArray = [[json objectForKey:@"url"] componentsSeparatedByString:@"/"];
        Article *article = [[Article alloc] init];
        article.aId = (NSNumber *)[[tmpArray objectAtIndex:4] substringFromIndex:2];
        article.link = [json objectForKey:@"url"];
        articleView.pushOrWidget = YES;
        articleView.currentArticle = article;

        NavigationController *nav = [[NavigationController alloc] initWithRootViewController:articleView];
        [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
    }
}

// system push notification registration success callback, delegate to pushManager
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

// system push notifications callback, delegate to pushManager
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}


@end
