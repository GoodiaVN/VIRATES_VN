//
//  ArticleTableViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/04.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ArticleTableViewController.h"
#import "ArticleTableViewHeader.h"
#import "ArticleTableViewCell.h"
#import "ArticleFavorite.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <ADG/ADGManagerViewController.h>

@interface ArticleTableViewController () <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,ADGManagerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *favoriteList;
@property (strong, nonatomic) NSMutableArray *articleArray;
@property (strong, nonatomic) ArticleTableViewHeader *headerView;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isForceLoad;
@property (nonnull) NSDate *nextLoadDate;


@property (nonatomic, retain) ADGManagerViewController *adg;

@end

@implementation ArticleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isLoading = NO;
    self.isForceLoad = NO;
    self.isBackgroundLoad = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleTableViewCell" bundle:nil] forCellReuseIdentifier:@"ArticleTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.headerView = [ArticleTableViewHeader view];
    self.tableView.scrollsToTop = YES;

    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewGestureHandler:)];
    [singleTapRecognizer setDelegate:self];
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self.headerView addGestureRecognizer:singleTapRecognizer];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(manualReload
                                                         ) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

    self.articleArray = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(!_adg) {
        NSDictionary *adgparam = @{
                                   @"locationid" : @"38398", //管理画面から払い出された広告枠ID
                                   @"adtype" : @(kADG_AdType_Free), //枠サイズ(kADG_AdType_Sp：320x50, kADG_AdType_Large:320x100, kADG_AdType_Rect:300x250, kADG_AdType_Tablet:728x90, kADG_AdType_Free:自由設定)
                                   @"originx" : @(0), //広告枠設置起点のx座標
                                   @"originy" : @(0), //広告枠設置起点のy座標
                                   @"w" : @(self.view.frame.size.width), //広告枠横幅（kADG_AdType_Freeのとき有効）
                                   @"h" : @(self.view.frame.size.width * 9.0 / 16.0)  //広告枠高さ（kADG_AdType_Freeのとき有効）
                                   };
        ADGManagerViewController *adgvc = [[ADGManagerViewController alloc] initWithAdParams:adgparam adView:self.view];
        self.adg = adgvc;
        _adg.rootViewController = self;
        _adg.delegate = self;
        [_adg setFillerRetry:NO];
        [_adg loadRequest];
    } else {
        [_adg resumeRefresh];
    }
}

- (void)reloadTableView {
    self.favoriteList = [ArticleFavorite getAllFavorites];
    for (Article *article in self.articleArray) {
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
            if (self.articleArray != nil && self.articleArray.count > 0){
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

    self.favoriteList = [ArticleFavorite getAllFavorites];
    __block BOOL blockIsBackgroundload = self.isBackgroundLoad;
    ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
    [[client sendArticleDetailRequestWithURLPath:self.articleCategory.link]  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [ViRatesServerRespons convertObjectToJsonDictionary:responseObject];
        if( result ) {
            self.articleArray = [NSMutableArray new];
            NSArray *resultArray = result[@"list"];
            NSDictionary *infoResult;
            for (NSDictionary *resultListDic in resultArray) {
                if( resultListDic[@"id"] ) {
                    NSMutableDictionary *tmpDic = [resultListDic mutableCopy];
                    [tmpDic addEntriesFromDictionary:infoResult];
                    Article *article = [[Article alloc] initWithDictionaryData:tmpDic];
                    article.isFavorite = [self.favoriteList containsObject:article.aId];
                    [self.articleArray addObject:article];
                } else {
                    infoResult = resultListDic;
                }
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

        if(self.tableView.tableHeaderView == nil){
            CGRect headerFrame = self.headerView.frame;
            headerFrame.size.width = self.view.frame.size.width;
            headerFrame.size.height = 150.0f;
            self.headerView.frame = headerFrame;

            UIView *view = [[UIView alloc] initWithFrame:headerFrame];
            [view addSubview:self.headerView];
            self.tableView.tableHeaderView = view;
        }

        Article *headerArticle = [self.articleArray firstObject];
        [self.headerView.headerImageView sd_setImageWithURL:[NSURL URLWithString:headerArticle.thumbnail]];
        self.headerView.titleLabel.text = headerArticle.title;
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

-(void)manualReload {
    self.isForceLoad = YES;
    [self reloadArticle];
}

#pragma mark -

- (void)ADGManagerViewControllerReceiveAd:(ADGManagerViewController *)adgManagerViewController
{
    NSLog(@"%@", @"ADGManagerViewControllerReceiveAd");
}


// エラー時のリトライは特段の理由がない限り必ず記述するようにしてください。
- (void)ADGManagerViewControllerFailedToReceiveAd:(ADGManagerViewController *)adgManagerViewController code:(kADGErrorCode)code {
    NSLog(@"%@", @"ADGManagerViewControllerFailedToReceiveAd");
    // 不通とエラー過多のとき以外はリトライ
    switch (code) {
        case kADGErrorCodeExceedLimit:
        case kADGErrorCodeNeedConnection:
            [self clearADGManagerVieeController];
            break;
        default:
            [adgManagerViewController loadRequest];
            break;
    }
}

- (void)ADGManagerViewControllerOpenUrl:(ADGManagerViewController *)adgManagerViewController{
    NSLog(@"%@", @"ADGManagerViewControllerOpenUrl");
}

- (void)clearADGManagerVieeController {
    _adg.delegate = nil;
    _adg.rootViewController = nil;
    _adg = nil;
}

#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.articleArray count]-1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Article *article = [self.articleArray objectAtIndex:indexPath.row+1];

    ArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleTableViewCell"];
    [cell.articleImageView sd_setImageWithURL:[NSURL URLWithString:article.thumbnail]];
    cell.articleTextLabel.text = article.title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(articleTableView:didSelectedArticle:withAllArticleArray:)]) {
        Article *article = [self.articleArray objectAtIndex:indexPath.row+1];
        [self.articleDelegate articleTableView:self.tableView didSelectedArticle:article withAllArticleArray:self.articleArray];
    }
}

- (void)headerViewGestureHandler:(UIGestureRecognizer *)gestureRecognize {
    if(self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(articleTableView:didSelectedArticle:withAllArticleArray:)]) {
        Article *article = [self.articleArray firstObject];
        [self.articleDelegate articleTableView:self.tableView didSelectedArticle:article withAllArticleArray:self.articleArray];
    }
}


- (void)showNoticeAlertViewWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
