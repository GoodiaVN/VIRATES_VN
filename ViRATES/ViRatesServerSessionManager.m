//
//  ViRatesServerSessionManager.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/07.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ViRatesServerSessionManager.h"

@implementation ViRatesServerSessionManager

- (nullable NSURLSessionDataTask *)progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                    success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                    failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {
    if (self.method == NetworkMethodGet) {
        return [self GET:self.URLString parameters:self.parameters progress:uploadProgress success:success failure:failure];
    }
    return [self POST:self.URLString parameters:self.parameters progress:uploadProgress success:success failure:failure];
}

@end
