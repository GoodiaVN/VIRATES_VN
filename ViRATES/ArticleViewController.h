//
//  ArticleViewController.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/13.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface ArticleViewController : UIViewController

@property (strong, nonatomic) Article *currentArticle;
@property (strong, nonatomic) NSArray *articleArray;
@property(nonatomic) BOOL isFavorite;
@property(nonatomic) BOOL isHistory;
@property(nonatomic) BOOL isSearchResult;
@property(nonatomic) BOOL pushOrWidget;

@property (nonatomic) NSInteger loadingCount;
@end
