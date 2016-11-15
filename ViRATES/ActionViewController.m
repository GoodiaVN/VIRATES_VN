//
//  ActionViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/10/15.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "ActionViewController.h"
#import <ASHorizontalScrollViewForObjectiveC/ASHorizontalScrollView.h>

#import "ActionButtonView.h"

@interface ActionViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewConstraintTop;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet ASHorizontalScrollView *menuScrollView;
@property (strong, nonatomic) UIView *rootView;
@property (strong, nonatomic) NSArray *actionTitles;
@property (strong, nonatomic) NSArray *actionImages;

@property (nonatomic, readwrite) BOOL isShowing;
@property (nonatomic) BOOL createdMenu;

@end

@implementation ActionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                       rootView:(UIView *)rootView {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.rootView = rootView;
        self.createdMenu = NO;
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBackgroundView:)];
        tapGesture.delegate = self;
        [self.view addGestureRecognizer:tapGesture];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.actionTitles = [NSArray arrayWithObjects:@"いいねする",@"シェアする",@"ツィートする",@"Lineに送る",@"Safariで開く",@"URLをコピー", nil];
    self.actionImages = [NSArray arrayWithObjects:@"icon_iine",@"icon_facebook",@"icon_twitter",@"icon_line",@"icon_safari",@"icon_copy", nil];
    self.contentViewConstraintTop.constant = self.rootView.frame.size.height;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMenu {

    if(!self.createdMenu) {
        self.menuScrollView.miniAppearPxOfLastItem = 10;
        self.menuScrollView.miniMarginPxBetweenItems = 0;
        self.menuScrollView.uniformItemSize = CGSizeMake(60, 70);
        [self.menuScrollView setItemsMarginOnce];
        NSMutableArray *buttons = [NSMutableArray array];
        for (int i=0; i<6; i++) {
            ActionButtonView *buttonView = [ActionButtonView view];
            buttonView.actionLabel.text = [self.actionTitles objectAtIndex:i];
            [buttonView.actionbutton setImage:[UIImage imageNamed:[self.actionImages objectAtIndex:i]] forState:UIControlStateNormal];
            buttonView.actionbutton.tag = i;
            [buttonView.actionbutton addTarget:self action:@selector(pressedMenuButton:) forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:buttonView];
        }

        [self.menuScrollView addItems:buttons];
        self.createdMenu = YES;
    }

    self.isShowing = YES;
    CGRect rootFrame = self.rootView.frame;
    rootFrame.origin.y = 0;
    self.view.frame = rootFrame;
    CGRect menuFrame = self.contentView.frame;
    menuFrame.origin.y = self.view.frame.size.height - menuFrame.size.height;
    self.contentViewConstraintTop.constant = menuFrame.origin.y;
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                        [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                     }];
}

- (void)hideMenu {
    self.isShowing = NO;
    CGRect rootFrame = self.rootView.frame;
    rootFrame.origin.y = self.view.frame.size.height;
    CGRect menuFrame = self.contentView.frame;
    menuFrame.origin.y += menuFrame.size.height;
    self.contentViewConstraintTop.constant = menuFrame.origin.y;
   [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.view.frame = rootFrame;
                     }];
}

- (void)pressedMenuButton:(UIButton *)button {
    [self hideMenu];
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(actionView:didSelectMenuAtIndex:)]){
        [self.delegate actionView:self didSelectMenuAtIndex:button.tag];
    }
}

- (void)handleTapBackgroundView:(UITapGestureRecognizer *)sender {
    NSLog(@"handleTapRootView");
    [self hideMenu];
}

- (IBAction)pressedCancel:(UIButton *)sender {
    [self hideMenu];
}

#pragma mark -
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != self.view) {
        return NO;
    }

    return YES;
}
@end
