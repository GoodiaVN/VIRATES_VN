//
//  ViRatesServerClient.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/07.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViRatesServerConfiguration.h"
#import "ViRatesServerRespons.h"
#import "ViRatesServerSessionManager.h"

#import "ViRatesServerArticleRequest.h"
#import "ViRatesServerFavoriteArticleRequest.h"
#import "ViRatesServerHistoryArticleRequest.h"
#import "ViRatesServerSendCommentRequest.h"

@interface ViRatesServerClient : NSObject

@property (nonatomic, strong) NSString *baseURIString;

+ (instancetype)sharedInstance;

- (ViRatesServerSessionManager *)sendFavoriteArticleRequest:(ViRatesServerFavoriteArticleRequest *)request withArticlePathId:(NSString *)idPath;

- (ViRatesServerSessionManager *)sendHistoryArticleRequest:(ViRatesServerHistoryArticleRequest *)request withArticlePathId:(NSString *)idPath;

- (ViRatesServerSessionManager *)sendArticleDetailRequest:(ViRatesServerArticleRequest *)request withURLPath:(NSString *)urlPath;

- (ViRatesServerSessionManager *)sendSearchArticleRequest:(ViRatesServerArticleRequest *)request withURLPath:(NSString *)urlPath;

- (ViRatesServerSessionManager *)sendCommentRequest:(ViRatesServerSendCommentRequest *)request;

- (ViRatesServerSessionManager *)sendCategoryRequest;

- (ViRatesServerSessionManager *)sendArticleDetailRequestWithURLPath:(NSString *)urlPathString;

- (ViRatesServerSessionManager *)sendKeywordRequest;

@end
