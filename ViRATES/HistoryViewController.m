//
//  HistoryViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/09.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "HistoryViewController.h"
#import "ArticleActionTableViewCell.h"
#import "HistoryActionViewController.h"
#import "IconActionSheetViewController.h"
#import "Article.h"
#import "ViRatesServerClient.h"
#import "ArticleViewController.h"
#import "ArticleFavorite.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <iOS-Slide-Menu/SlideNavigationController.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface HistoryViewController () <SlideNavigationControllerDelegate, IconActionSheetDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource, HistoryActionViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *actionBarButton;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *historyList;
@property (strong, nonatomic) NSArray *favoriteList;
@property (strong, nonatomic) NSMutableArray *deleteIndexList;
@property (strong, nonatomic) IconActionSheetViewController *actionSheetviewCtrl;
@property (strong, nonatomic) Article *selectedArticle;
@property (strong, nonatomic) UIView *noneView;
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"閲覧履歴";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    [self.tableView registerNib:[UINib nibWithNibName:@"ArticleActionTableViewCell" bundle:nil] forCellReuseIdentifier:@"ArticleActionTableViewCell"];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.deleteIndexList = [NSMutableArray array];

    UIImage* dotImage = [UIImage imageNamed:@"icon_delmenu"];
    CGRect frameimg = CGRectMake(0,0,21,28);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setImage:dotImage forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(pressedHistoryActionButton) forControlEvents:UIControlEventTouchUpInside];
    [someButton setImageEdgeInsets:UIEdgeInsetsMake(5, 9, 5, 7)];
    self.actionBarButton = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem = self.actionBarButton;


    self.actionSheetviewCtrl = [[IconActionSheetViewController alloc] initWithNibName:@"IconActionSheetViewController" bundle:[NSBundle mainBundle] rootView:self.view];
    self.actionSheetviewCtrl.delegate = self;
    CGRect menuFrame = self.actionSheetviewCtrl.view.frame;
    menuFrame.size.width = self.view.frame.size.width;
    menuFrame.size.height = self.view.frame.size.height - 64.0;
    menuFrame.origin.x = 0;
    menuFrame.origin.y = self.view.frame.size.height;
    self.actionSheetviewCtrl.view.frame = menuFrame;

    [self.actionSheetviewCtrl addIconAction:[[IconActionMenu alloc] initWithImage:[UIImage imageNamed:@"icon_del"] menuTitle:@"全ての履歴を削除"]];
    [self.actionSheetviewCtrl addIconAction:[[IconActionMenu alloc] initWithImage:[UIImage imageNamed:@"icon_selcdel"] menuTitle:@"選択削除"]];
    [self.actionSheetviewCtrl addIconAction:[[IconActionMenu alloc] initWithImage:[UIImage imageNamed:@"icon_cancel"] menuTitle:@"キャンセル"]];
    [self addChildViewController:self.actionSheetviewCtrl];
    [self.view addSubview:self.actionSheetviewCtrl.view];

    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(loadHistories) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self loadFavorite];
    [self loadHistories];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if(!self.isMovingToParentViewController) {
        [self loadFavorite];
        [self loadHistories];
    }
}
- (void)loadFavorite {
    self.favoriteList = [ArticleFavorite getAllFavorites];
}

-(void)loadHistories {

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.virates"];
    NSArray *array = [userDefaults arrayForKey:@"histories"];

    if(array != nil && [array count] > 0 ) {
        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
        [SVProgressHUD showWithStatus:@"読み込み中..."];

        NSString *urlPath = [array componentsJoinedByString:@","];

        ViRatesServerHistoryArticleRequest *model = [ViRatesServerHistoryArticleRequest new];
        ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
        [[client sendHistoryArticleRequest:model withArticlePathId:urlPath] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            self.historyList = [NSMutableArray array];
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if( [jsonDic objectForKey:@"list"]  && ![[jsonDic objectForKey:@"list"] isEqual:[NSNull null]] ){
                NSArray *resultArray = [jsonDic objectForKey:@"list"];
                for (NSDictionary *articleDict in resultArray) {
                    Article *article = [[Article alloc] initWithDictionaryData:articleDict];
                    article.isFavorite = [self.favoriteList containsObject:article.aId];
                    [self.historyList addObject:article];
                }
            }
            [self.tableView reloadData];
        } failure:
         ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             //
         }];
    } else{
        [self addHistoryEmptyView];
    }
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

- (void)pressedHistoryActionButton {
    if(self.actionSheetviewCtrl.isShowing){
        [self.actionSheetviewCtrl hideMenu];
    }else {
        [self.actionSheetviewCtrl showMenu];
    }
}

- (void)addHistoryEmptyView {
    if(self.noneView == nil){
        CGRect screenSize = [[UIScreen mainScreen] bounds];
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.size.width, screenSize.size.height-64)];
        self.noneView.backgroundColor = [UIColor lightGrayColor];

        UILabel *noneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenSize.size.width, 20)];
        [noneLabel setCenter:CGPointMake(screenSize.size.width/2, screenSize.size.height/2-20)];
        noneLabel.text = @"閲覧履歴はありません";
        noneLabel.font = [UIFont boldSystemFontOfSize:12];
        noneLabel.textAlignment = NSTextAlignmentCenter;
        noneLabel.textColor = [UIColor whiteColor];
        [self.noneView addSubview:noneLabel];
    }
    [self.view addSubview:self.noneView];
}


#pragma mark - TableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.historyList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Article *article = [self.historyList objectAtIndex:indexPath.row];
    ArticleActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleActionTableViewCell"];
    [cell.articleImageView sd_setImageWithURL:[NSURL URLWithString:article.thumbnail]];
    cell.articleTextLabel.text = article.title;
    cell.totalCommentLabel.text = [NSString stringWithFormat:@"%@",article.commentCount];
    cell.dateLabel.text = article.date;
    if([article.sponsored isEqualToNumber:@1]){
        cell.categoryLabel.text = @"PR";
    } else {
        cell.categoryLabel.text = @"おもしろ動画";
    }

    cell.actionButton.tag = indexPath.row;
    [cell.actionButton addTarget:self action:@selector(selectedActionButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Article *article = [self.historyList objectAtIndex:indexPath.row];
    if(tableView.isEditing) {
        [self.deleteIndexList addObject:article];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ArticleViewController *controller = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
        controller.currentArticle = article;
        controller.isHistory = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    self.deleteBarButtonItem.enabled = [self.deleteIndexList count] > 0;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.isEditing) {
        Article *article = [self.historyList objectAtIndex:indexPath.row];
        [self.deleteIndexList removeObject:article];
    }
    self.deleteBarButtonItem.enabled = [self.deleteIndexList count] > 0;
}

#pragma mark - Popover Methods
- (void)selectedActionButton:(UIButton *)sender{

    self.selectedArticle = [self.historyList objectAtIndex:sender.tag];

    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    ArticleActionTableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:ip];

    HistoryActionViewController *clController = [[HistoryActionViewController alloc] initWithNibName:@"HistoryActionViewController" bundle:nil disableAddFavorite:[self.favoriteList containsObject:self.selectedArticle.aId]];
    clController.delegate = self;
    clController.view.backgroundColor = [UIColor redColor];
    clController.modalPresentationStyle = UIModalPresentationPopover;
    clController.preferredContentSize = CGSizeMake(self.view.frame.size.width, 132);
    UIPopoverPresentationController *popController = clController.popoverPresentationController;
    popController.permittedArrowDirections = UIPopoverArrowDirectionUp |UIPopoverArrowDirectionDown ;
    popController.sourceView = selectedCell;
    popController.sourceRect = selectedCell.actionButton.frame;
    popController.delegate = self;
    [self presentViewController:clController animated:YES completion:nil];

}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}

#pragma mark - Popover Delegate Method
- (void)historyActionTableViewDidSelectedAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@""
                                                                           message:@"この閲覧履歴を削除します。よろしいですか？"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        [alertCtrl addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            self.selectedArticle = nil;
        }]];
        [alertCtrl addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self removeHistoryInArray:@[self.selectedArticle]];
            self.selectedArticle = nil;
        }]];
        [self presentViewController:alertCtrl animated:YES completion:nil];
    } else if (indexPath.row == 1) {
        [self addFavorite];
        self.selectedArticle = nil;
    } else {
        self.selectedArticle = nil;
    }
}


#pragma mark - Icon Action Sheet Delegate
- (void)actionSheet:(IconActionSheetViewController *)actionSheetCtrl didSelectMenuAtIndexPath:(NSIndexPath *)indexPath {
    [actionSheetCtrl hideMenu];
    if(indexPath.row == 0) {
        [self handleDeleteAll];
    } else if(indexPath.row == 1) {
        [self toggleEditingMode:YES];
    } else if(indexPath.row == 2) {
        NSLog(@"***** 設定 *****");
    }
}


#pragma mark - Private Methods
- (void)handleDeleteAll {
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"全ての履歴を削除します。よろしいですか？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleCancel handler:nil]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"***** 全ての削除の処理 *****");
        [self removeHistoryInArray:[NSArray arrayWithArray:self.historyList]];
    }]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (IBAction)cancelSelectionDelete:(UIBarButtonItem *)sender {
    [self.deleteIndexList removeAllObjects];
    [self toggleEditingMode:NO];
}

- (IBAction)deleteSelectionList:(UIBarButtonItem *)sender {

    NSString *message = [NSString stringWithFormat:@"選択した%@件を閲覧履歴から削除してもよろしいですか？",[NSNumber numberWithInteger:[self.deleteIndexList  count]]];
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@""
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleCancel handler:nil]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"***** 選択削除の処理 *****");
        [self removeHistoryInArray:self.deleteIndexList];
        [self.deleteIndexList removeAllObjects];
        [self toggleEditingMode:NO];
    }]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)toggleEditingMode:(BOOL)editMode;{

    self.tableView.editing          = editMode;
    self.toolbar.hidden             = !editMode;
    self.actionBarButton.enabled    = !editMode;

    if(editMode) {
        self.tableViewBottomConstraint.constant += self.toolbar.frame.size.height;
        for (int row = 0 ; row < [self.tableView numberOfRowsInSection:0] ; row ++){
            ArticleActionTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            cell.actionButton.hidden = YES;
        }
    } else {
        [self.deleteIndexList removeAllObjects];
        self.deleteBarButtonItem.enabled = NO;
        self.tableViewBottomConstraint.constant -= self.toolbar.frame.size.height;
        for (int row = 0 ; row < [self.tableView numberOfRowsInSection:0] ; row ++){
            ArticleActionTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            cell.actionButton.hidden = NO;
        }
    }
}

- (void)removeHistoryInArray:(NSArray *)targetArray {
    NSMutableArray *articleIdArray = [NSMutableArray array];
    for (Article *aritcle in targetArray) {
        [articleIdArray addObject:aritcle.aId];
        [self.historyList removeObject:aritcle];
    }

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.virates"];
    NSArray* array = [defaults arrayForKey:@"histories"];

    NSString *alertMessage = @"閲覧履歴から削除しました";

    NSMutableArray *marray = [NSMutableArray array];
    for(NSNumber *articleId in array) {
        if(![articleIdArray containsObject:articleId]) {
            [marray addObject:articleId];
        }
    }
    [defaults setObject:marray forKey:@"histories"];
    [defaults synchronize];
    [self showNoticeAlertViewWithMessage:alertMessage];
    [self.tableView reloadData];
    if([self.historyList count] == 0){
        [self addHistoryEmptyView];
    }
}

- (void)addFavorite {
    [ArticleFavorite addFavoriteWithArticle:self.selectedArticle complete:^(BOOL success, NSString *message, NSArray *favoriteList) {
        if (success) {
             self.favoriteList = [NSArray arrayWithArray:favoriteList];
        }
        [self showNoticeAlertViewWithMessage:message];
    }];
}


- (void)showNoticeAlertViewWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
