//
//  ArticleSegmentTableViewController.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/07.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViRatesServerClient.h"
#import "Article.h"
#import "ArticleCategory.h"

@protocol ArticleSegmentTableViewDelegate <NSObject>
@optional
- (void)articleSegmentTable:(UITableView *)tableView didSelectedArticle:(Article *)article withAllArticleArray:(NSArray *)articleArray;
- (void)ArticleSegmentScrollUpNavigationBar:(CGFloat)newY;
@end

@interface ArticleSegmentTableViewController : UIViewController

@property(nonatomic, assign) UINavigationBar* naviBar;

@property (nonatomic, assign) id<ArticleSegmentTableViewDelegate> articleDelegate;
@property (nonatomic, assign) ArticleCategory *articleCategory;
@property (nonatomic) BOOL isBackgroundLoad;

- (void)reloadArticle;
- (void)reloadTableView;
- (void)enableScrollToTop;

@end
