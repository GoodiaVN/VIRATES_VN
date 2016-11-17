//
//  ArticleCollectionViewController.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/02.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViRatesServerClient.h"
#import "Article.h"
#import "ArticleCategory.h"

@protocol ArticleCollectionViewDelegate <NSObject>
@optional
- (void)articleCollection:(UICollectionView *)collectionView didSelectedArticle:(Article *)article withAllArticleArray:(NSArray *)articleArray;

- (void)scrollUpNavigationBar:(CGFloat)newY;
@end


@interface ArticleCollectionViewController : UIViewController
@property (nonatomic) CGFloat previousScrollViewYOffset;

@property(nonatomic, assign) UINavigationBar* naviBar;

@property (nonatomic, assign) id<ArticleCollectionViewDelegate> articleDelegate;
@property (nonatomic, assign) ArticleCategory *articleCategory;
@property (nonatomic) BOOL isBackgroundLoad;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hideHeader:(BOOL)hideHeader;
- (void)reloadArticle;
- (void)reloadCollectionView;
- (void)enableScrollToTop;
@end
