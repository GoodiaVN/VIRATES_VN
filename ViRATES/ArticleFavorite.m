//
//  ArticleFavorite.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/31.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ArticleFavorite.h"

@implementation ArticleFavorite

+ (NSArray *)getAllFavorites {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.virates"];
    NSArray *array = [userDefaults arrayForKey:@"favorites"];

    if(array != nil && [array count] > 0 ) {
        return [NSArray arrayWithArray:array];
    }

    return [NSArray array];
}

+ (void)addFavoriteWithArticle:(Article *)article complete:(void (^)(BOOL, NSString *, NSArray *))addFavoriteBlock {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.virates"];
    NSArray *array = [userDefaults arrayForKey:@"favorites"];
    if( array == nil ){
        array = [NSArray array];
    }

    NSString *alertMessage = @"お気に入りに追加しました";
    BOOL isSuccess = NO;
    NSArray *aFavorite = [NSArray array];
    if([array count] >= 200) {
        alertMessage = @"お気に入り登録は200件までです";
    }else{
        if(![array containsObject:article.aId]) {

            NSMutableArray *marray = [NSMutableArray array];
            [marray addObject:article.aId];
            for (NSString *object in array) {
                [marray addObject:object];
            }
            [userDefaults setObject:marray forKey:@"favorites"];
            [userDefaults synchronize];
            aFavorite = [NSArray arrayWithArray:marray];
            isSuccess = YES;
        } else {
            aFavorite = [NSArray arrayWithArray:array];
        }
    }

    addFavoriteBlock(isSuccess, alertMessage, aFavorite);
}

+ (void)removeFavoriteWithArticleArray:(NSArray *)articleArray complete:(void (^)(BOOL, NSString *, NSArray *))removeFavoriteBlock {

    NSMutableArray *articleIdArray = [NSMutableArray array];
    for (Article *aritcle in articleArray) {
        [articleIdArray addObject:aritcle.aId];
    }
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.virates"];
    NSArray *array = [defaults arrayForKey:@"favorites"];

    NSString *alertMessage = @"お気に入りから削除しました";

    NSMutableArray *marray = [NSMutableArray array];
    for(NSNumber *articleId in array) {
        if(![articleIdArray containsObject:articleId]) {
            [marray addObject:articleId];
        }
    }
    [defaults setObject:marray forKey:@"favorites"];
    [defaults synchronize];

    removeFavoriteBlock(YES,alertMessage,marray);
}


@end
