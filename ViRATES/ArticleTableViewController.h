//
//  ArticleTableViewController.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/04.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViRatesServerClient.h"
#import "Article.h"
#import "ArticleCategory.h"

@protocol ArticleTableViewViewDelegate <NSObject>
@optional
- (void)articleTableView:(UITableView *)tableView didSelectedArticle:(Article *)article withAllArticleArray:(NSArray *)articleArray;
@end


@interface ArticleTableViewController : UIViewController

@property (nonatomic, assign) id<ArticleTableViewViewDelegate> articleDelegate;
@property (nonatomic, assign) ArticleCategory *articleCategory;
@property (nonatomic) BOOL isBackgroundLoad;

- (void)reloadArticle;
- (void)reloadTableView;

@end
