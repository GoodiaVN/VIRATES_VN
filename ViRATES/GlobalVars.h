//
//  GlobalVars.h
//  ViRATES
//
//  Created by Han Pham Xuan on 11/17/16.
//  Copyright © 2016 hunting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalVars : NSObject

+ (GlobalVars *)sharedInstance;

@property(nonatomic, readwrite) BOOL isShowNaviBar;
@end
