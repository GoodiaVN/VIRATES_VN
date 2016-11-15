//
//  ArticleFavorite.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/31.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"
@interface ArticleFavorite : NSObject
+ (NSArray *)getAllFavorites;
+ (void)addFavoriteWithArticle:(Article *)article complete:(void (^)(BOOL success, NSString *message, NSArray *favoriteList))addFavoriteBlock;
+ (void)removeFavoriteWithArticleArray:(NSArray *)articleArray complete:(void (^)(BOOL success, NSString *message, NSArray *favoriteList))removeFavoriteBlock;

@end
