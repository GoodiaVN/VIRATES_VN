//
//  ViRatesServerSessionManager.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/07.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger, NetworkMethod) {
    NetworkMethodNone,
    NetworkMethodGet,
    NetworkMethodPost
};

NS_ASSUME_NONNULL_BEGIN

@interface ViRatesServerSessionManager : AFHTTPSessionManager

@property (nonatomic, strong)  NSString* URLString;
@property (nonatomic, strong) id parameters;
@property (nonatomic) NetworkMethod method;


- (nullable NSURLSessionDataTask *)progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                    success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END