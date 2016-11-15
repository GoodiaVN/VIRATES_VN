//
//  ViRatesServerClient.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/07.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ViRatesServerClient.h"
#import "ViRatesServerRequest.h"

@implementation ViRatesServerClient

- (instancetype)init {
    self = [super init];
    self.baseURIString = VIRATES_SERVER_BASE_URL;
    return self;
}


+ (instancetype)sharedInstance {
    static ViRatesServerClient* client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [self new];
    });
    return client;
}

- (ViRatesServerSessionManager *)createSessionWithURLString:(NSString*)urlString parameters:(ViRatesServerRequest *)request {
    ViRatesServerSessionManager *sessionManager = [ViRatesServerSessionManager manager];

    sessionManager.URLString = [self.baseURIString stringByAppendingString:urlString];
    sessionManager.parameters = [request parameters];
    sessionManager.method = NetworkMethodPost;
    sessionManager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    [sessionManager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"text/html", nil]];
    return sessionManager;
}

- (ViRatesServerSessionManager *)sendFavoriteArticleRequest:(ViRatesServerFavoriteArticleRequest *)request withArticlePathId:(NSString *)idPath {
    return [self createSessionWithURLString:[NSString stringWithFormat:@"api_get_favorite.php?id=%@",idPath] parameters:request];
}

- (ViRatesServerSessionManager *)sendHistoryArticleRequest:(ViRatesServerHistoryArticleRequest *)request withArticlePathId:(NSString *)idPath {
     return [self createSessionWithURLString:[NSString stringWithFormat:@"api_get_favorite.php?id=%@",idPath] parameters:request];
}

- (ViRatesServerSessionManager *)sendArticleDetailRequest:(ViRatesServerArticleRequest *)request withURLPath:(NSString *)urlPath {
    return [self createSessionWithURLString:urlPath parameters:request];
}

- (ViRatesServerSessionManager *)sendSearchArticleRequest:(ViRatesServerArticleRequest *)request withURLPath:(NSString *)urlPath {
    return [self createSessionWithURLString:[NSString stringWithFormat:@"?s=%@",urlPath] parameters:request];
}

- (ViRatesServerSessionManager *)sendCommentRequest:(ViRatesServerSendCommentRequest *)request {
    return [self createSessionWithURLString:[NSString stringWithFormat:@"api_comment_post.php"] parameters:request];
}

- (ViRatesServerSessionManager *)sendCategoryRequest{
    return [self createSessionWithURLString:@"api_category_new" parameters:nil];
}

- (ViRatesServerSessionManager *)sendArticleDetailRequestWithURLPath:(NSString *)urlPathString{
    NSArray *pathArray = [urlPathString componentsSeparatedByString:VIRATES_SERVER_BASE_URL];
    NSString *pathURL = [pathArray lastObject];
    return [self createSessionWithURLString:pathURL parameters:nil];
}

- (ViRatesServerSessionManager *)sendKeywordRequest {
    return [self createSessionWithURLString:@"api_get_keyword" parameters:nil];
}

@end
