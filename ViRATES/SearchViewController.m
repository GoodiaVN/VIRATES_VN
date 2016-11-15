//
//  SearchViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/07/25.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchSegmentTableViewController.h"
#import "TagListView.h"
#import "TagView.h"
#import "Article.h"
#import "ViRatesServerClient.h"
#import "ArticleViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define STATUSBAR_HEIGHT 20
#define TITILEHEADER_HEIGHT 35
#define VERTICAL_MARGIN 20

@interface SearchViewController () <UISearchBarDelegate,TagListViewDelegate,SearchSegmentTableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *customNavigationView;

@property (weak, nonatomic) IBOutlet TagListView *historyTagListView;
@property (weak, nonatomic) IBOutlet TagListView *noticeTagListView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyTLViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noticeTLViewHeightConstraint;

@property (strong, nonatomic) SearchSegmentTableViewController *searchTableViewCtrl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) NSMutableArray *localHistoryTagArray;
@property (strong, nonatomic) NSArray *keywords;
@property (nonatomic) CGFloat tagListViewHeight;


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.searchBar.backgroundImage = [UIImage new];

    [self setUpTagViews];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.searchTableViewCtrl = [[SearchSegmentTableViewController alloc] initWithNibName:@"SearchSegmentTableViewController" bundle:nil];
    CGSize s_size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height -self.customNavigationView.frame.size.height-20);
    self.searchTableViewCtrl.view.frame = CGRectMake(0, self.customNavigationView.frame.size.height, s_size.width, s_size.height);
    self.searchTableViewCtrl.delegate = self;

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.containerView addGestureRecognizer:gestureRecognizer];

    [self setUpSearchHistoryTag];

    self.keywords = [NSArray array];
    ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
    [[client sendKeywordRequest] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [ViRatesServerRespons convertObjectToJsonDictionary:responseObject];
        if( result ) {
            self.keywords = result[@"list"];
            [self setUpNoticeTag];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showNoticeAlertViewWithMessage:@"通信エラー"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideKeyboard {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Tag Setup method

- (void)setUpTagViews {
    self.tagListViewHeight = (self.view.frame.size.height - self.customNavigationView.frame.size.height - STATUSBAR_HEIGHT - (TITILEHEADER_HEIGHT * 2) )/2.0;
    self.historyTLViewHeightConstraint.constant = self.tagListViewHeight;
    self.noticeTLViewHeightConstraint.constant = self.tagListViewHeight - VERTICAL_MARGIN *4;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGRect frame = self.historyTagListView.frame;
    frame.size.width = screenWidth;
    self.historyTagListView.frame = frame;
    self.historyTagListView.delegate = self;
    self.noticeTagListView.frame = frame;
    self.noticeTagListView.delegate = self;
}

- (void)updateTagViewHeight {
    NSInteger row = self.historyTagListView.rows == 0 ? 1 : self.historyTagListView.rows;
    CGFloat newHeight = (row * 26) + 15;
    self.historyTLViewHeightConstraint.constant = newHeight;
    self.noticeTLViewHeightConstraint.constant +=  (self.tagListViewHeight - newHeight);
}

- (void)setUpSearchHistoryTag {
    [self loadSearchHistoryTags];
    for (NSString *tagStr in self.localHistoryTagArray) {
        [self addHistoryTagWithTitle:tagStr];
    }
    [self updateTagViewHeight];
}

- (void)setUpNoticeTag {

    for (NSDictionary *keyword in self.keywords) {
        [self addNoticeTagWithTitle:keyword[@"name"]];
    }
}
- (IBAction)pressedCancelButton:(UIButton *)sender {
    [self dismiss];
}

- (void)addHistoryTagWithTitle:(NSString *)title {
    //タグを更新
    [self.historyTagListView removeTag:title];
    [self.historyTagListView addTag:title];
}

- (void)addNoticeTagWithTitle:(NSString *)title {
    TagView *tagView = [self.noticeTagListView addTag:title];
    CGFloat lastY = tagView.frame.origin.y + tagView.frame.size.height;

    lastY = self.noticeTagListView.tagViewHeight * self.noticeTagListView.rows;
    if(lastY > self.noticeTLViewHeightConstraint.constant - self.noticeTagListView.tagViewHeight){
        [self.noticeTagListView removeTheMostOldestTag];
    }
}


#pragma mark - Tag Delegate Methods
- (void)tagPressedWithTitle:(NSString *)title tagView:(TagView *)tagView tagListView:(TagListView *)tagListView {
    NSLog(@"tag pressed %@",title);
    self.searchBar.text = title;
    if([tagListView isEqual:self.historyTagListView]) {
        [self callForSearchingText:title];
    } else {
        for (NSDictionary *keywordDict in self.keywords) {
            if([[keywordDict objectForKey:@"name"] isEqualToString:title]) {
                [self getArticleWithKeywordURL:[keywordDict objectForKey:@"url"]];
                [self updateHistoryTagsWithText:title];
                break;
            }
        }
    }
}

- (void)tagRemoveButtonPressedWithTitle:(NSString *)title tagView:(TagView *)tagView tagListView:(TagListView *)tagListView {
    [self.historyTagListView  removeTag:title];
    [self.localHistoryTagArray removeObject:title];
    [self updateLocalHistorySearchTags];
    [self updateTagViewHeight];
}

#pragma mark - UISearchBar Delegate Methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchBar.text isEqualToString:@""]){
        [self.searchTableViewCtrl.view removeFromSuperview];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *searchString = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([searchString length] > 0){
        [self callForSearchingText:searchBar.text];
    } else {
        searchBar.text = @"";
    }
}

- (void)updateHistoryTagsWithText:(NSString *)searchText {
    [self addHistoryTagWithTitle:searchText];
    //localデータを更新
    if([self.localHistoryTagArray containsObject:searchText]) {
        [self.localHistoryTagArray removeObject:searchText];
    }
    [self.localHistoryTagArray addObject:searchText];
    [self updateLocalHistorySearchTags];
    [self updateTagViewHeight];
}

- (void)callForSearchingText:(NSString *)searchText {
    [self startSearchText:[searchText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    [self updateHistoryTagsWithText:searchText];
}

#pragma mark - Search Method
- (void)startSearchText:(NSString *)searchText {
    [SVProgressHUD showWithStatus:@"読み込み中..."];
    ViRatesServerArticleRequest *model = [ViRatesServerArticleRequest new];
    ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
    [[client sendSearchArticleRequest:model withURLPath:searchText] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        if(responseObject){

            if([responseObject length] < 5){
                [SVProgressHUD dismiss];
                [self showNoticeAlertViewWithMessage:@"該当する記事はありません"];
                return;
            }

            NSError *error;
            NSDictionary *jsonDict  = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];

            if( [jsonDict objectForKey:@"list"] ) {
                NSMutableArray *articleArray = [NSMutableArray array];
                for (NSDictionary *articleDict in [jsonDict objectForKey:@"list"]) {
                    Article *article = [[Article alloc] initWithDictionaryData:articleDict];
                    [articleArray addObject:article];
                }
                [self showSearchResultViewControllerWithArticleArray:[NSArray arrayWithArray:articleArray]];
            }
        }
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self showNoticeAlertViewWithMessage:@"通信エラー"];
    }];
}

- (void)getArticleWithKeywordURL:(NSString *)url {
    [SVProgressHUD showWithStatus:@"読み込み中..."];
    ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
    [[client sendArticleDetailRequestWithURLPath:url] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [ViRatesServerRespons convertObjectToJsonDictionary:responseObject];
        //NSLog(@"******* result %@",result);
        if( [result objectForKey:@"list"] ) {
            NSMutableArray *articleArray = [NSMutableArray array];
            for (NSDictionary *articleDict in [result objectForKey:@"list"]) {
                Article *article = [[Article alloc] initWithDictionaryData:articleDict];
                [articleArray addObject:article];
            }
            [self showSearchResultViewControllerWithArticleArray:[NSArray arrayWithArray:articleArray]];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self showNoticeAlertViewWithMessage:@"通信エラー"];
    }];
}

#pragma mark - Search TableView Delegate Method
- (void)searchSegmentTable:(UITableView *)tableView didSelectedArticle:(Article *)article withAllArticleArray:(NSArray *)articleArray {
    ArticleViewController *controller = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
    controller.currentArticle = article;
    controller.articleArray = articleArray;
    controller.isSearchResult = YES;

    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Private Methods
- (void)showSearchResultViewControllerWithArticleArray:(NSArray *)articleArray {
    self.searchTableViewCtrl.articleArray = articleArray;
    [self.searchTableViewCtrl loadTableView];
    [self.containerView addSubview:self.searchTableViewCtrl.view];
}

- (void)showNoticeAlertViewWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadSearchHistoryTags {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.virates"];
    NSArray *array = [userDefaults arrayForKey:@"historyTags"];

    if(array != nil && [array count] > 0 ) {
        self.localHistoryTagArray = [NSMutableArray arrayWithArray:array];
    } else {
        self.localHistoryTagArray = [NSMutableArray array];
    }
}

- (void)updateLocalHistorySearchTags {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.virates"];

    if([self.localHistoryTagArray count] > 10) {
        NSString *firstTagStr = [self.localHistoryTagArray firstObject];
        [self.historyTagListView removeTag:firstTagStr];
        [self.localHistoryTagArray removeObject:firstTagStr];
    }

    [userDefaults setObject:self.localHistoryTagArray forKey:@"historyTags"];
    [userDefaults synchronize];

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
