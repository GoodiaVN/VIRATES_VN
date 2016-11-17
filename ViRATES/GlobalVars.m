//
//  GlobalVars.m
//  ViRATES
//
//  Created by Han Pham Xuan on 11/17/16.
//  Copyright © 2016 hunting. All rights reserved.
//

#import "GlobalVars.h"

@implementation GlobalVars
+ (GlobalVars *)sharedInstance {
    static dispatch_once_t onceToken;
    static GlobalVars *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[GlobalVars alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _isShowNaviBar = YES;
    }
    return self;
}

@end
