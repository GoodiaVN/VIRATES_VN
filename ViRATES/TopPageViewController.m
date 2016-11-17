//
//  TopPageViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/06/30.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "TopPageViewController.h"
#import "SideMenuTableViewController.h"
#import "ArticleCollectionViewController.h"
#import "ArticleTableViewController.h"
#import "ArticleSegmentTableViewController.h"
#import "ViRatesServerClient.h"
#import "ArticleViewController.h"
#import "ArticleCategory.h"
#import "CAPSPageMenu.h"
#import "GNAdvertisement.h"
#import "WebViewController.h"

#import <iOS-Slide-Menu/SlideNavigationController.h>
typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
} ScrollDirection;

@interface TopPageViewController ()<SlideNavigationControllerDelegate,UIScrollViewDelegate,ArticleCollectionViewDelegate,ArticleTableViewViewDelegate,ArticleSegmentTableViewDelegate,CAPSPageMenuDelegate>

@property (strong, nonatomic) NSMutableArray *menuTitleArray;
@property (strong, nonatomic) NSMutableArray *articleCategoryArray;
@property (strong, nonatomic) NSMutableArray *scrollVcArray;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic) NSInteger currentMenuIndex;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) BOOL isPressedMenu;
@property (nonatomic) CAPSPageMenu *pagemenu;

@end

@implementation TopPageViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.isPressedMenu = NO;

    ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
    [[client sendCategoryRequest]  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [ViRatesServerRespons convertObjectToJsonDictionary:responseObject];
        if( result ) {
            NSArray *resultArray = result[@"list"];
            self.articleCategoryArray = [NSMutableArray array];
            for (NSDictionary *resultListDic in resultArray) {
                ArticleCategory *article = [[ArticleCategory alloc] initWithDictionaryData:resultListDic];
                [self.articleCategoryArray addObject:article];
            }

            NSArray *sortedArray = [self.articleCategoryArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSNumber *first = [(ArticleCategory*)a sort];
                NSNumber *second = [(ArticleCategory*)b sort];
                return [first compare:second];
            }];
            self.articleCategoryArray = [NSMutableArray arrayWithArray:sortedArray];
            [self setUpView];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showNoticeAlertViewWithMessage:@"通信エラー"];
    }];

    self.currentMenuIndex = 0;

    UIButton *buttonSearch  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [buttonSearch setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
    [buttonSearch addTarget:self action:@selector(callSearchViewController:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonSearch];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    buttonSearch.imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" ";
    self.navigationItem.backBarButtonItem = barButton;

    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_top"]];
    CGRect frame = titleImageView.frame;
    frame.size = CGSizeMake(100, 20);
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    titleImageView.frame = frame;
    titleImageView.userInteractionEnabled = YES;
    self.navigationItem.titleView = titleImageView;

    // Navigation bar下の線を削除
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];

    [navigationBar setShadowImage:[UIImage new]];

    SideMenuTableViewController *leftMenuVc = [[SideMenuTableViewController alloc] init];
    [SlideNavigationController sharedInstance].leftMenu = leftMenuVc;
    [SlideNavigationController sharedInstance].enableSwipeGesture = NO;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 18)];
    [button setImage:[UIImage imageNamed:@"icon_menu"] forState:UIControlStateNormal];
    [button addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [SlideNavigationController sharedInstance].leftBarButtonItem = leftBarButtonItem;

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if(!self.isMovingToParentViewController) {
        [self reloadArticleViewAtPage:self.pagemenu.currentPageIndex];
    }
}

- (void)reloadArticleViewAtPage:(NSInteger)page {
    UIViewController *viewcontroller = [self.scrollVcArray objectAtIndex:page];
    if([viewcontroller isKindOfClass:[ArticleCollectionViewController class]]) {
        ArticleCollectionViewController *colllectionView = (ArticleCollectionViewController *)viewcontroller;
        [colllectionView reloadCollectionView];
    } else if ([viewcontroller isKindOfClass:[ArticleTableViewController class]]) {
        ArticleTableViewController *tableView = (ArticleTableViewController *)viewcontroller;
        [tableView reloadTableView];
    } else if ([viewcontroller isKindOfClass:[ArticleSegmentTableViewController class]]) {
        ArticleSegmentTableViewController *segmentTableView = (ArticleSegmentTableViewController *)viewcontroller;
        [segmentTableView reloadTableView];
    }
}

- (void)setUpView {
    self.scrollVcArray = [NSMutableArray array];

    self.self.menuTitleArray = [NSMutableArray array];

    ArticleCategory *topCategory = [[ArticleCategory alloc] init];
    topCategory.name = @"Top";
    topCategory.link = [NSString stringWithFormat:@"%@/api_get_listall_",VIRATES_SERVER_BASE_URL];

    [self.articleCategoryArray insertObject:topCategory atIndex:0];

    ArticleCategory *poppularCategory = [[ArticleCategory alloc] init];
    poppularCategory.name = @"人気ランキング";
    [self.articleCategoryArray insertObject:poppularCategory atIndex:1];

    for (ArticleCategory *aCategory in self.articleCategoryArray) {
        [self createArticleViewWithArticleCategory:aCategory];
    }

    CGSize s_size = [[UIScreen mainScreen] bounds].size;
    NSDictionary *parameters = @{CAPSPageMenuOptionMenuItemSeparatorWidth   : @(4.3),
                                 CAPSPageMenuOptionEnableHorizontalBounce   : @(YES),
                                 CAPSPageMenuOptionViewBackgroundColor      :[UIColor colorWithRed:52/255.0 green:52/255.0 blue:52/255.0 alpha:1],
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1],
                                 CAPSPageMenuOptionAddBottomMenuHairline                : @(NO),
                                 CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth   : @(YES),
                                 CAPSPageMenuOptionCenterMenuItems  : @(YES),
                                 CAPSPageMenuOptionSeparatorUnderlineType :@(YES),
                                 CAPSPageMenuOptionMenuMargin: @(0
                                     ),
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HiraginoSans-W6" size:14],
                                 CAPSPageMenuOptionUnSelectedMenuItemFont: [UIFont fontWithName:@"HiraginoSans-W3" size:14],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor:[UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.00],
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0],
                                 CAPSPageMenuOptionShowSelectedMenuItemBackground: @(NO),
                                 CAPSPageMenuOptionSelectionIndicatorHeight: @(34)
                                 };

    self.pagemenu = [[CAPSPageMenu alloc] initWithViewControllers:self.scrollVcArray frame:CGRectMake(0.0, 0.0, s_size.width, s_size.height-64) options:parameters];
    self.pagemenu.delegate = self;

    [self.view addSubview:self.pagemenu.view];
    
    [self loadArticleAtPage:0];
}

- (void)createArticleViewWithArticleCategory:(ArticleCategory *)aCategory {

    [self.menuTitleArray addObject:aCategory.name];
    if([aCategory.name isEqualToString:@"Top"]) {
        ArticleCollectionViewController *aVc = [self createArticleCollectionViewControllerWithArticleCategory:aCategory hideHeader:NO];
        [self.scrollVcArray addObject:aVc];
        
        aVc.naviBar = self.navigationController.navigationBar;
        
    }else if([aCategory.name isEqualToString:@"ビックリ"]) {
        ArticleCollectionViewController *aVc = [self createArticleCollectionViewControllerWithArticleCategory:aCategory hideHeader:NO];
        [self.scrollVcArray addObject:aVc];
        
        aVc.naviBar = self.navigationController.navigationBar;
        
    } else if([aCategory.name isEqualToString:@"おもしろ"]) {
        ArticleCollectionViewController *aVc = [self createArticleCollectionViewControllerWithArticleCategory:aCategory hideHeader:YES];
        [self.scrollVcArray addObject:aVc];
        
        aVc.naviBar = self.navigationController.navigationBar;
        
    } else if([aCategory.name isEqualToString:@"芸能エンタメ"]) {
        ArticleCollectionViewController *aVc = [self createArticleCollectionViewControllerWithArticleCategory:aCategory hideHeader:NO];
        [self.scrollVcArray addObject:aVc];
        
        aVc.naviBar = self.navigationController.navigationBar;
        
    } else if([aCategory.name isEqualToString:@"Twitter"]) {
        ArticleCollectionViewController *aVc = [self createArticleCollectionViewControllerWithArticleCategory:aCategory hideHeader:NO];
        [self.scrollVcArray addObject:aVc];
        
        aVc.naviBar = self.navigationController.navigationBar;
        
    } else if([aCategory.name isEqualToString:@"雑学"]) {
        ArticleCollectionViewController *aVc = [self createArticleCollectionViewControllerWithArticleCategory:aCategory hideHeader:NO];
        [self.scrollVcArray addObject:aVc];
        
        aVc.naviBar = self.navigationController.navigationBar;
        
    } else if([aCategory.name isEqualToString:@"まとめ"]) {
        ArticleCollectionViewController *aVc = [self createArticleCollectionViewControllerWithArticleCategory:aCategory hideHeader:NO];
        [self.scrollVcArray addObject:aVc];
        
        aVc.naviBar = self.navigationController.navigationBar;
        
    } else if([aCategory.name isEqualToString:@"セクシー"]) {
        ArticleCollectionViewController *aVc = [self createArticleCollectionViewControllerWithArticleCategory:aCategory hideHeader:NO];
        [self.scrollVcArray addObject:aVc];
        
        aVc.naviBar = self.navigationController.navigationBar;
        
    } else if([aCategory.name isEqualToString:@"漫画"]) {
        ArticleTableViewController *aTableVc = [[ArticleTableViewController alloc] initWithNibName:@"ArticleTableViewController" bundle:nil];
        aTableVc.articleDelegate = self;
        aTableVc.articleCategory = aCategory;
        aTableVc.title = aCategory.name;
        [self.scrollVcArray addObject:aTableVc];
        
    } else if ([aCategory.name isEqualToString:@"人気ランキング"]) {
        ArticleSegmentTableViewController *aSegTableVc = [[ArticleSegmentTableViewController  alloc] initWithNibName:@"ArticleSegmentTableViewController" bundle:nil];
        aSegTableVc.articleDelegate = self;
        aSegTableVc.articleCategory = aCategory;
        aSegTableVc.title = aCategory.name;
        [self.scrollVcArray addObject:aSegTableVc];
        
        aSegTableVc.naviBar = self.navigationController.navigationBar;
        
    } else {
        ArticleCollectionViewController *aVc = [self createArticleCollectionViewControllerWithArticleCategory:aCategory hideHeader:NO];
        [self.scrollVcArray addObject:aVc];
        
        aVc.naviBar = self.navigationController.navigationBar;
        
    }

}

- (ArticleCollectionViewController *)createArticleCollectionViewControllerWithArticleCategory:(ArticleCategory *)aCategory hideHeader:(BOOL)hideHeader{
    ArticleCollectionViewController *aVc = [[ArticleCollectionViewController alloc] initWithNibName:@"ArticleCollectionViewController" bundle:nil hideHeader:hideHeader];
    aVc.articleDelegate = self;
    aVc.articleCategory = aCategory;
    aVc.title = aCategory.name;
    return aVc;
}

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index {
    [self loadArticleAtPage:index];
}

#pragma mark - slide navigation methods

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return NO;
}

- (void)callSearchViewController:(UIBarButtonItem *)barButtonItem {
    [self performSegueWithIdentifier:@"CallSearchViewSegue" sender:self];
}

#pragma mark - Scroll

- (void)loadArticleAtPage:(NSInteger)currentPage {
    UIViewController *controller = [self.scrollVcArray objectAtIndex:currentPage];
    [self loadArticleViewController:controller isBackgroundload:NO];
    [self loadBesideArticleAtCurrentPage:currentPage];
}

- (void)loadBesideArticleAtCurrentPage:(NSInteger)currentPage {
    NSInteger leftPage = currentPage - 1 ;
    if (leftPage > -1){
        UIViewController *controller = [self.scrollVcArray objectAtIndex:leftPage];
        [self loadArticleViewController:controller isBackgroundload:YES];
    }

    NSInteger rightPage = currentPage + 1 ;
    if (rightPage < [self.scrollVcArray count] ){
        UIViewController *controller = [self.scrollVcArray objectAtIndex:rightPage];
        [self loadArticleViewController:controller isBackgroundload:YES];
    }

}

- (void)loadArticleViewController:(UIViewController *)controller isBackgroundload:(BOOL)isBackgroundload{
    if([controller isKindOfClass:[ArticleCollectionViewController class]] ) {
        ArticleCollectionViewController *aController = (ArticleCollectionViewController *)controller;
        aController.isBackgroundLoad = isBackgroundload;
        
        if (!isBackgroundload) {
            [aController enableScrollToTop];
        }
        
        [aController reloadArticle];
    } else if([controller isKindOfClass:[ArticleSegmentTableViewController class]] ) {
        ArticleSegmentTableViewController *aController = (ArticleSegmentTableViewController*)controller;
        aController.isBackgroundLoad = isBackgroundload;
        
        if (!isBackgroundload) {
            [aController enableScrollToTop];
        }
        
        [aController reloadArticle];
    } else if([controller isKindOfClass:[ArticleTableViewController class]] ) {
        ArticleTableViewController *aController = (ArticleTableViewController*)controller;
        aController.isBackgroundLoad = isBackgroundload;
        [aController reloadArticle];
    }
}


#pragma mark - Article Delegate methods

-(void)ArticleSegmentScrollUpNavigationBar:(CGFloat)newY
{
    _pagemenu.view.frame = CGRectMake(0, newY, _pagemenu.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - newY);
}

-(void)scrollUpNavigationBar:(CGFloat)newY
{
    _pagemenu.view.frame = CGRectMake(0, newY, _pagemenu.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - newY);
}

- (void)articleCollection:(UICollectionView *)collectionView didSelectedArticle:(Article *)article withAllArticleArray:(NSArray *)articleArray {
    if([article.ad isKindOfClass:[GNAdvertisement class]]){

        GNAdvertisement *ad = (GNAdvertisement *)article.ad;
        if(!ad) return;
        [ad clickWithViewController:self complete:^(GNAdOpenType openType, NSString *url) {
            if(openType == GNAdOpenTypeWebView) {
                WebViewController *wc = [[WebViewController alloc] initWithNibName:nil bundle:nil];
                wc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                wc.urlString = url;
                UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:wc];
                navi.navigationBar.tintColor = [UIColor whiteColor];
                navi.navigationBar.barTintColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.00];
                navi.navigationBar.translucent = NO;
                [navi.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
                [self presentViewController:navi animated:YES completion:nil];
            }
        }];
    } else {
        [self pushtoArticleViewControllerAtArticle:article withAllArticleArray:articleArray];
    }
}

- (void)articleTableView:(UITableView *)tableView didSelectedArticle:(Article *)article withAllArticleArray:(NSArray *)articleArray {
    [self pushtoArticleViewControllerAtArticle:article withAllArticleArray:articleArray];
}

- (void)articleSegmentTable:(UITableView *)tableView didSelectedArticle:(Article *)article withAllArticleArray:(NSArray *)articleArray {
    if([article.ad isKindOfClass:[GNAdvertisement class]]){

        GNAdvertisement *ad = (GNAdvertisement *)article.ad;
        if(!ad) return;
        [ad clickWithViewController:self complete:^(GNAdOpenType openType, NSString *url) {
            if(openType == GNAdOpenTypeWebView) {
                WebViewController *wc = [[WebViewController alloc] initWithNibName:nil bundle:nil];
                wc.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                wc.urlString = url;
                UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:wc];
                navi.navigationBar.tintColor = [UIColor whiteColor];
                navi.navigationBar.barTintColor = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.00];
                navi.navigationBar.translucent = NO;
                [navi.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
                [self presentViewController:navi animated:YES completion:nil];
            }
        }];
    } else {
        [self pushtoArticleViewControllerAtArticle:article withAllArticleArray:articleArray];
    }

}

#pragma mark - Private Mehods
- (void)pushtoArticleViewControllerAtArticle:(Article *)article  withAllArticleArray:(NSArray *)articleArray {
    ArticleViewController *controller = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
    controller.currentArticle = article;
    controller.articleArray = articleArray;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showNoticeAlertViewWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
