//
//  FavoriteViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/09.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "FavoriteViewController.h"
#import "ArticleActionTableViewCell.h"
#import "FavoriteActionViewController.h"
#import "IconActionSheetViewController.h"
#import "Article.h"
#import "ViRatesServerClient.h"
#import "ArticleViewController.h"
#import "ArticleFavorite.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <iOS-Slide-Menu/SlideNavigationController.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface FavoriteViewController () <SlideNavigationControllerDelegate, IconActionSheetDelegate,UITableViewDelegate, UITableViewDataSource,UIPopoverPresentationControllerDelegate,FavoriteActionViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *actionBarButton;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *favoriteList;
@property (strong, nonatomic) NSMutableArray *deleteIndexList;
@property (strong, nonatomic) IconActionSheetViewController *actionSheetviewCtrl;
@property (strong, nonatomic) Article *selectedArticle;
@property (strong, nonatomic) UIView *noneView;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"お気に入り";
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
    [self.refreshControl addTarget:self action:@selector(loadFavorite) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self loadFavorite];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if(!self.isMovingToParentViewController) {
        [self loadFavorite];
    }
}

-(void)loadFavorite {


    NSArray *array = [ArticleFavorite getAllFavorites];

    if(array != nil && [array count] > 0 ) {
        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
        [SVProgressHUD showWithStatus:@"読み込み中..."];

        NSString *urlPath = [array componentsJoinedByString:@","];

        ViRatesServerFavoriteArticleRequest *model = [ViRatesServerFavoriteArticleRequest new];
        ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
        [[client sendFavoriteArticleRequest:model withArticlePathId:urlPath] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            self.favoriteList = [NSMutableArray array];
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if( [jsonDic objectForKey:@"list"]  && ![[jsonDic objectForKey:@"list"] isEqual:[NSNull null]] ){
                NSArray *resultArray = [jsonDic objectForKey:@"list"];
                for (NSDictionary *articleDict in resultArray) {
                    Article *article = [[Article alloc] initWithDictionaryData:articleDict];
                    article.isFavorite = YES;
                    [self.favoriteList addObject:article];
                }
            }
            [self.tableView reloadData];
        } failure:
         ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //
        }];
    } else{
        [self addFavoriteEmptyView];
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

- (void)addFavoriteEmptyView {
    if(self.noneView == nil){
        CGRect screenSize = [[UIScreen mainScreen] bounds];
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.size.width, screenSize.size.height-64)];
        self.noneView.backgroundColor = [UIColor lightGrayColor];

        UILabel *noneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenSize.size.width, 20)];
        [noneLabel setCenter:CGPointMake(screenSize.size.width/2, screenSize.size.height/2-20)];
        noneLabel.text = @"お気に入りはありません";
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
    return [self.favoriteList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Article *article = [self.favoriteList objectAtIndex:indexPath.row];
    ArticleActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleActionTableViewCell"];
    [cell.articleImageView sd_setImageWithURL:[NSURL URLWithString:article.thumbnail]];
    cell.articleTextLabel.text = article.title;
    cell.totalCommentLabel.text = [NSString stringWithFormat:@"%@",article.commentCount];
    cell.dateLabel.text = article.date;
    cell.actionButton.tag = indexPath.row;
    if([article.sponsored isEqualToNumber:@1]){
        cell.categoryLabel.text = @"PR";
    } else {
        cell.categoryLabel.text = @"おもしろ動画";
    }
    [cell.actionButton addTarget:self action:@selector(selectedActionButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Article *article = [self.favoriteList objectAtIndex:indexPath.row];
    if(tableView.isEditing) {
        [self.deleteIndexList addObject:article];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ArticleViewController *controller = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
        controller.currentArticle = article;
        controller.isFavorite = YES;
        [self.navigationController pushViewController:controller animated:YES];

    }
    self.deleteBarButtonItem.enabled = [self.deleteIndexList count] > 0;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.isEditing) {
        Article *article = [self.favoriteList objectAtIndex:indexPath.row];
        [self.deleteIndexList removeObject:article];
    }
    self.deleteBarButtonItem.enabled = [self.deleteIndexList count] > 0;
}

#pragma mark - Popover Methods
- (void)selectedActionButton:(UIButton *)sender{

    self.selectedArticle = [self.favoriteList objectAtIndex:sender.tag];

    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    ArticleActionTableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:ip];

    FavoriteActionViewController *clController = [[FavoriteActionViewController alloc] initWithNibName:@"FavoriteActionViewController" bundle:nil];
    clController.delegate = self;
    clController.view.backgroundColor = [UIColor redColor];
    clController.modalPresentationStyle = UIModalPresentationPopover;
    clController.preferredContentSize = CGSizeMake(self.view.frame.size.width, 88);
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

- (void)favoriteActionTableViewDidSelectedAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.row == 0 ) {
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@""
                                                                           message:@"このお気に入りを削除します。よろしいですか？"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        [alertCtrl addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
            self.selectedArticle = nil;
        }]];
        [alertCtrl addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self removeFavoriteInArray:@[self.selectedArticle]];
            self.selectedArticle = nil;
        }]];
        [self presentViewController:alertCtrl animated:YES completion:nil];
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
                                                                       message:@"全てのお気に入りを削除します。よろしいですか？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleCancel handler:nil]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"***** 全ての削除の処理 *****");
        [self removeFavoriteInArray:[NSArray arrayWithArray:self.favoriteList]];
    }]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}


- (IBAction)cancelSelectionDelete:(UIBarButtonItem *)sender {
    [self toggleEditingMode:NO];
}

- (IBAction)deleteSelectionList:(UIBarButtonItem *)sender {

    NSString *message = [NSString stringWithFormat:@"選択した%@件をお気に入りから削除してもよろしいですか？",[NSNumber numberWithInteger:[self.deleteIndexList  count]]];
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@""
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self removeFavoriteInArray:self.deleteIndexList];
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

- (void)removeFavoriteInArray:(NSArray *)targetArray {
    for (Article *aritcle in targetArray) {
        [self.favoriteList removeObject:aritcle];
    }

    [ArticleFavorite removeFavoriteWithArticleArray:targetArray complete:^(BOOL success, NSString *message, NSArray *favoriteList) {
        [self showNoticeAlertViewWithMessage:message];
        [self.tableView reloadData];
        if([self.favoriteList count] == 0){
            [self addFavoriteEmptyView];
        }
    }];
}


- (void)showNoticeAlertViewWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
