//
//  ArticleCollectionViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/02.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ArticleCollectionViewController.h"
#import "ArticleCollectionHeaderReusableView.h"
#import "ArticleCollectionViewCell.h"
#import "ArticleFavorite.h"
#import "UILabel+DynamicFontSize.h"
#import "GunosyAds.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <ADG/ADGManagerViewController.h>
#import "GlobalVars.h"

@interface ArticleCollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,ADGManagerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *favoriteList;
@property (strong, nonatomic) NSMutableArray *articleArray;
@property (strong, nonatomic) NSMutableArray *articleList;
@property (strong, nonatomic) ArticleCollectionHeaderReusableView *headerView;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) CGSize cellSize;
@property (nonatomic) BOOL hideHeader;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isForceLoad;
@property (nonatomic) BOOL enableGunosy;
@property (nonatomic) BOOL enableNend;

@property (nonnull) NSDate *nextLoadDate;

@property (nonatomic, retain) ADGManagerViewController *adg;

@end

@implementation ArticleCollectionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hideHeader:(BOOL)hideHeader {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.hideHeader = hideHeader;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isLoading = NO;
    self.isForceLoad = NO;
    self.isBackgroundLoad = NO;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.alwaysBounceVertical = YES;

    CGRect screenSize = [[UIScreen mainScreen] bounds];
    NSUInteger space = 7;
    NSUInteger cellNum = 2;
    CGFloat CellWidth = (screenSize.size.width - space * (cellNum+1)) / cellNum;
    self.cellSize = CGSizeMake(CellWidth, 215);

    [self.collectionView registerNib:[UINib nibWithNibName:@"ArticleCollectionHeaderReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ArticleCollectionHeader"];

    [self.collectionView registerNib:[UINib nibWithNibName:@"ArticleCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ArticleCollectionViewCell"];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(manualReload
                                                         ) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];

    self.articleArray = [NSMutableArray new];
    self.articleList = [NSMutableArray new];
    self.favoriteList = [NSArray new];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_adg) {
        [_adg resumeRefresh];
    }
}

- (void)enableScrollToTop
{
    self.collectionView.scrollsToTop = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.collectionView.scrollsToTop = NO;
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadArticle {

    // 強制ロード時のみスキップする
    if (self.isForceLoad == NO){
        if(self.isLoading){
            [self reloadCollectionView];
            return;
        }

        if(!self.isBackgroundLoad ) {
            if (self.articleArray != nil && self.articleArray.count > 0){
                NSDate *now = [NSDate date];
                NSComparisonResult result = [now compare:self.nextLoadDate];
                if (result == NSOrderedAscending){
                    [self reloadCollectionView];
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
    self.favoriteList = [ArticleFavorite getAllFavorites];
    __block BOOL blockIsBackgroundload = self.isBackgroundLoad;
    ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
    [[client sendArticleDetailRequestWithURLPath:self.articleCategory.link]  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [ViRatesServerRespons convertObjectToJsonDictionary:responseObject];
        if( result ) {
            NSArray *resultArray = result[@"list"];
            NSDictionary *infoResult = nil;
            self.articleArray = [NSMutableArray new];
            self.articleList = [NSMutableArray new];
            
            for (NSDictionary *resultListDic in resultArray) {
                if( resultListDic[@"id"] ) {
                    Article *article = [[Article alloc] initWithDictionaryData:resultListDic];
                    article.isFavorite = [self.favoriteList containsObject:article.aId];
                    [self.articleArray addObject:article];
                    [self.articleList addObject:article];
                    
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
            if(infoResult){
                if([[infoResult objectForKey:@"ad"] isEqualToString:@"gunosy"]) {
                    self.enableGunosy = YES;
                    [[GunosyAds sharedManager] getAdvertisementsByFrameId:@"918" complete:^(NSArray *ads) {
                        if([ads count] > 0) {
                            NSNumber *top = infoResult[@"top"];
                            NSNumber *iv = infoResult[@"iv"];
                            [self updateArticleWithAds:ads top:top.integerValue interval:iv.integerValue];
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
                                    NSNumber *top = infoResult[@"top"];
                                    NSNumber *iv = infoResult[@"iv"];
                                    [self updateArticleWithAds:ads top:top.integerValue interval:iv.integerValue];
                                }
                            }
                        } else {
                            self.enableGunosy = NO;
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        self.enableGunosy = NO;
                    }];
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
        [self.collectionView reloadData];
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

- (void)updateArticleWithAds:(NSArray *)ads top:(NSInteger)top interval:(NSInteger)interval {
//    BOOL startFromLeft = [self.articleCategory.name isEqualToString:@"Twitter"];
    BOOL startFromLeft = top == 3;
//    int top = startFromLeft ? 3 : 4;
//    int interval = 4;
    int arrayCount = (int)[self.articleArray count];
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
        if( i==0 ){
            if(top <= arrayCount ) {
                [self.articleArray insertObject:article atIndex:top];
            }
        } else{
            NSInteger nextRow = startFromLeft ? (interval * (i + 1)) - 1 : interval * (i + 1);
            if(nextRow <= arrayCount + i + 1 ) {
                [self.articleArray insertObject:article atIndex:nextRow];
            }
        }
    }
    [self.collectionView reloadData];
}

- (void)manualReload {
    self.isForceLoad = YES;
    [self reloadArticle];
}

- (void)reloadCollectionView {
    self.favoriteList = [ArticleFavorite getAllFavorites];
    for (Article *article in self.articleArray) {
        article.isFavorite = [self.favoriteList containsObject:article.aId];
    }
    [self.collectionView reloadData];
}

- (void)collectionViewCellFavoriteButtonPressed:(UIButton *)button {
    ArticleCollectionViewCell *cell  = (ArticleCollectionViewCell *)button.superview.superview;
    if (cell) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        NSInteger index = self.hideHeader ? indexPath.row : indexPath.row + 1;
        Article *article = [self.articleArray objectAtIndex:index];
        if(article.isFavorite) {
            [ArticleFavorite removeFavoriteWithArticleArray:@[article] complete:^(BOOL success, NSString *message, NSArray *favoriteList) {
                article.isFavorite = NO;
                self.favoriteList = [NSArray arrayWithArray:favoriteList];
                [self showNoticeAlertViewWithMessage:message];
                [cell.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_off"] forState:UIControlStateNormal];
            }];
        } else {
            [ArticleFavorite addFavoriteWithArticle:article complete:^(BOOL success, NSString *message, NSArray *favoriteList) {
                if(success) {
                    article.isFavorite = YES;
                    self.favoriteList = [NSArray arrayWithArray:favoriteList];
                    [cell.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_on"] forState:UIControlStateNormal];
                }
                [self showNoticeAlertViewWithMessage:message];
            }];
        }
    }

}

- (void)collectionViewHeaderFavoriteButtonPressed:(UIButton *)button {
    if(self.headerView) {
        Article *article = [self.articleArray firstObject];
        if(article.isFavorite) {
            [ArticleFavorite removeFavoriteWithArticleArray:@[article] complete:^(BOOL success, NSString *message, NSArray *favoriteList) {
                article.isFavorite = NO;
                self.favoriteList = [NSArray arrayWithArray:favoriteList];
                [self showNoticeAlertViewWithMessage:message];
                [self.headerView.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_off"] forState:UIControlStateNormal];
            }];
        } else {
            [ArticleFavorite addFavoriteWithArticle:article complete:^(BOOL success, NSString *message, NSArray *favoriteList) {
                if(success) {
                    article.isFavorite = YES;
                    self.favoriteList = [NSArray arrayWithArray:favoriteList];
                    [self.headerView.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_on"] forState:UIControlStateNormal];
                }
                [self showNoticeAlertViewWithMessage:message];
            }];
        }
    }
}
#pragma mark - UICollection View Delegate and DataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.hideHeader) {
        return [self.articleArray count];
    } else {
        return [self.articleArray count] - 1;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return self.cellSize;
}

- (ArticleCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ArticleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ArticleCollectionViewCell" forIndexPath:indexPath];
    NSInteger index = self.hideHeader ? indexPath.row : indexPath.row + 1;
    Article *article = [self.articleArray objectAtIndex:index];

    if((self.enableGunosy && [article.ad isKindOfClass:[GNAdvertisement class]]) || (self.enableNend && [article.ad isEqualToString:@"nend"]) ) {
        cell.adLabel.hidden                 = NO;
        cell.totalCommentLabel.hidden       = YES;
        cell.dateLabel.hidden               = YES;
        cell.commentImageView.hidden        = YES;
        cell.favoriteButton.hidden          = YES;
        cell.articleLabelImageView.hidden   = YES;
    } else {
        cell.adLabel.hidden                 = YES;
        cell.totalCommentLabel.hidden       = NO;
        cell.dateLabel.hidden               = NO;
        cell.commentImageView.hidden        = NO;
        cell.favoriteButton.hidden          = NO;
        cell.articleLabelImageView.hidden   = NO;
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
    cell.totalCommentLabel.text = [NSString stringWithFormat:@"%@",article.commentCount];
    cell.dateLabel.text = article.date;
    [cell.favoriteButton addTarget:self action:@selector(collectionViewCellFavoriteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if(article.isFavorite) {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_on"] forState:UIControlStateNormal];
    } else {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_off"] forState:UIControlStateNormal];
    }
    
    if(self.hideHeader){
        if(indexPath.row < 3){
            cell.articleLabelImageView.image = [UIImage imageNamed:@"icon_hot"];
        } else {
            cell.articleLabelImageView.image = [UIImage imageNamed:@"icon_new"];
        }
    } else {
        if(indexPath.row < 2){
            cell.articleLabelImageView.image = [UIImage imageNamed:@"icon_hot"];
        } else {
            cell.articleLabelImageView.image = [UIImage imageNamed:@"icon_new"];
        }
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if(self.headerView == nil) {
        self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ArticleCollectionHeader" forIndexPath:indexPath];
        CGRect frame = self.headerView.frame;
        frame.size.height = [[UIScreen mainScreen] bounds].size.width /375*212;
        self.headerView.frame = frame;
        NSDictionary *adgparam = @{
                                   @"locationid" : @"38398", //管理画面から払い出された広告枠ID
                                   @"adtype" : @(kADG_AdType_Free), //枠サイズ(kADG_AdType_Sp：320x50, kADG_AdType_Large:320x100, kADG_AdType_Rect:300x250, kADG_AdType_Tablet:728x90, kADG_AdType_Free:自由設定)
                                   @"originx" : @(0), //広告枠設置起点のx座標
                                   @"originy" : @(0), //広告枠設置起点のy座標
                                   @"w" : @([[UIScreen mainScreen] bounds].size.width), //広告枠横幅（kADG_AdType_Freeのとき有効）
                                   @"h" : @([[UIScreen mainScreen] bounds].size.width * 9.0 / 16.0)  //広告枠高さ（kADG_AdType_Freeのとき有効）
                                   };
        ADGManagerViewController *adgvc = [[ADGManagerViewController alloc] initWithAdParams:adgparam adView:self.headerView];
        self.adg = adgvc;
        _adg.rootViewController = self;
        _adg.delegate = self;
        [_adg setFillerRetry:NO];
        [_adg loadRequest];

    }
    if([self.articleArray count] > 0) {
        Article *todayHotArticle = [self.articleArray firstObject];
        [self.headerView.articleImageView sd_setImageWithURL:[NSURL URLWithString:todayHotArticle.thumbnail]];
        self.headerView.titleLabel.text = todayHotArticle.title;
        [self.headerView.titleLabel adjustFontSizeToFillItsContents];
        self.headerView.totalCommentLabel.text = [NSString stringWithFormat:@"%@",todayHotArticle.commentCount];
        [self.headerView.favoriteButton addTarget:self action:@selector(collectionViewHeaderFavoriteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if(todayHotArticle.isFavorite) {
            [self.headerView.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_on"] forState:UIControlStateNormal];
        } else {
            [self.headerView.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_off"] forState:UIControlStateNormal];
        }

        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectHeader)];
        [self.headerView addGestureRecognizer:gestureRecognizer];
    }
    return self.headerView;
}

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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {

    if(self.hideHeader || [self.articleArray count] < 1) return CGSizeZero;

    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width /375*212);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = self.hideHeader ? indexPath.row : indexPath.row + 1;
    Article *article = [self.articleArray objectAtIndex:index];
    if ( self.enableNend && [article.ad isEqualToString:@"nend"] ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:article.link]];
    } else if (self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(articleCollection:didSelectedArticle:withAllArticleArray:)]){
        [self.articleDelegate articleCollection:self.collectionView didSelectedArticle:article withAllArticleArray:self.articleList];
    }
}

- (void)didSelectHeader {
    if([self.articleArray count] > 0) {
        if (self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(articleCollection:didSelectedArticle:withAllArticleArray:)]){
            Article *todayHotArticle = [self.articleArray firstObject];
            [self.articleDelegate articleCollection:self.collectionView didSelectedArticle:todayHotArticle withAllArticleArray:self.articleList];
        }
    }
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
//            if (self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(scrollUpNavigationBar:)])
//            {
//                [self.articleDelegate scrollUpNavigationBar:MAX(_naviBar.frame.origin.y - scrollOffset + 22, _naviBar.frame.origin.y)];
//            }
//        }
//        else
//        {
//            [_naviBar setHidden:NO];
//            [GlobalVars sharedInstance].isShowNaviBar = YES;
//            
//            if (self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(scrollUpNavigationBar:)])
//            {
//                [self.articleDelegate scrollUpNavigationBar:MAX(_naviBar.frame.origin.y - 22 - scrollOffset, _naviBar.frame.origin.y - 66)];
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
//        if (self.articleDelegate && [self.articleDelegate respondsToSelector:@selector(scrollUpNavigationBar:)])
//        {
//            [self.articleDelegate scrollUpNavigationBar:_naviBar.frame.origin.y - 22];
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
