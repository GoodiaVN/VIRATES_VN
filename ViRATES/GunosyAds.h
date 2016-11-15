//
//  GunosyAdsSDK.h
//  GunosyAdsSDK
//
//  Created by Matsumoto Yuki on 2014/02/24.
//  Copyright (c) 2014年 Gunosy inc.,. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNAdvertisement.h"

@interface GunosyAds: NSObject
@property (nonatomic) BOOL verbose;

+ (GunosyAds *)sharedManager;
- (void)becomeActive;
- (void)setMediaID:(NSString *)mediaID;
- (void)setMediaUserID:(NSString *)mediaUserID;
- (void)setImagePreloadingEnabled:(BOOL)enabled;
- (void)sendCustomData:(NSDictionary *)customData;
- (void)getAdvertisementsByFrameId:(NSString *)frameId complete:(void (^)(NSArray *advertisements))complete;
- (NSString *)adIdentifier;
@end
