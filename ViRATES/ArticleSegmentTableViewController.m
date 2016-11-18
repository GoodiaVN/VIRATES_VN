//
//  ArticleSegmentTableViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/07.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ArticleSegmentTableViewController.h"
#import "ArticleSegmentTableViewCell.h"
#import "HMSegmentedControl.h"
#import "ArticleFavorite.h"
#import "GunosyAds.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "GlobalVars.h"

@interface ArticleSegmentTableViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *favoriteList;
@property(nonatomic) HMSegmentedControl *segmentedControl;
@property (strong, nonatomic) NSMutableArray *articleWeeklyArray;
@property (strong, nonatomic) NSMutableArray *articleMonthlyArray;
@property (strong, nonatomic) NSMutableArray *articleWeeklyList;
@property (strong, nonatomic) NSMutableArray *articleMonthlyList;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isForceLoad;
@property (nonnull) NSDate *nextLoadDate;
@property (nonatomic) BOOL enableGunosy;
@property (nonatomic) BOOL enableNend;

@property (strong, nonatomic) NSString *firstURL;
@property (strong, nonatomic) NSString *secondURL;

@end

@implementation ArticleSegmentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isLoading = NO;
    self.isForceLoad = NO;
    self.isBackgroundLoad = NO;


    NSArray *segmentMenu = [NSArray arrayWithObjects:@"週間", @"月間", nil];

    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:segmentMenu];
    self.segmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width, 45);
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.selectionIndicatorHeight = 3.0f;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.00];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName: [UIColor colorWithRed:0.122 green:0.122 blue:0.122 alpha:1.00]};

    self.segmentedControl.titleTextAttributes = attributes;
    [self.segmentedControl addTarget:self action:@selector(selectedSegmentedControl) forControlEvents:UIControlEventValueChanged];

    self.tableView.tableHeaderView = self.segmentedControl;
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleSegmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"ArticleSegmentTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.scrollsToTop = NO;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(manualReload
                                                         ) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];


    self.articleWeeklyArray = [NSMutableArray new];
    self.articleMonthlyArray = [NSMutableArray new];
    self.articleWeeklyList = [NSMutableArray new];
    self.articleMonthlyList = [NSMutableArray new];

}

- (void)enableScrollToTop
{
    self.tableView.scrollsToTop = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.tableView.scrollsToTop = NO;
}

- (void)reloadTableView {
    self.favoriteList = [ArticleFavorite getAllFavorites];
    for (Article *article in self.articleWeeklyArray) {
        article.isFavorite = [self.favoriteList containsObject:article.aId];
    }

    for (Article *article in self.articleMonthlyArray) {
        article.isFavorite = [self.favoriteList containsObject:article.aId];
    }
    [self.tableView reloadData];
}

- (void)reloadArticle {

    // 強制ロード時のみスキップする
    if (self.isForceLoad == NO){
        if(self.isLoading){
            [self reloadTableView];
            return;
        }

        if(!self.isBackgroundLoad ) {
            if (self.articleWeeklyArray != nil && self.articleWeeklyArray.count > 0){
                NSDate *now = [NSDate date];
                NSComparisonResult result = [now compare:self.nextLoadDate];
                if (result == NSOrderedAscending){
                    [self reloadTableView];
                    return;
                }
            }
            [SVProgressHUD showWithStatus:@"読み込み中..."];
        }
    }
    self.isLoading = YES;
    self.isForceLoad = NO;
    self.enableGunosy = NO;
    self.enableNend   = NO;

    if(self.firstURL == nil || self.secondURL == nil) {
        self.firstURL = [NSString stringWithFormat:@"%@/api_get_popular_/100",VIRATES_SERVER_BASE_URL];
        self.secondURL = [NSString stringWithFormat:@"%@/api_get_best_/100",VIRATES_SERVER_BASE_URL];
    }

    self.favoriteList = [ArticleFavorite getAllFavorites];
    __block BOOL blockIsBackgroundload = self.isBackgroundLoad;
    ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
    [[client sendArticleDetailRequestWithURLPath:self.firstURL]  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [ViRatesServerRespons convertObjectToJsonDictionary:responseObject];
        if( result ) {
            self.articleWeeklyArray = [NSMutableArray new];
            NSArray *resultArray = result[@"list"];
            NSDictionary *infoResult;
            for (NSDictionary *resultListDic in resultArray) {
                if( resultListDic[@"id"] ) {
                    NSMutableDictionary *tmpDic = [resultListDic mutableCopy];
                    [tmpDic addEntriesFromDictionary:infoResult];

                    Article *article = [[Article alloc] initWithDictionaryData:tmpDic];
                    article.isFavorite = [self.favoriteList containsObject:article.aId];
                    [self.articleWeeklyArray addObject:article];
                    [self.articleWeeklyList addObject:article];

                } else {
                    infoResult = resultListDic;
                }
            }
        }
        [self loadMonthlyArticle];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.refreshControl endRefreshing];
        if(!self.isBackgroundLoad ) {
            [SVProgressHUD dismiss];
        }
        if( !blockIsBackgroundload ){
            [self showNoticeAlertViewWithMessage:@"通信エラー"];
        }
    }];

}

- (void)loadMonthlyArticle {
    __block BOOL blockIsBackgroundload = self.isBackgroundLoad;
    ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
    [[client sendArticleDetailRequestWithURLPath:self.secondURL]  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [ViRatesServerRespons convertObjectToJsonDictionary:responseObject];
        //NSLog(@"******* result %@",result);
        if( result ) {
            self.articleMonthlyArray = [NSMutableArray new];
            NSArray *resultArray = result[@"list"];
            NSDictionary *infoResult;
            for (NSDictionary *resultListDic in resultArray) {
                if( resultListDic[@"id"] ) {
                    NSMutableDictionary *tmpDic = [resultListDic mutableCopy];
                    [tmpDic addEntriesFromDictionary:infoResult];

                    Article *article = [[Article alloc] initWithDictionaryData:tmpDic];
                    article.isFavorite = [self.favoriteList containsObject:article.aId];
                    [self.articleMonthlyArray addObject:article];
                    [self.articleMonthlyList addObject:article];
                    
                    // テーブルに広告用パラメータが埋め込まれている場合
                    // 最初のテーブルに広告idを合わせる
                    if (infoResult == nil){
                        if(resultListDic[@"ad"]){
                            NSMutableDictionary *tmpInfoResult = [NSMutableDictionary dictionary];
                            [tmpInfoResult setObject:resultListDic[@"ad"] forKey:@"ad"];
                            
                            // 広告用のパラメータを設定
                            // なければ仮の値を追加する
                            if (resultListDic[@"count"]){
                                [tmpInfoResult setObject:resultListDic[@"count"] forKey:@"count"];
                            } else {
                                [tmpInfoResult setObject:@6 forKey:@"count"];
                            }
                            
                            if (resultListDic[@"top"]){
                                [tmpInfoResult setObject:resultListDic[@"top"] forKey:@"top"];
                            } else {
                                [tmpInfoResult setObject:@3 forKey:@"top"];
                            }
                            
                            if (resultListDic[@"iv"]){
                                [tmpInfoResult setObject:resultListDic[@"iv"] forKey:@"iv"];
                            } else {
                                [tmpInfoResult setObject:@6 forKey:@"iv"];
                            }
                            infoResult = [NSDictionary dictionaryWithDictionary:tmpInfoResult];
                        }
                    }
                } else {
                    infoResult = resultListDic;
                }
            }
            if([[infoResult objectForKey:@"ad"] isEqualToString:@"gunosy"]) {
                self.enableGunosy = YES;
                [[GunosyAds sharedManager] getAdvertisementsByFrameId:@"918" complete:^(NSArray *ads) {
                    if([ads count] > 0) {
                        NSNumber *iv = infoResult[@"iv"];
                        [self updateArticleWithAds:ads interval:iv.integerValue];
                    }else{
                        self.enableGunosy = NO;
                    }
                }];
            } else if([[infoResult objectForKey:@"ad"] isEqualToString:@"nend"]) {
                self.enableNend = YES;
                NSString *urlstring = @"https://lona.nend.net/nafeed.php?api_key=877478ae8f7960ae7683fe9f2c39b65fac76303b&adspot_id=593674&ad_num=5";

                ViRatesServerSessionManager *sessionManager = [ViRatesServerSessionManager manager];
                sessionManager.URLString = urlstring;
                sessionManager.method = NetworkMethodGet;
                sessionManager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
                sessionManager.requestSerializer.timeoutInterval = 10;
                sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
                [sessionManager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E238 Safari/601.1" forHTTPHeaderField:@"User-Agent"];
                [sessionManager progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    if(responseObject != nil) {
                        NSError *nerror;
                        NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^nendNativeCallback\\((.*)\\)" options:0 error:&nerror];
                        NSString *result = [regexp stringByReplacingMatchesInString:jsonString options:0 range:NSMakeRange(0, jsonString.length) withTemplate:@"$1"];
                        NSData *ndata = [result dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *nendDict = [NSJSONSerialization JSONObjectWithData:ndata options:NSJSONReadingAllowFragments error:&nerror];
                        if(!nerror && nendDict[@"default_ads"] != nil) {
                            NSArray *ads = nendDict[@"default_ads"];
                            if([ads count] > 0) {
                                NSNumber *iv = infoResult[@"iv"];
                                [self updateArticleWithAds:ads interval:iv.integerValue];
                            }
                        }
                    } else {
                        self.enableGunosy = NO;
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    self.enableGunosy = NO;
                }];
            }
            self.isLoading = NO;
        } else {
            self.isLoading = NO;
        }
        [self.refreshControl endRefreshing];
        if(!self.isBackgroundLoad ) {
            [SVProgressHUD dismiss];
        }
        self.nextLoadDate = [NSDate dateWithTimeIntervalSinceNow:60*60];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.refreshControl endRefreshing];
        if(!self.isBackgroundLoad ) {
            [SVProgressHUD dismiss];
        }
        if( !blockIsBackgroundload ) {
            [self showNoticeAlertViewWithMessage:@"通信エラー"];
        }
    }];

}

- (void)updateArticleWithAds:(NSArray *)ads interval:(NSInteger)interval {
//    int interval = 6;
    NSInteger weeklyCount = (int)[self.articleWeeklyArray count];
    NSInteger monthlyCount = (int)[self.articleMonthlyArray count];
    for (int i = 0; i<[ads count]; i++) {
        NSDictionary *dict = @{};
        if(self.enableNend) {
            dict = [NSDictionary dictionaryWithObjects:@[ads[i][@"short_text"],
                                                         ads[i][@"ad_image"][@"image_url"],
                                                         ads[i][@"click_url"],
                                                         ads[i][@"impression_count_url"],
                                                         @"nend"]
                                               forKeys:@[@"title",@"thumbnail",@"link",@"impurl",@"ad"]];
        } else {
            GNAdvertisement *_ad = ads[i];
            dict = [NSDictionary dictionaryWithObjects:@[_ad.title,_ad.iconImageUrl,_ad]
                                               forKeys:@[@"title",@"thumbnail",@"ad"]];
        }
        Article *article = [[Article alloc] initWithDictionaryData:dict];
        NSInteger row = (interval*(i+1))-1;
        if(row <= weeklyCount) {
            [self.articleWeeklyArray insertObject:article atIndex:row];
        }

        if(row <= monthlyCount) {
            [self.articleMonthlyArray insertObject:article atIndex:row];
        }
    }
    [self.tableView reloadData];
}

-(void)manualReload {
    self.isForceLoad = YES;
    [self reloadArticle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectedSegmentedControl {
    [self.tableView reloadData];
    NSLog(@"selectedSegmentedControl %ld",self.segmentedControl.selectedSegmentIndex);

}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.segmentedControl.selectedSegmentIndex == 0 ? [self.articleWeeklyArray count] : [self.articleMonthlyArray count]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Article *article;
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        article = [self.articleWeeklyArray objectAtIndex:indexPath.row];
    } else {
        article = [self.articleMonthlyArray objectAtIndex:indexPath.row];
    }
    ArticleSegmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleSegmentTableViewCell"];

    if((self.enableGunosy && [article.ad isKindOfClass:[GNAdvertisement class]]) || (self.enableNend && [article.ad isEqualToString:@"nend"]) ) {
        cell.adLabel.hidden                 = NO;
        cell.totalCommentLabel.hidden       = YES;
        cell.dateLabel.hidden               = YES;
        cell.commentImageView.hidden        = YES;
        cell.tagLabel.hidden                = YES;
        cell.orderLabel.hidden              = YES;
    } else {
        cell.adLabel.hidden                 = YES;
        cell.totalCommentLabel.hidden       = NO;
        cell.dateLabel.hidden               = NO;
        cell.commentImageView.hidden        = NO;
        cell.tagLabel.hidden                = NO;
        cell.orderLabel.hidden              = NO;
    }

    if(self.enableNend && [article.ad isEqualToString:@"nend"]){
        ViRatesServerSessionManager *sessionManager = [ViRatesServerSessionManager manager];
        sessionManager.URLString = article.impurl;
        sessionManager.method = NetworkMethodGet;
        sessionManager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
        sessionManager.requestSerializer.timeoutInterval = 10;
        sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        [sessionManager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E238 Safari/601.1" forHTTPHeaderField:@"User-Agent"];
        [sessionManager progress:nil success:nil failure:nil];
    }

    [cell.articleImageView sd_setImageWithURL:[NSURL URLWithString:article.thumbnail]];
    cell.articleTextLabel.text = article.title;
    cell.orderLabel.text = [NSString stringWithFormat:@"%d.",[self findArticleInList:article.title]];
    cell.totalCommentLabel.text = [NSString stringWithFormat:@"%@",article.commentCount];
    cell.dateLabel.text = article.date;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Article *article;
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        article = [self.articleWeeklyArray objectAtIndex:indexPath.row];
    } else {
        article = [self.articleMonthlyArray objectAtIndex:indexPath.row];
    }
    if ( self.enableNend && [article.ad isEqualToString:@"nend"] ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:article.link]];
    } else if(self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(articleSegmentTable:didSelectedArticle:withAllArticleArray:)]){
        if(self.segmentedControl.selectedSegmentIndex == 0) {
            [self.articleDelegate articleSegmentTable:self.tableView didSelectedArticle:article withAllArticleArray:self.articleWeeklyList];
        } else {
            [self.articleDelegate articleSegmentTable:self.tableView didSelectedArticle:article withAllArticleArray:self.articleMonthlyList];
        }
    }
}

- (int)findArticleInList:(NSString *)title {
    NSArray *array;
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        array = [self.articleWeeklyList copy];
    } else {
        array = [self.articleMonthlyList copy];
    }

    for (int i = 0; i < [array count]; i++) {
        Article *article = [array objectAtIndex:i];
        if([title isEqualToString:article.title]){
            return i+1;
        }
    }

    return -1;
}

- (void)showNoticeAlertViewWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - SCROLLVIEW DELEGATE
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGRect frame = _naviBar.frame;
//    CGFloat scrollOffset = scrollView.contentOffset.y;
//    
//    if(scrollOffset > 0){
//        frame.origin.y = _naviBar.frame.origin.y;
//        frame.size.height = MAX(0, 44 - scrollOffset);
//        
//        CGFloat alpha = (44 - scrollOffset)/44;
//        [self updateBarButtonItems:alpha];
//        
//        if (scrollOffset >= 44)
//        {
//            [_naviBar setHidden:YES];
//            [GlobalVars sharedInstance].isShowNaviBar = NO;
//            
//            if (self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(ArticleSegmentScrollUpNavigationBar:)])
//            {
//                [self.articleDelegate ArticleSegmentScrollUpNavigationBar:MAX(_naviBar.frame.origin.y - scrollOffset + 22, _naviBar.frame.origin.y)];
//            }
//        }
//        else
//        {
//            [_naviBar setHidden:NO];
//            [GlobalVars sharedInstance].isShowNaviBar = YES;
//            
//            if (self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(ArticleSegmentScrollUpNavigationBar:)])
//            {
//                [self.articleDelegate ArticleSegmentScrollUpNavigationBar:MAX(_naviBar.frame.origin.y - 22 - scrollOffset, _naviBar.frame.origin.y - 66)];
//            }
//        }
//    }
//    else{
//        frame.origin.y = _naviBar.frame.origin.y;
//        frame.size.height = 44;
//        
//        [self updateBarButtonItems:1];
//        
//        [_naviBar setHidden:NO];
//        [GlobalVars sharedInstance].isShowNaviBar = YES;
//        
//        if (self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(ArticleSegmentScrollUpNavigationBar:)])
//        {
//            [self.articleDelegate ArticleSegmentScrollUpNavigationBar:_naviBar.frame.origin.y - 22];
//        }
//    }
//    [_naviBar setFrame:frame];
//}

- (void)updateBarButtonItems:(CGFloat)alpha
{
    [_naviBar.topItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    [_naviBar.topItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    _naviBar.topItem.titleView.alpha = alpha;
    _naviBar.tintColor = [_naviBar.tintColor colorWithAlphaComponent:alpha];
}
@end
