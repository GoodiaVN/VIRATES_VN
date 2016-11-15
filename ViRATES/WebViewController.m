//
//  WebViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/08/20.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "WebViewController.h"
#import <Webkit/WebKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
@interface WebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;
@property (strong, nonatomic) UIWebView *webView;

@end

@implementation WebViewController

- (instancetype)init {
    self = [super init];
    if(self) {
        self.isAd = NO;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isAd = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD showWithStatus:@"読み込み中..."];


    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithTitle:@">" style:UIBarButtonItemStylePlain target:self action:@selector(forward)];
    self.navigationItem.rightBarButtonItems = @[self.forwardButton, self.backButton];
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenSize.size.width, self.view.frame.size.height)];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.delegate = self;
    self.webView.opaque = NO;
    self.webView.scrollView.scrollsToTop = YES;
    [self.view addSubview:self.webView];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"%d:%@",self.isAd,self.urlString);
    if(!self.isAd) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
        self.navigationItem.leftBarButtonItem = doneButton;
    }

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD dismiss];
}

- (void)dismiss {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back {
    if(![self.webView canGoBack]) {
        self.backButton.enabled = NO;
    }
    [self.webView goBack];
}

-(void)forward {
    if(![self.webView canGoForward]) {
        self.forwardButton.enabled = NO;
    }
    [self.webView goForward];
}

#pragma mark - WKWebView Delegate Methods
- (void)webViewDidStartLoad:(UIWebView*)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [SVProgressHUD dismiss];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable responseObj, NSError * _Nullable error) {
        self.title = (NSString *)responseObj;
    }];
    self.backButton.enabled = [webView canGoBack];
    self.forwardButton.enabled = [webView canGoForward];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
    [SVProgressHUD dismiss];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.backButton.enabled = [webView canGoBack];
    self.forwardButton.enabled = [webView canGoForward];

}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (BOOL)shouldAutorotate {
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
