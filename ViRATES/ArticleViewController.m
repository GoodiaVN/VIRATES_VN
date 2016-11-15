//
//  ArticleViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/13.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ArticleViewController.h"
#import <Webkit/WebKit.h>
#import <Social/Social.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ViRatesServerClient.h"
#import "WebViewController.h"
#import "ArticleFavorite.h"
#import "ActionViewController.h"

#define TOOLBAR_HEIGHT 44

@interface ArticleViewController () <MFMailComposeViewControllerDelegate,UIGestureRecognizerDelegate,ActionViewDelegete,UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeLeft;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeRight;
@property (strong, nonatomic) UIImageView *tutorialView;
@property(nonatomic) BOOL isSwipe;
@property(nonatomic) int currentPageNo;

@property (strong, nonatomic) ActionViewController *actionViewController;


@end

@implementation ArticleViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.isFavorite = NO;
        self.isHistory = NO;
        self.isSwipe = NO;
        self.isSearchResult = NO;
        self.forwardButton.enabled = NO;

    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.actionViewController = [[ActionViewController alloc] initWithNibName:@"ActionViewController" bundle:[NSBundle mainBundle] rootView:self.view];
    self.actionViewController.delegate = self;
    CGRect actionMenuFrame = self.actionViewController.view.frame;
    actionMenuFrame.size.width = self.view.frame.size.width;
    actionMenuFrame.size.height = self.view.frame.size.height;
    actionMenuFrame.origin.x = 0;
    actionMenuFrame.origin.y = self.view.frame.size.height;
    self.actionViewController.view.frame = actionMenuFrame;
    [self addChildViewController:self.actionViewController];
    [self.view addSubview:self.actionViewController.view];

    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.webView.scrollView.scrollsToTop = YES;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    CGRect screenSize = [[UIScreen mainScreen] bounds];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, screenSize.size.width, screenSize.size.height-TOOLBAR_HEIGHT-20)];
    self.webView.delegate = self;

    [self.containerView insertSubview:self.webView belowSubview:self.favoriteButton];

    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_top"]];
    CGRect frame = titleImageView.frame;
    frame.size = CGSizeMake(100, 20);
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    titleImageView.frame = frame;
    self.navigationItem.titleView = titleImageView;

    if(!self.isHistory && !self.isFavorite && !self.pushOrWidget) {

        self.swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        self.swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        self.swipeLeft.numberOfTouchesRequired = 1;
        [self.webView addGestureRecognizer:self.swipeLeft];
        self.swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        self.swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        self.swipeRight.numberOfTouchesRequired = 1;
        [self.webView addGestureRecognizer:self.swipeRight];
    }

    if(self.pushOrWidget) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                 target:self
                                                 action:@selector(dismissModalView)];
    }

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    if(!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [self.activityIndicator setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2)];
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.hidesWhenStopped = YES;
        [self.view addSubview:self.activityIndicator];
    }

    [self loadData];
}

-(void)dismissModalView {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.isSearchResult){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

-(void)swipe:(UISwipeGestureRecognizer*)gesture {
    if(gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        [self goToPreviousArticle];
    }else if(gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self goToNextArticle];
    }
}

- (void)loadData {

    [self.activityIndicator startAnimating];

    self.forwardButton.enabled = NO;

    if([self.articleArray count] > 0) {
        for(int i = 0 ; i < [self.articleArray count] ; i++) {
            Article *tmpArticle = [self.articleArray objectAtIndex:i];
            if([self.currentArticle.aId isEqualToNumber:tmpArticle.aId]) {
                self.currentPageNo = i;
                break;
            }
        }
    }

    NSString *urlString = [NSString stringWithFormat:@"api-page_new/%@",self.currentArticle.aId];
    ViRatesServerArticleRequest *model = [ViRatesServerArticleRequest new];
    ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
    [[client sendArticleDetailRequest:model withURLPath:urlString]  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [ViRatesServerRespons convertObjectToJsonDictionary:responseObject];
        if( result ) {
            if (self.currentArticle.title == nil || [self.currentArticle.title isEqualToString:@""]) {
                self.currentArticle.title = [[[result objectForKey:@"list"] objectAtIndex:0] objectForKey:@"title"];
            }

            NSString *html = [NSString stringWithFormat:@"%@",[[[result objectForKey:@"list"] objectAtIndex:0] objectForKey:@"html"]];
            
            if(![[[[result objectForKey:@"list"] objectAtIndex:0] objectForKey:@"comment"] isEqual:[NSNull null]]) {
                html = [html stringByReplacingOccurrencesOfString:@"#comments{display:none;}" withString:@""];
            }

            int viewCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"viewCount"];
            if(viewCount < 4) {
                viewCount++;
                [[NSUserDefaults standardUserDefaults] setInteger:viewCount forKey:@"viewCount"];
            }

            self.favoriteButton.hidden = NO;
            if(self.currentArticle.isFavorite) {
                [self.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_on"] forState:UIControlStateNormal];
            } else {
                [self.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_off"] forState:UIControlStateNormal];
            }
            [self addHistory];
            [self.webView loadHTMLString:html baseURL:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"****error*** %@", [error description]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissTutorial {
    [self.tutorialView removeFromSuperview];
    self.webView.userInteractionEnabled = YES;
}

#pragma mark - WKWebView Delegate Methods
-(void)webViewDidStartLoad:(UIWebView*)webView {
    self.webView.frame = CGRectMake(0, 20,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-TOOLBAR_HEIGHT-20);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
-(void)webViewDidFinishLoad:(UIWebView*)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"$('#ad_bottom').hide();"];
    [self.activityIndicator stopAnimating];
    self.webView.hidden = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    int viewCount = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"viewCount"];
    if(viewCount == 3 && self.tutorialView == nil) {
        self.tutorialView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial"]];
        [self.tutorialView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTutorial)];
        [self.tutorialView addGestureRecognizer:recognizer];
        self.tutorialView.userInteractionEnabled = YES;
        [self.view addSubview:self.tutorialView];
        self.webView.userInteractionEnabled = NO;
    }

    self.forwardButton.enabled = [webView canGoForward];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *url = [[request URL]absoluteString];
    if([url isEqualToString:@"https://platform.twitter.com/jot.html"]) {
        return NO;
    }

    if ([[[request URL] scheme] isEqualToString:@"virates"]) {
        if([[[request URL] host] isEqualToString:@"facebook"]) {
            [self shareFacebook];
        }else if([[[request URL] host] isEqualToString:@"twitter"]) {
            [self shareTwitter];
        }else if([[[request URL] host] isEqualToString:@"line"]) {
            [self shareLine];
        }else if([[[request URL] host] isEqualToString:@"videoinfo"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"動画について" message:@"本アプリで閲覧できない動画は、Safari版ViRATESでご覧ください" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.currentArticle.link]];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }

        return NO;
    }else if([[[request URL] scheme] isEqualToString:@"related"]) {
        NSArray *tmpArray = [[[request URL] absoluteString] componentsSeparatedByString:@"/"];
        Article *article = [[Article alloc] init];
        NSNumber *articleId =[NSNumber numberWithInteger:[[[tmpArray objectAtIndex:4] substringFromIndex:2] integerValue]];
        article.aId = articleId;
        self.currentArticle = article;
        [self loadData];
        return NO;
    } else if([[[request URL] absoluteString] isEqualToString:@"http://virates.com/wp-comments-post.php"]) {
        NSString *comment = [webView stringByEvaluatingJavaScriptFromString:@"document.cform.comment.value"];

        if([comment length] < 3) {
            [self showNoticeAlertViewWithMessage:@"3文字以上入力してください"];
            return NO;
        }

        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
        [SVProgressHUD showWithStatus:@"送信中..."];

        ViRatesServerSendCommentRequest *model = [ViRatesServerSendCommentRequest new];
        model.aId =[NSString stringWithFormat:@"%@",self.currentArticle.aId];
        model.comment = comment;
        ViRatesServerClient *client = [ViRatesServerClient sharedInstance];
        [[client sendCommentRequest:model] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [SVProgressHUD dismiss];
            [self showNoticeAlertViewWithMessage:@"送信しました"];
            NSString *date = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSString *script = [NSString stringWithFormat:@"var div_element = document.createElement(\"div\");div_element.innerHTML = '<li class=\"comment\"><div class=\"comment-body\"><div class=\"comment-meta commentmetadata\">%@</div><p>%@</p></li>';var parent_object = document.getElementById(\"clist\");parent_object.appendChild(div_element);",date,comment];

            [webView stringByEvaluatingJavaScriptFromString:script];
            [webView stringByEvaluatingJavaScriptFromString:@"document.cform.comment.value=''"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD dismiss];
            [self showNoticeAlertViewWithMessage:@"通信エラー"];
        }];

        return NO;
    } else if (navigationType == WKNavigationTypeLinkActivated) {
        if([[[request URL] host] rangeOfString:@"nend"].location != NSNotFound ||
           [[[request URL] host] rangeOfString:@"i-mobile.co.jp"].location != NSNotFound
           || [[[request URL] host] rangeOfString:@"virates.com"].location != NSNotFound
           || [[[request URL] host] rangeOfString:@"gunosy.com"].location != NSNotFound
           || [[[request URL] host] rangeOfString:@"amoad.com"].location != NSNotFound) {
            [[UIApplication sharedApplication] openURL:[request URL]];
            return NO;
        }

        if([[[request URL] absoluteString] rangeOfString:@"https://www.facebook.com/dialog/feed?app_id=541595295946288"].location != NSNotFound) {
            [self shareFacebook];
             return NO;
        }else if([[[request URL] absoluteString] rangeOfString:@"https://twitter.com/intent/tweet"].location != NSNotFound) {
            NSArray *arr = [[[request URL] absoluteString] componentsSeparatedByString:@"&"];
            NSString *q_title = [[[[arr objectAtIndex:2] componentsSeparatedByString:@"="] objectAtIndex:1] stringByRemovingPercentEncoding];
            SLComposeViewController *slComposeViewController;
            slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [slComposeViewController setInitialText:q_title];
            [slComposeViewController addURL:[NSURL URLWithString:self.currentArticle.link]];
            slComposeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
                if(result == SLComposeViewControllerResultDone) {
                  /*  id tracker = [[GAI sharedInstance] defaultTracker];
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"sharre"
                                                                          action:@"Twitter"
                                                                           label:shareTitle
                                                                           value:nil] build]];*/
                }
            };
            [self presentViewController:slComposeViewController animated:YES completion:nil];
            return NO;
        }else if([[[request URL] absoluteString] rangeOfString:@"http://line.me/R/msg/text/?"].location != NSNotFound) {
            NSArray *arr = [[[request URL] absoluteString] componentsSeparatedByString:@"http://line.me/R/msg/text/?"];
            NSString *tmplineString = [arr objectAtIndex:1];
            NSString *q_description = [[[tmplineString componentsSeparatedByString:@"applewebdata"] objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString *downloadlink = @"http://virates.com/downloadline";
            NSString *lineString = [NSString stringWithFormat:@"line://msg/text/%@\n%@\n無料アプリDL→ %@",q_description, self.currentArticle.link, downloadlink];

            lineString =[lineString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
/*            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"sharre"
                                                                  action:@"LINE"
                                                                   label:shareTitle
                                                                   value:nil] build]];*/
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:lineString]];
            return NO;
        } else {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[request URL] absoluteString]]]];
            return NO;
        }
    }

    return YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"%@",error);
    if ([error code] != NSURLErrorCancelled && ![[[error userInfo] objectForKey:@"NSErrorFailingURLStringKey"] isEqualToString:@"https://platform.twitter.com/jot.html"]) {
        UIView *errorView = [[UIView alloc] initWithFrame:CGRectMake(0, webView.frame.size.height, webView.frame.size.width, 30)];
        errorView.backgroundColor = [UIColor blackColor];
        errorView.alpha = 0.4;
        UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, webView.frame.size.width, 30)];
        errorLabel.text = @"通信エラー";
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.textColor = [UIColor whiteColor];
        [errorView addSubview:errorLabel];
        [webView addSubview:errorView];

        [UIView animateWithDuration:0.5f
                              delay:0.5f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             errorView.frame = CGRectMake(0, webView.frame.size.height-30, errorView.frame.size.width, errorView.frame.size.height);
                         } completion:^(BOOL finished) {
                             [self performSelector:@selector(hideErrorView:) withObject:errorView afterDelay:2.0];
                         }];
    }
}

-(void)hideErrorView:(UIView*)errorView {
    [errorView removeFromSuperview];
}



- (void)procressAfterComment:(WKWebView *)webView {

}

- (void)goToPreviousArticle {
    self.isSwipe = YES;

    if(self.currentPageNo - 1 >= 0) {
        self.currentPageNo--;
        self.currentArticle = [self.articleArray objectAtIndex:self.currentPageNo];
        [UIView animateWithDuration:0.4f
                         animations:^{
                             self.webView.frame = CGRectMake(self.view.frame.size.width, 20, self.webView.frame.size.width, self.webView.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             self.webView.hidden = YES;
                             [self loadData];
                         }
         ];
    }
}

- (void)goToNextArticle {

    self.isSwipe = YES;

    if(self.currentPageNo + 1 < [self.articleArray count]){
        self.currentPageNo++;
        self.currentArticle = [self.articleArray objectAtIndex:self.currentPageNo];
        [UIView animateWithDuration:0.4f
                         animations:^{
                             self.webView.frame = CGRectMake(-self.view.frame.size.width, 20, self.webView.frame.size.width, self.webView.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             self.webView.hidden = YES;
                             [self loadData];
                         }
         ];
    }

}
#pragma mark - ActionView Delegate
- (void)actionView:(ActionViewController *)actionSheetCtrl didSelectMenuAtIndex:(NSInteger)index {
    if(index == 0){

    } else if(index == 1){
        [self shareFacebook];
    } else if(index == 2){
        [self shareTwitter];
    } else if(index == 3){
        [self shareLine];
    } else if(index == 4){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.currentArticle.link]];
    } else if(index == 5){
        [self copyUrl];
        [self showNoticeAlertViewWithMessage:@"URLをコピーしました"];
    }
}
#pragma mark - Toolbar Method
- (IBAction)pressedBackButton:(UIButton *)sender {
    if(![self.webView canGoBack]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.webView goBack];
    }
}

- (IBAction)pressedForwardButton:(UIButton *)sender {
    if(![self.webView canGoForward]) {
        self.forwardButton.enabled = NO;
    }
    [self.webView goForward];
}

- (IBAction)pressedFacebookButton:(UIButton *)sender {
    [self shareFacebook];
}

- (IBAction)pressedTwitterButton:(UIButton *)sender {
    [self shareTwitter];
}

- (IBAction)pressedLineButton:(UIButton *)sender {
    [self shareLine];
}
- (IBAction)pressedMailButton:(UIButton *)sender {
    [self sendMail];
}

- (IBAction)pressedActionButton:(UIButton *)sender {

    if(self.actionViewController.isShowing){
        [self.actionViewController hideMenu];
    }else {
        [self.actionViewController showMenu];
    }

}

- (IBAction)pressedFavoriteButton:(UIButton *)sender {
    [self addFavorite];
}

- (void)addFavorite {
    if(self.currentArticle.isFavorite) {
        [ArticleFavorite removeFavoriteWithArticleArray:@[self.currentArticle] complete:^(BOOL success, NSString *message, NSArray *favoriteList) {
            self.currentArticle.isFavorite = NO;
            [self showNoticeAlertViewWithMessage:message];
            [self.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_off"] forState:UIControlStateNormal];
        }];
    } else {
        [ArticleFavorite addFavoriteWithArticle:self.currentArticle complete:^(BOOL success, NSString *message, NSArray *favoriteList) {
            if(success) {
                self.currentArticle.isFavorite = YES;
                [self.favoriteButton setImage:[UIImage imageNamed:@"icon_favorite_on"] forState:UIControlStateNormal];
            }
            [self showNoticeAlertViewWithMessage:message];
        }];
    }
}

- (void)addHistory {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.virates"];
    NSArray *array = [userDefaults arrayForKey:@"histories"];
    if( array == nil ){
        array = [NSArray array];
    }

    NSMutableArray *marray;
    if([array containsObject:self.currentArticle.aId]) {
        marray = [NSMutableArray arrayWithArray:array];
        [marray removeObject:self.currentArticle.aId];
        [marray insertObject:self.currentArticle.aId atIndex:0];
    } else {
        marray = [NSMutableArray array];
        [marray addObject:self.currentArticle.aId];
        for (NSString *object in array) {
            [marray addObject:object];
        }
    }

    if([array count] > 200) {
        [marray removeLastObject];
    }

    [userDefaults setObject:marray forKey:@"histories"];
    [userDefaults synchronize];

}


#pragma mark - Share To SNS Mehtods

-(void)shareFacebook {
    SLComposeViewController *slComposeViewController;
    slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [slComposeViewController setInitialText:[NSString stringWithFormat:@"%@ - ViRATES[バイレーツ]", self.currentArticle.title]];
    [slComposeViewController addURL:[NSURL URLWithString:self.currentArticle.link]];

    slComposeViewController.completionHandler = ^(SLComposeViewControllerResult result) {
           };
    [self presentViewController:slComposeViewController animated:YES completion:nil];
}

-(void)shareTwitter {
    SLComposeViewController *slComposeViewController;
    slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [slComposeViewController setInitialText:[NSString stringWithFormat:@"%@ - ViRATES[バイレーツ] ", self.currentArticle.title]];
    [slComposeViewController addURL:[NSURL URLWithString:self.currentArticle.link]];
    slComposeViewController.completionHandler = ^(SLComposeViewControllerResult result) {

    };
    [self presentViewController:slComposeViewController animated:YES completion:nil];
}

-(void)shareLine {
    NSString *lineString = [NSString stringWithFormat:@"line://msg/text/%@ - ViRATES[バイレーツ]\n %@\n無料アプリDL→ %@", self.currentArticle.title, self.currentArticle.link,@"http://virates.com/downloadline"];
    lineString = [lineString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:lineString]];
}

-(void)sendMail {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;

    [picker setSubject:@"オススメ記事"];
    NSString *body = [NSString stringWithFormat:@"%@\n\n%@",self.currentArticle.title, self.currentArticle.link];
    [picker setMessageBody:body isHTML:NO];

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)copyUrl {
    [UIPasteboard generalPasteboard].string = self.currentArticle.link;
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
