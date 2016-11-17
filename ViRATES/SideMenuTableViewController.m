//
//  SideMenuTableViewController.m
//  ViRATES
//
//  Created by 金具 修平 on 2016/06/30.
//  Copyright © 2016年 hunting. All rights reserved.
//

#import "SideMenuTableViewController.h"
#import "SideMenuLogoTableViewCell.h"
#import "SideMenuTableViewCell.h"
#import "FavoriteViewController.h"
#import "HistoryViewController.h"
#import "SettingViewController.h"

#import <iOS-Slide-Menu/SlideNavigationController.h>

#define TWITTERURL @"https://twitter.com/ViRATEScom"

@interface SideMenuTableViewController ()
@property (strong, nonatomic) NSArray *menuTitleArray;
@property (strong, nonatomic) NSArray *iconTitleArray;
@end

@implementation SideMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuTitleArray = [NSArray arrayWithObjects:@"ホーム",
                                                    @"お気に入り",
                                                    @"閲覧履歴",
                                                    @"facebookいいね!",
                                                    @"twitterフォロー",
                                                    @"ViRATESを紹介",
                                                    @"レビューを書く",
                                                    @"設定", nil];
    self.iconTitleArray = [NSArray arrayWithObjects:@"home",
                                                    @"favorite",
                                                    @"history",
                                                    @"facebook",
                                                    @"twitter",
                                                    @"introduce",
                                                    @"review",
                                                    @"setting", nil];

    UINib *menuLogoNib = [UINib nibWithNibName:@"SideMenuLogoTableViewCell" bundle:nil];
    [self.tableView registerNib:menuLogoNib forCellReuseIdentifier:@"SideMenuLogoTableViewCell"];

    UINib *nib = [UINib nibWithNibName:@"SideMenuTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SideMenuTableViewCell"];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.scrollsToTop = NO;
    [self.tableView reloadData];
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);

    // ホームの選択を設定
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:1];
    SideMenuTableViewCell *cell = [self.tableView cellForRowAtIndexPath:ip];
    [cell setSelectedCellView:[NSString stringWithFormat:@"%@_r",self.iconTitleArray[0]]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }else {
        return [self.menuTitleArray count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.section == 0){
        SideMenuLogoTableViewCell *cell = (SideMenuLogoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SideMenuLogoTableViewCell"];
        return cell;
    }else{
       SideMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuTableViewCell"];
        cell.iconImageView.image = [UIImage imageNamed:self.iconTitleArray[indexPath.row]];
        cell.menuLabel.text = self.menuTitleArray[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        return 54.0f;
    }

    return 66.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        for (NSInteger i = 0 ; i <[self.iconTitleArray count] ; i++) {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:1];
            SideMenuTableViewCell *cell = [tableView cellForRowAtIndexPath:ip];
            [cell setUnSelectCellView:self.iconTitleArray[i]];
        }
        SideMenuTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *redIcon = [NSString stringWithFormat:@"%@_r",self.iconTitleArray[indexPath.row]];
        [cell setSelectedCellView:redIcon];
    }

    if(indexPath.row == 0){
        [SlideNavigationController sharedInstance].rightMenu = nil;
        [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:NO];
    } else if(indexPath.row == 1){
        if([[SlideNavigationController sharedInstance].rightMenu isKindOfClass:[FavoriteViewController class]]) {
            [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
            return;
        } else {
            FavoriteViewController *vc = [[FavoriteViewController alloc] initWithNibName:@"FavoriteViewController" bundle:nil];
            [SlideNavigationController sharedInstance].rightMenu = vc;

            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                     withSlideOutAnimation:NO
                                                                             andCompletion:nil];
        }
    } else if (indexPath.row == 2){
        if([[SlideNavigationController sharedInstance].rightMenu isKindOfClass:[HistoryViewController class]]) {
            [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
            return;
        } else {
            HistoryViewController *vc = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
            [SlideNavigationController sharedInstance].rightMenu = vc;

            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                     withSlideOutAnimation:NO
                                                                             andCompletion:nil];
        }
    } else if(indexPath.row == 3){
        UIAlertController *alert = [UIAlertController  alertControllerWithTitle:@""
                                                                        message:@"ViRATESのfacebookページにいいね！をしますか？"
                                                                 preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://profile/670470033009038"]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/670470033009038"]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/setariv"]];
            }
        }]];

        [self.view.window.rootViewController presentViewController:alert animated:YES completion:nil];
    } else if (indexPath.row == 4){
        // twitter
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTERURL]];
    } else if (indexPath.row == 5) {
        // 紹介
        NSArray *items = [NSArray arrayWithObjects: @"Virates APP" ,nil];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];

        activityVC.excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];

        [self.view.window.rootViewController presentViewController:activityVC animated:YES completion:nil];
    } else if (indexPath.row == 6) {
        // レビュー
    } else if (indexPath.row == 7) {
        if([[SlideNavigationController sharedInstance].rightMenu isKindOfClass:[SettingViewController class]]) {
            [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
            return;
        } else {
            SettingViewController *vc = [[SettingViewController alloc] init];
            [SlideNavigationController sharedInstance].rightMenu = vc;

            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                     withSlideOutAnimation:NO
                                                                             andCompletion:nil];
        }


    }
}

@end
