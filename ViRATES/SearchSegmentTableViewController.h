//
//  SearchSegmentTableViewController.h
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/02.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@protocol SearchSegmentTableViewDelegate <NSObject>
@optional
- (void)searchSegmentTable:(UITableView *)tableView didSelectedArticle:(Article *)article withAllArticleArray:(NSArray *)articleArray;
@end

@interface SearchSegmentTableViewController : UIViewController

@property (nonatomic, assign) id<SearchSegmentTableViewDelegate> delegate;
@property (strong, nonatomic) NSArray *articleArray;

- (void)loadTableView;

@end
